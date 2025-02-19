extends TileMapLayer

var chargedAvailable

signal freeChargeSlot

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	chargedAvailable = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_charge_charged_battery() -> void:
	print("creating charged battery tile")
	var coords = Vector2i(8,9)
	var atlasCoords = Vector2i(3,0)
	set_cell(
		coords,
		2,
		atlasCoords
	)
	chargedAvailable = true
	pass # Replace with function body.

func remove_battery(x : int, y : int, immediatelyReplace : bool) -> void:
	var coords = Vector2i(x,y)
	set_cell(
		coords,
		-1
	)
	freeChargeSlot.emit(immediatelyReplace)
	pass

func reset():
	var coords = Vector2i(8,9)
	set_cell(
		coords,
		-1
	)
	pass
