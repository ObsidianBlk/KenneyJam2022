extends Spatial


var _orbit_enabled : bool = false

onready var _camera = $OrbitCamera

func _unhandled_input(event) -> void:
	if event is InputEventMouseMotion:
		if _orbit_enabled:
			_camera.orbit(event.relative.x, event.relative.y)
	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_MIDDLE:
			_orbit_enabled = event.pressed
