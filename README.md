# nSpellTracker

```lua
addon.cfg = {
	highlightPlayerSpells = true, -- Player spells will have a blue border
	refreshInterval = 0.1, -- How fast to scan the auras (buff/debuffs)
	decimalThreshold = 3, --how many decimal points to take into account for calculating durations for auras and tempenchants.  Default 3
}
```

## Example

To add a debuff, buff or cooldown to track just open the class specific config
file under the `classes` folder and add one of the following: `addon:Debuff(...)`
`addon:Buff(...)` `addon:Cooldown(...)`, where `...` is a table containing
various settings.

The rootSpellID is the primary spellID that will be used for not only the Icon's texture but to compare it with other spellID's.
The rootSpellID is REQUIRED.

Example

```lua
addon:Debuff(rootSpellID, {
	spellID = 172,
	size = 36,
	position = {'CENTER', 'UIParent', 'CENTER', 150, 0},
	unit = 'target',
	validateUnit = true,
	hideOutOfCombat = true,
	isMine = true,
	desaturate = true,
})
```

To track multiple spells you just add a table of spell ids like so:

```lua
addon:Buff(rootSpellID, {
	spellID = {172, 234, 2356},
})
```

The same goes with the `spec` option:

```lua
addon:Buff(rootSpellID, {
	spec = {1, 3},
})
```

NOTE: Please note that the buff/debuff duration will be grabbed from the first spellID that matches, if a spellID table is used. So it may not match exactly with the duration for the rootSpellID.


## Buff/Debuff

```lua
addon:Buff(rootSpellID, {
	spellID = 172,
	size = 36,
	position = {'CENTER', 'UIParent', 'CENTER', 150, 0},
	unit = 'target',
	validateUnit = true,
	hideOutOfCombat = true,
	isMine = true,
	desaturate = true,
})

addon:Debuff(rootSpellID, {
	spellID = 172,
	size = 36,
	position = {'CENTER', 'UIParent', 'CENTER', 150, 0},
	unit = 'target',
	validateUnit = true,
	hideOutOfCombat = true,
	isMine = true,
	desaturate = true,
})
```

Buff/Debuff settings:

```lua
{
	-- The talent tree you want to track the spell (nil will make it work in
	-- any tree). 
	spec = nil, -- you can use a table as well, like {1,3} for specs 1 and 3
	
	-- Attribute that lets you show/hide the frame on a given state condition.
	-- example: '[stance:2] show; hide'
	visibilityState = '[petbattle] hide; show',
	
	-- The spellid to track this will represent the icon to be used. If no spellID is given then the rootSpellID is used.
	spellID = 469, -- a table can be used as well {12345, 435, 2586674} the first spellID that matches will be used. 
	spellID = {12345, 435, 2586674}, -- a table can be used as well, the first spellID that matches will be used. This table will always include the rootSpellID.
	
	-- The size of the icon.
	size = 26,
	
	--use a custom iconTexture instead of the one from the spellID. Use fileID numbers for iconTexture
	iconTexture = 12345,
	
	-- The position of the icon (http://www.wowwiki.com/API_Region_SetPoint).
	position = {'CENTER', 'UIParent', 'CENTER', 150, 0},
	
	--Unit ID (http://www.wowwiki.com/UnitId), the unit that should be tracked.
	unit = 'player',
	
	-- Only show the icon if unit is found.
	validateUnit = true,
	
	-- Hide icon out of combat.
	hideOutOfCombat = true,
	
	-- Hide if the buff/debuff isn't mine.
	isMine = false,
	
	--verify if the spellID is in our spellbook
	verifySpell = true,
	
	-- Desaturate the icon if not found.
	desaturate = true,
	
	---------------
	-- Set the alpha values of your icons (transparency) when found/notfound.
	---------------
	peekAlpha = {
		found = {
			icon = 1, --buff/debuff was found
		},
		notFound = {
			icon = 0.6, --buff/debuff was not found
		},
	},
	
	--sets the alpha when the Icon is active/inactive
	alpha = {
		active = 1, --default is 1
		inactive = 0.4, --default is 0.4
	},
	
	-- PostUpdateHook, apply additional logic to the buff/debuff after it has been processed.
	-- Example:
	PostUpdateHook = function(self)
		local haveTotem, name, startTime, duration, icon = GetTotemInfo(1)
		if haveTotem and name == 'Healing Stream Totem' then
			local timeLeft = Round(startTime + duration - GetTime())
			if timeLeft > 0 then
				self.Icon:SetAlpha(1)
				self.Icon.Duration:SetText(timeLeft)
			end
		end
	end,
	
	-- Set the types of GLOW you want
	glowOverlay = {
		shineType = 'Blizzard',
		reqAlpha = 0, --required alpha level to show, default is zero
		color = {r,g,b,a}, -- Default value is {0.95, 0.95, 0.32, 1}
		frequency = 0.125, -- Default value is 0.125
	},
	glowOverlay = {
		shineType = 'PixelGlow',
		reqAlpha = 0.5, --required alpha level to show, default is zero
		color = {242, 5/255, 5/255, 1}, -- Default value is {0.95, 0.95, 0.32, 1}
		numLines = 8, --default is 8
		frequency = 0.25, -- frequency, set to negative to inverse direction of rotation. Default value is 0.25;
		lineLength = nil, --length of lines, common is 10-15. Default = nil, will set line length depending on dimensions of glow frame
		lineThickness = 2, --line thickness, default value is 1
		xOffset = 0, --- offset of glow relative to region border;
		yOffset = 0, --- offset of glow relative to region border;
		border = false, -- set to true to create border under lines;
	},
	glowOverlay = {
		shineType = 'AutoCastGlow',
		reqAlpha = 0.5, --required alpha level to show, default is zero
		color = {242, 5/255, 5/255, 1}, -- Default value is {0.95, 0.95, 0.32, 1}
		numParticle = 8, --default is 8, number of particles to show
		frequency = 0.25, -- frequency, set to negative to inverse direction of rotation. Default value is 0.25;
		particleScale = 1, --scale of the particles, default is 1
		xOffset = 0, --- offset of glow relative to region border;
		yOffset = 0, --- offset of glow relative to region border;
	},
	glowOverlay = {
		shineType = 'ButtonGlow',
		reqAlpha = 0.5, --required alpha level to show, default is zero
		color = {242, 5/255, 5/255, 1}, -- Default value is {0.95, 0.95, 0.32, 1}
		frequency = 0.25, -- frequency, set to negative to inverse direction of rotation. Default value is 0.25;
	},
	
}
```


## Cooldown

```lua
addon:Cooldown(rootSpellID, {
	size = 36,
	position = {'CENTER', 'UIParent', 'CENTER', 150, 0},
	hideOutOfCombat = true,
	desaturate = true,
})
```

Cooldown settings:

```lua
{
	cdType = 'spell', --cooldown types can be 'spell' or 'item', when using 'item' provide the itemID as the rootSpellID
	--OR-- (don't use both!)
	cdType = 'item', --make sure to provide the itemID, its used for both the cooldown grab and the icon texture
	
	-- The talent tree you want to track the spell (nil will make it work in
	-- any tree). 
	spec = nil, -- you can use a table as well, like {1,3} for specs 1 and 3
	
	-- Attribute that lets you show/hide the frame on a given state condition.
	-- example: '[stance:2] show; hide'
	visibilityState = '[petbattle] hide; show',
	
	-- The size of the icon.
	size = 26,
	
	--use a custom iconTexture instead of the one from the spellID. Use fileID numbers for iconTexture
	iconTexture = 12345,
	
	-- The position of the icon (http://www.wowwiki.com/API_Region_SetPoint).
	position = {'CENTER', 'UIParent', 'CENTER', 150, 0},
	
	-- Hide icon out of combat.
	hideOutOfCombat = true,
	
	-- Desaturate the icon if not found.
	desaturate = true,
	
	--verify if the spellID is in our spellbook
	verifySpell = false,
	
	--add a global cooldown to check in duration. By default this is turned off. However you can override if you want.
	globalCooldown = 1.5, --default is off, however most spells and classes use a 1.5 global cooldown.
	
	---------------
	-- Set the alpha values of your icons (transparency) when on or not on cooldown
	---------------
	peekAlpha = {
		cooldown = {
			icon = 0.6, --spell on cooldown
		},
		notCooldown = {
			icon = 1, --spell not on cooldown
		},
	}
	
	--sets the alpha when the Icon is active/inactive
	alpha = {
		active = 1, --default is 1
		inactive = 0.4, --default is 0.4
	},
	
	-- PostUpdateHook, apply additional logic to the buff/debuff after it has been processed.
	-- Example:
	PostUpdateHook = function(self)
		local haveTotem, name, startTime, duration, icon = GetTotemInfo(1)
		if haveTotem and name == 'Healing Stream Totem' then
			local timeLeft = Round(startTime + duration - GetTime())
			if timeLeft > 0 then
				self.Icon:SetAlpha(1)
				self.Icon.Duration:SetText(timeLeft)
			end
		end
	end,
	
	-- Set the types of GLOW you want
	glowOverlay = {
		shineType = 'Blizzard',
		reqAlpha = 0, --required alpha level to show, default is zero
		color = {r,g,b,a}, -- Default value is {0.95, 0.95, 0.32, 1}
		frequency = 0.125, -- Default value is 0.125
	},
	glowOverlay = {
		shineType = 'PixelGlow',
		reqAlpha = 0.5, --required alpha level to show, default is zero
		color = {242, 5/255, 5/255, 1}, -- Default value is {0.95, 0.95, 0.32, 1}
		numLines = 8, --default is 8
		frequency = 0.25, -- frequency, set to negative to inverse direction of rotation. Default value is 0.25;
		lineLength = nil, --length of lines, common is 10-15. Default = nil, will set line length depending on dimensions of glow frame
		lineThickness = 2, --line thickness, default value is 1
		xOffset = 0, --- offset of glow relative to region border;
		yOffset = 0, --- offset of glow relative to region border;
		border = false, -- set to true to create border under lines;
	},
	glowOverlay = {
		shineType = 'AutoCastGlow',
		reqAlpha = 0.5, --required alpha level to show, default is zero
		color = {242, 5/255, 5/255, 1}, -- Default value is {0.95, 0.95, 0.32, 1}
		numParticle = 8, --default is 8, number of particles to show
		frequency = 0.25, -- frequency, set to negative to inverse direction of rotation. Default value is 0.25;
		particleScale = 1, --scale of the particles, default is 1
		xOffset = 0, --- offset of glow relative to region border;
		yOffset = 0, --- offset of glow relative to region border;
	},
	glowOverlay = {
		shineType = 'ButtonGlow',
		reqAlpha = 0.5, --required alpha level to show, default is zero
		color = {242, 5/255, 5/255, 1}, -- Default value is {0.95, 0.95, 0.32, 1}
		frequency = 0.25, -- frequency, set to negative to inverse direction of rotation. Default value is 0.25;
	},
	
}
```


## Temporary Enchants

NOTE: rootSpellID is the enchantID from GetWeaponEnchantInfo()

```lua
addon:TempEnchant(rootSpellID, {
	position = {'CENTER', 'UIParent', 'CENTER', 100, 80},
	size = 50,
	hideOutOfCombat = false,
	iconTexture = 135814,
	visibilityState = '[petbattle] [vehicleui] hide; show',
})
```

Temporary Enchant settings:

```lua
{
	
	-- The talent tree you want to track the spell (nil will make it work in
	-- any tree). 
	spec = nil, -- you can use a table as well, like {1,3} for specs 1 and 3
	
	-- Attribute that lets you show/hide the frame on a given state condition.
	-- example: '[stance:2] show; hide'
	visibilityState = '[petbattle] hide; show',
	
	-- The size of the icon.
	size = 26,
	
	--use a custom iconTexture instead of the one from the temporary enchant item slot texture. Use a fileID.
	iconTexture = 12345,
	
	-- The position of the icon (http://www.wowwiki.com/API_Region_SetPoint).
	position = {'CENTER', 'UIParent', 'CENTER', 150, 0},
	
	-- Hide icon out of combat.
	hideOutOfCombat = true,
	
	-- Desaturate the icon if not found.
	desaturate = true,
	
	---------------
	-- Set the alpha values of your icons (transparency) when found or notfound
	---------------
	peekAlpha = {
		found = {
			icon = 1, --enchant was found
		},
		notFound = {
			icon = 0.6, --enchant was not found
		},
	},
	
	--sets the alpha when the Icon is active/inactive
	alpha = {
		active = 1, --default is 1
		inactive = 0.4, --default is 0.4
	},
	
	-- PostUpdateHook, apply additional logic to the buff/debuff after it has been processed.
	-- Example:
	PostUpdateHook = function(self)
		local haveTotem, name, startTime, duration, icon = GetTotemInfo(1)
		if haveTotem and name == 'Healing Stream Totem' then
			local timeLeft = Round(startTime + duration - GetTime())
			if timeLeft > 0 then
				self.Icon:SetAlpha(1)
				self.Icon.Duration:SetText(timeLeft)
			end
		end
	end,
	
	-- Set the types of GLOW you want
	glowOverlay = {
		shineType = 'Blizzard',
		reqAlpha = 0, --required alpha level to show, default is zero
		color = {r,g,b,a}, -- Default value is {0.95, 0.95, 0.32, 1}
		frequency = 0.125, -- Default value is 0.125
	},
	glowOverlay = {
		shineType = 'PixelGlow',
		reqAlpha = 0.5, --required alpha level to show, default is zero
		color = {242, 5/255, 5/255, 1}, -- Default value is {0.95, 0.95, 0.32, 1}
		numLines = 8, --default is 8
		frequency = 0.25, -- frequency, set to negative to inverse direction of rotation. Default value is 0.25;
		lineLength = nil, --length of lines, common is 10-15. Default = nil, will set line length depending on dimensions of glow frame
		lineThickness = 2, --line thickness, default value is 1
		xOffset = 0, --- offset of glow relative to region border;
		yOffset = 0, --- offset of glow relative to region border;
		border = false, -- set to true to create border under lines;
	},
	glowOverlay = {
		shineType = 'AutoCastGlow',
		reqAlpha = 0.5, --required alpha level to show, default is zero
		color = {242, 5/255, 5/255, 1}, -- Default value is {0.95, 0.95, 0.32, 1}
		numParticle = 8, --default is 8, number of particles to show
		frequency = 0.25, -- frequency, set to negative to inverse direction of rotation. Default value is 0.25;
		particleScale = 1, --scale of the particles, default is 1
		xOffset = 0, --- offset of glow relative to region border;
		yOffset = 0, --- offset of glow relative to region border;
	},
	glowOverlay = {
		shineType = 'ButtonGlow',
		reqAlpha = 0.5, --required alpha level to show, default is zero
		color = {242, 5/255, 5/255, 1}, -- Default value is {0.95, 0.95, 0.32, 1}
		frequency = 0.25, -- frequency, set to negative to inverse direction of rotation. Default value is 0.25;
	},
	
}
```


## Spell Tracking

```lua
addon:Spell(rootSpellID, {
	position = {'CENTER', 'UIParent', 'CENTER', 100, 80},
	size = 50,
	hideOutOfCombat = false,
	iconTexture = 135814,
	visibilityState = '[petbattle] [vehicleui] hide; show',
})
```

Spell Tracking settings:

```lua
{
	
	-- The talent tree you want to track the spell (nil will make it work in
	-- any tree). 
	spec = nil, -- you can use a table as well, like {1,3} for specs 1 and 3
	
	-- Attribute that lets you show/hide the frame on a given state condition.
	-- example: '[stance:2] show; hide'
	visibilityState = '[petbattle] hide; show',
	
	-- The size of the icon.
	size = 26,
	
	--use a custom iconTexture instead of the one from the spellID. Use fileID numbers for iconTexture
	iconTexture = 12345,
	
	-- The position of the icon (http://www.wowwiki.com/API_Region_SetPoint).
	position = {'CENTER', 'UIParent', 'CENTER', 150, 0},
	
	-- Hide icon out of combat.
	hideOutOfCombat = true,
	
	-- Desaturate the icon if not found.
	desaturate = true,
	
	--verify if the spellID is in our spellbook
	verifySpell = false,
	
	--a spell is technically usable because they meet the resource requirement, like chi, mana, rage, etc... but can be on cooldown.
	--if you don't want to show a spell when it's usable but is on cooldown, then set showOnCooldown to false, the default is true.
	showOnCooldown = false, --default is true
	
	--this will add the global cooldown to the calculations of the spell cooldown.  It's recommended to leave this on.
	--Only play with this setting if you know what you are doing. This setting works closely with showOnCooldown above.
	useGlobalCooldown = true, --default is true
	
	--this option will show the spell icon ONLY when the spell itself has the spell activation overlay glow on it.  This is the yellow/gold glow that shows around a skill on the actionbars
	--when a skill has a proc or has triggered an activation.  NOTE: This option will ignore all checks unless the spell in question has a glow overlay.
	showOnlyOnOverlayGlow = false,
	
	---------------
	-- Set the alpha values of your icons (transparency) when found or notfound
	---------------
	peekAlpha = {
		usable = {
			icon = 1, --spell is usable
		},
		notUsable = {
			icon = 0.6, --spell not usable
		},
	},
	
	--sets the alpha when the Icon is active/inactive
	alpha = {
		active = 1, --default is 1
		inactive = 0.4, --default is 0.4
	},
	
	-- PostUpdateHook, apply additional logic to the buff/debuff after it has been processed.
	-- Example:
	PostUpdateHook = function(self)
		local haveTotem, name, startTime, duration, icon = GetTotemInfo(1)
		if haveTotem and name == 'Healing Stream Totem' then
			local timeLeft = Round(startTime + duration - GetTime())
			if timeLeft > 0 then
				self.Icon:SetAlpha(1)
				self.Icon.Duration:SetText(timeLeft)
			end
		end
	end,
	
	-- Set the types of GLOW you want
	glowOverlay = {
		shineType = 'Blizzard',
		reqAlpha = 0, --required alpha level to show, default is zero
		color = {r,g,b,a}, -- Default value is {0.95, 0.95, 0.32, 1}
		frequency = 0.125, -- Default value is 0.125
	},
	glowOverlay = {
		shineType = 'PixelGlow',
		reqAlpha = 0.5, --required alpha level to show, default is zero
		color = {242, 5/255, 5/255, 1}, -- Default value is {0.95, 0.95, 0.32, 1}
		numLines = 8, --default is 8
		frequency = 0.25, -- frequency, set to negative to inverse direction of rotation. Default value is 0.25;
		lineLength = nil, --length of lines, common is 10-15. Default = nil, will set line length depending on dimensions of glow frame
		lineThickness = 2, --line thickness, default value is 1
		xOffset = 0, --- offset of glow relative to region border;
		yOffset = 0, --- offset of glow relative to region border;
		border = false, -- set to true to create border under lines;
	},
	glowOverlay = {
		shineType = 'AutoCastGlow',
		reqAlpha = 0.5, --required alpha level to show, default is zero
		color = {242, 5/255, 5/255, 1}, -- Default value is {0.95, 0.95, 0.32, 1}
		numParticle = 8, --default is 8, number of particles to show
		frequency = 0.25, -- frequency, set to negative to inverse direction of rotation. Default value is 0.25;
		particleScale = 1, --scale of the particles, default is 1
		xOffset = 0, --- offset of glow relative to region border;
		yOffset = 0, --- offset of glow relative to region border;
	},
	glowOverlay = {
		shineType = 'ButtonGlow',
		reqAlpha = 0.5, --required alpha level to show, default is zero
		color = {242, 5/255, 5/255, 1}, -- Default value is {0.95, 0.95, 0.32, 1}
		frequency = 0.25, -- frequency, set to negative to inverse direction of rotation. Default value is 0.25;
	},
	
}
```