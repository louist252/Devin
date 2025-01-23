extends CharacterBody2D

signal player_died

const gravity : float = 5
const speed : float = 1000
const jumpPower : float = 1000
const devinCooldown : int = 30
const devinDuration : int = 5
const maxJumps : int = 2
var jumpCount : int = 0
var flipped = false
var isShooting = false
var isRetracting = false
var harpoonSpeed = 500
var swapped = false
var harpoonProjectile
var harpoonChainInstance

#Vars for health
@export var max_health = 100
var current_health
 
#Vars for brief period of invincibility after taking dmg
var invincible = false
var invincibility_timer = Timer.new()

@onready var pirateCollider = get_node("PirateCollider")
@onready var rightArm = get_node("PirateSprite/RightArmAndHarpoon")
@onready var leftArm = get_node("PirateSprite/LeftArm")
@onready var pirateBody = get_node("PirateSprite")
@onready var pirateHead = get_node("PirateSprite/PirateHead")
@onready var harpoonChain = get_node("PirateSprite/RightArmAndHarpoon/HarpoonChain")
@onready var harpoonTip = get_node("PirateSprite/RightArmAndHarpoon/HarpoonTip")
@onready var harpoonTipProjectile = preload("res://Pirate/HarpoonTip.tscn")
@onready var chainInitPos = get_node("PirateSprite/RightArmAndHarpoon/ChainInitPos")
@onready var bubbles = get_node("Bubbles")
@onready var devin = get_node("SharkBody")
@onready var devinCollider = devin.get_node("SharkCollider")
@onready var devinCooldownTimer = $DevinCooldown

func handleMovement():
	# If player jumps and didn't exhaust jumps, then decrease y velocity
	if Input.is_action_just_pressed("Jump") and jumpCount < maxJumps:
		velocity.y = -jumpPower
		jumpCount += 1

	# If the player hits the floor, then reset jumps
	elif is_on_floor():
		jumpCount = 0

	# Put gravity on player when not on ground
	if !is_on_floor():
		velocity.y += gravity
		if velocity.y == 80:
			velocity.y = 30
			
	# Rotate the arm toward the mouse position
	var armAngle = rightArm.global_position.angle_to_point(get_global_mouse_position())
	
	if (armAngle >= PI/2 or armAngle <= -PI/2) and !flipped:
		pirateBody.scale.x *= -1
		rightArm.scale.x *= -1
		rightArm.scale.y *= -1
		leftArm.scale.x *= -1
		leftArm.scale.y *= -1
		pirateHead.scale.x *= -1
		pirateHead.scale.y *= -1
		if (armAngle <= PI and armAngle >= PI / 2):
			pirateHead.rotation = (PI * -3)/4
		elif (armAngle >= -PI and armAngle <= -PI / 2):
			pirateHead.rotation = (PI * 3)/4
		flipped = true
	elif (flipped and (armAngle <= PI/2 and armAngle >= -PI/2)):
		pirateBody.scale.x *= -1
		rightArm.scale.x *= -1
		rightArm.scale.y *= -1
		leftArm.scale.x *= -1
		leftArm.scale.y *= -1
		pirateHead.scale.x *= -1
		pirateHead.scale.y *= -1
		flipped = false
	if flipped:
		leftArm.rotation = -armAngle
		rightArm.rotation = -armAngle
		if ((armAngle <= PI and armAngle >= (PI * 3)/4) or (armAngle >= -PI and armAngle <= (PI * -3)/4)):
			pirateHead.rotation = -armAngle
		#devin.flipped = flipped
		devin.rotation = devin.global_position.angle_to_point(get_global_mouse_position())
	else:
		leftArm.rotation = armAngle
		rightArm.rotation = armAngle
		pirateHead.rotation = clamp(armAngle, -PI/4, PI/4)
		#devin.flipped = flipped
		devin.rotation = devin.global_position.angle_to_point(get_global_mouse_position())

	# Player side-to-side movement
	var horizontal_dir = Input.get_axis("Left", "Right")
	velocity.x = speed * horizontal_dir
	if velocity.x != 0:
		if !pirateBody.is_playing():
			if velocity.x < 0:
				pirateBody.play_backwards()
			else:
				pirateBody.play("Headless_Walk")
	else:
		pirateBody.stop()
	move_and_slide()
	
func handleGun(delta):
	if Input.is_action_just_pressed("Shoot") and !isShooting:
		# Set Shooting to true and make the fake harpoonTip go away
		isShooting = true
		harpoonTip.visible = false
		harpoonChain.visible = true
		
		# Create the actual harpoon tip projectile
		harpoonProjectile = harpoonTipProjectile.instantiate()
		get_parent().add_child(harpoonProjectile)
		
		# Get body_entered signal from harpoonTip to detect collisions
		var harpoonProjectileArea = harpoonProjectile.get_node("Area2D")
		harpoonProjectileArea.connect("body_entered", _on_body_entered)
		
		# Position it in the origin position and moves it forward
		harpoonProjectile.global_position = chainInitPos.global_position
		harpoonProjectile.global_rotation = harpoonTip.global_rotation
		harpoonProjectile.global_position.x += 500 * cos(harpoonProjectile.global_rotation) * delta
		harpoonProjectile.global_position.y += 500 * sin(harpoonProjectile.global_rotation) * delta
		harpoonChain.set_as_top_level(true)
		
		# Sets the chains points
		# index 0 is at the tip of gun
		# index 1 is at the end of the harpoon tip projectile
		harpoonChain.set_point_position(0, harpoonChain.to_local(chainInitPos.global_position))
		harpoonChain.set_point_position(1, harpoonChain.to_local(harpoonProjectile.global_position))
	
		# Start the bubbles for the projectile
		bubbles.emitting = true
		bubbles.global_position = harpoonProjectile.global_position
	elif isShooting and !isRetracting:
		# Keeps moving the harpoon tip projectile forward
		harpoonProjectile.global_position.x += 1000 * cos(harpoonProjectile.global_rotation) * delta
		harpoonProjectile.global_position.y += 1000 * sin(harpoonProjectile.global_rotation) * delta
		
		# Sets the chains points
		# index 0 is at the tip of gun
		# index 1 is at the end of the harpoon tip projectile
		harpoonChain.set_point_position(0, harpoonChain.to_local(chainInitPos.global_position))
		harpoonChain.set_point_position(1, harpoonChain.to_local(harpoonProjectile.global_position)) 
		
		# Move the bubbles to the harpoon tip projectile
		bubbles.global_position = harpoonProjectile.global_position
		
		# If the harpoon tip is far enough away, start retracting it
		if ((chainInitPos.global_position - harpoonProjectile.global_position).length() > 600):
			isRetracting = true
	elif isRetracting:
		# Move the harpoon tip back towards the tip of the harpoon
		var movement = harpoonProjectile.global_position.move_toward(chainInitPos.global_position, delta * 1000)
		print(movement)
		harpoonProjectile.global_position = movement
		print(movement.normalized())
		harpoonProjectile.global_rotation = movement.normalized().angle()
		
		# Sets the chains points
		# index 0 is at the tip of gun
		# index 1 is at the end of the harpoon tip projectile
		harpoonChain.set_point_position(0, harpoonChain.to_local(chainInitPos.global_position))
		harpoonChain.set_point_position(1, harpoonChain.to_local(harpoonProjectile.global_position)) 
		
		# Move the bubbles to the harpoon tip projectile
		bubbles.global_position = harpoonProjectile.global_position
		
		# If the harpoon tip is roughly in the spot it needs to be, remove the harpoon tip projectile and replace it with the fake one
		if ((chainInitPos.global_position - harpoonProjectile.global_position).length() < 3):
			harpoonProjectile.queue_free()
			bubbles.emitting = false
			isRetracting = false
			isShooting = false
			harpoonTip.visible = true
			harpoonChain.visible = false

func handleSwap():
	if (Input.is_action_just_pressed("Swap")):
		print(devinCooldownTimer.time_left)
		if (!swapped and devinCooldownTimer.is_stopped()):
			devinCooldownTimer.wait_time = devinDuration
			devinCooldownTimer.start()
			swapped = true
			pirateBody.visible = false
			pirateCollider.disabled = true
			devinCollider.disabled = false
			devin.global_position = self.global_position
			devin.rotation = devin.global_position.angle_to_point(get_global_mouse_position())
			devin.visible = true
			devin.playing = true
		elif (swapped and devinCooldownTimer.is_stopped()):
			devinCooldownTimer.wait_time = devinCooldown
			devinCooldownTimer.start()
			swapped = false
			pirateBody.visible = true
			pirateCollider.disabled = false
			self.global_position = devin.global_position
			devinCollider.disabled = true
			devin.visible = false
			devin.playing = false

func _physics_process(delta):
	if !swapped:
		handleMovement()
		handleGun(delta)
		check_collisions()
	if !isShooting and !isRetracting:
		handleSwap()
	
func _on_body_entered(body):
	isRetracting = true

func _ready():
	add_child(invincibility_timer)
	invincibility_timer.one_shot = true
	invincibility_timer.connect("timeout", Callable(self, "_on_invincibility_timer_timeout"))
	current_health = max_health

func take_damage(amount):
	if not invincible:
		current_health -= amount
		current_health = max(current_health, 0)  # Prevent negative health
		print("Player health: ", current_health)  # For debugging
		if current_health <= 0:
			die()
		else:
			start_invincibility()

func die():
	print("Player died")
	set_physics_process(false)
	emit_signal("player_died")
	# do something here
	
func start_invincibility():
	invincible = true
	invincibility_timer.start(1.0)  # 1 second of invincibility

func _on_invincibility_timer_timeout():
	invincible = false
	
func check_collisions():
	if not invincible:
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider.is_in_group("enemies"):
				take_damage(10)  #10 per hit
				print("Collision with enemy")
				break  # Exit the loop after taking damage once
