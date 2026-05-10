-- [[ CAGE-STYLE: CLEAN BASE + AUTO SELL ]]

-- Clean up old menu if it exists
if game:GetService("CoreGui"):FindFirstChild("CageStyleExtension") then
    game:GetService("CoreGui"):FindFirstChild("CageStyleExtension"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Sidebar = Instance.new("Frame")
local ContentFrame = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local UIListLayout = Instance.new("UIListLayout")
local UserInputService = game:GetService("UserInputService")
local LP = game.Players.LocalPlayer

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
MainFrame.Size = UDim2.new(0, 320, 0, 320) -- Slightly taller for the new button
MainFrame.Active = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Sidebar
Sidebar.Name = "Sidebar"
Sidebar.Parent = MainFrame
Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Sidebar.Size = UDim2.new(0, 100, 1, 0)
Sidebar.BorderSizePixel = 0

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 10)
SidebarCorner.Parent = Sidebar

TitleLabel.Parent = Sidebar
TitleLabel.Size = UDim2.new(1, 0, 0, 40)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "CUSTOM"
TitleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold

-- Content Area
ContentFrame.Name = "Content"
ContentFrame.Parent = MainFrame
ContentFrame.Position = UDim2.new(0, 110, 0, 10)
ContentFrame.Size = UDim2.new(0, 200, 1, -20)
ContentFrame.BackgroundTransparency = 1

UIListLayout.Parent = ContentFrame
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Button Template
local function CreateToggleButton(name, globalVar, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35) -- Adjusted size to fit more buttons nicely
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

-- [1] AUTO SUBMIT
_G.AutoSubmit = false
CreateToggleButton("Auto Submit", "AutoSubmit")
task.spawn(function()
    while true do task.wait(1)
        if _G.AutoSubmit then pcall(function() game:GetService("ReplicatedStorage").Remotes.Server.GlobalCompetition:InvokeServer("SubmitAll") end) end
    end
end)

-- [2] AUTO BAIT & [3] SET LOC
_G.AutoBait = false
_G.CustomBaitPos = Vector3.new(-938.8, 1.7, 814.0)

CreateToggleButton("Auto Bait", "AutoBait")

CreateToggleButton("Set Bait Loc", "Unused", function(btn)
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        _G.CustomBaitPos = LP.Character.HumanoidRootPart.Position
        
        -- Visual Confirmation
        local oldText = btn.Text
        btn.Text = "SAVED!"
        btn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        task.wait(1)
        btn.Text = oldText
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
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

-- [4] AUTO CLAIM
_G.AutoClaim = false
CreateToggleButton("Auto Claim", "AutoClaim")
task.spawn(function()
    while true do task.wait(5)
        if _G.AutoClaim then pcall(function() game:GetService("ReplicatedStorage").Remotes.Server.claimPassiveIncome:FireServer() end) end
    end
end)

-- [5] AUTO SELL (Dynamic Inventory Scanner)
_G.AutoSell = false
CreateToggleButton("Auto Sell", "AutoSell")
task.spawn(function()
    while true do task.wait(3) -- Scans every 3 seconds
        if _G.AutoSell then
            pcall(function()
                local inv = LP.PlayerGui.Main.Centre.Inventory.ScrollingFrame
                local itemsToSell = {}
                
                -- Dynamically grab all current items in your inventory
                for _, icon in pairs(inv:GetChildren()) do
                    if icon.Name:find("Loot-") then
                        -- Safety check: DO NOT sell if it is locked
                        local isLockedAttr = icon:GetAttribute("Locked")
                        local lockLabel = icon:FindFirstChild("Locked")
                        
                        if not (isLockedAttr == true or (lockLabel and lockLabel.Visible == true)) then
                            table.insert(itemsToSell, icon.Name)
                        end
                    end
                end
                
                -- Only fire the remote if we actually have items to sell
                if #itemsToSell > 0 then
                    game:GetService("ReplicatedStorage").Remotes.Server.FishShop:FireServer("SellAll", {itemsToSell})
                end
            end)
        end
    end
end)

-- [6] TELEPORT TO EXHIBITION (Manual Coords)
CreateToggleButton("TP Exhibition", "Unused", function()
    local char = LP.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(-1097, 13, 450)
    end
end)

-- HIDE / SHOW KEYBIND (Right Control)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightControl then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Dragging Logic
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
