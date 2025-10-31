-- ===== LEXHOST Loader - Modern GUI + Original Verification =====
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local player = Players.LocalPlayer
local cam = workspace.CurrentCamera

local urlVip = "https://raw.githubusercontent.com/putraborz/VerifikasiScWata/refs/heads/main/Loader/vip.txt"
local urlSatuan = "https://raw.githubusercontent.com/putraborz/VerifikasiScWata/refs/heads/main/Loader/15.txt"

local successUrls = {
    "https://raw.githubusercontent.com/putraborz/WataXMountAtin/main/Loader/WataX.lua",
    "https://raw.githubusercontent.com/putraborz/WataXMountSalvatore/main/Loader/mainmap2.lua"
}

-- ===== Fetch Helper =====
local function fetch(url)
    local ok, res = pcall(function() return game:HttpGet(url, true) end)
    return ok and res or nil
end

-- ===== Original Verification System =====
local function isVerified(uname)
    local vip = fetch(urlVip)
    local sat = fetch(urlSatuan)
    if not vip or not sat then return false end
    uname = uname:lower()

    local function checkList(list)
        for line in list:gmatch("[^\r\n]+") do
            local nameOnly = line:match("^(.-)%s*%-%-") or line
            nameOnly = nameOnly:match("^%s*(.-)%s*$")
            if nameOnly:lower() == uname then
                return true
            end
        end
        return false
    end

    return checkList(vip) or checkList(sat)
end

-- ===== Notification Helper =====
local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Info",
            Text = text or "",
            Duration = duration or 4
        })
    end)
end

-- ===== GUI =====
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "LEXHOSTLoader"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 360, 0, 220)
frame.Position = UDim2.new(0.5, -180, 0.5, -110)
frame.BackgroundColor3 = Color3.fromRGB(25,25,30)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)
local stroke = Instance.new("UIStroke", frame)
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(255,255,255)

-- Title
local titleLabel = Instance.new("TextLabel", frame)
titleLabel.Size = UDim2.new(1, -24, 0, 28)
titleLabel.Position = UDim2.new(0, 12, 0, 8)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.Text = "LEX HOST PROJECT"
titleLabel.TextColor3 = Color3.fromRGB(220,220,255)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Close button
local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0, 32, 0, 28)
closeBtn.Position = UDim2.new(1, -40, 0, 8)
closeBtn.BackgroundColor3 = Color3.fromRGB(180,60,60)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,6)
closeBtn.MouseButton1Click:Connect(function()
    local b = Lighting:FindFirstChild("LEXHOST_Blur")
    if b then b:Destroy() end
    if gui and gui.Parent then gui:Destroy() end
end)

-- Avatar
local avatar = Instance.new("ImageLabel", frame)
avatar.Size = UDim2.new(0, 64, 0, 64)
avatar.Position = UDim2.new(0, 16, 0, 44)
avatar.BackgroundTransparency = 1
avatar.Image = "rbxassetid://112840507"
task.spawn(function()
    local ok,img = pcall(function()
        return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100)
    end)
    if ok and img then avatar.Image = img end
end)

-- Username
local unameLabel = Instance.new("TextLabel", frame)
unameLabel.Position = UDim2.new(0, 96, 0, 50)
unameLabel.Size = UDim2.new(1, -110, 0, 26)
unameLabel.BackgroundTransparency = 1
unameLabel.Font = Enum.Font.GothamBold
unameLabel.TextSize = 20
unameLabel.TextColor3 = Color3.fromRGB(240,240,240)
unameLabel.TextXAlignment = Enum.TextXAlignment.Left
unameLabel.Text = player.Name

-- Status
local status = Instance.new("TextLabel", frame)
status.Position = UDim2.new(0, 16, 0, 118)
status.Size = UDim2.new(1, -32, 0, 26)
status.BackgroundTransparency = 1
status.Font = Enum.Font.Gotham
status.TextSize = 14
status.TextColor3 = Color3.fromRGB(200,200,200)
status.Text = "Klik tombol verifikasi untuk lanjut..."

-- Verify Button
local verifyBtn = Instance.new("TextButton", frame)
verifyBtn.Size = UDim2.new(0.62, 0, 0, 36)
verifyBtn.Position = UDim2.new(0.19, 0, 1, -48)
verifyBtn.Text = "Verifikasi"
verifyBtn.Font = Enum.Font.GothamBold
verifyBtn.TextSize = 16
verifyBtn.TextColor3 = Color3.fromRGB(255,255,255)
verifyBtn.BackgroundColor3 = Color3.fromRGB(60, 170, 100)
Instance.new("UICorner", verifyBtn).CornerRadius = UDim.new(0,8)

-- ===== Verifikasi =====
local function showValidEffect()
    local blur = Lighting:FindFirstChild("LEXHOST_Blur") or Instance.new("BlurEffect", Lighting)
    blur.Name = "LEXHOST_Blur"
    blur.Size = 0
    TweenService:Create(blur, TweenInfo.new(0.3), {Size=8}):Play()

    local part = Instance.new("Part")
    part.Size = Vector3.new(1,1,1)
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.CFrame = cam.CFrame * CFrame.new(0,0,-6)
    part.Parent = workspace
    Debris:AddItem(part,6)

    local emitter = Instance.new("ParticleEmitter", part)
    emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    emitter.Rate = 90
    emitter.Lifetime = NumberRange.new(0.9,2.2)
    emitter.Speed = NumberRange.new(0.8,3)
    emitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0.4), NumberSequenceKeypoint.new(1,0.9)})
    emitter.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.06), NumberSequenceKeypoint.new(1,1)})
    emitter.Color = ColorSequence.new{Color3.fromRGB(120,80,255), Color3.fromRGB(80,200,255), Color3.fromRGB(255,160,80)}
    emitter.Enabled = true

    task.delay(3, function()
        if part then part:Destroy() end
        if emitter then emitter:Destroy() end
        if blur then TweenService:Create(blur,TweenInfo.new(0.5),{Size=0}):Play() task.delay(0.6,function() if blur.Parent then blur:Destroy() end end end
    end)
end

local function doVerify()
    status.Text = "Memeriksa..."
    verifyBtn.Active = false

    local ok,result = pcall(function() return isVerified(player.Name) end)
    verifyBtn.Active = true

    if not ok then
        status.Text = "⚠️ Error saat verifikasi."
        notify("LEXHOST","Gagal memeriksa daftar (error).",4)
        return
    end

    if result then
        status.Text = "✅ KAMU TERDAFTAR SEBAGAI PENGGUNA"
        _G.WataX_Replay = true
        showValidEffect()

        -- Load success scripts
        task.spawn(function()
            for _,url in ipairs(successUrls) do
                pcall(function()
                    loadstring(game:HttpGet(url,true))()
                end)
            end
        end)

        task.delay(0.8, function()
            if gui and gui.Parent then gui:Destroy() end
        end)
    else
        status.Text = "❌ KAMU TIDAK TERDAFTAR"
        _G.WataX_Replay = false
        notify("LEXHOST","Kamu belum terdaftar untuk menggunakan fitur ini.",4)
    end
end

verifyBtn.MouseButton1Click:Connect(doVerify)
