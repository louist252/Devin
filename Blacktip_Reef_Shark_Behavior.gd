#extends Enemy class
extends Enemy

@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@export var target_to_chase: CharacterBody2D
@onready var sprite = get_node("AnimatedSprite2D")

var flipped : bool = false
const BLACKTIP_HEALTH : float = 100
const BLACKTIP_DAMAGE : float = 50
const SPEED : float = 150.0

# Constructs an Enemy object with the sailfish stats
func _init():
	super(BLACKTIP_HEALTH, BLACKTIP_DAMAGE)

func _physics_process(delta: float) -> void:
	chase_player()
	flip()
	
func chase_player():
	navigation_agent_2d.target_position = target_to_chase.global_position
	var nextPos = navigation_agent_2d.get_next_path_position()
	var direction = (nextPos - self.global_position).normalized()
	velocity = global_position.direction_to(nextPos) * SPEED
	move_and_slide()
	self.rotation = direction.angle()

func flip():
	# Ensure that the fish is pointing in the correct direction. 
	if ((rotation <= PI/2 and rotation >= -PI/2) and flipped): 
		sprite.flip_v = !sprite.flip_v 
		flipped = false 
	elif ((rotation > PI/2 or rotation < -PI/2) and not flipped): 
		sprite.flip_v = !sprite.flip_v 
		flipped = true
