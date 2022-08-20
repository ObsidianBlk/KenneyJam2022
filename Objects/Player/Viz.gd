extends Spatial


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const BODY : Array = [
	{ # Female A
		"head": "res://Assets/Graphics/Player/FemA/head.png",
		"head_back": "res://Assets/Graphics/Player/FemA/headBack.png",
		"body": "res://Assets/Graphics/Player/FemA/body.png",
		"body_back": "res://Assets/Graphics/Player/FemA/bodyBack.png",
		"leg": "res://Assets/Graphics/Player/FemA/leg.png",
		"arm": "res://Assets/Graphics/Player/FemA/arm.png",
		"hand": "res://Assets/Graphics/Player/FemA/hand.png",
	},
	{ # Female B
		"head": "res://Assets/Graphics/Player/FemB/head.png",
		"head_back": "res://Assets/Graphics/Player/FemB/headBack.png",
		"body": "res://Assets/Graphics/Player/FemB/body.png",
		"body_back": "res://Assets/Graphics/Player/FemB/bodyBack.png",
		"leg": "res://Assets/Graphics/Player/FemB/leg.png",
		"arm": "res://Assets/Graphics/Player/FemB/arm.png",
		"hand": "res://Assets/Graphics/Player/FemB/hand.png",
	},
	{ # Male A
		"head": "res://Assets/Graphics/Player/MaleA/head.png",
		"head_back": "res://Assets/Graphics/Player/MaleA/headBack.png",
		"body": "res://Assets/Graphics/Player/MaleA/body.png",
		"body_back": "res://Assets/Graphics/Player/MaleA/bodyBack.png",
		"leg": "res://Assets/Graphics/Player/MaleA/leg.png",
		"arm": "res://Assets/Graphics/Player/MaleA/arm.png",
		"hand": "res://Assets/Graphics/Player/MaleA/hand.png",
	},
	{ # Male B
		"head": "res://Assets/Graphics/Player/MaleB/head.png",
		"head_back": "res://Assets/Graphics/Player/MaleB/headBack.png",
		"body": "res://Assets/Graphics/Player/MaleB/body.png",
		"body_back": "res://Assets/Graphics/Player/MaleB/bodyBack.png",
		"leg": "res://Assets/Graphics/Player/MaleB/leg.png",
		"arm": "res://Assets/Graphics/Player/MaleB/arm.png",
		"hand": "res://Assets/Graphics/Player/MaleB/hand.png",
	},
]

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _facing : int = -1 # 1 = Away | -1 = Towards
var _bidx : int = 0

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
onready var head : Sprite3D = $Head
onready var body : Sprite3D = $Body
onready var leg_right : Sprite3D = $Right_Leg
onready var leg_left : Sprite3D = $Left_Leg
onready var arm_right : Sprite3D = $Right_Arm
onready var hand_right : Sprite3D = $Right_Arm/Hand
onready var arm_left : Sprite3D = $Left_Arm
onready var hand_left : Sprite3D = $Left_Arm/Hand

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func set_body_index(idx : int) -> void:
	if idx >= 0 and idx < BODY.size():
		_bidx = idx
		var cset : Dictionary = BODY[_bidx]
		head.texture = load(cset.head if _facing < 0 else cset.head_back)
		body.texture = load(cset.body if _facing < 0 else cset.body_back)
		var tex = load(cset.arm)
		arm_left.texture = tex
		arm_right.texture = tex
		
		tex = load(cset.hand)
		hand_left.texture = tex
		hand_right.texture = tex
		
		tex = load(cset.leg)
		leg_left.texture = tex
		leg_right.texture = tex

func set_facing(f : int) -> void:
	f = -1 if f < 0 else 1
	if f != _facing:
		_facing = f
		var cset : Dictionary = BODY[_bidx]
		head.texture = load(cset.head if _facing < 0 else cset.head_back)
		body.texture = load(cset.body if _facing < 0 else cset.body_back)
