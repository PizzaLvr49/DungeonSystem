# DungeonSystem

DungeonSystem is a Roblox module employed to manage dungeon rooms, including creating rooms, managing players and enemies in the rooms, and managing dungeon states like win and fail states.

## Features

- Create and manage rooms.
- Track players and enemies in rooms.
- Manage start, reset, win, and fail states of dungeons.
- Debugging features for visualizing room boundaries in Studio mode.

## Installation

1. Place the `Modules` folder in your Roblox game's `ServerStorage`.

## Usage

### Creating a New Room

```lua
local ServerStorage = game:GetService("ServerStorage")
local RoomModule = require(ServerStorage.Modules.RoomModule)

local Rooms = ServerStorage:WaitForChild("Rooms"):GetChildren()
local newRoom = RoomModule.NewRoom(Rooms[1], CFrame.new(Vector3.new(50, 0.5, 10)), "RoomName", workspace.Folder)
```

### Converting a Room to a Dungeon

```lua
local DungeonRoom = require(ServerStorage.Modules.DungeonRoom)
local dungeon = DungeonRoom.ConvertToDungeon(newRoom)
dungeon:Start()
```

### Dungeon Event Handling

```lua
dungeon:ConnectToWin(function()
    print("Players Won")
end)

dungeon:ConnectToFail(function()
    print("Players Failed!")
end)
```

### Debugging

In Studio mode, room bounding boxes can be drawn:

```lua
RoomModule:DebugBoundingBox(ModelBoundsFrame, ModelBoundsSize)
```
