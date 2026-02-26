extends Resource
class_name EnemyBehaviors

class EnemyBehavior:
	extends Resource
	func randomize():
		pass
		
	func take_turn(player: NodePlayer,  enemy: NodeEnemy) -> void:
		pass
		
	func end_turn(enemy: NodeEnemy) -> void:
		if enemy.stats.vulnerable > 0:
			enemy.stats.vulnerable -= 1
		
		
class BehaviorGoodboy:
	extends EnemyBehavior
	var base_damage: int = 5
	var damage_variance: int = 3
	@export var actual_damage: int = base_damage
	
	func randomize():
		actual_damage = randi_range(base_damage - damage_variance, base_damage + damage_variance)
	
	func take_turn(player: NodePlayer,  enemy: NodeEnemy) -> void:
		player.damage(actual_damage)
		print("Hit ", player.player_name, " for ", actual_damage)
		end_turn(enemy)
		
		
		
class BehaviorBadboy:
	extends EnemyBehavior
	var base_damage: int = 5
	var damage_variance: int = 3
	@export var actual_damage: int = base_damage
	
	func randomize():
		actual_damage = randi_range(base_damage - damage_variance, base_damage + damage_variance)
	
	func take_turn(player: NodePlayer,  enemy: NodeEnemy) -> void:
		player.damage(actual_damage)
		print("Hit ", player.player_name, " for ", actual_damage)
		end_turn(enemy)
