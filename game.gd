extends Node2D

@onready var game_over_screen = $CanvasLayer/GameJoever
@onready var player = $PirateBody

func _ready():
	player.connect("player_died", _on_player_died)
	game_over_screen.visible = false

func _on_player_died():
	await get_tree().create_timer(1.0).timeout  # Optional delay
	game_over_screen.visible = true
	get_tree().paused = true  # Pause the game
