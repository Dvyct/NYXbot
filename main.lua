local localPlayer = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera
local UIS = game:GetService("UserInputService")

-- Aimbot settings
_G.AimbotKey = Enum.KeyCode.E
_G.AimbotEnabled = false
_G.AimbotPart = "Head"  -- Default aimbot part
_G.StickyAimEnabled = false

-- Function to check if a player is on the same team
local function isPlayerOnSameTeam(player)
	if player and player.Team then
		return player.Team == localPlayer.Team
	end
	return false
end

local currentTarget = nil
local aim = false

local function findNearestPlayer()
	local closestPlayer = nil
	local closestDistance = math.huge

	for _, player in ipairs(game.Players:GetPlayers()) do
		if player ~= localPlayer and player.Character and player.Character:FindFirstChild(_G.AimbotPart) then
			-- Check if the player is not on the same team
			if not isPlayerOnSameTeam(player) then
				local character = player.Character
				local targetPart = character[_G.AimbotPart]

				-- Calculate the screen position of the target part
				local targetScreenPos, onScreen = camera:WorldToScreenPoint(targetPart.Position)

				if onScreen then
					-- Calculate the distance from the mouse position to the target part
					local mousePos = UIS:GetMouseLocation()
					local distance = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(targetScreenPos.X, targetScreenPos.Y)).Magnitude

					-- Update the closest player if this player is closer
					if distance < closestDistance then
						closestPlayer = player
						closestDistance = distance
					end
				end
			end
		end
	end

	return closestPlayer
end

game:GetService("RunService").RenderStepped:Connect(function()
	if aim then
		local targetPlayer = currentTarget or findNearestPlayer()

		if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild(_G.AimbotPart) then
			if _G.AimbotEnabled == true then
				local targetPart = targetPlayer.Character[_G.AimbotPart]

				-- Calculate the screen position of the target part
				local targetScreenPos, onScreen = camera:WorldToScreenPoint(targetPart.Position)

				if onScreen then
					-- Update the mouse position to aim at the target
					UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
					UIS:SetMouseLocation(targetScreenPos.X, targetScreenPos.Y)
				end

				if _G.StickyAimEnabled then
					currentTarget = targetPlayer
				end
			else
				currentTarget = nil
			end
		else
			currentTarget = nil
		end
	end
end)

UIS.InputBegan:Connect(function(input, processed)
	if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == _G.AimbotKey and not processed then
		aim = true
	end
end)

UIS.InputEnded:Connect(function(input, processed)
	if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == _G.AimbotKey and not processed then
		aim = false
		UIS.MouseBehavior = Enum.MouseBehavior.Default
		currentTarget = nil  -- Reset the current target when aim key is released
	end
end)
