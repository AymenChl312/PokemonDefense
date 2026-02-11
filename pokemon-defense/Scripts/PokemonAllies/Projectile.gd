# res://Scripts/Projectile.gd
extends Area2D

var speed: float
var damage: float

func setup(p_sprite, p_speed, p_damage):
	$Sprite2D.texture = p_sprite
	speed = p_speed
	damage = p_damage

func _process(delta):
	position.x += speed * delta

func _on_area_entered(area):
	if area.is_in_group("Enemies"):
		if area.has_method("receive_damage"):
			area.receive_damage(damage)
			queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
