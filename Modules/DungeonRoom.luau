local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RoomModule = require(script.Parent)

local DungeonRoom = {}

export type Dungeon = {
	Name: string,
	Room: RoomModule.Room,
	State: string,
	Enemies: {Humanoid?},
	ForceWin: (Dungeon) -> (),
	ForceFail: (Dungeon) -> (),
	ConnectToWin: (Dungeon, callback: () -> any) -> (),
	ConnectToFail: (Dungeon, callback: () -> any) -> (),
	Start: (Dungeon) -> (),
	Pause: (Dungeon) -> (),
	Resume: (Dungeon) -> (),
	Reset: (Dungeon) -> (),
	EliminateEnemies: (Dungeon) -> (),
	EliminatePlayers: (Dungeon) -> (),
	UnanchorEnemies: (Dungeon) -> (),
	SetTimer: (Dungeon, duration: number) -> (),
	UpdateTimer: (Dungeon) -> (),
	HandlePlayerJoin: (Dungeon, player: Player) -> (),
	HandlePlayerLeave: (Dungeon, player: Player) -> (),
	AddScore: (Dungeon, points: number) -> (),
	GetScore: (Dungeon) -> number,
}

DungeonRoom.ConvertToDungeon = function(Room: RoomModule.Room): Dungeon
	local NewDungeon = {
		Name = Room.Name,
		Room = Room,
		Enemies = {},
		State = "Inactive",
		RoomWinListeners = {},
		RoomFailListeners = {},
		RoomPausedListeners = {},
		RoomResumedListeners = {},
		Timer = 0,
		Score = 0,
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

	function NewDungeon:ConnectToPause(callback: () -> any)
		table.insert(self.RoomPausedListeners, callback)
	end

	function NewDungeon:ConnectToResume(callback: () -> any)
		table.insert(self.RoomResumedListeners, callback)
	end

	function NewDungeon:Start()
		self.State = "Started"
		self:UnanchorEnemies()
		self:SetTimer(300) -- Example: 5-minute timer
	end

	function NewDungeon:Pause()
		if self.State == "Started" then
			self.State = "Paused"
			for _, CallBack in pairs(self.RoomPausedListeners) do
				CallBack()
			end
		else
			warn("Room is not in a state that can be paused")
		end
	end

	function NewDungeon:Resume()
		if self.State == "Paused" then
			self.State = "Started"
			for _, CallBack in pairs(self.RoomResumedListeners) do
				CallBack()
			end
		else
			warn("Room is not in a state that can be resumed")
		end
	end

	function NewDungeon:SetTimer(duration: number)
		self.Timer = duration
		RunService.Heartbeat:Connect(function()
			if self.State == "Started" then
				self:UpdateTimer()
			end
		end)
	end

	function NewDungeon:UpdateTimer()
		if self.Timer > 0 then
			self.Timer = self.Timer - 1
			if self.Timer == 0 then
				self:ForceFail()
			end
		end
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
		self.Score = 0
		self.Timer = 0
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

	function NewDungeon:HandlePlayerJoin(player: Player)
		print(player.Name .. " joined the dungeon")
		-- Add player-specific initialization if needed
	end

	function NewDungeon:HandlePlayerLeave(player: Player)
		print(player.Name .. " left the dungeon")
		-- Handle player leaving the dungeon
	end

	function NewDungeon:AddScore(points: number)
		self.Score = self.Score + points
	end

	function NewDungeon:GetScore(): number
		return self.Score
	end

	NewDungeon:InitEnemies()
	print("Room Enemies:", NewDungeon.Enemies)

	return NewDungeon
end

return DungeonRoom
