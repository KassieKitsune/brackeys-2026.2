extends ProgressBar

@export var pool : ResourcePool

func _ready():
	if pool != null:
		value = pool.current
		max_value = pool.max
		pool.changed.connect(on_pool_changed)
	pass # Replace with function body.

func on_pool_changed(ammount,current):
	value = current
