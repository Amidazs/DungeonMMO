--!strict
local Players=game:GetService("Players"); local RS=game:GetService("ReplicatedStorage")
local p=Players.LocalPlayer; local core=RS:WaitForChild("Core");local rem=core:WaitForChild("Remotes")
local req=rem:WaitForChild("DungeonEntryRequest")::RemoteEvent;local res=rem:WaitForChild("DungeonEntryResult")::RemoteEvent
local gui=Instance.new("ScreenGui");gui.Name="BaseUi";gui.ResetOnSpawn=false;gui.Parent=p:WaitForChild("PlayerGui")
local f=Instance.new("Frame");f.AnchorPoint=Vector2.new(.5,1);f.Position=UDim2.fromScale(.5,.96);f.Size=UDim2.fromOffset(520,180);f.Visible=true;f.Parent=gui
local t=Instance.new("TextLabel");t.Size=UDim2.new(1,0,0,40);t.Text="Dungeon Board";t.Parent=f
local function button(text,x,id) local b=Instance.new("TextButton");b.Position=UDim2.fromOffset(x,55);b.Size=UDim2.fromOffset(220,50);b.Text=text;b.Parent=f;b.Activated:Connect(function() req:FireServer(id) end);return b end
button("Enter Temple",20,"TestDungeon");button("Enter Abandoned Mine",280,"AbandonedMine")
local s=Instance.new("TextLabel");s.Position=UDim2.fromOffset(20,115);s.Size=UDim2.fromOffset(480,50);s.Text="Choose a dungeon";s.Parent=f
res.OnClientEvent:Connect(function(x) s.Text=if x.ok then "Teleporting..." else "Entry blocked: "..tostring(x.reason) end)
