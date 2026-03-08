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

var _flowing_upstream: Array[Variant]

func set_upstream_flow(upstream:Variant, upstream_flowing:bool) -> void:
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

static func build_water_node_from_csg_box(csg_box_3d:CSGBox3D) -> void:
	#print("_build_water_node(%s)" % csg_box_3d)
	var water_node:WaterNode3D
	var exisiting:bool = (csg_box_3d.get_child_count() == 1 and 
							csg_box_3d.get_child(0) is WaterNode3D)
							
	#print("\texisiting: %s" % exisiting)
	if exisiting:
		water_node = csg_box_3d.get_child(0)
	else:
		water_node = WaterNode3D.new()
		water_node.name = "water_node"
		
	#print("\tupdating size")
	water_node.water_size = csg_box_3d.size
	if csg_box_3d.size.y > csg_box_3d.size.x:
		water_node.falling_water = true
	
	if not exisiting:
		#print("\tadd_child")
		csg_box_3d.add_child(water_node)
		water_node.owner = EditorInterface.get_edited_scene_root()
	
	#print("\tupdating position")
	water_node.position = Vector3.ZERO
	#water_node.stop_flowing_instant()
	water_node.start_flowing_tween(1.0)
	
	print("\tdone")
