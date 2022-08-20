extends Spatial


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
onready var _sprite_node : Sprite3D = get_node_or_null("Sprite3D")

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func get_sprite_unit_size() -> Vector2:
	if _sprite_node != null:
		if _sprite_node.texture != null:
			var pix_size = _sprite_node.texture.get_size()
			return pix_size * _sprite_node.pixel_size
	return Vector2.ZERO

func get_height_from_origin() -> float:
	if _sprite_node != null:
		var size : Vector2 = get_sprite_unit_size()
		return (size.y * 0.5) - _sprite_node.translation.y
	return 0.0

