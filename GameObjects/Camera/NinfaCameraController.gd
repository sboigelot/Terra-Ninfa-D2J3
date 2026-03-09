@tool
class_name NinfaCameraController
extends Node3D

@export var camera:ToolCamera3D

@export_category("Camera Position")
@export var camera_position : Vector3:
	set(value):
		if camera == null: return
		camera.position = value
	get():
		if camera == null: return Vector3.ZERO
		return camera.position
		
@export var camera_rotation : Vector3:
	set(value):
		if camera == null: return
		camera.rotation = value
	get():
		if camera == null: return Vector3.ZERO
		return -camera.rotation

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
		
@export_range(0, 30, 0.1, "suffix:m/s") var zoom_speed_mouse : float = 5.0
@export_range(0, 30, 0.1, "suffix:m/s") var zoom_speed_keyboard : float = 10.0

@export_category("Camera Rotation")
@export var camera_rotation_keyboard_speed:float = 5.0
@export var camera_rotation_mouse_speed:float = 0.5
@export var allow_elevation_change:bool
@export var elevation_speed:float = 5.0

var _mouse_left_button_dragged : bool = false
var _mouse_right_button_dragged : bool = false
var _lastMousePosition = Vector2(0, 0)
var _last_mouse_world_position = Vector3.ZERO

@onready var size_requested : float = size # UNIT: m

const zoom_tween_duration:float = 0.05
var _zoom_tween:Tween
var _size_last : float = size # UNIT: m

var _mouse_wheel: float

@export_category("Camera Movement")
@export var allow_pivot_movement: bool = true
@export var camera_move_mouse_speed:float = 5
@export var max_frame_drag_distance: float = 2.0
@export var min_pivot_center: Vector3 = Vector3(-15, 0, -15)
@export var max_pivot_center: Vector3 = Vector3(15, 0, 15)

func _process(delta : float) -> void:
	if Engine.is_editor_hint():
		return
		
	_process_zoom(delta)
	_process_rotation(delta)
	_process_movement(delta)
	
func _unhandled_input(event: InputEvent) -> void:
	_mouse_wheel = 0
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_mouse_wheel = -event.factor
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_mouse_wheel = event.factor
	
func _process_zoom(delta : float) -> void:
	
	size_requested -= _mouse_wheel * zoom_speed_mouse
	_mouse_wheel = 0.0
		
	if Input.is_action_pressed("camera_zoom_in"):
		size_requested -= delta * zoom_speed_keyboard
		
	if Input.is_action_pressed("camera_zoom_out"):
		size_requested += delta * zoom_speed_keyboard

	size_requested = clamp(size_requested, size_min, size_max)
	if _size_last != size_requested:
		_size_last = size_requested
		
		if _zoom_tween != null and _zoom_tween.is_running():
			_zoom_tween.stop()
			
		_zoom_tween = create_tween()
		_zoom_tween.tween_property(self, "size", _size_last, zoom_tween_duration)

func _process_rotation(delta : float) -> void:
	if Input.is_action_pressed("camera_mouse_rotate"):
		var mouse_position = get_viewport().get_mouse_position()
		if not _mouse_left_button_dragged:
			_mouse_left_button_dragged = true
		else:
			var mouse_movement:Vector2 = _lastMousePosition - mouse_position
			rotation.y += delta * mouse_movement.x * camera_rotation_mouse_speed
			if allow_elevation_change:
				position.y += delta * mouse_movement.y * elevation_speed
		_lastMousePosition = mouse_position
		
	if Input.is_action_just_released("camera_mouse_rotate"):
		_mouse_left_button_dragged = false
		
	if Input.is_action_pressed("camera_rotate_clockwise"):
		rotation.y += delta * camera_rotation_keyboard_speed
		
	if Input.is_action_pressed("camera_rotate_counterclockwise"):
		rotation.y -= delta * camera_rotation_keyboard_speed
		
func _process_movement(_delta : float) -> void:
	if Input.is_action_pressed("camera_mouse_move"):
		if not _mouse_right_button_dragged:
			_last_mouse_world_position = get_mouse_world_position()
			_mouse_right_button_dragged = true
		else:
			var mouse_world_position = get_mouse_world_position()
			if mouse_world_position != Vector3.ZERO:
				var mouse_movement:Vector3 = _last_mouse_world_position - mouse_world_position
				mouse_movement = mouse_movement.clampf(-max_frame_drag_distance/2.0, max_frame_drag_distance/2.0)
				position = Vector3(
					clamp(position.x + mouse_movement.x, min_pivot_center.x, max_pivot_center.x),
					clamp(position.y + mouse_movement.y, min_pivot_center.y, max_pivot_center.y),
					clamp(position.z + mouse_movement.z, min_pivot_center.z, max_pivot_center.z)
				)
			_last_mouse_world_position = get_mouse_world_position()

	if Input.is_action_just_released("camera_mouse_move"):
		_mouse_right_button_dragged = false
		
func get_mouse_world_position() -> Vector3:
	var mouse_position = get_viewport().get_mouse_position()
	var origin := camera.project_ray_origin(mouse_position)
	var direction := camera.project_ray_normal(mouse_position)
	var ray_length := camera.far
	var end := origin + direction * ray_length
	var query := PhysicsRayQueryParameters3D.create(origin, end)
	var space_state := get_world_3d().direct_space_state
	var result := space_state.intersect_ray(query)
	var collided = result.has("collider") 
	if collided:
		var mouse_position_3D = result.get("position", end)
		return mouse_position_3D
	return Vector3.ZERO
	
