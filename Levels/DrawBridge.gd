@tool
extends RepairableNode3D

@export var vehicule_path_follow:PathFollow3D
@export var shovel_token:PickableObject

var tween:Tween
var completed:bool = false

func _ready() -> void:
	broken_changed.connect(_on_broken_changed)
	shovel_token.visible = false
	shovel_token.pickable = false
	
func _on_broken_changed() -> void:
	if broken:
		if tween != null and tween.is_running():
			tween.stop()
	elif not completed:
		tween = create_tween()
		tween.tween_property(vehicule_path_follow, "progress_ratio", 1.0, 5.0)
		tween.finished.connect(func():
			completed = true
			shovel_token.visible = true
			shovel_token.pickable = true
		)
