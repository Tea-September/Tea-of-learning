extends Area2D


func _on_body_entered(body: Node2D) -> void:
	body = body
	print("你已死亡！！！")
	$Timer.start()


func _on_timer_timeout() -> void:
	get_tree( ).reload_current_scene( )
