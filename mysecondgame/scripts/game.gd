extends Node2D

@export var ScoreLabel : Label;

@onready var player: CharacterBody2D = $player
@onready var game_over_label: Label = $CanvasLayer/GameOver

func _process(delta: float) -> void:
	delta = delta
	ScoreLabel.text = "Coin:10 / " + str(player.Score)

func show_game_over():
	game_over_label.visible = true
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
