local ServerStorage = game:GetService("ServerStorage")
ServerStorage:WaitForChild("Modules")
local RoomModule = require(ServerStorage.Modules.RoomModule)
local DungeonRoom = require(ServerStorage.Modules.RoomModule.DungeonRoom)

local Rooms = ServerStorage:WaitForChild("Rooms"):GetChildren()

local room = RoomModule.NewRoom(Rooms[1], CFrame.new(Vector3.new(50, 0.5, 10)), "Hello", workspace.Folder)
task.wait(2)
local Dungeon = DungeonRoom.ConvertToDungeon(room)
Dungeon:Start()

task.wait(4)

print("Players:", Dungeon.Room:GetPlayersInRoom())
print("Enemies:", Dungeon.Enemies)
print("Characters:", Dungeon.Room:GetCharactersInRoom())

Dungeon:ConnectToWin(function()
	print("Players Won")
end)
Dungeon:ConnectToFail(function()
	print("Players Failed!")
end)

-- Utilize additional features
Dungeon:EliminateEnemies()
task.wait(1)

Dungeon:EliminatePlayers()
task.wait(1)

Dungeon:UnanchorEnemies()
task.wait(1)

Dungeon:ForceWin()
task.wait(1)

print("Remaining Enemies:", Dungeon.Enemies)

task.wait(5)

Dungeon:Reset()

task.wait(1)

print("Players:", Dungeon.Room:GetPlayersInRoom())
print("Enemies:", Dungeon.Enemies)
print("Characters:", Dungeon.Room:GetCharactersInRoom())

Dungeon:Start()

task.wait(4)

print("Players after reset:", Dungeon.Room:GetPlayersInRoom())
print("Enemies after reset:", Dungeon.Enemies)
print("Characters after reset:", Dungeon.Room:GetCharactersInRoom())

Dungeon:ForceFail()
task.wait(1)

print("Remaining Enemies after force fail:", Dungeon.Enemies)
