extends Resource
class_name EnemyBehaviors

class EnemyBehavior:
	extends Resource
	var base_damage: int = 5
	var damage_variance: int = 3
	@export var actual_damage: int = base_damage
		
	func roll_intents(enemy: EnemyDB.EnemyData):
		actual_damage = randi_range(base_damage - damage_variance, base_damage + damage_variance)
		for effect in enemy.player_effects:
			effect.process_attacking_enemy(null, enemy.node)
		
	func refresh_effects_attack(enemy: EnemyDB.EnemyData) -> void:
		for effect in enemy.player_effects:
			effect.process_attacking_enemy(null, enemy.node)
		
	func take_turn(player: NodePlayer,  enemy: NodeEnemy) -> void:
		pass
		
	func end_turn(enemy: NodeEnemy) -> void:
		pass
		
		
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
