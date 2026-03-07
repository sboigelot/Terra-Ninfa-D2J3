@tool
class_name PickableObjectPedestal
extends StaticBody3D

signal activated_no_params()
signal activated(object_pedestal:PickableObjectPedestal, pickable_object:PickableObject)
signal deactivated_no_params()
signal deactivated(object_pedestal:PickableObjectPedestal)

@export var valid_object_tags:Array[String]
@export var target_object_count:int = 1

@export var detection_area3d: Area3D:
	set(value):
		detection_area3d = value
		update_configuration_warnings() 
		
@export var activation_visual: GeometryInstance3D:
	set(value):
		activation_visual = value
		update_configuration_warnings() 
		
@export var deactivated_material:StandardMaterial3D:
	set(value):
		deactivated_material = value
		if activation_visual != null:
			activation_visual.material = deactivated_material
		
@export var activated_material:StandardMaterial3D

@export var controlled_water_flow:Array[WaterNode3D]
@export var controlled_mechanisms:Array[Mechanism3D]

@export var is_activated:bool:
	set(value):
		if is_activated == value:
			return
		is_activated = value
		
		if is_activated:
			if activation_visual != null:
				activation_visual.material = activated_material
			activated_no_params.emit()
		else:
			if activation_visual != null:
				activation_visual.material = deactivated_material
			deactivated_no_params.emit()
		
		propagate_activation()

var activating_objects: Array[PickableObject]

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array
	
	if detection_area3d == null:
		warnings.append("Area3D child is missing")
	
	if activation_visual == null:
		warnings.append("activation_visual child is missing")
	else:
		var properties:Array[Dictionary] = activation_visual.get_property_list()
		var has_material_property = properties.any(
			func(dic:Dictionary): return dic["name"] == "material"
		)
		if not has_material_property:
			warnings.append("no material property in activation_visual child")
	
	return warnings

func _ready() -> void:
	if activation_visual != null:
		activation_visual.material = activated_material if is_activated else deactivated_material
		
	if detection_area3d != null:
		detection_area3d.collision_layer = 0
		detection_area3d.collision_mask = 2
		NodeHelper.connect_if_not_connected(detection_area3d.area_entered, _on_area_3d_area_entered)
		NodeHelper.connect_if_not_connected(detection_area3d.area_exited, _on_area_3d_area_exited)
	
func _on_area_3d_area_entered(area: Area3D) -> void:
	#print("Another area entered:", area.name)
	if area is PickableObject:
		if valid_object_tags.size() == 0 or valid_object_tags.has(area.object_tag):
			activating_objects.append(area)
			if activating_objects.size() == target_object_count:
				is_activated = true
				activated.emit(self, area)

func _on_area_3d_area_exited(area: Area3D) -> void:
	if activating_objects.has(area): 
		activating_objects.erase(area)
		if activating_objects.size() < target_object_count:
			is_activated = false
			deactivated.emit(self)
				
func propagate_activation() -> void:
	for water_node:WaterNode3D in controlled_water_flow:
		water_node.flowing = is_activated
	for mechanism:Mechanism3D in controlled_mechanisms:
		#mechanism.set_pedestal_intake(self,is_activated)
		printerr("Not implemented: #mechanism.set_pedestal_intake(self,is_activated)")
		pass
