extends Node3D
@onready var sunlight: DirectionalLight3D = $Sunlight
@onready var dn_timer: Timer = $dnTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("dncycle") && dn_timer.is_stopped():
		dn_timer.start(.05)
	if event.is_action_released("dncycle"):
		dn_timer.stop()


func _on_timer_timeout() -> void:
	sunlight.rotate_x(deg_to_rad(1.5))
