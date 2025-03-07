local Players = game:GetService("Players")
local Runservice = game:GetService("RunService")

local RoomModule = {}

export type Room = {
	Name: string,
	Model: Model,
	GetCharactersInRoom: (Room) -> {Model?},
	GetPlayersInRoom: (Room) -> {Model?},
	GetTaggedInRoom: (Room, Tag: string) -> {Model?}
}

function RoomModule.NewRoom(Model: Model, Frame: CFrame, Name: string, Parent: Instance) : Room
	-- Argument Checks
	if not Model then error("Model Is Nil") end
	if not Frame then error("Frame Is Nil") end
	if not Parent then error("Parent Is Nil") end

	-- Initialization
	local NewRoom = {} -- Explicitly define the type here
	NewRoom.Name = Name or "Room"
	NewRoom.Model = Model:Clone()
	NewRoom.Model:PivotTo(Frame)
	NewRoom.Model.Name = Name
	NewRoom.Model.Parent = Parent
	for _, Part in NewRoom.Model:GetDescendants() do
		if Part:IsA("BasePart") then
			Part.Anchored = true
		end
	end

	-- Functions
	function NewRoom:GetCharactersInRoom() : {Model?}
		local ModelBoundsFrame, ModelBoundsSize = self.Model:GetBoundingBox()
		-- Debug Bounding Box
		if Runservice:IsStudio() then
			local DebugPart = self.Model:FindFirstChild("DebugPart") or Instance.new("Part", self.Model)
			DebugPart.Name = "DebugPart"
			DebugPart.Size = ModelBoundsSize
			DebugPart.CFrame = ModelBoundsFrame
			DebugPart.Anchored = true
			DebugPart.CanCollide = false
			DebugPart.Transparency = 0.75
			DebugPart.Material = Enum.Material.SmoothPlastic
			DebugPart.Color = Color3.new(0, 1, 0)
		end
		local PartsInRoom = workspace:GetPartBoundsInBox(ModelBoundsFrame, ModelBoundsSize)
		local CharacterList: {Model?} = {}
		for _, Part in PartsInRoom do
			local PartModel = Part:FindFirstAncestorOfClass("Model")
			if not PartModel then continue end
			if not PartModel:FindFirstChildOfClass("Humanoid") then continue end
			if PartModel == self.Model then continue end
			if table.find(CharacterList, PartModel) then continue end
			table.insert(CharacterList, PartModel)
		end
		return CharacterList
	end 

	function NewRoom:GetPlayersInRoom() : {Model?}
		local CharacterList = self:GetCharactersInRoom()
		local PlayersList: {Model?} = {}
		for _, Character in CharacterList do
			if Character then
				local Player = Players:GetPlayerFromCharacter(Character)
				if not Player or not Player.Character then continue end
				table.insert(PlayersList, Player.Character)
			end
		end
		return PlayersList
	end

	function NewRoom:GetTaggedInRoom(Tag: string) : {Model?}
		local CharacterList = self:GetCharactersInRoom()
		local TaggedList: {Model?} = {}
		for _, Character in CharacterList do
			if Character and Character:HasTag(Tag) then
				table.insert(TaggedList, Character)
			end
		end
		return TaggedList
	end

	return NewRoom
end

return RoomModule
