-- LEXHOST Cinematic Verified FX (Final: blur on verify start, cinematic ~4s)
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- URL (sesuaikan jika perlu)
local urlVip = "https://raw.githubusercontent.com/putraborz/VerifikasiScWata/refs/heads/main/Loader/vip.txt"
local urlSatuan = "https://raw.githubusercontent.com/putraborz/VerifikasiScWata/refs/heads/main/Loader/15.txt"

local successUrls = {
    "https://raw.githubusercontent.com/putraborz/WataXMountAtin/main/Loader/WataX.lua",
    "https://raw.githubusercontent.com/putraborz/WataXMountSalvatore/main/Loader/mainmap2.lua"
}

local function fetch(url)
    local ok, res = pcall(function()
        return game:HttpGet(url, true)
    end)
    return ok and res or nil
end

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

local function notify(title, text, duration)
    local ok = pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Info",
            Text = text or "",
            Duration = duration or 4
        })
    end)
    if not ok then
        print(("[%s] %s"):format(title or "Info", text or ""))
    end
end

-- MAIN GUI LOADER
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "LEXHOSTLoader"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 320, 0, 200)
frame.Position = UDim2.new(0.5, -160, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", frame)
stroke.Thickness = 2

-- RGB border anim (loader)
task.spawn(function()
    while frame.Parent do
        for hue = 0, 255 do
            stroke.Color = Color3.fromHSV(hue/255, 1, 1)
            task.wait(0.02)
        end
    end
end)

local unameLabel = Instance.new("TextLabel", frame)
unameLabel.Position = UDim2.new(0, 20, 0, 60)
unameLabel.Size = UDim2.new(1, -40, 0, 25)
unameLabel.BackgroundTransparency = 1
unameLabel.Font = Enum.Font.GothamBold
unameLabel.TextSize = 20
unameLabel.TextColor3 = Color3.fromRGB(255,255,255)
unameLabel.Text = player.Name

local status = Instance.new("TextLabel", frame)
status.Position = UDim2.new(0, 20, 0, 120)
status.Size = UDim2.new(1, -40, 0, 24)
status.BackgroundTransparency = 1
status.Font = Enum.Font.Gotham
status.TextSize = 14
status.TextColor3 = Color3.fromRGB(255,255,255)
status.Text = "Klik tombol verifikasi untuk lanjut..."

local verifyBtn = Instance.new("TextButton", frame)
verifyBtn.Size = UDim2.new(0.6, 0, 0, 36)
verifyBtn.Position = UDim2.new(0.2, 0, 1, -44)
verifyBtn.Text = "Verifikasi"
verifyBtn.Font = Enum.Font.GothamBold
verifyBtn.TextSize = 16
verifyBtn.TextColor3 = Color3.fromRGB(255,255,255)
verifyBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 100)
Instance.new("UICorner", verifyBtn).CornerRadius = UDim.new(0, 8)

-- small pulse (getar)
local function pulse(obj, amt, times)
    amt = amt or 6
    times = times or 3
    for i = 1, times do
        local orig = obj.Position
        TweenService:Create(obj, TweenInfo.new(0.05), {Position = orig + UDim2.new(0, amt, 0, 0)}):Play()
        task.wait(0.05)
        TweenService:Create(obj, TweenInfo.new(0.05), {Position = orig}):Play()
        task.wait(0.05)
    end
end

-- CINEMATIC FX (durasi ~4s)
local function playCinematicFX()
    -- Blur (keadaan sudah blur ringan oleh doVerify, tapi pastikan ada)
    local blur = Lighting:FindFirstChild("LEXHOST_Blur")
    if not blur then
        blur = Instance.new("BlurEffect")
        blur.Name = "LEXHOST_Blur"
        blur.Size = 0
        blur.Parent = Lighting
        TweenService:Create(blur, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = 12}):Play()
    end

    -- Part + ParticleEmitter di depan kamera
    local part = Instance.new("Part")
    part.Name = "LEXHOST_ParticlePart"
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.Size = Vector3.new(1,1,1)
    part.CFrame = cam.CFrame * CFrame.new(0, 0, -6)
    part.Parent = workspace
    Debris:AddItem(part, 6)

    local emitter = Instance.new("ParticleEmitter", part)
    emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    emitter.Rate = 70
    emitter.Lifetime = NumberRange.new(1.0, 2.6)
    emitter.Speed = NumberRange.new(1.2, 4.2)
    emitter.Rotation = NumberRange.new(0, 360)
    emitter.RotSpeed = NumberRange.new(-90, 90)
    emitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.45), NumberSequenceKeypoint.new(1, 0.95)})
    emitter.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.06), NumberSequenceKeypoint.new(1, 1)})
    emitter.LightEmission = 0.85
    emitter.LockedToPart = true
    emitter.VelocitySpread = 180
    emitter.Speed = NumberRange.new(0.8, 3.5)
    emitter.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 80, 255)),
        ColorSequenceKeypoint.new(0.45, Color3.fromRGB(80, 200, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,160,80))
    }
    emitter.Enabled = true
    task.delay(3.8, function()
        if emitter and emitter.Parent then emitter.Enabled = false end
    end)

    -- Fullscreen verified GUI
    local verifiedGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    verifiedGui.Name = "LEXHOST_VerifiedFX"

    local textHolder = Instance.new("Frame", verifiedGui)
    textHolder.Size = UDim2.new(0.7, 0, 0, 160)
    textHolder.AnchorPoint = Vector2.new(0.5, 0.5)
    textHolder.Position = UDim2.new(0.5, 0, 0.5, 0)
    textHolder.BackgroundTransparency = 1

    local bigText = Instance.new("TextLabel", textHolder)
    bigText.Size = UDim2.new(1, 0, 1, 0)
    bigText.Position = UDim2.new(0, 0, 0, 0)
    bigText.BackgroundTransparency = 1
    bigText.Text = "✅ LEXHOST VERIFIED"
    bigText.Font = Enum.Font.GothamBlack
    bigText.TextSize = 56
    bigText.TextTransparency = 1
    bigText.TextStrokeTransparency = 0.6
    bigText.TextColor3 = Color3.fromRGB(255,255,255)
    bigText.RichText = false
    bigText.TextScaled = true
    bigText.TextWrapped = true

    -- initial small scale
    textHolder.Size = UDim2.new(0.12, 0, 0, 60)
    TweenService:Create(textHolder, TweenInfo.new(0.8, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Size = UDim2.new(0.7, 0, 0, 160)}):Play()
    TweenService:Create(bigText, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()

    -- RGB color cycling (futuristic)
    local cycle = true
    task.spawn(function()
        while cycle and bigText.Parent do
            for h = 0, 255 do
                if not (cycle and bigText.Parent) then break end
                bigText.TextColor3 = Color3.fromHSV(h/255, 0.95, 1)
                task.wait(0.014)
            end
        end
    end)

    -- small pulse scale
    TweenService:Create(textHolder, TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Size = UDim2.new(0.72, 0, 0, 168)}):Play()
    task.wait(0.18)
    TweenService:Create(textHolder, TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Size = UDim2.new(0.7, 0, 0, 160)}):Play()

    -- show ~3.6s then fade
    task.wait(3.6)
    cycle = false
    TweenService:Create(bigText, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
    TweenService:Create(textHolder, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0.05,0,0,40)}):Play()
    TweenService:Create(blur, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = 0}):Play()

    -- cleanup
    task.delay(1, function()
        if verifiedGui and verifiedGui.Parent then verifiedGui:Destroy() end
        if blur and blur.Parent then blur:Destroy() end
        if emitter and emitter.Parent then emitter:Destroy() end
        if part and part.Parent then part:Destroy() end
    end)
end

-- doVerify: blur appears immediately (ringan), then verifikasi dilakukan
local function doVerify()
    status.Text = "Memeriksa..."
    verifyBtn.Active = false

    -- create or tween blur to ringan (halus)
    local blur = Lighting:FindFirstChild("LEXHOST_Blur")
    if not blur then
        blur = Instance.new("BlurEffect")
        blur.Name = "LEXHOST_Blur"
        blur.Size = 0
        blur.Parent = Lighting
    end
    -- tween to soft value (ringan elegan)
    TweenService:Create(blur, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = 12}):Play()

    local ok, result = pcall(function()
        return isVerified(player.Name)
    end)

    verifyBtn.Active = true

    if not ok then
        status.Text = "⚠️ Error saat verifikasi."
        notify("LEXHOST", "Gagal memeriksa daftar (error).", 4)
        pulse(frame, 6, 3)
        -- hilangkan blur perlahan
        TweenService:Create(blur, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = 0}):Play()
        task.delay(0.6, function() if blur and blur.Parent then blur:Destroy() end end)
        return
    end

    if result then
        status.Text = "✅ KAMU TERDAFTAR"
        _G.WataX_Replay = true

        -- fade small loader UI
        TweenService:Create(frame, TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
        TweenService:Create(status, TweenInfo.new(0.45), {TextTransparency = 1}):Play()
        TweenService:Create(unameLabel, TweenInfo.new(0.45), {TextTransparency = 1}):Play()
        TweenService:Create(verifyBtn, TweenInfo.new(0.45), {TextTransparency = 1}):Play()
        task.wait(0.55)
        if frame and frame.Parent then frame.Visible = false end

        -- play cinematic (ke blur tetap ada)
        playCinematicFX()

        -- load success scripts after cinematic (agar sinematik terasa)
        for _,url in ipairs(successUrls) do
            local ok2, err = pcall(function()
                loadstring(game:HttpGet(url))()
            end)
            if not ok2 then warn("Gagal load:", url, err) end
        end

        if gui and gui.Parent then gui:Destroy() end
    else
        status.Text = "❌ KAMU TIDAK TERDAFTAR"
        _G.WataX_Replay = false
        pulse(frame, -6, 3)
        TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(200,50,50)}):Play()
        task.delay(0.6, function()
            if frame and frame.Parent then
                TweenService:Create(frame, TweenInfo.new(0.6), {BackgroundColor3 = Color3.fromRGB(35,35,35)}):Play()
            end
        end)
        notify("LEXHOST", "❌ Kamu belum terdaftar untuk menggunakan fitur ini.", 4)
        -- hilangkan blur perlahan
        TweenService:Create(blur, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = 0}):Play()
        task.delay(0.7, function() if blur and blur.Parent then blur:Destroy() end end)
    end
end

verifyBtn.MouseButton1Click:Connect(doVerify)
