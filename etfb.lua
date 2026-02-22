-- Target place
local TARGET_PLACE_ID = 131623223084840

-- Check VIP / Private server bằng RemoteFunction "GetServerType"
local function IsVipByRemote()
    local rrs
    local okService, err = pcall(function()
        return game:GetService("RobloxReplicatedStorage")
    end)

    if okService then
        rrs = err
    else
        warn("[VIP] Không lấy được RobloxReplicatedStorage:", err)
        return false, "NO_SERVICE"
    end

    if not rrs then
        warn("[VIP] RobloxReplicatedStorage nil")
        return false, "NO_SERVICE"
    end

    -- tìm RemoteFunction GetServerType
    local rf = rrs:FindFirstChild("GetServerType", true) -- true = tìm đệ quy
    if not rf or not rf:IsA("RemoteFunction") then
        warn("[VIP] Không tìm thấy RemoteFunction GetServerType")
        return false, "NO_REMOTE"
    end

    -- gọi remote
    local ok, result = pcall(function()
        return rf:InvokeServer()
    end)

    if not ok then
        warn("[VIP] Lỗi InvokeServer:", result)
        return false, "REMOTE_ERROR"
    end

    print("[VIP] GetServerType trả về:", result, "(" .. typeof(result) .. ")")

    -- xử lý kết quả
    if typeof(result) == "string" then
        local lower = result:lower()
        if lower:find("vip") or lower:find("private") then
            return true, result   -- VIP / private
        else
            return false, result  -- public
        end
    else
        -- kiểu khác thì coi như public, nhưng vẫn trả raw result cho debug
        return false, result
    end
end

-- Dùng:
local isVip, raw = IsVipByRemote()
local correctPlace = (game.PlaceId == TARGET_PLACE_ID)

if correctPlace and (not isVip) then
    warn("[LOADER] Đúng place & PUBLIC → load etfbmain.lua")
    loadstring(game:HttpGet("https://raw.githubusercontent.com/MoziIOnTop/pro/refs/heads/main/etfbmain.lua"))()
else
    warn("[LOADER] Private server HOẶC place khác → load key.lua")
    loadstring(game:HttpGet("https://raw.githubusercontent.com/MoziIOnTop/pro/refs/heads/main/key.lua"))()
end
