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
    newTile.image = newTile:setImageSheet(newTile.color.."Tile.png")
    newTile.label = newTile:setLabel(--[[newTile.depth]])
    newTile.group:insert(newTile.image)
    newTile.group:insert(newTile.label)

    return newTile -- return new tile instance

end


--Display an image based on the Tile's type property
--Requires: String of image to be used
function Tile:setImage(filename)
    return display.newImageRect(filename, self.settings.tileWidth, self.settings.tileHeight )
end

function Tile:setImageSheet()

    local options =
    {
        --required parameters
        width = 256,
        height = 256,
        numFrames = 2,

        --optional parameters; used for scaled content support
        sheetContentWidth = 512,  -- width of original 1x size of entire sheet
        sheetContentHeight = 256  -- height of original 1x size of entire sheet
    }
    local imageSheet = graphics.newImageSheet( "tileSheet.png", options )

    local sequenceData =
    {
        { name="ice", frames={ 1 }, count=1 },
        { name="grass", frames={ 2 }, count=1},
    }

    local tile = display.newSprite( imageSheet, sequenceData )
    tile:scale( 0.5, 0.5 )
    tile:setSequence("grass")
    tile:play()
    return tile

end

--Add a label to the group. Helpful for debug purposes.
function Tile:setLabel(label)
    local options =
    {
        text = label or "",
        font = native.systemFont,
        fontSize = 20,
    }
    return display.newText( options )
end

--Update the group's label. Helpful for debug purposes.
function Tile:updateLabel(label)
    self.label.text = label
end


--Add some extra depth to the tile
--Requires an amount to drop in depth
function Tile:setDepth(passedDepth)
    local newDepth = passedDepth or self.depth
    self.depth = newDepth
    self.group.y = self.group.y + self.depth -- move the group down by new depth amount
    --self:updateLabel(1-(self.depth/self.settings.frontHeight)*0.20) -- optional update label
    self.image:setFillColor(1, 1, 1, (1-(self.depth/self.settings.frontHeight)*0.20)) -- reduce opacity for deeper groups.
end


return Tile -- return the Tile instance
