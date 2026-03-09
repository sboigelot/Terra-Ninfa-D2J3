class_name PickableObject
extends Area3D

signal picked_up(pickable_object:PickableObject)
signal dropped_down(pickable_object:PickableObject)

const max_mouse_move_for_drop:float = 30.0
const min_msec_before_drop:float = 200

@export var pickable: bool = true
@export var object_tag: String
@export var scale_on_mouse_over: Vector3 = Vector3.ONE * 1.1

@onready var original_parent:Node3D = get_parent()

var picked:bool
var _mouse_pressed_position:Vector2
var _picked_up_time:float

func _init() -> void:
	add_to_group("pickable_object")
	collision_layer = 2
	collision_mask = 0
	NodeHelper.connect_if_not_connected(input_event, _on_input_event)
	NodeHelper.connect_if_not_connected(mouse_entered, _on_mouse_entered)
	NodeHelper.connect_if_not_connected(mouse_exited, _on_mouse_exited)

func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if (event is InputEventMouseButton and 
		event.button_index == MOUSE_BUTTON_LEFT and 
		event.pressed):
		if pickable:
			SfxManager.play("item_pickup")
			picked = true
			_picked_up_time = Time.get_ticks_msec()
			picked_up.emit(self)
			get_viewport().set_input_as_handled()
		else:
			SfxManager.play("click")

func _unhandled_input(event: InputEvent) -> void:
	if (picked and
		event is InputEventMouseButton and 
		event.button_index == MOUSE_BUTTON_LEFT):
		
		var now = Time.get_ticks_msec()
		var time_since_pickup = now - _picked_up_time
		if time_since_pickup < min_msec_before_drop:
			return
			
		if event.pressed:
			_mouse_pressed_position = get_viewport().get_mouse_position()
		else:
			var mouse_release_position = get_viewport().get_mouse_position()
			var mouse_move = _mouse_pressed_position.distance_to(mouse_release_position)
			if mouse_move < max_mouse_move_for_drop:
				SfxManager.play("item_pickup")
				picked = false
				dropped_down.emit(self)
				get_viewport().set_input_as_handled()
			
func _on_mouse_entered() -> void:
	scale = scale_on_mouse_over

func _on_mouse_exited() -> void:
	scale = Vector3.ONE
