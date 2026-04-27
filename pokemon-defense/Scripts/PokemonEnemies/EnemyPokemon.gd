extends Area2D

@export var my_id: PkmnID.Name
var stats: EnemyData
var current_health: int
var can_move = true
var attack_timer = 0.0
var current_speed_multiplier = 1.0
var slow_timer = 0.0

#--Set Up Enemies--

func _ready():
	add_to_group("Enemies")
	var library = preload("res://Data/Pokemons/EnemyLibrary.tres")
	if library.database.has(my_id):
		stats = library.database[my_id]
		setup_enemy()

func setup_enemy():
	$Sprite2D.texture = stats.sprite
	current_health = stats.health

#--Attack--

#Attack pokemon allies
func _process(delta):
	
	# Slow down 
	if slow_timer > 0:
		slow_timer -= delta
		if slow_timer <= 0:
			current_speed_multiplier = 1.0
			$Sprite2D.modulate = Color(1, 1, 1)

	# Attack
	if $AttackRay.is_colliding():
		var target = $AttackRay.get_collider()
		if target and target.has_method("receive_damage"):
			can_move = false
			attack_timer += delta
			if attack_timer >= stats.attack_speed:
				target.receive_damage(stats.attack_damage)
				attack_timer = 0.0 
	else:
		can_move = true
		attack_timer = stats.attack_speed

	# Movement
	if can_move:
		position.x -= (stats.speed * current_speed_multiplier) * delta

#---Damage & Effects--

#Slow effect from ice attacks
func apply_slow(reduction_percent: float, duration: float):
	if slow_timer <= 0:
		current_speed_multiplier = 1.0 - (reduction_percent / 100.0)
	slow_timer = duration
	
	if $Sprite2D.modulate != Color(1, 0, 0):
		$Sprite2D.modulate = Color(0.3, 0.5, 1.0)

#Damage received
func receive_damage(amount):
	current_health -= amount
	flash_hit()
	if current_health <= 0:
		queue_free()

#Animation damage
func flash_hit():
	var tween = create_tween()
	$Sprite2D.modulate = Color(1, 0, 0)
	var back_color = Color(0.3, 0.5, 1.0) if slow_timer > 0 else Color(1, 1, 1)
	tween.tween_property($Sprite2D, "modulate", back_color, 0.1)
