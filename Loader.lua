loadstring([[
    -- Anti-Cheat Tweaks
    local function obfuscate(str)
        return str:gsub(".", function(c) return string.char(c:byte() + 1) end)
    end
    local function deobfuscate(str)
        return str:gsub(".", function(c) return string.char(c:byte() - 1) end)
    end

    -- Delayed execution
    task.wait(math.random(2, 5))

    -- Core Config
    local Config = {
        Enabled = true,
        PickupRange = math.random(2.8, 3.2),
        Cooldown = math.random(0.08, 0.12)
    }
    local MONEY_TAG = deobfuscate(obfuscate("DroppedCash"))

    -- Service References
    local Players = game:GetService(deobfuscate(obfuscate("Players")))
    local Workspace = game:GetService(deobfuscate(obfuscate("Workspace")))
    local RunService = game:GetService(deobfuscate(obfuscate("RunService")))

    -- Player/Character
    local LocalPlayer = Players.LocalPlayer
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    task.wait(0.5)
    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

    -- Check if moving
    local function isPlayerMoving()
        return HumanoidRootPart.Velocity.Magnitude > 0.5
    end

    -- Collect function
    local function collectMoney()
        if not Config.Enabled or not isPlayerMoving() then return end
        if tick() - (lastCollect or 0) < Config.Cooldown then return end
        lastCollect = tick()

        local minPos = HumanoidRootPart.Position - Vector3.new(Config.PickupRange, 1, Config.PickupRange)
        local maxPos = HumanoidRootPart.Position + Vector3.new(Config.PickupRange, 1, Config.PickupRange)
        local moneyInRange = Workspace:FindPartsInRegion3(Region3.new(minPos, maxPos), Character, 5)

        if #moneyInRange > 0 then
            local randomCash = moneyInRange[math.random(1, #moneyInRange)]
            local cashObject = randomCash:FindFirstAncestorWithTag(MONEY_TAG) or (randomCash:HasTag(MONEY_TAG) and randomCash)
            if cashObject then
                task.wait(math.random(0.01, 0.03))
                local touchEvent = cashObject.Touched:FindFirstChildOfClass("BindableEvent")
                if touchEvent then
                    touchEvent:Fire(HumanoidRootPart)
                elseif cashObject:FindFirstChildOfClass("ProximityPrompt") then
                    local prompt = cashObject.ProximityPrompt
                    prompt:InputHoldBegin()
                    task.wait(prompt.HoldDuration + math.random(0.02, 0.05))
                    prompt:InputHoldEnd()
                end
            end
        end
    end

    -- Connect
    local Connection = RunService.Heartbeat:Connect(collectMoney)

    -- Respawn handler
    LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(math.random(1, 3))
        Character = newChar
        HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
        if Connection then Connection:Disconnect() end
        Connection = RunService.Heartbeat:Connect(collectMoney)
    end)

    -- Cleanup
    game:GetService("Players").PlayerRemoving:Connect(function(p)
        if p == LocalPlayer and Connection then
            Connection:Disconnect()
            Connection = nil
        end
    end)

    print(deobfuscate(obfuscate("Script running")))
]])()
