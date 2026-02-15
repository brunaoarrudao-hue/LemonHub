local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")

-- Limpar UI Antiga para evitar sobreposição
for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
    if v.Name == "Rayfield" then v:Destroy() end
end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "🍋 Lemon Hub v4.9",
   LoadingTitle = "Loading script",
})
_G.BringMob = true
_G.MegaHitbox = true
_G.HitRange = 100
_G.AutoQuest = false
_G.MissaoSelecionada = "BanditQuest1"
_G.NivelDaMissao = 1
_G.AutoFarm = false
_G.AutoChest = false
_G.AutoRaid = false
_G.TweenSpeed = 300
_G.AutoFruit = false
_G.Aimbot = false
_G.ESP = false
_G.AutoKillPlayer = false
_G.SkillZ = false
_G.SkillX = false
_G.SkillC = false
_G.SkillV = false

-- Função de Tween Corrigida
local function ToTween(TargetCFrame)
    pcall(function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root or not TargetCFrame then return end
        
        local distance = (root.Position - TargetCFrame.Position).Magnitude
        if distance < 8 then root.CFrame = TargetCFrame return end
        
        local tween = TweenService:Create(root, TweenInfo.new(distance / _G.TweenSpeed, Enum.EasingStyle.Linear), {CFrame = TargetCFrame})
        tween:Play()
        
        local nc = RunService.Stepped:Connect(function()
            for _, v in pairs(char:GetDescendants()) do 
                if v:IsA("BasePart") then v.CanCollide = false end 
            end
            root.Velocity = Vector3.new(0,0,0)
        end)
        
        tween.Completed:Wait()
        nc:Disconnect()
    end)
end

local function TeleportToScientist()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local target = nil

    -- 1. Tenta achar por qualquer parte que contenha "Scientist" no nome
    -- 2. Tenta achar o NPC pelo nome da "Aura" ou "Invisible Seat" que costuma ficar neles
    for _, v in pairs(workspace:GetDescendants()) do
        -- Procura por nomes comuns do NPC ou o modelo dele
        if (v.Name:find("Scientist") or v.Name:find("Raid") or v.Name == "Cientista") and v:IsA("BasePart") then
            -- Verifica se é um NPC real (geralmente tem um Humanoid ou está perto de um)
            if v.Parent:FindFirstChildOfClass("Humanoid") or v:FindFirstChildOfClass("ClickDetector") or v:FindFirstChildOfClass("ProximityPrompt") then
                target = v
                break
            end
        end
    end

    -- 3. Se ainda não achou, vamos procurar pela posição padrão do laboratório no Sea 2 (Pós-Rework)
    -- As coordenadas do laboratório costumam ser constantes mesmo mudando o visual
    if not target then
        local sea2_lab = Vector3.new(-6410, 250, -4490) -- Coordenada comum do Laboratório
        local dist = (root.Position - sea2_lab).Magnitude
        
        if dist < 5000 then -- Se você estiver no Sea 2
             Rayfield:Notify({Title = "Busca por Coordenada", Content = "NPC não achado pelo nome. Indo ao local provável do Lab.", Duration = 3})
             ToTween(CFrame.new(-6410, 250, -4490)) -- Vai para a entrada do Lab
             return
        end
    end

    if target then
        Rayfield:Notify({Title = "NPC Localizado!", Content = "Indo até: " .. target.Parent.Name, Duration = 3})
        
        -- Se for uma parte, vamos para ela. Se for um modelo, vamos para a RootPart.
        local targetPos = target:IsA("Model") and target.PrimaryPart.CFrame or target.CFrame
        ToTween(targetPos * CFrame.new(0, 0, 3))
    else
        Rayfield:Notify({
           Title = "Erro Crítico",
           Content = "O NPC não está carregado. Vá para a ilha Hot and Cold primeiro!",
           Duration = 5,
        })
    end
end
task.spawn(function()
    while task.wait() do
        pcall(function()
            if _G.BringMob or _G.MegaHitbox then
                local player = game.Players.LocalPlayer
                local character = player.Character
                local hrp = character.HumanoidRootPart
                local tool = character:FindFirstChildOfClass("Tool")
                
                local enemies = workspace.Enemies:GetChildren()
                local hitTargets = {}

                for _, v in pairs(enemies) do
                    local eHrp = v:FindFirstChild("HumanoidRootPart")
                    local eHum = v:FindFirstChild("Humanoid")

                    if eHrp and eHum and eHum.Health > 0 then
                        local dist = (eHrp.Position - hrp.Position).Magnitude
                        
                        -- 1. Lógica do Bring Mob (Puxa para sua frente se estiver no range)
                        if _G.BringMob and dist <= _G.HitRange then
                            eHrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -3) -- Puxa para 3 studs na sua frente
                            eHrp.CanCollide = false
                            eHum:ChangeState(11)
                        end

                        -- 2. Lógica do Dano (Armazena quem será atingido)
                        if _G.MegaHitbox and dist <= _G.HitRange then
                            table.insert(hitTargets, eHrp)
                        end
                    end
                end

                -- 3. Dispara o Dano em Massa
                if #hitTargets > 0 and tool then
                    -- Envia o sinal de dano para todos os alvos da lista de uma vez
                    game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("hit", tool, hitTargets)
                    
                    -- Fast Attack (Corta animação para bater na velocidade da luz)
                    for _, track in pairs(character.Humanoid:GetPlayingAnimationTracks()) do
                        track:Stop(0)
                    end
                end
            end
        end)
    end
end)
                            
                            
task.spawn(function()
    while task.wait(1) do -- Verifica a cada 1 segundo
        if _G.AutoQuest then
            pcall(function()
                local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
                
                -- Verifica se a janela de missão está invisível (ou seja, você está sem missão)
                if not playerGui.Main.Quest.Visible then
                    local remote = game:GetService("ReplicatedStorage").Remotes.CommF_
                    
                    -- Envia o comando para o servidor usando as variáveis que definimos
                    remote:InvokeServer("StartQuest", _G.MissaoSelecionada, _G.NivelDaMissao)
                    
                    Rayfield:Notify({
                        Title = "Auto Quest",
                        Content = "Pegando missão: " .. _G.MissaoSelecionada,
                        Duration = 2
                    })
                end
            end)
        end
    end
end)


-- Função de Skill (Fixa)
local function CastSkill(key)
    VIM:SendKeyEvent(true, key, false, game)
    task.wait(0.05)
    VIM:SendKeyEvent(false, key, false, game)
end

task.spawn(function()
    while task.wait(0.1) do
        if _G.AutoRaid then
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                -- 1. TENTA ACHAR INIMIGOS NA RAID
                local enemy = nil
                local dist = math.huge
                
                -- Nas Raids, os NPCs costumam ficar na pasta Enemies
                for _, v in pairs(workspace.Enemies:GetChildren()) do
                    if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        local d = (root.Position - v.HumanoidRootPart.Position).Magnitude
                        if d < dist then
                            dist = d
                            enemy = v
                        end
                    end
                end

                if enemy then
                    -- Lógica de Ataque (Igual ao seu Auto Farm)
                    ToTween(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 7, 0))
                    root.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0, 7, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                    
                    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    
                    if not char:FindFirstChildOfClass("Tool") then
                        local tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                        if tool then char.Humanoid:EquipTool(tool) end
                    end
                else
                    -- 2. LÓGICA DE NAVEGAÇÃO POR #ISLAND
                    -- Se não há inimigos, procuramos a ilha na sequência
                    for i = 2, 5 do -- As raids costumam ter 5 ilhas
                        local islandName = "island " .. i
                        local nextIsland = workspace:FindFirstChild(islandName) or workspace.Map:FindFirstChild(islandName)
                        
                        if nextIsland then
                            -- Verifica se você já não está nela (se está longe, ele voa)
                            local distToIsland = (root.Position - nextIsland.Position).Magnitude
                            if distToIsland > 50 then 
                                ToTween(nextIsland.CFrame * CFrame.new(0, 20, 0)) -- Voa um pouco acima da ilha
                                break 
                            end
                        end
                    end
                end -- Fim do if enemy
            end) -- Fim do pcall
        end -- Fim do if _G.AutoRaid
    end -- Fim do while
end) -- Fim do task.spawn
                    
-- // ⚔️ LÓGICA DO AUTO KILL PLAYER (PVP)
task.spawn(function()
    while task.wait() do
        if _G.AutoKillPlayer then
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                local targetPlayer = nil
                local shortestDist = math.huge

                -- 1. Procura o jogador mais próximo
                for _, p in pairs(Players:GetPlayers()) do
                    -- Verifica se não é você mesmo e se o jogador está vivo
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 and p.Character:FindFirstChild("HumanoidRootPart") then
                        
                        -- Opcional: Você pode adicionar uma verificação de Safe Zone aqui depois
                        local dist = (root.Position - p.Character.HumanoidRootPart.Position).Magnitude
                        
                        if dist < shortestDist then
                            shortestDist = dist
                            targetPlayer = p
                        end
                    end
                end

                -- 2. Se encontrou um alvo, inicia o ataque
                if targetPlayer and targetPlayer.Character then
                    local targetRoot = targetPlayer.Character.HumanoidRootPart
                    local targetHum = targetPlayer.Character.Humanoid

                    -- Voa até o jogador
                    ToTween(targetRoot.CFrame * CFrame.new(0, 5, 0))

                    -- 3. Loop de combate (gruda no jogador)
                    repeat
                        task.wait()
                        -- Quebra o loop se você desligar o toggle, o cara morrer ou sair do jogo
                        if not _G.AutoKillPlayer or not targetPlayer.Character or targetHum.Health <= 0 then break end
                        
                        -- Fica "colado" em cima do jogador (CFrame.new(0, 5, 0))
                        root.CFrame = targetRoot.CFrame * CFrame.new(0, 5, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                        
                        -- Clique de Ataque (VIM)
                        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                        
                        -- Garante que a arma está equipada
                        if not char:FindFirstChildOfClass("Tool") then
                            local tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                            if tool then char.Humanoid:EquipTool(tool) end
                        end

                        -- Você pode integrar suas funções de Auto Skill aqui também!
                        -- if _G.SkillZ then UseSkill(Enum.KeyCode.Z) end

                    until targetHum.Health <= 0 or not _G.AutoKillPlayer
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if _G.ESP then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    -- Highlight (Corpo)
                    if not p.Character:FindFirstChild("LemonHighlight") then
                        local hl = Instance.new("Highlight", p.Character)
                        hl.Name = "LemonHighlight"
                        hl.FillColor = Color3.fromRGB(255, 255, 0)
                    end
                    -- Billboard (Nome e Distância)
                    CreateBillboard(p)
                end
            end
        else
            -- Remove tudo se desligar
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character then
                    if p.Character:FindFirstChild("LemonHighlight") then p.Character.LemonHighlight:Destroy() end
                    if p.Character:FindFirstChild("LemonUI") then p.Character.LemonUI:Destroy() end
                end
            end
        end
    end
end)


-- Loop de Farm por Proximidade
task.spawn(function()
    while task.wait() do
        if _G.AutoFarm then
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then continue end

            local target = nil
            local dist = math.huge
-- // LÓGICA DO AUTO CHEST (VERSÃO FINAL SEM LAG)
task.spawn(function()
    while task.wait(0.1) do
        if _G.AutoChest then
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                local target = nil
                
                -- Busca bruta: olha tudo no mapa que tem "Chest" no nome
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("TouchTransmitter") and v.Parent:IsA("BasePart") and v.Parent.Name:find("Chest") then
                        target = v.Parent
                        break -- Achou um, para a busca e vai até ele
                    end
                end

                if target then
                    -- Usa a sua função de voar
                    ToTween(target.CFrame)
                    
                    -- Toca no baú para coletar
                    firetouchinterest(root, target, 0)
                    firetouchinterest(root, target, 1)
                    
                    -- Espera um pouco para o baú ser destruído pelo jogo
                    task.wait(0.2)
                end
            end)
        end
    end
end)
                -- // 🍎 LÓGICA DO AUTO PEGÁR FRUTAS
task.spawn(function()
    while task.wait(0.5) do -- Checa a cada meio segundo
        if _G.AutoFruit then
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                local targetFruit = nil
                local shortestDist = math.huge

                -- Frutas spawnadas no chão ficam soltas no Workspace
                for _, v in pairs(workspace:GetChildren()) do
                    -- Verifica se o objeto é uma Tool (itens soltos no chão) e se tem um "Handle" (a parte física de pegar)
                    if v:IsA("Tool") and v:FindFirstChild("Handle") then
                        
                        -- Pega o nome e transforma em minúsculo para facilitar a busca
                        local nome = string.lower(v.Name)
                        
                        -- Verifica se o nome tem o padrão "rocket-rocket" (tem um traço) OU se tem a palavra "fruit" / "fruta"
                        if nome:find("-") or nome:find("fruit") or nome:find("fruta") then
                            local dist = (root.Position - v.Handle.Position).Magnitude
                            if dist < shortestDist then
                                shortestDist = dist
                                targetFruit = v
                            end
                        end
                    end
                end

                -- Se achou uma fruta, voa até ela
                if targetFruit then
                    Rayfield:Notify({
                        Title = "🍎 Fruta Encontrada!",
                        Content = "Indo coletar: " .. targetFruit.Name,
                        Duration = 3
                    })
                    
                    -- Voa até o "Handle" (a parte física da fruta)
                    ToTween(targetFruit.Handle.CFrame)
                    
                    -- Simula o toque para guardar no inventário
                    firetouchinterest(root, targetFruit.Handle, 0)
                    firetouchinterest(root, targetFruit.Handle, 1)
                    
                    task.wait(1) -- Pausa para dar tempo do jogo registrar que você pegou
                end
            end)
        end
    end
end)
        


            -- Procura em Enemies e NPCs (cobre todas as versões do jogo)
            local folders = {workspace:FindFirstChild("Enemies"), workspace:FindFirstChild("NPCs"), workspace}
            for _, folder in pairs(folders) do
                if folder then
                    for _, enemy in pairs(folder:GetChildren()) do
                        if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 and enemy:FindFirstChild("HumanoidRootPart") then
                            local d = (root.Position - enemy.HumanoidRootPart.Position).Magnitude
                            if d < dist and d < 2000 then -- Só foca no que está perto/na mesma ilha
                                dist = d
                                target = enemy
                            end
                        end
                    end
                end
            end

            if target then
                -- Movimenta
                ToTween(target.HumanoidRootPart.CFrame * CFrame.new(0, 8, 0))

                repeat
                    task.wait()
                    if not _G.AutoFarm or not target.Parent or target.Humanoid.Health <= 0 then break end
                    
                    root.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 8, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                    
                    -- Ataque e Equipar
                    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    
                    if not char:FindFirstChildOfClass("Tool") then
                        local tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                        if tool then char.Humanoid:EquipTool(tool) end
                    end

                    -- Skills
                    if _G.SkillZ then CastSkill(Enum.KeyCode.Z) end
                    if _G.SkillX then CastSkill(Enum.KeyCode.X) end
                    if _G.SkillC then CastSkill(Enum.KeyCode.C) end
                    if _G.SkillV then CastSkill(Enum.KeyCode.V) end
                    
                until target.Humanoid.Health <= 0 or not _G.AutoFarm
            end
        end
    end
end)

-- Interface
local Tab1 = Window:CreateTab("Principal", "bolt")
Tab1:CreateToggle({
   Name = "Matar NPCs Próximos",
   CurrentValue = false,
   Callback = function(v) _G.AutoFarm = v end,
})
Tab1:CreateToggle({
   Name = "Auto Chest (Farm de Dinheiro)",
   CurrentValue = false,
   Callback = function(v) 
       _G.AutoChest = v 
   end,
})
Tab1:CreateToggle({
   Name = "Auto Raid (Beta)",
   CurrentValue = false,
   Callback = function(Value)
       _G.AutoRaid = Value
       print("Status Auto Raid: ", Value)
   end,
})
Tab1:CreateButton({
   Name = "Ir para o Cientista (Raid NPC)",
   Callback = function()
       TeleportToScientist()
   end,
})
Tab1:CreateToggle({
   Name = "Auto Quest (Pegar Missão)",
   CurrentValue = false,
   Callback = function(Value)
       _G.AutoQuest = Value
   end,
})
Tab1:CreateDropdown({
   Name = "Escolher Local de Farm",
   Options = {"Bandidos", "Macacos", "Gorilas", "Piratas"},
   CurrentOption = {"Bandidos"},
   MultipleOptions = false,
   Callback = function(Option)
      local escolha = Option[1]
      
      if escolha == "Bandidos" then
          _G.MissaoSelecionada = "BanditQuest1"
          _G.NivelDaMissao = 1
      elseif escolha == "Macacos" then
          _G.MissaoSelecionada = "JungleQuest"
          _G.NivelDaMissao = 1
      elseif escolha == "Gorilas" then
          _G.MissaoSelecionada = "JungleQuest"
          _G.NivelDaMissao = 2
      elseif escolha == "Piratas" then
          _G.MissaoSelecionada = "PiratelerQuest"
          _G.NivelDaMissao = 1
      end
   end,
})

local Tab2 = Window:CreateTab("Auto Skills", "zap")
Tab2:CreateToggle({Name = "Usar Z", CurrentValue = false, Callback = function(v) _G.SkillZ = v end})
Tab2:CreateToggle({Name = "Usar X", CurrentValue = false, Callback = function(v) _G.SkillX = v end})
Tab2:CreateToggle({Name = "Usar C", CurrentValue = false, Callback = function(v) _G.SkillC = v end})
Tab2:CreateToggle({Name = "Usar V", CurrentValue = false, Callback = function(v) _G.SkillV = v end})

local Tab3 = Window:CreateTab("PVP & Visual", "eye")
Tab3:CreateToggle({Name = "ESP Players", CurrentValue = false, Callback = function(v) _G.ESP = v end})
Tab3:CreateToggle({Name = "Aimbot", CurrentValue = false, Callback = function(v) _G.Aimbot = v end})
Tab3:CreateToggle({
   Name = "Auto Kill Player (Mais Próximo)",
   CurrentValue = false,
   Callback = function(v) 
       _G.AutoKillPlayer = v 
   end,
})
local Tab4 = Window:CreateTab("Config", "settings")
Tab4:CreateSlider({
   Name = "Velocidade Tween",
   Range = {100, 500},
   Increment = 10,
   CurrentValue = 300,
   Callback = function(v) _G.TweenSpeed = v end,
})
Tab4:CreateToggle({
   Name = "Auto Find Fruit",
   CurrentValue = false,
   Callback = function(Value)
       _G.AutoFruit = Value
       print("Auto Fruta: ", Value)
   end,
})
local ActiveCodes = {
    "LIGHTNINGABUSE", "KITT_RESET", "SUB2GAMERROBOT_RESET1", "Sub2CaptainMaui",
    "kittgaming", "Sub2Fer999", "Enyu_is_Pro", "Magicbus", "JCWK", 
    "Starcodeheo", "Bluxxy", "fudd10_v2", "FUDD10", "BIGNEWS", 
    "THEGREATACE", "SUB2GAMERROBOT_EXP1", "Sub2OfficialNoobie", 
    "StrawHatMaine", "SUB2NOOBMASTER123", "Sub2UncleKizaru", 
    "Sub2Daigrock", "Axiore", "TantaiGaming"
}

Tab4:CreateButton({
    Name = "Resgatar Todos os Códigos (XP/Reset)",
    Info = "Resgata todos os códigos de XP e Reset de Status ativos", -- Opcional
    Callback = function()
        for _, code in pairs(ActiveCodes) do
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("RedeemCode", code)
            task.wait(0.3)
        end
        
        Rayfield:Notify({
            Title = "Códigos Resgatados!",
            Content = "Todos os códigos disponíveis foram processados.",
            Duration = 5,
            Image = 4483362458,
        })
    end,
})
