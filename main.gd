extends Node

@export var mob_scene: PackedScene
@export var battery_scene: PackedScene
@export var wave_puzzle_spawner_scene: PackedScene
@export var sign_scene: PackedScene

var audience_health
var battery
var time_survived
var angry_wave
var playableCoordsTopLeft = Vector2(480,80)
var playableCoordsBottomRight = Vector2(1120,880)
var happyTeto = true
var justHit = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_music()
	Input.set_custom_mouse_cursor(preload("res://assets/target_off.png"), 0, Vector2(40,40))
	$signCharge.play("arrow")
	$signPlug.play("arrow")
	$signCharge.hide()
	$signPlug.hide()
	$HUD.toggle_tuto(false)
	battery = 100
	audience_health = 1
	angry_wave = 0
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if(audience_health == 0):
		game_over();
	
	if(battery <= 0 || justHit):
		$music/vocal_normal.volume_db = linear_to_db(0)
		$music/vocal_distorted.volume_db = linear_to_db(0)
	elif(angry_wave > 0):
		$music/vocal_normal.volume_db = linear_to_db(0)
		$music/vocal_distorted.volume_db = linear_to_db(5)
	else:
		$music/vocal_normal.volume_db = linear_to_db(5)
		$music/vocal_distorted.volume_db = linear_to_db(0)
		
		
func start_music():
	$music/instrumental.play()
	$music/vocal_normal.play()
	$music/vocal_distorted.play()
	$music/vocal_distorted.volume_db = linear_to_db(0)
	pass


func game_over():
	audience_health = 100
	$HUD.update_audience_health(audience_health)
	$HUD.show_game_over(time_survived)
	$sineSpawnTimer.stop()
	$mobTimer.stop()
	$Layers/charge.stopCharge()
	reset_tiles()
	$audienceTimer.stop()
	$batterySpawnTimer.stop()
	$Player.hide()
	$Player.toggleHitbox(false)
	Input.set_custom_mouse_cursor(preload("res://assets/target_off.png"), 0, Vector2(40,40))
	get_tree().call_group("wave_puzzle_spawners", "queue_free")
	get_tree().call_group("mobs", "queue_free")
	get_tree().call_group("batteries", "queue_free")

func _on_player_hit() -> void:
	$playerHit.play()
	audience_health -= 5
	if(audience_health<0): 
		audience_health = 0
	$HUD.update_audience_health(audience_health)
	justHit = true
	update_teto_status()
	await get_tree().create_timer(0.5).timeout
	justHit = false
	update_teto_status()	
	
func _on_player_get_battery() -> void:
	$signCharge.show()
	pass
	
func _on_player_charge_battery() -> void:
	$signCharge.hide()
	pass

func _on_player_plug_battery(isCharged) -> void:
	$signPlug.hide()
	if(isCharged):
		$fuelValid.play()
		battery += 20
		if(battery>100):
			battery = 100
	else:
		if(!$Layers/charged.chargedAvailable):
			print("charged available")
			$signCharge.hide()
		$fuelInvalid.play()
		battery -= 5
		if(battery <= 0):
			battery = 0
	$HUD.update_battery(battery)
	update_teto_status()
	
func new_game():
	audience_health = 100
	time_survived = 0
	angry_wave = 0
	battery = 100
	update_teto_status()
	$HUD.update_time_survived(time_survived)
	$HUD.update_battery(battery)
	$Player.isOnPuzzle = false
	$Player.start($playerStart.position)
	$Player.toggleHitbox(true)
	$Player.speed = 400
	$mobTimer.start()
	$audienceTimer.start()
	$batterySpawnTimer.start()
	$sineSpawnTimer.start()
	$mobTimer.wait_time = 1
	$signCharge.hide()
	$signPlug.hide()
	reset_tiles()

func start_tuto() -> void:
	$HUD.toggle_tuto(true)
	print("tutorial")
	audience_health = 100
	time_survived = 0
	angry_wave = 0
	battery = 100
	update_teto_status()
	$HUD.update_time_survived(time_survived)
	$HUD.update_battery(battery)
	$Player.isOnPuzzle = false
	$Player.start($playerStart.position)
	$Player.toggleHitbox(true)
	$Player.speed = 400
	
	$audienceTimer.start()
	
	$HUD.setTutoMsg("Wires slow you down!")
	await get_tree().create_timer(5.0).timeout
	
	spawn_mob()
	$HUD.setTutoMsg("Virus :\nClick to kill,\nlose HP on contact!")
	await get_tree().create_timer(5.0).timeout
	
	$HUD.setTutoMsg("The HP bar is on the right!")
	await get_tree().create_timer(5.0).timeout
	
	_on_battery_spawn_timer_timeout()
	$HUD.setTutoMsg("Battery : \nPick it up,\ncharge it up,\nplug it in to refill Teto's batteries!")
	await get_tree().create_timer(10.0).timeout
	
	$HUD.setTutoMsg("Teto's batteries drain over time. You lose HP when Teto's batteries are empty!")
	await get_tree().create_timer(5.0).timeout
	
	$HUD.setTutoMsg("The current battery level is on the left!")
	await get_tree().create_timer(5.0).timeout
	
	_on_sine_spawn_timer_timeout()
	$HUD.setTutoMsg("Sine wave puzzle :\nComplete it to fix Teto's voice!\nDon't wait too long, HP will drain!")
	await get_tree().create_timer(10.0).timeout
	
	$HUD.setTutoMsg("Good luck! \nSurvive as long as you can, \nThe Show Must Go On!")
	await get_tree().create_timer(5.0).timeout
	
	get_tree().reload_current_scene()
	
func reset_tiles():
	$Layers/charge.reset()
	$Layers/charged.reset()
	pass

func _on_mob_timer_timeout() -> void:
	spawn_mob()
	
	$mobTimer.wait_time = 0.995*$mobTimer.wait_time
	
func spawn_mob():
	var mob = mob_scene.instantiate()
	
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()
	
	var direction = mob_spawn_location.rotation + PI / 2
	
	mob.position = mob_spawn_location.global_position
	
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction
	
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)
	
	add_child(mob)

func _on_battery_spawn_timer_timeout() -> void:
	var battery_ = battery_scene.instantiate()
	battery_.position = Vector2(
		randi_range(playableCoordsTopLeft.x+80, playableCoordsBottomRight.x-80), 
		randi_range(playableCoordsTopLeft.y+80, playableCoordsBottomRight.y-80)
	)
	
	while(distance_between(battery_.position, $Player.position) < 200 ||
		distance_between(battery_.position, Vector2(1000,760)) < 100 || 
		distance_between(battery_.position, Vector2(600,200)) < 100
	):
		battery_.position = Vector2(
			randi_range(playableCoordsTopLeft.x+80, playableCoordsBottomRight.x-80), 
			randi_range(playableCoordsTopLeft.y+80, playableCoordsBottomRight.y-80)
		)
		
	add_child(battery_)
	
func _on_sine_spawn_timer_timeout() -> void:
	var wavePuzzleSpawner = wave_puzzle_spawner_scene.instantiate()
	wavePuzzleSpawner.position = Vector2(
		randi_range(playableCoordsTopLeft.x+80, playableCoordsBottomRight.x-80), 
		randi_range(playableCoordsTopLeft.y+80, playableCoordsBottomRight.y-80)
	)
	
	while(
		distance_between(wavePuzzleSpawner.position, $Player.position) < 200 || 
		distance_between(wavePuzzleSpawner.position, Vector2(1000,760)) < 100 || 
		distance_between(wavePuzzleSpawner.position, Vector2(600,200)) < 100
	):
		wavePuzzleSpawner.position = Vector2(
			randi_range(playableCoordsTopLeft.x+80, playableCoordsBottomRight.x-80), 
			randi_range(playableCoordsTopLeft.y+80, playableCoordsBottomRight.y-80)
		)

	wavePuzzleSpawner.completed.connect(_on_completed)
	wavePuzzleSpawner.angry.connect(_on_angry)
	wavePuzzleSpawner.clear_angry.connect(_on_clear_angry)
	add_child(wavePuzzleSpawner)
	
func _on_completed() -> void:
	$Player.isOnPuzzle = false
	$Player.reset_speed()

func _on_audience_timer_timeout() -> void:
	happyTeto = !happyTeto
	battery -= 2
	if(battery <= 0):
		battery = 0
		audience_health -= 3
		if(audience_health <= 0):
			audience_health = 0
	if(angry_wave > 0):
		audience_health -= 1
	time_survived += 1
	$HUD.update_time_survived(time_survived)
	$HUD.update_battery(battery)
	$HUD.update_audience_health(audience_health)
	update_teto_status()

func _on_angry() -> void:
	angry_wave += 1
	update_teto_status()

func _on_clear_angry() -> void:
	angry_wave -= 1
	
func distance_between(a: Vector2, b: Vector2) -> int:
	return sqrt(abs(a.x-b.x)**2 + abs(a.y-b.y)**2)
	
func update_teto_status() -> void:
	$HUD.update_teto_status(angry_wave>0, battery == 0, happyTeto, justHit)

func _on_charge_charged_battery() -> void:
	$signCharge.show()
	pass # Replace with function body.


func _on_charge_take_battery() -> void:
	$signCharge.hide()
	pass # Replace with function body.


func _on_charged_free_charge_slot(_ignore: bool) -> void:
	$signCharge.hide()
	$signPlug.show()
	pass # Replace with function body.
