-- [[ CAGE-STYLE: ENHANCED PRO UI v5 ]]

local LP = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Global Configs
_G.Toggles = {
    AutoCollect = false,
    AutoSell = false,
    AutoRod = false,
    AutoRodSell = false,
    AutoBuyBait = false,
    AutoBuyCage = false,
    KeepEventFish = false
}
_G.TargetCages = {} 
_G.SelectedBait = "Jar O' Worms"
_G.CustomBaitPos = Vector3.new(-938.8, 1.7, 814.0)

-- UI Cleanup
if game:GetService("CoreGui"):FindFirstChild("CageFishingUI") then
    game:GetService("CoreGui"):FindFirstChild("CageFishingUI"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CageFishingUI"
ScreenGui.Parent = game:GetService("CoreGui")

-- Main Window (Sized Up)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 650, 0, 450) -- Made significantly bigger
MainFrame.Position = UDim2.new(0.5, -325, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 180, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 15)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 70)
Title.Text = "Cage Fishing"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.BackgroundTransparency = 1
Title.Parent = Sidebar

-- Tab Container
local TabHolder = Instance.new("Frame")
TabHolder.Position = UDim2.new(0, 200, 0, 20)
TabHolder.Size = UDim2.new(1, -220, 1, -40)
TabHolder.BackgroundTransparency = 1
TabHolder.Parent = MainFrame

local function CreateTab()
    local frame = Instance.new("ScrollingFrame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    frame.ScrollBarThickness = 3
    frame.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 50)
    frame.Parent = TabHolder
    local layout = Instance.new("UIListLayout", frame)
    layout.Padding = UDim.new(0, 12)
    return frame
end

local AutofarmTab = CreateTab()
local MiscTab = CreateTab()
AutofarmTab.Visible = true

-- Sidebar Navigation Logic
local lastBtn = nil
local function AddTabBtn(name, targetFrame)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -30, 0, 45)
    btn.Position = UDim2.new(0, 15, 0, 80 + (#Sidebar:GetChildren() - 1) * 55)
    btn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    btn.Parent = Sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(TabHolder:GetChildren()) do v.Visible = false end
        targetFrame.Visible = true
        if lastBtn then TweenService:Create(lastBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(24, 24, 24)}):Play() end
        TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
        lastBtn = btn
    end)
end

AddTabBtn("Autofarm", AutofarmTab)
AddTabBtn("Miscellaneous", MiscTab)

-- PRO STYLE TOGGLE COMPONENT
local function AddToggle(name, parent, configKey, desc)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 60)
    container.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    container.Parent = parent
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 0, 30)
    label.Position = UDim2.new(0, 20, 0, 8)
    label.Text = name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 15
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = container

    if desc then
        local dLabel = Instance.new("TextLabel")
        dLabel.Size = UDim2.new(0.7, 0, 0, 20)
        dLabel.Position = UDim2.new(0, 20, 0, 30)
        dLabel.Text = desc
        dLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
        dLabel.Font = Enum.Font.Gotham
        dLabel.TextSize = 12
        dLabel.TextXAlignment = Enum.TextXAlignment.Left
        dLabel.BackgroundTransparency = 1
        dLabel.Parent = container
    end

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 46, 0, 24)
    toggleBtn.Position = UDim2.new(1, -66, 0.5, -12)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    toggleBtn.Text = ""
    toggleBtn.Parent = container
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 20, 0, 20)
    circle.Position = UDim2.new(0, 2, 0.5, -10)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.Parent = toggleBtn
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    toggleBtn.MouseButton1Click:Connect(function()
        _G.Toggles[configKey] = not _G.Toggles[configKey]
        local targetPos = _G.Toggles[configKey] and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        local targetCol = _G.Toggles[configKey] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(45, 45, 45)
        TweenService:Create(circle, TweenInfo.new(0.2), {Position = targetPos}):Play()
        TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = targetCol}):Play()
    end)
end

-- BUTTON COMPONENT (For Misc Tab)
local function AddActionButton(name, parent, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 50)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    btn.MouseButton1Click:Connect(callback)
end

-- POPULATE AUTOFARM
AddToggle("Auto Collect", AutofarmTab, "AutoCollect", "Automatically claims cage rewards")
AddToggle("Auto Sell", AutofarmTab, "AutoSell", "Sells unlocked items from inventory")
AddToggle("Keep Event Fish", AutofarmTab, "KeepEventFish", "Stops selling items marked as Event")
AddToggle("Auto Fishing Rod", AutofarmTab, "AutoRod", "Auto-casts your fishing rod")
AddToggle("Auto Sell Rod Fish", AutofarmTab, "AutoRodSell", "Sells fish caught by rod")
AddToggle("Cage Sniper", AutofarmTab, "AutoBuyCage", "Buys specific cages from the conveyor")

-- POPULATE MISCELLANEOUS
AddActionButton("Set Bait Location", MiscTab, function()
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        _G.CustomBaitPos = LP.Character.HumanoidRootPart.Position
        print("Bait Position Set!")
    end
end)

AddActionButton("Teleport to Exhibition", MiscTab, function()
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character.HumanoidRootPart.CFrame = CFrame.new(-1097, 13, 450)
    end
end)

AddToggle("Auto Buy Bait", MiscTab, "AutoBuyBait", "Buys selected bait automatically")

-- [Funtionality for Loot Checking]
-- Checking 'Locked' text and visibility from your provided Explorer images
local function IsItemLocked(icon)
    local lockedLabel = icon:FindFirstChild("Locked")
    return lockedLabel and lockedLabel.Visible == true
end

-- DRAGGING & CLOSE LOGIC
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
MainFrame.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

-- Keybind to hide (RightControl)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
