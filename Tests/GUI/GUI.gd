extends CanvasLayer

signal ninfa_gui_menu_active


var state : int = NINFA_GUI.STATES.MAIN_MENU

@onready var references : Dictionary = {
	str(NINFA_GUI.STATES.MAIN_MENU): $mainMenu,
	str(NINFA_GUI.STATES.INGAME_MENU): $inGameMenu
}

###############################################################################
###############################################################################
## SECTION: Private Member Functions ##########################################
###############################################################################
###############################################################################
func _gui_fsm(a_sender, a_request) -> void:
	var _tmp_actionKey = NINFA_GUI.ACTIONS.find_key(a_request)
	print(
		"Ninfa GUI: Received Request from \"%s\": %s" % [a_sender, _tmp_actionKey]
	)

	match a_request:
		NINFA_GUI.ACTIONS.START_GAME:
			print("Request == Start Game")

			match state:
				NINFA_GUI.STATES.MAIN_MENU:
					print("before transition")
					self.references[str(NINFA_GUI.STATES.MAIN_MENU)].hide_transition()
					self.ninfa_gui_menu_active.emit(false)
					self.state = NINFA_GUI.STATES.GAME

		NINFA_GUI.ACTIONS.RETURN_TO_MAIN_MENU:
			self.ninfa_gui_menu_active.emit(true)
			self.references[str(NINFA_GUI.STATES.MAIN_MENU)].reveal_transition()
			self.state = NINFA_GUI.STATES.MAIN_MENU

# REMARK: DEBUG ONLY
func _on_show_menu_pressed() -> void:
	self._gui_fsm(self, NINFA_GUI.ACTIONS.RETURN_TO_MAIN_MENU)

###############################################################################
###############################################################################
## SECTION: Godot Loadtime Function Overrides #################################
###############################################################################
###############################################################################
func _ready() -> void:
	# DESCRIPTION: Make known that menu is active
	self.ninfa_gui_menu_active.emit(true)

	# DESCRIPTION: Connect to the request signal of all the contexts 
	for _key in self.references.keys():
		self.references[_key].connect("ninfa_gui_fsm_request", self._gui_fsm)

	# REMARK: DEBUG ONLY
	$Button.pressed.connect(_on_show_menu_pressed)
