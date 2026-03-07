extends Label

@onready var _Camera : Node3D = get_parent().get_node("Camera")

func _ready():
	self.text = "Zoom: %s, Tilt: %s" % [self._Camera.get_zoom_level(), self._Camera.get_tilt()]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.text = "Zoom: %s, Tilt: %s" % [self._Camera.get_zoom_level(), self._Camera.get_tilt()]
