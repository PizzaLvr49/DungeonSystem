local ServerStorage = game:GetService("ServerStorage")
ServerStorage:WaitForChild("Modules")
local RoomModule = require(ServerStorage.Modules.RoomModule)
local DungeonRoom = require(ServerStorage.Modules.RoomModule.DungeonRoom)

local Rooms = ServerStorage:WaitForChild("Rooms"):GetChildren()

local room = RoomModule.NewRoom(Rooms[1], CFrame.new(Vector3.new(50, 0.5, 10)), "Hello", workspace.Folder)

task.wait(5)

local Dungeon = DungeonRoom.ConvertToDungeon(room)

print("Players:", Dungeon.Room:GetPlayersInRoom())
print("Enemies:", Dungeon.Enemies)
print("Characters:", Dungeon.Room:GetCharactersInRoom())


Dungeon:ConnectToWin(function()
	print("Players Won")
end)
Dungeon:ConnectToFail(function()
	print("Players Failed!")
end)

Dungeon:Start()
Dungeon:ForceWin()
