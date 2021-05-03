local _, addon = ...
if addon.playerClass ~= 'MONK' then return end

local brewmaster, mistweaver, windwalker = 1, 2, 3

--Whirling Dragon Punch
addon:Spell(152175, {
    position = {'CENTER', 'UIParent', 'CENTER', -220, 210},
	size = 50,
	spec = windwalker,
	hideOutOfCombat = false,
	verifySpell = true,
	visibilityState = '[petbattle] [vehicleui] hide; show',
	showOnCooldown = false,
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