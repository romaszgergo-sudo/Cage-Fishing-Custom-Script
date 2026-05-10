-- [[ CAGE-STYLE: CLEAN & FUNCTIONAL v6 ]]

local LP = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Configs
_G.Toggles = {
    AutoRod = false,
    AutoRodSell = false,
    AutoBuyBait = false,
    AutoBuyCage = false
}
_G.TargetCages = {} 
_G.SelectedBait = "Jar O' Worms"
_G.CustomBaitPos = Vector3.new(-938.8, 1.7, 814.0)

-- Clean old UI
if game:GetService("CoreGui"):FindFirstChild("CageFishingUI") then
    game:GetService("CoreGui"):FindFirstChild("CageFishingUI"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CageFishingUI"
ScreenGui.Parent = game:GetService("CoreGui")

-- Main Window
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 650, 0, 450)
MainFrame.Position = UDim2.new(0.5, -325, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 180, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
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

-- Tab System
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
    frame.ScrollBarThickness = 0
    frame.Parent = TabHolder
    Instance.new("UIListLayout", frame).Padding = UDim.new(0, 12)
    return frame
end

local FishingTab = CreateTab()
local BaitTab = CreateTab()
local MiscTab = CreateTab()
FishingTab.Visible = true

local function AddTabBtn(name, targetFrame)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -30, 0, 45)
    btn.Position = UDim2.new(0, 15, 0, 80 + (#Sidebar:GetChildren() - 1) * 55)
    btn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.Font = Enum.Font.GothamMedium
    btn.Parent = Sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(TabHolder:GetChildren()) do v.Visible = false end
        targetFrame.Visible = true
    end)
end

AddTabBtn("Fishing", FishingTab)
AddTabBtn("Bait", BaitTab)
AddTabBtn("Miscellaneous", MiscTab)

-- UI Components
local function AddToggle(name, parent, configKey)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 55)
    container.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    container.Parent = parent
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 20, 0, 0)
    label.Text = name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = container

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
        circle:TweenPosition(_G.Toggles[configKey] and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10), "Out", "Quart", 0.2)
        toggleBtn.BackgroundColor3 = _G.Toggles[configKey] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(45, 45, 45)
    end)
end

-- SIMPLE DROPDOWN SYSTEM
local function AddDropdown(name, parent, options, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 50)
    container.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    container.Parent = parent
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = name .. ": Select"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamMedium
    btn.Parent = container

    btn.MouseButton1Click:Connect(function()
        -- Cycle through options for simplicity
        local currentIdx = table.find(options, _G.SelectedBait) or 0
        local nextIdx = (currentIdx % #options) + 1
        _G.SelectedBait = options[nextIdx]
        btn.Text = name .. ": " .. _G.SelectedBait
        if callback then callback(_G.SelectedBait) end
    end)
end

-- POPULATE TABS
AddToggle("Auto Fishing Rod", FishingTab, "AutoRod")
AddToggle("Auto Sell Rod Fish", FishingTab, "AutoRodSell")
AddToggle("Cage Sniper", FishingTab, "AutoBuyCage")

-- Multi-Select Placeholder for Cages (Hardcoded example based on your screen)
AddDropdown("Target Cage", FishingTab, {"Wooden Cage", "Rusty Cage", "Iron Cage"}, function(val)
    _G.TargetCages = {val}
end)

AddToggle("Auto Buy Bait", BaitTab, "AutoBuyBait")
AddDropdown("Select Bait", BaitTab, {"Jar O' Worms", "Jar O' Grubs", "Jar O' Voidflies"}, function(val)
    _G.SelectedBait = val
end)

AddToggle("Set Bait Loc", MiscTab, "Unused") -- Simplified for set loc

-- FUNCTIONALITY LOOPS
task.spawn(function()
    while true do task.wait(1)
        if _G.Toggles.AutoBuyCage then
            pcall(function()
                for _, cage in pairs(workspace.Conveyor.Models:GetChildren()) do
                    local name = cage.Information.CageTag.Cage.Text
                    if table.find(_G.TargetCages, name) then
                        game:GetService("ReplicatedStorage").Remotes.Server.Conveyor:InvokeServer("Buy", {cage.Name})
                    end
                end
            end)
        end
        if _G.Toggles.AutoRod then pcall(function() game:GetService("ReplicatedStorage").Remotes.Server.FishFishingRod:InvokeServer() end) end
    end
end)

-- Dragging Logic
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = MainFrame.Position end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
MainFrame.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
