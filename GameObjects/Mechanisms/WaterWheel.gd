@tool
class_name WaterWheel
extends Mechanism3D

signal powered_up()
signal powered_down()

@export var powered:bool:
	set(value):
		if value == powered:
			return
			
		powered = value
		if value:
			powered_up.emit()
		else:
			powered_down.emit()
			
@export var rotating_visual:Node3D
@export var rotating_speeds:Vector3 = Vector3(0,0,1)

@export var controlled_mechanisms:Array[Mechanism3D]

func _on_water_intake_changed() -> void:
	powered = _water_intakes.size() > 0
	propagate_water_downstream()
	
func propagate_water_downstream() -> void:
	for mechanism:Mechanism3D in controlled_mechanisms:
		mechanism.on_mechanism_activated(powered)
	
func _on_player_click() -> void:
	pass
	
func _process(delta: float) -> void:
	if not powered:
		return
		
	rotate_wheel(delta)

func rotate_wheel(delta: float) -> void:
	if rotating_visual == null:
		return
	
	rotating_visual.rotation_degrees += rotating_speeds * delta

func on_mechanism_activated(_activated: bool) -> void:
	pass
