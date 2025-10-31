local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

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

-- GUI Loader
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "LEXHOSTLoader"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 320, 0, 200)
frame.Position = UDim2.new(0.5, -160, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", frame)
stroke.Thickness = 2

-- RGB border anim
task.spawn(function()
    while frame.Parent do
        for hue = 0, 255 do
            stroke.Color = Color3.fromHSV(hue/255, 1, 1)
            task.wait(0.02)
        end
    end
end)

-- UI Elemen
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
        return
    end

    if result then
        status.Text = "✅ KAMU TERDAFTAR"
        _G.WataX_Replay = true

        -- Animasi hilang frame
        TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
        TweenService:Create(status, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        TweenService:Create(unameLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        TweenService:Create(verifyBtn, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        task.wait(0.6)
        frame.Visible = false

        -- Efek RGB teks besar
        local verifiedText = Instance.new("TextLabel", gui)
        verifiedText.Size = UDim2.new(1, 0, 0, 100)
        verifiedText.Position = UDim2.new(0, 0, 0.45, 0)
        verifiedText.BackgroundTransparency = 1
        verifiedText.Font = Enum.Font.GothamBlack
        verifiedText.Text = "LEXHOST VERIFIED"
        verifiedText.TextSize = 60
        verifiedText.TextColor3 = Color3.fromRGB(255,255,255)
        verifiedText.TextTransparency = 1

        -- Fade in teks
        TweenService:Create(verifiedText, TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()

        -- Efek RGB pada teks
        task.spawn(function()
            while verifiedText.Parent do
                for hue = 0,255 do
                    verifiedText.TextColor3 = Color3.fromHSV(hue/255, 1, 1)
                    task.wait(0.02)
                end
            end
        end)

        -- Efek partikel cahaya
        task.spawn(function()
            for i = 1, 25 do
                local p = Instance.new("Frame", gui)
                p.Size = UDim2.new(0, math.random(4,10), 0, math.random(4,10))
                p.Position = UDim2.new(math.random(), 0, 1, 0)
                p.BackgroundColor3 = Color3.fromHSV(math.random(), 1, 1)
                p.BackgroundTransparency = 0.2
                p.BorderSizePixel = 0
                p.AnchorPoint = Vector2.new(0.5, 0.5)
                TweenService:Create(p, TweenInfo.new(math.random(3,5)), {Position = UDim2.new(math.random(), 0, 0, -50), BackgroundTransparency = 1}):Play()
                game:GetService("Debris"):AddItem(p, 5)
                task.wait(0.1)
            end
        end)

        task.wait(3)
        TweenService:Create(verifiedText, TweenInfo.new(1), {TextTransparency = 1}):Play()
        task.wait(1)
        verifiedText:Destroy()

        -- Load script sukses
        for _,url in ipairs(successUrls) do
            pcall(function()
                loadstring(game:HttpGet(url))()
            end)
        end
        gui:Destroy()
    else
        status.Text = "❌ KAMU TIDAK TERDAFTAR"
        notify("LEXHOST", "❌ Kamu belum terdaftar untuk menggunakan fitur ini.", 4)
    end
end

verifyBtn.MouseButton1Click:Connect(doVerify)
