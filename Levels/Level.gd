class_name Level
extends Node3D

@export var control_info: Node3D
@export var hud: MarginContainer
@export var hud_progress_bar: ProgressBar
@export var plants_placeholder: Node3D
@export var camera: Camera3D
@export var lake_water_node:WaterNode3D

var irrigated_plants:Array[Plant3D]
var max_plants:int

var progress_tween: Tween
var victory_triggered:bool = false

func _ready() -> void:
	Gui.ninfa_gui_menu_active.connect(_on_menu_menu_active_changed)
	set_pause(Gui.state == NINFA_GUI.STATES.MAIN_MENU)
	
	for plant:Plant3D in plants_placeholder.get_children():
		if plant.irrigated and not irrigated_plants.has(plant):
			irrigated_plants.append(plant)
		NodeHelper.connect_if_not_connected(
			plant.irrigated_changed,
			_on_plant_irrigated_changed
		)
	max_plants = plants_placeholder.get_child_count()
	hud_progress_bar.max_value = max_plants
	
	update_irrigation_progress()
	
	lake_water_node.flowing_changed.connect(_on_lake_water_node_flowing_changed)
	
func _on_menu_menu_active_changed(menu_active:bool) -> void:
	set_pause(menu_active)
	
func set_pause(paused) -> void:
	control_info.visible = not paused
	hud.visible = not paused
	get_tree().paused = paused
	
	#if not paused:
		#await get_tree().create_timer(5.0).timeout
		#victory()

func _on_plant_irrigated_changed(plant:Plant3D) -> void:
		if plant.irrigated:
			if not irrigated_plants.has(plant):
				irrigated_plants.append(plant)
		else:
			irrigated_plants.erase(plant)
		update_irrigation_progress()

func update_irrigation_progress() -> void:
	var irrigated_plant_count = irrigated_plants.size()
	
	if progress_tween != null and progress_tween.is_running():
		progress_tween.stop()
		
	progress_tween = create_tween()
	progress_tween.set_parallel(true)
	progress_tween.tween_property(
		hud_progress_bar, 
		"value", 
		irrigated_plant_count, 
		0.5)\
		.set_trans(Tween.TRANS_BOUNCE)\
		.set_ease(Tween.EASE_OUT)
	
	if irrigated_plant_count >= max_plants:
		victory()
		
func victory():
	if victory_triggered:
		return
	victory_triggered = true
	SfxManager.play("achievement")
	
	await get_tree().create_timer(10.0).timeout
	Gui.trigger_victory()

func _on_lake_water_node_flowing_changed() -> void:
	if lake_water_node.flowing:
		if not SfxManager.ambiance_collection.has("ambiance_pond_filled_loop"):
			SfxManager.ambiance_collection.append("ambiance_pond_filled_loop")
		else:
			SfxManager.ambiance_collection.erase("ambiance_pond_filled_loop")
