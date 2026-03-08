extends Node3D

###############################################################################
###############################################################################
## SECTION: Export Variables ##################################################
###############################################################################
###############################################################################
@export_category("Camera State")
@export var locked : bool = false

@export_category("Camera Position")
@export var pivot_point : Vector3 = Vector3(0, 0, 0)
@export_range(0, 100, 0.01, "suffix:m") var radial_offset : float = 12
@export_range(0, 100, 0.01, "suffix:m") var vertical_offset : float = 4
@export_range(-90, 0, 0.01, "radians_as_degrees") var tilt : float = 0

@export_category("Camera Zoom")
@export_range(0, 10, 0.1, "suffix:m") var ortho_scale_min : float = 0.1
@export_range(0, 100, 0.1, "suffix:m") var ortho_scale_max : float = 4.0
@export_range(0, 10, 0.1, "suffix:m") var ortho_scale_default : float = 4.0
@export_range(0, 10, 0.1, "suffix:m/s") var zoom_speed : float = 6.0
@export_range(0.01, 1, 0.01) var zoom_keyboard_factor : float = 0.5

@export_category("Camera Transforms")
@export var camera_rotation_keyboard_speed:float = 5.0
@export var camera_rotation_mouse_speed:float = 0.5
@export var camera_movement_speed : float = 1.0 # UNIT: m/s

###############################################################################
###############################################################################
## SECTION: Private Member Variables ##########################################
###############################################################################
###############################################################################
@onready var _Camera : Camera3D = $Camera3D 

var _mouse_dragged : bool = false
var _lastMousePosition = Vector2(0, 0)

var _cameraController_tween : Tween

###############################################################################
###############################################################################
## SECTION: Private Member Functions ##########################################
###############################################################################
###############################################################################
func _calculate_postion_transition_duration(a_delta : Vector3) -> float:
	var _tmp_distance : float = a_delta.length()
	return _tmp_distance / self.camera_movement_speed 

func _position_transition(
	a_targetPosition : Vector3, a_duration : float, a_easing : bool = true
) -> void:

	# DESCRIPTION: Make sure that tween is not already running
	if _cameraController_tween != null and _cameraController_tween.is_running():
		_cameraController_tween.stop()
	
	# DESCRIPTION: Create, configure and start tween
	_cameraController_tween = create_tween()

	if a_easing:
		_cameraController_tween.set_trans(Tween.TRANS_CUBIC)
		_cameraController_tween.set_ease(Tween.EASE_IN_OUT)

	_cameraController_tween.tween_property(
		self, "position", a_targetPosition, a_duration
	)

func _position_transition_with_duration_derived_from_delta(
	a_targetPosition : Vector3, a_delta : Vector3, a_easing : bool = true
) -> void:
	var _tmp_transitionDuration : float = self._calculate_postion_transition_duration(a_delta)

	self._position_transition(
		a_targetPosition, _tmp_transitionDuration, a_easing
	)

###############################################################################
## SUBSECTION: Process Functions ##############################################
###############################################################################
func _process_zoom(delta : float) -> void:
	# DESCRIPTION: Allow zoom by input events which only provide a 
	# "just pressed" state, e. g. mouse
	# REMARK: Does not allow for continuous zooming with keyboard shortcut
	if Input.is_action_just_pressed("camera_zoom_in"):
		_Camera.ortho_scale_requested -= delta * zoom_speed
		
	if Input.is_action_just_pressed("camera_zoom_out"):
		_Camera.ortho_scale_requested += delta * zoom_speed

	# DESCRIPTION: Hack to allow continuous zooming with the keyboard
	# REMARK: Works as follows: Mouse button events do not have a "pressed" type
	# so they do not trigger "is_action_pressed". But the key presses do. This is
	# a workaround, since Godot does not provide InputEvent type information 
	# outside of "_input". Adding it on top of "is_action_just_pressed" adds an
	# additional increment to the zoom request, but the impact should be negliable
	if Input.is_action_pressed("camera_zoom_in"):
		_Camera.ortho_scale_requested -= delta * zoom_speed * zoom_keyboard_factor
		
	if Input.is_action_pressed("camera_zoom_out"):
		_Camera.ortho_scale_requested += delta * zoom_speed * zoom_keyboard_factor

	_Camera.manage_zoom(delta)

func _process_rotation(delta : float) -> void:
	# DESCRIPTION: Handle rotation by mouse dragging
	if Input.is_action_pressed("camera_drag"):
		var _tmp_mouse_position = get_viewport().get_mouse_position()
		if not _mouse_dragged:
			_mouse_dragged = true

		else:
			var mouse_movement : float = _lastMousePosition.x - _tmp_mouse_position.x
			rotation.y += delta * mouse_movement * camera_rotation_mouse_speed
			
		_lastMousePosition = _tmp_mouse_position
		
	if Input.is_action_just_released("camera_drag"):
		_mouse_dragged = false

	# DESCRIPTION: Handle rotation by keyboard input	
	if Input.is_action_pressed("camera_rotate_clockwise"):
		rotation.y += delta * camera_rotation_keyboard_speed
		
	if Input.is_action_pressed("camera_rotate_counterclockwise"):
		rotation.y -= delta * camera_rotation_keyboard_speed

###############################################################################
###############################################################################
## SECTION: Public Member Functions ###########################################
###############################################################################
###############################################################################

###############################################################################
## SUBSECTION: Getter Functions ###############################################
###############################################################################
func get_zoom_level() -> float:
	return self._Camera.get_zoom_level()

func get_tilt() -> float:
	return self._Camera.get_tilt()

###############################################################################
## SUBSECTION: Request Functions ##############################################
###############################################################################
func request_vertical_transition_by_delta(a_delta : float) -> void:
	if not self.locked:
		var _tmp_targetPosition : Vector3 = self.position
		_tmp_targetPosition.y += a_delta

		self._position_transition_with_duration_derived_from_delta(
			_tmp_targetPosition, Vector3(0, a_delta, 0)
		)

func request_vertical_transition_to_absolute(a_vertical : float) -> void:
	# DESCRIPTION: Make sure that the camera is not locked
	if not self.locked:
		var _tmp_targetPosition : Vector3 = self.position
		_tmp_targetPosition.y = a_vertical

		var _tmp_positionDelta : Vector3 = Vector3(
			0,
			self.position.y - a_vertical,
			0
		)

		self._position_transition_with_duration_derived_from_delta(
			_tmp_targetPosition, _tmp_positionDelta
		)

func request_camera_lock() -> void:
	self.locked = true

func request_camera_unlock() -> void:
	self.locked = false

###############################################################################
###############################################################################
## SECTION: Godot Loadtime Function Overrides #################################
###############################################################################
###############################################################################
func _ready() -> void:
	# DESCRIPTION: Pass relevant settings to Camera
	# REMARK: Has to be done with a function, as some properties
	# have stacked value changes and will not update otherwise
	self._Camera.initialize(
		{
			"radial_offset": self.radial_offset,
			"vertical_offset": self.vertical_offset,
			"tilt": self.tilt,
			"ortho_scale_min": self.ortho_scale_min,
			"ortho_scale_max": self.ortho_scale_max,
			"ortho_scale_default": self.ortho_scale_default,
		}
	)

###############################################################################
###############################################################################
## SECTION: Godot Runtime Function Overrides #################################
###############################################################################
###############################################################################
func _process(delta : float) -> void:
	# DESCRIPTION: Make sure that the camera is not locked
	if not self.locked:
		_process_zoom(delta)
		_process_rotation(delta)

		if Input.is_action_just_pressed("ui_up"):
			self.request_vertical_transition_by_delta(5)

		if Input.is_action_just_pressed("ui_down"):
			self.request_vertical_transition_by_delta(-5)
