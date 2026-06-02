extends MeshInstance3D
class_name AsteroidMesh

@export var mat : Material
@export var scan_mat : Material

# ─── MC Tables ────────────────────────────────────────────────────────────────
# edge_table[256]: which edges are cut for each corner bitmask
const EDGE_TABLE := [
	0x000,0x109,0x203,0x30a,0x406,0x50f,0x605,0x70c,
	0x80c,0x905,0xa0f,0xb06,0xc0a,0xd03,0xe09,0xf00,
	0x190,0x099,0x393,0x29a,0x596,0x49f,0x795,0x69c,
	0x99c,0x895,0xb9f,0xa96,0xd9a,0xc93,0xf99,0xe90,
	0x230,0x339,0x033,0x13a,0x636,0x73f,0x435,0x53c,
	0xa3c,0xb35,0x83f,0x936,0xe3a,0xf33,0xc39,0xd30,
	0x3a0,0x2a9,0x1a3,0x0aa,0x7a6,0x6af,0x5a5,0x4ac,
	0xbac,0xaa5,0x9af,0x8a6,0xfaa,0xea3,0xda9,0xca0,
	0x460,0x569,0x663,0x76a,0x066,0x16f,0x265,0x36c,
	0xc6c,0xd65,0xe6f,0xf66,0x86a,0x963,0xa69,0xb60,
	0x5f0,0x4f9,0x7f3,0x6fa,0x1f6,0x0ff,0x3f5,0x2fc,
	0xdfc,0xcf5,0xfff,0xef6,0x9fa,0x8f3,0xbf9,0xaf0,
	0x650,0x759,0x453,0x55a,0x256,0x35f,0x055,0x15c,
	0xe5c,0xf55,0xc5f,0xd56,0xa5a,0xb53,0x859,0x950,
	0x7c0,0x6c9,0x5c3,0x4ca,0x3c6,0x2cf,0x1c5,0x0cc,
	0xfcc,0xec5,0xdcf,0xcc6,0xbca,0xac3,0x9c9,0x8c0,
	0x8c0,0x9c9,0xac3,0xbca,0xcc6,0xdcf,0xec5,0xfcc,
	0x0cc,0x1c5,0x2cf,0x3c6,0x4ca,0x5c3,0x6c9,0x7c0,
	0x950,0x859,0xb53,0xa5a,0xd56,0xc5f,0xf55,0xe5c,
	0x15c,0x055,0x35f,0x256,0x55a,0x453,0x759,0x650,
	0xaf0,0xbf9,0x8f3,0x9fa,0xef6,0xfff,0xcf5,0xdfc,
	0x2fc,0x3f5,0x0ff,0x1f6,0x6fa,0x7f3,0x4f9,0x5f0,
	0xb60,0xa69,0x963,0x86a,0xf66,0xe6f,0xd65,0xc6c,
	0x36c,0x265,0x16f,0x066,0x76a,0x663,0x569,0x460,
	0xca0,0xda9,0xea3,0xfaa,0x8a6,0x9af,0xaa5,0xbac,
	0x4ac,0x5a5,0x6af,0x7a6,0x0aa,0x1a3,0x2a9,0x3a0,
	0xd30,0xc39,0xf33,0xe3a,0x936,0x83f,0xb35,0xa3c,
	0x53c,0x435,0x73f,0x636,0x13a,0x033,0x339,0x230,
	0xe90,0xf99,0xc93,0xd9a,0xa96,0xb9f,0x895,0x99c,
	0x69c,0x795,0x49f,0x596,0x29a,0x393,0x099,0x190,
	0xf00,0xe09,0xd03,0xc0a,0xb06,0xa0f,0x905,0x80c,
	0x70c,0x605,0x50f,0x406,0x30a,0x203,0x109,0x000,
]

# tri_table[256][16]: up to 5 triangles (15 indices + terminator -1) per config
const TRI_TABLE := [
	[-1],
	[0,8,3,-1],[0,1,9,-1],[1,8,3,9,8,1,-1],[1,2,10,-1],[0,8,3,1,2,10,-1],
	[9,2,10,0,2,9,-1],[2,8,3,2,10,8,10,9,8,-1],[3,11,2,-1],
	[0,11,2,8,11,0,-1],[1,9,0,2,3,11,-1],[1,11,2,1,9,11,9,8,11,-1],
	[3,10,1,11,10,3,-1],[0,10,1,0,8,10,8,11,10,-1],
	[3,9,0,3,11,9,11,10,9,-1],[9,8,10,10,8,11,-1],
	[4,7,8,-1],[4,3,0,7,3,4,-1],[0,1,9,8,4,7,-1],
	[4,1,9,4,7,1,7,3,1,-1],[8,4,7,3,11,2,1,2,10,-1],  # corrected padding removed
	[1,2,10,4,3,0,4,7,3,-1],[9,2,10,9,0,2,8,4,7,-1],
	[2,10,9,2,9,7,2,7,3,7,9,4,-1],[8,4,7,3,11,2,-1],
	[11,4,7,11,2,4,2,0,4,-1],[9,0,1,8,4,7,2,3,11,-1],
	[4,7,11,9,4,11,9,11,2,9,2,1,-1],[3,10,1,3,11,10,7,8,4,-1],
	[1,11,10,1,4,11,1,0,4,7,11,4,-1],[4,7,8,9,0,11,9,11,10,11,0,3,-1],
	[4,7,11,4,11,9,9,11,10,-1],[9,5,4,-1],[9,5,4,0,8,3,-1],
	[0,5,4,1,5,0,-1],[8,5,4,8,3,5,3,1,5,-1],[1,2,10,9,5,4,-1],
	[3,0,8,1,2,10,4,9,5,-1],[5,2,10,5,4,2,4,0,2,-1],
	[2,10,5,3,2,5,3,5,4,3,4,8,-1],[9,5,4,2,3,11,-1],
	[0,11,2,0,8,11,4,9,5,-1],[0,5,4,0,1,5,2,3,11,-1],
	[2,1,5,2,5,8,2,8,11,4,8,5,-1],[10,3,11,10,1,3,9,5,4,-1],
	[4,9,5,0,8,1,8,10,1,8,11,10,-1],[5,4,0,5,0,11,5,11,10,11,0,3,-1],
	[5,4,8,5,8,10,10,8,11,-1],[9,7,8,5,7,9,-1],[9,3,0,9,5,3,5,7,3,-1],
	[0,7,8,0,1,7,1,5,7,-1],[1,5,3,3,5,7,-1],
	[9,7,8,9,5,7,10,1,2,-1],[10,1,2,9,5,0,5,3,0,5,7,3,-1],
	[8,0,2,8,2,5,8,5,7,10,5,2,-1],[2,10,5,2,5,3,3,5,7,-1],
	[7,9,5,7,8,9,3,11,2,-1],[9,5,7,9,7,2,9,2,0,2,7,11,-1],
	[2,3,11,0,1,8,1,7,8,1,5,7,-1],[11,2,1,11,1,7,7,1,5,-1],
	[9,5,8,8,5,7,10,1,3,10,3,11,-1],
	[5,7,0,5,0,9,7,11,0,1,0,10,11,10,0,-1],
	[11,10,0,11,0,3,10,5,0,8,0,7,5,7,0,-1],[11,10,5,7,11,5,-1],
	[10,6,5,-1],[0,8,3,5,10,6,-1],[9,0,1,5,10,6,-1],
	[1,8,3,1,9,8,5,10,6,-1],[1,6,5,2,6,1,-1],
	[1,6,5,1,2,6,3,0,8,-1],[9,6,5,9,0,6,0,2,6,-1],
	[5,9,8,5,8,2,5,2,6,3,2,8,-1],[2,3,11,10,6,5,-1],
	[11,0,8,11,2,0,10,6,5,-1],[0,1,9,2,3,11,5,10,6,-1],
	[5,10,6,1,9,2,9,11,2,9,8,11,-1],[6,3,11,6,5,3,5,1,3,-1],
	[0,8,11,0,11,5,0,5,1,5,11,6,-1],[3,11,6,0,3,6,0,6,5,0,5,9,-1],
	[6,5,9,6,9,11,11,9,8,-1],[5,10,6,4,7,8,-1],
	[4,3,0,4,7,3,6,5,10,-1],[1,9,0,5,10,6,8,4,7,-1],
	[10,6,5,1,9,7,1,7,3,7,9,4,-1],[6,1,2,6,5,1,4,7,8,-1],
	[1,2,5,5,2,6,3,0,4,3,4,7,-1],[8,4,7,9,0,5,0,6,5,0,2,6,-1],
	[7,3,9,7,9,4,3,2,9,5,9,6,2,6,9,-1],[3,11,2,7,8,4,10,6,5,-1],
	[5,10,6,4,7,2,4,2,0,2,7,11,-1],[0,1,9,4,7,8,2,3,11,5,10,6,-1],
	[9,2,1,9,11,2,9,4,11,7,11,4,5,10,6,-1],
	[8,4,7,3,11,5,3,5,1,5,11,6,-1],
	[5,1,11,5,11,6,1,0,11,7,11,4,0,4,11,-1],
	[0,5,9,0,6,5,0,3,6,11,6,3,8,4,7,-1],[6,5,9,6,9,11,4,7,9,7,11,9,-1],
	[10,4,9,6,4,10,-1],[4,10,6,4,9,10,0,8,3,-1],
	[10,0,1,10,6,0,6,4,0,-1],[8,3,1,8,1,6,8,6,4,6,1,10,-1],
	[1,4,9,1,2,4,2,6,4,-1],[3,0,8,1,2,9,2,4,9,2,6,4,-1],
	[0,2,4,4,2,6,-1],[8,3,2,8,2,4,4,2,6,-1],
	[10,4,9,10,6,4,11,2,3,-1],[0,8,2,2,8,11,4,9,10,4,10,6,-1],
	[3,11,2,0,1,6,0,6,4,6,1,10,-1],[6,4,1,6,1,10,4,8,1,2,1,11,8,11,1,-1],
	[9,6,4,9,3,6,9,1,3,11,6,3,-1],[8,11,1,8,1,0,11,6,1,9,1,4,6,4,1,-1],
	[3,11,6,3,6,0,0,6,4,-1],[6,4,8,11,6,8,-1],
	[7,10,6,7,8,10,8,9,10,-1],[0,7,3,0,10,7,0,9,10,6,7,10,-1],
	[10,6,7,1,10,7,1,7,8,1,8,0,-1],[10,6,7,10,7,1,1,7,3,-1],
	[1,2,6,1,6,8,1,8,9,8,6,7,-1],[2,6,9,2,9,1,6,7,9,0,9,3,7,3,9,-1],
	[7,8,0,7,0,6,6,0,2,-1],[7,3,2,6,7,2,-1],
	[2,3,11,10,6,8,10,8,9,8,6,7,-1],[2,0,7,2,7,11,0,9,7,6,7,10,9,10,7,-1],
	[1,8,0,1,7,8,1,10,7,6,7,10,2,3,11,-1],[11,2,1,11,1,7,10,6,1,6,7,1,-1],
	[8,9,6,8,6,7,9,1,6,11,6,3,1,3,6,-1],[0,9,1,11,6,7,-1],
	[7,8,0,7,0,6,3,11,0,11,6,0,-1],[7,11,6,-1],
	[7,6,11,-1],[3,0,8,11,7,6,-1],[0,1,9,11,7,6,-1],
	[8,1,9,8,3,1,11,7,6,-1],[10,1,2,6,11,7,-1],
	[1,2,10,3,0,8,6,11,7,-1],[2,9,0,2,10,9,6,11,7,-1],
	[6,11,7,2,10,3,10,8,3,10,9,8,-1],[7,2,3,6,2,7,-1],
	[7,0,8,7,6,0,6,2,0,-1],[2,7,6,2,3,7,0,1,9,-1],
	[1,6,2,1,8,6,1,9,8,8,7,6,-1],[10,7,6,10,1,7,1,3,7,-1],
	[10,7,6,1,7,10,1,8,7,1,0,8,-1],[0,3,7,0,7,10,0,10,9,6,10,7,-1],
	[7,6,10,7,10,8,8,10,9,-1],[6,8,4,11,8,6,-1],
	[3,6,11,3,0,6,0,4,6,-1],[8,6,11,8,4,6,9,0,1,-1],
	[9,4,6,9,6,3,9,3,1,11,3,6,-1],[6,8,4,6,11,8,2,10,1,-1],
	[1,2,10,3,0,11,0,6,11,0,4,6,-1],[4,11,8,4,6,11,0,2,9,2,10,9,-1],
	[10,9,3,10,3,2,9,4,3,11,3,6,4,6,3,-1],[8,2,3,8,4,2,4,6,2,-1],
	[0,4,2,4,6,2,-1],[1,9,0,2,3,4,2,4,6,4,3,8,-1],
	[1,9,4,1,4,2,2,4,6,-1],[8,1,3,8,6,1,8,4,6,6,10,1,-1],
	[10,1,0,10,0,6,6,0,4,-1],[4,6,3,4,3,8,6,10,3,0,3,9,10,9,3,-1],
	[10,9,4,6,10,4,-1],[4,9,5,7,6,11,-1],[0,8,3,4,9,5,11,7,6,-1],
	[5,0,1,5,4,0,7,6,11,-1],[11,7,6,8,3,4,3,5,4,3,1,5,-1],
	[9,5,4,10,1,2,7,6,11,-1],[6,11,7,1,2,10,0,8,3,4,9,5,-1],
	[7,6,11,5,4,10,4,2,10,4,0,2,-1],
	[3,4,8,3,5,4,3,2,5,10,5,2,11,7,6,-1],[7,2,3,7,6,2,5,4,9,-1],
	[9,5,4,0,8,6,0,6,2,6,8,7,-1],[3,6,2,3,7,6,1,5,0,5,4,0,-1],
	[6,2,8,6,8,7,2,1,8,4,8,5,1,5,8,-1],
	[9,5,4,10,1,6,1,7,6,1,3,7,-1],
	[1,6,10,1,7,6,1,0,7,8,7,0,9,5,4,-1],
	[4,0,10,4,10,5,0,3,10,6,10,7,3,7,10,-1],[7,6,10,7,10,8,5,4,10,4,8,10,-1],
	[6,9,5,6,11,9,11,8,9,-1],[3,6,11,0,6,3,0,5,6,0,9,5,-1],
	[0,11,8,0,5,11,0,1,5,5,6,11,-1],[6,11,3,6,3,5,5,3,1,-1],
	[1,2,10,9,5,11,9,11,8,11,5,6,-1],
	[0,11,3,0,6,11,0,9,6,5,6,9,1,2,10,-1],
	[11,8,5,11,5,6,8,0,5,10,5,2,0,2,5,-1],[6,11,3,6,3,5,2,10,3,10,5,3,-1],
	[5,8,9,5,2,8,5,6,2,3,8,2,-1],[9,5,6,9,6,0,0,6,2,-1],
	[1,5,8,1,8,0,5,6,8,3,8,2,6,2,8,-1],[1,5,6,2,1,6,-1],
	[1,3,6,1,6,10,3,8,6,5,6,9,8,9,6,-1],[10,1,0,10,0,6,9,5,0,5,6,0,-1],
	[0,3,8,5,6,10,-1],[10,5,6,-1],
	[11,5,10,7,5,11,-1],[11,5,10,11,7,5,8,3,0,-1],
	[5,11,7,5,10,11,1,9,0,-1],[10,7,5,10,11,7,9,8,1,8,3,1,-1],
	[11,1,2,11,7,1,7,5,1,-1],[0,8,3,1,2,7,1,7,5,7,2,11,-1],
	[9,7,5,9,2,7,9,0,2,2,11,7,-1],[7,5,2,7,2,11,5,9,2,3,2,8,9,8,2,-1],
	[2,5,10,2,3,5,3,7,5,-1],[8,2,0,8,5,2,8,7,5,10,2,5,-1],
	[9,0,1,5,10,3,5,3,7,3,10,2,-1],[9,8,2,9,2,1,8,7,2,10,2,5,7,5,2,-1],
	[1,3,5,3,7,5,-1],[0,8,7,0,7,1,1,7,5,-1],[9,0,3,9,3,5,5,3,7,-1],
	[9,8,7,5,9,7,-1],[5,8,4,5,10,8,10,11,8,-1],
	[5,0,4,5,11,0,5,10,11,11,3,0,-1],[0,1,9,8,4,10,8,10,11,10,4,5,-1],
	[10,11,4,10,4,5,11,3,4,9,4,1,3,1,4,-1],[2,5,1,2,8,5,2,11,8,4,5,8,-1],
	[0,4,11,0,11,3,4,5,11,2,11,1,5,1,11,-1],
	[0,2,5,0,5,9,2,11,5,4,5,8,11,8,5,-1],[9,4,5,2,11,3,-1],
	[2,5,10,3,5,2,3,4,5,3,8,4,-1],[5,10,2,5,2,4,4,2,0,-1],
	[3,10,2,3,5,10,3,8,5,4,5,8,0,1,9,-1],[5,10,2,5,2,4,1,9,2,9,4,2,-1],
	[8,4,5,8,5,3,3,5,1,-1],[0,4,5,1,0,5,-1],[8,4,5,8,5,3,9,0,5,0,3,5,-1],
	[9,4,5,-1],[4,11,7,4,9,11,9,10,11,-1],[0,8,3,4,9,7,9,11,7,9,10,11,-1],
	[1,10,11,1,11,4,1,4,0,7,4,11,-1],[3,1,4,3,4,8,1,10,4,7,4,11,10,11,4,-1],
	[4,11,7,9,11,4,9,2,11,9,1,2,-1],
	[9,7,4,9,11,7,9,1,11,2,11,1,0,8,3,-1],[11,7,4,11,4,2,2,4,0,-1],
	[11,7,4,11,4,2,8,3,4,3,2,4,-1],[2,9,10,2,7,9,2,3,7,7,4,9,-1],
	[9,10,7,9,7,4,10,2,7,8,7,0,2,0,7,-1],[3,7,10,3,10,2,7,4,10,1,10,0,4,0,10,-1],
	[1,10,2,8,7,4,-1],[4,9,1,4,1,7,7,1,3,-1],[4,9,1,4,1,7,0,8,1,8,7,1,-1],
	[4,0,3,7,4,3,-1],[4,8,7,-1],[9,10,8,10,11,8,-1],[3,0,9,3,9,11,11,9,10,-1],
	[0,1,10,0,10,8,8,10,11,-1],[3,1,10,11,3,10,-1],
	[1,2,11,1,11,9,9,11,8,-1],[3,0,9,3,9,11,1,2,9,2,11,9,-1],
	[0,2,11,8,0,11,-1],[3,2,11,-1],[2,3,8,2,8,10,10,8,9,-1],
	[9,10,2,0,9,2,-1],[2,3,8,2,8,10,0,1,8,1,10,8,-1],[1,10,2,-1],
	[1,3,8,9,1,8,-1],[0,9,1,-1],[0,3,8,-1],[-1],
]

# ─── Corner offsets for each cube ─────────────────────────────────────────────
const CORNERS := [
	Vector3i(0,0,0), Vector3i(1,0,0), Vector3i(1,1,0), Vector3i(0,1,0),
	Vector3i(0,0,1), Vector3i(1,0,1), Vector3i(1,1,1), Vector3i(0,1,1),
]

# Edge pairs: which two corners define each of the 12 edges
const EDGE_CORNERS := [
	[0,1],[1,2],[2,3],[3,0],  # bottom face
	[4,5],[5,6],[6,7],[7,4],  # top face
	[0,4],[1,5],[2,6],[3,7],  # verticals
]

var asteroid : Asteroid

# ─── Noise ────────────────────────────────────────────────────────────────────
var _noise : FastNoiseLite
var _density : PackedFloat32Array

const ISO_LEVEL   := 0.0
const NOISE_SCALE := 0.08
const SPHERE_BLEND := 4.0  # how sharply the sphere mask cuts off
const ORE_ISO_LEVEL := -0.4  # sits between ore (-0.5) and rock (positive)

# ─── Entry point ──────────────────────────────────────────────────────────────
func build_mesh(ast: Asteroid, scanner: Scanner = null) -> void:
	asteroid = ast
	_build_density()
	var m := ArrayMesh.new()
	_march_rock(m)
	_march_ore(m, scanner)
	mesh = m
	mesh.surface_set_material(0, mat)
	mesh.surface_set_material(1, scan_mat)
	scanner._scan_mat = scan_mat


# ─── Density field ────────────────────────────────────────────────────────────
func _build_density() -> void:
	_noise = FastNoiseLite.new()
	_noise.noise_type    = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	_noise.frequency     = NOISE_SCALE
	_noise.seed          = randi()
	_noise.fractal_type  = FastNoiseLite.FRACTAL_FBM
	_noise.fractal_octaves = 4

	var size   := Asteroid.SIZE
	var center := Vector3(size) * 0.5
	var radius := size.x * 0.4
	_density   = PackedFloat32Array()
	_density.resize(size.x * size.y * size.z)

	for z in size.z:
		for y in size.y:
			for x in size.x:
				var idx    := asteroid.index(x, y, z)
				var p      := Vector3(x, y, z)
				var sphere := radius - p.distance_to(center)
				var n      := _noise.get_noise_3d(x, y, z)
				var d      := sphere / SPHERE_BLEND + n

				if asteroid.voxels[idx] == Asteroid.ORE:
					d = -0.5
				_density[idx] = d


# ─── Marching cubes ───────────────────────────────────────────────────────────
func _march_rock(m: ArrayMesh) -> void:
	var verts   : PackedVector3Array
	var normals : PackedVector3Array
	var uvs     : PackedVector2Array
	var indices : PackedInt32Array
	var vert_offset := 0
	var size := Asteroid.SIZE

	for z in size.z - 1:
		for y in size.y - 1:
			for x in size.x - 1:
				var d : Array = []
				d.resize(8)
				for i in 8:
					var c = Vector3i(x, y, z) + CORNERS[i]
					d[i] = _density[asteroid.index(c.x, c.y, c.z)]

				var cube_idx := 0
				for i in 8:
					if d[i] > ISO_LEVEL:
						cube_idx |= (1 << i)

				if cube_idx == 0 or cube_idx == 255:
					continue

				var edges = EDGE_TABLE[cube_idx]
				if edges == 0:
					continue

				var edge_verts : Array = []
				edge_verts.resize(12)
				edge_verts.fill(Vector3.ZERO)
				for e in 12:
					if edges & (1 << e):
						var ca = EDGE_CORNERS[e][0]
						var cb = EDGE_CORNERS[e][1]
						var pa := Vector3(Vector3i(x, y, z) + CORNERS[ca])
						var pb := Vector3(Vector3i(x, y, z) + CORNERS[cb])
						var da = d[ca]
						var db = d[cb]
						var t  = (ISO_LEVEL - da) / (db - da)
						edge_verts[e] = pa.lerp(pb, t)

				var tris = TRI_TABLE[cube_idx]
				var i    := 0
				while i < tris.size() and tris[i] != -1:
					var v0 : Vector3 = edge_verts[tris[i]]
					var v1 : Vector3 = edge_verts[tris[i + 1]]
					var v2 : Vector3 = edge_verts[tris[i + 2]] 

					verts.append(v0); normals.append(_gradient_normal(v0)); uvs.append(Vector2(0,0))
					verts.append(v1); normals.append(_gradient_normal(v1)); uvs.append(Vector2(1,0))
					verts.append(v2); normals.append(_gradient_normal(v2)); uvs.append(Vector2(0,1))

					indices.append(vert_offset)
					indices.append(vert_offset + 1)
					indices.append(vert_offset + 2)
					vert_offset += 3
					i += 3

	if verts.is_empty():
		return

	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX]  = indices
	m.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
func _march_ore(m: ArrayMesh, scanner: Scanner) -> void:
	var verts   : PackedVector3Array
	var normals : PackedVector3Array
	var colors  : PackedColorArray
	var indices : PackedInt32Array
	var vert_offset := 0
	var size := Asteroid.SIZE
	var cube_count := 0

	for z in size.z - 1:
		for y in size.y - 1:
			for x in size.x - 1:
				var is_ore     := false
				var is_damaged := false

				for i in 8:
					var c = Vector3i(x, y, z) + CORNERS[i]
					if not asteroid.in_bounds(c):
						continue
					var cidx := asteroid.indexv(c)
					if asteroid.voxels[cidx] == Asteroid.ORE:
						is_ore = true
				if not is_ore and not is_damaged:
					continue

				cube_count += 1

				var d : Array = []
				d.resize(8)
				for i in 8:
					var c = Vector3i(x, y, z) + CORNERS[i]
					d[i] = _density[asteroid.index(c.x, c.y, c.z)]

				var cube_idx := 0
				for i in 8:
					if d[i] > ORE_ISO_LEVEL:
						cube_idx |= (1 << i)

				if cube_idx == 0 or cube_idx == 255:
					continue

				var edges = EDGE_TABLE[cube_idx]
				if edges == 0:
					continue

				var edge_verts : Array = []
				edge_verts.resize(12)
				edge_verts.fill(Vector3.ZERO)
				for e in 12:
					if edges & (1 << e):
						var ca = EDGE_CORNERS[e][0]
						var cb = EDGE_CORNERS[e][1]
						var pa := Vector3(Vector3i(x, y, z) + CORNERS[ca])
						var pb := Vector3(Vector3i(x, y, z) + CORNERS[cb])
						var da = d[ca]
						var db = d[cb]
						var t  = (ORE_ISO_LEVEL - da) / (db - da)
						edge_verts[e] = pa.lerp(pb, t)

				var col := Color(
					1.0 if is_ore else 0.0,
					1.0 if is_damaged else 0.0,
					0.0
				)

				var tris = TRI_TABLE[cube_idx]
				var i    := 0
				while i < tris.size() and tris[i] != -1:
					verts.append(edge_verts[tris[i]])
					normals.append(_gradient_normal(edge_verts[tris[i]]))
					colors.append(col)
					verts.append(edge_verts[tris[i + 1]])
					normals.append(_gradient_normal(edge_verts[tris[i + 1]]))
					colors.append(col)
					verts.append(edge_verts[tris[i + 2]])
					normals.append(_gradient_normal(edge_verts[tris[i + 2]]))
					colors.append(col)
					indices.append(vert_offset)
					indices.append(vert_offset + 1)
					indices.append(vert_offset + 2)
					vert_offset += 3
					i += 3

	print("ore cubes emitted: ", cube_count)
	print("ore verts: ", verts.size())

	if verts.is_empty():
		return

	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_COLOR]  = colors
	arrays[Mesh.ARRAY_INDEX]  = indices
	m.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)



# ─── Density gradient → smooth normal ─────────────────────────────────────────
func _gradient_normal(p: Vector3) -> Vector3:
	var eps := 0.5
	var dx  := _sample_density(p + Vector3(eps,0,0)) - _sample_density(p - Vector3(eps,0,0))
	var dy  := _sample_density(p + Vector3(0,eps,0)) - _sample_density(p - Vector3(0,eps,0))
	var dz  := _sample_density(p + Vector3(0,0,eps)) - _sample_density(p - Vector3(0,0,eps))
	return -Vector3(dx, dy, dz).normalized()  # negate: gradient points inward


# ─── Trilinear density sample (handles non-integer positions) ─────────────────
func _sample_density(p: Vector3) -> float:
	var x0 := clampi(int(p.x),     0, Asteroid.SIZE.x - 1)
	var x1 := clampi(int(p.x) + 1, 0, Asteroid.SIZE.x - 1)
	var y0 := clampi(int(p.y),     0, Asteroid.SIZE.y - 1)
	var y1 := clampi(int(p.y) + 1, 0, Asteroid.SIZE.y - 1)
	var z0 := clampi(int(p.z),     0, Asteroid.SIZE.z - 1)
	var z1 := clampi(int(p.z) + 1, 0, Asteroid.SIZE.z - 1)
	var tx  := fposmod(p.x, 1.0)
	var ty  := fposmod(p.y, 1.0)
	var tz  := fposmod(p.z, 1.0)
	var d000 := _density[asteroid.index(x0,y0,z0)]
	var d100 := _density[asteroid.index(x1,y0,z0)]
	var d010 := _density[asteroid.index(x0,y1,z0)]
	var d110 := _density[asteroid.index(x1,y1,z0)]
	var d001 := _density[asteroid.index(x0,y0,z1)]
	var d101 := _density[asteroid.index(x1,y0,z1)]
	var d011 := _density[asteroid.index(x0,y1,z1)]
	var d111 := _density[asteroid.index(x1,y1,z1)]
	var d00  = lerp(d000, d100, tx)
	var d10  = lerp(d010, d110, tx)
	var d01  = lerp(d001, d101, tx)
	var d11  = lerp(d011, d111, tx)
	var d0   = lerp(d00,  d10,  ty)
	var d1   = lerp(d01,  d11,  ty)
	return lerp(d0, d1, tz)


# ─── Determine which surface a cube belongs to ────────────────────────────────
# Uses the asteroid's voxel array at the cube's centre voxel.
# Falls back to any solid corner if the centre is EMPTY (can happen at the surface).
func _cube_belongs_to(x: int, y: int, z: int, surface_type: int) -> bool:
	# try centre first
	var cx := x  # cube spans x..x+1; use x as the "inside" voxel
	var cy := y
	var cz := z
	var v  := asteroid.voxels[asteroid.index(cx, cy, cz)]
	if v == surface_type:
		return true
	if v != Asteroid.EMPTY:
		return false  # it's the other type, skip for this surface
	# centre is empty — check all 8 corners for a solid match
	for i in 8:
		var c = Vector3i(x, y, z) + CORNERS[i]
		if not asteroid.in_bounds(c):
			continue
		v = asteroid.voxels[asteroid.index(c.x, c.y, c.z)]
		if v == surface_type:
			return true
	return false

func build_collider() -> Shape3D:
	if !mesh:
		printerr("Mesh must be generated before getting collider")
		return null
	return mesh.create_trimesh_shape()

	
func _save_mesh() -> void:
	var err := ResourceSaver.save(mesh, "res://asteroid_mesh.res")
	if err != OK:
		push_error("AsteroidMesh: failed to save mesh resource, error code %d" % err)
	
