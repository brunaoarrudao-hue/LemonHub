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
   Name = "🍋 Lemon Hub v4.5",
   LoadingTitle = "Carregando Módulos de Combate...",
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
    local dist = (root.Position - TargetCFrame.Position).Magnitude
    local tween = TweenService:Create(root, TweenInfo.new(dist / _G.TweenSpeed, Enum.EasingStyle.Linear), {CFrame = TargetCFrame})
    tween:Play()
    local nc = RunService.Stepped:Connect(function()
        for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end)
    tween.Completed:Wait()
    nc:Disconnect()
end

local function GetClosestPlayer()
    local target = nil
    local dist = math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then dist = d target = p end
        end
    end
    return target
end

local function UseSkills()
    if _G.SkillZ then VIM:SendKeyEvent(true, "Z", false, game) task.wait(0.1) end
    if _G.SkillX then VIM:SendKeyEvent(true, "X", false, game) task.wait(0.1) end
    if _G.SkillC then VIM:SendKeyEvent(true, "C", false, game) task.wait(0.1) end
    if _G.SkillV then VIM:SendKeyEvent(true, "V", false, game) task.wait(0.1) end
end

local function ManageESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local highlight = p.Character:FindFirstChild("LemonESP")
            if _G.ESP then
                if not highlight then
                    highlight = Instance.new("Highlight", p.Character)
                    highlight.Name = "LemonESP"
                    highlight.FillColor = Color3.fromRGB(255, 255, 0)
                end
            elseif highlight then
                highlight:Destroy()
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait()
        if _G.Aimbot then
            local target = GetClosestPlayer()
            if target then
                workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, target.Character.HumanoidRootPart.Position)
            end
        end
        if _G.ESP then ManageESP() end
    end
end)

task.spawn(function()
    while true do
        task.wait()
        if _G.AutoFarm then
            pcall(function()
                local char = LocalPlayer.Character
                for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                    if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                        repeat
                            task.wait()
                            if not _G.AutoFarm then break end
                            char.HumanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0, 7, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                            VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                            VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                            if not char:FindFirstChildOfClass("Tool") then
                                local t = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                                if t then char.Humanoid:EquipTool(t) end
                            end
                            UseSkills()
                        until enemy.Humanoid.Health <= 0 or not _G.AutoFarm
                    end
                end
            end)
        end
    end
end)

local FarmTab = Window:CreateTab("Auto Farm", "crosshair")
FarmTab:CreateToggle({Name = "Ativar Farm Próximos", CurrentValue = false, Callback = function(v) _G.AutoFarm = v end})

local SkillTab = Window:CreateTab("Auto Skills", "zap")
SkillTab:CreateToggle({Name = "Usar Skill Z", CurrentValue = false, Callback = function(v) _G.SkillZ = v end})
SkillTab:CreateToggle({Name = "Usar Skill X", CurrentValue = false, Callback = function(v) _G.SkillX = v end})
SkillTab:CreateToggle({Name = "Usar Skill C", CurrentValue = false, Callback = function(v) _G.SkillC = v end})
SkillTab:CreateToggle({Name = "Usar Skill V", CurrentValue = false, Callback = function(v) _G.SkillV = v end})

local CombatTab = Window:CreateTab("Combate", "swords")
CombatTab:CreateToggle({Name = "Aimbot Players", CurrentValue = false, Callback = function(v) _G.Aimbot = v end})
CombatTab:CreateToggle({Name = "ESP Players", CurrentValue = false, Callback = function(v) _G.ESP = v end})

local ConfigTab = Window:CreateTab("Configurações", "settings")
ConfigTab:CreateSlider({Name = "Velocidade Tween", Range = {100, 500}, Increment = 10, Suffix = "Speed", CurrentValue = 300, Callback = function(v) _G.TweenSpeed = v end})
