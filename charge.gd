extends TileMapLayer

signal chargedBattery
signal takeBattery

var slotAvailable

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$batteryChargeBar.hide()
	slotAvailable = true
	pass # Replace with function body.
	
func stopCharge() -> void:
	$chargeTimer.stop()
	$batteryChargeBar.hide()
	slotAvailable = true
	pass

func battery_submitted() -> void :
	if(slotAvailable):
		slotAvailable = false
		takeBattery.emit()
		var coords = Vector2i(12,9)
		var busyCoords = Vector2i(2,0)
		set_cell(
			coords,
			0,
			busyCoords
		)
		$chargeTimer.start()
		resetProgressBar(true)
		await $chargeTimer.timeout
		resetProgressBar(false)
		set_cell(
			coords,
			-1
		)
		chargedBattery.emit()
		slotAvailable = true
		
func resetProgressBar(showBar: bool):
	$batteryChargeBar.value = 0
	if(showBar):
		$batteryChargeBar.show()
	else:
		$batteryChargeBar.hide()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_charged_free_charge_slot(immediatelyReplace : bool) -> void:
	var coords = Vector2i(12,9)
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
	slotAvailable = true
	$chargeTimer.stop()
	$batteryChargeBar.hide()
	_on_charged_free_charge_slot(false)
	var coords = Vector2i(12,9)
	var freeCoords = Vector2i(1,0)
	set_cell(
		coords,
		0,
		freeCoords
	)
	pass


func _on_global_tick_timer_timeout() -> void:
	$batteryChargeBar.value += 1
	pass # Replace with function body.
