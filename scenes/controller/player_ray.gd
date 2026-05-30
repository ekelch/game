extends RayCast3D

@onready var proto_controller: CharacterBody3D = $"../.."
var lastCollider: RID;
signal colliderChanged;

func _ready() -> void:
	self.add_exception(proto_controller)

func _physics_process(_delta: float) -> void:
	if get_collider_rid() != lastCollider:
		lastCollider = get_collider_rid()
		colliderChanged.emit()

func interact():
	var interact_with = get_collider()
	if interact_with && interact_with.has_method("interact"):
		interact_with.call("interact")


func _on_collider_changed() -> void:
	if get_collider() && get_collider().has_method("get_tooltip"):
		UIController.showTooltip(get_collider().call("get_tooltip"))
	else:
		UIController.clearTooltip()
