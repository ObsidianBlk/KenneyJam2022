extends StaticBody


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal heat_injected(amount)

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
export var heat_per_second : float = 1000.0


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------



# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _physics_process(delta : float) -> void:
	emit_signal("heat_injected", heat_per_second * delta)


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------

