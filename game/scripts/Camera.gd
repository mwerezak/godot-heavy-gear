extends Camera2D

## TODO zoom and pan limits
var pan_speed = 400
var zoom_step = 1.1

func _ready():
	pass

func _input(event):
	if event.is_action_pressed("view_zoom_in"):
		zoom /= zoom_step
	if event.is_action_pressed("view_zoom_out"):
		zoom *= zoom_step

# use _process for smoother scrolling
func _process(delta):
	#smooth keyboard zoom
	if Input.is_action_pressed("view_zoom_in"):
		zoom /= zoom_step
	if Input.is_action_pressed("view_zoom_out"):
		zoom *= zoom_step
	
	var panning = Vector2()
	if Input.is_action_pressed("view_pan_up"):
		panning.y -= 1
	if Input.is_action_pressed("view_pan_down"):
		panning.y += 1
	if Input.is_action_pressed("view_pan_left"):
		panning.x -= 1
	if Input.is_action_pressed("view_pan_right"):
		panning.x += 1
	position += panning.normalized() * pan_speed * delta * zoom