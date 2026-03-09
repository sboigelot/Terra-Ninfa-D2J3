@tool
class_name WaterNode3D
extends ProceduralWaterShape

signal flowing_changed()

@export var flowing:bool:
	set(value):
		var new_value = not prevent_flowing and value
		if flowing == new_value:
			return
			
		flowing = new_value
		
		if flowing:
			start_flowing_tween()
		else:
			stop_flowing_tween()
		
		flowing_changed.emit()
		
	get():
		return flowing

@export var prevent_flowing:bool = false:
	set(value):
		if prevent_flowing == value:
			return
			
		prevent_flowing = value
		flowing = _flowing_upstream.size() > 0

@export var downstream: Array[WaterNode3D]
@export var mechanisms: Array[Mechanism3D]
@export var plants: Array[Plant3D]

@export var can_irrigate_plants: bool = true
@export var debug_hook:bool = false

var _flowing_upstream: Array

func set_upstream_flow(upstream:Variant, upstream_flowing:bool) -> void:
	if debug_hook:
		pass
		
	if _flowing_upstream == null:
		_flowing_upstream = []
	
	if not upstream_flowing:
		if _flowing_upstream.has(upstream):
			_flowing_upstream.erase(upstream)
			propagate_water_downstream()
	else:
		if not _flowing_upstream.has(upstream):
			_flowing_upstream.append(upstream)
			propagate_water_downstream()
	flowing = _flowing_upstream.size() > 0
	
func _ready() -> void:
	super()
		
	if plants.size() > 0 and not can_irrigate_plants:
		printerr("Water_node %s/%s can't irrigate plants by has %d" % [
			get_parent().name,
			name,
			plants.size()
		])
		
	if not flowing:
		stop_flowing_instant()
		
	NodeHelper.connect_if_not_connected(animation_finished, propagate_water_downstream)
	propagate_water_downstream()

func propagate_water_downstream() -> void:
	for water:WaterNode3D in downstream:
		water.set_upstream_flow(self, flowing)
	for mechanism:Mechanism3D in mechanisms:
		mechanism.set_water_intake(self)
	for plant:Plant3D in plants:
		plant.irrigated = flowing
