local _, Engine = ...
local Module = Engine:NewModule("VehicleSeatIndicator")

-- Lua API
local unpack = unpack

Module.OnInit = function(self)
	local content = VehicleSeatIndicator
	if not content then
		return
	end

	local config = self:GetStaticConfig("Blizzard").vehicleseat

	local point, anchor, rpoint, x, y = unpack(config.position)
	if anchor == "UICenter" then
		anchor = Engine:GetFrame()
	end

	local holder = CreateFrame("Frame", nil, Engine:GetFrame())
	holder:SetPoint(point, anchor, rpoint, x, y)
	holder:SetWidth(content:GetWidth())
	holder:SetHeight(content:GetHeight())

	local frameMeta = getmetatable(CreateFrame("Frame")).__index
	local SetPoint = frameMeta.SetPoint
	local ClearAllPoints = frameMeta.ClearAllPoints

	-- If Mappy is enabled, we need to reset objects it's already taken control of.
	if Engine:IsAddOnEnabled("Mappy") then
		content.Mappy_DidHook = true -- set the flag indicating its already been set up for Mappy
		content.Mappy_SetPoint = function() end -- kill the IsVisible reference Mappy makes
		content.Mappy_HookedSetPoint = function() end -- kill this too
		content.SetPoint = nil -- return the SetPoint method to its original metamethod
		content.ClearAllPoints = nil -- return the SetPoint method to its original metamethod
	end

	ClearAllPoints(content)
	SetPoint(content, "BOTTOM", holder, "BOTTOM", 0, 0)

	hooksecurefunc(content, "SetPoint", function(self, _, anchor) 
		if (anchor ~= holder) then
			ClearAllPoints(self)
			SetPoint(self, "BOTTOM", holder, "BOTTOM", 0, 0)
		end
	end)
	
end
