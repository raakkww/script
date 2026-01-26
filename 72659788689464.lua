local Services=setmetatable({},{__index=function(Self,Name)
	Self[Name]=game:GetService(Name)
	return Self[Name]
end})

local Players=Services.Players
local Workspace=Services.Workspace
local ReplicatedStorage=Services.ReplicatedStorage
local LocalPlayer=Players.LocalPlayer
local Camera=Workspace.CurrentCamera

local Target=nil
local CanShoot=true
local RemoteEvent=ReplicatedStorage.Events.RemoteEvent

local o;o=hookmetamethod(game,"__namecall",newcclosure(function(...)
	local Arguments={...}
	local Method=getnamecallmethod()
	
	if not checkcaller() and Arguments[1]==RemoteEvent and Method=="FireServer" and Arguments[2]==14 and Target and typeof(Target)=="Instance" and CanShoot then
		local BulletTable=Arguments[4]
		if type(BulletTable)=="table" and BulletTable[1] then
			local BulletData=BulletTable[1]
			if type(BulletData)=="table" and type(BulletData[4])=="userdata" then
				local StartPosition=Camera.CFrame.Position
				local TargetPosition=Target.Position
				local Direction=(TargetPosition-StartPosition).Unit
				
				BulletData[1]=StartPosition
				BulletData[2]=StartPosition+(Direction*10)
				BulletData[3]=TargetPosition
				BulletData[4]=Target
				BulletData[5]=TargetPosition
				BulletData[6]=Vector3.new(0,0,0)
			end
		end
	end
	
	return o(...)
end))

Services.RunService.RenderStepped:Connect(function()
	local Character=LocalPlayer.Character
	if not Character then Target=nil return end
	local Root=Character:FindFirstChild("HumanoidRootPart")
	if not Root then Target=nil return end
	
	local Closest=nil
	local Distance=math.huge
	
	for _,Player in Players:GetPlayers() do
		if Player==LocalPlayer then continue end
		if Player.Team and LocalPlayer.Team and Player.Team==LocalPlayer.Team then continue end
		local TargetCharacter=Player.Character
		if not TargetCharacter then continue end
		local TargetHumanoid=TargetCharacter:FindFirstChildOfClass("Humanoid")
		if not TargetHumanoid or TargetHumanoid.Health<=0 then continue end
		local TargetHead=TargetCharacter:FindFirstChild("Head")
		if not TargetHead then continue end
		local Dist=(Root.Position-TargetHead.Position).Magnitude
		if Dist<Distance then
			Distance=Dist
			Closest=TargetHead
		end
	end
	
	Target=Closest
	
	if Target then
		local Params=RaycastParams.new()
		Params.FilterDescendantsInstances={Character,Target.Parent}
		Params.FilterType=Enum.RaycastFilterType.Exclude
		
		local Origin=Root.Position
		local Destination=Target.Position
		local Direction=(Destination-Origin)
		
		local WallCheck=Workspace:Raycast(Origin,Direction,Params)
		
		CanShoot=not WallCheck
	else
		CanShoot=false
	end
end)

warn("ok")
