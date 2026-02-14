--[[
    🍋 LEMON HUB V2.2 - CLASSIC BRING MOB
    - Modo: Farm de Proximidade (Elimina o que estiver perto).
    - Função: Bring Mob (Agrupa todos os NPCs do mesmo nome).
    - Estabilidade: Câmera fixa e Noclip integrados.
]]

for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
    if v.Name == "Rayfield" then v:Destroy() end
end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")

local Window = Rayfield:CreateWindow({
   Name = "🍋 Lemon Hub v2.2 | Classic Farm",
   LoadingTitle = "Injetando Bring Mob...",
   LoadingSubtitle = "Modo Clássico (Sem Quest)",
})

-- // VARIÁVEIS
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

_G.AutoFarm = false
_G.BringMob = true
_G.TweenSpeed = 300 
_G.WalkSpeed = 20

-- // 🛡️ FUNÇÃO BRING MOB (Agrupa NPCs no Alvo)
local function BringMobFunction(TargetName, TargetCFrame)
    if _G.BringMob then
        pcall(function()
            for _, v in pairs(workspace.Enemies:GetChildren()) do
                if v.Name == TargetName and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                    v.HumanoidRootPart.CFrame = TargetCFrame
                    v.HumanoidRootPart.CanCollide = false
                    v.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
                    if v.Humanoid:FindFirstChild("Animator") then v.Humanoid.Animator:Destroy() end -- Opcional: Para o NPC não revidar
                end
            end
        end)
    end
end

-- // ⚡ BYPASS DE VELOCIDADE (Original Fix)
RunService.Stepped:Connect(function()
    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            local hum = LocalPlayer.Character.Humanoid
            if _G.WalkSpeed > 20 and hum.MoveDirection.Magnitude > 0 then
                LocalPlayer.Character:TranslateBy(hum.MoveDirection * (_G.WalkSpeed / 100))
            end
        end
    end)
end)

-- // ⚔️ INTERFACE
local FarmTab = Window:CreateTab("Farm Clássico", "swords")

FarmTab:CreateToggle({
   Name = "Ativar Farm de Proximidade",
   CurrentValue = false,
   Callback = function(v) _G.AutoFarm = v end,
})

FarmTab:CreateToggle({
   Name = "Puxar Inimigos (Bring Mob)",
   CurrentValue = true,
   Callback = function(v) _G.BringMob = v end,
})

local PVPPoint = Window:CreateTab("Ajustes", "settings")
PVPPoint:CreateSlider({
   Name = "Velocidade Bypass",
   Range = {20, 500},
   Increment = 1,
   CurrentValue = 20,
   Callback = function(v) _G.WalkSpeed = v end,
})

-- // 🚜 LOOP DE EXECUÇÃO (SEM QUEST)
task.spawn(function()
    while true do
        task.wait(0.1)
        if _G.AutoFarm then
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                
                -- Procura o inimigo mais próximo na pasta de inimigos
                for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                    if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                        
                        -- Auto Equipamento
                        if not char:FindFirstChildOfClass("Tool") then
                            local tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                            if tool then char.Humanoid:EquipTool(tool) end
                        end

                        repeat
                            task.wait()
                            if not _G.AutoFarm then break end
                            
                            local root = char:FindFirstChild("HumanoidRootPart")
                            local eRoot = enemy:FindFirstChild("HumanoidRootPart")
                            
                            if root and eRoot then
                                -- Ativa o Bring Mob para o nome desse inimigo específico
                                BringMobFunction(enemy.Name, eRoot.CFrame)

                                -- Posiciona o jogador acima para bater em área
                                root.Velocity = Vector3.new(0,0,0)
                                root.CFrame = eRoot.CFrame * CFrame.new(0, 7, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                                
                                -- Noclip bypass
                                for _, part in pairs(char:GetDescendants()) do
                                    if part:IsA("BasePart") then part.CanCollide = false end
                                end

                                -- Ataque
                                VIM:SendMouseButtonEvent(0,0,0,true,game,0)
                                VIM:SendMouseButtonEvent(0,0,0,false,game,0)
                            end
                        until enemy.Humanoid.Health <= 0 or not _G.AutoFarm
                    end
                end
            end)
        end
    end
end)

print("🍋 Lemon Hub v2.2 - Classic Farm Loaded!")
