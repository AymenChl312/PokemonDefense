# res://Scripts/Resources/LevelData.gd
extends Resource
class_name LevelData

@export var level_name: String = "Niveau 1"
@export var level_start_time: float = 3.0
@export var spawn_interval: float = 3.0
@export var possible_enemies: Array[PkmnID.Name] = []
