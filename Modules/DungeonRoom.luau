local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RoomModule = require(script.Parent)

local DungeonRoom = {}

export type Dungeon = {
	Name: string,
	Room: RoomModule.Room,
	State: string,
	Enemies: {Humanoid?},
	ForceWin: (Dungeon) -> nil,
	ForceFail: (Dungeon) -> nil,
	ConnectToWin: (Dungeon, callback: () -> any) -> nil,
	ConnectToFail: (Dungeon, callback: () -> any) -> nil,
	Start: (Dungeon) -> nil,
	Reset: (Dungeon) -> nil
}

DungeonRoom.ConvertToDungeon = function(Room: RoomModule.Room): Dungeon
	local NewDungeon = {
		Name = Room.Name,
		Room = Room,
		Enemies = {},
		State = "Inactive",
		RoomWinListeners = {},
		RoomFailListeners = {}
	}

	function NewDungeon:ForceWin()
		if self.State ~= "Started" then
			warn("Room Has Not Been Started Yet or Has Already Been Completed")
			return
		end
		for _, CallBack in pairs(self.RoomWinListeners) do
			CallBack()
		end
		self.Room.State = "Win"
		self:EliminateEnemies()
	end

	function NewDungeon:ForceFail()
		if self.State ~= "Started" then
			warn("Room Has Not Been Started Yet")
			return
		end
		self:EliminatePlayers()
		for _, CallBack in pairs(self.RoomFailListeners) do
			CallBack()
		end
		self.State = "Fail"
	end

	function NewDungeon:ConnectToWin(callback: () -> any)
		table.insert(self.RoomWinListeners, callback)
	end

	function NewDungeon:ConnectToFail(callback: () -> any)
		table.insert(self.RoomFailListeners, callback)
	end

	function NewDungeon:Start()
		self.State = "Started"
		self:UnanchorEnemies()
	end

	function NewDungeon:Reset()
		self.State = "Inactive"
		local Parent = self.Room.Model.Parent
		local Pivot = self.Room.Model:GetPivot()
		self.Room.Model:Destroy()
		self.Room.Model = self.Room.OriginalModel:Clone()
		self.Room.Model:PivotTo(Pivot)
		self.Room.Model.Name = self.Name
		self.Room.Model.Parent = Parent
		self:InitEnemies()
	end

	function NewDungeon:InitEnemies()
		for _, V in self.Room.Model:GetDescendants() do
			if V:IsA("Humanoid") then
				table.insert(self.Enemies, V)
				V:GetPropertyChangedSignal("Health"):Connect(function()
					if V.Health <= 0 then
						self:EnemyDied(V)
					end
				end)
			end
		end
	end

	function NewDungeon:EnemyDied(enemy)
		print(enemy.Parent.Name .. " Died")
		table.remove(self.Enemies, table.find(self.Enemies, enemy))
		if #self.Enemies == 0 then
			self:ForceWin()
		end
		task.wait(3)
		enemy.Parent:Destroy()
	end

	function NewDungeon:EliminateEnemies()
		for _, Enemy in self.Enemies do
			if Enemy then
				Enemy.Health = 0
			end
		end
	end

	function NewDungeon:EliminatePlayers()
		for _, Player in self.Room:GetPlayersInRoom() do
			local Humanoid = Player:FindFirstChildOfClass("Humanoid")
			if Humanoid then
				Humanoid.Health = 0
			end
		end
	end

	function NewDungeon:UnanchorEnemies()
		for _, Enemy in self.Enemies do
			for _, Part in Enemy.Parent:GetDescendants() do
				if Part:IsA("BasePart") then
					Part.Anchored = false
				end
			end
		end
	end

	NewDungeon:InitEnemies()
	print("Room Enemies:", NewDungeon.Enemies)

	return NewDungeon
end

return DungeonRoom
