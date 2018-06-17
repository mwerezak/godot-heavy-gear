extends Camera2D

var zoom_step = 0.1
var min_zoom = 0.5
var max_zoom = 10.0

var pan_speed = 800

## Rectangle used to limit the position of the camera node.
## While the built-in Camera2D limits ensure that the *viewport* does not leave certain limits,
## we have to manually ensure that the *camera* itself does not leave the map or else the view will "stick"
## at the edges. Using the two together allows us to properly handle map limits while zooming.
var limit_rect = null setget set_limit_rect

onready var _anim_player = $AnimationPlayer #for smooth transitions

func _ready():
	set_current(false)
	_anim_player.playback_default_blend_time = 10

## sets the camera position and zoom based on the given rect (while respecting limits)
## note that the view rect should be in global coordinates
export(Rect2) var view_rect setget set_view, get_view
func set_view(view_rect):
	if !is_inside_tree(): return
	
	## center the camera on the rect
	var center = (view_rect.position + view_rect.end)/2.0
	
	## set zoom so that view_rect is just contained in the camera view
	var view_size = get_tree().get_root().get_size()
	var zoom_factor = max(view_rect.size.x/view_size.x, view_rect.size.y/view_size.y)
	
	global_position = center
	zoom = zoom_factor*Vector2(1, 1)
	
	_snap_scroll_limits()
	_snap_zoom_limits()

func get_view():
	return get_point_view(global_position)

func set_view_smooth(view_rect, speed = 1.0):
	var cur_rect = get_view()
	if view_rect == cur_rect: return

	if _anim_player.is_playing():
		_anim_player.stop()

	var view_anim = _anim_player.get_animation("SetViewSmooth")
	var track_idx = view_anim.find_track(".:view_rect")
	view_anim.track_set_key_value(track_idx, 0, cur_rect)
	view_anim.track_set_key_value(track_idx, 1, view_rect)
	_anim_player.playback_speed = speed
	_anim_player.play("SetViewSmooth")

	yield(_anim_player, "animation_finished")

	_anim_player.stop()

## gets the view rect that will center the camera at a specific position, with an optional zoom level
func get_point_view(center_pos, zoom_level = null):
	if !get_tree(): return null

	var view_size = get_tree().get_root().get_size() * (zoom_level * Vector2(1,1) if zoom_level else zoom)
	return Rect2(center_pos - view_size/2, view_size)

var _mouse_captured = false
func _unhandled_input(event):
	# mousewheel zoom
	if event is InputEventMouseButton:
		if event.is_action_pressed("view_zoom_in"):
			zoom /= 1 + zoom_step
			_snap_zoom_limits()
		if event.is_action_pressed("view_zoom_out"):
			zoom *= 1 + zoom_step
			_snap_zoom_limits()
	
	if event.is_action_pressed("view_pan_mouse"):
		_mouse_captured = true
	elif event.is_action_released("view_pan_mouse"):
		_mouse_captured = false

	if _mouse_captured && event is InputEventMouseMotion:
		position -= event.relative * zoom #opposite to relative motion, like we're grabbing the map
		_snap_scroll_limits()

func _process(delta):
	#smooth keyboard zoom
	if Input.is_action_pressed("view_zoom_in"):
		zoom /= 1 + zoom_step * delta * 10
		_snap_zoom_limits()
	if Input.is_action_pressed("view_zoom_out"):
		zoom *= 1 + zoom_step * delta * 10
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
		_snap_scroll_limits()

func _snap_scroll_limits():
	if !limit_rect: return
	
	var screen = get_viewport().get_visible_rect()
	var width = screen.size.x * zoom.x
	var height = screen.size.y * zoom.y
	position.x = clamp(position.x, limit_rect.position.x + width/2, limit_rect.end.x - width/2)
	position.y = clamp(position.y, limit_rect.position.y + height/2, limit_rect.end.y - height/2)

func _snap_zoom_limits():
	if !limit_rect: return
	
	#ensure zoom cannot make screen larger than limit_rect
	var screen = get_viewport().get_visible_rect()
	var size_limit = min(limit_rect.size.x/screen.size.x, limit_rect.size.y/screen.size.y)
	var max_zoom_limit = min(size_limit, max_zoom)
	zoom.x = clamp(zoom.x, min_zoom, max_zoom_limit)
	zoom.y = clamp(zoom.y, min_zoom, max_zoom_limit)

func set_limit_rect(rect):
	limit_rect = rect
	
	limit_left = rect.position.x
	limit_top = rect.position.y
	limit_right = rect.end.x
	limit_bottom = rect.end.y
	_snap_scroll_limits()
	_snap_zoom_limits()

func set_current(active):
	current = active
	set_process(active)
	set_process_unhandled_input(active)
