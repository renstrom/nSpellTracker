--[[

	Heavily modified and refactored addon based on Zork's rFilter3.

]]--

local _, addon = ...
local config = addon.config

-- Global variable gather all frames that can be moved ingame, will be accessed by slash command function later
local Frames = {}

local floor = math.floor
local format = string.format

local GetFormattedTime = function(time)
	local hr, m, s, text

	if time <= 0 then
		text = ''
	elseif config.updatetime <= 0.1 and time < 3 then
		text = format('%.1f', time)
	elseif time < 60 then
		m = floor(time / 60)
		s = mod(time, 60)
		text = m == 0 and format('%ds', s)
	elseif time < 3600 then
		hr = floor(time / 3600)
		m = floor(mod(time, 3600) / 60 + 1)
		text = format('%dm', m)
	else
		hr = floor(time / 3600 + 1)
		text = format('%dh', hr)
	end

	return text
end

local ApplySize = function(i)
	local w = i:GetWidth()

	if w < i.data.size then
		w = i.data.size
	end

	i:SetSize(w, w)

	i.glow:SetPoint('TOPLEFT', i, 'TOPLEFT', -w*3.3/32, w*3.3/32)
	i.glow:SetPoint('BOTTOMRIGHT', i, 'BOTTOMRIGHT', w*3.3/32, -w*3.3/32)

	i.icon:SetPoint('TOPLEFT', i, 'TOPLEFT', w*3/32, -w*3/32)
	i.icon:SetPoint('BOTTOMRIGHT', i, 'BOTTOMRIGHT', -w*3/32, w*3/32)

	i.time:SetFont(STANDARD_TEXT_FONT, w*16/36, 'THINOUTLINE')
	i.time:SetPoint('BOTTOM', 0, 0)

	i.count:SetFont(STANDARD_TEXT_FONT, w*18/32, 'OUTLINE')
	i.count:SetPoint('TOPRIGHT', 0, 0)
end

local IsCurrentSpec = function(spec)
	if type(spec) == 'table' then
		for _, v in ipairs(spec) do
			if v == GetSpecialization() then
				return true
			end
		end

		return false
	end

	return spec == GetSpecialization()
end

local GetspellID = function(spellID)
	return type(spellID) == 'table' and spellID[1] or spellID
end

-- Generate the frame name if a global one is needed
local function MakeFrameName(f, t)
	if not f.movable then
		--return nil
	end

	local _, class = UnitClass('player')
	local spec = type(f.spec) == 'table' and f.spec[1] or f.spec and f.spec or 'None'

	return 'nSpellTracker'..t..'Frame'..f:GetSpellID()..'Spec'..spec..class
end

local UnlockFrame = function(i)
	-- Only show icons that are visible for the current spec
	if i.data.spec and not i.data:IsCurrentSpec() then
		return
	end

	i.locked = false
	i.dragtexture:SetAlpha(0.2)

	if i.data.movable then
		i:EnableMouse(true)
		i:RegisterForDrag('LeftButton','RightButton')

		i:SetScript('OnEnter', function(self)
			GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
			GameTooltip:AddLine(self:GetName(), 0, 1, 0.5, 1, 1, 1)
			GameTooltip:AddLine('Left mouse + alt + shift to drag', 1, 1, 1, 1, 1, 1)
			GameTooltip:AddLine('Right mouse + alt + shift to size', 1, 1, 1, 1, 1, 1)
			GameTooltip:Show()
		end)

		i:SetScript('OnLeave', function(self)
			GameTooltip:Hide()
		end)

		i:SetScript('OnDragStart', function(self, button)
			if IsAltKeyDown() and IsShiftKeyDown() and button == 'LeftButton' then
				self:StartMoving()
			end

			if IsAltKeyDown() and IsShiftKeyDown() and button == 'RightButton' then
				self:StartSizing()
			end
		end)

		i:SetScript('OnDragStop', function(self)
			self:StopMovingOrSizing()
		end)
	end
end

local LockFrame = function(i)
	i:EnableMouse(nil)
	i.locked = true
	i.dragtexture:SetAlpha(0)
	i:RegisterForDrag(nil)
	i:SetScript('OnEnter', nil)
	i:SetScript('OnLeave', nil)
	i:SetScript('OnDragStart', nil)
	i:SetScript('OnDragStop', nil)
end

local function ApplyMoveFunctionality(i)
	if not i.data.movable then
		if i:IsUserPlaced() then
			i:SetUserPlaced(false)
		end

		--return
	end

	local t = i:CreateTexture(nil, 'OVERLAY', nil, 6)
	t:SetAllPoints(i)
	t:SetTexture(0, 1, 0)
	if not i.data.movable then
		t:SetTexture(1, 0, 0)
	end
	t:SetAlpha(0)
	i.dragtexture = t

	if i.data.movable then
		i:SetHitRectInsets(-5, -5, -5, -5)
		i:SetClampedToScreen(true)
		i:SetMovable(true)
		i:SetResizable(true)
		i:SetUserPlaced(true)

		i:SetScript('OnSizeChanged', function(self)
			ApplySize(self)
		end)
	end

	-- Lock frame by default
	LockFrame(i)

	-- Load all the frames that can be moved into the global table
	table.insert(Frames, i:GetName())
end

local UnlockAllFrames = function()
	for i, v in ipairs(Frames) do
		UnlockFrame(_G[v])
	end
end

local LockAllFrames = function()
	for i, v in ipairs(Frames) do
		LockFrame(_G[v])
	end
end

local ResetAllFrames = function()
	for i, v in ipairs(Frames) do
		local f = _G[v]
		if f:IsUserPlaced() then
			f:SetPoint(unpack(f.data.position))
			f:SetSize(f.data.size, f.data.size)
		end
	end
end

local framesLocked = true
local function SlashCmd(cmd)
	if cmd:match('reset') then
		ResetAllFrames()
		return
	end

	if framesLocked then
		UnlockAllFrames()
		framesLocked = false
	else
		LockAllFrames()
		framesLocked = true
	end
end

SlashCmdList['nspelltracker'] = SlashCmd;
SLASH_nspelltracker1 = '/nspelltracker';
SLASH_nspelltracker2 = '/nst';
print('|c0033AAFF\/nspelltracker|r or |c0033AAFF\/nst|r to lock/unlock the frames.')

local CreateIcon = function(f, type)
	local name, _, icon, powerCost, isFunnel, powerType, castingTime, minRange, maxRange = GetSpellInfo(GetspellID(f.spellID))

	local i = CreateFrame('Frame', MakeFrameName(f, type), UIParent, 'SecureHandlerStateTemplate')
	i:SetSize(f.size, f.size)
	i:SetPoint(unpack(f.position))

	local glow = i:CreateTexture(nil, 'BACKGROUND', nil, -8)
	glow:SetTexture('Interface\\AddOns\\nSpellTracker\\media\\simplesquare_glow')
	glow:SetVertexColor(0, 0, 0, 1)

	local back = i:CreateTexture(nil, 'BACKGROUND',nil,-7)
	back:SetAllPoints(i)
	back:SetTexture('Interface\\AddOns\\nSpellTracker\\media\\d3portrait_back2')

	local texture = i:CreateTexture(nil, 'BACKGROUND', nil, -6)
	texture:SetTexture(icon)
	texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	texture:SetDesaturated(f.desaturate and 1 or nil)

	local border = i:CreateTexture(nil, 'BACKGROUND', nil, -4)
	border:SetTexture('Interface\\AddOns\\nSpellTracker\\media\\simplesquare_roth')
	border:SetVertexColor(0.37, 0.3, 0.3, 1)
	border:SetAllPoints(i)

	local time = i:CreateFontString(nil, 'BORDER')
	time:SetTextColor(1, 0.8, 0)

	local count = i:CreateFontString(nil, 'BORDER')
	count:SetTextColor(1, 1, 1)
	count:SetJustifyH('RIGHT')

	i.glow = glow
	i.border = border
	i.back = back
	i.position = f.position
	i.time = time
	i.count = count
	i.icon = texture
	i.data = f

	ApplySize(i)
	ApplyMoveFunctionality(i)

	if f.visibilityState then
		RegisterStateDriver(i, 'visibility', f.visibilityState)
	end

	f.iconframe = i
	f.name = name
	f.texture = icon
end

local CheckAura = function(f, spellID, filter)
	-- Make the icon visible in case we want to move it
	if not f.iconframe.locked then
		f.iconframe.icon:SetAlpha(1)
		f.iconframe:SetAlpha(1)
		f.iconframe.icon:SetDesaturated(nil)
		f.iconframe.time:SetText('30m')
		f.iconframe.count:SetText('3')
		return
	end

	if f.spec and not f:IsCurrentSpec() then
		f.iconframe:SetAlpha(0)
		return
	end

	if not UnitExists(f.unit) and f.validateUnit then
		f.iconframe:SetAlpha(0)
		return
	end

	if not InCombatLockdown() and f.hideOutOfCombat then
		if addon:Round(f.iconframe:GetAlpha(), 1) ~= 0 then
			securecall('UIFrameFadeOut', f.iconframe, 0.25, f.iconframe:GetAlpha(), 0)
		end
		return
	end

	local tmp_spellID = f.spellID
	if spellID then
		-- spellID gets overwritten for spell_lists
		tmp_spellID = spellID

		local name, _, icon = GetSpellInfo(spellID)
		if name then
			f.name = name
			f.iconframe.icon:SetTexture(icon)
		end
	end

	if f.name then
		local name, _, _, count, _, _, expires, caster, _, _, auraID = UnitAura(f.unit, f.name, nil, filter)
		if name and (not f.isMine or (f.isMine and caster == 'player')) and (not f.matchspellID or (f.matchspellID and auraID == tmp_spellID)) then
			if caster == 'player' and config.highlightPlayerSpells then
				f.iconframe.border:SetVertexColor(0.2, 0.6, 0.8, 1)
			elseif config.highlightPlayerSpells then
				f.iconframe.border:SetVertexColor(0.37, 0.3, 0.3, 1)
			end

			f.iconframe.icon:SetAlpha(f.alpha.found.icon)
			f.iconframe:SetAlpha(f.alpha.found.frame)

			-- Exit the spell list search loop
			if spellID then
				f.auraFound = true
			end

			if f.desaturate then
				f.iconframe.icon:SetDesaturated(nil)
			end

			--local value = floor((expires-GetTime())*10+0.5)/10
			if count and count > 1 then
				f.iconframe.count:SetText(count)
			else
				f.iconframe.count:SetText('')
			end

			local value = expires - GetTime()
			if value < 10 then
				f.iconframe.time:SetTextColor(1, 0.4, 0)
			else
				f.iconframe.time:SetTextColor(1, 0.8, 0)
			end

			f.iconframe.time:SetText(GetFormattedTime(value))
		else
			f.iconframe:SetAlpha(f.alpha.notFound.frame)
			f.iconframe.icon:SetAlpha(f.alpha.notFound.icon)

			if spellID then
				f.iconframe.icon:SetTexture(f.texture)
			end

			f.iconframe.time:SetText('')
			f.iconframe.count:SetText('')
			f.iconframe.time:SetTextColor(1, 0.8, 0)

			if config.highlightPlayerSpells then
				f.iconframe.border:SetVertexColor(0.37, 0.3, 0.3, 1)
			end

			if f.desaturate then
				f.iconframe.icon:SetDesaturated(1)
			end
		end
	end
end

local CheckCooldown = function(f)
	-- Make the icon visible in case we want to move it
	if not f.iconframe.locked then
		f.iconframe.icon:SetAlpha(1)
		f.iconframe:SetAlpha(1)
		f.iconframe.icon:SetDesaturated(nil)
		f.iconframe.time:SetText('30m')
		f.iconframe.count:SetText('3')
		return
	end

	if f.spec and not IsCurrentSpec(f.spec) then
		f.iconframe:SetAlpha(0)
		return
	end

	if not InCombatLockdown() and f.hideOutOfCombat then
		if addon:Round(f.iconframe:GetAlpha(), 1) ~= 0 then
			securecall('UIFrameFadeOut', f.iconframe, 0.25, f.iconframe:GetAlpha(), 0)
		end
		return
	end

	if f.name and f.spellID then
		local start, duration, _ = GetSpellCooldown(f:GetSpellID())

		if start and duration then
			local now = GetTime()
			local value = start + duration - now

			if value > 0 and duration > 2 then
				-- Item is on cooldown show time
				f.iconframe.icon:SetAlpha(f.alpha.cooldown.icon)
				f.iconframe:SetAlpha(f.alpha.cooldown.frame)
				f.iconframe.count:SetText('')
				f.iconframe.border:SetVertexColor(0.37, 0.3, 0.3, 1)

				if f.desaturate then
					f.iconframe.icon:SetDesaturated(1)
				end

				if value < 10 then
					f.iconframe.time:SetTextColor(1, 0.4, 0)
				else
					f.iconframe.time:SetTextColor(1, 0.8, 0)
				end

				f.iconframe.time:SetText(GetFormattedTime(value))
			else
				f.iconframe:SetAlpha(f.alpha.notCooldown.frame)
				f.iconframe.icon:SetAlpha(f.alpha.notCooldown.icon)
				f.iconframe.time:SetText('RDY')
				f.iconframe.count:SetText('')
				f.iconframe.time:SetTextColor(0, 0.8, 0)
				f.iconframe.border:SetVertexColor(0.4, 0.6, 0.2, 1)

				if f.desaturate then
					f.iconframe.icon:SetDesaturated(nil)
				end
			end
		end
	end
end

local SearchAuras = function(list, filter)
	for i, _ in ipairs(list) do
		local f = list[i]

		if not f.iconframe:IsShown() then
			return
		end

		if type(f.spellID) == 'table' then
			f.auraFound = false

			for _, spellID in ipairs(f.spellID) do
				if not f.auraFound then
					CheckAura(f, spellID, filter)
				end
			end
		else
			CheckAura(f, nil, filter)
		end
	end
end

local SearchCooldowns = function()
	for i, _ in ipairs(config.CooldownList) do
		local f = config.CooldownList[i]

		if not f.iconframe:IsShown() then
			return
		end

		CheckCooldown(f)
	end
end

local count = 0
local GenerateIcons = function(list, type)
	for i, _ in ipairs(list) do
		local f = list[i]

		if not f.icon then
			CreateIcon(f, type)
		end

		count = count + 1
	end
end

GenerateIcons(config.BuffList, 'Buff')
GenerateIcons(config.DebuffList, 'Debuff')
GenerateIcons(config.CooldownList, 'Cooldown')

if count > 0 then
	local a = CreateFrame('Frame')
	local ag = a:CreateAnimationGroup()
	local anim = ag:CreateAnimation()

	anim:SetDuration(config.updatetime)
	ag:SetLooping('REPEAT')

	ag:SetScript('OnLoop', function(self, event, ...)
		SearchAuras(config.BuffList, 'HELPFUL')
		SearchAuras(config.DebuffList, 'HARMFUL')
		SearchCooldowns()
	end)

	ag:Play()
end

--[[
if count > 0 then
	CreateFrame('Frame'):SetScript('OnUpdate', function(self, elapsed)
		self.lastUpdate = self.lastUpdate and (self.lastUpdate + elapsed) or 0

		if self.lastUpdate > config.updatetime then
			SearchAuras(config.BuffList, 'HELPFUL')
			SearchAuras(config.DebuffList, 'HARMFUL')
			SearchCooldowns()
			self.lastUpdate = 0
		end
	end)
end
]]--
