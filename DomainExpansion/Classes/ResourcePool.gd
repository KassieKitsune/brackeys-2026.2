extends Node
class_name ResourcePool

@export var max : int
@export var current : int

signal zeroed
signal changed(ammount,current)

func add(ammount):
	current += ammount
	current = clamp(current,0,max)
	check_zeroed()
	changed.emit(ammount,current)
	pass

func subtract(ammount):
	add(-ammount)
	pass

func check_zeroed():
	if current <= 0 :
		zeroed.emit()
	pass
