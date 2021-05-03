local _, addon = ...
if addon.playerClass ~= 'HUNTER' then return end

--Kill Shot
addon:Spell(53351, {
    position = {'CENTER', 'UIParent', 'CENTER', -220, 210},
	size = 50,
	hideOutOfCombat = false,
	visibilityState = '[petbattle] [vehicleui] hide; show',
	showOnCooldown = false,
	alpha = {
		active = 1, --default is 1
		inactive = 0, --default is 0.4
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
