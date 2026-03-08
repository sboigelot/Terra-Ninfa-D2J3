@tool
class_name PushButton3D
extends Mechanism3D

signal pressed()
signal toggled(is_pressed:bool)

@export var toggle_mode:bool = false
@export var release_delay:float = 1.0

@export var is_pressed:bool = false:
	set(value):
		if is_pressed == value:
			return
		is_pressed = value
		
		if is_pressed:
			pressed.emit()
			
		set_pressed_visuals()
		
		if toggle_mode:
			toggled.emit(is_pressed)
		else:
			await get_tree().create_timer(release_delay).timeout
			is_pressed = false
			set_pressed_visuals()

@export var pressed_visual:Node3D
@export var released_visual:Node3D

func set_pressed_visuals() -> void:
	if pressed_visual != null:
		pressed_visual.visible = is_pressed
	if released_visual != null:
		released_visual.visible = not is_pressed

func propagate_water_downstream() -> void:
	pass
	
func _on_water_intake_changed() -> void:
	pass

func _on_player_click() -> void:
	is_pressed = true

func on_mechanism_activated(activated: bool) -> void:
	is_pressed = activated
