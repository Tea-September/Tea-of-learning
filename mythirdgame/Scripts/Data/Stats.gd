class_name Stats
extends Node

signal health_changed

# 生命值，默认3
@export var max_health : int = 3

@onready var health : int = max_health:
	set(T):
		T = clampi(T, 0, max_health)
		if health == T:
			return
		health = T
		health_changed.emit()

# 攻击力，默认1
@export var max_attack : int = 1

@onready var attack : int = max_attack:
	set(T):
		T = clampi(T, 0, max_attack)
		if attack == T:
			return
		attack = T
