extends Node3D
class_name Bomb

## How many voxel steps the detonation line drills through
@export var line_steps       : int   = 20
## Seconds before detonation
@export var fuse_duration    : float = 3.0


signal detonated(ore_mined: int)
signal collapsed

var _asteroid  : Asteroid
var _local_dir : Vector3
var _timer     : float  = 0.0
var _armed     : bool   = false


func arm(asteroid: Asteroid, face_normal: Vector3) -> void:
	_asteroid  = asteroid
	_local_dir = face_normal
	_armed     = true
	_timer     = fuse_duration


func _process(delta: float) -> void:
	if not _armed:
		return

	_timer -= delta
	if _timer <= 0.0:
		_detonate()


func _detonate() -> void:
	_armed = false

	if not is_instance_valid(_asteroid):
		push_warning("Bomb: no valid asteroid reference")
		return

	var ast_xform   : Transform3D = _asteroid.global_transform
	var local_start : Vector3     = ast_xform.affine_inverse() * global_position
	var local_dir   : Vector3     = _local_dir
	queue_free()
