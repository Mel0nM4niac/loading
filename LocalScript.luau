local player = game.Players.LocalPlayer

-- create GUI
local gui = Instance.new("ScreenGui")
gui.Name = "FakeLoader"
gui.ResetOnSpawn = true
gui.Parent = player:WaitForChild("PlayerGui") -- show on this player's screen only

-- container
local container = Instance.new("Frame")
container.Size = UDim2.new(0,700,0,220)
container.Position = UDim2.new(.5,-350,.5,-110)
container.BackgroundColor3 = Color3.fromRGB(17,17,17)
container.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,20)
corner.Parent = container

-- title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,40)
title.Position = UDim2.new(0,0,0,10)
title.BackgroundTransparency = 1
title.Text = "Adopt Me Trade Faker and Pet Spawner"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold
title.Parent = container

-- progress bar background
local bar = Instance.new("Frame")
bar.Size = UDim2.new(0.9,0,0,30)
bar.Position = UDim2.new(.05,0,.4,0)
bar.BackgroundColor3 = Color3.fromRGB(34,34,34)
bar.Parent = container
local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(0,15)
barCorner.Parent = bar

-- fill
local fill = Instance.new("Frame")
fill.Size = UDim2.new(0,0,1,0)
fill.BackgroundColor3 = Color3.fromRGB(255,220,0)
fill.Parent = bar
local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(0,15)
fillCorner.Parent = fill

-- gradient (animated)
local gradient = Instance.new("UIGradient")
gradient.Rotation = 0
gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0,Color3.fromRGB(255,230,0)),
	ColorSequenceKeypoint.new(0.25,Color3.fromRGB(255,191,0)),
	ColorSequenceKeypoint.new(0.5,Color3.fromRGB(255,242,0)),
	ColorSequenceKeypoint.new(0.75,Color3.fromRGB(255,191,0)),
	ColorSequenceKeypoint.new(1,Color3.fromRGB(255,230,0))
}
gradient.Parent = fill

-- percent text
local percent = Instance.new("TextLabel")
percent.Size = UDim2.new(1,0,0,40)
percent.Position = UDim2.new(0,0,.6,0)
percent.BackgroundTransparency = 1
percent.Text = "0%"
percent.TextColor3 = Color3.new(1,1,1)
percent.TextScaled = true
percent.Font = Enum.Font.SourceSansBold
percent.Parent = container

-- status text
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1,0,0,20)
status.Position = UDim2.new(0,0,.8,0)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(150,150,150)
status.TextScaled = true
status.Font = Enum.Font.SourceSans
status.Parent = container

-- status messages
local messages = {
	"Initiating Script Loader Service",
	"Fetching Server.Pet.Storage",
	"Fetching Local.Pet.Storage",
	"Linking To Server",
	"Processing Inventory...",
	"Linking to Trade serverscripts",
	"Processing Game.Workspace...",
	"Fetching Local.Pet.Models",
	"Cloning Pet Animations..."
}

local messageIndex = 1
local progress = 0

-- typing effect
local function typeText(text)
	status.Text = ""
	for i = 1,#text do
		status.Text = string.sub(text,1,i)
		task.wait(0.02)
	end
end

typeText(messages[1])

-- loader animation
task.spawn(function()
	while progress < 99 do
		-- speed changes depending on percent
		local speed = 0.06
		if progress > 30 then speed = 0.045 end
		if progress > 60 then speed = 0.035 end
		if progress > 85 then speed = 0.02 end
		if progress > 95 then speed = 0.01 end

		progress += speed
		progress = math.min(progress, 99) -- never above 99

		percent.Text = math.floor(progress).."%"
		fill.Size = UDim2.new(progress/100,0,1,0)

		-- update status messages
		if math.floor(progress/12) > messageIndex and messageIndex < #messages then
			messageIndex += 1
			task.spawn(function()
				typeText(messages[messageIndex])
			end)
		end

		task.wait(0.05)
	end

	status.Text = "Finalizing injection..."
end)

-- gradient movement (simulate glow animation)
task.spawn(function()
	while true do
		gradient.Offset = Vector2.new((gradient.Offset.X + 0.01) % 1, 0)
		task.wait(0.03)
	end
end)