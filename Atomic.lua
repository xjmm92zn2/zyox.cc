-- NAMECALL BYPASS - ADD THIS AT THE VERY TOP
local oldCheck = checkcaller
checkcaller = function() return true end

-- Hook Mouse.Hit
local mouseMeta = getrawmetatable(Mouse)
local oldMouseIndex = mouseMeta.__index
mouseMeta.__index = newcclosure(function(self, key)
    if not oldCheck() and key == "Hit" and shared.Config and shared.Config.SilentAim and shared.Config.SilentAim.Enabled then
        return CFrame.new(shared.Config.SilentAim.AimPosition or Vector3.new(0,0,0))
    end
    if not oldCheck() and key == "Target" and shared.Config and shared.Config.SilentAim and shared.Config.SilentAim.Enabled then
        return shared.Config.SilentAim.AimPart
    end
    return oldMouseIndex(self, key)
end)

-- Hook RemoteEvents
local function hookRemote(remote)
    if remote and remote:IsA("RemoteEvent") then
        local oldFire = remote.FireServer
        remote.FireServer = newcclosure(function(self, ...)
            if not oldCheck() and shared.Config and shared.Config.SilentAim and shared.Config.SilentAim.Enabled then
                local args = {...}
                for i, v in pairs(args) do
                    if typeof(v) == "Vector3" then
                        args[i] = shared.Config.SilentAim.AimPosition or v
                    elseif typeof(v) == "CFrame" then
                        args[i] = CFrame.new(shared.Config.SilentAim.AimPosition or Vector3.new(0,0,0))
                    end
                end
                return oldFire(self, unpack(args))
            end
            return oldFire(self, ...)
        end)
    end
end

for _, child in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do 
    pcall(hookRemote, child) 
end

-- Hook Raycast
local oldRaycast = Workspace.Raycast
Workspace.Raycast = newcclosure(function(origin, direction, params)
    if not oldCheck() and shared.Config and shared.Config.SilentAim and shared.Config.SilentAim.Enabled then
        if shared.Config.SilentAim.AimPosition then
            direction = (shared.Config.SilentAim.AimPosition - origin).Unit * 10000
        end
    end
    return oldRaycast(origin, direction, params)
end)

-- Hook math.random
local oldRandom = math.random
math.random = newcclosure(function(...)
    if not oldCheck() then
        local args = {...}
        if #args == 2 and args[1] == -0.05 and args[2] == 0.05 then
            if shared.Config and shared.Config.Spread and shared.Config.Spread.Enabled then
                return oldRandom(args[1], args[2]) * (shared.Config.Spread.Amount / 100)
            end
        end
    end
    return oldRandom(...)
end)

print("Namecall bypass active!")

-- lph
local LPH_NO_VIRTUALIZE = function(f) return f end
if not getfenv().LPH_NO_VIRTUALIZE then
    getfenv().LPH_NO_VIRTUALIZE = function(f) return f end
    getfenv().LPH_JIT = function(f) return f end
    getfenv().LPH_JIT_ULTRA = function(f) return f end
    getfenv().LPH_JIT_MAX = function(f) return f end
end

local bypassSuccess, bypassErr = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/AlwaysTappingWith/cuocries/refs/heads/main/Source.lua"))()
end)
if not bypassSuccess then warn("Bypasser failed to load:", bypassErr) end

setfpscap(1000)

-- Services
local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local Workspace = game:GetService('Workspace')
local UserInputService = game:GetService('UserInputService')
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Stats = game:GetService('Stats')
local MarketplaceService = game:GetService('MarketplaceService')
local Lighting = game:GetService('Lighting')
local TweenService = game:GetService('TweenService')
local GuiService = game:GetService('GuiService')
local VirtualInputManager = game:GetService('VirtualInputManager')
local HttpService = game:GetService('HttpService')

-- Configuration Table
local Config = {
    Settings = {
        AlwaysOn = true,
        UseKeybinds = true,
        Platform = 'Mobile',
        Version = '1.0.0',
    },
    SilentAim = {
        Enabled = true,
        Prediction = 0.132,
        Method = 'Raycast',
        Accuracy = 100,
        FOVSize = 80,
        WallCheck = true,
        TeamCheck = false,
        TargetPlayer = nil,
        AimPart = nil,
        AimPosition = nil,
        OverrideYAxis = 'None',
        PredictionAdjustment = 1,
        HitLocation = {
            HitTarget = 'Nearest Point',
            PointScale = 'Dynamic',
            MaxNearestPoint = 2,
            IgnoreBlankPoints = true,
            R15 = {'Head'},
        },
        HitChance = {
            HitChance = 100,
            MissChance = 0,
        },
        PredictionPoints = {
            Enabled = false,
            HitPoints = {
                Head = 0.011,
                UpperTorso = 0.135,
                LowerTorso = 0.127,
                HumanoidRootPart = 0.127,
                LeftUpperArm = 0.127,
                LeftLowerArm = 0.127,
                LeftHand = 0.127,
                RightUpperArm = 0.127,
                RightLowerArm = 0.127,
                RightHand = 0.127,
                LeftUpperLeg = 0.127,
                LeftLowerLeg = 0.127,
                LeftFoot = 0.127,
                RightUpperLeg = 0.127,
                RightLowerLeg = 0.127,
                RightFoot = 0.127,
            },
        },
        ClientRedirection = {
            Enabled = false,
            Weapons = {},
        },
    },
    Triggerbot = {
        Enabled = true,
        Delay = 0.0001,
        Prediction = 0,
        FOVSize = 80,
        WallCheck = true,
        Keybind = "",
        LastTick = 0,
        Checks = {
            KnifeCheck = true,
            ForcefieldCheck = true,
            KnockedCheck = true,
            AmmoCheck = true,
        },
        SpecificWeapons = {
            Enabled = false,
            Weapons = {},
        },
    },
    AimAssist = {
        Enabled = false,
        Smoothness = 0.1,
        Prediction = 0.127,
        FOV = 200,
        WallCheck = false,
        KnockedCheck = true,
        Target = nil,
        Locked = false,
        HorizontalPrediction = 0,
        VerticalPrediction = 0,
        OffsetEnabled = false,
        FallOffset = 0,
        JumpOffset = 0,
        OverrideYAxis = 'None',
    },
    Speed = {
        Enabled = true,
        Multiplier = 35,
        AntiFling = true,
        Normal = { Multiplier = 35 },
        LowHealth = { Enabled = false, Threshold = 40, Multiplier = 50 },
        Reloading = { Enabled = false, Multiplier = 28 },
        Shooting = { Enabled = false, Multiplier = 20 },
    },
    InfiniteRange = {
        Enabled = true,
        MaxRange = math.huge,
    },
    RapidFire = {
        Enabled = false,
        Delay = 0.01,
        SpecificWeapons = { Enabled = false, Weapons = {} },
    },
    ESP = {
        Enabled = false,
        Box = { 
            Enabled = false, 
            Color = Color3.fromRGB(98, 117, 180), 
            Filled = false, 
            FilledColor = Color3.fromRGB(98, 117, 180),
            Transparency = 0.5,
        },
        Text = { 
            Enabled = false, 
            Teamcheck = false, 
            Size = 13, 
            Color = Color3.fromRGB(255, 255, 255),
            Font = 'GothamBold',
        },
        HealthBar = { 
            Enabled = false, 
            Color1 = Color3.fromRGB(0, 255, 0), 
            Color2 = Color3.fromRGB(255, 0, 0),
            Color3 = Color3.fromRGB(255, 255, 0),
        },
        ArmorBar = { 
            Enabled = false, 
            Color = Color3.fromRGB(135, 206, 250),
            Color2 = Color3.fromRGB(100, 149, 237),
        },
        TargetLine = false,
        Tracer = false,
        TracerColor = Color3.fromRGB(255, 255, 255),
        Distance = false,
    },
    AntiCurve = {
        Enabled = false,
        MaxAngle = 12,
        DistanceThreshold = 100,
        Visualize = false,
    },
    PingPrediction = {
        Enabled = false,
        Values = {
            ['20-30'] = 0.105,
            ['30-40'] = 0.110,
            ['40-50'] = 0.115,
            ['50-60'] = 0.120,
            ['60-70'] = 0.123,
            ['70-80'] = 0.129,
            ['80-90'] = 0.130,
            ['90-100'] = 0.134,
            ['100-110'] = 0.139,
            ['110-120'] = 0.144,
            ['120-130'] = 0.149,
            ['130-140'] = 0.1274,
            ['140-150'] = 0.1575,
        },
    },
    Keybinds = {
        SilentAim = 'K',
        Triggerbot = 'L',
        AimAssist = 'X',
        Speed = 'T',
        InfiniteRange = 'I',
        RapidFire = 'R',
        ESP = 'P',
        TargetLine = 'F',
        Tracer = 'G',
    },
}

-- Global Variables
local currentTarget = nil
local isLocking = false
local triggerEnabled = false
local SpeedEnabled = false
local BaseSpeed = 16
local lastVisibleTarget = nil
local lastTriggerClick = 0
local guiVisible = true
local infRangeActive = false
local currentFOV = 200
local currentFOVX = 7
local currentFOVY = 7
local espLabels = {}
local chamsHighlights = {}
local silentTracked = {}
local silentTimes = {}
local silentState = { Current = nil, Tick = nil }
local camVelocity = Vector3.new()
local isFiring = false
local autoPredPrev = nil
local autoPredTick = nil
local lockedPlayer = nil
local silentTargetLine = nil
local stepAntiCurveOverlay = nil

-- Drawing Objects
local FOVCircle = Drawing.new('Circle')
FOVCircle.Visible = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Transparency = 0.5
FOVCircle.Thickness = 2
FOVCircle.NumSides = 100000
FOVCircle.Radius = 200
FOVCircle.Filled = false
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

local TriggerFOVCircle = Drawing.new('Circle')
TriggerFOVCircle.Visible = false
TriggerFOVCircle.Color = Color3.fromRGB(255, 50, 50)
TriggerFOVCircle.Transparency = 0.5
TriggerFOVCircle.Thickness = 2
TriggerFOVCircle.NumSides = 100000
TriggerFOVCircle.Radius = 200
TriggerFOVCircle.Filled = false
TriggerFOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

local TargetLine = Drawing.new('Line')
TargetLine.Visible = false
TargetLine.Color = Color3.fromRGB(255, 0, 0)
TargetLine.Thickness = 1.5
TargetLine.Transparency = 0.5

local TracerLine = Drawing.new('Line')
TracerLine.Visible = false
TracerLine.Color = Color3.fromRGB(255, 255, 255)
TracerLine.Thickness = 1
TracerLine.Transparency = 0.3

local fovBox = nil
local fovCircle = nil

-- Utility Functions
local function IsPlayerValid(player)
    if not player or player == LocalPlayer then return false end
    local character = player.Character
    if not character then return false end
    local humanoid = character:FindFirstChildOfClass('Humanoid')
    local root = character:FindFirstChild('HumanoidRootPart')
    if not humanoid or not root then return false end
    if humanoid.Health <= 0 then return false end
    if character:FindFirstChild('Downed') then return false end
    if character:FindFirstChild('GRABBING_CONSTRAINT') then return false end
    local bodyEffects = character:FindFirstChild('BodyEffects')
    if bodyEffects then
        local ko = bodyEffects:FindFirstChild('K.O')
        if ko and ko.Value then return false end
        local knocked = bodyEffects:FindFirstChild('Knocked')
        if knocked and knocked.Value then return false end
        local dead = bodyEffects:FindFirstChild('Dead')
        if dead and dead.Value then return false end
    end
    return true
end

local function IsVisible(part)
    if not part then return false end
    local origin = Camera.CFrame.Position
    local direction = part.Position - origin
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.IgnoreWater = true
    local result = Workspace:Raycast(origin, direction, raycastParams)
    return not result or result.Instance:IsDescendantOf(part.Parent)
end

local function IsSameTeam(player)
    if not player then return true end
    local myTeam = LocalPlayer.Team
    local theirTeam = player.Team
    if not myTeam or not theirTeam then return false end
    return myTeam == theirTeam
end

local function IsKnockedOrKO(player)
    if not player or not player.Character then return false end
    local bodyEffects = player.Character:FindFirstChild('BodyEffects')
    if not bodyEffects then return false end
    local ko = bodyEffects:FindFirstChild('K.O')
    if ko and ko.Value then return true end
    local knocked = bodyEffects:FindFirstChild('Knocked')
    if knocked and knocked.Value then return true end
    local dead = bodyEffects:FindFirstChild('Dead')
    if dead and dead.Value then return true end
    return false
end

local function GetBestAimPart(character)
    if not character then return nil end
    local priority = {
        'Head', 'UpperTorso', 'HumanoidRootPart', 'LowerTorso',
        'LeftUpperArm', 'RightUpperArm', 'LeftLowerArm', 'RightLowerArm',
        'LeftHand', 'RightHand', 'LeftUpperLeg', 'RightUpperLeg',
        'LeftLowerLeg', 'RightLowerLeg', 'LeftFoot', 'RightFoot'
    }
    for _, partName in ipairs(priority) do
        local p = character:FindFirstChild(partName)
        if p then return p end
    end
    return character:FindFirstChild('HumanoidRootPart') or character:FindFirstChild('Head')
end

local function GetClosestPlayerInFOV(fovSize)
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local closestDist = fovSize or 200
    local closestPlayer = nil
    local closestPart = nil
    for _, player in ipairs(Players:GetPlayers()) do
        if IsPlayerValid(player) then
            local character = player.Character
            local head = character:FindFirstChild('Head')
            if head then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestPlayer = player
                        closestPart = head
                    end
                end
            end
        end
    end
    return closestPlayer, closestPart
end

local function GetClosestPlayerToCursor()
    local closestDist = math.huge
    local closestPlr = nil
    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild('Humanoid') and v.Character.Humanoid.Health > 0 then
            local screenPos, onScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            if onScreen then
                local mousePos = UserInputService:GetMouseLocation()
                local dist = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                if dist < closestDist then
                    closestPlr = v
                    closestDist = dist
                end
            end
        end
    end
    return closestPlr
end

local function CheckAmmo()
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass('Tool')
    if not tool then return false end
    local currentAmmo = tool:FindFirstChild('CurrentAmmo')
    local clip = tool:FindFirstChild('Clip')
    local mag = tool:FindFirstChild('Mag')
    local ammo = tool:FindFirstChild('Ammo')
    if currentAmmo and currentAmmo:IsA('IntValue') then
        return currentAmmo.Value > 0
    elseif clip and clip:IsA('IntValue') then
        return clip.Value > 0
    elseif mag and mag:IsA('IntValue') then
        return mag.Value > 0
    else
        return not (ammo and ammo:IsA('IntValue')) and true or ammo.Value > 0
    end
end

local function ActivateTool()
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass('Tool')
    if tool then tool:Activate() end
end

local function SmoothLerp(current, target, smoothness, deltaTime)
    if smoothness >= 1 then return target end
    local alpha = 1 - math.pow(1 - math.clamp(smoothness, 0.01, 0.5), deltaTime * 60)
    return current:Lerp(target, alpha)
end

local function GetShakedVector3(Setting)
    return Vector3.new(
        math.random(-Setting * 1e9, Setting * 1e9),
        math.random(-Setting * 1e9, Setting * 1e9),
        math.random(-Setting * 1e9, Setting * 1e9)
    ) / 1e9
end

local function CheckAnti(Plr)
    if not Plr or not Plr.Character then return false end
    local root = Plr.Character:FindFirstChild('HumanoidRootPart')
    if not root then return false end
    local vel = root.Velocity
    if vel.Y < -70 then return true end
    if vel.X > 450 or vel.X < -35 then return true end
    if vel.Y > 60 then return true end
    if vel.Z > 35 or vel.Z < -35 then return true end
    return false
end

-- Triggerbot Validation
local function IsTriggerTargetValid(model)
    if not model then return false end
    local humanoid = model:FindFirstChildOfClass('Humanoid')
    if not humanoid or humanoid.Health <= 0 then return false end
    local player = Players:GetPlayerFromCharacter(model)
    if not player or player == LocalPlayer then return false end
    
    if Config.Triggerbot.Checks.KnifeCheck then
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass('Tool')
        if tool then
            local name = tool.Name:lower()
            if name:find('knife') or name:find('blade') or name:find('dagger') or 
               name:find('melee') or name:find('sword') or name:find('combat') or
               name:find('bat') or name:find('hammer') or name:find('axe') then
                return false
            end
        end
    end
    
    if Config.Triggerbot.Checks.ForcefieldCheck then
        if model:FindFirstChildOfClass('ForceField') then return false end
        if model:GetAttribute('Shield') or model:GetAttribute('Protected') then return false end
        if model:FindFirstChild('Shield') then return false end
    end
    
    if Config.Triggerbot.Checks.KnockedCheck then
        if model:FindFirstChild('BodyEffects') then
            local bodyEffects = model.BodyEffects
            if bodyEffects:FindFirstChild('K.O') and bodyEffects['K.O'].Value then return false end
            if bodyEffects:FindFirstChild('Knocked') and bodyEffects['Knocked'].Value then return false end
            if bodyEffects:FindFirstChild('Dead') and bodyEffects['Dead'].Value then return false end
        end
        if humanoid.Health < 4 then return false end
        if model:FindFirstChild('Downed') then return false end
    end
    
    if Config.Triggerbot.Checks.AmmoCheck and not CheckAmmo() then return false end
    
    return true
end

-- Silent Aim Helper Functions
local function SilentFilter(obj)
    if string.find(obj.Name, 'Gun') then return end
    if obj:IsA('BasePart') or obj:IsA('MeshPart') then return true end
end

local function SilentGetAllBodyParts(character)
    local closestDist = math.huge
    local bodyPart = nil
    if character and character:GetChildren() then
        for _, part in next, character:GetChildren() do
            if SilentFilter(part) then
                local pos = Camera:WorldToScreenPoint(part.Position)
                local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    bodyPart = part
                end
            end
        end
    end
    return bodyPart
end

local function SilentGetNearestPointOnCharacter(character, scale, maxDist)
    local part = SilentGetAllBodyParts(character)
    if not part then return nil end
    local clamp = math.clamp
    local mousePoint = UserInputService:GetMouseLocation()
    local pointRay = Camera:ViewportPointToRay(mousePoint.X, mousePoint.Y)
    local intersect = pointRay.Origin + pointRay.Direction * pointRay.Direction:Dot(part.Position - pointRay.Origin)
    local transform = part.CFrame:PointToObjectSpace(intersect)
    local reduced = (part.Size - (part.Size * (scale == 'Dynamic' and 0 or 0) / 100))
    local half = reduced / 2
    return part.CFrame * Vector3.new(
        clamp(transform.X, -half.X, half.X),
        clamp(transform.Y, -half.Y, half.Y),
        clamp(transform.Z, -half.Z, half.Z)
    )
end

local function SilentGetVelocity(rootPart)
    local pos = rootPart.Position
    local tick = tick()
    table.insert(silentTracked, pos)
    table.insert(silentTimes, tick)
    if #silentTracked >= 3 then
        local n = #silentTracked
        local p1, p2, p3 = silentTracked[n-2], silentTracked[n-1], silentTracked[n]
        local t1, t2, t3 = silentTimes[n-2], silentTimes[n-1], silentTimes[n]
        if (t2 - t1) ~= 0 and (t3 - t2) ~= 0 then
            local v1 = (p2 - p1) / (t2 - t1)
            local v2 = (p3 - p2) / (t3 - t2)
            return v2
        end
    end
    return rootPart.Velocity or Vector3.new()
end

local function SilentGetEndpoint(velocity, position, prediction, adjustment)
    local camCF = Camera.CFrame
    local relVel = camCF:VectorToObjectSpace(velocity)
    local predVel = adjustment and adjustment[1]
        and relVel * prediction * adjustment[2]
        or relVel * prediction
    return position + camCF:VectorToWorldSpace(predVel)
end

local function SilentGetHitChance()
    local cfg = Config.SilentAim.HitChance
    return (math.floor(math.random() * 100) / 100) <= (cfg.HitChance / 100) - cfg.MissChance
end

-- ESP System
local function addESPToPlayer(player)
    if player == LocalPlayer then return end
    local esp = {
        player = player,
        nameTag = Drawing.new('Text'),
        nameTagOutline = Drawing.new('Text'),
        box = Drawing.new('Square'),
        boxFill = Drawing.new('Square'),
        healthBar = Drawing.new('Line'),
        healthBarBg = Drawing.new('Line'),
        healthBarEmpty = Drawing.new('Line'),
        healthBarFill = Drawing.new('Line'),
        armorBar = Drawing.new('Line'),
        armorBarBg = Drawing.new('Line'),
        tracer = Drawing.new('Line'),
        distanceText = Drawing.new('Text'),
        skeleton = {},
    }
    
    esp.nameTag.Size = Config.ESP.Text.Size or 13
    esp.nameTag.Center = true
    esp.nameTag.Outline = true
    esp.nameTag.OutlineColor = Color3.fromRGB(0, 0, 0)
    esp.nameTag.Color = Config.ESP.Text.Color or Color3.fromRGB(255, 255, 255)
    esp.nameTag.Visible = false
    esp.nameTag.ZIndex = 1000
    
    esp.nameTagOutline.Size = Config.ESP.Text.Size or 13
    esp.nameTagOutline.Center = true
    esp.nameTagOutline.Outline = true
    esp.nameTagOutline.OutlineColor = Color3.fromRGB(0, 0, 0)
    esp.nameTagOutline.Color = Color3.fromRGB(0, 0, 0)
    esp.nameTagOutline.Visible = false
    esp.nameTagOutline.ZIndex = 999
    
    esp.box.Thickness = 2
    esp.box.Color = Config.ESP.Box.Color or Color3.fromRGB(98, 117, 180)
    esp.box.Filled = false
    esp.box.Visible = false
    esp.box.ZIndex = 500
    
    esp.boxFill.Thickness = 2
    esp.boxFill.Color = Config.ESP.Box.FilledColor or Color3.fromRGB(98, 117, 180)
    esp.boxFill.Filled = true
    esp.boxFill.Transparency = Config.ESP.Box.Transparency or 0.5
    esp.boxFill.Visible = false
    esp.boxFill.ZIndex = 499
    
    esp.healthBar.Thickness = 3
    esp.healthBar.Color = Config.ESP.HealthBar.Color1 or Color3.fromRGB(0, 255, 0)
    esp.healthBar.Visible = false
    esp.healthBar.ZIndex = 600
    
    esp.healthBarBg.Thickness = 3
    esp.healthBarBg.Color = Color3.fromRGB(50, 50, 50)
    esp.healthBarBg.Visible = false
    esp.healthBarBg.ZIndex = 598
    
    esp.healthBarEmpty.Thickness = 3
    esp.healthBarEmpty.Color = Color3.fromRGB(50, 50, 50)
    esp.healthBarEmpty.Visible = false
    esp.healthBarEmpty.ZIndex = 597
    
    esp.healthBarFill.Thickness = 3
    esp.healthBarFill.Color = Config.ESP.HealthBar.Color1 or Color3.fromRGB(0, 255, 0)
    esp.healthBarFill.Visible = false
    esp.healthBarFill.ZIndex = 599
    
    esp.armorBar.Thickness = 3
    esp.armorBar.Color = Config.ESP.ArmorBar.Color or Color3.fromRGB(135, 206, 250)
    esp.armorBar.Visible = false
    esp.armorBar.ZIndex = 601
    
    esp.armorBarBg.Thickness = 3
    esp.armorBarBg.Color = Color3.fromRGB(50, 50, 50)
    esp.armorBarBg.Visible = false
    esp.armorBarBg.ZIndex = 600
    
    esp.tracer.Thickness = 1
    esp.tracer.Color = Config.ESP.TracerColor or Color3.fromRGB(255, 255, 255)
    esp.tracer.Visible = false
    esp.tracer.ZIndex = 400
    esp.tracer.Transparency = 0.5
    
    esp.distanceText.Size = 11
    esp.distanceText.Center = true
    esp.distanceText.Outline = true
    esp.distanceText.OutlineColor = Color3.fromRGB(0, 0, 0)
    esp.distanceText.Color = Color3.fromRGB(255, 255, 255)
    esp.distanceText.Visible = false
    esp.distanceText.ZIndex = 700
    
    espLabels[player.UserId] = esp
end

local function removeESPFromPlayer(player)
    local esp = espLabels[player.UserId]
    if esp then
        esp.nameTag:Remove()
        esp.nameTagOutline:Remove()
        esp.box:Remove()
        esp.boxFill:Remove()
        esp.healthBar:Remove()
        esp.healthBarBg:Remove()
        esp.healthBarEmpty:Remove()
        esp.healthBarFill:Remove()
        esp.armorBar:Remove()
        esp.armorBarBg:Remove()
        esp.tracer:Remove()
        esp.distanceText:Remove()
        if esp.skeleton then
            for _, line in pairs(esp.skeleton) do
                line:Remove()
            end
        end
        espLabels[player.UserId] = nil
    end
end

local function refreshESP()
    if not Config.ESP.Enabled then
        for _, esp in pairs(espLabels) do
            esp.nameTag.Visible = false
            esp.nameTagOutline.Visible = false
            esp.box.Visible = false
            esp.boxFill.Visible = false
            esp.healthBar.Visible = false
            esp.healthBarBg.Visible = false
            esp.healthBarEmpty.Visible = false
            esp.healthBarFill.Visible = false
            esp.armorBar.Visible = false
            esp.armorBarBg.Visible = false
            esp.tracer.Visible = false
            esp.distanceText.Visible = false
            if esp.skeleton then
                for _, line in pairs(esp.skeleton) do
                    line.Visible = false
                end
            end
        end
        return
    end
    
    for userId, esp in pairs(espLabels) do
        local player = esp.player
        if not player or not player.Parent then
            esp.nameTag.Visible = false
            esp.nameTagOutline.Visible = false
            esp.box.Visible = false
            esp.boxFill.Visible = false
            esp.healthBar.Visible = false
            esp.healthBarBg.Visible = false
            esp.healthBarEmpty.Visible = false
            esp.healthBarFill.Visible = false
            esp.armorBar.Visible = false
            esp.armorBarBg.Visible = false
            esp.tracer.Visible = false
            esp.distanceText.Visible = false
            continue
        end
        
        if player.Character and player.Character.Parent and 
           player.Character:FindFirstChild('HumanoidRootPart') and 
           player.Character:FindFirstChild('Head') then
            local humanoid = player.Character:FindFirstChildOfClass('Humanoid')
            if not humanoid or humanoid.Health <= 0 then
                esp.nameTag.Visible = false
                esp.nameTagOutline.Visible = false
                esp.box.Visible = false
                esp.boxFill.Visible = false
                esp.healthBar.Visible = false
                esp.healthBarBg.Visible = false
                esp.healthBarEmpty.Visible = false
                esp.healthBarFill.Visible = false
                esp.armorBar.Visible = false
                esp.armorBarBg.Visible = false
                esp.tracer.Visible = false
                esp.distanceText.Visible = false
                continue
            end
            
            local rootPart = player.Character.HumanoidRootPart
            local head = player.Character.Head
            local pos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            
            if onScreen and pos.Z > 0 then
                local headPos = Camera:WorldToViewportPoint(head.Position)
                local legPos = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
                local height = math.abs(headPos.Y - legPos.Y)
                local width = height / 2
                
                -- Box ESP
                if Config.ESP.Box.Enabled then
                    local boxX = pos.X - width
                    local boxY = pos.Y - height/2
                    esp.box.Size = Vector2.new(width * 2, height)
                    esp.box.Position = Vector2.new(boxX, boxY)
                    esp.box.Color = Config.ESP.Box.Color
                    esp.box.Visible = true
                    
                    if Config.ESP.Box.Filled then
                        esp.boxFill.Size = Vector2.new(width * 2, height)
                        esp.boxFill.Position = Vector2.new(boxX, boxY)
                        esp.boxFill.Color = Config.ESP.Box.FilledColor
                        esp.boxFill.Visible = true
                    else
                        esp.boxFill.Visible = false
                    end
                else
                    esp.box.Visible = false
                    esp.boxFill.Visible = false
                end
                
                -- Text ESP
                if Config.ESP.Text.Enabled then
                    if Config.ESP.Text.Teamcheck and IsSameTeam(player) then
                        esp.nameTag.Color = Color3.fromRGB(0, 255, 0)
                    else
                        esp.nameTag.Color = Config.ESP.Text.Color or Color3.fromRGB(255, 255, 255)
                    end
                    esp.nameTag.Text = player.DisplayName or player.Name
                    esp.nameTag.Position = Vector2.new(pos.X, pos.Y - height/2 - 20)
                    esp.nameTag.Visible = true
                    esp.nameTagOutline.Text = player.DisplayName or player.Name
                    esp.nameTagOutline.Position = Vector2.new(pos.X, pos.Y - height/2 - 19)
                    esp.nameTagOutline.Visible = true
                else
                    esp.nameTag.Visible = false
                    esp.nameTagOutline.Visible = false
                end
                
                -- Health Bar
                if Config.ESP.HealthBar.Enabled then
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    local barX = pos.X + width + 5
                    local barY = pos.Y - height/2
                    local barHeight = height
                    
                    esp.healthBarBg.From = Vector2.new(barX, barY + barHeight)
                    esp.healthBarBg.To = Vector2.new(barX, barY)
                    esp.healthBarBg.Visible = true
                    
                    local r = 255 * (1 - healthPercent)
                    local g = 255 * healthPercent
                    local color
                    if healthPercent > 0.5 then
                        color = Color3.fromRGB(0, 255, 0)
                    elseif healthPercent > 0.25 then
                        color = Color3.fromRGB(255, 255, 0)
                    else
                        color = Color3.fromRGB(255, 0, 0)
                    end
                    
                    esp.healthBar.From = Vector2.new(barX, barY + barHeight)
                    esp.healthBar.To = Vector2.new(barX, barY + barHeight * (1 - healthPercent))
                    esp.healthBar.Color = color
                    esp.healthBar.Visible = true
                else
                    esp.healthBar.Visible = false
                    esp.healthBarBg.Visible = false
                end
                
                -- Armor Bar
                if Config.ESP.ArmorBar.Enabled then
                    local bodyEffects = player.Character:FindFirstChild('BodyEffects')
                    if bodyEffects then
                        local armor = bodyEffects:FindFirstChild('Armor')
                        if armor and armor.Value then
                            local armorPercent = armor.Value / 100
                            local barX = pos.X - width - 5
                            local barY = pos.Y - height/2
                            local barHeight = height
                            
                            esp.armorBarBg.From = Vector2.new(barX, barY + barHeight)
                            esp.armorBarBg.To = Vector2.new(barX, barY)
                            esp.armorBarBg.Visible = true
                            
                            esp.armorBar.From = Vector2.new(barX, barY + barHeight)
                            esp.armorBar.To = Vector2.new(barX, barY + barHeight * (1 - armorPercent))
                            esp.armorBar.Color = Config.ESP.ArmorBar.Color or Color3.fromRGB(135, 206, 250)
                            esp.armorBar.Visible = true
                        else
                            esp.armorBar.Visible = false
                            esp.armorBarBg.Visible = false
                        end
                    else
                        esp.armorBar.Visible = false
                        esp.armorBarBg.Visible = false
                    end
                else
                    esp.armorBar.Visible = false
                    esp.armorBarBg.Visible = false
                end
                
                -- Tracer
                if Config.ESP.Tracer then
                    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    esp.tracer.From = center
                    esp.tracer.To = Vector2.new(pos.X, pos.Y)
                    esp.tracer.Color = Config.ESP.TracerColor or Color3.fromRGB(255, 255, 255)
                    esp.tracer.Visible = true
                else
                    esp.tracer.Visible = false
                end
                
                -- Distance
                if Config.ESP.Distance then
                    local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
                    local distanceText = tostring(math.floor(distance)) .. 'm'
                    esp.distanceText.Text = distanceText
                    esp.distanceText.Position = Vector2.new(pos.X, pos.Y + height/2 + 15)
                    esp.distanceText.Visible = true
                else
                    esp.distanceText.Visible = false
                end
            else
                esp.nameTag.Visible = false
                esp.nameTagOutline.Visible = false
                esp.box.Visible = false
                esp.boxFill.Visible = false
                esp.healthBar.Visible = false
                esp.healthBarBg.Visible = false
                esp.healthBarEmpty.Visible = false
                esp.healthBarFill.Visible = false
                esp.armorBar.Visible = false
                esp.armorBarBg.Visible = false
                esp.tracer.Visible = false
                esp.distanceText.Visible = false
            end
        else
            esp.nameTag.Visible = false
            esp.nameTagOutline.Visible = false
            esp.box.Visible = false
            esp.boxFill.Visible = false
            esp.healthBar.Visible = false
            esp.healthBarBg.Visible = false
            esp.healthBarEmpty.Visible = false
            esp.healthBarFill.Visible = false
            esp.armorBar.Visible = false
            esp.armorBarBg.Visible = false
            esp.tracer.Visible = false
            esp.distanceText.Visible = false
        end
    end
end

-- Initialize ESP for existing players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then addESPToPlayer(player) end
end

Players.PlayerAdded:Connect(addESPToPlayer)
Players.PlayerRemoving:Connect(removeESPFromPlayer)

-- Update ESP on character add
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function(char)
            removeESPFromPlayer(player)
            char:WaitForChild('HumanoidRootPart')
            task.wait(0.1)
            addESPToPlayer(player)
        end)
        player.CharacterRemoving:Connect(function()
            removeESPFromPlayer(player)
        end)
    end
end

-- Ping Prediction
local function UpdatePingPrediction()
    if not Config.PingPrediction.Enabled then return end
    local ok, raw = pcall(function()
        return Stats.Network.ServerStatsItem['Data Ping']:GetValueString()
    end)
    if not ok then return end
    local ping = tonumber(string.split(raw, '(')[1])
    if not ping then return end
    local pp = Config.PingPrediction.Values
    if ping < 30 then Config.SilentAim.Prediction = pp['20-30']
    elseif ping < 40 then Config.SilentAim.Prediction = pp['30-40']
    elseif ping < 50 then Config.SilentAim.Prediction = pp['40-50']
    elseif ping < 60 then Config.SilentAim.Prediction = pp['50-60']
    elseif ping < 70 then Config.SilentAim.Prediction = pp['60-70']
    elseif ping < 80 then Config.SilentAim.Prediction = pp['70-80']
    elseif ping < 90 then Config.SilentAim.Prediction = pp['80-90']
    elseif ping < 100 then Config.SilentAim.Prediction = pp['90-100']
    elseif ping < 110 then Config.SilentAim.Prediction = pp['100-110']
    elseif ping < 120 then Config.SilentAim.Prediction = pp['110-120']
    elseif ping < 130 then Config.SilentAim.Prediction = pp['120-130']
    elseif ping < 140 then Config.SilentAim.Prediction = pp['130-140']
    else Config.SilentAim.Prediction = pp['140-150']
    end
end

-- Anti Curve
local function CheckAntiCurve(targetPos)
    if not Config.AntiCurve.Enabled then return false end
    local origin = Camera.CFrame.Position
    local direction = (targetPos - origin).Unit
    local distance = (targetPos - origin).Magnitude
    if distance > Config.AntiCurve.DistanceThreshold then return false end
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.IgnoreWater = true
    local result = Workspace:Raycast(origin, direction * distance, raycastParams)
    if not result then return false end
    local hitPos = result.Position
    local offset = (hitPos - targetPos).Magnitude
    local angle = math.deg(math.atan2(offset, distance))
    return angle < Config.AntiCurve.MaxAngle
end

-- Infinite Range
local function ApplyInfiniteRange()
    if not Config.InfiniteRange.Enabled then return end
    local character = LocalPlayer.Character
    if not character then return end
    local tool = character:FindFirstChildOfClass('Tool')
    if not tool then return end
    local rangeProps = {'Range', 'MaxRange', 'FireRange', 'Distance', 'MaxDistance', 'GunRange', 'WeaponRange'}
    for _, propName in pairs(rangeProps) do
        local rangeValue = tool:FindFirstChild(propName)
        if rangeValue and rangeValue:IsA('NumberValue') then
            rangeValue.Value = Config.InfiniteRange.MaxRange
        end
        local config = tool:FindFirstChild('Configuration') or tool:FindFirstChild('GunConfig') or tool:FindFirstChild('WeaponConfig')
        if config then
            local r = config:FindFirstChild(propName)
            if r and r:IsA('NumberValue') then
                r.Value = Config.InfiniteRange.MaxRange
            end
        end
    end
    -- Also check for attributes
    for _, propName in pairs(rangeProps) do
        if tool:GetAttribute(propName) then
            tool:SetAttribute(propName, Config.InfiniteRange.MaxRange)
        end
    end
end

-- Namecall Hook (Silent Aim & Anti Curve)
local NameCall
NameCall = hookmetamethod(game, '__namecall', LPH_NO_VIRTUALIZE(function(Self, ...)
    if checkcaller() then return NameCall(Self, ...) end
    local Arguments = {...}
    local Method = getnamecallmethod()
    
    -- Silent Aim
    if Config.SilentAim.Enabled and Config.SilentAim.AimPart and Config.SilentAim.AimPosition then
        if math.random(100) <= Config.SilentAim.Accuracy then
            -- Anti Curve check
            if Config.AntiCurve.Enabled and not CheckAntiCurve(Config.SilentAim.AimPosition) then
                return NameCall(Self, ...)
            end
            
            -- FireServer Method
            if Config.SilentAim.Method == 'FireServer' then
                if Method == 'FireServer' and Self.ClassName == 'RemoteEvent' then
                    if type(Arguments[1]) == 'string' then
                        if typeof(Arguments[2]) == 'Vector3' then
                            Arguments[2] = Config.SilentAim.AimPosition
                        elseif typeof(Arguments[2]) == 'table' then
                            for Index, Value in Arguments[2] do
                                if typeof(Value) == 'CFrame' then
                                    Arguments[2][Index] = CFrame.new(Config.SilentAim.AimPosition)
                                elseif typeof(Value) == 'Vector3' then
                                    Arguments[2][Index] = Config.SilentAim.AimPosition
                                end
                            end
                        elseif typeof(Arguments[2]) == 'CFrame' then
                            Arguments[2] = CFrame.new(Config.SilentAim.AimPosition)
                        end
                    end
                    if type(Arguments[1]) == 'table' then
                        for Index, Value in Arguments[1] do
                            if typeof(Value) == 'Vector3' then
                                Arguments[1][Index] = Config.SilentAim.AimPosition
                            elseif typeof(Value) == 'CFrame' then
                                Arguments[1][Index] = CFrame.new(Config.SilentAim.AimPosition)
                            end
                        end
                    end
                    return NameCall(Self, unpack(Arguments))
                end
            end
            
            -- Raycast Method
            if Config.SilentAim.Method == 'Raycast' then
                if Self == Workspace and Method:find('cast') then
                    if Method == 'Raycast' then
                        Arguments[2] = (Config.SilentAim.AimPosition - Arguments[1]).Unit * 10000
                    elseif Method == 'Shapecast' then
                        Arguments[2] = (Config.SilentAim.AimPosition - Arguments[1].Position).Unit * 10000
                    elseif Method == 'Spherecast' then
                        Arguments[3] = (Config.SilentAim.AimPosition - Arguments[1]).Unit * 10000
                    elseif Method == 'Blockcast' then
                        Arguments[3] = (Config.SilentAim.AimPosition - Arguments[1].Position).Unit * 10000
                    end
                    return NameCall(Self, unpack(Arguments))
                end
            end
            
            -- Mouse Hit Method via Namecall
            if Config.SilentAim.Method == 'MouseHit' then
                if Method == 'GetMouseLocation' or Method == 'GetMouse' then
                    local mousePos = Camera:WorldToViewportPoint(Config.SilentAim.AimPosition)
                    return Vector2.new(mousePos.X, mousePos.Y)
                end
            end
        end
    end
    
    return NameCall(Self, ...)
end))

-- Mouse.Hit Hook (Alternative method)
local MouseHitHook
local function SetupMouseHitHook()
    if not Config.SilentAim.Enabled or Config.SilentAim.Method ~= 'MouseHit' then
        if MouseHitHook then
            MouseHitHook:Disconnect()
            MouseHitHook = nil
        end
        return
    end
    if MouseHitHook then return end
    
    local meta = getrawmetatable(game)
    local oldIndex = meta.__index
    
    MouseHitHook = hookmetamethod(game, '__index', function(self, key)
        if not checkcaller() and self == Mouse then
            if key == 'Hit' or key == 'Target' then
                if Config.SilentAim.Enabled and Config.SilentAim.Method == 'MouseHit' and Config.SilentAim.AimPosition then
                    if key == 'Hit' then
                        return CFrame.new(Config.SilentAim.AimPosition)
                    end
                    if key == 'Target' and Config.SilentAim.AimPart then
                        return Config.SilentAim.AimPart
                    end
                end
            end
            if key == 'UnitRay' or key == 'X' or key == 'Y' then
                if Config.SilentAim.Enabled and Config.SilentAim.Method == 'MouseHit' and Config.SilentAim.AimPosition then
                    if key == 'UnitRay' then
                        local origin = Camera.CFrame.Position
                        local direction = (Config.SilentAim.AimPosition - origin).Unit
                        return Ray.new(origin, direction)
                    end
                end
            end
        end
        return oldIndex(self, key)
    end)
end

-- Triggerbot Main Function
local function TriggerBot()
    if not Config.Triggerbot.Enabled then return end
    if tick() - Config.Triggerbot.LastTick < Config.Triggerbot.Delay then return end
    
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local ray = Camera:ViewportPointToRay(center.X, center.Y)
    local origin = ray.Origin
    local direction = ray.Direction
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.IgnoreWater = true
    
    local hit = Workspace:Raycast(origin, direction * 1000, raycastParams)
    
    if hit and hit.Instance then
        local model = hit.Instance:FindFirstAncestorOfClass('Model')
        if model and IsTriggerTargetValid(model) then
            local targetPart = model:FindFirstChild('HumanoidRootPart') or model:FindFirstChild('Torso') or model:FindFirstChild('UpperTorso')
            if targetPart then
                -- Wall Check
                if Config.Triggerbot.WallCheck and not IsVisible(targetPart) then
                    return
                end
                
                -- Check if target is in FOV
                local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist > Config.Triggerbot.FOVSize then
                        return
                    end
                else
                    return
                end
                
                -- Prediction
                local aimPosition = hit.Position
                if Config.Triggerbot.Prediction > 0 then
                    aimPosition = targetPart.Position + targetPart.Velocity * Config.Triggerbot.Prediction
                end
                
                -- Check if prediction is valid
                local finalDirection = (aimPosition - origin).Unit
                local finalHit = Workspace:Raycast(origin, finalDirection * 1000, raycastParams)
                if finalHit and finalHit.Instance and finalHit.Instance:IsDescendantOf(model) then
                    ActivateTool()
                    Config.Triggerbot.LastTick = tick()
                end
            end
        end
    end
end

-- Heartbeat Logic
RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function()
    -- Triggerbot
    TriggerBot()
    
    -- Silent Aim Target Update
    if not Config.SilentAim.Enabled then
        Config.SilentAim.TargetPlayer = nil
        Config.SilentAim.AimPart = nil
        Config.SilentAim.AimPosition = nil
        SetupMouseHitHook()
    else
        if Config.PingPrediction.Enabled then UpdatePingPrediction() end
        
        local target, head = GetClosestPlayerInFOV(Config.SilentAim.FOVSize)
        if target then
            -- Wall Check
            if Config.SilentAim.WallCheck and not IsVisible(head) then
                Config.SilentAim.TargetPlayer = nil
                Config.SilentAim.AimPart = nil
                Config.SilentAim.AimPosition = nil
                SetupMouseHitHook()
                return
            end
            
            -- Team Check
            if Config.SilentAim.TeamCheck and IsSameTeam(target) then
                Config.SilentAim.TargetPlayer = nil
                Config.SilentAim.AimPart = nil
                Config.SilentAim.AimPosition = nil
                SetupMouseHitHook()
                return
            end
            
            -- Knock Check
            if IsKnockedOrKO(target) then
                Config.SilentAim.TargetPlayer = nil
                Config.SilentAim.AimPart = nil
                Config.SilentAim.AimPosition = nil
                SetupMouseHitHook()
                return
            end
            
            Config.SilentAim.TargetPlayer = target
            Config.SilentAim.AimPart = GetBestAimPart(target.Character)
            
            if Config.SilentAim.AimPart then
                local velocity = Config.SilentAim.AimPart.Velocity or Vector3.zero
                
                -- Prediction Points (per body part)
                if Config.SilentAim.PredictionPoints.Enabled then
                    local nearest = SilentGetAllBodyParts(target.Character)
                    if nearest then
                        local pm = Config.SilentAim.PredictionPoints.HitPoints[nearest.Name]
                        if pm then
                            Config.SilentAim.AimPosition = Config.SilentAim.AimPart.Position + (velocity * pm)
                        else
                            Config.SilentAim.AimPosition = Config.SilentAim.AimPart.Position + (velocity * Config.SilentAim.Prediction)
                        end
                    else
                        Config.SilentAim.AimPosition = Config.SilentAim.AimPart.Position + (velocity * Config.SilentAim.Prediction)
                    end
                else
                    Config.SilentAim.AimPosition = Config.SilentAim.AimPart.Position + (velocity * Config.SilentAim.Prediction)
                end
                
                -- Override Y Axis
                local override = Config.SilentAim.OverrideYAxis
                if override == 'Full' then
                    Config.SilentAim.AimPosition = Vector3.new(
                        Config.SilentAim.AimPosition.X,
                        Config.SilentAim.AimPart.Position.Y,
                        Config.SilentAim.AimPosition.Z
                    )
                elseif override == 'Partial' then
                    local velY = Config.SilentAim.AimPart.Velocity and Config.SilentAim.AimPart.Velocity.Y or 0
                    Config.SilentAim.AimPosition = Vector3.new(
                        Config.SilentAim.AimPosition.X,
                        Config.SilentAim.AimPart.Position.Y + (velY * Config.SilentAim.Prediction * 0.5),
                        Config.SilentAim.AimPosition.Z
                    )
                end
            end
            SetupMouseHitHook()
        else
            Config.SilentAim.TargetPlayer = nil
            Config.SilentAim.AimPart = nil
            Config.SilentAim.AimPosition = nil
            SetupMouseHitHook()
        end
    end
end))

-- Camera Velocity Tracking (for Aim Assist prediction)
RunService.Heartbeat:Connect(function()
    if lockedPlayer and lockedPlayer.Character and lockedPlayer.Character:FindFirstChild('HumanoidRootPart') then
        local old = lockedPlayer.Character.HumanoidRootPart.Position
        task.wait(0.145)
        if lockedPlayer and lockedPlayer.Character and lockedPlayer.Character:FindFirstChild('HumanoidRootPart') then
            camVelocity = (lockedPlayer.Character.HumanoidRootPart.Position - old) / 0.145
        end
    end
end)

-- RenderStepped Logic
RunService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function(deltaTime)
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    -- FOV Circle (Silent Aim)
    FOVCircle.Position = center
    FOVCircle.Radius = Config.SilentAim.FOVSize
    FOVCircle.Visible = Config.SilentAim.Enabled
    
    -- Triggerbot FOV Circle
    TriggerFOVCircle.Position = center
    TriggerFOVCircle.Radius = Config.Triggerbot.FOVSize
    TriggerFOVCircle.Visible = Config.Triggerbot.Enabled
    
    -- Target Line
    if Config.ESP.TargetLine and Config.SilentAim.Enabled and Config.SilentAim.AimPart then
        local pos, onScreen = Camera:WorldToViewportPoint(Config.SilentAim.AimPart.Position)
        if onScreen then
            TargetLine.From = center
            TargetLine.To = Vector2.new(pos.X, pos.Y)
            TargetLine.Visible = true
        else
            TargetLine.Visible = false
        end
    else
        TargetLine.Visible = false
    end
    
    -- Anti Curve Visualization
    if Config.AntiCurve.Enabled and Config.AntiCurve.Visualize and Config.SilentAim.AimPosition then
        if stepAntiCurveOverlay then stepAntiCurveOverlay() end
    end
    
    -- Aim Assist Logic
    if Config.AimAssist.Enabled and Config.AimAssist.Locked and Config.AimAssist.Target then
        local character = Config.AimAssist.Target.Character
        if character and IsPlayerValid(Config.AimAssist.Target) then
            local aimPart = GetBestAimPart(character)
            if aimPart then
                -- Wall Check
                if Config.AimAssist.WallCheck and not IsVisible(aimPart) then
                    Config.AimAssist.Locked = false
                    Config.AimAssist.Target = nil
                    return
                end
                
                -- Knocked Check
                if Config.AimAssist.KnockedCheck and IsKnockedOrKO(Config.AimAssist.Target) then
                    Config.AimAssist.Locked = false
                    Config.AimAssist.Target = nil
                    return
                end
                
                local targetPos = aimPart.Position
                local velocity = aimPart.Velocity or Vector3.zero
                
                -- Prediction
                local predVel = Vector3.new(
                    velocity.X * (Config.AimAssist.HorizontalPrediction or 0),
                    velocity.Y * (Config.AimAssist.VerticalPrediction or 0),
                    velocity.Z * (Config.AimAssist.HorizontalPrediction or 0)
                )
                targetPos = targetPos + (predVel * (Config.AimAssist.Prediction + 0.01))
                
                -- Offsets
                if Config.AimAssist.OffsetEnabled then
                    local humanoid = character:FindFirstChildOfClass('Humanoid')
                    if humanoid then
                        local state = humanoid:GetState()
                        if state == Enum.HumanoidStateType.Freefall then
                            targetPos = targetPos + Vector3.new(0, Config.AimAssist.FallOffset, 0)
                        elseif state == Enum.HumanoidStateType.Jumping then
                            targetPos = targetPos + Vector3.new(0, Config.AimAssist.JumpOffset, 0)
                        end
                    end
                end
                
                -- Override Y Axis
                local override = Config.AimAssist.OverrideYAxis
                if override == 'Full' then
                    targetPos = Vector3.new(targetPos.X, aimPart.Position.Y, targetPos.Z)
                elseif override == 'Partial' then
                    local velY = aimPart.Velocity and aimPart.Velocity.Y or 0
                    targetPos = Vector3.new(targetPos.X, aimPart.Position.Y + (velY * Config.AimAssist.Prediction * 0.5), targetPos.Z)
                end
                
                -- Check Anti (anti-cheat bypass)
                if not CheckAnti(Config.AimAssist.Target) then
                    targetPos = targetPos + camVelocity * Config.AimAssist.Prediction
                else
                    local humanoid = character:FindFirstChildOfClass('Humanoid')
                    if humanoid then
                        targetPos = targetPos + (humanoid.MoveDirection * humanoid.WalkSpeed) * Config.AimAssist.Prediction
                    end
                end
                
                -- Camera Shake effect
                local shake = GetShakedVector3(0)
                targetPos = targetPos + shake
                
                local currentCFrame = Camera.CFrame
                local targetCFrame = CFrame.new(currentCFrame.Position, targetPos)
                local smoothCFrame = SmoothLerp(currentCFrame, targetCFrame, Config.AimAssist.Smoothness, deltaTime)
                Camera.CFrame = smoothCFrame
            end
        else
            Config.AimAssist.Locked = false
            Config.AimAssist.Target = nil
        end
    end
    
    -- Speed Logic
    if Config.Speed.Enabled then
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChild('Humanoid')
        if humanoid and humanoid.Health > 0 then
            local speed = Config.Speed.Normal.Multiplier or 35
            
            -- Low Health
            if Config.Speed.LowHealth.Enabled and humanoid.Health <= Config.Speed.LowHealth.Threshold then
                speed = Config.Speed.LowHealth.Multiplier
            end
            
            -- Reloading
            if Config.Speed.Reloading.Enabled then
                local tool = character:FindFirstChildOfClass('Tool')
                if tool and tool:FindFirstChild('Reloading') and tool.Reloading.Value then
                    speed = Config.Speed.Reloading.Multiplier
                end
            end
            
            -- Shooting
            if Config.Speed.Shooting.Enabled then
                if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                    speed = Config.Speed.Shooting.Multiplier
                end
            end
            
            humanoid.WalkSpeed = speed
        end
        
        -- Anti Fling
        if Config.Speed.AntiFling then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart')
            if hrp then
                local vel = hrp.Velocity
                if vel.Y > 50 or vel.Y < -50 then
                    hrp.Velocity = Vector3.new(vel.X, 0, vel.Z)
                end
                if vel.X > 200 or vel.X < -200 then
                    hrp.Velocity = Vector3.new(0, vel.Y, vel.Z)
                end
                if vel.Z > 200 or vel.Z < -200 then
                    hrp.Velocity = Vector3.new(vel.X, vel.Y, 0)
                end
            end
        end
    end
    
    -- Infinite Range
    ApplyInfiniteRange()
    
    -- ESP
    refreshESP()
end))

-- Rapid Fire Logic
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if Config.RapidFire.Enabled then
            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool then
                if Config.RapidFire.SpecificWeapons.Enabled then
                    local valid = false
                    for _, wName in pairs(Config.RapidFire.SpecificWeapons.Weapons) do
                        if tool.Name == wName then
                            valid = true
                            break
                        end
                    end
                    if not valid then return end
                end
                task.spawn(function()
                    while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and Config.RapidFire.Enabled do
                        local currentTool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                        if not currentTool then break end
                        if Config.RapidFire.SpecificWeapons.Enabled then
                            local valid = false
                            for _, wName in pairs(Config.RapidFire.SpecificWeapons.Weapons) do
                                if currentTool.Name == wName then
                                    valid = true
                                    break
                                end
                            end
                            if not valid then break end
                        end
                        currentTool:Activate()
                        task.wait(Config.RapidFire.Delay)
                    end
                end)
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isFiring = false
    end
end)

-- Keybinds (PC Only)
if Config.Settings.Platform == 'PC' and Config.Settings.UseKeybinds then
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        
        -- Silent Aim Toggle
        if input.KeyCode == Enum.KeyCode[Config.Keybinds.SilentAim] then
            Config.SilentAim.Enabled = not Config.SilentAim.Enabled
            print("Silent Aim: " .. (Config.SilentAim.Enabled and "ON" or "OFF"))
        end
        
        -- Triggerbot Toggle
        if input.KeyCode == Enum.KeyCode[Config.Keybinds.Triggerbot] then
            Config.Triggerbot.Enabled = not Config.Triggerbot.Enabled
            print("Triggerbot: " .. (Config.Triggerbot.Enabled and "ON" or "OFF"))
        end
        
        -- Aim Assist Toggle
        if input.KeyCode == Enum.KeyCode[Config.Keybinds.AimAssist] then
            Config.AimAssist.Enabled = not Config.AimAssist.Enabled
            if not Config.AimAssist.Enabled then
                Config.AimAssist.Locked = false
                Config.AimAssist.Target = nil
            end
            print("Aim Assist: " .. (Config.AimAssist.Enabled and "ON" or "OFF"))
        end
        
        -- Speed Toggle
        if input.KeyCode == Enum.KeyCode[Config.Keybinds.Speed] then
            Config.Speed.Enabled = not Config.Speed.Enabled
            if not Config.Speed.Enabled then
                local character = LocalPlayer.Character
                local humanoid = character and character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = 16
                end
            end
            print("Speed: " .. (Config.Speed.Enabled and "ON" or "OFF"))
        end
        
        -- Infinite Range Toggle
        if input.KeyCode == Enum.KeyCode[Config.Keybinds.InfiniteRange] then
            Config.InfiniteRange.Enabled = not Config.InfiniteRange.Enabled
            print("Infinite Range: " .. (Config.InfiniteRange.Enabled and "ON" or "OFF"))
        end
        
        -- Rapid Fire Toggle
        if input.KeyCode == Enum.KeyCode[Config.Keybinds.RapidFire] then
            Config.RapidFire.Enabled = not Config.RapidFire.Enabled
            print("Rapid Fire: " .. (Config.RapidFire.Enabled and "ON" or "OFF"))
        end
        
        -- ESP Toggle
        if input.KeyCode == Enum.KeyCode[Config.Keybinds.ESP] then
            Config.ESP.Enabled = not Config.ESP.Enabled
            print("ESP: " .. (Config.ESP.Enabled and "ON" or "OFF"))
        end
        
        -- Target Line Toggle
        if input.KeyCode == Enum.KeyCode[Config.Keybinds.TargetLine] then
            Config.ESP.TargetLine = not Config.ESP.TargetLine
            print("Target Line: " .. (Config.ESP.TargetLine and "ON" or "OFF"))
        end
        
        -- Tracer Toggle
        if input.KeyCode == Enum.KeyCode[Config.Keybinds.Tracer] then
            Config.ESP.Tracer = not Config.ESP.Tracer
            print("Tracer: " .. (Config.ESP.Tracer and "ON" or "OFF"))
        end
    end)
end

-- Aim Assist Lock (Right Click)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if Config.AimAssist.Enabled and input.UserInputType == Enum.UserInputType.MouseButton2 then
        local target, part = GetClosestPlayerInFOV(Config.AimAssist.FOV)
        if target and part then
            -- Check if target is valid for aim assist
            if IsPlayerValid(target) and not IsKnockedOrKO(target) then
                if Config.AimAssist.WallCheck and not IsVisible(part) then
                    return
                end
                Config.AimAssist.Locked = true
                Config.AimAssist.Target = target
                lockedPlayer = target
                print("Aim Assist Locked: " .. (target.DisplayName or target.Name))
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, processed)
    if processed then return end
    if Config.AimAssist.Enabled and input.UserInputType == Enum.UserInputType.MouseButton2 then
        Config.AimAssist.Locked = false
        Config.AimAssist.Target = nil
        lockedPlayer = nil
        print("Aim Assist Unlocked")
    end
end)

-- Triggerbot Hold Mode (Middle Click or Keybind)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if Config.Triggerbot.Enabled and input.UserInputType == Enum.UserInputType.MouseButton3 then
        triggerEnabled = true
    end
    if input.KeyCode == Enum.KeyCode[Config.Keybinds.Triggerbot] then
        triggerEnabled = not triggerEnabled
    end
end)

UserInputService.InputEnded:Connect(function(input, processed)
    if processed then return end
    if Config.Triggerbot.Enabled and input.UserInputType == Enum.UserInputType.MouseButton3 then
        triggerEnabled = false
    end
end)

-- Mobile/Always On Mode
if Config.Settings.Platform == 'Mobile' and Config.Settings.AlwaysOn then
    Config.SilentAim.Enabled = true
    Config.Triggerbot.Enabled = true
    Config.AimAssist.Enabled = true
    Config.Speed.Enabled = true
    Config.InfiniteRange.Enabled = true
    Config.RapidFire.Enabled = true
    Config.ESP.Enabled = true
    Config.ESP.TargetLine = true
    Config.ESP.Tracer = true
    print("Always On Mode Activated (Mobile)")
end

-- Automated Prediction
local function UpdateAutomatedPrediction()
    if not Config.SilentAim.PredictionPoints.Enabled then return end
    if not Config.SilentAim.TargetPlayer then return end
    local character = Config.SilentAim.TargetPlayer.Character
    if not character then return end
    local root = character:FindFirstChild('HumanoidRootPart')
    if not root then return end
    
    local now = tick()
    local pos = root.Position
    
    if autoPredPrev and autoPredTick and (now - autoPredTick) > 0 then
        local velocity = (pos - autoPredPrev) / (now - autoPredTick)
        local speed = velocity.Magnitude
        if speed > 1 then
            local root2 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart')
            local dist = root2 and (root.Position - root2.Position).Magnitude or 50
            local scale = math.clamp(speed / 50, 0.08, 0.22)
            local adjusted = scale * (dist / 50)
            Config.SilentAim.Prediction = math.clamp(adjusted, 0.08, 0.22)
        end
    end
    
    autoPredPrev = pos
    autoPredTick = now
end

RunService.Heartbeat:Connect(function()
    UpdateAutomatedPrediction()
end)

-- Client Redirection (Destroys client scripts for specified weapons)
RunService.Heartbeat:Connect(function()
    if not Config.SilentAim.ClientRedirection.Enabled then return end
    local character = LocalPlayer.Character
    if not character then return end
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return end
    local weapons = Config.SilentAim.ClientRedirection.Weapons
    for _, weaponName in ipairs(weapons) do
        local clean = weaponName:gsub("%[", ""):gsub("%]", "")
        if tool.Name == weaponName or tool.Name:find(clean) then
            for _, child in ipairs(tool:GetChildren()) do
                if child:IsA("LocalScript") or child:IsA("Script") then
                    child:Destroy()
                end
            end
            break
        end
    end
end)

-- Hit Scan (Automatic shooting)
RunService.RenderStepped:Connect(function()
    if not Config.SilentAim.Enabled then return end
    if not Config.SilentAim.TargetPlayer then return end
    if Config.SilentAim.Method ~= 'Automatic' then return end
    
    local character = Config.SilentAim.TargetPlayer.Character
    if not character then return end
    local player = Config.SilentAim.TargetPlayer
    if IsKnockedOrKO(player) then return end
    if not SilentGetHitChance() then return end
    
    local mainEvent = ReplicatedStorage:FindFirstChild('MainEvent')
    if not mainEvent then return end
    
    local hit = SilentGetHitPosition(player)
    if hit then
        mainEvent:FireServer('UpdateMousePosI2', hit)
    end
end)

-- Silent Get Hit Position (for Hit Scan)
local function SilentGetHitPosition(player)
    local character = player.Character
    if not character then return nil end
    local humanoid = character:FindFirstChild('Humanoid')
    local rootPart = character:FindFirstChild('HumanoidRootPart')
    if not humanoid or not rootPart then return nil end
    
    local sa = Config.SilentAim
    local mult = sa.Prediction
    local power = sa.PredictionAdjustment
    if power ~= 1 then mult = mult * (1 - (power - 1) / 2) end
    
    if sa.PredictionPoints.Enabled then
        local nearest = SilentGetAllBodyParts(character)
        if nearest then
            local pm = sa.PredictionPoints.HitPoints[nearest.Name]
            if pm then mult = Vector3.new(pm, pm, pm) end
        end
    end
    
    local hitTarget = sa.HitLocation.HitTarget
    local hitPos
    
    if hitTarget == 'Nearest Point' then
        local np = SilentGetNearestPointOnCharacter(character, sa.HitLocation.PointScale, sa.HitLocation.MaxNearestPoint)
        hitPos = np and Vector3.new(np.X, np.Y, np.Z) or rootPart.Position
    elseif hitTarget == 'Nearest Part' then
        local np = SilentGetAllBodyParts(character)
        hitPos = np and np.Position or rootPart.Position
    else
        hitPos = rootPart.Position
    end
    
    local velocity = SilentGetVelocity(rootPart)
    
    local override = sa.OverrideYAxis
    if type(mult) == 'number' then
        if override == 'Full' then
            mult = Vector3.new(mult, 0, mult)
        elseif override == 'Partial' then
            mult = Vector3.new(mult, rootPart.Velocity.Y / 5, mult)
        else
            mult = Vector3.new(mult, mult, mult)
        end
    end
    
    return SilentGetEndpoint(velocity, hitPos, mult, sa['3D Adjustment'])
end

-- GUI (Visual Status Display)
local gui = Instance.new("ScreenGui")
gui.Parent = CoreGui
gui.Name = "AtomicGUI"

local text = Instance.new("TextLabel")
text.Parent = gui
text.AnchorPoint = Vector2.new(0.5, 1)
text.Position = UDim2.new(0.5, 0, 1, -110)
text.Size = UDim2.new(0, 280, 0, 200)
text.BackgroundTransparency = 1
text.TextXAlignment = Enum.TextXAlignment.Center
text.TextYAlignment = Enum.TextYAlignment.Bottom
text.Font = Enum.Font.Gotham
text.TextSize = 14
text.RichText = true
text.TextStrokeTransparency = 0
text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

local function updateGUI()
    if not guiVisible then
        text.Text = ""
        return
    end
    
    local lines = {}
    table.insert(lines, '<font color="rgb(97,222,241)">Atomic Script</font>')
    
    if Config.SilentAim.Enabled and Config.SilentAim.TargetPlayer then
        local player = Config.SilentAim.TargetPlayer
        local name = (player.DisplayName ~= "" and player.DisplayName) or player.Name
        table.insert(lines, '<font color="rgb(255,255,255)">Silent Aim </font><font color="rgb(97,222,241)">('..name..')</font>')
    end
    
    if Config.Triggerbot.Enabled then
        table.insert(lines, '<font color="rgb(255,255,255)">Trigger Bot </font><font color="rgb(50,205,50)">ON</font>')
    end
    
    if Config.AimAssist.Enabled and Config.AimAssist.Locked then
        local player = Config.AimAssist.Target
        if player then
            local name = (player.DisplayName ~= "" and player.DisplayName) or player.Name
            table.insert(lines, '<font color="rgb(255,255,255)">Aim Assist </font><font color="rgb(135,206,250)">('..name..')</font>')
        end
    end
    
    if Config.Speed.Enabled then
        table.insert(lines, '<font color="rgb(255,255,255)">Speed </font><font color="rgb(255,255,0)">ON</font>')
    end
    
    if Config.InfiniteRange.Enabled then
        table.insert(lines, '<font color="rgb(255,255,255)">Infinite Range </font><font color="rgb(255,165,0)">ON</font>')
    end
    
    if Config.RapidFire.Enabled then
        table.insert(lines, '<font color="rgb(255,255,255)">Rapid Fire </font><font color="rgb(255,0,0)">ON</font>')
    end
    
    if Config.ESP.Enabled then
        table.insert(lines, '<font color="rgb(255,255,255)">ESP </font><font color="rgb(0,255,255)">ON</font>')
    end
    
    text.Text = table.concat(lines, "\n")
end

RunService.RenderStepped:Connect(updateGUI)

-- Cleanup on unload
local function cleanup()
    -- Remove GUI
    gui:Destroy()
    
    -- Remove FOV circles
    FOVCircle:Remove()
    TriggerFOVCircle:Remove()
    TargetLine:Remove()
    TracerLine:Remove()
    
    -- Remove ESP
    for _, esp in pairs(espLabels) do
        esp.nameTag:Remove()
        esp.nameTagOutline:Remove()
        esp.box:Remove()
        esp.boxFill:Remove()
        esp.healthBar:Remove()
        esp.healthBarBg:Remove()
        esp.healthBarEmpty:Remove()
        esp.healthBarFill:Remove()
        esp.armorBar:Remove()
        esp.armorBarBg:Remove()
        esp.tracer:Remove()
        esp.distanceText:Remove()
    end
    espLabels = {}
    
    -- Remove Chams
    for _, highlight in pairs(chamsHighlights) do
        highlight:Destroy()
    end
    chamsHighlights = {}
    
    print("Atomic Script Unloaded")
end

-- Set up cleanup on script unload
game:GetService("RunService").Heartbeat:Connect(function()
    if not gui.Parent then
        cleanup()
    end
end)

-- Print startup message
print("========================================")
print("       ATOMIC SCRIPT LOADED")
print("   Silent Aim | Triggerbot | Aim Assist")
print("   Speed | Infinite Range | Rapid Fire")
print("   ESP | Anti Curve | Ping Prediction")
print("========================================")
print("PC Keybinds:")
if Config.Settings.Platform == 'PC' then
    print("K - Silent Aim Toggle")
    print("L - Triggerbot Toggle")
    print("X - Aim Assist Toggle")
    print("T - Speed Toggle")
    print("I - Infinite Range Toggle")
    print("R - Rapid Fire Toggle")
    print("P - ESP Toggle")
    print("F - Target Line Toggle")
    print("G - Tracer Toggle")
end
if Config.Settings.Platform == 'Mobile' and Config.Settings.AlwaysOn then
    print("Always On Mode Activated - All features enabled")
end
print("========================================")