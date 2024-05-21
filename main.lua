local localPlayer = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- Aimbot settings
_G.AimbotKey = Enum.KeyCode.V
_G.AimbotEnabled = true
_G.AimbotPart = "Head"  -- custom
_G.StickyAimEnabled = true
_G.AimbotSensitivity = 1 -- 0 to 1
_G.TeamCheck = true
_G.FovCircleVisible = true
_G.FovCircleRadius = 250
_G.AimedLineVisible = true
-- Aimbot FOV Circle
local FOV = Drawing.new("Circle")
FOV.Color = Color3.new(0, 0, 0)
FOV.Thickness = 1
FOV.Transparency = 1
FOV.Filled = false
FOV.Radius = _G.FovCircleRadius  -- Default FOV radius
FOV.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2) 

local AimedLine = Drawing.new("Line")
AimedLine.Color = Color3.new(1, 1, 1)
AimedLine.Thickness = 1
AimedLine.Transparency = 1

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
            -- Check if the player is not on the same team if TeamCheck is enabled
            if not _G.TeamCheck or (_G.TeamCheck and not isPlayerOnSameTeam(player)) then
                local character = player.Character
                local targetPart = character[_G.AimbotPart]

                -- Calculate the screen position of the target part
                local targetScreenPos, onScreen = camera:WorldToScreenPoint(targetPart.Position)

                if onScreen then
                    -- Calculate the distance from the mouse position to the target part
                    local mousePos = UIS:GetMouseLocation()
                    local distance = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(targetScreenPos.X, targetScreenPos.Y)).Magnitude
                    -- Update the closest player if this player is closer and within the Aimbot FOV
                    if distance < closestDistance and distance <= FOV.Radius * 1.2 then
                        closestPlayer = player
                        closestDistance = distance
                    end
                end
            end
        end
    end

    return closestPlayer
end

RunService.RenderStepped:Connect(function()
    FOV.Position = UIS:GetMouseLocation()
    AimedLine.From = FOV.Position
    FOV.Visible = _G.FovCircleVisible
    AimedLine.Visible = _G.AimedLineVisible
    FOV.Radius = _G.FovCircleRadius
    if aim then
        local targetPlayer = currentTarget or findNearestPlayer()

        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild(_G.AimbotPart) then
            if _G.AimbotEnabled == true then
                local targetPart = targetPlayer.Character[_G.AimbotPart]

                -- Calculate the new camera CFrame to aim at the target
                local targetPosition = targetPart.Position
                local cameraPosition = camera.CFrame.Position
                local aimDirection = (targetPosition - cameraPosition).unit

                -- Interpolate the camera CFrame towards the target
                local newCFrame = CFrame.new(cameraPosition, cameraPosition + aimDirection)
                camera.CFrame = camera.CFrame:Lerp(newCFrame, _G.AimbotSensitivity)

                -- Update the aimed line to point to the target part
                local targetScreenPos, onScreen = camera:WorldToScreenPoint(targetPart.Position)
                if onScreen then
                    AimedLine.To = Vector2.new(targetScreenPos.X, targetScreenPos.Y) 
                else
                    AimedLine.To = AimedLine.From
                end

                if _G.StickyAimEnabled then
                    currentTarget = targetPlayer
                end
            else
                currentTarget = nil
                AimedLine.To = AimedLine.From
            end
        else
            currentTarget = nil
            AimedLine.To = AimedLine.From
        end
    else
        AimedLine.To = AimedLine.From
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
        currentTarget = nil  -- Reset the current target when aim key is released
        AimedLine.To = AimedLine.From
    end
end)
