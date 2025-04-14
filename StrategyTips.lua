
ClassStrategyCO = {};
ClassStrategyNC = {};

function InitializeStrategyPaladin()

	ClassStrategyCO = {
		--Roles
		[1] = {"tank","Tank","Bot will use Tank role and strategy."},
		[2] = {"dps","DPS","Bot will use Dps role and strategy."},		
		[3] = {"heal","Healer","Bot will use Healer role and strategy."},
		-- Roles addons
		[4] = {"bthreat","Righteous fury","Cast Righteous fury threat buff on self (use only for tanking)"},
		[5] = {"tank assist","Offtank","The bot will assist the tank in the group."},
		[6] = {"healer dps","Healer DPS","Healers cast damage spells if they have enough mana)"},
		[7] = {"dps assist","DPS single","Target one mob at a time"}, -- Needs correction
		[8] = {"dps aoe","DPS multi","Target many mobs at a time."},
		--
		[9] = {"avoid aoe","Avoid AoE","Bots automatically avoid the majority of harmful aoe spells."}, -- Needs correction		
		[10] = {"save mana","Save Mana","Healers save mana by prioritizing high-efficiency spells when mana falls below a threshold."},
		[11] = {"bhealth","Seal of Light","Buff health (Seal of light)"},
		[12] = {"bmana","Seal of Wisdom","Buff mana (Seal of wisdom)"},		
		[13] = {"potions","Use potions","Use potions in combat"},
		[14] = {"threat","Threat Control","The bot will be conservative while in combat to prevent gaining too much threat."},
		[15] = {"mark rti","Mark RTI","Assign Raid icons to targets (Use on Tank)."}, -- ???
		--
		[16] = {"bcast","Concetration Aura","The bot will use buffs that help casting (Concetration aura)."}, -- ???
		[17] = {"baoe","Retribution Aura","Buff area of effect (Paladin - Retribution aura)."}, -- ???
		[18] = {"barmor","Devotion Aura","The bot will use buffs that increases armor (Devotion aura)."}, -- ???
		[19] = {"bcast","Concetration Aura","The bot will use buffs that help casting (Concetration aura)."}, -- ???
		[20] = {"rfire","Fire Aura","The bot will use Fire Resistance Aura."},
		[21] = {"rfrost","Frost Aura","The bot will use Frost Resistance Aura."},
		[22] = {"rshadow","Shadow Aura","The bot will use Shadow Resistance Aura."},
		--
		[23] = {"bdps","BoM","The bot will use buffs that increases damage in combat (Blessing of Might)."}, -- ???		
		[24] = {"bstats","BoK","The bot will use buffs that increases stats. (Blessing of Kings)"}, -- ???
		[25] = {"bmana","BoW","The bot will use buffs that restores/increase mana. (Blessing of Wisdom to Casters)"}, -- ???
	};

	ClassStrategyNC = {
		[1] = {"baoe","Retribution Aura","Buff area of effect (Paladin - Retribution aura)."}, -- ???
		[2] = {"barmor","Devotion Aura","The bot will use buffs that increases armor (Devotion aura)."}, -- ???
		[3] = {"bcast","Concetration Aura","The bot will use buffs that help casting (Concetration aura)."}, -- ???
		[4] = {"rfire","Fire Aura","The bot will use Fire Resistance Aura."},
		[5] = {"rfrost","Frost Aura","The bot will use Frost Resistance Aura."},
		[6] = {"rshadow","Shadow Aura","The bot will use Shadow Resistance Aura."},
		[7] = {"bdps","BoM","The bot will use buffs that increases damage in combat (Blessing of Might)."}, -- ???		
		[8] = {"bstats","BoK","The bot will use buffs that increases stats. (Blessing of Kings)"}, -- ???
		[9] = {"bmana","BoW","The bot will use buffs that restores/increase mana. (Blessing of Wisdom to Casters)"}, -- ???
		[10] = {"food","Rest","The bot will receive food and drinks after leaving combat depending on their requirements."},
		[11] = {"pvp","PVP","Turn on or off pvp mode"},
	};
end

function InitializeStrategyPriest()

	ClassStrategyCO = {
		--Roles
		[1] = {"shadow","DPS Shadow","Use default Shadow spec DPS role."},
		[2] = {"holy dps","DPS Holy","Use default Holy spec DPS role."},
		[3] = {"heal","Healer","Bot will use default Healer role and strategy."},
		[4] = {"holy heal","Healer Holy","Use default Holy healer role."},
		-- Roles addons
		[5] = {"tank assist","Offtank","The bot will assist the tank in the group."},
		[6] = {"healer dps","Healer DPS","Healers cast damage spells if they have enough mana)"},
		[7] = {"dps assist","DPS single","Target one mob at a time"}, -- Needs correction
		[8] = {"dps aoe","DPS multi","Target many mobs at a time."},
		--
		[9] = {"dps debuff","Debuff (DPS)","The bot will cast debuffs on their target while in combat."},
		[10] = {"aoe","AOE Damage","Bots use AOE damage while in combat."}, -- Needs correction		
		[11] = {"avoid aoe","Avoid AoE","Bots automatically avoid the majority of harmful aoe spells."}, -- Needs correction
		[12] = {"shadow aoe","Shadow (AoE)","The bot will use shadow-based area of effect spells if there are multiple targets."},
		[13] = {"shadow debuff","Debuff (Shadow)","The bot will cast shadow-based debuffs on their target while in combat."},
		[14] = {"rshadow","Shadow Resist","The bot will use Prayer of shadow spell."},		
		[15] = {"save mana","Save Mana","Healers save mana by prioritizing high-efficiency spells when mana falls below a threshold."},
		[16] = {"potions","Use potions","Use potions in combat"},
		[17] = {"threat","Threat Control","The bot will be conservative while in combat to prevent gaining too much threat."},
		--
		[18] = {"buff","Buff players","The bot will use usefull buffs on players"}, -- ???
	};

	ClassStrategyNC = {
		[1] = {"buff","Buff players","The bot will use usefull buffs on players"}, -- ???
		[2] = {"rshadow","Shadow Resist","The bot will use Prayer of shadow spell."},
		[3] = {"food","Rest","The bot will receive food and drinks after leaving combat depending on their requirements."},
		[4] = {"pvp","PVP","Turn on or off pvp mode"},
	};
end

function InitializeStrategyWarrior()

	ClassStrategyCO = {
		--Roles
		[1] = {"tank","Tank","Bot will use Tank role and strategy."},
		[2] = {"arms","DPS Arms","Use default Arms DPS spec combat strategy"},
		[3] = {"fury","DPS Fury","Use default Fury DPS spec combat strategy"},		
		--
		[4] = {"tank assist","Offtank","The bot will assist the tank in the group."},		
		[5] = {"dps assist","DPS single","Target one mob at a time"}, -- Needs correction
		[6] = {"dps aoe","DPS multi","Target many mobs at a time."},
		[7] = {"aoe","AOE Damage","Bots use AOE damage while in combat."}, -- Needs correction
		[8] = {"avoid aoe","Avoid AoE","Bots automatically avoid the majority of harmful aoe spells."}, -- Needs correction
		[9] = {"save mana","Save Rage","Warrior will try to save rage for more usefull spells."},
		[10] = {"potions","Use potions","Use potions in combat"},
		[11] = {"threat","Threat Control","The bot will be conservative while in combat to prevent gaining too much threat."},
		[12] = {"mark rti","Mark RTI","Assign Raid icons to targets (Use on Tank)."}, -- ???
	};

	ClassStrategyNC = {
		[1] = {"food","Rest","The bot will receive food and drinks after leaving combat depending on their requirements."},
		[2] = {"pvp","PVP","Turn on or off pvp mode"},
	};
end

function InitializeStrategyHunter()

	ClassStrategyCO = {
		--Roles
		[1] = {"dps","DPS","Bot will use Dps role and strategy."},		
		-- Roles addons
		[2] = {"tank assist","Offtank","The bot will assist the tank in the group."},
		[3] = {"dps assist","DPS single","Target one mob at a time"}, -- Needs correction
		[4] = {"dps aoe","DPS multi","Target many mobs at a time."},		
		[5] = {"dps debuff","Debuff (DPS)","The bot will cast debuffs on their target while in combat."},
		--
		[6] = {"aoe","AOE Damage","Bots use AOE damage while in combat."}, -- Needs correction
		[7] = {"avoid aoe","Avoid AoE","Bots automatically avoid the majority of harmful aoe spells."}, -- Needs correction
		[8] = {"rnature","Nature Resist","The bot will use nature resist aura."},
		[9] = {"save mana","Save Mana","Healers save mana by prioritizing high-efficiency spells when mana falls below a threshold."},
		[10] = {"potions","Use potions","Use potions in combat"},
		[11] = {"threat","Threat Control","The bot will be conservative while in combat to prevent gaining too much threat."},
		[12] = {"kite","Kite Adds","The bot will try to kite adds around."},
		--
		[13] = {"bdps","Buff DPS","The bot will use buffs that increases damage in combat."},
		[14] = {"boost","AP aura","The bot will use aura that increases damage in combat (Trueshot aura)."},
	};

	ClassStrategyNC = {
		[1] = {"bdps","Buff DPS","The bot will use buffs that increases damage in combat."}, -- ???
		[2] = {"bspeed","Speed aura","The bot will use aspect that increases travel speed out of combat (Apect of the pack)."}, -- ???
		[3] = {"rnature","Nature Resist","The bot will use nature resist aura."},
		[4] = {"food","Rest","The bot will receive food and drinks after leaving combat depending on their requirements."},
		[5] = {"pvp","PVP","Turn on or off pvp mode"},
	};
end

function InitializeStrategyMage()

	ClassStrategyCO = {
		--Roles
		[1] = {"fire","DPS Fire","Use default Fire spec DPS role."},
		[2] = {"frost","DPS Frost","Use default Frost spec DPS role."},
		[3] = {"arcane","DPS Arcane","Use default Arcane spec DPS role."},
		--
		[4] = {"tank assist","Offtank","The bot will assist the tank in the group."},
		[5] = {"dps assist","DPS single","Target one mob at a time"}, -- Needs correction
		[6] = {"dps aoe","DPS multi","Target many mobs at a time."},
		[7] = {"fire aoe","AOE Fire","Target many mobs at a time with fire AOE spells."},
		[8] = {"frost aoe","AOE Frost","Target many mobs at a time with frost AOE spells."},
		[9] = {"arcane aoe","AOE Arcane","Target many mobs at a time with arcane AOE spells."},		
		[10] = {"avoid aoe","Avoid AoE","Bots automatically avoid the majority of harmful aoe spells."}, -- Needs correction			
		[11] = {"save mana","Save Mana","Save mana by prioritizing high-efficiency spells when mana falls below a threshold."},
		[12] = {"potions","Use potions","Use potions in combat"},
		[13] = {"threat","Threat Control","The bot will be conservative while in combat to prevent gaining too much threat."},
		--
		[14] = {"buff","Buff players","The bot will use usefull buffs on players"}, -- ???
		[15] = {"bdps","Buff DPS","The bot will use buffs that increases damage in combat."}, -- ???
		[16] = {"bmana","Buff mana","The bot will use buffs that increase mana. (Arcane Intelect)"}, -- ???
	};

	ClassStrategyNC = {
		[1] = {"buff","Buff players","The bot will use usefull buffs on players"}, -- ???
		[2] = {"bdps","Buff DPS","The bot will use buffs that increases damage in combat."}, -- ???
		[3] = {"bmana","Buff mana","The bot will use buffs that increase mana. (Arcane Intelect)"}, -- ???
		[4] = {"food","Rest","The bot will receive food and drinks after leaving combat depending on their requirements."},
		[5] = {"pvp","PVP","Turn on or off pvp mode"},
	};
end

function InitializeStrategyDruid()

	ClassStrategyCO = {
		--Roles
		[1] = {"bear","Tank","The bot will tank in bear form. Use on feral Tank spec."},
		[2] = {"cat","DPS melee","The bot will DPS in cat form. Use on feral DPS spec"},
		[3] = {"caster","DPS range","The bot will fight as caster from distance. Use on Balance spec"},
		[4] = {"heal","Healer","Bot will use Healer role and strategy. Use on Restoration spec."},
		-- Roles addons
		[5] = {"tank assist","Offtank","The bot will assist the tank in the group."},
		[6] = {"healer dps","Healer DPS","Healers cast damage spells if they have enough mana)"},
		[7] = {"dps assist","DPS single","Target one mob at a time"}, -- Needs correction
		[8] = {"dps aoe","DPS multi","Target many mobs at a time."},
		[9] = {"dps debuff","Debuff (DPS)","The bot will cast debuffs on their target while in combat."},
		[10] = {"avoid aoe","Avoid AoE","Bots automatically avoid the majority of harmful aoe spells."}, -- Needs correction
		--Forms addons
		[11] = {"cat aoe","Cat AOE","The bot will use cat AOE damage abilities."},
		[12] = {"caster aoe","Caster AOE","The bot will use caster AOE damage abilities."},
		[13] = {"caster debuff","Caster debuff","The bot will use caster debuffs abilities in combat."},
		--
		[14] = {"save mana","Save Mana","Healers save mana by prioritizing high-efficiency spells when mana falls below a threshold."},
		[15] = {"potions","Use potions","Use potions in combat"},
		[16] = {"threat","Threat Control","The bot will be conservative while in combat to prevent gaining too much threat."},
		[17] = {"buff","Buff players","The bot will use usefull buffs on players"}, -- ???
		[18] = {"mark rti","Mark RTI","Assign Raid icons to targets (Use on Tank)."}, -- ???
	};

	ClassStrategyNC = {
		[1] = {"buff","Buff players","The bot will use usefull buffs on players"}, -- ???
		[2] = {"food","Rest","The bot will receive food and drinks after leaving combat depending on their requirements."},
		[3] = {"pvp","PVP","Turn on or off pvp mode"},
	};
end

function InitializeStrategyRogue()

	ClassStrategyCO = {
		--Roles
		[1] = {"dps","DPS","Bot will use Dps role and strategy."},
		-- Roles addons
		[2] = {"tank assist","Offtank","The bot will assist the tank in the group."},
		[3] = {"dps assist","DPS single","Target one mob at a time"}, -- Needs correction
		[4] = {"dps aoe","DPS multi","Target many mobs at a time."},
		[5] = {"aoe","AOE Damage","Bots use AOE damage while in combat."}, -- Needs correction	
		[6] = {"avoid aoe","Avoid AoE","Bots automatically avoid the majority of harmful aoe spells."}, -- Needs correction
		--Forms
		[7] = {"melee","Melee role","The bot will fight as melee in close range (Assassination rogue)."},
		[8] = {"ranged","Ranged role","The bot will fight as ranged from distance."},
		[9] = {"stealth","Stealth start","The bot will start fight from stealth (Assassination rogue buff)."},
		--
		[10] = {"save mana","Save energy","Rogue saves energy by prioritizing high-efficiency spells when energy falls below a threshold."},
		[11] = {"potions","Use potions","Use potions in combat"},
		[12] = {"threat","Threat Control","The bot will be conservative while in combat to prevent gaining too much threat."},
		[13] = {"kite","Kite Adds","The bot will try to kite adds around."},
		[14] = {"buff","Buff players","The bot will use usefull buffs on players (ToT)"}, -- ???
	};

	ClassStrategyNC = {
		[1] = {"buff","Buff players","The bot will use usefull buffs on players (ToT)"}, -- ???
		[2] = {"food","Rest","The bot will receive food and drinks after leaving combat depending on their requirements."},
		[3] = {"pvp","PVP","Turn on or off pvp mode"},
	};
end

function InitializeStrategyDeathKnight()

	ClassStrategyCO = {
		--Roles
		--[1] = {"tank","Tank","Not used in code, will add --> tank face strategy"},
		[1] = {"blood","Blood DK","Bot will use blood DK role and strategy."},
		[2] = {"frost","Frost DK","Bot will use frost DK role and strategy."},		
		[3] = {"unholy","Unholy DK","Bot will use unholy DK role and strategy."},
		-- Roles addons
		[4] = {"tank assist","Offtank","The bot will assist the tank in the group."},
		[5] = {"dps assist","DPS single","Target one mob at a time"},
		[6] = {"dps aoe","DPS multi","Target many mobs at a time."},
		[7] = {"frost aoe","DPSF multi","Target many mobs at a time with frost spells."},
		[8] = {"unholy aoe","DPSU multi","Target many mobs at a time with unholy spells."},
		--
		[9] = {"avoid aoe","Avoid AoE","Bots automatically avoid the majority of harmful aoe spells."},	
		[10] = {"save mana","Save RunePower","DK save rune power by prioritizing high-efficiency spells when rune power falls below a threshold."},
		[11] = {"potions","Use potions","Use potions in combat"},
		[12] = {"threat","Threat Control","The bot will be conservative while in combat to prevent gaining too much threat."},
		[13] = {"kite","Kite Adds","The bot will try to kite adds around."},
		[14] = {"bdps","Buff DPS","The bot will use buffs that increases damage/stats in combat (Melee haste, AGI/STR, AP )."}, -- ???
		[15] = {"mark rti","Mark RTI","Assign Raid icons to targets (Use on Tank)."}, -- ???
	};

	ClassStrategyNC = {
		[1] = {"bdps","Buff DPS","The bot will use buffs that increases damage/stats in combat (Melee haste, AGI/STR, AP )."}, -- ???		
		[2] = {"food","Rest","The bot will receive food and drinks after leaving combat depending on their requirements."},
		[3] = {"pvp","PVP","Turn on or off pvp mode"},
	};
end

function InitializeStrategyWarlock()

	ClassStrategyCO = {
		--Roles
		[1] = {"dps","DPS","Bot will use Dps role and strategy."},		
		-- Roles addons
		[2] = {"tank assist","Offtank","The bot will assist the tank in the group."},
		[3] = {"dps assist","DPS single","Target one mob at a time"},
		[4] = {"dps aoe","DPS multi","Target many mobs at a time."},		
		[5] = {"dps debuff","Debuff (DPS)","The bot will cast debuffs on their target while in combat."},
		[6] = {"aoe","AOE Damage","Bots use AOE damage while in combat."},
		[7] = {"avoid aoe","Avoid AoE","Bots automatically avoid the majority of harmful aoe spells."},
		--
		[8] = {"save mana","Save Mana","Healers save mana by prioritizing high-efficiency spells when mana falls below a threshold."},
		[9] = {"potions","Use potions","Use potions in combat"},
		[10] = {"threat","Threat Control","The bot will be conservative while in combat to prevent gaining too much threat."},
		[11] = {"kite","Kite Adds","The bot will try to kite adds around."},
		--
		[12] = {"bdps","Buff DPS","The bot will use buffs that increases damage in combat."}, -- ???
		[13] = {"bmana","Buff mana","The bot will use buffs that increases mana."}, -- ???
	};

	ClassStrategyNC = {
		[1] = {"bdps","Buff DPS","The bot will use buffs that increases damage in combat."}, -- ???
		[2] = {"bmana","Buff mana","The bot will use buffs that increases mana."}, -- ???
		[3] = {"food","Rest","The bot will receive food and drinks after leaving combat depending on their requirements."},
		[4] = {"pvp","PVP","Turn on or off pvp mode"},
	};
end

function InitializeStrategyShaman()

	ClassStrategyCO = {
		--Roles
		[1] = {"melee","Melee DPS","The bot will fight as melee DPS. Use on Enhancement spec"},
		[2] = {"ranged","Ranged DPS","The bot will fight as range DPS. Use on Elemental spec"},
		[3] = {"heal","Healer","Bot will use Healer role and strategy."},
		-- Roles addons
		[4] = {"tank assist","Offtank","The bot will assist the tank in the group."},
		[5] = {"healer dps","Healer DPS","Healers cast damage spells if they have enough mana)"},
		[6] = {"dps assist","DPS single","Target one mob at a time"}, -- Needs correction
		[7] = {"dps aoe","DPS multi","Target many mobs at a time."},		
		[8] = {"avoid aoe","Avoid AoE","Bots automatically avoid the majority of harmful aoe spells."},
		--
		[9] = {"totems","Use Totems","Bot will use totems in combat"},
		[10] = {"save mana","Save Mana","Save mana by prioritizing high-efficiency spells when mana falls below a threshold."},
		[11] = {"potions","Use potions","Use potions in combat"},
		[12] = {"threat","Threat Control","The bot will be conservative while in combat to prevent gaining too much threat."},
		--Buffs
		[13] = {"bdps","Buff dps","Bot will use totems to buff DPS)"},
		[14] = {"bmana","Buff mana","Bot will use totems to buff/replenish mana)"},
		
	};

	ClassStrategyNC = {
		[1] = {"bdps","Buff dps","Bot will use totems to buff DPS)"},
		[2] = {"bmana","Buff mana","Bot will use totems to buff/replenish mana)"},
		[3] = {"food","Rest","The bot will receive food and drinks after leaving combat depending on their requirements."},
		[4] = {"pvp","PVP","Turn on or off pvp mode"},
	};
end
