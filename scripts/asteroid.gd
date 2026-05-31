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
var support : PackedFloat32Array
var stress  : PackedFloat32Array

var core_position : Vector3i


func _ready() -> void:
	var total := SIZE.x * SIZE.y * SIZE.z
	voxels.resize(total)
	support.resize(total)
	stress.resize(total)
	generate_asteroid()
	recalculate_support_field()
	$MeshInstance3D.build_mesh(self,$Scanner)


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


func _ore_at(x: int, y: int, z: int) -> bool:
	var h := (x * 92837111) ^ (y * 689287499) ^ (z * 283923481)
	return (h % 7) == 0


func recalculate_support_field():
	support.fill(0.0)

	var core_idx := indexv(core_position)
	if voxels[core_idx] == EMPTY:
		return

	support[core_idx] = MAX_SUPPORT

	var queue : Array[Vector3i] = []
	queue.push_back(core_position)
	var head := 0

	while head < queue.size():
		var current : Vector3i = queue[head]
		head += 1

		var current_support := support[indexv(current)]

		for dir in DIRS:
			var n : Vector3i = current + dir
			if not in_bounds(n):
				continue

			var n_idx := indexv(n)
			if voxels[n_idx] == EMPTY:
				continue

			var nearby_voids := count_adjacent_voids(n)
			var propagated : float = current_support \
				- SUPPORT_DECAY \
				- nearby_voids * VOID_PENALTY \
				- stress[n_idx] * STRESS_PENALTY

			if propagated <= 0.0:
				continue

			if propagated > support[n_idx]:
				support[n_idx] = propagated
				queue.push_back(n)


func will_collapse(start: Vector3, direction: Vector3, steps: int) -> bool:
	var dir_norm := direction.normalized()
	var pos      := start

	var voxels_scratch  := voxels.duplicate()
	var stress_scratch  := stress.duplicate()
	var support_scratch := support.duplicate()

	for i in steps:
		var voxel := Vector3i(pos.round())
		if in_bounds(voxel):
			var idx := indexv(voxel)
			if voxels_scratch[idx] != EMPTY:
				voxels_scratch[idx] = EMPTY
			_add_stress_to(voxel, 6, voxels_scratch, stress_scratch)
		pos += dir_norm

	var saved_voxels  := voxels
	var saved_stress  := stress
	var saved_support := support

	voxels  = voxels_scratch
	stress  = stress_scratch
	support = support_scratch

	recalculate_support_field()
	var would_collapse := calculate_global_instability() >= COLLAPSE_THRESHOLD

	voxels  = saved_voxels
	stress  = saved_stress
	support = saved_support

	return would_collapse


func detonate_line(start: Vector3, direction: Vector3, steps: int) -> int:
	var dir_norm  := direction.normalized()
	var pos       := start
	var ore_mined := 0

	for i in steps:
		var voxel := Vector3i(pos.round())
		if in_bounds(voxel):
			var idx := indexv(voxel)
			match voxels[idx]:
				ORE:
					ore_mined += 1
					voxels[idx] = EMPTY
				ROCK:
					voxels[idx] = EMPTY
			_add_stress_to(voxel, 6, voxels, stress)
		pos += dir_norm

	recalculate_support_field()

	if calculate_global_instability() >= COLLAPSE_THRESHOLD:
		return -1
	
	$MeshInstance3D.build_mesh(self,$Scanner)
	return ore_mined


func _add_stress_to(
	center: Vector3i,
	radius: int,
	target_voxels: PackedByteArray,
	target_stress: PackedFloat32Array
) -> void:
	for z in range(center.z - radius, center.z + radius + 1):
		for y in range(center.y - radius, center.y + radius + 1):
			for x in range(center.x - radius, center.x + radius + 1):
				var p := Vector3i(x, y, z)
				if not in_bounds(p):
					continue
				var idx := x + y * SIZE.x + z * SIZE.x * SIZE.y
				if target_voxels[idx] == EMPTY:
					continue
				var dist := Vector3(x, y, z).distance_to(Vector3(center))
				if dist > radius:
					continue
				target_stress[idx] += ((radius - dist) / radius) * 5.0


func calculate_global_instability() -> float:
	var total_stress    := 0.0
	var total_voxels    := 0

	for z in SIZE.z:
		for y in SIZE.y:
			for x in SIZE.x:
				var idx := index(x, y, z)
				if voxels[idx] == EMPTY:
					continue
				total_voxels += 1
				total_stress += stress[idx] / max(support[idx], 1.0)

	if total_voxels == 0:
		return 0.0

	return total_stress / total_voxels


func count_adjacent_voids(p: Vector3i) -> int:
	var count := 0
	for dir in DIRS:
		var n : Vector3i = p + dir
		if not in_bounds(n):
			count += 1
			continue
		if voxels[indexv(n)] == EMPTY:
			count += 1
	return count


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
