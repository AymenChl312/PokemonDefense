extends Area2D

var speed = 400
var damage = 0

func _process(delta):
	position.x += speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_area_entered(area):
	if area.is_in_group("Enemies"):
		if area.has_method("receive_damage"):
			area.receive_damage(damage)
			queue_free()
