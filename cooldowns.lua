local _, addon = ...
local cfg = addon.cfg

local function GetAlpha(self, duration)
	local alpha = self.alpha.active
	
	if self.Icon.Cooldown:GetCooldownDuration() <= 0 then
		alpha = self.alpha.inactive
	end
	
	if self.peekAlpha then
		if self.peekAlpha.notCooldown and self.Icon.Cooldown:GetCooldownDuration() <= 0 then
			--spell not on cooldown
			alpha = self.peekAlpha.notCooldown.icon or alpha
		elseif self.peekAlpha.cooldown and self.Icon.Cooldown:GetCooldownDuration() > 0 then
			--spell on cooldown
			alpha = self.peekAlpha.cooldown.icon or alpha
		end
	end
	
	if self.hideOutOfCombat and not InCombatLockdown() then
		alpha = self.alpha.inactive
	end
	
	return alpha
end

local function UpdateCooldown(self)
	
	local start, duration, enable
	
	if not self.cdType or self.cdType == 'spell' then
		start, duration, enable = GetSpellCooldown(self.spellID)
	elseif self.cdType and self.cdType == 'item' then
		start, duration, enable = GetItemCooldown(self.spellID)
	end
	
	local charges, maxCharges, chargeStart, chargeDuration = GetSpellCharges(self.spellID)
	
	if maxCharges ~= nil and maxCharges > 1 then
		self.Icon.Count:SetText(charges)
	else
		self.Icon.Count:SetText('')
	end
	
	if charges and maxCharges and maxCharges > 1 and charges < maxCharges then
		StartChargeCooldown(self.Icon, chargeStart, chargeDuration)
	else
		ClearChargeCooldown(self.Icon)
	end
	
	if not self.globalCooldown or (self.globalCooldown and duration > self.globalCooldown) then
		CooldownFrame_Set(self.Icon.Cooldown, start, duration, enable)
	end
	
	if self.desaturate and self.Icon.Cooldown:GetCooldownDuration() > 0 then
		self.Icon.Texture:SetDesaturated(true)
	else
		self.Icon.Texture:SetDesaturated(false)
	end
	
	--check icon just in case
	if not self.iconTexture and self.cdType and self.cdType == 'item' then
		local itemTex = select(10, GetItemInfo(self.rootSpellID))
		if itemTex and itemTex ~= self.Icon.Texture:GetTexture() then
			self.Icon.Texture:SetTexture(itemTex)
		end
	end
	
	local alpha = GetAlpha(self, duration)
	self.Icon:SetAlpha(alpha)
	
	addon:SetGlow(self, alpha)
	
	--set on cooldown done to clear the icon
	if not self.hooked then
		self.hooked = true
		self.Icon.Cooldown:HookScript("OnCooldownDone", function() 
			self.Icon:SetAlpha(0)
			--clear the flash that happens afterwards
			CooldownFrame_Clear(self.Icon.Cooldown)
		end)
	end
	
	if duration and self.PostUpdateHook then
		self:PostUpdateHook()
	end
end

local function ScanCooldowns(self, event, ...)
	for _, self in pairs(addon.cooldowns) do
		if self:IsCurrentSpec() or (self.verifySpell and FindSpellBookSlotBySpellID(self.spellID)) then
			UpdateCooldown(self)
		else
			self.Icon:SetAlpha(0)
		end
	end
end

local events = CreateFrame('Frame')
events:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
events:RegisterEvent('PLAYER_REGEN_DISABLED')
events:RegisterEvent('PLAYER_REGEN_ENABLED')
events:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED')
events:RegisterEvent('SPELL_UPDATE_CHARGES')
events:RegisterEvent('SPELL_UPDATE_COOLDOWN')
events:RegisterEvent('SPELL_UPDATE_USABLE')
events:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
events:RegisterEvent("BAG_UPDATE_COOLDOWN")
events:RegisterEvent("PET_BAR_UPDATE_COOLDOWN")
events:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
events:RegisterEvent("UNIT_SPELLCAST_SENT")
events:RegisterEvent("LOSS_OF_CONTROL_ADDED")
events:RegisterEvent("LOSS_OF_CONTROL_UPDATE")

events:SetScript('OnEvent', ScanCooldowns)