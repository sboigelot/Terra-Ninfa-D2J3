@tool
extends EditorInspectorPlugin

func _can_handle(object: Object) -> bool:
	if object is Plant3D:
		return true
	return false

func _get_all_water_nodes(sample_plant:Plant3D) -> Array[WaterNode3D]:
	var plant_placeholder = sample_plant.get_parent()
	var level = plant_placeholder.get_parent()
	
	var all_water_nodes:Array[WaterNode3D]
	
	var canals = level.get_node("Terrain/CSGCombiner3D/Canals")
	for canal:Node3D in canals.get_children():
		if canal.get_child_count() == 1:
			var child = canal.get_child(0)
			if child is WaterNode3D:
				all_water_nodes.append(child)
				
	var waters = level.get_node("Waters")
	for child:Node3D in canals.get_children():
		if child is WaterNode3D:
			all_water_nodes.append(child)
	
	print("%s water node found" % all_water_nodes.size())
	return all_water_nodes

func _relink_plants(sample_plant:Plant3D) -> void:
	var all_water_nodes = _get_all_water_nodes(sample_plant)
	var plant_placeholder = sample_plant.get_parent()
	for plant:Plant3D in plant_placeholder.get_children():
		_relink_plant(plant, all_water_nodes)

func _show_plants(sample_plant:Plant3D, visible:bool) -> void:
	var plant_placeholder = sample_plant.get_parent()
	for plant:Plant3D in plant_placeholder.get_children():
		plant.disable_sfx = true
		plant.irrigated = visible
		
	await sample_plant.get_tree().create_timer(5.0).timeout
	for plant:Plant3D in plant_placeholder.get_children():
		plant.disable_sfx = false
		
func _random_visual(plant:Plant3D) -> void:
	plant.get_child(0).position = Vector3.ZERO
	plant.scale = Vector3.ONE * randf_range(0.75, 1.25)
	plant.rotation_degrees = Vector3(0,randf_range(-180, 180),0)
		
func _random_visuals(sample_plant:Plant3D) -> void:
	var plant_placeholder = sample_plant.get_parent()
	for plant:Plant3D in plant_placeholder.get_children():
		_random_visual(plant)
		
func _relink_plant(plant:Plant3D, all_water_nodes:Array[WaterNode3D]) -> void:
	if all_water_nodes.size() == 0:
		all_water_nodes = _get_all_water_nodes(plant)
	
	var output = "Linking %s...\n" % plant.name
	
	var closest_distance:float = INF
	var closest_water_node:WaterNode3D
	for water_node in all_water_nodes:
		while water_node.plants.has(plant):
			output += "\tunlink %s/%s\n"  % [water_node.get_parent().name, water_node.name]
			water_node.plants.erase(plant)
			
		if not water_node.can_irrigate_plants:
			continue
		
		if water_node.falling_water:
			continue
			
		var distance = plant.global_position.distance_to(water_node.global_position)
		if (closest_water_node == null or
			closest_distance > distance):
				closest_distance = distance
				closest_water_node = water_node
	
	output += "\tlink %s/%s" % [closest_water_node.get_parent().name, closest_water_node.name]
	closest_water_node.plants.append(plant)
	plant.get_child(0).position = Vector3.ZERO
	print_rich(output)
	
func _parse_begin(object: Object):
	
	_add_button("Link this plant", 
		func(): _relink_plant(object, [])
	)
	
	_add_button("Link all plants", 
		func(): _relink_plants(object)
	)
	
	_add_button("Random scale & rotation", 
		func(): 
			_random_visual(object)
	)
	
	_add_button("Random all scale & rotation", 
		func(): 
			_random_visuals(object)
	)
	
	_add_button("Show all plants", func(): _show_plants(object, true))
	_add_button("Hide all plants", func(): _show_plants(object, false))

func _add_button(text:String, on_pressed:Callable, disabled:bool = false) -> void:
	var button = Button.new()
	button.text = text
	button.pressed.connect(on_pressed)
	button.disabled = disabled
	add_custom_control(button)
