class_name PickableObjectController
extends Node3D

@export var mouse_3d_cursor:Node3D
@export var picked_object_holder:Marker3D

func _ready() -> void:
	assert(mouse_3d_cursor != null)
	assert(picked_object_holder != null)
	connect_pickable_objects()

func connect_pickable_objects() -> void:
	for pickable_object:PickableObject in get_tree().get_nodes_in_group("pickable_object"):
		NodeHelper.connect_if_not_connected(pickable_object.picked_up, _on_pickable_object_picked_up)
		NodeHelper.connect_if_not_connected(pickable_object.dropped_down, _on_pickable_object_dropped_down)

func _on_pickable_object_picked_up(pickable_object:PickableObject) -> void:
	pickable_object.original_parent.remove_child(pickable_object)
	picked_object_holder.add_child(pickable_object)
	pickable_object.position = Vector3.ZERO

func _on_pickable_object_dropped_down(pickable_object:PickableObject) -> void:
	picked_object_holder.remove_child(pickable_object)
	pickable_object.original_parent.add_child(pickable_object)
	pickable_object.global_position = mouse_3d_cursor.global_position

func _process(_delta: float) -> void:
	update_mouse_3d_cursor_position()
	
func update_mouse_3d_cursor_position() -> void:
	var mouse_position := get_viewport().get_mouse_position()
	var camera := get_viewport().get_camera_3d()
	var origin := camera.project_ray_origin(mouse_position)
	var direction := camera.project_ray_normal(mouse_position)
	var ray_length := camera.far
	var end := origin + direction * ray_length
	var query := PhysicsRayQueryParameters3D.create(origin, end)
	var space_state := get_world_3d().direct_space_state
	var result := space_state.intersect_ray(query)
	var collided = result.has("collider")
	mouse_3d_cursor.visible = picked_object_holder.get_child_count() > 0 
	if collided:
		var mouse_position_3D = result.get("position", end)
		mouse_3d_cursor.position = mouse_position_3D
