@tool
extends EditorInspectorPlugin

var source_water_node_3d:WaterNode3D
var source_mechanism_3d:Mechanism3D
var source_label:Label
var source_details:RichTextLabel

func _can_handle(object: Object) -> bool:
	if object is WaterNode3D:
		return true
	if object is WaterRooter:
		return true
	if object is WaterGate:
		return true
	return false

func _parse_begin(object: Object):
	source_label = Label.new()
	add_custom_control(source_label)
	
	source_details = RichTextLabel.new()
	source_details.bbcode_enabled = true
	source_details.fit_content = true
	add_custom_control(source_details)
	
	_update_source_info()
	
	_add_button("Pick as source", 
		func(): 
			source_water_node_3d = null
			source_mechanism_3d = null
			if object is WaterNode3D:
				source_water_node_3d = object
			if object is Mechanism3D:
				source_mechanism_3d = object
			_update_source_info()
	)
	
	if source_water_node_3d != null and source_water_node_3d != object:
		if object is WaterNode3D:
			_add_button("Add to source downstream", 
				func(): 
					if not source_water_node_3d.downstream.has(object):
						source_water_node_3d.downstream.append(object)
						source_water_node_3d.propagate_water_downstream()
					else:
						print_rich("[color=orange]%s is already downstream of %s[/color]" % [object.name, source_water_node_3d.name])
					_update_source_info()
			)
			
			_add_button("Remove from source downstream", 
				func(): 
					source_water_node_3d.downstream.erase(object)
					object.set_upstream_flow(source_water_node_3d, false)
					_update_source_info()
			)
			
			_add_button("List upstreams", 
				func(): _list_upstreams(object)
			)
			
		if object is Mechanism3D:
			_add_button("Add to source mechanisms", 
				func(): 
					if not source_water_node_3d.mechanisms.has(object):
						source_water_node_3d.mechanisms.append(object)
						source_water_node_3d.propagate_water_downstream()
					else:
						print_rich("[color=orange]%s is already mechanisms of %s[/color]" % [object.name, source_water_node_3d.name])
					_update_source_info()
			)
			
			_add_button("Remove from source mechanisms", 
				func(): 
					source_water_node_3d.mechanisms.erase(object)
					object.set_water_intake(source_water_node_3d)
					_update_source_info()
			)

	if source_mechanism_3d != null and source_mechanism_3d != object:
		_add_button("Add to mechanism downstream", 
			func(): 
				if not source_mechanism_3d.downstream.has(object):
					source_mechanism_3d.downstream.append(object)
					source_mechanism_3d.propagate_water_downstream()
				else:
					print_rich("[color=orange]%s is already downstream of %s[/color]" % [object.name, source_water_node_3d.name])
				_update_source_info()
		)
		
		_add_button("Remove from mechanism downstream", 
			func(): 
				source_mechanism_3d.downstream.erase(object)
				object.set_upstream_flow(source_mechanism_3d, false)
				_update_source_info()
		)
		
func _add_button(text:String, on_pressed:Callable, disabled:bool = false) -> void:
	var button = Button.new()
	button.text = text
	button.pressed.connect(on_pressed)
	button.disabled = disabled
	add_custom_control(button)

func _update_source_info() -> void:
	
	source_label.text = "Source: none"
	source_details.text = ""
	
	if source_water_node_3d != null:
		source_label.text = "Source: %s" % source_water_node_3d.name
		var detail_text = "[u]Details:[/u]"
		
		detail_text += "\n\t[u]Downstream:[/u]"
		for water_node:WaterNode3D in source_water_node_3d.downstream:
			detail_text += "\n\t\t- %s" % water_node.name
		
		detail_text += "\n\t[u]Mechanisms:[/u]"
		for mechanism:Mechanism3D in source_water_node_3d.mechanisms:
			detail_text += "\n\t\t- %s" % mechanism.name
		
		source_details.text = detail_text
		
	if source_mechanism_3d != null:
		source_label.text = "Source: %s" % source_mechanism_3d.name
		var detail_text = "[u]Details:[/u]"
		
		detail_text += "\n\t[u]Downstream:[/u]"
		for water_node:WaterNode3D in source_mechanism_3d.downstream:
			detail_text += "\n\t\t- %s" % water_node.name
		
		source_details.text = detail_text

func _list_upstreams(water_node:WaterNode3D) -> void:
	print("Searching for %s upstreams..." % water_node.name)
	var csg_parent = water_node.get_parent().get_parent()
	for csg in csg_parent.get_children():
		if csg.get_child_count() == 0:
			continue
	
		var csg_child = csg.get_child(0)
		if csg_child is WaterNode3D:
			var other_water_node:WaterNode3D = csg_child
			if other_water_node.downstream.has(water_node):
				print("\t%s/%s is upstream" % [csg.name, other_water_node.name])
	
	var terrain = csg_parent.get_parent().get_parent()
	var testmap = terrain.get_parent()
	var mechanisms = testmap.get_node("Mecanisms")
	_list_upstreams_in_mechanisms(mechanisms, water_node)
	
	print("done")

func _list_upstreams_in_mechanisms(node:Node3D, water_node:WaterNode3D) -> void:
	if node is WaterGate:
		var mech:WaterGate = node
		if mech.downstream.has(water_node):
			print("\t%s is upstream" % [mech.name])
			
	if node is WaterRooter:
		var mech:WaterRooter = node
		if mech.downstream.has(water_node):
			print("\t%s is upstream" % [mech.name])

	for child in node.get_children():
		_list_upstreams_in_mechanisms(child, water_node)
