class_name TestPlant
extends ConditionalWater

@export var dry_scale: Vector3 = Vector3.ZERO
@export var irrigated_scale: Vector3 = Vector3.ONE

var tween:Tween

func propagate_water_downstream() -> void:
	if tween != null and tween.is_running():
		tween.stop()
	
	var target_scale = irrigated_scale if flowing else dry_scale
		
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", target_scale, 1.0)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_BOUNCE)
	
	rotation_degrees = Vector3.ZERO
	tween.tween_property(self, "rotation_degrees", Vector3(0,360,0), 1.0)
	
	
