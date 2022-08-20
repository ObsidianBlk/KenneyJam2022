extends KinematicBody

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const BODIES : Array = [
	preload("res://Objects/Lodytian/Bodies/Body_A.tscn")
]

const ARMS : Array = [
	"res://Objects/Lodytian/Arms/Arm_A.tscn",
	"res://Objects/Lodytian/Arms/Arm_B.tscn",
	"res://Objects/Lodytian/Arms/Arm_C.tscn",
	"res://Objects/Lodytian/Arms/Arm_D.tscn",
	"res://Objects/Lodytian/Arms/Arm_E.tscn",
]

const LEGS : Array = [
	"res://Objects/Lodytian/Legs/Leg_A.tscn",
	"res://Objects/Lodytian/Legs/Leg_B.tscn",
	"res://Objects/Lodytian/Legs/Leg_C.tscn",
	"res://Objects/Lodytian/Legs/Leg_D.tscn",
	"res://Objects/Lodytian/Legs/Leg_E.tscn",
]

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
export var camera_group : String = ""							setget set_camera_group
export var body_seed : int = 12345								setget set_body_seed
export var start_as_adult : bool = false
export var min_growth_time : float = 20.0
export var max_growth_time : float = 55.0
export var gravity : float = 9.8								setget set_gravity

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _rng : RandomNumberGenerator = null
var _camera : Spatial = null

var _sec_to_adult : float = 0.0
var _max_leg_height : float = 0.0
var _body_scale : float = 0.25

var _velocity : Vector3 = Vector3.ZERO

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
onready var _body : Spatial = $Body
onready var _parts : Spatial = $Body/Parts

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_camera_group(g : String) -> void:
	camera_group = g
	_FindCamera()

func set_body_seed(s : int) -> void:
	body_seed = s
	if _rng == null:
		_rng = RandomNumberGenerator.new()
	_rng.seed = body_seed

func set_gravity(g : float) -> void:
	if g > 0.0:
		gravity = g

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	set_body_seed(body_seed)
	_BuildBody()

func _physics_process(delta : float) -> void:
	_UpdateCameraFacing()
	_ProcessGrowth(delta)
	_velocity.y -= gravity * delta
	_velocity = move_and_slide_with_snap(_velocity, Vector3.DOWN, Vector3.UP, true)


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _FindCamera() -> void:
	if camera_group != "":
		if is_inside_tree():
			var cnodes = get_tree().get_nodes_in_group(camera_group)
			if cnodes.size() > 0:
				if cnodes[0].has_method("view_camera") and cnodes[0].current == true:
					_camera = cnodes[0]

func _UpdateCameraFacing() -> void:
	if _camera:
		if _body != null:
			if _camera.current == true:
				_camera.view_camera(_body)
			else:
				_camera = null
	else:
		_FindCamera()


func _ProcessGrowth(delta : float) -> void:
	if _body_scale < 1.0:
		var growth : float = (0.75 / _sec_to_adult) * delta
		_body_scale = min(1.0, _body_scale + growth)
		_parts.scale = Vector3.ONE * _body_scale
		_parts.translation.y = _max_leg_height * _body_scale



func _AttachFlippable(itemlist : Array, idx : int, pos : Vector3, flip : bool = false) -> Spatial:
	if flip:
		pos = Vector3(-pos.x, pos.y, pos.z)
	var ITEM : PackedScene = load(itemlist[idx])
	if ITEM:
		var item = ITEM.instance()
		if item:
			item.translation = pos
			item.scale.x = -1 if flip else 1
			_parts.add_child(item)
			return item
	return null

func _BuildBody() -> void:
	var bidx : int = _rng.randi_range(0, BODIES.size() - 1)
	var body = BODIES[bidx].instance()
	_parts.add_child(body)
	body.generate(_rng.randi())
	
	var aidx : int = _rng.randi_range(0, ARMS.size() - 1)
	var pos : Vector3 = body.get_arm_position()
	var item = _AttachFlippable(ARMS, aidx, pos)
	item = _AttachFlippable(ARMS, aidx, pos, true)
	
	var lidx : int = _rng.randi_range(0, LEGS.size() - 1)
	pos = body.get_leg_position()
	item = _AttachFlippable(LEGS, lidx, pos)
	item = _AttachFlippable(LEGS, lidx, pos, true)
	
	_max_leg_height = item.get_height_from_origin()
	_parts.translation.y = _max_leg_height * _body_scale
	
	if start_as_adult:
		_body_scale = 1.0
	else:
		_sec_to_adult = min_growth_time + _rng.randf_range(0.0, max_growth_time - min_growth_time)


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------


