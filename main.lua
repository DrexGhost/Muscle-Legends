local Core, GUI = ...
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local T = Core.T
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Watermark = {}

local wmScreenGui = Instance.new("ScreenGui")
wmScreenGui.Name = "NexusWatermark"
wmScreenGui.ResetOnSpawn = false
wmScreenGui.IgnoreGuiInset = true
wmScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
wmScreenGui.DisplayOrder = 999
wmScreenGui.Parent = PlayerGui

local wmRoot = Instance.new("Frame")
wmRoot.Name = "Root"
wmRoot.AnchorPoint = Vector2.new(0.5, 0)
wmRoot.Size = UDim2.new(0, 420, 0, 46)
wmRoot.Position = UDim2.new(0.5, 0, 0, 15)
wmRoot.BackgroundColor3 = T.bg1
wmRoot.BorderSizePixel = 0
wmRoot.ClipsDescendants = true
wmRoot.Parent = wmScreenGui
wmRoot.Visible = Core.settings.watermark or false

local wmScale = Instance.new("UIScale")
wmScale.Scale = (Core.settings.watermarkScale or 100) / 100
wmScale.Parent = wmRoot

local wmCorner = Instance.new("UICorner")
wmCorner.CornerRadius = UDim.new(0, 12)
wmCorner.Parent = wmRoot

local wmGrad = Instance.new("UIGradient")
wmGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 32, 54)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 12, 22)),
})
wmGrad.Rotation = 0
wmGrad.Parent = wmRoot

local wmStroke = Instance.new("UIStroke")
wmStroke.Color = T.stroke
wmStroke.Thickness = 1
wmStroke.Parent = wmRoot

local wmAccentBar = Instance.new("Frame")
wmAccentBar.Size = UDim2.new(0, 3, 0.7, 0)
wmAccentBar.Position = UDim2.new(0, 0, 0.15, 0)
wmAccentBar.BackgroundColor3 = T.accent
wmAccentBar.BorderSizePixel = 0
wmAccentBar.Parent = wmRoot

local wmAccentCorner = Instance.new("UICorner")
wmAccentCorner.CornerRadius = UDim.new(1, 0)
wmAccentCorner.Parent = wmAccentBar

local wmLayout = Instance.new("UIListLayout")
wmLayout.FillDirection = Enum.FillDirection.Horizontal
wmLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
wmLayout.VerticalAlignment = Enum.VerticalAlignment.Center
wmLayout.Padding = UDim.new(0, 10)
wmLayout.SortOrder = Enum.SortOrder.LayoutOrder
wmLayout.Parent = wmRoot

local wmPad = Instance.new("UIPadding")
wmPad.PaddingLeft = UDim.new(0, 14)
wmPad.PaddingRight = UDim.new(0, 14)
wmPad.Parent = wmRoot

local wmAvatarFrame = Instance.new("Frame")
wmAvatarFrame.Size = UDim2.new(0, 32, 0, 32)
wmAvatarFrame.BackgroundColor3 = T.accent
wmAvatarFrame.BorderSizePixel = 0
wmAvatarFrame.LayoutOrder = 1
wmAvatarFrame.Parent = wmRoot

local wmAvatarCorner = Instance.new("UICorner")
wmAvatarCorner.CornerRadius = UDim.new(1, 0)
wmAvatarCorner.Parent = wmAvatarFrame

local wmAvatarWrap = Instance.new("Frame")
wmAvatarWrap.Size = UDim2.new(1, -4, 1, -4)
wmAvatarWrap.Position = UDim2.new(0.5, -14, 0.5, -14)
wmAvatarWrap.BackgroundColor3 = T.bg1
wmAvatarWrap.BorderSizePixel = 0
wmAvatarWrap.Parent = wmAvatarFrame

local wmAvatarWrapCorner = Instance.new("UICorner")
wmAvatarWrapCorner.CornerRadius = UDim.new(1, 0)
wmAvatarWrapCorner.Parent = wmAvatarWrap

local wmAvatar = Instance.new("ImageLabel")
wmAvatar.Size = UDim2.new(1, 0, 1, 0)
wmAvatar.BackgroundTransparency = 1
wmAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
wmAvatar.Parent = wmAvatarWrap

local wmAvatarImgCorner = Instance.new("UICorner")
wmAvatarImgCorner.CornerRadius = UDim.new(1, 0)
wmAvatarImgCorner.Parent = wmAvatar

local function wmMakeSeparator(order)
    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(0, 1, 0.5, 0)
    sep.BackgroundColor3 = T.stroke
    sep.BorderSizePixel = 0
    sep.LayoutOrder = order
    sep.Parent = wmRoot
    return sep
end

local function wmMakeStat(label, order, iconColor)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(0, 80, 1, 0)
    holder.BackgroundTransparency = 1
    holder.LayoutOrder = order
    holder.Parent = wmRoot

    local icon = Instance.new("Frame")
    icon.Size = UDim2.new(0, 6, 0, 6)
    icon.Position = UDim2.new(0, 0, 0.5, -3)
    icon.BackgroundColor3 = iconColor
    icon.BorderSizePixel = 0
    icon.Parent = holder

    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(1, 0)
    iconCorner.Parent = icon

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -12, 0, 12)
    lbl.Position = UDim2.new(0, 12, 0, 12)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = T.textMuted
    lbl.TextSize = 9
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = holder

    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(1, -12, 0, 16)
    val.Position = UDim2.new(0, 12, 0, 23)
    val.BackgroundTransparency = 1
    val.Text = "—"
    val.TextColor3 = T.text
    val.TextSize = 12
    val.Font = Enum.Font.GothamBold
    val.TextXAlignment = Enum.TextXAlignment.Left
    val.Parent = holder

    return val
end

local wmFpsValue = wmMakeStat("FPS", 2, T.accent)
wmMakeSeparator(3)
local wmPingValue = wmMakeStat("PING", 4, T.success)
wmMakeSeparator(5)
local wmOnlineValue = wmMakeStat("ONLINE", 6, T.warn)

local wmFpsFrames = 0
local wmFpsAccum = 0

RunService.RenderStepped:Connect(function(dt)
    if not wmRoot.Visible then return end
    wmFpsFrames = wmFpsFrames + 1
    wmFpsAccum = wmFpsAccum + dt
    if wmFpsAccum >= 0.5 then
        local currentFps = math.floor(wmFpsFrames / wmFpsAccum + 0.5)
        wmFpsFrames = 0
        wmFpsAccum = 0
        local fpsColor = currentFps >= 60 and T.success or (currentFps >= 30 and T.warn or T.danger)
        wmFpsValue.Text = tostring(currentFps)
        wmFpsValue.TextColor3 = fpsColor
    end
end)

task.spawn(function()
    while wmScreenGui.Parent do
        task.wait(1)
        if wmRoot.Visible then
            local ping = 0
            pcall(function() ping = math.floor(LocalPlayer:GetNetworkPing() * 1000 + 0.5) end)
            local pingColor = ping < 60 and T.success or (ping < 120 and T.warn or T.danger)
            wmPingValue.Text = ping .. " ms"
            wmPingValue.TextColor3 = pingColor
            wmOnlineValue.Text = tostring(#Players:GetPlayers())
        end
    end
end)

Players.PlayerAdded:Connect(function() if wmRoot.Visible then wmOnlineValue.Text = tostring(#Players:GetPlayers()) end end)
Players.PlayerRemoving:Connect(function() task.wait(0.1) if wmRoot.Visible then wmOnlineValue.Text = tostring(#Players:GetPlayers()) end end)

task.spawn(function()
    while wmScreenGui.Parent do
        TweenService:Create(wmAccentBar, TweenInfo.new(1.8, Enum.EasingStyle.Sine), {BackgroundColor3 = T.accent:Lerp(Color3.fromRGB(255,255,255), 0.3)}):Play()
        task.wait(1.8)
        TweenService:Create(wmAccentBar, TweenInfo.new(1.8, Enum.EasingStyle.Sine), {BackgroundColor3 = T.accent}):Play()
        task.wait(1.8)
    end
end)

function Watermark.setEnabled(v)
    wmRoot.Visible = v
end

function Watermark.setScale(scale)
    wmScale.Scale = scale
end

Core.Watermark = Watermark

local function build()
    local tab = GUI.makeTab("Main", 1, "dashboard")
    local page = GUI.makePage()

    local profileCard = Instance.new("Frame", page)
    profileCard.Size = UDim2.new(1, 0, 0, 92); profileCard.BackgroundColor3 = T.card; profileCard.BorderSizePixel = 0; profileCard.LayoutOrder = 1
    Instance.new("UICorner", profileCard).CornerRadius = UDim.new(0, 12)
    local pcStroke = Instance.new("UIStroke", profileCard); pcStroke.Color = T.stroke; pcStroke.Thickness = 1; pcStroke.Transparency = 0.3; pcStroke.Parent = profileCard

    local avatarRing = Instance.new("Frame", profileCard)
    avatarRing.Size = UDim2.new(0, 64, 0, 64); avatarRing.Position = UDim2.new(0, 14, 0.5, -32); avatarRing.BackgroundColor3 = T.accent; avatarRing.BorderSizePixel = 0; avatarRing.ZIndex = 2
    Instance.new("UICorner", avatarRing).CornerRadius = UDim.new(1, 0)

    local avatarWrap = Instance.new("Frame", avatarRing)
    avatarWrap.Size = UDim2.new(0, 58, 0, 58); avatarWrap.Position = UDim2.new(0.5, -29, 0.5, -29); avatarWrap.BackgroundColor3 = T.bg1; avatarWrap.BorderSizePixel = 0; avatarWrap.ZIndex = 3
    Instance.new("UICorner", avatarWrap).CornerRadius = UDim.new(1, 0)

    local avatar = Instance.new("ImageLabel", avatarWrap)
    avatar.Size = UDim2.new(1, 0, 1, 0); avatar.BackgroundTransparency = 1; avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"; avatar.ZIndex = 4
    Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)

    local nameText = Instance.new("TextLabel", profileCard)
    nameText.Size = UDim2.new(1, -100, 0, 20); nameText.Position = UDim2.new(0, 92, 0, 22); nameText.BackgroundTransparency = 1; nameText.Text = LocalPlayer.DisplayName; nameText.TextColor3 = T.text; nameText.TextSize = 15; nameText.Font = Enum.Font.GothamBold; nameText.TextXAlignment = Enum.TextXAlignment.Left; nameText.ZIndex = 4

    local userText = Instance.new("TextLabel", profileCard)
    userText.Size = UDim2.new(1, -100, 0, 14); userText.Position = UDim2.new(0, 92, 0, 42); userText.BackgroundTransparency = 1; userText.Text = "@" .. LocalPlayer.Name; userText.TextColor3 = T.textDim; userText.TextSize = 11; userText.Font = Enum.Font.Gotham; userText.TextXAlignment = Enum.TextXAlignment.Left; userText.ZIndex = 4

    GUI.makeSectionHeader(page, "Stats", 2)

    local statsRow = Instance.new("Frame", page)
    statsRow.Size = UDim2.new(1, 0, 0, 56); statsRow.BackgroundTransparency = 1; statsRow.LayoutOrder = 3
    local statsLayout = Instance.new("UIListLayout", statsRow); statsLayout.FillDirection = Enum.FillDirection.Horizontal; statsLayout.Padding = UDim.new(0, 8); statsLayout.Parent = statsRow

    local function MakeStat(order, title)
        local card = Instance.new("Frame", statsRow)
        card.Size = UDim2.new(0.5, -4, 1, 0); card.BackgroundColor3 = T.row; card.BorderSizePixel = 0; card.LayoutOrder = order
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
        local t = Instance.new("TextLabel", card); t.Size = UDim2.new(1, -20, 0, 12); t.Position = UDim2.new(0, 12, 0, 10); t.BackgroundTransparency = 1; t.Text = title; t.TextColor3 = T.textMuted; t.TextSize = 9; t.Font = Enum.Font.GothamBold; t.TextXAlignment = Enum.TextXAlignment.Left
        local v = Instance.new("TextLabel", card); v.Size = UDim2.new(1, -20, 0, 20); v.Position = UDim2.new(0, 12, 0, 26); v.BackgroundTransparency = 1; v.Text = "0"; v.TextColor3 = T.text; v.TextSize = 16; v.Font = Enum.Font.GothamBold; v.TextXAlignment = Enum.TextXAlignment.Left
        return v
    end

    local strValue = MakeStat(1, "Strength:")
    local rebValue = MakeStat(2, "Rebirth:")

    task.spawn(function()
        while GUI.screenGui.Parent do
            task.wait(1)
            local stats = LocalPlayer:FindFirstChild("leaderstats")
            if stats then
                local s = stats:FindFirstChild("Strength")
                local r = stats:FindFirstChild("Rebirths")
                if s then strValue.Text = tostring(s.Value) end
                if r then rebValue.Text = tostring(r.Value) end
            end
        end
    end)

    GUI.makeSectionHeader(page, "Other", 4)

    GUI.makeToggle(page, "Watermark", "Показать Watermark на экране", Core.settings.watermark, 5, function(v)
        Core.settings.watermark = v
        if Core.Watermark then Core.Watermark.setEnabled(v) end
    end, "watermark")

    GUI.makeToggle(page, "Anti-AFK", "Защита от кика за неактивность", Core.settings.antiAfk, 6, function(v)
        Core.settings.antiAfk = v
    end, "antiAfk")

    tab.Button.MouseButton1Click:Connect(function() GUI.switchTab(tab, page) end)
    return tab, page
end
return build