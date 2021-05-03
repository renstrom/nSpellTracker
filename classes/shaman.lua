local _, addon = ...
if addon.playerClass ~= 'SHAMAN' then return end

local elemental, enhancement, restoration = 1, 2, 3 

-- Lightning Shield
addon:Buff(192106, {
    position = {'CENTER', 'UIParent', 'CENTER', 200, 350},
	size = 50,
	spec = elemental,
	hideOutOfCombat = false,
	visibilityState = '[petbattle] [vehicleui] hide; show',
	peekAlpha = {
		found = {
			icon = 0,
		},
		notFound = {
			icon = 1,
		},
	},
	glowOverlay = {
		shineType = 'AutoCastGlow',
		reqAlpha = 0.5, --required alpha level to show, default is zero
		color = {0, 1, 118/255, 1}, --  Default value is {0.95, 0.95, 0.32, 1}
		numParticle = 8, --default is 8, number of particles to show
		frequency = 0.25, -- frequency, set to negative to inverse direction of rotation. Default value is 0.25;
		particleScale = 1, --scale of the particles, default is 1
		xOffset = 0, --- offset of glow relative to region border;
		yOffset = 0, --- offset of glow relative to region border;
	},
})

-- Water Shield
addon:Buff(52127, {
    position = {'CENTER', 'UIParent', 'CENTER', 200, 350},
	size = 50,
	spec = restoration,
	hideOutOfCombat = false,
	visibilityState = '[petbattle] [vehicleui] hide; show',
	peekAlpha = {
		found = {
			icon = 0,
		},
		notFound = {
			icon = 1,
		},
	},
	glowOverlay = {
		shineType = 'AutoCastGlow',
		reqAlpha = 0.5, --required alpha level to show, default is zero
		color = {0, 1, 118/255, 1}, --  Default value is {0.95, 0.95, 0.32, 1}
		numParticle = 8, --default is 8, number of particles to show
		frequency = 0.25, -- frequency, set to negative to inverse direction of rotation. Default value is 0.25;
		particleScale = 1, --scale of the particles, default is 1
		xOffset = 0, --- offset of glow relative to region border;
		yOffset = 0, --- offset of glow relative to region border;
	},
})

--Flametongue Weapon
addon:TempEnchant(5400, {
    position = {'CENTER', 'UIParent', 'CENTER', 255, 350},
	size = 50,
	hideOutOfCombat = false,
	iconTexture = 135814,
	visibilityState = '[petbattle] [vehicleui] hide; show',
	peekAlpha = {
		found = {
			icon = 0,
		},
		notFound = {
			icon = 1,
		},
	},
	glowOverlay = {
		shineType = 'AutoCastGlow',
		reqAlpha = 0.5, --required alpha level to show, default is zero
		color = {242, 5/255, 5/255, 1}, --  Default value is {0.95, 0.95, 0.32, 1}
		numParticle = 8, --default is 8, number of particles to show
		frequency = 0.25, -- frequency, set to negative to inverse direction of rotation. Default value is 0.25;
		particleScale = 1, --scale of the particles, default is 1
		xOffset = 0, --- offset of glow relative to region border;
		yOffset = 0, --- offset of glow relative to region border;
	},
})

--Earthquake
addon:Spell(61882, {
    position = {'CENTER', 'UIParent', 'CENTER', -220, 210},
	size = 50,
	spec = elemental,
	hideOutOfCombat = false,
	visibilityState = '[petbattle] [vehicleui] hide; show',
	peekAlpha = {
		usable = {
			icon = 1, --spell is usable
		},
		notUsable = {
			icon = 0, --spell not usable
		},
	},
	glowOverlay = {
		shineType = 'PixelGlow',
		reqAlpha = 0.5, --required alpha level to show, default is zero
		--color = {1, 1, 0, 1}, -- Default value is {0.95, 0.95, 0.32, 1}
		color = {0, 1, 118/255, 1}, -- Default value is {0.95, 0.95, 0.32, 1}
		numLines = 8, --default is 8
		frequency = 0.4, -- frequency, set to negative to inverse direction of rotation. Default value is 0.25;
		lineLength = nil, --length of lines, common is 10-15. Default = nil, will set line length depending on dimensions of glow frame
		lineThickness = 3, --line thickness, default value is 1
		xOffset = 0, --- offset of glow relative to region border;
		yOffset = 0, --- offset of glow relative to region border;
		border = false, -- set to true to create border under lines;
	},
})
