extends Node

@export var mob_scene: PackedScene
@export var battery_scene: PackedScene
@export var wave_puzzle_spawner_scene: PackedScene

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
	battery = 100
	audience_health = 1
	angry_wave = 0
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(audience_health == 0):
		game_over();
		

func game_over():
	audience_health = 100
	$HUD.update_audience_health(audience_health)
	$HUD.show_game_over(time_survived)
	$sineSpawnTimer.stop()
	$mobTimer.stop()
	$audienceTimer.stop()
	$batterySpawnTimer.stop()
	$Player.hide()
	$Player.toggleHitbox(false)
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
	pass

func _on_player_plug_battery(isCharged) -> void:
	if(isCharged):
		$fuelValid.play()
		battery += 20
		if(battery>100):
			battery = 100
	else:
		$fuelInvalid.play()
		battery -= 5
		if(battery <= 0):
			battery = 0
	$HUD.update_battery(battery)
	update_teto_status()
	
func new_game():
	print("new game")
	audience_health = 100
	time_survived = 0
	angry_wave = 0
	battery = 100
	$HUD.update_battery(battery)
	$HUD.show_message("Get Ready")
	$Player.start($playerStart.position)
	$Player.toggleHitbox(true)
	$Player.speed = 400
	$mobTimer.start()
	$audienceTimer.start()
	$batterySpawnTimer.start()
	$sineSpawnTimer.start()
	$mobTimer.wait_time = 1
	reset_tiles()

func reset_tiles():
	$Layers/charge.reset()
	$Layers/charged.reset()
	pass

func _on_mob_timer_timeout() -> void:
	var mob = mob_scene.instantiate()
	
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()
	
	var direction = mob_spawn_location.rotation + PI / 2
	
	mob.position = mob_spawn_location.position
	
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction
	
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)
	
	add_child(mob)
	
	$mobTimer.wait_time = 0.995*$mobTimer.wait_time
	
	pass # Replace with function body.

func _on_battery_spawn_timer_timeout() -> void:
	var battery = battery_scene.instantiate()
	battery.position = Vector2(
		randi_range(playableCoordsTopLeft.x, playableCoordsBottomRight.x), 
		randi_range(playableCoordsTopLeft.y, playableCoordsBottomRight.y)
	)
	while(distance_to_player(battery.position.x, battery.position.y) < 200):
		battery.position = Vector2(
			randi_range(playableCoordsTopLeft.x, playableCoordsBottomRight.x), 
			randi_range(playableCoordsTopLeft.y, playableCoordsBottomRight.y)
		)
	add_child(battery)
	
func _on_sine_spawn_timer_timeout() -> void:
	var wavePuzzleSpawner = wave_puzzle_spawner_scene.instantiate()
	wavePuzzleSpawner.position = Vector2(
		randi_range(playableCoordsTopLeft.x, playableCoordsBottomRight.x), 
		randi_range(playableCoordsTopLeft.y, playableCoordsBottomRight.y)
	)
	while(distance_to_player(wavePuzzleSpawner.position.x, wavePuzzleSpawner.position.y) < 200):
		wavePuzzleSpawner.position = Vector2(
			randi_range(playableCoordsTopLeft.x, playableCoordsBottomRight.x), 
			randi_range(playableCoordsTopLeft.y, playableCoordsBottomRight.y)
		)
	wavePuzzleSpawner.completed.connect(_on_completed)
	wavePuzzleSpawner.angry.connect(_on_angry)
	wavePuzzleSpawner.clear_angry.connect(_on_clear_angry)
	add_child(wavePuzzleSpawner)
	
func _on_completed() -> void:
	$Player.reset_speed()


func _on_audience_timer_timeout() -> void:
	happyTeto = !happyTeto
	battery -= 1
	print(battery)
	print(angry_wave)
	if(battery <= 0):
		battery = 0
		audience_health -= 1
	if(angry_wave > 0):
		audience_health -= 2
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
	

func distance_to_player(x,y) -> int:
	return sqrt(abs(x-$Player.position.x)**2 + abs(y-$Player.position.y)**2)
	
func update_teto_status() -> void:
	$HUD.update_teto_status(angry_wave>0, battery == 0, happyTeto, justHit)
