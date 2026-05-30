# ProtoController v1.0 by Brackeys
# CC0 License
# Intended for rapid prototyping of first-person games.
# Happy prototyping!

extends CharacterBody3D
@onready var ray_cast_3d: RayCast3D = $Head/RayCast3D

## Can we move around?
@export var can_move : bool = true
## Are we affected by gravity?
@export var has_gravity : bool = true
## Can we press to jump?
@export var can_jump : bool = true
## Can we hold to run?
@export var can_sprint : bool = true
## Can we press to enter freefly mode (noclip)?
@export var can_freefly : bool = false

@export_group("Speeds")
## Look around rotation speed.
@export var look_speed : float = 0.001
## Normal speed.
@export var base_speed : float = 7.0
## Speed of jump.
@export var jump_velocity : float = 5.5
## How fast do we run?
@export var sprint_speed : float = 10.0
## How fast do we freefly?
@export var freefly_speed : float = 25.0
@export var momentum_ground : float = 0.8
@export var momentum_air : float = 0.15
@export var gravity_up: float = 15
@export var gravity_down: float = 17.5

@export_group("Input Actions")
## Name of Input Action to move Left.
@export var input_left : String = "move_left"
## Name of Input Action to move Right.
@export var input_right : String = "move_right"
## Name of Input Action to move Forward.
@export var input_forward : String = "move_forward"
## Name of Input Action to move Backward.
@export var input_back : String = "move_backward"
## Name of Input Action to Jump.
@export var input_jump : String = "move_jump"
## Name of Input Action to Sprint.
@export var input_sprint : String = "move_sprint"
## Name of Input Action to toggle freefly mode.
@export var input_freefly : String = "freefly"

@onready var xval: Label = $"../DebugCanvas/VBoxContainer/xbox/xval"
@onready var anime: AnimationPlayer = $AnimationPlayer

var mouse_captured : bool = false
var look_rotation : Vector2
var move_speed : float = 0.0
var freeflying : bool = false
var crouching: bool = false

## IMPORTANT REFERENCES
@onready var head: Node3D = $Head
@onready var collider: CollisionShape3D = $Collider

func _ready() -> void:
	check_input_mappings()
	look_rotation.y = rotation.y
	look_rotation.x = head.rotation.x

func _unhandled_input(event: InputEvent) -> void:
	# Mouse capturing
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		capture_mouse()
	if Input.is_key_pressed(KEY_ESCAPE):
		release_mouse()
	
	if Input.is_action_just_pressed("interact"):
		ray_cast_3d.interact()
	#crouch
	if Input.is_action_just_pressed("move_crouch"):
		crouching = true
		anime.play("crouch")
	if Input.is_action_just_released("move_crouch"):
		crouching = false
		anime.play_backwards("crouch")
	# Look around
	if mouse_captured and event is InputEventMouseMotion:
		rotate_look(event.relative)
	
	# Toggle freefly mode
	if can_freefly and Input.is_action_just_pressed(input_freefly):
		if not freeflying:
			enable_freefly()
		else:
			disable_freefly()


func _process(delta: float) -> void:
	xval.text = str(Engine.get_frames_per_second())


func check_jump():
	if can_jump:
		if Input.is_action_just_pressed(input_jump) and is_on_floor():
			velocity.y = jump_velocity

func check_sprint():
	if can_sprint and Input.is_action_pressed(input_sprint):
		move_speed = sprint_speed
	else:
		move_speed = base_speed
		
func adjust_velocity():
	if can_move:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var move_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		var momentum = momentum_ground if is_on_floor() else momentum_air
		if move_dir:
			velocity.x = move_toward(velocity.x, move_dir.x * move_speed, momentum)
			velocity.z = move_toward(velocity.z, move_dir.z * move_speed, momentum)
		else:
			if is_on_floor():
				velocity.x = move_toward(velocity.x, 0, momentum)
				velocity.z = move_toward(velocity.z, 0, momentum)
	else:
		velocity.x = 0
		velocity.y = 0

func apply_gravity(delta: float):
	if has_gravity:
		if !is_on_floor():
			var grav = gravity_up if velocity.y > 0 else gravity_down
			velocity.y -= grav * delta

func freefly_motion(delta: float):
	var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
	var motion := (head.global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	motion *= freefly_speed * delta
	move_and_collide(motion)
		
func _physics_process(delta: float) -> void:
	# If freeflying, handle freefly and nothing else
	if can_freefly and freeflying:
		freefly_motion(delta)
		return

	check_jump()
	check_sprint()
	adjust_velocity()
	apply_gravity(delta)
	move_and_slide()


## Rotate us to look around.
## Base of controller rotates around y (left/right). Head rotates around x (up/down).
## Modifies look_rotation based on rot_input, then resets basis and rotates by look_rotation.
func rotate_look(rot_input : Vector2):
	look_rotation.x -= rot_input.y * look_speed
	look_rotation.x = clamp(look_rotation.x, deg_to_rad(-85), deg_to_rad(85))
	look_rotation.y -= rot_input.x * look_speed
	transform.basis = Basis()
	rotate_y(look_rotation.y)
	head.transform.basis = Basis()
	head.rotate_x(look_rotation.x)


func enable_freefly():
	collider.disabled = true
	freeflying = true
	velocity = Vector3.ZERO

func disable_freefly():
	collider.disabled = false
	freeflying = false


func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true


func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false


## Checks if some Input Actions haven't been created.
## Disables functionality accordingly.
func check_input_mappings():
	if can_move and not InputMap.has_action(input_left):
		push_error("Movement disabled. No InputAction found for input_left: " + input_left)
		can_move = false
	if can_move and not InputMap.has_action(input_right):
		push_error("Movement disabled. No InputAction found for input_right: " + input_right)
		can_move = false
	if can_move and not InputMap.has_action(input_forward):
		push_error("Movement disabled. No InputAction found for input_forward: " + input_forward)
		can_move = false
	if can_move and not InputMap.has_action(input_back):
		push_error("Movement disabled. No InputAction found for input_back: " + input_back)
		can_move = false
	if can_jump and not InputMap.has_action(input_jump):
		push_error("Jumping disabled. No InputAction found for input_jump: " + input_jump)
		can_jump = false
	if can_sprint and not InputMap.has_action(input_sprint):
		push_error("Sprinting disabled. No InputAction found for input_sprint: " + input_sprint)
		can_sprint = false
	if can_freefly and not InputMap.has_action(input_freefly):
		push_error("Freefly disabled. No InputAction found for input_freefly: " + input_freefly)
		can_freefly = false


func _on_ready() -> void:
	pass # Replace with function body.
