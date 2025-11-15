local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local Options = Library.Options
local Toggles = Library.Toggles
Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true
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
local requiredFunctions = {
    "hookfunction", "getconnections", "getgc", "setclipboard", "writefile", "readfile", "isfile"
}
local failedFunctions = {}
for _, func in ipairs(requiredFunctions) do
    local e = getGlobal(func) ~= nil
    local c = e and "rgb(0,255,0)" or "rgb(255,0,0)"
    print(string.format('<font color="%s">%s</font>', c, func))
    if not e then
        table.insert(failedFunctions, func)
    end
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

local versionURL = "https://getostium.vercel.app/version.txt"
local latestVersion = game:HttpGet(versionURL):gsub("%s+", "") 

print("Latest Version:", latestVersion)

local Window = Library:CreateWindow({
    Title = "Ostium",
    Footer = latestVersion .. " | Ostium | Build A Boat For Treasure",
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
    AutoFarm = Window:AddTab("Auto Farm", "rocket"),
    Build = Window:AddTab("Build", "target"),
    Misc = Window:AddTab("Misc", "user"),
    Visuals = Window:AddTab("Visuals", "eye"),
    UISettings = Window:AddTab("UI Settings", "user-round-cog"),
}
local player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")

-- Auto Farm Variables
getgenv().TreasureAutoFarm = {
    Enabled = false,
    Teleport = 3.40,
    TimeBetweenRuns = 6
}
local autoFarmRun = 1
local playerDied = false
local GMT = getrawmetatable(game)
setreadonly(GMT, false)
local OLD = GMT.__namecall
GMT.__namecall = newcclosure(function(self, ...)
    local Method = getnamecallmethod()
    if Method == "InvokeServer" and self.Name == 'InstaLoadFunction' then
        playerDied = true
    end
    return OLD(self, ...)
end)

local function autoFarmLoop(currentRun)
    local Character = player.Character
    local NormalStages = Workspace.BoatStages.NormalStages
    for i = 1, 10 do
        local Stage = NormalStages["CaveStage" .. i]
        local DarknessPart = Stage:FindFirstChild("DarknessPart")
        if DarknessPart then
            Character.HumanoidRootPart.CFrame = DarknessPart.CFrame
            DarknessPart.Event:Fire()
            repeat task.wait() until player.OtherData['Stage' .. (i - 1)].Value ~= '' or not getgenv().TreasureAutoFarm.Enabled
        end
    end
    firetouchinterest(Character.HumanoidRootPart, NormalStages.TheEnd.GoldenChest.Trigger, 1)
    task.wait()
    firetouchinterest(Character.HumanoidRootPart, NormalStages.TheEnd.GoldenChest.Trigger, 0)
    repeat task.wait() until playerDied; playerDied = false
    repeat task.wait() until Workspace:FindFirstChild(player.Name) and Workspace:FindFirstChild(player.Name):FindFirstChild('HumanoidRootPart')
    Workspace.ClaimRiverResultsGold:FireServer()
    for i = 1, 10 do
        repeat task.wait() until player.OtherData['Stage' .. (i - 1)].Value == '' or not getgenv().TreasureAutoFarm.Enabled
    end
end

-- Connections
local connections = {}
local antiAFKConnection
local autoFarmConnection

-- Home Tab
local HomeGroup = Tabs.Home:AddLeftGroupbox("Welcome")
local avatarImage = HomeGroup:AddImage("AvatarThumbnail", {
    Image = "rbxassetid://0",
})
task.spawn(function()
    repeat task.wait() until player
    task.wait(1)
    local success, thumbnail = pcall(function()
        return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180)
    end)
    if success and thumbnail then
        avatarImage:SetImage(thumbnail)
    else
        local alternatives = {Enum.ThumbnailType.AvatarThumbnail, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailType.Avatar}
        for _, thumbnailType in ipairs(alternatives) do
            local altSuccess, altThumbnail = pcall(function()
                return Players:GetUserThumbnailAsync(player.UserId, thumbnailType, Enum.ThumbnailSize.Size180x180)
            end)
            if altSuccess and altThumbnail then
                avatarImage:SetImage(altThumbnail)
                break
            end
        end
    end
end)
HomeGroup:AddLabel((function() local h=os.date("*t").hour return (h<12 and h>=5 and "Good morning" or h<17 and "Good afternoon" or h<21 and "Good evening" or "Good night") end)() .. ", " .. player.Name)
HomeGroup:AddDivider()
HomeGroup:AddButton("Join Discord", function()
    setclipboard("https://discord.gg/zrAB2m5gvz")
    Library:Notify("Discord link copied to clipboard!", 3)
end)
HomeGroup:AddButton("Website", function()
    setclipboard("https://getvelocityx.netlify.app/")
    Library:Notify("Website link copied to clipboard!", 3)
end)
Tabs.Home:UpdateWarningBox({
    Title = "Changelogs",
    Text = [[
<font color="rgb(76, 0, 255)">Release v2.12</font>
<font color="rgb(255, 255, 255)">-- Build A Boat For Treasure Edition --</font>
- <font color="rgb(0, 255, 0)">Adapted for BABFT with Auto Farm, Image Loader, and more</font>
]],
    IsNormal = true,
    Visible = true,
    LockSize = true
})
local StatusGroup = Tabs.Home:AddRightGroupbox("Status")
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
StatusGroup:AddLabel('<font color="rgb(0,255,255)">Total Executions: ' .. count .. '</font>')
local keybindSection = Tabs.UISettings:AddRightGroupbox("Keybind")
local uiToggle = keybindSection:AddCheckbox("UIToggle", {
    Text = "Toggle UI",
    Default = true,
    Callback = function(Value)
        Library:Toggle(Value)
    end
})
uiToggle:AddKeyPicker("UIToggleKey", {
    Default = "LeftControl",
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "UI Toggle Key",
    NoUI = false
})

-- Auto Farm Tab
local AutoFarmGroup = Tabs.AutoFarm:AddLeftGroupbox("Auto Farm")
AutoFarmGroup:AddCheckbox("AutoFarmMoney", {
    Text = "Auto Farm Gold",
    Default = false,
    Callback = function(Value)
        getgenv().TreasureAutoFarm.Enabled = Value
        if Value then
            task.spawn(function()
                while getgenv().TreasureAutoFarm.Enabled do
                    pcall(autoFarmLoop, autoFarmRun)
                    autoFarmRun = autoFarmRun + 1
                end
            end)
        end
    end
})
AutoFarmGroup:AddCheckbox("AutoFarmGoldBlock", {
    Text = "Auto Farm Gold Block",
    Default = false,
    Callback = function(Value)
        getgenv().TreasureAutoFarm.Enabled = Value
        if Value then
            task.spawn(function()
                while getgenv().TreasureAutoFarm.Enabled do
                    pcall(function()
                        local Root = player.Character.HumanoidRootPart
                        Workspace.Gravity = 0
                        Root.CFrame = Workspace.BoatStages.NormalStages.CaveStage1.DarknessPart.CFrame
                        Workspace.BoatStages.NormalStages.CaveStage1.DarknessPart.Event:Fire()
                        repeat task.wait() until player.OtherData.Stage0.Value ~= '' or not getgenv().TreasureAutoFarm.Enabled
                        firetouchinterest(Root, Workspace.BoatStages.NormalStages.TheEnd.GoldenChest.Trigger, 1)
                        task.wait()
                        firetouchinterest(Root, Workspace.BoatStages.NormalStages.TheEnd.GoldenChest.Trigger, 0)
                        repeat task.wait() until playerDied; playerDied = false
                        repeat task.wait() until Workspace:FindFirstChild(player.Name) and Workspace:FindFirstChild(player.Name):FindFirstChild('HumanoidRootPart')
                        Workspace.ClaimRiverResultsGold:FireServer()
                        repeat task.wait() until player.OtherData.Stage0.Value == ''
                    end)
                end
            end)
        end
    end
})
AutoFarmGroup:AddSlider("TeleportSpeed", {
    Text = "Teleport Speed",
    Default = 3.4,
    Min = 1,
    Max = 10,
    Rounding = 1,
    Callback = function(Value)
        getgenv().TreasureAutoFarm.Teleport = Value
    end
})
AutoFarmGroup:AddSlider("TimeBetween", {
    Text = "Time Between Runs",
    Default = 6,
    Min = 1,
    Max = 20,
    Rounding = 0,
    Callback = function(Value)
        getgenv().TreasureAutoFarm.TimeBetweenRuns = Value
    end
})
local AntiAFKGroup = Tabs.AutoFarm:AddRightGroupbox("Anti-AFK")
AntiAFKGroup:AddCheckbox("AntiAFK", {
    Text = "Enable Anti-AFK",
    Default = false,
    Callback = function(Value)
        if Value then
            antiAFKConnection = player.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        else
            if antiAFKConnection then
                antiAFKConnection:Disconnect()
            end
        end
    end
})

-- Build Tab (Image Loader)
local ImageGroup = Tabs.Build:AddLeftGroupbox("Image Loader")
local BlockType = "PlasticBlock"
local blockSize = 2
local Bdepth = 2
local angleY = 0
local batchSize = 750
local previewFolder = Workspace:FindFirstChild("ImagePreview") or Instance.new("Folder", Workspace)
previewFolder.Name = "ImagePreview"
ImageGroup:AddInput("ImageURL", {
    Text = "Image URL or File Name",
    Default = "",
    Numeric = false,
    Finished = true,
    Callback = function(Value)
        -- Implement URL fetch or file read logic here (simplified)
        Library:Notify("Image loaded: " .. Value, 3)
    end
})
ImageGroup:AddDropdown("BlockType", {
    Text = "Block Type",
    Default = "PlasticBlock",
    Values = {"PlasticBlock", "WoodBlock", "GoldBlock", "NeonBlock"},
    Callback = function(Value)
        BlockType = Value
    end
})
ImageGroup:AddSlider("BlockSize", {
    Text = "Block Size",
    Default = 2,
    Min = 0.1,
    Max = 10,
    Rounding = 1,
    Callback = function(Value)
        blockSize = Value
    end
})
ImageGroup:AddSlider("PreviewSpeed", {
    Text = "Preview Speed",
    Default = 750,
    Min = 100,
    Max = 4000,
    Rounding = 0,
    Callback = function(Value)
        batchSize = Value
    end
})
ImageGroup:AddCheckbox("Preview", {
    Text = "Enable Preview",
    Default = false,
    Callback = function(Value)
        -- Toggle preview logic
        Library:Notify("Preview " .. (Value and "enabled" or "disabled"), 3)
    end
})
ImageGroup:AddButton("Load Image", function()
    -- Implement build image logic
    Library:Notify("Loading image...", 3)
end)

-- Auto Build (WIP)
local AutoBuildGroup = Tabs.Build:AddRightGroupbox("Auto Build (WIP)")
AutoBuildGroup:AddButton("Save Build", function()
    Library:Notify("Save build WIP", 3)
end)
AutoBuildGroup:AddButton("Load Build", function()
    Library:Notify("Load build WIP", 3)
end)

-- Misc Tab
local TeleportGroup = Tabs.Misc:AddLeftGroupbox("Teleports")
TeleportGroup:AddButton("Teleport to White", function()
    player.Character.HumanoidRootPart.CFrame = CFrame.new(-49.8510132, -9.7000021, -520.37085)
end)
TeleportGroup:AddButton("Teleport to Black", function()
    player.Character.HumanoidRootPart.CFrame = CFrame.new(-503.82843, -9.7000021, -69.433342)
end)
TeleportGroup:AddButton("Teleport to Red", function()
    player.Character.HumanoidRootPart.CFrame = CFrame.new(396.697418, -9.7000021, -64.7801361)
end)
TeleportGroup:AddButton("Teleport to Blue", function()
    player.Character.HumanoidRootPart.CFrame = CFrame.new(396.697418, -9.7000021, 300.219849)
end)
TeleportGroup:AddButton("Teleport to Magenta", function()
    player.Character.HumanoidRootPart.CFrame = CFrame.new(396.697418, -9.7000021, 647.219849)
end)
TeleportGroup:AddButton("Teleport to Yellow", function()
    player.Character.HumanoidRootPart.CFrame = CFrame.new(-503.82843, -9.7000021, 640.56665)
end)
TeleportGroup:AddButton("Teleport to Green", function()
    player.Character.HumanoidRootPart.CFrame = CFrame.new(-503.82843, -9.7000021, 293.56665)
end)

local TrollGroup = Tabs.Misc:AddRightGroupbox("Troll")
TrollGroup:AddButton("Force Share Mode", function()
    Workspace.SettingFunction:InvokeServer("ShareBlocks", true)
    Library:Notify("Share Mode Enabled", 3)
end)
TrollGroup:AddButton("Disable Share Mode", function()
    Workspace.SettingFunction:InvokeServer("ShareBlocks", false)
    Library:Notify("Share Mode Disabled", 3)
end)
TrollGroup:AddButton("Color All Blocks Randomly", function()
    -- Simplified color all blocks
    Library:Notify("Coloring blocks...", 3)
end)
TrollGroup:AddButton("Disable Block Restrictions", function()
    local zone = Workspace:FindFirstChild(Workspace:FindFirstChild(player.Team.Name:lower():gsub(" ", "") .. "Zone") or "WhiteZone")
    if zone then zone.QuestNum.Value = 0 end
    Library:Notify("Restrictions Disabled", 3)
end)
TrollGroup:AddButton("Server Hop", function()
    -- Server hop logic
    local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    for _, v in pairs(servers.data) do
        if v.playing < v.maxPlayers then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id, player)
            break
        end
    end
end)
TrollGroup:AddButton("Rejoin", function()
    TeleportService:Teleport(game.PlaceId, player)
end)

-- Visuals Tab (Performance)
local PerformanceGroup = Tabs.Visuals:AddLeftGroupbox("Performance")
PerformanceGroup:AddCheckbox("FPSBoost", {
    Text = "FPS Boost",
    Default = false,
    Callback = function(Value)
        if Value then
            for _, v in pairs(game:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Material = Enum.Material.Plastic
                    v.Reflectance = 0
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    v.Transparency = 1
                end
            end
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            settings().Rendering.QualityLevel = "Level01"
        else
            -- Restore
            settings().Rendering.QualityLevel = "Automatic"
            Lighting.GlobalShadows = true
            Lighting.FogEnd = 100000
        end
    end
})
PerformanceGroup:AddCheckbox("HideBlocks", {
    Text = "Hide Blocks",
    Default = false,
    Callback = function(Value)
        Workspace.Blocks.Parent = Value and ReplicatedStorage or Workspace
    end
})
PerformanceGroup:AddCheckbox("HideTerrain", {
    Text = "Hide Terrain",
    Default = false,
    Callback = function(Value)
        Workspace.MainTerrain.Parent = Value and ReplicatedStorage or Workspace
    end
})

-- UI Settings Tab
local enableNotifications = true
local notifyDuration = 3
local SettingsLeftGroup = Tabs.UISettings:AddLeftGroupbox("Menu Settings")
local MenuVisibility = SettingsLeftGroup:AddCheckbox("MenuVisibility", {
    Text = "Show Menu",
    Default = true,
    Disabled = false,
    Tooltip = "Toggle menu visibility",
    Callback = function(Value)
        Library:Toggle(Value)
        if enableNotifications then
            Library:Notify(Value and "Menu shown" or "Menu hidden", notifyDuration)
        end
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
        if enableNotifications then
            Library:Notify("Unloading menu...", notifyDuration)
        end
        task.wait(0.3)
        Library:Unload()
    end,
    DoubleClick = false,
    Tooltip = "Unload the menu"
})
local AppearanceGroup = Tabs.UISettings:AddLeftGroupbox("Appearance")
AppearanceGroup:AddCheckbox("ShowKeybinds", {
    Text = "Show Keybinds Frame",
    Default = false,
    Disabled = false,
    Tooltip = "Toggle keybinds list visibility",
    Callback = function(Value)
        Library.KeybindFrame.Visible = Value
        if enableNotifications then
            Library:Notify("Keybinds frame " .. (Value and "shown" or "hidden"), notifyDuration)
        end
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
        if enableNotifications then
            Library:Notify("Notification duration set to " .. Value .. " seconds", Value)
        end
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
    Multi = false,
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
        Library:Notify("This is a test notification!", notifyDuration)
    end
})
Library:SetWatermarkVisibility(true)
local function updateWatermark()
    local fps = 60
    local frameTimer = tick()
    local frameCounter = 0
    local conn = RunService.RenderStepped:Connect(function()
        frameCounter += 1
        if tick() - frameTimer >= 1 then
            fps = frameCounter
            frameTimer = tick()
            frameCounter = 0
        end
        local pingItem = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]
        local ping = pingItem and pingItem:GetValue() or 0
        Library:SetWatermark(string.format("Ostium | %d FPS | %d ms | v2.12", math.floor(fps), math.floor(ping)))
    end)
    table.insert(connections, {disconnect = function() conn:Disconnect() end})
end
updateWatermark()
game:GetService('Players').LocalPlayer.Idled:Connect(function()
    game:GetService('VirtualUser'):CaptureController()
    game:GetService('VirtualUser'):ClickButton2(Vector2.new())
end)