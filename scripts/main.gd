extends Node3D
const PORTALSCENE = "res://scenes/levels/portalscene.tscn";

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		SceneLoader.load_scene(PORTALSCENE)
