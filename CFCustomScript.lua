-- [[ CAGE-STYLE: ATTRIBUTE & VISIBILITY SYNC EDITION ]]

local LP = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")

-- Configuration
_G.TargetFish = {"Secret", "Abyssal", "Serpent", "Leviathan"}
_G.AutoUnlock = false
_G.AutoSubmit = false
_G.AutoBait = false
_G.AutoClaim = false
_G.CustomBaitPos = Vector3.new(-938.8, 1.7, 814.0)

-- Clean up old menu if it exists
if game:GetService("CoreGui"):FindFirstChild("CageStyleExtension") then
    game:GetService("CoreGui"):FindFirstChild("CageStyleExtension"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "CageStyleExtension"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -150)
MainFrame.Size = UDim2.new(0, 320, 0, 320)
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Name = "Sidebar"
Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Sidebar.Size = UDim2.new(0, 100, 1, 0)
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

local TitleLabel = Instance.new("TextLabel", Sidebar)
TitleLabel.Size = UDim2.new(1, 0, 0, 40)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "CUSTOM"
TitleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold

local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Name = "Content"
ContentFrame.Position = UDim2.new(0, 110, 0, 10)
ContentFrame.Size = UDim2.new(0, 200, 1, -20)
ContentFrame.BackgroundTransparency = 1

local UIListLayout = Instance.new("UIListLayout", ContentFrame)
UIListLayout.Padding = UDim.new(0, 8)

local function CreateToggleButton(name, globalVar, callback)
    local btn = Instance.new("TextButton", ContentFrame)
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
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
CreateToggleButton("Auto Submit", "AutoSubmit")
task.spawn(function()
    while true do task.wait(1)
        if _G.AutoSubmit then pcall(function() game:GetService("ReplicatedStorage").Remotes.Server.GlobalCompetition:InvokeServer("SubmitAll") end) end
    end
end)

-- [2] AUTO BAIT & [3] SET LOC
CreateToggleButton("Auto Bait", "AutoBait")
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

-- [4] AUTO UNLOCK (FIXED FOR ATTRIBUTES)
CreateToggleButton("Auto Unlock", "AutoUnlock")
task.spawn(function()
    while true do task.wait(1.5)
        if _G.AutoUnlock then
            pcall(function()
                local inv = LP.PlayerGui.Main.Centre.Inventory.ScrollingFrame
                for _, icon in pairs(inv:GetChildren()) do
                    if icon.Name:find("Loot-") then
                        -- Check BOTH Attribute and Label Visibility
                        local isLockedAttr = icon:GetAttribute("Locked")
                        local lockLabel = icon:FindFirstChild("Locked")
                        
                        -- If either the label is visible OR the attribute is true, we unlock it
                        if isLockedAttr == true or (lockLabel and lockLabel.Visible == true) then
                            local nameLabel = icon:FindFirstChild("ItemName")
                            local fullName = nameLabel and nameLabel.Text or ""
                            
                            for _, target in pairs(_G.TargetFish) do
                                if fullName:lower():find(target:lower()) then
                                    -- 1. Fire Remote to the Server
                                    game:GetService("ReplicatedStorage").Remotes.Server.Inventory:FireServer("Lock", {icon.Name})
                                    
                                    -- 2. FORCE Attribute Change Locally
                                    icon:SetAttribute("Locked", false)
                                    
                                    -- 3. FORCE Label Update Locally
                                    if lockLabel then lockLabel.Visible = false end
                                    
                                    -- 4. UI Nudge to refresh the icon state
                                    icon.LayoutOrder = icon.LayoutOrder + 1
                                    icon.LayoutOrder = icon.LayoutOrder - 1
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- [5] TP EXHIBITION
CreateToggleButton("TP Exhibition", "Unused", function()
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character.HumanoidRootPart.CFrame = CFrame.new(-1097, 13, 450)
    end
end)

-- Dragging & Hide Logic
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = MainFrame.Position end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UIS.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.RightControl then MainFrame.Visible = not MainFrame.Visible end
end)
