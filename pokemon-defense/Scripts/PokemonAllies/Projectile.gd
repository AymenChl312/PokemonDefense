extends Area2D

var speed: float
var value: float      
var is_energy: bool = false
var is_slow: bool = false
var slow_amount: float = 0.0
var is_breath: bool = false 
var damaged_enemies: Array = [] 

#--Set Up--

func _ready():
	# Force la détection même si on a oublié de cocher des cases dans l'éditeur
	monitoring = true 
	monitorable = true
	
	# Reconnexion automatique du signal de collision
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)

func setup(p_sprite, p_speed, p_value, p_is_energy = false):
	$Sprite2D.texture = p_sprite
	speed = p_speed
	value = p_value
	is_energy = p_is_energy
	
	if is_energy:
		z_index = 10
		launch_energy_arc()

func set_slow_effect(p_is_slow: bool, p_amount: float):
	is_slow = p_is_slow
	slow_amount = p_amount

func set_as_breath(duration: float):
	is_breath = true 
	await get_tree().process_frame
	check_initial_overlap()
	
	var tween = create_tween()
	tween.tween_interval(duration)
	tween.tween_callback(queue_free)

func check_initial_overlap():
	var targets = get_overlapping_areas()
	for target in targets:
		_on_area_entered(target)

#--Set up parameters (Énergie naturelle)--
# Cette fonction était manquante et causait ton crash
func setup_natural(p_sprite, p_value, p_target_y):
	$Sprite2D.texture = p_sprite
	value = p_value
	is_energy = true
	z_index = 10
	launch_natural_fall(p_target_y)

#--Attacks--

func _process(delta):
	if not is_energy and not is_breath:
		position.x += speed * delta

func _on_area_entered(area):
	# DEBUG: Cette ligne s'affiche dans ta console Godot
	print("Projectile touche quelque chose : ", area.name, " Groupe : ", area.get_groups())

	if not is_energy and area.is_in_group("Enemies"):
		
		# Logique Souffle
		if is_breath:
			if not damaged_enemies.has(area):
				damaged_enemies.append(area)
				if area.has_method("receive_damage"):
					print("Dégâts de SOUFFLE infligés à : ", area.name)
					area.receive_damage(value)
			return 

		# Logique Projectile Classique
		if area.has_method("apply_slow") and is_slow:
			area.apply_slow(slow_amount, 3.0) 
		
		if area.has_method("receive_damage"):
			print("Dégâts de BALLE infligés à : ", area.name, " Valeur : ", value)
			area.receive_damage(value)
			queue_free()
		else:
			print("ERREUR : L'ennemi n'a pas de fonction receive_damage !")

#Destroy exiting screen
func _on_visible_on_screen_notifier_2d_screen_exited():
	if not is_energy:
		queue_free()

#--Energies

#Energy trajectory
func launch_energy_arc():
	var tween = create_tween()
	var jump_x = randf_range(-60, 60)
	var jump_height = -40 
	var start_y = global_position.y
	
	tween.set_parallel(true)
	tween.tween_property(self, "global_position:x", global_position.x + jump_x, 0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "global_position:y", start_y + jump_height, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(self, "global_position:y", start_y, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	tween.set_parallel(false)
	tween.tween_interval(8.0)
	
	add_flashing_sequence(tween)

#Natural energy trajectory
func launch_natural_fall(target_y):
	var tween = create_tween()
	tween.tween_property(self, "global_position:y", target_y, 5.0).set_trans(Tween.TRANS_LINEAR)
	tween.tween_interval(8.0)
	add_flashing_sequence(tween)

#Energy dying
func add_flashing_sequence(tween: Tween):
	for i in range(4):
		tween.tween_property(self, "modulate:a", 0.2, 0.2)
		tween.tween_property(self, "modulate:a", 1.0, 0.2)
	
	tween.tween_property(self, "modulate:a", 0, 0.5)
	tween.tween_callback(queue_free)

#Energy input receiver
func _on_input_event(_viewport, event, _shape_idx):
	if is_energy and event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			input_pickable = false 
			var tween = create_tween()
			tween.tween_property(self, "global_position", Vector2(50, 50), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
			tween.tween_callback(collect_energy)

#Energy collected
func collect_energy():
	var main = get_tree().current_scene
	main.energy += value
	main.update_ui()
	queue_free()
