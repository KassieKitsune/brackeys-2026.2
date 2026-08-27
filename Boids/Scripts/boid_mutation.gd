extends Resource
class_name BoidCharacteristics

@export var color : Color = Color.WHITE

@export var coherence : float = 1
@export var separation : float = 0.2
@export var alignment : float = 1

@export var vision_radius : float = 180
@export var protected_radius : float = 30

@export var bias_to : Vector2 = Vector2.ZERO # BiasDirection
@export var bias : float = 0 # Strength of Bias

@export var max_speed : float = 50
@export var accelleration : float = 800
@export var turning_radius : float = PI/2
