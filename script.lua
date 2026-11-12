-- Flying Sled (ID: 99119261) + Lógica do Carpet + Posição Centralizada
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local backpack = player:WaitForChild("Backpack")

local gearId = 99119261
local animId = "rbxassetid://855828754"

local success, objects = pcall(function()
	return game:GetObjects("rbxassetid://" .. gearId)
end)

if success and objects and #objects > 0 then
	local tool = objects[1]

	for _, v in ipairs(tool:GetDescendants()) do
		if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then
			v:Destroy()
		end
	end

	tool.TextureId = "rbxassetid://99167204"

	local function setupHandle(t)
		local handle = t:FindFirstChild("Handle")
		if handle then
			handle.Transparency = 0
			local mesh = handle:FindFirstChildOfClass("SpecialMesh")
			if not mesh then
				mesh = Instance.new("SpecialMesh")
				mesh.Parent = handle
			end
			mesh.MeshType = Enum.MeshType.FileMesh
			mesh.MeshId = "rbxassetid://99167224"
			mesh.TextureId = "rbxassetid://99167239"
			-- Tamanho reduzido um pouco (2.2)
			mesh.Scale = Vector3.new(2.2, 2.2, 2.2)
			mesh.VertexColor = Vector3.new(1, 1, 1)
		end
	end

	setupHandle(tool)
	tool.Parent = backpack

	-- ==========================================
	-- GRIPS (Posições na mão e no chão)
	-- ==========================================
	-- Na mão (Perfeito como você disse)
	local GRIP_DOC = CFrame.new(0, -1, 0) * CFrame.Angles(math.rad(90), math.rad(90), 0)
	
	-- Voando (Mais para a esquerda e mais para cima)
	-- X = -2.2 (Mais para a esquerda)
	-- Y = -1.2 (Mais para cima)
	-- Z = 0 (Centralizado no eixo de profundidade)
	local GRIP_NGANG = CFrame.new(-2.2, -1.2, 0) * CFrame.Angles(math.rad(90), 0, 0)
	
	tool.Grip = GRIP_DOC

	local equipped = false
	local isFlying = false
	local FLY_SPEED = 70

	local bodyVel, bodyGyro
	local lastTrailPos = nil
	local currentAnimTrack = nil

	local SledColors = {
		Color3.fromRGB(255, 0, 0),
		Color3.fromRGB(255, 50, 50),
		Color3.fromRGB(0, 255, 0),
		Color3.fromRGB(50, 255, 50),
		Color3.fromRGB(255, 0, 0)
	}

	local function createTrail(fromPos, toPos)
		local dist = (toPos - fromPos).Magnitude
		if dist < 1 then return end

		local mid = fromPos:Lerp(toPos, 0.5)
		local lookCF = CFrame.lookAt(mid, toPos)

		local model = Instance.new("Model")
		model.Name = "SledTrail"

		local partWidth = 0.65
		local height = 0.5

		for i, color in ipairs(SledColors) do
			local p = Instance.new("Part")
			p.Size = Vector3.new(partWidth, height, dist + 2)
			p.Anchored = true
			p.CanCollide = false
			p.Material = Enum.Material.Neon 
			p.Color = color
			p.Transparency = 0.05 
			p.CastShadow = false

			local offsetX = (i - 3) * partWidth
			p.CFrame = lookCF * CFrame.new(offsetX, -2, 0) 

			local light = Instance.new("PointLight")
			light.Color = color
			light.Brightness = 10.0 
			light.Range = 15       
			light.Parent = p

			p.Parent = model
		end

		model.Parent = workspace
		Debris:AddItem(model, 1.5)
	end

	local function cleanupMovers()
		if bodyVel then bodyVel:Destroy() bodyVel = nil end
		if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
	end

	local function stopAnimation()
		if currentAnimTrack then
			currentAnimTrack:Stop()
			currentAnimTrack:Destroy()
			currentAnimTrack = nil
		end
	end

	local function stopFlying()
		isFlying = false
		tool.Grip = GRIP_DOC
		lastTrailPos = nil
		cleanupMovers()
		stopAnimation()

		setupHandle(tool)

		local char = player.Character
		if char then
			local humanoid = char:FindFirstChild("Humanoid")
			if humanoid then
				humanoid.PlatformStand = false
				humanoid.AutoRotate = true
			end
		end
	end

	local function startAnimation(humanoid)
		stopAnimation()
		local animator = humanoid:FindFirstChildOfClass("Animator") or humanoid:WaitForChild("Animator", 2)
		if animator then
			local animObj = Instance.new("Animation")
			animObj.AnimationId = animId
			currentAnimTrack = animator:LoadAnimation(animObj)
			currentAnimTrack.Priority = Enum.AnimationPriority.Action
			currentAnimTrack:Play()
		end
	end

	local function startFlying()
		local char = player.Character
		if not char then return end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		local humanoid = char:FindFirstChild("Humanoid")
		if not hrp or not humanoid then return end

		isFlying = true
		tool.Grip = GRIP_NGANG 
		lastTrailPos = hrp.Position

		setupHandle(tool)

		humanoid.PlatformStand = true
		humanoid.AutoRotate = false

		cleanupMovers()
		startAnimation(humanoid)

		bodyVel = Instance.new("BodyVelocity")
		bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		bodyVel.Velocity = Vector3.zero
		bodyVel.Parent = hrp

		bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
		bodyGyro.P = 12000
		bodyGyro.CFrame = hrp.CFrame
		bodyGyro.Parent = hrp

		hrp.AssemblyLinearVelocity = Vector3.new(0, 25, 0)
	end

	tool.Activated:Connect(function()
		if not equipped then return end
		if isFlying then
			stopFlying()
		else
			startFlying()
		end
	end)

	tool.Equipped:Connect(function()
		equipped = true
		tool.Grip = GRIP_DOC
		setupHandle(tool)
	end)

	tool.Unequipped:Connect(function()
		equipped = false
		stopFlying()
	end)

	local function onCharacterAdded(char)
		stopFlying()
		local humanoid = char:WaitForChild("Humanoid", 5)
		if humanoid then
			humanoid.Died:Connect(stopFlying)
		end
	end

	if player.Character then
		onCharacterAdded(player.Character)
	end
	player.CharacterAdded:Connect(onCharacterAdded)

	local trailCooldown = 0
	RunService.RenderStepped:Connect(function(dt)
		if not (equipped and isFlying and player.Character) then return end

		local hrp = player.Character:FindFirstChild("HumanoidRootPart")
		local humanoid = player.Character:FindFirstChild("Humanoid")
		if not hrp or not bodyVel or not bodyGyro then return end

		local camCF = camera.CFrame
		bodyGyro.CFrame = camCF

		local moveDir = Vector3.zero

		if humanoid.MoveDirection.Magnitude > 0.05 then
			local localMove = camCF:VectorToObjectSpace(humanoid.MoveDirection)
			moveDir = Vector3.new(localMove.X, 0, localMove.Z)
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			moveDir = moveDir + Vector3.new(0, 1, 0)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
			moveDir = moveDir + Vector3.new(0, -1, 0)
		end

		if humanoid.MoveDirection.Magnitude <= 0.05 then
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Vector3.new(0, 0, -1) end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir + Vector3.new(0, 0, 1) end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir + Vector3.new(-1, 0, 0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Vector3.new(1, 0, 0) end
		end

		if moveDir.Magnitude > 0 then
			moveDir = moveDir.Unit
			local flyVector = camCF.RightVector * moveDir.X
				+ Vector3.new(0, 1, 0) * moveDir.Y
				+ camCF.LookVector * -moveDir.Z
			bodyVel.Velocity = flyVector * FLY_SPEED
		else
			bodyVel.Velocity = Vector3.zero
		end

		trailCooldown = trailCooldown - dt
		if trailCooldown <= 0 then
			trailCooldown = 0.05

			local currentPos = hrp.Position
			if lastTrailPos then
				local dist = (currentPos - lastTrailPos).Magnitude
				if dist > 1.5 then
					createTrail(lastTrailPos, currentPos)
					lastTrailPos = currentPos
				end
			else
				lastTrailPos = currentPos
			end
		end
	end)

	print("✅ Trenó centralizado!")
else
	warn("Erro ao carregar o Trenó!")
end
