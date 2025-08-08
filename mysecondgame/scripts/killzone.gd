extends Area2D

func _on_body_entered(body: Node2D) -> void:
	body = body
	get_tree().current_scene.show_game_over()
	$GameOverMusic.play()
	print("你已死亡！！！")
	# 销毁玩家碰撞体
	body.get_node("CollisionShape2D").queue_free()
	# 时间放缓一半
	Engine.time_scale = 0.5
	# 倒计时开始
	$Timer.start()


func _on_timer_timeout() -> void:
	# 时间流速恢复
	Engine.time_scale = 1
	# 重新加载程序
	get_tree( ).reload_current_scene( )
