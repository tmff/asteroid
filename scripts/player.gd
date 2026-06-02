extends CharacterBody3D
class_name Player

# ─── Settings ─────────────────────────────────────────────────────────────────
@export var WALK_SPEED    := 6.0
@export var ZERO_G_SPEED  := 8.0
@export var GRAVITY       := 20.0
@export var MOUSE_SENS    := 0.002
@export var BOMB_REACH    := 8.0
@export var zero_g : bool = true

@export var bomb_scene : PackedScene

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
			
	if event.is_action_pressed("bomb_place"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			_try_place_bomb()
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

# ─── Bomb Placement ───────────────────────────────────────────────────────────
func _try_place_bomb() -> void:
	var asteroid : Asteroid = get_tree().get_first_node_in_group("asteroid")
	if not asteroid:
		return

	var space  := get_world_3d().direct_space_state
	var origin := camera.global_position
	var target := origin + (-camera.global_transform.basis.z * BOMB_REACH)
	var query  := PhysicsRayQueryParameters3D.create(origin, target)
	query.exclude   = [self]
	query.hit_back_faces = false

	var hit := space.intersect_ray(query)
	if hit.is_empty():
		return

	# only place on the asteroid's collider
	if hit.collider != asteroid.get_node("CollisionShape3D").get_parent():
		return

	var world_normal : Vector3 = hit.normal
	# snap normal to the nearest axis in asteroid local space
	var local_normal := asteroid.global_transform.basis.inverse() * world_normal
	local_normal = _snap_to_cardinal(local_normal)

	var bomb : Bomb = bomb_scene.instantiate()
	# position flush on the hit face, slightly offset so it sits on the surface
	bomb.global_position = hit.position + world_normal * 0.05
	asteroid.add_child(bomb)

	bomb.detonated.connect(func(ore: int): print("Bomb mined %d ore" % ore))
	bomb.collapsed.connect(func(): print("Asteroid collapsed!"))
	bomb.arm(asteroid, local_normal)


func _snap_to_cardinal(v: Vector3) -> Vector3:
	# returns the axis-aligned unit vector closest to v
	var best := Vector3.RIGHT
	var best_dot := -INF
	for axis in [Vector3.RIGHT, Vector3.LEFT, Vector3.UP, Vector3.DOWN,
				 Vector3.FORWARD, Vector3.BACK]:
		var d := v.dot(axis)
		if d > best_dot:
			best_dot = d
			best = axis
	return best

# ─── Physics ──────────────────────────────────────────────────────────────────
func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	if zero_g:
		_process_zero_g(delta)
	else:
		_process_grounded(delta)
	move_and_slide()
	update_remote_transform.rpc(global_transform, camera.global_transform)

func _process_grounded(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
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
