-- [[ CAGE-STYLE: UNLOCKER & TP EDITION ]]

local LP = game:GetService("Players").LocalPlayer
local UIS = game:GetService("UserInputService")

-- Configuration
_G.TargetFish = {"Abyssal", "Serpent", "Leviathan", "Secret"} 
_G.AutoUnlock = false -- New Toggle
_G.AutoSubmit = false
_G.AutoBait = false
_G.CustomBaitPos = Vector3.new(-938.8, 1.7, 814.0)

-- Clean up old UI
if game:GetService("CoreGui"):FindFirstChild("CageStyleFinal") then
    game:GetService("CoreGui"):FindFirstChild("CageStyleFinal"):Destroy()
end

-- UI Creation
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "CageStyleFinal"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 300, 0, 350)
Main.Position = UDim2.new(0.5, -150, 0.5, -175)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Instance.new("UICorner", Main)

local Scrolling = Instance.new("ScrollingFrame", Main)
Scrolling.Size = UDim2.new(1, -20, 1, -20)
Scrolling.Position = UDim2.new(0, 10, 0, 10)
Scrolling.BackgroundTransparency = 1
Scrolling.CanvasSize = UDim2.new(0, 0, 1.5, 0)
local List = Instance.new("UIListLayout", Scrolling)
List.Padding = UDim.new(0, 5)

-- Button Helper
local function CreateBtn(txt, callback)
    local b = Instance.new("TextButton", Scrolling)
    b.Size = UDim2.new(1, 0, 0, 35)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    b.Text = txt
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 14
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(callback)
    return b
end

-- UI Buttons
local unlockBtn = CreateBtn("Auto Unlock: OFF", function()
    _G.AutoUnlock = not _G.AutoUnlock
    script.Parent.Text = "Auto Unlock: " .. (_G.AutoUnlock and "ON" or "OFF")
end)
unlockBtn.Name = "UnlockToggle"

CreateBtn("Auto Submit", function() _G.AutoSubmit = not _G.AutoSubmit end)

CreateBtn("Set Bait Loc", function(b)
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        _G.CustomBaitPos = LP.Character.HumanoidRootPart.Position
        b.Text = "LOCATION SET!"
        task.wait(1)
        b.Text = "Set Bait Loc"
    end
end)

CreateBtn("Teleport to Bait", function()
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character.HumanoidRootPart.CFrame = CFrame.new(_G.CustomBaitPos + Vector3.new(0, 3, 0))
    end
end)

-- [[ LOGIC LOOPS ]]

-- Auto Unlock Loop
task.spawn(function()
    while true do task.wait(2)
        if _G.AutoUnlock then
            pcall(function()
                local inv = LP.PlayerGui.Main.Centre.Inventory.ScrollingFrame
                for _, icon in pairs(inv:GetChildren()) do
                    if icon.Name:find("Loot-") then
                        -- Check if it IS locked (Label is Visible)
                        local lockLabel = icon:FindFirstChild("Locked")
                        if lockLabel and lockLabel.Visible == true then
                            
                            local nameLabel = icon:FindFirstChild("ItemName")
                            local fishName = nameLabel and nameLabel.Text or ""
                            
                            for _, target in pairs(_G.TargetFish) do
                                if fishName:lower():find(target:lower()) then
                                    -- Fire Remote to toggle OFF
                                    game:GetService("ReplicatedStorage").Remotes.Server.Inventory:FireServer("Lock", {icon.Name})
                                    print("[Cage-Unlock] Unlocking Secret: " .. fishName)
                                    
                                    -- Visual Update Hack: Toggle visibility to force refresh
                                    icon.Visible = false
                                    task.wait(0.05)
                                    icon.Visible = true
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Auto Submit Loop
task.spawn(function()
    while true do task.wait(1)
        if _G.AutoSubmit then
            pcall(function() game:GetService("ReplicatedStorage").Remotes.Server.GlobalCompetition:InvokeServer("SubmitAll") end)
        end
    end
end)

-- Dragging logic for UI
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
