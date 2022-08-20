extends StaticBody
tool


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal spawn_block(at_pos)

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
enum BLOCK_STATE {Dirt=0, Grass=1, Snow=2}

const HEAT_MAX : float = 1000.0
const RANGE_SNOW : Dictionary = {"min":-1.0, "max":250.0}
const RANGE_DIRT : Dictionary = {"min":250.0, "max":600.0}
const RANGE_GRASS : Dictionary = {"min":600.0, "max":1001.0}
const SPAWN_HEAT_COST : float = 200.0

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
export var block_seed : int = 412987
export (BLOCK_STATE) var initial_block_state : int = BLOCK_STATE.Dirt	setget set_initial_block_state
export var static_state : bool = false
export var verbose : bool = false


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _rng : RandomNumberGenerator = RandomNumberGenerator.new()
var _block_state : int = -1
var _blocks : Array = [
	null, null, null
]
var _neighbors : Array = [weakref(null), weakref(null), weakref(null), weakref(null)]

var _heat : float = HEAT_MAX


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Settings
# ------------------------------------------------------------------------------
func set_block_seed(s : int) -> void:
	_rng.seed = s

func set_initial_block_state(bs : int) -> void:
	if BLOCK_STATE.values().find(bs) >= 0:
		initial_block_state = bs
		match initial_block_state:
			BLOCK_STATE.Grass:
				_heat = HEAT_MAX * 0.85
			BLOCK_STATE.Dirt:
				_heat = HEAT_MAX * 0.5
			BLOCK_STATE.Snow:
				_heat = HEAT_MAX * 0.2
		if Engine.editor_hint:
			_SetVizState(initial_block_state, true)

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_blocks[BLOCK_STATE.Dirt] = get_node_or_null("Dirt_Block")
	_blocks[BLOCK_STATE.Grass] = get_node_or_null("Grass_Block")
	_blocks[BLOCK_STATE.Snow] = get_node_or_null("Snow_Block")
	set_initial_block_state(initial_block_state)
	_SetVizState(initial_block_state)
	_FindHeatSources()

func _physics_process(delta : float) -> void:
	translation = translation.floor()
	match _block_state:
		BLOCK_STATE.Dirt:
			pass
		BLOCK_STATE.Grass:
			#if not Engine.editor_hint and verbose:
			#	print("HEAT: ", _heat)
			if _heat > 800.0:
				var enl : Array = _GetEmptyNeighborList()
				if enl.size() > 0:
					match enl[_rng.randi_range(0, enl.size() - 1)]:
						0: # North
							emit_signal("spawn_block", self, (translation + Vector3.FORWARD).floor())
						1: # East
							emit_signal("spawn_block", self, (translation + Vector3.RIGHT).floor())
						2: # South
							emit_signal("spawn_block", self, (translation + Vector3.BACK).floor())
						3: # West
							emit_signal("spawn_block", self, (translation + Vector3.LEFT).floor())
			
			var ncount : int = _GetNeighborCount()
			var dh : float = (_heat * 0.1) * delta
			if ncount > 0 and _heat - dh >= RANGE_GRASS.min:
				for i in range(4):
					var n : Spatial = _neighbors[i].get_ref()
					if n != null:
#						if not Engine.editor_hint and verbose:
#							print("Neighbor ", i, " Heat: ", n.get_heat())
						if n.get_heat() < _heat:
							n.change_heat(dh / ncount)
							_heat -= dh / ncount
		BLOCK_STATE.Snow:
			change_heat(-((HEAT_MAX - _heat) * 0.1) * delta)
			var dh : float = ((HEAT_MAX - _heat) * 0.1) * delta
			for i in range(4):
				if _neighbors[i].get_ref() != null:
					_neighbors[i].get_ref().change_heat(-dh)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _HideAllBlocks() -> void:
	if _blocks[BLOCK_STATE.Dirt]:
		_blocks[BLOCK_STATE.Dirt].visible = false
	if _blocks[BLOCK_STATE.Grass]:
		_blocks[BLOCK_STATE.Grass].visible = false
	if _blocks[BLOCK_STATE.Snow]:
		_blocks[BLOCK_STATE.Snow].visible = false


func _SetVizState(new_state : int, instant : bool = false) -> void:
	if _block_state == new_state or BLOCK_STATE.values().find(new_state) < 0:
		return
	
	if _block_state < 0 and _blocks[new_state] != null:
		_HideAllBlocks()
		_block_state = new_state
		_blocks[_block_state].visible = true
		return
	
	if static_state:
		return
	
	var old_block : MeshInstance = _blocks[_block_state]
	_block_state = new_state
	var new_block : MeshInstance = _blocks[_block_state]
	
	if instant:
		if old_block:
			old_block.visible = false
		if new_block:
			new_block.visible = true
	else:
		new_block.scale = Vector3.ONE * 0.05
		new_block.visible = true
		
		var tween : SceneTreeTween = create_tween()
		tween.set_trans(Tween.TRANS_LINEAR).set_parallel(true)
		tween.tween_property(old_block, "scale", Vector3.ONE * 0.05, 0.25)
		tween.tween_property(new_block, "scale", Vector3.ONE, 0.25)
		tween.connect("finished", self, "_on_block_change_complete", [old_block])

func _FindHeatSources() -> void:
	for child in get_children():
		if child.has_signal("heat_injected"):
			if not child.is_connected("heat_injected", self, "_on_heat_injected"):
				child.connect("heat_injected", self, "_on_heat_injected")

func _GetEmptyNeighborList() -> Array:
	var nl : Array = []
	for i in range(4):
		if _neighbors[i].get_ref() == null:
			nl.append(i)
	return nl

func _GetNeighborCount() -> int:
	var count : int = 0
	for i in range(4):
		if _neighbors[i].get_ref() != null:
			count += 1
		else:
			_neighbors[i] = weakref(null)
	return count

func _HeatInRange(r : Dictionary) -> bool:
	return _heat >= r.min and _heat < r.max

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func can_spawn() -> bool:
	return _heat - SPAWN_HEAT_COST > RANGE_GRASS.min

func cool_from_spawn() -> void:
	change_heat(-SPAWN_HEAT_COST)

func set_neighbor(dir : int, neighbor : Spatial) -> void:
	if dir >= 0 and dir < _neighbors.size():
		if neighbor == null or neighbor.has_method("change_heat"):
			_neighbors[dir] = weakref(neighbor)
	if verbose:
		var res : String = "["
		for n in _neighbors:
			if n.get_ref() != null:
				res = "%sValid "%[res]
			else:
				res = "%sNULL "%[res]
		res = "%s]"%[res]
		print(res)

func get_heat() -> float:
	return _heat

func change_heat(amount : float) -> void:
	var nheat : float = max(0.0, min(HEAT_MAX, _heat + amount))
	if nheat != _heat:
		_heat = nheat
#		if verbose:
#			print("Heat: ", _heat)
		if _HeatInRange(RANGE_SNOW):
			_SetVizState(BLOCK_STATE.Snow)
		elif _HeatInRange(RANGE_DIRT):
			_SetVizState(BLOCK_STATE.Dirt)
		elif _HeatInRange(RANGE_GRASS):
			_SetVizState(BLOCK_STATE.Grass)


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_block_change_complete(block : MeshInstance) -> void:
	block.visible = false
	block.scale = Vector3.ONE

func _on_heat_injected(amount : float) -> void:
	change_heat(amount)
