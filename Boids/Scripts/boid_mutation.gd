extends Resource
class_name Mutation

@export var coherence : float = 1
@export var separation : float = 1
@export var alignment : float = 1

@export var bias_to : Vector2 = Vector2.ZERO # BiasDirection
@export var bias : float = 0 # Strength of Bias

@export var max_speed : float = 200
@export var accelleration : float = 50
@export var direction : Vector2 = Vector2.ZERO
@export var turning_radius : float = PI/2
