--[[ ===========================================================
     PAINEL DE BOMBAS - OFF/ON + Confetes Personalizados por Bomba
=========================================================== ]]
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remove painel antigo se já existir
if playerGui:FindFirstChild("BombasGui") then
    playerGui.BombasGui:Destroy()
end

-- 1. ScreenGui Principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BombasGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- 2. Botão Redondo Flutuante para reabrir o painel
local miniBtn = Instance.new("TextButton")
miniBtn.Name = "MiniButton"
miniBtn.Size = UDim2.new(0, 50, 0, 50)
miniBtn.Position = UDim2.new(0, 20, 0.5, -25)
miniBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
miniBtn.TextColor3 = Color3.fromRGB(255, 60, 60)
miniBtn.Text = "+"
miniBtn.Font = Enum.Font.SourceSansBold
miniBtn.TextSize = 24
miniBtn.Visible = false
miniBtn.Parent = screenGui

local miniCorner = Instance.new("UICorner")
miniCorner.CornerRadius = UDim.new(1, 0)
miniCorner.Parent = miniBtn

local miniStroke = Instance.new("UIStroke")
miniStroke.Color = Color3.fromRGB(220, 50, 50)
miniStroke.Thickness = 2
miniStroke.Parent = miniBtn

-- 3. Janela Principal Arrastável
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 260, 0, 230)
mainFrame.Position = UDim2.new(0.5, -130, 0.5, -115)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 10)
frameCorner.Parent = mainFrame

-- Barra Superior (Cabeçalho)
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 10)
topCorner.Parent = topBar

local topCover = Instance.new("Frame")
topCover.Size = UDim2.new(1, 0, 0, 10)
topCover.Position = UDim2.new(0, 0, 1, -10)
topCover.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
topCover.BorderSizePixel = 0
topCover.Parent = topBar

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -45, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "💣 Spawn Bombas"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

-- Botão de Minimizar (-)
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 35, 1, 0)
minBtn.Position = UDim2.new(1, -35, 0, 0)
minBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
minBtn.BorderSizePixel = 0
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.Text = "-"
minBtn.Font = Enum.Font.SourceSansBold
minBtn.TextSize = 18
minBtn.Parent = topBar

-- Lógica de Arrastar Janela Principal
local draggingMain, dragStartMain, startPosMain
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingMain = true
        dragStartMain = input.Position
        startPosMain = mainFrame.Position
    end
end)

-- Lógica de Arrastar Botão Redondo Mini
local draggingMini, dragStartMini, startPosMini, miniMoved = false, nil, nil, false
miniBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingMini = true
        miniMoved = false
        dragStartMini = input.Position
        startPosMini = miniBtn.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        if draggingMain then
            local delta = input.Position - dragStartMain
            mainFrame.Position = UDim2.new(startPosMain.X.Scale, startPosMain.X.Offset + delta.X, startPosMain.Y.Scale, startPosMain.Y.Offset + delta.Y)
        elseif draggingMini then
            local delta = input.Position - dragStartMini
            if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
                miniMoved = true
            end
            miniBtn.Position = UDim2.new(startPosMini.X.Scale, startPosMini.X.Offset + delta.X, startPosMini.Y.Scale, startPosMini.Y.Offset + delta.Y)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingMain = false
        draggingMini = false
    end
end)

minBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    miniBtn.Visible = true
end)

miniBtn.MouseButton1Click:Connect(function()
    if not miniMoved then
        mainFrame.Visible = true
        miniBtn.Visible = false
    end
end)

-----------------------------------------------------------
-- FUNÇÕES DE REMOÇÃO E SPAWN DAS BOMBAS
-----------------------------------------------------------

local function removerBomba(nomeItem)
    local backpack = player:FindFirstChild("Backpack")
    local character = player.Character

    if backpack then
        for _, item in pairs(backpack:GetChildren()) do
            if item.Name == nomeItem then item:Destroy() end
        end
    end
    if character then
        for _, item in pairs(character:GetChildren()) do
            if item.Name == nomeItem then item:Destroy() end
        end
    end
end

-- 1. Emerald Bomb (Explosão com Confetes Verde-Esmeralda)
local function loadEmeraldBomb()
    removerBomba("EmeraldFakeBomb")
    local backpack = player:WaitForChild("Backpack")
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")

    local GEAR_ID = 104642566
    local success, tool = pcall(function()
        return game:GetObjects("rbxassetid://" .. GEAR_ID)[1]
    end)
    if not success or not tool or not tool:IsA("Tool") then return end

    tool.Name = "EmeraldFakeBomb"
    tool.TextureId = "rbxassetid://127321770551252"
    tool.RequiresHandle = true
    tool.CanBeDropped = false

    local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
    if handle then
        handle.Transparency = 0 
        handle.Color = Color3.fromRGB(40, 180, 100)
        handle.CanCollide = false
        handle.Massless = true
        handle.Size = Vector3.new(2.5, 2.5, 2.5) 
        
        local handMesh = Instance.new("SpecialMesh")
        handMesh.MeshId = "rbxassetid://104516854"
        handMesh.TextureId = "rbxassetid://125916152510920"
        handMesh.Scale = Vector3.new(1.5, 1.5, 1.5) 
        handMesh.Parent = handle
    end

    for _, child in ipairs(tool:GetDescendants()) do
        if child:IsA("Script") or child:IsA("LocalScript") or child:IsA("Animation") then
            child:Destroy()
        end
    end

    tool.Parent = backpack
    humanoid:EquipTool(tool)

    local canUse = true
    tool.Activated:Connect(function()
        if not canUse then return end
        canUse = false
        if handle then handle.Transparency = 1 end

        local bombPart = Instance.new("Part")
        bombPart.Name = "DroppedEmeraldBomb"
        bombPart.Size = Vector3.new(3, 3, 3) 
        bombPart.Color = Color3.fromRGB(40, 180, 100) 
        bombPart.Material = Enum.Material.SmoothPlastic
        bombPart.CanCollide = true
        bombPart.Anchored = false
        
        local mesh = Instance.new("SpecialMesh")
        mesh.MeshId = "rbxassetid://104516854"
        mesh.TextureId = "rbxassetid://125916152510920"
        mesh.Scale = Vector3.new(1.5, 1.5, 1.5) 
        mesh.Parent = bombPart

        local root = character:FindFirstChild("HumanoidRootPart")
        bombPart.CFrame = root.CFrame * CFrame.new(0, -3, -1)
        bombPart.Parent = workspace

        local gyro = Instance.new("BodyGyro")
        gyro.MaxTorque = Vector3.new(40000, 40000, 40000)
        gyro.P = 3000
        gyro.CFrame = bombPart.CFrame
        gyro.Parent = bombPart

        task.delay(0.5, function()
            if gyro and gyro.Parent then
                gyro:Destroy()
                bombPart.AssemblyAngularVelocity = Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
            end
        end)

        task.delay(3, function()
            local confetti = Instance.new("ParticleEmitter")
            confetti.Texture = "rbxassetid://258127463" -- Formato de pedacinhos de confete
            confetti.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 120)),     
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 180, 90)),   
                ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 90, 40))    
            })
            confetti.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 0.2)})
            confetti.Speed = NumberRange.new(30, 60)
            confetti.SpreadAngle = Vector2.new(180, 180)
            confetti.Lifetime = NumberRange.new(1.5, 3)
            confetti.Rate = 0
            confetti.Rotation = NumberRange.new(0, 360)
            confetti.RotSpeed = NumberRange.new(-150, 150)
            confetti.Parent = bombPart
            confetti:Emit(300)

            bombPart.Transparency = 1
            bombPart.CanCollide = false
            Debris:AddItem(bombPart, 4)
        end)

        task.wait(1)
        if handle then handle.Transparency = 0 end
        canUse = true
    end)
end

-- 2. Bomb Normal (Explosão com Confetes Coloridos-Normal)
local function loadFakeC4()
    removerBomba("FakeC4")
    local backpack = player:WaitForChild("Backpack")
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")

    local GEAR_ID = 104642566
    local success, tool = pcall(function()
        return game:GetObjects("rbxassetid://" .. GEAR_ID)[1]
    end)
    if not success or not tool or not tool:IsA("Tool") then return end

    tool.Name = "FakeC4"
    tool.TextureId = "rbxassetid://104516910"
    tool.RequiresHandle = true
    tool.CanBeDropped = false

    local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
    if handle then
        handle.Transparency = 0 
        handle.Color = Color3.fromRGB(45, 45, 45)
        handle.CanCollide = false
        handle.Massless = true
        handle.Size = Vector3.new(2.5, 2.5, 2.5) 
        
        local handMesh = Instance.new("SpecialMesh")
        handMesh.MeshId = "rbxassetid://104516854"
        handMesh.TextureId = "rbxassetid://104516981"
        handMesh.Scale = Vector3.new(1.5, 1.5, 1.5) 
        handMesh.Parent = handle
    end

    for _, child in ipairs(tool:GetDescendants()) do
        if child:IsA("Script") or child:IsA("LocalScript") or child:IsA("Animation") then
            child:Destroy()
        end
    end

    tool.Parent = backpack
    humanoid:EquipTool(tool)

    local canUse = true
    tool.Activated:Connect(function()
        if not canUse then return end
        canUse = false
        if handle then handle.Transparency = 1 end

        local c4Part = Instance.new("Part")
        c4Part.Name = "DroppedC4"
        c4Part.Size = Vector3.new(3, 3, 3) 
        c4Part.Color = Color3.fromRGB(45, 45, 45) 
        c4Part.Material = Enum.Material.SmoothPlastic
        c4Part.CanCollide = true
        c4Part.Anchored = false
        
        local mesh = Instance.new("SpecialMesh")
        mesh.MeshId = "rbxassetid://104516854"
        mesh.TextureId = "rbxassetid://104516981"
        mesh.Scale = Vector3.new(1.5, 1.5, 1.5) 
        mesh.Parent = c4Part

        local root = character:FindFirstChild("HumanoidRootPart")
        c4Part.CFrame = root.CFrame * CFrame.new(0, -3, -1)
        c4Part.Parent = workspace

        local gyro = Instance.new("BodyGyro")
        gyro.MaxTorque = Vector3.new(40000, 40000, 40000)
        gyro.P = 3000
        gyro.CFrame = c4Part.CFrame
        gyro.Parent = c4Part

        task.delay(0.5, function()
            if gyro and gyro.Parent then
                gyro:Destroy()
                c4Part.AssemblyAngularVelocity = Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
            end
        end)

        task.delay(3, function()
            local confetti = Instance.new("ParticleEmitter")
            confetti.Texture = "rbxassetid://258127463" -- Formato de pedacinhos de confete
            confetti.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 50)),     -- Vermelho
                ColorSequenceKeypoint.new(0.2, Color3.fromRGB(50, 255, 50)),   -- Verde
                ColorSequenceKeypoint.new(0.4, Color3.fromRGB(50, 150, 255)),  -- Azul
                ColorSequenceKeypoint.new(0.6, Color3.fromRGB(255, 255, 50)),  -- Amarelo
                ColorSequenceKeypoint.new(0.8, Color3.fromRGB(255, 100, 255)), -- Rosa
                ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 255, 255))    -- Ciano
            })
            confetti.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 0.2)})
            confetti.Speed = NumberRange.new(30, 60)
            confetti.SpreadAngle = Vector2.new(180, 180)
            confetti.Lifetime = NumberRange.new(1.5, 3)
            confetti.Rate = 0
            confetti.Rotation = NumberRange.new(0, 360)
            confetti.RotSpeed = NumberRange.new(-150, 150)
            confetti.Parent = c4Part
            confetti:Emit(300) 

            c4Part.Transparency = 1
            c4Part.CanCollide = false
            Debris:AddItem(c4Part, 4)
        end)

        task.wait(1)
        if handle then handle.Transparency = 0 end
        canUse = true
    end)
end

-- 3. Bomb Gold (Explosão com Confetes Dourados)
local function loadGoldBomb()
    removerBomba("GoldBomb")
    local backpack = player:WaitForChild("Backpack")
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")

    local GEAR_ID = 104642566
    local success, tool = pcall(function()
        return game:GetObjects("rbxassetid://" .. GEAR_ID)[1]
    end)
    if not success or not tool or not tool:IsA("Tool") then return end

    tool.Name = "GoldBomb"
    tool.TextureId = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=70754337097792"
    tool.RequiresHandle = true
    tool.CanBeDropped = false

    local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
    if handle then
        handle.Transparency = 0 
        handle.Color = Color3.fromRGB(255, 215, 0)
        handle.CanCollide = false
        handle.Massless = true
        handle.Size = Vector3.new(2.5, 2.5, 2.5) 
        
        local handMesh = Instance.new("SpecialMesh")
        handMesh.MeshId = "rbxassetid://104516854"
        handMesh.TextureId = "rbxassetid://111999858263148"
        handMesh.Scale = Vector3.new(1.5, 1.5, 1.5) 
        handMesh.Parent = handle
    end

    for _, child in ipairs(tool:GetDescendants()) do
        if child:IsA("Script") or child:IsA("LocalScript") or child:IsA("Animation") then
            child:Destroy()
        end
    end

    tool.Parent = backpack
    humanoid:EquipTool(tool)

    local canUse = true
    tool.Activated:Connect(function()
        if not canUse then return end
        canUse = false
        if handle then handle.Transparency = 1 end

        local bombPart = Instance.new("Part")
        bombPart.Name = "DroppedGoldBomb"
        bombPart.Size = Vector3.new(3, 3, 3) 
        bombPart.Color = Color3.fromRGB(255, 215, 0) 
        bombPart.Material = Enum.Material.SmoothPlastic
        bombPart.CanCollide = true
        bombPart.Anchored = false
        
        local mesh = Instance.new("SpecialMesh")
        mesh.MeshId = "rbxassetid://104516854"
        mesh.TextureId = "rbxassetid://111999858263148"
        mesh.Scale = Vector3.new(1.5, 1.5, 1.5) 
        mesh.Parent = bombPart

        local root = character:FindFirstChild("HumanoidRootPart")
        bombPart.CFrame = root.CFrame * CFrame.new(0, -3, -1)
        bombPart.Parent = workspace

        local gyro = Instance.new("BodyGyro")
        gyro.MaxTorque = Vector3.new(40000, 40000, 40000)
        gyro.P = 3000
        gyro.CFrame = bombPart.CFrame
        gyro.Parent = bombPart

        task.delay(0.5, function()
            if gyro and gyro.Parent then
                gyro:Destroy()
                bombPart.AssemblyAngularVelocity = Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
            end
        end)

        task.delay(3, function()
            local confetti = Instance.new("ParticleEmitter")
            confetti.Texture = "rbxassetid://258127463" -- Formato de pedacinhos de confete
            confetti.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 240, 120)),   -- Dourado claro brilhante
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 215, 0)),  -- Dourado padrão
                ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 130, 20))    -- Ouro escuro
            })
            confetti.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 0.2)})
            confetti.Speed = NumberRange.new(30, 60)
            confetti.SpreadAngle = Vector2.new(180, 180)
            confetti.Lifetime = NumberRange.new(1.5, 3)
            confetti.Rate = 0
            confetti.Rotation = NumberRange.new(0, 360)
            confetti.RotSpeed = NumberRange.new(-150, 150)
            confetti.Parent = bombPart
            confetti:Emit(300)

            bombPart.Transparency = 1
            bombPart.CanCollide = false
            Debris:AddItem(bombPart, 4)
        end)

        task.wait(1)
        if handle then handle.Transparency = 0 end
        canUse = true
    end)
end

-----------------------------------------------------------
-- CRIAÇÃO DOS BOTÕES NO PAINEL (Com Cores e Sistema OFF/ON)
-----------------------------------------------------------
local function criarLinhaBomba(nomeTexto, posY, callbackSpawn, nomeItemRemover, corFundoBotao)
    local btnSpawn = Instance.new("TextButton")
    btnSpawn.Size = UDim2.new(0.72, 0, 0, 45)
    btnSpawn.Position = UDim2.new(0.05, 0, 0, posY)
    btnSpawn.BackgroundColor3 = corFundoBotao
    btnSpawn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnSpawn.Text = nomeTexto
    btnSpawn.Font = Enum.Font.SourceSansBold
    btnSpawn.TextSize = 14
    btnSpawn.Parent = mainFrame

    local corner1 = Instance.new("UICorner")
    corner1.CornerRadius = UDim.new(0, 6)
    corner1.Parent = btnSpawn

    btnSpawn.MouseButton1Click:Connect(callbackSpawn)

    local btnToggle = Instance.new("TextButton")
    btnToggle.Size = UDim2.new(0.18, 0, 0, 45)
    btnToggle.Position = UDim2.new(0.79, 0, 0, posY)
    btnToggle.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    btnToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnToggle.Text = "OFF"
    btnToggle.Font = Enum.Font.SourceSansBold
    btnToggle.TextSize = 15
    btnToggle.Parent = mainFrame

    local corner2 = Instance.new("UICorner")
    corner2.CornerRadius = UDim.new(0, 6)
    corner2.Parent = btnToggle

    local ligado = false
    btnToggle.MouseButton1Click:Connect(function()
        ligado = not ligado
        if ligado then
            btnToggle.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
            btnToggle.Text = "ON"
            callbackSpawn()
        else
            btnToggle.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
            btnToggle.Text = "OFF"
            removerBomba(nomeItemRemover)
        end
    end)
end

criarLinhaBomba("Spawn Bomb Emerald", 55, loadEmeraldBomb, "EmeraldFakeBomb", Color3.fromRGB(30, 110, 60))
criarLinhaBomba("Spawn Bomb Normal", 110, loadFakeC4, "FakeC4", Color3.fromRGB(50, 50, 50))
criarLinhaBomba("Spawn Bomb Gold", 165, loadGoldBomb, "GoldBomb", Color3.fromRGB(160, 130, 20))

print("✅ Painel atualizado com confetes personalizados nas explosões!")
