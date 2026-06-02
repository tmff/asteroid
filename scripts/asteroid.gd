extends Node3D
class_name Asteroid

const SIZE := Vector3i(64, 64, 64)

const EMPTY := 0
const ROCK  := 1
const ORE   := 2

const MAX_SUPPORT    := 100.0
const SUPPORT_DECAY  := 1.5
const VOID_PENALTY   := 4.0
const STRESS_PENALTY := 0.5

const COLLAPSE_THRESHOLD := 0.75

const DIRS := [
	Vector3i( 1, 0, 0), Vector3i(-1, 0, 0),
	Vector3i( 0, 1, 0), Vector3i( 0,-1, 0),
	Vector3i( 0, 0, 1), Vector3i( 0, 0,-1),
]

var voxels  : PackedByteArray

var core_position : Vector3i


func _ready() -> void:
	var total := SIZE.x * SIZE.y * SIZE.z
	voxels.resize(total)
	generate_asteroid()
	recalculate_support_field()
	$MeshInstance3D.build_mesh(self,$Scanner)
	$CollisionShape3D.shape = $MeshInstance3D.build_collider()


func generate_asteroid():
	var center := SIZE / 2
	var radius := SIZE.x * 0.4
	core_position = center

	# pick a random offset for the ore cluster, kept well inside the asteroid
	var ore_center := Vector3i(
		center.x + randi_range(-8, 8),
		center.y + randi_range(-8, 8),
		center.z + randi_range(-8, 8)
	)
	var ore_radius := 6.0

	for z in SIZE.z:
		for y in SIZE.y:
			for x in SIZE.x:
				var dist := Vector3(x, y, z).distance_to(Vector3(center))
				var noise := randf_range(-3.0, 3.0)
				if dist < radius + noise:
					var ore_dist := Vector3(x, y, z).distance_to(Vector3(ore_center))
					voxels[index(x, y, z)] = ORE if ore_dist < ore_radius else ROCK
				else:
					voxels[index(x, y, z)] = EMPTY

func recalculate_support_field():
	pass


func will_collapse(start: Vector3, direction: Vector3, steps: int) -> bool:
	return false


func _add_stress_to(
	pos: Vector3i
) -> void:
	pass


func calculate_global_instability() -> float:
	return 1.0

func in_bounds(v: Vector3i) -> bool:
	return (
		v.x >= 0 and v.y >= 0 and v.z >= 0
		and v.x < SIZE.x
		and v.y < SIZE.y
		and v.z < SIZE.z
	)


func index(x: int, y: int, z: int) -> int:
	return x + y * SIZE.x + z * SIZE.x * SIZE.y


func indexv(v: Vector3i) -> int:
	return index(v.x, v.y, v.z)
