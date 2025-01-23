extends CharacterBody2D

class_name Enemy

var health : float
var damage : float

func _init(maxHealth : float, damage : float, startingPos : Vector2 = Vector2.ZERO):
	self.health = maxHealth
	self.damage = damage
	self.position = startingPos
	add_to_group("enemies")

func takeDamage(damage : float):
	self.health -= damage

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
