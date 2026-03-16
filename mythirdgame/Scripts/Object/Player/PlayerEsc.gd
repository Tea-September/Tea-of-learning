extends CharacterBody2D

@onready var Player: player = $".."

# Esc退出至标题页面
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not Player.is_game_over:
		if not get_tree( ).paused:
			Player._on_button_pressed()
		else:
			Player._on_continue_pressed()
