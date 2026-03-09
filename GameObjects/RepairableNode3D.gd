@tool
class_name RepairableNode3D
extends Node3D

signal broken_changed()

@export var broken:bool = true:
	set(value):
		if broken == value:
			return
		broken = value
		SfxManager.play(broken_sfx if broken else repaired_sfx)
		propagate_broken_state()
		broken_changed.emit()

@export var broken_visual:Node3D
@export var repaired_visual:Node3D

@export var prevent_flowing_when_broken: Array[WaterNode3D]
@export var prevent_flowing_when_repaired: Array[WaterNode3D]

@export var broken_sfx:String = "ruin_destroy"
@export var repaired_sfx:String = "achievement"

func _ready() -> void:
	propagate_broken_state()
	
func propagate_broken_state() -> void:
	if broken_visual != null:
		broken_visual.visible = broken
		
	if repaired_visual != null:
		repaired_visual.visible = not broken
		
	for water_node:WaterNode3D in prevent_flowing_when_broken:
		water_node.prevent_flowing = broken
		
	for water_node:WaterNode3D in prevent_flowing_when_repaired:
		water_node.prevent_flowing = not broken
