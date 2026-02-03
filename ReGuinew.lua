--=====================================================
-- ReGUI CLONE - CORE / WINDOW SYSTEM (PART 1)
--=====================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local LP = Players.LocalPlayer
repeat task.wait() until LP:FindFirstChild("PlayerGui")

-----------------------------------------------------
-- ROOT TABLE
-----------------------------------------------------
local ReGUI = {}
ReGUI.__index = ReGUI

ReGUI.Windows = {}
ReGUI.Pages = {}

-----------------------------------------------------
-- THEME (match ReGUI/x2Swiftz style)
-----------------------------------------------------
ReGUI.Theme = {
    Background = Color3.fromRGB(18,18,22),
    Window = Color3.fromRGB(22,22,28),
    Topbar = Color3.fromRGB(25,25,30),
    Section = Color3.fromRGB(30,30,36),
    Accent = Color3.fromRGB(90,130,255),
    Button = Color3.fromRGB(35,35,42),
    Text = Color3.fromRGB(255,255,255),
    SubText = Color3.fromRGB(160,160,160),
    Stroke = Color3.fromRGB(55,55,65)
}

-----------------------------------------------------
-- UTIL
-----------------------------------------------------
local function Tween(obj,props,t)
    TweenService:Create(
        obj,
        TweenInfo.new(t or .15,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
        props
    ):Play()
end

-----------------------------------------------------
-- SCREEN GUI
-----------------------------------------------------
local Screen = Instance.new("ScreenGui")
Screen.Name = "ReGUI_Clone"
Screen.ResetOnSpawn = false
Screen.Parent = LP.PlayerGui

-----------------------------------------------------
-- WINDOW CLASS
-----------------------------------------------------
local WindowClass = {}
WindowClass.__index = WindowClass

-----------------------------------------------------
function ReGUI:CreateWindow(title,size)

    local win = setmetatable({},WindowClass)

    -------------------------------------------------
    -- FRAME
    -------------------------------------------------
    local Main = Instance.new("Frame",Screen)
    Main.Size = size or UDim2.fromOffset(520,340)
    Main.Position = UDim2.fromScale(.5,.5)
    Main.AnchorPoint = Vector2.new(.5,.5)
    Main.BackgroundColor3 = self.Theme.Window
    Main.Active = true
    Instance.new("UICorner",Main).CornerRadius = UDim.new(0,12)

    win.Main = Main

    -------------------------------------------------
    -- TOPBAR
    -------------------------------------------------
    local Top = Instance.new("Frame",Main)
    Top.Size = UDim2.new(1,0,0,36)
    Top.BackgroundColor3 = self.Theme.Topbar
    win.Top = Top

    local Title = Instance.new("TextLabel",Top)
    Title.Size = UDim2.fromScale(1,1)
    Title.BackgroundTransparency = 1
    Title.Text = title or "ReGUI"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 15
    Title.TextColor3 = self.Theme.Text

    -------------------------------------------------
    -- DRAG SYSTEM
    -------------------------------------------------
    do
        local drag,start,pos

        Top.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then
                drag=true
                start=i.Position
                pos=Main.Position
            end
        end)

        UIS.InputChanged:Connect(function(i)
            if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
                local d=i.Position-start
                Main.Position=pos+UDim2.fromOffset(d.X,d.Y)
            end
        end)

        UIS.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then
                drag=false
            end
        end)
    end

    -------------------------------------------------
    -- PAGE HOLDER
    -------------------------------------------------
    local Holder = Instance.new("Frame",Main)
    Holder.Position = UDim2.fromOffset(0,36)
    Holder.Size = UDim2.new(1,0,1,-36)
    Holder.BackgroundTransparency = 1

    win.PageHolder = Holder
    win.Pages = {}
    win.CurrentPage = nil

    table.insert(self.Windows,win)
    return win
end

-----------------------------------------------------
-- WINDOW : CREATE PAGE (stub for part 2)
-----------------------------------------------------
function WindowClass:CreatePage(name)
    warn("[ReGUI Clone] CreatePage will be implemented in Part 2:",name)
end

-----------------------------------------------------
-- EXPORT
-----------------------------------------------------
getgenv().ReGUI_CLONE = ReGUI

-----------------------------------------------------
-- TEST BOOT
-----------------------------------------------------

local Window = ReGUI:CreateWindow("Atlas Hub",UDim2.fromOffset(520,340))

--=====================================================
-- ReGUI CLONE - PART 2 (Pages / Tabs / Sections)
--=====================================================

-----------------------------------------------------
-- SIDEBAR TAB BAR
-----------------------------------------------------

local function CreateSidebar(win)

    local Side = Instance.new("Frame",win.Main)
    Side.Name = "Sidebar"
    Side.Size = UDim2.new(0,140,1,-36)
    Side.Position = UDim2.fromOffset(0,36)
    Side.BackgroundColor3 = ReGUI.Theme.Topbar

    win.Sidebar = Side

    local Layout = Instance.new("UIListLayout",Side)
    Layout.Padding = UDim.new(0,6)
    Layout.HorizontalAlignment = Center
end

-----------------------------------------------------
-- PAGE CLASS
-----------------------------------------------------

local PageClass = {}
PageClass.__index = PageClass

-----------------------------------------------------
-- WINDOW : CREATE PAGE
-----------------------------------------------------

function WindowClass:CreatePage(name)

    if not self.Sidebar then
        CreateSidebar(self)

        -- resize holder for sidebar
        self.PageHolder.Position = UDim2.fromOffset(140,36)
        self.PageHolder.Size = UDim2.new(1,-140,1,-36)
    end

    -------------------------------------------------
    -- TAB BUTTON
    -------------------------------------------------
    local TabBtn = Instance.new("TextButton",self.Sidebar)
    TabBtn.Size = UDim2.new(1,-12,0,32)
    TabBtn.Text = name
    TabBtn.Font = Enum.Font.Gotham
    TabBtn.TextSize = 13
    TabBtn.TextColor3 = ReGUI.Theme.SubText
    TabBtn.BackgroundColor3 = ReGUI.Theme.Button

    Instance.new("UICorner",TabBtn).CornerRadius = UDim.new(0,8)

    -------------------------------------------------
    -- PAGE FRAME
    -------------------------------------------------
    local PageFrame = Instance.new("ScrollingFrame",self.PageHolder)
    PageFrame.Name = name.."_Page"
    PageFrame.Size = UDim2.fromScale(1,1)
    PageFrame.CanvasSize = UDim2.fromScale(0,0)
    PageFrame.ScrollBarImageTransparency = 1
    PageFrame.BackgroundTransparency = 1
    PageFrame.Visible = false

    local Layout = Instance.new("UIListLayout",PageFrame)
    Layout.Padding = UDim.new(0,10)

    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        PageFrame.CanvasSize =
            UDim2.fromOffset(0,Layout.AbsoluteContentSize.Y+14)
    end)

    -------------------------------------------------
    local page = setmetatable({},PageClass)
    page.Frame = PageFrame
    page.Layout = Layout
    page.Window = self

    -------------------------------------------------
    -- TAB CLICK
    -------------------------------------------------
    TabBtn.MouseButton1Click:Connect(function()

        for _,p in pairs(self.Pages) do
            p.Frame.Visible = false
        end

        for _,b in pairs(self.Sidebar:GetChildren()) do
            if b:IsA("TextButton") then
                Tween(b,{TextColor3=ReGUI.Theme.SubText},.12)
            end
        end

        PageFrame.Visible = true
        Tween(TabBtn,{TextColor3=ReGUI.Theme.Text},.12)

        self.CurrentPage = page
    end)

    -------------------------------------------------
    if not self.CurrentPage then
        PageFrame.Visible = true
        TabBtn.TextColor3 = ReGUI.Theme.Text
        self.CurrentPage = page
    end

    table.insert(self.Pages,page)
    return page
end

-----------------------------------------------------
-- PAGE : SECTION
-----------------------------------------------------

function PageClass:Section(title)

    local Section = Instance.new("Frame",self.Frame)
    Section.BackgroundColor3 = ReGUI.Theme.Section
    Section.Size = UDim2.new(1,-18,0,32)
    Instance.new("UICorner",Section).CornerRadius = UDim.new(0,10)

    local Stroke = Instance.new("UIStroke",Section)
    Stroke.Color = ReGUI.Theme.Stroke
    Stroke.Thickness = 1

    local Label = Instance.new("TextLabel",Section)
    Label.Size = UDim2.new(1,-12,0,28)
    Label.Position = UDim2.fromOffset(6,2)
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Left
    Label.Text = title
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 13
    Label.TextColor3 = ReGUI.Theme.Text

    return Section
end
  --=====================================================
-- ReGUI CLONE - PART 3 (Controls / Widgets)
--=====================================================

-----------------------------------------------------
-- HELPER : CREATE ITEM CONTAINER
-----------------------------------------------------
local function CreateItem(page,height)

    local Holder = Instance.new("Frame",page.Frame)
    Holder.Size = UDim2.new(1,-18,0,height)
    Holder.BackgroundColor3 = ReGUI.Theme.Button
    Instance.new("UICorner",Holder).CornerRadius = UDim.new(0,8)

    local Stroke = Instance.new("UIStroke",Holder)
    Stroke.Color = ReGUI.Theme.Stroke
    Stroke.Thickness = 1

    return Holder
end

-----------------------------------------------------
-- PAGE : LABEL
-----------------------------------------------------
function PageClass:Label(text)

    local Holder = CreateItem(self,28)

    Holder.BackgroundTransparency = 1

    local L = Instance.new("TextLabel",Holder)
    L.Size = UDim2.new(1,-10,1,0)
    L.Position = UDim2.fromOffset(8,0)
    L.BackgroundTransparency = 1
    L.TextXAlignment = Left
    L.Text = text
    L.Font = Enum.Font.Gotham
    L.TextSize = 13
    L.TextColor3 = ReGUI.Theme.SubText

    return L
end

-----------------------------------------------------
-- PAGE : BUTTON
-----------------------------------------------------
function PageClass:Button(text,callback)

    local Holder = CreateItem(self,30)

    local B = Instance.new("TextButton",Holder)
    B.Size = UDim2.fromScale(1,1)
    B.BackgroundTransparency = 1
    B.Text = text
    B.Font = Enum.Font.Gotham
    B.TextSize = 13
    B.TextColor3 = ReGUI.Theme.Text

    B.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    return B
end

-----------------------------------------------------
-- PAGE : TOGGLE
-----------------------------------------------------
function PageClass:Toggle(text,default,callback)

    local state = default or false
    local Holder = CreateItem(self,30)

    local B = Instance.new("TextButton",Holder)
    B.Size = UDim2.fromScale(1,1)
    B.BackgroundTransparency = 1
    B.Text = text.." : "..(state and "ON" or "OFF")
    B.Font = Enum.Font.Gotham
    B.TextSize = 13
    B.TextColor3 = ReGUI.Theme.Text

    B.MouseButton1Click:Connect(function()
        state = not state
        B.Text = text.." : "..(state and "ON" or "OFF")
        if callback then callback(state) end
    end)

    return {
        Set = function(_,v)
            state=v
            B.Text=text.." : "..(state and "ON" or "OFF")
        end,
        Get = function()
            return state
        end
    }
end

-----------------------------------------------------
-- PAGE : SLIDER
-----------------------------------------------------
function PageClass:Slider(text,min,max,default,callback)

    local Holder = CreateItem(self,44)

    local L = Instance.new("TextLabel",Holder)
    L.Size = UDim2.new(1,0,0,18)
    L.BackgroundTransparency = 1
    L.Text = text
    L.Font = Enum.Font.Gotham
    L.TextSize = 12
    L.TextColor3 = ReGUI.Theme.Text

    local Bar = Instance.new("Frame",Holder)
    Bar.Position = UDim2.fromOffset(8,26)
    Bar.Size = UDim2.new(1,-16,0,6)
    Bar.BackgroundColor3 = ReGUI.Theme.Topbar
    Instance.new("UICorner",Bar)

    local Fill = Instance.new("Frame",Bar)
    Fill.BackgroundColor3 = ReGUI.Theme.Accent
    Instance.new("UICorner",Fill)

    local value = default or min

    local function Set(val)
        value = math.clamp(val,min,max)
        local pct = (value-min)/(max-min)
        Fill.Size = UDim2.fromScale(pct,1)
        if callback then callback(value) end
    end

    Set(value)

    local drag=false

    Bar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            drag=true
        end
    end)

    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            drag=false
        end
    end)

    UIS.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local pos=(i.Position.X-Bar.AbsolutePosition.X)/Bar.AbsoluteSize.X
            Set(min+(max-min)*pos)
        end
    end)

    return {
        Set = Set,
        Get = function() return value end
    }
end

-----------------------------------------------------
-- PAGE : TEXTBOX
-----------------------------------------------------
function PageClass:Textbox(placeholder,callback)

    local Holder = CreateItem(self,30)

    local Box = Instance.new("TextBox",Holder)
    Box.Size = UDim2.fromScale(1,1)
    Box.BackgroundTransparency = 1
    Box.PlaceholderText = placeholder
    Box.Text = ""
    Box.Font = Enum.Font.Gotham
    Box.TextSize = 13
    Box.TextColor3 = ReGUI.Theme.Text
    Box.PlaceholderColor3 = ReGUI.Theme.SubText

    Box.FocusLost:Connect(function()
        if callback then callback(Box.Text) end
    end)

    return Box
end

-----------------------------------------------------
-- PAGE : DROPDOWN
-----------------------------------------------------
function PageClass:Dropdown(text,options,callback)

    local Holder = CreateItem(self,30)
    local Open=false

    local Btn = Instance.new("TextButton",Holder)
    Btn.Size=UDim2.fromScale(1,1)
    Btn.BackgroundTransparency=1
    Btn.Text=text
    Btn.Font=Enum.Font.Gotham
    Btn.TextSize=13
    Btn.TextColor3=ReGUI.Theme.Text

    local List = Instance.new("Frame",self.Frame)
    List.Size=UDim2.new(1,-18,0,0)
    List.BackgroundColor3=ReGUI.Theme.Section
    List.Visible=false
    List.ClipsDescendants=true
    Instance.new("UICorner",List)

    local lay=Instance.new("UIListLayout",List)

    local function Toggle()
        Open=not Open
        List.Visible=true
        Tween(List,{
            Size = Open and UDim2.new(1,-18,0,#options*28) or UDim2.new(1,-18,0,0)
        },.15)
    end

    Btn.MouseButton1Click:Connect(Toggle)

    for _,opt in pairs(options) do
        local O=Instance.new("TextButton",List)
        O.Size=UDim2.new(1,0,0,28)
        O.BackgroundColor3=ReGUI.Theme.Button
        O.Text=opt
        O.Font=Enum.Font.Gotham
        O.TextSize=13
        O.TextColor3=ReGUI.Theme.Text

        O.MouseButton1Click:Connect(function()
            Btn.Text=text..": "..opt
            Toggle()
            if callback then callback(opt) end
        end)
    end
  end

--=====================================================
-- ReGUI CLONE - PART 4 (Config / Notify / Popup / Final)
--=====================================================

local HttpService = game:GetService("HttpService")

-----------------------------------------------------
-- FLAGS / CONFIG
-----------------------------------------------------
ReGUI.Flags = {}
ReGUI.ConfigName = "regui_clone_config.json"

local fileSupport = writefile and readfile and isfile

function ReGUI:SaveConfig()
    if not fileSupport then return end
    writefile(self.ConfigName,HttpService:JSONEncode(self.Flags))
end

function ReGUI:LoadConfig()
    if not fileSupport or not isfile(self.ConfigName) then return end
    self.Flags = HttpService:JSONDecode(readfile(self.ConfigName))
end

-----------------------------------------------------
-- PAGE OVERRIDE: STORE FLAGS
-----------------------------------------------------
local oldToggle = PageClass.Toggle
function PageClass:Toggle(flag,text,default,callback)

    ReGUI.Flags[flag] = default or false

    local obj = oldToggle(self,text,default,function(v)
        ReGUI.Flags[flag] = v
        if callback then callback(v) end
    end)

    return obj
end

local oldSlider = PageClass.Slider
function PageClass:Slider(flag,text,min,max,default,callback)

    ReGUI.Flags[flag] = default or min

    return oldSlider(self,text,min,max,default,function(v)
        ReGUI.Flags[flag] = v
        if callback then callback(v) end
    end)
end

-----------------------------------------------------
-- NOTIFICATION
-----------------------------------------------------
function ReGUI:Notify(text)

    local N = Instance.new("TextLabel",Screen)
    N.AnchorPoint = Vector2.new(1,1)
    N.Position = UDim2.fromScale(.98,.95)
    N.Size = UDim2.fromOffset(260,56)
    N.BackgroundColor3 = self.Theme.Section
    N.TextWrapped = true
    N.Text = text
    N.Font = Enum.Font.Gotham
    N.TextSize = 13
    N.TextColor3 = self.Theme.Text

    Instance.new("UICorner",N)

    Tween(N,{Position=UDim2.fromScale(.98,.88)},.2)

    task.delay(3,function()
        Tween(N,{Position=UDim2.fromScale(.98,1.1)},.25)
        task.wait(.3)
        N:Destroy()
    end)
end

-----------------------------------------------------
-- POPUP CONFIRM
-----------------------------------------------------
function ReGUI:Confirm(title,text,callback)

    local Blur = Instance.new("Frame",Screen)
    Blur.Size = UDim2.fromScale(1,1)
    Blur.BackgroundColor3 = Color3.fromRGB(0,0,0)
    Blur.BackgroundTransparency = .5

    local Box = Instance.new("Frame",Blur)
    Box.AnchorPoint = Vector2.new(.5,.5)
    Box.Position = UDim2.fromScale(.5,.5)
    Box.Size = UDim2.fromOffset(320,180)
    Box.BackgroundColor3 = self.Theme.Window
    Instance.new("UICorner",Box)

    local T = Instance.new("TextLabel",Box)
    T.Size = UDim2.new(1,0,0,32)
    T.BackgroundTransparency = 1
    T.Text = title
    T.Font = Enum.Font.GothamBold
    T.TextSize = 15
    T.TextColor3 = self.Theme.Text

    local M = Instance.new("TextLabel",Box)
    M.Position = UDim2.fromOffset(12,40)
    M.Size = UDim2.new(1,-24,0,70)
    M.TextWrapped = true
    M.BackgroundTransparency = 1
    M.Text = text
    M.Font = Enum.Font.Gotham
    M.TextColor3 = self.Theme.SubText
    M.TextSize = 13

    local Yes = Instance.new("TextButton",Box)
    Yes.Position = UDim2.fromOffset(30,125)
    Yes.Size = UDim2.fromOffset(110,32)
    Yes.Text = "Confirm"
    Yes.BackgroundColor3 = self.Theme.Accent
    Yes.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner",Yes)

    local No = Instance.new("TextButton",Box)
    No.Position = UDim2.fromOffset(180,125)
    No.Size = UDim2.fromOffset(110,32)
    No.Text = "Cancel"
    No.BackgroundColor3 = self.Theme.Section
    No.TextColor3 = self.Theme.Text
    Instance.new("UICorner",No)

    local function Close()
        Blur:Destroy()
    end

    Yes.MouseButton1Click:Connect(function()
        Close()
        if callback then callback(true) end
    end)

    No.MouseButton1Click:Connect(function()
        Close()
        if callback then callback(false) end
    end)
end

-----------------------------------------------------
-- HOTKEY TOGGLE WINDOWS (RightShift)
-----------------------------------------------------
UIS.InputBegan:Connect(function(i,gp)
    if not gp and i.KeyCode == Enum.KeyCode.RightShift then
        for _,w in pairs(ReGUI.Windows) do
            w.Main.Visible = not w.Main.Visible
        end
    end
end)

-----------------------------------------------------
-- DESTROY / UNLOAD
-----------------------------------------------------
function ReGUI:Destroy()
    Screen:Destroy()
end

-----------------------------------------------------
-- AUTO LOAD CONFIG
-----------------------------------------------------
ReGUI:LoadConfig()

