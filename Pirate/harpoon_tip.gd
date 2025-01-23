extends Sprite2D

#@onready var main = preload("res://Game.tscn")

@onready var particlesLeft = get_node("HarpoonWaterParticleLeft")
@onready var particlesRight = get_node("HarpoonWaterParticleRight")
@onready var particles

func _ready():
	particles = $CPUParticles2D
	particlesLeft.emitting = true
	particlesRight.emitting = true
func _physics_process(_delta: float) -> void:
	particles.angle_min = -rotation_degrees
	particles.angle_max = -rotation_degrees

#func _on_body_entered(body: Node2D) -> void:
#	body.emit_signal("body_entered")
