local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local Options = Library.Options
local Toggles = Library.Toggles
Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local function print_colored(t, c)
    if c == "red" then
        warn("[ERROR] " .. t)
    elseif c == "yellow" then
        warn("[WARN] " .. t)
    else
        print(t)
    end
end

local ascii = [[
                                   
                                   
            @@@@@@@@@              
         @@@@@@@@@@@@@@@@          
      @@@@@@@@           @@@       
     @@@@@@@                @      
    @@@@@@@                        
    @@@@@@           @@@@@@        
    @@@@@@@             @@@@@@     
    @@@@@@@@@@            @@@@@    
     @@@@@@@@@@@@@@@       @@@@    
        @@@@@@@@@@@@@@     @@@@    
                 @@@@@    @@@@@    
     @            @@@@    @@@@     
      *@@%      @@@@@    @@@       
         @@@@@@@@@@@   @@@         
                    @@@            
              
        -- Made by Velocity.
                                   
]]

local function getGlobal(p)
    local v = getfenv(0)
    while v ~= nil and p ~= "" do
        local n, nxt = string.match(p, "^([^.]+)%.?(.*)$")
        v = v[n]
        p = nxt
    end
    return v
end

loadstring(game:HttpGet("https://raw.githubusercontent.com/Saersa/Fun_Scripts/refs/heads/main/Console_Rich_Text.lua"))()

local function testFunction(n, f)
    local e = getGlobal(n) ~= nil
    local c = e and "rgb(0,255,0)" or "rgb(255,0,0)"
    print(string.format('<font color="%s">%s</font>', c, n))
    if not e then
        table.insert(f, n)
    end
end

local requiredFunctions = {
    "hookfunction", "getconnections", "getgc", "setclipboard", "writefile", "readfile", "isfile"
}
print_colored(ascii, "green")
print("\nChecking required functions...\n")
local failedFunctions = {}
for _, func in ipairs(requiredFunctions) do
    testFunction(func, failedFunctions)
end
local Unsupported = {}
for _, func in ipairs(failedFunctions) do
    Unsupported[func] = true
end
if #failedFunctions > 0 then
    local msg = "Unsupported functions: " .. table.concat(failedFunctions, ", ") .. ". Some features may not work."
    Library:Notify(msg, 6)
else
    Library:Notify("All required functions supported", 3)
end
print_colored("Script Loaded", "green")

local function safeAddCheckbox(g, i, d, r)
    if r and Unsupported[r] then
        d.Disabled = true
        d.Text = d.Text .. " (Unsupported)"
    end
    return g:AddCheckbox(i, d)
end

local function safeAddSlider(g, i, d, r)
    if r and Unsupported[r] then
        d.Disabled = true
        d.Text = d.Text .. " (Unsupported)"
    end
    return g:AddSlider(i, d)
end

local function safeAddDropdown(g, i, d, r)
    if r and Unsupported[r] then
        d.Disabled = true
        d.Text = d.Text .. " (Unsupported)"
    end
    return g:AddDropdown(i, d)
end

local Window = Library:CreateWindow({
    Title = "Ostium",
    Footer = "v2.12 | Ostium | Pressure",
    Icon = 117198211193045,
    NotifySide = "Right",
    ShowCustomCursor = false,
    EnableSidebarResize = true,
    SidebarMinWidth = 200,
    SidebarCompactWidth = 56,
    SidebarCollapseThreshold = 0.45,
})

local Tabs = {
    Home = Window:AddTab("Start", "house"),
    Player = Window:AddTab("Player", "user"),
    Teleports = Window:AddTab("Teleports", "map"),
    Farming = Window:AddTab("Farming", "sparkles"),
    Visuals = Window:AddTab("Visuals", "eye"),
    Misc = Window:AddTab("Misc", "box"),
}

-- Declare forward-referenced locals early to fix scoping in closures
local character
local rootPart
local humanoid
local autoTreeFarmEnabled = false
local treesBrought = false
local badTrees = {}

local HomeGroup = Tabs.Home:AddLeftGroupbox("Welcome")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local avatarImage = HomeGroup:AddImage("AvatarThumbnail", {
    Image = "rbxassetid://0",
    Callback = function(image)
        print("Image changed!", image)
    end,
})

task.spawn(function()
    repeat task.wait() until player
    task.wait(1)
    local success, thumbnail = pcall(function()
        return Players:GetUserThumbnailAsync(
            player.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size180x180
        )
    end)
    if success and thumbnail then
        avatarImage:SetImage(thumbnail)
    else
        local alternatives = {
            Enum.ThumbnailType.AvatarThumbnail,
            Enum.ThumbnailType.AvatarBust,
            Enum.ThumbnailType.Avatar,
        }
        for _, thumbnailType in ipairs(alternatives) do
            local altSuccess, altThumbnail = pcall(function()
                return Players:GetUserThumbnailAsync(
                    player.UserId,
                    thumbnailType,
                    Enum.ThumbnailSize.Size180x180
                )
            end)
            if altSuccess and altThumbnail then
                avatarImage:SetImage(altThumbnail)
                break
            end
        end
    end
end)

HomeGroup:AddLabel((function() local h=os.date("*t").hour return (h<12 and h>=5 and "Good morning" or h<17 and "Good afternoon" or h<21 and "Good evening" or "Good night") end)() .. ", " .. game.Players.LocalPlayer.Name)
HomeGroup:AddDivider()
HomeGroup:AddButton("Join Discord", function()
    setclipboard("https://discord.gg/9UuswyPTDE")
    Library:Notify("Discord link copied to clipboard!")
end)
HomeGroup:AddButton("Website", function()
    setclipboard("https://getvelocityx.netlify.app/")
    Library:Notify("website link copied to clipboard!")
end)
HomeGroup:AddButton({
    Text = "Reset Character",
    Func = function()
        if player.Character then player.Character:Destroy() end
        player:LoadCharacter()
    end
})
HomeGroup:AddButton({
    Text = "Play Again",
    Func = function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
        local AcceptPlayAgain = RemoteEvents:WaitForChild("AcceptPlayAgain")
        AcceptPlayAgain:FireServer()
    end
})

Tabs.Home:UpdateWarningBox({
    Title = "Changelogs",
    Text = [[
<font color="rgb(76, 0, 255)">Release v2.12</font>
<font color="rgb(255, 255, 255)">-- Fixes & Additions --</font>
- <font color="rgb(0, 255, 0)">Fixed Godmode and JumpPower</font>
- <font color="rgb(0, 255, 0)">Added Reset & Play Again buttons</font>
- <font color="rgb(0, 255, 0)">Integrated Advanced ESP Library</font>
- <font color="rgb(0, 255, 0)">Added Fullbright, No Fog, Anti-Lag</font>
- <font color="rgb(0, 255, 0)">Organized tabs & Removed duplicates</font>
]],
    IsNormal = true,
    Visible = true,
    LockSize = true
})

local StatusGroup = Tabs.Home:AddRightGroupbox("Status")
local HttpService = game:GetService("HttpService")
local fileName = "Ostium/ostium_executions.json"
local count = 0
if isfile(fileName) then
    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(fileName))
    end)
    if success and data.count then
        count = data.count
    end
end
count = count + 1
pcall(function()
    writefile(fileName, HttpService:JSONEncode({count = count}))
end)
local ExecutionLabel = StatusGroup:AddLabel('<font color="rgb(0,255,255)">Total Executions: ' .. count .. '</font>')
StatusGroup:AddDivider()
local VolcanoLabel = StatusGroup:AddLabel('<font color="rgb(0,255,255)">🟢 Volcano</font>')
local DeltaLabel = StatusGroup:AddLabel('<font color="rgb(0,255,255)">🟢 Delta</font>')
local SwiftLabel = StatusGroup:AddLabel('<font color="rgb(0,255,255)">🟢 Swift</font>')
local ValexLabel = StatusGroup:AddLabel('<font color="rgb(0,255,255)">🟢 Valex</font>')
local VelocityLabel = StatusGroup:AddLabel('<font color="rgb(0,255,255)">🟢 Velocity</font>')
local KRNLLabel = StatusGroup:AddLabel('<font color="rgb(0,255,255)">🟢 KRNL</font>')
local SolaraLabel = StatusGroup:AddLabel('<font color="rgb(0,255,255)">🟢 Solara</font>')
local XenoLabel = StatusGroup:AddLabel('<font color="rgb(0,255,255)">🟢 Xeno</font>')

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local ESP_Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bocaj111004/ESPLibrary/refs/heads/main/Library.lua"))()
_G.FadeTime = _G.FadeTime or 0.5
ESP_Library:SetFadeTime(_G.FadeTime)
ESP_Library:SetShowDistance(true)
ESP_Library:SetFillTransparency(0.75)
ESP_Library:SetOutlineTransparency(0)
ESP_Library:SetTextTransparency(0)
ESP_Library:SetTextOutlineTransparency(0)
ESP_Library:SetTextSize(17)

local ESPSettings = Tabs.Visuals:AddLeftGroupbox("ESP Settings")
ESPSettings:AddCheckbox("ESPRainbow", {
    Text = "Rainbow Mode (global)",
    Default = false,
    Tooltip = "When enabled, all ESPs will smoothly cycle colors.",
    Callback = function(Value)
        ESP_Library:SetRainbow(Value)
        _G.ESPRainbowEnabled = Value
    end
})
ESPSettings:AddCheckbox("EnableTracers", {
    Text = "Enable Tracers",
    Default = false,
    Tooltip = "Enables tracers for all ESPs",
    Callback = function(Value)
        ESP_Library:SetTracers(Value)
        _G.EnableTracers = Value
    end
})
ESPSettings:AddCheckbox("EnableArrows", {
    Text = "Enable Arrows",
    Default = false,
    Tooltip = "Enables arrows for all ESPs",
    Callback = function(Value)
        ESP_Library:SetArrows(Value)
        _G.EnableArrows = Value
    end
})
ESPSettings:AddDropdown("TracerOrigin", {
    Text = "Tracer Origin",
    Default = "Bottom",
    Multi = false,
    Values = {"Bottom", "Center", "Top", "Mouse"},
    Tooltip = "Select origin point for tracers",
    Callback = function(Value)
        ESP_Library:SetTracerOrigin(Value)
    end
})
ESPSettings:AddSlider("TracerSize", {
    Text = "Tracer Size",
    Default = 1,
    Min = 0.1,
    Max = 5,
    Rounding = 1,
    Compact = true,
    Tooltip = "Adjusts thickness of tracer lines",
    Callback = function(Value)
        ESP_Library:SetTracerSize(Value)
    end
})
ESPSettings:AddSlider("ArrowRadius", {
    Text = "Arrow Radius",
    Default = 200,
    Min = 50,
    Max = 500,
    Rounding = 0,
    Compact = true,
    Tooltip = "Adjusts distance from center for arrows",
    Callback = function(Value)
        ESP_Library:SetArrowRadius(Value)
    end
})
ESPSettings:AddSlider("ESPDistance", {
    Text = "ESP Distance",
    Default = 200,
    Min = 50,
    Max = 1000,
    Rounding = 0,
    Compact = true,
    Tooltip = "Maximum distance (studs) to display ESP for all object types.",
    Callback = function(Value)
        _G.ESPDistance = Value
    end
})
_G.ESPDistance = _G.ESPDistance or 200
_G.ESPRainbowEnabled = _G.ESPRainbowEnabled or false

local function getESPColor(baseColor)
    return baseColor
end

local function addESPWithDynamicColor(object, text, basePart, baseColor)
    local color = getESPColor(baseColor)
    ESP_Library:AddESP({
        Object = object,
        Text = text,
        Color = color,
        BasePart = basePart
    })
end

local function playerRoot()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
end

local function distanceBetweenRootAndPart(part)
    local root = playerRoot()
    if not root or not part or not part:IsA("BasePart") then return math.huge end
    return (root.Position - part.Position).Magnitude
end

local VisualsGroup = Tabs.Visuals:AddLeftGroupbox("Object ESP") -- Changed to Left to avoid overlap

-- Optimized getAllowedObjects using specific folders instead of full GetDescendants
local Characters = Workspace:WaitForChild("Characters")
local Items = Workspace:WaitForChild("Items")
local function getAllowedObjects(category)
    local categories = {
        Player = function() return Players:GetPlayers() end,
        Animal = function()
            local animals = {}
            for _, obj in ipairs(Characters:GetChildren()) do
                if obj:IsA("Model") and (obj.Name:find("Wolf") or obj.Name:find("Bear") or obj.Name:find("Bunny") or obj.Name:find("Deer")) then
                    table.insert(animals, obj)
                end
            end
            return animals
        end,
        Enemy = function()
            local enemies = {}
            for _, obj in ipairs(Characters:GetChildren()) do
                if obj:IsA("Model") and (obj.Name:find("Cultist") or obj.Name:find("Alien")) then
                    table.insert(enemies, obj)
                end
            end
            return enemies
        end,
        ["Lost Kid"] = function()
            local kids = {}
            for _, obj in ipairs(Characters:GetChildren()) do
                if obj:IsA("Model") and obj.Name:find("Lost Child") then
                    table.insert(kids, obj)
                end
            end
            return kids
        end,
        Food = function()
            local foods = {}
            for _, obj in ipairs(Items:GetChildren()) do
                if obj:IsA("Model") and (obj.Name:find("Berry") or obj.Name:find("Apple") or obj.Name:find("Carrot") or obj.Name:find("Steak") or obj.Name:find("Morsel")) then
                    table.insert(foods, obj)
                end
            end
            return foods
        end,
        Scrap = function()
            local scraps = {}
            for _, obj in ipairs(Items:GetChildren()) do
                if obj:IsA("Model") and (obj.Name:find("Bolt") or obj.Name:find("Sheet Metal") or obj.Name:find("Broken Fan") or obj.Name:find("Old Radio")) then
                    table.insert(scraps, obj)
                end
            end
            return scraps
        end,
        Fuel = function()
            local fuels = {}
            for _, obj in ipairs(Items:GetChildren()) do
                if obj:IsA("Model") and (obj.Name:find("Log") or obj.Name:find("Coal") or obj.Name:find("Oil Barrel") or obj.Name:find("Fuel Canister")) then
                    table.insert(fuels, obj)
                end
            end
            return fuels
        end,
        ["Misc Items"] = function()
            local misc = {}
            for _, obj in ipairs(Items:GetChildren()) do
                local name = obj.Name
                if obj:IsA("Model") and not (name:find("Berry") or name:find("Apple") or name:find("Carrot") or name:find("Steak") or name:find("Morsel") or name:find("Bolt") or name:find("Sheet Metal") or name:find("Broken Fan") or name:find("Old Radio") or name:find("Log") or name:find("Coal") or name:find("Oil Barrel") or name:find("Fuel Canister")) then
                    table.insert(misc, obj)
                end
            end
            return misc
        end
    }
    return categories[category] and categories[category]() or {}
end

-- ESP optimization: Dynamic culling every 0.5s, only close objects
local espLoops = {} -- cat -> connection
local espObjects = {} -- cat -> {obj = true}
local espColors = {} -- cat -> Color3

for _, cat in ipairs({"Player", "Animal", "Enemy", "Lost Kid", "Food", "Scrap", "Fuel", "Misc Items"}) do
    local toggle = VisualsGroup:AddCheckbox(cat .. "ESP", {
        Text = cat .. " ESP",
        Default = false,
        Callback = function(Value)
            if Value then
                espObjects[cat] = {}
                espColors[cat] = Color3.fromRGB(255, 255, 255)
                espLoops[cat] = task.spawn(function()
                    while Toggles[cat .. "ESP"].Value do
                        local objects = getAllowedObjects(cat)
                        local current = {}
                        local playerRootPos = playerRoot()
                        if not playerRootPos then
                            task.wait(0.5)
                            continue
                        end
                        for _, obj in ipairs(objects) do
                            local root = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                            if root and (root.Position - playerRootPos.Position).Magnitude <= _G.ESPDistance then
                                current[obj] = true
                                if not espObjects[cat][obj] then
                                    addESPWithDynamicColor(obj, obj.Name, root, espColors[cat])
                                    espObjects[cat][obj] = true
                                end
                            end
                        end
                        -- Remove far ones
                        for obj, _ in pairs(espObjects[cat]) do
                            if not current[obj] then
                                ESP_Library:RemoveESP(obj)
                                espObjects[cat][obj] = nil
                            end
                        end
                        espObjects[cat] = current
                        task.wait(0.5) -- Throttled update
                    end
                    -- Cleanup
                    for obj, _ in pairs(espObjects[cat] or {}) do
                        ESP_Library:RemoveESP(obj)
                    end
                    espObjects[cat] = nil
                    espLoops[cat] = nil
                end)
            else
                if espLoops[cat] then
                    task.cancel(espLoops[cat])
                    espLoops[cat] = nil
                end
                for obj, _ in pairs(espObjects[cat] or {}) do
                    ESP_Library:RemoveESP(obj)
                end
                espObjects[cat] = nil
            end
        end
    })
    local colorPicker = toggle:AddColorPicker(cat .. "Color", {
        Default = Color3.fromRGB(255, 255, 255),
        Title = cat .. " Color",
        Callback = function(Value)
            espColors[cat] = Value
            local espColor = getESPColor(Value)
            for obj, _ in pairs(espObjects[cat] or {}) do
                if ESP_Library:GetESP(obj) then
                    ESP_Library:UpdateObjectColor(obj, espColor)
                end
            end
        end
    })
end

local lightingGroup = Tabs.Visuals:AddRightGroupbox("Lighting")
local fullbrightEnabled = false
lightingGroup:AddCheckbox("Fullbright", {
    Text = "Fullbright",
    Default = false,
    Callback = function(Value)
        fullbrightEnabled = Value
        if Value then
            Lighting.Brightness = 2
            Lighting.Ambient = Color3.new(1,1,1)
            Lighting.ColorShift_Bottom = Color3.new(0,0,0)
            Lighting.ColorShift_Top = Color3.new(0,0,0)
            Lighting.OutdoorAmbient = Color3.new(1,1,1)
            Lighting.ClockTime = 14
        else
            Lighting.Brightness = 1
            Lighting.Ambient = Color3.new(0.4,0.4,0.4)
            Lighting.ColorShift_Bottom = Color3.new(0,0,0)
            Lighting.ColorShift_Top = Color3.new(0,0,0)
            Lighting.OutdoorAmbient = Color3.new(0.5,0.5,0.5)
            Lighting.ClockTime = 12
        end
    end
})
lightingGroup:AddCheckbox("NoFog", {
    Text = "No Fog",
    Default = false,
    Callback = function(Value)
        Lighting.FogEnd = Value and 100000 or 100000
        Lighting.FogStart = Value and 0 or 0
    end
})
local antiLagEnabled = false
lightingGroup:AddCheckbox("AntiLag", {
    Text = "Anti Lag",
    Default = false,
    Callback = function(Value)
        antiLagEnabled = Value
        settings().Rendering.QualityLevel = Value and Enum.SavedQualitySetting.Automatic or Enum.SavedQualitySetting.Automatic
        Workspace.StreamingEnabled = not Value
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
                v.Enabled = not Value
            end
        end
    end
})

local PlayerGroup = Tabs.Player:AddLeftGroupbox('Player Mods')

-- Defer humanoid init until character loads
task.spawn(function()
    repeat task.wait() until LocalPlayer.Character
    humanoid = LocalPlayer.Character:WaitForChild("Humanoid")
end)

PlayerGroup:AddSlider("WalkSpeed", {
    Text = "Walk Speed",
    Default = 16,
    Min = 1,
    Max = 700,
    Rounding = 0,
    Compact = true,
    Callback = function(Value)
        if humanoid then humanoid.WalkSpeed = Value end
    end
})

local jumpPowerConnection
PlayerGroup:AddSlider("JumpPower", {
    Text = "Jump Power",
    Default = 50,
    Min = 50,
    Max = 700,
    Rounding = 0,
    Compact = true,
    Callback = function(Value)
        if humanoid then
            humanoid.JumpPower = Value
            humanoid.UseJumpPower = true
            humanoid.JumpHeight = Value / 50
        end
        if jumpPowerConnection then jumpPowerConnection:Disconnect() end
        jumpPowerConnection = humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
            if humanoid.JumpPower ~= Value then
                humanoid.JumpPower = Value
                humanoid.UseJumpPower = true
                humanoid.JumpHeight = Value / 50
            end
        end)
    end
})

_G.HackedWalkSpeed = 16
PlayerGroup:AddCheckbox("WalkSpeedToggle50", {
    Text = "Walk Speed Toggle (50)",
    Default = false,
    Callback = function(Value)
        _G.HackedWalkSpeed = Value and 50 or 16
        local function applyWalkSpeed(hum)
            if hum then
                hum.WalkSpeed = _G.HackedWalkSpeed
                hum.Changed:Connect(function(prop)
                    if prop == "WalkSpeed" and hum.WalkSpeed ~= _G.HackedWalkSpeed then
                        hum.WalkSpeed = _G.HackedWalkSpeed
                    end
                end)
            end
        end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            applyWalkSpeed(LocalPlayer.Character.Humanoid)
        end
        LocalPlayer.CharacterAdded:Connect(function(char)
            char:WaitForChild("Humanoid")
            applyWalkSpeed(char:FindFirstChild("Humanoid"))
        end)
    end
})

local InfiniteJumpEnabled = false
PlayerGroup:AddCheckbox("InfiniteJump", {
    Text = "Infinite Jump",
    Default = false,
    Callback = function(Value)
        InfiniteJumpEnabled = Value
    end
})
UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpEnabled and humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Seated then
        if humanoid.FloorMaterial == Enum.Material.Air then
            humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
            task.wait(0.02)
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

local NoclipEnabled = false
PlayerGroup:AddCheckbox("Noclip", {
    Text = "Noclip",
    Default = false,
    Callback = function(Value)
        NoclipEnabled = Value
    end
})
RunService.Stepped:Connect(function()
    if NoclipEnabled then
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end)

local isFlying = false
local flySpeed = 60
local flyConnections = {}
local flyKeys = {W = false, A = false, S = false, D = false, Space = false, Shift = false}

local function startFlight()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not (hum and hrp) then return end
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.Name = "FlightGyro"
    bodyGyro.P = 9e4
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.CFrame = hrp.CFrame
    bodyGyro.Parent = hrp
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Name = "FlightVelocity"
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = hrp
    hum.AutoRotate = false
    hum.PlatformStand = true
    hum:ChangeState(Enum.HumanoidStateType.Physics)
    local inputBegan = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        local kc = input.KeyCode
        if kc == Enum.KeyCode.W then flyKeys.W = true
        elseif kc == Enum.KeyCode.A then flyKeys.A = true
        elseif kc == Enum.KeyCode.S then flyKeys.S = true
        elseif kc == Enum.KeyCode.D then flyKeys.D = true
        elseif kc == Enum.KeyCode.Space then flyKeys.Space = true
        elseif kc == Enum.KeyCode.LeftShift then flyKeys.Shift = true end
    end)
    table.insert(flyConnections, inputBegan)
    local inputEnded = UserInputService.InputEnded:Connect(function(input)
        local kc = input.KeyCode
        if kc == Enum.KeyCode.W then flyKeys.W = false
        elseif kc == Enum.KeyCode.A then flyKeys.A = false
        elseif kc == Enum.KeyCode.S then flyKeys.S = false
        elseif kc == Enum.KeyCode.D then flyKeys.D = false
        elseif kc == Enum.KeyCode.Space then flyKeys.Space = false
        elseif kc == Enum.KeyCode.LeftShift then flyKeys.Shift = false end
    end)
    table.insert(flyConnections, inputEnded)
    local renderConnection = RunService.RenderStepped:Connect(function()
        if not (char and hrp and hrp:FindFirstChild("FlightVelocity")) then
            stopFlight()
            return
        end
        local camCF = camera.CFrame
        local moveVec = Vector3.zero
        if flyKeys.W then moveVec += camCF.LookVector end
        if flyKeys.S then moveVec -= camCF.LookVector end
        if flyKeys.A then moveVec -= camCF.RightVector end
        if flyKeys.D then moveVec += camCF.RightVector end
        if flyKeys.Space then moveVec += camCF.UpVector end
        if flyKeys.Shift then moveVec -= camCF.UpVector end
        hrp.FlightVelocity.Velocity = moveVec.Magnitude > 0 and moveVec.Unit * flySpeed or Vector3.zero
        hrp.FlightGyro.CFrame = camCF
    end)
    table.insert(flyConnections, renderConnection)
end

function stopFlight()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        if hrp:FindFirstChild("FlightVelocity") then hrp.FlightVelocity:Destroy() end
        if hrp:FindFirstChild("FlightGyro") then hrp.FlightGyro:Destroy() end
    end
    if hum then
        hum.AutoRotate = true
        hum.PlatformStand = false
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
    for _, conn in ipairs(flyConnections) do conn:Disconnect() end
    table.clear(flyConnections)
    table.clear(flyKeys)
end

PlayerGroup:AddCheckbox("Fly", {
    Text = "Fly (WASD + Space + Shift)",
    Default = false,
    Callback = function(Value)
        isFlying = Value
        if Value then startFlight() else stopFlight() end
    end
}):AddKeyPicker("FlyKeybind", {
    Default = "Q",
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "Fly Toggle",
    NoUI = false,
    Callback = function() end
})

local godmodeEnabled = false
local godmodeConnection
PlayerGroup:AddCheckbox("Godmode", {
    Text = "Godmode",
    Default = false,
    Callback = function(Value)
        godmodeEnabled = Value
        if humanoid then
            humanoid.MaxHealth = Value and math.huge or 100
            humanoid.Health = Value and math.huge or 100
        end
        if godmodeConnection then godmodeConnection:Disconnect() end
        godmodeConnection = humanoid.HealthChanged:Connect(function(health)
            if godmodeEnabled and health < humanoid.MaxHealth then
                humanoid.Health = humanoid.MaxHealth
            end
        end)
    end
})

local TeleportGroup = Tabs.Teleports:AddLeftGroupbox("Quick Teleports")
TeleportGroup:AddButton({
    Text = "Teleport to Campfire",
    Func = function()
        local char = LocalPlayer.Character
        if char then char:PivotTo(CFrame.new(0, 10, 0)) end
    end
})
TeleportGroup:AddButton({
    Text = "Teleport to Grinder",
    Func = function()
        local char = LocalPlayer.Character
        if char then char:PivotTo(CFrame.new(16.1,4,-4.6)) end
    end
})

local storyCoords = {
    { "[safezone] safe zone", "0, 110, -0" }
}
local storyTPGroup = Tabs.Teleports:AddRightGroupbox("Story Teleports")
for _, entry in ipairs(storyCoords) do
    local name, coord = entry[1], entry[2]
    storyTPGroup:AddButton({
        Text = name,
        Func = function()
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then 
                    local x, y, z = coord:match("([^,]+),%s*([^,]+),%s*([^,]+)")
                    hrp.CFrame = CFrame.new(tonumber(x), tonumber(y), tonumber(z)) 
                end
            end
        end
    })
end

local kidsGroup = Tabs.Teleports:AddLeftGroupbox("Lost Kids Coordinates")
local kidLabels = {}
local function updateKidsList()
    for _, label in ipairs(kidLabels) do
        if label and label.Parent then
            label:Destroy()
        end
    end
    kidLabels = {}
    local kids = {}
    for _, obj in ipairs(Characters:GetChildren()) do
        if obj:IsA("Model") and obj.Name:find("Lost Child") then
            local pos = obj.PrimaryPart and obj.PrimaryPart.Position or (pcall(function() return obj:GetPivot().Position end) and obj:GetPivot().Position or Vector3.new(0,0,0))
            table.insert(kids, {name = obj.Name, pos = pos})
        end
    end
    for _, kid in ipairs(kids) do
        local label = kidsGroup:AddLabel('<font color="rgb(255,165,0)">' .. kid.name .. '</font> | ' .. tostring(math.floor(kid.pos.X)) .. ', ' .. tostring(math.floor(kid.pos.Y)) .. ', ' .. tostring(math.floor(kid.pos.Z)))
        table.insert(kidLabels, label)
    end
end
updateKidsList()
-- Throttled update every 2s instead of every frame
task.spawn(function()
    while true do
        updateKidsList()
        task.wait(2)
    end
end)

local teleportTargets = {
    "Alien", "Alien Chest", "Alien Shelf", "Alpha Wolf", "Alpha Wolf Pelt", "Anvil Base", "Apple", "Bandage", "Bear", "Berry",
    "Bolt", "Broken Fan", "Broken Microwave", "Bunny", "Bunny Foot", "Cake", "Carrot", "Chair Set", "Chest", "Chilli",
    "Coal", "Coin Stack", "Crossbow Cultist", "Cultist", "Cultist Gem", "Deer", "Fuel Canister", "Giant Sack", "Good Axe", "Iron Body",
    "Item Chest", "Item Chest2", "Item Chest3", "Item Chest4", "Item Chest6", "Laser Fence Blueprint", "Laser Sword", "Leather Body", "Log", "Lost Child",
    "Lost Child2", "Lost Child3", "Lost Child4", "Medkit", "Meat? Sandwich", "Morsel", "Old Car Engine", "Old Flashlight", "Old Radio", "Oil Barrel",
    "Raygun", "Revolver", "Revolver Ammo", "Rifle", "Rifle Ammo", "Riot Shield", "Sapling", "Seed Box", "Sheet Metal", "Spear",
    "Steak", "Stronghold Diamond Chest", "Tyre", "UFO Component", "UFO Junk", "Washing Machine", "Wolf", "Wolf Corpse", "Wolf Pelt"
}
local tpDropdown = Tabs.Teleports:AddRightGroupbox("Teleport to Item/Mob"):AddDropdown("TPTarget", {
    Text = "Select Target",
    Default = "",
    Values = teleportTargets,
    Callback = function(Value)
        if Value == "" then return end
        local closest, shortest = nil, math.huge
        local ignoreDistanceFrom = Vector3.new(0, 0, 0)
        local minDistance = 50
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name == Value and obj:IsA("Model") then
                local cf = nil
                if pcall(function() cf = obj:GetPivot() end) then
                else
                    local part = obj:FindFirstChildWhichIsA("BasePart")
                    if part then cf = part.CFrame end
                end
                if cf then
                    local dist = (cf.Position - ignoreDistanceFrom).Magnitude
                    if dist >= minDistance and dist < shortest then
                        closest = obj
                        shortest = dist
                    end
                end
            end
        end
        if closest then
            local cf = nil
            if pcall(function() cf = closest:GetPivot() end) then
            else
                local part = closest:FindFirstChildWhichIsA("BasePart")
                if part then cf = part.CFrame end
            end
            if cf then
                local char = LocalPlayer.Character
                if char then char:PivotTo(cf + Vector3.new(0, 5, 0)) end
            end
        end
    end
})

local possibleCharacters = {
    "Alpha Wolf", "Bear", "Lost Child", "Lost Child2", "Lost Child3", "Lost Child4",
    "Wolf", "Bunny", "Cultist", "Alien"
}
local mobTPDropdown = Tabs.Teleports:AddLeftGroupbox("Teleport Mob to You"):AddDropdown("TPMob", {
    Text = "Select Mob",
    Default = "",
    Values = possibleCharacters,
    Callback = function(Value)
        if Value == "" then return end
        local characterFolder = Characters
        local stackOffsetY = 3
        local count = 0
        for _, model in ipairs(characterFolder:GetChildren()) do
            if model.Name == Value then
                local mainPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
                if mainPart and rootPart then
                    local targetCFrame = rootPart.CFrame + Vector3.new(0, count * stackOffsetY, 0)
                    if model.PrimaryPart then
                        model:SetPrimaryPartCFrame(targetCFrame)
                    else
                        mainPart.CFrame = targetCFrame
                    end
                    count = count + 1
                end
            end
        end
    end
})

local safezoneBaseplates = {}
local baseplateSize = Vector3.new(2048, 1, 2048)
local baseY = 100
local centerPos = Vector3.new(0, baseY, 0)
for dx = -1, 1 do
    for dz = -1, 1 do
        local pos = centerPos + Vector3.new(dx * baseplateSize.X, 0, dz * baseplateSize.Z)
        local baseplate = Instance.new("Part")
        baseplate.Name = "SafeZoneBaseplate"
        baseplate.Size = baseplateSize
        baseplate.Position = pos
        baseplate.Anchored = true
        baseplate.CanCollide = false
        baseplate.Transparency = 1
        baseplate.Color = Color3.fromRGB(255, 255, 255)
        baseplate.Parent = Workspace
        table.insert(safezoneBaseplates, baseplate)
    end
end

local safeZoneGroup = Tabs.Farming:AddLeftGroupbox("Safe Zone")
safeZoneGroup:AddCheckbox("ShowSafeZone", {
    Text = "Show Safe Zone",
    Default = false,
    Callback = function(Value)
        for _, baseplate in ipairs(safezoneBaseplates) do
            baseplate.Transparency = Value and 0.8 or 1
            baseplate.CanCollide = Value
        end
    end
})

local killAuraToggle = false
local radius = 200
local toolsDamageIDs = {
    ["Old Axe"] = "1_8982038982",
    ["Good Axe"] = "112_8982038982",
    ["Strong Axe"] = "116_8982038982",
    ["Chainsaw"] = "647_8992824875",
    ["Spear"] = "196_8999010016"
}
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

local function getAnyToolWithDamageID()
    for toolName, damageID in pairs(toolsDamageIDs) do
        local tool = player.Backpack:FindFirstChild(toolName) or player.Character:FindFirstChild(toolName)
        if tool then return tool, damageID end
    end
    return nil, nil
end

local function equipTool(tool)
    if tool then remoteEvents.EquipItemHandle:FireServer("FireAllClients", tool) end
end

local function unequipTool(tool)
    if tool then remoteEvents.UnequipItemHandle:FireServer("FireAllClients", tool) end
end

local function killAuraLoop()
    while killAuraToggle do
        local char = LocalPlayer.Character
        if not char then task.wait(0.5); continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then task.wait(0.5); continue end
        local tool, damageID = getAnyToolWithDamageID()
        if tool and damageID then
            equipTool(tool)
            for _, mob in ipairs(Characters:GetChildren()) do
                if mob:IsA("Model") then
                    local part = mob:FindFirstChildWhichIsA("BasePart")
                    if part and (part.Position - hrp.Position).Magnitude <= radius then
                        pcall(function()
                            remoteEvents.ToolDamageObject:InvokeServer(mob, tool, damageID, CFrame.new(part.Position))
                        end)
                    end
                end
            end
            task.wait(0.1)
        else
            task.wait(1)
        end
    end
end

local killAuraGroup = Tabs.Farming:AddRightGroupbox("Kill Aura")
killAuraGroup:AddCheckbox("KillAura", {
    Text = "Kill Aura",
    Default = false,
    Callback = function(Value)
        killAuraToggle = Value
        if Value then
            task.spawn(killAuraLoop)
        else
            local tool, _ = getAnyToolWithDamageID()
            unequipTool(tool)
        end
    end
})
killAuraGroup:AddSlider("KillAuraRadius", {
    Text = "Radius",
    Default = 200,
    Min = 20,
    Max = 500,
    Rounding = 0,
    Compact = true,
    Callback = function(Value)
        radius = Value
    end
})

local campfireDropPos = Vector3.new(0, 19, 0)
local machineDropPos = Vector3.new(21, 16, -5)
local campfireFuelItems = {"Log", "Coal", "Fuel Canister", "Oil Barrel", "Biofuel"}
local autocookItems = {"Morsel", "Steak"}
local autoGrindItems = {"UFO Junk", "UFO Component", "Old Car Engine", "Broken Fan", "Old Microwave", "Bolt", "Log", "Cultist Gem", "Sheet Metal", "Old Radio","Tyre","Washing Machine", "Cultist Experiment", "Cultist Component", "Gem of the Forest Fragment", "Broken Microwave"}
local autoEatFoods = {"Cooked Steak", "Cooked Morsel", "Berry", "Carrot", "Apple"}
local biofuelItems = {"Carrot", "Cooked Morsel", "Morsel", "Steak", "Cooked Steak", "Log"}
local autoFuelEnabledItems = {}
local autoCookEnabledItems = {}
local autoGrindEnabledItems = {}
local autoEatEnabled = false
local autoEatHPEnabled = false
local autoBiofuelEnabledItems = {}
local alwaysFeedEnabledItems = {}

local remoteConsume = remoteEvents:WaitForChild("RequestConsumeItem")

local function moveItemToPos(item, position)
    if not item or not item:IsDescendantOf(Workspace) then return end
    local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart") or item:FindFirstChild("Handle")
    if not part then return end
    if not item.PrimaryPart then pcall(function() item.PrimaryPart = part end) end
    pcall(function()
        remoteEvents.RequestStartDraggingItem:FireServer(item)
        task.wait(0.05)
        item:SetPrimaryPartCFrame(CFrame.new(position))
        task.wait(0.05)
        remoteEvents.StopDraggingItem:FireServer(item)
    end)
end

local function createAutoDropdown(title, itemList, enabledTable)
    local group = Tabs.Farming:AddLeftGroupbox(title)
    local dropdown = group:AddDropdown(title .. "Select", {
        Text = "Select Items",
        Default = "",
        Multi = true,
        Values = itemList,
        Callback = function(Value)
        end
    })
    group:AddCheckbox(title .. "BulkEnable", {
        Text = "Enable All",
        Default = false,
        Callback = function(Value)
            for _, itemName in ipairs(itemList) do
                enabledTable[itemName] = Value
            end
        end
    })
end

createAutoDropdown("Auto Feed Campfire (ignores HP)", campfireFuelItems, alwaysFeedEnabledItems)
createAutoDropdown("Auto Feed Campfire (HP Based)", campfireFuelItems, autoFuelEnabledItems)
createAutoDropdown("Auto Cook Food", autocookItems, autoCookEnabledItems)
createAutoDropdown("Auto Machine Grind", autoGrindItems, autoGrindEnabledItems)
createAutoDropdown("Auto Biofuel Processor", biofuelItems, autoBiofuelEnabledItems)

local eatGroup = Tabs.Farming:AddRightGroupbox("Auto Eat")
eatGroup:AddCheckbox("AutoEat3Sec", {
    Text = "Enable Auto Eat (3 sec interval)",
    Default = false,
    Callback = function(Value)
        autoEatEnabled = Value
    end
})
eatGroup:AddCheckbox("AutoEatHPBased", {
    Text = "Enable Auto Eat (HP Based)",
    Default = false,
    Callback = function(Value)
        autoEatHPEnabled = Value
    end
})

local function simulateMouseClick()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

-- Optimized tree farm: Scan only Foliage and Landmarks descendants
local Map = Workspace:WaitForChild("Map")
local Foliage = Map:WaitForChild("Foliage")
local Landmarks = Map:WaitForChild("Landmarks")
task.spawn(function()
    while true do
        if autoTreeFarmEnabled then
            local trees = {}
            local ignoreDistanceFrom = Vector3.new(0, 0, 0)
            local minDistance = 50
            -- Scan only relevant folders
            for _, folder in {Foliage, Landmarks} do
                for _, obj in ipairs(folder:GetDescendants()) do
                    if obj.Name == "Trunk" and obj.Parent and obj.Parent.Name == "Small Tree" then
                        local distance = (obj.Position - ignoreDistanceFrom).Magnitude
                        if distance > minDistance and not badTrees[obj:GetFullName()] then
                            table.insert(trees, obj)
                        end
                    end
                end
            end
            table.sort(trees, function(a, b)
                return (a.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <
                    (b.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            end)
            for _, trunk in ipairs(trees) do
                if not autoTreeFarmEnabled then break end
                LocalPlayer.Character:PivotTo(trunk.CFrame + Vector3.new(0, 3, 0))
                task.wait(0.2)
                local startTime = tick()
                while autoTreeFarmEnabled and trunk and trunk.Parent and trunk.Parent.Name == "Small Tree" do
                    simulateMouseClick()
                    task.wait(0.2)
                    if tick() - startTime > 12 then
                        badTrees[trunk:GetFullName()] = true
                        break
                    end
                end
                task.wait(0.3)
            end
        end
        task.wait(1.5)
    end
end)

local treeGroup = Tabs.Farming:AddLeftGroupbox("Auto Tree Farm")
treeGroup:AddCheckbox("AutoTreeFarm", {
    Text = "Auto Tree Farm (Small Trees)",
    Default = false,
    Callback = function(Value)
        autoTreeFarmEnabled = Value
    end
})

coroutine.wrap(function()
    while true do
        for itemName, enabled in pairs(alwaysFeedEnabledItems) do
            if enabled then
                for _, item in ipairs(Items:GetChildren()) do
                    if item.Name == itemName then moveItemToPos(item, campfireDropPos) end
                end
            end
        end
        task.wait(2)
    end
end)()

coroutine.wrap(function()
    local campfire = Map:WaitForChild("Campground"):WaitForChild("MainFire")
    local fillFrame = campfire.Center.BillboardGui.Frame.Background.Fill
    while true do
        local healthPercent = fillFrame.Size.X.Scale
        if healthPercent < 0.7 then
            repeat
                for itemName, enabled in pairs(autoFuelEnabledItems) do
                    if enabled then
                        for _, item in ipairs(Items:GetChildren()) do
                            if item.Name == itemName then moveItemToPos(item, campfireDropPos) end
                        end
                    end
                end
                task.wait(0.5)
                healthPercent = fillFrame.Size.X.Scale
            until healthPercent >= 1
        end
        task.wait(2)
    end
end)()

coroutine.wrap(function()
    while true do
        for itemName, enabled in pairs(autoCookEnabledItems) do
            if enabled then
                for _, item in ipairs(Items:GetChildren()) do
                    if item.Name == itemName then moveItemToPos(item, campfireDropPos) end
                end
            end
        end
        task.wait(2.5)
    end
end)()

coroutine.wrap(function()
    while true do
        for itemName, enabled in pairs(autoGrindEnabledItems) do
            if enabled then
                for _, item in ipairs(Items:GetChildren()) do
                    if item.Name == itemName then moveItemToPos(item, machineDropPos) end
                end
            end
        end
        task.wait(2.5)
    end
end)()

coroutine.wrap(function()
    while true do
        if autoEatEnabled then
            local available = {}
            for _, item in ipairs(Items:GetChildren()) do
                if table.find(autoEatFoods, item.Name) then table.insert(available, item) end
            end
            if #available > 0 then
                local food = available[math.random(1, #available)]
                pcall(function() remoteConsume:InvokeServer(food) end)
            end
        end
        task.wait(3)
    end
end)()

local hungerBar = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Interface"):WaitForChild("StatBars"):WaitForChild("HungerBar"):WaitForChild("Bar")
coroutine.wrap(function()
    while true do
        if autoEatHPEnabled then
            if hungerBar.Size.X.Scale <= 0.5 then
                repeat
                    local currentHunger = hungerBar.Size.X.Scale
                    local available = {}
                    for _, item in ipairs(Items:GetChildren()) do
                        if item.Name and table.find(autoEatFoods, item.Name) then
                            table.insert(available, item)
                        end
                    end
                    if #available > 0 then
                        local food = available[math.random(1, #available)]
                        if food then
                            pcall(function() remoteConsume:InvokeServer(food) end)
                        end
                    else
                        break
                    end
                    task.wait(1)
                until hungerBar.Size.X.Scale >= 0.99 or not autoEatHPEnabled
            end
        end
        task.wait(3)
    end
end)()

coroutine.wrap(function()
    local biofuelProcessorPos
    while true do
        if not biofuelProcessorPos then
            local Structures = Workspace:FindFirstChild("Structures")
            local processor = Structures and Structures:FindFirstChild("Biofuel Processor")
            local part = processor and processor:FindFirstChild("Part")
            if part then biofuelProcessorPos = part.Position + Vector3.new(0, 5, 0) end
        end
        if biofuelProcessorPos then
            for itemName, enabled in pairs(autoBiofuelEnabledItems) do
                if enabled then
                    for _, item in ipairs(Items:GetChildren()) do
                        if item.Name == itemName then moveItemToPos(item, biofuelProcessorPos) end
                    end
                end
            end
        end
        task.wait(2)
    end
end)()

local originalTreeCFrames = {}

local function getAllSmallTrees()
    local trees = {}
    local function scan(folder)
        for _, obj in ipairs(folder:GetChildren()) do
            if obj:IsA("Model") and obj.Name == "Small Tree" then table.insert(trees, obj) end
        end
    end
    if Foliage then scan(Foliage) end
    if Landmarks then scan(Landmarks) end
    return trees
end

local function findTrunk(tree)
    for _, part in ipairs(tree:GetDescendants()) do
        if part:IsA("BasePart") and part.Name == "Trunk" then return part end
    end
end

local function bringAllTrees()
    if not rootPart then return end
    local target = CFrame.new(rootPart.Position + rootPart.CFrame.LookVector * 10)
    for _, tree in ipairs(getAllSmallTrees()) do
        local trunk = findTrunk(tree)
        if trunk then
            if not originalTreeCFrames[tree] then originalTreeCFrames[tree] = trunk.CFrame end
            tree.PrimaryPart = trunk
            trunk.Anchored = false
            trunk.CanCollide = false
            task.wait()
            tree:SetPrimaryPartCFrame(target + Vector3.new(math.random(-5,5), 0, math.random(-5,5)))
            trunk.Anchored = true
        end
    end
    treesBrought = true
end

local function restoreTrees()
    for tree, cframe in pairs(originalTreeCFrames) do
        local trunk = findTrunk(tree)
        if trunk then
            tree.PrimaryPart = trunk
            tree:SetPrimaryPartCFrame(cframe)
            trunk.Anchored = true
            trunk.CanCollide = true
        end
    end
    originalTreeCFrames = {}
    treesBrought = false
end

treeGroup:AddCheckbox("AutoBringTrees", {
    Text = "Auto Bring All Small Trees",
    Default = false,
    Callback = function(Value)
        if Value and not treesBrought then bringAllTrees()
        elseif not Value and treesBrought then restoreTrees() end
    end
})

local strongholdRunning = true
local function getStrongholdTimerLabel()
    return Map:FindFirstChild("Landmarks")
        and Map.Landmarks:FindFirstChild("Stronghold")
        and Map.Landmarks.Stronghold:FindFirstChild("Functional")
        and Map.Landmarks.Stronghold.Functional:FindFirstChild("Sign")
        and Map.Landmarks.Stronghold.Functional.Sign:FindFirstChild("SurfaceGui")
        and Map.Landmarks.Stronghold.Functional.Sign.SurfaceGui:FindFirstChild("Frame")
        and Map.Landmarks.Stronghold.Functional.Sign.SurfaceGui.Frame:FindFirstChild("Body")
end

local strongholdGroup = Tabs.Teleports:AddRightGroupbox("Stronghold")
local strongholdDropdown = strongholdGroup:AddDropdown("StrongholdActions", {
    Text = "Actions",
    Default = "",
    Values = {"Teleport to Stronghold", "Teleport to Diamond Chest"},
    Callback = function(Value)
        if Value == "Teleport to Stronghold" then
            local targetPart = Map:FindFirstChild("Landmarks")
                and Map.Landmarks:FindFirstChild("Stronghold")
                and Map.Landmarks.Stronghold:FindFirstChild("Functional")
                and Map.Landmarks.Stronghold.Functional:FindFirstChild("EntryDoors")
                and Map.Landmarks.Stronghold.Functional.EntryDoors:FindFirstChild("DoorRight")
                and Map.Landmarks.Stronghold.Functional.EntryDoors.DoorRight:FindFirstChild("Model")
            if targetPart then
                local children = targetPart:GetChildren()
                local destination = children[5]
                if destination and destination:IsA("BasePart") then
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then hrp.CFrame = destination.CFrame + Vector3.new(0, 5, 0) end
                end
            end
        elseif Value == "Teleport to Diamond Chest" then
            local items = Items
            if not items then return end
            local chest = items:FindFirstChild("Stronghold Diamond Chest")
            if not chest then return end
            local chestLid = chest:FindFirstChild("ChestLid")
            if not chestLid then return end
            local diamondchest = chestLid:FindFirstChild("Meshes/diamondchest_Cube.002")
            if not diamondchest then return end
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = diamondchest.CFrame + Vector3.new(0, 5, 0) end
        end
    end
})

coroutine.wrap(function()
    local lastTimerText = nil
    while strongholdRunning do
        local label = getStrongholdTimerLabel()
        local timerText = "Stronghold Timer: " .. tostring(label and label.ContentText or "N/A")
        if timerText ~= lastTimerText then
            Library:Notify(timerText, 1)
            lastTimerText = timerText
        end
        task.wait(0.5)
    end
end)()

local bracket = {
    weapons = {"Laser Sword", "Raygun", "Kunai", "Katana", "Spear"},
    minifoods = {"Apple", "Berry", "Carrot"},
    meat = {"Steak", "Cooked Steak", "Cooked Morsel" , "Morsel"},
    ["guns/ammo"] = {"Rifle", "Revolver", "Raygun", "Tactical Shotgun", "Revolver Ammo", "Rifle Ammo"},
    materials = {"Log", "Coal", "Fuel Canister", "UFO Junk", "UFO Component", "Bandage", "MedKit",
        "Old Car Engine", "Broken Fan", "Old Microwave", "Old Radio", "Sheet Metal"},
    pelts = {"Alpha Wolf Pelt", "Bear Pelt", "Wolf Pelt", "Bunny Foot"},
    misc_tools = {"Good Sack", "Old Flashlight", "Old Radio", "Giant Sack", "Strong Flashlight", "Chainsaw"}
}

local function findTeleportablePart(item)
    for _, descendant in ipairs(item:GetDescendants()) do
        if descendant:IsA("BasePart") then return descendant end
        if descendant:IsA("Model") then
            for _, sub in ipairs(descendant:GetDescendants()) do
                if sub:IsA("BasePart") then return sub end
            end
        end
    end
    return nil
end

local function teleportBracketItem(itemName)
    if not rootPart then return end
    local stackOffsetY = 2
    local count = 0
    for _, item in ipairs(Items:GetChildren()) do
        if item.Name == itemName then
            local targetPart = findTeleportablePart(item)
            if targetPart then
                remoteEvents.RequestStartDraggingItem:FireServer(item)
                local offset = Vector3.new(0, count * stackOffsetY, 0)
                targetPart.CFrame = rootPart.CFrame + offset
                remoteEvents.StopDraggingItem:FireServer(item)
                count = count + 1
            end
        end
    end
end

for groupName, itemList in pairs(bracket) do
    local label = groupName:gsub("_", " "):gsub("/", " / ")
    label = label:gsub("(%a)([%w_']*)", function(first, rest) return first:upper() .. rest:lower() end)
    local bracketGroup = Tabs.Teleports:AddRightGroupbox(label)
    local bracketDropdown = bracketGroup:AddDropdown(groupName .. "TP", {
        Text = "Select Item",
        Default = "",
        Values = itemList,
        Callback = function(Value)
            if Value == "" then return end
            teleportBracketItem(Value)
        end
    })
end

extraScriptsGroup:AddButton({
    Text = "Anti AFK",
    Func = function()
        wait(0.5)
        local ba=Instance.new("ScreenGui")
        local ca=Instance.new("TextLabel")local da=Instance.new("Frame")
        local _b=Instance.new("TextLabel")local ab=Instance.new("TextLabel")
        ba.Parent=game.CoreGui
        ba.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
        ca.Parent=ba
        ca.Active=true
        ca.BackgroundColor3=Color3.new(0.176471,0.176471,0.176471)
        ca.Draggable=true
        ca.Position=UDim2.new(0.698610067,0,0.098096624,0)
        ca.Size=UDim2.new(0,370,0,52)
        ca.Font=Enum.Font.SourceSansSemibold
        ca.Text="anti afk"
        ca.TextColor3=Color3.new(0,1,1)
        ca.TextSize=22
        da.Parent=ca
        da.BackgroundColor3=Color3.new(0.196078,0.196078,0.196078)
        da.Position=UDim2.new(0,0,1.0192306,0)
        da.Size=UDim2.new(0,370,0,107)
        _b.Parent=da
        _b.BackgroundColor3=Color3.new(0.176471,0.176471,0.176471)
        _b.Position=UDim2.new(0,0,0.800455689,0)
        _b.Size=UDim2.new(0,370,0,21)
        _b.Font=Enum.Font.Arial
        _b.Text="anti afk"
        _b.TextColor3=Color3.new(0,1,1)
        _b.TextSize=20
        ab.Parent=da
        ab.BackgroundColor3=Color3.new(0.176471,0.176471,0.176471)
        ab.Position=UDim2.new(0,0,0.158377,0)
        ab.Size=UDim2.new(0,370,0,44)
        ab.Font=Enum.Font.ArialBold
        ab.Text="status: active"
        ab.TextColor3=Color3.new(0,1,1)
        ab.TextSize=20
        local bb=game:service'VirtualUser'
        game:service'Players'.LocalPlayer.Idled:connect(function()
            bb:CaptureController()
            bb:ClickButton2(Vector2.new())
            ab.Text="roblox tried to kick you but failed to do so!"
            wait(2)
            ab.Text="status : active"
        end)
    end
})


local UISettings = Window:AddTab("UI Settings", "user-round-cog")
local SettingsLeftGroup = UISettings:AddLeftGroupbox("Menu Settings")
local MenuVisibility = SettingsLeftGroup:AddCheckbox("MenuVisibility", {
    Text = "Show Menu",
    Default = true,
    Disabled = false,
    Tooltip = "Toggle menu visibility",
    Callback = function(Value)
        Library:Toggle(Value)
    end
})
MenuVisibility:AddKeyPicker("MenuToggleKey", {
    Default = "End",
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "Menu Toggle",
    NoUI = false
})
SettingsLeftGroup:AddDivider()
SettingsLeftGroup:AddButton({
    Text = "Unload Menu",
    Func = function()
        task.wait(0.3)
        Library:Unload()
    end,
    DoubleClick = false,
    Tooltip = "Unload the menu"
})

local AppearanceGroup = UISettings:AddLeftGroupbox("Appearance")
AppearanceGroup:AddCheckbox("ShowKeybinds", {
    Text = "Show Keybinds Frame",
    Default = false,
    Disabled = false,
    Tooltip = "Toggle keybinds list visibility",
    Callback = function(Value)
        Library.KeybindFrame.Visible = Value
    end
})

SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetFolder("Ostium")
SaveManager:BuildConfigSection(UISettings)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("Ostium")
ThemeManager:ApplyToTab(UISettings)

local NotificationGroup = UISettings:AddRightGroupbox("Notifications")
local notifyDuration = 3
local enableNotifications = true
local notificationSoundId = 0
local soundPresets = {
    {Name = "None", Id = 0},
    {Name = "Default Notification", Id = 3023237993},
    {Name = "Android Ding", Id = 6205430632},
    {Name = "Error Buzz", Id = 5188022160},
    {Name = "Alert Alarm", Id = 1616678030}
}
NotificationGroup:AddCheckbox("EnableNotifications", {
    Text = "Enable Notifications",
    Default = true,
    Disabled = false,
    Tooltip = "Toggle whether notifications are shown for actions",
    Callback = function(Value)
        enableNotifications = Value
    end
})
NotificationGroup:AddSlider("NotifyDuration", {
    Text = "Notification Duration (s)",
    Default = 3,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Compact = true,
    Callback = function(Value)
        notifyDuration = Value
    end
})
local soundInput = NotificationGroup:AddInput("NotificationSoundId", {
    Text = "Notification Sound ID",
    Default = "0",
    Numeric = true,
    Finished = true,
    Tooltip = "Roblox sound ID for all notifications (0 for none)",
    Callback = function(Value)
        notificationSoundId = tonumber(Value) or 0
    end
})
NotificationGroup:AddDropdown("SoundPreset", {
    Text = "Sound Preset",
    Default = "None",
    Values = {"None", "Default Notification", "Android Ding", "Error Buzz", "Alert Alarm"},
    Callback = function(Value)
        for _, preset in ipairs(soundPresets) do
            if preset.Name == Value then
                notificationSoundId = preset.Id
                soundInput:SetValue(tostring(preset.Id))
                break
            end
        end
    end
})
NotificationGroup:AddButton({
    Text = "Test Notification",
    Func = function()
        Library:Notify({
            Title = "Test Notification",
            Content = "This is a test notification!",
            Duration = notifyDuration,
            SoundId = notificationSoundId > 0 and notificationSoundId or nil
        })
    end
})

Library:SetWatermarkVisibility(true)

local function updateWatermark()
    local fps = 60
    local frameTimer = tick()
    local frameCounter = 0
    local watermarkConnection
    watermarkConnection = RunService.RenderStepped:Connect(function()
        frameCounter = frameCounter + 1
        if tick() - frameTimer >= 1 then
            fps = frameCounter
            frameTimer = tick()
            frameCounter = 0
        end
        Library:SetWatermark(string.format(
            "Ostium | %d FPS | By Velocity | %d ping | v2.12",
            math.floor(fps),
            math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        ))
    end)
end
updateWatermark()

LocalPlayer.CharacterAdded:Connect(function(newChar)
    character = newChar
    rootPart = newChar:WaitForChild("HumanoidRootPart")
    humanoid = newChar:WaitForChild("Humanoid")

end)
