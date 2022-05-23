--Default Tile object and properties.
local Tile = {
    color="blue",
    type="hex", -- not used yet
    decoration="blank", --not used yet
    depth=0 --not used yet
}


--Constructor
--Args will default to property values above, or can pass parameters directly
function Tile:new( ... )

    --Create a local table for new tile instance and set Meta and Index
    local newTile = ... or {}
    setmetatable( newTile, self )
    self.__index = self

    --Set up new display group with image and label for this tile instance
    newTile.group = display.newGroup()
    newTile.image = newTile:setImage(newTile.color.."Tile.png")
    newTile.label = newTile:setLabel()
    newTile.group:insert(newTile.image)
    newTile.group:insert(newTile.label)

    return newTile -- return new tile instance

end


--Display an image based on the Tile's type property
--Requires: String of image to be used
function Tile:setImage(filename)
    return display.newImageRect(filename, self.settings.tileWidth, self.settings.tileHeight )
end


--Add a label to the group. Helpful for debug purposes.
function Tile:setLabel()
    local options =
    {
        text = label or "",
        font = native.systemFont,
        fontSize = 20,
    }
    return display.newText( options )
end


--Add some extra depth to the tile
--Requires an amount to drop in depth
function Tile:setDepth(passedDepth)
    local newDepth = passedDepth or self.depth
    self.group.y = self.group.y + newDepth
end


return Tile -- return the Tile instance
