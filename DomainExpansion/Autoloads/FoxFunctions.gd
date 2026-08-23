extends Node

#just some helper functions for common calculations etc.

func power_delta(base,scale = 0,delta = get_process_delta_time()):
	return pow(base,delta*scale)

func choose(list : Array):
	var max = list.size()-1
	var roll = randi_range(0,max)
	return list[roll]

func mean(list : Array): #Finds Mean of Ints, Floats, and Vectors
	var sum
	var av
	var size = list.size()
	
	if list[0] is float || list[0] is int:
		
		sum = 0.0
	elif list[0] is Vector2 || list[0] is Vector2i :
		sum = Vector2.ZERO
	elif list[0] is Vector3 || list[0] is Vector3i :
		sum = Vector3.ZERO
	else:
		return null
	
	if list[0] is int:
		for i in list :
			sum += float(i)
	elif list[0] is Vector2i:
		for i in list :
			sum += Vector2(i)
	elif list[0] is Vector3i:
		for i in list :
			sum += Vector3(i)
	else :
		for i in list :
			sum += i
		
	av = sum/float(size)
	
	return av
