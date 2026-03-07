@tool
class_name WaterNode3D
extends ProceduralWaterShape
		
@export var flowing:bool:
	set(value):
		if flowing == value:
			return
		flowing = value
		
		if flowing:
			start_flowing_tween()
		else:
			stop_flowing_tween()

	get():
		return flowing

@export var downstream: Array[WaterNode3D]
@export var mechanisms: Array[Mechanism3D]
@export var plants: Array[Plant3D]

func _ready() -> void:
	super()
	if not flowing:
		stop_flowing_instant()
		
	NodeHelper.connect_if_not_connected(animation_finished, propagate_water_downstream)
	propagate_water_downstream()

func propagate_water_downstream() -> void:
	for water:WaterNode3D in downstream:
		water.flowing = flowing
	for mechanism:Mechanism3D in mechanisms:
		mechanism.set_water_intake(self)
	for plant:Plant3D in plants:
		plant.irrigated = flowing
