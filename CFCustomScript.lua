-- [[ CAGE-STYLE ULTIMATE EXTENSION ]]

-- Cleanup old versions
if game:GetService("CoreGui"):FindFirstChild("CageStyleExtension") then
    game:GetService("CoreGui"):FindFirstChild("CageStyleExtension"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Sidebar = Instance.new("Frame")
local ContentFrame = Instance.new("Frame")
local SettingsFrame = Instance.new("Frame")
local UserInputService = game:GetService("UserInputService")
local LP = game:GetService("Players").LocalPlayer

-- Configuration & Globals
_G.TargetFish = {"Abyssal", "Giant Trevally", "Whale"} 
_G.AutoLock = false
_G.AutoSubmit = false
_G.AutoBait = false
_G.AutoClaim = false
_G.CustomBaitPos = Vector3.new(-938.8, 1.7, 814.0)

-- Container Setup
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "CageStyleExtension"
ScreenGui.ResetOnSpawn = false

-- Main Body
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -150)
MainFrame.Size = UDim2.new(0, 320, 0, 320)
MainFrame.Active = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Sidebar Navigation
Sidebar.Name = "Sidebar"
Sidebar.Parent = MainFrame
Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Sidebar.Size = UDim2.new(0, 100, 1, 0)
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

local function CreateNav(name, pos, frame)
    local btn = Instance.new("TextButton")
    btn.Parent = Sidebar
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Position = UDim2.new(0, 0, 0, pos)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.MouseButton1Click:Connect(function()
        ContentFrame.Visible = (frame == ContentFrame)
        SettingsFrame.Visible = (frame == SettingsFrame)
    end)
end

-- Panels
ContentFrame.Parent = MainFrame
ContentFrame.Position = UDim2.new(0, 110, 0, 10)
ContentFrame.Size = UDim2.new(0, 200, 1, -20)
ContentFrame.BackgroundTransparency = 1

SettingsFrame.Parent = MainFrame
SettingsFrame.Position = UDim2.new(0, 110, 0, 10)
SettingsFrame.Size = UDim2.new(0, 200, 1, -20)
SettingsFrame.BackgroundTransparency = 1
SettingsFrame.Visible = false

CreateNav("MAIN", 10, ContentFrame)
CreateNav("SETTINGS", 50, SettingsFrame)

local list1 = Instance.new("UIListLayout", ContentFrame)
list1.Padding = UDim.new(0, 8)

-- Settings: Fish Input Box
local FishInput = Instance.new("TextBox")
FishInput.Parent = SettingsFrame
FishInput.Size = UDim2.new(1, 0, 0, 80)
FishInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
FishInput.Text = "Abyssal, Giant Trevally, Whale"
FishInput.PlaceholderText = "Enter Fish Names (Comma separated)"
FishInput.TextColor3 = Color3.fromRGB(255, 255, 255)
FishInput.TextWrapped = true
FishInput.Font = Enum.Font.Gotham
Instance.new("UICorner", FishInput)

FishInput.FocusLost:Connect(function()
    local list = {}
    for s in string.gmatch(FishInput.Text, "([^,]+)") do
        table.insert(list, s:match("^%s*(.-)%s*$"))
    end
    _G.TargetFish = list
end)

-- UI Toggle Template
local function CreateToggle(name, globalVar, parent, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        if globalVar ~= "Unused" then
            _G[globalVar] = not _G[globalVar]
            btn.BackgroundColor3 = _G[globalVar] and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(35, 35, 35)
        end
        if callback then callback(btn) end
    end)
end

-- Build Main Tab
CreateToggle("Auto Submit", "AutoSubmit", ContentFrame)
CreateToggle("Auto Bait", "AutoBait", ContentFrame)
CreateToggle("Auto Claim", "AutoClaim", ContentFrame)
CreateToggle("Auto Lock", "AutoLock", ContentFrame)

CreateToggle("Set Bait Loc", "Unused", ContentFrame, function(btn)
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        _G.CustomBaitPos = LP.Character.HumanoidRootPart.Position
        btn.Text = "SAVED!"
        task.wait(1)
        btn.Text = "Set Bait Loc"
    end
end)

CreateToggle("TP Exhibition", "Unused", ContentFrame, function()
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character.HumanoidRootPart.CFrame = CFrame.new(-1097, 13, 450)
    end
end)

-- [[ LOGIC LOOPS ]]

-- Loop 1: Auto Lock
task.spawn(function()
    while true do task.wait(3)
        if _G.AutoLock then
            pcall(function()
                local loot = game.Workspace.Debris.Players:FindFirstChild(LP.Name):FindFirstChild("Loot")
                if loot then
                    for _, item in pairs(loot:GetChildren()) do
                        for _, target in pairs(_G.TargetFish) do
                            if string.find(item.Name:lower(), target:lower()) and not item:GetAttribute("Locked") then
                                game:GetService("ReplicatedStorage").Remotes.Server.Inventory:FireServer("Lock", {[1] = item.Name})
                                print("[Cage-Lock] Locking: " .. item.Name)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Loop 2: Submit & Claim
task.spawn(function()
    while true do task.wait(1)
        if _G.AutoSubmit then 
            pcall(function() game:GetService("ReplicatedStorage").Remotes.Server.GlobalCompetition:InvokeServer("SubmitAll") end) 
        end
        if _G.AutoClaim then 
            pcall(function() game:GetService("ReplicatedStorage").Remotes.Server.claimPassiveIncome:FireServer() end) 
        end
    end
end)

-- Loop 3: Auto Bait
task.spawn(function()
    while true do
        if _G.AutoBait then
            pcall(function()
                game:GetService("ReplicatedStorage").Remotes.Server.Tool:InvokeServer("Activate", {
                    ItemKey = "Bait-7", 
                    RelativeFactor = Vector3.new(0.5, 1.7, 0.1), 
                    ZoneIndex = 1, 
                    Position = _G.CustomBaitPos
                })
            end)
            task.wait(300)
        else task.wait(1) end
    end
end)

-- Dragging & Toggle Logic
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

UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.RightControl then MainFrame.Visible = not MainFrame.Visible end
end)
