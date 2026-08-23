extends Node2D
class_name projectile

@export var velocity = Vector2.ZERO
@export var decelleration = 0

func _process(delta):
	_move(delta)
	pass

func _move(delta):
	if velocity != Vector2.ZERO:
		rotation = velocity.angle()
	global_position += velocity*delta
	velocity -= velocity*delta*decelleration
	return
