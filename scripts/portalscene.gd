extends Node3D

const mainScenePath = "res://scenes/main.tscn";

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		SceneLoader.load_scene(mainScenePath)
