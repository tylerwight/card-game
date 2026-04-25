extends Resource
class_name CardEffects

class CardEffect:
	extends Resource
	
	var encounter:
		get:
			return Main.get_tree().get_first_node_in_group("encounter")
	
	func get_cost(card: NodeCard, _player: NodePlayer) -> int:
		return card.card_info.cost_mana
	
	func card_playable(card: NodeCard, player: NodePlayer,  _enemy: NodeEnemy) -> Dictionary:
		if player.mana < card.card_info.get_cost(card, player):
			return {"playable": false, "message": "NOT ENOUGH MANA"}
		return {"playable": true, "message": ""}
	
	func cast(_card: NodeCard, _player: NodePlayer,  _enemy: NodeEnemy) -> void:
		# override in subclasses
		pass
	
	func upgrade(_card: CardDB.CardData) -> void:
		pass
		
	func end(card: NodeCard, _player: NodePlayer,  _enemy: NodeEnemy) -> void:
		print("ending card: ", card.card_info.name)
		if card.card_info.discard_to_exhuast == true:
			card.exhaust()
		else:
			card.discard()
			




class EffectAttack:
	extends CardEffect
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		enemy.damage_melee(card.card_info.damage_actual)
		
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
	
	func upgrade(card: CardDB.CardData) -> void:
		if card.upgraded:
			return
		card.damage_melee = 18
		card.upgraded = true
		card.name = "[color=green]" + card.name + "+[/color]"	

class EffectInflame:
	extends CardEffect
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		player.apply_strength(card.card_info.strength)
		end(card, player, enemy)
		
	func upgrade(card: CardDB.CardData) -> void:
		if card.upgraded:
			return
		card.strength = 3
		card.upgraded = true
		card.name = "[color=green]" + card.name + "+[/color]"	


class EffectCleave:
	extends CardEffect
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		print("attacking all enemies")
		for enem in encounter.enemies:
			enem.damage_melee(card.card_info.damage_actual)
			print("Cleave hitting for: ", card.card_info.damage_actual)
		
		end(card, player, enemy)
		
	func upgrade(card: CardDB.CardData) -> void:
		if card.upgraded:
			return
		card.damage_melee = 11
		card.upgraded = true
		card.name = "[color=green]" + card.name + "+[/color]"	 
		
		
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
		
	func upgrade(card: CardDB.CardData) -> void:
		if card.upgraded:
			return
		card.strength = 4
		card.upgraded = true
		card.name = "[color=green]" + card.name + "+[/color]"	
		
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
		
	func upgrade(card: CardDB.CardData) -> void:
		if card.upgraded:
			return
		card.cost_mana = 0
		card.upgraded = true
		card.name = "[color=green]" + card.name + "+[/color]"

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
					var removed = encounter.deck_hand.discard.remove_card(crd)
					if not removed:
						print("FAILED TO REMOVE CARD?!?!")
				
		
		encounter.deck_hand.print_status()
		end(card, player, enemy)

	func upgrade(card: CardDB.CardData) -> void:
		if card.upgraded:
			return
		card.damage_melee = 12
		card.upgraded = true
		card.name = "[color=green]" + card.name + "+[/color]"	


class EffectHeavyblade:
	extends CardEffect
	var str_mul = 2
	
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		var strength = 0
		for effect in player.player_effects:
			if effect is PlayerEffects.StrengthEffect:
				strength = effect.strength
		
		var extra_damage = strength * str_mul
		
		print("extra damage: ", extra_damage, "   damage actual: ", card.card_info.damage_actual)
		enemy.damage_melee(card.card_info.damage_actual + extra_damage)
		end(card, player, enemy)
	
	func upgrade(card: CardDB.CardData) -> void:
		if card.upgraded:
			return
		str_mul = 5
		card.upgraded = true
		card.name = "[color=green]" + card.name + "+[/color]"	


class EffectArmaments:
	extends CardEffect
	
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		if not enemy == null:
			print("WTF? Why was I sent an enemy")
		player.block_add(card.card_info.block_std)
		
		if not card.card_info.upgraded:
			if encounter.deck_hand.hand.cards.size() > 0:
				var picked_cards = await Main.create_card_picker(encounter.deck_hand.hand.cards.filter(func(c): return c != card.card_info), "Pick a card to upgrade", 1, false)
			

				for crd in picked_cards:
					if crd:
						crd.upgrade()
		else:
			for crd in encounter.deck_hand.hand.cards:
				if crd:
					crd.upgrade()
		
		await Main.get_tree().process_frame
		
		for crd in encounter.deck_hand.get_card_nodes():
			crd._update_desc_label(crd.card_info.get_description(), crd.card_info.name)
			crd._update_cost_label()
		await Main.get_tree().process_frame
		end(card, player, enemy)
		
	func upgrade(card: CardDB.CardData) -> void:
		if card.upgraded:
			return
		card.description = "Gain ~blk~ block. Upgrade ALL cards in your hand for the rest of combat."
		card.dynamic_desc = "Gain ~blk~ block. Upgrade ALL cards in your hand for the rest of combat."
		card.upgraded = true
		card.name = "[color=green]" + card.name + "+[/color]"


class EffectIronwave:
	extends CardEffect
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		player.block_add(card.card_info.block_std)
		enemy.damage_melee(card.card_info.damage_actual)
		
		end(card, player, enemy)
		
	func upgrade(card: CardDB.CardData) -> void:
		if card.upgraded:
			return
		card.block_std = 7
		card.damage_melee = 7
		card.upgraded = true
		card.name = "[color=green]" + card.name + "+[/color]"

class EffectPerfectedstrike:
	extends CardEffect
	var strike_dmg = 2
	
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		var extra_damage = 0
		
		for crd in encounter.deck_hand.deck.cards:
			if crd.name.to_lower().contains("strike"):
				extra_damage += strike_dmg
		for crd in encounter.deck_hand.hand.cards:
			if crd.name.to_lower().contains("strike"):
				extra_damage += strike_dmg				
		for crd in encounter.deck_hand.discard.cards:
			if crd.name.to_lower().contains("strike"):
				extra_damage += strike_dmg					
			
		print("PERFECTED STRIKE DOING: ", card.card_info.damage_actual, " + xtra:", extra_damage )
		enemy.damage_melee(card.card_info.damage_actual + extra_damage)
		
		end(card, player, enemy)
	
	func upgrade(card: CardDB.CardData) -> void:
		if card.upgraded:
			return
		strike_dmg = 3
		card.upgraded = true
		card.name = "[color=green]" + card.name + "+[/color]"

class EffectPommelstrike:
	extends CardEffect
	var draw = 1
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		enemy.damage_melee(card.card_info.damage_actual)
		
		encounter.deck_hand.draw_hand(false, draw)
		end(card, player, enemy)
		encounter.deck_hand.render_hand()
	
	func upgrade(card: CardDB.CardData) -> void:
		if card.upgraded:
			return
		card.damage_melee = 10
		draw = 2
		card.upgraded = true
		card.name = "[color=green]" + card.name + "+[/color]"
		

class EffectShrugitoff:
	extends CardEffect
	var draw = 1
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		player.block_add(card.card_info.block_std)
		
		encounter.deck_hand.draw_hand(false, draw)
		end(card, player, enemy)
		encounter.deck_hand.render_hand()
	
	func upgrade(card: CardDB.CardData) -> void:
		if card.upgraded:
			return
		card.block_std = 11
		card.upgraded = true
		card.name = "[color=green]" + card.name + "+[/color]"
		
		
class EffectSwordboomerang:
	extends CardEffect
	var times = 3
	
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		for time in times:
			enemy.damage_melee(card.card_info.damage_actual)
		end(card, player, enemy)

	
	func upgrade(card: CardDB.CardData) -> void:
		if card.upgraded:
			return
		times = 4
		card.upgraded = true
		card.name = "[color=green]" + card.name + "+[/color]"

class EffectThunderclap:
	extends CardEffect
	
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		for enem in encounter.enemies:
			enem.damage_melee(card.card_info.damage_actual)
			enem.apply_vulnerable(card.card_info.vulnerable)
		end(card, player, enemy)

	
	func upgrade(card: CardDB.CardData) -> void:
		if card.upgraded:
			return
		card.damage_melee = 7
		card.upgraded = true
		card.name = "[color=green]" + card.name + "+[/color]"

class EffectTruegrit:
	extends CardEffect
	
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		player.block_add(card.card_info.block_std)
		
		if not card.card_info.upgraded:
			var hand = encounter.deck_hand.get_card_nodes().filter(func(c): return c != card)
			if hand.size() > 0:
				hand.pick_random().exhaust()
		else:
			var picked_cards = null
			if encounter.deck_hand.hand.cards.size() > 0:
				picked_cards = await Main.create_card_picker(encounter.deck_hand.hand.cards.filter(func(c): return c != card.card_info), "Pick a card to exhaust", 1, false)
			
			for crd in picked_cards:
				if crd:
					var card_node = crd.get_node(encounter)
					if card_node:
						card_node.exhaust()
			
		end(card, player, enemy)

	
	func upgrade(card: CardDB.CardData) -> void:
		if card.upgraded:
			return
		card.block_std = 9
		card.upgraded = true
		card.name = "[color=green]" + card.name + "+[/color]"

class EffectTwinstrike:
	extends CardEffect
	var times = 2
	
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		for time in times:
			enemy.damage_melee(card.card_info.damage_actual)
		end(card, player, enemy)

	
	func upgrade(card: CardDB.CardData) -> void:
		if card.upgraded:
			return
		card.damage_melee = 7
		card.upgraded = true
		card.name = "[color=green]" + card.name + "+[/color]"

class EffectWarcry:
	extends CardEffect
	var draw = 1
	
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		encounter.deck_hand.draw_hand(false, draw)
		
		end(card, player, enemy)
		encounter.deck_hand.render_hand()
		
		if encounter.deck_hand.discard.cards.size() > 0:
			var picked_cards: Array[CardDB.CardData] = await Main.create_card_picker(encounter.deck_hand.hand.cards, "Pick a card to add to top of deck", 1, false)
		
			for crd in picked_cards:
				if crd:
					var card_node: NodeCard = crd.get_node(encounter)
					card_node.move_to_top_of_draw_pile()
				
		
		encounter.deck_hand.print_status()

	func upgrade(card: CardDB.CardData) -> void:
		if card.upgraded:
			return
		draw = 2
		card.upgraded = true
		card.name = "[color=green]" + card.name + "+[/color]"	
		
	func end(card: NodeCard, _player: NodePlayer,  _enemy: NodeEnemy) -> void:
		card.exhaust()

class EffectWound:
	extends CardEffect
	
	func card_playable(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> Dictionary:
		return {"playable": false, "message": "WOUNDS ARE NOT PLAYABLE"}
			
class EffectWildstrike:
	extends CardEffect
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		enemy.damage_melee(card.card_info.damage_actual)
		var tmp_card: CardDB.CardData = CardDB.get_card("wound")
		encounter.deck_hand.deck.add_card_to_deck_random(tmp_card)
		end(card, player, enemy)
	
	func upgrade(card: CardDB.CardData) -> void:
		if card.upgraded:
			return
		card.damage_melee = 17
		card.upgraded = true
		card.name = "[color=green]" + card.name + "+[/color]"
	

class EffectBattletrance:
	extends CardEffect
	var draw = 3
	
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		encounter.deck_hand.draw_hand(false, draw)
		
		
		var found_trance = false
	
		for effect in player.player_effects:
			if effect is PlayerEffects.BattleTranceEffect:
				found_trance = true
		
		if found_trance == false:
			var tmp = PlayerEffects.BattleTranceEffect.new()
			player.player_effects.append(tmp)		
		
		end(card, player, enemy)
		encounter.deck_hand.render_hand()
	
	func upgrade(card: CardDB.CardData) -> void:
		if card.upgraded:
			return
		draw = 4
		card.upgraded = true
		card.name = "[color=green]" + card.name + "+[/color]"
		card.description = "Draw [color=green]4[/color] cards. You cannot draw additional cards this turn."
		card.dynamic_desc = "Draw [color=green]4[/color] cards. You cannot draw additional cards this turn."


class EffectBloodForBlood:
	extends CardEffect
	
	func get_cost(card: NodeCard, player: NodePlayer) -> int:
		var result = card.card_info.cost_mana - player.hp_loss_count
		if result < 0: result = 0
		return result
	
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		enemy.damage_melee(card.card_info.damage_actual)
		print("Hit ", enemy.name, " for ", card.card_info.damage_actual)
		end(card, player, enemy)
	
	func upgrade(card: CardDB.CardData) -> void:
		if card.upgraded:
			return
		card.damage_melee = 22
		card.upgraded = true
		card.name = "[color=green]" + card.name + "+[/color]"	


class EffectBloodletting:
	extends CardEffect
	var hp_loss = 3
	var mana_gain = 2
	
	
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		player.remove_hp(hp_loss) 
		player.mana += mana_gain
		end(card, player, enemy)
	
	func upgrade(card: CardDB.CardData) -> void:
		if card.upgraded:
			return
		mana_gain = 3
		card.upgraded = true
		card.name = "[color=green]" + card.name + "+[/color]"	
		card.description = "Lose 3 HP. Gain 3 Energy."
		card.dynamic_desc = "Lose 3 HP. Gain 3 Energy."

class EffectBurningpact:
	extends CardEffect
	var draw = 2
	
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		encounter.deck_hand.print_status()
		var picked_cards = null
		if encounter.deck_hand.hand.cards.size() > 0:
			picked_cards = await Main.create_card_picker(encounter.deck_hand.hand.cards.filter(func(c): return c != card.card_info), "Pick a card to exhaust", 1, false)
		
		for crd in picked_cards:
			if crd:
				var card_node = crd.get_node(encounter)
				if card_node:
					card_node.exhaust()
					
		
		encounter.deck_hand.draw_hand(false, draw)
		end(card, player, enemy)
		
		encounter.deck_hand.render_hand()
	
	func upgrade(card: CardDB.CardData) -> void:
		if card.upgraded:
			return
		draw = 3
		card.upgraded = true
		card.name = "[color=green]" + card.name + "+[/color]"	
		card.description = "Exhaust 1 card. Draw 3 cards."
		card.dynamic_desc = "Exhaust 1 card. Draw 3 cards."


class EffectCarnage:
	extends CardEffect
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
		enemy.damage_melee(card.card_info.damage_actual)
		
		end(card, player, enemy)
	
	func upgrade(card: CardDB.CardData) -> void:
		if card.upgraded:
			return
		card.damage_melee = 28
		card.upgraded = true
		card.name = "[color=green]" + card.name + "+[/color]"


class EffectCombust:
	extends CardEffect
	var hp_loss = 1
	var dmg = 5
	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
	
		var tmp = PlayerEffects.CombustEffect.new()
		tmp.hp_loss = hp_loss
		tmp.damage = dmg
		player.player_effects.append(tmp)
		
		end(card, player, enemy)
		
	func upgrade(card: CardDB.CardData) -> void:
		if card.upgraded:
			return
		dmg = 7
		card.upgraded = true
		card.name = "[color=green]" + card.name + "+[/color]"	


class EffectDarkembrace:
	extends CardEffect

	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
	
		var tmp = PlayerEffects.DarkembraceEffect.new()

		player.player_effects.append(tmp)
		
		end(card, player, enemy)
		
	func upgrade(card: CardDB.CardData) -> void:
		if card.upgraded:
			return
		card.cost_mana = 1
		card.upgraded = true
		card.name = "[color=green]" + card.name + "+[/color]"	


class EffectDisarm:
	extends CardEffect

	func cast(card: NodeCard, player: NodePlayer,  enemy: NodeEnemy) -> void:
	
		enemy.apply_strength(card.card_info.strength)
		
		
		end(card, player, enemy)
		
	func upgrade(card: CardDB.CardData) -> void:
		if card.upgraded:
			return
		card.strength = -3
		card.upgraded = true
		card.name = "[color=green]" + card.name + "+[/color]"	
