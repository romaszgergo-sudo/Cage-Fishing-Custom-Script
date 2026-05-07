-- [[ CAGE-STYLE: RESTORED & UNIFIED EDITION ]]

local LP = game:GetService("Players").LocalPlayer
local UIS = game:GetService("UserInputService")

-- Configuration
_G.TargetFish = {"Abyssal", "Serpent", "Leviathan", "Secret", "Whale"} 
_G.AutoUnlock = false
_G.AutoSubmit = false
_G.CustomBaitPos = Vector3.new(-938.8, 1.7, 814.0)

-- UI Cleanup
if game:GetService("CoreGui"):FindFirstChild("CageStyleUnified") then
    game:GetService("CoreGui"):FindFirstChild("CageStyleUnified"):Destroy()
end

-- Main UI Setup
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "CageStyleUnified"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 250, 0, 350)
Main.Position = UDim2.new(0.5, -125, 0.5, -175)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -20, 1, -20)
Scroll.Position = UDim2.new(0, 10, 0, 10)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 4
Scroll.CanvasSize = UDim2.new(0, 0, 1.3, 0) -- Extra space for buttons

local List = Instance.new("UIListLayout", Scroll)
List.Padding = UDim.new(0, 8)

-- Function to create buttons that match your new look
local function CreateBtn(name, globalVar, callback)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        if globalVar then
            _G[globalVar] = not _G[globalVar]
            btn.Text = name .. ": " .. (_G[globalVar] and "ON" or "OFF")
            btn.BackgroundColor3 = _G[globalVar] and Color3.fromRGB(55, 55, 55) or Color3.fromRGB(35, 35, 35)
        end
        if callback then callback(btn) end
    end)
    return btn
end

-- Building the Menu
CreateBtn("Auto Submit", "AutoSubmit")

CreateBtn("Set Bait Loc", nil, function(b)
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        _G.CustomBaitPos = LP.Character.HumanoidRootPart.Position
        b.Text = "LOC SAVED!"
        task.wait(1)
        b.Text = "Set Bait Loc"
    end
end)

CreateBtn("Teleport to Bait", nil, function()
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character.HumanoidRootPart.CFrame = CFrame.new(_G.CustomBaitPos + Vector3.new(0, 3, 0))
    end
end)

CreateBtn("Auto Unlock", "AutoUnlock")

-- Logic Loops

-- Improved Auto Unlock Loop
task.spawn(function()
    while true do task.wait(1.5)
        if _G.AutoUnlock then
            pcall(function()
                local inv = LP.PlayerGui.Main.Centre.Inventory.ScrollingFrame -- Correct path
                
                for _, icon in pairs(inv:GetChildren()) do
                    if icon.Name:find("Loot-") then
                        -- Target items that ARE currently locked
                        local lockLabel = icon:FindFirstChild("Locked")
                        if lockLabel and lockLabel.Visible == true then
                            
                            local nameLabel = icon:FindFirstChild("ItemName")
                            local fullName = nameLabel and nameLabel.Text or ""
                            
                            for _, target in pairs(_G.TargetFish) do
                                if fullName:lower():find(target:lower()) then
                                    -- Fire Remote to unlock
                                    game:GetService("ReplicatedStorage").Remotes.Server.Inventory:FireServer("Lock", {icon.Name})
                                    
                                    -- FORCE REFRESH: This fixes the "must move to hotbar" bug
                                    lockLabel.Visible = false 
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

-- Auto Submit
task.spawn(function()
    while true do task.wait(1)
        if _G.AutoSubmit then
            pcall(function() game:GetService("ReplicatedStorage").Remotes.Server.GlobalCompetition:InvokeServer("SubmitAll") end)
        end
    end
end)

-- UI Draggable Logic
local dragging, dragInput, dragStart, startPos
Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = Main.Position end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
Main.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
