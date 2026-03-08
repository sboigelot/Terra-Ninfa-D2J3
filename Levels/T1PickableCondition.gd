extends PickableObject

@export var t1_gate: RepairableNode3D:
	set(value):
		if t1_gate == value:
			return
		
		if t1_gate != null:
			NodeHelper.disconnect_if_connected(t1_gate.broken_changed, on_gate_broken_changed)
		
		t1_gate = value
		
		if t1_gate != null:
			NodeHelper.connect_if_not_connected(t1_gate.broken_changed, on_gate_broken_changed)

var picked_once: bool = false

func _ready() -> void:
	pickable = t1_gate == null
	picked_up.connect(on_picked_up)
	
func on_picked_up(_pickable_object:PickableObject):
	picked_once = true
	
func on_gate_broken_changed():
	pickable = picked_once or not t1_gate.broken
