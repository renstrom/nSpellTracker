local _, addon = ...
local cfg = addon.cfg
local spellOverlayGlow = {}

local function checkUsable(self, spellID)

	--check our overlay if enabled before anything else
	if self.showOnlyOnOverlayGlow then
		if spellOverlayGlow[spellID] then
			return true
		end
		return false
	end
	
	local start, duration = GetSpellCooldown(spellID)
	
	--this is a dummy spell to check for global cooldown
	--https://wowpedia.fandom.com/wiki/API_GetSpellCooldown
	local gcdSTART, gcdDUR = GetSpellCooldown(61304)

	--do this switch before our calculation extender below
	local isGCD = false
	
	--if our spell durations match the global cooldown durations then it's the global cooldown and not the spell cooldown
	if gcdSTART and gcdSTART == start and gcdDUR and gcdDUR == duration then
		isGCD = true
	end
	
	if self.useGlobalCooldown then
		if ((gcdSTART or 0) + (gcdDUR or 0) > start + duration) then
			start = gcdSTART
			duration = gcdDUR
		end
	end

	local charges = GetSpellCharges(spellID)
	if (charges == nil) then
		charges = (duration == 0) and 1 or 0
	end
	local ready = start == 0 or charges > 0 or isGCD
	
	if self.showOnCooldown and start > 0 then
		ready = true
	elseif not self.showOnCooldown and start > 0 and not isGCD then
		ready = false
	end

	return IsUsableSpell(spellID) and ready
end

local function GetAlpha(self, spellID, isUsable)
	local alpha = self.alpha.active
	
	if not isUsable then
		alpha = self.alpha.inactive
	end

	if self.peekAlpha then
		if self.peekAlpha.notUsable and not isUsable then
			--spell not usable
			alpha = self.peekAlpha.notUsable.icon or alpha
		elseif self.peekAlpha.usable and isUsable then
			--spell usable
			alpha = self.peekAlpha.usable.icon or alpha
		end
	end
	
	if self.verifySpell and spellID and not FindSpellBookSlotBySpellID(spellID) then
		alpha = self.alpha.inactive
	end
	
	if self.hideOutOfCombat and not InCombatLockdown() then
		alpha = self.alpha.inactive
	end
	
	return alpha
end

local function UpdateSpells(self)
	if not self.spellID then return end
	if self.validateUnit and not UnitExists(self.unit) then return end
	
	local name, _, icon = GetSpellInfo(self.spellID)
	local isUsable = checkUsable(self, self.spellID)

	if self.desaturate then
		self.Icon.Texture:SetDesaturated(not durationText)
	end
	
	if not self.iconTexture and icon and icon ~= self.Icon.Texture:GetTexture() then
		self.Icon.Texture:SetTexture(icon)
	end
	
	local alpha = GetAlpha(self, self.spellID, isUsable)
	self.Icon:SetAlpha(alpha)

	addon:SetGlow(self, alpha)
	
	if duration and self.PostUpdateHook then
		self:PostUpdateHook()
	end
end

local function ScanSpells()
	for _, self in pairs(addon.spells) do
		if self:IsCurrentSpec() then
			UpdateSpells(self)
		else
			self.Icon:SetAlpha(0)
		end
	end
end

local events = CreateFrame("Frame")
events:SetScript("OnEvent", function(self, event, spellID)
	if not spellID then return end
	
	if event == "SPELL_ACTIVATION_OVERLAY_GLOW_SHOW" then
		spellOverlayGlow[spellID] = true
	elseif event == "SPELL_ACTIVATION_OVERLAY_GLOW_HIDE" then
		spellOverlayGlow[spellID] = nil
	end
end)
events:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
events:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE")


addon.ScanSpells = ScanSpells
