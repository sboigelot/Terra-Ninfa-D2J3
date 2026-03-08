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
		output_index_changed.emit()
		_start_change_rotation()
		
@export var downstream: Array[WaterNode3D]

@export var rotation_degree_per_index:float = 0

var rotation_tween:Tween

func _on_water_intake_changed() -> void:
	propagate_water_downstream()

func propagate_water_downstream() -> void:
	for index in downstream.size():
		var water_activated = index == output_index and _water_intakes.size() > 0
		var water_node:WaterNode3D = downstream[index]
		water_node.set_upstream_flow(self, water_activated)

func _on_player_click() -> void:
	SfxManager.play("click")
	output_index += 1
	
func on_mechanism_activated(_activated: bool) -> void:
	output_index += 1
	
func _start_change_rotation() -> void:
	if rotation_degree_per_index == 0:
		propagate_water_downstream()
		return
		
	if rotation_tween != null and rotation_tween.is_running():
		rotation_tween.stop()
	
	var desired_rotation_y:float = 0.0
	if output_index != -1:
		desired_rotation_y = rotation_degree_per_index * (output_index + 1.0)
	var desired_rotation = Vector3(0, desired_rotation_y, 0)
	
	rotation_tween = create_tween()
	rotation_tween.tween_property(self, "rotation_degrees", desired_rotation, 1.0)\
					.set_ease(Tween.EASE_OUT)\
					.set_trans(Tween.TRANS_LINEAR)
	rotation_tween.finished.connect(propagate_water_downstream)
