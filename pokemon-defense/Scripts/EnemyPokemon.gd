extends Area2D

var speed = 50
var health = 50
var attack_damage = 5
var can_move = true

func _ready():
	add_to_group("Enemies")

func _process(delta):
	if $AttackRay.is_colliding():
		var target = $AttackRay.get_collider()
		if target and target.has_method("take_damage"):
			can_move = false
			target.take_damage(attack_damage * delta) 
	else:
		can_move = true

	if can_move:
		position.x -= speed * delta

func receive_damage(amount):
	health -= amount
	flash_hit()
	if health <= 0:
		queue_free()
		
func flash_hit():
	var tween = create_tween()
	$Sprite2D.modulate = Color(1, 0, 0)
	tween.tween_property($Sprite2D, "modulate", Color(1, 1, 1), 0.2)
