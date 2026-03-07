@tool
extends Node3D

###############################################################################
###############################################################################
## SECTION: Export Variables ##################################################
###############################################################################
###############################################################################
@export_category("Camera Position")
@export var pivot_point : Vector3 = Vector3(0, 0, 0)
@export_range(0, 100, 0.01, "suffix:m") var radial_offset : float = 12
@export_range(0, 100, 0.01, "suffix:m") var vertical_offset : float = 4
@export_range(-90, 0, 0.01, "radians_as_degrees") var tilt : float = 0

@export_category("Camera Zoom")
@export_range(0, 10, 0.1, "suffix:m") var ortho_scale_min : float = 0.1
@export_range(0, 100, 0.1, "suffix:m") var ortho_scale_max : float = 4.0
@export_range(0, 10, 0.1, "suffix:m") var ortho_scale_default : float = 4.0
@export_range(0, 10, 0.1, "suffix:m/s") var zoom_speed : float = 4.0

@onready var _Camera : Camera3D = $Camera3D 

var _mouse_dragged : bool = false
var _lastMousePosition = Vector2(0, 0)

var _request_rotation_clockwise : bool = false
var _request_rotation_counterclockwise : bool = false

func get_zoom_level() -> float:
	return self._Camera.get_zoom_level()

func get_tilt() -> float:
	return self._Camera.get_tilt()

func _manage_rotation(a_delta : float) -> void:
	if self._request_rotation_clockwise:
		self.rotation.y = self.rotation.y + a_delta * 500
		self._request_rotation_clockwise = false

	if self._request_rotation_clockwise:
		self.rotation.y = self.rotation.y - a_delta * 500
		self._request_rotation_clockwise = false

	print("Rotation: ", self.rotation.y)


func _input(event : InputEvent) -> void:
	# REMARK: Currently just a place holder! Not completely implemented yet
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			self._mouse_dragged = true
			self._lastMousePosition = get_viewport().get_mouse_position()

		if event.is_released():
			self._mouse_dragged = false

	if InputMap.event_is_action(event, "camera_rotate_clockwise"):
		self._request_rotation_clockwise = true
		print("Clockwise")

	if InputMap.event_is_action(event,"camera_rotate_counterclockwise"):
		self._request_rotation_counterclockwise = true
		print("Counterclockwise")


func _ready() -> void:
	# DESCRIPTION: Pass relevant settings to Camera
	# REMARK: Has to be done with a function, as some properties
	# have stacked value changes and will not update otherwise
	print("Camera Controller: tilt: %s" % [self.tilt])
	self._Camera.initialize(
		{
			"radial_offset": self.radial_offset,
			"vertical_offset": self.vertical_offset,
			"tilt": self.tilt,
			"ortho_scale_min": self.ortho_scale_min,
			"ortho_scale_max": self.ortho_scale_max,
			"ortho_scale_default": self.ortho_scale_default,
			"zoom_speed": self.zoom_speed
		}
	)

func _process(delta : float) -> void:
	self._manage_rotation(delta)
