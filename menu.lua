-- [[ Rscripts Risk Notice ]]
-- This script is not verified by rscripts.net. Deal with caution.
-- [[ End Rscripts Risk Notice ]]

-- ============================================================
-- Serviços
-- ============================================================
local Players           = game:GetService("Players")
local Workspace         = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui           = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- Remotes (descobertos via Remote Spy)
-- ============================================================
local Remotes       = ReplicatedStorage:WaitForChild("Remotes")
local ClickEvent    = Remotes:WaitForChild("Click")
local FuerzaEvent   = Remotes:WaitForChild("Fuerza")
local RebirthEvent  = Remotes:WaitForChild("Rebirth")

-- ============================================================
-- Estado
-- ============================================================
local State = {
    InstaKill    = false,
    GodMode      = false,
    KillRange    = 80,
    SpeedOn      = false,
    Speed        = 16,
    AutoClick    = false,
    CPS          = 10,
    AutoRebirth  = false,
    RebirthDelay = 2,
}

-- ============================================================
-- Utilidades
-- ============================================================
local function isEnemy(model)
    if not model or not model:IsA("Model") then return false end
    if model == LocalPlayer.Character then return false end
    local owner = Players:GetPlayerFromCharacter(model)
    if owner and owner == LocalPlayer then return false end
    return true
end

local function killHumanoid(hum)
    if not hum or hum.Health <= 0 then return end
    pcall(function()
        hum.MaxHealth = 0
        hum.Health = 0
        hum:ChangeState(Enum.HumanoidStateType.Dead)
    end)
    pcall(function()
        hum:TakeDamage(hum.MaxHealth + 999999)
    end)
end

-- ============================================================
-- God Mode
-- ============================================================
local function applyGodMode(char)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.MaxHealth = math.huge
        hum.Health = math.huge
        hum.BreakJointsOnDeath = false
    end
end

local function hookChar(char)
    if State.GodMode then applyGodMode(char) end
    char.ChildAdded:Connect(function(c)
        if c:IsA("Humanoid") and State.GodMode then applyGodMode(char) end
    end)
end

if LocalPlayer.Character then hookChar(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(hookChar)

task.spawn(function()
    while true do
        if State.GodMode then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.MaxHealth = math.huge
                if hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
            end
        end
        task.wait(0.2)
    end
end)

-- ============================================================
-- Speed
-- ============================================================
task.spawn(function()
    while true do
        if State.SpeedOn then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.WalkSpeed ~= State.Speed then hum.WalkSpeed = State.Speed end
        end
        task.wait(0.1)
    end
end)

-- ============================================================
-- Insta Kill
-- ============================================================
task.spawn(function()
    while true do
        if State.InstaKill then
            local char = LocalPlayer.Character
            local myRoot = char and char:FindFirstChild("HumanoidRootPart")
            if myRoot then
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("Humanoid") and isEnemy(obj.Parent) then
                        local root = obj.Parent and obj.Parent:FindFirstChild("HumanoidRootPart")
                        if root and (myRoot.Position - root.Position).Magnitude <= State.KillRange then
                            killHumanoid(obj)
                        end
                    end
                end
            end
        end
        task.wait(0.15)
    end
end)

-- ============================================================
-- Auto Click
-- ============================================================
task.spawn(function()
    while true do
        if State.AutoClick then
            pcall(function() ClickEvent:FireServer() end)
            task.wait(1 / math.max(State.CPS, 1))
        else
            task.wait(0.1)
        end
    end
end)

-- ============================================================
-- Auto Rebirth
-- ============================================================
task.spawn(function()
    while true do
        if State.AutoRebirth then
            pcall(function() RebirthEvent:FireServer() end)
            task.wait(State.RebirthDelay)
        else
            task.wait(0.5)
        end
    end
end)

-- ============================================================
-- GUI — Rayfield Mobile
-- ============================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateMobile({
    Name = "Assasin leveling menu",
    LoadingTitle = "Assasin leveling menu",
    LoadingSubtitle = "By BRN",
    ShowText = "BRN", -- Texto que aparece na tela para reabrir no mobile
    Theme = "Default",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "AssasinBRN",
        FileName = "Config"
    },
    KeySystem = false
})

-- ============================================================
-- Aba Main
-- ============================================================
local MainTab = Window:CreateTab("Main", 4483345998)

MainTab:CreateToggle({
    Name = "Auto Click (Força)",
    CurrentValue = false,
    Flag = "AutoClick",
    Callback = function(v) State.AutoClick = v end
})

MainTab:CreateSlider({
    Name = "Velocidade (CPS)",
    Range = {1, 50},
    Increment = 1,
    Suffix = "CPS",
    CurrentValue = 10,
    Flag = "CPS",
    Callback = function(v) State.CPS = v end
})

MainTab:CreateToggle({
    Name = "Auto Rebirth",
    CurrentValue = false,
    Flag = "AutoRebirth",
    Callback = function(v) State.AutoRebirth = v end
})

MainTab:CreateSlider({
    Name = "Delay do Rebirth",
    Range = {1, 10},
    Increment = 1,
    Suffix = "segundos",
    CurrentValue = 2,
    Flag = "RebirthDelay",
    Callback = function(v) State.RebirthDelay = v end
})

MainTab:CreateToggle({
    Name = "God Mode",
    CurrentValue = false,
    Flag = "GodMode",
    Callback = function(v)
        State.GodMode = v
        if v and LocalPlayer.Character then applyGodMode(LocalPlayer.Character) end
    end
})

MainTab:CreateToggle({
    Name = "Speed",
    CurrentValue = false,
    Flag = "SpeedOn",
    Callback = function(v) State.SpeedOn = v end
})

MainTab:CreateSlider({
    Name = "Valor do Speed",
    Range = {16, 500},
    Increment = 5,
    Suffix = "WalkSpeed",
    CurrentValue = 16,
    Flag = "SpeedValue",
    Callback = function(v) State.Speed = v end
})

-- ============================================================
-- Aba Combat
-- ============================================================
local CombatTab = Window:CreateTab("Combat", 4483345998)

CombatTab:CreateToggle({
    Name = "Insta Kill",
    CurrentValue = false,
    Flag = "InstaKill",
    Callback = function(v) State.InstaKill = v end
})

CombatTab:CreateSlider({
    Name = "Alcance do Kill",
    Range = {20, 500},
    Increment = 20,
    Suffix = "studs",
    CurrentValue = 80,
    Flag = "KillRange",
    Callback = function(v) State.KillRange = v end
})

Rayfield:LoadConfiguration()

-- ============================================================
-- Trava o Menu na Tela
-- ============================================================
task.spawn(function()
    task.wait(2)

    local mainFrame = nil

    local function findMainFrame()
        local guis = {}
        for _, g in ipairs(CoreGui:GetChildren()) do
            if g:IsA("ScreenGui") then table.insert(guis, g) end
        end
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if pg then
            for _, g in ipairs(pg:GetChildren()) do
                if g:IsA("ScreenGui") then table.insert(guis, g) end
            end
        end

        for _, gui in ipairs(guis) do
            local nome = gui.Name:lower()
            if nome:find("rayfield") or nome:find("sirius") then
                for _, obj in ipairs(gui:GetDescendants()) do
                    if obj:IsA("Frame") and obj.Active and obj.Draggable then
                        return obj
                    end
                end
            end
        end
        return nil
    end

    mainFrame = findMainFrame()

    local function clampToScreen()
        if not mainFrame or not mainFrame.Parent then
            mainFrame = findMainFrame()
            if not mainFrame then return end
        end

        local viewport = Workspace.CurrentCamera.ViewportSize
        local absPos = mainFrame.AbsolutePosition
        local absSize = mainFrame.AbsoluteSize

        local newX = math.clamp(absPos.X, 0, math.max(0, viewport.X - absSize.X))
        local newY = math.clamp(absPos.Y, 0, math.max(0, viewport.Y - absSize.Y))

        if newX ~= absPos.X or newY ~= absPos.Y then
            mainFrame.Position = UDim2.new(0, newX, 0, newY)
        end
    end

    while true do
        pcall(clampToScreen)
        task.wait(0.05)
    end
end)