extends Line2D

signal solved

@export var wavelength = 100
@export var intensity = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	wavelength = randi_range(10,30)
	intensity = randi_range(10,150)
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
	
	if(Input.is_action_pressed("move_up")):
		intensity += 1
	if(Input.is_action_pressed("move_down")):
		intensity -= 1
	if(Input.is_action_pressed("move_left")):
		wavelength -= 1
	if(Input.is_action_pressed("move_right")):
		wavelength += 1
		
	if(wavelength < 10): wavelength = 10
	if(wavelength < 30): wavelength = 30
	if(intensity < 10): intensity = 10
	if(intensity < 150) : intensity = 150
		
	if(check_match()):
		$targetSine.default_color = Color(0,1,0)
		solved.emit()
		_ready()
		$targetSine._ready()
	pass

func check_match() -> bool:
	return ((abs(wavelength) - abs($targetSine.wavelength) < 3) && (abs(intensity) - abs($targetSine.intensity) < 5))
