-- LEXHOST Loader (FINAL FIX VIP TXT PARSING)
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local cam = workspace.CurrentCamera

local urlVip = "https://raw.githubusercontent.com/putraborz/VerifikasiScWata/refs/heads/main/Loader/vip.txt"
local urlSatuan = "https://raw.githubusercontent.com/putraborz/VerifikasiScWata/refs/heads/main/Loader/15.txt"

local successUrls = {
    "https://raw.githubusercontent.com/putraborz/WataXMountAtin/main/Loader/WataX.lua",
    "https://raw.githubusercontent.com/putraborz/WataXMountSalvatore/main/Loader/mainmap2.lua"
}

local function fetch(url)
    local ok, res = pcall(function() return game:HttpGet(url, true) end)
    return ok and res or ""
end

-- ===== FIX VIP TXT PARSING =====
local function isVerified(uname)
    if not uname then return false end
    local vipText = fetch(urlVip) or ""
    local satText = fetch(urlSatuan) or ""
    uname = tostring(uname):lower()

    local allNames = {}
    for word in vipText:gmatch("%S+") do table.insert(allNames, word) end
    for word in satText:gmatch("%S+") do table.insert(allNames, word) end

    for _, name in ipairs(allNames) do
        if tostring(name):lower() == uname then
            return true
        end
    end
    return false
end

local function notify(title,text,duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Info",
            Text = text or "",
            Duration = duration or 4
        })
    end)
end

-- ===== GUI BUILD =====
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
    Instance.new("UICorner", verifyBtn).CornerRadius = UDim.new(0, 8)

    return gui, frame, verifyBtn, status, unameLabel
end

local gui, frame, verifyBtn, statusLabel, unameLabel = createGuiIfMissing()

-- ===== PROSES VERIFIKASI =====
local function showValidCinematic()
    -- blur & particle
    local blur = Lighting:FindFirstChild("LEXHOST_Blur") or Instance.new("BlurEffect", Lighting)
    blur.Name = "LEXHOST_Blur"
    blur.Size = 0
    TweenService:Create(blur, TweenInfo.new(0.28), {Size = 8}):Play()

    local part = Instance.new("Part")
    part.Size = Vector3.new(1,1,1); part.Anchored = true; part.CanCollide=false; part.Transparency=1
    part.CFrame = cam.CFrame * CFrame.new(0,0,-6); part.Parent=workspace
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

    local vg = Instance.new("ScreenGui", player.PlayerGui)
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

    TweenService:Create(holder, TweenInfo.new(0.8, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Size=UDim2.new(0.78,0,0,140)}):Play()
    TweenService:Create(bigText, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency=0}):Play()

    task.wait(3.6)
    TweenService:Create(bigText, TweenInfo.new(0.9), {TextTransparency = 1}):Play()
    TweenService:Create(holder, TweenInfo.new(0.9), {Size = UDim2.new(0.08,0,0,40)}):Play()
    TweenService:Create(blur, TweenInfo.new(0.9), {Size=0}):Play()
    task.delay(1.1,function() if vg then vg:Destroy() end if emitter then emitter:Destroy() end if part then part:Destroy() end if blur then blur:Destroy() end end)
end

local function showInvalid()
    if statusLabel and statusLabel.Parent then
        statusLabel.Text = "VERIFIKASI GAGAL - NAMA TIDAK TERDAFTAR"
        notify("LEXHOST","VERIFIKASI GAGAL - NAMA TIDAK TERDAFTAR",4)
    end
end

local scriptsLoaded = false
local function loadSuccessScripts()
    if scriptsLoaded then return end
    scriptsLoaded = true
    for _, url in ipairs(successUrls) do
        pcall(function()
            local s = game:HttpGet(url,true)
            if s then pcall(function() loadstring(s)() end) end
        end)
    end
end

local function doVerify()
    statusLabel.Text = "Memeriksa..."
    verifyBtn.Active=false
    local blur = Lighting:FindFirstChild("LEXHOST_Blur") or Instance.new("BlurEffect",Lighting)
    blur.Size=0; blur.Name="LEXHOST_Blur"
    TweenService:Create(blur,TweenInfo.new(0.35),{Size=8}):Play()
    local ok,result = pcall(function() return isVerified(player.Name) end)
    verifyBtn.Active=true
    if not ok then
        statusLabel.Text="⚠️ Error saat verifikasi."
        notify("LEXHOST","Gagal memeriksa daftar (error).",4)
        TweenService:Create(blur,TweenInfo.new(0.5),{Size=0}):Play()
        task.delay(0.6,function() if blur and blur.Parent then blur:Destroy() end end)
        return
    end
    if result then
        statusLabel.Text="VERIFIKASI VALID - AKSES DIBERIKAN"
        _G.WataX_Replay=true
        showValidCinematic()
        loadSuccessScripts()
        if gui and gui.Parent then gui:Destroy() end
    else
        _G.WataX_Replay=false
        showInvalid()
        TweenService:Create(blur,TweenInfo.new(0.6),{Size=0}):Play()
        task.delay(0.7,function() if blur and blur.Parent then blur:Destroy() end end)
    end
end

verifyBtn.MouseButton1Click:Connect(doVerify)

-- ===== Realtime Check =====
task.spawn(function()
    while true do
        task.wait(10)
        local ok,result = pcall(function() return isVerified(player.Name) end)
        if ok then
            if result and not _G.WataX_Replay then
                _G.WataX_Replay=true
                notify("LEXHOST","Status berubah: VERIFIKASI VALID (realtime)",4)
                doVerify()
            elseif not result and _G.WataX_Replay then
                _G.WataX_Replay=false
                notify("LEXHOST","Status berubah: VERIFIKASI GAGAL (realtime)",4)
            end
        end
    end
end)
