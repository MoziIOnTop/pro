local FE4R = {}
FE4R.__index = FE4R
FE4R.Version = "1.1.0"
FE4R.Flags = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local Theme = {
    Window = Color3.fromRGB(10, 12, 15),
    WindowAlpha = 0.10,

    Sidebar = Color3.fromRGB(15, 17, 21),
    SidebarAlpha = 0.05,

    Card = Color3.fromRGB(21, 24, 29),
    CardAlpha = 0.10,

    Element = Color3.fromRGB(23, 26, 32),
    ElementAlpha = 0.06,
    ElementHover = Color3.fromRGB(33, 37, 45),

    Stroke = Color3.fromRGB(64, 70, 82),
    StrokeAlpha = 0.10,

    Text = Color3.fromRGB(242, 244, 247),
    TextDim = Color3.fromRGB(146, 154, 167),

    Accent = Color3.fromRGB(255, 255, 255),
    ToggleOff = Color3.fromRGB(40, 44, 52),

    Font = Enum.Font.GothamMedium,
    FontBold = Enum.Font.GothamBold,
    FontLight = Enum.Font.Gotham,
}
FE4R.Theme = Theme

local CFG = {
    WindowSize = Vector2.new(760, 450),
    SidebarWidth = 218,
    TopbarHeight = 46,
    Pad = 14,
    RowHeight = 46,
    Corner = 10,
    LogoAssetId = "rbxassetid://114472961937918",
    ToggleIconAssetId = "rbxassetid://114472961937918",
    LogoHeight = 56,
}
FE4R.Config = CFG

local function New(class, props, children)
    local inst = Instance.new(class)
    local parent = nil
    for k, v in pairs(props or {}) do
        if k == "Parent" then parent = v else inst[k] = v end
    end
    for _, c in ipairs(children or {}) do c.Parent = inst end
    if parent then inst.Parent = parent end
    return inst
end

local function Corner(radius)
    return New("UICorner", { CornerRadius = UDim.new(0, radius or CFG.Corner) })
end

local function Stroke(color, thickness, transparency)
    return New("UIStroke", {
        Color = color or Theme.Stroke,
        Thickness = thickness or 1,
        Transparency = transparency or Theme.StrokeAlpha,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

local function Padding(all, l, r, t, b)
    return New("UIPadding", {
        PaddingLeft = UDim.new(0, l or all or 0),
        PaddingRight = UDim.new(0, r or all or 0),
        PaddingTop = UDim.new(0, t or all or 0),
        PaddingBottom = UDim.new(0, b or all or 0),
    })
end

local function ListLayout(pad, dir)
    return New("UIListLayout", {
        Padding = UDim.new(0, pad or 8),
        FillDirection = dir or Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
end

local function Tween(obj, time, props)
    local t = TweenService:Create(obj, TweenInfo.new(time or 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

local function GuiParent()
    if gethui then
        local ok, res = pcall(gethui)
        if ok and res then return res end
    end
    local ok = pcall(function() return CoreGui.Name end)
    if ok then return CoreGui end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local function MakeDraggable(handle, target)
    local dragging, dragStart, startPos = false, nil, nil
    local function clampPosition(pos)
        local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
        local sz = target.AbsoluteSize
        local halfW, halfH = sz.X / 2, sz.Y / 2
        local absX = pos.X.Scale * vp.X + pos.X.Offset
        local absY = pos.Y.Scale * vp.Y + pos.Y.Offset
        absX = math.clamp(absX, halfW, math.max(vp.X - halfW, halfW))
        absY = math.clamp(absY, halfH, math.max(vp.Y - halfH, halfH))
        return UDim2.new(0, absX, 0, absY)
    end
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                      or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            local newPos = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
            target.Position = clampPosition(newPos)
        end
    end)
end

function FE4R:CreateWindow(cfg)
    cfg = cfg or {}
    local Window = {}
    Window.Tabs = {}
    Window.ActiveTab = nil

    local title = cfg.Title or "FE4R Scripts"
    local subtitle = cfg.Subtitle or "created by Fe4r"
    local logoId = cfg.Logo or CFG.LogoAssetId

    local old = GuiParent():FindFirstChild("FE4R_UI")
    if old then old:Destroy() end

    local ScreenGui = New("ScreenGui", {
        Name = "FE4R_UI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 9999,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = GuiParent(),
    })
    Window.Gui = ScreenGui

    local Main = New("Frame", {
        Name = "Main",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(CFG.WindowSize.X, CFG.WindowSize.Y),
        BackgroundColor3 = Theme.Window,
        BackgroundTransparency = Theme.WindowAlpha,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = ScreenGui,
    }, { Corner(CFG.Corner + 2), Stroke() })
    Window.Main = Main

    local scale = New("UIScale", { Parent = Main })
    local function fitScreen()
        local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
        local s = math.min(vp.X / (CFG.WindowSize.X + 60), vp.Y / (CFG.WindowSize.Y + 60), 1)
        scale.Scale = math.max(s, 0.55)
    end
    fitScreen()
    if workspace.CurrentCamera then
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fitScreen)
    end

    local Topbar = New("Frame", {
        Name = "Topbar",
        Size = UDim2.new(1, 0, 0, CFG.TopbarHeight),
        BackgroundTransparency = 1,
        Parent = Main,
    }, { Padding(nil, CFG.Pad + 2, CFG.Pad, 0, 0) })

    New("TextLabel", {
        Name = "Title",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, -7),
        Size = UDim2.new(0, 260, 0, 18),
        BackgroundTransparency = 1,
        Font = Theme.FontBold,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 17,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Topbar,
    })

    New("TextLabel", {
        Name = "Subtitle",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 9),
        Size = UDim2.new(0, 260, 0, 14),
        BackgroundTransparency = 1,
        Font = Theme.FontLight,
        Text = subtitle,
        TextColor3 = Theme.TextDim,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Topbar,
    })

    local Controls = New("Frame", {
        Name = "Controls",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(28, 28),
        BackgroundTransparency = 1,
        Parent = Topbar,
    }, {
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
    })

    local function CtrlButton(text, order, callback)
        local b = New("TextButton", {
            Size = UDim2.fromOffset(28, 28),
            BackgroundColor3 = Theme.Element,
            BackgroundTransparency = 0.45,
            Font = Theme.Font,
            Text = text,
            TextColor3 = Theme.TextDim,
            TextSize = 15,
            AutoButtonColor = false,
            LayoutOrder = order,
            Parent = Controls,
        }, { Corner(7) })
        b.MouseEnter:Connect(function()
            Tween(b, 0.15, { BackgroundTransparency = 0.15, TextColor3 = Theme.Text })
        end)
        b.MouseLeave:Connect(function()
            Tween(b, 0.15, { BackgroundTransparency = 0.45, TextColor3 = Theme.TextDim })
        end)
        b.MouseButton1Click:Connect(callback)
        return b
    end

    local Body = New("Frame", {
        Name = "Body",
        Position = UDim2.new(0, 0, 0, CFG.TopbarHeight),
        Size = UDim2.new(1, 0, 1, -CFG.TopbarHeight),
        BackgroundTransparency = 1,
        Parent = Main,
    })

    New("Frame", {
        Name = "Divider",
        Position = UDim2.new(0, CFG.SidebarWidth, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        BackgroundColor3 = Theme.Stroke,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = Body,
    })

    local Sidebar = New("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, CFG.SidebarWidth, 1, 0),
        BackgroundColor3 = Theme.Sidebar,
        BackgroundTransparency = Theme.SidebarAlpha,
        BorderSizePixel = 0,
        Parent = Body,
    }, { Corner(CFG.Corner + 2), Padding(CFG.Pad) })

    New("UIListLayout", {
        Padding = UDim.new(0, 12),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = Sidebar,
    })

    New("ImageLabel", {
        Name = "Logo",
        Size = UDim2.new(1, 0, 0, CFG.LogoHeight),
        BackgroundTransparency = 1,
        Image = logoId,
        ScaleType = Enum.ScaleType.Fit,
        LayoutOrder = 1,
        Parent = Sidebar,
    })

    local Profile = New("Frame", {
        Name = "Profile",
        Size = UDim2.new(1, 0, 0, 56),
        BackgroundColor3 = Theme.Card,
        BackgroundTransparency = Theme.CardAlpha,
        BorderSizePixel = 0,
        LayoutOrder = 2,
        Parent = Sidebar,
    }, { Corner(9), Stroke(), Padding(nil, 9, 9, 0, 0) })

    local Avatar = New("ImageLabel", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.fromOffset(38, 38),
        BackgroundColor3 = Theme.Element,
        BackgroundTransparency = 0.2,
        Parent = Profile,
    }, { Corner(19) })

    task.spawn(function()
        local ok, url = pcall(function()
            return Players:GetUserThumbnailAsync(
                LocalPlayer.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size100x100
            )
        end)
        if ok and url then Avatar.Image = url end
    end)

    New("TextLabel", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 48, 0.5, -9),
        Size = UDim2.new(1, -56, 0, 14),
        BackgroundTransparency = 1,
        Font = Theme.FontLight,
        Text = "Welcome",
        TextColor3 = Theme.TextDim,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Profile,
    })

    New("TextLabel", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 48, 0.5, 8),
        Size = UDim2.new(1, -56, 0, 16),
        BackgroundTransparency = 1,
        Font = Theme.Font,
        Text = LocalPlayer.DisplayName,
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = Profile,
    })

    local SearchHolder = New("Frame", {
        Name = "Search",
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Theme.Element,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        LayoutOrder = 3,
        Parent = Sidebar,
    }, { Corner(8), Stroke() })

    New("TextLabel", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 10, 0.5, 0),
        Size = UDim2.fromOffset(16, 16),
        BackgroundTransparency = 1,
        Font = Theme.Font,
        Text = "\u{1F50D}",
        TextColor3 = Theme.TextDim,
        TextSize = 12,
        Parent = SearchHolder,
    })

    local SearchBox = New("TextBox", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 30, 0.5, 0),
        Size = UDim2.new(1, -38, 1, 0),
        BackgroundTransparency = 1,
        Font = Theme.Font,
        PlaceholderText = "Search...",
        PlaceholderColor3 = Theme.TextDim,
        Text = "",
        TextColor3 = Theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = SearchHolder,
    })

    local TabList = New("ScrollingFrame", {
        Name = "TabList",
        Size = UDim2.new(1, 0, 1, -(CFG.LogoHeight + 56 + 34 + 12 * 3)),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Stroke,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        LayoutOrder = 4,
        Parent = Sidebar,
    }, { ListLayout(4) })

    local Content = New("Frame", {
        Name = "Content",
        Position = UDim2.new(0, CFG.SidebarWidth, 0, 0),
        Size = UDim2.new(1, -CFG.SidebarWidth, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = Body,
    }, { Padding(nil, CFG.Pad + 4, CFG.Pad + 4, CFG.Pad, CFG.Pad) })

    local PageTitle = New("TextLabel", {
        Name = "PageTitle",
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundTransparency = 1,
        Font = Theme.FontBold,
        Text = "",
        TextColor3 = Theme.Text,
        TextSize = 26,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Content,
    })

    local Pages = New("Frame", {
        Name = "Pages",
        Position = UDim2.new(0, 0, 0, 44),
        Size = UDim2.new(1, 0, 1, -44),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = Content,
    })

    local ToggleBtn
    CtrlButton("\u{00D7}", 1, function()
        Main.Visible = false
    end)

    MakeDraggable(Topbar, Main)

    ToggleBtn = New("TextButton", {
        Name = "ToggleBtn",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 14, 0.5, 0),
        Size = UDim2.fromOffset(46, 46),
        BackgroundColor3 = Theme.Window,
        BackgroundTransparency = 0.12,
        Text = "",
        AutoButtonColor = false,
        Visible = true,
        Parent = ScreenGui,
    }, { Corner(12), Stroke() })

    New("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(0.7, 0.7),
        BackgroundTransparency = 1,
        Image = CFG.ToggleIconAssetId,
        ScaleType = Enum.ScaleType.Fit,
        Parent = ToggleBtn,
    })

    ToggleBtn.MouseButton1Click:Connect(function()
        Main.Visible = not Main.Visible
    end)
    MakeDraggable(ToggleBtn, ToggleBtn)

    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == (cfg.ToggleKey or Enum.KeyCode.RightShift) then
            Main.Visible = not Main.Visible
        end
    end)

    function Window:CreateTab(name, icon)
        local Tab = {}
        Tab.Name = name
        Tab.Elements = {}

        local Button = New("TextButton", {
            Name = name,
            Size = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = Theme.Element,
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            Parent = TabList,
        }, { Corner(8) })

        local Indicator = New("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.fromOffset(3, 0),
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0,
            Parent = Button,
        }, { Corner(2) })

        if icon then
            New("ImageLabel", {
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 12, 0.5, 0),
                Size = UDim2.fromOffset(17, 17),
                BackgroundTransparency = 1,
                Image = icon,
                ImageColor3 = Theme.TextDim,
                Name = "Icon",
                Parent = Button,
            })
        end

        local BtnLabel = New("TextLabel", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, icon and 38 or 14, 0.5, 0),
            Size = UDim2.new(1, -(icon and 46 or 22), 1, 0),
            BackgroundTransparency = 1,
            Font = Theme.Font,
            Text = name,
            TextColor3 = Theme.TextDim,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = Button,
        })

        local Page = New("ScrollingFrame", {
            Name = name .. "_Page",
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Stroke,
            CanvasSize = UDim2.new(),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = Pages,
        }, { ListLayout(10), Padding(nil, 0, 6, 0, 10) })

        Tab.Button = Button
        Tab.Page = Page

        function Tab:Select()
            for _, t in ipairs(Window.Tabs) do
                t.Page.Visible = false
                Tween(t.Button, 0.15, { BackgroundTransparency = 1 })
                Tween(t.Button:FindFirstChildOfClass("TextLabel"), 0.15, { TextColor3 = Theme.TextDim })
                local ic = t.Button:FindFirstChild("Icon")
                if ic then Tween(ic, 0.15, { ImageColor3 = Theme.TextDim }) end
                Tween(t.Button:FindFirstChildOfClass("Frame"), 0.18, { Size = UDim2.fromOffset(3, 0) })
            end
            Page.Visible = true
            PageTitle.Text = name
            Window.ActiveTab = Tab
            Tween(Button, 0.15, { BackgroundTransparency = 0.55 })
            Tween(BtnLabel, 0.15, { TextColor3 = Theme.Text })
            local ic = Button:FindFirstChild("Icon")
            if ic then Tween(ic, 0.15, { ImageColor3 = Theme.Text }) end
            Tween(Indicator, 0.18, { Size = UDim2.fromOffset(3, 18) })
        end

        Button.MouseButton1Click:Connect(function() Tab:Select() end)
        Button.MouseEnter:Connect(function()
            if Window.ActiveTab ~= Tab then Tween(Button, 0.15, { BackgroundTransparency = 0.75 }) end
        end)
        Button.MouseLeave:Connect(function()
            if Window.ActiveTab ~= Tab then Tween(Button, 0.15, { BackgroundTransparency = 1 }) end
        end)

        local function BaseRow(elName, height)
            local h = height or CFG.RowHeight
            local border = New("Frame", {
                Name = elName .. "_Border",
                Size = UDim2.new(1, 0, 0, h),
                BackgroundColor3 = Theme.Stroke,
                BackgroundTransparency = 0.4,
                BorderSizePixel = 0,
                Parent = Page,
            }, { Corner(12) })
            local row = New("Frame", {
                Name = elName,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.new(1, -2, 1, -2),
                BackgroundColor3 = Theme.Element,
                BackgroundTransparency = Theme.ElementAlpha + 0.05,
                BorderSizePixel = 0,
                ClipsDescendants = true,
                Parent = border,
            }, { Corner(11), Padding(nil, 14, 14, 0, 0) })
            table.insert(Tab.Elements, { Name = elName, Frame = border })
            return row
        end

        local function RowLabel(parent, text, dim)
            return New("TextLabel", {
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 0, 0.5, 0),
                Size = UDim2.new(1, -80, 1, 0),
                BackgroundTransparency = 1,
                Font = Theme.Font,
                Text = text,
                TextColor3 = dim and Theme.TextDim or Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = parent,
            })
        end

        function Tab:AddSection(text)
            local sec = New("Frame", {
                Name = "Section_" .. text,
                Size = UDim2.new(1, 0, 0, 34),
                BackgroundTransparency = 1,
                ClipsDescendants = false,
                Parent = Page,
            })
            New("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 2, 0.5, 1),
                Size = UDim2.fromOffset(3, 18),
                BackgroundColor3 = Theme.Accent,
                BackgroundTransparency = 0.2,
                BorderSizePixel = 0,
                Parent = sec,
            }, { Corner(2) })
            New("TextLabel", {
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 13, 0.5, 1),
                Size = UDim2.new(1, -13, 0, 20),
                BackgroundTransparency = 1,
                Font = Theme.FontBold,
                Text = string.upper(text),
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = sec,
            })
            table.insert(Tab.Elements, { Name = text, Frame = sec })
            return sec
        end

        function Tab:AddLabel(text)
            local row = BaseRow(text, 40)
            local lbl = RowLabel(row, text, true)
            lbl.Size = UDim2.new(1, 0, 1, 0)
            return {
                Set = function(_, newText) lbl.Text = newText end
            }
        end

        function Tab:AddButton(o)
            o = o or {}
            local row = BaseRow(o.Name or "Button")
            RowLabel(row, o.Name or "Button")

            local btn = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, 0, 0.5, 0),
                Size = UDim2.fromOffset(76, 28),
                BackgroundColor3 = Theme.Accent,
                BackgroundTransparency = 0.08,
                Font = Theme.Font,
                Text = o.ButtonText or "Run",
                TextColor3 = Color3.fromRGB(12, 14, 18),
                TextSize = 12,
                AutoButtonColor = false,
                Parent = row,
            }, { Corner(7) })

            btn.MouseEnter:Connect(function() Tween(btn, 0.15, { BackgroundTransparency = 0 }) end)
            btn.MouseLeave:Connect(function() Tween(btn, 0.15, { BackgroundTransparency = 0.08 }) end)
            btn.MouseButton1Click:Connect(function()
                if o.Callback then task.spawn(o.Callback) end
            end)
            return row
        end

        function Tab:AddToggle(o)
            o = o or {}
            local state = o.Default or false
            local row = BaseRow(o.Name or "Toggle")
            RowLabel(row, o.Name or "Toggle")

            local track = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, 0, 0.5, 0),
                Size = UDim2.fromOffset(46, 24),
                BackgroundColor3 = state and Theme.Accent or Theme.ToggleOff,
                BackgroundTransparency = 0,
                Text = "",
                AutoButtonColor = false,
                Parent = row,
            }, { Corner(12) })

            local knob = New("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                Position = state and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                Size = UDim2.fromOffset(20, 20),
                BackgroundColor3 = state and Color3.fromRGB(16, 18, 22) or Color3.fromRGB(120, 128, 140),
                BorderSizePixel = 0,
                Parent = track,
            }, { Corner(10) })

            local api = {}
            function api:Set(v, silent)
                state = v and true or false
                Tween(track, 0.16, { BackgroundColor3 = state and Theme.Accent or Theme.ToggleOff })
                Tween(knob, 0.16, {
                    Position = state and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                    BackgroundColor3 = state and Color3.fromRGB(16, 18, 22) or Color3.fromRGB(120, 128, 140),
                })
                if o.Flag then FE4R.Flags[o.Flag] = state end
                if not silent and o.Callback then task.spawn(o.Callback, state) end
            end
            function api:Get() return state end

            track.MouseButton1Click:Connect(function() api:Set(not state) end)
            if o.Flag then FE4R.Flags[o.Flag] = state end
            if state and o.Callback then task.spawn(o.Callback, true) end
            return api
        end

        function Tab:AddSlider(o)
            o = o or {}
            local min, max = o.Min or 0, o.Max or 100
            local value = math.clamp(o.Default or min, min, max)
            local decimals = o.Decimals or 0
            local row = BaseRow(o.Name or "Slider", 58)

            local lbl = RowLabel(row, o.Name or "Slider")
            lbl.Position = UDim2.new(0, 0, 0, 10)
            lbl.Size = UDim2.new(1, -60, 0, 16)
            lbl.AnchorPoint = Vector2.new(0, 0)

            local valLbl = New("TextLabel", {
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, 0, 0, 10),
                Size = UDim2.fromOffset(56, 16),
                BackgroundTransparency = 1,
                Font = Theme.Font,
                Text = tostring(value),
                TextColor3 = Theme.TextDim,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = row,
            })

            local bar = New("Frame", {
                AnchorPoint = Vector2.new(0, 1),
                Position = UDim2.new(0, 0, 1, -14),
                Size = UDim2.new(1, 0, 0, 6),
                BackgroundColor3 = Theme.ToggleOff,
                BorderSizePixel = 0,
                Parent = row,
            }, { Corner(3) })

            local fill = New("Frame", {
                Size = UDim2.fromScale((value - min) / (max - min), 1),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0,
                Parent = bar,
            }, { Corner(3) })

            local function round(n)
                local m = 10 ^ decimals
                return math.floor(n * m + 0.5) / m
            end

            local api = {}
            function api:Set(v, silent)
                value = math.clamp(round(v), min, max)
                Tween(fill, 0.08, { Size = UDim2.fromScale((value - min) / (max - min), 1) })
                valLbl.Text = tostring(value)
                if o.Flag then FE4R.Flags[o.Flag] = value end
                if not silent and o.Callback then task.spawn(o.Callback, value) end
            end
            function api:Get() return value end

            local dragging = false
            local function update(input)
                local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                api:Set(min + (max - min) * rel)
            end
            bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    update(input)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                              or input.UserInputType == Enum.UserInputType.Touch) then
                    update(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            if o.Flag then FE4R.Flags[o.Flag] = value end
            return api
        end

        function Tab:AddDropdown(o)
            o = o or {}
            local options = o.Options or {}
            local selected = o.Default or options[1] or "..."
            local open = false

            local row = BaseRow(o.Name or "Dropdown")
            row.ClipsDescendants = true
            RowLabel(row, o.Name or "Dropdown")

            local box = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, 0, 0, 10),
                Size = UDim2.fromOffset(150, 24),
                BackgroundColor3 = Theme.Card,
                BackgroundTransparency = 0.1,
                Text = "",
                AutoButtonColor = false,
                Parent = row,
            }, { Corner(6), Stroke() })

            local boxLbl = New("TextLabel", {
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 9, 0.5, 0),
                Size = UDim2.new(1, -28, 1, 0),
                BackgroundTransparency = 1,
                Font = Theme.Font,
                Text = tostring(selected),
                TextColor3 = Theme.Text,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = box,
            })

            local arrow = New("TextLabel", {
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -8, 0.5, 0),
                Size = UDim2.fromOffset(12, 12),
                BackgroundTransparency = 1,
                Font = Theme.Font,
                Text = "\u{25BE}",
                TextColor3 = Theme.TextDim,
                TextSize = 11,
                Parent = box,
            })

            local listHolder = New("Frame", {
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, 0, 0, 40),
                Size = UDim2.new(0, 150, 0, 0),
                BackgroundTransparency = 1,
                Parent = row,
            }, { ListLayout(3) })

            local api = {}
            function api:Set(v, silent)
                selected = v
                boxLbl.Text = tostring(v)
                if o.Flag then FE4R.Flags[o.Flag] = v end
                if not silent and o.Callback then task.spawn(o.Callback, v) end
            end
            function api:Get() return selected end

            local function rebuild()
                for _, c in ipairs(listHolder:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                for i, opt in ipairs(options) do
                    local ob = New("TextButton", {
                        Size = UDim2.new(1, 0, 0, 26),
                        BackgroundColor3 = Theme.Card,
                        BackgroundTransparency = 0.15,
                        Font = Theme.Font,
                        Text = "  " .. tostring(opt),
                        TextColor3 = Theme.TextDim,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        AutoButtonColor = false,
                        LayoutOrder = i,
                        Parent = listHolder,
                    }, { Corner(6) })
                    ob.MouseEnter:Connect(function() Tween(ob, 0.12, { TextColor3 = Theme.Text, BackgroundTransparency = 0 }) end)
                    ob.MouseLeave:Connect(function() Tween(ob, 0.12, { TextColor3 = Theme.TextDim, BackgroundTransparency = 0.15 }) end)
                    ob.MouseButton1Click:Connect(function()
                        api:Set(opt)
                        open = false
                        Tween(row.Parent, 0.18, { Size = UDim2.new(1, 0, 0, CFG.RowHeight) })
                        Tween(arrow, 0.18, { Rotation = 0 })
                    end)
                end
            end
            rebuild()

            function api:SetOptions(newOptions)
                options = newOptions or {}
                rebuild()
            end

            box.MouseButton1Click:Connect(function()
                open = not open
                local h = CFG.RowHeight + (open and (#options * 29 + 8) or 0)
                Tween(row.Parent, 0.18, { Size = UDim2.new(1, 0, 0, h) })
                Tween(arrow, 0.18, { Rotation = open and 180 or 0 })
            end)

            if o.Flag then FE4R.Flags[o.Flag] = selected end
            return api
        end

        function Tab:AddTextbox(o)
            o = o or {}
            local row = BaseRow(o.Name or "Textbox")
            RowLabel(row, o.Name or "Textbox")

            local holder = New("Frame", {
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, 0, 0.5, 0),
                Size = UDim2.fromOffset(150, 26),
                BackgroundColor3 = Theme.Card,
                BackgroundTransparency = 0.1,
                Parent = row,
            }, { Corner(6), Stroke() })

            local tb = New("TextBox", {
                Size = UDim2.new(1, -16, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Font = Theme.Font,
                PlaceholderText = o.Placeholder or "...",
                PlaceholderColor3 = Theme.TextDim,
                Text = o.Default or "",
                TextColor3 = Theme.Text,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
                Parent = holder,
            })

            tb.FocusLost:Connect(function(enter)
                if o.Flag then FE4R.Flags[o.Flag] = tb.Text end
                if o.Callback then task.spawn(o.Callback, tb.Text, enter) end
            end)

            return {
                Set = function(_, v) tb.Text = v end,
                Get = function() return tb.Text end,
            }
        end

        table.insert(Window.Tabs, Tab)
        if #Window.Tabs == 1 then Tab:Select() end
        return Tab
    end

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q = string.lower(SearchBox.Text)
        local tab = Window.ActiveTab
        if not tab then return end
        for _, el in ipairs(tab.Elements) do
            if q == "" then
                el.Frame.Visible = true
            else
                el.Frame.Visible = string.find(string.lower(el.Name), q, 1, true) ~= nil
            end
        end
    end)

    local NotifHolder = New("Frame", {
        Name = "Notifications",
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -16, 1, -16),
        Size = UDim2.fromOffset(270, 400),
        BackgroundTransparency = 1,
        Parent = ScreenGui,
    }, {
        New("UIListLayout", {
            Padding = UDim.new(0, 8),
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
    })

    function Window:Notify(o)
        o = o or {}
        local card = New("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Theme.Window,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = NotifHolder,
        }, { Corner(9), Stroke(), Padding(12) })

        local t = New("TextLabel", {
            Size = UDim2.new(1, 0, 0, 16),
            BackgroundTransparency = 1,
            Font = Theme.FontBold,
            Text = o.Title or "Notification",
            TextColor3 = Theme.Text,
            TextSize = 13,
            TextTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = card,
        })

        local d = New("TextLabel", {
            Position = UDim2.new(0, 0, 0, 20),
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Font = Theme.FontLight,
            Text = o.Text or "",
            TextColor3 = Theme.TextDim,
            TextSize = 12,
            TextTransparency = 1,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = card,
        })

        Tween(card, 0.22, { BackgroundTransparency = 0.08 })
        Tween(t, 0.22, { TextTransparency = 0 })
        Tween(d, 0.22, { TextTransparency = 0 })

        task.delay(o.Duration or 4, function()
            Tween(card, 0.25, { BackgroundTransparency = 1 })
            Tween(t, 0.25, { TextTransparency = 1 })
            Tween(d, 0.25, { TextTransparency = 1 })
            task.delay(0.3, function() card:Destroy() end)
        end)
    end

    function Window:Destroy()
        ScreenGui:Destroy()
    end

    function Window:SetTitle(newTitle)
        Topbar.Title.Text = newTitle
    end

    return Window
end

return FE4R
