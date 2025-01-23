extends CharacterBody2D

@export var speed = 5
@export var rotSpeed = 2
var flipped = false
var playing = false

func handleInput(delta):
	# Get rotation input
	if playing:
		var input = Input.get_axis("Shark_Rotate_CCW","Shark_Rotate_CW")
		self.rotate(input * delta * 2) 
	var degree = rad_to_deg(rotation)
	# Flip the shark based on how it's rotated
	if (degree >= 90 and degree <= 180 or degree <= -90 and degree >= -180) and not flipped:
		flipped = true
		scale.y *= -1
	elif flipped and (degree <= 90 and degree >= 0 or degree >= -90 and degree <= 0):
		flipped = false
		scale.y *= -1

	# Move the shark toward the direction it's facing
	if playing:
		velocity = transform.x * 50
		move_and_slide()

func _physics_process(delta):
	handleInput(delta)
