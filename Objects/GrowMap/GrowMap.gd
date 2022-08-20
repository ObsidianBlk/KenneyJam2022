extends Spatial


# ------------------------------------------------------------------------------
# Constant
# ------------------------------------------------------------------------------
const GROWBLOCK : PackedScene = preload("res://Objects/GrowBlock/GrowBlock.tscn")

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
export var min_block_spawn_rate : float = 1.0			setget set_min_block_spawn_rate
export var max_block_spawn_rate : float = 3.0			setget set_max_block_spawn_rate


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _rng : RandomNumberGenerator = RandomNumberGenerator.new()
var _map : Dictionary = {}
var _spawn_delay : float = 0.0

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_min_block_spawn_rate(r : float) -> void:
	if r > 0.0 and r <= max_block_spawn_rate:
		min_block_spawn_rate = r

func set_max_block_spawn_rate(r : float) -> void:
	if r >= min_block_spawn_rate:
		max_block_spawn_rate = r

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	randomize()
	_rng.seed = randi()
	
	for child in get_children():
		if child.has_signal("spawn_block"):
			child.translation = child.translation.floor()
			if not (child.translation in _map):
				_map[child.translation] = child
				child.connect("spawn_block", self, "_on_spawn_block")
	
	for child in get_children():
		if child.has_signal("spawn_block"):
			_SetNeighbors(child)

func _physics_process(delta : float) -> void:
	if _spawn_delay > 0.0:
		_spawn_delay -= delta


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------

func _SetNeighbors(gb : Spatial) -> void:
	if gb.translation in _map:
		var npos : Vector3 = (gb.translation + Vector3.FORWARD).floor()
		if npos in _map:
			gb.set_neighbor(0, _map[npos])
			_map[npos].set_neighbor(2, gb)
		else:
			gb.set_neighbor(0, null)
		
		npos = (gb.translation + Vector3.RIGHT).floor()
		if npos in _map:
			gb.set_neighbor(1, _map[npos])
			_map[npos].set_neighbor(3, gb)
		else:
			gb.set_neighbor(1, null)
		
		npos = (gb.translation + Vector3.BACK).floor()
		if npos in _map:
			gb.set_neighbor(2, _map[npos])
			_map[npos].set_neighbor(0, gb)
		else:
			gb.set_neighbor(2, null)
		
		npos = (gb.translation + Vector3.LEFT).floor()
		if npos in _map:
			gb.set_neighbor(3, _map[npos])
			_map[npos].set_neighbor(1, gb)
		else:
			gb.set_neighbor(3, null)


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_spawn_block(block : Spatial, at_pos : Vector3) -> void:
	if _spawn_delay > 0.0:
		return
	if not block.has_method("can_spawn"):
		return
	
	at_pos = at_pos.floor()
	if not (at_pos in _map) and block.can_spawn():
		block.cool_from_spawn()
		var gb = GROWBLOCK.instance()
		gb.translation = at_pos
		#gb.verbose = true
		add_child(gb)
		_map[at_pos] = gb
		_SetNeighbors(gb)
		gb.connect("spawn_block", self, "_on_spawn_block")
		_spawn_delay = _rng.randf_range(min_block_spawn_rate, max_block_spawn_rate)


