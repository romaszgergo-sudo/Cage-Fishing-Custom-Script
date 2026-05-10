-- [[ CAGE-STYLE: CONVEYOR SCANNER UPDATE ]]

-- Clean up old menu
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

-- Global Toggles & Configs
_G.AutoBait = false
_G.CustomBaitPos = Vector3.new(-938.8, 1.7, 814.0)
_G.AutoClaim = false
_G.AutoSell = false
_G.AutoRod = false
_G.AutoRodSell = false
_G.AutoBuyBait = false
_G.AutoBuyCage = false
_G.TargetCageName = "Iron Cage" -- Change this to the exact name shown over the cage

-- Container
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "CageStyleExtension"
ScreenGui.ResetOnSpawn = false

-- Main Body
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -150)
MainFrame.Size = UDim2.new(0, 320, 0, 320)
MainFrame.Active = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Sidebar
Sidebar.Name = "Sidebar"
Sidebar.Parent = MainFrame
Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Sidebar.Size = UDim2.new(0, 100, 1, 0)
Sidebar.BorderSizePixel = 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

TitleLabel.Parent = Sidebar
TitleLabel.Size = UDim2.new(1, 0, 0, 40)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "CAGE v3"
TitleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold

-- Content Area
ContentFrame.Name = "Content"
ContentFrame.Parent = MainFrame
ContentFrame.Position = UDim2.new(0, 110, 0, 10)
ContentFrame.Size = UDim2.new(0, 200, 1, -20)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 4
ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

UIListLayout.Parent = ContentFrame
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Button Template
local function CreateToggleButton(name, globalVar, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.Parent = ContentFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        if globalVar ~= "Unused" then
            _G[globalVar] = not _G[globalVar]
            btn.BackgroundColor3 = _G[globalVar] and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(35, 35, 35)
        end
        if callback then callback(btn) end
    end)
    return btn
end

-- ==========================================
-- ||             FEATURES                 ||
-- ==========================================

-- [1] AUTO BAIT
CreateToggleButton("Auto Bait (Cage)", "AutoBait")
CreateToggleButton("Set Bait Loc", "Unused", function(btn)
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        _G.CustomBaitPos = LP.Character.HumanoidRootPart.Position
        btn.Text = "SAVED!"
        task.wait(1)
        btn.Text = "Set Bait Loc"
    end
end)

task.spawn(function()
    while true do
        if _G.AutoBait then
            pcall(function()
                game:GetService("ReplicatedStorage").Remotes.Server.Tool:InvokeServer("Activate", {ItemKey = "Bait-7", RelativeFactor = Vector3.new(0.5, 1.7, 0.1), ZoneIndex = 1, Position = _G.CustomBaitPos})
            end)
            task.wait(300)
        else task.wait(1) end
    end
end)

-- [2] AUTO CLAIM
CreateToggleButton("Auto Claim", "AutoClaim")
task.spawn(function()
    while true do task.wait(5)
        if _G.AutoClaim then pcall(function() game:GetService("ReplicatedStorage").Remotes.Server.claimPassiveIncome:FireServer() end) end
    end
end)

-- [3] AUTO SELL CAGES (Dynamic Inventory)
CreateToggleButton("Auto Sell (Cages)", "AutoSell")
task.spawn(function()
    while true do task.wait(3)
        if _G.AutoSell then
            pcall(function()
                local inv = LP.PlayerGui.Main.Centre.Inventory.ScrollingFrame
                local itemsToSell = {}
                for _, icon in pairs(inv:GetChildren()) do
                    if icon.Name:find("Loot-") then
                        -- Based on your image: checking the 'Locked' attribute/child
                        local locked = icon:GetAttribute("Locked") or (icon:FindFirstChild("Locked") and icon.Locked.Visible)
                        if not locked then
                            table.insert(itemsToSell, icon.Name)
                        end
                    end
                end
                if #itemsToSell > 0 then
                    game:GetService("ReplicatedStorage").Remotes.Server.FishShop:FireServer("SellAll", {itemsToSell})
                end
            end)
        end
    end
end)

-- [4] AUTO FISHING ROD
CreateToggleButton("Auto Fish (Rod)", "AutoRod")
task.spawn(function()
    while true do task.wait(1.5)
        if _G.AutoRod then pcall(function() game:GetService("ReplicatedStorage").Remotes.Server.FishFishingRod:InvokeServer() end) end
    end
end)

-- [5] AUTO SELL ROD FISH
CreateToggleButton("Auto Sell (Rod)", "AutoRodSell")
task.spawn(function()
    while true do task.wait(3)
        if _G.AutoRodSell then pcall(function() game:GetService("ReplicatedStorage").Remotes.Server.FisherMan:FireServer("SellFish") end) end
    end
end)

-- [6] AUTO BUY BAIT
CreateToggleButton("Auto Buy Bait", "AutoBuyBait")
task.spawn(function()
    while true do task.wait(5)
        if _G.AutoBuyBait then pcall(function() game:GetService("ReplicatedStorage").Remotes.Server.Bait:FireServer("Buy", 7) end) end
    end
end)

-- [7] AUTO BUY CAGE (WORKSPACE SCANNER)
CreateToggleButton("Auto Buy Cage", "AutoBuyCage")
task.spawn(function()
    while true do task.wait(1) -- Fast scan for new cages
        if _G.AutoBuyCage then 
            pcall(function() 
                local conveyorModels = workspace:WaitForChild("Conveyor"):WaitForChild("Models")
                for _, cage in pairs(conveyorModels:GetChildren()) do
                    -- Drilling down based on your screenshots: Cage -> Information -> CageTag -> Cage (TextLabel)
                    local info = cage:FindFirstChild("Information")
                    local tag = info and info:FindFirstChild("CageTag")
                    local nameLabel = tag and tag:FindFirstChild("Cage")
                    
                    if nameLabel and nameLabel.Text == _G.TargetCageName then
                        -- Buy the cage using its unique ID (the name of the model)
                        game:GetService("ReplicatedStorage").Remotes.Server.Conveyor:InvokeServer("Buy", {cage.Name})
                        task.wait(0.5) -- Small delay to prevent spamming the same cage
                    end
                end
            end)
        end
    end
end)

-- [8] TELEPORT TO EXHIBITION
CreateToggleButton("TP Exhibition", "Unused", function()
    local char = LP.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(-1097, 13, 450)
    end
end)

-- UI LOGIC (Keybind & Dragging)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightControl then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

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
