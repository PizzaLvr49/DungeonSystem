local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local RoomModule = {}

export type Room = {
	Name: string,
	Model: Model,
	OriginalModel: Model,
	GetCharactersInRoom: (Room) -> {Model?},
	GetPlayersInRoom: (Room) -> {Model?},
	GetTaggedInRoom: (Room, Tag: string) -> {Model?}
}

function RoomModule.NewRoom(Model: Model, Frame: CFrame, Name: string, Parent: Instance): Room
	-- Argument Checks
	assert(Model, "Model Is Nil")
	assert(Frame, "Frame Is Nil")
	assert(Parent, "Parent Is Nil")

	-- Initialization
	local NewRoom = {
		Name = Name or "Room",
		OriginalModel = Model,
		Model = Model:Clone()
	}
	NewRoom.Model:PivotTo(Frame)
	NewRoom.Model.Name = NewRoom.Name
	NewRoom.Model.Parent = Parent

	for _, Part in NewRoom.Model:GetDescendants() do
		if Part:IsA("BasePart") then
			Part.Anchored = true
		end
	end

	-- Functions
	function RoomModule:DebugBoundingBox(ModelBoundsFrame, ModelBoundsSize)
		if not RunService:IsStudio() then warn("Debugging is only meant for developmental purposes") end
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

	function NewRoom:GetCharactersInRoom(): {Model?}
		local ModelBoundsFrame, ModelBoundsSize = self.Model:GetBoundingBox()
		if RunService:IsStudio() then
			self:DebugBoundingBox(ModelBoundsFrame, ModelBoundsSize)
		end

		local PartsInRoom = workspace:GetPartBoundsInBox(ModelBoundsFrame, ModelBoundsSize)
		local CharacterList = {}

		for _, Part in PartsInRoom do
			local PartModel = Part:FindFirstAncestorOfClass("Model")
			if PartModel and PartModel:FindFirstChildOfClass("Humanoid") and PartModel ~= self.Model then
				if not table.find(CharacterList, PartModel) then
					table.insert(CharacterList, PartModel)
				end
			end
		end
		return CharacterList
	end 

	function NewRoom:GetPlayersInRoom(): {Model?}
		local PlayersList = {}
		for _, Character in self:GetCharactersInRoom() do
			local Player = Players:GetPlayerFromCharacter(Character)
			if Player and Player.Character then
				table.insert(PlayersList, Player.Character)
			end
		end
		return PlayersList
	end

	function NewRoom:GetTaggedInRoom(Tag: string): {Model?}
		local TaggedList = {}
		for _, Character in self:GetCharactersInRoom() do
			if Character and Character:HasTag(Tag) then
				table.insert(TaggedList, Character)
			end
		end
		return TaggedList
	end

	return NewRoom
end

return RoomModule
