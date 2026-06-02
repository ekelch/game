extends CanvasLayer

signal loading_screen_ready
@onready var progress_bar: TextureProgressBar = $TextureProgressBar

func _ready() -> void:
	#can animate start and await finish
	loading_screen_ready.emit()

func _on_progress_changed(new_value: float) -> void:
	progress_bar.value = new_value

func _on_load_finished() -> void:
	#backward animation await
	queue_free()
