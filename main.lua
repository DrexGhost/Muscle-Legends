local Core, GUI = ...
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local T = Core.T

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

    tab.Button.MouseButton1Click:Connect(function() GUI.switchTab(tab, page) end)
    return tab, page
end
return build
