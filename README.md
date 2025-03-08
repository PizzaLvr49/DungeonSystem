# DungeonSystem

DungeonSystem is a Roblox module designed to manage dungeon rooms, including creating rooms, handling players and enemies within those rooms, and managing dungeon states like win and fail conditions.

## Features

- Create and manage rooms.
- Track players and enemies within rooms.
- Handle dungeon start, reset, win, and fail states.
- Debugging tools for visualizing room boundaries in Studio mode.

## Installation

1. Clone the repository to your local machine.
2. Place the `Modules` folder in your Roblox game's `ServerStorage`.

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

### Handling Dungeon Events

```lua
dungeon:ConnectToWin(function()
    print("Players Won")
end)

dungeon:ConnectToFail(function()
    print("Players Failed!")
end)
```

### Debugging

In Studio mode, bounding boxes for rooms can be visualized:

```lua
RoomModule:DebugBoundingBox(ModelBoundsFrame, ModelBoundsSize)
```

## Contributing

If you would like to contribute to this project, please fork the repository and submit a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
