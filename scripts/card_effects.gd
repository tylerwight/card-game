extends Resource
class_name CardEffects

class CardEffect:
	extends Resource

	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		# override in subclasses
		pass
		
	func end(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		card.discard()



class EffectAttack:
	extends CardEffect
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		enemy.damage_melee(card.card_info.damage_melee)
		print("Hit ", enemy.name, " for ", card.card_info.damage_melee)
		end(card, player, enemy)
		

class EffectDefend:
	extends CardEffect
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		if not enemy == null:
			print("WTF? Why was I sent an enemy")
		player.block_add(card.card_info.block_std)
		print("Gave ", card.card_info.block_std, " block to ", player.player_name)
		
		end(card, player, enemy)

		
class EffectBash:
	extends CardEffect
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		enemy.damage_melee(card.card_info.damage_melee)
		enemy.apply_vulnerable(card.card_info.vulnerable)
		print("Dealt damage:", card.card_info.damage_melee, " applied vuln:", card.card_info.vulnerable)
		end(card, player, enemy)
		
		
class EffectAnger:
	extends CardEffect
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		var encounter: NodeEncounter = player.get_tree().get_first_node_in_group("encounter")
		enemy.damage_melee(card.card_info.damage_melee)
		encounter.deck_hand.discard.add_card_to_deck(card.card_info.duplicate())
		end(card, player, enemy)
		
class EffectBodySlam:
	extends CardEffect
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		enemy.damage_melee(player.block)
		end(card, player, enemy)
		

		
