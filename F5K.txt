local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local locale = player.LocaleId or "en-us"

local isVietnamese = string.lower(locale):find("vi")

local videoLink = "https://youtu.be/P2eBaYooaq4?si=5afFDx-5JY_L_I0-"

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FurinaNotice"
ScreenGui.Parent = CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 360, 0, 180)
Frame.Position = UDim2.new(0.5, -180, 0.5, -90)
Frame.BackgroundColor3 = Color3.fromRGB(15,15,20)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,40)
Title.Position = UDim2.new(0,0,0,0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 22
Title.TextColor3 = Color3.fromRGB(0,200,255)
Title.Text = "FURINA HUB"
Title.Parent = Frame

local Message = Instance.new("TextLabel")
Message.Size = UDim2.new(1,-20,0,80)
Message.Position = UDim2.new(0,10,0,50)
Message.BackgroundTransparency = 1
Message.Font = Enum.Font.Gotham
Message.TextSize = 14
Message.TextColor3 = Color3.fromRGB(220,220,220)
Message.TextWrapped = true

if isVietnamese then
    Message.Text = "Script đã được cải tiến, hãy lấy nó trong video mới.\nẤn nút bên dưới để lấy link video."
else
    Message.Text = "The script has been improved, get it in the new video.\nPress the button below to get the video link."
end

Message.Parent = Frame

local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(0.6,0,0,35)
CopyBtn.Position = UDim2.new(0.2,0,1,-45)
CopyBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)
CopyBtn.Font = Enum.Font.GothamBold
CopyBtn.TextSize = 14
CopyBtn.TextColor3 = Color3.new(1,1,1)
CopyBtn.Text = isVietnamese and "Copy Link" or "Copy Link"
CopyBtn.Parent = Frame
Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0,8)

CopyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(videoLink)
        CopyBtn.Text = isVietnamese and "Đã copy!" or "Copied!"
    else
        CopyBtn.Text = "Clipboard not supported"
    end
end)

-- hiệu ứng hiện nhẹ
Frame.BackgroundTransparency = 1
for i = 1, 10 do
    Frame.BackgroundTransparency = 1 - i/10
    task.wait(0.03)
end
