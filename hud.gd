extends CanvasLayer

signal start_game

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func show_message(text):
	$messageLabel.text = text
	$messageLabel.show()
	$messageTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func show_game_over():
	show_message("Game Over")
	# Wait until the MessageTimer has counted down.
	await $messageTimer.timeout
	$messageLabel.text = "Dodge the Creeps!"
	$messageLabel.show()
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(1.0).timeout
	$startButton.show()
	
func update_audience_health(audienceHealth):
	$audienceLabel.text = str(audienceHealth) + " %"

func update_time_survived(timeSurvived):
	var seconds = timeSurvived%60
	var minutes = timeSurvived/60
	$timeSurvivedLabel.text = ("%02d" % minutes) + ":" + ("%02d" % seconds)

func _on_start_button_pressed() -> void:
	$startButton.hide()
	start_game.emit()

func _on_message_timer_timeout() -> void:
	$messageLabel.hide()
