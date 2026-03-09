extends Button

var _sfxAllowed : bool = true

func _on_mouse_entered() -> void:
	if self._sfxAllowed:
		SfxManager.play("drop_003")

func _on_pressed() -> void:
	if self._sfxAllowed:
		SfxManager.play("switch_005")

func initialize(a_callback) -> void:
	# DESCRIPTION: Add custom callback for button press
	if a_callback != null:
		self.pressed.connect(a_callback)

func set_to_active() -> void:
	self._sfxAllowed = true

func set_to_inactive() -> void:
	self._sfxAllowed = false

func _ready() -> void:
	# DESCRIPTION: Signal management
	self.mouse_entered.connect(_on_mouse_entered)
	self.pressed.connect(_on_pressed)
	self.visibility_changed.connect(_on_visibility_changed)
	
func _on_visibility_changed() -> void:
	if visible and is_visible_in_tree():
		mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	
