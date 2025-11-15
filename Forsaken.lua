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
local versionURL = "https://raw.githubusercontent.com/ForsakenHub/ForsakenHub/main/version.txt"
local latestVersion = game:HttpGet(versionURL):gsub("%s+", "")
print("Latest Version:", latestVersion)
local Window = Library:CreateWindow({
    Title = "Ostium",
    Footer = latestVersion .. " | Ostium | By Velocity",
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
    Combat = Window:AddTab("Combat", "rocket"),
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
local playerData = player:WaitForChild("PlayerData")
local RemoteEvent = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent")
local purchasedEmotesFolder = playerData:WaitForChild("Purchased"):WaitForChild("Emotes")
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
local genEnabled = false
local genInterval = 1.25
local re = true
local Check = false
local lt = 0
local Old
Old = hookmetamethod(game, "__namecall", function(Self, ...)
    local Args = { ... }
    local Method = getnamecallmethod()
    if not checkcaller() and typeof(Self) == "Instance" then
        if Method == "InvokeServer" or Method == "FireServer" then
            if tostring(Self) == "RF" then
                if Args[1] == "enter" then
                    Check = true
                elseif Args[1] == "leave" then
                    Check = false
                end
            elseif tostring(Self) == "RE" then
                lt = os.clock()
            end
        end
    end
    return Old(Self, unpack(Args))
end)
RunService.Stepped:Connect(function()
    if genEnabled and Check and re and os.clock() - lt >= genInterval then
        re = false
        task.spawn(function()
            for _, gen in ipairs(Workspace.Map.Ingame:WaitForChild("Map"):GetChildren()) do
                if gen.Name == "Generator" and gen:FindFirstChild("Remotes") then
                    gen.Remotes.RE:FireServer()
                end
            end
            task.wait(genInterval)
            re = true
        end)
    end
end)
local camera = Workspace.CurrentCamera
local killersFolder = Workspace:WaitForChild("Players"):WaitForChild("Killers")
local survivorsFolder = Workspace:WaitForChild("Players"):WaitForChild("Survivors")
local trackedGenerators = {}
local espParts = {}
local ingame = Workspace:WaitForChild("Map"):WaitForChild("Ingame")
local dispenserPartNames = { "SprayCan", "UpperHolder", "Root" }
local sentryESPColor = Color3.fromRGB(128, 128, 128)
local CustomESP_tripwarePartNames = { "Hook1", "Hook2", "Wire" }
local CustomESP_subspaceColor = Color3.fromRGB(160, 32, 240)
local colorByName = {
    BloxyCola = Color3.fromRGB(255, 140, 0),
    Medkit = Color3.fromRGB(255, 100, 255),
}
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
getgenv().AimbotConfig = getgenv().AimbotConfig or {}
getgenv().AimbotConfig.Slash = getgenv().AimbotConfig.Slash or { Enabled = false, Smoothness = 1, Prediction = 0.25, Duration = 2 }
getgenv().AimbotConfig.Shoot = getgenv().AimbotConfig.Shoot or { Enabled = false, Smoothness = 1, Prediction = 0.25, Duration = 1.5 }
getgenv().AimbotConfig.Punch = getgenv().AimbotConfig.Punch or { Enabled = false, Smoothness = 1, Prediction = 0.25, Duration = 1.5 }
getgenv().AimbotConfig.TrueShoot = getgenv().AimbotConfig.TrueShoot or { Enabled = false, Smoothness = 1, Prediction = 0.6, Duration = 1.5 }
getgenv().AimbotConfig.ThrowPizza = getgenv().AimbotConfig.ThrowPizza or { Enabled = false, Smoothness = 1, Prediction = 0.25, Duration = 1.5 }
getgenv().AimbotConfig.Killers = getgenv().AimbotConfig.Killers or { Enabled = false, Duration = 3 }
getgenv().AimbotConfig.SelectedSkills = getgenv().AimbotConfig.SelectedSkills or {
    "Slash", "Punch", "Stab", "Nova", "VoidRush",
    "WalkspeedOverride", "Behead", "GashingWound",
    "CorruptNature", "CorruptEnergy", "MassInfection", "Entanglement"
}
getgenv().AimbotConfig.Mode = getgenv().AimbotConfig.Mode or "Aimlock"
local function isKillerSkill(skillName)
    for _, v in ipairs(getgenv().AimbotConfig.SelectedSkills) do
        if v == skillName then return true end
    end
    return false
end
local function getNearestTargetByDistance()
    local nearest
    local shortestDistance = math.huge
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    local myPos = myChar.HumanoidRootPart.Position
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (player.Character.HumanoidRootPart.Position - myPos).Magnitude
            if dist < shortestDistance then
                shortestDistance = dist
                nearest = player
            end
        end
    end
    return nearest
end
local function getNearestTargetByMaxHP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            if humanoid.MaxHealth > 300 then
                return player
            end
        end
    end
end
local function aimrootpart(target, duration, prediction, smoothness)
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not target or not target.Character then return end
    local root = target.Character:FindFirstChild("HumanoidRootPart")
    if not root or not myRoot then return end
    task.spawn(function()
        local start = tick()
        while tick() - start < duration and root.Parent and myRoot.Parent do
            local predictedPos = root.Position + (root.Velocity * prediction)
            local targetCFrame = CFrame.lookAt(myRoot.Position, predictedPos)
            myRoot.CFrame = myRoot.CFrame:Lerp(targetCFrame, math.clamp(smoothness, 0, 1))
            task.wait()
        end
    end)
end
local function aimlock(target, duration, prediction, smoothness)
    local start = tick()
    local cam = Workspace.CurrentCamera
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if tick() - start > duration or not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
            conn:Disconnect()
            return
        end
        local hrp = target.Character.HumanoidRootPart
        local pos = hrp.Position + (hrp.Velocity * prediction)
        local cf = CFrame.new(cam.CFrame.Position, pos)
        cam.CFrame = cam.CFrame:Lerp(cf, math.clamp(smoothness, 0, 1))
    end)
end
local function aimTarget(target, duration, prediction, smoothness)
    if not target then return end
    if getgenv().AimbotConfig.Mode == "Aimlock" then
        aimlock(target, duration, prediction, smoothness)
    elseif getgenv().AimbotConfig.Mode == "Root Lock" then
        aimrootpart(target, duration, prediction, smoothness)
    end
end
RemoteEvent.OnClientEvent:Connect(function(...)
    local args = { ... }
    if args[1] == "UseActorAbility" then
        local skill = args[2]
        local character = LocalPlayer.Character
        if skill == "Slash" and getgenv().AimbotConfig.Slash.Enabled and character and character.Name == "Shedletsky" then
            local target = getNearestTargetByMaxHP()
            aimTarget(target, getgenv().AimbotConfig.Slash.Duration, getgenv().AimbotConfig.Slash.Prediction, getgenv().AimbotConfig.Slash.Smoothness)
        end
        if skill == "Shoot" then
            if getgenv().AimbotConfig.Shoot.Enabled then
                local target = getNearestTargetByMaxHP()
                aimTarget(target, getgenv().AimbotConfig.Shoot.Duration, getgenv().AimbotConfig.Shoot.Prediction, getgenv().AimbotConfig.Shoot.Smoothness)
            end
            if getgenv().AimbotConfig.TrueShoot.Enabled then
                local target = getNearestTargetByMaxHP()
                aimlock(target, getgenv().AimbotConfig.TrueShoot.Duration, getgenv().AimbotConfig.TrueShoot.Prediction, getgenv().AimbotConfig.TrueShoot.Smoothness)
            end
        end
        if skill == "Punch" and getgenv().AimbotConfig.Punch.Enabled then
            local target = getNearestTargetByMaxHP()
            aimTarget(target, getgenv().AimbotConfig.Punch.Duration, getgenv().AimbotConfig.Punch.Prediction, getgenv().AimbotConfig.Punch.Smoothness)
        end
        if skill == "ThrowPizza" and getgenv().AimbotConfig.ThrowPizza.Enabled then
            local target = getNearestTargetByDistance()
            aimTarget(target, getgenv().AimbotConfig.ThrowPizza.Duration, getgenv().AimbotConfig.ThrowPizza.Prediction, getgenv().AimbotConfig.ThrowPizza.Smoothness)
        end
        if getgenv().AimbotConfig.Killers.Enabled and isKillerSkill(skill) then
            local target = getNearestTargetByDistance()
            aimTarget(target, getgenv().AimbotConfig.Killers.Duration, 0, 1)
        end
    end
end)
local staminaLoopToggle = false
local maxStamina = 100
local minStamina = 0
local staminaGain = 20
local staminaLoss = 10
local sprintSpeed = 26
local staminaLossDisabled = false
local autoPickupEnabled = true
local function isAlive(char)
    return char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0
end
local hasDropped = false
local RoundTimer = ReplicatedStorage:WaitForChild("RoundTimer")
RoundTimer:GetAttributeChangedSignal("TimeLeft"):Connect(function()
    if not autoPickupEnabled or hasDropped then return end
    local timeLeft = RoundTimer:GetAttribute("TimeLeft")
    if timeLeft and timeLeft <= 0.2 then
        local char = player.Character
        if not char then return end
        for _, v in pairs(player.Backpack:GetChildren()) do
            if v:IsA("Tool") then
                v.Parent = char
            end
        end
        task.wait()
        for _, v in pairs(char:GetChildren()) do
            if v:IsA("Tool") then
                v.Parent = Workspace
            end
        end
        hasDropped = true
    end
end)
task.spawn(function()
    while task.wait(1) do
        local char = player.Character
        if autoPickupEnabled and isAlive(char) then
            local mapIngame = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Ingame")
            if mapIngame then
                for _, tool in ipairs(mapIngame:GetChildren()) do
                    if tool:IsA("Tool") then
                        char.Humanoid:EquipTool(tool)
                    end
                end
            end
        end
    end
end)
_G.pickUpNear = false
_G.pickUpAll = false
local function autoPickUpLoop()
    while task.wait(0.2) do
        if not _G.pickUpNear and not _G.pickUpAll then break end
        pcall(function()
            local items = {}
            for _, v in pairs(Workspace.Map.Ingame:GetDescendants()) do
                if v:IsA("Tool") then
                    table.insert(items, v.ItemRoot)
                end
            end
            for _, v in pairs(items) do
                if _G.pickUpNear then
                    local magnitude = (player.Character.HumanoidRootPart.Position - v.Position).magnitude
                    if magnitude <= 10 then
                        fireproximityprompt(v.ProximityPrompt)
                    end
                end
                if _G.pickUpAll then
                    if not player.Backpack:FindFirstChild(v.Parent.Name) then
                        player.Character.HumanoidRootPart.CFrame = v.CFrame
                        task.wait(0.3)
                        fireproximityprompt(v.ProximityPrompt)
                    end
                end
            end
        end)
    end
end
local animationId = "75804462760596"
local animationSpeed = 0
local loopRunning = false
local loopThread
local currentAnim = nil
getgenv().FakeLag = {
    Active = false,
    targetRemoteName = "UnreliableRemoteEvent",
    blockedFirstArg = "UpdCF",
    delay = 0.1,
    lastSendTime = 0,
    Hooked = false
}
getgenv().FakeLag.Setup = function()
    if getgenv().FakeLag.Hooked then return end
    getgenv().FakeLag.SavedHook = hookmetamethod(game, "__namecall", function(self, ...)
        local methodName = getnamecallmethod()
        local arguments = { ... }
        if self.Name == getgenv().FakeLag.targetRemoteName and methodName == "FireServer" and arguments[1] == getgenv().FakeLag.blockedFirstArg then
            if getgenv().FakeLag.Active then
                local currentTime = tick()
                if currentTime - getgenv().FakeLag.lastSendTime < getgenv().FakeLag.delay then
                    return
                else
                    getgenv().FakeLag.lastSendTime = currentTime
                end
            end
        end
        return getgenv().FakeLag.SavedHook(self, ...)
    end)
    getgenv().FakeLag.Hooked = true
end
getgenv().FakeLag.Activate = function()
    getgenv().FakeLag.Active = true
end
getgenv().FakeLag.Deactivate = function()
    getgenv().FakeLag.Active = false
end
getgenv().FakeLag.Setup()
getgenv().Players = game:GetService("Players")
getgenv().MarketplaceService = game:GetService("MarketplaceService")
getgenv().RunService = game:GetService("RunService")
getgenv().player = getgenv().Players.LocalPlayer
getgenv().replacementAnimations = {
    idle = "rbxassetid://134624270247120",
    walk = "rbxassetid://132377038617766",
    run = "rbxassetid://115946474977409"
}
getgenv().animationNameCache = {}
getgenv().currentTrack = nil
getgenv().currentType = nil
getgenv().toggleEnabled = false
getgenv().getAnimationNameFromId = function(assetId)
    if getgenv().animationNameCache[assetId] then
        return getgenv().animationNameCache[assetId]
    end
    local success, info = pcall(function()
        return getgenv().MarketplaceService:GetProductInfo(assetId)
    end)
    if success and info and info.Name then
        getgenv().animationNameCache[assetId] = info.Name
        return info.Name
    end
    return nil
end
getgenv().playReplacementAnimation = function(animator, animType)
    if getgenv().currentTrack then
        getgenv().currentTrack:Stop()
    end
    local anim = Instance.new("Animation")
    anim.AnimationId = getgenv().replacementAnimations[animType]
    local track = animator:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Movement
    track:Play()
    getgenv().currentTrack = track
    getgenv().currentType = animType
end
getgenv().setupCharacter = function(char)
    local humanoid = char:WaitForChild("Humanoid")
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end
    getgenv().RunService.Heartbeat:Connect(function()
        if getgenv().toggleEnabled and getgenv().currentTrack then
            if getgenv().currentType == "idle" then
                getgenv().currentTrack:AdjustSpeed(1)
            elseif getgenv().currentType == "walk" then
                getgenv().currentTrack:AdjustSpeed(humanoid.WalkSpeed / 12)
            elseif getgenv().currentType == "run" then
                getgenv().currentTrack:AdjustSpeed(humanoid.WalkSpeed / 26)
            end
        end
    end)
    animator.AnimationPlayed:Connect(function(track)
        if getgenv().toggleEnabled then
            local animationId = track.Animation.AnimationId
            local assetId = animationId:match("%d+")
            if assetId then
                local animName = getgenv().getAnimationNameFromId(tonumber(assetId))
                if animName then
                    local lowerName = animName:lower()
                    if lowerName:find("idle") then
                        track:Stop()
                        getgenv().playReplacementAnimation(animator, "idle")
                    elseif lowerName:find("walk") then
                        track:Stop()
                        getgenv().playReplacementAnimation(animator, "walk")
                    elseif lowerName:find("run") then
                        track:Stop()
                        getgenv().playReplacementAnimation(animator, "run")
                    end
                end
            end
        end
    end)
end
if getgenv().player.Character then
    getgenv().setupCharacter(getgenv().player.Character)
end
getgenv().player.CharacterAdded:Connect(getgenv().setupCharacter)
local DoLoop = false
local genv = {}
genv.running = false
genv.animTrack = nil
genv.toggleValue = false
function genv.getCharacterHumanoid()
    local character = game:GetService("Players").LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    return character, humanoid
end
function genv.getAnimator(humanoid)
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end
    return animator
end
function genv.handleToggle(enabled)
    genv.running = enabled
    if not enabled and genv.animTrack then
        genv.animTrack:Stop()
        genv.animTrack = nil
    end
    local character, _ = genv.getCharacterHumanoid()
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.Transparency = enabled and rootPart.Transparency or 1
    end
end
local survivorValue = playerData:WaitForChild("Equipped"):WaitForChild("Survivor")
function genv.updateToggle()
    local character, humanoid = genv.getCharacterHumanoid()
    local isTarget = (survivorValue.Value == "007n7" or survivorValue.Value == "Noob" or survivorValue.Value == "TwoTime") and humanoid and humanoid.MaxHealth < 300
    genv.handleToggle(isTarget)
end
local SoundService = game:GetService("SoundService")
local folderPath = "Ostium/Assets"
if not isfolder("Ostium") then makefolder("Ostium") end
if not isfolder(folderPath) then makefolder(folderPath) end
getgenv().tracks = {
    ["None"] = "", ["----------- UST -----------"] = nil, ["A BRAVE SOUL (MS 4 Killer VS MS 4 Survivor)"] = "https://github.com/ForsakenHub/ForsakenHub/raw/refs/heads/main/A%20BRAVE%20SOUL%20(MS%204%20Killer%20VS%20MS%204%20Survivor).mp3",
}
local options = {
}
getgenv().currentLastSurvivor = nil
getgenv().currentSongId = nil
getgenv().originalSongId = nil
getgenv().isPlaying = false
getgenv().songStartTime = 0
getgenv().currentSongDuration = 0
getgenv().isToggleOn = false
function downloadTrack(name, audioUrl)
    local fullPath = folderPath .. "/" .. name:gsub("[^%w]", "_") .. ".mp3"
    if not isfile(fullPath) then
        local request = http_request or syn.request or request
        if not request then error("Executor does not support HTTP requests.") end
        local response = request({
            Url = audioUrl,
            Method = "GET",
            Headers = {
                ["User-Agent"] = "Mozilla/5.0",
                ["Accept"] = "*/*"
            }
        })
        local fileData = response.Body
        if (not fileData or #fileData == 0) and response.BodyRaw then
            fileData = response.BodyRaw
        end
        if fileData and #fileData > 0 then
            writefile(fullPath, fileData)
        end
    end
    return fullPath
end
function getLastSurvivor()
    local theme = Workspace:FindFirstChild("Themes")
    if theme then
        return theme:FindFirstChild("LastSurvivor")
    end
    return nil
end
function setLastSurvivorSong(songName)
    local lastSurvivor = getLastSurvivor()
    if not lastSurvivor then return end
    local url = tracks[songName]
    if not url then return end
    local path = downloadTrack(songName, url)
    local soundAsset = getcustomasset(path)
    if getgenv().isToggleOn and not getgenv().originalSongId then
        getgenv().originalSongId = lastSurvivor.SoundId
    end
    lastSurvivor.SoundId = soundAsset
    lastSurvivor.Loaded:Wait()
    getgenv().currentSongDuration = lastSurvivor.TimeLength
    lastSurvivor:Play()
    getgenv().songStartTime = tick()
    getgenv().isPlaying = true
    getgenv().currentLastSurvivor = lastSurvivor
end
getgenv().chatWindow = game:GetService("TextChatService"):WaitForChild("ChatWindowConfiguration")
getgenv().chatEnabled = false
getgenv().connection = nil
local function getEmoteList()
    local list = {}
    for _, emote in ipairs(purchasedEmotesFolder:GetChildren()) do
        table.insert(list, emote.Name)
    end
    return list
end
local emoteList = getEmoteList()
local selectedEmote = emoteList[1]
local emoteGuiMain = Instance.new("ScreenGui")
emoteGuiMain.Name = "CustomEmoteGuiMain"
emoteGuiMain.ResetOnSpawn = false
emoteGuiMain.DisplayOrder = 999998
emoteGuiMain.Enabled = false
emoteGuiMain.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local emoteGuiToggle = Instance.new("ScreenGui")
emoteGuiToggle.Name = "CustomEmoteGuiToggle"
emoteGuiToggle.ResetOnSpawn = false
emoteGuiToggle.DisplayOrder = 999999
emoteGuiToggle.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local toggleEmoteGuiButton = Instance.new("ImageButton")
toggleEmoteGuiButton.Size = UDim2.new(0, 60, 0, 60)
toggleEmoteGuiButton.Position = UDim2.new(0.05, 340, 0.05, -47.5)
toggleEmoteGuiButton.AnchorPoint = Vector2.new(0.5, 0.5)
toggleEmoteGuiButton.BackgroundTransparency = 1
toggleEmoteGuiButton.Image = "rbxassetid://73335752800725"
toggleEmoteGuiButton.ZIndex = 999999
toggleEmoteGuiButton.Parent = emoteGuiToggle
local survivorValue = playerData:WaitForChild("Equipped"):WaitForChild("Survivor")
local guiVisible = false
local function updateToggle()
    local isTarget = survivorValue.Value == "007n7"
    emoteGuiToggle.Enabled = isTarget
    if not isTarget then
        emoteGuiMain.Enabled = false
        guiVisible = false
    end
end
updateToggle()
survivorValue:GetPropertyChangedSignal("Value"):Connect(updateToggle)
local playButton = Instance.new("TextButton")
playButton.Size = UDim2.new(0, 160, 0, 36)
playButton.Position = UDim2.new(1, -204, 0, 150)
playButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
playButton.TextColor3 = Color3.new(1, 1, 1)
playButton.Font = Enum.Font.SourceSans
playButton.TextSize = 18
playButton.Text = "Boombox Clone (007n7)"
playButton.Parent = emoteGuiMain
local dropdownFrame = Instance.new("Frame")
dropdownFrame.Size = UDim2.new(0, 220, 0, 40)
dropdownFrame.Position = UDim2.new(1, -240, 0, 100)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
dropdownFrame.BorderSizePixel = 0
dropdownFrame.Parent = emoteGuiMain
local dropdownButton = Instance.new("TextButton")
dropdownButton.Size = UDim2.new(1, 0, 1, 0)
dropdownButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
dropdownButton.TextColor3 = Color3.new(1, 1, 1)
dropdownButton.Font = Enum.Font.SourceSans
dropdownButton.TextSize = 18
dropdownButton.Text = selectedEmote and ("Emote: " .. selectedEmote) or "Chọn Emote"
dropdownButton.Parent = dropdownFrame
local emoteListFrame = Instance.new("ScrollingFrame")
emoteListFrame.Size = UDim2.new(1, 0, 0, math.clamp(#emoteList, 1, 8) * 30)
emoteListFrame.Position = UDim2.new(0, 0, 1, 2)
emoteListFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
emoteListFrame.BorderSizePixel = 0
emoteListFrame.Visible = false
emoteListFrame.CanvasSize = UDim2.new(0, 0, 0, #emoteList * 30)
emoteListFrame.ScrollBarThickness = 6
emoteListFrame.Parent = dropdownFrame
local listLayout = Instance.new("UIListLayout")
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = emoteListFrame
local function populateDropdown(list)
    for _, child in ipairs(emoteListFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, name in ipairs(list) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -6, 0, 30)
        btn.Position = UDim2.new(0, 3, 0, 0)
        btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 16
        btn.Text = name
        btn.Parent = emoteListFrame
        btn.MouseButton1Click:Connect(function()
            selectedEmote = name
            dropdownButton.Text = "Emote: " .. name
            emoteListFrame.Visible = false
        end)
    end
    emoteListFrame.CanvasSize = UDim2.new(0, 0, 0, #list * 30)
    emoteListFrame.Size = UDim2.new(1, 0, 0, math.clamp(#list, 1, 8) * 30)
end
populateDropdown(emoteList)
dropdownButton.MouseButton1Click:Connect(function()
    emoteListFrame.Visible = not emoteListFrame.Visible
    if emoteListFrame.Visible then
        RemoteEvent:FireServer("StopEmote", "Animations", "0")
    end
end)
playButton.MouseButton1Click:Connect(function()
    if not selectedEmote then return end
    RemoteEvent:FireServer("PlayEmote", "Animations", selectedEmote)
    task.wait(0.001)
    RemoteEvent:FireServer("StopEmote", "Animations", selectedEmote)
    task.wait(0.001)
    RemoteEvent:FireServer("UseActorAbility", "Clone")
    emoteListFrame.Visible = false
end)
toggleEmoteGuiButton.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    emoteGuiMain.Enabled = guiVisible
    if not guiVisible then
        emoteListFrame.Visible = false
    end
end)
local emotes2 = getEmoteList()
local screenGui2 = Instance.new("ScreenGui")
screenGui2.DisplayOrder = 999999
screenGui2.Name = "EmoteGUI2"
screenGui2.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
screenGui2.ResetOnSpawn = false
screenGui2.ZIndexBehavior = Enum.ZIndexBehavior.Global
local background2 = Instance.new("Frame")
background2.Size = UDim2.new(0, 260, 0, 100)
background2.Position = UDim2.new(0, 0, 0.203, 0)
background2.BackgroundTransparency = 1
background2.BorderSizePixel = 0
background2.Visible = false
background2.Parent = screenGui2
local playButton2 = Instance.new("TextButton")
playButton2.Size = UDim2.new(0, 160, 0, 36)
playButton2.Position = UDim2.new(0, 50, 0, 60)
playButton2.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
playButton2.TextColor3 = Color3.new(1, 1, 1)
playButton2.Font = Enum.Font.SourceSans
playButton2.TextSize = 18
playButton2.Text = "Play Emote"
playButton2.Parent = background2
local dropdownFrame2 = Instance.new("Frame")
dropdownFrame2.Size = UDim2.new(0, 220, 0, 40)
dropdownFrame2.Position = UDim2.new(0, 20, 0, 10)
dropdownFrame2.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
dropdownFrame2.BorderSizePixel = 0
dropdownFrame2.Parent = background2
local dropdownButton2 = Instance.new("TextButton")
dropdownButton2.Size = UDim2.new(1, 0, 1, 0)
dropdownButton2.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
dropdownButton2.TextColor3 = Color3.new(1, 1, 1)
dropdownButton2.Font = Enum.Font.SourceSans
dropdownButton2.TextSize = 18
dropdownButton2.Text = emotes2[1] and ("Emote: " .. emotes2[1]) or "Chọn Emote"
dropdownButton2.Parent = dropdownFrame2
local emoteListFrame2 = Instance.new("ScrollingFrame")
emoteListFrame2.Size = UDim2.new(1, 0, 0, math.clamp(#emotes2, 1, 8) * 30)
emoteListFrame2.Position = UDim2.new(0, 0, 1, 2)
emoteListFrame2.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
emoteListFrame2.BorderSizePixel = 0
emoteListFrame2.Visible = false
emoteListFrame2.CanvasSize = UDim2.new(0, 0, 0, #emotes2 * 30)
emoteListFrame2.ScrollBarThickness = 6
emoteListFrame2.Parent = dropdownFrame2
local listLayout2 = Instance.new("UIListLayout")
listLayout2.FillDirection = Enum.FillDirection.Vertical
listLayout2.SortOrder = Enum.SortOrder.LayoutOrder
listLayout2.Parent = emoteListFrame2
local selectedEmote2 = emotes2[1]
local function populateDropdown2(list)
    for _, child in ipairs(emoteListFrame2:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, name in ipairs(list) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -6, 0, 30)
        btn.Position = UDim2.new(0, 3, 0, 0)
        btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 16
        btn.Text = name
        btn.Parent = emoteListFrame2
        btn.MouseButton1Click:Connect(function()
            selectedEmote2 = name
            dropdownButton2.Text = "Emote: " .. name
            emoteListFrame2.Visible = false
        end)
    end
    emoteListFrame2.CanvasSize = UDim2.new(0, 0, 0, #list * 30)
    emoteListFrame2.Size = UDim2.new(1, 0, 0, math.clamp(#list, 1, 8) * 30)
end
populateDropdown2(emotes2)
dropdownButton2.MouseButton1Click:Connect(function()
    emoteListFrame2.Visible = not emoteListFrame2.Visible
    if emoteListFrame2.Visible then
        RemoteEvent:FireServer("StopEmote", "Animations", "0")
    end
end)
playButton2.MouseButton1Click:Connect(function()
    if not selectedEmote2 then return end
    RemoteEvent:FireServer("PlayEmote", "Animations", selectedEmote2)
end)
local toggleButton2 = Instance.new("ImageButton")
toggleButton2.Size = UDim2.new(0, 60, 0, 60)
toggleButton2.Position = UDim2.new(0.05, 248, 0.05, -47.5)
toggleButton2.AnchorPoint = Vector2.new(0.5, 0.5)
toggleButton2.BackgroundTransparency = 1
toggleButton2.Image = "rbxassetid://87214736647237"
toggleButton2.Parent = screenGui2
toggleButton2.ZIndex = 200010
toggleButton2.MouseButton1Click:Connect(function()
    background2.Visible = not background2.Visible
    if background2.Visible then
        RemoteEvent:FireServer("StopEmote", "Animations", "0")
    end
end)
local function refreshAll()
    local newList = getEmoteList()
    emoteList = newList
    populateDropdown(newList)
    populateDropdown2(newList)
    if #newList > 0 then
        selectedEmote = selectedEmote or newList[1]
        selectedEmote2 = selectedEmote2 or newList[1]
        dropdownButton.Text = "Emote: " .. selectedEmote
        dropdownButton2.Text = "Emote: " .. selectedEmote2
    else
        selectedEmote = nil
        selectedEmote2 = nil
        dropdownButton.Text = "Choose Emote"
        dropdownButton2.Text = "Choose Emote"
    end
end
purchasedEmotesFolder.ChildAdded:Connect(refreshAll)
purchasedEmotesFolder.ChildRemoved:Connect(refreshAll)
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
    setclipboard("https://discord.gg/forsaken")
    Library:Notify("Discord link copied to clipboard!", 3)
end)
HomeGroup:AddButton("Website", function()
    setclipboard("https://forsakenhub.com")
    Library:Notify("Website link copied to clipboard!", 3)
end)
Tabs.Home:UpdateWarningBox({
    Title = "Changelogs",
    Text = [[
<font color="rgb(76, 0, 255)">Release v2.12</font>
- <font color="rgb(0, 255, 0)">skibidi relaesae</font>
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
local GeneratorGroup = Tabs.Combat:AddLeftGroupbox("Generators")
GeneratorGroup:AddCheckbox("AutoGenerator", {
    Text = "Auto Repair Generators",
    Default = false,
    Callback = function(Value)
        genEnabled = Value
    end
})
GeneratorGroup:AddSlider("GenInterval", {
    Text = "Repair Delay (Seconds)",
    Default = 1.25,
    Min = 1,
    Max = 15,
    Rounding = 0.25,
    Callback = function(Value)
        genInterval = Value
    end
})
local ESPSettings = Tabs.Visuals:AddRightGroupbox("ESP Settings")
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
local VisualsGroup = Tabs.Visuals:AddLeftGroupbox("Object ESP")
VisualsGroup:AddCheckbox("PlayerESP", {
    Text = "Player ESP",
    Default = false,
    Tooltip = "Highlights players with name and distance",
    Callback = function(Value)
        _G.PlayerESP_Elements = _G.PlayerESP_Elements or {}
        _G.PlayerESP_Color = _G.PlayerESP_Color or Color3.fromRGB(0, 255, 0)
         
        local function createRecordForCharacter(player, character)
            if not player or player == LocalPlayer then return end
            if not character or not character:IsA("Model") then return end
            local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
            if not root then return end
            _G.PlayerESP_Elements[player] = _G.PlayerESP_Elements[player] or {player = player, root = root, object = character, added = false}
            local rec = _G.PlayerESP_Elements[player]
            local dist = distanceBetweenRootAndPart(root)
            if dist <= _G.ESPDistance and not rec.added then
                addESPWithDynamicColor(rec.object, player.DisplayName or player.Name, rec.root, _G.PlayerESP_Color)
                rec.added = true
            elseif dist > _G.ESPDistance and rec.added then
                ESP_Library:RemoveESP(rec.object)
                rec.added = false
            end
        end
         
        local function removeForPlayer(player)
            local rec = _G.PlayerESP_Elements[player]
            if rec and rec.added then
                ESP_Library:RemoveESP(rec.object)
            end
            _G.PlayerESP_Elements[player] = nil
        end
         
        if Value then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    if player.Character then
                        createRecordForCharacter(player, player.Character)
                    end
                    player.CharacterAdded:Connect(function(char)
                        task.spawn(function()
                            task.wait(0.5)
                            createRecordForCharacter(player, char)
                        end)
                    end)
                    player.CharacterRemoving:Connect(function()
                        removeForPlayer(player)
                    end)
                end
            end
         
            _G.PlayerESP_PlayerAdded = Players.PlayerAdded:Connect(function(player)
                player.CharacterAdded:Connect(function(char)
                    task.spawn(function()
                        task.wait(0.5)
                        createRecordForCharacter(player, char)
                    end)
                end)
                player.CharacterRemoving:Connect(function()
                    removeForPlayer(player)
                end)
            end)
         
            _G.PlayerESP_PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
                removeForPlayer(player)
            end)
         
            _G.PlayerESP_Update = RunService.Heartbeat:Connect(function()
                local lpRoot = playerRoot()
                if not lpRoot then return end
                local toRemove = {}
                local espColor = getESPColor(_G.PlayerESP_Color)
                for player, rec in pairs(_G.PlayerESP_Elements) do
                    if not player or not player.Parent then
                        table.insert(toRemove, player)
                    else
                        local char = player.Character
                        local targetRoot = rec.root
                        if char and targetRoot and targetRoot.Parent and targetRoot:IsDescendantOf(char) then
                            local dist = (lpRoot.Position - targetRoot.Position).Magnitude
                            if dist <= _G.ESPDistance then
                                if not rec.added then
                                    addESPWithDynamicColor(rec.object, player.DisplayName or player.Name, targetRoot, _G.PlayerESP_Color)
                                    rec.added = true
                                else
                                    ESP_Library:UpdateObjectText(rec.object, player.DisplayName or player.Name)
                                    ESP_Library:UpdateObjectColor(rec.object, espColor)
                                end
                            else
                                if rec.added then
                                    ESP_Library:RemoveESP(rec.object)
                                    rec.added = false
                                end
                            end
                        else
                            table.insert(toRemove, player)
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
         
            for player, rec in pairs(_G.PlayerESP_Elements) do
                if rec and rec.added then
                    ESP_Library:RemoveESP(rec.object)
                end
                _G.PlayerESP_Elements[player] = nil
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
VisualsGroup:AddCheckbox("ItemESP", {
    Text = "Item ESP",
    Default = false,
    Tooltip = "Highlights items like BloxyCola and Medkit",
    Callback = function(Value)
        _G.ItemESP_Elements = _G.ItemESP_Elements or {}
        local function createRecordForItem(itemRoot)
            if not itemRoot or not itemRoot:IsA("BasePart") or not itemRoot.Parent then return end
            local tagName = itemRoot.Parent.Name
            local color = colorByName[tagName] or Color3.fromRGB(255, 255, 255)
            _G.ItemESP_Elements[itemRoot] = _G.ItemESP_Elements[itemRoot] or {root = itemRoot, object = itemRoot.Parent, added = false, color = color}
            local rec = _G.ItemESP_Elements[itemRoot]
            local dist = distanceBetweenRootAndPart(itemRoot)
            if dist <= _G.ESPDistance and not rec.added then
                addESPWithDynamicColor(rec.object, tagName, itemRoot, color)
                rec.added = true
            elseif dist > _G.ESPDistance and rec.added then
                ESP_Library:RemoveESP(rec.object)
                rec.added = false
            end
        end
        local function removeForItem(itemRoot)
            local rec = _G.ItemESP_Elements[itemRoot]
            if rec and rec.added then
                ESP_Library:RemoveESP(rec.object)
            end
            _G.ItemESP_Elements[itemRoot] = nil
        end
        if Value then
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") and v.Name == "ItemRoot" then
                    createRecordForItem(v)
                end
            end
            _G.ItemESP_DescendantAdded = Workspace.DescendantAdded:Connect(function(desc)
                if desc:IsA("BasePart") and desc.Name == "ItemRoot" then
                    task.spawn(function()
                        task.wait(0.1)
                        createRecordForItem(desc)
                    end)
                end
            end)
            _G.ItemESP_Update = RunService.Heartbeat:Connect(function()
                local lpRoot = playerRoot()
                if not lpRoot then return end
                local toRemove = {}
                for itemRoot, rec in pairs(_G.ItemESP_Elements) do
                    if not itemRoot or not itemRoot.Parent then
                        table.insert(toRemove, itemRoot)
                    else
                        local dist = (lpRoot.Position - itemRoot.Position).Magnitude
                        if dist <= _G.ESPDistance then
                            if not rec.added then
                                addESPWithDynamicColor(rec.object, itemRoot.Parent.Name, itemRoot, rec.color)
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
                for _, ir in ipairs(toRemove) do
                    removeForItem(ir)
                end
            end)
        else
            if _G.ItemESP_DescendantAdded then
                _G.ItemESP_DescendantAdded:Disconnect()
                _G.ItemESP_DescendantAdded = nil
            end
            if _G.ItemESP_Update then
                _G.ItemESP_Update:Disconnect()
                _G.ItemESP_Update = nil
            end
            for itemRoot, rec in pairs(_G.ItemESP_Elements) do
                if rec and rec.added then
                    ESP_Library:RemoveESP(rec.object)
                end
                _G.ItemESP_Elements[itemRoot] = nil
            end
            _G.ItemESP_Elements = {}
        end
    end
}):AddColorPicker("ItemESP_Color", {
    Default = Color3.fromRGB(255, 255, 255),
    Title = "Item Color",
    Callback = function(Value)
        _G.ItemESP_Color = Value
        local espColor = getESPColor(Value)
        for _, rec in pairs(_G.ItemESP_Elements or {}) do
            if rec and rec.added then
                ESP_Library:UpdateObjectColor(rec.object, espColor)
            end
        end
    end
})
VisualsGroup:AddCheckbox("GeneratorESP", {
    Text = "Generator ESP",
    Default = false,
    Tooltip = "Highlights generators and fake generators with progress",
    Callback = function(Value)
        _G.GeneratorESP_Elements = _G.GeneratorESP_Elements or {}
        local function createRecordForGenerator(gen)
            if not gen or not gen:IsA("Model") then return end
            local adornee = gen.PrimaryPart or gen:FindFirstChildWhichIsA("BasePart")
            if not adornee then return end
            local progress = gen:FindFirstChild("Progress")
            local text = gen.Name == "FakeGenerator" and "Fake Generator" or (progress and progress:IsA("ValueBase") and tostring(progress.Value) .. "%" or "Generator")
            local color = gen.Name == "FakeGenerator" and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(220, 150, 255)
            _G.GeneratorESP_Elements[gen] = _G.GeneratorESP_Elements[gen] or {object = gen, basePart = adornee, added = false, color = color, text = text}
            local rec = _G.GeneratorESP_Elements[gen]
            local dist = distanceBetweenRootAndPart(adornee)
            if dist <= _G.ESPDistance and not rec.added then
                addESPWithDynamicColor(rec.object, rec.text, rec.basePart, rec.color)
                rec.added = true
            elseif dist > _G.ESPDistance and rec.added then
                ESP_Library:RemoveESP(rec.object)
                rec.added = false
            end
        end
        local function removeForGenerator(gen)
            local rec = _G.GeneratorESP_Elements[gen]
            if rec and rec.added then
                ESP_Library:RemoveESP(rec.object)
            end
            _G.GeneratorESP_Elements[gen] = nil
        end
        if Value then
            local rootMap = Workspace:FindFirstChild("Map")
            if rootMap then
                local ingameMap = rootMap:FindFirstChild("Ingame")
                if ingameMap then
                    local gameMap = ingameMap:FindFirstChild("Map")
                    if gameMap then
                        for _, obj in ipairs(gameMap:GetDescendants()) do
                            if obj.Name == "Generator" or obj.Name == "FakeGenerator" then
                                createRecordForGenerator(obj)
                            end
                        end
                    end
                end
            end
            _G.GeneratorESP_DescendantAdded = Workspace.DescendantAdded:Connect(function(desc)
                if desc.Name == "Generator" or desc.Name == "FakeGenerator" then
                    task.spawn(function()
                        task.wait(0.1)
                        createRecordForGenerator(desc)
                    end)
                end
            end)
            _G.GeneratorESP_Update = RunService.Heartbeat:Connect(function()
                local lpRoot = playerRoot()
                if not lpRoot then return end
                local toRemove = {}
                for gen, rec in pairs(_G.GeneratorESP_Elements) do
                    if not gen or not gen.Parent then
                        table.insert(toRemove, gen)
                    else
                        local adornee = rec.basePart
                        if adornee and adornee.Parent then
                            local dist = (lpRoot.Position - adornee.Position).Magnitude
                            local progress = gen:FindFirstChild("Progress")
                            local newText = gen.Name == "FakeGenerator" and "Fake Generator" or (progress and progress:IsA("ValueBase") and tostring(progress.Value) .. "%" or "Generator")
                            rec.text = newText
                            if dist <= _G.ESPDistance then
                                if not rec.added then
                                    addESPWithDynamicColor(rec.object, newText, adornee, rec.color)
                                    rec.added = true
                                else
                                    ESP_Library:UpdateObjectText(rec.object, newText)
                                end
                            else
                                if rec.added then
                                    ESP_Library:RemoveESP(rec.object)
                                    rec.added = false
                                end
                            end
                        else
                            table.insert(toRemove, gen)
                        end
                    end
                end
                for _, g in ipairs(toRemove) do
                    removeForGenerator(g)
                end
            end)
        else
            if _G.GeneratorESP_DescendantAdded then
                _G.GeneratorESP_DescendantAdded:Disconnect()
                _G.GeneratorESP_DescendantAdded = nil
            end
            if _G.GeneratorESP_Update then
                _G.GeneratorESP_Update:Disconnect()
                _G.GeneratorESP_Update = nil
            end
            for gen, rec in pairs(_G.GeneratorESP_Elements) do
                if rec and rec.added then
                    ESP_Library:RemoveESP(rec.object)
                end
                _G.GeneratorESP_Elements[gen] = nil
            end
            _G.GeneratorESP_Elements = {}
        end
    end
}):AddColorPicker("GeneratorESP_Color", {
    Default = Color3.fromRGB(220, 150, 255),
    Title = "Generator Color",
    Callback = function(Value)
        _G.GeneratorESP_Color = Value
        local espColor = getESPColor(Value)
        for _, rec in pairs(_G.GeneratorESP_Elements or {}) do
            if rec and rec.added then
                ESP_Library:UpdateObjectColor(rec.object, espColor)
            end
        end
    end
})
VisualsGroup:AddCheckbox("BuildESP", {
    Text = "Build ESP",
    Default = false,
    Tooltip = "Highlights dispensers and sentries",
    Callback = function(Value)
        _G.BuildESP_Elements = _G.BuildESP_Elements or {}
        local function isDispenser(model)
            return model:IsA("Model") and model.Name:lower():find("dispenser")
        end
        local function isSentry(model)
            return model:IsA("Model") and model.Name:lower():find("sentry")
        end
        local function createRecordForBuild(part)
            if not part or not part:IsA("BasePart") or not part.Parent then return end
            local parent = part.Parent
            local isDisp = isDispenser(parent)
            local isSent = isSentry(parent)
            if not isDisp and not isSent then return end
            local text = isDisp and "Dispenser" or "Sentry"
            local color = isDisp and Color3.fromRGB(0, 162, 255) or sentryESPColor
            if table.find(dispenserPartNames, part.Name) or part.Name == "Root" then
                _G.BuildESP_Elements[parent] = _G.BuildESP_Elements[parent] or {object = parent, basePart = part, added = false, color = color, text = text}
                local rec = _G.BuildESP_Elements[parent]
                local dist = distanceBetweenRootAndPart(part)
                if dist <= _G.ESPDistance and not rec.added then
                    addESPWithDynamicColor(rec.object, text, part, color)
                    rec.added = true
                elseif dist > _G.ESPDistance and rec.added then
                    ESP_Library:RemoveESP(rec.object)
                    rec.added = false
                end
            end
        end
        local function removeForBuild(parent)
            local rec = _G.BuildESP_Elements[parent]
            if rec and rec.added then
                ESP_Library:RemoveESP(rec.object)
            end
            _G.BuildESP_Elements[parent] = nil
        end
        if Value then
            for _, part in ipairs(ingame:GetDescendants()) do
                if part:IsA("BasePart") then
                    createRecordForBuild(part)
                end
            end
            _G.BuildESP_DescendantAdded = ingame.DescendantAdded:Connect(function(desc)
                if desc:IsA("BasePart") then
                    task.spawn(function()
                        task.wait(0.1)
                        createRecordForBuild(desc)
                    end)
                end
            end)
            _G.BuildESP_Update = RunService.Heartbeat:Connect(function()
                local lpRoot = playerRoot()
                if not lpRoot then return end
                local toRemove = {}
                for parent, rec in pairs(_G.BuildESP_Elements) do
                    if not parent or not parent.Parent then
                        table.insert(toRemove, parent)
                    else
                        local part = rec.basePart
                        if part and part.Parent then
                            local dist = (lpRoot.Position - part.Position).Magnitude
                            if dist <= _G.ESPDistance then
                                if not rec.added then
                                    addESPWithDynamicColor(rec.object, rec.text, part, rec.color)
                                    rec.added = true
                                end
                            else
                                if rec.added then
                                    ESP_Library:RemoveESP(rec.object)
                                    rec.added = false
                                end
                            end
                        else
                            table.insert(toRemove, parent)
                        end
                    end
                end
                for _, p in ipairs(toRemove) do
                    removeForBuild(p)
                end
            end)
        else
            if _G.BuildESP_DescendantAdded then
                _G.BuildESP_DescendantAdded:Disconnect()
                _G.BuildESP_DescendantAdded = nil
            end
            if _G.BuildESP_Update then
                _G.BuildESP_Update:Disconnect()
                _G.BuildESP_Update = nil
            end
            for parent, rec in pairs(_G.BuildESP_Elements) do
                if rec and rec.added then
                    ESP_Library:RemoveESP(rec.object)
                end
                _G.BuildESP_Elements[parent] = nil
            end
            _G.BuildESP_Elements = {}
        end
    end
}):AddColorPicker("BuildESP_Color", {
    Default = Color3.fromRGB(0, 162, 255),
    Title = "Build Color",
    Callback = function(Value)
        _G.BuildESP_Color = Value
        local espColor = getESPColor(Value)
        for _, rec in pairs(_G.BuildESP_Elements or {}) do
            if rec and rec.added then
                ESP_Library:UpdateObjectColor(rec.object, espColor)
            end
        end
    end
})
VisualsGroup:AddCheckbox("TrapESP", {
    Text = "Trap ESP",
    Default = false,
    Tooltip = "Highlights tripwires and subspace mines",
    Callback = function(Value)
        _G.TrapESP_Elements = _G.TrapESP_Elements or {}
        local function isTripware(model)
            return model:IsA("Model") and model.Name:find("TaphTripwire") ~= nil
        end
        local function isSubspace(model)
            return model:IsA("Model") and model.Name == "SubspaceTripmine"
        end
        local function createRecordForTrap(part)
            if not part or not part:IsA("BasePart") or not part.Parent then return end
            local parent = part.Parent
            local isTrip = isTripware(parent)
            local isSub = isSubspace(parent)
            if not isTrip and not isSub then return end
            local text = isTrip and "Tripwire" or "Subspace Tripmine"
            local color = isTrip and Color3.fromRGB(255, 85, 0) or CustomESP_subspaceColor
            if table.find(CustomESP_tripwarePartNames, part.Name) or part.Name == "SubspaceBox" then
                _G.TrapESP_Elements[parent] = _G.TrapESP_Elements[parent] or {object = parent, basePart = part, added = false, color = color, text = text}
                local rec = _G.TrapESP_Elements[parent]
                local dist = distanceBetweenRootAndPart(part)
                if dist <= _G.ESPDistance and not rec.added then
                    addESPWithDynamicColor(rec.object, text, part, color)
                    rec.added = true
                elseif dist > _G.ESPDistance and rec.added then
                    ESP_Library:RemoveESP(rec.object)
                    rec.added = false
                end
            end
        end
        local function removeForTrap(parent)
            local rec = _G.TrapESP_Elements[parent]
            if rec and rec.added then
                ESP_Library:RemoveESP(rec.object)
            end
            _G.TrapESP_Elements[parent] = nil
        end
        if Value then
            for _, part in ipairs(ingame:GetDescendants()) do
                if part:IsA("BasePart") then
                    createRecordForTrap(part)
                end
            end
            _G.TrapESP_DescendantAdded = ingame.DescendantAdded:Connect(function(desc)
                if desc:IsA("BasePart") then
                    task.spawn(function()
                        task.wait(0.1)
                        createRecordForTrap(desc)
                    end)
                end
            end)
            _G.TrapESP_Update = RunService.Heartbeat:Connect(function()
                local lpRoot = playerRoot()
                if not lpRoot then return end
                local toRemove = {}
                for parent, rec in pairs(_G.TrapESP_Elements) do
                    if not parent or not parent.Parent then
                        table.insert(toRemove, parent)
                    else
                        local part = rec.basePart
                        if part and part.Parent then
                            local dist = (lpRoot.Position - part.Position).Magnitude
                            if dist <= _G.ESPDistance then
                                if not rec.added then
                                    addESPWithDynamicColor(rec.object, rec.text, part, rec.color)
                                    rec.added = true
                                end
                            else
                                if rec.added then
                                    ESP_Library:RemoveESP(rec.object)
                                    rec.added = false
                                end
                            end
                        else
                            table.insert(toRemove, parent)
                        end
                    end
                end
                for _, p in ipairs(toRemove) do
                    removeForTrap(p)
                end
            end)
        else
            if _G.TrapESP_DescendantAdded then
                _G.TrapESP_DescendantAdded:Disconnect()
                _G.TrapESP_DescendantAdded = nil
            end
            if _G.TrapESP_Update then
                _G.TrapESP_Update:Disconnect()
                _G.TrapESP_Update = nil
            end
            for parent, rec in pairs(_G.TrapESP_Elements) do
                if rec and rec.added then
                    ESP_Library:RemoveESP(rec.object)
                end
                _G.TrapESP_Elements[parent] = nil
            end
            _G.TrapESP_Elements = {}
        end
    end
}):AddColorPicker("TrapESP_Color", {
    Default = Color3.fromRGB(255, 85, 0),
    Title = "Trap Color",
    Callback = function(Value)
        _G.TrapESP_Color = Value
        local espColor = getESPColor(Value)
        for _, rec in pairs(_G.TrapESP_Elements or {}) do
            if rec and rec.added then
                ESP_Library:UpdateObjectColor(rec.object, espColor)
            end
        end
    end
})
local AimbotGroup = Tabs.Combat:AddRightGroupbox("Aimbot")
AimbotGroup:AddCheckbox("SlashAimbot", {
    Text = "Target Slash",
    Default = false,
    Callback = function(Value)
        getgenv().AimbotConfig.Slash.Enabled = Value
    end
})
AimbotGroup:AddSlider("SlashSmooth", {
    Text = "Smoothness Slash",
    Default = 100,
    Min = 0,
    Max = 101,
    Rounding = 1,
    Callback = function(Value)
        getgenv().AimbotConfig.Slash.Smoothness = Value / 100
    end
})
AimbotGroup:AddSlider("SlashPred", {
    Text = "Prediction Slash",
    Default = 0.25,
    Min = 0,
    Max = 2,
    Rounding = 0.05,
    Callback = function(Value)
        getgenv().AimbotConfig.Slash.Prediction = Value
    end
})
AimbotGroup:AddCheckbox("ShootAimbot", {
    Text = "Target One Shot",
    Default = false,
    Callback = function(Value)
        getgenv().AimbotConfig.Shoot.Enabled = Value
    end
})
AimbotGroup:AddSlider("ShootSmooth", {
    Text = "Smoothness One Shot",
    Default = 100,
    Min = 0,
    Max = 101,
    Rounding = 1,
    Callback = function(Value)
        getgenv().AimbotConfig.Shoot.Smoothness = Value / 100
    end
})
AimbotGroup:AddSlider("ShootPred", {
    Text = "Prediction One Shot",
    Default = 0.25,
    Min = 0,
    Max = 2,
    Rounding = 0.05,
    Callback = function(Value)
        getgenv().AimbotConfig.Shoot.Prediction = Value
    end
})
AimbotGroup:AddCheckbox("TrueShootAimbot", {
    Text = "Target True One Shot",
    Default = false,
    Callback = function(Value)
        getgenv().AimbotConfig.TrueShoot.Enabled = Value
    end
})
AimbotGroup:AddSlider("TrueShootSmooth", {
    Text = "Smoothness True One Shot",
    Default = 100,
    Min = 0,
    Max = 101,
    Rounding = 1,
    Callback = function(Value)
        getgenv().AimbotConfig.TrueShoot.Smoothness = Value / 100
    end
})
AimbotGroup:AddSlider("TrueShootPred", {
    Text = "Prediction True One Shot",
    Default = 0.6,
    Min = 0,
    Max = 2,
    Rounding = 0.05,
    Callback = function(Value)
        getgenv().AimbotConfig.TrueShoot.Prediction = Value
    end
})
AimbotGroup:AddCheckbox("PunchAimbot", {
    Text = "Target Punch",
    Default = false,
    Callback = function(Value)
        getgenv().AimbotConfig.Punch.Enabled = Value
    end
})
AimbotGroup:AddSlider("PunchSmooth", {
    Text = "Smoothness Punch",
    Default = 100,
    Min = 0,
    Max = 101,
    Rounding = 1,
    Callback = function(Value)
        getgenv().AimbotConfig.Punch.Smoothness = Value / 100
    end
})
AimbotGroup:AddSlider("PunchPred", {
    Text = "Prediction Punch",
    Default = 0.25,
    Min = 0,
    Max = 2,
    Rounding = 0.05,
    Callback = function(Value)
        getgenv().AimbotConfig.Punch.Prediction = Value
    end
})
AimbotGroup:AddCheckbox("ThrowPizzaAimbot", {
    Text = "Target Throw Pizza",
    Default = false,
    Callback = function(Value)
        getgenv().AimbotConfig.ThrowPizza.Enabled = Value
    end
})
AimbotGroup:AddSlider("ThrowSmooth", {
    Text = "Smoothness Throw Pizza",
    Default = 100,
    Min = 0,
    Max = 101,
    Rounding = 1,
    Callback = function(Value)
        getgenv().AimbotConfig.ThrowPizza.Smoothness = Value / 100
    end
})
AimbotGroup:AddSlider("ThrowPred", {
    Text = "Prediction Throw Pizza",
    Default = 0.25,
    Min = 0,
    Max = 2,
    Rounding = 0.2,
    Callback = function(Value)
        getgenv().AimbotConfig.ThrowPizza.Prediction = Value
    end
})
AimbotGroup:AddCheckbox("KillersAimbot", {
    Text = "Enemy Target",
    Default = false,
    Callback = function(Value)
        getgenv().AimbotConfig.Killers.Enabled = Value
    end
})
AimbotGroup:AddDropdown("AimMode", {
    Text = "Target Mode",
    Default = "Aimlock",
    Values = {"Aimlock", "RootPart"},
    Callback = function(Value)
        getgenv().AimbotConfig.Mode = Value
    end
})
local StaminaGroup = Tabs.Combat:AddLeftGroupbox("Stamina")
StaminaGroup:AddCheckbox("StaminaHack", {
    Text = "Custom Stamina",
    Default = false,
    Callback = function(Value)
        staminaLoopToggle = Value
    end
})
StaminaGroup:AddInput("MaxStam", {
    Text = "Max Stamina",
    Default = "100",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        maxStamina = tonumber(Value) or maxStamina
    end
})
StaminaGroup:AddInput("MinStam", {
    Text = "Min Stamina",
    Default = "0",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        minStamina = tonumber(Value) or minStamina
    end
})
StaminaGroup:AddInput("StamGain", {
    Text = "Stamina Gain",
    Default = "20",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        staminaGain = tonumber(Value) or staminaGain
    end
})
StaminaGroup:AddInput("StamLoss", {
    Text = "Stamina Loss",
    Default = "10",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        staminaLoss = tonumber(Value) or staminaLoss
    end
})
StaminaGroup:AddInput("SprintSpd", {
    Text = "Sprint Speed",
    Default = "26",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        sprintSpeed = tonumber(Value) or sprintSpeed
    end
})
StaminaGroup:AddCheckbox("NoStamLoss", {
    Text = "Disable Stamina Loss",
    Default = false,
    Callback = function(Value)
        staminaLossDisabled = Value
    end
})
task.spawn(function()
    local Sprinting = game:GetService("ReplicatedStorage"):WaitForChild("Systems"):WaitForChild("Character"):WaitForChild("Game"):WaitForChild("Sprinting")
    local stamina = require(Sprinting)
    local defaultValues = {
        MaxStamina = 100,
        MinStamina = 0,
        StaminaGain = 20,
        StaminaLoss = 10,
        SprintSpeed = 26,
    }
    while task.wait() do
        if staminaLoopToggle then
            stamina.MaxStamina = maxStamina
            stamina.MinStamina = minStamina
            stamina.StaminaGain = staminaGain
            stamina.StaminaLoss = staminaLoss
            stamina.SprintSpeed = sprintSpeed
            stamina.StaminaLossDisabled = staminaLossDisabled
        else
            stamina.MaxStamina = defaultValues.MaxStamina
            stamina.MinStamina = defaultValues.MinStamina
            stamina.StaminaGain = defaultValues.StaminaGain
        end
    end
end)
local PickupGroup = Tabs.Combat:AddRightGroupbox("Pickup")
PickupGroup:AddCheckbox("AutoPickup", {
    Text = "Auto Pickup Items",
    Default = false,
    Callback = function(Value)
        autoPickupEnabled = Value
    end
})
PickupGroup:AddCheckbox("PickupNear", {
    Text = "Pickup Near Items",
    Default = false,
    Callback = function(Value)
        _G.pickUpNear = Value
        if Value then
            task.spawn(autoPickUpLoop)
        end
    end
})
PickupGroup:AddCheckbox("PickupAll", {
    Text = "Pickup All Items",
    Default = false,
    Callback = function(Value)
        _G.pickUpAll = Value
        if Value then
            task.spawn(autoPickUpLoop)
        end
    end
})
local MiscGroup = Tabs.Combat:AddLeftGroupbox("Misc")
MiscGroup:AddCheckbox("Invisibility", {
    Text = "Invisibility",
    Default = false,
    Callback = function(Value)
        loopRunning = Value
        local speaker = Players.LocalPlayer
        if not speaker or not speaker.Character then return end
        local humanoid = speaker.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.RigType ~= Enum.HumanoidRigType.R6 then
            return
        end
        if Value then
            loopThread = task.spawn(function()
                while loopRunning do
                    local anim = Instance.new("Animation")
                    anim.AnimationId = "rbxassetid://" .. animationId
                    local loadedAnim = humanoid:LoadAnimation(anim)
                    currentAnim = loadedAnim
                    loadedAnim.Looped = false
                    loadedAnim:Play()
                    loadedAnim:AdjustSpeed(animationSpeed)
                    task.wait(0.000001)
                end
            end)
        else
            if loopThread then
                loopRunning = false
                task.cancel(loopThread)
            end
            if currentAnim then
                currentAnim:Stop()
                currentAnim = nil
            end
            local Humanoid = speaker.Character:FindFirstChildOfClass("Humanoid") or speaker.Character:FindFirstChildOfClass("AnimationController")
            if Humanoid then
                for _, v in pairs(Humanoid:GetPlayingAnimationTracks()) do
                    v:AdjustSpeed(100000)
                end
            end
            local animateScript = speaker.Character:FindFirstChild("Animate")
            if animateScript then
                animateScript.Disabled = true
                animateScript.Disabled = false
            end
        end
    end
})
MiscGroup:AddCheckbox("Ghosting", {
    Text = "CFrame Ghosting",
    Default = false,
    Callback = function(Value)
        if Value then
            getgenv().activateRemoteHook("UnreliableRemoteEvent", "UpdCF")
        else
            getgenv().deactivateRemoteHook("UnreliableRemoteEvent", "UpdCF")
        end
    end
})
MiscGroup:AddCheckbox("FakeLag", {
    Text = "Enable Fake Lag",
    Default = false,
    Callback = function(Value)
        if Value then
            getgenv().FakeLag.Activate()
        else
            getgenv().FakeLag.Deactivate()
        end
    end
})
MiscGroup:AddInput("LagDelay", {
    Text = "Delay (seconds)",
    Default = "0.1",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num > 0 then
            getgenv().FakeLag.delay = num
        end
    end
})
MiscGroup:AddCheckbox("FakeInjured", {
    Text = "Fake Injured Animations",
    Default = false,
    Callback = function(Value)
        getgenv().toggleEnabled = Value
        if not Value and getgenv().currentTrack then
            getgenv().currentTrack:Stop()
        end
    end
})
MiscGroup:AddCheckbox("AutoClosePopup", {
    Text = "Auto Close Popups",
    Default = false,
    Callback = function(Value)
        DoLoop = Value
        task.spawn(function()
            local player = game:GetService("Players").LocalPlayer
            local Survivors = Workspace:WaitForChild("Players"):WaitForChild("Survivors")
            while DoLoop and task.wait() do
                local temp = player.PlayerGui:FindFirstChild("TemporaryUI")
                if temp and temp:FindFirstChild("1x1x1x1Popup") then
                    temp["1x1x1x1Popup"]:Destroy()
                end
                for _, survivor in pairs(Survivors:GetChildren()) do
                    if survivor:GetAttribute("Username") == player.Name then
                        local speedMultipliers = survivor:FindFirstChild("SpeedMultipliers")
                        if speedMultipliers then
                            local val = speedMultipliers:FindFirstChild("SlowedStatus")
                            if val and val:IsA("NumberValue") then
                                val.Value = 1
                            end
                        end
                        local fovMultipliers = survivor:FindFirstChild("FOVMultipliers")
                        if fovMultipliers then
                            local val = fovMultipliers:FindFirstChild("SlowedStatus")
                            if val and val:IsA("NumberValue") then
                                val.Value = 1
                            end
                        end
                    end
                end
            end
        end)
    end
})
MiscGroup:AddCheckbox("InvisibleEffect", {
    Text = "Fully Invisible Effect",
    Default = false,
    Callback = function(Value)
        genv.toggleValue = Value
        if Value then
            genv.updateToggle()
        else
            genv.handleToggle(false)
        end
    end
})
survivorValue:GetPropertyChangedSignal("Value"):Connect(function()
    if genv.toggleValue then
        genv.updateToggle()
    end
end)
player.CharacterAdded:Connect(function(char)
    task.wait(0.1)
    if genv.toggleValue then
        genv.updateToggle()
    end
end)
RunService.Heartbeat:Connect(function()
    if not genv.running then return end
    local character, humanoid = genv.getCharacterHumanoid()
    if not character or not humanoid then return end
    local animator = genv.getAnimator(humanoid)
    local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local status = game:GetService("Players").LocalPlayer.PlayerGui.MainUI.StatusContainer:FindFirstChild("Invisibility")
    if humanoid.MaxHealth < 300 and torso and torso.Transparency ~= 0 and status then
        if not genv.animTrack or not genv.animTrack.IsPlaying then
            local animation = Instance.new("Animation")
            animation.AnimationId = "rbxassetid://75804462760596"
            genv.animTrack = animator:LoadAnimation(animation)
            genv.animTrack.Looped = true
            genv.animTrack:Play(0)
            genv.animTrack:AdjustSpeed(0)
            genv.animTrack.TimePosition = 0
            if rootPart then
                rootPart.Transparency = 0.4
            end
        end
    else
        if genv.animTrack and genv.animTrack.IsPlaying then
            genv.animTrack:Stop(0)
            genv.animTrack = nil
            if rootPart then
                rootPart.Transparency = 1
            end
        end
    end
end)
local LMSGroup = Tabs.Combat:AddRightGroupbox("LMS")
LMSGroup:AddCheckbox("LMSReplacer", {
    Text = "LMS Replacer Song",
    Default = false,
    Callback = function(Value)
        getgenv().isToggleOn = Value
        local lastSurvivor = getLastSurvivor()
        if not Value then
            if lastSurvivor and getgenv().originalSongId then
                lastSurvivor.SoundId = getgenv().originalSongId
                lastSurvivor:Play()
            end
            getgenv().currentLastSurvivor = nil
            getgenv().currentSongId = nil
            getgenv().originalSongId = nil
            getgenv().isPlaying = false
        end
    end
})
LMSGroup:AddDropdown("CustomLMSSong", {
    Text = "Custom LMS Song",
    Default = "None",
    Values = options,
    Callback = function(Value)
        getgenv().selectedSong = Value
    end
})
LMSGroup:AddInput("CustomSongURL", {
    Text = "Custom LMS Song URL",
    Default = "",
    Numeric = false,
    Finished = true,
    Callback = function(Value)
        if Value and Value ~= "" then
            getgenv().customSongUrl = Value
            local lastSurvivor = getLastSurvivor()
            if lastSurvivor and getgenv().isToggleOn then
                local path = downloadTrack("Custom_LMS_Song", getgenv().customSongUrl)
                local soundAsset = getcustomasset(path)
                if not getgenv().originalSongId then
                    getgenv().originalSongId = lastSurvivor.SoundId
                end
                lastSurvivor.SoundId = soundAsset
                lastSurvivor.Loaded:Wait()
                lastSurvivor:Play()
                getgenv().songStartTime = tick()
                getgenv().currentSongDuration = lastSurvivor.TimeLength
                getgenv().isPlaying = true
                getgenv().currentLastSurvivor = lastSurvivor
            end
        end
    end
})
RunService.Heartbeat:Connect(function()
    if getgenv().isToggleOn and not getgenv().isPlaying and getLastSurvivor() then
        setLastSurvivorSong(getgenv().selectedSong)
    elseif not getLastSurvivor() and getgenv().isPlaying then
        getgenv().isPlaying = false
    end
    if getgenv().isPlaying and lastSurvivor then
        if tick() - getgenv().songStartTime >= getgenv().currentSongDuration then
            getgenv().isPlaying = false
        end
    end
end)
local ChatGroup = Tabs.Combat:AddLeftGroupbox("Chat")
ChatGroup:AddCheckbox("ChatToggle", {
    Text = "Toggle Chat Visibility",
    Default = false,
    Callback = function(Value)
        getgenv().chatEnabled = Value
        if getgenv().chatEnabled then
            getgenv().connection = game:GetService("RunService").Heartbeat:Connect(function()
                getgenv().chatWindow.Enabled = true
            end)
        else
            if getgenv().connection then
                getgenv().connection:Disconnect()
                getgenv().connection = nil
            end
            getgenv().chatWindow.Enabled = false
        end
    end
})
local AchieveGroup = Tabs.Combat:AddRightGroupbox("Achievements")
AchieveGroup:AddButton("UnlockMeetBrandon", {
    Text = "[.] (Meet ogologl's best friend for the first time)",
    Func = function()
        local remote = game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent")
        remote:FireServer("UnlockAchievement", "MeetBrandon")
    end
})
AchieveGroup:AddButton("UnlockILoveCats", {
    Text = "[Meow meow meow] (Interact with the cat in the lobby more than 15 times)",
    Func = function()
        local remote = game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent")
        remote:FireServer("UnlockAchievement", "ILoveCats")
    end
})
AchieveGroup:AddButton("UnlockTVTIME", {
    Text = "[Coming straight from YOUR house.] (??? - I Love TV)",
    Func = function()
        local remote = game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent")
        remote:FireServer("UnlockAchievement", "TVTIME")
    end
})
AchieveGroup:AddButton("UnlockMeetDemophon", {
    Text = "[A Captain and his Ship] (Hear his tale)",
    Func = function()
        local remote = game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent")
        remote:FireServer("UnlockAchievement", "MeetDemophon")
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
local ServerGroup = Tabs.Combat:AddRightGroupbox("Server")
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
        Library:SetWatermark(string.format("Ostium | By Velocity | %d FPS | %d ms | %s", math.floor(fps), math.floor(ping), latestVersion))
    end)
end
updateWatermark()
game:GetService('Players').LocalPlayer.Idled:Connect(function()
    game:GetService('VirtualUser'):CaptureController()
    game:GetService('VirtualUser'):ClickButton2(Vector2.new())
end)