local NexusX = _G.NexusX
local content = NexusX.Gui.Contents["TELEPORT"]
local UI = NexusX.UI

UI.addText(content, "Teleport", Color3.fromRGB(255, 255, 255), 18, 5)
local locations = {
    {name = "Tiny Island", coords = Vector3.new(-35, 7, 1876)},
    {name = "Frost Gym", coords = Vector3.new(-2597, 7, -407)},
    {name = "Mythical Gym", coords = Vector3.new(2231, 7, 1070)},
    {name = "Muscle King Gym", coords = Vector3.new(-8584, 17, -5678)},
    {name = "Eternal Gym", coords = Vector3.new(-6739, 7, -1282)},
    {name = "Legends Gym", coords = Vector3.new(4629, 991, -3896)},
    {name = "Jungle Gym", coords = Vector3.new(-8706, 6, 2387)},
    {name = "Industrial Gym", coords = Vector3.new(-5545, 60, 4941)},
    {name = "Electro Gym", coords = Vector3.new(-3134, 168, 4999)},
}
for i, loc in ipairs(locations) do
    local btn = Instance.new("TextButton", content)
    btn.Size = UDim2.new(0.45, 0, 0, 30)
    if i == #locations then
        btn.Position = UDim2.new(0.5, -105, 0, 40 + math.floor((i-1) / 2) * 35)
    else
        btn.Position = UDim2.new(0.05 + ((i-1) % 2) * 0.48, 0, 0, 40 + math.floor((i-1) / 2) * 35)
    end
    btn.BackgroundColor3 = NexusX.Colors.button
    btn.Text = loc.name
    btn.TextColor3 = NexusX.Colors.text
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamSemibold
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    UI.addButtonStroke(btn, Color3.fromRGB(80, 80, 80), 1)

    btn.MouseButton1Click:Connect(function()
        local hrp = NexusX.Player.Character and NexusX.Player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(loc.coords) end
    end)
end
