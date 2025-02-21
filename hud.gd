extends CanvasLayer

signal start_tuto
signal start_game

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$gameOverPicture.hide()
	$tutoMgsBg.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	$timeResultLabel.hide()
	$audienceHealth.value = 100
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func show_game_over(score: int):
	$gameOverPicture.texture = load(get_game_over_picture(score))
	
	$startButton.position.x = 1030
	$startButton.position.y = 666
	
	$gameOverPicture.show()
	
	$timeResultLabel.text = $timeSurvivedLabel.text
	$timeResultLabel.show()
	
	print("show game over")
	$startButton.show()
	
func toggle_tuto(enabled: bool):
	if(enabled):
		$tutoMgsBg.show()
		$tutoMgsBg/tutoMessage.show()
	else:
		$tutoMgsBg.hide()
		$tutoMgsBg/tutoMessage.hide()

func setTutoMsg(msg: String):
	$tutoMgsBg/tutoMessage.text = msg

func update_battery(battery):
	$batteryLabel.text = str(battery) + " %"

func update_audience_health(health):
	$audienceHealth.value = health

func update_time_survived(timeSurvived):
	var seconds = timeSurvived%60
	var minutes = timeSurvived/60
	$timeSurvivedLabel.text = ("%02d" % minutes) + ":" + ("%02d" % seconds)

func _on_start_button_pressed() -> void:
	$gameOverPicture.hide()
	$timeResultLabel.hide()
	$startButton.hide()
	$tutoButton.hide()
	start_game.emit()


func _on_tuto_button_pressed() -> void:
	$gameOverPicture.hide()
	$timeResultLabel.hide()
	$startButton.hide()
	$tutoButton.hide()
	start_tuto.emit()
	
	pass # Replace with function body.

func update_teto_status(angry: bool, empty: bool, happy: bool, hit: bool) -> void:
	if(hit):
		$tetoUi.texture = preload("res://assets/ui/teto_status/teto_status_hurt.png")
	elif(empty):
		$tetoUi.texture = preload("res://assets/ui/teto_status/teto_status_battery.png")
	elif(angry):
		$tetoUi.texture = preload("res://assets/ui/teto_status/teto_status_wave.png")
	elif(happy):
		$tetoUi.texture = preload("res://assets/ui/teto_status/teto_status_good_1.png")
	else:
		$tetoUi.texture = preload("res://assets/ui/teto_status/teto_status_good_2.png")

func get_game_over_picture(score: int) -> String:
	var result = ""
	if(score < 30):
		result = "worst"
	elif(score < 60):
		result = "bad"
	elif(score < 120):
		result = "good"
	if(score >= 180):
		result = "best"
	return "res://assets/ui/game_over_screens/" + result + ".png"
