-- [[ CAGE-STYLE: PRO UI UPDATE ]]

local LP = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- Global Configs
_G.Toggles = {
    AutoCollect = false,
    AutoSell = false,
    AutoRod = false,
    AutoRodSell = false,
    AutoBuyBait = false,
    AutoBuyCage = false
}
_G.TargetCages = {} -- Table for multi-select
_G.TargetBait = "Jar O' Worms"

-- UI Cleanup
if game:GetService("CoreGui"):FindFirstChild("CageFishingUI") then
    game:GetService("CoreGui"):FindFirstChild("CageFishingUI"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CageFishingUI"
ScreenGui.Parent = game:GetService("CoreGui")

-- Main Window
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 140, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Text = "Cage Fishing"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.BackgroundTransparency = 1
Title.Parent = Sidebar

-- Tab Container
local TabHolder = Instance.new("Frame")
TabHolder.Position = UDim2.new(0, 150, 0, 15)
TabHolder.Size = UDim2.new(1, -165, 1, -30)
TabHolder.BackgroundTransparency = 1
TabHolder.Parent = MainFrame

local function CreateTab(name)
    local frame = Instance.new("ScrollingFrame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    frame.ScrollBarThickness = 2
    frame.Parent = TabHolder
    local layout = Instance.new("UIListLayout", frame)
    layout.Padding = UDim.new(0, 10)
    return frame
end

local AutofarmTab = CreateTab("Autofarm")
local MiscTab = CreateTab("Miscellaneous")
AutofarmTab.Visible = true -- Default

-- Sidebar Buttons
local function AddTabBtn(name, targetFrame)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, 50 + (#Sidebar:GetChildren() * 40))
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamMedium
    btn.Parent = Sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(TabHolder:GetChildren()) do v.Visible = false end
        targetFrame.Visible = true
    end)
end

AddTabBtn("Autofarm", AutofarmTab)
AddTabBtn("Miscellaneous", MiscTab)

-- PRO STYLE TOGGLE
local function AddToggle(name, parent, configKey)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 45)
    container.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    container.Parent = parent
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.Text = name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = container

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 40, 0, 20)
    toggleBtn.Position = UDim2.new(1, -55, 0.5, -10)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    toggleBtn.Text = ""
    toggleBtn.Parent = container
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 16, 0, 16)
    circle.Position = UDim2.new(0, 2, 0.5, -8)
    circle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    circle.Parent = toggleBtn
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    toggleBtn.MouseButton1Click:Connect(function()
        _G.Toggles[configKey] = not _G.Toggles[configKey]
        if _G.Toggles[configKey] then
            circle:TweenPosition(UDim2.new(1, -18, 0.5, -8), "Out", "Quart", 0.2)
            toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        else
            circle:TweenPosition(UDim2.new(0, 2, 0.5, -8), "Out", "Quart", 0.2)
            toggleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        end
    end)
end

-- Populate Tabs
AddToggle("Auto Collect", AutofarmTab, "AutoCollect")
AddToggle("Auto Sell", AutofarmTab, "AutoSell")
AddToggle("Auto Fishing Rod", AutofarmTab, "AutoRod")
AddToggle("Auto Sell Rod Fish", AutofarmTab, "AutoRodSell")
AddToggle("Cage Sniper", AutofarmTab, "AutoBuyCage")

-- DRAGGING LOGIC
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
    end
end)
MainFrame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
MainFrame.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

-- LOOPS (Example of the new Scanner integration)
task.spawn(function()
    while true do task.wait(1)
        if _G.Toggles.AutoBuyCage then
            pcall(function()
                local conveyorModels = workspace.Conveyor.Models
                for _, cage in pairs(conveyorModels:GetChildren()) do
                    local nameLabel = cage.Information.CageTag.Cage
                    -- Here we check against the multi-select table
                    if table.find(_G.TargetCages, nameLabel.Text) then
                        game:GetService("ReplicatedStorage").Remotes.Server.Conveyor:InvokeServer("Buy", {cage.Name})
                    end
                end
            end)
        end
    end
end)
