@tool
class_name SchizoRoom
extends Node2D

static var active_room: SchizoRoom
static var all_rooms: Array[SchizoRoom] = []

var ray: RayCast2D

@export var pathways: Dictionary[String, DoorPathway] = {}

var active := false:
    set(value):
        active = value
        if Engine.is_editor_hint():
            return
        if active:
            self.visibility_layer = self.visibility_layer | 8
        else:
            self.visibility_layer = self.visibility_layer & 1048567

func get_collision_shape_aabb(polygon: PackedVector2Array) -> Rect2:
    var points = polygon
    if points.size() == 0:
        return Rect2(0, 0, 0, 0)
    
    var min_pos = points[0]
    var max_pos = points[0]
    
    for point in points:
        min_pos.x = min(min_pos.x, point.x)
        min_pos.y = min(min_pos.y, point.y)
        max_pos.x = max(max_pos.x, point.x)
        max_pos.y = max(max_pos.y, point.y)
    
    var p  = min_pos
    var size = max_pos - min_pos
    return Rect2(p, size)

@export var trect: TextureRect

@export var fuck_this := false:
    set(value):
        fuck_this = false
        _generate_preview_textures_plural(closest_active_to_player)
@export var closest_active_to_player: DoorPathway
@export var player_instance: Player
@export var schizo_active_room: SchizoRoom

func _generate_preview_textures_plural(path: DoorPathway) -> void:
    # var color_vp := _generate_preview_texture(16)
    var light_vp := _generate_preview_texture(path, 16, null)

    # if color_vp == null or light_vp == null:
    if light_vp == null:
        return

    await get_tree().process_frame
    RenderingServer.force_draw()

    if not Engine.is_editor_hint():
        # a_glimpse_to_the_past_colours = ImageTexture.create_from_image(color_vp.get_texture().get_image()).duplicate()
        path.a_glimpse_to_the_past_lights = ImageTexture.create_from_image(light_vp.get_texture().get_image()).duplicate()
        # remove_child(color_vp)
        remove_child(light_vp)
        # color_vp.free()
        light_vp.free()


func _generate_preview_texture(paath: DoorPathway, cull_mask: int, exclude_other: SubViewport) -> SubViewport:
    var path := closest_active_to_player if Engine.is_editor_hint() else paath
    var close := path
    # if close.to != self:
        # return null
    # print("acctually doing something")

    var aabb := get_collision_shape_aabb($"Area2D".get_child(0).polygon)
    var vp := SubViewport.new()
    add_child(vp)
    vp.size = aabb.size
    vp.disable_3d = true
    vp.transparent_bg = true
    vp.handle_input_locally = false
    vp.snap_2d_transforms_to_pixel = true
    vp.snap_2d_vertices_to_pixel = true
    vp.canvas_cull_mask = cull_mask
    vp.owner = get_tree().edited_scene_root
    vp.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
    for child in get_children():
        if child != vp and child != exclude_other and child is not SubViewport:
            var d = child.duplicate(0)
            vp.add_child(d)
            d.owner = get_tree().edited_scene_root

    for child in SchizoRoom.active_room.get_children():
    # for child in schizo_active_room.get_children():
        if child is not SubViewport:
            var d = child.duplicate(0)
            vp.add_child(d)
            d.owner = get_tree().edited_scene_root
            var pos = path.to.pathways[path.to_id].global_position - (path.global_position - child.global_position) - self.global_position
            d.global_position = pos

    var player := player_instance if Engine.is_editor_hint() else Player.get_instance(self)
    var light: PointLight2D
    if Engine.is_editor_hint():
        var lights =  player_instance.find_children("*", "PointLight2D", true)
        for l: PointLight2D in lights:
            if l.range_item_cull_mask ==2 :
                light = l.duplicate()
                break
    else:
        light = player.get_light_child().duplicate()

    vp.add_child(light)
    light.owner = get_tree().edited_scene_root
    light.global_position = path.to.pathways[path.to_id].global_position - (path.global_position - player.global_position) - self.global_position

    vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    return vp

@export var area: Area2D

func _ready() -> void:
    if Engine.is_editor_hint():
        return

    all_rooms.append(self)
    area.area_entered.connect(_on_area_entered)
    area.area_exited.connect(_on_area_exited)
    active = false

    $"Hidden".visible = true
    $"Area2D".visible = true

    var hid: TileMapLayer = $"Hidden"
    var bg: TileMapLayer = $"Background"
    for tile in bg.get_used_cells():
        hid.set_cell(tile, 0, Vector2i(3, 3))

    for path: DoorPathway in $"Pathways".get_children():
        pathways[path.id] = path
    
    ray = RayCast2D.new()
    add_child(ray)
    ray.collide_with_areas = false
    ray.collide_with_bodies = true
    ray.collision_mask = 1
    ray.target_position =  Vector2.ZERO
    ray.enabled = false
    ray.hit_from_inside = false

var closest_path_to_player: DoorPathway

func _process(_delta: float) -> void:
    if Engine.is_editor_hint():
        return

    var player := Player.get_instance(self)
    var min_dist := 9999.9
    var closest_path: DoorPathway
    for path_id in pathways:
        var path := pathways[path_id]
        var dist := path.global_position.distance_to(player.global_position)
        if dist < min_dist:
            min_dist = dist
            closest_path = path

    if min_dist < 9996.9:
        closest_path_to_player = closest_path

    if not active:
        if Engine.get_frames_drawn() % 2 == 0:
            for path_id in pathways:
                var path := pathways[path_id]
                # _generate_preview_textures_plural(path)
                path.color_rect.visible = false
                path.light_rect.visible = false
                path.light_rect.z_index = 0
        return


    # var min_dist := 9999.9
    # var closest_path: DoorPathway
    for path_id in pathways:
        var path := pathways[path_id]

        if abs(path.global_position.y - player.global_position.y) > 256:
            continue
        if abs(path.global_position.x - player.global_position.x) > 256:
            continue

        ray.global_position = player.global_position
        ray.target_position = path.global_position
        path.force_update_transform()

        # var dist := path.global_position.distance_to(player.global_position)
        # var zindex := 10 - roundi(dist / 10)
        # print("path ", path_id, " : ", zindex)
        # path.color_rect.z_index = zindex
        # path.light_rect.z_index = zindex
        # print(name)
        # print(closest_path_to_player)
        if path != closest_path_to_player:
            path.light_rect.z_index = -1
        
        if ray.is_colliding():
            path.color_rect.visible = false
            path.light_rect.visible = false
            continue
        
        # if path_id == "right":
        #     return
        # print("drawing preview for ", path_id)

        path.to._generate_preview_textures_plural(path)

        # _generate_preview_textures_plural(path.to.pathways[path.to_id])
        # _generate_preview_textures_plural(path)
        
        # var dist := path.global_position.distance_to(player.global_position)
        # if dist < min_dist:
        #     min_dist = dist
        #     closest_path = path

    #     # print("Trying to move ", path.to_room.name, " to ", name)
        
    #     # move room such that the 2 markers are at same position
        var to_path := path.to_room.pathways[path.to_id]
        var to_offset := to_path.position

        path.color_rect.visible = true
        path.light_rect.visible = true

        path.color_rect.global_position = path.global_position - to_offset
        path.light_rect.global_position = path.global_position - to_offset

        # path.color_rect.texture = path.to_room.pathways[path.to_id].a_glimpse_to_the_past_colours
        # path.color_rect.texture = path.to_room.pathways[path.to_id].a_glimpse_to_the_past_colours
        # path.light_rect.texture = path.to_room.pathways[path.to_id].a_glimpse_to_the_past_lights
        path.light_rect.texture = path.a_glimpse_to_the_past_lights

    #     path.to_room.global_position = path.global_position - to_offset
    #     # print(path.to_room.global_position)
    #     # print("-=-=")

    # if min_dist < 999.9 and Engine.get_frames_drawn() % 30 == 0:
    #     # print(closest_path)
    #     _foresee_the_present(closest_path)

func _exit_tree() -> void:
    if Engine.is_editor_hint():
        return
    all_rooms.erase(self)

func _on_area_entered(_other: Area2D) -> void:
    if Engine.is_editor_hint():
        return
    # print(self.name, " enter ", _other.name)
    Player.get_instance(self).call_deferred("reparent", $"YSort")
    active = true
    active_room = self
    for room in all_rooms:
        if room != active_room:
            room.active = false

func _on_area_exited(_other: Area2D) -> void:
    if Engine.is_editor_hint():
        return
    active = false