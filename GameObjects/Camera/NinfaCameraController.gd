@tool
class_name NinfaCameraController
extends Node3D

@export var camera:ToolCamera3D
@export var camera_focus:Marker3D

@export_category("Camera Position")
@export var camera_position : Vector3:
	set(value):
		if camera == null: return
		camera.position = value
	get():
		if camera == null: return Vector3.ZERO
		return camera.position
		
@export_range(0, 90, 0.1) var tilt : float = 0:
	set(value):
		if camera == null: return
		camera.rotation_degrees.x = -value
	get():
		if camera == null: return 0
		return -camera.rotation_degrees.x

@export_category("Camera Zoom")
@export_range(0, 10, 0.1, "suffix:m") var size_min : float = 3.0
@export_range(0, 100, 0.1, "suffix:m") var size_max : float = 100.0
		
@export_range(0, 100, 0.1, "suffix:m") var size : float:
	set(value):
		if camera == null: return
		
		if camera.projection == Camera3D.PROJECTION_ORTHOGONAL:
			camera.size = value
			
		if camera.projection == Camera3D.PROJECTION_PERSPECTIVE:
			camera.fov = value
	get():
		if camera == null: return 0
		
		if camera.projection == Camera3D.PROJECTION_ORTHOGONAL:
			return camera.size
			
		if camera.projection == Camera3D.PROJECTION_PERSPECTIVE:
			return camera.fov
			
		return 0
		
@export_range(0, 30, 0.1, "suffix:m/s") var zoom_speed : float = 6.0

@export_category("Camera Rotation")
@export var camera_rotation_keyboard_speed:float = 5.0
@export var camera_rotation_mouse_speed:float = 0.5
@export var allow_elevation_change:bool
@export var elevation_speed:float = 5.0

var _mouse_dragged : bool = false
var _lastMousePosition = Vector2(0, 0)

@onready var size_requested : float = size # UNIT: m

const zoom_tween_duration:float = 0.1
var _zoom_tween:Tween
var _size_last : float = size # UNIT: m
		
func _process(delta : float) -> void:
	if camera_focus != null:
		camera.look_at(camera_focus.global_position)
		
	if Engine.is_editor_hint():
		return
		
	_process_zoom(delta)
	_process_rotation(delta)
	
func _process_zoom(delta : float) -> void:
		
	if Input.is_action_just_pressed("camera_zoom_in"):
		size_requested -= delta * zoom_speed
		
	if Input.is_action_just_pressed("camera_zoom_out"):
		size_requested += delta * zoom_speed

	size_requested = clamp(size_requested, size_min, size_max)
	if _size_last != size_requested:
		_size_last = size_requested
		
		if _zoom_tween != null and _zoom_tween.is_running():
			_zoom_tween.stop()
			
		_zoom_tween = create_tween()
		_zoom_tween.tween_property(self, "size", _size_last, zoom_tween_duration)

func _process_rotation(delta : float) -> void:
	if Input.is_action_pressed("camera_drag"):
		var mouse_position = get_viewport().get_mouse_position()
		if not _mouse_dragged:
			_mouse_dragged = true
		else:
			var mouse_movement:Vector2 = _lastMousePosition - mouse_position
			rotation.y += delta * mouse_movement.x * camera_rotation_mouse_speed
			if allow_elevation_change:
				position.y += delta * mouse_movement.y * elevation_speed
		_lastMousePosition = mouse_position
		
	if Input.is_action_just_released("camera_drag"):
		_mouse_dragged = false
		
	if Input.is_action_pressed("camera_rotate_clockwise"):
		rotation.y += delta * camera_rotation_keyboard_speed
		
	if Input.is_action_pressed("camera_rotate_counterclockwise"):
		rotation.y -= delta * camera_rotation_keyboard_speed
