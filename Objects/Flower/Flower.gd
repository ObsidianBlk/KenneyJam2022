extends Spatial

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal heat_injected(amount)

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const TIME_TO_FULL_GROWTH : float = 5.0
const TIME_TO_DEATH : float = 10.0

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
export var start_fully_grown : bool = false
export var heat_per_second : float = 350.0


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _dying : bool = false

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
onready var model : MeshInstance = $Model

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	if not start_fully_grown:
		model.scale = Vector3(1.0, 0.05, 1.0)
		var tween : SceneTreeTween = create_tween()
		tween.set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(model, "scale", Vector3.ONE, TIME_TO_FULL_GROWTH)


func _physics_process(delta : float) -> void:
	emit_signal("heat_injected", heat_per_second * model.scale.y * delta)



# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func die() -> void:
	if _dying == true:
		return
	
	_dying = true
	var tween : SceneTreeTween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(model, "scale", Vector3(1.0, 0.05, 1.0), TIME_TO_DEATH)
	tween.connect("finished", self, "_on_death")

func is_dying() -> bool:
	return _dying

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_death() -> void:
	call_deferred("queue_free")
