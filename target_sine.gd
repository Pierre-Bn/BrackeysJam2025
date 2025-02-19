extends Line2D

@export var wavelength = 100
@export var intensity = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	wavelength = randi_range(1,3) * 10
	intensity = randi_range(1,10) * 10
	
	var array = []
	
	var nb_points = 1280/wavelength #il faut que nb_points * wavelength = longueur de la fenetre = 1280
	
	for i in range(nb_points):
		array.append(Vector2(
			i*wavelength,
			sin(i)*intensity + 512
		))
		
	points = array
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
