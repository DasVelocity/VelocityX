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
    Footer = latestVersion .. " | Ostium | Arsenal",
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
        Player = Window:AddTab("Player", "user"),
    Gun = Window:AddTab("Gun Mods", "target"),
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
<font color="rgb(255, 255, 255)">-- Arsenal Edition --</font>
- <font color="rgb(0, 255, 0)">i just released this what you mean</font>
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





local AimbotGroup = Tabs.Main:AddLeftGroupbox("Aimbot")
local aimbotMasterEnabled = false
local aimbotFOV = 100
local aimbotTeamCheck = "Enemies"

AimbotGroup:AddCheckbox("EnableAimbot", {
    Text = "Enable Aimbot",
    Default = false,
    Callback = function(Value)
        aimbotMasterEnabled = Value
    end
})
AimbotGroup:AddSlider("AimbotFOV", {
    Text = "FOV",
    Default = 100,
    Min = 0,
    Max = 500,
    Rounding = 0,
    Callback = function(Value)
        aimbotFOV = Value
    end
})
AimbotGroup:AddDropdown("AimbotTeam", {
    Text = "Team Check",
    Default = "Enemies",
    Values = {"Everyone", "Enemies", "None"},
    Callback = function(Value)
        aimbotTeamCheck = Value
    end
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local cam = Workspace.CurrentCamera

local aimWhileHolding = false
local currentTarget = nil
local currentTargetPlayer = nil
local currentTargetScreenDist = math.huge

mouse.Button2Down:Connect(function()
    aimWhileHolding = true
end)
mouse.Button2Up:Connect(function()
    aimWhileHolding = false
    currentTarget = nil
    currentTargetPlayer = nil
    currentTargetScreenDist = math.huge
end)

local function findClosestCandidate()
    if not cam then cam = Workspace.CurrentCamera end
    local closestPlayer, closestHead, closestDist = nil, nil, aimbotFOV
    local mx, my = mouse.X, mouse.Y

    if not player.Character or not player.Character:FindFirstChild("Head") then
        return nil
    end

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") then
            if aimbotTeamCheck == "Everyone" or aimbotTeamCheck == "None" or (aimbotTeamCheck == "Enemies" and plr.Team ~= player.Team) then
                local head = plr.Character.Head
                local screenPos, onScreen = cam:WorldToViewportPoint(head.Position)
                if onScreen then
                    local screenDist = (Vector2.new(mx, my) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                    if screenDist < closestDist then
                        closestDist = screenDist
                        closestHead = head
                        closestPlayer = plr
                    end
                end
            end
        end
    end

    if closestHead then
        return closestPlayer, closestHead, closestDist
    else
        return nil
    end
end

local aimbotConnection = RunService.RenderStepped:Connect(function()
    if not aimbotMasterEnabled or not aimWhileHolding then
        return
    end

    local foundPlayer, foundHead, foundDist = findClosestCandidate()
    if foundHead then
        if not currentTarget then
            currentTarget = foundHead
            currentTargetPlayer = foundPlayer
            currentTargetScreenDist = foundDist
        else
            if foundPlayer ~= currentTargetPlayer and foundDist < currentTargetScreenDist then
                currentTarget = foundHead
                currentTargetPlayer = foundPlayer
                currentTargetScreenDist = foundDist
            else
                if foundPlayer == currentTargetPlayer then
                    currentTargetScreenDist = foundDist
                end
            end
        end

        if currentTarget and currentTarget.Parent then
            local camPos = Workspace.CurrentCamera.CFrame.Position
            Workspace.CurrentCamera.CFrame = CFrame.lookAt(camPos, currentTarget.Position)
        else
            currentTarget = nil
            currentTargetPlayer = nil
            currentTargetScreenDist = math.huge
        end
    else
        currentTarget = nil
        currentTargetPlayer = nil
        currentTargetScreenDist = math.huge
    end
end)

table.insert(connections, {disconnect = function() aimbotConnection:Disconnect() end})



local HitboxGroup = Tabs.Main:AddLeftGroupbox("Silent Aim")
local hitboxEnabled = false
local noCollisionEnabled = false
local hitbox_original_properties = {}
local hitboxSize = 21
local hitboxTransparency = 6
local teamCheck = "FFA"
local defaultBodyParts = {"UpperTorso", "Head", "HumanoidRootPart"}
local ScreenGui = Instance.new("ScreenGui", player.PlayerGui)
local WarningText = Instance.new("TextLabel", ScreenGui)
WarningText.Size = UDim2.new(0, 200, 0, 50)
WarningText.TextSize = 16
WarningText.Position = UDim2.new(0.5, -150, 0, 0)
WarningText.Text = ""
WarningText.TextColor3 = Color3.new(1, 0, 0)
WarningText.BackgroundTransparency = 1
WarningText.Visible = false
local function savedPart(plr, part)
    if not hitbox_original_properties[plr] then
        hitbox_original_properties[plr] = {}
    end
    if not hitbox_original_properties[plr][part.Name] then
        hitbox_original_properties[plr][part.Name] = {
            CanCollide = part.CanCollide,
            Transparency = part.Transparency,
            Size = part.Size
        }
    end
end
local function restoredPart(plr)
    if hitbox_original_properties[plr] then
        for partName, properties in pairs(hitbox_original_properties[plr]) do
            local part = plr.Character and plr.Character:FindFirstChild(partName)
            if part and part:IsA("BasePart") then
                part.CanCollide = properties.CanCollide
                part.Transparency = properties.Transparency
                part.Size = properties.Size
            end
        end
    end
end
local function findClosestPart(plr, partName)
    if not plr.Character then return nil end
    for _, part in ipairs(plr.Character:GetChildren()) do
        if part:IsA("BasePart") and part.Name:lower():match(partName:lower()) then
            return part
        end
    end
    return nil
end
local function extendHitbox(plr)
    for _, partName in ipairs(defaultBodyParts) do
        local part = plr.Character and (plr.Character:FindFirstChild(partName) or findClosestPart(plr, partName))
        if part and part:IsA("BasePart") then
            savedPart(plr, part)
            part.CanCollide = not noCollisionEnabled
            part.Transparency = hitboxTransparency / 10
            part.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
        end
    end
end
local function isEnemy(plr)
    if teamCheck == "FFA" or teamCheck == "Everyone" then return true end
    return plr.Team ~= player.Team
end
local function shouldExtendHitbox(plr)
    return isEnemy(plr)
end
local function updateHitboxes()
    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            if shouldExtendHitbox(v) then
                extendHitbox(v)
            else
                restoredPart(v)
            end
        end
    end
end
local function onCharacterAdded(character)
    task.wait(0.1)
    if hitboxEnabled then updateHitboxes() end
end
local function onPlayerAdded(plr)
    plr.CharacterAdded:Connect(onCharacterAdded)
    plr.CharacterRemoving:Connect(function()
        restoredPart(plr)
        hitbox_original_properties[plr] = nil
    end)
end
local function checkForDeadPlayers()
    for plr, _ in pairs(hitbox_original_properties) do
        if not plr.Parent or not plr.Character or not plr.Character:IsDescendantOf(game) then
            restoredPart(plr)
            hitbox_original_properties[plr] = nil
        end
    end
end
Players.PlayerAdded:Connect(onPlayerAdded)
for _, plr in ipairs(Players:GetPlayers()) do onPlayerAdded(plr) end
local hitboxConnection
hitboxConnection = task.spawn(function()
    while true do
        if hitboxEnabled then
            updateHitboxes()
            checkForDeadPlayers()
        end
        task.wait(0.1)
    end
end)
table.insert(connections, {disconnect = function() task.cancel(hitboxConnection) end})
HitboxGroup:AddCheckbox("SilentAim", {
    Text = "Silent Aim",
    Default = false,
    Callback = function(Value)
        hitboxEnabled = Value
        if not Value then
            for _, plr in ipairs(Players:GetPlayers()) do restoredPart(plr) end
            hitbox_original_properties = {}
        else
            updateHitboxes()
        end
    end
})
HitboxGroup:AddSlider("HitboxSize", {
    Text = "Hitbox Size",
    Default = 21,
    Min = 1,
    Max = 50,
    Rounding = 0,
    Callback = function(Value)
        hitboxSize = Value
        if hitboxEnabled then updateHitboxes() end
    end
})
HitboxGroup:AddSlider("HitboxTransparency", {
    Text = "Hitbox Transparency",
    Default = 6,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Callback = function(Value)
        hitboxTransparency = Value
        if hitboxEnabled then updateHitboxes() end
    end
})
HitboxGroup:AddDropdown("TeamCheck", {
    Text = "Team Check",
    Default = "FFA",
    Values = {"FFA", "Team-Based", "Everyone"},
    Callback = function(Value)
        teamCheck = Value
        if hitboxEnabled then updateHitboxes() end
    end
})
HitboxGroup:AddCheckbox("NoCollision", {
    Text = "No Collision",
    Default = false,
    Callback = function(Value)
        noCollisionEnabled = Value
        WarningText.Visible = Value
        if hitboxEnabled then updateHitboxes() end
    end
})
local TriggerGroup = Tabs.Main:AddRightGroupbox("Triggerbot")
getgenv().triggerb = false
local teamcheck = "Team-Based"
local delay = 0.2
local isAlive = true
TriggerGroup:AddCheckbox("EnableTriggerbot", {
    Text = "Enable Triggerbot",
    Default = false,
    Callback = function(Value) getgenv().triggerb = Value end
})
TriggerGroup:AddDropdown("TriggerTeamCheck", {
    Text = "Team Check Mode",
    Default = "Team-Based",
    Values = {"FFA", "Team-Based", "Everyone"},
    Callback = function(Value) teamcheck = Value end
})
TriggerGroup:AddSlider("ShotDelay", {
    Text = "Shot Delay",
    Default = 2,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Callback = function(Value) delay = Value / 10 end
})
local function isEnemy(targetPlayer)
    if teamcheck == "FFA" then return true
    elseif teamcheck == "Everyone" then return targetPlayer ~= player
    elseif teamcheck == "Team-Based" then return targetPlayer.Team ~= player.Team end
    return false
end
local function checkhealth()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.HealthChanged:Connect(function(health) isAlive = health > 0 end)
    end
end
player.CharacterAdded:Connect(checkhealth)
checkhealth()
local triggerConnection
triggerConnection = task.spawn(function()
    while true do
        if getgenv().triggerb and isAlive then
            local mouse = player:GetMouse()
            local target = mouse.Target
            if target and target.Parent:FindFirstChild("Humanoid") and target.Parent.Name ~= player.Name then
                local targetPlayer = Players:FindFirstChild(target.Parent.Name)
                if targetPlayer and isEnemy(targetPlayer) then
                    mouse1press()
                    task.wait(delay)
                    mouse1release()
                end
            end
        end
        task.wait()
    end
end)
table.insert(connections, {disconnect = function() task.cancel(triggerConnection) end})
local KillAllGroup = Tabs.Main:AddRightGroupbox("Kill All")
getgenv().KillAll = false
local runServiceConnection
local mouseDown = false
KillAllGroup:AddCheckbox("KillAll", {
    Text = "Kill All",
    Default = false,
    Callback = function(Value)
        getgenv().KillAll = Value
        ReplicatedStorage.wkspc.CurrentCurse.Value = Value and "Infinite Ammo" or ""
         
        local function closestplayer()
            local closestDistance = math.huge
            local closestPlayer = nil
            for _, enemyPlayer in pairs(Players:GetPlayers()) do
                if enemyPlayer ~= player and enemyPlayer.TeamColor ~= player.TeamColor and enemyPlayer.Character then
                    local character = enemyPlayer.Character
                    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                    local humanoid = character:FindFirstChild("Humanoid")
                    if humanoidRootPart and humanoid and humanoid.Health > 0 then
                        local distance = (player.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
                        if distance < closestDistance then
                            closestDistance = distance
                            closestPlayer = enemyPlayer
                        end
                    end
                end
            end
            return closestPlayer
        end
        local function KillAllFunc()
            ReplicatedStorage.wkspc.TimeScale.Value = 12
            runServiceConnection = RunService.Stepped:Connect(function()
                if getgenv().KillAll then
                    local closestPlayer = closestplayer()
                    if closestPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local enemyRootPart = closestPlayer.Character.HumanoidRootPart
                        local targetPosition = enemyRootPart.Position - enemyRootPart.CFrame.LookVector * 2 + Vector3.new(0, 2, 0)
                        player.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
                        if closestPlayer.Character:FindFirstChild("Head") then
                            local enemyHead = closestPlayer.Character.Head.Position
                            Workspace.CurrentCamera.CFrame = CFrame.new(Workspace.CurrentCamera.CFrame.Position, enemyHead)
                        end
                        if not mouseDown then
                            mouse1press()
                            mouseDown = true
                        end
                    else
                        if mouseDown then
                            mouse1release()
                            mouseDown = false
                        end
                    end
                else
                    if runServiceConnection then runServiceConnection:Disconnect() runServiceConnection = nil end
                    if mouseDown then mouse1release() mouseDown = false end
                end
            end)
        end
        local function onCharacterAdded(character)
            task.wait(0.5)
            KillAllFunc()
        end
        player.CharacterAdded:Connect(onCharacterAdded)
        if Value then
            task.wait(0.5)
            KillAllFunc()
        else
            ReplicatedStorage.wkspc.CurrentCurse.Value = ""
            getgenv().KillAll = false
            ReplicatedStorage.wkspc.TimeScale.Value = 1
            if runServiceConnection then runServiceConnection:Disconnect() runServiceConnection = nil end
            if mouseDown then mouse1release() mouseDown = false end
        end
    end
})



local GunGroup = Tabs.Gun:AddLeftGroupbox("Overpower Gun")
local SettingsInfinite = false
local originalValues = {FireRate = {}, ReloadTime = {}, EReloadTime = {}, Auto = {}, Spread = {}, Recoil = {}}
GunGroup:AddCheckbox("InfiniteAmmo", {
    Text = "Infinite Ammo",
    Default = false,
    Callback = function(Value)
        SettingsInfinite = Value
        if SettingsInfinite then
            task.spawn(function()
                while SettingsInfinite do
                    pcall(function()
                        local playerGui = player.PlayerGui
                        playerGui.GUI.Client.Variables.ammocount.Value = 99
                        playerGui.GUI.Client.Variables.ammocount2.Value = 99
                    end)
                    task.wait()
                end
            end)
        end
    end
})
GunGroup:AddCheckbox("FastReload", {
    Text = "Fast Reload",
    Default = false,
    Callback = function(Value)
        for _, v in pairs(ReplicatedStorage.Weapons:GetChildren()) do
            if v:FindFirstChild("ReloadTime") then
                if Value then
                    if not originalValues.ReloadTime[v] then originalValues.ReloadTime[v] = v.ReloadTime.Value end
                    v.ReloadTime.Value = 0.01
                else
                    v.ReloadTime.Value = originalValues.ReloadTime[v] or 0.8
                end
            end
            if v:FindFirstChild("EReloadTime") then
                if Value then
                    if not originalValues.EReloadTime[v] then originalValues.EReloadTime[v] = v.EReloadTime.Value end
                    v.EReloadTime.Value = 0.01
                else
                    v.EReloadTime.Value = originalValues.EReloadTime[v] or 0.8
                end
            end
        end
    end
})
GunGroup:AddCheckbox("FastFireRate", {
    Text = "Fast Fire Rate",
    Default = false,
    Callback = function(Value)
        for _, v in pairs(ReplicatedStorage.Weapons:GetDescendants()) do
            if v.Name == "FireRate" or v.Name == "BFireRate" then
                if Value then
                    if not originalValues.FireRate[v] then originalValues.FireRate[v] = v.Value end
                    v.Value = 0.02
                else
                    v.Value = originalValues.FireRate[v] or 0.8
                end
            end
        end
    end
})
GunGroup:AddCheckbox("AlwaysAuto", {
    Text = "Always Auto",
    Default = false,
    Callback = function(Value)
        for _, v in pairs(ReplicatedStorage.Weapons:GetDescendants()) do
            if v.Name == "Auto" or v.Name == "AutoFire" or v.Name == "Automatic" or v.Name == "AutoShoot" or v.Name == "AutoGun" then
                if Value then
                    if not originalValues.Auto[v] then originalValues.Auto[v] = v.Value end
                    v.Value = true
                else
                    v.Value = originalValues.Auto[v] or false
                end
            end
        end
    end
})
GunGroup:AddCheckbox("NoSpread", {
    Text = "No Spread",
    Default = false,
    Callback = function(Value)
        for _, v in pairs(ReplicatedStorage.Weapons:GetDescendants()) do
            if v.Name == "MaxSpread" or v.Name == "Spread" or v.Name == "SpreadControl" then
                if Value then
                    if not originalValues.Spread[v] then originalValues.Spread[v] = v.Value end
                    v.Value = 0
                else
                    v.Value = originalValues.Spread[v] or 1
                end
            end
        end
    end
})
GunGroup:AddCheckbox("NoRecoil", {
    Text = "No Recoil",
    Default = false,
    Callback = function(Value)
        for _, v in pairs(ReplicatedStorage.Weapons:GetDescendants()) do
            if v.Name == "RecoilControl" or v.Name == "Recoil" then
                if Value then
                    if not originalValues.Recoil[v] then originalValues.Recoil[v] = v.Value end
                    v.Value = 0
                else
                    v.Value = originalValues.Recoil[v] or 1
                end
            end
        end
    end
})
local FlyGroup = Tabs.Player:AddLeftGroupbox("Fly Hacks")
local flySettings = {fly = false, flyspeed = 50}
local c, h, bv, bav, cam, flying
local buttons = {W=false, S=false, A=false, D=false, Moving=false}
local startFly = function()
    if not player.Character or not player.Character.Head or flying then return end
    c = player.Character
    h = c.Humanoid
    h.PlatformStand = true
    cam = Workspace:WaitForChild('Camera')
    bv = Instance.new("BodyVelocity")
    bav = Instance.new("BodyAngularVelocity")
    bv.Velocity, bv.MaxForce, bv.P = Vector3.new(0,0,0), Vector3.new(10000,10000,10000), 1000
    bav.AngularVelocity, bav.MaxTorque, bav.P = Vector3.new(0,0,0), Vector3.new(10000,10000,10000), 1000
    bv.Parent, bav.Parent = c.Head, c.Head
    flying = true
    h.Died:connect(function() flying = false end)
end
local endFly = function()
    if not player.Character or not flying then return end
    h.PlatformStand = false
    bv:Destroy()
    bav:Destroy()
    flying = false
end
UserInputService.InputBegan:connect(function(input, GPE)
    if GPE then return end
    for i,_ in pairs(buttons) do
        if i ~= "Moving" and input.KeyCode == Enum.KeyCode[i] then
            buttons[i] = true
            buttons.Moving = true
        end
    end
end)
UserInputService.InputEnded:connect(function(input, GPE)
    if GPE then return end
    local a = false
    for i,_ in pairs(buttons) do
        if i ~= "Moving" then
            if input.KeyCode == Enum.KeyCode[i] then buttons[i] = false end
            if buttons[i] then a = true end
        end
    end
    buttons.Moving = a
end)
local setVec = function(vec) return vec * (flySettings.flyspeed / vec.Magnitude) end
local flyConnection = RunService.Heartbeat:Connect(function(step)
    if flying and c and c.PrimaryPart then
        local p = c.PrimaryPart.Position
        local cf = cam.CFrame
        local ax, ay, az = cf:toEulerAnglesXYZ()
        c:SetPrimaryPartCFrame(CFrame.new(p.x, p.y, p.z) * CFrame.Angles(ax, ay, az))
        if buttons.Moving then
            local t = Vector3.new()
            if buttons.W then t = t + setVec(cf.lookVector) end
            if buttons.S then t = t - setVec(cf.lookVector) end
            if buttons.A then t = t - setVec(cf.rightVector) end
            if buttons.D then t = t + setVec(cf.rightVector) end
            c:TranslateBy(t * step)
        end
    end
end)
table.insert(connections, {disconnect = function() flyConnection:Disconnect() end})
FlyGroup:AddCheckbox("Fly", {
    Text = "Fly",
    Default = false,
    Callback = function(Value)
        flySettings.fly = Value
        if Value then startFly() else endFly() end
    end
})
FlyGroup:AddSlider("FlySpeed", {
    Text = "Fly Speed",
    Default = 50,
    Min = 1,
    Max = 500,
    Rounding = 0,
    Callback = function(Value) flySettings.flyspeed = Value end
})
local SpeedGroup = Tabs.Player:AddLeftGroupbox("Speed Power")
local settings = {WalkSpeed = 16}
local isWalkSpeedEnabled = false
local walkMethods = {"Velocity", "Vector", "CFrame"}
local selectedWalkMethod = walkMethods[1]
SpeedGroup:AddCheckbox("CustomWalkSpeed", {
    Text = "Custom WalkSpeed",
    Default = false,
    Callback = function(Value) isWalkSpeedEnabled = Value end
})
SpeedGroup:AddDropdown("WalkMethod", {
    Text = "Walk Method",
    Default = "Velocity",
    Values = walkMethods,
    Callback = function(Value) selectedWalkMethod = Value end
})
SpeedGroup:AddSlider("WalkspeedPower", {
    Text = "Walkspeed Power",
    Default = 16,
    Min = 16,
    Max = 500,
    Rounding = 0,
    Callback = function(Value) settings.WalkSpeed = Value end
})
local speedConnection
speedConnection = task.spawn(function()
    while true do
        if isWalkSpeedEnabled then
            local plr = Players.LocalPlayer
            if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local character = plr.Character
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if humanoid and rootPart then
                    local VS = humanoid.MoveDirection * settings.WalkSpeed
                    if selectedWalkMethod == "Velocity" then
                        rootPart.Velocity = Vector3.new(VS.X, rootPart.Velocity.Y, VS.Z)
                    elseif selectedWalkMethod == "Vector" then
                        local scaleFactor = 0.0001
                        rootPart.CFrame = rootPart.CFrame + (VS * RunService.Heartbeat:Wait() * scaleFactor)
                    elseif selectedWalkMethod == "CFrame" then
                        local scaleFactor = 0.0001
                        rootPart.CFrame = rootPart.CFrame + (humanoid.MoveDirection * settings.WalkSpeed * RunService.Heartbeat:Wait() * scaleFactor)
                    else
                        humanoid.WalkSpeed = settings.WalkSpeed
                    end
                end
            end
        end
        task.wait()
    end
end)
table.insert(connections, {disconnect = function() task.cancel(speedConnection) end})
local JumpGroup = Tabs.Player:AddLeftGroupbox("JumpPower")
local IJ = false
JumpGroup:AddCheckbox("InfiniteJump", {
    Text = "Infinite Jump",
    Default = false,
    Callback = function(Value)
        IJ = Value
        UserInputService.JumpRequest:Connect(function()
            if IJ then player.Character:FindFirstChildOfClass('Humanoid'):ChangeState("Jumping") end
        end)
    end
})
local isJumpPowerEnabled = false
local jumpMethods = {"Velocity", "Vector", "CFrame"}
local selectedJumpMethod = jumpMethods[1]
local jumpPower = 50
JumpGroup:AddCheckbox("CustomJumpPower", {
    Text = "Custom JumpPower",
    Default = false,
    Callback = function(Value) isJumpPowerEnabled = Value end
})
JumpGroup:AddDropdown("JumpMethod", {
    Text = "Jump Method",
    Default = "Velocity",
    Values = jumpMethods,
    Callback = function(Value) selectedJumpMethod = Value end
})
JumpGroup:AddSlider("ChangeJumpPower", {
    Text = "Change JumpPower",
    Default = 50,
    Min = 30,
    Max = 500,
    Rounding = 0,
    Callback = function(Value) jumpPower = Value end
})
local jumpConnection
jumpConnection = task.spawn(function()
    while true do
        if isJumpPowerEnabled then
            local plr = Players.LocalPlayer
            local humanoid = plr.Character:WaitForChild("Humanoid")
            humanoid.UseJumpPower = true
            humanoid.Jumping:Connect(function(isActive)
                if isActive then
                    local rootPart = plr.Character:FindFirstChild("HumanoidRootPart")
                    if rootPart then
                        if selectedJumpMethod == "Velocity" then
                            rootPart.Velocity = rootPart.Velocity * Vector3.new(1, 0, 1) + Vector3.new(0, jumpPower, 0)
                        elseif selectedJumpMethod == "Vector" then
                            rootPart.Velocity = Vector3.new(0, jumpPower, 0)
                        elseif selectedJumpMethod == "CFrame" then
                            plr.Character:SetPrimaryPartCFrame(plr.Character:GetPrimaryPartCFrame() + Vector3.new(0, jumpPower, 0))
                        end
                    end
                end
            end)
        end
        task.wait()
    end
end)
table.insert(connections, {disconnect = function() task.cancel(jumpConnection) end})
local AntiAimGroup = Tabs.Player:AddLeftGroupbox("Anti Aim")
local spinSpeed = 10
local gyro
AntiAimGroup:AddCheckbox("AntiAim", {
    Text = "Anti-Aim",
    Default = false,
    Callback = function(Value)
        local character = player.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        if Value then
            if humanoidRootPart then
                local spin = Instance.new("BodyAngularVelocity")
                spin.Name = "AntiAimSpin"
                spin.AngularVelocity = Vector3.new(0, spinSpeed, 0)
                spin.MaxTorque = Vector3.new(0, math.huge, 0)
                spin.P = 500000
                spin.Parent = humanoidRootPart
                gyro = Instance.new("BodyGyro")
                gyro.Name = "AntiAimGyro"
                gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                gyro.CFrame = humanoidRootPart.CFrame
                gyro.P = 3000
                gyro.Parent = humanoidRootPart
            end
        else
            if humanoidRootPart then
                local spin = humanoidRootPart:FindFirstChild("AntiAimSpin")
                if spin then spin:Destroy() end
                if gyro then gyro:Destroy() gyro = nil end
            end
        end
    end
})
AntiAimGroup:AddSlider("SpinSpeed", {
    Text = "Spin Speed",
    Default = 10,
    Min = 10,
    Max = 100,
    Rounding = 0,
    Callback = function(Value)
        spinSpeed = Value
        local character = player.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            local spin = humanoidRootPart:FindFirstChild("AntiAimSpin")
            if spin then spin.AngularVelocity = Vector3.new(0, spinSpeed, 0) end
        end
    end
})
local DebrisGroup = Tabs.Player:AddRightGroupbox("Object Teleport")
local debris_selected = "Both"
local debris_options = {"DeadHP", "DeadAmmo", "Both"}
local isCollecting = false
DebrisGroup:AddCheckbox("CollectDebris", {
    Text = "Enable Collect debris",
    Default = false,
    Callback = function(Value)
        isCollecting = Value
        if Value then managePickups() end
    end
})
DebrisGroup:AddDropdown("SelectObject", {
    Text = "Select Object",
    Default = "Both",
    Values = debris_options,
    Callback = function(Value) debris_selected = Value end
})
function managePickups()
    local debrisConnection
    debrisConnection = task.spawn(function()
        while isCollecting do
            task.wait(0.1)
            pcall(function()
                local character = player.Character
                if character then
                    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                    if humanoidRootPart then
                        for _, v in pairs(Workspace.Debris:GetChildren()) do
                            if (debris_selected == "DeadHP" and v.Name == "DeadHP") or
                               (debris_selected == "DeadAmmo" and v.Name == "DeadAmmo") or
                               (debris_selected == "Both" and (v.Name == "DeadHP" or v.Name == "DeadAmmo")) then
                                v.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0.2, 0)
                            end
                        end
                    end
                end
            end)
        end
    end)
    table.insert(connections, {disconnect = function() task.cancel(debrisConnection) end})
end
local MiscGroup = Tabs.Player:AddRightGroupbox("Useful Cheat")
MiscGroup:AddInput("TimeScale", {
    Text = "TimeScale",
    Default = "1",
    Numeric = false,
    Finished = true,
    Callback = function(Value) ReplicatedStorage.wkspc.TimeScale.Value = Value end
})
MiscGroup:AddSlider("FOVArsenal", {
    Text = "FOV",
    Default = 70,
    Min = 0,
    Max = 120,
    Rounding = 0,
    Callback = function(Value) player.Settings.FOV.Value = Value end
})
local isNoClipEnabled = false
MiscGroup:AddCheckbox("NoClip", {
    Text = "Toggle NoClip",
    Default = false,
    Callback = function(Value)
        isNoClipEnabled = Value
        local noclipConnection
        noclipConnection = task.spawn(function()
            while isNoClipEnabled do
                local character = player.Character
                if character then
                    for _, part in pairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
                RunService.Stepped:Wait()
            end
            local character = player.Character
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
            end
        end)
        table.insert(connections, {disconnect = function() task.cancel(noclipConnection) end})
    end
})
player.CharacterAdded:Connect(function(character)
    if isNoClipEnabled then
        task.spawn(function()
            while isNoClipEnabled do
                if character then
                    for _, part in pairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
                RunService.Stepped:Wait()
            end
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end)
    end
end)
local xrayOn = false
MiscGroup:AddCheckbox("Xray", {
    Text = "Toggle Xray",
    Default = false,
    Callback = function(Value)
        xrayOn = Value
        if xrayOn then
            for _, descendant in pairs(Workspace:GetDescendants()) do
                if descendant:IsA("BasePart") then
                    if not descendant:FindFirstChild("OriginalTransparency") then
                        local originalTransparency = Instance.new("NumberValue")
                        originalTransparency.Name = "OriginalTransparency"
                        originalTransparency.Value = descendant.Transparency
                        originalTransparency.Parent = descendant
                    end
                    descendant.Transparency = 0.5
                end
            end
        else
            for _, descendant in pairs(Workspace:GetDescendants()) do
                if descendant:IsA("BasePart") then
                    if descendant:FindFirstChild("OriginalTransparency") then
                        descendant.Transparency = descendant.OriginalTransparency.Value
                        descendant.OriginalTransparency:Destroy()
                    end
                end
            end
        end
    end
})

local RandomStuff = Tabs.Player:AddRightGroupbox("Random Stuff")

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local spinConnection
local rainbowConnection
local spinning = false
local rainbowing = false

local function startSpin()
	if spinConnection then spinConnection:Disconnect() end
	spinning = true
	spinConnection = RunService.Heartbeat:Connect(function()
		local character = player.Character
		if not character then return end
		local hrp = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
		if hrp then
			hrp.CFrame *= CFrame.Angles(0, math.rad(5), 0)
		end
	end)
end

local function stopSpin()
	spinning = false
	if spinConnection then
		spinConnection:Disconnect()
		spinConnection = nil
	end
end

player.CharacterAdded:Connect(function()
	if spinning then startSpin() end
	if rainbowing then
		local character = player.Character or player.CharacterAdded:Wait()
		for _, part in pairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Material = Enum.Material.Neon
			end
		end
	end
end)

RandomStuff:AddCheckbox("Spin", {
	Text = "Spin Player",
	Default = false,
	Callback = function(Value)
		if Value then
			startSpin()
		else
			stopSpin()
		end
	end
})

RandomStuff:AddCheckbox("RainbowSkin", {
	Text = "Rainbow Skin",
	Default = false,
	Callback = function(Value)
		if Value then
			rainbowing = true
			local hue = 0
			rainbowConnection = RunService.RenderStepped:Connect(function(dt)
				local character = player.Character
				if not character then return end
				hue = (hue + dt * 0.5) % 1
				local color = Color3.fromHSV(hue, 1, 1)
				for _, obj in pairs(character:GetDescendants()) do
					if obj:IsA("BasePart") then
						obj.Color = color
						obj.Material = Enum.Material.Neon
					elseif obj:IsA("Accessory") then
						local handle = obj:FindFirstChild("Handle")
						if handle then
							handle.Color = color
							handle.Material = Enum.Material.Neon
						end
					elseif obj:IsA("Clothing") or obj:IsA("ShirtGraphic") then
						obj:Destroy()
					end
				end
			end)
		else
			rainbowing = false
			if rainbowConnection then
				rainbowConnection:Disconnect()
				rainbowConnection = nil
			end
			local character = player.Character
			if character then
				for _, obj in pairs(character:GetDescendants()) do
					if obj:IsA("BasePart") then
						obj.Material = Enum.Material.Plastic
						obj.Color = Color3.new(1, 1, 1)
					end
				end
			end
		end
	end
})






local ESPSettings = Tabs.Visuals:AddLeftGroupbox("ESP Settings")
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
                        addESPWithDynamicColor(p.Character, p.DisplayName or p.Name, root, Color3.fromRGB(255, 0, 0))
                        playerEspElements[p] = {object = p.Character, root = root, added = true}
                    end
                end
                p.CharacterAdded:Connect(function(char)
                    task.wait(0.5)
                    local newRoot = char:FindFirstChild("HumanoidRootPart")
                    if newRoot and playerEspActive then
                        addESPWithDynamicColor(char, p.DisplayName or p.Name, newRoot, Color3.fromRGB(255, 0, 0))
                        playerEspElements[p] = {object = char, root = newRoot, added = true}
                    end
                end)
            end
            Players.PlayerAdded:Connect(function(p)
                p.CharacterAdded:Connect(function(char)
                    task.wait(0.5)
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if root and playerEspActive then
                        addESPWithDynamicColor(char, p.DisplayName or p.Name, root, Color3.fromRGB(255, 0, 0))
                        playerEspElements[p] = {object = char, root = root, added = true}
                    end
                end)
            end)
            local espUpdateConn = RunService.Heartbeat:Connect(function()
                if not playerEspActive then return end
                local lpRoot = playerRoot()
                if not lpRoot then return end
                for p, rec in pairs(playerEspElements) do
                    if p and p.Character and rec.object == p.Character then
                        local dist = distanceBetweenRootAndPart(rec.root)
                        if dist <= _G.ESPDistance then
                            if not rec.added then
                                addESPWithDynamicColor(rec.object, p.DisplayName or p.Name, rec.root, Color3.fromRGB(255, 0, 0))
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
            table.insert(connections, {disconnect = function() espUpdateConn:Disconnect() end})
        else
            for p, rec in pairs(playerEspElements) do
                if rec.added then ESP_Library:RemoveESP(rec.object) end
            end
            playerEspElements = {}
        end
    end
}):AddColorPicker("PlayerColor", {
    Default = Color3.fromRGB(255, 0, 0),
    Title = "Player Color",
    Callback = function(Value)
        for _, rec in pairs(playerEspElements) do
            if rec.added then ESP_Library:UpdateObjectColor(rec.object, Value) end
        end
    end
})



local LightingGroup = Tabs.Visuals:AddLeftGroupbox("Lighting")
local fullbrightEnabled = false
LightingGroup:AddCheckbox("Fullbright", {
    Text = "Fullbright",
    Default = false,
    Callback = function(Value)
        fullbrightEnabled = Value
        if Value then
            Lighting.Brightness = 2
            Lighting.Ambient = Color3.new(1,1,1)
            Lighting.OutdoorAmbient = Color3.new(1,1,1)
            Lighting.ClockTime = 14
        else
            Lighting.Brightness = 1
            Lighting.Ambient = Color3.new(0.4,0.4,0.4)
            Lighting.OutdoorAmbient = Color3.new(0.5,0.5,0.5)
            Lighting.ClockTime = 12
        end
    end
})
local PerformanceGroup = Tabs.Visuals:AddRightGroupbox("Performance")
local originalMaterials = {}
local originalDecalsTextures = {}
local originalLightingSettings = {GlobalShadows = Lighting.GlobalShadows, FogEnd = Lighting.FogEnd, Brightness = Lighting.Brightness}
local originalTerrainSettings = {
    WaterWaveSize = Workspace.Terrain.WaterWaveSize,
    WaterWaveSpeed = Workspace.Terrain.WaterWaveSpeed,
    WaterReflectance = Workspace.Terrain.WaterReflectance,
    WaterTransparency = Workspace.Terrain.WaterTransparency
}
local originalEffects = {}
PerformanceGroup:AddCheckbox("AntiLag", {
    Text = "Anti Lag",
    Default = false,
    Callback = function(Value)
        if Value then
            for _, O in pairs(Workspace:GetDescendants()) do
                if O:IsA("BasePart") and not O.Parent:FindFirstChild("Humanoid") then
                    originalMaterials[O] = O.Material
                    O.Material = Enum.Material.SmoothPlastic
                    if O:IsA("Texture") then
                        table.insert(originalDecalsTextures, O)
                        O:Destroy()
                    end
                end
            end
        else
            for O, material in pairs(originalMaterials) do
                if O and O:IsA("BasePart") then O.Material = material end
            end
            originalMaterials = {}
        end
    end
})
PerformanceGroup:AddCheckbox("FPSBoost", {
    Text = "FPS Boost",
    Default = false,
    Callback = function(Value)
        if Value then
            local g = game
            local w = g.Workspace
            local l = g.Lighting
            local t = w.Terrain
            originalTerrainSettings.WaterWaveSize = t.WaterWaveSize
            originalTerrainSettings.WaterWaveSpeed = t.WaterWaveSpeed
            originalTerrainSettings.WaterReflectance = t.WaterReflectance
            originalTerrainSettings.WaterTransparency = t.WaterTransparency
            t.WaterWaveSize = 0
            t.WaterWaveSpeed = 0
            t.WaterReflectance = 0
            t.WaterTransparency = 0
            l.GlobalShadows = false
            l.FogEnd = 9e9
            l.Brightness = 0
            settings().Rendering.QualityLevel = "Level01"
            for _, v in pairs(g:GetDescendants()) do
                if v:IsA("Part") or v:IsA("Union") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
                    originalMaterials[v] = v.Material
                    v.Material = "Plastic"
                    v.Reflectance = 0
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    table.insert(originalDecalsTextures, v)
                    v.Transparency = 1
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                    v.Lifetime = NumberRange.new(0)
                elseif v:IsA("Explosion") then
                    v.BlastPressure = 1
                    v.BlastRadius = 1
                elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") then
                    v.Enabled = false
                elseif v:IsA("MeshPart") then
                    originalMaterials[v] = v.Material
                    v.Material = "Plastic"
                    v.Reflectance = 0
                    v.TextureID = 10385902758728957
                end
            end
            for _, e in pairs(l:GetChildren()) do
                if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
                    originalEffects[e] = e.Enabled
                    e.Enabled = false
                end
            end
        else
            local t = Workspace.Terrain
            t.WaterWaveSize = originalTerrainSettings.WaterWaveSize
            t.WaterWaveSpeed = originalTerrainSettings.WaterWaveSpeed
            t.WaterReflectance = originalTerrainSettings.WaterReflectance
            t.WaterTransparency = originalTerrainSettings.WaterTransparency
            Lighting.GlobalShadows = originalLightingSettings.GlobalShadows
            Lighting.FogEnd = originalLightingSettings.FogEnd
            Lighting.Brightness = originalLightingSettings.Brightness
            settings().Rendering.QualityLevel = "Automatic"
            for v, material in pairs(originalMaterials) do
                if v and v:IsA("BasePart") then
                    v.Material = material
                    v.Reflectance = 0
                end
            end
            originalMaterials = {}
            for e, enabled in pairs(originalEffects) do
                if e then e.Enabled = enabled end
            end
            originalEffects = {}
            for _, v in pairs(originalDecalsTextures) do
                if v and v.Parent then v.Transparency = 0 end
            end
            originalDecalsTextures = {}
        end
    end
})
local fullBrightEnabled = false
PerformanceGroup:AddCheckbox("FullBright", {
    Text = "Full Bright",
    Default = false,
    Callback = function(Value)
        fullBrightEnabled = Value
        local Light = Lighting
        local function doFullBright()
            if fullBrightEnabled then
                Light.Ambient = Color3.new(1, 1, 1)
                Light.ColorShift_Bottom = Color3.new(1, 1, 1)
                Light.ColorShift_Top = Color3.new(1, 1, 1)
            else
                Light.Ambient = Color3.new(0.5, 0.5, 0.5)
                Light.ColorShift_Bottom = Color3.new(0, 0, 0)
                Light.ColorShift_Top = Color3.new(0, 0, 0)
            end
        end
        doFullBright()
        Light.LightingChanged:Connect(doFullBright)
    end
})
local ServerGroup = Tabs.Main:AddLeftGroupbox("Server")
ServerGroup:AddButton({
    Text = "Server Hop",
    Func = function()
        local placeID = game.PlaceId
        local allIDs = {}
        local foundAnything = ""
        local actualHour = os.date("!*t").hour
        local file = pcall(function()
            allIDs = game:GetService('HttpService'):JSONDecode(readfile("NotSameServers.json"))
        end)
        if not file then
            table.insert(allIDs, actualHour)
            writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(allIDs))
        end
        function teleportReturner()
            local site = foundAnything == "" and game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. placeID .. '/servers/Public?sortOrder=Asc&limit=100')) or game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. placeID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
            if site.nextPageCursor and site.nextPageCursor ~= "null" then foundAnything = site.nextPageCursor end
            for _, v in pairs(site.data) do
                local serverID = tostring(v.id)
                if tonumber(v.maxPlayers) > tonumber(v.playing) then
                    local possible = true
                    for _, existing in pairs(allIDs) do
                        if serverID == tostring(existing) then possible = false end
                    end
                    if possible then
                        table.insert(allIDs, serverID)
                        pcall(function()
                            writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(allIDs))
                            game:GetService("TeleportService"):TeleportToPlaceInstance(placeID, serverID, player)
                        end)
                    end
                end
            end
        end
        task.spawn(function()
            while task.wait() do
                pcall(teleportReturner)
            end
        end)
    end
})
ServerGroup:AddButton({
    Text = "Rejoin Server",
    Func = function() game:GetService("TeleportService"):Teleport(game.PlaceId, player) end
})
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
end
updateWatermark()
game:GetService('Players').LocalPlayer.Idled:Connect(function()
    game:GetService('VirtualUser'):CaptureController()
    game:GetService('VirtualUser'):ClickButton2(Vector2.new())
end)