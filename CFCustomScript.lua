-- [[ CAGE-STYLE: FULL FARM V5 ]]

-- Clean up old menu if it exists
if game:GetService("CoreGui"):FindFirstChild("CageStyleExtension") then
    game:GetService("CoreGui"):FindFirstChild("CageStyleExtension"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Sidebar = Instance.new("Frame")
local ContentFrame = Instance.new("ScrollingFrame")
local TitleLabel = Instance.new("TextLabel")
local UIListLayout = Instance.new("UIListLayout")
local UserInputService = game:GetService("UserInputService")
local LP = game.Players.LocalPlayer

-- Configs
_G.AutoRod = false
_G.AutoRodSell = false
_G.AutoBait = false
_G.AutoBuyBait = false
_G.AutoClaim = false
_G.AutoSell = false
_G.AutoBuyCage = false
_G.TargetCages = {} 
_G.CustomBaitPos = Vector3.new(-938.8, 1.7, 814.0)

local CageList = {
    "Wooden Cage", "Rusty Cage", "Plastic Cage", "Iron Cage", "Shark Cage", 
    "Crystal Cage", "Moonlight Cage", "Sunlight Cage", "Angelic Cage", 
    "Diamond Cage", "Radioactive Cage", "Steampunk Cage", "Divine Doom Cage", 
    "Vine Cage", "Halloween 2025 Cage", "Money Vault Cage", "Free Cage Lol 67", 
    "Christmas 2025 Cage", "Fossil Cage", "Starry Cage", "The Tiger Enclosure", 
    "Bloodmoon Cage", "Hellfire Cage", "Galaxy Cage", "Easter Cage", 
    "Pirate Cage", "Atlantean Cage", "Arcade Cage"
}

-- Container
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "CageStyleExtension"
ScreenGui.ResetOnSpawn = false

-- Main Body
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -200)
MainFrame.Size = UDim2.new(0, 420, 0, 420) 
MainFrame.Active = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- Sidebar
Sidebar.Name = "Sidebar"
Sidebar.Parent = MainFrame
Sidebar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
Sidebar.Size = UDim2.new(0, 120, 1, 0)
Sidebar.BorderSizePixel = 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

TitleLabel.Parent = Sidebar
TitleLabel.Size = UDim2.new(1, 0, 0, 50)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "CUSTOM V5"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold

-- Content Area
ContentFrame.Name = "Content"
ContentFrame.Parent = MainFrame
ContentFrame.Position = UDim2.new(0, 130, 0, 15)
ContentFrame.Size = UDim2.new(1, -145, 1, -30)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ScrollBarThickness = 3
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

UIListLayout.Parent = ContentFrame
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Button Template
local function CreateToggleButton(name, globalVar, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -5, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 11
    btn.Parent = ContentFrame

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        if globalVar ~= "Unused" then
            _G[globalVar] = not _G[globalVar]
            btn.BackgroundColor3 = _G[globalVar] and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(35, 35, 35)
        end
        if callback then callback(btn) end
    end)
    return btn
end

-- [1] ROD FARMING
CreateToggleButton("Auto Fishing Rod", "AutoRod")
CreateToggleButton("Auto Sell (Rod Fish)", "AutoRodSell")

-- [2] CAGE SNIPER
CreateToggleButton("Auto Buy Selected Cages", "AutoBuyCage")

local DropBtn = CreateToggleButton("Filter Cages (" .. #_G.TargetCages .. " Selected)", "Unused")
local DropFrame = Instance.new("ScrollingFrame", ContentFrame)
DropFrame.Size = UDim2.new(1, -5, 0, 0)
DropFrame.Visible = false
DropFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
DropFrame.BorderSizePixel = 0
DropFrame.ScrollBarThickness = 2
DropFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UIListLayout", DropFrame).Padding = UDim.new(0, 2)
Instance.new("UICorner", DropFrame).CornerRadius = UDim.new(0, 6)

for _, cageName in pairs(CageList) do
    local cBtn = Instance.new("TextButton", DropFrame)
    cBtn.Size = UDim2.new(1, 0, 0, 30)
    cBtn.Text = cageName
    cBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    cBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    cBtn.Font = Enum.Font.Gotham
    cBtn.TextSize = 11
    
    cBtn.MouseButton1Click:Connect(function()
        if table.find(_G.TargetCages, cageName) then
            for i, v in pairs(_G.TargetCages) do if v == cageName then table.remove(_G.TargetCages, i) end end
            cBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        else
            table.insert(_G.TargetCages, cageName)
            cBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        end
        DropBtn.Text = "Filter Cages (" .. #_G.TargetCages .. " Selected)"
    end)
end

DropBtn.MouseButton1Click:Connect(function()
    DropFrame.Visible = not DropFrame.Visible
    DropFrame.Size = DropFrame.Visible and UDim2.new(1, -5, 0, 160) or UDim2.new(1, -5, 0, 0)
end)

-- [3] BAIT & UTILS
CreateToggleButton("Auto Buy Bait (Worms)", "AutoBuyBait")
CreateToggleButton("Auto Use Bait", "AutoBait")
CreateToggleButton("Set Bait Loc", "Unused", function(btn)
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        _G.CustomBaitPos = LP.Character.HumanoidRootPart.Position
        btn.Text = "SAVED!"
        task.wait(1)
        btn.Text = "Set Bait Loc"
    end
end)
CreateToggleButton("Auto Claim Income", "AutoClaim")
CreateToggleButton("Auto Sell (Cage Loot)", "AutoSell")

CreateToggleButton("TP Exhibition", "Unused", function()
    if LP.Character and LP.Character.PrimaryPart then
        LP.Character:SetPrimaryPartCFrame(CFrame.new(-1097, 13, 450))
    end
end)

-- ==========================================
-- ||             LOOPS                    ||
-- ==========================================

-- Auto Rod
task.spawn(function()
    while true do task.wait(1.5)
        if _G.AutoRod then pcall(function() game:GetService("ReplicatedStorage").Remotes.Server.FishFishingRod:InvokeServer() end) end
    end
end)

-- Auto Rod Sell
task.spawn(function()
    while true do task.wait(3)
        if _G.AutoRodSell then pcall(function() game:GetService("ReplicatedStorage").Remotes.Server.FisherMan:FireServer("SellFish") end) end
    end
end)

-- Cage Sniper
task.spawn(function()
    while true do task.wait(0.5)
        if _G.AutoBuyCage and #_G.TargetCages > 0 then
            pcall(function()
                for _, model in pairs(workspace.Conveyor.Models:GetChildren()) do
                    local tag = model:FindFirstChild("Information") and model.Information:FindFirstChild("CageTag")
                    if tag and table.find(_G.TargetCages, tag.Cage.Text) then
                        game:GetService("ReplicatedStorage").Remotes.Server.Conveyor:InvokeServer("Buy", {model.Name})
                    end
                end
            end)
        end
    end
end)

-- Bait & Other Loops
task.spawn(function()
    while true do task.wait(5)
        if _G.AutoBuyBait then game:GetService("ReplicatedStorage").Remotes.Server.Bait:FireServer("Buy", 7) end
        if _G.AutoClaim then game:GetService("ReplicatedStorage").Remotes.Server.claimPassiveIncome:FireServer() end
    end
end)

task.spawn(function()
    while true do
        if _G.AutoBait then
            pcall(function()
                local args = {"Activate", {ItemKey = "Bait-7", RelativeFactor = Vector3.new(0.5, 1.7, 0.1), ZoneIndex = 1, Position = _G.CustomBaitPos}}
                game:GetService("ReplicatedStorage").Remotes.Server.Tool:InvokeServer(unpack(args))
            end)
            task.wait(300)
        else task.wait(1) end
    end
end)

-- Inventory Sell Loop
task.spawn(function()
    while true do task.wait(3)
        if _G.AutoSell then
            pcall(function()
                local inv = LP.PlayerGui.Main.Centre.Inventory.ScrollingFrame
                local items = {}
                for _, icon in pairs(inv:GetChildren()) do
                    if icon.Name:find("Loot-") then
                        local lock = icon:GetAttribute("Locked") or (icon:FindFirstChild("Locked") and icon.Locked.Visible)
                        if not lock then table.insert(items, icon.Name) end
                    end
                end
                if #items > 0 then game:GetService("ReplicatedStorage").Remotes.Server.FishShop:FireServer("SellAll", {items}) end
            end)
        end
    end
end)

-- Dragging Logic
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = MainFrame.Position end
end)
MainFrame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
MainFrame.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightControl then MainFrame.Visible = not MainFrame.Visible end
end)
