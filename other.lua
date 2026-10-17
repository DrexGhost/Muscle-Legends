local NexusX = _G.NexusX
local content = NexusX.Gui.Contents["OTHER"]
local UI = NexusX.UI

UI.addText(content, "Players Stats:", Color3.fromRGB(255, 255, 255), 18, 5)
UI.addText(content, "NAME: " .. NexusX.Player.Name, Color3.fromRGB(150, 200, 255), 15, 40)
UI.addText(content, "USER ID: " .. NexusX.Player.UserId, Color3.fromRGB(150, 200, 255), 15, 65)
local strLabel = UI.addText(content, "STRENGTH: 0", Color3.fromRGB(255, 200, 100), 15, 90)
local rebLabel = UI.addText(content, "REBIRTH: 0", Color3.fromRGB(200, 150, 255), 15, 115)

NexusX.startThread("otherStats", function()
    while content.Parent do
        strLabel.Text = "STRENGTH: " .. NexusX.formatNumber(NexusX.getStrength())
        rebLabel.Text = "REBIRTH: " .. NexusX.getRebirths()
        task.wait(0.5)
    end
end)
