extends Area2D

@onready var animation: AnimationPlayer = $AnimationPlayer

func _on_body_entered(body: Node2D) -> void:
	# 分数 + 1
	body.Score += 1;
	# 播放金币音乐，并销毁节点
	animation.play("pickup")
