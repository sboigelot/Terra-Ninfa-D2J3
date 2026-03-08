extends Control

class_name NinfaMenu

signal ninfa_gui_fsm_request

var _tween : Tween

func _tween_initialize() -> void:
    if self._tween != null and self._tween.is_running():
        self._tween.stop()
    
    self._tween = create_tween()

func hide_transition() -> void:
    self._tween_initialize()

func reveal_transition() -> void:
    self._tween_initialize()