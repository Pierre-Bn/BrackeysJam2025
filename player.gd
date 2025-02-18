extends Area2D

signal hit
signal chargeBattery
signal takeBattery
signal giveBattery
signal plugBattery

@export var speed = 400
var screen_size 
var hasBattery
var isBatteryCharged

func start(pos):
	position = pos
	show()
	$Sprite2D.hide()
	hasBattery = false
	$CollisionShape2D.disabled = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		if(velocity.x != 0) :
			$AnimatedSprite2D.play("walk_r")
			$AnimatedSprite2D.flip_h = velocity.x < 0
		else:
			if(velocity.y > 0) :
				$AnimatedSprite2D.play("walk_d")
			if(velocity.y < 0) :
				$AnimatedSprite2D.play("walk_u")
	else:
		$AnimatedSprite2D.stop()
		
	position += velocity * delta
	var corner1 = Vector2i(121,121)
	var corner2 = Vector2i(screen_size.x-121, screen_size.y-121)
	#position = position.clamp(Vector2.ZERO, screen_size)
	position = position.clamp(corner1, corner2)


func _on_body_entered(body: Node2D) -> void:	
	if (body.name == "spikes"):
		speed = 200
		pass
	if (body.is_in_group("mobs")):
		$hitTimer.start()
		$AnimatedSprite2D.modulate.a = 0.5;
		hit.emit()
		$CollisionShape2D.set_deferred("disabled", true)
	if (body.is_in_group("batteries") && !hasBattery): #picking up an empty battery from the floor
		hasBattery = true
		isBatteryCharged = false
		$Sprite2D.texture = preload("res://assets/battery_sprites/battery_empty.png")
		$Sprite2D.show()
		body.call_deferred("queue_free")
		pass
	if (body.name == "charge" && hasBattery && !isBatteryCharged): #placing an empty battery on a charge tile
		body.call_deferred("battery_submitted")
	
	if (body.name == "charged" && !(hasBattery && isBatteryCharged)): #picking up charged battery
		print("picking up charged battery")
		body.call_deferred("remove_battery", 8, 9, hasBattery)
		hasBattery = true
		isBatteryCharged = true
		$Sprite2D.texture = preload("res://assets/battery_sprites/battery_full.png")
		$Sprite2D.show()
	
	if (body.name == "plug" && hasBattery): #plugging in charged battery
		emit_signal("plugBattery",isBatteryCharged)
		hasBattery = false
		isBatteryCharged = false
		$Sprite2D.hide()
		pass
		
func _on_body_exited(body: Node2D) -> void:
	if (body.name == "spikes"):
		speed = 400
		pass
	pass

func _on_hit_timer_timeout() -> void:
	$AnimatedSprite2D.modulate.a = 1.0;
	$CollisionShape2D.set_deferred("disabled", false)

func _on_charge_take_battery() -> void:
	if(!isBatteryCharged):
		hasBattery = false
		isBatteryCharged = false
		$Sprite2D.hide()
		print("chargin!")
		pass
