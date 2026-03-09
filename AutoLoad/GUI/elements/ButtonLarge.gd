extends Button

func _on_mouse_entered() -> void:
	SfxManager.play("drop_003")

func _on_pressed() -> void:
	SfxManager.play("switch_005")

func initialize(a_callback) -> void:
	# DESCRIPTION: Add custom callback for button press
	if a_callback != null:
		self.pressed.connect(a_callback)

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
	
	
