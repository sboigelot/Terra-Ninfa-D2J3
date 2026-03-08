extends Camera3D

const zoom_tween_duration : float = 0.2 # 0.1

###############################################################################
###############################################################################
## SECTION: Public Member Variables ###########################################
###############################################################################
###############################################################################
var radial_offset : float = 10 # UNIT: m
var vertical_offset : float = 3 # UNIT: m
var tilt : float = 0 # UNIT: Radians

var ortho_scale_min : float = 0.1 # UNIT: m
var ortho_scale_max : float = 4.0 # UNIT: m
var ortho_scale_default : float = 4.0 # UNIT: m
var ortho_scale_requested : float = self.ortho_scale_default # UNIT: m

###############################################################################
###############################################################################
## SECTION: Private Variables #################################################
###############################################################################
###############################################################################
var _ortho_scale_last : float = self.ortho_scale_default # UNIT: m
var _zoom_tween : Tween

###############################################################################
###############################################################################
## SECTION: Private Member Functions ##########################################
###############################################################################
###############################################################################
func _update_tilt() -> void:
	self.rotation.x = self.tilt

func _update_position() -> void:
	self.position.z = self.radial_offset
	self.position.y = self.vertical_offset

###############################################################################
###############################################################################
## SECTION: Public Member Functions ###########################################
###############################################################################
###############################################################################
func manage_zoom(_delta : float) -> void:
	# DESCRIPTION: Make sure that the requested ortho scale is within the range
	ortho_scale_requested = clamp(
		ortho_scale_requested, ortho_scale_min, ortho_scale_max
	)

	# DESCRIPTION: If the last scale is different to the requested one, create
	# a tweened transition.
	if _ortho_scale_last != ortho_scale_requested:
		_ortho_scale_last = ortho_scale_requested
		
		# DESCRIPTION: Make sure that tween is not already running
		if _zoom_tween != null and _zoom_tween.is_running():
			_zoom_tween.stop()
		
		# DESCRIPTION: Create, configure and start tween
		_zoom_tween = create_tween()
		_zoom_tween.tween_property(
			self, "size", ortho_scale_requested, zoom_tween_duration
		)

###############################################################################
###############################################################################
## SECTION: Public Setter Member Functions ####################################
###############################################################################
###############################################################################
func set_radial_offset(a_offset : float) -> void:
	self.radial_offset = a_offset
	self._update_position()

func set_vertical_offset(a_offset : float) -> void:
	self.vertical_offset = a_offset
	self._update_position()

func set_tilt(a_rad : float) -> void:
	self.tilt = a_rad
	self._update_tilt()

func set_zoom_level(a_level : float) -> void:
	self.size = a_level
	self._ortho_scale_last = self.size

func set_zoom_speed(a_speed : float) -> void:
	self.zoom_speed = a_speed

###############################################################################
###############################################################################
## SECTION: Public Getter Member Functions ####################################
###############################################################################
###############################################################################
func get_zoom_level() -> float:
	return self.size

func get_tilt() -> float:
	return self.rotation.x

###############################################################################
###############################################################################
## SECTION: Public Member Functions ###########################################
###############################################################################
###############################################################################
func initialize(a_data : Dictionary) -> void:
	print("Camera init")
	if a_data.has("radial_offset"):
		self.set_radial_offset(a_data.radial_offset)

	if a_data.has("vertical_offset"):
		self.set_vertical_offset(a_data.vertical_offset)

	if a_data.has("tilt"):
		self.set_tilt(a_data.tilt)

	if a_data.has("ortho_scale_min"):
		self.ortho_scale_min = a_data.ortho_scale_min

	if a_data.has("ortho_scale_max"):
		self.ortho_scale_max = a_data.ortho_scale_max

	if a_data.has("ortho_scale_default"):
		self.ortho_scale_default = a_data.ortho_scale_default

###############################################################################
###############################################################################
## SECTION: Godot Loadtime Function Overrides #################################
###############################################################################
###############################################################################
func _ready() -> void:
	# DESCRIPTION: Initialize the current and last orthographic scale values
	self._ortho_scale_last = self.ortho_scale_default
	self.ortho_scale_requested = self.ortho_scale_default

	# DESCRIPTION: Set default orthographic scale
	self.set_zoom_level(self.ortho_scale_default)
	self._update_position()
	self._update_tilt()
