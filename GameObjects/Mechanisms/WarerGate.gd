@tool
class_name WaterGate
extends Mechanism3D

signal refuse_opening()

var _gate_open:bool = false
@export var gate_open:bool:
	set(value):
		set_gate_open(value)
	get():
		return _gate_open

@export var open_on_player_click:bool = true

## used to call directly with signal events
func set_gate_open(value:bool) -> void:
	if value == gate_open:
			return
	_gate_open = value
	
	if gate_visual_open != null:
		gate_visual_open.visible = _gate_open
	if gate_visual_close != null:
		gate_visual_close.visible = not _gate_open
	
	propagate_water_downstream()
	
@export var downstream: Array[WaterNode3D]

@export var gate_visual_open: Node3D
@export var gate_visual_close: Node3D

func _on_water_intake_changed() -> void:
	propagate_water_downstream()

func propagate_water_downstream() -> void:
	for water_node:WaterNode3D in downstream:
		var water_activated = gate_open and _water_intakes.size() > 0
		water_node.set_upstream_flow(self, water_activated)

func _on_player_click() -> void:
	SfxManager.play("click")
	if open_on_player_click:
		gate_open = not gate_open
	else:
		refuse_opening.emit()

func on_mechanism_activated(activated: bool) -> void:
	gate_open = activated
