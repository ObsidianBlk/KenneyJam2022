extends Spatial


# ------------------------------------------------------------------------------
# Signal
# ------------------------------------------------------------------------------
signal flower_planted()
signal tree_planted()

# ------------------------------------------------------------------------------
# Constant
# ------------------------------------------------------------------------------
const GROWBLOCK : PackedScene = preload("res://Objects/GrowBlock/GrowBlock.tscn")
const TREE : PackedScene = preload("res://Objects/Tree/Tree.tscn")
const FLOWER : PackedScene = preload("res://Objects/Flower/Flower.tscn")

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
export var min_block_spawn_rate : float = 1.0			setget set_min_block_spawn_rate
export var max_block_spawn_rate : float = 3.0			setget set_max_block_spawn_rate
export var disable_spawning : bool = false


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
				child.connect("release", self, "_on_block_release")
	
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
# Public Methods
# ------------------------------------------------------------------------------
func heatup(pos : Vector3, amount : float) -> void:
	pos = pos.floor()
	if pos in _map:
		_map[pos].change_heat(amount)


func can_grow_flower(pos : Vector3) -> bool:
	pos = pos.floor()
	if pos in _map:
		var type : int = _map[pos].get_block()
		if type == 0 or type == 1:
			if _map[pos].count_flowers() < 3:
				return true
	return false

func spawn_flower(pos : Vector3) -> bool:
	pos = pos.floor()
	if pos in _map:
		var type : int = _map[pos].get_block()
		if type == 0 or type == 1:
			if _map[pos].count_flowers() < 3:
				var offset = Vector3(
					0.05 + (float(_rng.randi_range(0, 9)) * 0.1),
					1.0,
					0.05 + (float(_rng.randi_range(0, 9)) * 0.1)
				)
				var flower = FLOWER.instance()
				flower.translation = offset
				_map[pos].add_child(flower)
				emit_signal("flower_planted")
				return true
	return false

func can_grow_tree(pos : Vector3) -> bool:
	pos = pos.floor()
	if pos in _map:
		if _map[pos].count_trees() < 1:
			return true
	return false


func spawn_tree(pos : Vector3) -> bool:
	print("spos: ", pos)
	pos = pos.floor()
	print("pos: ", pos, " | Keys: ", _map.keys())
	if pos in _map:
		var type : int = _map[pos].get_block()
		if type == 0 or type == 1:
			if _map[pos].count_trees() < 1:
				var offset = Vector3(
					0.05 + (float(_rng.randi_range(0, 9)) * 0.1),
					1.0,
					0.05 + (float(_rng.randi_range(0, 9)) * 0.1)
				)
				var tree = TREE.instance()
				tree.translation = offset
				_map[pos].add_child(tree)
				emit_signal("tree_planted")
				return true
	return false


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_spawn_block(block : Spatial, at_pos : Vector3) -> void:
	if _spawn_delay > 0.0 or disable_spawning:
		return
	if not block.has_method("can_spawn"):
		return
	
	at_pos = at_pos.floor()
	if not (at_pos in _map) and block.can_spawn():
		block.cool_from_spawn()
		var gb = GROWBLOCK.instance()
		gb.block_seed = _rng.randi()
		gb.translation = at_pos
		#gb.verbose = true
		add_child(gb)
		_map[at_pos] = gb
		_SetNeighbors(gb)
		gb.connect("spawn_block", self, "_on_spawn_block")
		gb.connect("release", self, "_on_block_release")
		_spawn_delay = _rng.randf_range(min_block_spawn_rate, max_block_spawn_rate)

func _on_block_release(pos : Vector3) -> void:
	pos = pos.floor()
	if pos in _map:
		_map[pos].queue_free()
		_map.erase(pos)
