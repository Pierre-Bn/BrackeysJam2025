extends StaticBody2D

@export var wave_puzzle_scene: PackedScene

signal completed
signal angry
signal clear_angry

var isAngry

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$angryBar.value = 100
	$angryProgressTimer.start()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(!isAngry && $angryBar.value == 0):
		isAngry = true
		$Sprite2D.texture = preload("res://assets/wave_puzzle_sprite/wave_puzzle_spawner_angry.png")
		angry.emit()
	pass
	
func start_puzzle() -> void:
	add_child(wave_puzzle_scene.instantiate())
	var puzzle = get_node("CanvasLayer").get_node("inputSine")
	puzzle.solved.connect(_on_solved)
	toggleHitbox(false)
	$angryProgressTimer.stop()
	pass

func _on_solved():
	await get_tree().create_timer(0.25).timeout
	completed.emit()
	if(isAngry):
		clear_angry.emit()
	queue_free()
	pass

func toggleHitbox(enabled: bool):	
	$CollisionShape2D.disabled = !enabled

func _on_angry_progress_timer_timeout() -> void:
	$angryBar.value -= 1
