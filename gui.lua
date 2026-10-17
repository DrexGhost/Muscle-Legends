local NexusX = _G.NexusX
local UIS = NexusX.UIS
local RunService = NexusX.RunService
local TweenService = NexusX.TweenService
local Colors = NexusX.Colors
local Settings = NexusX.Settings
local player = NexusX.Player
local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("Muscle Legends2")
if oldGui then oldGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "Muscle Legends2"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 600, 0, 300)
main.Position = UDim2.new(Settings.menuPos[1], Settings.menuPos[2], Settings.menuPos[3], Settings.menuPos[4])
main.BackgroundColor3 = Colors.bg
main.BorderSizePixel = 0
main.Visible = Settings.menuOpen
main.ClipsDescendants = true
main.Active = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

local topBar = Instance.new("Frame", main)
topBar.Size = UDim2.new(1, 0, 0, 35)
topBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
topBar.BorderSizePixel = 0
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 8)

local titleLabel = Instance.new("TextLabel", topBar)
titleLabel.Size = UDim2.new(0, 200, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Muscle Legends"
titleLabel.TextColor3 = Colors.text
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", topBar)
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -30, 0.5, -12)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
closeBtn.AutoButtonColor = false
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

local sideBar = Instance.new("Frame", main)
sideBar.Size = UDim2.new(0, 110, 1, -35)
sideBar.Position = UDim2.new(0, 0, 0, 35)
sideBar.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
sideBar.BorderSizePixel = 0
Instance.new("UICorner", sideBar).CornerRadius = UDim.new(0, 8)

local contentFrame = Instance.new("Frame", main)
contentFrame.Size = UDim2.new(1, -110, 1, -35)
contentFrame.Position = UDim2.new(0, 110, 0, 35)
contentFrame.BackgroundColor3 = Colors.accent
contentFrame.BorderSizePixel = 0
contentFrame.Active = true
Instance.new("UICorner", contentFrame).CornerRadius = UDim.new(0, 8)

local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0, Settings.openBtnSize, 0, Settings.openBtnSize)
openBtn.Position = UDim2.new(Settings.openBtnPos[1], Settings.openBtnPos[2], Settings.openBtnPos[3], Settings.openBtnPos[4])
openBtn.BackgroundColor3 = Colors.bg
openBtn.BorderSizePixel = 0
openBtn.Text = "Δ"
openBtn.TextColor3 = Colors.text
openBtn.TextSize = math.floor(Settings.openBtnSize * 0.58)
openBtn.Font = Enum.Font.GothamBold
openBtn.Visible = not Settings.menuOpen
openBtn.ZIndex = 10
openBtn.Active = true
openBtn.AutoButtonColor = false
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0, 8)

local fpsOverlay = Instance.new("TextLabel", gui)
fpsOverlay.Size = UDim2.new(0, 80, 0, 25)
fpsOverlay.Position = UDim2.new(Settings.fpsPos[1], Settings.fpsPos[2], Settings.fpsPos[3], Settings.fpsPos[4])
fpsOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
fpsOverlay.BackgroundTransparency = 0.5
fpsOverlay.BorderSizePixel = 0
fpsOverlay.Text = "FPS: 0"
fpsOverlay.TextColor3 = Color3.fromRGB(255, 255, 255)
fpsOverlay.TextSize = 14
fpsOverlay.Font = Enum.Font.GothamBold
fpsOverlay.TextXAlignment = Enum.TextXAlignment.Center
fpsOverlay.Visible = Settings.fps
fpsOverlay.ZIndex = 10
fpsOverlay.Active = true
Instance.new("UICorner", fpsOverlay).CornerRadius = UDim.new(0, 6)

NexusX.Gui = {
    Main = main, SideBar = sideBar, ContentFrame = contentFrame,
    OpenBtn = openBtn, FPSOverlay = fpsOverlay,
    Contents = {}, TabButtons = {}
}
NexusX.UI.Toggles = {}
NexusX.UI.Sliders = {}
NexusX.UI.SubToggles = {}

function NexusX.UI.makeDraggable(frame, dragArea, saveKey, onDragEnd)
    local dragging, dragInput, dragStart, startPos, moved = false, nil, nil, nil, false
    local area = dragArea or frame
    area.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging, dragInput, dragStart, startPos, moved = true, input, input.Position, frame.Position, false
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging, dragInput = false, nil
                    if saveKey and moved then
                        NexusX.saveSetting(saveKey, {frame.Position.X.Scale, frame.Position.X.Offset, frame.Position.Y.Scale, frame.Position.Y.Offset})
                    end
                    if onDragEnd then onDragEnd(moved) end
                end
            end)
        end
    end)
    area.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then dragInput = input end
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if not dragging or input ~= dragInput then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local delta = input.Position - dragStart
        if math.abs(delta.X) > 3 or math.abs(delta.Y) > 3 then moved = true end
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end)
end

function NexusX.UI.addButtonStroke(button, color, thickness)
    local stroke = Instance.new("UIStroke", button)
    stroke.Color = color or Color3.fromRGB(80, 80, 80)
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.LineJoinMode = Enum.LineJoinMode.Round
end

function NexusX.UI.createToggle(parent, text, posY, defaultState, callback, settingName, skipInitial)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -20, 0, 30)
    frame.Position = UDim2.new(0, 10, 0, posY)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Colors.text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left

    local toggle = Instance.new("TextButton", frame)
    toggle.Size = UDim2.new(0, 40, 0, 20)
    toggle.Position = UDim2.new(1, -40, 0.5, -10)
    toggle.BackgroundColor3 = defaultState and Colors.toggleOn or Colors.toggleOff
    toggle.BorderSizePixel = 0
    toggle.Text = ""
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)

    local dot = Instance.new("Frame", toggle)
    dot.Size = UDim2.new(0, 16, 0, 16)
    dot.Position = defaultState and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    dot.BackgroundColor3 = Colors.text
    dot.BorderSizePixel = 0
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    if settingName then NexusX.UI.Toggles[settingName] = {toggle = toggle, dot = dot} end
    local enabled = defaultState or false
    if defaultState and callback and not skipInitial then callback(true) end

    local function switch()
        enabled = not enabled
        if enabled then
            toggle.BackgroundColor3 = Colors.toggleOn
            TweenService:Create(dot, TweenInfo.new(0.15), {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
        else
            toggle.BackgroundColor3 = Colors.toggleOff
            TweenService:Create(dot, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
        end
        if settingName then NexusX.saveSetting(settingName, enabled) end
        if callback then callback(enabled) end
    end

    toggle.Activated:Connect(switch)
    return frame
end

function NexusX.UI.createSlider(parent, text, posY, min, max, default, callback, settingName)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -20, 0, 50)
    frame.Position = UDim2.new(0, 10, 0, posY)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. default
    label.TextColor3 = Colors.text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left

    local sliderBg = Instance.new("Frame", frame)
    sliderBg.Size = UDim2.new(1, 0, 0, 8)
    sliderBg.Position = UDim2.new(0, 0, 0, 28)
    sliderBg.BackgroundColor3 = Colors.button
    sliderBg.BorderSizePixel = 0
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", sliderBg)
    local percent = (default - min) / (max - min)
    fill.Size = UDim2.new(percent, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local dragBtn = Instance.new("TextButton", sliderBg)
    dragBtn.Size = UDim2.new(0, 18, 0, 18)
    dragBtn.Position = UDim2.new(percent, -9, 0.5, -9)
    dragBtn.BackgroundColor3 = Colors.text
    dragBtn.BorderSizePixel = 0
    dragBtn.Text = ""
    dragBtn.AutoButtonColor = false
    Instance.new("UICorner", dragBtn).CornerRadius = UDim.new(1, 0)

    if settingName then NexusX.UI.Sliders[settingName] = {label = label, fill = fill, dragBtn = dragBtn, min = min, max = max, text = text} end

    local function updateSlider()
        local mousePos = UIS:GetMouseLocation()
        local guiPos = sliderBg.AbsolutePosition
        local guiSize = sliderBg.AbsoluteSize
        local relativeX = math.clamp((mousePos.X - guiPos.X) / guiSize.X, 0, 1)
        local value = math.floor(min + (max - min) * relativeX + 0.5)
        label.Text = text .. ": " .. value
        TweenService:Create(fill, TweenInfo.new(0.1), {Size = UDim2.new(relativeX, 0, 1, 0)}):Play()
        TweenService:Create(dragBtn, TweenInfo.new(0.1), {Position = UDim2.new(relativeX, -9, 0.5, -9)}):Play()
        if settingName then NexusX.saveSetting(settingName, value) end
        if callback then callback(value) end
    end

    local function onStart()
        updateSlider()
        local conn
        conn = RunService.RenderStepped:Connect(function()
            if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then conn:Disconnect(); return end
            updateSlider()
        end)
    end

    dragBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then onStart() end
    end)
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then onStart() end
    end)
end

function NexusX.UI.addText(parent, text, color, size, yPos)
    local label = Instance.new("TextLabel", parent)
    label.Size = UDim2.new(1, -20, 0, 25)
    label.Position = UDim2.new(0, 10, 0, yPos or 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color or Color3.fromRGB(220, 220, 220)
    label.TextSize = size or 16
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    return label
end

local tabNames = {"MAIN", "AUTO", "TELEPORT", "MOVEMENT", "KILL", "EVENT", "ULTIMATE", "OTHER"}
for i, name in ipairs(tabNames) do
    local tabBtn = Instance.new("TextButton", sideBar)
    tabBtn.Size = UDim2.new(1, -10, 0, 26)
    tabBtn.Position = UDim2.new(0, 5, 0, 8 + (i - 1) * 31)
    tabBtn.BackgroundColor3 = Colors.button
    tabBtn.BorderSizePixel = 0
    tabBtn.Text = name
    tabBtn.TextColor3 = Colors.text
    tabBtn.TextSize = 12
    tabBtn.Font = Enum.Font.GothamSemibold
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)
    NexusX.UI.addButtonStroke(tabBtn, Color3.fromRGB(80, 80, 80), 1)

    local content = Instance.new("ScrollingFrame", contentFrame)
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 4
    content.ScrollBarImageColor3 = Color3.fromRGB(40, 40, 40)
    content.CanvasSize = UDim2.new(0, 0, 0, 700)
    content.Visible = false
    content.BorderSizePixel = 0
    content.ScrollingEnabled = true
    content.Active = true

    NexusX.Gui.TabButtons[name] = tabBtn
    NexusX.Gui.Contents[name] = content

    tabBtn.MouseEnter:Connect(function() TweenService:Create(tabBtn, TweenInfo.new(0.15), {BackgroundColor3 = Colors.buttonHover}):Play() end)
    tabBtn.MouseLeave:Connect(function()
        if not content.Visible then TweenService:Create(tabBtn, TweenInfo.new(0.15), {BackgroundColor3 = Colors.button}):Play() end
    end)

    tabBtn.Activated:Connect(function()
        for _, c in pairs(NexusX.Gui.Contents) do c.Visible = false end
        for _, b in pairs(NexusX.Gui.TabButtons) do TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Colors.button}):Play() end
        content.Visible = true
        TweenService:Create(tabBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
    end)
end

NexusX.Gui.TabButtons["MAIN"].BackgroundColor3 = Color3.fromRGB(45, 45, 45)
NexusX.Gui.Contents["MAIN"].Visible = true

NexusX.UI.makeDraggable(openBtn, nil, "openBtnPos", function(moved)
    if not moved then NexusX.toggleMenu() end
end)
NexusX.UI.makeDraggable(fpsOverlay, nil, "fpsPos")

function NexusX.toggleMenu()
    Settings.menuOpen = not Settings.menuOpen
    if Settings.menuOpen then
        main.Visible = true
        main.Size = UDim2.new(0, 0, 0, 300)
        TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 600, 0, 300)}):Play()
        openBtn.Visible = false
    else
        local tween = TweenService:Create(main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 300)})
        tween:Play()
        tween.Completed:Connect(function() main.Visible = false end)
        openBtn.Visible = true
    end
end

closeBtn.Activated:Connect(NexusX.toggleMenu)
UIS.InputBegan:Connect(function(input, gp) if not gp and input.KeyCode == Enum.KeyCode.LeftAlt then NexusX.toggleMenu() end end)

local frameCount, lastFpsUpdate = 0, 0
RunService.Heartbeat:Connect(function(dt)
    frameCount = frameCount + 1
    lastFpsUpdate = lastFpsUpdate + dt
    if lastFpsUpdate >= 1 then
        fpsOverlay.Text = "FPS: " .. math.floor(frameCount / lastFpsUpdate + 0.5)
        frameCount, lastFpsUpdate = 0, 0
    end
end)
