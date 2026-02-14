local a=game:GetService"Players"
local b=game:GetService"HttpService"
local c=game:GetService"TweenService"

if shared.UPDATE_LOG_EXECUTED then
shared.UPDATE_LOG_EXECUTED=false
return
end
shared.UPDATE_LOG_EXECUTED=true

local function loadJson(d)
local e,f=pcall(function()
return b:JSONDecode(readfile(d))
end)
return e and type(f)=='table'and f or nil,f
end

local function retry(d,e,f)
e=e and tonumber(e)or 3
f=f and tonumber(f)or 1
assert(d~=nil and type(d)=="function",`function expected got {tostring(type(d))}!`)
local g
repeat
e=e-1
local h,i=pcall(d)
if h then
g=i
e=-1
end
task.wait(f)
until e<=0
return g
end

local d="https://raw.githubusercontent.com/VapeVoidware/VWExtra/main/"

local e=(shared.UpdateLogDevMode and loadJson"VW_Update_Log.json")or(retry(function()
return b:JSONDecode(game:HttpGet(d.."UpdateMeta.json",true))
end,10,3)or loadJson"VW_Update_Log.json")

if not e then warn"[VW Update Log]: Failure loading changelogData!"
return end
pcall(function()writefile("VW_Update_Log.json",b:JSONEncode(e))end)

local f=loadJson"Local_VW_Update_Log.json"or{lastRead=""}

local function getNewestUpdate()
for g,h in pairs(e)do
if h.new then return h end
end
return nil
end

local g=getNewestUpdate()
if not g then warn"[VW Update Log]: Failure getting newest update!"
return end

task.spawn(function()
pcall(function()
task.wait(5)
loadstring(
game:HttpGet(d.."libraries/library.lua",true)
)()
end)
end)

if(not(shared.UpdateLogBypass or shared.UpdateLogDevMode))and f.lastRead==tostring(g.updateLogId)then return end

local h={}
h.__index=h

local function getCoreGui()
local i,j=pcall(function()
return game:GetService"CoreGui"
end)
return i and j
end

function h.new()
local i=setmetatable({},h)
i.ScreenGui=Instance.new"ScreenGui"
i.ScreenGui.Name="NotificationGui"
i.ScreenGui.Parent=getCoreGui()or a.LocalPlayer:WaitForChild"PlayerGui"
i.ScreenGui.ResetOnSpawn=false
i.Notifications={}
return i
end

local function save()
f.lastRead=tostring(g.updateLogId)
writefile("Local_VW_Update_Log.json",b:JSONEncode(f))
end

local i=false

function h.CreateNotification(j,k,l,m,n,o)
repeat task.wait()until not i
i=true
local p=Instance.new"Frame"
p.Size=UDim2.new(0,300,0,120)
p.Position=UDim2.new(1,20,0,-150)
p.BackgroundColor3=Color3.fromRGB(40,40,60)
p.BorderSizePixel=0
p.Parent=j.ScreenGui

local q=Instance.new"UICorner"
q.CornerRadius=UDim.new(0,12)
q.Parent=p

local r=Instance.new"ImageLabel"
r.Name="Blur"
r.Size=UDim2.new(1,89,1,52)
r.Position=UDim2.fromOffset(-48,-31)
r.BackgroundTransparency=1
r.Image="rbxassetid://14898786664"
r.ScaleType=Enum.ScaleType.Slice
r.SliceCenter=Rect.new(52,31,261,502)
r.Parent=p

local s=Instance.new"TextLabel"
s.Size=UDim2.new(1,-20,0,30)
s.Position=UDim2.new(0,10,0,10)
s.BackgroundTransparency=1
s.Text=k
s.TextColor3=Color3.fromRGB(255,255,255)
s.Font=Enum.Font.FredokaOne
s.TextSize=20
s.TextXAlignment=Enum.TextXAlignment.Left
s.Parent=p

local t=Instance.new"TextLabel"
t.Size=UDim2.new(1,-20,0,40)
t.Position=UDim2.new(0,10,0,40)
t.BackgroundTransparency=1
t.Text=l
t.TextColor3=Color3.fromRGB(200,200,220)
t.Font=Enum.Font.SourceSans
t.TextSize=16
t.TextXAlignment=Enum.TextXAlignment.Left
t.TextWrapped=true
t.Parent=p

local u=c:Create(p,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{
Position=UDim2.new(1,-320,0,20)
})
u:Play()

if m then
local v=Instance.new"TextButton"
v.Size=UDim2.new(0,60,0,30)
v.Position=UDim2.new(0,150,0,80)
v.BackgroundColor3=Color3.fromRGB(80,255,80)
v.Text="Yes"
v.TextColor3=Color3.fromRGB(255,255,255)
v.Font=Enum.Font.SourceSansBold
v.TextSize=18
v.Parent=p

local w=Instance.new"UICorner"
w.CornerRadius=UDim.new(0,8)
w.Parent=v

local x=Instance.new"TextButton"
x.Size=UDim2.new(0,60,0,30)
x.Position=UDim2.new(0,220,0,80)
x.BackgroundColor3=Color3.fromRGB(255,80,80)
x.Text="No"
x.TextColor3=Color3.fromRGB(255,255,255)
x.Font=Enum.Font.SourceSansBold
x.TextSize=18
x.Parent=p

local y=Instance.new"UICorner"
y.CornerRadius=UDim.new(0,8)
y.Parent=x

v.MouseEnter:Connect(function()
c:Create(v,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(120,255,120)}):Play()
end)
v.MouseLeave:Connect(function()
c:Create(v,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(80,255,80)}):Play()
end)
x.MouseEnter:Connect(function()
c:Create(x,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(255,120,120)}):Play()
end)
x.MouseLeave:Connect(function()
c:Create(x,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(255,80,80)}):Play()
end)

local function closeNotification()
local z=c:Create(p,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{
Position=UDim2.new(1,20,0,20)
})
z:Play()
z.Completed:Connect(function()
p:Destroy()
end)
i=false
end

v.MouseButton1Click:Connect(function()
if n then n()end
closeNotification()
end)
x.MouseButton1Click:Connect(function()
if o then o()end
closeNotification()
end)

task.delay(15,function()
if p.Parent then
closeNotification()
end
end)
else
task.delay(5,function()
if p.Parent then
local v=c:Create(p,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{
Position=UDim2.new(1,20,0,20)
})
v:Play()
v.Completed:Connect(function()
p:Destroy()
end)
end
i=false
end)
end

table.insert(j.Notifications,p)
return p
end

local function addBlur(j)
local k=Instance.new'ImageLabel'
k.Name='Blur'
k.Size=UDim2.new(1,89,1,52)
k.Position=UDim2.fromOffset(-48,-31)
k.BackgroundTransparency=1
k.Image='rbxassetid://14898786664'
k.ScaleType=Enum.ScaleType.Slice
k.SliceCenter=Rect.new(52,31,261,502)
k.Parent=j
return k
end

local j=h.new()

local function createChangelogUI()
local k=a.LocalPlayer
local l=k:WaitForChild"PlayerGui"

local m=Instance.new"ScreenGui"
m.Name="ChangelogUI"
m.Parent=getCoreGui()or l
m.ResetOnSpawn=false

local n=Instance.new"Frame"
n.Size=UDim2.new(0.85,0,0.9,0)
n.Position=UDim2.new(0.5,0,1.05,0)
n.AnchorPoint=Vector2.new(0.5,0)
n.BackgroundColor3=Color3.fromRGB(60,60,80)
n.BorderSizePixel=0
n.BackgroundTransparency=1
n.Parent=m

local o=Instance.new"UICorner"
o.CornerRadius=UDim.new(0,20)
o.Parent=n

local p=Instance.new"Frame"
p.Size=UDim2.new(1,0,0,40)
p.BackgroundColor3=Color3.fromRGB(80,80,120)
p.BorderSizePixel=0
p.Parent=n

local q=Instance.new"UICorner"
q.CornerRadius=UDim.new(0,20)
q.Parent=p

local r=Instance.new"TextButton"
r.Size=UDim2.new(0,30,0,30)
r.Position=UDim2.new(1,-40,0,5)
r.BackgroundColor3=Color3.fromRGB(129,145,186)
r.Text="x"
r.TextColor3=Color3.fromRGB(255,255,255)
r.Font=Enum.Font.SourceSansBold
r.TextSize=20
r.Parent=p

local s=Instance.new"UICorner"
s.CornerRadius=UDim.new(0,8)
s.Parent=r

local t=Instance.new"TextLabel"
t.TextScaled=true
t.Font=Enum.Font.FredokaOne
t.Position=UDim2.new(0.5,0,0,5)
t.AnchorPoint=Vector2.new(0.5,0)
t.Parent=p
t.Text="VW Update Log"
t.TextColor3=Color3.fromRGB(255,255,255)
t.AutomaticSize=Enum.AutomaticSize.X
t.Size=UDim2.new(0,100,0,30)
t.BackgroundTransparency=1

local u=Instance.new"UIStroke"
u.Parent=t
u.Color=Color3.fromRGB(0,0,0)
u.Thickness=2

local v=Instance.new"ScrollingFrame"
v.Size=UDim2.new(1,-30,1,-50)
v.Position=UDim2.new(0,19,0,45)
v.BackgroundTransparency=1
v.BorderSizePixel=0
v.ScrollBarThickness=10
v.ScrollBarImageColor3=Color3.fromRGB(100,100,140)
v.ScrollingEnabled=true
v.ScrollingDirection=Enum.ScrollingDirection.Y
v.Parent=n

local w=Instance.new"UIListLayout"
w.Padding=UDim.new(0,15)
w.SortOrder=Enum.SortOrder.LayoutOrder
w.Parent=v

local x=TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
local y=c:Create(n,x,{
Position=UDim2.new(0.5,0,0.05,0),
BackgroundTransparency=0
})
y:Play()

r.MouseEnter:Connect(function()
c:Create(r,TweenInfo.new(0.2),{
BackgroundColor3=Color3.fromRGB(255,80,80)
}):Play()
end)
r.MouseLeave:Connect(function()
c:Create(r,TweenInfo.new(0.2),{
BackgroundColor3=Color3.fromRGB(129,145,186)
}):Play()
end)

local function createUpdateEntry(z)
if not z.visible then return end

local A=Instance.new"Frame"
A.BackgroundColor3=Color3.fromRGB(70,70,100)
A.BorderSizePixel=0
A.BackgroundTransparency=1

local B=Instance.new"UICorner"
B.CornerRadius=UDim.new(0,15)
B.Parent=A

local C=Instance.new"TextLabel"
C.Size=UDim2.new(0.6,0,0,50)
C.Position=UDim2.new(0,15,0,15)
C.BackgroundTransparency=1
C.Text=z.title
C.TextColor3=Color3.fromRGB(255,255,255)
C.Font=Enum.Font.SourceSansBold
C.TextSize=32
C.TextXAlignment=Enum.TextXAlignment.Left
C.Parent=A

local D=Instance.new"TextLabel"
D.Size=UDim2.new(0,240,0,30)
D.Position=UDim2.new(0,15,0,65)
D.BackgroundTransparency=1
D.Text=z.date
D.TextColor3=Color3.fromRGB(200,200,220)
D.Font=Enum.Font.SourceSans
D.TextSize=20
D.TextXAlignment=Enum.TextXAlignment.Left
D.Parent=A

if z.new then
local E=Instance.new"TextLabel"
E.Size=UDim2.new(0,80,0,30)
E.Position=UDim2.new(0,265,0,65)
E.BackgroundColor3=Color3.fromRGB(80,255,80)
E.Text="NEW"
E.TextColor3=Color3.fromRGB(255,255,255)
E.Font=Enum.Font.SourceSansBold
E.TextSize=18
E.Parent=A

addBlur(E)

local F=Instance.new("UIStroke",E)

local G=Instance.new"UICorner"
G.CornerRadius=UDim.new(0,8)
G.Parent=E

E.MouseEnter:Connect(function()
local H=c:Create(E,TweenInfo.new(0.3,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{
Size=UDim2.new(0,90,0,34),
BackgroundColor3=Color3.fromRGB(120,255,120)
})
local I=c:Create(F,TweenInfo.new(0.3,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{
Thickness=2
})
H:Play()
I:Play()

task.spawn(function()
while E:IsDescendantOf(game)do
c:Create(E,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{
BackgroundColor3=Color3.fromRGB(80,255,80)
}):Play()
task.wait(0.5)
c:Create(E,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{
BackgroundColor3=Color3.fromRGB(120,255,120)
}):Play()
task.wait(0.5)
end
end)
end)

E.MouseLeave:Connect(function()
local H=c:Create(E,TweenInfo.new(0.3,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{
Size=UDim2.new(0,80,0,30),
BackgroundColor3=Color3.fromRGB(80,255,80)
})
local I=c:Create(F,TweenInfo.new(0.3,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{
Thickness=1
})
H:Play()
I:Play()
end)
end

local E=15
if z.image and z.image.assetId then
local F=Instance.new"ImageLabel"
F.Size=UDim2.new(0,z.image.banner and 200 or 100,0,100*z.image.aspectRatio)
F.Position=UDim2.new(1,z.image.banner and-220 or-120,0,15)
F.BackgroundTransparency=1
F.Image=z.image.assetId
F.Parent=A

addBlur(F)

local G=Instance.new"UICorner"
G.CornerRadius=UDim.new(0,8)
G.Parent=F

E=E+(z.image.banner and 200 or 100)+15
end

if z.video and type(z.video)=="table"then
if not z.videos then
z.videos={}
end
table.insert(z.videos,z.video)
z.video=nil
end

















































































if z.videos and type(z.videos)=="table"and#z.videos>0 then
local F=E
for G,H in ipairs(z.videos)do
if H.url and H.image then
local I=Instance.new"ImageLabel"
I.Size=UDim2.new(0,240,0,135)
I.Position=UDim2.new(1,-260,0,F)
I.BackgroundTransparency=1
I.Image=H.image
I.Parent=A

addBlur(I)

local J=Instance.new"UICorner"
J.CornerRadius=UDim.new(0,8)
J.Parent=I

local K=Instance.new"TextLabel"
K.Size=UDim2.new(0,240,0,30)
K.Position=UDim2.new(1,-260,0,F+135+15)
K.BackgroundTransparency=1
K.Text=H.title or"Showcase "..G
K.TextColor3=Color3.fromRGB(200,200,220)
K.Font=Enum.Font.SourceSans
K.TextSize=20
K.TextXAlignment=Enum.TextXAlignment.Left
K.Parent=A

local L=Instance.new"TextButton"
L.Size=UDim2.new(0,120,0,30)
L.Position=UDim2.new(1,-260,0,F+135+45)
L.BackgroundColor3=Color3.fromRGB(80,120,255)
L.Text="Copy Video URL"
L.TextColor3=Color3.fromRGB(255,255,255)
L.Font=Enum.Font.SourceSansBold
L.TextSize=18
L.Parent=A

local M=Instance.new"UICorner"
M.CornerRadius=UDim.new(0,8)
M.Parent=L

addBlur(L)

local N=Instance.new("UIStroke",L)
N.Thickness=1

L.MouseEnter:Connect(function()
c:Create(L,TweenInfo.new(0.3,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{
Size=UDim2.new(0,130,0,34),
BackgroundColor3=Color3.fromRGB(120,160,255)
}):Play()
c:Create(N,TweenInfo.new(0.3,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{
Thickness=2
}):Play()
end)

L.MouseLeave:Connect(function()
c:Create(L,TweenInfo.new(0.3,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{
Size=UDim2.new(0,120,0,30),
BackgroundColor3=Color3.fromRGB(80,120,255)
}):Play()
c:Create(N,TweenInfo.new(0.3,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{
Thickness=1
}):Play()
end)

L.MouseButton1Click:Connect(function()
local O,P=pcall(function()
setclipboard(H.url)
end)
if O then
print("Copied video URL to clipboard: ",H.url)
L.Text="Copied!"
task.delay(0.5,function()
L.Text="Copy Video URL"
end)
else
warn("Failed to copy video URL: ",P)
end
end)

F=F+135+90
end
end
end

local F=Instance.new"TextLabel"
F.Size=UDim2.new(1,-280,0,0)
F.Position=UDim2.new(0,15,0,110)
F.BackgroundTransparency=1
F.Text=z.body
F.TextColor3=Color3.fromRGB(230,230,255)
F.Font=Enum.Font.SourceSans
F.TextSize=22
F.TextXAlignment=Enum.TextXAlignment.Left
F.TextYAlignment=Enum.TextYAlignment.Top
F.TextWrapped=true
F.RichText=true
F.Parent=A

task.wait()
local G=F.TextBounds.Y
if G==0 then
local H=select(2,z.body:gsub("\n",""))+1
G=H*F.TextSize
end
local H=125

local I
if z.images and type(z.images)=="table"and#z.images>0 then
I=Instance.new"ScrollingFrame"
I.Size=UDim2.new(1,-280,0,180)
I.Position=UDim2.new(0,15,0,110+G+15)
I.BackgroundTransparency=1
I.BorderSizePixel=0
I.ScrollBarThickness=8
I.ScrollBarImageColor3=Color3.fromRGB(100,100,140)
I.ScrollingDirection=Enum.ScrollingDirection.X
I.CanvasSize=UDim2.new(0,0,0,0)
I.Parent=A

local J=Instance.new"UIListLayout"
J.FillDirection=Enum.FillDirection.Horizontal
J.SortOrder=Enum.SortOrder.LayoutOrder
J.Padding=UDim.new(0,10)
J.Parent=I

for K,L in ipairs(z.images)do
local M=Instance.new"ImageLabel"
M.Size=UDim2.new(0,300,0,169)
M.BackgroundTransparency=1
M.Image=L
M.Parent=I

local N=Instance.new"UICorner"
N.CornerRadius=UDim.new(0,8)
N.Parent=M

addBlur(M)
end

local K=#z.images
I.CanvasSize=UDim2.new(0,(300*K)+(10*(K-1)),0,169)
H=H+180+15
end

F.Size=UDim2.new(1,-280,0,G)
A.Size=UDim2.new(1,0,0,G+H)

A.Parent=v
local J=c:Create(A,TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
BackgroundTransparency=0
})
J:Play()

task.spawn(function()
task.wait(0.1)
local K=F.TextBounds.Y
if K~=G then
F.Size=UDim2.new(1,-280,0,K)
if I then
I.Position=UDim2.new(0,15,0,110+K+15)
end
local L=H-G+K
A.Size=UDim2.new(1,0,0,K+L)
v.CanvasSize=UDim2.new(0,0,0,w.AbsoluteContentSize.Y+30)
end
end)
end

for z,A in ipairs(e)do
createUpdateEntry(A)
task.wait(0.1)
end

task.wait()
v.CanvasSize=UDim2.new(0,0,0,w.AbsoluteContentSize.Y+30)

r.MouseButton1Click:Connect(function()
local z=c:Create(n,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{
Position=UDim2.new(0.5,0,1.05,0),
BackgroundTransparency=1
})
z:Play()
z.Completed:Connect(function()
m:Destroy()
save()
end)
end)
end

j:CreateNotification(
"New Patch Note!",
"A new patch note ("..(g.title or"v"..g.updateLogId)..") is available! Open the changelog?",
true,
function()
createChangelogUI()
end,
function()
save()
shared.UPDATE_LOG_EXECUTED=false
end
)