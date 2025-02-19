extends Node

@export var mob_scene: PackedScene
@export var battery_scene: PackedScene

var audienceHealth
var time_survived

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audienceHealth = 100
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(audienceHealth == 0):
		game_over();
		audienceHealth = 100

func game_over():
	$HUD.show_game_over()
	$mobTimer.stop()
	$audienceTimer.stop()
	$batterySpawnTimer.stop()
	$Player.hide()
	$Player.toggleHitbox(false)

func _on_player_hit() -> void:
	$playerHit.play()
	audienceHealth -= 10
	if(audienceHealth<0): 
		audienceHealth = 0
	$HUD.update_audience_health(audienceHealth)
	
func _on_player_get_battery() -> void:
	pass

func _on_player_plug_battery(isCharged) -> void:
	if(isCharged):
		$fuelValid.play()
		audienceHealth += 20
		if(audienceHealth>100):
			audienceHealth = 100
	else:
		$fuelInvalid.play()
		audienceHealth -= 5
	$HUD.update_audience_health(audienceHealth)
	
func new_game():
	get_tree().call_group("mobs", "queue_free")
	get_tree().call_group("batteries", "queue_free")
	audienceHealth = 100
	time_survived = 0
	$HUD.update_audience_health(audienceHealth)
	$HUD.show_message("Get Ready")
	$Player.start($playerStart.position)
	$Player.toggleHitbox(true)
	$startTimer.start()
	$batterySpawnTimer.start()
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
	battery.position = Vector2(randi_range(64,1216), randi_range(64,896))
	add_child(battery)
	$HUD.update_audience_health(audienceHealth)

func _on_start_timer_timeout() -> void:
	$mobTimer.start()
	$audienceTimer.start()

func _on_audience_timer_timeout() -> void:
	audienceHealth -= 1
	time_survived += 1
	$HUD.update_time_survived(time_survived)
	$HUD.update_audience_health(audienceHealth)
