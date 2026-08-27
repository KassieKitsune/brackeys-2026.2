extends AreaBoid
class_name MouseFollowingAreaBoid
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	bias_to = global_position.direction_to(get_global_mouse_position())
	bias = global_position.distance_to(get_global_mouse_position())/180
	super(delta)
	pass
