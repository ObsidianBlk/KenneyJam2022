extends KinematicBody


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal flower_seeds_changed(amount)
signal tree_seeds_changed(amount)

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const CAMERA_GROUP : String = "camera"
const MAX_FLOWER_SEEDS : int = 5
const MAX_TREE_SEEDS : int = 3

enum STATE {Idle=0, Moving=1, Air=3, Jump=4}

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
export (int, 0, 3) var vis : int = 0
export var max_speed : float = 8.0							setget set_max_speed
export var max_jump_height : float = 1.5					setget set_max_jump_height
export var half_jump_dist : float = 2.0						setget set_half_jump_dist

export var gravity_fall_mult : float = 2.0					setget set_gravity_fall_mult

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _velocity : Vector3 = Vector3.ZERO
var _gravity : float = 0.0
var _jump_strength : float = 0.0

var _state : int = STATE.Idle

var _flower_seeds : int = 0
var _tree_seeds : int = 0

var _camera : Spatial = null
var _ix : Array = [0.0, 0.0]
var _iy : Array = [0.0, 0.0]

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
onready var viz_node : Spatial = $Viz

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_vis(v : int) -> void:
	if v >= 0 and v < 4:
		vis = v
		if viz_node:
			viz_node.set_body_index(vis)


func set_max_speed(s : float) -> void:
	if s > 0.0:
		max_speed = s
		_CalculateJumpVariables()

func set_max_jump_height(h : float) -> void:
	if h > 0.0:
		max_jump_height = h
		_CalculateJumpVariables()

func set_half_jump_dist(d : float) -> void:
	if d > 0.0:
		half_jump_dist = d
		_CalculateJumpVariables()

func set_gravity_fall_mult(m : float) -> void:
	if m > 0.0:
		gravity_fall_mult = m

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	set_vis(vis)

func _unhandled_input(event) -> void:
	_HandleMoveEvents(event)
	match _state:
		STATE.Idle, STATE.Moving, STATE.Jump:
			_HandleJumpEvents(event)

func _physics_process(delta : float) -> void:
	_UpdateCameraFacing()
	
	_ProcessVelocity_v(delta)
	_ProcessVelocity_h(delta)
	#print(_velocity)
	_velocity = move_and_slide_with_snap(_velocity, Vector3.DOWN * 0.01, Vector3.UP, false, 4, deg2rad(60.0))
	_ProcessGroundState()


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _CalculateJumpVariables() -> void:
	# NOTE: The idea for this came from...
	# https://youtu.be/hG9SzQxaCm8
	_jump_strength = (2 * max_jump_height * max_speed) / half_jump_dist
	_gravity = (2 * max_jump_height * pow(max_speed, 2)) / pow(half_jump_dist, 2)


func _UpdateCameraFacing() -> void:
	if _camera:
		if viz_node != null:
			if _camera.current == true:
				_camera.view_camera(viz_node)
			else:
				_camera = null
	else:
		_FindCamera()

func _ProcessVelocity_v(delta : float) -> void:
	if _state == STATE.Jump and _velocity.y <= 0.0:
		_velocity.y += _jump_strength
	elif not is_on_floor():
		var mult = gravity_fall_mult if (_state == STATE.Air or _velocity.y <= 0.0) else 1.0
		_velocity.y -= _gravity * mult * delta

func _ProcessVelocity_h(delta : float) -> void:
	var angle : float = 0.0
	if _camera:
		angle = _camera.global_rotation.y
	var speed : Vector2 = Vector2(
		_ix[1] - _ix[0],
		_iy[1] - _iy[0]
	).rotated(-angle) * max_speed * delta
	_velocity.x = speed.x
	_velocity.z = speed.y

func _ProcessGroundState() -> void:
	if _state != STATE.Jump and is_on_floor():
		_velocity.y = 0.0
		_state = STATE.Idle if _GetCurrentSpeed() < 0.1 else STATE.Moving
	elif _velocity.y <= 0.0:
		_state = STATE.Air


func _HandleMoveEvents(event : InputEvent) -> void:
	if event.is_action("forward") or event.is_action("backward"):
		_iy[0] = event.get_action_strength("forward")
		_iy[1] = event.get_action_strength("backward")
	elif event.is_action("left") or event.is_action("right"):
		_ix[0] = event.get_action_strength("left")
		_ix[1] = event.get_action_strength("right")

func _HandleJumpEvents(event : InputEvent) -> void:
	if event.is_action_pressed("jump") and is_on_floor():
		print(is_on_floor())
		_state = STATE.Jump
	elif event.is_action_released("jump") and _state == STATE.Jump:
		_state = STATE.Air

func _FindCamera() -> void:
	if is_inside_tree():
		var cnodes = get_tree().get_nodes_in_group(CAMERA_GROUP)
		if cnodes.size() > 0:
			if cnodes[0].has_method("view_camera") and cnodes[0].current == true:
				_camera = cnodes[0]

func _GetCurrentSpeed() -> float:
	var v : Vector2 = Vector2(_velocity.x, _velocity.z)
	return v.length()

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------

func add_flower_seeds(amount : int) -> void:
	_flower_seeds = max(0, min(MAX_FLOWER_SEEDS, _flower_seeds + amount))
	emit_signal("flower_seeds_changed", _flower_seeds)

func add_tree_seeds(amount : int) -> void:
	_tree_seeds = max(0, min(MAX_TREE_SEEDS, _tree_seeds + amount))
	emit_signal("tree_seeds_changed", _tree_seeds)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------

func _on_Collector_body_entered(body : Spatial) -> void:
	var groups : Array = body.get_groups()
	for group in groups:
		group.begins_with("seeds_")
		var parts = group.split("_")
		if parts.size() == 3:
			if ["flower", "tree"].find(parts[1]) >= 0 and parts[2].is_valid_integer():
				var count : int = parts[1].to_int()
				if count > 0:
					match parts[1]:
						"flower":
							add_flower_seeds(count)
						"tree":
							add_tree_seeds(count)
					body.queue_free()
		
