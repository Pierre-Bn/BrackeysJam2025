extends CanvasLayer


@export var wavelength = 100
@export var intensity = 100

signal solved

var verticalOffset = 480
var horizontalOffset = 400
var windowLegth = 800
var isSolved = false


var targetWavelength
var targetIntensity
var inputWavelength
var inputIntensity

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Panel.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	
	targetWavelength = randi_range(1,3) * 10
	targetIntensity = randi_range(1,5) * 20
	inputWavelength = randi_range(1,3) * 10
	inputIntensity = randi_range(1,5) * 20
	
	while(inputIntensity == targetIntensity && inputWavelength == targetWavelength):
		inputWavelength = randi_range(1,3) * 10
		inputIntensity = randi_range(1,5) * 20
		
	$targetWave.points = generatePoints(targetWavelength, targetIntensity)
	$inputWave.points = generatePoints(inputWavelength, inputIntensity)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if(!check_match()):
		if(Input.is_action_just_pressed("move_up")):
			inputIntensity += 20
		if(Input.is_action_just_pressed("move_down")):
			inputIntensity -= 20
		if(Input.is_action_just_pressed("move_left")):
			inputWavelength -= 10
		if(Input.is_action_just_pressed("move_right")):
			inputWavelength += 10
		
		if(inputWavelength < 10): inputWavelength = 10
		if(inputWavelength > 30): inputWavelength = 30
		if(inputIntensity < 20): inputIntensity = 20
		if(inputIntensity > 100) : inputIntensity = 100
		
		$inputWave.points = generatePoints(inputWavelength, inputIntensity)
		$inputWave.default_color = Color(1,1,0,0.5) if check_close() else Color(1,0,0,0.5)
		
		
	else:
		
		$targetWave.default_color = Color(0,1,0)
		if(!isSolved):
			isSolved = true
			solved.emit()
	pass
	
func generatePoints(wavelength_: int, intensity_: int):
	
	var array = []
	
	var nb_points = 800/wavelength_ #il faut que nb_points * wavelength = longueur de la fenetre jouable = 800
	
	for i in range(nb_points):
		array.append(Vector2(
			i*wavelength_ + horizontalOffset,
			sin(i)*intensity_ + verticalOffset
		))
		
	return array


func check_match() -> bool:
	return (inputWavelength == targetWavelength && inputIntensity == targetIntensity)
	
func check_close() -> bool:
	return abs(inputWavelength - targetWavelength) <= 10 && abs(inputIntensity - targetIntensity) <= 20
