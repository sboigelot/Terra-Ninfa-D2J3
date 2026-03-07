@tool
extends Camera3D

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
var zoom_speed : float = 4.0 # UNIT: m

###############################################################################
###############################################################################
## SECTION: Private Variables #################################################
###############################################################################
###############################################################################
var _ortho_scale_last : float = self.ortho_scale_default # UNIT: m
var _ortho_scale_requested : float = self.ortho_scale_default # UNIT: m
var _request_zoom_in : bool = false
var _request_zoom_out : bool = false

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

# TODO: Add smoothing out
# BUG: Holding down a key leads to a sometimes a short freeze before zooming 
# resumes
func _manage_zoom(a_delta : float) -> void:
	# DESCRIPTION: Only process when last and requested ortho scale are not
	# identical
	if self._ortho_scale_last != self._ortho_scale_requested:
		print("Last != requested")

		# DESCRIPTION: Determine whether the requested scale is within the 
		# the allowed range
		var _tmp_aboveMinimum : bool = (self.ortho_scale_min <= self._ortho_scale_requested)
		var _tmp_belowMaximum : bool = (self._ortho_scale_requested <= self.ortho_scale_max)

		# DESCRIPTION: Clamp the requested scale between minimum and maximum
		if  not _tmp_aboveMinimum:
			self._ortho_scale_requested = self.ortho_scale_min

		elif not _tmp_belowMaximum:
			self._ortho_scale_requested = self.ortho_scale_max

		# DESCRIPTION: Apply the scale change gradually by interpolating the
		# distance to the target with variable weights
		# TODO: Add better smoothing
		var _tmp_scaleDistance : float = abs(self.size - self._ortho_scale_requested)
		var _tmp_scaleDelta = a_delta * _tmp_scaleDistance

		# DESCRIPTION: Ensure stop by preventing moving too small increments
		if _tmp_scaleDistance >= 0.01:
			var _tmp_size : Vector2 = Vector2(self.size, 0).move_toward(
				Vector2(self._ortho_scale_requested, 0),
				_tmp_scaleDelta
			)
			self.size = _tmp_size.x

		else:
			self.size = self._ortho_scale_requested

		self._ortho_scale_last = self.size

	else:
		self._ortho_scale_requested = self.size
		self._ortho_scale_last = self.size

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

	if a_data.has("zoom_speed"):
		self.set_zoom_speed(a_data.zoom_speed)

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
	self._ortho_scale_requested = self.ortho_scale_default

	# DESCRIPTION: Set default orthographic scale
	self.set_zoom_level(self.ortho_scale_default)
	self._update_position()
	self._update_tilt()

###############################################################################
###############################################################################
## SECTION: Godot Runtime Function Overrides ##################################
###############################################################################
###############################################################################
# REMARK: Zooming requests need to be handle in input, as otherwise the mouse
# wheel input would not be registered. In theory, it would be possible to hard
# code it to mouse wheel, but that would mean unnecessary logic duplication for
# keyboard and potential controller inputs
# REMARK: Mouse wheel inputs are registered twice (start and stop). 
# TODO: Verify whether double mouse input detection is an issue
func _input(event: InputEvent) -> void:
	if InputMap.event_is_action(event, "camera_zoom_in"):
		print("Request zoom in")
		self._request_zoom_in = true

	if InputMap.event_is_action(event, "camera_zoom_out"):
		print("Request zoom out")
		self._request_zoom_out = true

func _process(delta: float) -> void:
	# DESCRIPTION: Handle camera zoom in
	if self._request_zoom_in:
		self._ortho_scale_requested -= delta * self.zoom_speed
		self._request_zoom_in = false
			
	# DESCRIPTION: Handle camera zoom out
	if self._request_zoom_out:
		self._ortho_scale_requested += delta * self.zoom_speed
		self._request_zoom_out = false
	
	# DESCRIPTION: Call management functions
	self._manage_zoom(delta)
