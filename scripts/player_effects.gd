extends Resource
class_name PlayerEffects

class PlayerEffect:
	extends Resource
	var type: String = "default"
	var deleteme: bool = false
	func print() -> String:
		return "PlayerEffect(type:%s)" % type
	func process_attacking_player(_encounter: NodeEncounter, _card: NodeCard) -> void:
		pass
	func process_attacking_enemy(_encounter: NodeEncounter, _enemy: NodeEnemy) -> void:
		pass
	func process_attacked_player(_encounter: NodeEncounter, _damage: Dictionary) -> void:
		pass
	func process_attacked_enemy(_encounter: NodeEncounter, _enemy: NodeEnemy, _damage: Dictionary) -> void:
		pass
	func process_end_player(_encounter: NodeEncounter, _card: NodeCard) -> void:
		pass
	func process_end_enemy(_encounter: NodeEncounter) -> void:
		pass
	func process_draw_player(_encounter: NodeEncounter, drawcount: int) -> int:
		return drawcount
	func process_exhaust_player(_encounter: NodeEncounter) -> void:
		pass




class WeakEffect:
	extends PlayerEffect
	func _init():
		type = "attacking"
	var weak = 0
	func print() -> String:
		return "PlayerEffect(weak:%s)" % weak
		
	func process_attacking_player(_encounter: NodeEncounter, card: NodeCard) -> void:
		print("processing weak, weak is: ", weak)
		if weak > 0:
			card.card_info.damage_actual = int(card.card_info.damage_actual * 0.75)
			
	func process_attacking_enemy(_encounter: NodeEncounter, enemy: NodeEnemy) -> void:
		print("APPLYING WEAK TO enemy damage\n before:", enemy.stats.behavior.actual_damage)
		if weak > 0:
			enemy.stats.behavior.actual_damage = int(enemy.stats.behavior.actual_damage * 0.75)
		print("AFTER:", enemy.stats.behavior.actual_damage)
		
	func process_end_player(_encounter: NodeEncounter, _card: NodeCard) -> void:
		print("current weak: ", weak)
		weak -= 1
		if weak < 1:
			deleteme = true
		print("After: ", weak)
		
	func process_end_enemy(_encounter: NodeEncounter) -> void:
		print("current weak: ", weak)
		weak -= 1
		if weak < 1:
			deleteme = true
		print("After: ", weak)


class StrengthEffect:
	extends PlayerEffect
	func _init():
		type = "attacking"
	var strength = 0
	func print() -> String:
		return "PlayerEffect(strength:%s)" % strength
		
	func process_attacking_player(_encounter: NodeEncounter, card: NodeCard) -> void:
		print("processing str, str is: ", strength, " Final value: ", card.card_info.damage_actual + strength)
		card.card_info.damage_actual = card.card_info.damage_actual + strength
		
	func process_attacking_enemy(_encounter: NodeEncounter, enemy: NodeEnemy) -> void:
		print("Processing enemy str. Damage before: ", enemy.stats.behavior.actual_damage)
		enemy.stats.behavior.actual_damage = int(enemy.stats.behavior.actual_damage + strength)
		print("enemy str after: ", enemy.stats.behavior.actual_damage)
		
	func process_end_player(_encounter: NodeEncounter, _card: NodeCard) -> void:
		if strength == 0:
			deleteme = true
			
	func process_end_enemy(_encounter: NodeEncounter) -> void:
		if strength == 0:
			deleteme = true


class VulnerableEffect:
	extends PlayerEffect
	func _init():
		type = "attacked"
	var vulnerable = 0
	func print() -> String:
		return "PlayerEffect(vulnerable:%s)" % vulnerable
		
	func process_attacked_player(_encounter: NodeEncounter, damage: Dictionary) -> void:
		print("player has vulnerable: ", vulnerable, " upping dmg from ", damage["value"])
		if vulnerable > 0:
			damage["value"] = int(damage["value"] * 1.5)
		print("new damage = ", damage["value"])
		
	func process_attacked_enemy(_encounter: NodeEncounter, _enemy: NodeEnemy, damage: Dictionary) -> void:
		print("enemy has vulnerable: ", vulnerable, " upping dmg from ", damage["value"])
		if vulnerable > 0:
			damage["value"] = int(damage["value"] * 1.5)
		print("new damage = ", damage["value"])
		
	func process_end_player(_encounter: NodeEncounter, _card: NodeCard) -> void:
		vulnerable -= 1
		if vulnerable < 1:
			deleteme = true

	func process_end_enemy(_encounter: NodeEncounter) -> void:
		vulnerable -= 1
		if vulnerable < 1:
			deleteme = true


class FlexEffect:
	extends PlayerEffect
	var flxstrength = 0
	
	func print() -> String:
		return "PlayerEffect(flxstrength:%s)" % flxstrength
		
	func _init():
		type = "end"
	
	
	func process_end_player(encounter: NodeEncounter, _card: NodeCard) -> void:
		encounter.player.apply_strength(-flxstrength)
		flxstrength = 0
		
		
		
class BattleTranceEffect:
	extends PlayerEffect
	
	func print() -> String:
		return "PlayerEffect(BattleTrance)"
		
	func _init():
		type = "draw"
	
	
	func process_draw_player(_encounter: NodeEncounter, _drawcount: int) -> int:
		print("BATTLE TRANCE STOPPING DRAW")
		return 0
		
	func process_end_player(encounter: NodeEncounter, _card: NodeCard) -> void:
		deleteme = true


class CombustEffect:
	extends PlayerEffect
	var hp_loss = 1
	var damage = 5
	
	func print() -> String:
		return "PlayerEffect(Combust)"
		
	func _init():
		type = "end"
		
	func process_end_player(encounter: NodeEncounter, _card: NodeCard) -> void:
		encounter.player.remove_hp(hp_loss)
		for enemy in encounter.enemies:
			enemy.damage_melee(damage)


class DarkembraceEffect:
	extends PlayerEffect
	
	func print() -> String:
		return "PlayerEffect(Dark Embrace)"
		
	func _init():
		type = "end"
	func process_exhaust_player(encounter: NodeEncounter) -> void:
		print("DARK EMBRACE")
		encounter.deck_hand.draw_hand(false, 1)
		encounter.deck_hand.render_hand()
		
	
