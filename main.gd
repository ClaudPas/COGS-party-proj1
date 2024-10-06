extends Node2D

func spawn_bullet():
	var new_bullet = preload("res://bullet.tscn").instantiate()
	%PathFollow2D.progress_ratio = randf()
	new_bullet.global_position = %PathFollow2D.global_position
	add_child(new_bullet)
	
func _on_timer_timeout():
		spawn_bullet()
	
	
	
