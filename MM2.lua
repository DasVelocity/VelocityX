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
print_colored(ascii, "green")
print("\nChecking required functions...\n")
print_colored("Script Loaded", "green")
local versionURL = "https://getostium.vercel.app/version.txt"
local latestVersion = game:HttpGet(versionURL):gsub("%s+", "")
print("Latest Version:", latestVersion)
local Window = Library:CreateWindow({
    Title = "Ostium",
    Footer = latestVersion .. " | Ostium | MM2",
    Icon = 117198211193045,
    NotifySide = "Right",
    ShowCustomCursor = false,
    EnableSidebarResize = true,
    SidebarMinWidth = 200,
    SidebarCompactWidth = 56,
    SidebarCollapseThreshold = 0.45,
})
local Tabs = {
    Home = Window:AddTab("Home", "house"),
    Combat = Window:AddTab("Combat", "sword"),
    Utilities = Window:AddTab("Utilities", "wrench"),
    Settings = Window:AddTab("Settings", "cog"),
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
local function UpdateRoles()
    local rolesData = ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
    local Murder, Sheriff, Hero = nil, nil, nil
    for name, data in pairs(rolesData) do
        if (data.Role == "Murderer") then
            Murder = name
        elseif (data.Role == "Sheriff") then
            Sheriff = name
        elseif (data.Role == "Hero") then
            Hero = name
        end
    end
    return rolesData, Murder, Sheriff, Hero
end
local connections = {}
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
    setclipboard("https://discord.gg/9UuswyPTDE")
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
<font color="rgb(255, 255, 255)">-- MM2 Edition --</font>
- <font color="rgb(0, 255, 0)">Adapted from Arsenal with full MM2 features</font>
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
local CharacterSettings = {
    WalkSpeed = {Value = 16, Default = 16, Locked = false},
    JumpPower = {Value = 50, Default = 50, Locked = false}
}
local function updateCharacter()
    local character = player.Character
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        if not CharacterSettings.WalkSpeed.Locked then
            humanoid.WalkSpeed = CharacterSettings.WalkSpeed.Value
        end
        if not CharacterSettings.JumpPower.Locked then
            humanoid.JumpPower = CharacterSettings.JumpPower.Value
        end
    end
end
local Murder, Sheriff, Hero
local roles = {}
local gunDropESPEnabled = false
local mapPaths = {
    "ResearchFacility",
    "Hospital3",
    "MilBase",
    "House2",
    "Workplace",
    "Mansion2",
    "BioLab",
    "Hotel",
    "Factory",
    "Bank2",
    "PoliceStation"
}
local teleportTarget = nil
local function updateTeleportPlayers()
    local playersList = {"Select Player"}
    for _, plr in pairs(Players:GetPlayers()) do
        if (plr ~= player) then
            table.insert(playersList, plr.Name)
        end
    end
    return playersList
end
local teleportDropdown
local function initializeTeleportDropdown(group)
    teleportDropdown = group:AddDropdown("TeleportPlayers", {
        Text = "Players",
        Default = "Select Player",
        Values = updateTeleportPlayers(),
        Callback = function(selected)
            if (selected ~= "Select Player") then
                teleportTarget = Players:FindFirstChild(selected)
            else
                teleportTarget = nil
            end
        end
    })
end
Players.PlayerAdded:Connect(function(plr)
    task.wait(1)
    if teleportDropdown then
        teleportDropdown:Refresh(updateTeleportPlayers())
    end
end)
Players.PlayerRemoving:Connect(function(plr)
    if teleportDropdown then
        teleportDropdown:Refresh(updateTeleportPlayers())
    end
end)
local function teleportToPlayer()
    if (teleportTarget and teleportTarget.Character) then
        local targetRoot = teleportTarget.Character:FindFirstChild("HumanoidRootPart")
        local localRoot = player.Character:FindFirstChild("HumanoidRootPart")
        if (targetRoot and localRoot) then
            localRoot.CFrame = targetRoot.CFrame
            Library:Notify("Successfully teleported to " .. teleportTarget.Name, 3)
        end
    else
        Library:Notify("Target not found or unavailable", 3)
    end
end
local isCameraLocked = false
local isSpectating = false
local lockedRole = nil
local cameraConnection = nil
local originalCameraType = Enum.CameraType.Custom
local originalCameraSubject = nil
local function GetTargetPosition()
    if not lockedRole then
        return nil
    end
    local targetName = ((lockedRole == "Sheriff") and Sheriff) or Murder
    if not targetName then
        return nil
    end
    local plr = Players:FindFirstChild(targetName)
    if (not plr) then
        return nil
    end
    local character = plr.Character
    if not character then
        return nil
    end
    local head = character:FindFirstChild("Head")
    return (head and head.Position) or nil
end
local function UpdateSpectate()
    if (not isSpectating or not lockedRole) then
        return
    end
    local targetPos = GetTargetPosition()
    if not targetPos then
        return
    end
    local offset = CFrame.new(0, 2, 8)
    local targetChar = Players:FindFirstChild(((lockedRole == "Sheriff") and Sheriff) or Murder).Character
    if targetChar then
        local root = targetChar:FindFirstChild("HumanoidRootPart")
        if root then
            Workspace.CurrentCamera.CFrame = root.CFrame * offset
        end
    end
end
local function UpdateLockCamera()
    if (not isCameraLocked or not lockedRole) then
        return
    end
    local targetPos = GetTargetPosition()
    if not targetPos then
        return
    end
    local currentPos = Workspace.CurrentCamera.CFrame.Position
    Workspace.CurrentCamera.CFrame = CFrame.new(currentPos, targetPos)
end
local function Update()
    if isSpectating then
        UpdateSpectate()
    elseif isCameraLocked then
        UpdateLockCamera()
    end
end
local function AutoUpdate()
    while true do
        local rolesData, m, s, h = UpdateRoles()
        roles = rolesData
        Murder, Sheriff, Hero = m, s, h
        task.wait(3)
    end
end
coroutine.wrap(AutoUpdate)()
cameraConnection = RunService.RenderStepped:Connect(Update)
player.AncestryChanged:Connect(
    function()
        if (not player.Parent and cameraConnection) then
            cameraConnection:Disconnect()
            Workspace.CurrentCamera.CameraType = originalCameraType
            Workspace.CurrentCamera.CameraSubject = originalCameraSubject
        end
    end
)
UpdateRoles()
local AutoFarm = {
    Enabled = false,
    Mode = "Teleport",
    TeleportDelay = 0,
    MoveSpeed = 50,
    WalkSpeed = 32,
    Connection = nil,
    CoinCheckInterval = 0.5,
    CoinContainers = {
        "Factory",
        "Hospital3",
        "MilBase",
        "House2",
        "Workplace",
        "Mansion2",
        "BioLab",
        "Hotel",
        "Bank2",
        "PoliceStation",
        "ResearchFacility",
        "Lobby"
    }
}
local function findNearestCoin()
    local closestCoin = nil
    local shortestDistance = math.huge
    local character = player.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        return nil
    end
    for _, containerName in ipairs(AutoFarm.CoinContainers) do
        local container = workspace:FindFirstChild(containerName)
        if container then
            local coinContainer =
                ((containerName == "Lobby") and container) or container:FindFirstChild("CoinContainer")
            if coinContainer then
                for _, coin in ipairs(coinContainer:GetChildren()) do
                    if coin:IsA("BasePart") then
                        local distance = (humanoidRootPart.Position - coin.Position).Magnitude
                        if (distance < shortestDistance) then
                            shortestDistance = distance
                            closestCoin = coin
                        end
                    end
                end
            end
        end
    end
    return closestCoin
end
local function teleportToCoin(coin)
    if (not coin or not player.Character) then
        return
    end
    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        return
    end
    humanoidRootPart.CFrame = CFrame.new(coin.Position + Vector3.new(0, 3, 0))
    task.wait(AutoFarm.TeleportDelay)
end
local function smoothMoveToCoin(coin)
    if (not coin or not player.Character) then
        return
    end
    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        return
    end
    local startTime = tick()
    local startPos = humanoidRootPart.Position
    local endPos = coin.Position + Vector3.new(0, 3, 0)
    local distance = (startPos - endPos).Magnitude
    local duration = distance / AutoFarm.MoveSpeed
    while ((tick() - startTime) < duration) and AutoFarm.Enabled do
        if (not coin or not coin.Parent) then
            break
        end
        local progress = math.min((tick() - startTime) / duration, 1)
        humanoidRootPart.CFrame = CFrame.new(startPos:Lerp(endPos, progress))
        task.wait()
    end
end
local function walkToCoin(coin)
    if (not coin or not player.Character) then
        return
    end
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return
    end
    humanoid.WalkSpeed = AutoFarm.WalkSpeed
    humanoid:MoveTo(coin.Position + Vector3.new(0, 0, 3))
    local startTime = tick()
    while AutoFarm.Enabled and (humanoid.MoveDirection.Magnitude > 0) and ((tick() - startTime) < 10) do
        task.wait(0.5)
    end
end
local function collectCoin(coin)
    if (not coin or not player.Character) then
        return
    end
    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        return
    end
    firetouchinterest(humanoidRootPart, coin, 0)
    firetouchinterest(humanoidRootPart, coin, 1)
end
local function farmLoop()
    while AutoFarm.Enabled do
        local coin = findNearestCoin()
        if coin then
            if (AutoFarm.Mode == "Teleport") then
                teleportToCoin(coin)
            elseif (AutoFarm.Mode == "Smooth") then
                smoothMoveToCoin(coin)
            else
                walkToCoin(coin)
            end
            collectCoin(coin)
        else
            Library:Notify("No coins found nearby!", 2)
            task.wait(2)
        end
        task.wait(AutoFarm.CoinCheckInterval)
    end
end
local GunSystem = {
    AutoGrabEnabled = false,
    NotifyGunDrop = true,
    GunDropCheckInterval = 1,
    ActiveGunDrops = {},
    GunDropHighlights = {}
}
local function TeleportToMurderer(murderer)
    local targetRoot = murderer.Character:FindFirstChild("HumanoidRootPart")
    local localRoot = player.Character:FindFirstChild("HumanoidRootPart")
    if (targetRoot and localRoot) then
        localRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -5)
        task.wait(0.3)
        return true
    end
    return false
end
local function ScanForGunDrops()
    GunSystem.ActiveGunDrops = {}
    for _, mapName in ipairs(mapPaths) do
        local map = workspace:FindFirstChild(mapName)
        if map then
            local gunDrop = map:FindFirstChild("GunDrop")
            if gunDrop then
                table.insert(GunSystem.ActiveGunDrops, gunDrop)
            end
        end
    end
    local rootGunDrop = workspace:FindFirstChild("GunDrop")
    if rootGunDrop then
        table.insert(GunSystem.ActiveGunDrops, rootGunDrop)
    end
end
local function EquipGun()
    if (player.Character and player.Character:FindFirstChild("Gun")) then
        return true
    end
    local gun = player.Backpack:FindFirstChild("Gun")
    if gun then
        gun.Parent = player.Character
        task.wait(0.1)
        return player.Character:FindFirstChild("Gun") ~= nil
    end
    return false
end
local function GrabGun(gunDrop)
    if not gunDrop then
        ScanForGunDrops()
        if (#GunSystem.ActiveGunDrops == 0) then
            Library:Notify("No guns available on the map", 3)
            return false
        end
        local nearestGun = nil
        local minDistance = math.huge
        local character = player.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            for _, drop in ipairs(GunSystem.ActiveGunDrops) do
                local distance = (humanoidRootPart.Position - drop.Position).Magnitude
                if (distance < minDistance) then
                    nearestGun = drop
                    minDistance = distance
                end
            end
        end
        gunDrop = nearestGun
    end
    if (gunDrop and player.Character) then
        local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CFrame = gunDrop.CFrame
            task.wait(0.3)
            local prompt = gunDrop:FindFirstChildOfClass("ProximityPrompt")
            if prompt then
                fireproximityprompt(prompt)
                Library:Notify("Successfully grabbed the gun!", 3)
                return true
            end
        end
    end
    return false
end
local function AutoGrabGun()
    while GunSystem.AutoGrabEnabled do
        ScanForGunDrops()
        if ((#GunSystem.ActiveGunDrops > 0) and player.Character) then
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local nearestGun = nil
                local minDistance = math.huge
                for _, gunDrop in ipairs(GunSystem.ActiveGunDrops) do
                    local distance = (humanoidRootPart.Position - gunDrop.Position).Magnitude
                    if (distance < minDistance) then
                        nearestGun = gunDrop
                        minDistance = distance
                    end
                end
                if nearestGun then
                    humanoidRootPart.CFrame = nearestGun.CFrame
                    task.wait(0.3)
                    local prompt = nearestGun:FindFirstChildOfClass("ProximityPrompt")
                    if prompt then
                        fireproximityprompt(prompt)
                        task.wait(1)
                    end
                end
            end
        end
        task.wait(GunSystem.GunDropCheckInterval)
    end
end
local function GetMurderer()
    local rolesData = ReplicatedStorage:FindFirstChild("GetPlayerData"):InvokeServer()
    for playerName, data in pairs(rolesData) do
        if (data.Role == "Murderer") then
            return Players:FindFirstChild(playerName)
        end
    end
end
local function GrabAndShootMurderer()
    if not (player.Character and player.Character:FindFirstChild("Gun")) then
        if not GrabGun() then
            Library:Notify("Failed to get gun!", 3)
            return
        end
        task.wait(0.1)
    end
    if not EquipGun() then
        Library:Notify("Failed to equip gun!", 3)
        return
    end
    local rolesData = ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
    local murderer = nil
    for name, data in pairs(rolesData) do
        if (data.Role == "Murderer") then
            murderer = Players:FindFirstChild(name)
            break
        end
    end
    if (not murderer or not murderer.Character) then
        Library:Notify("Murderer not found!", 3)
        return
    end
    local targetRoot = murderer.Character:FindFirstChild("HumanoidRootPart")
    local localRoot = player.Character:FindFirstChild("HumanoidRootPart")
    if (targetRoot and localRoot) then
        localRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -4)
        task.wait(0.1)
    end
    local gun = player.Character:FindFirstChild("Gun")
    if not gun then
        Library:Notify("Gun not equipped!", 3)
        return
    end
    local targetPart = murderer.Character:FindFirstChild("HumanoidRootPart")
    if not targetPart then
        return
    end
    local args = {[1] = 1, [2] = targetPart.Position, [3] = "AH2"}
    if (gun:FindFirstChild("KnifeLocal") and gun.KnifeLocal:FindFirstChild("CreateBeam")) then
        gun.KnifeLocal.CreateBeam.RemoteFunction:InvokeServer(unpack(args))
        Library:Notify("Successfully shot the murderer!", 3)
    end
end
local gunDropESPEnabled = true
local notifiedGunDrops = {}
local function checkForGunDrops()
    for _, mapName in ipairs(mapPaths) do
        local map = workspace:FindFirstChild(mapName)
        if map then
            local gunDrop = map:FindFirstChild("GunDrop")
            if (gunDrop and not notifiedGunDrops[gunDrop]) then
                if gunDropESPEnabled then
                    Library:Notify("A gun has appeared on the map: " .. mapName, 5)
                end
                notifiedGunDrops[gunDrop] = true
            end
        end
    end
end
local function setupGunDropMonitoring()
    for _, mapName in ipairs(mapPaths) do
        local map = workspace:FindFirstChild(mapName)
        if map then
            if map:FindFirstChild("GunDrop") then
                checkForGunDrops()
            end
            map.ChildAdded:Connect(
                function(child)
                    if (child.Name == "GunDrop") then
                        task.wait(0.5)
                        checkForGunDrops()
                    end
                end
            )
        end
    end
end
local function setupGunDropRemovalTracking()
    for _, mapName in ipairs(mapPaths) do
        local map = workspace:FindFirstChild(mapName)
        if map then
            map.ChildRemoved:Connect(
                function(child)
                    if ((child.Name == "GunDrop") and notifiedGunDrops[child]) then
                        notifiedGunDrops[child] = nil
                    end
                end
            )
        end
    end
end
setupGunDropMonitoring()
setupGunDropRemovalTracking()
workspace.ChildAdded:Connect(
    function(child)
        if table.find(mapPaths, child.Name) then
            task.wait(2)
            checkForGunDrops()
        end
    end
)
local killActive = false
local attackDelay = 0.5
local targetRoles = {"Sheriff", "Hero", "Innocent"}
local function getPlayerRole(plr)
    if (roles and roles[plr.Name]) then
        return roles[plr.Name].Role
    end
    return nil
end
local function equipKnife()
    local character = player.Character
    if not character then
        return false
    end
    if character:FindFirstChild("Knife") then
        return true
    end
    local knife = player.Backpack:FindFirstChild("Knife")
    if knife then
        knife.Parent = character
        return true
    end
    return false
end
local function getNearestTarget()
    local targets = {}
    local localRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then
        return nil
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if ((plr ~= player) and plr.Character) then
            local role = getPlayerRole(plr)
            local humanoid = plr.Character:FindFirstChild("Humanoid")
            local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart")
            if (role and humanoid and (humanoid.Health > 0) and targetRoot and table.find(targetRoles, role)) then
                table.insert(
                    targets,
                    {Player = plr, Distance = (localRoot.Position - targetRoot.Position).Magnitude}
                )
            end
        end
    end
    table.sort(
        targets,
        function(a, b)
            return a.Distance < b.Distance
        end
    )
    return (targets[1] and targets[1].Player) or nil
end
local function attackTarget(target)
    if (not target or not target.Character) then
        return false
    end
    local humanoid = target.Character:FindFirstChild("Humanoid")
    if (not humanoid or (humanoid.Health <= 0)) then
        return false
    end
    if not equipKnife() then
        Library:Notify("No knife found!", 2)
        return false
    end
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    local localRoot = player.Character:FindFirstChild("HumanoidRootPart")
    if (targetRoot and localRoot) then
        localRoot.CFrame =
            CFrame.new(
            targetRoot.Position + ((localRoot.Position - targetRoot.Position).Unit * 2),
            targetRoot.Position
        )
    end
    local knife = player.Character:FindFirstChild("Knife")
    if (knife and knife:FindFirstChild("Stab")) then
        for i = 1, 3 do
            knife.Stab:FireServer("Down")
        end
        return true
    end
    return false
end
local function killTargets()
    if killActive then
        return
    end
    killActive = true
    Library:Notify("Starting attack on nearest targets...", 2)
    local function attackSequence()
        while killActive do
            local target = getNearestTarget()
            if not target then
                Library:Notify("No valid targets found!", 3)
                killActive = false
                break
            end
            if attackTarget(target) then
                Library:Notify("Attacked " .. target.Name, 1)
            end
            task.wait(attackDelay)
        end
    end
    task.spawn(attackSequence)
end
local function stopKilling()
    killActive = false
    Library:Notify("Attack sequence stopped", 2)
end
local shotButton = nil
local shotButtonFrame = nil
local shotButtonActive = false
local shotType = "Default"
local buttonSize = 50
local isDragging = false
local function CreateShotButton()
    if shotButton then
        return
    end
    local screenGui = game:GetService("CoreGui"):FindFirstChild("Ostium_SheriffGui") or Instance.new("ScreenGui")
    screenGui.Name = "Ostium_SheriffGui"
    screenGui.Parent = game:GetService("CoreGui")
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 999
    screenGui.IgnoreGuiInset = true
    shotButtonFrame = Instance.new("Frame")
    shotButtonFrame.Name = "ShotButtonFrame"
    shotButtonFrame.Size = UDim2.new(0, buttonSize, 0, buttonSize)
    shotButtonFrame.Position = UDim2.new(1, -buttonSize - 20, 0.5, -buttonSize / 2)
    shotButtonFrame.AnchorPoint = Vector2.new(1, 0.5)
    shotButtonFrame.BackgroundTransparency = 1
    shotButtonFrame.ZIndex = 100
    shotButton = Instance.new("TextButton")
    shotButton.Name = "SheriffShotButton"
    shotButton.Size = UDim2.new(1, 0, 1, 0)
    shotButton.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
    shotButton.BackgroundTransparency = 0.5
    shotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    shotButton.Text = "SHOT"
    shotButton.TextSize = 14
    shotButton.Font = Enum.Font.GothamBold
    shotButton.BorderSizePixel = 0
    shotButton.ZIndex = 101
    shotButton.AutoButtonColor = false
    shotButton.TextScaled = true
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 40, 150)
    stroke.Thickness = 2
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Transparency = 0.3
    stroke.Parent = shotButton
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.3, 0)
    corner.Parent = shotButton
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.85
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.ZIndex = 100
    shadow.Parent = shotButton
    local function animatePress()
        local tweenService = game:GetService("TweenService")
        local pressDown = tweenService:Create(shotButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0.9, 0, 0.9, 0), BackgroundColor3 = Color3.fromRGB(70, 70, 70), TextColor3 = Color3.fromRGB(200, 200, 255)})
        local pressUp = tweenService:Create(shotButton, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(100, 100, 100), TextColor3 = Color3.fromRGB(255, 255, 255)})
        pressDown:Play()
        pressDown.Completed:Wait()
        pressUp:Play()
    end
    shotButton.MouseButton1Click:Connect(function()
        animatePress()
        if (not player.Character or not player.Character:FindFirstChild("Humanoid") or (player.Character.Humanoid.Health <= 0)) then return end
        local success, rolesData = pcall(function() return ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer() end)
        if (not success or not rolesData) then return end
        local murderer = nil
        for name, data in pairs(rolesData) do
            if (data.Role == "Murderer") then
                murderer = Players:FindFirstChild(name)
                break
            end
        end
        if (not murderer or not murderer.Character or not murderer.Character:FindFirstChild("Humanoid") or (murderer.Character.Humanoid.Health <= 0)) then return end
        local gun = player.Character:FindFirstChild("Gun") or player.Backpack:FindFirstChild("Gun")
        if ((shotType == "Default") and not gun) then return end
        if (gun and not player.Character:FindFirstChild("Gun")) then gun.Parent = player.Character end
        if (shotType == "Teleport") then
            local targetRoot = murderer.Character:FindFirstChild("HumanoidRootPart")
            local localRoot = player.Character:FindFirstChild("HumanoidRootPart")
            if (targetRoot and localRoot) then
                localRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -4)
            end
        end
        if (gun and not player.Character:FindFirstChild("Gun")) then gun.Parent = player.Character end
        gun = player.Character:FindFirstChild("Gun")
        if (gun and gun:FindFirstChild("KnifeLocal")) then
            local targetPart = murderer.Character:FindFirstChild("HumanoidRootPart")
            if targetPart then
                local args = {[1] = 10, [2] = targetPart.Position, [3] = "AH2"}
                gun.KnifeLocal.CreateBeam.RemoteFunction:InvokeServer(unpack(args))
            end
        end
    end)
    local dragInput
    local dragStart
    local startPos
    local function updateInput(input)
        local delta = input.Position - dragStart
        local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        local guiSize = game:GetService("CoreGui").AbsoluteSize
        newPos = UDim2.new(math.clamp(newPos.X.Scale, 0, 1), math.clamp(newPos.X.Offset, 0, guiSize.X - buttonSize), math.clamp(newPos.Y.Scale, 0, 1), math.clamp(newPos.Y.Offset, 0, guiSize.Y - buttonSize))
        shotButtonFrame.Position = newPos
    end
    shotButton.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1) then
            isDragging = true
            dragStart = input.Position
            startPos = shotButtonFrame.Position
            animatePress()
            input.Changed:Connect(function()
                if (input.UserInputState == Enum.UserInputState.End) then
                    isDragging = false
                end
            end)
        end
    end)
    shotButton.InputChanged:Connect(function(input)
        if ((input.UserInputType == Enum.UserInputType.MouseMovement) and isDragging) then
            updateInput(input)
        end
    end)
    shotButton.Parent = shotButtonFrame
    shotButtonFrame.Parent = screenGui
    shotButtonActive = true
    Library:Notify("Shot button activated", 3)
end
local function RemoveShotButton()
    if not shotButton then return end
    if shotButton then shotButton:Destroy() shotButton = nil end
    if shotButtonFrame then shotButtonFrame:Destroy() shotButtonFrame = nil end
    local screenGui = game:GetService("CoreGui"):FindFirstChild("Ostium_SheriffGui")
    if screenGui then screenGui:Destroy() end
    shotButtonActive = false
    Library:Notify("Deactivated", 3)
end
local function ShootMurderer()
    if (not player.Character or not player.Character:FindFirstChild("Humanoid") or (player.Character.Humanoid.Health <= 0)) then return end
    local success, rolesData = pcall(function() return ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer() end)
    if (not success or not rolesData) then return end
    local murderer = nil
    for name, data in pairs(rolesData) do
        if (data.Role == "Murderer") then
            murderer = Players:FindFirstChild(name)
            break
        end
    end
    if (not murderer or not murderer.Character or not murderer.Character:FindFirstChild("Humanoid") or (murderer.Character.Humanoid.Health <= 0)) then return end
    local gun = player.Character:FindFirstChild("Gun") or player.Backpack:FindFirstChild("Gun")
    if ((shotType == "Default") and not gun) then return end
    if (gun and not player.Character:FindFirstChild("Gun")) then gun.Parent = player.Character end
    if (shotType == "Teleport") then
        local targetRoot = murderer.Character:FindFirstChild("HumanoidRootPart")
        local localRoot = player.Character:FindFirstChild("HumanoidRootPart")
        if (targetRoot and localRoot) then
            localRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -4)
        end
    end
    if (gun and not player.Character:FindFirstChild("Gun")) then gun.Parent = player.Character end
    gun = player.Character:FindFirstChild("Gun")
    if (gun and gun:FindFirstChild("KnifeLocal")) then
        local targetPart = murderer.Character:FindFirstChild("HumanoidRootPart")
        if targetPart then
            local args = {[1] = 1, [2] = targetPart.Position, [3] = "AH2"}
            gun.KnifeLocal.CreateBeam.RemoteFunction:InvokeServer(unpack(args))
        end
    end
end
local Settings = {
    Hitbox = {Enabled = false, Size = 5, Color = Color3.new(1, 0, 0), Adornments = {}, Connections = {}},
    Noclip = {Enabled = false, Connection = nil},
    AntiAFK = {Enabled = false, Connection = nil}
}
local function ToggleNoclip(state)
    if state then
        Settings.Noclip.Connection = RunService.Stepped:Connect(function()
            local chr = player.Character
            if chr then
                for _, part in pairs(chr:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    elseif Settings.Noclip.Connection then
        Settings.Noclip.Connection:Disconnect()
    end
end
local function UpdateHitboxes()
    for _, plr in pairs(Players:GetPlayers()) do
        if (plr ~= player) then
            local chr = plr.Character
            local box = Settings.Hitbox.Adornments[plr]
            if (chr and Settings.Hitbox.Enabled) then
                local root = chr:FindFirstChild("HumanoidRootPart")
                if root then
                    if not box then
                        box = Instance.new("BoxHandleAdornment")
                        box.Adornee = root
                        box.Size = Vector3.new(Settings.Hitbox.Size, Settings.Hitbox.Size, Settings.Hitbox.Size)
                        box.Color3 = Settings.Hitbox.Color
                        box.Transparency = 0.4
                        box.ZIndex = 10
                        box.Parent = root
                        Settings.Hitbox.Adornments[plr] = box
                    else
                        box.Size = Vector3.new(Settings.Hitbox.Size, Settings.Hitbox.Size, Settings.Hitbox.Size)
                        box.Color3 = Settings.Hitbox.Color
                    end
                end
            elseif box then
                box:Destroy()
                Settings.Hitbox.Adornments[plr] = nil
            end
        end
    end
end
local function ToggleAntiAFK(state)
    if state then
        Settings.AntiAFK.Connection = RunService.Heartbeat:Connect(function()
            pcall(function()
                local vu = game:GetService("VirtualUser")
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
            end)
        end)
    elseif Settings.AntiAFK.Connection then
        Settings.AntiAFK.Connection:Disconnect()
    end
end
local AutoInject = {
    Enabled = false,
    ScriptURL = "https://raw.githubusercontent.com/dyumra/DYHUB-Universal-Game/refs/heads/main/Mm2dyhubvw2.lua"
}
local function SetupAutoInject()
    if not AutoInject.Enabled then return end
    spawn(function()
        wait(2)
        if AutoInject.Enabled then
            pcall(function()
                loadstring(game:HttpGet(AutoInject.ScriptURL))()
            end)
        end
    end)
    player.OnTeleport:Connect(function(state)
        if ((state == Enum.TeleportState.Started) and AutoInject.Enabled) then
            queue_on_teleport([[wait(2) loadstring(game:HttpGet("]] .. AutoInject.ScriptURL .. [["))()]])
        end
    end)
    game:GetService("Players").PlayerRemoving:Connect(function(plr)
        if ((plr == player) and AutoInject.Enabled) then
            queue_on_teleport([[wait(2) loadstring(game:HttpGet("]] .. AutoInject.ScriptURL .. [["))()]])
        end
    end)
end
local keybindSection = Tabs.Settings:AddRightGroupbox("Keybind")
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
local enableNotifications = true
local notifyDuration = 3
local SettingsLeftGroup = Tabs.Settings:AddLeftGroupbox("Menu Settings")
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
local AppearanceGroup = Tabs.Settings:AddLeftGroupbox("Appearance")
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
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("Ostium")
ThemeManager:ApplyToTab(Tabs.Settings)
local NotificationGroup = Tabs.Settings:AddRightGroupbox("Notifications")
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
local HitboxGroup = Tabs.Settings:AddLeftGroupbox("Hitboxes")
local HitboxEnabled = HitboxGroup:AddCheckbox("HitboxesEnabled", {
    Text = "Hitboxes",
    Default = false,
    Callback = function(state)
        Settings.Hitbox.Enabled = state
        if state then
            RunService.Heartbeat:Connect(UpdateHitboxes)
        else
            for _, box in pairs(Settings.Hitbox.Adornments) do
                if box then
                    box:Destroy()
                end
            end
            Settings.Hitbox.Adornments = {}
        end
    end
})
local HitboxColor = HitboxEnabled:AddColorPicker("HitboxColor", {
    Default = Color3.new(1, 0, 0),
    Title = "Hitbox color",
    Callback = function(col)
        Settings.Hitbox.Color = col
        UpdateHitboxes()
    end
})
HitboxGroup:AddSlider("HitboxSize", {
    Text = "Hitbox size",
    Default = 5,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Callback = function(val)
        Settings.Hitbox.Size = val
        UpdateHitboxes()
    end
})
local CharacterFunctionsGroup = Tabs.Settings:AddRightGroupbox("Character Functions")
CharacterFunctionsGroup:AddCheckbox("AntiAFK", {
    Text = "Anti-AFK",
    Default = false,
    Callback = function(state)
        Settings.AntiAFK.Enabled = state
        ToggleAntiAFK(state)
    end
})
CharacterFunctionsGroup:AddCheckbox("NoClip", {
    Text = "NoClip",
    Default = false,
    Callback = function(state)
        Settings.Noclip.Enabled = state
        ToggleNoclip(state)
    end
})
local AutoInjectGroup = Tabs.Settings:AddRightGroupbox("Auto Execute")
AutoInjectGroup:AddCheckbox("AutoInject", {
    Text = "Auto Inject on Rejoin/Hop",
    Default = false,
    Callback = function(state)
        AutoInject.Enabled = state
        if state then
            SetupAutoInject()
            Library:Notify("Autoinject is enabled! The script will restart automatically.", 3)
        else
            Library:Notify("Autoinjection disabled", 3)
        end
    end
})
AutoInjectGroup:AddButton("ManualReInject", {
    Text = "Manual Re-Inject",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet(AutoInject.ScriptURL))()
            Library:Notify("The script has been successfully reloaded!", 3)
        end)
    end
})
local SocialsGroup = Tabs.Settings:AddLeftGroupbox("Socials")
SocialsGroup:AddButton("Discord", function()
    if pcall(setclipboard, "https://dsc.gg/dyhub") then
        Library:Notify("Link copied to clipboard.", 3)
    else
        Library:Notify("Failed to copy link.", 5)
    end
end)
SocialsGroup:AddButton("Social", function()
    if pcall(setclipboard, "https://guns.lol/DYHUB") then
        Library:Notify("Link copied to clipboard.", 3)
    else
        Library:Notify("Failed to copy link.", 5)
    end
end)
local ChangelogsGroup = Tabs.Settings:AddRightGroupbox("Changelogs")
ChangelogsGroup:AddLabel("DYHUB • MM2 commands:")
ChangelogsGroup:AddLabel("|• Silent Aimbot")
ChangelogsGroup:AddLabel("|• All Sheriff Functions")
ChangelogsGroup:AddLabel("|• Better shot")
ChangelogsGroup:AddLabel("|• Fixed errors")
ChangelogsGroup:AddLabel("|• Shot variants [default; teleport]")
ChangelogsGroup:AddLabel("|• Faster shots")
ChangelogsGroup:AddLabel("|• New shot button")
ChangelogsGroup:AddLabel("|• Shot button settings")
ChangelogsGroup:AddLabel("|•All Murder Functions")
ChangelogsGroup:AddLabel("|• Fixed kill player")
ChangelogsGroup:AddLabel("|• Kill all function")
ChangelogsGroup:AddLabel("|• All Innocent Functions")
ChangelogsGroup:AddLabel("|• Grab GunDrop")
ChangelogsGroup:AddLabel("|• Auto Grab Gun Drop")
ChangelogsGroup:AddLabel("|• Grab gun and shoot murder function")
ChangelogsGroup:AddLabel("|• Fixed Notifications")
ChangelogsGroup:AddLabel("|• Fixed Check GunDrop Function")
ChangelogsGroup:AddLabel("|• Autofarm Money")
ChangelogsGroup:AddLabel("|• Autofarm variables [Tp; smooth; walk]")
ChangelogsGroup:AddLabel("|• Coin checker function")
ChangelogsGroup:AddLabel("|• Autofarm settings")
ChangelogsGroup:AddLabel("|• Tp to lobby function")
local ServerGroup = Tabs.Utilities:AddRightGroupbox("Server")
ServerGroup:AddButton("Rejoin", function()
    local success, error = pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
    end)
    if not success then
        warn("Rejoin error:", error)
    end
end)
ServerGroup:AddButton("ServerHop", function()
    local placeId = game.PlaceId
    local currentJobId = game.JobId
    local function serverHop()
        local servers = {}
        local success, result = pcall(function()
            return HttpService:JSONDecode(HttpService:GetAsync("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"))
        end)
        if (success and result and result.data) then
            for _, server in ipairs(result.data) do
                if (server.id ~= currentJobId) then
                    table.insert(servers, server)
                end
            end
            if (#servers > 0) then
                TeleportService:TeleportToPlaceInstance(placeId, servers[math.random(#servers)].id)
            else
                TeleportService:Teleport(placeId)
            end
        else
            TeleportService:Teleport(placeId)
        end
    end
    pcall(serverHop)
end)
ServerGroup:AddButton("LowServer", function()
    local placeId = game.PlaceId
    local currentJobId = game.JobId
    local function joinLowerServer()
        local servers = {}
        local success, result = pcall(function()
            return HttpService:JSONDecode(HttpService:GetAsync("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"))
        end)
        if (success and result and result.data) then
            for _, server in ipairs(result.data) do
                if ((server.id ~= currentJobId) and (server.playing < (server.maxPlayers or 30))) then
                    table.insert(servers, server)
                end
            end
            table.sort(servers, function(a, b) return a.playing < b.playing end)
            if (#servers > 0) then
                TeleportService:TeleportToPlaceInstance(placeId, servers[1].id)
            else
                TeleportService:Teleport(placeId)
            end
        else
            TeleportService:Teleport(placeId)
        end
    end
    pcall(joinLowerServer)
end)
task.spawn(function()
    if not player.Character then
        player.CharacterAdded:Wait()
    end
    ScanForGunDrops()
    if GunSystem.AutoGrabEnabled then
        coroutine.wrap(AutoGrabGun)()
    end
end)
local ESPSettings = Tabs.Utilities:AddLeftGroupbox("ESP Settings")
ESPSettings:AddCheckbox("ESPRainbow", {
    Text = "Rainbow Mode",
    Default = false,
    Callback = function(Value)
        ESP_Library:SetRainbow(Value)
        _G.ESPRainbowEnabled = Value
    end
})
ESPSettings:AddCheckbox("EnableTracers", {
    Text = "Tracers",
    Default = false,
    Callback = function(Value)
        ESP_Library:SetTracers(Value)
        _G.EnableTracers = Value
    end
})
ESPSettings:AddCheckbox("EnableArrows", {
    Text = "Arrows",
    Default = false,
    Callback = function(Value)
        ESP_Library:SetArrows(Value)
        _G.EnableArrows = Value
    end
})
ESPSettings:AddDropdown("TracerOrigin", {
    Text = "Tracer Origin",
    Default = "Bottom",
    Values = {"Bottom", "Center", "Top", "Mouse"},
    Callback = function(Value) ESP_Library:SetTracerOrigin(Value) end
})
ESPSettings:AddSlider("TracerSize", {
    Text = "Tracer Size",
    Default = 1,
    Min = 0.1,
    Max = 5,
    Rounding = 1,
    Compact = true,
    Callback = function(Value) ESP_Library:SetTracerSize(Value) end
})
ESPSettings:AddSlider("ArrowRadius", {
    Text = "Arrow Radius",
    Default = 200,
    Min = 50,
    Max = 500,
    Rounding = 0,
    Compact = true,
    Callback = function(Value) ESP_Library:SetArrowRadius(Value) end
})
ESPSettings:AddSlider("ESPDistance", {
    Text = "ESP Distance",
    Default = 200,
    Min = 50,
    Max = 1000,
    Rounding = 0,
    Compact = true,
    Callback = function(Value) _G.ESPDistance = Value end
})
local VisualsGroup = Tabs.Utilities:AddRightGroupbox("Special ESP")
local AllowedEntities = {
    ["GunDrop"] = {targetPart = nil, name = "Gun"}
}
VisualsGroup:AddCheckbox("EntityESP", {
    Text = "Entity ESP",
    Default = false,
    Tooltip = "Shows GunDrops",
    Callback = function(Value)
        _G.EntityESP_Elements = _G.EntityESP_Elements or {}
        _G.EntityESP_Trans = _G.EntityESP_Trans or {}
        local Objects, lastUpdate, UPDATE_INTERVAL, MAX_PROCESS_PER_FRAME = {}, 0, 1/30, 5
        local function getTargetPart(model)
            local c = AllowedEntities[model.Name]
            if not c then return end
            local p = model:FindFirstChild(c.targetPart, true)
            if p and p:IsA("BasePart") then return p end
            return model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
        end
        local function handleTransparency(t, e)
            if not t then return end
            if t:IsA("Model") then
                for _, p in ipairs(t:GetDescendants()) do
                    if p:IsA("BasePart") then
                        if e then
                            if not _G.EntityESP_Trans[p] then _G.EntityESP_Trans[p] = p.Transparency end
                            p.Transparency = 0
                        elseif _G.EntityESP_Trans[p] then
                            p.Transparency = _G.EntityESP_Trans[p]
                            _G.EntityESP_Trans[p] = nil
                        end
                    end
                end
            elseif t:IsA("BasePart") then
                if e then
                    if not _G.EntityESP_Trans[t] then _G.EntityESP_Trans[t] = t.Transparency end
                    t.Transparency = 0
                elseif _G.EntityESP_Trans[t] then
                    t.Transparency = _G.EntityESP_Trans[t]
                    _G.EntityESP_Trans[t] = nil
                end
            end
        end
        local function addESP(m)
            local t = getTargetPart(m)
            if not t then return end
            local c = AllowedEntities[m.Name]
            if not c then return end
            local d = distanceBetweenRootAndPart(t:IsA("BasePart") and t or m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart"))
            if d > _G.ESPDistance then return end
            local r = _G.EntityESP_Elements[m]
            if r and r.added then return end
            local bp = t:IsA("BasePart") and t or t.PrimaryPart or t:FindFirstChildWhichIsA("BasePart")
            if not bp then return end
            handleTransparency(t, true)
            local col = Options.EntityESP_Color.Value
            addESPWithDynamicColor(t, c.name, bp, col)
            _G.EntityESP_Elements[m] = {model = m, target = t, added = true}
        end
        local function removeESPRecord(r)
            if not r or not r.added or not r.target then return end
            ESP_Library:RemoveESP(r.target)
            handleTransparency(r.target, false)
            _G.EntityESP_Elements[r.model] = nil
        end
        local function cleanup()
            if _G.EntityESP_Add then _G.EntityESP_Add:Disconnect() _G.EntityESP_Add = nil end
            if _G.EntityESP_Update then _G.EntityESP_Update:Disconnect() _G.EntityESP_Update = nil end
            for _, r in pairs(_G.EntityESP_Elements) do if r then removeESPRecord(r) end end
            table.clear(_G.EntityESP_Elements)
            table.clear(_G.EntityESP_Trans)
            table.clear(Objects)
        end
        if Value then
            cleanup()
            for _, mapName in ipairs(mapPaths) do
                local map = workspace:FindFirstChild(mapName)
                if map then
                    local gunDrop = map:FindFirstChild("GunDrop")
                    if gunDrop and AllowedEntities[gunDrop.Name] then Objects[#Objects+1] = gunDrop end
                end
            end
            local rootGunDrop = workspace:FindFirstChild("GunDrop")
            if rootGunDrop and AllowedEntities[rootGunDrop.Name] then Objects[#Objects+1] = rootGunDrop end
            _G.EntityESP_Add = workspace.DescendantAdded:Connect(function(v)
                if v:IsA("BasePart") or v:IsA("Model") then
                    for _, mapName in ipairs(mapPaths) do
                        local map = workspace:FindFirstChild(mapName)
                        if map and (v:IsDescendantOf(map) or v == map) and v.Name == "GunDrop" then
                            Objects[#Objects+1] = v
                            break
                        end
                    end
                    if v.Name == "GunDrop" and not table.find(mapPaths, v.Parent.Name) then Objects[#Objects+1] = v end
                end
            end)
            _G.EntityESP_Update = RunService.Heartbeat:Connect(function()
                local n = tick()
                if n - lastUpdate < UPDATE_INTERVAL then return end
                lastUpdate = n
                local r = playerRoot()
                if not r then return end
                local col = Options.EntityESP_Color.Value
                local ec = getESPColor(col)
                local rm = {}
                for i = 1, math.min(#Objects, MAX_PROCESS_PER_FRAME) do
                    local v = Objects[i]
                    if (v:IsA("BasePart") or v:IsA("Model")) and AllowedEntities[v.Name] then addESP(v) end
                end
                table.clear(Objects)
                for m, rec in pairs(_G.EntityESP_Elements) do
                    if not m or not m.Parent or not rec then
                        rm[#rm+1] = m
                    else
                        local cfg = AllowedEntities[m.Name]
                        if not cfg then
                            rm[#rm+1] = m
                        else
                            local t = getTargetPart(m)
                            if not t or not t.Parent then
                                removeESPRecord(rec)
                                rm[#rm+1] = m
                            else
                                rec.target = t
                                local d = distanceBetweenRootAndPart(t:IsA("BasePart") and t or m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart"))
                                if d <= _G.ESPDistance then
                                    if not rec.added then
                                        local bp = t:IsA("BasePart") and t or m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart")
                                        addESPWithDynamicColor(t, cfg.name, bp, col)
                                        rec.added = true
                                        handleTransparency(t, true)
                                    else
                                        ESP_Library:UpdateObjectColor(t, ec)
                                        ESP_Library:UpdateObjectText(t, cfg.name)
                                    end
                                elseif rec.added then
                                    removeESPRecord(rec)
                                    rec.added = false
                                end
                            end
                        end
                    end
                end
                for _, m in ipairs(rm) do _G.EntityESP_Elements[m] = nil end
            end)
        else
            cleanup()
        end
    end
}):AddColorPicker("EntityESP_Color", {
    Default = Color3.fromRGB(255, 215, 0),
    Title = "GunDrop Color",
    Callback = function(Value)
        local ec = getESPColor(Value)
        for _, rec in pairs(_G.EntityESP_Elements or {}) do
            if rec and rec.added and rec.target then
                ESP_Library:UpdateObjectColor(rec.target, ec)
            end
        end
    end
})
VisualsGroup:AddCheckbox("PlayerESP", {
    Text = "Player ESP",
    Default = false,
    Tooltip = "Highlights players with name, role and distance",
    Callback = function(Value)
        _G.PlayerESP_Elements = _G.PlayerESP_Elements or {}
        _G.PlayerESP_Color = _G.PlayerESP_Color or Color3.fromRGB(0, 255, 0)
         
        local function createRecordForCharacter(plr, character)
            if not plr or plr == player then return end
            if not character or not character:IsA("Model") then return end
            local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
            if not root then return end
            _G.PlayerESP_Elements[plr] = _G.PlayerESP_Elements[plr] or {player = plr, root = root, object = character, added = false}
            local rec = _G.PlayerESP_Elements[plr]
            local dist = distanceBetweenRootAndPart(root)
            local role = getPlayerRole(plr)
            local text = (plr.DisplayName or plr.Name) .. " [" .. (role or "Unknown") .. "]"
            if dist <= _G.ESPDistance and not rec.added then
                addESPWithDynamicColor(rec.object, text, rec.root, _G.PlayerESP_Color)
                rec.added = true
            elseif dist > _G.ESPDistance and rec.added then
                ESP_Library:RemoveESP(rec.object)
                rec.added = false
            end
        end
         
        local function removeForPlayer(plr)
            local rec = _G.PlayerESP_Elements[plr]
            if rec and rec.added then
                ESP_Library:RemoveESP(rec.object)
            end
            _G.PlayerESP_Elements[plr] = nil
        end
         
        if Value then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player then
                    if plr.Character then
                        createRecordForCharacter(plr, plr.Character)
                    end
                    plr.CharacterAdded:Connect(function(char)
                        task.spawn(function()
                            task.wait(0.5)
                            createRecordForCharacter(plr, char)
                        end)
                    end)
                    plr.CharacterRemoving:Connect(function()
                        removeForPlayer(plr)
                    end)
                end
            end
             
            _G.PlayerESP_PlayerAdded = Players.PlayerAdded:Connect(function(plr)
                plr.CharacterAdded:Connect(function(char)
                    task.spawn(function()
                        task.wait(0.5)
                        createRecordForCharacter(plr, char)
                    end)
                end)
                plr.CharacterRemoving:Connect(function()
                    removeForPlayer(plr)
                end)
            end)
             
            _G.PlayerESP_PlayerRemoving = Players.PlayerRemoving:Connect(function(plr)
                removeForPlayer(plr)
            end)
             
            _G.PlayerESP_Update = RunService.Heartbeat:Connect(function()
                local lpRoot = playerRoot()
                if not lpRoot then return end
                local toRemove = {}
                local espColor = getESPColor(_G.PlayerESP_Color)
                for plr, rec in pairs(_G.PlayerESP_Elements) do
                    if not plr or not plr.Parent then
                        table.insert(toRemove, plr)
                    else
                        local char = plr.Character
                        local targetRoot = rec.root
                        if char and targetRoot and targetRoot.Parent and targetRoot:IsDescendantOf(char) then
                            local dist = (lpRoot.Position - targetRoot.Position).Magnitude
                            local role = getPlayerRole(plr)
                            local text = (plr.DisplayName or plr.Name) .. " [" .. (role or "Unknown") .. "]"
                            if dist <= _G.ESPDistance then
                                if not rec.added then
                                    addESPWithDynamicColor(rec.object, text, targetRoot, _G.PlayerESP_Color)
                                    rec.added = true
                                else
                                    ESP_Library:UpdateObjectText(rec.object, text)
                                    ESP_Library:UpdateObjectColor(rec.object, espColor)
                                end
                            else
                                if rec.added then
                                    ESP_Library:RemoveESP(rec.object)
                                    rec.added = false
                                end
                            end
                        else
                            table.insert(toRemove, plr)
                        end
                    end
                end
                for _, p in ipairs(toRemove) do
                    removeForPlayer(p)
                end
            end)
        else
            if _G.PlayerESP_PlayerAdded then
                _G.PlayerESP_PlayerAdded:Disconnect()
                _G.PlayerESP_PlayerAdded = nil
            end
            if _G.PlayerESP_PlayerRemoving then
                _G.PlayerESP_PlayerRemoving:Disconnect()
                _G.PlayerESP_PlayerRemoving = nil
            end
            if _G.PlayerESP_Update then
                _G.PlayerESP_Update:Disconnect()
                _G.PlayerESP_Update = nil
            end
             
            for plr, rec in pairs(_G.PlayerESP_Elements) do
                if rec and rec.added then
                    ESP_Library:RemoveESP(rec.object)
                end
                _G.PlayerESP_Elements[plr] = nil
            end
            _G.PlayerESP_Elements = {}
        end
    end
}):AddColorPicker("PlayerESP_Color", {
    Default = Color3.fromRGB(0, 255, 0),
    Title = "Player Color",
    Callback = function(Value)
        _G.PlayerESP_Color = Value
        local espColor = getESPColor(Value)
        for _, rec in pairs(_G.PlayerESP_Elements or {}) do
            if rec and rec.added then
                ESP_Library:UpdateObjectColor(rec.object, espColor)
            end
        end
    end
})
local AutoFarmGroup = Tabs.Utilities:AddLeftGroupbox("Auto Farm")
AutoFarmGroup:AddDropdown("MovementMode", {
    Text = "Movement Mode",
    Default = "Teleport",
    Values = {"Teleport", "Smooth", "Walk"},
    Callback = function(mode)
        AutoFarm.Mode = mode
        Library:Notify("Mode set to: " .. mode, 2)
    end
})
AutoFarmGroup:AddSlider("TeleportDelay", {
    Text = "Teleport Delay (sec)",
    Default = 0,
    Min = 0,
    Max = 1,
    Rounding = 1,
    Compact = true,
    Callback = function(value)
        AutoFarm.TeleportDelay = value
    end
})
AutoFarmGroup:AddSlider("MoveSpeed", {
    Text = "Smooth Move Speed",
    Default = 50,
    Min = 20,
    Max = 200,
    Rounding = 0,
    Callback = function(value)
        AutoFarm.MoveSpeed = value
    end
})
AutoFarmGroup:AddSlider("WalkSpeed", {
    Text = "Walk Speed",
    Default = 32,
    Min = 16,
    Max = 100,
    Rounding = 0,
    Callback = function(value)
        AutoFarm.WalkSpeed = value
    end
})
AutoFarmGroup:AddSlider("CoinInterval", {
    Text = "Check Interval (sec)",
    Default = 0.5,
    Min = 0.1,
    Max = 2,
    Rounding = 1,
    Compact = true,
    Callback = function(value)
        AutoFarm.CoinCheckInterval = value
    end
})
AutoFarmGroup:AddCheckbox("EnableAutoFarm", {
    Text = "Enable AutoFarm",
    Default = false,
    Callback = function(state)
        AutoFarm.Enabled = state
        if state then
            AutoFarm.Connection = task.spawn(farmLoop)
            Library:Notify("Started farming nearest coins!", 2)
        else
            if AutoFarm.Connection then
                task.cancel(AutoFarm.Connection)
            end
            Library:Notify("Stopped farming coins", 2)
        end
    end
})
local TeleportGroup = Tabs.Combat:AddLeftGroupbox("Teleport")
initializeTeleportDropdown(TeleportGroup)
TeleportGroup:AddButton("TeleportToPlayer", teleportToPlayer)
TeleportGroup:AddButton("UpdatePlayers", function()
    if teleportDropdown then
        teleportDropdown:Refresh(updateTeleportPlayers())
    end
end)
local function teleportToLobby()
    local lobby = workspace:FindFirstChild("Lobby")
    if not lobby then
        Library:Notify("Lobby not found!", 2)
        return
    end
    local spawnPoint = lobby:FindFirstChild("SpawnPoint")
    if spawnPoint and spawnPoint:IsA("BasePart") then
        -- use it
    elseif lobby.PrimaryPart and lobby.PrimaryPart:IsA("BasePart") then
        spawnPoint = lobby.PrimaryPart
    else
        spawnPoint = lobby:FindFirstChildOfClass("SpawnLocation") or lobby:FindFirstChildWhichIsA("BasePart")
    end
    if spawnPoint and spawnPoint:IsA("BasePart") then
        if (player.Character and player.Character:FindFirstChild("HumanoidRootPart")) then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(spawnPoint.Position + Vector3.new(0, 5, 0))
            Library:Notify("Teleported to Lobby!", 3)
        end
    else
        Library:Notify("No valid spawn point found in Lobby!", 3)
    end
end
TeleportGroup:AddButton("TeleportLobby", teleportToLobby)
TeleportGroup:AddButton("TeleportSheriff", function()
    if Sheriff then
        local sheriffPlayer = Players:FindFirstChild(Sheriff)
        if (sheriffPlayer and sheriffPlayer.Character) then
            local targetRoot = sheriffPlayer.Character:FindFirstChild("HumanoidRootPart")
            local localRoot = player.Character:FindFirstChild("HumanoidRootPart")
            if (targetRoot and localRoot) then
                localRoot.CFrame = targetRoot.CFrame
                Library:Notify("Successfully teleported to the sheriff: " .. Sheriff, 3)
            end
        else
            Library:Notify("Sheriff not found or unavailable", 3)
        end
    else
        Library:Notify("Sheriff is not determined in the current match", 3)
    end
end)
TeleportGroup:AddButton("TeleportMurderer", function()
    if Murder then
        local murderPlayer = Players:FindFirstChild(Murder)
        if (murderPlayer and murderPlayer.Character) then
            local targetRoot = murderPlayer.Character:FindFirstChild("HumanoidRootPart")
            local localRoot = player.Character:FindFirstChild("HumanoidRootPart")
            if (targetRoot and localRoot) then
                localRoot.CFrame = targetRoot.CFrame
                Library:Notify("Successfully teleported to the Murder:" .. Murder, 3)
            end
        else
            Library:Notify("The Murder has not been found or is unavailable.", 3)
        end
    else
        Library:Notify("The Murder is not determined in the current match.", 3)
    end
end)
local AimbotGroup = Tabs.Combat:AddRightGroupbox("Aimbot")
local RoleDropdown = AimbotGroup:AddDropdown("TargetRole", {
    Text = "Target Role",
    Default = "None",
    Values = {"None", "Sheriff", "Murderer"},
    Callback = function(selected)
        lockedRole = ((selected ~= "None") and selected) or nil
    end
})
AimbotGroup:AddCheckbox("SpectateMode", {
    Text = "Spectate Mode",
    Default = false,
    Callback = function(state)
        isSpectating = state
        if state then
            originalCameraType = Workspace.CurrentCamera.CameraType
            originalCameraSubject = Workspace.CurrentCamera.CameraSubject
            Workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
        else
            Workspace.CurrentCamera.CameraType = originalCameraType
            Workspace.CurrentCamera.CameraSubject = originalCameraSubject
        end
    end
})
AimbotGroup:AddCheckbox("LockCamera", {
    Text = "Lock Camera",
    Default = false,
    Callback = function(state)
        isCameraLocked = state
        if (not state and not isSpectating) then
            Workspace.CurrentCamera.CameraType = originalCameraType
            Workspace.CurrentCamera.CameraSubject = originalCameraSubject
        end
    end
})
local InnocentGroup = Tabs.Combat:AddLeftGroupbox("Innocent")
InnocentGroup:AddCheckbox("NotifyGunDrop", {
    Text = "Notify GunDrop",
    Default = true,
    Callback = function(state)
        gunDropESPEnabled = state
        if state then
            task.spawn(function()
                task.wait(1)
                checkForGunDrops()
            end)
        end
    end
})
InnocentGroup:AddButton("GrabGun", function() GrabGun() end)
InnocentGroup:AddCheckbox("AutoGrabGun", {
    Text = "Auto Grab Gun",
    Default = false,
    Callback = function(state)
        GunSystem.AutoGrabEnabled = state
        if state then
            coroutine.wrap(AutoGrabGun)()
            Library:Notify("Auto Grab Gun enabled!", 3)
        else
            Library:Notify("Auto Grab Gun disabled", 3)
        end
    end
})
InnocentGroup:AddButton("GrabShootMurderer", GrabAndShootMurderer)
local MurderGroup = Tabs.Combat:AddRightGroupbox("Murder")
MurderGroup:AddCheckbox("KillAll", {
    Text = "Kill All",
    Default = false,
    Callback = function(state)
        if state then
            killTargets()
        else
            stopKilling()
        end
    end
})
MurderGroup:AddSlider("AttackDelay", {
    Text = "Attack Delay",
    Default = 0.5,
    Min = 0.1,
    Max = 2,
    Rounding = 1,
    Compact = true,
    Callback = function(value)
        attackDelay = value
        Library:Notify("Delay set to " .. value .. "s", 2)
    end
})
MurderGroup:AddButton("EquipKnife", function()
    if equipKnife() then
        Library:Notify("Knife equipped!", 2)
    else
        Library:Notify("No knife found!", 2)
    end
end)
local SheriffGroup = Tabs.Combat:AddLeftGroupbox("Sheriff")
SheriffGroup:AddDropdown("ShotType", {
    Text = "Shot Type",
    Default = "Default",
    Values = {"Default", "Teleport"},
    Callback = function(selectedType)
        shotType = selectedType
        Library:Notify("Shot Type: " .. selectedType, 3)
    end
})
SheriffGroup:AddButton("ShootMurderer", ShootMurderer)
local ShotButtonGroup = Tabs.Combat:AddRightGroupbox("Shot Button")
ShotButtonGroup:AddButton("ToggleShotButton", function()
    if shotButtonActive then
        RemoveShotButton()
    else
        CreateShotButton()
    end
end)
ShotButtonGroup:AddSlider("ButtonSize", {
    Text = "Button Size",
    Default = 50,
    Min = 10,
    Max = 100,
    Rounding = 0,
    Callback = function(size)
        buttonSize = size
        if shotButtonActive then
            local currentPos = (shotButtonFrame and shotButtonFrame.Position) or UDim2.new(1, -buttonSize - 20, 0.5, -buttonSize / 2)
            RemoveShotButton()
            CreateShotButton()
            if shotButtonFrame then
                shotButtonFrame.Position = currentPos
            end
        end
        Library:Notify("Size: " .. size, 3)
    end
})
local WalkspeedGroup = Tabs.Combat:AddLeftGroupbox("Walkspeed")
WalkspeedGroup:AddSlider("Walkspeed", {
    Text = "Walkspeed",
    Default = 16,
    Min = 0,
    Max = 200,
    Rounding = 0,
    Callback = function(value)
        CharacterSettings.WalkSpeed.Value = value
        updateCharacter()
    end
})
WalkspeedGroup:AddButton("ResetWalkspeed", function()
    CharacterSettings.WalkSpeed.Value = CharacterSettings.WalkSpeed.Default
    updateCharacter()
end)
WalkspeedGroup:AddCheckbox("BlockWalkspeed", {
    Text = "Block walkspeed",
    Default = false,
    Callback = function(state)
        CharacterSettings.WalkSpeed.Locked = state
        updateCharacter()
    end
})
local JumpGroup = Tabs.Combat:AddRightGroupbox("JumpPower")
JumpGroup:AddSlider("Jumppower", {
    Text = "Jumppower",
    Default = 50,
    Min = 0,
    Max = 200,
    Rounding = 0,
    Callback = function(value)
        CharacterSettings.JumpPower.Value = value
        updateCharacter()
    end
})
JumpGroup:AddButton("ResetJumppower", function()
    CharacterSettings.JumpPower.Value = CharacterSettings.JumpPower.Default
    updateCharacter()
end)
JumpGroup:AddCheckbox("BlockJumppower", {
    Text = "Block jumppower",
    Default = false,
    Callback = function(state)
        CharacterSettings.JumpPower.Locked = state
        updateCharacter()
    end
})
local EmoteGroup = Tabs.Combat:AddRightGroupbox("Emotes")
EmoteGroup:AddButton("DupeEmoteAll", function()
    local replicatedStorage = game:GetService("ReplicatedStorage")
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return end
    local mainGui = playerGui:FindFirstChild("MainGUI")
    if not mainGui then return end
    local gameFrame = mainGui:FindFirstChild("Game")
    if not gameFrame then return end
    local emoteFrame = gameFrame:FindFirstChild("Emotes")
    if not emoteFrame then return end
    local modulesFolder = replicatedStorage:FindFirstChild("Modules")
    if not modulesFolder then return end
    local emoteModuleScript = modulesFolder:FindFirstChild("EmoteModule")
    if not emoteModuleScript then return end
    local success, emoteModule = pcall(require, emoteModuleScript)
    if not success then return end
    if emoteModule and typeof(emoteModule.GeneratePage) == "function" then
        emoteModule.GeneratePage({"headless", "zombie", "zen", "ninja", "floss", "dab", "sit"}, emoteFrame, "Ostium EMOTES")
        print("Emotes unlocked successfully!")
    end
end)
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
        Library:SetWatermark(string.format("Ostium | %d FPS | %d ms | v%s", math.floor(fps), math.floor(ping), latestVersion))
    end)
end
updateWatermark()
game:GetService('Players').LocalPlayer.Idled:Connect(function()
    game:GetService('VirtualUser'):CaptureController()
    game:GetService('VirtualUser'):ClickButton2(Vector2.new())
end)