extends Spatial

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal heat_injected(amount)

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const TIME_TO_FULL_GROWTH : float = 5.0

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
export var start_fully_grown : bool = false
export var heat_per_second : float = 300.0


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
onready var model : MeshInstance = $Model

# ------------------------------------------------------------------------------
# Override Methodsmodel.scale.y
# ------------------------------------------------------------------------------
func _ready() -> void:
	if not start_fully_grown:
		model.scale = Vector3(1.0, 0.05, 1.0)
		var tween : SceneTreeTween = create_tween()
		tween.set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(model, "scale", Vector3.ONE, TIME_TO_FULL_GROWTH)
		tween.connect("finished", self, "_on_fully_grown")


func _physics_process(delta : float) -> void:
	emit_signal("heat_injected", heat_per_second * model.scale.y * delta)


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_fully_grown() -> void:
	pass

