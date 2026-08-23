extends Area2D
class_name HitDetector

enum MODE {HIT,HURT,BOTH}
enum TARGET_MODE{EXCLUDE,INCLUDE}
signal hit(area,direction,damage,impact)

@export var mode : MODE

@export_category("Combat Statistics")
@export var damage : int = 0
@export var impact : int = 0

@export_category("Group Selection")
@export var selection_mode : TARGET_MODE
@export var groups : Array[String]

func _ready():
	area_entered.connect(_on_area_entered)
	if owner != null:
		for g in owner.get_groups():
			add_to_group(g)
	#match mode:
		#MODE.HURT:
			#monitorable = true
			#monitoring = true
		#MODE.HIT:
			#monitorable = true
			#monitoring = false
		#MODE.BOTH:
			#monitorable = true
			#monitoring = false

func _on_area_entered(area:Area2D):
	var direction = global_position.direction_to(area.global_position)
	var e_damage = damage
	var e_impact = impact
	if area is HitDetector:
		if area.mode == mode && mode != MODE.BOTH:
			return null
		
		match selection_mode :
			TARGET_MODE.EXCLUDE:
				for group in groups :
					if area.is_in_group(group):
						return null
			TARGET_MODE.INCLUDE :
				var has = false
				for group in groups :
					if area.is_in_group(group):
						has = true
				if !has:
					return
				pass
		match mode :
			MODE.HURT :
				e_damage = area.damage
				e_impact = area.impact
			MODE.BOTH :
				e_damage = area.damage
				e_impact = area.impact
		
		hit.emit(area,direction,e_damage,e_impact)
		if !area.monitoring :
			area.hit.emit(self,-direction,damage,impact)
