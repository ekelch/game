extends Node3D
@onready var anime: AnimationPlayer = $AnimationPlayer
const open_tooltip: String = "open"
const close_tooltip: String = "close"
var interact_keybind: String = "unbound"
var door_open: bool = false

func _on_ready() -> void:
	var interact_keybinds: Array[InputEvent] = InputMap.action_get_events("interact")
	if !interact_keybinds.is_empty():
		var key = interact_keybinds[0] as InputEventKey
		interact_keybind = key.as_text_physical_keycode()
	
func get_tooltip() -> String:
	return "%s [%s]" % [close_tooltip if door_open else open_tooltip, interact_keybind]
	
func interact() -> void:
	if door_open:
		anime.play_backwards("open")
		door_open = false
	else:
		anime.play("open")
		door_open = true
	UIController.showTooltip(get_tooltip())
