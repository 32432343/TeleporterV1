-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

local junkA = math.random(100000, 999999)
local junkB = "randomString" .. tostring(junkA)
local junkC = {junkA, junkB, 42, "junk"}
local function junkFunc1()
    local sum = 0
    for i = 1, 100 do
        sum = sum + i * junkA
        if sum > 999999999 then
            sum = sum - junkA * 10
        end
    end
    return sum
end
local function junkFunc2(x)
    if x > 0 then
        for i = 1, 10 do
            local _ = i * junkA + x
        end
        return true
    else
        return false
    end
end
local junkVar1 = junkFunc1()
local junkVar2 = junkFunc2(junkVar1)
for i = 1, 5 do
    local _ = i * 2 + junkVar1
end
local junkTable = {}
for i = 1, 20 do
    junkTable[i] = i * junkA
end
local function junkFunc3()
    return junkTable[math.random(1,20)] or 0
end
local junkValue = junkFunc3()
-- JUNK CODE END

local function getHRP()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

local rootPart

-- Get HumanoidRootPart
task.spawn(function()
    rootPart = getHRP()
end)

local function teleportThroughWalls(targetCFrame, steps, delay)
    steps = steps or 15
    delay = delay or 0.02
    if not rootPart then return end
    local startPos = rootPart.Position
    local endPos = targetCFrame.p
    for i = 1, steps do
        local alpha = i / steps
        local interpPos = startPos:Lerp(endPos, alpha)
        local rayOrigin = interpPos + Vector3.new(0, 2, 0)
        local rayDir = Vector3.new(0, -5, 0)
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {player.Character}
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        local raycastResult = Workspace:Raycast(rayOrigin, rayDir, raycastParams)
        if raycastResult then
            interpPos = Vector3.new(interpPos.X, raycastResult.Position.Y + 3, interpPos.Z)
        end
        rootPart.CFrame = CFrame.new(interpPos)
        task.wait(delay)
    end
end

-- GUI Setup
local CoreGui = game:GetService("CoreGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Teleporter"
screenGui.Parent = CoreGui
screenGui.ResetOnSpawn = false

local function createRoundedFrame(parent, size, pos, bgColor, radius)
    local frame = Instance.new("Frame")
    frame.Size = size
    frame.Position = pos
    frame.BackgroundColor3 = bgColor
    frame.BorderSizePixel = 0
    frame.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius
    corner.Parent = frame
    return frame
end

local mainFrame = createRoundedFrame(screenGui, UDim2.new(0, 600, 0, 460), UDim2.new(0, 20, 0, 20), Color3.fromRGB(25, 25, 35), UDim.new(0, 24))
mainFrame.Active = true
mainFrame.Draggable = true

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, -60, 0, 60)
title.Position = UDim2.new(0, 20, 0, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 36
title.TextColor3 = Color3.fromRGB(240, 240, 240)
title.Text = "Teleport to Player V6"
title.TextStrokeTransparency = 0.6
title.TextXAlignment = Enum.TextXAlignment.Left

local credits = Instance.new("TextLabel", mainFrame)
credits.Size = UDim2.new(1, -60, 0, 28)
credits.Position = UDim2.new(0, 20, 0, 60)
credits.BackgroundTransparency = 1
credits.Font = Enum.Font.Gotham
credits.TextSize = 18
credits.TextColor3 = Color3.fromRGB(180, 180, 180)
credits.Text = "by Sonar17"
credits.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -56, 0, 14)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 28
closeBtn.Text = "X"
closeBtn.AutoButtonColor = true
local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius = UDim.new(0, 8)
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

local searchBg = createRoundedFrame(mainFrame, UDim2.new(0, 440, 0, 50), UDim2.new(0, 20, 0, 100), Color3.fromRGB(65, 65, 95), UDim.new(0, 18))

local searchBox = Instance.new("TextBox", searchBg)
searchBox.Size = UDim2.new(1, -18, 1, -16)
searchBox.Position = UDim2.new(0, 9, 0, 8)
searchBox.BackgroundTransparency = 1
searchBox.PlaceholderText = "Search players..."
searchBox.Text = ""
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 26
searchBox.TextColor3 = Color3.fromRGB(240, 240, 240)
searchBox.ClearTextOnFocus = false

local listFrame = createRoundedFrame(mainFrame, UDim2.new(0, 440, 0, 220), UDim2.new(0, 20, 0, 160), Color3.fromRGB(50, 50, 75), UDim.new(0, 18))
listFrame.Visible = false
listFrame.ClipsDescendants = true

local scrollingFrame = Instance.new("ScrollingFrame", listFrame)
scrollingFrame.Size = UDim2.new(1, 0, 1, 0)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.BorderSizePixel = 0
scrollingFrame.ScrollBarThickness = 10
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

local uiListLayout = Instance.new("UIListLayout", scrollingFrame)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Padding = UDim.new(0, 10)

local selectedPlayer = nil

local dropdownBtn = Instance.new("TextButton", mainFrame)
dropdownBtn.Size = UDim2.new(0, 440, 0, 58)
dropdownBtn.Position = UDim2.new(0.5, -220, 1, -135)
dropdownBtn.BackgroundColor3 = Color3.fromRGB(90, 160, 255)
dropdownBtn.Font = Enum.Font.GothamBold
dropdownBtn.TextSize = 28
dropdownBtn.TextColor3 = Color3.new(1, 1, 1)
dropdownBtn.Text = "Select Player"
dropdownBtn.AutoButtonColor = true
local dropdownCorner = Instance.new("UICorner", dropdownBtn)
dropdownCorner.CornerRadius = UDim.new(0, 20)

local tpButton = Instance.new("TextButton", mainFrame)
tpButton.Size = UDim2.new(0, 440, 0, 64)
tpButton.Position = UDim2.new(0.5, -220, 1, -60)
tpButton.BackgroundColor3 = Color3.fromRGB(65, 220, 150)
tpButton.Font = Enum.Font.GothamBold
tpButton.TextSize = 28
tpButton.TextColor3 = Color3.new(1, 1, 1)
tpButton.Text = "Teleport"
tpButton.AutoButtonColor = true
local tpCorner = Instance.new("UICorner", tpButton)
tpCorner.CornerRadius = UDim.new(0, 20)

local function updateDropdownText(name)
    dropdownBtn.Text = name or "Select Player"
end

local function createPlayerButtons(playerList)
    scrollingFrame:ClearAllChildren()
    selectedPlayer = nil
    updateDropdownText(nil)

    for _, p in ipairs(playerList) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -18, 0, 48)
        btn.BackgroundColor3 = Color3.fromRGB(80, 80, 110)
        btn.TextColor3 = Color3.fromRGB(245, 245, 245)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 26
        btn.Text = p.Name
        btn.AutoButtonColor = true
        btn.Parent = scrollingFrame

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 14)
        corner.Parent = btn

        btn.MouseButton1Click:Connect(function()
            selectedPlayer = p
            updateDropdownText(p.Name)
            listFrame.Visible = false
        end)
    end
    task.wait()
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y + 12)
end

local function getFilteredPlayers()
    local searchTerm = searchBox.Text:lower()
    local allPlayers = Players:GetPlayers()
    local filtered = {}

    for _, p in ipairs(allPlayers) do
        if p ~= player then
            if searchTerm == "" or p.Name:lower():find(searchTerm) then
                table.insert(filtered, p)
            end
        end
    end

    return filtered
end

dropdownBtn.MouseButton1Click:Connect(function()
    if listFrame.Visible then
        listFrame.Visible = false
    else
        createPlayerButtons(getFilteredPlayers())
        listFrame.Visible = true
    end
end)

local debounceSearch = false
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    if debounceSearch then return end
    debounceSearch = true
    task.delay(0.15, function()
        if listFrame.Visible then
            createPlayerButtons(getFilteredPlayers())
        end
        debounceSearch = false
    end)
end)

tpButton.MouseButton1Click:Connect(function()
    if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") and rootPart then
        local targetCFrame = selectedPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
        task.spawn(function()
            teleportThroughWalls(targetCFrame, 25, 0.015)
        end)
    else
        tpButton.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
        task.delay(0.4, function()
            tpButton.BackgroundColor3 = Color3.fromRGB(65, 220, 150)
        end)
    end
end)

task.spawn(function()
    while true do
        task.wait(5)
        if listFrame.Visible then
            createPlayerButtons(getFilteredPlayers())
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = UserInputService:GetMouseLocation()
        local absPos = Vector2.new(mainFrame.AbsolutePosition.X, mainFrame.AbsolutePosition.Y)
        local absSize = Vector2.new(mainFrame.AbsoluteSize.X, mainFrame.AbsoluteSize.Y)
        local inBounds = mousePos.X >= absPos.X and mousePos.X <= absPos.X + absSize.X
            and mousePos.Y >= absPos.Y and mousePos.Y <= absPos.Y + absSize.Y
        if not inBounds then
            listFrame.Visible = false
        end
    end
end)
