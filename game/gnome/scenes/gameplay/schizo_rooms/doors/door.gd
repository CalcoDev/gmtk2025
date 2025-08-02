class_name FrickingDoor
extends Node2D

func _ready() -> void:
    var area: Area2D = $"Area2D"
    area.body_entered.connect(_body_entered)
    area.body_exited.connect(_body_exited)

func _body_entered(other: Node2D) -> void:
    var p := Player.get_instance(self)
    if other != p:
        return
    var path := _get_path()
    var to_path := path.to_room.pathways[path.to_id]
    var to_offset := to_path.position
    path.to_room.global_position = path.global_position - to_offset

func _body_exited(other: Node2D) -> void:
    pass

func _get_path() -> DoorPathway:
    var room := _get_door_parent()
    var min_dst := 99999.9
    var ret_path: DoorPathway
    for path_id in room.pathways:
        # print(path_id)
        var path := room.pathways[path_id]
        var dist := path.global_position.distance_to(global_position)
        if dist < min_dst:
            min_dst = dist
            ret_path = path
    return ret_path

func _get_door_parent() -> SchizoRoom:
    # var p := get_parent()
    # while p is not SchizoRoom:
    #     p = p.get_parent()
    # return p
    return SchizoRoom.active_room