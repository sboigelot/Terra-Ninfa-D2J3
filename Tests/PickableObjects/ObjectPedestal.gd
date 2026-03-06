class_name ObjectPedestal
extends Node3D

signal activated(object_pedestal:ObjectPedestal, pickable_object:PickableObject)
signal deactivated(object_pedestal:ObjectPedestal)

@export var valid_object_tags:Array[String]

@export var csg_mesh:CSGCylinder3D
@export var deactivated_material:StandardMaterial3D
@export var activated_material:StandardMaterial3D

var activating_objects: Array[PickableObject]

func _ready() -> void:
	csg_mesh.material = deactivated_material
	
func _on_area_3d_area_entered(area: Area3D) -> void:
	print("Another area entered:", area.name)
	if area is PickableObject:
		if valid_object_tags.has(area.object_tag):
			activating_objects.append(area)
			if activating_objects.size() == 1:
				csg_mesh.material = activated_material
				activated.emit(self, area)


func _on_area_3d_area_exited(area: Area3D) -> void:
	if activating_objects.has(area):
		activating_objects.erase(area)
		if activating_objects.size() == 0:
			csg_mesh.material = deactivated_material
			deactivated.emit(self)
