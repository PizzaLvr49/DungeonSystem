local Players = game:GetService("Players")
local Runservice = game:GetService("RunService")
local RoomModule = require(script.Parent)

local DungeonRoom = {}

export type Dungeon = {
	Name: string,
	Room: RoomModule.Room,
	State: string,
	Enemies: {Humanoid?},
	ForceWin: () -> nil,
	ForceFail: () -> nil,
	ConnectToWin: (Dungeon, callback: () -> any) -> nil,
	ConnectToFail: (Dungeon, callback: () -> any) -> nil,
	Start: () -> nil
}

DungeonRoom.ConvertToDungeon = function(Room: RoomModule.Room) : Dungeon
	local NewDungeon = {}
	NewDungeon.Name = Room.Name
	NewDungeon.Room = Room
	NewDungeon.Enemies = {}
	NewDungeon.State = "Inactive"
	for _,V in NewDungeon.Room.Model:GetDescendants() do
		local function EnemyDied()
			print(V.Parent.Name.." Died")
			task.wait(3)
			V.Parent:Destroy()
		end
		if V:IsA("Humanoid") then
			table.insert(NewDungeon.Enemies, V)
			V:GetPropertyChangedSignal("Health"):Connect(function()
				local Value = V.Health
				if Value <= 0 then
					EnemyDied()
				end
			end)
		end
	end
	print("Room Enemies:", NewDungeon.Enemies)

	local RoomWinListeners = {}
	local RoomFailListeners = {}

	function NewDungeon:ForceWin()
		if self.Room.State ~= "Started" then warn("Room Has Not Been Started Yet") return end
		for _, Enemy in pairs(self.Room:GetTaggedInRoom("Enemy")) do
			if Enemy then
				local Humanoid = Enemy:FindFirstChildOfClass("Humanoid")
				if not Humanoid then continue end
				Humanoid.Health = 0
			end
		end
		for _, CallBack in pairs(RoomWinListeners) do
			CallBack()
		end
		NewDungeon.Room.State = "Win"
	end

	function NewDungeon:ForceFail()
		if self.Room.State ~= "Started" then warn("Room Has Not Been Started Yet") return end
		for _, Player in pairs(self.Room:GetPlayersInRoom()) do
			if Player then
				local Humanoid = Player:FindFirstChildOfClass("Humanoid")
				if not Humanoid then continue end
				Humanoid.Health = 0
			end
		end
		for _, CallBack in pairs(RoomFailListeners) do
			CallBack()
		end
		self.Room.State = "Fail"
	end

	function NewDungeon:ConnectToWin(callback: () -> any)
		table.insert(RoomWinListeners, callback)
	end

	function NewDungeon:ConnectToFail(callback: () -> any)
		table.insert(RoomFailListeners, callback)
	end

	function NewDungeon:Start()
		self.Room.State = "Started"
		for _,Enemy in self.Enemies do
			for _,Part in Enemy.Parent:GetDescendants() do
				if Part:IsA("BasePart") then
					Part.Anchored = false
				end
			end
		end
	end

	return NewDungeon
end

return DungeonRoom
