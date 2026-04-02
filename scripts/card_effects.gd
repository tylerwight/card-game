extends Resource
class_name CardEffects

class CardEffect:
	extends Resource
	
	var encounter:
		get:
			return Main.get_tree().get_first_node_in_group("encounter")
	
	func card_playable(card: NodeCard, player: NodePlayer,  _enemy: NodeEnemy) -> Dictionary:
		if player.mana < card.card_info.cost_mana:
			return {"playable": false, "message": "NOT ENOUGH MANA"}
		return {"playable": true, "message": ""}
	
	func cast(_card: NodeCard, _player: NodePlayer,  _enemy: NodeEnemy) -> void:
		# override in subclasses
		pass
	
	func upgrade(_card: CardDB.CardData) -> void:
		pass
		
	func end(card: NodeCard, _player: NodePlayer,  _enemy: NodeEnemy) -> void:
		if card.card_info.discard_to_exhuast == true:
			card.exhaust()
		else:
			card.discard()
			




class EffectAttack:
	extends CardEffect
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		print("casting ATTACK, attempting to hit for: ", card.card_info.damage_actual)
		enemy.damage_melee(card.card_info.damage_actual)
		print("Hit ", enemy.name, " for ", card.card_info.damage_actual)
		
		end(card, player, enemy)
	
	func upgrade(card: CardDB.CardData) -> void:
		if card.upgraded:
			return
		card.damage_melee = 9
		card.upgraded = true
		card.name = "[color=green]" + card.name + "+[/color]"
		

class EffectDefend:
	extends CardEffect
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		if not enemy == null:
			print("WTF? Why was I sent an enemy")
		player.block_add(card.card_info.block_std)
		print("Gave ", card.card_info.block_std, " block to ", player.player_name)
		
		end(card, player, enemy)
		
	func upgrade(card: CardDB.CardData) -> void:
		if card.upgraded:
			return
		card.block_std = 8
		card.upgraded = true
		card.name = "[color=green]" + card.name + "+[/color]"
		
class EffectBash:
	extends CardEffect
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		enemy.damage_melee(card.card_info.damage_actual)
		enemy.apply_vulnerable(card.card_info.vulnerable)
		print("Dealt damage:", card.card_info.damage_actual, " applied vuln:", card.card_info.vulnerable)
		end(card, player, enemy)
		
	func upgrade(card: CardDB.CardData) -> void:
		if card.upgraded:
			return
		card.damage_melee = 10
		card.vulnerable = 3
		card.upgraded = true
		card.name = "[color=green]" + card.name + "+[/color]"
		
class EffectAnger:
	extends CardEffect
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		var encounter: NodeEncounter = player.get_tree().get_first_node_in_group("encounter")
		enemy.damage_melee(card.card_info.damage_actual)
		encounter.deck_hand.discard.add_card_to_deck(card.card_info.duplicate())
		end(card, player, enemy)
		
	func upgrade(card: CardDB.CardData) -> void:
		if card.upgraded:
			return
		card.damage_melee = 8
		card.upgraded = true
		card.name = "[color=green]" + card.name + "+[/color]"
		
class EffectBodySlam:
	extends CardEffect
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		enemy.damage_melee(player.block)
		end(card, player, enemy)
		
	func upgrade(card: CardDB.CardData) -> void:
		if card.upgraded:
			return
		card.cost_mana = 0
		card.upgraded = true
		card.name = "[color=green]" + card.name + "+[/color]"


class EffectClothesline:
	extends CardEffect
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		enemy.damage_melee(card.card_info.damage_actual)
		enemy.apply_weak(card.card_info.weak)
		end(card, player, enemy)
		
	func upgrade(card: CardDB.CardData) -> void:
		if card.upgraded:
			return
		card.damage_melee = 14
		card.weak = 3
		card.upgraded = true
		card.name = "[color=green]" + card.name + "+[/color]"	

class EffectClash:
	extends CardEffect
	
	func card_playable(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> Dictionary:
		if player.mana < card.card_info.cost_mana:
			return {"playable": false, "message": "NOT ENOUGH MANA"}
		
		var hand = encounter.deck_hand.hand.cards
		var only_attacks = true
		
		for h_card in hand:
			print("searching card: ", h_card.name, "  Type found: ", h_card.type)
			if h_card.type != "attack":
				only_attacks = false
		
		if only_attacks == false:
			return {"playable": false, "message": "CARD REQUIRES ONLY ATTACKS IN HAND"}
			
		return {"playable": true, "message": ""}
	
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		print("Encounter:", encounter.title)
		enemy.damage_melee(card.card_info.damage_actual)
		print("Hit ", enemy.name, " for ", card.card_info.damage_actual)
		end(card, player, enemy)


class EffectInflame:
	extends CardEffect
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		player.apply_strength(card.card_info.strength)
		end(card, player, enemy)


class EffectCleave:
	extends CardEffect
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		print("attacking all enemies")
		for enem in encounter.enemies:
			enem.damage_melee(card.card_info.damage_actual)
			print("Cleave hitting for: ", card.card_info.damage_actual)
		
		end(card, player, enemy)

class EffectFlex:
	extends CardEffect
	
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		player.apply_strength(card.card_info.strength)
		
		var found_flx = false
	
		for effect in player.player_effects:
			if effect is PlayerEffects.FlexEffect:
				effect.flxstrength += card.card_info.strength
				found_flx = true
		
		if found_flx == false:
			var tmp = PlayerEffects.FlexEffect.new()
			tmp.flxstrength += card.card_info.strength
			player.player_effects.append(tmp)
		
		end(card, player, enemy)
		
		
class EffectHavoc:
	extends CardEffect
	
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		var deck = encounter.deck_hand.deck
		
		if deck.cards.size() == 0:
			print("shuffling discard")
			encounter.deck_hand.shuffle_discard()
		
		var topdeck = deck.pull_card_from_deck()
		
		if topdeck: 
			await encounter.spawn_and_play_card(topdeck)
			
		end(card, player, enemy)


class EffectHeadbutt:
	extends CardEffect
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		encounter.deck_hand.print_status()
		enemy.damage_melee(card.card_info.damage_actual)

		if encounter.deck_hand.discard.cards.size() > 0:
			var picked_cards = await Main.create_card_picker(encounter.deck_hand.discard.cards, "Pick a card to add to top of deck", 1, false)
		
			for crd in picked_cards:
				if crd:
					encounter.deck_hand.deck.add_card_to_deck_front(crd)
					encounter.deck_hand.discard.cards.erase(crd)
				
		
		encounter.deck_hand.print_status()
		end(card, player, enemy)

class EffectHeavyblade:
	extends CardEffect
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		var strength = 0
		for effect in player.player_effects:
			if effect is PlayerEffects.StrengthEffect:
				strength = effect.strength
		
		var extra_damage = strength * 2
		
		print("extra damage: ", extra_damage, "   damage actual: ", card.card_info.damage_actual)
		enemy.damage_melee(card.card_info.damage_actual + extra_damage)
		end(card, player, enemy)
