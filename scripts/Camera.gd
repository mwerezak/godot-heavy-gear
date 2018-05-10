extends Camera2D

## TODO zoom limits
var pan_speed = 400
var zoom_step = 1.1

## Rectangle used to limit camera panning.
## Note that the built in camera limits do not work: they don't actually constrain the position of the camera.
## They only stop the view from moving. For the player, this makes the camera appear to "stick" at the edges of the map, 
## which is bad.
var limit_rect = null setget set_limit_rect

## TODO mouse capture panning

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
	
	if limit_rect: _snap_to_limits()

# force position to be inside limit_rect
func _snap_to_limits():
	position.x = clamp(position.x, limit_rect.position.x, limit_rect.end.x)
	position.y = clamp(position.y, limit_rect.position.y, limit_rect.end.y)

func set_limit_rect(rect):
	limit_rect = rect
	_snap_to_limits()
