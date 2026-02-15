extends Area2D

@export var my_id: PkmnID.Name
var stats: EnemyData
var current_health: int
var can_move = true
var attack_timer = 0.0


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
	if $AttackRay.is_colliding():
		var target = $AttackRay.get_collider()
		if target and target.has_method("take_damage"):
			can_move = false
			attack_timer += delta
			var attack_cooldown = stats.attack_speed
			
			if attack_timer >= attack_cooldown:
				target.take_damage(stats.attack_damage)
				attack_timer = 0.0 
	else:
		can_move = true
		attack_timer = stats.attack_speed

	if can_move:
		position.x -= stats.speed * delta

	if can_move:
		position.x -= stats.speed * delta


#---Damage--

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
	tween.tween_property($Sprite2D, "modulate", Color(1, 1, 1), 0.2)
