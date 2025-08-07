extends Area2D

func _on_body_entered(body: Node2D) -> void:
	# 分数 + 1
	body.Score += 1;
	print(body.Score)
	# 销毁金币节点
	queue_free()
