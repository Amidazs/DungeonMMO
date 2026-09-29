--!strict
-- Truthful local navigation and session-local presentation preferences.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")
local UiArt = require(shared:WaitForChild("UiArt"))
local Assets = require(shared:WaitForChild("UiArtAssets"))
local Theme = require(shared:WaitForChild("UiTheme"))
local UI = require(shared:WaitForChild("UiComponents"))
local Controller = require(script.Parent:WaitForChild("HudWindowController"))
local gui = Instance.new("ScreenGui")
gui.Name = "NavigationMenu"
gui.ResetOnSpawn = false
gui.DisplayOrder = 173
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")
local function label(parent, name, text, x, y, w, h)
    local l = UI.label(parent, name, text, "Body")
    l.Position = UDim2.fromOffset(x,y)
    l.Size = UDim2.fromOffset(w,h)
    l.TextWrapped = true
    l.ZIndex = 16
    return l
end
local function window(name, art)
    local m = UI.modal(gui, name.."Panel", name, "", UDim2.fromOffset(600,750))
    m.Root.Visible = false
    m.Root.ZIndex = 11
    UiArt.reference_background(m.Root, art, 11)
    m.Title.Visible = false
    m.Subtitle.Visible = false
    m.Body.Position = UDim2.fromScale(0.09,0.18)
    m.Body.Size = UDim2.fromScale(0.82,0.73)
    m.Body.ZIndex = 15
    UiArt.align_close(m.Root,m.Close,art)
    Theme.bind_responsive_scale(m.Root,1366,0.5,1)
    Controller.register(name,function(visible) m.Root.Visible = visible end)
    m.Close.Activated:Connect(function() Controller.set_visible(name,false) end)
    return m
end
local map = window("Map","Journal")
local map_title = label(map.Root,"MapTitle","Local Map",120,50,400,35)
map_title.BackgroundColor3 = Color3.fromRGB(14,16,18)
map_title.BackgroundTransparency = 0
map_title.TextSize = 26
local description = label(map.Body,"MapDescription","Current area landmarks • north is up\nWorld geography has not been authored yet.",0,0,490,48)
local map_area = Instance.new("Frame")
map_area.Name = "LocalLandmarks"
map_area.Position = UDim2.fromOffset(0,62)
map_area.Size = UDim2.new(1,0,1,-120)
map_area.BackgroundColor3 = Color3.fromRGB(21,27,26)
map_area.BorderSizePixel = 0
map_area.ClipsDescendants = true
map_area.ZIndex = 16
map_area.Parent = map.Body
Theme.add_stroke(map_area,Theme.PALETTE.AccentBright,0.3)
local player_marker = label(map_area,"PlayerMarker","▲",0,0,22,22)
player_marker.AnchorPoint = Vector2.new(0.5,0.5)
player_marker.Position = UDim2.fromScale(0.5,0.5)
player_marker.TextColor3 = Color3.fromRGB(83,204,248)
player_marker.ZIndex = 20
local coords = label(map.Body,"Coordinates","",0,490,490,40)
coords.Position = UDim2.new(0,0,1,-42)
local points = {}
local function add_prompt(prompt)
    if not prompt:IsA("ProximityPrompt") then return end
    local parent = prompt.Parent
    local part = if parent and parent:IsA("BasePart") then parent else if parent then parent:FindFirstAncestorWhichIsA("BasePart") else nil
    if not part then return end
    local marker = label(map_area,"Landmark",prompt.ObjectText ~= "" and prompt.ObjectText or prompt.ActionText,0,0,100,28)
    marker.TextSize = 12
    marker.AnchorPoint = Vector2.new(0.5,0.5)
    marker.TextColor3 = Theme.PALETTE.AccentBright
    table.insert(points,{Part=part,Marker=marker})
end
for _,item in ipairs(workspace:GetDescendants()) do add_prompt(item) end
workspace.DescendantAdded:Connect(add_prompt)
local settings = window("Settings","Settings")
label(settings.Body,"Heading","Display & Camera",0,0,490,32).TextSize = 24
label(settings.Body,"Scope","These preferences apply for this play session.",0,40,490,38)
local show_coords = true
local use_24 = true
local fov = 70
local function setting(name,text,y,action)
    local b = UI.button(settings.Body,name,text,"Secondary")
    b.Position = UDim2.fromOffset(0,y)
    b.Size = UDim2.new(1,0,0,44)
    b.ZIndex = 17
    UiArt.paint_button(b,"Secondary")
    b.Activated:Connect(function() action(b) end)
    return b
end
setting("Coordinates","Coordinates: On",100,function(b)
    show_coords = not show_coords
    b.Text = "Coordinates: "..(if show_coords then "On" else "Off")
    coords.Visible = show_coords
end)
setting("ClockFormat","Clock: 24 hour",160,function(b)
    use_24 = not use_24
    b.Text = "Clock: "..(if use_24 then "24 hour" else "12 hour")
end)
setting("CameraFov","Camera field of view: 70",220,function(b)
    fov = if fov >= 90 then 70 else fov + 10
    if workspace.CurrentCamera then workspace.CurrentCamera.FieldOfView = fov end
    b.Text = "Camera field of view: "..fov
end)
label(settings.Body,"Help","I  Inventory     C  Stats     K  Skills\nJ  Guild     L  Quests     M  Map\nClose a window with its gold X.",0,300,490,110)
local mini = Instance.new("Frame")
mini.Name = "LocationHud"
mini.AnchorPoint = Vector2.new(1,0)
mini.Position = UDim2.new(1,-18,0,12)
mini.Size = UDim2.fromOffset(260,182)
mini.BackgroundTransparency = 1
mini.Parent = gui
Theme.bind_responsive_scale(mini,1600,0.55,1)
UiArt.popup_background(mini,1)
local zone = label(mini,"Zone","Current Area",18,12,224,26)
zone.TextXAlignment = Enum.TextXAlignment.Center
local clock = label(mini,"WorldTime","",18,42,224,22)
clock.TextXAlignment = Enum.TextXAlignment.Center
local hint = label(mini,"MapHint","Local landmarks\nOpen Map [M]",18,74,224,48)
hint.TextXAlignment = Enum.TextXAlignment.Center
local mini_coords = label(mini,"Coordinates","",18,133,224,24)
mini_coords.TextXAlignment = Enum.TextXAlignment.Center
local open = Instance.new("TextButton")
open.Name = "OpenMap"
open.Size = UDim2.fromScale(1,1)
open.BackgroundTransparency = 1
open.Text = ""
open.ZIndex = 21
open.Parent = mini
open.Activated:Connect(function() Controller.set_visible("Map",true) end)
UserInputService.InputBegan:Connect(function(input,processed)
    if not processed and input.KeyCode == Enum.KeyCode.M then Controller.toggle("Map") end
end)
task.spawn(function()
    while gui.Parent do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local is_base = player.PlayerScripts:FindFirstChild("Base") ~= nil
        zone.Text = if is_base then "Starting Base" else "Dungeon"
        local hour = math.floor(Lighting.ClockTime)
        local minute = math.floor((Lighting.ClockTime % 1)*60)
        clock.Text = if use_24 then string.format("World time  %02d:%02d",hour,minute) else string.format("World time  %d:%02d %s",(hour-1)%12+1,minute,if hour>=12 then "PM" else "AM")
        mini_coords.Visible = show_coords
        if root and root:IsA("BasePart") then
            coords.Text = string.format("X: %.0f   Y: %.0f   Z: %.0f",root.Position.X,root.Position.Y,root.Position.Z)
            mini_coords.Text = coords.Text
            for _,point in ipairs(points) do
                local delta = point.Part.Position-root.Position
                local x,z = 0.5+delta.X/500,0.5+delta.Z/500
                point.Marker.Visible = point.Part.Parent ~= nil and x>0.08 and x<0.92 and z>0.06 and z<0.94
                point.Marker.Position = UDim2.fromScale(x,z)
            end
        end
        task.wait(0.25)
    end
end)
