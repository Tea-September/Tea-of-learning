class_name Stats
extends Node

signal health_changed
signal  energy_changed

# 生命值，默认3
@export var max_health : int = 3

@onready var health : int = max_health:
	set(T):
		T = clampi(T, 0, max_health)
		if health == T:
			return
		health = T
		health_changed.emit()

# 能量值，默认5
@export var max_energy : int = 5

@onready var energy : int = max_energy:
	set(T):
		T = clampi(T, 0, max_energy)
		if energy == T:
			return
		energy = T
		energy_changed.emit()

# 攻击力，默认1
@export var max_attack : int = 1

@onready var attack : int = max_attack:
	set(T):
		T = clampi(T, 0, max_attack)
		if attack == T:
			return
		attack = T

func to_dict() -> Dictionary:
	return {
		max_energy = max_energy,
		max_health = max_health,
		max_attack = max_attack,
		health = health,
		energy= energy,
		attack = attack,
	}

func from_dict(dict: Dictionary) -> void:
	max_energy = dict.max_energy
	max_health = dict.max_health
	max_attack = dict.max_attack
	health = dict.health
	energy= dict.energy
	attack = dict.attack
