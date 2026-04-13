local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- */  WindUI Initialization  /* --
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- */  Game Variables & References  /* --
local plr = game.Players.LocalPlayer
local map = workspace:WaitForChild("Map")
local npcFolder = workspace:WaitForChild("NPCs")

local stage1 = map.Stage:FindFirstChild("LavaStage")
local stage2 = map.Stage:FindFirstChild("LavaStage2")
local stage3 = map.Stage:FindFirstChild("Stage3")
local stage4 = map.Stage:FindFirstChild("Stage4")

-- Логика пуль
local bBullets = false
local bsize = Vector3.new(2, 2, 2)

-- */  Helper Functions  /* --
local function destroy(obj)
    if obj then obj:Destroy() end
end

local function createPlatform(pos, rot, size)
    local mPlatform = stage4 and stage4:FindFirstChild("Moving Platform")
    local plat = (mPlatform and mPlatform:Clone()) or Instance.new("Part")
    
    for _, child in pairs(plat:GetChildren()) do child:Destroy() end

    plat.Name = "SafePlatform"
    plat.Material = Enum.Material.SmoothPlastic
    plat.BrickColor = BrickColor.new("Bright green")
    plat.Transparency = 0.3
    plat.Size = Vector3.new(size[1], size[2], size[3])
    plat.Anchored = true
    plat.CanCollide = true
    
    local rotation = CFrame.Angles(math.rad(rot[1]), math.rad(rot[2]), math.rad(rot[3]))
    plat.CFrame = CFrame.new(Vector3.new(pos[1], pos[2], pos[3])) * rotation
    plat.Parent = workspace
    return plat
end

local function spawnPaths()
    createPlatform({22.999, -0.697, 307}, {0,0,0}, {20, 1.4, 20})
    createPlatform({-5.706, 2.205, 284.952}, {0, 135, 5}, {72, 1.4, 20})
    createPlatform({-48.654, 8.195, 278.744}, {0, 35, 0}, {38.823, 1.4, 20})
    createPlatform({-82.952, 3.942, 292.389}, {0, 10, 10}, {47.823, 1.4, 20})
    createPlatform({-198.219, -0.245, 296.428}, {0, 0, 0}, {189.566, 1.4, 20})
end

local levelRanges = {
    {minX = 23,   maxX = 63,   minZ = 112, maxZ = 183, level = 3},
    {minX = -102, maxX = 193,  minZ = 267, maxZ = 334, level = 4},
    {minX = -402, maxX = -338, minZ = 266, maxZ = 396, level = 5},
}

local function getLevel(pos)
    for _, range in ipairs(levelRanges) do
        if pos.X >= range.minX and pos.X < range.maxX and pos.Z >= range.minZ and pos.Z < range.maxZ then return range.level end
    end
    return nil
end

local function findNPCs()
    local npcs = {}
    if not npcFolder then return npcs end
    for _, npc in ipairs(npcFolder:GetChildren()) do
        if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") then
            table.insert(npcs, {Instance = npc, Level = getLevel(npc.HumanoidRootPart.Position)})
        end
    end
    return npcs
end

-- */  WINDOW SETUP  /* --
local Window = WindUI:CreateWindow({
    Title = "Artly Hub | IWTT Game",
    Folder = "Artly_IWTT",
    Icon = "solar:bolt-circle-bold",
    OpenButton = { Enabled = true, Scale = 0.7 }
})

-- ==========================================
-- 1. INFO TAB
-- ==========================================
do
    local InfoTab = Window:Tab({ Title = "Info", Icon = "solar:info-circle-bold" })
    local Sec = InfoTab:Section({ Title = "Welcome " .. plr.Name })
    Sec:Section({ Title = "UI and scripts: Artly Hub (Ported)" })
    Sec:Section({ Title = "Warning: Beta Version", TextTransparency = 0.5 })
    Sec:Section({ Title = "Version: 2.0.1" })
end

-- ==========================================
-- 2. QUICK MENU TAB
-- ==========================================
do
    local QuickTab = Window:Tab({ Title = "Quick Menu", Icon = "solar:flash-drive-bold" })
    
    local BBSection = QuickTab:Section({ Title = "Big Bullets" })
    BBSection:Slider({
    Title = "Bullet Size",
    Min = 0.5,
    Max = 4,
    Step = 0.1, -- Шаг должен быть числом
    Default = 2,
    Callback = function(v)
        -- Добавляем проверку, чтобы скрипт не падал, если v вдруг придет кривой
        if v then
            bsize = Vector3.new(tonumber(v), tonumber(v), tonumber(v))
            print("New bullet size: " .. tostring(v))
        end
    end
})
    BBSection:Toggle({ Title = "Toggle Big Bullets", Callback = function(v) bBullets = v end })

    local GlobalSec = QuickTab:Section({ Title = "Global" })
    GlobalSec:Button({ Title = "Delete all lava", Callback = function() destroy(stage1.Lavas); destroy(stage2.Lavas); destroy(stage3.Lava) end })
    GlobalSec:Button({ Title = "Delete all traps and spikes", Callback = function() 
        destroy(stage2:FindFirstChild("Triggers")); destroy(stage3:FindFirstChild("Triggers"))
        destroy(stage4.FakeIsland.Trigger); destroy(stage4.FakeIsland.FakeButton); destroy(stage4.BlockTrap)
    end })
    GlobalSec:Button({ Title = "1hp all NPC's", Callback = function() for _, n in pairs(findNPCs()) do if n.Instance:FindFirstChild("Stats") then n.Instance.Stats:SetAttribute("health", 1) end end end })
    GlobalSec:Button({ Title = "Kill all NPC's", Callback = function() for _, n in pairs(findNPCs()) do if n.Instance:FindFirstChild("Stats") then n.Instance.Stats:SetAttribute("health", 0) end end end })
    GlobalSec:Button({ Title = "Create paths", Callback = spawnPaths })

    local SagatSec = QuickTab:Section({ Title = "Sagat Hint: Middle platform" })
    SagatSec:Button({ Title = "Kill boss", Callback = function() 
        local h = workspace.Map.Stage.Stage6.BossFight:FindFirstChild("Hitboxes")
        if h then h:SetAttribute("Health", 0); for _, p in pairs(h:GetDescendants()) do if p:IsA("BasePart") then p:Destroy() end end end
    end })
end

-- ==========================================
-- 3. LAVA TAB
-- ==========================================
do
    local LavaTab = Window:Tab({ Title = "Lava", Icon = "solar:fire-bold" })
    LavaTab:Section({ Title = "Global" }):Button({ Title = "Delete all lava", Callback = function() destroy(stage1.Lavas); destroy(stage2.Lavas); destroy(stage3.Lava) end })
    LavaTab:Section({ Title = "Stage 1" }):Button({ Title = "Delete lava", Callback = function() destroy(stage1.Lavas) end })
    LavaTab:Section({ Title = "Stage 2" }):Button({ Title = "Delete lava", Callback = function() destroy(stage2.Lavas) end })
    LavaTab:Section({ Title = "Stage 3" }):Button({ Title = "Delete lava", Callback = function() destroy(stage3.Lava) end })
end

-- ==========================================
-- 4. TRAPS TAB
-- ==========================================
do
    local TrapsTab = Window:Tab({ Title = "Traps", Icon = "solar:bomb-minimalistic-bold" })
    TrapsTab:Section({ Title = "Global" }):Button({ Title = "Delete all traps", Callback = function() 
        destroy(stage2:FindFirstChild("Triggers")); destroy(stage3:FindFirstChild("Triggers")); destroy(stage4.BlockTrap)
    end })
    TrapsTab:Section({ Title = "Stage 3" }):Button({ Title = "Delete traps", Callback = function() destroy(stage3:FindFirstChild("Triggers")) end })
    TrapsTab:Section({ Title = "Stage 4" }):Button({ Title = "Delete traps", Callback = function() destroy(stage4.BlockTrap) end })
end

-- ==========================================
-- 5. PATHS TAB
-- ==========================================
do
    local PathsTab = Window:Tab({ Title = "Paths", Icon = "solar:map-bold" })
    PathsTab:Section({ Title = "Stage 4" }):Button({ Title = "Create path", Callback = spawnPaths })
end

-- ==========================================
-- 6. NPCs TAB
-- ==========================================
do
    local NpcTab = Window:Tab({ Title = "NPC's", Icon = "solar:users-group-rounded-bold" })
    local G = NpcTab:Section({ Title = "Global" })
    G:Button({ Title = "1hp all NPC's", Callback = function() for _, n in pairs(findNPCs()) do if n.Instance:FindFirstChild("Stats") then n.Instance.Stats:SetAttribute("health", 1) end end end })
    G:Button({ Title = "Kill all NPC's", Callback = function() for _, n in pairs(findNPCs()) do if n.Instance:FindFirstChild("Stats") then n.Instance.Stats:SetAttribute("health", 0) end end end })

    for i = 3, 5 do
        local S = NpcTab:Section({ Title = "Stage " .. i })
        S:Button({ Title = "1hp NPC's", Callback = function() for _, n in pairs(findNPCs()) do if n.Level == i and n.Instance:FindFirstChild("Stats") then n.Instance.Stats:SetAttribute("health", 1) end end end })
        S:Button({ Title = "Kill NPC's", Callback = function() for _, n in pairs(findNPCs()) do if n.Level == i and n.Instance:FindFirstChild("Stats") then n.Instance.Stats:SetAttribute("health", 0) end end end })
    end
end

-- ==========================================
-- 7. BOSSES TAB
-- ==========================================
do
    local BossTab = Window:Tab({ Title = "Boss's", Icon = "solar:ghost-bold" })
    local Sagat = BossTab:Section({ Title = "Sagat, first 'mini-boss'" })
    Sagat:Button({ Title = "Kill Boss", Callback = function() 
        local h = workspace.Map.Stage.Stage6.BossFight:FindFirstChild("Hitboxes")
        if h then h:SetAttribute("Health", 0); for _, p in pairs(h:GetDescendants()) do if p:IsA("BasePart") then p:Destroy() end end end
    end })
    Sagat:Button({ Title = "Safe lava", Callback = function() 
        local l = workspace.Map.Stage.Stage6.SagatRoom:FindFirstChild("Lava")
        if l then l.BrickColor = BrickColor.new("dark Dark stone grey"); for _, p in pairs(l:GetChildren()) do p:Destroy() end end
    end })
end

-- ==========================================
-- SETTINGS TAB
-- ==========================================
do
    local SettingsTab = Window:Tab({ Title = "Settings", Icon = "solar:settings-bold" })
    local isOpened = true
    SettingsTab:Keybind({ Title = "Hide/Show Menu", Default = Enum.KeyCode.F, Callback = function() isOpened = not isOpened; if isOpened then Window:Open() else Window:Close() end end })
    SettingsTab:Button({ Title = "Unload Artly", Color = Color3.fromHex("#EF4F1D"), Callback = function() Window:Destroy() end })
end

-- */  Background Logic  /* --
local tParts = workspace:FindFirstChild("TempPart")
if tParts then
    tParts.ChildAdded:Connect(function(p)
        if p:IsA("BasePart") and p.Name == "Part" and bBullets then p.Size = bsize end
    end)
end

WindUI:Notify({ Title = "Artly Hub", Content = "Script loaded successfully! (Full Port)" })
