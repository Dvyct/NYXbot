local localPlayer = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Aimbot settings
_G.AimbotKey = Enum.KeyCode.V
_G.AimbotEnabled = true
_G.AimbotPart = "Head"
_G.StickyAimEnabled = true
_G.AimbotSensitivity = 0.2 -- 0 to 1 (higher values are more responsive)
_G.TeamCheck = true
_G.FovCircleVisible = true
_G.FovCircleRadius = 250
_G.AimedLineVisible = false
_G.BulletSpeed = 820

-- Aimbot FOV Circle
local FOV = Drawing.new("Circle")
FOV.Color = Color3.new(0, 0, 0)
FOV.Thickness = 1
FOV.Transparency = 1
FOV.Filled = false
FOV.Radius = _G.FovCircleRadius
FOV.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

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
            if not _G.TeamCheck or (_G.TeamCheck and not isPlayerOnSameTeam(player)) then
                local character = player.Character
                local targetPart = character[_G.AimbotPart]
                local targetScreenPos, onScreen = camera:WorldToScreenPoint(targetPart.Position)

                if onScreen then
                    local mousePos = UIS:GetMouseLocation()
                    local distance = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(targetScreenPos.X, targetScreenPos.Y)).Magnitude
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

local function getPredictedPosition(targetPart, bulletSpeed)
    local targetVelocity = targetPart.Velocity
    local targetPosition = targetPart.Position
    local distance = (targetPosition - camera.CFrame.Position).Magnitude
    local timeToHit = distance / bulletSpeed
    local predictedPosition = targetPosition + (targetVelocity * timeToHit)
    return predictedPosition
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
                local predictedPosition = getPredictedPosition(targetPart, _G.BulletSpeed)
                local cameraPosition = camera.CFrame.Position
                local aimDirection = (predictedPosition - cameraPosition).unit

                local targetCFrame = CFrame.new(cameraPosition, cameraPosition + aimDirection)
                camera.CFrame = camera.CFrame:Lerp(targetCFrame, _G.AimbotSensitivity)

                local predictedScreenPos, onScreen = camera:WorldToScreenPoint(predictedPosition)
                if onScreen then
                    AimedLine.To = Vector2.new(predictedScreenPos.X, predictedScreenPos.Y)
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
        currentTarget = nil
        AimedLine.To = AimedLine.From
    end
end)
