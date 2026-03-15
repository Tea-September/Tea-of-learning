extends Interactable

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func interact() -> void:
	super()
	
	animation_player.play("SaveActived")
	Game.save_game()
