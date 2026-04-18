local animationIds = {
    ["83829782357897"]=true,["126830014841198"]=true,["126355327951215"]=true,["121086746534252"]=true,["105458270463374"]=true,["18885909645"]=true,["94162446513587"]=true,["93069721274110"]=true,["97433060861952"]=true,["121293883585738"]=true,["92173139187970"]=true,["106847695270773"]=true,["125403313786645"]=true,["81639435858902"]=true,["137314737492715"]=true,["120112897026015"]=true,["82113744478546"]=true,["118298475669935"]=true,["126681776859538"]=true,["129976080405072"]=true,["109667959938617"]=true,["74707328554358"]=true,["133336594357903"]=true,["86204001129974"]=true,["70371667919898"]=true,["131543461321709"]=true,["106776364623742"]=true,["136323728355613"]=true,["109230267448394"]=true,["139835501033932"]=true,["114356208094580"]=true,["106538427162796"]=true,["126896426760253"]=true,["126171487400618"]=true,["97167027849946"]=true,["99135633258223"]=true,["98456918873918"]=true,["83251433279852"]=true,["122709416391891"]=true,["87989533095285"]=true,["139309647473555"]=true,["133363345661032"]=true,["128414736976503"]=true,["77375846492436"]=true,["100358581940485"]=true,["91758760621955"]=true,["94634594529334"]=true,["90620531468240"]=true,["94958041603347"]=true,["131642454238375"]=true,["110702884830060"]=true,["76312020299624"]=true,["126654961540956"]=true,["139613699193400"]=true,["91509234639766"]=true,["114506382930939"]=true,["82113036350227"]=true,["88451353906104"]=true,["99829427721752"]=true
}

local delayedAnimations = {}
local recent = {}
local CirclePart, HitCirclePart
local blockRemote, blockButton, connections = nil, nil, {}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function(char)
    Character, Humanoid, RootPart = char, char:WaitForChild("Humanoid"), char:WaitForChild("HumanoidRootPart")
end)

local function isKiller(player)
    local killers = Workspace:FindFirstChild("Players") and Workspace.Players:FindFirstChild("Killers")
    if not killers or not player then return false end
    return killers:FindFirstChild(player.Name) or (player.Character and killers:FindFirstChild(player.Character.Name))
end

local function CreateCircle(partRef, size)
    if partRef and partRef.Parent then return partRef end
    local p = Instance.new("Part")
    p.Anchored, p.CanCollide, p.Transparency = true, false, 0.2
    p.Material, p.Shape = Enum.Material.Neon, Enum.PartType.Cylinder
    p.Size = Vector3.new(0.2, size, size)
    p.Color = Color3.fromRGB(255, 0, 0)
    p.Parent = Workspace
    return p
end

local function GetMainKiller()
    local killers = Workspace:FindFirstChild("Players") and Workspace.Players:FindFirstChild("Killers")
    if not killers then return nil end
    for _, k in ipairs(killers:GetChildren()) do
        local hrp = k:FindFirstChild("HumanoidRootPart")
        if hrp then return k, hrp.CFrame end
    end
end

local function CheckWall(fromPos, toPos)
    if not getgenv().HutaoConfig.WallCheck then return false end
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    local blacklist = {Character, Workspace:FindFirstChild("Players")}
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then table.insert(blacklist, obj) end
    end
    rayParams.FilterDescendantsInstances = blacklist
    return Workspace:Raycast(fromPos, (toPos - fromPos), rayParams) ~= nil
end

local function UpdateCircle()
    if not RootPart then return end
    local killer, kcf = GetMainKiller()
    if not kcf then return end

    if getgenv().HutaoConfig.ShowCircle then
        CirclePart = CreateCircle(CirclePart, getgenv().HutaoConfig.RangeCheck * 2)
        CirclePart.CFrame = (kcf + Vector3.new(0, -3, 0)) * CFrame.Angles(0, 0, math.rad(90))
        CirclePart.Size = Vector3.new(0.2, getgenv().HutaoConfig.RangeCheck * 2, getgenv().HutaoConfig.RangeCheck * 2)
        if getgenv().HutaoConfig.UseHitCircle then
            CirclePart.Color = Color3.fromRGB(255, 0, 0)
        else
            local inside = (RootPart.Position - kcf.Position).Magnitude <= getgenv().HutaoConfig.RangeCheck
            CirclePart.Color = inside and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        end
    elseif CirclePart then CirclePart:Destroy() CirclePart = nil end

    if getgenv().HutaoConfig.UseHitCircle then
        HitCirclePart = CreateCircle(HitCirclePart, getgenv().HutaoConfig.HitRange * 2)
        local pos = kcf.Position + kcf.LookVector * (getgenv().HutaoConfig.HitRange * 0.8) + Vector3.new(0, -3, 0)
        HitCirclePart.CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, math.rad(90))
        local inside = (RootPart.Position - pos).Magnitude <= getgenv().HutaoConfig.HitRange
        HitCirclePart.Color = inside and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    elseif HitCirclePart then HitCirclePart:Destroy() HitCirclePart = nil end
end

local function fastBlock()
    if blockRemote then
        pcall(function() blockRemote:FireServer(true) task.delay(0, function() blockRemote:FireServer(false) end) end)
    elseif blockButton then
        for i = 1, #connections do pcall(function() connections[i]:Fire() end) end
        pcall(function() blockButton:Activate() end)
    end
end

local function initBlockButton()
    local container = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MainUI"):WaitForChild("AbilityContainer")
    blockButton = container:FindFirstChild("Block")
    if blockButton then
        connections = getconnections(blockButton.MouseButton1Click)
        local f = connections[1] and connections[1].Function
        if f and islclosure(f) then
            for _, v in pairs(getupvalues(f)) do
                if typeof(v) == "Instance" and v:IsA("RemoteEvent") then blockRemote = v break end
            end
        end
    end
end

initBlockButton()
LocalPlayer.CharacterAdded:Connect(function() task.wait(0.5) initBlockButton() end)

local function onAnimationPlayed(player, char, track)
    if not getgenv().HutaoConfig.AutoBlock or not track.Animation then return end
    local animId = tostring(track.Animation.AnimationId):match("%d+")
    if not animationIds[animId] then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not RootPart or not root then return end

    if getgenv().HutaoConfig.StubCheckEnabled and math.abs(root.Position.Y - RootPart.Position.Y) > getgenv().HutaoConfig.StubCheck then return end

    local inRange = false
    if getgenv().HutaoConfig.UseHitCircle then
        local _, kcf = GetMainKiller()
        if kcf then
            local pos = kcf.Position + kcf.LookVector * (getgenv().HutaoConfig.HitRange * 0.8)
            inRange = (RootPart.Position - pos).Magnitude <= getgenv().HutaoConfig.HitRange
        end
    else
        inRange = (RootPart.Position - root.Position).Magnitude <= getgenv().HutaoConfig.RangeCheck
    end

    if inRange and not CheckWall(RootPart.Position, root.Position) then
        local now = tick()
        if now - (recent[player.UserId] or 0) > 0.02 then
            recent[player.UserId] = now
            fastBlock()
        end
    end
end

local function monitorCharacter(player, char)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then hum.AnimationPlayed:Connect(function(track) onAnimationPlayed(player, char, track) end) end
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        if p.Character then monitorCharacter(p, p.Character) end
        p.CharacterAdded:Connect(function(c) monitorCharacter(p, c) end)
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(c) monitorCharacter(p, c) end)
end)

RunService.Heartbeat:Connect(UpdateCircle)
