-- LEXHOST Loader (FINAL - Verifikasi Valid + Realtime 10s)
-- Fitur utama:
--  • Realtime check setiap 10s
--  • "VERIFIKASI VALID - AKSES DIBERIKAN" fullscreen cinematic
--  • "VERIFIKASI GAGAL - NAMA TIDAK TERDAFTAR" di GUI
--  • Blur halus saat memeriksa / cinematic
--  • Tombol X untuk tutup GUI
-- Semua logika verifikasi tetap memakai 2 file GitHub (tidak diubah)

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- URLs verifikasi (tetap)
local urlVip = "https://raw.githubusercontent.com/putraborz/VerifikasiScWata/refs/heads/main/vip.txt"
local urlSatuan = "https://raw.githubusercontent.com/putraborz/VerifikasiScWata/refs/heads/main/15.txt"

local successUrls = {
    "https://raw.githubusercontent.com/putraborz/WataXMountAtin/main/Loader/WataX.lua",
    "https://raw.githubusercontent.com/putraborz/WataXMountSalvatore/main/Loader/mainmap2.lua"
}

-- safe fetch
local function fetch(url)
    if not url then return nil end
    local ok, res = pcall(function() return game:HttpGet(url, true) end)
    if not ok or not res then return nil end
    return tostring(res)
end

-- check list case-insensitive
local function isVerified(uname)
    if not uname then return false end
    local vip = fetch(urlVip)
    local sat = fetch(urlSatuan)
    if not vip and not sat then return false end
    uname = tostring(uname):lower()
    local function checkList(list)
        if not list then return false end
        for line in list:gmatch("[^\r\n]+") do
            local nameOnly = line:match("^(.-)%s*%-%-") or line
            nameOnly = nameOnly:match("^%s*(.-)%s*$") or ""
            if nameOnly:lower() == uname then return true end
        end
        return false
    end
    return checkList(vip) or checkList(sat)
end

local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Info",
            Text = text or "",
            Duration = duration or 4
        })
    end)
end

-- ====== Build GUI (LEXHOSTLoader) ======
local function createGuiIfMissing()
    local existing = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("LEXHOSTLoader")
    if existing then return existing end

    local gui = Instance.new("ScreenGui")
    gui.Name = "LEXHOSTLoader"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame", gui)
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 360, 0, 220)
    frame.Position = UDim2.new(0.5, -180, 0.5, -110)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,25)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 1
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Thickness = 2

    -- fade-in
    TweenService:Create(frame, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()

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

    -- Close button (X)
    local closeBtn = Instance.new("TextButton", frame)
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 32, 0, 28)
    closeBtn.Position = UDim2.new(1, -40, 0, 8)
    closeBtn.BackgroundColor3 = Color3.fromRGB(180,60,60)
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,6)
    closeBtn.MouseEnter:Connect(function() pcall(function() TweenService:Create(closeBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(220,80,80)}):Play() end) end)
    closeBtn.MouseLeave:Connect(function() pcall(function() TweenService:Create(closeBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(180,60,60)}):Play() end) end)
    closeBtn.MouseButton1Click:Connect(function()
        local b = Lighting:FindFirstChild("LEXHOST_Blur")
        if b then pcall(function() TweenService:Create(b, TweenInfo.new(0.3), {Size = 0}):Play() end); task.delay(0.35, function() if b and b.Parent then b:Destroy() end end) end
        local vg = player.PlayerGui:FindFirstChild("LEXHOST_VerifiedFX")
        if vg then vg:Destroy() end
        if gui and gui.Parent then gui:Destroy() end
    end)

    -- Avatar
    local avatar = Instance.new("ImageLabel", frame)
    avatar.Size = UDim2.new(0, 64, 0, 64)
    avatar.Position = UDim2.new(0, 16, 0, 44)
    avatar.BackgroundTransparency = 1
    avatar.Image = "rbxassetid://112840507"
    task.spawn(function()
        local ok, img = pcall(function() return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100) end)
        if ok and img then avatar.Image = img end
    end)

    -- Username
    local unameLabel = Instance.new("TextLabel", frame)
    unameLabel.Name = "UsernameLabel"
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
    status.Name = "StatusLabel"
    status.Position = UDim2.new(0, 16, 0, 118)
    status.Size = UDim2.new(1, -32, 0, 26)
    status.BackgroundTransparency = 1
    status.Font = Enum.Font.Gotham
    status.TextSize = 14
    status.TextColor3 = Color3.fromRGB(200,200,200)
    status.Text = "Klik tombol verifikasi untuk lanjut..."

    -- Verify Button
    local verifyBtn = Instance.new("TextButton", frame)
    verifyBtn.Name = "VerifyBtn"
    verifyBtn.Size = UDim2.new(0.62, 0, 0, 36)
    verifyBtn.Position = UDim2.new(0.19, 0, 1, -48)
    verifyBtn.Text = "Verifikasi"
    verifyBtn.Font = Enum.Font.GothamBold
    verifyBtn.TextSize = 16
    verifyBtn.TextColor3 = Color3.fromRGB(255,255,255)
    verifyBtn.BackgroundColor3 = Color3.fromRGB(60, 170, 100)
    Instance.new("UICorner", verifyBtn).CornerRadius = UDim.new(0, 8)

    -- Small extra buttons
    local tiktokBtn = Instance.new("TextButton", frame)
    tiktokBtn.Size = UDim2.new(0.13, 0, 0, 28)
    tiktokBtn.Position = UDim2.new(0.02, 0, 1, -40)
    tiktokBtn.Text = "TikTok"
    tiktokBtn.Font = Enum.Font.GothamBold
    tiktokBtn.TextSize = 12
    tiktokBtn.TextColor3 = Color3.fromRGB(255,255,255)
    tiktokBtn.BackgroundColor3 = Color3.fromRGB(50,50,60)
    Instance.new("UICorner", tiktokBtn).CornerRadius = UDim.new(0,6)

    local discordBtn = Instance.new("TextButton", frame)
    discordBtn.Size = UDim2.new(0.13, 0, 0, 28)
    discordBtn.Position = UDim2.new(0.86, 0, 1, -40)
    discordBtn.Text = "Discord"
    discordBtn.Font = Enum.Font.GothamBold
    discordBtn.TextSize = 12
    discordBtn.TextColor3 = Color3.fromRGB(255,255,255)
    discordBtn.BackgroundColor3 = Color3.fromRGB(48,60,110)
    Instance.new("UICorner", discordBtn).CornerRadius = UDim.new(0,6)

    -- border anim
    task.spawn(function()
        while frame.Parent do
            for h = 0, 255 do
                if not frame.Parent then break end
                stroke.Color = Color3.fromHSV(h/255, 0.85, 0.95)
                task.wait(0.02)
            end
        end
    end)

    return gui
end

local gui = createGuiIfMissing()
local frame = gui:FindFirstChild("MainFrame")
local verifyBtn = frame:FindFirstChild("VerifyBtn")
local statusLabel = frame:FindFirstChild("StatusLabel")
local unameLabel = frame:FindFirstChild("UsernameLabel")

-- helper pulse (shake)
local function pulseObj(obj, amt, times)
    amt = amt or 6; times = times or 3
    for i = 1, times do
        local ok, orig = pcall(function() return obj.Position end)
        if not ok then break end
        pcall(function() TweenService:Create(obj, TweenInfo.new(0.05), {Position = orig + UDim2.new(0, amt, 0, 0)}):Play() end)
        task.wait(0.05)
        pcall(function() TweenService:Create(obj, TweenInfo.new(0.05), {Position = orig}):Play() end)
        task.wait(0.05)
    end
end

-- Cinematic: show big center message "VERIFIKASI VALID - AKSES DIBERIKAN"
local scriptsLoaded = false
local function showValidCinematic()
    -- ensure blur
    local blur = Lighting:FindFirstChild("LEXHOST_Blur")
    if not blur then
        blur = Instance.new("BlurEffect")
        blur.Name = "LEXHOST_Blur"
        blur.Size = 0
        blur.Parent = Lighting
    end
    TweenService:Create(blur, TweenInfo.new(0.28), {Size = 8}):Play()

    -- particle source
    local part = Instance.new("Part")
    part.Name = "LEXHOST_ParticlePart"
    part.Size = Vector3.new(1,1,1)
    part.Anchored = true; part.CanCollide = false; part.Transparency = 1
    part.CFrame = cam.CFrame * CFrame.new(0,0,-6)
    part.Parent = workspace
    Debris:AddItem(part, 6)

    local emitter = Instance.new("ParticleEmitter", part)
    emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    emitter.Rate = 90
    emitter.Lifetime = NumberRange.new(0.9,2.2)
    emitter.Speed = NumberRange.new(0.8,3)
    emitter.RotSpeed = NumberRange.new(-90,90)
    emitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0.4), NumberSequenceKeypoint.new(1,0.9)})
    emitter.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.06), NumberSequenceKeypoint.new(1,1)})
    emitter.LightEmission = 0.85
    emitter.LockedToPart = true
    emitter.VelocitySpread = 180
    emitter.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(120,80,255)),
        ColorSequenceKeypoint.new(0.45, Color3.fromRGB(80,200,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,160,80))
    }
    emitter.Enabled = true
    task.delay(3.6, function() if emitter and emitter.Parent then emitter.Enabled = false end end)

    -- fullscreen GUI
    local vg = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    vg.Name = "LEXHOST_VerifiedFX"

    local holder = Instance.new("Frame", vg)
    holder.AnchorPoint = Vector2.new(0.5,0.5)
    holder.Position = UDim2.new(0.5,0,0.5,0)
    holder.Size = UDim2.new(0.12,0,0,60)
    holder.BackgroundTransparency = 1

    local bigText = Instance.new("TextLabel", holder)
    bigText.Size = UDim2.new(1,0,1,0)
    bigText.BackgroundTransparency = 1
    bigText.Text = "VERIFIKASI VALID - AKSES DIBERIKAN"
    bigText.Font = Enum.Font.GothamBlack
    bigText.TextSize = 48
    bigText.TextTransparency = 1
    bigText.TextStrokeTransparency = 0.6
    bigText.TextColor3 = Color3.fromRGB(255,255,255)
    bigText.TextScaled = true
    bigText.TextWrapped = true

    -- animate to center large + fade in
    TweenService:Create(holder, TweenInfo.new(0.8, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Size = UDim2.new(0.78,0,0,140)}):Play()
    TweenService:Create(bigText, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()

    -- rgb cycling
    local running = true
    task.spawn(function()
        while running and bigText.Parent do
            for h = 0,255 do
                if not (running and bigText.Parent) then break end
                bigText.TextColor3 = Color3.fromHSV(h/255, 0.9, 1)
                task.wait(0.012)
            end
        end
    end)

    -- pulse
    TweenService:Create(holder, TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Size = UDim2.new(0.8,0,0,146)}):Play()
    task.wait(0.18)
    TweenService:Create(holder, TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Size = UDim2.new(0.78,0,0,140)}):Play()

    -- show ~3.6s then fade
    task.wait(3.6)
    running = false
    pcall(function()
        TweenService:Create(bigText, TweenInfo.new(0.9), {TextTransparency = 1}):Play()
        TweenService:Create(holder, TweenInfo.new(0.9), {Size = UDim2.new(0.08,0,0,40)}):Play()
        if Lighting:FindFirstChild("LEXHOST_Blur") then
            TweenService:Create(Lighting:FindFirstChild("LEXHOST_Blur"), TweenInfo.new(0.9), {Size = 0}):Play()
        end
    end)
    task.delay(1.1, function()
        if vg and vg.Parent then vg:Destroy() end
        if Lighting:FindFirstChild("LEXHOST_Blur") then Lighting:FindFirstChild("LEXHOST_Blur"):Destroy() end
        if emitter and emitter.Parent then emitter:Destroy() end
        if part and part.Parent then part:Destroy() end
    end)
end

-- showInvalid (update main GUI status text)
local function showInvalid()
    if statusLabel and statusLabel.Parent then
        statusLabel.Text = "VERIFIKASI GAGAL - NAMA TIDAK TERDAFTAR"
        pulseObj(frame, -6, 3)
        notify("LEXHOST", "VERIFIKASI GAGAL - NAMA TIDAK TERDAFTAR", 4)
    end
end

-- load success scripts only once (unless you want reload behavior)
local function loadSuccessScripts()
    if scriptsLoaded then return end
    scriptsLoaded = true
    for _, url in ipairs(successUrls) do
        pcall(function()
            local s = game:HttpGet(url, true)
            if s then
                local ok, err = pcall(function() loadstring(s)() end)
                if not ok then warn("Gagal load:", url, err) end
            end
        end)
    end
end

-- manual verify (triggered by button)
local function doVerify()
    if not frame or not verifyBtn or not statusLabel then return end
    statusLabel.Text = "Memeriksa..."
    verifyBtn.Active = false

    -- create blur (halus size = 8)
    local blur = Lighting:FindFirstChild("LEXHOST_Blur")
    if not blur then
        blur = Instance.new("BlurEffect")
        blur.Name = "LEXHOST_Blur"
        blur.Size = 0
        blur.Parent = Lighting
    end
    TweenService:Create(blur, TweenInfo.new(0.35), {Size = 8}):Play()

    local ok, result = pcall(function() return isVerified(player.Name) end)
    verifyBtn.Active = true

    if not ok then
        statusLabel.Text = "⚠️ Error saat verifikasi."
        notify("LEXHOST", "Gagal memeriksa daftar (error).", 4)
        pulseObj(frame, 6, 3)
        pcall(function() TweenService:Create(blur, TweenInfo.new(0.5), {Size = 0}):Play() end)
        task.delay(0.6, function() if blur and blur.Parent then blur:Destroy() end end)
        return
    end

    if result then
        statusLabel.Text = "VERIFIKASI VALID - AKSES DIBERIKAN"
        _G.WataX_Replay = true
        -- hide small UI
        pcall(function()
            TweenService:Create(frame, TweenInfo.new(0.45), {BackgroundTransparency = 1}):Play()
            TweenService:Create(statusLabel, TweenInfo.new(0.45), {TextTransparency = 1}):Play()
            TweenService:Create(unameLabel, TweenInfo.new(0.45), {TextTransparency = 1}):Play()
            TweenService:Create(verifyBtn, TweenInfo.new(0.45), {TextTransparency = 1}):Play()
        end)
        task.wait(0.55)
        if frame and frame.Parent then frame.Visible = false end

        showValidCinematic()
        loadSuccessScripts()
        if gui and gui.Parent then gui:Destroy() end
    else
        showInvalid()
        pcall(function() TweenService:Create(blur, TweenInfo.new(0.6), {Size = 0}):Play() end)
        task.delay(0.7, function() if blur and blur.Parent then blur:Destroy() end end)
    end
end

verifyBtn.MouseButton1Click:Connect(doVerify)

-- Realtime checker every 10s
local checkInterval = 10
local lastVerified = false

-- initial check
do
    local ok, result = pcall(function() return isVerified(player.Name) end)
    if ok and result then
        lastVerified = true
        _G.WataX_Replay = true
        -- hide loader UI
        if frame and frame.Parent then
            TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            task.delay(0.35, function() if frame then frame.Visible = false end end)
        end
        -- cinematic on initial valid and load scripts
        showValidCinematic()
        loadSuccessScripts()
    else
        lastVerified = false
        _G.WataX_Replay = false
    end
end

-- background loop
task.spawn(function()
    while true do
        task.wait(checkInterval)
        local ok, result = pcall(function() return isVerified(player.Name) end)
        if not ok then
            -- ignore network error
        else
            if result and (not lastVerified) then
                lastVerified = true
                _G.WataX_Replay = true
                notify("LEXHOST", "Status berubah: VERIFIKASI VALID - AKSES DIBERIKAN (realtime).", 4)
                if frame and frame.Parent then
                    pcall(function()
                        TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                        task.delay(0.35, function() if frame then frame.Visible = false end end)
                    end)
                end
                showValidCinematic()
                loadSuccessScripts()
                local existing = player.PlayerGui:FindFirstChild("LEXHOSTLoader")
                if existing then existing:Destroy() end
            elseif (not result) and lastVerified then
                lastVerified = false
                _G.WataX_Replay = false
                notify("LEXHOST", "Status berubah: VERIFIKASI GAGAL - NAMA TIDAK TERDAFTAR (realtime).", 5)
                -- recreate GUI if missing so user can view status & re-verify
                if not player.PlayerGui:FindFirstChild("LEXHOSTLoader") then
                    gui = createGuiIfMissing()
                    frame = gui:FindFirstChild("MainFrame")
                    verifyBtn = frame:FindFirstChild("VerifyBtn")
                    statusLabel = frame:FindFirstChild("StatusLabel")
                    unameLabel = frame:FindFirstChild("UsernameLabel")
                    verifyBtn.MouseButton1Click:Connect(doVerify)
                else
                    local lf = player.PlayerGui:FindFirstChild("LEXHOSTLoader")
                    if lf and lf.MainFrame and lf.MainFrame:FindFirstChild("StatusLabel") then
                        lf.MainFrame.StatusLabel.Text = "VERIFIKASI GAGAL - NAMA TIDAK TERDAFTAR"
                    end
                end
            end
        end
    end
end)
