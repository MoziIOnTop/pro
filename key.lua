local Players      = game:GetService("Players")
local CoreGui      = game:GetService("CoreGui")
local Lighting     = game:GetService("Lighting")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer  = Players.LocalPlayer
local KEY_LINK     = "https://loot-link.com/s?AY7n36gp"
local REQUIRED_KEY = "FREE_76002dbd381656d46e167e6334900ece"
local function makeRound(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = obj
end
local function makeStroke(obj, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.Color = Color3.fromRGB(255, 255, 255)
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = obj
end
local function makeGradient(obj, c1, c2, rot)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(
        Color3.fromRGB(c1[1], c1[2], c1[3]),
        Color3.fromRGB(c2[1], c2[2], c2[3])
    )
    g.Rotation = rot or 0
    g.Parent = obj
end
local function safeParent()
    local lp = Players.LocalPlayer
    if lp then
        local pg = lp:FindFirstChildOfClass("PlayerGui")
        if pg then return pg end
    end
    return CoreGui
end
local function showRestrictionMessage()
    
    local parent = safeParent()
    local old = parent:FindFirstChild("SAB_Message_Overlay")
    if old then pcall(function() old:Destroy() end) end
    local oldBlur = Lighting:FindFirstChild("SAB_Message_OverlayBlur")
    if oldBlur then pcall(function() oldBlur:Destroy() end) end

    local blur = Instance.new("BlurEffect")
    blur.Name = "SAB_Message_OverlayBlur"
    blur.Size = 16
    blur.Parent = Lighting

    local gui = Instance.new("ScreenGui")
    gui.Name = "SAB_Message_Overlay"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 9e6
    gui.Parent = parent

    local dim = Instance.new("Frame")
    dim.BackgroundColor3 = Color3.fromRGB(8, 10, 20)
    dim.BackgroundTransparency = 0.45
    dim.Size = UDim2.fromScale(1, 1)
    dim.ZIndex = 1
    dim.Parent = gui

    local card = Instance.new("Frame")
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.Position    = UDim2.fromScale(0.5, 0.5)
    card.Size        = UDim2.fromOffset(420, 150)
    card.BackgroundColor3 = Color3.fromRGB(16, 18, 34)
    card.BackgroundTransparency = 0.05
    card.BorderSizePixel = 0
    card.ZIndex = 2
    card.Parent = gui
    makeRound(card, 18)
    makeStroke(card, 1, 0.12)
    makeGradient(card, {62, 54, 160}, {105, 97, 220}, 90)

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.fromOffset(18, 14)
    title.Size = UDim2.new(1, -36, 0, 20)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 17
    title.TextColor3 = Color3.fromRGB(240, 241, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 3
    title.Text = "Notice"
    title.Parent = card

    local msg = Instance.new("TextLabel")
    msg.BackgroundTransparency = 1
    msg.Position = UDim2.fromOffset(18, 40)
    msg.Size = UDim2.new(1, -36, 0, 50)
    msg.Font = Enum.Font.Gotham
    msg.TextSize = 13
    msg.TextColor3 = Color3.fromRGB(190, 194, 220)
    msg.TextXAlignment = Enum.TextXAlignment.Left
    msg.TextWrapped = true
    msg.ZIndex = 3
    msg.Text = "This script can only be used in ETFB Public Server."
    msg.Parent = card

    local okBtn = Instance.new("TextButton")
    okBtn.BackgroundColor3 = Color3.fromRGB(120, 140, 255)
    okBtn.Position = UDim2.new(0.5, -70, 0, 98)
    okBtn.Size = UDim2.fromOffset(140, 32)
    okBtn.AutoButtonColor = true
    okBtn.Font = Enum.Font.GothamSemibold
    okBtn.TextSize = 14
    okBtn.TextColor3 = Color3.new(1, 1, 1)
    okBtn.Text = "OK"
    okBtn.ZIndex = 3
    okBtn.Parent = card
    makeRound(okBtn, 12)

    local btnGrad = Instance.new("UIGradient")
    btnGrad.Color = ColorSequence.new(
        Color3.fromRGB(115, 135, 255),
        Color3.fromRGB(170, 140, 255)
    )
    btnGrad.Rotation = 0
    btnGrad.Parent = okBtn

    local function closeAndKick()
        pcall(function() gui:Destroy() end)
        pcall(function() blur:Destroy() end)
        if LocalPlayer then
            LocalPlayer:Kick("This script can only be used in ETFB Public Server.")
        end
    end

    okBtn.MouseButton1Click:Connect(closeAndKick)
    dim.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            closeAndKick()
        end
    end)
end

local function showKeyOverlay(onSubmit)
    if not onSubmit then return end

    local parent = safeParent()
    local old = parent:FindFirstChild("KeySystem_Overlay")
    if old then pcall(function() old:Destroy() end) end
    local oldBlur = Lighting:FindFirstChild("KeySystem_OverlayBlur")
    if oldBlur then pcall(function() oldBlur:Destroy() end) end

    local blur = Instance.new("BlurEffect")
    blur.Name = "KeySystem_OverlayBlur"
    blur.Size = 16
    blur.Parent = Lighting

    local gui = Instance.new("ScreenGui")
    gui.Name = "KeySystem_Overlay"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 9e6
    gui.Parent = parent

    local dim = Instance.new("Frame")
    dim.BackgroundColor3 = Color3.fromRGB(8, 10, 20)
    dim.BackgroundTransparency = 0.35
    dim.Size = UDim2.fromScale(1, 1)
    dim.ZIndex = 1
    dim.Parent = gui

    local card = Instance.new("Frame")
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.Position    = UDim2.fromScale(0.5, 0.5)
    card.Size        = UDim2.fromOffset(430, 190)
    card.BackgroundColor3 = Color3.fromRGB(16, 18, 34)
    card.BackgroundTransparency = 0.05
    card.BorderSizePixel = 0
    card.ZIndex = 2
    card.Parent = gui
    makeRound(card, 18)
    makeStroke(card, 1, 0.15)
    makeGradient(card, {62, 54, 160}, {105, 97, 220}, 90)

    local header = Instance.new("Frame")
    header.BackgroundColor3 = Color3.fromRGB(10, 12, 26)
    header.BackgroundTransparency = 0.15
    header.Size = UDim2.new(1, -30, 0, 32)
    header.Position = UDim2.fromOffset(15, 10)
    header.ZIndex = 3
    header.Parent = card
    makeRound(header, 10)

    local statusDot = Instance.new("Frame")
    statusDot.Size = UDim2.fromOffset(8, 8)
    statusDot.Position = UDim2.fromOffset(10, 12)
    statusDot.BackgroundColor3 = Color3.fromRGB(90, 255, 150)
    statusDot.BorderSizePixel = 0
    statusDot.ZIndex = 4
    statusDot.Parent = header
    makeRound(statusDot, 999)

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.fromOffset(26, 3)
    title.Size = UDim2.new(1, -30, 0, 16)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextColor3 = Color3.fromRGB(240, 241, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 4
    title.Text = "Key System"
    title.Parent = header

    local subtitleTop = Instance.new("TextLabel")
    subtitleTop.BackgroundTransparency = 1
    subtitleTop.Position = UDim2.fromOffset(26, 17)
    subtitleTop.Size = UDim2.new(1, -30, 0, 14)
    subtitleTop.Font = Enum.Font.Gotham
    subtitleTop.TextSize = 11
    subtitleTop.TextColor3 = Color3.fromRGB(150, 160, 210)
    subtitleTop.TextXAlignment = Enum.TextXAlignment.Left
    subtitleTop.ZIndex = 4
    subtitleTop.Text = "Enter key to unlock."
    subtitleTop.Parent = header

    local box = Instance.new("TextBox")
    box.BackgroundColor3 = Color3.fromRGB(12, 14, 28)
    box.BackgroundTransparency = 0.08
    box.Position = UDim2.fromOffset(20, 56)
    box.Size = UDim2.new(1, -40, 0, 36)
    box.ClearTextOnFocus = false
    box.Font = Enum.Font.GothamMedium
    box.TextSize = 13
    box.TextColor3 = Color3.fromRGB(235, 239, 255)
    box.PlaceholderColor3 = Color3.fromRGB(120, 125, 150)
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.PlaceholderText = "Enter key..."
    box.Text = ""
    box.ZIndex = 3
    box.Parent = card
    makeRound(box, 10)

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 10)
    pad.Parent = box

    local warnLabel = Instance.new("TextLabel")
    warnLabel.BackgroundTransparency = 1
    warnLabel.Position = UDim2.fromOffset(20, 96)
    warnLabel.Size = UDim2.new(1, -40, 0, 14)
    warnLabel.Font = Enum.Font.Gotham
    warnLabel.TextSize = 11
    warnLabel.TextColor3 = Color3.fromRGB(255, 140, 140)
    warnLabel.TextXAlignment = Enum.TextXAlignment.Left
    warnLabel.ZIndex = 3
    warnLabel.Visible = false
    warnLabel.Text = "Invalid key."
    warnLabel.Parent = card

    local getKeyBtn = Instance.new("TextButton")
    getKeyBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 80)
    getKeyBtn.Position = UDim2.new(0, 20, 0, 116)
    getKeyBtn.Size = UDim2.new(0.5, -25, 0, 32)
    getKeyBtn.AutoButtonColor = true
    getKeyBtn.Font = Enum.Font.GothamSemibold
    getKeyBtn.TextSize = 14
    getKeyBtn.TextColor3 = Color3.fromRGB(230, 235, 255)
    getKeyBtn.Text = "Get Key"
    getKeyBtn.ZIndex = 3
    getKeyBtn.Parent = card
    makeRound(getKeyBtn, 12)

    local getKeyGrad = Instance.new("UIGradient")
    getKeyGrad.Color = ColorSequence.new(
        Color3.fromRGB(120, 140, 255),
        Color3.fromRGB(180, 155, 255)
    )
    getKeyGrad.Rotation = 0
    getKeyGrad.Parent = getKeyBtn

    local submit = Instance.new("TextButton")
    submit.BackgroundColor3 = Color3.fromRGB(120, 140, 255)
    submit.Position = UDim2.new(0.5, 5, 0, 116)
    submit.Size = UDim2.new(0.5, -25, 0, 32)
    submit.AutoButtonColor = true
    submit.Font = Enum.Font.GothamSemibold
    submit.TextSize = 15
    submit.TextColor3 = Color3.new(1, 1, 1)
    submit.Text = "Continue"
    submit.ZIndex = 3
    submit.Parent = card
    makeRound(submit, 12)

    local btnGrad = Instance.new("UIGradient")
    btnGrad.Color = ColorSequence.new(
        Color3.fromRGB(115, 135, 255),
        Color3.fromRGB(170, 140, 255)
    )
    btnGrad.Rotation = 0
    btnGrad.Parent = submit

    local discordLabel = Instance.new("TextButton")
    discordLabel.BackgroundTransparency = 1
    discordLabel.Position = UDim2.fromOffset(20, 154)
    discordLabel.Size = UDim2.new(1, -40, 0, 18)
    discordLabel.Font = Enum.Font.GothamSemibold
    discordLabel.TextSize = 12
    discordLabel.TextColor3 = Color3.fromRGB(150, 170, 255)
    discordLabel.TextXAlignment = Enum.TextXAlignment.Left
    discordLabel.ZIndex = 3
    discordLabel.Text = "Discord.gg/mozil"
    discordLabel.AutoButtonColor = false
    discordLabel.Parent = card

    local inputConn
    local closed = false

    local function closeOverlay()
        if closed then return end
        closed = true
        if inputConn then pcall(function() inputConn:Disconnect() end) end
        pcall(function()
            TweenService:Create(card, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.fromOffset(430, 0),
                BackgroundTransparency = 0.4
            }):Play()
        end)
        task.delay(0.18, function()
            pcall(function() gui:Destroy() end)
            pcall(function() blur:Destroy() end)
        end)
    end

    local function shakeCard()
        local orig = card.Position
        TweenService:Create(card, TweenInfo.new(0.06, Enum.EasingStyle.Linear), {Position = orig + UDim2.fromOffset(6, 0)}):Play()
        task.wait(0.06)
        TweenService:Create(card, TweenInfo.new(0.06, Enum.EasingStyle.Linear), {Position = orig - UDim2.fromOffset(4, 0)}):Play()
        task.wait(0.06)
        TweenService:Create(card, TweenInfo.new(0.06, Enum.EasingStyle.Linear), {Position = orig}):Play()
    end

    local function flashBoxError()
        local origColor = box.BackgroundColor3
        TweenService:Create(box, TweenInfo.new(0.12, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Color3.fromRGB(90, 40, 60)
        }):Play()
        task.delay(0.15, function()
            TweenService:Create(box, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
                BackgroundColor3 = origColor
            }):Play()
        end)
    end

    local function doSubmit()
        local txt = (box.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")

        if txt == "" then
            warnLabel.Visible = true
            warnLabel.Text = "Enter your key."
            shakeCard()
            flashBoxError()
            return
        end

        if txt ~= REQUIRED_KEY then
            warnLabel.Visible = true
            warnLabel.Text = "Invalid key."
            shakeCard()
            flashBoxError()
            return
        end

        warnLabel.Visible = false
        closeOverlay()
        task.defer(function()
            pcall(onSubmit, txt)
        end)
    end

    local copiedLabel
    local function showCopied(text)
        if copiedLabel and copiedLabel.Parent then
            copiedLabel:Destroy()
        end
        copiedLabel = Instance.new("TextLabel")
        copiedLabel.BackgroundTransparency = 1
        copiedLabel.Position = UDim2.new(1, -140, 0, 154)
        copiedLabel.Size = UDim2.fromOffset(120, 18)
        copiedLabel.Font = Enum.Font.GothamSemibold
        copiedLabel.TextSize = 12
        copiedLabel.TextColor3 = Color3.fromRGB(120, 255, 170)
        copiedLabel.TextXAlignment = Enum.TextXAlignment.Right
        copiedLabel.ZIndex = 4
        copiedLabel.Text = text or "Copied!"
        copiedLabel.Parent = card

        task.spawn(function()
            task.wait(1.1)
            if copiedLabel then
                local fadeTween = TweenService:Create(copiedLabel, TweenInfo.new(0.2), {
                    TextTransparency = 1
                })
                fadeTween:Play()
                fadeTween.Completed:Wait()
                if copiedLabel then copiedLabel:Destroy() end
            end
        end)
    end

    local function doCopyKeyLink()
        if setclipboard then
            pcall(function() setclipboard(KEY_LINK) end)
            showCopied("Key link copied")
        else
            warnLabel.Visible = true
            warnLabel.Text = "Clipboard not supported."
            print("[KeySystem] KEY LINK:", KEY_LINK)
        end
    end

    local function copyDiscord()
        if setclipboard then
            pcall(function() setclipboard("https://discord.gg/mozil") end)
            showCopied("Discord copied")
        else
            print("[KeySystem] Discord link: https://discord.gg/mozil")
        end
    end

    getKeyBtn.MouseButton1Click:Connect(doCopyKeyLink)
    submit.MouseButton1Click:Connect(doSubmit)
    discordLabel.MouseButton1Click:Connect(copyDiscord)

    inputConn = UIS.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter then
                doSubmit()
            elseif input.KeyCode == Enum.KeyCode.Escape then
                closeOverlay()
            end
        end
    end)

    dim.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            closeOverlay()
        end
    end)

    task.defer(function()
        pcall(function() box:CaptureFocus() end)
    end)
end


showKeyOverlay(function(userKey)
    getgenv().UserKey = userKey

    
    task.delay(1.5, function()
        showRestrictionMessage()
    end)
end)
