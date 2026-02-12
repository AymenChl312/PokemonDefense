extends Area2D

var active = false
var speed = 800

func _ready():
	add_to_group("Mowers")
	area_entered.connect(_on_area_entered)

func _process(delta):
	if active:
		global_position.x += speed * delta
		if global_position.x > 2000:
			queue_free()

func _on_area_entered(area):
	if area.is_in_group("Enemies"):
		if area.get("is_boss") == true:
			return
			
		if not active:
			active = true
		
		if area.has_method("die"):
			area.die()
		else:
			area.queue_free()
