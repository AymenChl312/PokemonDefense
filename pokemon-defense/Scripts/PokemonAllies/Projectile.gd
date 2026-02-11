extends Area2D

var speed: float
var value: float      
var is_energy: bool = false

func setup(p_sprite, p_speed, p_value, p_is_energy = false):
	$Sprite2D.texture = p_sprite
	speed = p_speed
	value = p_value
	is_energy = p_is_energy
	
	if is_energy:
		z_index = 10 
		launch_energy_arc()
	else:
		z_index = 0

func _process(delta):
	if not is_energy:
		position.x += speed * delta

func launch_energy_arc():
	var tween = create_tween().set_parallel(true)
	
	var jump_x = randf_range(-40, 40)
	var jump_height = -40 
	var start_y = global_position.y
	
	tween.tween_property(self, "global_position:x", global_position.x + jump_x, 1.0)
	tween.tween_property(self, "global_position:y", start_y + jump_height, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	tween.chain().tween_property(self, "global_position:y", start_y, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	tween.chain().tween_interval(20.0) 
	
	tween.chain().tween_property(self, "modulate:a", 0, 1.0)
	tween.tween_callback(queue_free)

func _on_input_event(_viewport, event, _shape_idx):
	if is_energy and event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			input_pickable = false 
			var tween = create_tween()
			tween.tween_property(self, "global_position", Vector2(50, 50), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
			tween.tween_callback(collect_energy)

func collect_energy():
	var main = get_tree().current_scene
	main.energy += value
	main.update_ui()
	queue_free()

func _on_area_entered(area):
	if not is_energy and area.is_in_group("Enemies"):
		if area.has_method("receive_damage"):
			area.receive_damage(value)
			queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	if not is_energy:
		queue_free()
