extends StaticBody2D

var projectile_scene = preload("res://Scenes/bubble.tscn")

func _ready():
	$ShootTimer.timeout.connect(_on_shoot_timer_timeout)

func _on_shoot_timer_timeout():
	var projectile = projectile_scene.instantiate()
	get_parent().add_child(projectile)
	projectile.global_position = global_position
