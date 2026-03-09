class_name Level
extends Node3D

@export var control_info: Node3D
@export var tvui: TvUi
@export var plants_placeholder: Node3D

const min_time_during_update_plant_count: float = 1.0
var time_since_update_plant_count:float
var plant_count_invalidated:bool = false

func _ready() -> void:
	Gui.ninfa_gui_menu_active.connect(_on_menu_menu_active_changed)
	set_pause(Gui.state == NINFA_GUI.STATES.MAIN_MENU)
	update_irrigation_progress()
	
	for plant:Plant3D in plants_placeholder.get_children():
		NodeHelper.connect_if_not_connected(
			plant.irrigated_changed,
			_on_plant_irrigated_changed
		)
		
func _process(delta: float) -> void:
	time_since_update_plant_count += delta
	if (plant_count_invalidated and
		time_since_update_plant_count >= min_time_during_update_plant_count):
			update_irrigation_progress() 
	
func _on_menu_menu_active_changed(menu_active:bool) -> void:
	set_pause(menu_active)
	
func set_pause(paused) -> void:
	control_info.visible = not paused
	#get_tree().paused = paused

func _on_plant_irrigated_changed(plant:Plant3D) -> void:
	plant_count_invalidated = true

func update_irrigation_progress() -> void:
	time_since_update_plant_count = 0.0
	var max_plants = plants_placeholder.get_child_count()
	var irrigated_plants = plants_placeholder.get_children()\
									.filter(
										func(plant:Plant3D): return plant.irrigated
									)\
									.size()
	
	tvui.irrigated_progress_bar.max_value = max_plants
	tvui.irrigated_progress_bar.value = irrigated_plants
	
	if irrigated_plants >= max_plants:
		victory()
		
func victory():
	pass
