local Core = ...
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local T = Core.T

local oldGui = PlayerGui:FindFirstChild("NexusML_UI")
if oldGui then oldGui:Destroy() end

local GUI = { _tabs = {}, _pages = {} }

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NexusML_UI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999
screenGui.Parent = PlayerGui

GUI.screenGui = screenGui
local BASE_W, BASE_H = 660, 460

local function makeCorner(parent, radius)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = UDim.new(0, radius)
    return c
end

local function makeStroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke", parent)
    s.Color = color or T.stroke
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.Parent = parent
    return s
end

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Size = UDim2.new(0, BASE_W, 0, BASE_H)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.BackgroundColor3 = T.bg2
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Visible = false
Main.Parent = screenGui
makeCorner(Main, 24)
makeStroke(Main, T.stroke, 1.5, 0.2)

GUI.Main = Main
GUI.BASE_W, GUI.BASE_H = BASE_W, BASE_H

local uiScale = Instance.new("UIScale")
uiScale.Scale = (Core.settings.guiScale or 85) / 100
uiScale.Parent = Main
GUI.uiScale = uiScale

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 58)
TopBar.BackgroundColor3 = T.panel
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 2
TopBar.Parent = Main
makeCorner(TopBar, 24)

local TopBarMask = Instance.new("Frame")
TopBarMask.Name = "TopBarMask"
TopBarMask.Size = UDim2.new(1, 0, 0, 24)
TopBarMask.Position = UDim2.new(0, 0, 1, -24)
TopBarMask.BackgroundColor3 = T.panel
TopBarMask.BorderSizePixel = 0
TopBarMask.ZIndex = 3
TopBarMask.Parent = TopBar

local logoBox = Instance.new("Frame")
logoBox.Size = UDim2.new(0, 34, 0, 34)
logoBox.Position = UDim2.new(0, 16, 0.5, -17)
logoBox.BackgroundColor3 = T.accent
logoBox.BorderSizePixel = 0
logoBox.ZIndex = 4
logoBox.Parent = TopBar
makeCorner(logoBox, 9)

local logoText = Instance.new("TextLabel")
logoText.Size = UDim2.new(1, 0, 1, 0)
logoText.BackgroundTransparency = 1
logoText.Text = "M"
logoText.TextColor3 = Color3.fromRGB(10, 14, 24)
logoText.TextSize = 20
logoText.Font = Enum.Font.GothamBlack
logoText.ZIndex = 5
logoText.Parent = logoBox

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 200, 0, 20)
titleLabel.Position = UDim2.new(0, 68, 0, 12)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Muscle Legends"
titleLabel.TextColor3 = T.text
titleLabel.TextSize = 15
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.ZIndex = 4
titleLabel.Parent = TopBar

local versionLabel = Instance.new("TextLabel")
versionLabel.Size = UDim2.new(0, 200, 0, 14)
versionLabel.Position = UDim2.new(0, 68, 0, 30)
versionLabel.BackgroundTransparency = 1
versionLabel.Text = "NexusX"
versionLabel.TextColor3 = T.textMuted
versionLabel.TextSize = 10
versionLabel.Font = Enum.Font.Gotham
versionLabel.TextXAlignment = Enum.TextXAlignment.Left
versionLabel.ZIndex = 4
versionLabel.Parent = TopBar

local closeBtn = Instance.new("ImageButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -44, 0.5, -16)
closeBtn.BackgroundColor3 = T.panelHi
closeBtn.BorderSizePixel = 0
closeBtn.Image = "rbxassetid://2923552991"
closeBtn.ImageColor3 = T.textDim
closeBtn.ScaleType = Enum.ScaleType.Fit
closeBtn.AutoButtonColor = false
closeBtn.ZIndex = 4
closeBtn.Parent = TopBar
makeCorner(closeBtn, 7)

local closePad = Instance.new("UIPadding", closeBtn)
closePad.PaddingTop = UDim.new(0, 8)
closePad.PaddingBottom = UDim.new(0, 8)
closePad.PaddingLeft = UDim.new(0, 8)
closePad.PaddingRight = UDim.new(0, 8)

closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.danger, ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
end)
closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.panelHi, ImageColor3 = T.textDim}):Play()
end)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 152, 1, -58)
Sidebar.Position = UDim2.new(0, 0, 0, 58)
Sidebar.BackgroundColor3 = T.bg2
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 2
Sidebar.Parent = Main
makeCorner(Sidebar, 24)

local sidePad = Instance.new("UIPadding")
sidePad.PaddingTop = UDim.new(0, 10)
sidePad.PaddingLeft = UDim.new(0, 8)
sidePad.PaddingRight = UDim.new(0, 8)
sidePad.PaddingBottom = UDim.new(0, 10)
sidePad.Parent = Sidebar

local sideLayout = Instance.new("UIListLayout")
sideLayout.Padding = UDim.new(0, 4)
sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
sideLayout.Parent = Sidebar

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -152, 1, -58)
Content.Position = UDim2.new(0, 152, 0, 58)
Content.BackgroundTransparency = 1
Content.ZIndex = 2
Content.Parent = Main
GUI.Content = Content

local contentPad = Instance.new("UIPadding")
contentPad.PaddingLeft = UDim.new(0, 12)
contentPad.PaddingRight = UDim.new(0, 12)
contentPad.PaddingTop = UDim.new(0, 12)
contentPad.PaddingBottom = UDim.new(0, 12)
contentPad.Parent = Content

local ICON_IDS = {
    dashboard = "83894654139062",
    helper = "3650695359",
    farm = "80653163718801",
    ultimate = "15311960682",
    motion = "3220768089",
    combat = "76078853582404",
    settings = "100589335929927"
}

local function buildIcon(holder, kind, color)
    for _, c in ipairs(holder:GetChildren()) do c:Destroy() end
    local id = ICON_IDS[kind]
    if not id then return end

    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(0, 16, 0, 16)
    img.Position = UDim2.new(0, 3, 0.5, -8)
    img.BackgroundTransparency = 1
    img.Image = "rbxassetid://" .. id
    img.ImageColor3 = color
    img.ScaleType = Enum.ScaleType.Fit
    img.Parent = holder
end

function GUI.makeTab(text, order, iconKind)
    local tab = Instance.new("TextButton")
    tab.Size = UDim2.new(1, 0, 0, 36)
    tab.BackgroundColor3 = T.card
    tab.BackgroundTransparency = 1
    tab.BorderSizePixel = 0
    tab.Text = ""
    tab.AutoButtonColor = false
    tab.LayoutOrder = order
    tab.Parent = Sidebar
    makeCorner(tab, 8)

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 3, 0.55, 0)
    indicator.Position = UDim2.new(0, 0, 0.225, 0)
    indicator.BackgroundColor3 = T.accent
    indicator.BorderSizePixel = 0
    indicator.BackgroundTransparency = 1
    indicator.Parent = tab
    makeCorner(indicator, 10)

    local iconHolder = Instance.new("Frame")
    iconHolder.Size = UDim2.new(0, 22, 1, 0)
    iconHolder.Position = UDim2.new(0, 12, 0, 0)
    iconHolder.BackgroundTransparency = 1
    iconHolder.Parent = tab
    buildIcon(iconHolder, iconKind, T.textDim)

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -40, 1, 0)
    textLabel.Position = UDim2.new(0, 40, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = T.textDim
    textLabel.TextSize = 12
    textLabel.Font = Enum.Font.GothamMedium
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = tab

    local obj = { Button = tab, Indicator = indicator, IconHolder = iconHolder, Text = textLabel, Active = false, IconKind = iconKind }

    obj.SetActive = function(v)
        obj.Active = v
        if v then
            TweenService:Create(tab, TweenInfo.new(0.2), {BackgroundColor3 = T.card, BackgroundTransparency = 0.05}):Play()
            TweenService:Create(indicator, TweenInfo.new(0.25), {BackgroundTransparency = 0}):Play()
            TweenService:Create(textLabel, TweenInfo.new(0.2), {TextColor3 = T.text}):Play()
            buildIcon(iconHolder, iconKind, T.accent)
        else
            TweenService:Create(tab, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            TweenService:Create(indicator, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
            TweenService:Create(textLabel, TweenInfo.new(0.2), {TextColor3 = T.textDim}):Play()
            buildIcon(iconHolder, iconKind, T.textDim)
        end
    end

    tab.MouseEnter:Connect(function()
        if not obj.Active then
            TweenService:Create(tab, TweenInfo.new(0.12), {BackgroundTransparency = 0.55, BackgroundColor3 = T.card}):Play()
            TweenService:Create(textLabel, TweenInfo.new(0.12), {TextColor3 = T.text}):Play()
        end
    end)
    tab.MouseLeave:Connect(function()
        if not obj.Active then
            TweenService:Create(tab, TweenInfo.new(0.12), {BackgroundTransparency = 1}):Play()
            TweenService:Create(textLabel, TweenInfo.new(0.12), {TextColor3 = T.textDim}):Play()
        end
    end)

    table.insert(GUI._tabs, obj)
    return obj
end

function GUI.makePage()
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.CanvasSize = UDim2.new(0, 0, 0, 800)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = T.accent
    page.ScrollBarImageTransparency = 0.5
    page.Visible = false
    page.Parent = Content

    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    local pad = Instance.new("UIPadding", page)
    pad.PaddingRight = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)

    table.insert(GUI._pages, page)
    return page
end

function GUI.switchTab(targetTab, targetPage)
    for _, tab in ipairs(GUI._tabs) do tab.SetActive(tab == targetTab) end
    for _, page in ipairs(GUI._pages) do page.Visible = (page == targetPage) end
end

function GUI.makeSectionHeader(parent, text, order)
    local holder = Instance.new("Frame", parent)
    holder.Size = UDim2.new(1, 0, 0, 24)
    holder.BackgroundTransparency = 1
    holder.LayoutOrder = order

    local dot = Instance.new("Frame", holder)
    dot.Size = UDim2.new(0, 6, 0, 6)
    dot.Position = UDim2.new(0, 4, 0.5, -3)
    dot.BackgroundColor3 = T.accent
    dot.BorderSizePixel = 0
    makeCorner(dot, 10)

    local lbl = Instance.new("TextLabel", holder)
    lbl.Size = UDim2.new(1, -30, 1, 0)
    lbl.Position = UDim2.new(0, 18, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = T.text
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
end

function GUI.makeToggle(parent, name, desc, default, order, callback, settingName)
    local row = Instance.new("TextButton", parent)
    row.Size = UDim2.new(1, 0, 0, 48)
    row.BackgroundColor3 = T.card
    row.BorderSizePixel = 0
    row.Text = ""
    row.AutoButtonColor = false
    row.LayoutOrder = order
    makeCorner(row, 10)
    local rowStroke = makeStroke(row, T.stroke, 1, 0.4)

    local nameLbl = Instance.new("TextLabel", row)
    nameLbl.Size = UDim2.new(1, -80, 0, 16)
    nameLbl.Position = UDim2.new(0, 14, 0, 9)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = name
    nameLbl.TextColor3 = T.text
    nameLbl.TextSize = 13
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left

    local descLbl = Instance.new("TextLabel", row)
    descLbl.Size = UDim2.new(1, -80, 0, 14)
    descLbl.Position = UDim2.new(0, 14, 0, 26)
    descLbl.BackgroundTransparency = 1
    descLbl.Text = desc or ""
    descLbl.TextColor3 = T.textMuted
    descLbl.TextSize = 10
    descLbl.Font = Enum.Font.Gotham
    descLbl.TextXAlignment = Enum.TextXAlignment.Left

    local pill = Instance.new("Frame", row)
    pill.Size = UDim2.new(0, 40, 0, 22)
    pill.Position = UDim2.new(1, -54, 0.5, -11)
    pill.BackgroundColor3 = default and T.accent or T.toggleOff
    pill.BorderSizePixel = 0
    makeCorner(pill, 11)

    local knob = Instance.new("Frame", pill)
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = default and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    makeCorner(knob, 9)

    local state = default
    local function setState(v, silent)
        state = v
        TweenService:Create(pill, TweenInfo.new(0.2), {BackgroundColor3 = state and T.accent or T.toggleOff}):Play()
        TweenService:Create(knob, TweenInfo.new(0.22, Enum.EasingStyle.Back), {Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}):Play()
        if not silent then
            if settingName then Core.saveSetting(settingName, state) end
            if callback then callback(state) end
        end
    end

    row.MouseButton1Click:Connect(function() setState(not state, false) end)
    row.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = T.cardHover}):Play()
        TweenService:Create(rowStroke, TweenInfo.new(0.15), {Color = T.accent, Transparency = 0.5}):Play()
    end)
    row.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = T.card}):Play()
        TweenService:Create(rowStroke, TweenInfo.new(0.15), {Color = T.stroke, Transparency = 0.4}):Play()
    end)

    if settingName then Core.toggleRefs[settingName] = { setEnabled = setState } end
    return { Set = setState, Get = function() return state end, Desc = descLbl, Row = row, NameLabel = nameLbl, DescLabel = descLbl }
end

function GUI.makeSlider(parent, name, min, max, default, order, callback, settingName)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 62)
    row.BackgroundColor3 = T.card
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    makeCorner(row, 10)
    local rowStroke = makeStroke(row, T.stroke, 1, 0.4)

    local nameLbl = Instance.new("TextLabel", row)
    nameLbl.Size = UDim2.new(1, -80, 0, 16)
    nameLbl.Position = UDim2.new(0, 14, 0, 8)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = name
    nameLbl.TextColor3 = T.text
    nameLbl.TextSize = 13
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left

    local valLbl = Instance.new("TextLabel", row)
    valLbl.Size = UDim2.new(0, 60, 0, 16)
    valLbl.Position = UDim2.new(1, -74, 0, 8)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(default)
    valLbl.TextColor3 = T.accent
    valLbl.TextSize = 13
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextXAlignment = Enum.TextXAlignment.Right

    local track = Instance.new("Frame", row)
    track.Size = UDim2.new(1, -28, 0, 4)
    track.Position = UDim2.new(0, 14, 0, 42)
    track.BackgroundColor3 = T.toggleOff
    track.BorderSizePixel = 0
    makeCorner(track, 10)

    local initPct = (default - min) / (max - min)
    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new(initPct, 0, 1, 0)
    fill.BackgroundColor3 = T.accent
    fill.BorderSizePixel = 0
    makeCorner(fill, 10)

    local knob = Instance.new("Frame", track)
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(initPct, 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    makeCorner(knob, 10)
    makeStroke(knob, T.accent, 2)

    local value, activeDrag = default, false
    local function apply(v, silent)
        value = math.clamp(math.floor(v + 0.5), min, max)
        local pct = (value - min) / (max - min)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, 0, 0.5, 0)
        valLbl.Text = tostring(value)
        if not silent then
            if settingName then Core.saveSetting(settingName, value) end
            if callback then callback(value) end
        end
    end

    local clickArea = Instance.new("TextButton", row)
    clickArea.Size = UDim2.new(1, 0, 0, 30)
    clickArea.Position = UDim2.new(0, 0, 0, 26)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""

    clickArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            activeDrag = true
            apply(min + ((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X) * (max - min), false)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if activeDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            apply(min + ((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X) * (max - min), false)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            activeDrag = false
        end
    end)

    if settingName then Core.sliderRefs[settingName] = { setValue = function(v, s) apply(v, s ~= false) end } end
    return { Set = apply, Get = function() return value end }
end

function GUI.makeActionButton(parent, text, variant, order, onClick)
    local color, textColor, strokeColor = T.card, Color3.fromRGB(255, 255, 255), T.stroke
    if variant == "primary" then color = T.accent; textColor = Color3.fromRGB(10, 14, 24); strokeColor = T.accent
    elseif variant == "blue" then color = T.blue; textColor = Color3.fromRGB(255, 255, 255); strokeColor = T.blueHi
    elseif variant == "danger" then color = T.danger; textColor = Color3.fromRGB(255, 255, 255); strokeColor = T.danger end

    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.BackgroundColor3 = color
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = textColor
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.LayoutOrder = order
    makeCorner(btn, 10)
    local s = makeStroke(btn, strokeColor, 1)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = color:Lerp(Color3.fromRGB(255, 255, 255), variant == "primary" and 0.2 or 0.15)}):Play()
        TweenService:Create(s, TweenInfo.new(0.15), {Color = T.accent, Transparency = 0.4}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = color}):Play()
        TweenService:Create(s, TweenInfo.new(0.15), {Color = strokeColor, Transparency = 0}):Play()
    end)

    if onClick then btn.MouseButton1Click:Connect(onClick) end
    return btn
end

local floatBtn = Instance.new("TextButton", screenGui)
floatBtn.Name = "FloatButton"
floatBtn.Size = UDim2.new(0, Core.settings.floatBtnSize or 58, 0, Core.settings.floatBtnSize or 58)
floatBtn.AnchorPoint = Vector2.new(0, 0.5)
floatBtn.Position = UDim2.new(Core.settings.floatBtnPos[1] or 0, Core.settings.floatBtnPos[2] or 20, Core.settings.floatBtnPos[3] or 0.5, Core.settings.floatBtnPos[4] or 0)
floatBtn.BackgroundColor3 = T.bg1
floatBtn.BorderSizePixel = 0
floatBtn.Text = ""
floatBtn.AutoButtonColor = false
floatBtn.ClipsDescendants = true
floatBtn.Parent = screenGui
makeCorner(floatBtn, 14)

local fbGrad = Instance.new("UIGradient", floatBtn)
fbGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(26, 34, 54)), ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 14, 26))})
fbGrad.Rotation = 135
local fbStroke = makeStroke(floatBtn, T.accent, 1.5, 0.3)

local barContainer = Instance.new("Frame", floatBtn)
barContainer.Size = UDim2.new(0, 32, 1, -18)
barContainer.Position = UDim2.new(0.5, -16, 0.5, 0)
barContainer.AnchorPoint = Vector2.new(0, 0.5)
barContainer.BackgroundTransparency = 1

local barLayout = Instance.new("UIListLayout", barContainer)
barLayout.FillDirection = Enum.FillDirection.Horizontal
barLayout.Padding = UDim.new(0, 3)
barLayout.VerticalAlignment = Enum.VerticalAlignment.Center

local bars = {}
for i = 1, 5 do
    local bar = Instance.new("Frame", barContainer)
    bar.Size = UDim2.new(0, 4, 0.3, 0)
    bar.BackgroundColor3 = T.accent
    bar.BorderSizePixel = 0
    makeCorner(bar, 10)
    table.insert(bars, {frame = bar, phase = i * 0.8})
end

local eqHovered = false
RunService.Heartbeat:Connect(function()
    if not floatBtn.Parent or not floatBtn.Visible then return end
    local t = tick()
    local speed = eqHovered and 6 or 3
    for _, b in ipairs(bars) do
        local v = (math.sin(t * speed + b.phase) + 1) / 2
        b.frame.Size = UDim2.new(0, 4, 0.2 + v * 0.75, 0)
    end
end)

floatBtn.MouseEnter:Connect(function()
    eqHovered = true
    TweenService:Create(fbStroke, TweenInfo.new(0.15), {Color = T.accentSoft, Transparency = 0}):Play()
end)
floatBtn.MouseLeave:Connect(function()
    eqHovered = false
    TweenService:Create(fbStroke, TweenInfo.new(0.15), {Color = T.accent, Transparency = 0.3}):Play()
end)

local isOpen, animating = false, false

function GUI.open()
    if isOpen or animating then return end
    animating, isOpen = true, true
    Main.Visible = true
    Main.Size = UDim2.new(0, BASE_W * 0.85, 0, BASE_H * 0.85)
    TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, BASE_W, 0, BASE_H)}):Play()
    TweenService:Create(floatBtn, TweenInfo.new(0.22, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 0, 0, 0)}):Play()
    Core.settings.menuOpen = true
    Core.saveSetting("menuOpen", true)
    task.delay(0.32, function() animating = false end)
end

function GUI.close()
    if not isOpen or animating then return end
    animating, isOpen = false, false
    TweenService:Create(Main, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, BASE_W * 0.85, 0, BASE_H * 0.85)}):Play()
    TweenService:Create(floatBtn, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, Core.settings.floatBtnSize, 0, Core.settings.floatBtnSize)}):Play()
    Core.settings.menuOpen = false
    Core.saveSetting("menuOpen", false)
    task.delay(0.25, function()
        Main.Visible = false
        animating = false
    end)
end

function GUI.setOpenState(open)
    if open then
        if not isOpen then
            isOpen = true
            Main.Visible = true
            Main.Size = UDim2.new(0, BASE_W, 0, BASE_H)
            floatBtn.Size = UDim2.new(0, 0, 0, 0)
        end
    else
        if isOpen then
            isOpen = false
            Main.Visible = false
        end
        floatBtn.Size = UDim2.new(0, Core.settings.floatBtnSize, 0, Core.settings.floatBtnSize)
    end
end

function GUI.setScale(scale) uiScale.Scale = scale end
function GUI.setButtonSize(size)
    Core.settings.floatBtnSize = size
    if not isOpen and not animating then
        TweenService:Create(floatBtn, TweenInfo.new(0.2), {Size = UDim2.new(0, size, 0, size)}):Play()
    end
end
function GUI.setButtonPos(pos) floatBtn.Position = UDim2.new(pos[1] or 0, pos[2] or 20, pos[3] or 0.5, pos[4] or 0) end
function GUI.activateFirstTab() if #GUI._tabs > 0 and #GUI._pages > 0 then GUI.switchTab(GUI._tabs[1], GUI._pages[1]) end end

local fbDragging, fbDragStart, fbStartPos, fbHasMoved = false, nil, nil, false
floatBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        fbDragging = true; fbHasMoved = false; fbDragStart = input.Position; fbStartPos = floatBtn.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if not fbDragging then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local delta = input.Position - fbDragStart
    if math.abs(delta.X) > 3 or math.abs(delta.Y) > 3 then fbHasMoved = true end
    floatBtn.Position = UDim2.new(fbStartPos.X.Scale, fbStartPos.X.Offset + delta.X, fbStartPos.Y.Scale, fbStartPos.Y.Offset + delta.Y)
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if fbDragging then
            fbDragging = false
            if fbHasMoved then
                Core.saveSetting("floatBtnPos", {floatBtn.Position.X.Scale, floatBtn.Position.X.Offset, floatBtn.Position.Y.Scale, floatBtn.Position.Y.Offset})
            else
                if isOpen then GUI.close() else GUI.open() end
            end
        end
    end
end)

closeBtn.MouseButton1Click:Connect(GUI.close)
UIS.InputBegan:Connect(function(input, gp) if not gp and input.KeyCode == Enum.KeyCode.LeftAlt then if isOpen then GUI.close() else GUI.open() end end end)

return GUI