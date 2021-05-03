local _, addon = ...

addon.auras = {}
addon.cooldowns = {}
addon.tempenchants = {}
addon.spells = {}

addon.playerClass = select(2, UnitClass('player'))

addon.cfg = addon.cfg or {
	highlightPlayerSpells = false,
	refreshInterval = 0.1,
	decimalThreshold = 3,
}

local cfg = addon.cfg
local CreateIcon, TrackSpell, UpdateConfig
local LibGlow = LibStub("LibCustomGlow-1.0")

-- Public methods

local function IsNumeric(data)
	if type(data) == "number" then
		return true
	elseif type(data) ~= "string" then
		return false
	end
	data = strtrim(data)
	local x, y = string.find(data, "[%d+][%.?][%d*]")
	if x and x == 1 and y == strlen(data) then
		return true
	end
	if strmatch(data,"%d") then return true end
	return false
end

function addon:GetTimeText(timeLeft)
	if not IsNumeric(timeLeft) then return timeLeft end
	
	local hours, minutes, seconds = 0, 0, 0
	if( timeLeft >= 3600 ) then
		hours = ceil(timeLeft / 3600)
		timeLeft = mod(timeLeft, 3600)
	end
	
	if( timeLeft >= 60 ) then
		minutes = ceil(timeLeft / 60)
		timeLeft = mod(timeLeft, 60)
	end
	
	seconds = timeLeft > 0 and timeLeft or 0
	
	if hours > 0 then
		return string.format("%dh", hours)
	elseif minutes > 0 then
		return string.format("%dm", minutes)
	elseif seconds > 0 then
		return string.format("%ds", seconds)
	else
		return nil
	end
end

function addon:SetGlow(self, alpha)
	if not self.glowOverlay then return end
	if not alpha then return end
	
	local reqAlpha = self.glowOverlay.reqAlpha or 0
	local shineType = self.glowOverlay.shineType or 'Blizzard'
	
	local switch = false
	if reqAlpha > 0 and alpha >= reqAlpha then switch = true end
	if reqAlpha == 0 and alpha > reqAlpha then switch = true end --only display by default if we have alpha greather than zero
	
	if shineType == 'Blizzard' then
		if switch then
			ActionButton_ShowOverlayGlow(self.Icon)
		else
			ActionButton_HideOverlayGlow(self.Icon)
		end
	elseif shineType == 'PixelGlow' then
		local opt = self.glowOverlay
		if switch then
			LibGlow.PixelGlow_Start(self.Icon, opt.color, opt.numLines, opt.frequency, opt.lineLength, opt.lineThickness, opt.xOffset, opt.yOffset, opt.border)
		else
			LibGlow.PixelGlow_Stop(self.Icon, nil)
		end
	elseif shineType == 'AutoCastGlow' then
		local opt = self.glowOverlay
		if switch then
			LibGlow.AutoCastGlow_Start(self.Icon, opt.color, opt.numParticle, opt.frequency, opt.particleScale, opt.xOffset, opt.yOffset)
		else
			LibGlow.AutoCastGlow_Stop(self.Icon, nil)
		end
	elseif shineType == 'ButtonGlow' then
		local opt = self.glowOverlay
		if switch then
			LibGlow.ButtonGlow_Start(self.Icon, opt.color, opt.frequency)
		else
			LibGlow.ButtonGlow_Stop(self.Icon, nil)
		end
	end
end

function addon:Buff(spellID, config)
	local aura = TrackSpell(spellID, 'HELPFUL')
	aura.rootSpellID = spellID
	UpdateConfig(aura, config)
	CreateIcon(aura, self.auras)
	table.insert(self.auras, aura)
end

function addon:Debuff(spellID, config)
	local aura = TrackSpell(spellID, 'HARMFUL')
	aura.unit = 'target'
	aura.rootSpellID = spellID
	UpdateConfig(aura, config)
	CreateIcon(aura, self.auras)
	table.insert(self.auras, aura)
end

function addon:Cooldown(spellID, config)
	local cd = TrackSpell(spellID, nil)
	-- cd.desaturate = true
	cd.rootSpellID = spellID
	cd.cdType = 'spell'
	UpdateConfig(cd, config)
	--overwrite, we don't want to use multiple spellID's
	cd.spellID = spellID
	CreateIcon(cd, self.cooldowns)
	table.insert(self.cooldowns, cd)
end

function addon:TempEnchant(spellID, config)
	local tmpEnch = TrackSpell(spellID, nil)
	tmpEnch.rootSpellID = spellID
	UpdateConfig(tmpEnch, config)
	--overwrite, we don't want to use multiple spellID's
	tmpEnch.spellID = spellID
	CreateIcon(tmpEnch, self.tempenchants)
	table.insert(self.tempenchants, tmpEnch)
end

function addon:Spell(spellID, config)
	local spell = TrackSpell(spellID, nil)
	spell.rootSpellID = spellID
	spell.showOnCooldown = true
	spell.useGlobalCooldown = true
	UpdateConfig(spell, config)
	--overwrite, we don't want to use multiple spellID's
	spell.spellID = spellID
	CreateIcon(spell, self.spells)
	table.insert(self.spells, spell)
end

-- Private

local spell = {}
spell.__index = spell

function spell:IsCurrentSpec()
	if type(self.spec) == 'table' then
		for _, spec in pairs(self.spec) do
			if spec == GetSpecialization() then
				return true
			end
		end
		
		return false
	end
	
	if type(self.spec) == 'string' then
		return GetSpecialization() and GetSpecializationRole(GetSpecialization()) == self.spec
	end
	
	return self.spec == nil or self.spec == GetSpecialization()
end

TrackSpell = function(spellID, filter)
	local t = {}
	setmetatable(t, spell)
	
	-- Internal values
	t.spellID = spellID
	t.filter = filter
	
	-- Set default values
	t.caster = 'player'
	t.desaturate = false
	t.hideOutOfCombat = true
	t.position = {'CENTER'}
	t.size = 36
	t.spec = nil
	t.unit = 'player'
	t.verifySpell = false
	t.visibilityState = '[petbattle] [vehicleui] hide; show'
	
	t.alpha = {
		active = 1,
		inactive = 0.4
	}
	
	return t
end

UpdateConfig = function(old, new)
	for k, v in pairs(new) do
		old[k] = v
	end
end

local function GetFrameName(spellID, addonTbl)
	return string.format('%s%s%s', 'nSpellTracker', #addonTbl, spellID)
end

CreateIcon = function(self, addonTbl)
	local _, _, iconTexture = GetSpellInfo(self.rootSpellID)
	
	--grab the icon from the itemid if using item cooldowns
	if self.cdType and self.cdType == 'item' then
		local itemTex = select(10, GetItemInfo(self.rootSpellID))
		if itemTex then iconTexture = itemTex end
	end
	
	self.Icon = CreateFrame('Frame', GetFrameName(self.rootSpellID, addonTbl), UIParent, 'SecureHandlerStateTemplate')
	self.Icon:SetPoint(unpack(self.position))
	self.Icon:SetSize(self.size, self.size)
	self.Icon:SetAlpha(0)
	
	-- Create cooldown
	local cooldown = CreateFrame('Cooldown', '$parentCooldown', self.Icon, 'CooldownFrameTemplate')
	cooldown:SetAllPoints(self.Icon)
	cooldown:SetEdgeTexture('Interface\\Cooldown\\edge')
	cooldown:SetSwipeColor(0, 0, 0)
	cooldown:SetHideCountdownNumbers(false)
	self.Icon.Cooldown = cooldown -- Needs lowercase 'c' because of ActionButton_UpdateCooldown
	
	local chargeCooldown = CreateFrame('Cooldown', '$parentChargeCooldown', self.Icon, 'CooldownFrameTemplate')
	chargeCooldown:SetAllPoints(self.Icon)
	chargeCooldown:SetHideCountdownNumbers(true)
	chargeCooldown:SetDrawSwipe(false)
	chargeCooldown:SetFrameStrata('TOOLTIP')
	self.Icon.chargeCooldown = chargeCooldown
	
	-- Create texture
	local texture = self.Icon:CreateTexture('$parentTexture', 'BACKGROUND', nil, -6)
	texture:SetAllPoints(self.Icon)
	texture:SetTexture(self.iconTexture or iconTexture or 135986) --135986 = seal of wrath
	self.Icon.Texture = texture
	
	-- Create border glow
	local glow = self.Icon:CreateTexture('$parentGlow', 'BACKGROUND', nil, -8)
	glow:SetTexture('Interface\\AddOns\\nSpellTracker\\media\\simplesquare_glow')
	glow:SetVertexColor(0, 0, 0, 1)
	glow:SetPoint('TOPLEFT', self.Icon, 'TOPLEFT', -self.size*3.3/32, self.size*3.3/32)
	glow:SetPoint('BOTTOMRIGHT', self.Icon, 'BOTTOMRIGHT', self.size*3.3/32, -self.size*3.3/32)
	self.Icon.Glow = glow
	
	-- Create border
	local border = self.Icon:CreateTexture('$parentBorder', 'BACKGROUND', nil, -4)
	border:SetTexture('Interface\\AddOns\\nSpellTracker\\media\\simplesquare_roth')
	border:SetVertexColor(0.37, 0.3, 0.3, 1)
	border:SetAllPoints(self.Icon)
	self.Icon.Border = border
	
	-- Stacks/count
	local count = self.Icon:CreateFontString('$parentCount', 'OVERLAY')
	count:SetFontObject(NumberFontNormal)
	count:SetPoint('BOTTOMRIGHT', self.Icon, 'BOTTOMRIGHT', 0, 0)
	self.Icon.Count = count
	
	-- Duration (auras only)
	local duration = self.Icon:CreateFontString('$parentDuration', 'OVERLAY')
	duration:SetFontObject(NumberFontNormal)
	duration:SetPoint('CENTER', self.Icon, 'CENTER', 0, 0)
	self.Icon.Duration = duration
	
	-- Set visibility
	if self.visibilityState then
		RegisterStateDriver(self.Icon, 'visibility', self.visibilityState)
	end
end

local events = CreateFrame('Frame')
events:SetScript('OnUpdate', function(self, elapsed)
	self.delta = (self.delta or 0) + elapsed
	if self.delta >= cfg.refreshInterval then
		self.delta = self.delta - cfg.refreshInterval
		if addon.ScanAuras then addon.ScanAuras() end
		if addon.ScanTempEnchants then addon.ScanTempEnchants() end
		if addon.ScanSpells then addon.ScanSpells() end
	end
end)