@tool
class_name ProceduralWaterShape
extends Node3D

signal animation_finished()

@export var water_size: Vector3 = Vector3.ONE:
	set(value):
		water_size = value
		change_csg_box_size()

var _material:StandardMaterial3D = preload("res://Assets/Materials/water_material.material")
@export var material: StandardMaterial3D:
	set(value):
		_material = value
		csg_box.material = material
	get():
		return _material
		
@export var falling_water:bool = false

var csg_box:CSGBox3D
var tween:Tween

func _init() -> void:
	set_notify_transform(true)
	
	csg_box = get_node_or_null("_csgbox3d")
	if csg_box == null:
		csg_box = CSGBox3D.new()
		csg_box.name = "_csgbox3d"
		csg_box.material = material
		add_child(csg_box, false, Node.InternalMode.INTERNAL_MODE_BACK)
		change_csg_box_size()
		
func _ready() -> void:
	change_csg_box_size()

func change_csg_box_size() -> void:
	csg_box.size = water_size
	csg_box.scale = Vector3.ONE
	csg_box.position = Vector3.ZERO

func get_aabb() -> AABB:
	var aabb = AABB(position, water_size)
	return aabb

func _notification(what) -> void:
	match what:
		NOTIFICATION_TRANSFORM_CHANGED:
			if scale != Vector3.ONE:
				var scale_change = scale - Vector3.ONE
				water_size += scale_change
				scale = Vector3.ONE

func start_flowing_tween(duration: float = 2.0) -> void:
	if tween != null and tween.is_running():
		tween.stop()
		
	csg_box.visible = true
	if falling_water:
		csg_box.position = Vector3(0, water_size.y /2, 0)
	else:
		csg_box.position = Vector3(0, -water_size.y /2, 0)
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(csg_box, "scale", Vector3.ONE, duration)\
			.set_ease(Tween.EASE_OUT)\
			.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(csg_box, "position", Vector3.ZERO, duration)\
			.set_ease(Tween.EASE_OUT)\
			.set_trans(Tween.TRANS_LINEAR)
	tween.finished.connect(animation_finished.emit)
	
func stop_flowing_tween(duration: float = 2.0) -> void:
	if tween != null and tween.is_running():
		tween.stop()
		
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(csg_box, "scale", Vector3(1.0, 0.0, 1.0), duration)
	tween.tween_property(csg_box, "position", Vector3(0, -water_size.y /2 , 0), duration)
	tween.set_parallel(false)
	tween.tween_property(csg_box, "visible", false, 0.0)
	tween.finished.connect(animation_finished.emit)
	
func stop_flowing_instant() -> void:
	if tween != null and tween.is_running():
		tween.stop()
		
	#csg_box.visible = false
	csg_box.scale = Vector3(1.0, 0.0, 1.0)
	csg_box.position = Vector3(0, -csg_box.size.y / 2, 0)
	animation_finished.emit()
	
	
