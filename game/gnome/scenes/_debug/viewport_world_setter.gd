@tool
extends Node2D

@export var from: SubViewport
@export var from_node: Node2D

# @export var viewports: Array[SubViewport] = []
@export var to: SubViewport

@export var set_world := false:
    set(value):
        set_world = false
        # for vp in viewports:
        if from != null:
            to.world_2d = from.world_2d
        if from_node != null:
            to.world_2d = from_node.get_world_2d()

@export var unset_world := false:
    set(value):
        unset_world = false
        # for vp in viewports:
        to.world_2d = null