extends Line2D

signal solved

@export var wavelength = 100
@export var intensity = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	wavelength = randi_range(1,3) * 10
	intensity = randi_range(1,10) * 10
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var array = []
	
	var nb_points = 1280/wavelength
	
	for i in range(nb_points):
		array.append(Vector2(
			i*wavelength,
			sin(i)*intensity + 512
		))
		
	points = array
	
	if(!check_match()):
		if(Input.is_action_just_pressed("move_up")):
			intensity += 10
		if(Input.is_action_just_pressed("move_down")):
			intensity -= 10
		if(Input.is_action_just_pressed("move_left")):
			wavelength -= 10
		if(Input.is_action_just_pressed("move_right")):
			wavelength += 10
		
		if(wavelength < 10): wavelength = 10
		if(wavelength > 30): wavelength = 30
		if(intensity < 10): intensity = 10
		if(intensity > 100) : intensity = 100
	else:
		print("target wl : " + str($targetSine.wavelength))
		print("found wl : " + str(wavelength))
		print("target in : " + str($targetSine.intensity))
		print("found in : " + str(intensity))
		$targetSine.default_color = Color(0,1,0)
		solved.emit()

func check_match() -> bool:
	return ((abs(wavelength - $targetSine.wavelength) < 3) && (abs(intensity - $targetSine.intensity) < 5))
