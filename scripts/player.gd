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
	camera.current = is_multiplayer_authority()
	$MeshInstance3D.visible = !is_multiplayer_authority()

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return

	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENS)
		camera.rotate_x(-event.relative.y * MOUSE_SENS)
		camera.rotation.x = clampf(camera.rotation.x, -PI * 0.5, PI * 0.5)
	if event.is_action_pressed("toggle_zero_g"):
		toggle_gravity.rpc()
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_pressed("use_scanner"):
		var asteroid = get_tree().get_first_node_in_group("asteroid")
		var scanner := asteroid.get_node("Scanner") as Scanner
		scanner.scan_all()

# ─── Physics ──────────────────────────────────────────────────────────────────
func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	if zero_g:
		_process_zero_g(delta)
	else:
		_process_grounded(delta)
	move_and_slide()
	update_remote_transform.rpc(global_transform,camera.global_transform)

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

@rpc("any_peer")
func toggle_gravity():
	zero_g = !zero_g
	if zero_g:
		velocity.y = 0.0

@rpc("any_peer", "unreliable_ordered")
func update_remote_transform(player_transform: Transform3D, camera_transform: Transform3D) -> void:
	if not is_multiplayer_authority():
		global_transform = player_transform
		camera.global_transform = camera_transform
