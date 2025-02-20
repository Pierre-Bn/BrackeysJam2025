extends Line2D

@export var wavelength = 100
@export var intensity = 100

var verticalOffset = 512
var horizontalOffset = 400
var windowLegth = 800

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	wavelength = randi_range(1,3) * 10
	intensity = randi_range(1,5) * 20
	
	var array = []
	
	var nb_points = 800/wavelength #il faut que nb_points * wavelength = longueur de la fenetre jouable = 800
	
	for i in range(nb_points):
		array.append(Vector2(
			i*wavelength + horizontalOffset,
			sin(i)*intensity + verticalOffset
		))
		
	points = array
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
