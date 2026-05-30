extends CanvasLayer

signal loading_screen_ready

func _ready() -> void:
	#can animate start and await finish
	print("going to emit")
	loading_screen_ready.emit()

func _on_progress_changed(new_value: float) -> void:
	pass

func _on_load_finished() -> void:
	#backward animation await
	queue_free()
