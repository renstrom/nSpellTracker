local _, addon = ...
if addon.playerClass ~= 'MAGE' then return end

-- addon:Cooldown(44481, {
	-- cdType = 'item',
	-- position = {'CENTER', 'UIParent', 'CENTER', 150, 70},
	-- size = 50,
	-- visibilityState = '[petbattle] [vehicleui] hide; show',
	-- hideOutOfCombat = false,
    -- alpha = {
        -- active = 1,
        -- inactive = 0,
    -- },
	-- glowOverlay = {
		-- shineType = 'PixelGlow',
		-- reqAlpha = 0.5, --required alpha level to show, default is zero
		-- color = {242, 5/255, 5/255, 1}, --  Default value is {0.95, 0.95, 0.32, 1}
		-- numLines = 8, --default is 8
		-- frequency = 0.25, -- frequency, set to negative to inverse direction of rotation. Default value is 0.25;
		-- lineLength = nil, --length of lines, common is 10-15. Default = nil, will set line length depending on dimensions of glow frame
		-- lineThickness = 2, --line thickness, default value is 1
		-- xOffset = 0, --- offset of glow relative to region border;
		-- yOffset = 0, --- offset of glow relative to region border;
		-- border = false,  -- set to true to create border under lines;
	-- },
-- })