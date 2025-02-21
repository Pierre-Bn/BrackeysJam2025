extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.play("fly")

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_2d_kill() -> void:
	$killVirus.play()
	await get_tree().create_timer(0.2).timeout
	Input.set_custom_mouse_cursor(preload("res://assets/target_off.png"), 0, Vector2(40,40))
	queue_free()
	pass # Replace with function body.


func _on_area_2d_mouse_entered() -> void:
	Input.set_custom_mouse_cursor(preload("res://assets/target_on.png"), 0, Vector2(40,40))
	pass # Replace with function body.


func _on_area_2d_mouse_exited() -> void:
	Input.set_custom_mouse_cursor(preload("res://assets/target_off.png"), 0, Vector2(40,40))
	pass # Replace with function body.
