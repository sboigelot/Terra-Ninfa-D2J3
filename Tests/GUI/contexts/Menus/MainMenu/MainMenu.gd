extends NinfaMenu

###############################################################################
###############################################################################
## SECTION: Private Member Variables ##########################################
###############################################################################
###############################################################################
var _credtisDefaultPosition : Vector2 = Vector2(0, 0)

@onready var _buttonReferences : Dictionary = {
	"start": {
		"reference": $root/vpos/rootButtons/vpos/start,
		"callback": _on_start_button_pressed
	},
	"credits": {
		"reference": $root/vpos/rootButtons/vpos/credits,
		"callback": _on_credits_button_pressed
	},
	"exit": {
		"reference": $root/vpos/rootButtons/vpos/exit,
		"callback": _on_exit_button_pressed
	}
}

@onready var _credits = $credits

func _initialize_credits() -> void:
	self._credits.position.x -= self._credits.size.x + 48
	self._credits.visible = false

func _toggle_credits() -> void:
	var _tmp_stateBefore = self._credits.visible

	self._credits.visible = true
	self._tween_initialize()

	var _tmp_targetPosition : Vector2 = self._credtisDefaultPosition

	if _tmp_stateBefore:
		_tmp_targetPosition.x -= self._credits.size.x + 48

	self._tween.tween_property(self._credits, "position",  _tmp_targetPosition, 2)
	self._tween.set_trans(Tween.TRANS_CUBIC)
	self._tween.set_ease(Tween.EASE_IN_OUT)

	await self._tween.finished

	if _tmp_stateBefore:
		self._credits.visible = false

###############################################################################
###############################################################################
## SECTION: Public Member Functions ###########################################
###############################################################################
###############################################################################
func reveal_transition() -> void:
	self._initialize_credits()
	super.reveal_transition()

	self._tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 1)
	self._tween.set_trans(Tween.TRANS_CUBIC)
	self._tween.set_ease(Tween.EASE_IN_OUT)

	await self._tween.finished

func hide_transition() -> void:
	super.hide_transition()
			
	self._tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 1)
	self._tween.set_trans(Tween.TRANS_CUBIC)
	self._tween.set_ease(Tween.EASE_IN)

	await self._tween.finished

###############################################################################
###############################################################################
## SECTION: Signal Handling ###################################################
###############################################################################
###############################################################################
func _on_start_button_pressed() -> void:
	print("Start button pressed")
	emit_signal("ninfa_gui_fsm_request", self, NINFA_GUI.ACTIONS.START_GAME)

func _on_credits_button_pressed() -> void:
	self._toggle_credits()

func _on_exit_button_pressed() -> void:
	get_tree().quit()

###############################################################################
###############################################################################
## SECTION: Godot Loadtime Function Overrides #################################
###############################################################################
###############################################################################
func _ready() -> void:
	# DESCRIPTION: Store default position
	self._credtisDefaultPosition = self._credits.position
	self._initialize_credits()

	# DESCRIPTION: Remove exit button in web export
	if OS.has_feature("web"):
		_buttonReferences.exit.reference.queue_free()
		_buttonReferences.erase("exit")

	for _key in self._buttonReferences.keys():
		self._buttonReferences[_key].reference.initialize(
			self._buttonReferences[_key].callback
		)
