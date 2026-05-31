extends Node3D
class_name Scanner

const HIGH_STRESS_RATIO = 0.4

@export var scan_speed := 70.0

var asteroid : Asteroid
var _scan_mat : ShaderMaterial

var scanning := false
var scan_radius := 0.0
var max_scan_radius := 0.0


func _ready() -> void:
	asteroid = get_parent() as Asteroid
	assert(
		asteroid != null,
		"Scanner must be a child of Asteroid"
	)

	max_scan_radius = Vector3(Asteroid.SIZE).length()


func _process(delta: float) -> void:
	if !scanning:
		return

	scan_radius += scan_speed * delta

	if _scan_mat:
		_scan_mat.set_shader_parameter(
			"scan_radius",
			scan_radius
		)

	if scan_radius >= max_scan_radius:
		clear_scan()


func scan_all() -> void:
	if !_scan_mat:
		return

	scanning = true
	scan_radius = 0.0

	_scan_mat.set_shader_parameter(
		"scan_origin",
		Vector3(asteroid.core_position)
	)

	_scan_mat.set_shader_parameter(
		"scan_radius",
		0.0
	)


func clear_scan() -> void:
	scanning = false
	scan_radius = 0.0

	if _scan_mat:
		_scan_mat.set_shader_parameter(
			"scan_radius",
			-9999.0
		)
