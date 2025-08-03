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

        # for path_id in pathways:
        #     pathways[path_id].to.preview_textures.clear()
        #     pathways[path_id].to.preview_rectangular.visible = false

        var vps: Array = []
        for path_id in pathways:
            var path := pathways[path_id]

            var light_vp := path.to._generate_preview_texture(path, 16, null)
            vps.append([path, light_vp])
        
        # await get_tree().create_timer(0.2).timeout
        await get_tree().process_frame
        # await get_tree().process_frame
        # await get_tree().process_frame
        RenderingServer.force_draw()

        # trect.texture = ImageTexture.create_from_image(vps[0][1].get_texture().get_image())

        # await RenderingServer.frame_post_draw

        for info in vps:
            var img := ImageTexture.create_from_image(info[1].get_texture().get_image())
            info[0].light_rect.texture = img.duplicate(0)
            info[1].free()

        for path_id in pathways:
            var path := pathways[path_id]

            var to_path := path.to_room.pathways[path.to_id]
            var to_offset := to_path.position
            # path.to.preview_rectangular.global_position = path.global_position - to_offset
            path.light_rect.global_position = path.global_position - to_offset

            var player := Player.get_instance(self)
            if abs(path.global_position.y - player.global_position.y) > 256:
                continue
            if abs(path.global_position.x - player.global_position.x) > 256:
                continue

            ray.global_position = player.global_position
            ray.target_position = path.global_position
            path.force_update_transform()
            
            if ray.is_colliding():
                path.light_rect.visible = false
            else:
                path.light_rect.visible = true

            # var mat := path.to.preview_rectangular.material as ShaderMaterial

            # var area2d = path.to.find_children("*", "Area2D", false)[0]
            # var aabb := get_collision_shape_aabb(area2d.get_child(0).polygon)
            # path.to.preview_rectangular.visible = true
            # path.to.preview_rectangular.size = aabb.size

            # mat.set_shader_parameter("u_textures", path.to.preview_textures)
            # mat.set_shader_parameter("u_texture_count", path.to.preview_textures.size())
        
        # get_tree().create_timer(0.5).timeout.connect(

        # print("AA")

# @export var closest_active_to_player: DoorPathway
@export var player_instance: Player
@export var schizo_active_room: SchizoRoom

# @export var preview_rectangular: ColorRect
# var preview_textures: Array[Texture2D] = []

# @export var preview_vp: SubViewport

func _generate_preview_texture(path: DoorPathway, cull_mask: int, exclude_other: SubViewport) -> SubViewport:
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
            if d.name == "Hidden":
                d.visible = true
            vp.add_child(d)
            d.owner = get_tree().edited_scene_root

    if Engine.is_editor_hint():
        for child in schizo_active_room.get_children():
            if child is not SubViewport:
                var d = child.duplicate(0)
                if d.name == "Hidden":
                    d.visible = true
                vp.add_child(d)
                d.owner = get_tree().edited_scene_root
                var pos = path.to.pathways[path.to_id].global_position - (path.global_position - child.global_position) - self.global_position
                d.global_position = pos
    else:
        for child in SchizoRoom.active_room.get_children():
            if child is not SubViewport:
                var d = child.duplicate(0)
                vp.add_child(d)
                d.owner = get_tree().edited_scene_root
                var pos = path.to.pathways[path.to_id].global_position - (path.global_position - child.global_position) - self.global_position
                d.global_position = pos

    var player := player_instance if Engine.is_editor_hint() else Player.get_instance(self)
    # var player := Player.get_instance(self)
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

func _process(_delta: float) -> void:
    if Engine.is_editor_hint():
        return

    if not active:
        return
    
    if Engine.get_frames_drawn() % 30 == 0:
        fuck_this = true
        # assert(false)

    # var player := Player.get_instance(self)
    # for path_id in pathways:
    #     var path := pathways[path_id]
    #     path.to.preview_textures.clear()
    #     path.to.preview_rectangular.visible = false

    # var vps := []
    # for path_id in pathways:
    #     var path := pathways[path_id]

    #     if abs(path.global_position.y - player.global_position.y) > 256:
    #         continue
    #     if abs(path.global_position.x - player.global_position.x) > 256:
    #         continue

    #     ray.global_position = player.global_position
    #     ray.target_position = path.global_position
    #     path.force_update_transform()
        
    #     if ray.is_colliding():
    #         continue
        
    #     var light_vp := path.to._generate_preview_texture(path, 16, null)
    #     vps.append([path, light_vp])

    #     if path.a_glimpse_to_the_past_lights != null:
    #         var to_path := path.to_room.pathways[path.to_id]
    #         var to_offset := to_path.position
    #         path.to.preview_rectangular.global_position = path.global_position - to_offset

    # await get_tree().process_frame
    # RenderingServer.force_draw()

    # for info in vps:
    #     info[0].to.preview_textures.append(info[1].get_texture().duplicate(0))

    # for path_id in pathways:
    #     var path := pathways[path_id]
    #     var mat := path.to.preview_rectangular.material as ShaderMaterial

    #     var area2d = path.to.find_children("*", "Area2D", false)[0]
    #     var aabb := get_collision_shape_aabb(area2d.get_child(0).polygon)
    #     path.to.preview_rectangular.size = aabb.size

    #     mat.set_shader_parameter("u_textures", path.to.preview_textures)
    #     mat.set_shader_parameter("u_texture_count", path.to.preview_textures.size())


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