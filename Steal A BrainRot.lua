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
    for n in p:gmatch("[^%.]+") do
        v = v and v[n]
    end
    return v
end

loadstring(game:HttpGet("https://raw.githubusercontent.com/Saersa/Fun_Scripts/refs/heads/main/Console_Rich_Text.lua"))()

local tested = 0
local supported = 0

local function testFunction(n, failedList)
    tested += 1
    local exists = getGlobal(n) ~= nil
    local color = exists and "rgb(0,255,0)" or "rgb(255,0,0)"
    local display = "[" .. n .. "]"

    if exists then
        supported += 1
    else
        failedList[#failedList + 1] = n
    end

    print(string.format('<font color="%s">%s</font>', color, display))
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

print("\nSummary:")
print(string.format("Tested: %d  |  Supported: %d  |  Missing: %d", tested, supported, #failedFunctions))

if #failedFunctions > 0 then
    Library:Notify(
        string.format("Tested %d functions: %d supported, %d missing.", tested, supported, #failedFunctions),
        6
    )
else
    Library:Notify("All required functions supported", 3)
end

print_colored("Script Loaded", "green")

local Connections = {}
local function DisconnectAll(namePrefix)
    for name, conn in pairs(Connections) do
        if name:find(namePrefix, 1, true) then
            if conn then conn:Disconnect() end
            Connections[name] = nil
        end
    end
end





local Window = Library:CreateWindow({
    Title = "Ostium",
    Footer = "v2.11 | Steal A Brainrot | Ostium | By Velocity",
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
    Main = Window:AddTab("Main", "rocket"),
    Visuals = Window:AddTab("Visuals", "eye"),
    Server = Window:AddTab("Server", "server"),
    Misc = Window:AddTab("Misc", "box"),
    UISettings = Window:AddTab("UI Settings", "user-round-cog"),
}

local character
local rootPart
local humanoid
local player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local TextService = game:GetService("TextService")

-- ESP Library Integration
local ESP_Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bocaj111004/ESPLibrary/refs/heads/main/Library.lua"))()
_G.FadeTime = _G.FadeTime or 0.5
ESP_Library:SetFadeTime(_G.FadeTime)
ESP_Library:SetShowDistance(true)
ESP_Library:SetFillTransparency(0.75)
ESP_Library:SetOutlineTransparency(0)
ESP_Library:SetTextTransparency(0)
ESP_Library:SetTextOutlineTransparency(0)
ESP_Library:SetTextSize(17)

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
    local char = player.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
end

local function distanceBetweenRootAndPart(part)
    local root = playerRoot()
    if not root or not part or not part:IsA("BasePart") then return math.huge end
    return (root.Position - part.Position).Magnitude
end

-- Home Tab
local HomeGroup = Tabs.Home:AddLeftGroupbox("Welcome")
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

Tabs.Home:UpdateWarningBox({
    Title = "Changelogs",
    Text = [[
<font color="rgb(76, 0, 255)">Release v1.0</font>
<font color="rgb(255, 255, 255)">-- Steal A Brainrot Edition --</font>
- <font color="rgb(0, 255, 0)">Advanced ESP Library Integration</font>
- <font color="rgb(0, 255, 0)">Player, Rarity, Lock, Pet ESP</font>
- <font color="rgb(0, 255, 0)">Optimized Movement & Steal</font>
- <font color="rgb(0, 255, 0)">Pet Finder, Server Tools</font>
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
StatusGroup:AddLabel('<font color="rgb(0,255,255)">🟢 Optimized ESP</font>')
StatusGroup:AddLabel('<font color="rgb(0,255,255)">🟢 Full Features</font>')

-- Main Tab
local MainGroup = Tabs.Main:AddLeftGroupbox("Movement & Steal")
local noclipActive = false
local noclipConnection
MainGroup:AddCheckbox("NoClip", {
    Text = "NoClip",
    Default = false,
    Callback = function(Value)
        noclipActive = Value
        if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
        if Value then
            noclipConnection = RunService.Stepped:Connect(function()
                if player.Character then
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end)
        end
    end
})

local flyActive = false
local flyConnection
local flySpeed = 50
MainGroup:AddCheckbox("Fly", {
    Text = "Fly (WASD + Space/Shift)",
    Default = false,
    Callback = function(Value)
        flyActive = Value
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not (hrp and hum) then return end
        if Value then
            hum.PlatformStand = true
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
            bodyVelocity.Velocity = Vector3.new(0, 0.1, 0)
            bodyVelocity.Parent = hrp
            local bodyGyro = Instance.new("BodyGyro")
            bodyGyro.MaxTorque = Vector3.new(4000, 4000, 4000)
            bodyGyro.P = 2000
            bodyGyro.CFrame = hrp.CFrame
            bodyGyro.Parent = hrp
            flyConnection = RunService.Heartbeat:Connect(function()
                if not flyActive or not hrp.Parent then return end
                local cam = Workspace.CurrentCamera
                local move = Vector3.new(0,0,0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0,1,0) end
                bodyVelocity.Velocity = move.Unit * flySpeed
                bodyGyro.CFrame = cam.CFrame
            end)
        else
            hum.PlatformStand = false
            if hrp:FindFirstChild("BodyVelocity") then hrp.BodyVelocity:Destroy() end
            if hrp:FindFirstChild("BodyGyro") then hrp.BodyGyro:Destroy() end
            if flyConnection then flyConnection:Disconnect() flyConnection = nil end
        end
    end
}):AddKeyPicker("FlyKey", {Default = "Q", SyncToggleState = true, Mode = "Toggle"})

MainGroup:AddSlider("FlySpeed", {
    Text = "Fly Speed",
    Default = 50,
    Min = 1,
    Max = 200,
    Rounding = 0,
    Callback = function(Value)
        flySpeed = Value
    end
})

local savedBasePosition = nil
MainGroup:AddButton({
    Text = "Set Base Position",
    Func = function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            savedBasePosition = char.HumanoidRootPart.Position + Vector3.new(0, 2, 0)
            Library:Notify("Base position saved!", 2)
        end
    end
})

local floatActive = false
local floatConnection
MainGroup:AddButton({
    Text = "Float to Base",
    Func = function()
        if not savedBasePosition then Library:Notify("Set base first!", 3) return end
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not (hrp and hum) then return end
        hum:ChangeState(Enum.HumanoidStateType.Freefall)
        floatActive = true
        floatConnection = RunService.Heartbeat:Connect(function()
            if not floatActive or not hrp.Parent then floatActive = false if floatConnection then floatConnection:Disconnect() end return end
            local direction = (savedBasePosition - hrp.Position).Unit
            hrp.Velocity = direction * 40
            if (savedBasePosition - hrp.Position).Magnitude < 3 then
                floatActive = false
                hrp.Velocity = Vector3.new(0,0,0)
                if floatConnection then floatConnection:Disconnect() end
            end
        end)
    end
})

local autoStealActive = false
local autoStealCooldown = false
MainGroup:AddCheckbox("AutoSteal", {
    Text = "Auto Steal (15s CD)",
    Default = false,
    Callback = function(Value)
        if not savedBasePosition then Library:Notify("Set base first!", 3) return end
        if autoStealCooldown then return end
        autoStealActive = Value
        if Value then
            autoStealCooldown = true
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                local skyPos = hrp.Position + Vector3.new(0, 200, 0)
                hrp.CFrame = CFrame.new(skyPos)
                task.wait(1)
                local originalBase = savedBasePosition
                savedBasePosition = Vector3.new(savedBasePosition.X, skyPos.Y, savedBasePosition.Z)
                -- Float to base
                floatActive = true
                while floatActive do task.wait() end
                hrp.CFrame = CFrame.new(hrp.Position.X, originalBase.Y, hrp.Position.Z)
                savedBasePosition = originalBase
            end
            task.wait(15)
            autoStealCooldown = false
            autoStealActive = false
        end
    end
})

local boostSpeedActive = false
local currentSpeedBoost = 0
MainGroup:AddSlider("SpeedBoost", {
    Text = "Speed Boost",
    Default = 0,
    Min = 0,
    Max = 6,
    Rounding = 1,
    Callback = function(Value)
        currentSpeedBoost = Value
        if humanoid and boostSpeedActive then humanoid.WalkSpeed = 16 + Value * 10 end
    end
})

MainGroup:AddCheckbox("BoostSpeed", {
    Text = "Boost Speed Toggle",
    Default = false,
    Callback = function(Value)
        boostSpeedActive = Value
        if humanoid then humanoid.WalkSpeed = Value and (16 + currentSpeedBoost * 10) or 16 end
    end
})

MainGroup:AddButton({
    Text = "Steal (Middle Teleport)",
    Func = function()
        local pos = CFrame.new(0, -500, 0)
        local startT = os.clock()
        while os.clock() - startT < 1 do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = pos
            end
            task.wait()
        end
    end
})

local shop = player.PlayerGui:FindFirstChild("Main") and player.PlayerGui.Main:FindFirstChild("CoinsShop")
if shop then
    MainGroup:AddButton({
        Text = "Toggle Invisible (Cloak)",
        Func = function()
            local char = player.Character
            if char then
                local cloak = char:FindFirstChild("Invisibility Cloak")
                if cloak and cloak:GetAttribute("SpeedModifier") == 2 then
                    cloak.Parent = Workspace
                    Library:Notify("Invisible toggled!", 2)
                else
                    Library:Notify("Use Cloak First", 2)
                end
            end
        end
    })
end

-- Visuals Tab
local ESPSettings = Tabs.Visuals:AddLeftGroupbox("ESP Settings")
ESPSettings:AddCheckbox("ESPRainbow", {
    Text = "Rainbow Mode",
    Default = false,
    Tooltip = "Cycle colors for all ESP",
    Callback = function(Value)
        ESP_Library:SetRainbow(Value)
        _G.ESPRainbowEnabled = Value
    end
})
ESPSettings:AddCheckbox("EnableTracers", {
    Text = "Tracers",
    Default = false,
    Tooltip = "Enable tracers",
    Callback = function(Value)
        ESP_Library:SetTracers(Value)
        _G.EnableTracers = Value
    end
})
ESPSettings:AddCheckbox("EnableArrows", {
    Text = "Arrows",
    Default = false,
    Tooltip = "Enable arrows",
    Callback = function(Value)
        ESP_Library:SetArrows(Value)
        _G.EnableArrows = Value
    end
})
ESPSettings:AddDropdown("TracerOrigin", {
    Text = "Tracer Origin",
    Default = "Bottom",
    Values = {"Bottom", "Center", "Top", "Mouse"},
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
    Callback = function(Value)
        _G.ESPDistance = Value
    end
})

local VisualsGroup = Tabs.Visuals:AddRightGroupbox("ESP Toggles")
local playerEspActive = false
local playerEspElements = {}
VisualsGroup:AddCheckbox("PlayerESP", {
    Text = "Player ESP",
    Default = false,
    Callback = function(Value)
        playerEspActive = Value
        if Value then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
                    local root = p.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        addESPWithDynamicColor(p.Character, p.DisplayName or p.Name, root, Color3.fromRGB(0, 255, 0))
                        playerEspElements[p] = {object = p.Character, root = root, added = true}
                    end
                end
                p.CharacterAdded:Connect(function(char)
                    task.wait(0.5)
                    local newRoot = char:FindFirstChild("HumanoidRootPart")
                    if newRoot and playerEspActive then
                        addESPWithDynamicColor(char, p.DisplayName or p.Name, newRoot, Color3.fromRGB(0, 255, 0))
                        playerEspElements[p] = {object = char, root = newRoot, added = true}
                    end
                end)
            end
            Players.PlayerAdded:Connect(function(p)
                p.CharacterAdded:Connect(function(char)
                    task.wait(0.5)
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if root and playerEspActive then
                        addESPWithDynamicColor(char, p.DisplayName or p.Name, root, Color3.fromRGB(0, 255, 0))
                        playerEspElements[p] = {object = char, root = root, added = true}
                    end
                end)
            end)
            local updateConn = RunService.Heartbeat:Connect(function()
                if not playerEspActive then return end
                local lpRoot = playerRoot()
                if not lpRoot then return end
                for p, rec in pairs(playerEspElements) do
                    if p and p.Character and rec.object == p.Character then
                        local dist = distanceBetweenRootAndPart(rec.root)
                        if dist <= _G.ESPDistance then
                            if not rec.added then
                                addESPWithDynamicColor(rec.object, p.DisplayName or p.Name, rec.root, Color3.fromRGB(0, 255, 0))
                                rec.added = true
                            end
                        else
                            if rec.added then
                                ESP_Library:RemoveESP(rec.object)
                                rec.added = false
                            end
                        end
                    end
                end
            end)
        else
            for p, rec in pairs(playerEspElements) do
                if rec.added then ESP_Library:RemoveESP(rec.object) end
            end
            playerEspElements = {}
        end
    end
}):AddColorPicker("PlayerColor", {
    Default = Color3.fromRGB(0, 255, 0),
    Title = "Player Color",
    Callback = function(Value)
        for _, rec in pairs(playerEspElements) do
            if rec.added then ESP_Library:UpdateObjectColor(rec.object, Value) end
        end
    end
})

-- Rarity & Lock ESP (Optimized)
local activeRarityEsp = {Legendary = false, Mythic = false, ["Brainrot God"] = false, Secret = false}
local activeLockEsp = false
local lteInstances = {}
local rarityInstances = {}
local RaritySettings = {
    ["Legendary"] = {Color = Color3.new(1, 1, 0), Size = UDim2.new(0, 150, 0, 50)},
    ["Mythic"] = {Color = Color3.new(1, 0, 0), Size = UDim2.new(0, 150, 0, 50)},
    ["Brainrot God"] = {Color = Color3.new(0.5, 0, 0.5), Size = UDim2.new(0, 180, 0, 60)},
    ["Secret"] = {Color = Color3.new(0, 0, 0), Size = UDim2.new(0, 200, 0, 70)}
}
local MutationSettings = {
    ["Gold"] = {Color = Color3.fromRGB(255, 215, 0), Size = UDim2.new(0, 120, 0, 30)},
    ["Diamond"] = {Color = Color3.fromRGB(0, 191, 255), Size = UDim2.new(0, 120, 0, 30)},
    ["Rainbow"] = {Color = Color3.fromRGB(255, 192, 203), Size = UDim2.new(0, 120, 0, 30)},
    ["Bloodrot"] = {Color = Color3.fromRGB(139, 0, 0), Size = UDim2.new(0, 120, 0, 30)}
}

local function updateLockEsp()
    if not activeLockEsp then
        for _, inst in pairs(lteInstances) do if inst then inst:Destroy() end end
        lteInstances = {}
        return
    end
    local myPlot
    for _, plot in ipairs(Workspace.Plots:GetChildren()) do
        if plot:FindFirstChild("YourBase", true) and plot.YourBase.Enabled then myPlot = plot.Name break end
    end
    for _, plot in pairs(Workspace.Plots:GetChildren()) do
        local timeLabel = plot.Purchases and plot.Purchases.PlotBlock and plot.Purchases.PlotBlock.Main and plot.Purchases.PlotBlock.Main.BillboardGui and plot.Purchases.PlotBlock.Main.BillboardGui.RemainingTime
        if timeLabel and timeLabel:IsA("TextLabel") then
            local espName = "LockESP_" .. plot.Name
            local existing = plot:FindFirstChild(espName)
            local unlocked = timeLabel.Text == "0s"
            local text = unlocked and "Unlocked" or "Lock: " .. timeLabel.Text
            local color = (plot.Name == myPlot and (unlocked and Color3.fromRGB(0,255,0) or Color3.fromRGB(0,255,0))) or (unlocked and Color3.fromRGB(220,20,60) or Color3.fromRGB(255,255,0))
            if not existing then
                local bb = Instance.new("BillboardGui")
                bb.Name = espName
                bb.Size = UDim2.new(0,200,0,30)
                bb.StudsOffset = Vector3.new(0,5,0)
                bb.AlwaysOnTop = true
                bb.Adornee = plot.Purchases.PlotBlock.Main
                local label = Instance.new("TextLabel")
                label.Text = text
                label.Size = UDim2.new(1,0,1,0)
                label.BackgroundTransparency = 1
                label.TextScaled = true
                label.TextColor3 = color
                label.TextStrokeColor3 = Color3.new(0,0,0)
                label.TextStrokeTransparency = 0
                label.Font = Enum.Font.SourceSansBold
                label.Parent = bb
                bb.Parent = plot
                lteInstances[plot.Name] = bb
            else
                existing.TextLabel.Text = text
                existing.TextLabel.TextColor3 = color
            end
        end
    end
end

local function updateRarityEsp()
    local myPlot
    for _, plot in ipairs(Workspace.Plots:GetChildren()) do
        if plot:FindFirstChild("YourBase", true) and plot.YourBase.Enabled then myPlot = plot.Name break end
    end
    for _, plot in pairs(Workspace.Plots:GetChildren()) do
        if plot.Name == myPlot then continue end
        for _, child in pairs(plot:GetDescendants()) do
            if child.Name == "Rarity" and child:IsA("TextLabel") and activeRarityEsp[child.Text] then
                local parentModel = child.Parent.Parent
                local espName = child.Text .. "_ESP"
                local mutEspName = "Mutation_ESP"
                local existingBb = parentModel:FindFirstChild(espName)
                local existingMut = parentModel:FindFirstChild(mutEspName)
                local settings = RaritySettings[child.Text]
                if not existingBb then
                    local bb = Instance.new("BillboardGui")
                    bb.Name = espName
                    bb.Size = settings.Size
                    bb.StudsOffset = Vector3.new(0,3,0)
                    bb.AlwaysOnTop = true
                    local label = Instance.new("TextLabel")
                    label.Text = child.Parent.DisplayName.Text
                    label.Size = UDim2.new(1,0,1,0)
                    label.BackgroundTransparency = 1
                    label.TextScaled = true
                    label.TextColor3 = settings.Color
                    label.TextStrokeColor3 = Color3.new(0,0,0)
                    label.TextStrokeTransparency = 0
                    label.Font = Enum.Font.SourceSansBold
                    label.Parent = bb
                    bb.Parent = parentModel
                    rarityInstances[parentModel] = bb
                end
                local mutation = child.Parent:FindFirstChild("Mutation")
                if mutation and mutation:IsA("TextLabel") and MutationSettings[mutation.Text] then
                    local mutSettings = MutationSettings[mutation.Text]
                    if not existingMut then
                        local mutBb = Instance.new("BillboardGui")
                        mutBb.Name = mutEspName
                        mutBb.Size = mutSettings.Size
                        mutBb.StudsOffset = Vector3.new(0,6,0)
                        mutBb.AlwaysOnTop = true
                        local mutLabel = Instance.new("TextLabel")
                        mutLabel.Text = mutation.Text
                        mutLabel.Size = UDim2.new(1,0,1,0)
                        mutLabel.BackgroundTransparency = 1
                        mutLabel.TextScaled = true
                        mutLabel.TextColor3 = mutSettings.Color
                        mutLabel.TextStrokeColor3 = Color3.new(0,0,0)
                        mutLabel.TextStrokeTransparency = 0
                        mutLabel.Font = Enum.Font.SourceSansBold
                        mutLabel.Parent = mutBb
                        mutBb.Parent = parentModel
                    else
                        existingMut.TextLabel.Text = mutation.Text
                        existingMut.TextLabel.TextColor3 = mutSettings.Color
                    end
                elseif existingMut then
                    existingMut:Destroy()
                end
            end
        end
    end
end

local espMulti = VisualsGroup:AddDropdown("EspMulti", {
    Text = "ESP Types",
    Values = {"Lock", "Legendary", "Mythic", "Brainrot God", "Secret"},
    Multi = true,
    Default = {},
    Callback = function(Value)
        activeLockEsp = Value["Lock"] or false
        activeRarityEsp["Legendary"] = Value["Legendary"] or false
        activeRarityEsp["Mythic"] = Value["Mythic"] or false
        activeRarityEsp["Brainrot God"] = Value["Brainrot God"] or false
        activeRarityEsp["Secret"] = Value["Secret"] or false
        updateLockEsp()
        updateRarityEsp()
    end
})

task.spawn(function()
    while true do
        task.wait(0.25)
        if activeLockEsp then updateLockEsp() end
        local hasActiveRarity = false
        for _ in pairs(activeRarityEsp) do hasActiveRarity = true break end
        if hasActiveRarity then updateRarityEsp() end
    end
end)

-- Pet ESP (Adapted)
local petEspActive = false
local petEspElements = {}
local petAllowed = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic"} -- Adapt to game pets
VisualsGroup:AddCheckbox("PetESP", {
    Text = "Pet ESP",
    Default = false,
    Callback = function(Value)
        petEspActive = Value
        if Value then
            for _, plot in pairs(Workspace.Plots:GetChildren()) do
                for _, pet in pairs(plot:GetDescendants()) do
                    if pet.Name:find("Pet") and pet:FindFirstChild("DisplayName") then
                        local root = pet:FindFirstChild("HumanoidRootPart") or pet.PrimaryPart
                        if root then
                            addESPWithDynamicColor(pet, pet.DisplayName.Text, root, Color3.fromRGB(255, 165, 0))
                            petEspElements[pet] = {object = pet, root = root, added = true}
                        end
                    end
                end
            end
            local updateConn = RunService.Heartbeat:Connect(function()
                if not petEspActive then return end
                local lpRoot = playerRoot()
                if not lpRoot then return end
                for pet, rec in pairs(petEspElements) do
                    if pet and pet.Parent then
                        local dist = distanceBetweenRootAndPart(rec.root)
                        if dist <= _G.ESPDistance then
                            if not rec.added then
                                addESPWithDynamicColor(rec.object, pet.DisplayName.Text, rec.root, Color3.fromRGB(255, 165, 0))
                                rec.added = true
                            end
                        else
                            if rec.added then
                                ESP_Library:RemoveESP(rec.object)
                                rec.added = false
                            end
                        end
                    end
                end
            end)
        else
            for pet, rec in pairs(petEspElements) do
                if rec.added then ESP_Library:RemoveESP(rec.object) end
            end
            petEspElements = {}
        end
    end
}):AddColorPicker("PetColor", {
    Default = Color3.fromRGB(255, 165, 0),
    Title = "Pet Color",
    Callback = function(Value)
        for _, rec in pairs(petEspElements) do
            if rec.added then ESP_Library:UpdateObjectColor(rec.object, Value) end
        end
    end
})

local fullbrightEnabled = false
local noFogEnabled = false
local antiLagEnabled = false
local LightingGroup = Tabs.Visuals:AddLeftGroupbox("Lighting")
LightingGroup:AddCheckbox("Fullbright", {
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
LightingGroup:AddCheckbox("NoFog", {
    Text = "No Fog",
    Default = false,
    Callback = function(Value)
        noFogEnabled = Value
        Lighting.FogEnd = Value and 100000 or 100000
        Lighting.FogStart = Value and 0 or 0
    end
})
LightingGroup:AddCheckbox("AntiLag", {
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

-- Server Tab
local plotName
for _, plot in ipairs(Workspace.Plots:GetChildren()) do
    if plot:FindFirstChild("YourBase", true) and plot.YourBase.Enabled then
        plotName = plot.Name
        break
    end
end
local ServerGroup = Tabs.Server:AddLeftGroupbox("Server Tools")
if plotName then
    local remainingTime = Workspace.Plots[plotName].Purchases.PlotBlock.Main.BillboardGui.RemainingTime
    local rtp = ServerGroup:AddParagraph({ Title = "Lock Time: " .. remainingTime.Text })
    task.spawn(function()
        while true do
            rtp:SetTitle("Lock Time: " .. remainingTime.Text)
            task.wait(0.25)
        end
    end)
end

local petModels = ReplicatedStorage.Models.Animals:GetChildren()
local petNames = {}
for _, pet in ipairs(petModels) do
    table.insert(petNames, pet.Name)
end
local PetDropdown = ServerGroup:AddDropdown("PetFinder", {
    Text = "Pet Finder",
    Values = petNames,
    Multi = true,
    Default = {},
})
local SelectedPets = {}
local isRunning = false
local Rparagraph = ServerGroup:AddParagraph({ Title = "No pets selected" })
local lnt = 0
local nc = 5
PetDropdown:OnChanged(function(SelectedPetss)
    SelectedPets = {}
    for petName, isSelected in pairs(SelectedPetss) do
        if isSelected then table.insert(SelectedPets, petName) end
    end
    if not isRunning and #SelectedPets > 0 then
        isRunning = true
        task.spawn(function()
            local lastResults = {}
            while #SelectedPets > 0 do
                local counts = {}
                local found = false
                local newPetsFound = false
                for _, plot in pairs(Workspace.Plots:GetChildren()) do
                    if plot.Name ~= plotName then
                        local owner = (plot:FindFirstChild("PlotSign") and plot.PlotSign:FindFirstChild("SurfaceGui") and plot.PlotSign.SurfaceGui.Frame.TextLabel.Text:match("^(.-)'s Base")) or "Unknown"
                        for _, v in pairs(plot:GetDescendants()) do
                            if v.Name == "DisplayName" and table.find(SelectedPets, v.Text) then
                                counts[owner] = counts[owner] or {}
                                counts[owner][v.Text] = (counts[owner][v.Text] or 0) + 1
                                found = true
                                if not lastResults[owner] or not lastResults[owner][v.Text] then newPetsFound = true end
                            end
                        end
                    end
                end
                if found then
                    local resultText = ""
                    for owner, pets in pairs(counts) do
                        for name, count in pairs(pets) do
                            resultText = resultText .. name.." x"..count.." | Owner: "..owner.."\n"
                            if newPetsFound and (os.time() - lnt) > nc then
                                Library:Notify({ Title = "Pet Finder", Content = "Found "..name.." x"..count.." Owner: "..owner, Duration = 2 })
                                lnt = os.time()
                            end
                        end
                    end
                    Rparagraph:SetTitle(resultText)
                else
                    Rparagraph:SetTitle("No selected pets found")
                end
                lastResults = counts
                task.wait(0.5)
            end
            isRunning = false
            Rparagraph:SetTitle("No pets selected")
        end)
    elseif #SelectedPets == 0 then
        Rparagraph:SetTitle("No pets selected")
    end
end)

ServerGroup:AddButton({
    Text = "Server Hop",
    Func = function()
        -- Server Hop code (optimized, same as before)
        local PlaceID = game.PlaceId
        local AllIDs = {}
        local foundAnything = ""
        local actualHour = os.date("!*t").hour
        local File = pcall(function()
            AllIDs = game:GetService('HttpService'):JSONDecode(readfile("NotSameServers.json"))
        end)
        if not File then
            table.insert(AllIDs, actualHour)
            writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
        end
        local function TPReturner()
            local Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100' .. (foundAnything ~= "" and '&cursor=' .. foundAnything or '')))
            if Site.nextPageCursor and Site.nextPageCursor ~= "null" then foundAnything = Site.nextPageCursor end
            local num = 0
            for _, v in pairs(Site.data) do
                local Possible = true
                local ID = tostring(v.id)
                if tonumber(v.maxPlayers) > tonumber(v.playing) then
                    for _, Existing in pairs(AllIDs) do
                        if num ~= 0 then
                            if ID == tostring(Existing) then Possible = false end
                        else
                            if tonumber(actualHour) ~= tonumber(Existing) then
                                pcall(function() delfile("NotSameServers.json") AllIDs = {} table.insert(AllIDs, actualHour) end)
                            end
                        end
                        num = num + 1
                    end
                    if Possible then
                        table.insert(AllIDs, ID)
                        task.wait()
                        pcall(function()
                            writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
                            game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, player)
                        end)
                        task.wait(4)
                    end
                end
            end
        end
        task.spawn(function()
            while task.wait() do
                pcall(TPReturner)
                if foundAnything ~= "" then TPReturner() end
            end
        end)
    end
})

ServerGroup:AddButton({
    Text = "Rejoin",
    Func = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
    end
})

if shop then
    ServerGroup:AddKeybind("ShopToggle", {
        Title = "Shop Toggle",
        Mode = "Toggle",
        Default = "F",
        Callback = function(Value)
            shop.Visible = Value
            shop.Position = Value and UDim2.new(0.5, 0, 0.5, 0) or UDim2.new(0.5, 0, 1.5, 0)
        end
    })
end

-- Misc Tab
local MiscGroup = Tabs.Misc:AddLeftGroupbox("Extras")
MiscGroup:AddButton({
    Text = "Infinite Yield",
    Func = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    end
})

MiscGroup:AddKeybind("StealBind", {
    Title = "Steal Keybind",
    Mode = "Toggle",
    Default = "G",
    Callback = function()
        local pos = CFrame.new(0, -500, 0)
        local startT = os.clock()
        while os.clock() - startT < 1 do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = pos
            end
            task.wait()
        end
    end
})

local TimerPara = MiscGroup:AddParagraph({ Title = "Time: 00:00:00" })
local startTime = os.time()
task.spawn(function()
    while true do
        local elapsed = os.difftime(os.time(), startTime)
        TimerPara:SetTitle(string.format("Time: %02d:%02d:%02d", math.floor(elapsed / 3600), math.floor((elapsed % 3600) / 60), elapsed % 60))
        task.wait(1)
    end
end)

MiscGroup:AddButton({
    Text = "Discord Invite",
    Func = function()
        setclipboard("https://discord.gg/FmMuvkaWvG")
        Library:Notify("Copied Successfully", 2)
    end
})

-- UI Settings Tab
local SettingsLeftGroup = Tabs.UISettings:AddLeftGroupbox("Menu Settings")
local MenuVisibility = SettingsLeftGroup:AddCheckbox("MenuVisibility", {
    Text = "Show Menu",
    Default = true,
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
    end
})

local AppearanceGroup = Tabs.UISettings:AddLeftGroupbox("Appearance")
AppearanceGroup:AddCheckbox("ShowKeybinds", {
    Text = "Show Keybinds Frame",
    Default = false,
    Callback = function(Value)
        Library.KeybindFrame.Visible = Value
    end
})

SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetFolder("Ostium")
SaveManager:BuildConfigSection(Tabs.UISettings)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("Ostium")
ThemeManager:ApplyToTab(Tabs.UISettings)

local NotificationGroup = Tabs.UISettings:AddRightGroupbox("Notifications")
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
    Callback = function(Value)
        enableNotifications = Value
    end
})
NotificationGroup:AddSlider("NotifyDuration", {
    Text = "Duration (s)",
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
    Text = "Sound ID",
    Default = "0",
    Numeric = true,
    Finished = true,
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
            Title = "Test",
            Content = "Test notification!",
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
    local conn = RunService.RenderStepped:Connect(function()
        frameCounter = frameCounter + 1
        if tick() - frameTimer >= 1 then
            fps = frameCounter
            frameTimer = tick()
            frameCounter = 0
        end
        Library:SetWatermark(string.format("Ostium | %d FPS | %d ping | v1.0", math.floor(fps), math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())))
    end)
end
updateWatermark()

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    rootPart = newChar:WaitForChild("HumanoidRootPart")
    humanoid = newChar:WaitForChild("Humanoid")
    if boostSpeedActive then humanoid.WalkSpeed = 16 + currentSpeedBoost * 10 end
    noclipActive = false
    flyActive = false
    autoStealActive = false
    floatActive = false
end)

if player.Character then
    character = player.Character
    rootPart = character:FindFirstChild("HumanoidRootPart")
    humanoid = character:FindFirstChild("Humanoid")
end

game:GetService('Players').LocalPlayer.Idled:Connect(function()
    game:GetService('VirtualUser'):CaptureController()
    game:GetService('VirtualUser'):ClickButton2(Vector2.new())
end)