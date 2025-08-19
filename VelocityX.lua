local repo = "https://raw.githubusercontent.com/DasVelocity/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "VelocityLib.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local Options = Library.Options
local Toggles = Library.Toggles
Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameData = ReplicatedStorage:WaitForChild("GameData")
local currentFloor = GameData:WaitForChild("Floor").Value
local Window = Library:CreateWindow({
Title = "Velocity X",
Footer = "v1.O | Velocity X | Floor: " .. currentFloor,
Icon = 136131547315751,
NotifySide = "Right",
ShowCustomCursor = true,
})
local Tabs = {
Home = Window:AddTab("Home", "house"),
Player = Window:AddTab("Player", "user"),
Visuals = Window:AddTab("Visuals", "eye"),
Entities = Window:AddTab("Entities", "shield"),
Misc = Window:AddTab("Misc", "box"),
UISettings = Window:AddTab("UI Settings", "user-round-cog"),
}
local HomeGroup = Tabs.Home:AddLeftGroupbox("Welcome")

-- Create a basic ImageLabel using Instance.new
local avatarImage = Instance.new("ImageLabel")
avatarImage.Name = "AvatarThumbnail"
avatarImage.Size = UDim2.new(0, 220, 0, 220)
avatarImage.Position = UDim2.new(0.5, -90, 0, 10)
avatarImage.Image = "rbxassetid://0" -- Default placeholder
avatarImage.BackgroundTransparency = 1
avatarImage.BorderSizePixel = 0
avatarImage.ScaleType = Enum.ScaleType.Fit

-- Parent it to the HomeGroup (you might need to adjust this depending on your library structure)
-- If HomeGroup has a specific container, parent to that instead
if HomeGroup.Container then
    avatarImage.Parent = HomeGroup.Container
elseif HomeGroup.Frame then
    avatarImage.Parent = HomeGroup.Frame
else
    avatarImage.Parent = HomeGroup -- Try direct parenting
end

-- Load the player's avatar
spawn(function()
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    
    -- Wait for player to be available
    if not player then
        repeat 
            task.wait(0.1) 
            player = Players.LocalPlayer
        until player
    end
    
    task.wait(1)
    
    local success, thumbnail = pcall(function()
        return Players:GetUserThumbnailAsync(
            player.UserId, 
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size180x180
        )
    end)
    
    if success and thumbnail then
        print("Successfully loaded avatar thumbnail")
        avatarImage.Image = thumbnail
    else
        warn("Failed to load avatar thumbnail: " .. tostring(thumbnail))
        
        local alternatives = {
            Enum.ThumbnailType.AvatarThumbnail,
            Enum.ThumbnailType.AvatarBust,
            Enum.ThumbnailType.Avatar
        }
        
        for i, thumbnailType in ipairs(alternatives) do
            local altSuccess, altThumbnail = pcall(function()
                return Players:GetUserThumbnailAsync(
                    player.UserId, 
                    thumbnailType,
                    Enum.ThumbnailSize.Size180x180
                )
            end)
            
            if altSuccess and altThumbnail then
                print("Loaded alternative thumbnail type: " .. tostring(thumbnailType))
                avatarImage.Image = altThumbnail
                break
            else
                warn("Alternative " .. i .. " failed: " .. tostring(altThumbnail))
            end
        end
    end
end)
HomeGroup:AddButton("Join Discord", function()
    setclipboard("https://discord.gg/doorsmodmenu")
    Library:Notify("Discord link copied to clipboard!")
end)

local IntroductionGroup = Tabs.Home:AddRightGroupbox("Introduction")
IntroductionGroup:AddLabel('Welcome, thanks for')
IntroductionGroup:AddLabel('choosing velocity x!')


local ChangelogsGroup = Tabs.Home:AddRightGroupbox("Changelogs")
ChangelogsGroup:AddLabel('<font color="rgb(0,255,0)">Added: Added Entity Tab with Anti features</font>')
ChangelogsGroup:AddLabel('<font color="rgb(0,255,0)">Added: Great Outdoors ESP</font>')
ChangelogsGroup:AddLabel('<font color="rgb(255,0,0)">Added: Old deprecated hacks</font>')
ChangelogsGroup:AddLabel('<font color="rgb(0,255,0)">Added: Floor detection in footer</font>')
-- Global Variables
local LocalPlayer = game.Players.LocalPlayer
local Rooms = workspace.CurrentRooms
local Unloaded = false
local ClonedCollision
local OldAccel = LocalPlayer.Character.HumanoidRootPart.CustomPhysicalProperties
local EspTable = {
    Interactables = {
        GoldPiles = {},
        Doors = {},
        DoorKeys = {},
        GeneratorFuses = {},
        Generators = {},
        GateLevers = {},
        BackroomsLevers = {},
        LibraryBooks = {},
        BreakerPoles = {},
        Anchors = {},
        MiscPickups = {},
        Closets = {}
    },
    Entities = {},
    Players = {}
}
local MiscPickups = {
    ["Glowsticks"] = "Glowstick",
    ["StarJug"] = "Barrel of Starlight",
    ["Lockpick"] = "Lock-Pick",
    ["Bandage"] = "Bandage",
    ["StarVial"] = "Vial of Starlight",
    ["SkeletonKey"] = "Skeleton Key",
    ["Crucifix"] = "Crucifix",
    ["CrucifixWall"] = "Crucifix",
    ["Flashlight"] = "Flashlight",
    ["Candle"] = "Candle",
    ["Straplight"] = "Straplight",
    ["Vitamins"] = "Vitamins",
    ["Lighter"] = "Lighter",
    ["Shears"] = "Shears",
    ["BatteryPack"] = "Battery Pack",
    ["BandagePack"] = "Bandage Pack",
    ["LaserPointer"] = "Laser Pointer",
    ["Bulklight"] = "Bulk Light",
    ["Battery"] = "Battery",
    ["Candy"] = "Candy",
    ["OutdoorsKey"] = "Outdoors Key" -- New from Outdoors
}
local EntityDistances = {
    ["RushMoving"] = 50,
    ["BackdoorRush"] = 50,
    ["AmbushMoving"] = 100,
    ["A60"] = 100,
    ["A120"] = 35
}
-- Anti Connections table to manage disconnects
local AntiConnections = {}
-- Lighting originals for fullbright
local oldBrightness = game.Lighting.Brightness
local oldClockTime = game.Lighting.ClockTime
local oldFogEnd = game.Lighting.FogEnd
local oldGlobalShadows = game.Lighting.GlobalShadows
local oldAmbient = game.Lighting.Ambient
-- ESP Functions (Adapted from my.lua)
local function Esp(Parent, TextAdornee, Text, Color, OutlineColor)
    if Parent:FindFirstChild("_LOLHAXHL") then return end
    local BillboardGui = Instance.new("BillboardGui", Parent)
    local TextLabel = Instance.new("TextLabel", BillboardGui)
    local Highlight = Instance.new("Highlight", Parent)
    BillboardGui.Adornee = TextAdornee
    BillboardGui.AlwaysOnTop = true
    BillboardGui.Name = "_LOLHAXBG"
    BillboardGui.Size = UDim2.fromScale(1, 1)
    BillboardGui.Enabled = true
    Highlight.Name = "_LOLHAXHL"
    TextLabel.Size = UDim2.fromScale(1, 1)
    TextLabel.TextStrokeTransparency = 0
    TextLabel.Font = Enum.Font[Options.ESPFont.Value] or Enum.Font.SourceSans
    TextLabel.TextSize = Options.ESPFontSize.Value or 20
    TextLabel.TextColor3 = Color
    TextLabel.BackgroundTransparency = 1
    Highlight.Adornee = Parent
    Highlight.FillColor = Color
    Highlight.OutlineColor = OutlineColor or Color
    TextLabel.TextTransparency = 1
    Highlight.FillTransparency = 1
    Highlight.OutlineTransparency = 1
    TextLabel:SetAttribute("Text", Text)
    task.spawn(function()
        while Parent and Parent.Parent and not Unloaded do
            local Distance = (workspace.CurrentCamera.CFrame.Position - Parent:GetPivot().Position).Magnitude
            TextLabel.Text = Text .. "\n[ " .. string.format(Distance <= 9.9 and "%.1f" or "%.0f", Distance) .. " ]"
            task.wait()
        end
    end)
    game:GetService("TweenService"):Create(Highlight, TweenInfo.new(Options.ESPFadeTime.Value or 1), {FillTransparency = Options.ESPFillTransparency.Value or 0.7, OutlineTransparency = Options.ESPOutlineTransparency.Value or 0.2}):Play()
    game:GetService("TweenService"):Create(TextLabel, TweenInfo.new(Options.ESPFadeTime.Value or 1), {TextTransparency = 0}):Play()
    -- Remove ESP when parent destroyed
    Parent.Destroying:Connect(function()
        RemoveEspSmooth(Parent)
    end)
    return Highlight, TextLabel
end
local function RemoveEspSmooth(Parent)
    if Parent:FindFirstChild("_LOLHAXHL") and Parent:FindFirstChild("_LOLHAXBG") then
        game:GetService("TweenService"):Create(Parent._LOLHAXHL, TweenInfo.new(Options.ESPFadeTime.Value or 1), {FillTransparency = 1, OutlineTransparency = 1}):Play()
        game:GetService("TweenService"):Create(Parent._LOLHAXBG.TextLabel, TweenInfo.new(Options.ESPFadeTime.Value or 1), {TextTransparency = 1}):Play()
        task.delay(Options.ESPFadeTime.Value or 1, function()
            if Parent:FindFirstChild("_LOLHAXHL") then Parent._LOLHAXHL:Destroy() end
            if Parent:FindFirstChild("_LOLHAXBG") then Parent._LOLHAXBG:Destroy() end
        end)
    end
end
-- Function to scan and add ESP to existing items
local function ScanAndAddESP(category, names, toggle, fillColor, outlineColor, adorneeFunc, removalCondition, textFunc)
    if not Toggles[toggle].Value then return end
    names = type(names) == "table" and names or {names}
    for _, room in pairs(Rooms:GetChildren()) do
        for _, v in pairs(room:GetDescendants()) do
            if v:IsA("Model") and table.find(names, v.Name) then
                local adornee = adorneeFunc(v)
                local text = textFunc and textFunc(v) or v.Name
                local Highlight, TextLabel = Esp(adornee, adornee, text, Options[fillColor].Value, Options[outlineColor].Value)
                if Highlight then
                    table.insert(EspTable[category][names[1] .. "s"] or EspTable[category], {Highlight, TextLabel})
                    removalCondition(v, adornee)
                end
            end
        end
    end
end
-- Function to scan and add entity ESP (now scans all descendants)
local function ScanAndAddEntityESP(names, toggle, colorOption, adorneeFunc, removalCondition, preAddFunc, textFunc)
    if not Toggles[toggle].Value then return end
    names = type(names) == "table" and names or {names}
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and table.find(names, v.Name) then
            if preAddFunc then preAddFunc(v) end
            local adornee = adorneeFunc(v)
            local text = textFunc and textFunc(v) or v.Name
            local Highlight, TextLabel = Esp(v, adornee, text, Options[colorOption].Value, Options[colorOption].Value)
            if Highlight then
                table.insert(EspTable.Entities, {Highlight, TextLabel})
                removalCondition(v)
            end
        end
    end
end
local function RescanAll()
    if Toggles.ESPInteractMainEnabled.Value then
        if Toggles.ESPDoors.Value then
            ScanAndAddESP("Interactables", "Door", "ESPDoors", "ESPDoorsFill", "ESPDoorsOutline",
                function(v) return v.Door end,
                function(v, adornee) v.AttributeChanged:Once(function() RemoveEspSmooth(adornee) end) end)
        end
        if Toggles.ESPDoorKeys.Value then
            ScanAndAddESP("Interactables", "KeyObtain", "ESPDoorKeys", "ESPDoorKeysFill", "ESPDoorKeysOutline",
                function(v) return v end,
                function(v, adornee) end)
        end
        if Toggles.ESPGoldPiles.Value then
            ScanAndAddESP("Interactables", "GoldPile", "ESPGoldPiles", "ESPGoldPilesFill", "ESPGoldPilesOutline",
                function(v) return v end,
                function(v, adornee) end)
        end
        if Toggles.ESPGeneratorFuses.Value then
            ScanAndAddESP("Interactables", "FuseObtain", "ESPGeneratorFuses", "ESPGeneratorFusesFill", "ESPGeneratorFusesOutline",
                function(v) return v end,
                function(v, adornee) v.Hitbox.FuseModel.Changed:Once(function() RemoveEspSmooth(adornee) end) end)
        end
        if Toggles.ESPGenerators.Value then
            ScanAndAddESP("Interactables", "MinesGenerator", "ESPGenerators", "ESPGeneratorsFill", "ESPGeneratorsOutline",
                function(v) return v end,
                function(v, adornee) v.Lever.Sound.Played:Once(function() RemoveEspSmooth(adornee) end) end)
        end
        if Toggles.ESPGateLevers.Value then
            ScanAndAddESP("Interactables", "LeverForGate", "ESPGateLevers", "ESPGateLeversFill", "ESPGateLeversOutline",
                function(v) return v.Main end,
                function(v, adornee) v.ActivateEventPrompt.AttributeChanged:Once(function() RemoveEspSmooth(adornee) end) end)
        end
        if Toggles.ESPBackroomsLevers.Value then
            ScanAndAddESP("Interactables", "TimerLever", "ESPBackroomsLevers", "ESPBackroomsLeversFill", "ESPBackroomsLeversOutline",
                function(v) return v.Hitbox end,
                function(v, adornee) v.ActivateEventPrompt.AttributeChanged:Once(function() RemoveEspSmooth(adornee) end) end)
        end
        if Toggles.ESPLibraryBooks.Value then
            ScanAndAddESP("Interactables", "LiveHintBook", "ESPLibraryBooks", "ESPLibraryBooksFill", "ESPLibraryBooksOutline",
                function(v) return v end,
                function(v, adornee) end)
        end
        if Toggles.ESPBreakerPoles.Value then
            ScanAndAddESP("Interactables", "LiveBreakerPolePickup", "ESPBreakerPoles", "ESPBreakerPolesFill", "ESPBreakerPolesOutline",
                function(v) return v end,
                function(v, adornee) end)
        end
        if Toggles.ESPAnchors.Value then
            ScanAndAddESP("Interactables", "_NestHandler", "ESPAnchors", "ESPAnchorsFill", "ESPAnchorsOutline",
                function(v) return v.AnchorBase end,
                function(v, adornee) v.AttributeChanged:Once(function() RemoveEspSmooth(adornee) end) end)
        end
        if Toggles.ESPMiscPickups.Value then
            for pickupName, display in pairs(MiscPickups) do
                ScanAndAddESP("Interactables", pickupName, "ESPMiscPickups", "ESPMiscPickupsFill", "ESPMiscPickupsOutline",
                    function(v) return v.PrimaryPart end,
                    function(v, adornee) end,
                    function(v) return display end)
            end
        end
        if Toggles.ESPClosets.Value then
            -- Scan for Wardrobe
            ScanAndAddESP("Interactables", "Wardrobe", "ESPClosets", "ESPClosetsFill", "ESPClosetsOutline",
                function(v) return v.Door or v.Main end,
                function(v, adornee) v.AttributeChanged:Once(function() RemoveEspSmooth(adornee) end) end,
                function(v) return "Closet" end)
            -- Scan for Toolshed
            ScanAndAddESP("Interactables", "Toolshed", "ESPClosets", "ESPClosetsFill", "ESPClosetsOutline",
                function(v) return v.Door or v.Main end,
                function(v, adornee) v.AttributeChanged:Once(function() RemoveEspSmooth(adornee) end) end,
                function(v) return "Toolshed" end)
        end
    end
    if Toggles.ESPEntitiesEnabled.Value then
        if Toggles.ESPGiggle.Value then
            ScanAndAddEntityESP("GiggleCeiling", "ESPGiggle", "ESPGiggleColor",
                function(v) return v.Root end,
                function(v) end,
                nil,
                function(v) return "Giggle" end)
        end
        if Toggles.ESPFigure.Value then
            ScanAndAddEntityESP("FigureRig", "ESPFigure", "ESPFigureColor",
                function(v) return v.Figure end,
                function(v) end,
                nil,
                function(v) return "Figure" end)
        end
        if Toggles.ESPGrumble.Value then
            ScanAndAddEntityESP("GrumbleRig", "ESPGrumble", "ESPGrumbleColor",
                function(v) return v.Model end,
                function(v) end,
                nil,
                function(v) return "Grumble" end)
        end
        if Toggles.ESPGloombatSwarm.Value then
            ScanAndAddEntityESP("GloombatSwarm", "ESPGloombatSwarm", "ESPGloombatSwarmColor",
                function(v) return v end,
                function(v) end,
                nil,
                function(v) return "Gloombat Swarm" end)
        end
        if Toggles.ESPDread.Value then
            ScanAndAddEntityESP("Dread", "ESPDread", "ESPDreadColor",
                function(v) return v.Main end,
                function(v) end,
                function(v)
                    v:WaitForChild("Main")
                    if not v:FindFirstChildOfClass("Humanoid") then
                        Instance.new("Humanoid", v)
                    end
                    v.Main.Transparency = 0.999
                end,
                function(v) return "Dread" end)
        end
        if Toggles.ESPRush.Value then
            ScanAndAddEntityESP("RushMoving", "ESPRush", "ESPRushColor",
                function(v) return v end,
                function(v) end,
                nil,
                function(v) return "Rush" end)
        end
        if Toggles.ESPMovingAmbush.Value then
            ScanAndAddEntityESP("AmbushMoving", "ESPMovingAmbush", "ESPMovingAmbushColor",
                function(v) return v end,
                function(v) end,
                nil,
                function(v) return "Ambush" end)
        end
        if Toggles.ESPA60.Value then
            ScanAndAddEntityESP("A60", "ESPA60", "ESPA60Color",
                function(v) return v end,
                function(v) end,
                nil,
                function(v) return "A-60" end)
        end
        if Toggles.ESPA120.Value then
            ScanAndAddEntityESP("A120", "ESPA120", "ESPA120Color",
                function(v) return v end,
                function(v) end,
                nil,
                function(v) return "A-120" end)
        end
        if Toggles.ESPBlitz.Value then
            ScanAndAddEntityESP("BackdoorRush", "ESPBlitz", "ESPBlitzColor",
                function(v) return v end,
                function(v) end,
                nil,
                function(v) return "Blitz" end)
        end
        if Toggles.ESPEyes.Value then
            ScanAndAddEntityESP("Eyes", "ESPEyes", "ESPEyesColor",
                function(v) return v end,
                function(v) end,
                nil,
                function(v) return "Eyes" end)
        end
        if Toggles.ESPLookman.Value then
            ScanAndAddEntityESP("BackdoorLookman", "ESPLookman", "ESPLookmanColor",
                function(v) return v.Eyes end,
                function(v) end,
                nil,
                function(v) return "Lookman" end)
        end
        if Toggles.ESPSnare.Value then
            ScanAndAddEntityESP("Snare", "ESPSnare", "ESPSnareColor",
                function(v) return v end,
                function(v) end,
                nil,
                function(v) return "Snare" end)
        end
        if Toggles.ESPWorldLotus.Value then
            ScanAndAddEntityESP("WorldLotus", "ESPWorldLotus", "ESPWorldLotusColor",
                function(v) return v end,
                function(v) end,
                nil,
                function(v) return "World Lotus" end)
        end
        if Toggles.ESPBramble.Value then
            ScanAndAddEntityESP("Bramble", "ESPBramble", "ESPBrambleColor",
                function(v) return v end,
                function(v) end,
                nil,
                function(v) return "Bramble" end)
        end
        if Toggles.ESPCaws.Value then
            ScanAndAddEntityESP("Caws", "ESPCaws", "ESPCawsColor",
                function(v) return v end,
                function(v) end,
                nil,
                function(v) return "Caws" end)
        end
        if Toggles.ESPEyestalk.Value then
            ScanAndAddEntityESP("Eyestalk", "ESPEyestalk", "ESPEyestalkColor",
                function(v) return v end,
                function(v) end,
                nil,
                function(v) return "Eyestalk" end)
        end
        if Toggles.ESPGrampy.Value then
            ScanAndAddEntityESP("Grampy", "ESPGrampy", "ESPGrampyColor",
                function(v) return v end,
                function(v) end,
                nil,
                function(v) return "Grampy" end)
        end
        if Toggles.ESPGroundskeeper.Value then
            ScanAndAddEntityESP("Groundskeeper", "ESPGroundskeeper", "ESPGroundskeeperColor",
                function(v) return v end,
                function(v) end,
                nil,
                function(v) return "Groundskeeper" end)
        end
        if Toggles.ESPMandrake.Value then
            ScanAndAddEntityESP("Mandrake", "ESPMandrake", "ESPMandrakeColor",
                function(v) return v end,
                function(v) end,
                nil,
                function(v) return "Mandrake" end)
        end
        if Toggles.ESPMonument.Value then
            ScanAndAddEntityESP("Monument", "ESPMonument", "ESPMonumentColor",
                function(v) return v end,
                function(v) end,
                nil,
                function(v) return "Monument" end)
        end
        if Toggles.ESPSurge.Value then
            ScanAndAddEntityESP("Surge", "ESPSurge", "ESPSurgeColor",
                function(v) return v end,
                function(v) end,
                nil,
                function(v) return "Surge" end)
        end
    end
end
local RunService = game:GetService("RunService")
local lastScan = 0
RunService.Heartbeat:Connect(function(delta)
    if Unloaded then return end
    lastScan = lastScan + delta
    if lastScan > 0.5 then
        lastScan = 0
        RescanAll()
    end
end)
-- Trigger rescan when new room added
Rooms.ChildAdded:Connect(function(newRoom)
    task.delay(0.1, RescanAll) -- Delay to allow descendants to load
end)
-- Handle floor changes to fix ESP not highlighting new objects on different floors
GameData.Floor.Changed:Connect(function(newFloor)
    -- Clear existing ESP to prevent stale highlights
    for category, subs in pairs(EspTable) do
        for sub, esps in pairs(subs) do
            for _, esp in pairs(esps) do
                RemoveEspSmooth(esp[1].Adornee)
            end
            subs[sub] = {}
        end
    end
    currentFloor = newFloor
    Window.Footer = "floor: " .. newFloor
    -- Rescan immediately after clearing
    RescanAll()
end)
-- Player Tab: Movement and Bypasses
local MovementGroup = Tabs.Player:AddRightGroupbox("Movement Settings")
MovementGroup:AddToggle("WalkspeedModifier", {
    Text = "Custom Walk Speed",
    Default = false,
    Tooltip = "Changes your walking speed to the set value.",
    Callback = function(Value)
        updatespeed()
    end
})
MovementGroup:AddToggle("NoAcceleration", {
    Text = "Instant Acceleration",
    Default = false,
    Tooltip = "Removes slow-down when changing direction.",
    Callback = function(Value)
        LocalPlayer.Character.HumanoidRootPart.CustomPhysicalProperties = (Value and PhysicalProperties.new(100, 0, 0, 0, 0) or OldAccel)
    end
})

MovementGroup:AddToggle("AlwaysJump", { Text = "Always Can Jump", Default = false, Tooltip = "Lets you jump anytime.", Callback = function(Value)
    LocalPlayer.Character:SetAttribute("CanJump", Value or CanJump)
end })


-- Default fly speed
local FlySpeed = 50

-- Fly speed slider
MovementGroup:AddSlider("Fly Speed", {
    Text = "Fly Speed",
    Default = FlySpeed,
    Min = 0,
    Max = 150,
    Rounding = 0,
    Compact = true,
    Tooltip = "Change fly speed",
    Callback = function(Value)
        FlySpeed = Value
    end
})

-- Fly toggle
local isFlying = false
local flyConnections = {}
local keys = {W = false, A = false, S = false, D = false, Space = false, Shift = false}

local function startFly()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Create BodyVelocity
    local bv = Instance.new("BodyVelocity")
    bv.Name = "FlyVelocity"
    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)  -- Increased for better force against gravity/physics
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = hrp

    -- Create BodyGyro for smooth orientation
    local bg = Instance.new("BodyGyro")
    bg.Name = "FlyGyro"
    bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    bg.P = 20000  -- Proportional gain for responsiveness
    bg.D = 1000   -- Derivative gain for damping
    bg.Parent = hrp

    -- Disable humanoid interference
    humanoid.AutoRotate = false
    humanoid.PlatformStand = true
    humanoid:ChangeState(Enum.HumanoidStateType.Physics)

    -- Input connections
    local inputBegan = game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.W then keys.W = true
        elseif input.KeyCode == Enum.KeyCode.A then keys.A = true
        elseif input.KeyCode == Enum.KeyCode.S then keys.S = true
        elseif input.KeyCode == Enum.KeyCode.D then keys.D = true
        elseif input.KeyCode == Enum.KeyCode.Space then keys.Space = true
        elseif input.KeyCode == Enum.KeyCode.LeftShift then keys.Shift = true end
    end)
    table.insert(flyConnections, inputBegan)

    local inputEnded = game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.W then keys.W = false
        elseif input.KeyCode == Enum.KeyCode.A then keys.A = false
        elseif input.KeyCode == Enum.KeyCode.S then keys.S = false
        elseif input.KeyCode == Enum.KeyCode.D then keys.D = false
        elseif input.KeyCode == Enum.KeyCode.Space then keys.Space = false
        elseif input.KeyCode == Enum.KeyCode.LeftShift then keys.Shift = false end
    end)
    table.insert(flyConnections, inputEnded)

    -- RenderStepped for smooth updates
    local renderConnection = game:GetService("RunService").RenderStepped:Connect(function()
        local cam = workspace.CurrentCamera
        if not cam or not hrp or not hrp:FindFirstChild("FlyVelocity") or not humanoid or humanoid.Health <= 0 then
            stopFly()
            return
        end

        -- Update direction every frame for camera responsiveness
        local move = Vector3.new(0, 0, 0)
        if keys.W then move = move + cam.CFrame.LookVector end
        if keys.S then move = move - cam.CFrame.LookVector end
        if keys.A then move = move - cam.CFrame.RightVector end
        if keys.D then move = move + cam.CFrame.RightVector end
        if keys.Space then move = move + Vector3.new(0, 1, 0) end
        if keys.Shift then move = move - Vector3.new(0, 1, 0) end

        local direction = (move.Magnitude > 0) and (move.Unit * FlySpeed) or Vector3.new(0, 0, 0)
        bv.Velocity = direction

        -- Update gyro to face camera
        bg.CFrame = cam.CFrame
    end)
    table.insert(flyConnections, renderConnection)
end

local function stopFly()
    local player = game.Players.LocalPlayer
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local hrp = character and character:FindFirstChild("HumanoidRootPart")

    -- Clean up instances
    if hrp then
        local flyVelocity = hrp:FindFirstChild("FlyVelocity")
        if flyVelocity then flyVelocity:Destroy() end
        local flyGyro = hrp:FindFirstChild("FlyGyro")
        if flyGyro then flyGyro:Destroy() end
    end

    -- Restore humanoid
    if humanoid then
        humanoid.AutoRotate = true
        humanoid.PlatformStand = false
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end

    -- Disconnect all connections
    for _, conn in ipairs(flyConnections) do
        conn:Disconnect()
    end
    flyConnections = {}

    -- Reset keys
    keys = {W = false, A = false, S = false, D = false, Space = false, Shift = false}
end

MovementGroup:AddToggle("Fly", {
    Text = "Fly",
    Default = false,
    Callback = function(Value)
        isFlying = Value
        if Value then
            startFly()
        else
            stopFly()
        end
    end
})

-- Noclip Toggle Implementation
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local noclipConnection = nil

MovementGroup:AddToggle("Noclip", {
    Text = "Noclip", 
    Default = false, 
    Tooltip = "you know what it does", 
    Callback = function(Value)
        if Value then
            -- Enable noclip
            noclipConnection = RunService.Stepped:Connect(function()
                if player.Character and player.Character:FindFirstChild("Humanoid") then
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            -- Disable noclip
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end
            
            -- Re-enable collision for character parts
            if player.Character then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        -- Reset collision based on part type
                        if part.Name == "Head" then
                            part.CanCollide = false
                        elseif part.Parent:IsA("Accessory") then
                            part.CanCollide = false
                        else
                            part.CanCollide = true
                        end
                    end
                end
            end
        end
    end
})

-- Handle character respawn
game.Players.LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    if isFlying then
        -- Wait for HRP and Humanoid to be added
        newCharacter:WaitForChild("HumanoidRootPart")
        newCharacter:WaitForChild("Humanoid")
        startFly()
    end
end)

-- Handle death cleanup (optional, but ensures cleanup on death)
game.Players.LocalPlayer.CharacterRemoving:Connect(function()
    if isFlying then
        stopFly()
    end
end)



MovementGroup:AddToggle("LadderSpeedBoost", {
    Text = "Faster Ladder Climb",
    Default = false,
    Callback = function(Value)
        -- Logic from ey.lua for ladder boost
        if Value then
            AntiConnections["LadderBoost"] = LocalPlayer.Character.Humanoid.StateChanged:Connect(function(_, new)
                if new == Enum.HumanoidStateType.Climbing then
                    LocalPlayer.Character.Humanoid.WalkSpeed = Options.LadderSpeedBoostAmount.Value
                else
                    LocalPlayer.Character.Humanoid.WalkSpeed = Toggles.WalkspeedModifier.Value and Options.WalkspeedAmount.Value or 16
                end
            end)
        else
            if AntiConnections["LadderBoost"] then AntiConnections["LadderBoost"]:Disconnect() end
            LocalPlayer.Character.Humanoid.WalkSpeed = Toggles.WalkspeedModifier.Value and Options.WalkspeedAmount.Value or 16
        end
    end
})

MovementGroup:AddSlider("LadderSpeedBoostAmount", {
    Text = "Ladder Climb Speed",
    Default = 0,
    Min = 0,
    Max = 50,
    Rounding = 0,
    Compact = true,
    Tooltip = "Boost for climbing ladders. Higher values might be unstable."
})
MovementGroup:AddSlider("WalkspeedAmount", {
    Text = "Walk Speed Value",
    Default = 20,
    Min = 10,
    Max = 50,
    Rounding = 0,
    Compact = true,
    Tooltip = "Sets how fast you walk.",
    Callback = function(Value)
        updatespeed()
    end
})
local VisualEffects = Tabs.Player:AddLeftGroupbox("Visual Effects")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

VisualEffects:AddToggle("NoCamShake", {
    Text = "No Camera Shake",
    Default = false,
    Tooltip = "Removes camera shaking from entities.",
    Callback = function(Value)
        require(LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game).csgo = Value and CFrame.new(0, 0, 0) or nil
    end
})
VisualEffects:AddToggle("NoLookBob", {
    Text = "No Head Bobbing",
    Default = false,
    Tooltip = "Removes head bobbing when walking.",
    Callback = function(Value)
        require(LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game).spring.Speed = Value and 9e9 or 8
    end
})
VisualEffects:AddToggle("Ambience", {
    Text = "Fullbright",
    Default = false,
    Tooltip = "Changes the map's color tint.",
    Callback = function(Value)
        game.Lighting.GlobalShadows = not Value
        game.Lighting.OutdoorAmbient = Value and Options.AmbienceColor.Value or Color3.new(0, 0, 0)
    end
}):AddColorPicker("AmbienceColor", {
    Default = Color3.new(1, 1, 1),
    Title = "Color Tint",
    Callback = function(Value)
        game.Lighting.OutdoorAmbient = Toggles.Ambience.Value and Value or Color3.new(0, 0, 0)
    end
})
VisualEffects:AddToggle("NoFog", {
    Text = "Remove Fog",
    Default = false,
    Tooltip = "Clears any fog in the map.",
    Callback = function(Value)
        if game.Lighting:FindFirstChild("Atmosphere") then
            game.Lighting.Atmosphere.Density = Value and 0 or 0.3
        end
        game.Lighting.FogEnd = Value and 9999 or 500
    end
})

VisualEffects:AddDivider()

VisualEffects:AddToggle("Thirdperson", {
    Text = "Third Person View",
    Default = false,
    Tooltip = "Shows your character from behind.",
    Callback = function(Value)
        if Value then
            AntiConnections["Thirdperson"] = RunService.RenderStepped:Connect(function()
                local Cam = workspace.CurrentCamera
                Cam.CFrame = Cam.CFrame * CFrame.new(Options.ThirdpersonOffset.Value, Options.ThirdpersonOffsetUp.Value, 3.5 * (Options.ThirdpersonDistance.Value / 7.5)) * (Toggles.NoCamShake.Value and CFrame.new() or require(LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game).csgo)
            end)
        else
            if AntiConnections["Thirdperson"] then AntiConnections["Thirdperson"]:Disconnect() end
        end
    end
}):AddKeyPicker("ThirdpersonKey", { Default = "V", SyncToggleState = false, Mode = "Toggle", Text = "Third Person", NoUI = false })
VisualEffects:AddSlider("ThirdpersonDistance", {
    Text = "Third Person Distance",
    Default = 10,
    Min = 5,
    Max = 30,
    Rounding = 0,
    Compact = true,
    Tooltip = "How far the camera is in third person."
})
VisualEffects:AddSlider("ThirdpersonOffset", {
    Text = "Third Person Side Offset",
    Default = 0,
    Min = -5,
    Max = 5,
    Rounding = 1,
    Compact = true,
    Tooltip = "Left/right camera shift in third person."
})
VisualEffects:AddSlider("ThirdpersonOffsetUp", {
    Text = "Third Person Height Offset",
    Default = 0,
    Min = -5,
    Max = 5,
    Rounding = 1,
    Compact = true,
    Tooltip = "Up/down camera shift in third person."
})



VisualEffects:AddSlider("FOV", {
    Text = "Field of View",
    Default = 70,
    Min = 0,
    Max = 120,
    Rounding = 1,
    Compact = true,
    Tooltip = "Changes camera field of view smoothly every frame.",
    Callback = function(TargetFOV)
        TargetFOV = math.clamp(TargetFOV, 0, 120)
        local CurrentFOV = Camera.FieldOfView or 70
        local Speed = 10  -- Higher = faster transitions

        -- Disconnect previous connection if it exists
        if _G.FOVConnection then _G.FOVConnection:Disconnect() end

        -- Update FOV every frame smoothly
        _G.FOVConnection = RunService.RenderStepped:Connect(function(dt)
            CurrentFOV = CurrentFOV + (TargetFOV - CurrentFOV) * math.clamp(Speed * dt, 0, 1)
            Camera.FieldOfView = CurrentFOV
        end)
    end
})

local AutomationGroup = Tabs.Player:AddRightGroupbox("Automation")
AutomationGroup:AddToggle("AnchorCode", { Text = "Auto Anchor Codes", Default = false, Tooltip = "Notifies when anchor codes are found." })
AutomationGroup:AddToggle("MinecartInteract", { Text = "Auto Spam Minecart", Default = false, Tooltip = "Spams interact on nearby minecarts." }):AddKeyPicker("MinecartInteractKey", { Default = "H", SyncToggleState = false, Mode = "Hold", Text = "Spam Minecart", NoUI = false })
AutomationGroup:AddToggle("AnchorAutoSolve", { Text = "Auto Solve Anchors", Default = false, Tooltip = "Solves anchors automatically when close." })
AutomationGroup:AddToggle("AutoPadlockSolve", { Text = "Auto Solve Library Padlock", Default = false, Tooltip = "Unlocks padlock automatically when near." })
AutomationGroup:AddDivider()
AutomationGroup:AddSlider("AutoPadlockSolveDistance", { Text = "Padlock Solve Distance", Default = 25, Min = 10, Max = 50, Rounding = 0, Compact = false, Tooltip = "Distance to auto-input padlock code."})
AutomationGroup:AddSlider("AutoInteractRange", { Text = "Interact Range Boost", Default = 1, Min = 1, Max = 2, Rounding = 1, Compact = false })
local BypassGroup = Tabs.Player:AddLeftGroupbox("Bypass")
BypassGroup:AddToggle("CrouchSpoof", { Text = "Bypass Figure", Default = false, Tooltip = "Makes the game think you're crouching. Useful in Figure rooms.", Callback = function(Value)
    ReplicatedStorage.RemotesFolder.Crouch:FireServer(Value)
end })
BypassGroup:AddToggle("SpeedBypass", { Text = "Bypass Speed", Default = false, Tooltip = "Tries to avoid the speed anti-cheat." })
-- Visuals Tab: ESP and Effects
local ESPPlayers = Tabs.Visuals:AddLeftGroupbox("Player ESP")
ESPPlayers:AddToggle("ESPPlayersEnabled", {
    Text = "Enable Player ESP",
    Default = false,
    Callback = function(Value)
        if Value then
            for _, Player in pairs(game.Players:GetPlayers()) do
                if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    local Highlight, TextLabel = Esp(Player.Character, Player.Character, Player.Name, Options.ESPPlayerFillColor.Value, Options.ESPPlayerOutlineColor.Value)
                    table.insert(EspTable.Players, {Highlight, TextLabel})
                end
            end
        else
            for _, esp in pairs(EspTable.Players) do
                RemoveEspSmooth(esp[1].Adornee)
            end
            EspTable.Players = {}
        end
    end
}):AddColorPicker("ESPPlayerFillColor", {
    Default = Color3.new(1, 1, 1),
    Title = "Fill Color"
}):AddColorPicker("ESPPlayerOutlineColor", {
    Default = Color3.new(1, 1, 1),
    Title = "Outline Color"
})
local ESPInteractables = Tabs.Visuals:AddRightTabbox("Interactable ESP")
local ESPInteractables_Config = ESPInteractables:AddTab("Options")
ESPInteractables_Config:AddToggle("ESPDoors", {
    Text = "Doors",
    Default = false,
    Callback = function(Value)
        if Value then
            ScanAndAddESP("Interactables", "Door", "ESPDoors", "ESPDoorsFill", "ESPDoorsOutline",
                function(v) return v.Door end,
                function(v, adornee) v.AttributeChanged:Once(function() RemoveEspSmooth(adornee) end) end,
                function(v) return "Door" end)
        else
            for _, esp in pairs(EspTable.Interactables.Doors) do RemoveEspSmooth(esp[1].Adornee) end
            EspTable.Interactables.Doors = {}
        end
    end
}):AddColorPicker("ESPDoorsFill", { Default = Color3.new(1, 1, 1), Title = "Fill Color" })
:AddColorPicker("ESPDoorsOutline", { Default = Color3.new(1, 1, 1), Title = "Outline Color" })
ESPInteractables_Config:AddToggle("ESPDoorKeys", {
    Text = "Door Keys",
    Default = false,
    Callback = function(Value)
        if Value then
            ScanAndAddESP("Interactables", "KeyObtain", "ESPDoorKeys", "ESPDoorKeysFill", "ESPDoorKeysOutline",
                function(v) return v end,
                function(v, adornee) end,
                function(v) return "Door Key" end) -- No removal condition in my.lua
        else
            for _, esp in pairs(EspTable.Interactables.DoorKeys) do RemoveEspSmooth(esp[1].Adornee) end
            EspTable.Interactables.DoorKeys = {}
        end
    end
}):AddColorPicker("ESPDoorKeysFill", { Default = Color3.new(1, 1, 1), Title = "Fill Color" })
:AddColorPicker("ESPDoorKeysOutline", { Default = Color3.new(1, 1, 1), Title = "Outline Color" })
ESPInteractables_Config:AddToggle("ESPGoldPiles", {
    Text = "Gold Piles",
    Default = false,
    Callback = function(Value)
        if Value then
            ScanAndAddESP("Interactables", "GoldPile", "ESPGoldPiles", "ESPGoldPilesFill", "ESPGoldPilesOutline",
                function(v) return v end,
                function(v, adornee) end,
                function(v) return "Gold Pile [ "..v:GetAttribute("GoldValue").." ]" end)
        else
            for _, esp in pairs(EspTable.Interactables.GoldPiles) do RemoveEspSmooth(esp[1].Adornee) end
            EspTable.Interactables.GoldPiles = {}
        end
    end
}):AddColorPicker("ESPGoldPilesFill", { Default = Color3.new(1, 1, 1), Title = "Fill Color" })
:AddColorPicker("ESPGoldPilesOutline", { Default = Color3.new(1, 1, 1), Title = "Outline Color" })
ESPInteractables_Config:AddToggle("ESPGeneratorFuses", {
    Text = "Generator Fuses",
    Default = false,
    Callback = function(Value)
        if Value then
            ScanAndAddESP("Interactables", "FuseObtain", "ESPGeneratorFuses", "ESPGeneratorFusesFill", "ESPGeneratorFusesOutline",
                function(v) return v end,
                function(v, adornee) v.Hitbox.FuseModel.Changed:Once(function() RemoveEspSmooth(adornee) end) end,
                function(v) return "Generator Fuse" end)
        else
            for _, esp in pairs(EspTable.Interactables.GeneratorFuses) do RemoveEspSmooth(esp[1].Adornee) end
            EspTable.Interactables.GeneratorFuses = {}
        end
    end
}):AddColorPicker("ESPGeneratorFusesFill", { Default = Color3.new(1, 1, 1), Title = "Fill Color" })
:AddColorPicker("ESPGeneratorFusesOutline", { Default = Color3.new(1, 1, 1), Title = "Outline Color" })
ESPInteractables_Config:AddToggle("ESPGenerators", {
    Text = "Generators",
    Default = false,
    Callback = function(Value)
        if Value then
            ScanAndAddESP("Interactables", "MinesGenerator", "ESPGenerators", "ESPGeneratorsFill", "ESPGeneratorsOutline",
                function(v) return v end,
                function(v, adornee) v.Lever.Sound.Played:Once(function() RemoveEspSmooth(adornee) end) end,
                function(v) return "Generator" end)
        else
            for _, esp in pairs(EspTable.Interactables.Generators) do RemoveEspSmooth(esp[1].Adornee) end
            EspTable.Interactables.Generators = {}
        end
    end
}):AddColorPicker("ESPGeneratorsFill", { Default = Color3.new(1, 1, 1), Title = "Fill Color" })
:AddColorPicker("ESPGeneratorsOutline", { Default = Color3.new(1, 1, 1), Title = "Outline Color" })
ESPInteractables_Config:AddToggle("ESPGateLevers", {
    Text = "Gate Levers",
    Default = false,
    Callback = function(Value)
        if Value then
            ScanAndAddESP("Interactables", "LeverForGate", "ESPGateLevers", "ESPGateLeversFill", "ESPGateLeversOutline",
                function(v) return v.Main end,
                function(v, adornee) v.ActivateEventPrompt.AttributeChanged:Once(function() RemoveEspSmooth(adornee) end) end,
                function(v) return "Gate Lever" end)
        else
            for _, esp in pairs(EspTable.Interactables.GateLevers) do RemoveEspSmooth(esp[1].Adornee) end
            EspTable.Interactables.GateLevers = {}
        end
    end
}):AddColorPicker("ESPGateLeversFill", { Default = Color3.new(1, 1, 1), Title = "Fill Color" })
:AddColorPicker("ESPGateLeversOutline", { Default = Color3.new(1, 1, 1), Title = "Outline Color" })
ESPInteractables_Config:AddToggle("ESPBackroomsLevers", {
    Text = "Timer Levers",
    Default = false,
    Callback = function(Value)
        if Value then
            ScanAndAddESP("Interactables", "TimerLever", "ESPBackroomsLevers", "ESPBackroomsLeversFill", "ESPBackroomsLeversOutline",
                function(v) return v.Hitbox end,
                function(v, adornee) v.ActivateEventPrompt.AttributeChanged:Once(function() RemoveEspSmooth(adornee) end) end,
                function(v) return "Timer Lever" end)
        else
            for _, esp in pairs(EspTable.Interactables.BackroomsLevers) do RemoveEspSmooth(esp[1].Adornee) end
            EspTable.Interactables.BackroomsLevers = {}
        end
    end
}):AddColorPicker("ESPBackroomsLeversFill", { Default = Color3.new(1, 1, 1), Title = "Fill Color" })
:AddColorPicker("ESPBackroomsLeversOutline", { Default = Color3.new(1, 1, 1), Title = "Outline Color" })
ESPInteractables_Config:AddToggle("ESPLibraryBooks", {
    Text = "Library Books",
    Default = false,
    Callback = function(Value)
        if Value then
            ScanAndAddESP("Interactables", "LiveHintBook", "ESPLibraryBooks", "ESPLibraryBooksFill", "ESPLibraryBooksOutline",
                function(v) return v end,
                function(v, adornee) end,
                function(v) return "Book" end)
        else
            for _, esp in pairs(EspTable.Interactables.LibraryBooks) do RemoveEspSmooth(esp[1].Adornee) end
            EspTable.Interactables.LibraryBooks = {}
        end
    end
}):AddColorPicker("ESPLibraryBooksFill", { Default = Color3.new(1, 1, 1), Title = "Fill Color" })
:AddColorPicker("ESPLibraryBooksOutline", { Default = Color3.new(1, 1, 1), Title = "Outline Color" })
ESPInteractables_Config:AddToggle("ESPBreakerPoles", {
    Text = "Breaker Poles",
    Default = false,
    Callback = function(Value)
        if Value then
            ScanAndAddESP("Interactables", "LiveBreakerPolePickup", "ESPBreakerPoles", "ESPBreakerPolesFill", "ESPBreakerPolesOutline",
                function(v) return v end,
                function(v, adornee) end,
                function(v) return "Breaker Pole" end)
        else
            for _, esp in pairs(EspTable.Interactables.BreakerPoles) do RemoveEspSmooth(esp[1].Adornee) end
            EspTable.Interactables.BreakerPoles = {}
        end
    end
}):AddColorPicker("ESPBreakerPolesFill", { Default = Color3.new(1, 1, 1), Title = "Fill Color" })
:AddColorPicker("ESPBreakerPolesOutline", { Default = Color3.new(1, 1, 1), Title = "Outline Color" })
ESPInteractables_Config:AddToggle("ESPAnchors", {
    Text = "Anchors",
    Default = false,
    Callback = function(Value)
        if Value then
            ScanAndAddESP("Interactables", "_NestHandler", "ESPAnchors", "ESPAnchorsFill", "ESPAnchorsOutline",
                function(v) return v.AnchorBase end,
                function(v, adornee) v.AttributeChanged:Once(function() RemoveEspSmooth(adornee) end) end,
                function(v) return "Anchor" end) -- Simplified, full logic in my.lua for anchors
        else
            for _, esp in pairs(EspTable.Interactables.Anchors) do RemoveEspSmooth(esp[1].Adornee) end
            EspTable.Interactables.Anchors = {}
        end
    end
}):AddColorPicker("ESPAnchorsFill", { Default = Color3.new(1, 1, 1), Title = "Fill Color" })
:AddColorPicker("ESPAnchorsOutline", { Default = Color3.new(1, 1, 1), Title = "Outline Color" })
ESPInteractables_Config:AddToggle("ESPMiscPickups", {
    Text = "Misc Items",
    Default = false,
    Callback = function(Value)
        if Value then
            for name, display in pairs(MiscPickups) do
                ScanAndAddESP("Interactables", name, "ESPMiscPickups", "ESPMiscPickupsFill", "ESPMiscPickupsOutline",
                    function(v) return v.PrimaryPart end,
                    function(v, adornee) end,
                    function(v) return display end)
            end
        else
            for _, esp in pairs(EspTable.Interactables.MiscPickups) do RemoveEspSmooth(esp[1].Adornee) end
            EspTable.Interactables.MiscPickups = {}
        end
    end
}):AddColorPicker("ESPMiscPickupsFill", { Default = Color3.new(1, 1, 1), Title = "Fill Color" })
:AddColorPicker("ESPMiscPickupsOutline", { Default = Color3.new(1, 1, 1), Title = "Outline Color" })
ESPInteractables_Config:AddToggle("ESPClosets", {
    Text = "Closets & Sheds",
    Default = false,
    Callback = function(Value)
        if Value then
            -- Scan for Wardrobe
            ScanAndAddESP("Interactables", "Wardrobe", "ESPClosets", "ESPClosetsFill", "ESPClosetsOutline",
                function(v) return v.Door or v.Main end,
                function(v, adornee) v.AttributeChanged:Once(function() RemoveEspSmooth(adornee) end) end,
                function(v) return "Closet" end)
            -- Scan for Toolshed
            ScanAndAddESP("Interactables", "Toolshed", "ESPClosets", "ESPClosetsFill", "ESPClosetsOutline",
                function(v) return v.Door or v.Main end,
                function(v, adornee) v.AttributeChanged:Once(function() RemoveEspSmooth(adornee) end) end,
                function(v) return "Toolshed" end)
        else
            for _, esp in pairs(EspTable.Interactables.Closets) do RemoveEspSmooth(esp[1].Adornee) end
            EspTable.Interactables.Closets = {}
        end
    end
}):AddColorPicker("ESPClosetsFill", { Default = Color3.new(1, 1, 1), Title = "Fill Color" })
:AddColorPicker("ESPClosetsOutline", { Default = Color3.new(1, 1, 1), Title = "Outline Color" })
local ESPEntities = Tabs.Visuals:AddLeftGroupbox("Entity ESP")
ESPEntities:AddToggle("ESPEntitiesEnabled", { Text = "Enable Entity ESP", Default = false })
ESPEntities:AddToggle("ESPGiggle", { Text = "Giggle", Default = false }):AddColorPicker("ESPGiggleColor", { Default = Color3.new(255, 174, 116), Title = "Color" })
ESPEntities:AddToggle("ESPFigure", { Text = "Figure", Default = false }):AddColorPicker("ESPFigureColor", { Default = Color3.new(255, 174, 116), Title = "Color" })
ESPEntities:AddToggle("ESPGrumble", { Text = "Grumble", Default = false }):AddColorPicker("ESPGrumbleColor", { Default = Color3.new(255, 174, 116), Title = "Color" })
ESPEntities:AddToggle("ESPGloombatSwarm", { Text = "Gloombat Swarm", Default = false }):AddColorPicker("ESPGloombatSwarmColor", { Default = Color3.new(255, 174, 116), Title = "Color" })
ESPEntities:AddToggle("ESPDread", { Text = "Dread", Default = false }):AddColorPicker("ESPDreadColor", { Default = Color3.new(255, 174, 116), Title = "Color" })
ESPEntities:AddToggle("ESPRush", { Text = "Rush", Default = false }):AddColorPicker("ESPRushColor", { Default = Color3.new(255, 174, 116), Title = "Color" })
ESPEntities:AddToggle("ESPMovingAmbush", { Text = "Ambush", Default = false }):AddColorPicker("ESPMovingAmbushColor", { Default = Color3.fromRGB(255, 174, 116), Title = "Color" })
ESPEntities:AddToggle("ESPA60", { Text = "A-60", Default = false }):AddColorPicker("ESPA60Color", { Default = Color3.fromRGB(255, 174, 116), Title = "Color" })
ESPEntities:AddToggle("ESPA120", { Text = "A-120", Default = false }):AddColorPicker("ESPA120Color", { Default = Color3.fromRGB(255, 174, 116), Title = "Color" })
ESPEntities:AddToggle("ESPBlitz", { Text = "Blitz", Default = false }):AddColorPicker("ESPBlitzColor", { Default = Color3.fromRGB(255, 174, 116), Title = "Color" })
ESPEntities:AddToggle("ESPEyes", { Text = "Eyes", Default = false }):AddColorPicker("ESPEyesColor", { Default = Color3.fromRGB(255, 174, 116), Title = "Color" })
ESPEntities:AddToggle("ESPLookman", { Text = "Lookman", Default = false }):AddColorPicker("ESPLookmanColor", { Default = Color3.fromRGB(255, 174, 116), Title = "Color" })
ESPEntities:AddToggle("ESPSnare", { Text = "Snare", Default = false }):AddColorPicker("ESPSnareColor", { Default = Color3.new(255, 174, 116), Title = "Color" })
ESPEntities:AddToggle("ESPWorldLotus", { Text = "World Lotus", Disabled = true, Default = false }):AddColorPicker("ESPWorldLotusColor", { Default = Color3.new(255, 174, 116), Title = "Color" })
ESPEntities:AddToggle("ESPBramble", { Text = "Bramble", Default = false }):AddColorPicker("ESPBrambleColor", { Default = Color3.new(255, 174, 116), Title = "Color" })
ESPEntities:AddToggle("ESPCaws", { Text = "Caws", Default = false }):AddColorPicker("ESPCawsColor", { Default = Color3.new(255, 174, 116), Title = "Color" })
ESPEntities:AddToggle("ESPEyestalk", { Text = "Eyestalk", Default = false }):AddColorPicker("ESPEyestalkColor", { Default = Color3.new(255, 174, 116), Title = "Color" })
ESPEntities:AddToggle("ESPGrampy", { Text = "Grampy", Default = false }):AddColorPicker("ESPGrampyColor", { Default = Color3.new(255, 174, 116), Title = "Color" })
ESPEntities:AddToggle("ESPGroundskeeper", { Text = "Groundskeeper", Default = false }):AddColorPicker("ESPGroundskeeperColor", { Default = Color3.new(255, 174, 116), Title = "Color" })
ESPEntities:AddToggle("ESPMandrake", { Text = "Mandrake", Default = false }):AddColorPicker("ESPMandrakeColor", { Default = Color3.new(255, 174, 116), Title = "Color" })
ESPEntities:AddToggle("ESPMonument", { Text = "Monument", Default = false }):AddColorPicker("ESPMonumentColor", { Default = Color3.new(255, 174, 116), Title = "Color" })
ESPEntities:AddToggle("ESPSurge", { Text = "Surge", Default = false }):AddColorPicker("ESPSurgeColor", { Default = Color3.new(255, 174, 116), Title = "Color" })
Toggles.ESPGiggle:OnChanged(function(Value)
    if Value then
        ScanAndAddEntityESP("GiggleCeiling", "ESPGiggle", "ESPGiggleColor",
            function(v) return v.Root end,
            function(v) end,
            nil,
            function(v) return "Giggle" end)
    else
        for _, esp in pairs(EspTable.Entities) do
            if esp[2]:GetAttribute("Text") == "Giggle" then RemoveEspSmooth(esp[1].Adornee) end
        end
    end
end)
Toggles.ESPFigure:OnChanged(function(Value)
    if Value then
        ScanAndAddEntityESP("FigureRig", "ESPFigure", "ESPFigureColor",
            function(v) return v.Figure end,
            function(v) end,
            nil,
            function(v) return "Figure" end)
    else
        for _, esp in pairs(EspTable.Entities) do
            if esp[2]:GetAttribute("Text") == "Figure" then RemoveEspSmooth(esp[1].Adornee) end
        end
    end
end)
Toggles.ESPGrumble:OnChanged(function(Value)
    if Value then
        ScanAndAddEntityESP("GrumbleRig", "ESPGrumble", "ESPGrumbleColor",
            function(v) return v.Model end,
            function(v) end,
            nil,
            function(v) return "Grumble" end)
    else
        for _, esp in pairs(EspTable.Entities) do
            if esp[2]:GetAttribute("Text") == "Grumble" then RemoveEspSmooth(esp[1].Adornee) end
        end
    end
end)
Toggles.ESPGloombatSwarm:OnChanged(function(Value)
    if Value then
        ScanAndAddEntityESP("GloombatSwarm", "ESPGloombatSwarm", "ESPGloombatSwarmColor",
            function(v) return v end,
            function(v) end,
            nil,
            function(v) return "Gloombat Swarm" end)
    else
        for _, esp in pairs(EspTable.Entities) do
            if esp[2]:GetAttribute("Text") == "Gloombat Swarm" then RemoveEspSmooth(esp[1].Adornee) end
        end
    end
end)
Toggles.ESPDread:OnChanged(function(Value)
    if Value then
        ScanAndAddEntityESP("Dread", "ESPDread", "ESPDreadColor",
            function(v) return v.Main end,
            function(v) end,
            function(v)
                v:WaitForChild("Main")
                if not v:FindFirstChildOfClass("Humanoid") then
                    Instance.new("Humanoid", v)
                end
                v.Main.Transparency = 0.999
            end,
            function(v) return "Dread" end)
    else
        for _, esp in pairs(EspTable.Entities) do
            if esp[2]:GetAttribute("Text") == "Dread" then RemoveEspSmooth(esp[1].Adornee) end
        end
    end
end)
Toggles.ESPRush:OnChanged(function(Value)
    if Value then
        ScanAndAddEntityESP("RushMoving", "ESPRush", "ESPRushColor",
            function(v) return v end,
            function(v) end,
            nil,
            function(v) return "Rush" end)
    else
        for _, esp in pairs(EspTable.Entities) do
            if esp[2]:GetAttribute("Text") == "Rush" then RemoveEspSmooth(esp[1].Adornee) end
        end
    end
end)
Toggles.ESPMovingAmbush:OnChanged(function(Value)
    if Value then
        ScanAndAddEntityESP("AmbushMoving", "ESPMovingAmbush", "ESPMovingAmbushColor",
            function(v) return v end,
            function(v) end,
            nil,
            function(v) return "Ambush" end)
    else
        for _, esp in pairs(EspTable.Entities) do
            if esp[2]:GetAttribute("Text") == "Ambush" then RemoveEspSmooth(esp[1].Adornee) end
        end
    end
end)
Toggles.ESPA60:OnChanged(function(Value)
    if Value then
        ScanAndAddEntityESP("A60", "ESPA60", "ESPA60Color",
            function(v) return v end,
            function(v) end,
            nil,
            function(v) return "A-60" end)
    else
        for _, esp in pairs(EspTable.Entities) do
            if esp[2]:GetAttribute("Text") == "A-60" then RemoveEspSmooth(esp[1].Adornee) end
        end
    end
end)
Toggles.ESPA120:OnChanged(function(Value)
    if Value then
        ScanAndAddEntityESP("A120", "ESPA120", "ESPA120Color",
            function(v) return v end,
            function(v) end,
            nil,
            function(v) return "A-120" end)
    else
        for _, esp in pairs(EspTable.Entities) do
            if esp[2]:GetAttribute("Text") == "A-120" then RemoveEspSmooth(esp[1].Adornee) end
        end
    end
end)
Toggles.ESPBlitz:OnChanged(function(Value)
    if Value then
        ScanAndAddEntityESP("BackdoorRush", "ESPBlitz", "ESPBlitzColor",
            function(v) return v end,
            function(v) end,
            nil,
            function(v) return "Blitz" end)
    else
        for _, esp in pairs(EspTable.Entities) do
            if esp[2]:GetAttribute("Text") == "Blitz" then RemoveEspSmooth(esp[1].Adornee) end
        end
    end
end)
Toggles.ESPEyes:OnChanged(function(Value)
    if Value then
        ScanAndAddEntityESP("Eyes", "ESPEyes", "ESPEyesColor",
            function(v) return v end,
            function(v) end,
            nil,
            function(v) return "Eyes" end)
    else
        for _, esp in pairs(EspTable.Entities) do
            if esp[2]:GetAttribute("Text") == "Eyes" then RemoveEspSmooth(esp[1].Adornee) end
        end
    end
end)
Toggles.ESPLookman:OnChanged(function(Value)
    if Value then
        ScanAndAddEntityESP("BackdoorLookman", "ESPLookman", "ESPLookmanColor",
            function(v) return v.Eyes end,
            function(v) end,
            nil,
            function(v) return "Lookman" end)
    else
        for _, esp in pairs(EspTable.Entities) do
            if esp[2]:GetAttribute("Text") == "Lookman" then RemoveEspSmooth(esp[1].Adornee) end
        end
    end
end)
Toggles.ESPSnare:OnChanged(function(Value)
    if Value then
        ScanAndAddEntityESP("Snare", "ESPSnare", "ESPSnareColor",
            function(v) return v end,
            function(v) end,
            nil,
            function(v) return "Snare" end)
    else
        for _, esp in pairs(EspTable.Entities) do
            if esp[2]:GetAttribute("Text") == "Snare" then RemoveEspSmooth(esp[1].Adornee) end
        end
    end
end)
Toggles.ESPWorldLotus:OnChanged(function(Value)
    if Value then
        ScanAndAddEntityESP("WorldLotus", "ESPWorldLotus", "ESPWorldLotusColor",
            function(v) return v end,
            function(v) end,
            nil,
            function(v) return "World Lotus" end)
    else
        for _, esp in pairs(EspTable.Entities) do
            if esp[2]:GetAttribute("Text") == "World Lotus" then RemoveEspSmooth(esp[1].Adornee) end
        end
    end
end)
Toggles.ESPBramble:OnChanged(function(Value)
    if Value then
        ScanAndAddEntityESP("Bramble", "ESPBramble", "ESPBrambleColor",
            function(v) return v end,
            function(v) end,
            nil,
            function(v) return "Bramble" end)
    else
        for _, esp in pairs(EspTable.Entities) do
            if esp[2]:GetAttribute("Text") == "Bramble" then RemoveEspSmooth(esp[1].Adornee) end
        end
    end
end)
Toggles.ESPCaws:OnChanged(function(Value)
    if Value then
        ScanAndAddEntityESP("Caws", "ESPCaws", "ESPCawsColor",
            function(v) return v end,
            function(v) end,
            nil,
            function(v) return "Caws" end)
    else
        for _, esp in pairs(EspTable.Entities) do
            if esp[2]:GetAttribute("Text") == "Caws" then RemoveEspSmooth(esp[1].Adornee) end
        end
    end
end)
Toggles.ESPEyestalk:OnChanged(function(Value)
    if Value then
        ScanAndAddEntityESP("Eyestalk", "ESPEyestalk", "ESPEyestalkColor",
            function(v) return v end,
            function(v) end,
            nil,
            function(v) return "Eyestalk" end)
    else
        for _, esp in pairs(EspTable.Entities) do
            if esp[2]:GetAttribute("Text") == "Eyestalk" then RemoveEspSmooth(esp[1].Adornee) end
        end
    end
end)
Toggles.ESPGrampy:OnChanged(function(Value)
    if Value then
        ScanAndAddEntityESP("Grampy", "ESPGrampy", "ESPGrampyColor",
            function(v) return v end,
            function(v) end,
            nil,
            function(v) return "Grampy" end)
    else
        for _, esp in pairs(EspTable.Entities) do
            if esp[2]:GetAttribute("Text") == "Grampy" then RemoveEspSmooth(esp[1].Adornee) end
        end
    end
end)
Toggles.ESPGroundskeeper:OnChanged(function(Value)
    if Value then
        ScanAndAddEntityESP("Groundskeeper", "ESPGroundskeeper", "ESPGroundskeeperColor",
            function(v) return v end,
            function(v) end,
            nil,
            function(v) return "Groundskeeper" end)
    else
        for _, esp in pairs(EspTable.Entities) do
            if esp[2]:GetAttribute("Text") == "Groundskeeper" then RemoveEspSmooth(esp[1].Adornee) end
        end
    end
end)
Toggles.ESPMandrake:OnChanged(function(Value)
    if Value then
        ScanAndAddEntityESP("Mandrake", "ESPMandrake", "ESPMandrakeColor",
            function(v) return v end,
            function(v) end,
            nil,
            function(v) return "Mandrake" end)
    else
        for _, esp in pairs(EspTable.Entities) do
            if esp[2]:GetAttribute("Text") == "Mandrake" then RemoveEspSmooth(esp[1].Adornee) end
        end
    end
end)
Toggles.ESPMonument:OnChanged(function(Value)
    if Value then
        ScanAndAddEntityESP("Monument", "ESPMonument", "ESPMonumentColor",
            function(v) return v end,
            function(v) end,
            nil,
            function(v) return "Monument" end)
    else
        for _, esp in pairs(EspTable.Entities) do
            if esp[2]:GetAttribute("Text") == "Monument" then RemoveEspSmooth(esp[1].Adornee) end
        end
    end
end)
Toggles.ESPSurge:OnChanged(function(Value)
    if Value then
        ScanAndAddEntityESP("Surge", "ESPSurge", "ESPSurgeColor",
            function(v) return v end,
            function(v) end,
            nil,
            function(v) return "Surge" end)
    else
        for _, esp in pairs(EspTable.Entities) do
            if esp[2]:GetAttribute("Text") == "Surge" then RemoveEspSmooth(esp[1].Adornee) end
        end
    end
end)
-- DescendantAdded connection for new interactables and some entities
Rooms.DescendantAdded:Connect(function(v)
    if not Toggles.ESPInteractMainEnabled.Value then return end
    if v:IsA("Model") then
        if v.Name == "Door" and Toggles.ESPDoors.Value then
            local Highlight, TextLabel = Esp(v.Door, v.Door, "Door", Options.ESPDoorsFill.Value, Options.ESPDoorsOutline.Value)
            table.insert(EspTable.Interactables.Doors, {Highlight, TextLabel})
            v.AttributeChanged:Once(function() RemoveEspSmooth(v.Door) end)
        elseif v.Name == "KeyObtain" and Toggles.ESPDoorKeys.Value then
            local Highlight, TextLabel = Esp(v, v, "Door Key", Options.ESPDoorKeysFill.Value, Options.ESPDoorKeysOutline.Value)
            table.insert(EspTable.Interactables.DoorKeys, {Highlight, TextLabel})
        -- Add similar for other interactables...
        elseif v.Name == "GiggleCeiling" and Toggles.ESPGiggle.Value then
            local Highlight, TextLabel = Esp(v, v.Root, "Giggle", Options.ESPGiggleColor.Value, Options.ESPGiggleColor.Value)
            table.insert(EspTable.Entities, {Highlight, TextLabel})
        elseif v.Name == "Snare" and Toggles.ESPSnare.Value then
            local Highlight, TextLabel = Esp(v, v, "Snare", Options.ESPSnareColor.Value, Options.ESPSnareColor.Value)
            table.insert(EspTable.Entities, {Highlight, TextLabel})
        elseif v.Name == "Wardrobe" and Toggles.ESPClosets.Value then
            local adornee = v.Door or v.Main
            local Highlight, TextLabel = Esp(adornee, adornee, "Closet", Options.ESPClosetsFill.Value, Options.ESPClosetsOutline.Value)
            table.insert(EspTable.Interactables.Closets, {Highlight, TextLabel})
            v.AttributeChanged:Once(function() RemoveEspSmooth(adornee) end)
        elseif v.Name == "Toolshed" and Toggles.ESPClosets.Value then
            local adornee = v.Door or v.Main
            local Highlight, TextLabel = Esp(adornee, adornee, "Toolshed", Options.ESPClosetsFill.Value, Options.ESPClosetsOutline.Value)
            table.insert(EspTable.Interactables.Closets, {Highlight, TextLabel})
            v.AttributeChanged:Once(function() RemoveEspSmooth(adornee) end)
        -- Add for other room-based entities if needed
        end
    end
end)
-- workspace.DescendantAdded for all entities (stable across rooms)
workspace.DescendantAdded:Connect(function(v)
    if not Toggles.ESPEntitiesEnabled.Value then return end
    if v:IsA("Model") then
        if v.Name == "GloombatSwarm" and Toggles.ESPGloombatSwarm.Value then
            local Highlight, TextLabel = Esp(v, v, "Gloombat Swarm", Options.ESPGloombatSwarmColor.Value, Options.ESPGloombatSwarmColor.Value)
            table.insert(EspTable.Entities, {Highlight, TextLabel})
        elseif v.Name == "Dread" and Toggles.ESPDread.Value then
            v:WaitForChild("Main")
            Instance.new("Humanoid", v)
            v.Main.Transparency = 0.999
            local Highlight, TextLabel = Esp(v, v.Main, "Dread", Options.ESPDreadColor.Value, Options.ESPDreadColor.Value)
            table.insert(EspTable.Entities, {Highlight, TextLabel})
        elseif v.Name == "RushMoving" and Toggles.ESPRush.Value then
            local Highlight, TextLabel = Esp(v, v, "Rush", Options.ESPRushColor.Value, Options.ESPRushColor.Value)
            table.insert(EspTable.Entities, {Highlight, TextLabel})
        elseif v.Name == "AmbushMoving" and Toggles.ESPMovingAmbush.Value then
            local Highlight, TextLabel = Esp(v, v, "Ambush", Options.ESPMovingAmbushColor.Value, Options.ESPMovingAmbushColor.Value)
            table.insert(EspTable.Entities, {Highlight, TextLabel})
        elseif v.Name == "A60" and Toggles.ESPA60.Value then
            local Highlight, TextLabel = Esp(v, v, "A-60", Options.ESPA60Color.Value, Options.ESPA60Color.Value)
            table.insert(EspTable.Entities, {Highlight, TextLabel})
        elseif v.Name == "A120" and Toggles.ESPA120.Value then
            local Highlight, TextLabel = Esp(v, v, "A-120", Options.ESPA120Color.Value, Options.ESPA120Color.Value)
            table.insert(EspTable.Entities, {Highlight, TextLabel})
        elseif v.Name == "BackdoorRush" and Toggles.ESPBlitz.Value then
            local Highlight, TextLabel = Esp(v, v, "Blitz", Options.ESPBlitzColor.Value, Options.ESPBlitzColor.Value)
            table.insert(EspTable.Entities, {Highlight, TextLabel})
        elseif v.Name == "Eyes" and Toggles.ESPEyes.Value then
            local Highlight, TextLabel = Esp(v, v, "Eyes", Options.ESPEyesColor.Value, Options.ESPEyesColor.Value)
            table.insert(EspTable.Entities, {Highlight, TextLabel})
        elseif v.Name == "BackdoorLookman" and Toggles.ESPLookman.Value then
            local Highlight, TextLabel = Esp(v, v.Eyes, "Lookman", Options.ESPLookmanColor.Value, Options.ESPLookmanColor.Value)
            table.insert(EspTable.Entities, {Highlight, TextLabel})
        elseif v.Name == "FigureRig" and Toggles.ESPFigure.Value then
            local Highlight, TextLabel = Esp(v, v.Figure, "Figure", Options.ESPFigureColor.Value, Options.ESPFigureColor.Value)
            table.insert(EspTable.Entities, {Highlight, TextLabel})
        elseif v.Name == "GrumbleRig" and Toggles.ESPGrumble.Value then
            local Highlight, TextLabel = Esp(v, v.Model, "Grumble", Options.ESPGrumbleColor.Value, Options.ESPGrumbleColor.Value)
            table.insert(EspTable.Entities, {Highlight, TextLabel})
        elseif v.Name == "Snare" and Toggles.ESPSnare.Value then
            local Highlight, TextLabel = Esp(v, v, "Snare", Options.ESPSnareColor.Value, Options.ESPSnareColor.Value)
            table.insert(EspTable.Entities, {Highlight, TextLabel})
        elseif v.Name == "WorldLotus" and Toggles.ESPWorldLotus.Value then
            local Highlight, TextLabel = Esp(v, v, "World Lotus", Options.ESPWorldLotusColor.Value, Options.ESPWorldLotusColor.Value)
            table.insert(EspTable.Entities, {Highlight, TextLabel})
        elseif v.Name == "Bramble" and Toggles.ESPBramble.Value then
            local Highlight, TextLabel = Esp(v, v, "Bramble", Options.ESPBrambleColor.Value, Options.ESPBrambleColor.Value)
            table.insert(EspTable.Entities, {Highlight, TextLabel})
        elseif v.Name == "Caws" and Toggles.ESPCaws.Value then
            local Highlight, TextLabel = Esp(v, v, "Caws", Options.ESPCawsColor.Value, Options.ESPCawsColor.Value)
            table.insert(EspTable.Entities, {Highlight, TextLabel})
        elseif v.Name == "Eyestalk" and Toggles.ESPEyestalk.Value then
            local Highlight, TextLabel = Esp(v, v, "Eyestalk", Options.ESPEyestalkColor.Value, Options.ESPEyestalkColor.Value)
            table.insert(EspTable.Entities, {Highlight, TextLabel})
        elseif v.Name == "Grampy" and Toggles.ESPGrampy.Value then
            local Highlight, TextLabel = Esp(v, v, "Grampy", Options.ESPGrampyColor.Value, Options.ESPGrampyColor.Value)
            table.insert(EspTable.Entities, {Highlight, TextLabel})
        elseif v.Name == "Groundskeeper" and Toggles.ESPGroundskeeper.Value then
            local Highlight, TextLabel = Esp(v, v, "Groundskeeper", Options.ESPGroundskeeperColor.Value, Options.ESPGroundskeeperColor.Value)
            table.insert(EspTable.Entities, {Highlight, TextLabel})
        elseif v.Name == "Mandrake" and Toggles.ESPMandrake.Value then
            local Highlight, TextLabel = Esp(v, v, "Mandrake", Options.ESPMandrakeColor.Value, Options.ESPMandrakeColor.Value)
            table.insert(EspTable.Entities, {Highlight, TextLabel})
        elseif v.Name == "Monument" and Toggles.ESPMonument.Value then
            local Highlight, TextLabel = Esp(v, v, "Monument", Options.ESPMonumentColor.Value, Options.ESPMonumentColor.Value)
            table.insert(EspTable.Entities, {Highlight, TextLabel})
        elseif v.Name == "Surge" and Toggles.ESPSurge.Value then
            local Highlight, TextLabel = Esp(v, v, "Surge", Options.ESPSurgeColor.Value, Options.ESPSurgeColor.Value)
            table.insert(EspTable.Entities, {Highlight, TextLabel})
        end
    end
end)
local ESPSettings = Tabs.Visuals:AddRightGroupbox("ESP Settings")
ESPSettings:AddDropdown("ESPFont", {
    Values = { "Arial", "SourceSans", "Highway", "Fantasy", "Gotham", "DenkOne", "JosefinSans", "Nunito", "Oswald", "RobotoMono", "Sarpanch", "Ubuntu" },
    Default = 2,
    Multi = false,
    Text = "Text Font"
})
ESPSettings:AddSlider("ESPFontSize", { Text = "Font Size", Default = 20, Min = 10, Max = 32, Rounding = 0, Compact = true })
ESPSettings:AddSlider("ESPFillTransparency", { Text = "Fill Transparency", Default = 0.7, Min = 0, Max = 1, Rounding = 2, Compact = true })
ESPSettings:AddSlider("ESPOutlineTransparency", { Text = "Outline Transparency", Default = 0.2, Min = 0, Max = 1, Rounding = 2, Compact = true })
ESPSettings:AddSlider("ESPFadeTime", { Text = "Fade Time", Default = 1, Min = 0, Max = 2, Rounding = 2, Compact = true, Suffix = "s" })
-- Entities Tab: Notify and Anti
local NotifyGroup = Tabs.Entities:AddLeftGroupbox("Entity Notifications")
local EntityNotifications = {
    ["Screech"] = {Description = "Screech has spawned! Look away to avoid damage!", Color = Color3.fromRGB(255, 255, 0)},
    ["Halt"] = {Description = "Halt is here! Turn around to navigate the hallway!", Color = Color3.fromRGB(0, 255, 255)},
    ["FigureRig"] = {Description = "Figure detected! Stay quiet and avoid movement!", Color = Color3.fromRGB(255, 0, 0)},
    ["Eyes"] = {Description = "Eyes spawned! Don't look at them!", Color = Color3.fromRGB(127, 30, 220)},
    ["SeekMoving"] = {Description = "Seek is chasing! Run and avoid obstacles!", Color = Color3.fromRGB(255, 100, 100)},
    ["RushMoving"] = {Description = "Rush is coming! Hide in a closet!", Color = Color3.fromRGB(0, 255, 0)},
    ["AmbushMoving"] = {Description = "Ambush is approaching! Hide multiple times!", Color = Color3.fromRGB(80, 255, 110)},
    ["A60"] = {Description = "A-60 is rushing! Find a hiding spot!", Color = Color3.fromRGB(200, 50, 50)},
    ["A120"] = {Description = "A-120 is near! Stay alert and hide!", Color = Color3.fromRGB(55, 55, 55)},
    ["GiggleCeiling"] = {Description = "Giggle is on the ceiling! Avoid making noise!", Color = Color3.fromRGB(200, 200, 200)},
    ["GrumbleRig"] = {Description = "Grumble is patrolling! Stay out of its path!", Color = Color3.fromRGB(150, 150, 150)},
    ["GloombatSwarm"] = {Description = "Gloombat Swarm incoming! Stay in the light!", Color = Color3.fromRGB(100, 100, 100)},
    ["Dread"] = {Description = "Dread is active! Watch the timer!", Color = Color3.fromRGB(80, 80, 80)},
    ["BackdoorLookman"] = {Description = "Lookman is watching! Avoid eye contact!", Color = Color3.fromRGB(110, 15, 15)},
    ["Snare"] = {Description = "Snare trap spawned! Watch your step!", Color = Color3.fromRGB(100, 100, 100)},
    ["WorldLotus"] = {Description = "World Lotus detected! Avoid its gaze!", Color = Color3.fromRGB(200, 230, 50)},
    ["Bramble"] = {Description = "Bramble is growing! Stay clear of vines!", Color = Color3.fromRGB(50, 150, 30)},
    ["Caws"] = {Description = "Caws are flying! Listen for their cries!", Color = Color3.fromRGB(30, 30, 30)},
    ["Eyestalk"] = {Description = "Eyestalk is watching! Don't linger in its sight!", Color = Color3.fromRGB(150, 80, 200)},
    ["Grampy"] = {Description = "Grampy is roaming! Avoid his patrol!", Color = Color3.fromRGB(180, 180, 180)},
    ["Groundskeeper"] = {Description = "Groundskeeper is near! Stay hidden!", Color = Color3.fromRGB(100, 150, 50)},
    ["Mandrake"] = {Description = "Mandrake is screaming! Cover your ears!", Color = Color3.fromRGB(130, 80, 30)},
    ["Monument"] = {Description = "Monument activated! Avoid its effects!", Color = Color3.fromRGB(150, 150, 150)},
    ["Surge"] = {Description = "Surge is charging! Stay grounded!", Color = Color3.fromRGB(230, 130, 30)},
}
NotifyGroup:AddToggle("NotifyEntities", {
    Text = "Notify on Entity Spawn",
    Default = false,
    Callback = function(Value)
        if Value then
            AntiConnections["NotifyEntities"] = workspace.ChildAdded:Connect(function(child)
                if child:IsA("Model") and EntityNotifications[child.Name] and Toggles["Notify" .. child.Name].Value then
                    Library:Notify(EntityNotifications[child.Name].Description, 5)
                end
            end)
            AntiConnections["NotifyEntitiesRooms"] = Rooms.DescendantAdded:Connect(function(desc)
                if desc:IsA("Model") and EntityNotifications[desc.Name] and Toggles["Notify" .. desc.Name].Value then
                    Library:Notify(EntityNotifications[desc.Name].Description, 5)
                end
            end)
        else
            if AntiConnections["NotifyEntities"] then AntiConnections["NotifyEntities"]:Disconnect() end
            if AntiConnections["NotifyEntitiesRooms"] then AntiConnections["NotifyEntitiesRooms"]:Disconnect() end
        end
    end
})
NotifyGroup:AddToggle("NotifyScreech", { Text = "Screech", Default = true })
NotifyGroup:AddToggle("NotifyHalt", { Text = "Halt", Default = true })
NotifyGroup:AddToggle("NotifyFigureRig", { Text = "Figure", Default = true })
NotifyGroup:AddToggle("NotifyEyes", { Text = "Eyes", Default = true })
NotifyGroup:AddToggle("NotifySeekMoving", { Text = "Seek", Default = true })
NotifyGroup:AddToggle("NotifyRushMoving", { Text = "Rush", Default = true })
NotifyGroup:AddToggle("NotifyAmbushMoving", { Text = "Ambush", Default = true })
NotifyGroup:AddToggle("NotifyA60", { Text = "A-60", Default = true })
NotifyGroup:AddToggle("NotifyA120", { Text = "A-120", Default = true })
NotifyGroup:AddToggle("NotifyGiggleCeiling", { Text = "Giggle", Default = true })
NotifyGroup:AddToggle("NotifyGrumbleRig", { Text = "Grumble", Default = true })
NotifyGroup:AddToggle("NotifyGloombatSwarm", { Text = "Gloombat Swarm", Default = true })
NotifyGroup:AddToggle("NotifyDread", { Text = "Dread", Default = true })
NotifyGroup:AddToggle("NotifyBackdoorLookman", { Text = "Lookman", Default = true })
NotifyGroup:AddToggle("NotifySnare", { Text = "Snare", Default = true })
NotifyGroup:AddToggle("NotifyWorldLotus", { Text = "World Lotus", Default = true })
NotifyGroup:AddToggle("NotifyBramble", { Text = "Bramble", Default = true })
NotifyGroup:AddToggle("NotifyCaws", { Text = "Caws", Default = true })
NotifyGroup:AddToggle("NotifyEyestalk", { Text = "Eyestalk", Default = true })
NotifyGroup:AddToggle("NotifyGrampy", { Text = "Grampy", Default = true })
NotifyGroup:AddToggle("NotifyGroundskeeper", { Text = "Groundskeeper", Default = true })
NotifyGroup:AddToggle("NotifyMandrake", { Text = "Mandrake", Default = true })
NotifyGroup:AddToggle("NotifyMonument", { Text = "Monument", Default = true })
NotifyGroup:AddToggle("NotifySurge", { Text = "Surge", Default = true })
local AntiGroup = Tabs.Entities:AddRightGroupbox("Avoid Entities")
AntiGroup:AddToggle("AntiScreech", {
    Text = "Avoid Screech",
    Default = false,
    Callback = function(Value)
        if Value then
            AntiConnections["Screech"] = workspace.ChildAdded:Connect(function(child)
                if child.Name == "Screech" then
                    child:Destroy()
                end
            end)
        else
            if AntiConnections["Screech"] then AntiConnections["Screech"]:Disconnect() end
        end
    end
})
AntiGroup:AddToggle("NoHasteEffects", {
    Text = "Avoid Haste Screen Effects",
    Default = false,
    Tooltip = "Removes red edges when Haste appears.",
    Callback = function(Value)
        for _, v in workspace.CurrentCamera:GetChildren() do
            if v.Name == "LiveSanity" and workspace:FindFirstChild("EntityModel") then
                v.Enabled = not Value
            end
        end
    end
})
AntiGroup:AddToggle("NoHidingVignette", {
    Text = "Avoid Hiding Edges",
    Default = false,
    Tooltip = "Removes dark edges when hiding.",
    Callback = function(Value)
        LocalPlayer.PlayerGui.MainUI.MainFrame.HideVignette.Image = Value and "rbxassetid://0" or "rbxassetid://6100076320"
    end
})
AntiGroup:AddToggle("NoHaltEffects", {
    Text = "Avoid Halt Flashing",
    Default = false,
    Tooltip = "Removes flashing in Halt rooms.",
    Callback = function(Value)
        -- Hook from ey.lua for shade module
        if Value then
            AntiConnections["HaltEffects"] = Rooms.DescendantAdded:Connect(function(desc)
                if desc.Name == "Shade" then
                    desc:Destroy()
                end
            end)
        else
            if AntiConnections["HaltEffects"] then AntiConnections["HaltEffects"]:Disconnect() end
        end
    end
})
AntiGroup:AddToggle("RemoveTimothyJumpscare", {
    Text = "Avoid Timothy Scare",
    Default = false,
    Tooltip = "Removes Timothy's jumpscare.",
    Callback = function(Value)
        -- Hook spider jumpscare module
    end
})
AntiGroup:AddToggle("NoGlitchJumpscare", {
    Text = "Avoid Glitch Scare",
    Default = false,
    Tooltip = "Removes Glitch's jumpscare.",
    Callback = function(Value)
        -- Hook glitch module
    end
})
AntiGroup:AddToggle("NoVoidEffect", {
    Text = "Avoid Void Effect",
    Default = false,
    Tooltip = "Removes void falling effect.",
    Callback = function(Value)
        -- Hook void module
    end
})
AntiGroup:AddToggle("NoSeekEffects", {
    Text = "Avoid Seek Room Effects",
    Default = false,
    Tooltip = "Removes Seek's eyes and textures.",
    Callback = function(Value)
        -- Hook seek module
    end
})
AntiGroup:AddToggle("AntiHalt", {
    Text = "Avoid Halt",
    Default = false,
    Callback = function(Value)
        if Value then
            AntiConnections["Halt"] = Rooms.DescendantAdded:Connect(function(desc)
                if desc.Name == "Halt" then
                    desc:Destroy()
                end
            end)
        else
            if AntiConnections["Halt"] then AntiConnections["Halt"]:Disconnect() end
        end
    end
})
AntiGroup:AddToggle("AntiGiggle", {
    Text = "Avoid Giggle",
    Default = false,
    Callback = function(Value)
        if Value then
            AntiConnections["Giggle"] = Rooms.DescendantAdded:Connect(function(desc)
                if desc.Name == "GiggleCeiling" then
                    desc:WaitForChild("Hitbox", 9e9)
                    desc.Hitbox.CanTouch = false
                end
            end)
            for _, Room in Rooms:GetChildren() do
                for _, Giggle in Room:GetChildren() do
                    if Giggle:IsA("Model") and Giggle.Name == "GiggleCeiling" then
                        Giggle:WaitForChild("Hitbox", 9e9)
                        Giggle.Hitbox.CanTouch = false
                    end
                end
            end
        else
            if AntiConnections["Giggle"] then
                AntiConnections["Giggle"]:Disconnect()
            end
            for _, Room in Rooms:GetChildren() do
                for _, Giggle in Room:GetChildren() do
                    if Giggle:IsA("Model") and Giggle.Name == "GiggleCeiling" then
                        Giggle:WaitForChild("Hitbox", 9e9)
                        Giggle.Hitbox.CanTouch = true
                    end
                end
            end
        end
    end
})
AntiGroup:AddToggle("AntiGloombat", {
    Text = "Avoid Gloombat Swarm",
    Default = false,
    Callback = function(Value)
       
        for _, v in game:GetService("Workspace").CurrentRooms:GetDescendants() do
            if v.Name == "GloomEgg" and v:IsA("Model") and v:FindFirstChild("Egg") then
                v.Egg.CanTouch = not Value
            end
        end
    end
})
game:GetService("Workspace").CurrentRooms.DescendantAdded:Connect(function(v)
    if v.Name == "GloomEgg" and v:IsA("Model") then
        v:WaitForChild("Egg", 9e9)
        v.Egg.CanTouch = not Toggles.AntiGloombat.Value
    end
end)
AntiGroup:AddToggle("AntiLookman", {
    Text = "Avoid Lookman",
    Default = false,
    Callback = function(Value)
        if Value then
            AntiConnections["Lookman"] = workspace.ChildAdded:Connect(function(child)
                if child.Name == "BackdoorLookman" then
                    child:WaitForChild("Core", 9e9)
                    child.Core.CanTouch = false
                end
            end)
            for _, v in workspace:GetChildren() do
                if v.Name == "BackdoorLookman" and v:IsA("Model") then
                    v:WaitForChild("Core", 9e9)
                    v.Core.CanTouch = false
                end
            end
           
            local Main_Game = require(LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game)
            Main_Game.forcecharlook(Vector3.new(0, -1, 0))
        else
            if AntiConnections["Lookman"] then AntiConnections["Lookman"]:Disconnect() end
            for _, v in workspace:GetChildren() do
                if v.Name == "BackdoorLookman" and v:IsA("Model") then
                    v:WaitForChild("Core", 9e9)
                    v.Core.CanTouch = true
                end
            end
           
            local Main_Game = require(LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game)
            Main_Game.forcecharlook(Vector3.new(0, 0, 0))
        end
    end
})
AntiGroup:AddToggle("AntiSnare", {
    Text = "Avoid Snare",
    Default = false,
    Callback = function(Value)
        for _, v in game:GetService("Workspace").CurrentRooms:GetDescendants() do
            if v.Name == "Snare" and v:FindFirstChild("Hitbox") then
                v.Hitbox.CanTouch = not Value
            end
        end
    end
})
AntiGroup:AddToggle("AntiSeekArmsChandelier", {
    Text = "Avoid Seek Arms & Chandeliers",
    Default = false,
    Callback = function(Value)
        if Value then
            AntiConnections["SeekArmsChandelier"] = Rooms.DescendantAdded:Connect(function(desc)
                if desc.Name == "Seek_Arm" then
                    desc:WaitForChild("AnimatorPart", 9e9)
                    desc.AnimatorPart.CanTouch = false
                    desc.AnimatorPart.Transparency = 1
                    for _, part in desc:GetDescendants() do
                        if part:IsA("BasePart") then
                            part.Transparency = 1
                        end
                    end
                elseif desc.Name == "ChandelierObstruction" then
                    desc:WaitForChild("HurtPart", 9e9)
                    desc.HurtPart.CanTouch = false
                    desc.HurtPart.Transparency = 1
                    for _, part in desc:GetDescendants() do
                        if part:IsA("BasePart") then
                            part.Transparency = 1
                        end
                    end
                end
            end)
            for _, v in Rooms:GetDescendants() do
                if v.Name == "Seek_Arm" and v:IsA("Model") then
                    v:WaitForChild("AnimatorPart", 9e9)
                    v.AnimatorPart.CanTouch = false
                    v.AnimatorPart.Transparency = 1
                    for _, part in v:GetDescendants() do
                        if part:IsA("BasePart") then
                            part.Transparency = 1
                        end
                    end
                elseif v.Name == "ChandelierObstruction" and v:IsA("Model") then
                    v:WaitForChild("HurtPart", 9e9)
                    v.HurtPart.CanTouch = false
                    v.HurtPart.Transparency = 1
                    for _, part in v:GetDescendants() do
                        if part:IsA("BasePart") then
                            part.Transparency = 1
                        end
                    end
                end
            end
        else
            if AntiConnections["SeekArmsChandelier"] then AntiConnections["SeekArmsChandelier"]:Disconnect() end
            for _, v in Rooms:GetDescendants() do
                if v.Name == "Seek_Arm" and v:IsA("Model") then
                    v:WaitForChild("AnimatorPart", 9e9)
                    v.AnimatorPart.CanTouch = true
                    v.AnimatorPart.Transparency = 0
                    for _, part in v:GetDescendants() do
                        if part:IsA("BasePart") then
                            part.Transparency = 0
                        end
                    end
                elseif v.Name == "ChandelierObstruction" and v:IsA("Model") then
                    v:WaitForChild("HurtPart", 9e9)
                    v.HurtPart.CanTouch = true
                    v.HurtPart.Transparency = 0
                    for _, part in v:GetDescendants() do
                        if part:IsA("BasePart") then
                            part.Transparency = 0
                        end
                    end
                end
            end
        end
    end
})
AntiGroup:AddToggle("AntiDupe", {
    Text = "Avoid Fake Doors",
    Default = false,
    Callback = function(Value)
        -- Handle existing DoorFake models
        for _, v in game:GetService("Workspace").CurrentRooms:GetDescendants() do
            if v.Name == "DoorFake" and v:IsA("Model") then
                if v:FindFirstChild("Hidden") then
                    v.Hidden.CanTouch = not Value
                end
                if v:FindFirstChild("LockPart") and v.LockPart:FindFirstChild("UnlockPrompt") then
                    v.LockPart.UnlockPrompt.Enabled = not Value
                end
            end
        end
    end
})
game:GetService("Workspace").CurrentRooms.DescendantAdded:Connect(function(v)
    if v.Name == "DoorFake" and v:IsA("Model") then
        v:WaitForChild("Hidden", 9e9)
        v.Hidden.CanTouch = not Toggles.AntiDupe.Value
        v:WaitForChild("LockPart", 2)
        if v:FindFirstChild("LockPart") and v.LockPart:FindFirstChild("UnlockPrompt") then
            v.LockPart.UnlockPrompt.Enabled = not Toggles.AntiDupe.Value
        end
    end
end)
AntiGroup:AddToggle("AntiMandrake", {
    Text = "Avoid Mandrake",
    Default = false,
    Callback = function(Value)
        local Workspace = game:GetService("Workspace")
        local CurrentRooms = Workspace:WaitForChild("CurrentRooms")
        -- Function to destroy MandrakeHole
        local function destroyMandrake(obj)
            if obj.Name == "MandrakeHole" then
                obj:Destroy()
            end
        end
        if Value then
            -- Destroy existing Mandrakes
            for _, v in ipairs(CurrentRooms:GetDescendants()) do
                destroyMandrake(v)
            end
            -- Destroy any new Mandrakes that appear
            CurrentRooms.DescendantAdded:Connect(destroyMandrake)
        end
    end
})


AntiGroup:AddToggle("NoA90", { Text = "Avoid A-90", Default = false, Tooltip = "Disables A-90 entirely." })
AntiGroup:AddToggle("NoA90Damage", { Text = "Avoid A-90 Damage", Default = false, Tooltip = "Prevents A-90 from damaging you." })
AntiGroup:AddToggle("NoScreechDamage", { Text = "Avoid Screech Damage", Default = false, Tooltip = "Prevents Screech from damaging you." })
AntiGroup:AddToggle("NoHaltDamage", { Text = "Avoid Halt Damage", Default = false, Tooltip = "Prevents Halt from damaging you." })


local GeneralNotifying = Tabs.Entities:AddLeftGroupbox("Other Notifications")
GeneralNotifying:AddToggle("PadlockCode", { Text = "Library Padlock Codes", Default = false, Tooltip = "Notifies when padlock codes are found." })
GeneralNotifying:AddSlider("NotificationOffsetX", { Text = "X Position Offset", Default = 0, Min = -1, Max = 1, Rounding = 2, Compact = true })
GeneralNotifying:AddSlider("NotificationOffsetY", { Text = "Y Position Offset", Default = 0, Min = -1, Max = 1, Rounding = 2, Compact = true })
GeneralNotifying:AddSlider("NotificationDPISize", { Text = "Size Multiplier", Default = 1, Min = 0.8, Max = 3, Rounding = 1, Compact = true })
GeneralNotifying:AddButton("Test Alert", function()
    Library:Notify("im gay", 2.5)
end)
local MiscAudio = Tabs.Misc:AddRightGroupbox("Audio Settings")
MiscAudio:AddToggle("SilentJammin", { Text = "Mute Jeff's Shop Music", Default = false, Tooltip = "Silences the music in Jeff's shop.", Callback = function(Value)
    LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game.Health.Jam.Playing = not Value
    game.SoundService.Main.Jamming.Enabled = not Value
end })
MiscAudio:AddToggle("NoHasteSound", { Text = "Mute Haste Ambience", Default = false, Tooltip = "Silences loud sounds when Haste appears." })
MiscAudio:AddToggle("SilentInteracting", { Text = "Mute Interact Sounds", Default = false, Tooltip = "No sound when using prompts.", Callback = function(Value)
    LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game.PromptService.Triggered.Volume = Value and 0 or 0.04
end })
MiscAudio:AddToggle("NoRandomAmbience", { Text = "Mute Random Ambience", Default = false, Tooltip = "Silences random ambient sounds." })

local HotelGroup = Tabs.Misc:AddLeftGroupbox("Doors before hotel +")
HotelGroup:AddButton({
    Text = "Join Hotel Before Plus",
    Tooltip = "Teleports to Hotel Before Plus in Doors",
    Func = function()
        if game.PlaceId == 6516141723 then
            local args = {
                {
                    Mods = {"BeforePlus"},
                    Settings = {},
                    Destination = "Hotel",
                    FriendsOnly = false,
                    MaxPlayers = "1"
                }
            }
            game:GetService("ReplicatedStorage"):WaitForChild("RemotesFolder"):WaitForChild("CreateElevator"):FireServer(unpack(args))
            Library:Notify({
                Title = "Teleport",
                Description = "Joining Hotel Before The Update...",
                Time = 5,
                SoundId = 4590662766
            })
        else
            Library:Notify({
                Title = "Teleport",
                Description = "go to the lobby first",
                Time = 10,
                SoundId = 4590662766
            })
        end
    end
})

local ExploitTroll = Tabs.Misc:AddLeftGroupbox("Trolling")
ExploitTroll:AddToggle("SpamTools", { Text = "Remove Player Tools", Default = false, Tooltip = "Uses up other players' tools by spamming." }):AddKeyPicker("SpamToolsKey", { Default = "G", SyncToggleState = false, Mode = "Hold", Text = "Spam Tools", NoUI = false })
ExploitTroll:AddInput("WhitelistSpamTools", { Default = "", Numeric = false, Finished = true, ClearTextOnFocus = true, Text = "Spam Tools Whitelist", Callback = function(Value)
    
end })
if LocalPlayer.Character:FindFirstChild("CollisionPart") then
    ClonedCollision = LocalPlayer.Character.CollisionPart:Clone()
    ClonedCollision.Name = "_CollisionClone"
    ClonedCollision.Massless = true
    ClonedCollision.Parent = LocalPlayer.Character
    ClonedCollision.CanCollide = false
    ClonedCollision.CanQuery = false
    ClonedCollision.CustomPhysicalProperties = PhysicalProperties.new(0.01, 0.7, 0, 1, 1)
end
task.spawn(function()
    while task.wait(0.23) and not Unloaded do
        if Toggles.SpeedBypass.Value and ClonedCollision then
            ClonedCollision.Massless = false
            task.wait(0.23)
            if LocalPlayer.Character.HumanoidRootPart.Anchored then
                ClonedCollision.Massless = true
                task.wait(1)
            end
            ClonedCollision.Massless = true
        end
    end
end)
local MovementScript = LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game.Movement
local env = getsenv(MovementScript)
local updatespeed = env.updatespeed
local OldUpdateSpeed; OldUpdateSpeed = hookfunction(updatespeed, function(...)
    OldUpdateSpeed(...)
    local Speed = LocalPlayer.Character.Humanoid.WalkSpeed
    if Toggles.WalkspeedModifier.Value then
        Speed = Options.WalkspeedAmount.Value
    end
    LocalPlayer.Character.Humanoid.WalkSpeed = Speed
end)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetFolder("velocityx_configs")
SaveManager:BuildConfigSection(Tabs.UISettings)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("velocityx_themes")
ThemeManager:BuildThemeSection(Tabs.UISettings)
local UISettingsGroup = Tabs.UISettings:AddLeftGroupbox("UI Management")
UISettingsGroup:AddButton("Unload", function()
    for toggleName, toggle in pairs(Toggles) do
        if toggle.Value then
            toggle.Value = false
        end
    end
    for _, conn in pairs(AntiConnections) do
        if conn then
            conn:Disconnect()
        end
    end
    game.Lighting.Brightness = oldBrightness
    game.Lighting.ClockTime = oldClockTime
    game.Lighting.FogEnd = oldFogEnd
    game.Lighting.GlobalShadows = oldGlobalShadows
    game.Lighting.Ambient = oldAmbient
    Unloaded = true
    Library:Unload()
end)
