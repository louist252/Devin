extends AnimatableBody2D

#var area2D

#func _ready():
	#var area2d = $"Area2D"


#func _on_area_2d_area_entered(area:Area2D) -> void:
	#print(area.name)


#func _on_area_2d_body_entered(body:Node2D) -> void:
	#print(body)
