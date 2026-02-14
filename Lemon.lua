local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")

for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
    if v.Name == "Rayfield" then v:Destroy() end
end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "🍋 Lemon Hub v4.7",
   LoadingTitle = "Ajustando Sistemas...",
})

_G.AutoFarm = false
_G.TweenSpeed = 300
_G.Aimbot = false
_G.ESP = false
_G.SkillZ = false
_G.SkillX = false
_G.SkillC = false
_G.SkillV = false

local function ToTween(TargetCFrame)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or not TargetCFrame then return end
    local distance = (root.Position - TargetCFrame.Position).Magnitude
    if distance < 10 then root.CFrame = TargetCFrame return end
    local tween = TweenService:Create(root, TweenInfo.new(distance / _G.TweenSpeed, Enum.EasingStyle.Linear), {CFrame = TargetCFrame})
    tween:Play()
    local nc = RunService.Stepped:Connect(function()
        for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
        root.Velocity = Vector3.new(0,0,0)
    end)
    tween.Completed:Wait()
    nc:Disconnect()
end

local function GetRecommendedQuest()
    local myLevel = LocalPlayer.Data.Level.Value
    local Compass_Data = {
        [1]   = {NPC = "Bandit Recruiter", Quest = "Bandit", Enemy = "Bandit", Index = 1},
        [10]  = {NPC = "Adventurer", Quest = "Monkey", Enemy = "Monkey", Index = 1},
        [15]  = {NPC = "Adventurer", Quest = "Gorilla", Enemy = "Gorilla", Index = 2},
        [30]  = {NPC = "Pirate Affiliate", Quest = "Pirate", Enemy = "Pirate", Index = 1},
        [40]  = {NPC = "Pirate Affiliate", Quest = "Brute", Enemy = "Brute", Index = 2},
    }
    local best, high = nil, -1
    for lvl, data in pairs(Compass_Data) do
        if myLevel >= lvl and lvl > high then high = lvl best = data end
    end
    return best
end

local function ReleaseSkill(key)
    task.spawn(function()
        VIM:SendKeyEvent(true, key, false, game)
        task.wait(0.1)
        VIM:SendKeyEvent(false, key, false, game)
    end)
end

task.spawn(function()
    while task.wait() do
        if _G.ESP then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    if not p.Character:FindFirstChild("LemonESP") then
                        local highlight = Instance.new("Highlight", p.Character)
                        highlight.Name = "LemonESP"
                        highlight.FillColor = Color3.fromRGB(255, 255, 0)
                    end
                end
            end
        else
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("LemonESP") then p.Character.LemonESP:Destroy() end
            end
        end
        if _G.Aimbot then
            local target, dist = nil, math.huge
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local d = (LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if d < dist then dist = d target = p end
                end
            end
            if target then
                workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, target.Character.HumanoidRootPart.Position)
            end
        end
    end
end)

task.spawn(function()
    while task.wait() do
        if _G.AutoFarm then
            pcall(function()
                local q = GetRecommendedQuest()
                if q then
                    if not LocalPlayer.PlayerGui.Main.Quest.Visible then
                        local npc = workspace.NPCs:FindFirstChild(q.NPC) or workspace:FindFirstChild(q.NPC)
                        if npc then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = npc.HumanoidRootPart.CFrame * CFrame.new(0, 5, 2)
                            task.wait(0.2)
                            ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", q.Quest, q.Index)
                        end
                    else
                        for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                            if enemy.Name == q.Enemy and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                                ToTween(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 7, 0))
                                repeat
                                    task.wait()
                                    local char = LocalPlayer.Character
                                    local eRoot = enemy:FindFirstChild("HumanoidRootPart")
                                    if char and eRoot and _G.AutoFarm and LocalPlayer.PlayerGui.Main.Quest.Visible then
                                        char.HumanoidRootPart.CFrame = eRoot.CFrame * CFrame.new(0, 7, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                                        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                                        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                                        if not char:FindFirstChildOfClass("Tool") then
                                            local t = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                                            if t then char.Humanoid:EquipTool(t) end
                                        end
                                        if _G.SkillZ then ReleaseSkill(Enum.KeyCode.Z) end
                                        if _G.SkillX then ReleaseSkill(Enum.KeyCode.X) end
                                        if _G.SkillC then ReleaseSkill(Enum.KeyCode.C) end
                                        if _G.SkillV then ReleaseSkill(Enum.KeyCode.V) end
                                    end
                                until enemy.Humanoid.Health <= 0 or not _G.AutoFarm or not LocalPlayer.PlayerGui.Main.Quest.Visible
                            end
                        end
                    end
                end
            end)
        end
    end
end)

local FarmTab = Window:CreateTab("Farm", "crosshair")
FarmTab:CreateToggle({Name = "Auto Farm Level", CurrentValue = false, Callback = function(v) _G.AutoFarm = v end})

local SkillTab = Window:CreateTab("Skills", "zap")
SkillTab:CreateToggle({Name = "Skill Z", CurrentValue = false, Callback = function(v) _G.SkillZ = v end})
SkillTab:CreateToggle({Name = "Skill X", CurrentValue = false, Callback = function(v) _G.SkillX = v end})
SkillTab:CreateToggle({Name = "Skill C", CurrentValue = false, Callback = function(v) _G.SkillC = v end})
SkillTab:CreateToggle({Name = "Skill V", CurrentValue = false, Callback = function(v) _G.SkillV = v end})

local CombatTab = Window:CreateTab("Combat", "eye")
CombatTab:CreateToggle({Name = "ESP Players", CurrentValue = false, Callback = function(v) _G.ESP = v end})
CombatTab:CreateToggle({Name = "Aimbot", CurrentValue = false, Callback = function(v) _G.Aimbot = v end})

local ConfigTab = Window:CreateTab("Settings", "settings")
ConfigTab:CreateSlider({Name = "Tween Speed", Range = {100, 500}, Increment = 10, Suffix = "S", CurrentValue = 300, Callback = function(v) _G.TweenSpeed = v end})
