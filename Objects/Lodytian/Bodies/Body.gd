extends Spatial

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
var pixel_size : float = 0.003

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _arm_position : Vector3 = Vector3.ZERO
var _leg_position : Vector3 = Vector3.ZERO
var _eye_position : Vector3 = Vector3.ZERO

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
onready var _rng : RandomNumberGenerator = RandomNumberGenerator.new()
onready var _body : Sprite3D = $Body

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_pixel_size(ps : float) -> void:
	if ps > 0.0:
		pixel_size = ps
		if _body:
			_body.pixel_size = pixel_size

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	set_pixel_size(pixel_size)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _GenerateArmPosition() -> void:
	var start : Position3D = get_node_or_null("Arm_Top")
	var end : Position3D = get_node_or_null("Arm_Bottom")
	if start != null and end != null:
		_arm_position = Vector3(
			start.translation.x,
			_rng.randf_range(end.translation.y, start.translation.y),
			start.translation.z
		)

func _GenerateLegPosition() -> void:
	var pos : Position3D = get_node_or_null("Leg")
	if pos != null:
		_leg_position = Vector3(
			_rng.randf_range(0.0, pos.translation.x),
			pos.translation.y,
			pos.translation.z
		)

func _GenerateEyePosition() -> void:
	var start : Position3D = get_node_or_null("Eye_Top")
	var end : Position3D = get_node_or_null("Eye_Bottom")
	if start != null and end != null:
		_eye_position = Vector3(
			start.translation.x,
			_rng.randf_range(end.translation.y, start.translation.y),
			start.translation.z
		)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func generate(_seed : int = INF) -> void:
	if _seed != INF:
		_rng.seed = _seed
	_GenerateArmPosition()
	_GenerateLegPosition()
	_GenerateEyePosition()


func get_arm_position() -> Vector3:
	return _arm_position

func get_leg_position() -> Vector3:
	return _leg_position

func get_eye_position() -> Vector3:
	return _eye_position
