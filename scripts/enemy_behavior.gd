extends Resource
class_name EnemyBehaviors

class EnemyBehavior:
	extends Resource
	var base_damage: int = 5
	var damage_variance: int = 3
	@export var actual_damage: int = base_damage
		
	func roll_intents(enemy: EnemyDB.EnemyData):
		actual_damage = randi_range(base_damage - damage_variance, base_damage + damage_variance)
		if enemy.weak > 0:
			actual_damage = actual_damage * 0.75
		
	@warning_ignore("unused_parameter")
	func take_turn(player: NodePlayer,  enemy: NodeEnemy) -> void:
		pass
		
	func end_turn(enemy: NodeEnemy) -> void:
		if enemy.stats.vulnerable > 0:
			enemy.stats.vulnerable -= 1
		
		
class BehaviorGoodboy:
	extends EnemyBehavior
	
	#func randomize(enemy: NodeEnemy):
		#actual_damage = randi_range(base_damage - damage_variance, base_damage + damage_variance)
	
	func take_turn(player: NodePlayer,  enemy: NodeEnemy) -> void:
		player.damage(actual_damage)
		print("Hit ", player.player_name, " for ", actual_damage)
		end_turn(enemy)
		
		
		
class BehaviorBadboy:
	extends EnemyBehavior
	
	#func randomize(enemy: NodeEnemy):
		#actual_damage = randi_range(base_damage - damage_variance, base_damage + damage_variance)
	
	func take_turn(player: NodePlayer,  enemy: NodeEnemy) -> void:
		player.damage(actual_damage)
		print("Hit ", player.player_name, " for ", actual_damage)
		end_turn(enemy)
