extends CharacterBody3D
class_name Player

# ─── Settings ─────────────────────────────────────────────────────────────────
@export var WALK_SPEED    := 6.0
@export var ZERO_G_SPEED  := 8.0
@export var GRAVITY       := 20.0
@export var MOUSE_SENS    := 0.002

@export var zero_g : bool = true

@onready var camera : Camera3D = $Camera3D

# ─── Input ────────────────────────────────────────────────────────────────────
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENS)
		camera.rotate_x(-event.relative.y * MOUSE_SENS)
		camera.rotation.x = clampf(camera.rotation.x, -PI * 0.5, PI * 0.5)

	if event.is_action_pressed("toggle_zero_g"):
		zero_g = !zero_g
		if zero_g:
			velocity.y = 0.0

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

# ─── Physics ──────────────────────────────────────────────────────────────────
func _physics_process(delta: float) -> void:
	if zero_g:
		_process_zero_g(delta)
	else:
		_process_grounded(delta)
	move_and_slide()

func _process_grounded(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	# Horizontal input in world space (player stays +Y up)
	var dir := Vector3.ZERO
	var basis := global_transform.basis
	if Input.is_action_pressed("move_forward"):  dir -= basis.z
	if Input.is_action_pressed("move_back"):     dir += basis.z
	if Input.is_action_pressed("move_left"):     dir -= basis.x
	if Input.is_action_pressed("move_right"):    dir += basis.x
	dir.y = 0.0
	dir = dir.normalized()

	velocity.x = dir.x * WALK_SPEED
	velocity.z = dir.z * WALK_SPEED

func _process_zero_g(_delta: float) -> void:
	# 6DOF: all six axes relative to camera orientation
	var dir := Vector3.ZERO
	var basis := camera.global_transform.basis
	if Input.is_action_pressed("move_forward"):  dir -= basis.z
	if Input.is_action_pressed("move_back"):     dir += basis.z
	if Input.is_action_pressed("move_left"):     dir -= basis.x
	if Input.is_action_pressed("move_right"):    dir += basis.x
	if Input.is_action_pressed("move_up"):       dir += basis.y
	if Input.is_action_pressed("move_down"):     dir -= basis.y

	if dir.length_squared() > 0.0:
		velocity = dir.normalized() * ZERO_G_SPEED
	else:
		velocity = Vector3.ZERO
