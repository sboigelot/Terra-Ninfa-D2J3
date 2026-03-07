@abstract 
class_name Mechanism3D
extends Node3D

var _water_intakes:Array[WaterNode3D]

func set_water_intake(water_node:WaterNode3D) -> void:
	if water_node.flowing:
		if not _water_intakes.has(water_node):
			_water_intakes.append(water_node)
			_on_water_intake_changed()
	else:
		_water_intakes.erase(water_node)
		_on_water_intake_changed()

@export var mouse_control_area:Area3D
@export var scale_on_mouse_over: Vector3 = Vector3.ONE * 1.1

func _ready() -> void:
	if mouse_control_area != null:
		NodeHelper.connect_if_not_connected(mouse_control_area.input_event, _on_mouse_control_area_input_event)
		NodeHelper.connect_if_not_connected(mouse_control_area.mouse_entered, _on_mouse_control_area_mouse_entered)
		NodeHelper.connect_if_not_connected(mouse_control_area.mouse_exited, _on_mouse_control_area_mouse_exited)

func _on_mouse_control_area_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if (event is InputEventMouseButton and 
		event.button_index == MOUSE_BUTTON_LEFT and 
		event.pressed):
		_on_player_click()
		get_viewport().set_input_as_handled()
	
func _on_mouse_control_area_mouse_entered() -> void:
	scale = scale_on_mouse_over
	
func _on_mouse_control_area_mouse_exited() -> void:
	scale = Vector3.ONE

@abstract func _on_water_intake_changed() -> void
@abstract func propagate_water_downstream() -> void
@abstract func _on_player_click() -> void
	
