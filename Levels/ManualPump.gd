class_name ManualPump
extends Mechanism3D

@export var pumping_duration:float = 3.0
@export var pumping_in_progress: bool = false:
	set(value):
		var new_value = value and _water_intakes.size() > 0
		if pumping_in_progress == new_value:
			return
			
		pumping_in_progress = new_value
		if pumping_in_progress:
			start_pumping_animation()
		propagate_water_downstream()
		
@export var downstream: Array[WaterNode3D]
@export var bucket_follow_path: PathFollow3D

var tween:Tween

func _on_water_intake_changed() -> void:
	propagate_water_downstream()
	
func propagate_water_downstream() -> void:
	for water_node in downstream:
		water_node.set_upstream_flow(self, pumping_in_progress)
	
func _on_player_click() -> void:
	pass
	
func on_mechanism_activated(activated: bool) -> void:
	pumping_in_progress = activated

func start_pumping_animation() -> void:
	if tween != null and tween.is_running():
		tween.stop()
		
	tween = create_tween()
	tween.tween_property(bucket_follow_path, "progress_ratio", 1.0, pumping_duration)
	tween.finished.connect(func():
		bucket_follow_path.progress_ratio = 0.0
		pumping_in_progress = false
	)
