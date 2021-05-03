local _, addon = ...
local cfg = addon.cfg

local function Round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

local function GetAlpha(self, duration, hasEnchant)
	local alpha = self.alpha.active
	
	if duration == 0 then
		alpha = self.alpha.inactive
	end
	
	if not hasEnchant then
		alpha = self.alpha.inactive
	end
	
	if self.peekAlpha then
		if self.peekAlpha.notFound and not hasEnchant then
			--enchant not found
			alpha = self.peekAlpha.notFound.icon or alpha
		elseif self.peekAlpha.found and hasEnchant then
			--enchant found
			alpha = self.peekAlpha.found.icon or alpha
		end
	end
	
	if self.hideOutOfCombat and not InCombatLockdown() then
		alpha = self.alpha.inactive
	end
	
	return alpha
end

local function UpdateTempEnchant(self)
	if not self.spellID then return end
	if self.validateUnit and not UnitExists(self.unit) then return end
	
	local duration, iconTexture
	local hasEnchant = true
	local hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantID, hasOffHandEnchant, offHandExpiration, offHandCharges, offHandEnchantID = GetWeaponEnchantInfo()
	local mhExp = mainHandExpiration and (mainHandExpiration / 1000)
	local ohExp = offHandExpiration and (offHandExpiration / 1000)
	
	if mainHandEnchantID and mainHandEnchantID == self.spellID then
		duration = mhExp
		iconTexture = GetInventoryItemTexture("player", GetInventorySlotInfo("MainHandSlot"))
	elseif offHandEnchantID and offHandEnchantID == self.spellID then
		duration = ohExp
		iconTexture = GetInventoryItemTexture("player", GetInventorySlotInfo("SecondaryHandSlot"))
	else
		hasEnchant = false
	end
	
	if duration and duration > 0 and duration < cfg.decimalThreshold then
		self.Icon.Duration:SetTextColor(1, 0, 0, 1)
	else
		self.Icon.Duration:SetTextColor(1, 1, 1, 1)
	end
	
	local durationText = ''
	if duration and duration > 0 then
		durationText = (duration == math.huge) and 'Inf' or duration
	end
	self.Icon.Duration:SetText(addon:GetTimeText(durationText))
	
	if self.desaturate then
		self.Icon.Texture:SetDesaturated(not durationText)
	end
	
	if not self.iconTexture and iconTexture and iconTexture ~= self.Icon.Texture:GetTexture() then
		self.Icon.Texture:SetTexture(iconTexture)
	end
	
	local alpha = GetAlpha(self, duration, hasEnchant)
	self.Icon:SetAlpha(alpha)
	
	addon:SetGlow(self, alpha)
	
	if duration and self.PostUpdateHook then
		self:PostUpdateHook()
	end
	
end

local function ScanTempEnchants()
	for _, self in pairs(addon.tempenchants) do
		if self:IsCurrentSpec() then
			UpdateTempEnchant(self)
		else
			self.Icon:SetAlpha(0)
		end
	end
end

addon.ScanTempEnchants = ScanTempEnchants
