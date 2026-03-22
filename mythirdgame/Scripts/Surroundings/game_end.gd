extends Control



func _ready() -> void:
	# 播放标题BGM
	SoundManager.play_bgm(preload("res://Game Assets/Music/game_end.ogg"))
	$AnimationPlayer.play("game_end")
	
func _physics_process(delta: float) -> void:
	delta = delta
	if not $AnimationPlayer.is_playing():
		Game.back_to_title()
