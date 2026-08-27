extends Area2D
class_name AreaBoid

static var count : int = 0

var velocity : Vector2 = Vector2.ZERO
var flock: Array[AreaBoid] = []
var touching : Array [AreaBoid] = []
var mouse_hovered : bool = false

@onready var rays: Array[Node] = $Rays.get_children()
@onready var ray_0: RayCast2D = $Rays/Ray0
@onready var ray_1: RayCast2D = $Rays/Ray1
@onready var ray_2: RayCast2D = $Rays/ray2

@export var debug : bool = false
@export var direction : Vector2 = Vector2.ZERO
@export var characteristics : BoidCharacteristics

var flock_direction : Vector2 = Vector2.ZERO
var flock_center : Vector2 = Vector2.ZERO
var touch_center : Vector2 = Vector2.ZERO

var coherence : float
var separation : float
var alignment : float

var bias_to : Vector2 # BiasDirection
var bias : float  # Strength of Bias

var sep_dir : Vector2

var max_speed : float 
var accelleration : float 
var turning_radius : float
var process_frame : int 

signal selected

func _ready() -> void:
	coherence = characteristics.coherence
	separation = characteristics.separation
	alignment = characteristics.alignment

	bias_to = characteristics.bias_to # BiasDirection
	bias = characteristics.bias  # Strength of Bias

	max_speed = characteristics.max_speed
	accelleration = characteristics.accelleration
	turning_radius = characteristics.turning_radius
	
	$Sprite2D.modulate = characteristics.color
	
	flock.append(self)
	count += 1
	direction = Vector2.from_angle(randf_range(0,TAU))
	pass # Replace with function body.

func _process(delta: float) -> void:
	$Sprite2D.rotation = direction.angle()
	$Sprite2D.speed_scale = max(velocity.length()/max_speed,1.0)
	
	flock_center = get_flock_center()
	touch_center = get_touch_center()
	flock_direction = get_flock_direction()
	
	var target_direction = direction
	if flock.size() > 0 :
		target_direction += global_position.direction_to(flock_center)*coherence
		target_direction += flock_direction*alignment
	target_direction += bias_to*bias
	if touching.size() > 0 :
		for separation_direction in get_touch_directions():
			target_direction -= separation_direction*separation*PI
			#target_direction -= global_position.direction_to(touch_center)*separation
	
	direction = direction.move_toward(target_direction,delta*10)
	#direction = target_direction
	velocity = velocity.move_toward(direction*max_speed,accelleration*delta)
	
	var r : int = 0
	ray_0.target_position = direction*max_speed
	ray_1.target_position = direction.rotated(-PI/8)*max_speed
	ray_2.target_position = direction.rotated(+PI/8)*max_speed
	for ray_cast in rays:
		if ray_cast is RayCast2D:
			if ray_cast.is_colliding():
				direction -= global_position.direction_to(ray_cast.get_collision_point())
				break
		
	move(delta)
	queue_redraw()

func _draw():
	if mouse_hovered:
		draw_circle(Vector2.ZERO,16,Color.CRIMSON)
	if debug:
		draw_line(Vector2.ZERO,global_position-flock_center,Color.AQUA)

func get_flock_center() -> Vector2:
	var sum : Vector2 = Vector2.ZERO
	for n in flock:
		sum += n.global_position
	return sum/flock.size()

func get_flock_direction() -> Vector2:
	var sum : Vector2 = Vector2.ZERO
	for n in flock:
		sum += n.direction
	return sum/flock.size()

func get_touch_center() -> Vector2:
	var sum : Vector2 = Vector2.ZERO
	for n in touching:
		sum += n.global_position
	return sum/flock.size()

func get_touch_directions() -> Array[Vector2]:
	var dirs : Array[Vector2] = []
	for n in touching:
		dirs.append(global_position.direction_to(n.global_position))
	return dirs

func move(delta:float):
	global_position += velocity*delta

func apply_mutation(mutation:BoidCharacteristics):
	for prop in mutation.get_property_list():
		if prop["type"] == typeof(get(prop["name"])):
			set(prop["name"],mutation.prop)
	pass

func _on_vision_area_entered(area: Area2D) -> void:
	if area is AreaBoid:
		flock.append(area)
		area.tree_exiting.connect(_on_flock_leave.bind(area))

func _on_vision_area_exited(area: Area2D) -> void:
	if area is AreaBoid:
		_on_flock_leave(area)

func _on_area_entered(area: Area2D) -> void:
	if area is AreaBoid:
		touching.append(area)
		area.tree_exiting.connect(_on_touch_leave.bind(area))

func _on_area_exited(area: Area2D) -> void:
	if area is AreaBoid:
		_on_touch_leave(area)

func _on_flock_leave(neighbour:AreaBoid):
	if flock.has(neighbour):
		flock.erase(neighbour)
	neighbour.tree_exiting.disconnect(_on_flock_leave.bind(neighbour))

func _on_touch_leave(neighbour:AreaBoid):
	if touching.has(neighbour):
		touching.erase(neighbour)
	neighbour.tree_exiting.disconnect(_on_touch_leave.bind(neighbour))

func _on_collider_body_entered(body: Node2D) -> void:
	velocity = -velocity
	pass # Replace with function body.


func _on_mouse_entered() -> void:
	mouse_hovered = true
	pass # Replace with function body.


func _on_mouse_exited() -> void:
	mouse_hovered = false
	pass # Replace with function body.

func _exit_tree() -> void:
	count -= 1
