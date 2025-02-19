extends TileMapLayer

signal chargedBattery
signal takeBattery

var slotAvailable

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	slotAvailable = true
	print("created charge tile")
	pass # Replace with function body.

func battery_submitted() -> void :
	if(slotAvailable):
		slotAvailable = false
		takeBattery.emit()
		print("starting charge")
		var coords = Vector2i(8,9)
		var busyCoords = Vector2i(2,0)
		var freeCoords = Vector2i(1,0)
		set_cell(
			coords,
			0,
			busyCoords
		)
		$chargeTimer.start()
		await $chargeTimer.timeout
		print("charge finished")
		set_cell(
			coords,
			-1
		)
		chargedBattery.emit()
		slotAvailable = true
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_charged_free_charge_slot(immediatelyReplace : bool) -> void:
	var coords = Vector2i(8,9)
	var freeCoords = Vector2i(1,0)
	set_cell(
		coords,
		0,
		freeCoords
	)
	if(immediatelyReplace):
		battery_submitted()
	pass # Replace with function body.

func reset():
	var coords = Vector2i(8,9)
	var busyCoords = Vector2i(2,0)
	var freeCoords = Vector2i(1,0)
	set_cell(
		coords,
		0,
		freeCoords
	)
	pass
