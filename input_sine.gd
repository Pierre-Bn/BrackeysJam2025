extends Line2D

signal solved

@export var wavelength = 100
@export var intensity = 100

var verticalOffset = 512
var horizontalOffset = 400
var windowLegth = 800

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	wavelength = randi_range(1,3) * 10
	intensity = randi_range(1,5) * 20
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var array = []
	
	var nb_points = 800/wavelength #il faut que nb_points * wavelength = longueur de la fenetre jouable = 800
	
	for i in range(nb_points):
		array.append(Vector2(
			i*wavelength + horizontalOffset,
			sin(i)*intensity + verticalOffset
		))
		
	points = array
	
	if(!check_match()):
		if(Input.is_action_just_pressed("move_up")):
			intensity += 20
		if(Input.is_action_just_pressed("move_down")):
			intensity -= 20
		if(Input.is_action_just_pressed("move_left")):
			wavelength -= 10
		if(Input.is_action_just_pressed("move_right")):
			wavelength += 10
		
		if(wavelength < 10): wavelength = 10
		if(wavelength > 30): wavelength = 30
		if(intensity < 20): intensity = 20
		if(intensity > 100) : intensity = 100
		
		default_color = Color(1,1,0,0.5) if check_close() else Color(1,0,0,0.5)
		
	else:
		
		$targetSine.default_color = Color(0,1,0)
		solved.emit()

func check_match() -> bool:
	return (wavelength == $targetSine.wavelength && intensity == $targetSine.intensity)
	
func check_close() -> bool:
	return abs(wavelength - $targetSine.wavelength) <= 10 && abs(intensity - $targetSine.intensity) <= 20
	
