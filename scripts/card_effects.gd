extends Resource
class_name CardEffects

class CardEffect:
	extends Resource
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		# override in subclasses
		pass


class EffectAttack:
	extends CardEffect
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		enemy.damage_melee(card.card_info.damage_melee)
		print("Hit ", enemy.name, " for ", card.card_info.damage_melee)
		end(card, player, enemy)
		
	func end(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		card.discard()
		


class EffectDefend:
	extends CardEffect
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		if not enemy == null:
			print("WTF? Why was I sent an enemy")
		player.block_add(card.card_info.block_std)
		print("Gave ", card.card_info.block_std, " block to ", player.player_name)
		
		end(card, player, enemy)
	func end(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		card.discard()
		
		
class EffectBash:
	extends CardEffect
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		enemy.damage_melee(card.damage_melee)
		enemy.apply_vulnerable(card.vulnerable)
		
		print("Gave ", card.block_std, " block to ", player.player_name)
		
	func end(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		card.discard()
		
