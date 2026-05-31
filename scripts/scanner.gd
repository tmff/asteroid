extends Node3D
class_name Scanner

var asteroid : Asteroid
var _scan_mat : ShaderMaterial

const HIGH_STRESS_RATIO = 0.4

func _ready() -> void:
	asteroid = get_parent() as Asteroid
	assert(asteroid != null, "Scanner must be a child of Asteroid")


func scan_all():
	_scan_mat.set_shader_parameter("scan_active", true)

func clear_scan() -> void:
	if _scan_mat:
		_scan_mat.set_shader_parameter("scan_active", false)
