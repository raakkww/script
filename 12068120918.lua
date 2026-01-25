--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]

local a=(function()
for a,b in next,getloadedmodules()do
if b:GetFullName():match"NetworkClient"then
return require(b)
end
end
end)()

local b=(function()
for b,c in next,debug.getupvalue(a.getEvent,5)do
return c
end
end)()

local c
c=hookfunction(b,function(d,...)
if d.eventName=="SelfReport"then
return
end

return c(d,...)
end)


game:GetService"Debris"
local d=game:GetService"Players"
game:GetService"CoreGui"
local e=game:GetService"RunService"
game:GetService"HttpService"
local f=game:GetService"UserInputService"


local g=workspace.CurrentCamera
local h=d.LocalPlayer
local i=f:GetMouseLocation()


local j=e.RenderStepped


local k={
Draw=function(k:string,l:{}?):Instance|boolean
local m,n=pcall(Drawing.new,k)

if not m then
return false
end

if l then
for o,p in next,l do
local q,r=pcall(function()
(n::any)[o]=p
end)

if not q then
warn(r)
return false
end
end
end

return n
end,

Create=function(k:string,l:{}?,m:{}?):Instance|boolean
local n,o=pcall(Instance.new,k)

if not n then
return false
end

if l then
for p,q in next,l do
local r,s=pcall(function()
(o::any)[p]=q
end)

if not r then
warn(s)
return false
end
end
end

if m then
for p,q in pairs(m)do
o:SetAttribute(p,q)
end
end

return o
end,

InRadius=function(k:Vector2,l:number):boolean
local m=f:GetMouseLocation()
return(k-m).Magnitude<=l
end,

Direction=function(k:Vector3,l:Vector3):Vector3
return(l-k).Unit*1000
end,

Chance=function(k:number):boolean
k=math.floor(k)
local l=math.floor(Random.new().NextNumber(Random.new(),0,1)*100)/100
return l<=k/100
end,

GetRaycastParams=function():RaycastParams
local k=RaycastParams.new()
k.FilterType=Enum.RaycastFilterType.Blacklist
k.IgnoreWater=true
k.FilterDescendantsInstances={h.Character,g,workspace.CompanyFlags}

return k
end,
}


local l={
Config={
Enabled=false,

Hitpart="Head",
Hitchance=100,
DistanceLimit=500,

TeamCheck=false,
VisibleCheck=false,
FlagBearerPriority=false,
},

FOVConfig={
Enabled=false,
Outline=false,
Visible=false,
Filled=false,

Radius=100,
Thickness=1,
NumSides=30,
Transparency=1,

Color=Color3.new(1,1,1)
},

LineConfig={
Enabled=false,
Outline=false,

Thickness=1,
Transparency=1,
Color=Color3.new(1,1,1),
},

TargetIndicator={
Enabled=false,

Flags={"Name","Distance","Health","Hitchance","Flagbearer"},
},

Line=k.Draw("Line",{
ZIndex=11,
Visible=false,
}),

LineOutline=k.Draw("Line",{
ZIndex=10,
Visible=false,
Color=Color3.new(0,0,0),
}),

FOVCircle=k.Draw("Circle",{
ZIndex=11,
Visible=false,
}),

FOVCircleOutline=k.Draw("Circle",{
ZIndex=10,
Visible=false,
Color=Color3.new(0,0,0),
}),

Indicator=k.Draw("Text",{
Size=18,
Center=false,
Outline=true,
Visible=false,
Color=Color3.new(1,1,1),
Position=Vector2.new(80,g.ViewportSize.Y/2),
}),

Target=nil,
}

local m={
Config={
Enabled=false,

Lifetime=1,
FadeOut=true,

Color1=Color3.fromRGB(255,255,255),
Color2=Color3.fromRGB(255,255,255),

Transparency1=0,
Transparency2=0,

Texture="rbxassetid://446111271",
TextureLength=1,
TextureSpeed=1,

LightEmission=1,
FaceCamera=true,

Width0=0.5,
Width1=0.5
}
}


l.WallCheck=function(n)
if not l.Config.VisibleCheck then
return true
end

if not n or not n.Parent then
return false
end

local o=workspace:Raycast(g.CFrame.Position,k.Direction(g.CFrame.Position,n.Position),k.GetRaycastParams())

if o then
local p=o.Instance
local q=p:FindFirstAncestorOfClass"Model"
local r=n:FindFirstAncestorOfClass"Model"

return q==r
end

return false
end

l.IsFlagBearer=function(n)
for o,p in next,workspace.CompanyFlags:GetChildren()do
if p.Holder.Value and p.Holder.Value==n then
return true
end
end

return false
end

l.TeamCheck=function(n)
if not l.Config.TeamCheck then
return true
end

return n and n.Team~=h.Team
end

l.Distance=function(n)
local o=(g.CFrame.Position-n.Character:GetPivot().Position).Magnitude
return o<=l.Config.DistanceLimit
end

l.IsAlive=function(n)
return n and n.Character and n.Character:FindFirstChild"Humanoid"and n.Character.Humanoid.Health>0
end

l.GetClosestPlayer=function()
if not l.Config.Enabled then
return nil
end

local n,o,p,q=math.huge,(math.huge)

for r,s in next,d:GetPlayers()do
if s~=h then
local t=s.Character

if t and t:FindFirstChild(l.Config.Hitpart)then
if not l.TeamCheck(s)then
continue
end

if not l.IsAlive(s)then
continue
end

if not l.Distance(s)then
continue
end

local u=t[l.Config.Hitpart]
local v,w=g:WorldToViewportPoint(u.Position)

if w then
local x=Vector2.new(v.X,v.Y)
local y=(i-x).Magnitude

if y<math.min(n,o)then
if not l.FOVConfig.Enabled or k.InRadius(x,l.FOVConfig.Radius)then
if l.WallCheck(u)then
local z=l.IsFlagBearer(s)

if l.Config.FlagBearerPriority and z then
q=s
o=y
elseif not l.Config.FlagBearerPriority then
p=s
n=y
elseif not z then
p=s
n=y
end
end
end
end
end
end
end
end

return(l.Config.FlagBearerPriority and q)or p
end


local function BuildIndicatorText(n,o,p)
local q={}

for r,s in next,l.TargetIndicator.Flags do
if s then
if r=="Name"then
table.insert(q,"Name: "..n.Name)
elseif r=="Health"then
table.insert(q,"Health: "..math.floor(n.Character.Humanoid.Health).."hp")
elseif r=="Distance"then
local t=(g.CFrame.Position-n.Character:GetPivot().Position).Magnitude
table.insert(q,"Distance: "..math.floor(t).."m")
elseif r=="Hitchance"then
table.insert(q,"Hitchance: "..o.."%")
elseif r=="Flagbearer"then
table.insert(q,"Flagbearer: "..tostring(p))
end
end
end

return table.concat(q,"\n")
end

local n={}

table.insert(n,j:Connect(function()
l.Target=l.GetClosestPlayer()
i=f:GetMouseLocation()

if l.FOVConfig.Enabled then
local o=l.FOVCircle
o.Radius=l.FOVConfig.Radius
o.Thickness=l.FOVConfig.Thickness
o.Filled=l.FOVConfig.Filled
o.NumSides=l.FOVConfig.NumSides
o.Color=l.FOVConfig.Color
o.Transparency=l.FOVConfig.Transparency
o.Visible=l.FOVConfig.Visible
o.Position=Vector2.new(i.X,i.Y)

if l.FOVConfig.Outline then
local p=l.FOVCircleOutline
p.Radius=l.FOVConfig.Radius
p.Thickness=l.FOVConfig.Thickness+2
p.NumSides=l.FOVConfig.NumSides
p.Visible=l.FOVConfig.Visible
p.Position=Vector2.new(i.X,i.Y)
else
l.FOVCircleOutline.Visible=false
end
else
l.FOVCircle.Visible=false
l.FOVCircleOutline.Visible=false
end

if l.LineConfig.Enabled then
local o=l.Line
local p=l.LineOutline

local q=l.Target and l.Target.Character and g:WorldToViewportPoint(l.Target.Character[l.Config.Hitpart].Position)

if q then
o.Visible=true
o.Color=l.LineConfig.Color
o.Thickness=l.LineConfig.Thickness
o.Transparency=l.LineConfig.Transparency

o.To=Vector2.new(q.X,q.Y)
o.From=Vector2.new(i.X,i.Y)

if l.LineConfig.Outline then
p.Visible=true
p.Thickness=l.LineConfig.Thickness+2

p.To=Vector2.new(q.X,q.Y)
p.From=Vector2.new(i.X,i.Y)
else
p.Visible=false
end
else
o.Visible=false
p.Visible=false
end
else
l.Line.Visible=false
l.LineOutline.Visible=false
end

if l.TargetIndicator.Enabled then
l.Indicator.Visible=true

if l.Target then
l.Indicator.Text=BuildIndicatorText(l.Target,math.clamp(l.Config.Hitchance,1,99),l.IsFlagBearer(l.Target))

l.Indicator.Position=Vector2.new(40,g.ViewportSize.Y/2)
else
l.Indicator.Visible=false
end
else
l.Indicator.Visible=false
end
end))


local o=(function()
for o,p in pairs(getgc(true))do
if typeof and typeof(p)=="function"then
local q=debug.getinfo(p)

if q and q.source:find"WeaponsProjectilesClient"and q.name=="simulateFirearmProjectile"then
return p
end
end
end
end)()

local p
p=hookfunction(o,function(q,r,s)
if q.isLocal then
local t=q.position

if l.Target and l.Target.Character and k.Chance(l.Config.Hitchance)then
local u=l.Target.Character[l.Config.Hitpart]

if u then
local v=(u.Position-t).Unit

local w=q.velocity.Magnitude
q.velocity=v*w
end
end

local u=p(q,r,s)

local v=q.position

task.spawn(function()
if m.Config.Enabled then
local w=k.Create("Part",{
Anchored=true,
Parent=workspace,
Transparency=1
})

local x=k.Create("Attachment",{
Parent=w,
WorldPosition=t,
})

local y=k.Create("Attachment",{
Parent=w,
WorldPosition=v,
})

local z=k.Create("Beam",{
Parent=w,
Attachment0=x,
Attachment1=y,
Color=ColorSequence.new(m.Config.Color1,m.Config.Color2),
Transparency=NumberSequence.new(m.Config.Transparency1,m.Config.Transparency2),
Texture=m.Config.Texture,
TextureLength=m.Config.TextureLength,
TextureSpeed=m.Config.TextureSpeed,
LightEmission=m.Config.LightEmission,
FaceCamera=m.Config.FaceCamera,
Width0=m.Config.Width0,
Width1=m.Config.Width1
})

task.delay(m.Config.Lifetime,function()
if m.Config.FadeOut then
local A=m.Config.Transparency1
local B=m.Config.Transparency2

for C=0,1,0.1 do
local D=A+(1-A)*C
local E=B+(1-B)*C
z.Transparency=NumberSequence.new(D,E)
task.wait(0.05)
end
end

w:Destroy()
end)
end
end)

return u
end

return p(q,r,s)
end)


local q='https://raw.githubusercontent.com/BlackDisciplesHook/LinoriaLib2/main/'

local r=loadstring(game:HttpGet(q..'Library.lua'))()
local s=loadstring(game:HttpGet(q..'addons/ThemeManager.lua'))()
local t=loadstring(game:HttpGet(q..'addons/SaveManager.lua'))()

local u=r:CreateWindow{
Title='',
Center=true,
AutoShow=true,
TabPadding=0,
MenuFadeTime=0.2
}

local v={
Combat=u:AddTab"Combat",
Visuals=u:AddTab"Visuals",
Settings=u:AddTab"Settings"
}

local w=v.Combat:AddLeftGroupbox'Silent Aim'

w:AddToggle('SilentAimEnabled',{
Text="Enabled",
Default=false,
Callback=function(x)
l.Config.Enabled=x
end
})

w:AddSlider('SilentAimHitchance',{
Text='Hitchance',
Default=100,
Min=1,
Max=100,
Suffix="%",
Rounding=0,
Compact=false,
Callback=function(x)
l.Config.Hitchance=x
end
})

w:AddDropdown('SilentAimAimpart',{
Values={"Head","Torso"},
Multi=false,
Text='Hitpart',
Default="Head",
Callback=function(x)
l.Config.Hitpart=x
end
})

w:AddDivider()

w:AddSlider('SilentAimDistanceLimit',{
Text='Max Distance',
Default=500,
Min=0,
Max=1000,
Rounding=0,
Suffix="m",
Compact=false,
Callback=function(x)
l.Config.DistanceLimit=x
end
})

w:AddLabel'Decrease/Increase':AddKeyPicker('-',{
Default='',
Text='Decrease Distance',
Mode='Toggle',
NoUI=true,
Callback=function()
Options.SilentAimDistanceLimit:SetValue(Options.SilentAimDistanceLimit.Value-10)
r:Notify('Max Distance: '..Options.SilentAimDistanceLimit.Value,1)
end
}):AddKeyPicker('+',{
Default='',
Text='Increase Distance',
Mode='Toggle',
NoUI=true,
Callback=function()
Options.SilentAimDistanceLimit:SetValue(Options.SilentAimDistanceLimit.Value+10)
r:Notify('Max Distance: '..Options.SilentAimDistanceLimit.Value,1)
end
})

w:AddDivider()

w:AddToggle('SilentAimVisibleCheckEnabled',{
Text="Visible Check",
Default=false,
Callback=function(x)
l.Config.VisibleCheck=x
end
})

w:AddToggle('SilentAimTeamCheckEnabled',{
Text="Team Check",
Default=false,
Callback=function(x)
l.Config.TeamCheck=x
end
})

w:AddToggle('SilentAimPrioritiseFlagBearer',{
Text="Prioritise Flag Bearer",
Default=false,
Callback=function(x)
l.Config.FlagBearerPriority=x
end
})

local x=v.Combat:AddRightGroupbox'FOV'

x:AddToggle('SilentAimFOVEnabled',{
Text="Enabled",
Default=false,
Callback=function(y)
l.FOVConfig.Enabled=y
end
})

x:AddToggle('SilentAimFOVVisible',{
Text="Visible",
Default=false,
Callback=function(y)
l.FOVConfig.Visible=y
end
}):AddColorPicker('SilentAimFOVColor',{
Title='Color',
Default=Color3.fromRGB(255,255,255),
Transparency=0,
Callback=function(y,z)
l.FOVConfig.Color=y
end
})

x:AddToggle('SilentAimFOVOutline',{
Text="Outline",
Default=false,
Callback=function(y)
l.FOVConfig.Outline=y
end
})











x:AddDivider()

x:AddSlider('SilentAimFOVRadius',{
Text='Radius',
Default=100,
Min=0,
Max=1000,
Rounding=0,
Suffix="px",
Compact=false,
Callback=function(y)
l.FOVConfig.Radius=y
end
})

x:AddSlider('SilentAimFOVThickness',{
Text='Thickness',
Default=1,
Min=1,
Max=10,
Rounding=0,
Suffix="px",
Compact=false,
Callback=function(y)
l.FOVConfig.Thickness=y
end
})

x:AddSlider('SilentAimFOVNumSides',{
Text='Num Sides',
Default=30,
Min=3,
Max=60,
Rounding=0,
Compact=false,
Callback=function(y)
l.FOVConfig.NumSides=y
end
})

local y=v.Combat:AddLeftGroupbox'Line'

y:AddToggle('SilentAimLineEnabled',{
Text="Enabled",
Default=false,
Callback=function(z)
l.LineConfig.Enabled=z
end
}):AddColorPicker('SilentAimLineColor',{
Title='Color',
Default=Color3.fromRGB(255,255,255),
Transparency=0,
Callback=function(z,A)
l.LineConfig.Color=z
end
})

y:AddToggle('SilentAimLineOutlineEnabled',{
Text="Outline",
Default=false,
Callback=function(z)
l.LineConfig.Outline=z
end
})

y:AddSlider('SilentAimLineThickness',{
Text='Thickness',
Default=1,
Min=1,
Max=10,
Rounding=0,
Suffix="px",
Compact=false,
Callback=function(z)
l.LineConfig.Thickness=z
end
})

local z=v.Combat:AddRightGroupbox'Target Indicator'

z:AddToggle('SilentAimIndicatorEnabled',{
Text="Enabled",
Default=false,
Callback=function(A)
l.TargetIndicator.Enabled=A
end
})

z:AddDropdown('SilentAimIndicatorFlags',{
Values=l.TargetIndicator.Flags,
Multi=true,
Text='Flags',
Default={},
Callback=function(A)
l.TargetIndicator.Flags=A
end
})

local A=v.Visuals:AddLeftGroupbox'Bullet Tracers'

A:AddToggle("BulletTracersEnabled",{
Text="Enabled",
Default=m.Config.Enabled,
Callback=function(B)
m.Config.Enabled=B
end
})

A:AddSlider("BulletTracersLifetime",{
Text="Lifetime",
Default=m.Config.Lifetime,
Min=0.1,
Max=10,
Rounding=1,
Callback=function(B)
m.Config.Lifetime=B
end
})

A:AddToggle("BulletTracersFadeOut",{
Text="Fade Out",
Default=m.Config.FadeOut,
Callback=function(B)
m.Config.FadeOut=B
end
})

A:AddLabel"Color 1":AddColorPicker("BulletTracersColor1",{
Text="Color 1",
Default=m.Config.Color1,
Callback=function(B)
m.Config.Color1=B
end
})

A:AddLabel"Color 2":AddColorPicker("BulletTracersColor2",{
Text="Color 2",
Default=m.Config.Color2,
Callback=function(B)
m.Config.Color2=B
end
})

A:AddSlider("BulletTracersTransparency1",{
Text="Transparency 1",
Default=m.Config.Transparency1,
Min=0,
Max=1,
Rounding=2,
Callback=function(B)
m.Config.Transparency1=B
end
})

A:AddSlider("BulletTracersTransparency2",{
Text="Transparency 2",
Default=m.Config.Transparency2,
Min=0,
Max=1,
Rounding=2,
Callback=function(B)
m.Config.Transparency2=B
end
})


A:AddSlider("BulletTracersTextureLength",{
Text="Texture Length",
Default=m.Config.TextureLength,
Min=0.1,
Max=10,
Rounding=1,
Callback=function(B)
m.Config.TextureLength=B
end
})

A:AddSlider("BulletTracersTextureSpeed",{
Text="Texture Speed",
Default=m.Config.TextureSpeed,
Min=0.1,
Max=10,
Rounding=1,
Callback=function(B)
m.Config.TextureSpeed=B
end
})

A:AddSlider("BulletTracersLightEmission",{
Text="Light Emission",
Default=m.Config.LightEmission,
Min=0,
Max=10,
Rounding=2,
Callback=function(B)
m.Config.LightEmission=B
end
})

A:AddToggle("BulletTracersFaceCamera",{
Text="Face Camera",
Default=m.Config.FaceCamera,
Callback=function(B)
m.Config.FaceCamera=B
end
})

A:AddSlider("BulletTracersWidth0",{
Text="Width 0",
Default=m.Config.Width0,
Min=0.1,
Max=5,
Rounding=2,
Callback=function(B)
m.Config.Width0=B
end
})

A:AddSlider("BulletTracersWidth1",{
Text="Width 1",
Default=m.Config.Width1,
Min=0.1,
Max=5,
Rounding=2,
Callback=function(B)
m.Config.Width1=B
end
})

local B=v.Settings:AddLeftGroupbox'Menu'

B:AddToggle('Keybinds',{
Text="Keybinds",
Default=false,
Callback=function(C)
r.KeybindFrame.Visible=C
end
})

B:AddLabel'Menu bind':AddKeyPicker('MenuKeybind',{
Default='RightShift',
NoUI=true,
Text='Menu'
})

r.ToggleKeybind=Options.MenuKeybind

s:SetLibrary(r)
s:SetFolder'84e/Themes'
s:ApplyToTab(v.Settings)
s:ApplyTheme"BDH"

t:SetLibrary(r)
t:SetFolder'84e/Napoleonic Wars'
t:IgnoreThemeSettings()
t:BuildConfigSection(v.Settings)
