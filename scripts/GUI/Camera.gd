extends Camera2D

var zoom_step = 1.1
var min_zoom = 0.5
var max_zoom = 2.0

var pan_speed = 800

## Rectangle used to limit camera panning.
## Note that the built in camera limits do not work: they don't actually constrain the position of the camera.
## They only stop the view from moving. For the player, this makes the camera appear to "stick" at the edges of the map, 
## which is bad.
var limit_rect = null setget set_limit_rect

## TODO mouse capture panning

func _input(event):
	if event.is_action_pressed("view_zoom_in"):
		zoom /= zoom_step
		_snap_zoom_limits()
	if event.is_action_pressed("view_zoom_out"):
		zoom *= zoom_step
		_snap_zoom_limits()

# use _process for smoother scrolling
func _process(delta):
	#smooth keyboard zoom
	if Input.is_action_pressed("view_zoom_in"):
		zoom /= zoom_step
		_snap_zoom_limits()
	if Input.is_action_pressed("view_zoom_out"):
		zoom *= zoom_step
		_snap_zoom_limits()
	
	var panning = Vector2()
	if Input.is_action_pressed("view_pan_up"):
		panning.y -= 1
	if Input.is_action_pressed("view_pan_down"):
		panning.y += 1
	if Input.is_action_pressed("view_pan_left"):
		panning.x -= 1
	if Input.is_action_pressed("view_pan_right"):
		panning.x += 1
	
	if panning.length_squared() > 0:
		position += panning.normalized() * pan_speed * delta * zoom
		if limit_rect: _snap_to_limits()

# force position to be inside limit_rect
func _snap_to_limits():
	position.x = clamp(position.x, limit_rect.position.x, limit_rect.end.x)
	position.y = clamp(position.y, limit_rect.position.y, limit_rect.end.y)

func _snap_zoom_limits():
	zoom.x = clamp(zoom.x, min_zoom, max_zoom)
	zoom.y = clamp(zoom.y, min_zoom, max_zoom)

func set_limit_rect(rect):
	limit_rect = rect
	_snap_to_limits()
