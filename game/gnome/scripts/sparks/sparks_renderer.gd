class_name SparksRenderer
extends Node2D

const GROUP := &"spark_renderer"

static func get_active(node: Node) -> SparksRenderer:
    return node.get_tree().get_first_node_in_group(GROUP) as SparksRenderer

func _notification(what: int) -> void:
    if what == NOTIFICATION_ENTER_TREE:
        add_to_group(GROUP)

var _sparks: Dictionary[Spark, Polygon2D] = {}

@warning_ignore("shadowed_variable_base_class")
func spawn_spark(position: Vector2 = Vector2.ZERO, size: Vector2 = Vector2.ONE, angle: float = 0.0, speed: float = 0.0, lifetime: float = 2.0) -> void:
    var spark := Spark.new(position, size, angle, speed, lifetime)
    var p := Polygon2D.new()
    add_child(p)
    if Engine.is_editor_hint():
        p.owner = get_tree().edited_scene_root
    p.polygon = PackedVector2Array([Vector2(3, 0), Vector2(0, 0.5), Vector2(-3, 0), Vector2(0, -0.5)])
    p.global_position = position
    p.visibility_layer = 9
    _sparks[spark] = p

var _delete_queue := []
func process_sparks(delta: float) -> void:
    if _delete_queue.size() > 0:
        _delete_queue.clear()
    for spark in _sparks:
        spark.process(delta)
        if spark.should_die():
            _delete_queue.append(spark)
            continue
        var polygon := _sparks[spark]
        polygon.global_position = spark.position
        polygon.scale = spark.size * spark._get_progress()
        polygon.rotation = spark.angle

    for spark in _delete_queue:
        _sparks[spark].queue_free()
        _sparks.erase(spark)

func _process(delta: float) -> void:
    process_sparks(delta)