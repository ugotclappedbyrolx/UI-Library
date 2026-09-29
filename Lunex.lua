local UserInputService = game:GetService("UserInputService")
local TweenService    = game:GetService("TweenService")
local RunService      = game:GetService("RunService")
local TextService     = game:GetService("TextService")
local HttpService     = game:GetService("HttpService")
local Players         = game:GetService("Players")
local LocalPlayer     = Players.LocalPlayer

local Library = {}
Library.Folder = "Lunex.lol"  -- users can change this
Library.Theme         = {}
Library.Presets       = {}
Library.Toggled       = true
Library.ToggleKey     = Enum.KeyCode.Insert
Library.Flags         = {}
Library.Controls      = {}
Library.Defaults      = {}
Library.UIExpansion   = false

Library.ThemeRegistry  = {}
Library.ThemeCallbacks = {}
Library.ThemePickers   = {}

local function get_configs_path()
    return Library.Folder .. "/Configs"
end

local function get_themes_path()
    return Library.Folder .. "/Themes"
end

local function ensure_folders()
    if makefolder and isfolder and not isfolder(Library.Folder) then
        pcall(makefolder, Library.Folder)
    end
    if makefolder and isfolder and not isfolder(get_configs_path()) then
        pcall(makefolder, get_configs_path())
    end
    if makefolder and isfolder and not isfolder(get_themes_path()) then
        pcall(makefolder, get_themes_path())
    end
end

local function deep_copy(t)
    local r = {}
    for k, v in pairs(t) do
        if type(v) == "table" then r[k] = deep_copy(v) else r[k] = v end
    end
    return r
end

local function get_gui_parent()
    local ok, hui = pcall(gethui)
    if ok and hui then return hui end
    local ok2, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok2 and cg then return cg end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local PRESET_THEMES = {
    Default = {
        Accent        = Color3.fromRGB(200, 68, 240),
        AccentDark    = Color3.fromRGB(160, 45, 200),
        TextActive    = Color3.fromRGB(255, 255, 255),
        TextInactive  = Color3.fromRGB(136, 136, 136),
        OuterBorder   = Color3.fromRGB(31, 31, 31),
        InnerBorder   = Color3.fromRGB(31, 31, 31),
        PanelFill     = Color3.fromRGB(0, 0, 0),
        ContentOuter  = Color3.fromRGB(31, 31, 31),
        ContentInner  = Color3.fromRGB(0, 0, 0),
        ContentFill   = Color3.fromRGB(0, 0, 0),
        ChildFill     = Color3.fromRGB(0, 0, 0),
        ComboInner    = Color3.fromRGB(20, 20, 20),
        ComboFill     = Color3.fromRGB(0, 0, 0),
        ComboSelected = Color3.fromRGB(200, 68, 240),
        HeaderTop     = Color3.fromRGB(18, 18, 18),
        HeaderBottom  = Color3.fromRGB(0, 0, 0),
        TabTop        = Color3.fromRGB(31, 31, 31),
        TabMid        = Color3.fromRGB(15, 15, 15),
        TabBottom     = Color3.fromRGB(0, 0, 0),
        TabInactive   = Color3.fromRGB(128, 128, 128),
        TabHover      = Color3.fromRGB(208, 208, 208),
    },
    ["Tokyo Night"] = {
        Accent        = Color3.fromRGB(187, 154, 247),
        AccentDark    = Color3.fromRGB(138, 99,  210),
        TextActive    = Color3.fromRGB(192, 202, 245),
        TextInactive  = Color3.fromRGB(86,  95,  137),
        OuterBorder   = Color3.fromRGB(10,  10,  18),
        InnerBorder   = Color3.fromRGB(36,  40,  59),
        PanelFill     = Color3.fromRGB(26,  27,  38),
        ContentOuter  = Color3.fromRGB(36,  40,  59),
        ContentInner  = Color3.fromRGB(15,  15,  24),
        ContentFill   = Color3.fromRGB(22,  22,  30),
        ChildFill     = Color3.fromRGB(18,  18,  26),
        ComboInner    = Color3.fromRGB(30,  32,  48),
        ComboFill     = Color3.fromRGB(24,  25,  38),
        ComboSelected = Color3.fromRGB(187, 154, 247),
        HeaderTop     = Color3.fromRGB(30,  32,  48),
        HeaderBottom  = Color3.fromRGB(22,  22,  30),
        TabTop        = Color3.fromRGB(40,  44,  66),
        TabMid        = Color3.fromRGB(30,  32,  48),
        TabBottom     = Color3.fromRGB(22,  22,  30),
        TabInactive   = Color3.fromRGB(100, 110, 150),
        TabHover      = Color3.fromRGB(160, 175, 220),
    },
    Crimson = {
        Accent        = Color3.fromRGB(255, 75,  75),
        AccentDark    = Color3.fromRGB(180, 40,  40),
        TextActive    = Color3.fromRGB(255, 240, 240),
        TextInactive  = Color3.fromRGB(140, 100, 100),
        OuterBorder   = Color3.fromRGB(10,  0,   0),
        InnerBorder   = Color3.fromRGB(40,  20,  20),
        PanelFill     = Color3.fromRGB(20,  12,  12),
        ContentOuter  = Color3.fromRGB(40,  20,  20),
        ContentInner  = Color3.fromRGB(10,  0,   0),
        ContentFill   = Color3.fromRGB(24,  15,  15),
        ChildFill     = Color3.fromRGB(16,  10,  10),
        ComboInner    = Color3.fromRGB(30,  18,  18),
        ComboFill     = Color3.fromRGB(22,  14,  14),
        ComboSelected = Color3.fromRGB(255, 75,  75),
        HeaderTop     = Color3.fromRGB(32,  18,  18),
        HeaderBottom  = Color3.fromRGB(18,  10,  10),
        TabTop        = Color3.fromRGB(42,  22,  22),
        TabMid        = Color3.fromRGB(30,  16,  16),
        TabBottom     = Color3.fromRGB(20,  12,  12),
        TabInactive   = Color3.fromRGB(130, 90,  90),
        TabHover      = Color3.fromRGB(200, 130, 130),
    },
    Emerald = {
        Accent        = Color3.fromRGB(80,  250, 123),
        AccentDark    = Color3.fromRGB(40,  180, 80),
        TextActive    = Color3.fromRGB(240, 255, 240),
        TextInactive  = Color3.fromRGB(100, 130, 110),
        OuterBorder   = Color3.fromRGB(0,   10,  0),
        InnerBorder   = Color3.fromRGB(20,  40,  25),
        PanelFill     = Color3.fromRGB(12,  20,  14),
        ContentOuter  = Color3.fromRGB(20,  40,  25),
        ContentInner  = Color3.fromRGB(0,   10,  0),
        ContentFill   = Color3.fromRGB(15,  24,  17),
        ChildFill     = Color3.fromRGB(10,  16,  12),
        ComboInner    = Color3.fromRGB(18,  30,  20),
        ComboFill     = Color3.fromRGB(14,  22,  16),
        ComboSelected = Color3.fromRGB(80,  250, 123),
        HeaderTop     = Color3.fromRGB(18,  32,  20),
        HeaderBottom  = Color3.fromRGB(10,  18,  12),
        TabTop        = Color3.fromRGB(22,  42,  26),
        TabMid        = Color3.fromRGB(16,  30,  20),
        TabBottom     = Color3.fromRGB(12,  20,  14),
        TabInactive   = Color3.fromRGB(90,  130, 100),
        TabHover      = Color3.fromRGB(130, 200, 150),
    }
}

local FONT      = Enum.Font.SourceSans
local FONT_BOLD = Enum.Font.SourceSansBold
local FONT_SIZE = 13
local STROKE_T  = 0.55

Library.Theme = deep_copy(PRESET_THEMES.Default)
Library.Presets = PRESET_THEMES

function Library:RegisterTheme(inst, prop, key)
    if not inst then return end
    table.insert(self.ThemeRegistry, {Inst = inst, Prop = prop, Key = key})
    if self.Theme and self.Theme[key] then
        inst[prop] = self.Theme[key]
    end
end

function Library:RegisterThemeCallback(fn)
    table.insert(self.ThemeCallbacks, fn)
    pcall(fn)
end

function Library:RefreshTheme()
    local registry = self.ThemeRegistry
    for i = #registry, 1, -1 do
        local item = registry[i]
        if item.Inst and item.Inst.Parent then
            if self.Theme[item.Key] then
                item.Inst[item.Prop] = self.Theme[item.Key]
            end
        else
            table.remove(registry, i)
        end
    end
    for _, cb in ipairs(self.ThemeCallbacks) do
        pcall(cb)
    end
    for _, ctrl in pairs(self.ThemePickers) do
        if ctrl and ctrl.Set and self.Theme[ctrl._key] then
            ctrl:Set(self.Theme[ctrl._key], false)
        end
    end
end

local function new_instance(class, props, parent)
    local obj = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            if k ~= "Parent" then obj[k] = v end
        end
    end
    if parent then obj.Parent = parent end
    return obj
end

local function apply_font(label, bold)
    label.Font = bold and FONT_BOLD or FONT
end

local function make_label(parent, text, color_key_or_color, props)
    local bold = props and props.Bold
    local color = type(color_key_or_color) == "string" and Library.Theme[color_key_or_color] or color_key_or_color
    local label = new_instance("TextLabel", {
        BackgroundTransparency = 1,
        Text                   = text or "",
        TextColor3             = color or Library.Theme.TextActive,
        TextSize               = FONT_SIZE,
        TextXAlignment         = Enum.TextXAlignment.Left,
        TextYAlignment         = Enum.TextYAlignment.Center,
        TextStrokeColor3       = Library.Theme.OuterBorder,
        TextStrokeTransparency = STROKE_T,
        TextTruncate           = Enum.TextTruncate.AtEnd,
        RichText               = false,
        ZIndex                 = 5,
    }, parent)
    apply_font(label, bold)

    if type(color_key_or_color) == "string" then
        Library:RegisterTheme(label, "TextColor3", color_key_or_color)
    end
    Library:RegisterTheme(label, "TextStrokeColor3", "OuterBorder")

    if props then
        for k, v in pairs(props) do
            if k ~= "Bold" then label[k] = v end
        end
    end
    return label
end

local function framed_box(parent, outer_key, inner_key, fill_key, props)
    local outer_color = type(outer_key) == "string" and Library.Theme[outer_key] or outer_key
    local inner_color = type(inner_key) == "string" and Library.Theme[inner_key] or inner_key
    local fill_color  = type(fill_key) == "string" and Library.Theme[fill_key] or fill_key

    local outer = new_instance("Frame", {
        BackgroundColor3    = outer_color,
        BorderSizePixel     = 0,
        Size                = UDim2.fromScale(1, 1),
    }, parent)
    if type(outer_key) == "string" then
        Library:RegisterTheme(outer, "BackgroundColor3", outer_key)
    end
    if props then
        for k, v in pairs(props) do outer[k] = v end
    end

    local inner = new_instance("Frame", {
        BackgroundColor3 = inner_color,
        BorderSizePixel  = 0,
        Position         = UDim2.fromOffset(1, 1),
        Size             = UDim2.new(1, -2, 1, -2),
        ZIndex           = outer.ZIndex or 1,
    }, outer)
    if type(inner_key) == "string" then
        Library:RegisterTheme(inner, "BackgroundColor3", inner_key)
    end

    local fill = new_instance("Frame", {
        Name             = "Fill",
        BackgroundColor3 = fill_color,
        BorderSizePixel  = 0,
        Position         = UDim2.fromOffset(2, 2),
        Size             = UDim2.new(1, -4, 1, -4),
        ZIndex           = outer.ZIndex or 1,
    }, outer)
    if type(fill_key) == "string" then
        Library:RegisterTheme(fill, "BackgroundColor3", fill_key)
    end

    return outer, fill
end

local function vertical_gradient(frame, top_key, bottom_key, trans_seq)
    frame.BackgroundColor3 = Color3.new(1, 1, 1)
    local grad = new_instance("UIGradient", {
        Rotation      = 90,
        Transparency  = trans_seq or NumberSequence.new(0),
    }, frame)

    local function update()
        local top = type(top_key) == "string" and Library.Theme[top_key] or top_key
        local bot = type(bottom_key) == "string" and Library.Theme[bottom_key] or bottom_key
        grad.Color = ColorSequence.new(top, bot)
    end
    update()
    Library:RegisterThemeCallback(update)
    return grad
end

local function tween(obj, duration, goal)
    return TweenService:Create(obj, TweenInfo.new(duration or 0.12, Enum.EasingStyle.Quad), goal)
end

local KEY_NAMES = {
    [Enum.UserInputType.MouseButton1] = "LM",
    [Enum.UserInputType.MouseButton2] = "RM",
    [Enum.UserInputType.MouseButton3] = "MM",
    [Enum.KeyCode.LeftShift]  = "Shift", [Enum.KeyCode.RightShift]  = "Shift",
    [Enum.KeyCode.LeftControl]= "Ctrl",  [Enum.KeyCode.RightControl]= "Ctrl",
    [Enum.KeyCode.LeftAlt]    = "Alt",   [Enum.KeyCode.RightAlt]    = "Alt",
    [Enum.KeyCode.Space]      = "Space", [Enum.KeyCode.Return]      = "Enter",
    [Enum.KeyCode.Tab]        = "Tab",   [Enum.KeyCode.Backspace]   = "Back",
    [Enum.KeyCode.CapsLock]   = "Caps",  [Enum.KeyCode.Escape]      = "Esc",
    [Enum.KeyCode.Insert]     = "Insert",[Enum.KeyCode.Delete]      = "Del",
    [Enum.KeyCode.Up]="Up", [Enum.KeyCode.Down]="Down",
    [Enum.KeyCode.Left]="Left", [Enum.KeyCode.Right]="Right",
}
local function key_text(key)
    if key == nil then return "-" end
    if KEY_NAMES[key] then return KEY_NAMES[key] end
    if typeof(key) == "EnumItem" and key.EnumType == Enum.KeyCode then
        return key.Name
    end
    return "?"
end

local screen_gui = new_instance("ScreenGui", {
    Name            = "ui",
    IgnoreGuiInset  = true,
    ResetOnSpawn    = false,
    ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
    DisplayOrder    = 999,
}, get_gui_parent())

local popup_layer = new_instance("Frame", {
    Name = "PopupLayer",
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    ZIndex = 500,
}, screen_gui)

local open_popups = {}

local function close_all_popups()
    local current = open_popups
    open_popups = {}
    for _, fn in ipairs(current) do
        pcall(fn)
    end
end

local MIN_SIZE = Vector2.new(360, 360)
local MAX_SIZE = Vector2.new(800, 800)

local function sync_tab_gap(window)
    local tab = window.ActiveTab
    if not tab then return end
    local panel_w = window.Canvas.Size.X.Offset - 20

    local tab_left = window.TabHost.Position.X.Offset - 10
    local gx = tab_left + (tab.Index - 1) * (window._tab_w + window._tab_sp)
    local tw = window._tab_w

    local function set_seg(frame, x, w)
        frame.Position = UDim2.fromOffset(x, frame.Position.Y.Offset)
        frame.Size = UDim2.fromOffset(math.max(0, w), 1)
    end
    set_seg(window._oT1, 0,           gx)
    set_seg(window._oT2, gx + tw,     panel_w - (gx + tw))
    set_seg(window._iT1, 1,           gx)
    set_seg(window._iT2, gx + tw - 1, panel_w - gx - tw)
end

local function update_tab_positions(window)
    local tabs = window.Tabs
    local count = #tabs
    if count == 0 then return end

    local panel_w = window.Canvas.Size.X.Offset - 20
    local sp = window._tab_sp or 2
    local w = 81

    local gaps = math.max(0, count - 1) * sp
    local total = count * w + gaps

    window._tab_w = w
    window._tabs_total = total

    window.TabHost.Size = UDim2.fromOffset(total, window._tab_h)
    window.TabHost.Position = UDim2.fromOffset(
        10 + math.floor((panel_w - total) / 2),
        40 - window._tab_h
    )

    for i, tab in ipairs(tabs) do
        local x = (i - 1) * (w + sp)
        tab.Button.Position = UDim2.fromOffset(x, 0)
        tab.Button.Size = UDim2.fromOffset(w, window._tab_h)
    end

    sync_tab_gap(window)
end

local function is_click(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch
end

local function is_move(input)
    return input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch
end

local function serialize(val)
    if typeof(val) == "Color3" then
        return {__type = "Color3", r = val.R, g = val.G, b = val.B}
    elseif typeof(val) == "EnumItem" then
        return {__type = "EnumItem", enumType = tostring(val.EnumType), name = val.Name}
    end
    return val
end

local function deserialize(val)
    if type(val) == "table" and val.__type then
        if val.__type == "Color3" then
            return Color3.new(val.r, val.g, val.b)
        elseif val.__type == "EnumItem" then
            local enum_group = Enum[val.enumType]
            if enum_group and enum_group[val.name] then
                return enum_group[val.name]
            end
        end
    end
    return val
end

local function scan_config_files()
    local files = {}
    if not isfolder or not listfiles then return files end
    local path = get_configs_path()
    if not isfolder(path) then return files end
    local ok, all = pcall(listfiles, path)
    if not ok then return files end
    for _, f in ipairs(all) do
        local name = f:match("([^\\/]+)%.json$")
        if name and f:find(path, 1, true) and name ~= "configs_list" then
            table.insert(files, name)
        end
    end
    table.sort(files)
    return files
end

local function scan_theme_files()
    local files = {}
    if not isfolder or not listfiles then return files end
    local path = get_themes_path()
    if not isfolder(path) then return files end
    local ok, all = pcall(listfiles, path)
    if not ok then return files end
    for _, f in ipairs(all) do
        local name = f:match("([^\\/]+)_theme%.json$")
        if name then
            table.insert(files, name)
        end
    end
    table.sort(files)
    return files
end

function Library:SaveConfig(filename)
    if not writefile then return end
    ensure_folders()
    filename = filename or "default"
    local path = get_configs_path() .. "/" .. filename .. ".json"
    local data = {}
    for flag, val in pairs(self.Flags) do
        if type(val) == "table" and not val.__type then
            local tbl = {}
            for k, v in pairs(val) do tbl[k] = serialize(v) end
            data[flag] = tbl
        else
            data[flag] = serialize(val)
        end
    end
    pcall(writefile, path, HttpService:JSONEncode(data))
end

function Library:LoadConfig(filename)
    if not readfile or not isfile then return end
    filename = filename or "default"
    local path = get_configs_path() .. "/" .. filename .. ".json"
    if not isfile(path) then return end
    local ok, content = pcall(readfile, path)
    if not ok then return end
    local ok2, decoded = pcall(function() return HttpService:JSONDecode(content) end)
    if not ok2 or type(decoded) ~= "table" then return end

    for flag, val in pairs(decoded) do
        local final
        if type(val) == "table" and not val.__type then
            final = {}
            for k, v in pairs(val) do final[k] = deserialize(v) end
        else
            final = deserialize(val)
        end
        self.Flags[flag] = final
        if self.Controls[flag] and self.Controls[flag].Set then
            self.Controls[flag]:Set(final, true)
        end
    end
    self:RefreshTheme()
end

function Library:DeleteConfig(filename)
    if not delfile or not isfile then return end
    filename = filename or "default"
    local path = get_configs_path() .. "/" .. filename .. ".json"
    if isfile(path) then
        pcall(delfile, path)
    end
end

function Library:SetAutoLoad(filename)
    if not writefile then return end
    ensure_folders()
    filename = filename or "default"
    pcall(writefile, get_configs_path() .. "/autoload.json", HttpService:JSONEncode({autoload = filename}))
end

function Library:CheckAutoLoad()
    ensure_folders()
    local path = get_configs_path() .. "/autoload.json"
    if not isfile or not readfile or not isfile(path) then return end
    local ok, content = pcall(readfile, path)
    if not ok then return end
    local ok2, decoded = pcall(function() return HttpService:JSONDecode(content) end)
    if ok2 and type(decoded) == "table" and decoded.autoload then
        self:LoadConfig(decoded.autoload)
    end
end

function Library:ResetToDefaults()
    for flag, default_val in pairs(self.Defaults) do
        self.Flags[flag] = deep_copy(default_val)
        if self.Controls[flag] and self.Controls[flag].Set then
            self.Controls[flag]:Set(deep_copy(default_val), true)
        end
    end
end

function Library:SaveTheme(theme_name)
    if not writefile then return end
    ensure_folders()
    theme_name = theme_name or "custom_theme"
    local path = get_themes_path() .. "/" .. theme_name .. "_theme.json"
    local data = {}
    for k, v in pairs(self.Theme) do
        data[k] = serialize(v)
    end
    pcall(writefile, path, HttpService:JSONEncode(data))
end

function Library:LoadTheme(theme_name)
    if not readfile or not isfile then return end
    theme_name = theme_name or "custom_theme"
    local path = get_themes_path() .. "/" .. theme_name .. "_theme.json"
    if not isfile(path) then return end
    local ok, content = pcall(readfile, path)
    if not ok then return end
    local ok2, decoded = pcall(function() return HttpService:JSONDecode(content) end)
    if not ok2 or type(decoded) ~= "table" then return end

    for k, v in pairs(decoded) do
        self.Theme[k] = deserialize(v)
    end
    self:RefreshTheme()
end

function Library:DeleteTheme(theme_name)
    if not delfile or not isfile then return end
    theme_name = theme_name or "custom_theme"
    local path = get_themes_path() .. "/" .. theme_name .. "_theme.json"
    if isfile(path) then
        pcall(delfile, path)
    end
end

function Library:SetPresetTheme(name)
    if PRESET_THEMES[name] then
        for k, v in pairs(PRESET_THEMES[name]) do
            self.Theme[k] = v
        end
        self:RefreshTheme()
    end
end

function Library:ResetThemeToDefault()
    for k, v in pairs(PRESET_THEMES.Default) do
        self.Theme[k] = v
    end
    self:RefreshTheme()
end

local function add_resize_handles(canvas, on_resize, window_ref)
    local T = 8
    local host = new_instance("Frame", {
        Name = "ResizeHost",
        BackgroundTransparency = 1,
        Active = false,
        Position = canvas.Position,
        Size = canvas.Size,
        ZIndex = 60,
    }, canvas.Parent)

    local function sync_host()
        host.Position = canvas.Position
        host.Size = canvas.Size
        host.Visible = canvas.Visible and (Library.UIExpansion == true)
    end
    canvas:GetPropertyChangedSignal("Position"):Connect(sync_host)
    canvas:GetPropertyChangedSignal("Size"):Connect(sync_host)
    canvas:GetPropertyChangedSignal("Visible"):Connect(sync_host)
    Library._UpdateResizeVisibility = sync_host
    sync_host()

    local edges = {
        {n="N",  p=UDim2.new(0,T,0,-T),    s=UDim2.new(1,-T*2,0,T*2), sx= 0, sy=-1},
        {n="S",  p=UDim2.new(0,T,1,-T),    s=UDim2.new(1,-T*2,0,T*2), sx= 0, sy= 1},
        {n="W",  p=UDim2.new(0,-T,0,T),    s=UDim2.new(0,T*2,1,-T*2), sx=-1, sy= 0},
        {n="E",  p=UDim2.new(1,-T,0,T),    s=UDim2.new(0,T*2,1,-T*2), sx= 1, sy= 0},
        {n="NW", p=UDim2.new(0,-T,0,-T),   s=UDim2.fromOffset(T*2,T*2), sx=-1, sy=-1},
        {n="NE", p=UDim2.new(1,-T,0,-T),   s=UDim2.fromOffset(T*2,T*2), sx= 1, sy=-1},
        {n="SW", p=UDim2.new(0,-T,1,-T),   s=UDim2.fromOffset(T*2,T*2), sx=-1, sy= 1},
        {n="SE", p=UDim2.new(1,-T,1,-T),   s=UDim2.fromOffset(T*2,T*2), sx= 1, sy= 1},
    }
    for _, e in ipairs(edges) do
        local handle = new_instance("TextButton", {
            Name = "Resize" .. e.n,
            Text = "",
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            Position = e.p,
            Size = e.s,
            ZIndex = 60,
        }, host)

        local active, start_size, start_pos, start_input = false, nil, nil, nil
        handle.InputBegan:Connect(function(input)
            if is_click(input) and Library.UIExpansion then
                active = true
                start_size = Vector2.new(canvas.Size.X.Offset, canvas.Size.Y.Offset)
                start_pos = canvas.Position
                start_input = Vector2.new(input.Position.X, input.Position.Y)
                close_all_popups()
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if not active or not is_move(input) or not Library.UIExpansion then return end
            local current = Vector2.new(input.Position.X, input.Position.Y)
            local delta = current - start_input

            local min_w = window_ref and window_ref:GetMinWidth() or MIN_SIZE.X
            local w = math.clamp(start_size.X + e.sx * delta.X, min_w, MAX_SIZE.X)
            local h = math.clamp(start_size.Y + e.sy * delta.Y, MIN_SIZE.Y, MAX_SIZE.Y)
            local ox = (e.sx < 0) and (start_size.X - w) or 0
            local oy = (e.sy < 0) and (start_size.Y - h) or 0
            canvas.Size = UDim2.fromOffset(w, h)
            canvas.Position = UDim2.new(
                start_pos.X.Scale, start_pos.X.Offset + ox,
                start_pos.Y.Scale, start_pos.Y.Offset + oy
            )
            if on_resize then on_resize() end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if is_click(input) then active = false end
        end)
    end
end

function Library:Window(options)
    options = options or {}
    local size = options.Size or Vector2.new(480, 450)

    local canvas = new_instance("CanvasGroup", {
        Name              = "Window",
        AnchorPoint       = Vector2.new(0, 0),
        Position          = UDim2.new(0.5, -math.floor(size.X/2), 0.5, -math.floor(size.Y/2)),
        Size              = UDim2.fromOffset(size.X, size.Y),
        BackgroundTransparency = 1,
        GroupTransparency = 0,
        ZIndex            = 10,
    }, screen_gui)

    local w_outer = new_instance("Frame", {
        BackgroundColor3 = Library.Theme.OuterBorder,
        BorderSizePixel  = 0,
        Size             = UDim2.fromScale(1, 1),
        ZIndex           = 1,
    }, canvas)
    Library:RegisterTheme(w_outer, "BackgroundColor3", "OuterBorder")

    local w_inner = new_instance("Frame", {
        BackgroundColor3 = Library.Theme.InnerBorder,
        BorderSizePixel  = 0,
        Position         = UDim2.fromOffset(1, 1),
        Size             = UDim2.new(1, -2, 1, -2),
        ZIndex           = 1,
    }, w_outer)
    Library:RegisterTheme(w_inner, "BackgroundColor3", "InnerBorder")

    local w_fill = new_instance("Frame", {
        BackgroundColor3 = Library.Theme.PanelFill,
        BorderSizePixel  = 0,
        Position         = UDim2.fromOffset(2, 2),
        Size             = UDim2.new(1, -4, 1, -4),
        ZIndex           = 1,
    }, w_outer)
    Library:RegisterTheme(w_fill, "BackgroundColor3", "PanelFill")

    local top_bar = new_instance("Frame", {
        Name = "TopBar",
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel  = 0,
        Position         = UDim2.fromOffset(2, 2),
        Size             = UDim2.new(1, -4, 0, 38),
        ZIndex           = 2,
    }, w_outer)
    vertical_gradient(top_bar, "HeaderTop", "HeaderBottom")

    local title_label = make_label(canvas, "", "TextActive", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 4),
        Size = UDim2.fromOffset(250, 14),
        TextXAlignment = Enum.TextXAlignment.Center,
        RichText = true,
        Bold = true,
        ZIndex = 6,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })

    Library:RegisterThemeCallback(function()
        local accent_hex = string.format("#%02X%02X%02X",
            math.floor(Library.Theme.Accent.R * 255),
            math.floor(Library.Theme.Accent.G * 255),
            math.floor(Library.Theme.Accent.B * 255)
        )
        title_label.Text = string.format('%s<font color="%s">%s</font>',
            options.TitleLeft or "remade by ",
            accent_hex,
            options.TitleRight or "angel"
        )
    end)

    local panel = new_instance("Frame", {
        Name = "Panel",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(10, 40),
        Size = UDim2.new(1, -20, 1, -50),
        ZIndex = 2,
    }, canvas)

    local panel_fill = new_instance("Frame", {
        BackgroundColor3 = Library.Theme.ContentFill,
        BorderSizePixel  = 0,
        Position         = UDim2.fromOffset(2, 2),
        Size             = UDim2.new(1, -4, 1, -4),
        ZIndex           = 2,
    }, panel)
    Library:RegisterTheme(panel_fill, "BackgroundColor3", "ContentFill")

    local left_border  = new_instance("Frame", {BackgroundColor3 = Library.Theme.ContentOuter, BorderSizePixel = 0, Position = UDim2.fromOffset(0, 0), Size = UDim2.fromOffset(1, 1), ZIndex = 2}, panel)
    local right_border = new_instance("Frame", {BackgroundColor3 = Library.Theme.ContentOuter, BorderSizePixel = 0, Position = UDim2.new(1, -1, 0, 0), Size = UDim2.fromOffset(1, 1), ZIndex = 2}, panel)
    local bottom_border= new_instance("Frame", {BackgroundColor3 = Library.Theme.ContentOuter, BorderSizePixel = 0, Position = UDim2.fromOffset(0, 1, 1, -1), Size = UDim2.new(1, 0, 0, 1), ZIndex = 2}, panel)
    local top_border1  = new_instance("Frame", {BackgroundColor3 = Library.Theme.ContentOuter, BorderSizePixel = 0, Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, 0, 0, 1), ZIndex = 2}, panel)
    local top_border2  = new_instance("Frame", {BackgroundColor3 = Library.Theme.ContentOuter, BorderSizePixel = 0, Position = UDim2.fromOffset(0, 0), Size = UDim2.fromOffset(0, 1), ZIndex = 2}, panel)
    Library:RegisterTheme(left_border, "BackgroundColor3", "ContentOuter")
    Library:RegisterTheme(right_border, "BackgroundColor3", "ContentOuter")
    Library:RegisterTheme(bottom_border, "BackgroundColor3", "ContentOuter")
    Library:RegisterTheme(top_border1, "BackgroundColor3", "ContentOuter")
    Library:RegisterTheme(top_border2, "BackgroundColor3", "ContentOuter")

    local inner_left   = new_instance("Frame", {BackgroundColor3 = Library.Theme.ContentInner, BorderSizePixel = 0, Position = UDim2.fromOffset(1, 1), Size = UDim2.new(0, 1, 1, -2), ZIndex = 2}, panel)
    local inner_right  = new_instance("Frame", {BackgroundColor3 = Library.Theme.ContentInner, BorderSizePixel = 0, Position = UDim2.new(1, -2, 0, 1), Size = UDim2.new(0, 1, 1, -2), ZIndex = 2}, panel)
    local inner_bottom = new_instance("Frame", {BackgroundColor3 = Library.Theme.ContentInner, BorderSizePixel = 0, Position = UDim2.fromOffset(0, 1, 1, -2), Size = UDim2.new(1, -2, 0, 1), ZIndex = 2}, panel)
    local inner_top1   = new_instance("Frame", {BackgroundColor3 = Library.Theme.ContentInner, BorderSizePixel = 0, Position = UDim2.fromOffset(1, 1), Size = UDim2.new(1, -2, 0, 1), ZIndex = 2}, panel)
    local inner_top2   = new_instance("Frame", {BackgroundColor3 = Library.Theme.ContentInner, BorderSizePixel = 0, Position = UDim2.fromOffset(1, 1), Size = UDim2.fromOffset(0, 1), ZIndex = 2}, panel)
    Library:RegisterTheme(inner_left, "BackgroundColor3", "ContentInner")
    Library:RegisterTheme(inner_right, "BackgroundColor3", "ContentInner")
    Library:RegisterTheme(inner_bottom, "BackgroundColor3", "ContentInner")
    Library:RegisterTheme(inner_top1, "BackgroundColor3", "ContentInner")
    Library:RegisterTheme(inner_top2, "BackgroundColor3", "ContentInner")

    local TAB_W, TAB_H, TAB_SP = 81, 18, 2
    local tabs_total = TAB_W * 4 + TAB_SP * 3
    local tab_host = new_instance("Frame", {
        Name = "Tabs",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(10 + math.floor(((canvas.Size.X.Offset - 20) - tabs_total) / 2), 40 - TAB_H),
        Size = UDim2.fromOffset(tabs_total, TAB_H),
        ZIndex = 4,
    }, canvas)

    local page_host = new_instance("Frame", {
        Name = "Pages",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(18, 48),
        Size = UDim2.new(1, -36, 1, -66),
        ZIndex = 3,
        ClipsDescendants = true,
    }, canvas)

    local drag_zone = new_instance("TextButton", {
        Name = "DragZone",
        BackgroundTransparency = 1,
        Text = "",
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.fromScale(1, 1),
        ZIndex = 2,
        AutoButtonColor = false,
    }, canvas)

    do
        local dragging, start_pos, start_input = false, nil, nil
        drag_zone.InputBegan:Connect(function(input)
            if is_click(input) then
                dragging = true
                start_pos = canvas.Position
                start_input = Vector2.new(input.Position.X, input.Position.Y)
                close_all_popups()
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and is_move(input) then
                local current = Vector2.new(input.Position.X, input.Position.Y)
                local delta = current - start_input
                canvas.Position = UDim2.new(
                    start_pos.X.Scale, start_pos.X.Offset + delta.X,
                    start_pos.Y.Scale, start_pos.Y.Offset + delta.Y
                )
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if is_click(input) then dragging = false end
        end)
    end

    local window = setmetatable({
        Canvas   = canvas,
        TabHost  = tab_host,
        PageHost = page_host,
        Tabs     = {},
        ActiveTab= nil,
        _tab_w   = TAB_W,
        _tab_h   = TAB_H,
        _tab_sp  = TAB_SP,
        _oT1     = top_border1,
        _oT2     = top_border2,
        _iT1     = inner_top1,
        _iT2     = inner_top2,
        _tabs_total = tabs_total,
    }, {__index = Library._WindowMethods})

    function window:GetMinWidth()
        local panel_padding = 20
        local num = #self.Tabs
        if num == 0 then return MIN_SIZE.X end
        local total_tabs = num * TAB_W + math.max(0, num - 1) * TAB_SP
        return math.max(MIN_SIZE.X, total_tabs + 20)
    end

    add_resize_handles(canvas, function()
        update_tab_positions(window)
    end, window)

    return window
end

Library._WindowMethods = {}

function Library._WindowMethods:Tab(name)
    local win = self
    local idx = #win.Tabs + 1

    local btn = new_instance("TextButton", {
        Name = name,
        Text = "",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.fromOffset(win._tab_w, win._tab_h),
        ZIndex = 4,
    }, win.TabHost)

    local t_outer = new_instance("Frame", {
        BackgroundColor3 = Library.Theme.ContentOuter,
        BorderSizePixel  = 0,
        Position         = UDim2.fromOffset(0, 0),
        Size             = UDim2.new(1, 0, 0, win._tab_h),
        ZIndex           = 4,
    }, btn)
    Library:RegisterTheme(t_outer, "BackgroundColor3", "ContentOuter")

    local t_inner = new_instance("Frame", {
        BackgroundColor3 = Library.Theme.ContentInner,
        BorderSizePixel  = 0,
        Position         = UDim2.fromOffset(1, 1),
        Size             = UDim2.new(1, -2, 0, win._tab_h - 1),
        ZIndex           = 4,
    }, t_outer)
    Library:RegisterTheme(t_inner, "BackgroundColor3", "ContentInner")

    local t_fill = new_instance("Frame", {
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel  = 0,
        Position         = UDim2.fromOffset(2, 2),
        Size             = UDim2.new(1, -4, 0, win._tab_h - 2),
        ZIndex           = 4,
    }, t_outer)

    local grad = new_instance("UIGradient", { Rotation = 90 }, t_fill)
    Library:RegisterThemeCallback(function()
        grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Library.Theme.TabTop),
            ColorSequenceKeypoint.new(0.50, Library.Theme.TabMid),
            ColorSequenceKeypoint.new(1.00, Library.Theme.TabBottom),
        })
    end)

    local label = make_label(btn, name, "TabInactive", {
        Size = UDim2.new(1, 0, 0, win._tab_h),
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 8,
    })

    local page = new_instance("Frame", {
        Name = name,
        BackgroundTransparency = 1,
        Visible = false,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 3,
        ClipsDescendants = false,
    }, win.PageHost)
    new_instance("UIPadding", {
        PaddingLeft   = UDim.new(0, 2),
        PaddingTop    = UDim.new(0, 2),
        PaddingRight  = UDim.new(0, 2),
        PaddingBottom = UDim.new(0, 2),
    }, page)
    new_instance("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding       = UDim.new(0, 6),
        SortOrder     = Enum.SortOrder.LayoutOrder,
    }, page)

    local left_col = new_instance("ScrollingFrame", {
        Name = "LeftCol",
        BackgroundTransparency = 1,
        Size = UDim2.new(0.5, -3, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Library.Theme.Accent,
        LayoutOrder = 1,
        ZIndex = 3,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, page)
    Library:RegisterTheme(left_col, "ScrollBarImageColor3", "Accent")
    new_instance("UIPadding", {
        PaddingRight = UDim.new(0, 4),
    }, left_col)

    new_instance("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding       = UDim.new(0, 6),
        SortOrder     = Enum.SortOrder.LayoutOrder,
    }, left_col)

    local right_col = new_instance("ScrollingFrame", {
        Name = "RightCol",
        BackgroundTransparency = 1,
        Size = UDim2.new(0.5, -3, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Library.Theme.Accent,
        LayoutOrder = 2,
        ZIndex = 3,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, page)
    Library:RegisterTheme(right_col, "ScrollBarImageColor3", "Accent")
    new_instance("UIPadding", {
        PaddingRight = UDim.new(0, 4),
    }, right_col)

    new_instance("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding       = UDim.new(0, 6),
        SortOrder     = Enum.SortOrder.LayoutOrder,
    }, right_col)

    local tab = setmetatable({
        Window   = win,
        Button   = btn,
        Outer    = t_outer,
        Inner    = t_inner,
        Fill     = t_fill,
        Grad     = grad,
        Label    = label,
        Page     = page,
        LeftCol  = left_col,
        RightCol = right_col,
        Index    = idx,
        _groups  = 0,
    }, {__index = Library._TabMethods})
    win.Tabs[#win.Tabs + 1] = tab

    local function select()
        for _, t in ipairs(win.Tabs) do
            local active = (t == tab)
            t.Page.Visible = active
            tween(t.Label, 0.12, { TextColor3 = active and Library.Theme.Accent or Library.Theme.TabInactive }):Play()

            local oh = win._tab_h + (active and 1 or 0)
            local ih = active and (win._tab_h + 1) or (win._tab_h - 1)
            local fh = active and win._tab_h or (win._tab_h - 2)
            t.Outer.Size = UDim2.new(1, 0, 0, oh)
            t.Inner.Size = UDim2.new(1, -2, 0, ih)
            t.Fill.Size  = UDim2.new(1, -4, 0, fh)

            local z = active and 6 or 4
            t.Outer.ZIndex, t.Inner.ZIndex, t.Fill.ZIndex = z, z, z
            t.Button.ZIndex = active and 7 or 4
        end
        win.ActiveTab = tab
        sync_tab_gap(win)
    end
    tab.Select = select

    Library:RegisterThemeCallback(function()
        local active = (win.ActiveTab == tab)
        label.TextColor3 = active and Library.Theme.Accent or Library.Theme.TabInactive
    end)

    btn.MouseButton1Click:Connect(function()
        close_all_popups()
        select()
    end)
    btn.MouseEnter:Connect(function()
        if win.ActiveTab ~= tab then
            tween(label, 0.12, { TextColor3 = Library.Theme.TabHover }):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if win.ActiveTab ~= tab then
            tween(label, 0.12, { TextColor3 = Library.Theme.TabInactive }):Play()
        end
    end)

    update_tab_positions(win)
    if #win.Tabs == 1 then select() end
    return tab
end

Library._TabMethods = {}

function Library._TabMethods:Group(title, side)
    local tab = self
    tab._groups = tab._groups + 1

    local HEADER_H = 19
    local parent_col
    if side == 1 or side == "left" then
        parent_col = tab.LeftCol
    elseif side == 2 or side == "right" then
        parent_col = tab.RightCol
    else
        parent_col = (tab._groups % 2 == 1) and tab.LeftCol or tab.RightCol
    end

    local col = new_instance("Frame", {
        Name = title,
        BackgroundColor3 = Library.Theme.OuterBorder,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, HEADER_H + 15),
        LayoutOrder = tab._groups,
        ZIndex = 3,
        Active = true,
    }, parent_col)
    Library:RegisterTheme(col, "BackgroundColor3", "OuterBorder")

    local col_inner = new_instance("Frame", {
        BackgroundColor3 = Library.Theme.InnerBorder,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(1, 1),
        Size = UDim2.new(1, -2, 1, -2),
        ZIndex = 3,
    }, col)
    Library:RegisterTheme(col_inner, "BackgroundColor3", "InnerBorder")

    local body = new_instance("Frame", {
        Name = "Body",
        BackgroundColor3 = Library.Theme.ChildFill,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(2, 2),
        Size = UDim2.new(1, -4, 1, -4),
        ZIndex = 3,
        ClipsDescendants = false,
        Active = true,
    }, col)
    Library:RegisterTheme(body, "BackgroundColor3", "ChildFill")

    local header = new_instance("Frame", {
        BackgroundColor3 = Library.Theme.HeaderTop,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, HEADER_H),
        ZIndex = 3,
    }, body)
    vertical_gradient(header, "HeaderTop", "HeaderBottom")
    make_label(header, title, "TextActive", {
        Position = UDim2.fromOffset(6, 0),
        Size = UDim2.new(1, -6, 1, 0),
        ZIndex = 4,
    })

    local divider = new_instance("Frame", {
        BackgroundColor3 = Library.Theme.InnerBorder,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, HEADER_H),
        Size = UDim2.new(1, 0, 0, 1),
        ZIndex = 4,
    }, body)
    Library:RegisterTheme(divider, "BackgroundColor3", "InnerBorder")

    local content = new_instance("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, HEADER_H + 1),
        Size = UDim2.new(1, 0, 0, 0),
        ZIndex = 3,
    }, body)

    local padding = new_instance("UIPadding", {
        PaddingLeft   = UDim.new(0, 6),
        PaddingTop    = UDim.new(0, 5),
        PaddingRight  = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 5),
    }, content)
    local content_list = new_instance("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding       = UDim.new(0, 4),
        SortOrder     = Enum.SortOrder.LayoutOrder,
    }, content)

    local function update_size()
        task.wait()
        local content_h = content_list.AbsoluteContentSize.Y
        local top_pad = padding.PaddingTop.Offset
        local bot_pad = padding.PaddingBottom.Offset
        local total = HEADER_H + 1 + top_pad + bot_pad + content_h

        content.Size = UDim2.new(1, 0, 0, total - (HEADER_H + 1))
        col.Size = UDim2.new(1, 0, 0, math.max(HEADER_H + 15, total))
    end

    content_list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update_size)
    content.ChildAdded:Connect(function() task.defer(update_size) end)
    content.ChildRemoved:Connect(function() task.defer(update_size) end)
    task.defer(update_size)

    local group = setmetatable({
        Tab = tab,
        Content = content,
        _order = 0,
        _update_size = update_size,
    }, {__index = Library._GroupMethods})
    return group
end

Library._GroupMethods = {}

local function next_row(group, height)
    group._order = group._order + 1
    local row = new_instance("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, height),
        LayoutOrder = group._order,
        ZIndex = 3,
    }, group.Content)
    if group._update_size then
        task.defer(group._update_size)
    end
    return row
end

function Library._GroupMethods:Checkbox(text, default, callback, extra, flag)
    extra = extra or {}
    local state = default and true or false
    local row = next_row(self, 14)

    local btn = new_instance("TextButton", {
        Text = "",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(12, 12),
        Position = UDim2.fromOffset(0, 1),
        ZIndex = 3,
    }, row)
    local _, fill = framed_box(btn, "OuterBorder", "InnerBorder", "ChildFill", { ZIndex = 3 })
    local accent = new_instance("Frame", {
        BackgroundColor3 = Library.Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = state and 0 or 1,
        ZIndex = 3,
    }, fill)
    vertical_gradient(accent, "Accent", "AccentDark")

    local label = make_label(row, text, state and "TextActive" or "TextInactive", {
        Position = UDim2.fromOffset(19, 0),
        Size = UDim2.new(1, -19, 1, 0),
        ZIndex = 3,
    })

    Library:RegisterThemeCallback(function()
        label.TextColor3 = state and Library.Theme.TextActive or Library.Theme.TextInactive
    end)

    local function set(value, fire_callback)
        state = value and true or false
        if flag then Library.Flags[flag] = state end
        tween(accent, 0.12, { BackgroundTransparency = state and 0 or 1 }):Play()
        tween(label, 0.12, { TextColor3 = state and Library.Theme.TextActive or Library.Theme.TextInactive }):Play()
        if fire_callback ~= false and callback then
            task.spawn(callback, state)
        end
    end

    btn.MouseButton1Click:Connect(function()
        set(not state, true)
    end)
    btn.MouseEnter:Connect(function()
        if not state then
            tween(fill, 0.12, { BackgroundColor3 = Color3.fromRGB(39, 40, 57) }):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if not state then
            tween(fill, 0.12, { BackgroundColor3 = Library.Theme.ChildFill }):Play()
        end
    end)

    if extra.colors then
        local sx = 0
        for _, cfg in ipairs(extra.colors) do
            sx = sx + 14
            self:_swatch(row, cfg, UDim2.new(1, -sx, 0, 1), cfg.flag)
        end
    end

    local ctrl = {
        Set = function(_, v, f) set(v, f) end,
        Get = function() return state end,
    }
    if flag then
        Library.Flags[flag] = state
        Library.Controls[flag] = ctrl
        Library.Defaults[flag] = state
    end
    if callback and default ~= nil then
        task.spawn(callback, state)
    end
    return ctrl
end

function Library._GroupMethods:_swatch(row, cfg, position, flag)
    local color = cfg.default or Library.Theme.Accent
    local btn = new_instance("TextButton", {
        Text = "",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(12, 12),
        Position = position,
        ZIndex = 4,
    }, row)
    local _, fill = framed_box(btn, "OuterBorder", "InnerBorder", color, { ZIndex = 4 })

    local function set(value, fire_callback)
        color = value
        fill.BackgroundColor3 = value
        if flag then Library.Flags[flag] = value end
        if fire_callback ~= false and cfg.callback then
            task.spawn(cfg.callback, value)
        end
    end

    btn.MouseButton1Click:Connect(function()
        close_all_popups()
        local abs = btn.AbsolutePosition
        Library._ColorPicker(popup_layer, abs + Vector2.new(0, 14), color, function(c)
            set(c, true)
        end)
    end)

    local ctrl = {
        Set = function(_, v, f) set(v, f) end,
        Get = function() return color end,
    }
    if flag then
        Library.Flags[flag] = color
        Library.Controls[flag] = ctrl
        Library.Defaults[flag] = color
    end
    return btn
end

function Library._GroupMethods:ColorPicker(text, default, callback, flag)
    local color = default or Library.Theme.Accent
    local row = next_row(self, 14)
    make_label(row, text, "TextInactive", {
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, -20, 1, 0),
        ZIndex = 3,
    })

    local btn = new_instance("TextButton", {
        Text = "",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(12, 12),
        Position = UDim2.new(1, -12, 0, 1),
        ZIndex = 4,
    }, row)
    local _, fill = framed_box(btn, "OuterBorder", "InnerBorder", color, { ZIndex = 4 })

    local function set(value, fire_callback)
        color = value
        fill.BackgroundColor3 = value
        if flag then Library.Flags[flag] = value end
        if fire_callback ~= false and callback then
            task.spawn(callback, value)
        end
    end

    btn.MouseButton1Click:Connect(function()
        close_all_popups()
        local abs = btn.AbsolutePosition
        Library._ColorPicker(popup_layer, abs + Vector2.new(0, 14), color, function(c)
            set(c, true)
        end)
    end)

    local ctrl = {
        Set = function(_, v, f) set(v, f) end,
        Get = function() return color end,
    }
    if flag then
        Library.Flags[flag] = color
        Library.Controls[flag] = ctrl
        Library.Defaults[flag] = color
    end
    return ctrl
end

function Library._GroupMethods:Slider(text, options, callback, flag)
    options = options or {}
    local minv = options.min or 0
    local maxv = options.max or 1
    local decimals = options.decimals ~= nil and options.decimals or 3
    local is_int = options.int and true or false
    local suffix = options.suffix or ""
    local value = options.default or minv

    local row = next_row(self, 28)
    local label = make_label(row, text, "TextInactive", {
        Position = UDim2.fromOffset(1, 0),
        Size = UDim2.fromOffset(120, 13),
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 3,
    })
    local val_label = make_label(row, "", "TextInactive", {
        Position = UDim2.new(1, -120, 0, 0),
        Size = UDim2.fromOffset(120, 13),
        TextXAlignment = Enum.TextXAlignment.Right,
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 3,
    })

    local track = new_instance("TextButton", {
        Text = "",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 16),
        Size = UDim2.new(1, 0, 0, 12),
        ZIndex = 3,
    }, row)
    local _, t_fill = framed_box(track, "OuterBorder", "InnerBorder", "ChildFill", { ZIndex = 3 })
    local progress = new_instance("Frame", {
        BackgroundColor3 = Library.Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(0, 1),
        ZIndex = 3,
    }, t_fill)
    vertical_gradient(progress, "Accent", "AccentDark")

    local function format(v)
        if is_int then return string.format("%d%s", v, suffix) end
        return string.format("%." .. decimals .. "f%s", v, suffix)
    end

    local function render()
        local t = (maxv > minv) and (value - minv) / (maxv - minv) or 0
        progress.Size = UDim2.fromScale(math.clamp(t, 0, 1), 1)
        val_label.Text = format(value)
    end

    local function set(v, fire_callback)
        v = math.clamp(v, minv, maxv)
        if is_int then v = math.floor(v + 0.5) end
        value = v
        render()
        if flag then Library.Flags[flag] = value end
        if fire_callback ~= false and callback then
            task.spawn(callback, value)
        end
    end

    local dragging = false
    local function from_input(input)
        local input_x = input.Position.X
        local rel = (input_x - t_fill.AbsolutePosition.X) / t_fill.AbsoluteSize.X
        set(minv + math.clamp(rel, 0, 1) * (maxv - minv), true)
    end

    track.InputBegan:Connect(function(input)
        if is_click(input) then
            dragging = true
            from_input(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and is_move(input) then
            from_input(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if is_click(input) then dragging = false end
    end)
    track.MouseEnter:Connect(function()
        tween(label, 0.12, { TextColor3 = Library.Theme.TextActive }):Play()
        tween(val_label, 0.12, { TextColor3 = Library.Theme.TextActive }):Play()
    end)
    track.MouseLeave:Connect(function()
        if not dragging then
            tween(label, 0.12, { TextColor3 = Library.Theme.TextInactive }):Play()
            tween(val_label, 0.12, { TextColor3 = Library.Theme.TextInactive }):Play()
        end
    end)

    render()
    local ctrl = {
        Set = function(_, v, f) set(v, f) end,
        Get = function() return value end,
    }
    if flag then
        Library.Flags[flag] = value
        Library.Controls[flag] = ctrl
        Library.Defaults[flag] = value
    end
    if callback and options.default ~= nil then
        task.spawn(callback, value)
    end
    return ctrl
end

function Library._GroupMethods:Keybind(text, default, callback, flag)
    local row = next_row(self, 14)
    make_label(row, text, "TextInactive", {
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, -38, 1, 0),
        ZIndex = 3,
    })

    local box = new_instance("TextButton", {
        Text = "",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 1),
        Size = UDim2.fromOffset(32, 12),
        ZIndex = 4,
    }, row)
    local _, b_fill = framed_box(box, "OuterBorder", "InnerBorder", "ChildFill", { ZIndex = 4 })
    local label = make_label(b_fill, key_text(default), "TextInactive", {
        Size = UDim2.fromScale(1, 1),
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 5,
        TextSize = 11,
    })

    local listening = false
    local key = default

    local function set(k, fire_callback)
        key = k
        label.Text = key_text(k)
        if flag then Library.Flags[flag] = k end
        if fire_callback ~= false and callback then
            task.spawn(callback, k)
        end
    end

    box.MouseButton1Click:Connect(function()
        listening = true
        label.Text = "..."
        label.TextColor3 = Library.Theme.Accent
        local conn
        conn = UserInputService.InputBegan:Connect(function(input, game_processed)
            if not listening then return end
            local k
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode == Enum.KeyCode.Escape then
                    k = nil
                else
                    k = input.KeyCode
                end
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 or
                   input.UserInputType == Enum.UserInputType.MouseButton2 or
                   input.UserInputType == Enum.UserInputType.MouseButton3 or
                   input.UserInputType == Enum.UserInputType.Touch then
                k = input.UserInputType
            else
                return
            end
            listening = false
            conn:Disconnect()
            set(k, true)
            label.TextColor3 = Library.Theme.TextInactive
        end)
    end)

    local ctrl = {
        Set = function(_, k, f) set(k, f) end,
        Get = function() return key end,
    }
    if flag then
        Library.Flags[flag] = key
        Library.Controls[flag] = ctrl
        Library.Defaults[flag] = key
    end
    return ctrl
end

local function plus_icon(parent, color_key)
    local host = new_instance("Frame", {
        Name = "Icon",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -5, 0.5, 0),
        Size = UDim2.fromOffset(7, 7),
        ZIndex = 4,
    }, parent)
    local color = type(color_key) == "string" and Library.Theme[color_key] or color_key
    local hbar = new_instance("Frame", {
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 3),
        Size = UDim2.fromOffset(7, 1),
        ZIndex = 4,
    }, host)
    local vbar = new_instance("Frame", {
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(3, 0),
        Size = UDim2.fromOffset(1, 7),
        ZIndex = 4,
    }, host)
    if type(color_key) == "string" then
        Library:RegisterTheme(hbar, "BackgroundColor3", color_key)
        Library:RegisterTheme(vbar, "BackgroundColor3", color_key)
    end
    return {
        SetOpen = function(open) vbar.Visible = not open end,
        IsOpen = function() return not vbar.Visible end,
    }
end

local function build_combo_popup(box, items, multi, get_state, on_pick)
    close_all_popups()
    local ITEM_H = 16
    local target_h = #items * ITEM_H + 4

    local box_abs = box.AbsolutePosition
    local box_sz = box.AbsoluteSize

    local blocker = new_instance("TextButton", {
        Name = "Blocker",
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 501,
    }, screen_gui)
    blocker.MouseButton1Click:Connect(close_all_popups)

    local pop = new_instance("Frame", {
        Name = "DropdownPopup",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(box_abs.X, box_abs.Y + box_sz.Y + 4),
        Size = UDim2.fromOffset(box_sz.X, target_h),
        ClipsDescendants = true,
        ZIndex = 502,
    }, screen_gui)

    local _, pfill = framed_box(pop, "OuterBorder", "ComboInner", "ComboFill", { ZIndex = 502 })
    pfill.Size = UDim2.new(1, -2, 1, -2)

    local mask = new_instance("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        ClipsDescendants = true,
        ZIndex = 503,
    }, pfill)

    local container = new_instance("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, -target_h),
        Size = UDim2.new(1, 0, 0, target_h),
        ZIndex = 503,
    }, mask)

    for i, it in ipairs(items) do
        local ib = new_instance("TextButton", {
            Text = "",
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, (i - 1) * ITEM_H),
            Size = UDim2.new(1, 0, 0, ITEM_H),
            ClipsDescendants = true,
            ZIndex = 504,
        }, container)
        local selected = get_state(i)
        local il = make_label(ib, (selected and "> " or "") .. it, selected and "ComboSelected" or "TextInactive", {
            Position = UDim2.fromOffset(5, 0),
            Size = UDim2.new(1, -7, 1, 0),
            ZIndex = 505,
        })
        ib.MouseEnter:Connect(function()
            if not get_state(i) then
                tween(il, 0.1, { TextColor3 = Library.Theme.TextActive }):Play()
            end
        end)
        ib.MouseLeave:Connect(function()
            if not get_state(i) then
                tween(il, 0.1, { TextColor3 = Library.Theme.TextInactive }):Play()
            end
        end)
        ib.MouseButton1Click:Connect(function()
            on_pick(i)
            if multi then
                local s = get_state(i)
                il.Text = (s and "> " or "") .. it
                il.TextColor3 = s and Library.Theme.ComboSelected or Library.Theme.TextInactive
            else
                close_all_popups()
            end
        end)
    end

    tween(container, 0.15, { Position = UDim2.fromOffset(0, 0) }):Play()

    open_popups[#open_popups + 1] = function()
        blocker:Destroy()
        pop:Destroy()
    end
    return pop
end

function Library._GroupMethods:Combo(text, items, default, callback, flag)
    local index = default or 1
    local row = next_row(self, 34)
    make_label(row, text, "TextInactive", {
        Position = UDim2.fromOffset(1, 0),
        Size = UDim2.fromOffset(120, 13),
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 3,
    })

    local box = new_instance("TextButton", {
        Text = "",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 16),
        Size = UDim2.new(1, 0, 0, 18),
        ClipsDescendants = true,
        ZIndex = 3,
    }, row)
    local _, b_fill = framed_box(box, "OuterBorder", "ComboInner", "ComboFill", { ZIndex = 3 })
    local preview = make_label(box, items[index] or "", "TextInactive", {
        Position = UDim2.fromOffset(5, 1),
        Size = UDim2.new(1, -20, 1, -2),
        TextSize = 12,
        ZIndex = 4,
    })
    local icon = plus_icon(box, "Accent")

    local function set(i, fire_callback)
        index = i
        preview.Text = items[index] or ""
        if flag then Library.Flags[flag] = index end
        if fire_callback ~= false and callback then
            task.spawn(callback, index, items[index])
        end
    end

    box.MouseEnter:Connect(function()
        tween(preview, 0.12, { TextColor3 = Library.Theme.TextActive }):Play()
    end)
    box.MouseLeave:Connect(function()
        tween(preview, 0.12, { TextColor3 = Library.Theme.TextInactive }):Play()
    end)
    box.MouseButton1Click:Connect(function()
        if icon.IsOpen() then
            close_all_popups()
            icon.SetOpen(false)
            return
        end
        icon.SetOpen(true)
        build_combo_popup(box, items, false, function(i) return i == index end, function(i)
            set(i, true)
        end)
        open_popups[#open_popups + 1] = function()
            icon.SetOpen(false)
        end
    end)

    local ctrl = {
        Set = function(_, i, f) set(i, f) end,
        Get = function() return index, items[index] end,
        Refresh = function(_, new_items)
            items = new_items
            index = math.clamp(index, 1, #items)
            preview.Text = items[index] or ""
            if flag then Library.Flags[flag] = index end
        end,
    }
    if flag then
        Library.Flags[flag] = index
        Library.Controls[flag] = ctrl
        Library.Defaults[flag] = index
    end
    if callback and default then
        task.spawn(callback, index, items[index])
    end
    return ctrl
end

function Library._GroupMethods:MultiCombo(text, items, defaults, callback, flag)
    local state = {}
    for i = 1, #items do state[i] = defaults and defaults[i] or false end
    local row = next_row(self, 34)
    make_label(row, text, "TextInactive", {
        Position = UDim2.fromOffset(1, 0),
        Size = UDim2.fromOffset(120, 13),
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 3,
    })

    local box = new_instance("TextButton", {
        Text = "",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 16),
        Size = UDim2.new(1, 0, 0, 18),
        ClipsDescendants = true,
        ZIndex = 3,
    }, row)
    local _, b_fill = framed_box(box, "OuterBorder", "ComboInner", "ComboFill", { ZIndex = 3 })
    local preview = make_label(box, "", "TextInactive", {
        Position = UDim2.fromOffset(5, 1),
        Size = UDim2.new(1, -20, 1, -2),
        TextSize = 12,
        ZIndex = 4,
    })
    local icon = plus_icon(box, "Accent")

    local function refresh()
        local parts = {}
        for i, on in ipairs(state) do
            if on then table.insert(parts, items[i]) end
        end
        preview.Text = (#parts == 0) and "none showing" or table.concat(parts, ", ")
    end
    refresh()

    local function set(st, fire_callback)
        state = st
        refresh()
        if flag then Library.Flags[flag] = deep_copy(state) end
        if fire_callback ~= false and callback then
            task.spawn(callback, deep_copy(state))
        end
    end

    box.MouseEnter:Connect(function()
        tween(preview, 0.12, { TextColor3 = Library.Theme.TextActive }):Play()
    end)
    box.MouseLeave:Connect(function()
        tween(preview, 0.12, { TextColor3 = Library.Theme.TextInactive }):Play()
    end)
    box.MouseButton1Click:Connect(function()
        if icon.IsOpen() then
            close_all_popups()
            icon.SetOpen(false)
            return
        end
        icon.SetOpen(true)
        build_combo_popup(box, items, true, function(i) return state[i] end, function(i)
            state[i] = not state[i]
            refresh()
            if flag then Library.Flags[flag] = deep_copy(state) end
            if callback then task.spawn(callback, deep_copy(state)) end
        end)
        open_popups[#open_popups + 1] = function()
            icon.SetOpen(false)
        end
    end)

    local ctrl = {
        Set = function(_, st, f) set(st, f) end,
        Get = function() return deep_copy(state) end,
    }
    if flag then
        Library.Flags[flag] = deep_copy(state)
        Library.Controls[flag] = ctrl
        Library.Defaults[flag] = deep_copy(state)
    end
    return ctrl
end

function Library._GroupMethods:TextBox(text, default, callback, flag)
    local row = next_row(self, 34)
    make_label(row, text, "TextInactive", {
        Position = UDim2.fromOffset(1, 0),
        Size = UDim2.fromOffset(120, 13),
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 3,
    })

    local box_frame = new_instance("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 16),
        Size = UDim2.new(1, 0, 0, 18),
        ZIndex = 3,
    }, row)
    local _, b_fill = framed_box(box_frame, "OuterBorder", "ComboInner", "ComboFill", { ZIndex = 3 })
    local tb = new_instance("TextBox", {
        BackgroundTransparency = 1,
        Text = default or "",
        TextColor3 = Library.Theme.TextActive,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.fromOffset(5, 0),
        Size = UDim2.new(1, -10, 1, 0),
        ClearTextOnFocus = false,
        ZIndex = 4,
    }, b_fill)
    apply_font(tb, false)
    Library:RegisterTheme(tb, "TextColor3", "TextActive")

    local function set(str, fire_callback)
        tb.Text = str or ""
        if flag then Library.Flags[flag] = str end
        if fire_callback ~= false and callback then
            task.spawn(callback, str)
        end
    end

    tb.FocusLost:Connect(function()
        set(tb.Text, true)
    end)

    local ctrl = {
        Set = function(_, str, f) set(str, f) end,
        Get = function() return tb.Text end,
    }
    if flag then
        Library.Flags[flag] = default or ""
        Library.Controls[flag] = ctrl
        Library.Defaults[flag] = default or ""
    end
    return ctrl
end

function Library._GroupMethods:Button(text, callback)
    local row = next_row(self, 20)
    local btn = new_instance("TextButton", {
        Text = "",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 3,
    }, row)
    local _, fill = framed_box(btn, "OuterBorder", "InnerBorder", "ComboFill", { ZIndex = 3 })
    make_label(btn, text, "TextActive", {
        Size = UDim2.fromScale(1, 1),
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 4,
    })
    btn.MouseButton1Click:Connect(function()
        if callback then task.spawn(callback) end
    end)
    btn.MouseEnter:Connect(function()
        tween(fill, 0.12, { BackgroundColor3 = Color3.fromRGB(35, 36, 45) }):Play()
    end)
    btn.MouseLeave:Connect(function()
        tween(fill, 0.12, { BackgroundColor3 = Library.Theme.ComboFill }):Play()
    end)
end

function Library._GroupMethods:Label(text)
    local row = next_row(self, 14)
    make_label(row, text, "TextInactive", {
        Size = UDim2.fromScale(1, 1),
        ZIndex = 3,
    })
end

function Library._GroupMethods:Divider()
    local row = next_row(self, 12)
    local line = new_instance("Frame", {
        BackgroundColor3 = Library.Theme.InnerBorder,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -12, 0, 2),
        Position = UDim2.new(0, 6, 0.5, -1),
        ZIndex = 3,
    }, row)
    Library:RegisterTheme(line, "BackgroundColor3", "InnerBorder")
    return row
end

function Library._GroupMethods:ToggleKeybind(text, default_state, default_key, callback, flag)
    local state = default_state and true or false
    local key = default_key or Enum.KeyCode.None

    local row = next_row(self, 34)

    local btn = new_instance("TextButton", {
        Text = "",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(12, 12),
        Position = UDim2.fromOffset(0, 11),
        ZIndex = 3,
    }, row)
    local _, fill = framed_box(btn, "OuterBorder", "InnerBorder", "ChildFill", { ZIndex = 3 })
    local accent = new_instance("Frame", {
        BackgroundColor3 = Library.Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = state and 0 or 1,
        ZIndex = 3,
    }, fill)
    vertical_gradient(accent, "Accent", "AccentDark")

    local label = make_label(row, text, state and "TextActive" or "TextInactive", {
        Position = UDim2.fromOffset(19, 0),
        Size = UDim2.new(1, -80, 1, 0),
        ZIndex = 3,
    })

    local box = new_instance("TextButton", {
        Text = "",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 11),
        Size = UDim2.fromOffset(60, 12),
        ZIndex = 4,
    }, row)
    local _, b_fill = framed_box(box, "OuterBorder", "InnerBorder", "ChildFill", { ZIndex = 4 })
    local key_label = make_label(b_fill, key_text(key), "TextInactive", {
        Size = UDim2.fromScale(1, 1),
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 5,
        TextSize = 11,
    })

    Library:RegisterThemeCallback(function()
        label.TextColor3 = state and Library.Theme.TextActive or Library.Theme.TextInactive
    end)

    local function set_state(val, fire_callback)
        state = val and true or false
        if flag then Library.Flags[flag] = {state = state, key = key} end
        tween(accent, 0.12, { BackgroundTransparency = state and 0 or 1 }):Play()
        tween(label, 0.12, { TextColor3 = state and Library.Theme.TextActive or Library.Theme.TextInactive }):Play()
        if fire_callback ~= false and callback then
            task.spawn(callback, state, key)
        end
    end

    local function set_key(k, fire_callback)
        key = k or Enum.KeyCode.None
        key_label.Text = key_text(key)
        if flag then Library.Flags[flag] = {state = state, key = key} end
        if fire_callback ~= false and callback then
            task.spawn(callback, state, key)
        end
    end

    btn.MouseButton1Click:Connect(function()
        set_state(not state, true)
    end)
    btn.MouseEnter:Connect(function()
        if not state then
            tween(fill, 0.12, { BackgroundColor3 = Color3.fromRGB(39, 40, 57) }):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if not state then
            tween(fill, 0.12, { BackgroundColor3 = Library.Theme.ChildFill }):Play()
        end
    end)

    local listening = false
    box.MouseButton1Click:Connect(function()
        listening = true
        key_label.Text = "..."
        key_label.TextColor3 = Library.Theme.Accent
        local conn
        conn = UserInputService.InputBegan:Connect(function(input, game_processed)
            if not listening then return end
            local k
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode == Enum.KeyCode.Escape then
                    k = nil
                else
                    k = input.KeyCode
                end
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 or
                   input.UserInputType == Enum.UserInputType.MouseButton2 or
                   input.UserInputType == Enum.UserInputType.MouseButton3 or
                   input.UserInputType == Enum.UserInputType.Touch then
                k = input.UserInputType
            else
                return
            end
            listening = false
            conn:Disconnect()
            set_key(k, true)
            key_label.TextColor3 = Library.Theme.TextInactive
        end)
    end)

    if flag then
        Library.Flags[flag] = {state = state, key = key}
        Library.Controls[flag] = {
            Set = function(_, v, f)
                if type(v) == "table" then
                    set_state(v.state, f)
                    set_key(v.key, f)
                else
                    set_state(v, f)
                end
            end,
            Get = function() return {state = state, key = key} end,
        }
        Library.Defaults[flag] = {state = state, key = key}
    end

    if callback and default_state ~= nil then
        task.spawn(callback, state, key)
    end

    return {
        SetState = set_state,
        SetKey = set_key,
        Get = function() return {state = state, key = key} end,
    }
end

function Library._ColorPicker(parent, pos, start_color, on_change)
    local h, s, v = Color3.toHSV(start_color)
    local W = 150
    local pop = new_instance("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(pos.X - W + 12, pos.Y),
        Size = UDim2.fromOffset(W, 120),
        ZIndex = 510,
    }, parent)
    local _, pf = framed_box(pop, "OuterBorder", "InnerBorder", "PanelFill", { ZIndex = 510 })

    local sv = new_instance("ImageButton", {
        BackgroundColor3 = Color3.fromHSV(h, 1, 1),
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.fromOffset(W - 30, 100),
        ZIndex = 511,
        AutoButtonColor = false,
    }, pf)
    local white = new_instance("Frame", {
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 511,
    }, sv)
    new_instance("UIGradient", {
        Rotation = 0,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1)
        }),
    }, white)
    local black = new_instance("Frame", {
        BackgroundColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 511,
    }, sv)
    new_instance("UIGradient", {
        Rotation = 90,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0)
        }),
    }, black)

    local circle = new_instance("Frame", {
        Name = "Indicator",
        Size = UDim2.fromOffset(7, 7),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Position = UDim2.fromScale(s, 1 - v),
        ZIndex = 514,
    }, sv)
    new_instance("UICorner", { CornerRadius = UDim.new(1, 0) }, circle)
    new_instance("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1 }, circle)

    local hue = new_instance("ImageButton", {
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Position = UDim2.new(1, -16, 0, 6),
        Size = UDim2.fromOffset(12, 100),
        ZIndex = 511,
        AutoButtonColor = false,
    }, pf)
    local hg = new_instance("UIGradient", { Rotation = 90 }, hue)
    hg.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.34, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.84, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
    })

    local function update_indicator()
        circle.Position = UDim2.fromScale(math.clamp(s, 0, 1), math.clamp(1 - v, 0, 1))
    end

    local function push()
        update_indicator()
        if on_change then on_change(Color3.fromHSV(h, s, v)) end
    end

    local function update_sv()
        sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        push()
    end

    local dragging_sv, dragging_hue = false, false
    local function handle_picker(input)
        local pos = Vector2.new(input.Position.X, input.Position.Y)
        if dragging_sv then
            s = math.clamp((pos.X - sv.AbsolutePosition.X) / sv.AbsoluteSize.X, 0, 1)
            v = 1 - math.clamp((pos.Y - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y, 0, 1)
            push()
        elseif dragging_hue then
            h = math.clamp((pos.Y - hue.AbsolutePosition.Y) / hue.AbsoluteSize.Y, 0, 1)
            update_sv()
        end
    end

    sv.InputBegan:Connect(function(input)
        if is_click(input) then
            dragging_sv = true
            handle_picker(input)
        end
    end)
    hue.InputBegan:Connect(function(input)
        if is_click(input) then
            dragging_hue = true
            handle_picker(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if is_click(input) then
            dragging_sv, dragging_hue = false, false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if is_move(input) and (dragging_sv or dragging_hue) then
            handle_picker(input)
        end
    end)

    local blocker = new_instance("TextButton", {
        Name = "Blocker",
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 509,
    }, parent)
    blocker.MouseButton1Click:Connect(function()
        if not dragging_sv and not dragging_hue then
            close_all_popups()
        end
    end)

    update_indicator()
    open_popups[#open_popups + 1] = function()
        blocker:Destroy()
        pop:Destroy()
    end
end

function Library:CreateConfigManager(tab, side)
    local group = tab:Group("Config Manager", side or "left")

    local config_combo
    local name_box = group:TextBox("Config Name", "my_config", function(str) end, "_cfg_name")

    local function refresh_dropdown()
        local list = scan_config_files()
        if #list == 0 then list = {"none"} end
        if config_combo and config_combo.Refresh then
            config_combo:Refresh(list)
            config_combo:Set(1, false)
        end
    end

    config_combo = group:Combo("Saved Configs", scan_config_files(), 1, function(idx, name)
        if name and name ~= "none" then
            name_box:Set(name, false)
        end
    end, "_cfg_combo")

    group:Button("Save Config", function()
        local name = name_box:Get()
        if name and name ~= "" then
            Library:SaveConfig(name)
            print("✅ Config saved:", name)
            refresh_dropdown()
        end
    end)

    group:Button("Load Config", function()
        local _, name = config_combo:Get()
        if name and name ~= "none" then
            Library:LoadConfig(name)
            print("✅ Config loaded:", name)
        end
    end)

    group:Button("Delete Config", function()
        local _, name = config_combo:Get()
        if name and name ~= "none" then
            Library:DeleteConfig(name)
            print("🗑️ Config deleted:", name)
            refresh_dropdown()
        end
    end)

    group:Button("Refresh", function()
        refresh_dropdown()
        print("🔄 Config list refreshed")
    end)

    group:Button("Reset to Defaults", function()
        Library:ResetToDefaults()
        print("↻ Reset to defaults")
    end)

    refresh_dropdown()
    return group
end

function Library:CreateThemeManager(tab, side)
    local group = tab:Group("Theme Manager", side or "right")

    local theme_combo
    local name_box = group:TextBox("Theme Name", "my_theme", function(str) end, "_theme_name")

    group:Combo("Preset Theme", {"Default", "Tokyo Night", "Crimson", "Emerald"}, 1, function(idx, name)
        Library:SetPresetTheme(name)
        print("Theme:", name)
    end, "_theme_preset")

    local function refresh_dropdown()
        local list = scan_theme_files()
        if #list == 0 then list = {"none"} end
        if theme_combo and theme_combo.Refresh then
            theme_combo:Refresh(list)
            theme_combo:Set(1, false)
        end
    end

    theme_combo = group:Combo("Saved Themes", scan_theme_files(), 1, function(idx, name)
        if name and name ~= "none" then
            name_box:Set(name, false)
        end
    end, "_theme_combo")

    group:Button("Save Theme", function()
        local name = name_box:Get()
        if name and name ~= "" then
            Library:SaveTheme(name)
            print("💾 Theme saved:", name)
            refresh_dropdown()
        end
    end)

    group:Button("Load Theme", function()
        local _, name = theme_combo:Get()
        if name and name ~= "none" then
            Library:LoadTheme(name)
            print("💾 Theme loaded:", name)
        end
    end)

    group:Button("Delete Theme", function()
        local _, name = theme_combo:Get()
        if name and name ~= "none" then
            Library:DeleteTheme(name)
            print("🗑️ Theme deleted:", name)
            refresh_dropdown()
        end
    end)

    group:Button("Refresh", function()
        refresh_dropdown()
        print("🔄 Theme list refreshed")
    end)

    group:Button("Reset Theme to Default", function()
        Library:ResetThemeToDefault()
        print("↻ Reset theme")
    end)

    refresh_dropdown()
    return group
end

function Library:CreateUICustomization(tab, side)
    local group = tab:Group("UI Customization", side or "left")

    group:Checkbox("UI Expansion (Resize)", Library.UIExpansion, function(val)
        Library.UIExpansion = val
        if Library._UpdateResizeVisibility then
            Library._UpdateResizeVisibility()
        end
    end, nil, "_ui_expansion")

    local leftText = Library.WatermarkOptions.leftText or "Lunex UI"
    local rightText = Library.WatermarkOptions.rightText or "v1.0"
    local leftColor = Library.WatermarkOptions.leftColor or Library.Theme.TextActive
    local rightColor = Library.WatermarkOptions.rightColor or Library.Theme.Accent

    group:Checkbox("Show Watermark", Library.WatermarkVisible, function(val)
        Library.WatermarkVisible = val
        Library:_UpdateWatermark()
    end, nil, "_watermark_visible")

    group:TextBox("Left Text", leftText, function(str)
        Library.WatermarkOptions.leftText = str
        Library:_UpdateWatermark()
    end, "_watermark_left_text")

    group:ColorPicker("Left Color", leftColor, function(col)
        Library.WatermarkOptions.leftColor = col
        Library:_UpdateWatermark()
    end, "_watermark_left_color")

    group:TextBox("Right Text", rightText, function(str)
        Library.WatermarkOptions.rightText = str
        Library:_UpdateWatermark()
    end, "_watermark_right_text")

    group:ColorPicker("Right Color", rightColor, function(col)
        Library.WatermarkOptions.rightColor = col
        Library:_UpdateWatermark()
    end, "_watermark_right_color")

    group:Label("───── Theme Colors ─────")

    group:ColorPicker("Accent", Library.Theme.Accent, function(col)
        Library.Theme.Accent = col
        Library.Theme.AccentDark = Color3.new(col.R * 0.7, col.G * 0.7, col.B * 0.7)
        Library:RefreshTheme()
    end, "_ui_accent")

    group:ColorPicker("Text Active", Library.Theme.TextActive, function(col)
        Library.Theme.TextActive = col
        Library:RefreshTheme()
    end, "_ui_text_active")

    group:ColorPicker("Text Inactive", Library.Theme.TextInactive, function(col)
        Library.Theme.TextInactive = col
        Library:RefreshTheme()
    end, "_ui_text_inactive")

    group:ColorPicker("Panel Background", Library.Theme.PanelFill, function(col)
        Library.Theme.PanelFill = col
        Library:RefreshTheme()
    end, "_ui_panel_fill")

    group:ColorPicker("Content Background", Library.Theme.ContentFill, function(col)
        Library.Theme.ContentFill = col
        Library:RefreshTheme()
    end, "_ui_content_fill")

    group:ColorPicker("Group Background", Library.Theme.ChildFill, function(col)
        Library.Theme.ChildFill = col
        Library:RefreshTheme()
    end, "_ui_child_fill")

    group:ColorPicker("Header Top", Library.Theme.HeaderTop, function(col)
        Library.Theme.HeaderTop = col
        Library:RefreshTheme()
    end, "_ui_header_top")

    group:ColorPicker("Header Bottom", Library.Theme.HeaderBottom, function(col)
        Library.Theme.HeaderBottom = col
        Library:RefreshTheme()
    end, "_ui_header_bottom")

    group:ColorPicker("Outer Border", Library.Theme.OuterBorder, function(col)
        Library.Theme.OuterBorder = col
        Library:RefreshTheme()
    end, "_ui_outer_border")

    group:ColorPicker("Inner Border", Library.Theme.InnerBorder, function(col)
        Library.Theme.InnerBorder = col
        Library:RefreshTheme()
    end, "_ui_inner_border")

    group:ColorPicker("Tab Inactive", Library.Theme.TabInactive, function(col)
        Library.Theme.TabInactive = col
        Library:RefreshTheme()
    end, "_ui_tab_inactive")

    group:ColorPicker("Tab Hover", Library.Theme.TabHover, function(col)
        Library.Theme.TabHover = col
        Library:RefreshTheme()
    end, "_ui_tab_hover")

    return group
end

Library.WatermarkVisible = false
Library.WatermarkOptions = {}
Library._WatermarkHost = nil

function Library:_UpdateWatermark()
    local opts = Library.WatermarkOptions or {}
    local leftColor = opts.leftColor or Library.Theme.TextActive
    local rightColor = opts.rightColor or Library.Theme.Accent
    local leftText = opts.leftText or "Lunex UI"
    local rightText = opts.rightText or "v1.0"

    if Library._WatermarkHost then
        Library._WatermarkHost:Destroy()
        Library._WatermarkHost = nil
    end

    if not Library.WatermarkVisible then return end

    local PAD, GAP, H = 8, 4, 21
    local parts = {
        {t = leftText,  color = leftColor},
        {t = rightText, color = rightColor},
    }
    local total = PAD * 2
    for i, p in ipairs(parts) do
        total = total + TextService:GetTextSize(p.t, FONT_SIZE, FONT, Vector2.new(10000, 100)).X
        if i < #parts then total = total + GAP end
    end

    local host = new_instance("Frame", {
        Name = "Watermark",
        BackgroundColor3 = Library.Theme.OuterBorder,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(10, 55),
        Size = UDim2.fromOffset(math.ceil(total), H),
        ZIndex = 400,
    }, screen_gui)
    Library:RegisterTheme(host, "BackgroundColor3", "OuterBorder")

    local f_inner = new_instance("Frame", {
        BackgroundColor3 = Library.Theme.InnerBorder,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(1, 1),
        Size = UDim2.new(1, -2, 1, -2),
        ZIndex = 400,
    }, host)
    Library:RegisterTheme(f_inner, "BackgroundColor3", "InnerBorder")

    local fill = new_instance("Frame", {
        BackgroundColor3 = Library.Theme.PanelFill,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(2, 2),
        Size = UDim2.new(1, -4, 1, -4),
        ZIndex = 400,
    }, host)
    Library:RegisterTheme(fill, "BackgroundColor3", "PanelFill")
    vertical_gradient(fill, "HeaderTop", "HeaderBottom")

    local strip = new_instance("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(PAD - 2, 0),
        Size = UDim2.new(1, -(PAD - 2), 1, 0),
        ZIndex = 401,
    }, fill)
    new_instance("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, GAP),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, strip)

    for i, p in ipairs(parts) do
        local lbl = new_instance("TextLabel", {
            BackgroundTransparency = 1,
            Text = p.t,
            TextColor3 = p.color,
            TextSize = FONT_SIZE,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            TextStrokeColor3 = Library.Theme.OuterBorder,
            TextStrokeTransparency = STROKE_T,
            TextTruncate = Enum.TextTruncate.None,
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2.fromOffset(0, H - 4),
            LayoutOrder = i,
            ZIndex = 401,
        }, strip)
        apply_font(lbl, false)
        Library:RegisterTheme(lbl, "TextStrokeColor3", "OuterBorder")
    end

    local grab = new_instance("TextButton", {
        Name = "Drag",
        Text = "",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 402,
    }, host)

    local dragging, start_pos, start_input = false, nil, nil
    grab.InputBegan:Connect(function(input)
        if is_click(input) then
            dragging = true
            start_pos = host.Position
            start_input = Vector2.new(input.Position.X, input.Position.Y)
            close_all_popups()
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and is_move(input) then
            local current = Vector2.new(input.Position.X, input.Position.Y)
            local delta = current - start_input
            host.Position = UDim2.new(
                start_pos.X.Scale, start_pos.X.Offset + delta.X,
                start_pos.Y.Scale, start_pos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if is_click(input) then dragging = false end
    end)

    Library._WatermarkHost = host
end

function Library:CreateMobileToggle(on_toggle)
    local logo_asset = nil
    local logo_url = "https://raw.githubusercontent.com/1svxz/Lunex.lol-Ui-lib/refs/heads/main/BackgroundEraser_20260821_225640829.png"
    local logo_file = "lunex_logo.png"

    pcall(function()
        if not isfile(logo_file) then
            writefile(logo_file, game:HttpGet(logo_url))
        end
        logo_asset = getcustomasset(logo_file)
    end)

    local host = new_instance("Frame", {
        Name = "MobileToggle",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -95, 0.5, 0),
        Size = UDim2.fromOffset(50, 50),
        ClipsDescendants = false,
        ZIndex = 600,
    }, screen_gui)

    local btn = new_instance("ImageButton", {
        Name = "ToggleBtn",
        Image = logo_asset or "rbxassetid://1234567890",
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(80, 80),
        Position = UDim2.new(0.5, -67.5, 0.5, -67.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 601,
        AutoButtonColor = false,
        ScaleType = Enum.ScaleType.Fit,
    }, host)

    local dragging, start_pos, start_input = false, nil, nil
    local moved = false
    btn.InputBegan:Connect(function(input)
        if is_click(input) then
            dragging = true
            start_pos = host.Position
            start_input = Vector2.new(input.Position.X, input.Position.Y)
            moved = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and is_move(input) then
            local current = Vector2.new(input.Position.X, input.Position.Y)
            local delta = current - start_input
            if delta.Magnitude > 5 then moved = true end
            host.Position = UDim2.new(
                start_pos.X.Scale, start_pos.X.Offset + delta.X,
                start_pos.Y.Scale, start_pos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if is_click(input) then
            if dragging and not moved and on_toggle then
                on_toggle()
            end
            dragging = false
        end
    end)

    return host
end

local function make_cursor()
    local S = 11
    local C = math.floor(S / 2)
    local gui = new_instance("ScreenGui", {
        Name = "cursor",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 2147483647,
    }, get_gui_parent())

    local host = new_instance("Frame", {
        Name = "Cross",
        BackgroundTransparency = 1,
        Active = false,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(S, S),
        Visible = false,
        ZIndex = 1,
    }, gui)
    local function no_interact(o)
        o.Active = false
        pcall(function() o.Interactable = false end)
    end
    no_interact(host)

    local function bar(color_key, x, y, w, h, z)
        local color = type(color_key) == "string" and Library.Theme[color_key] or color_key
        local f = new_instance("Frame", {
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(x, y),
            Size = UDim2.fromOffset(w, h),
            ZIndex = z,
        }, host)
        no_interact(f)
        if type(color_key) == "string" then
            Library:RegisterTheme(f, "BackgroundColor3", color_key)
        end
    end

    bar("OuterBorder", 0, C - 1, S, 3, 1)
    bar("OuterBorder", C - 1, 0, 3, S, 1)
    bar("TextActive", 1, C, S - 2, 1, 2)
    bar("TextActive", C, 1, 1, S - 2, 2)

    return host
end

Library.CursorEnabled = not UserInputService.TouchEnabled
local cursor = make_cursor()
local cursor_conns = {}

local function move_cursor()
    local m = UserInputService:GetMouseLocation()
    cursor.Position = UDim2.fromOffset(m.X, m.Y)
end

local function set_cursor_enabled(on)
    on = on and Library.CursorEnabled
    cursor.Visible = on
    if not UserInputService.TouchEnabled then
        UserInputService.MouseIconEnabled = not on
    end
    if on and #cursor_conns == 0 then
        move_cursor()
        cursor_conns[1] = RunService.RenderStepped:Connect(move_cursor)
        cursor_conns[2] = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                move_cursor()
            end
        end)
    elseif not on and #cursor_conns > 0 then
        for _, c in ipairs(cursor_conns) do c:Disconnect() end
        table.clear(cursor_conns)
    end
end

function Library:BindToggle(window)
    local visible = true
    set_cursor_enabled(true)

    local function toggle_ui()
        visible = not visible
        close_all_popups()
        set_cursor_enabled(visible)

        if visible then
            window.Canvas.Visible = true
        end

        local tw = TweenService:Create(window.Canvas, TweenInfo.new(0.30, Enum.EasingStyle.Cubic, visible and Enum.EasingDirection.Out or Enum.EasingDirection.In), {
            GroupTransparency = visible and 0 or 1,
        })
        tw:Play()
        if not visible then
            tw.Completed:Connect(function()
                window.Canvas.Visible = false
            end)
        end
    end

    UserInputService.InputBegan:Connect(function(input, game_processed)
        if not game_processed and input.KeyCode == Library.ToggleKey then
            toggle_ui()
        end
    end)

    Library:CreateMobileToggle(toggle_ui)
end

return Library
