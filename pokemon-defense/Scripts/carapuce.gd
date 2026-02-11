extends StaticBody2D

var projectile_scene = preload("res://Scenes/Bubble.tscn")
var health = 100
var attack_stat = 20

func _ready():
	$ShootTimer.timeout.connect(_on_shoot_timer_timeout)

func _process(_delta):
	if $LineDetector.is_colliding():
		if $ShootTimer.is_stopped():
			$ShootTimer.start()
	else:
		$ShootTimer.stop()

func take_damage(amount):
	health -= amount
	flash_hit()
	if health <= 0:
		queue_free()

func _on_shoot_timer_timeout():
	var projectile = projectile_scene.instantiate()
	projectile.damage = attack_stat 
	get_tree().current_scene.get_node("Projectiles").add_child(projectile)
	
	projectile.global_position = global_position

func flash_hit():
	var tween = create_tween()
	$Sprite2D.modulate = Color(1, 0, 0)
	tween.tween_property($Sprite2D, "modulate", Color(1, 1, 1), 0.2)
