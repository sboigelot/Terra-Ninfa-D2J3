@tool
class_name WaterRooter
extends Mechanism3D

signal output_index_changed()

@export var allow_no_output:bool:
	set(value):
		allow_no_output = value
		output_index = -1 if allow_no_output else output_index
		
@export var output_index: int:
	set(value):
		if value == output_index:
			return
		output_index = value
		if output_index >= downstream.size():
			output_index = -1 if allow_no_output else 0
		propagate_water_downstream()
		output_index_changed.emit()
		
@export var downstream: Array[WaterNode3D]

func _on_water_intake_changed() -> void:
	propagate_water_downstream()

func propagate_water_downstream() -> void:
	for index in downstream.size():
		var water:WaterNode3D = downstream[index]
		water.flowing = index == output_index

func _on_player_click() -> void:
	output_index += 1
