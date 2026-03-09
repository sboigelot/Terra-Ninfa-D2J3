extends CanvasLayer

signal ninfa_gui_menu_active(menu_active:bool)

var state : int = NINFA_GUI.STATES.MAIN_MENU

@onready var open_menu_button: Button = $MarginContainer/OpenMenuButton

@onready var references : Dictionary = {
	str(NINFA_GUI.STATES.MAIN_MENU): $mainMenu
}

###############################################################################
###############################################################################
## SECTION: Private Member Functions ##########################################
###############################################################################
###############################################################################
func _gui_fsm(a_sender, a_request) -> void:
	var _tmp_actionKey = NINFA_GUI.ACTIONS.find_key(a_request)
	# print(
	# 	"Ninfa GUI: Received Request from \"%s\": %s" % [a_sender, _tmp_actionKey]
	# )

	match a_request:
		NINFA_GUI.ACTIONS.START_GAME:
			match state:
				NINFA_GUI.STATES.MAIN_MENU:
					self.references[str(NINFA_GUI.STATES.MAIN_MENU)].hide_transition()
					self.ninfa_gui_menu_active.emit(false)
					self.state = NINFA_GUI.STATES.GAME
					self.open_menu_button.visible = true

		NINFA_GUI.ACTIONS.RETURN_TO_MAIN_MENU:
			self.ninfa_gui_menu_active.emit(true)
			self.references[str(NINFA_GUI.STATES.MAIN_MENU)].reveal_transition()
			self.state = NINFA_GUI.STATES.MAIN_MENU
			self.open_menu_button.visible = false

###############################################################################
###############################################################################
## SECTION: Godot Loadtime Function Overrides #################################
###############################################################################
###############################################################################
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# DESCRIPTION: Make known that menu is active
	_gui_fsm(self, NINFA_GUI.ACTIONS.RETURN_TO_MAIN_MENU)

	# DESCRIPTION: Connect to the request signal of all the contexts 
	for _key in self.references.keys():
		self.references[_key].connect("ninfa_gui_fsm_request", self._gui_fsm)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if state == NINFA_GUI.STATES.GAME:
			_gui_fsm(self, NINFA_GUI.ACTIONS.RETURN_TO_MAIN_MENU)

func _on_open_menu_button_pressed() -> void:
	_gui_fsm(self, NINFA_GUI.ACTIONS.RETURN_TO_MAIN_MENU)
