extends Spatial


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
export var current : bool = false						setget set_current
export var zoom : float = 1.0							setget set_zoom
export var pitch_degree_min : float = -90.0				setget set_pitch_degree_min
export var pitch_degree_max : float = 90.0				setget set_pitch_degree_max

export var target_path : NodePath = ""

export var sensitivity : Vector2 = Vector2(0.2, 0.2)

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _target : WeakRef = weakref(null)

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
onready var _arm_node : Spatial = $Arm
onready var _camera_node : Camera = $Arm/Camera

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_current(c : bool) -> void:
	current = c
	if _camera_node:
		_camera_node.current = current

func set_zoom(z : float) -> void:
	if z >= 0.0:
		zoom = z
		if _camera_node:
			_camera_node.transform.origin.z = zoom

func set_pitch_degree_min(p : float) -> void:
	if p <= pitch_degree_max and p >= -90.0:
		pitch_degree_min = p

func set_pitch_degree_max(p : float) -> void:
	if p >= pitch_degree_min and p <= 90.0:
		pitch_degree_max = p

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	set_current(current)
	set_zoom(zoom)

func _physics_process(_delta : float) -> void:
	var target = _target.get_ref()
	if target == null:
		_GetTarget()
	else:
		global_translation = target.global_translation

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _GetTarget() -> void:
	if target_path != "":
		var t = get_node_or_null(target_path)
		if t != null:
			_target = weakref(t)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------

func view_camera(item : Spatial) -> void:
	var cpos = _camera_node.global_translation
	cpos.y = item.global_translation.y
	item.look_at(cpos, Vector3.UP)


func orbit(yaw : float, pitch : float) -> void:
	rotation.y = wrapf(rotation.y - (yaw * sensitivity.x), 0.0, TAU)
	rotation.x = clamp(rotation.x - (pitch * sensitivity.y), deg2rad(pitch_degree_min), deg2rad(pitch_degree_max))



