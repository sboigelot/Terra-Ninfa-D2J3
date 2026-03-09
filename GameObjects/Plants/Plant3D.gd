@tool
class_name Plant3D
extends Node3D

signal irrigated_changed(plant:Plant3D)

@export var irrigated:bool:
	set(value):
		if irrigated == value:
			return
		irrigated = value
		_on_irrigated_changed()
		
@export var dry_scale: Vector3 = Vector3.ZERO
@export var irrigated_scale: Vector3 = Vector3.ONE
@export var tween_duration: float = 0.5

var tween:Tween

func _on_irrigated_changed() -> void:
	start_tween()
	irrigated_changed.emit(self)
	
func start_tween() -> void:
	if tween != null and tween.is_running():
		tween.stop()
	
	var target_scale = irrigated_scale if irrigated else dry_scale
	if target_scale == Vector3.ZERO:
		target_scale = Vector3.ONE * 0.001
		
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "rotation_degrees", Vector3(0,180,0), tween_duration)
	tween.tween_property(self, "scale", target_scale, tween_duration * .75)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_QUAD)
	
	rotation_degrees = Vector3.ZERO
	#tween.finished.connect(irrigated_changed.emit)
