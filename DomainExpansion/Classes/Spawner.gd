extends Node2D
class_name ObjectSpawner

@export var scene:PackedScene
@export var use_pooling:bool
@export var pool_size:int = 10

var pool:Array[Node] = []

func _ready() -> void:
	if use_pooling:
		for i in pool_size:
			pool.append(scene.instantiate())

func spawn(object : PackedScene = scene):
	var sp_object:Node 
	
	if use_pooling:
		for i in pool:
			if !i.is_inside_tree():
				sp_object = i
				sp_object.global_position = global_position
				get_tree().current_scene.add_child(sp_object)
				return sp_object
		return null
	for g in get_groups():
		sp_object.add_to_group(g)
	sp_object = object.instantiate()
	sp_object.global_position = global_position
	get_tree().current_scene.add_child(sp_object)
	return sp_object
