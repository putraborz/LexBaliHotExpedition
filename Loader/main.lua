-- LEXHOST Cinematic Verified FX - siap tempel
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- (sisipkan URL dll sesuai kebutuhan)
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

-- MAIN GUI LOADER (keperluan verifikasi)
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

-- Helper small pulse (getar)
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

-- SINEMATIC FX FUNCTION
local function playCinematicFX()
    -- 1) BlurEffect (lighting)
    local blur = Instance.new("BlurEffect")
    blur.Name = "LEXHOST_Blur"
    blur.Size = 0
    blur.Parent = Lighting
    -- tween blur to a soft value
    TweenService:Create(blur, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = 18}):Play()

    -- 2) small camera-facing Part + ParticleEmitter (di depan kamera)
    local part = Instance.new("Part")
    part.Name = "LEXHOST_ParticlePart"
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.Size = Vector3.new(1,1,1)
    part.CFrame = cam.CFrame * CFrame.new(0, 0, -6) -- 6 studs di depan kamera
    part.Parent = workspace
    Debris:AddItem(part, 6)

    local emitter = Instance.new("ParticleEmitter", part)
    emitter.Name = "LEXHOST_PEmitter"
    -- tekstur partikel (pakai sparkles built-in); bisa diganti asset id jika mau
    emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    emitter.Rate = 60
    emitter.Lifetime = NumberRange.new(1.2, 3)
    emitter.Speed = NumberRange.new(1, 4)
    emitter.Rotation = NumberRange.new(0, 360)
    emitter.RotSpeed = NumberRange.new(-90, 90)
    emitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 0.9)})
    emitter.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 1)})
    emitter.LightEmission = 0.8
    emitter.LockedToPart = true
    emitter.VelocitySpread = 180
    -- warna campur (RGB-warni / bebas)
    emitter.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 80, 255)), -- ungu
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80, 200, 255)), -- cyan
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,160,80)) -- orange
    }

    -- buat emitter burst intens lalu slow
    emitter.Enabled = true
    -- bersihkan emitter beberapa detik kemudian
    task.delay(4.5, function()
        if emitter and emitter.Parent then
            emitter.Enabled = false
        end
    end)

    -- 3) Teks besar fullscreen (UI)
    local verifiedGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    verifiedGui.Name = "LEXHOST_VerifiedFX"

    local bigText = Instance.new("TextLabel", verifiedGui)
    bigText.Size = UDim2.new(1, 0, 0, 160)
    bigText.Position = UDim2.new(0, 0, 0.45, -80)
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

    -- scale effect using UIAspect? We'll tween TextSize and TextTransparency via a wrapper frame to simulate scale
    local textHolder = Instance.new("Frame", verifiedGui)
    textHolder.Size = UDim2.new(0.6, 0, 0, 160)
    textHolder.AnchorPoint = Vector2.new(0.5, 0.5)
    textHolder.Position = UDim2.new(0.5, 0, 0.5, 0)
    textHolder.BackgroundTransparency = 1
    bigText.Parent = textHolder

    -- initial small scale
    textHolder.Size = UDim2.new(0.1, 0, 0, 60)
    bigText.TextTransparency = 1

    -- animate scale & fade in
    TweenService:Create(textHolder, TweenInfo.new(0.8, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Size = UDim2.new(0.7, 0, 0, 160)}):Play()
    TweenService:Create(bigText, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()

    -- RGB color cycling for text (futuristic)
    local cycle = true
    task.spawn(function()
        while cycle and bigText.Parent do
            for h = 0, 255 do
                if not (cycle and bigText.Parent) then break end
                bigText.TextColor3 = Color3.fromHSV(h/255, 0.95, 1)
                task.wait(0.015)
            end
        end
    end)

    -- small glow/flicker pulses
    task.spawn(function()
        local alpha = 0.15
        while bigText.Parent do
            TweenService:Create(bigText, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextTransparency = 0.05}):Play()
            task.wait(0.35)
            TweenService:Create(bigText, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextTransparency = 0}):Play()
            task.wait(0.35)
        end
    end)

    -- play a short scale-pulse
    TweenService:Create(textHolder, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Size = UDim2.new(0.72, 0, 0, 168)}):Play()
    task.wait(0.22)
    TweenService:Create(textHolder, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Size = UDim2.new(0.7, 0, 0, 160)}):Play()

    -- durasi tampil total ~4 detik
    task.wait(3.6)

    -- fade out everything
    cycle = false
    TweenService:Create(bigText, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
    TweenService:Create(textHolder, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0.05,0,0,40)}):Play()
    TweenService:Create(blur, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = 0}):Play()

    -- stop emitter gracefully
    if emitter and emitter.Parent then
        emitter.Enabled = false
    end

    task.wait(1)
    -- cleanup
    if verifiedGui and verifiedGui.Parent then verifiedGui:Destroy() end
    if blur and blur.Parent then blur:Destroy() end
    if emitter and emitter.Parent then emitter:Destroy() end
    if part and part.Parent then part:Destroy() end
end

-- Verifikasi (memanggil playCinematicFX() ketika sukses)
local function doVerify()
    status.Text = "Memeriksa..."
    verifyBtn.Active = false

    local ok, result = pcall(function()
        return isVerified(player.Name)
    end)

    verifyBtn.Active = true

    if not ok then
        status.Text = "⚠️ Error saat verifikasi."
        notify("LEXHOST", "Gagal memeriksa daftar (error).", 4)
        pulse(frame, 6, 3)
        return
    end

    if result then
        status.Text = "✅ KAMU TERDAFTAR"
        _G.WataX_Replay = true

        -- fade out small loader UI
        TweenService:Create(frame, TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
        TweenService:Create(status, TweenInfo.new(0.45), {TextTransparency = 1}):Play()
        TweenService:Create(unameLabel, TweenInfo.new(0.45), {TextTransparency = 1}):Play()
        TweenService:Create(verifyBtn, TweenInfo.new(0.45), {TextTransparency = 1}):Play()
        task.wait(0.55)
        -- sembunyikan frame (biar fullscreen effect lebih clean)
        if frame and frame.Parent then frame.Visible = false end

        -- jalankan cinematic FX (blur + particle + teks RGB)
        playCinematicFX()

        -- load urls setelah efek (agar terasa sinematik)
        for _,url in ipairs(successUrls) do
            local ok2, err = pcall(function()
                loadstring(game:HttpGet(url))()
            end)
            if not ok2 then warn("Gagal load:", url, err) end
        end

        -- bersihkan gui utama
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
    end
end

verifyBtn.MouseButton1Click:Connect(doVerify)
