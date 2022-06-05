--Default Tile object and properties.
local Tile = {
    type="grass", -- determins what sequence to use in sprite imageSheet
    decoration="blank", --not used yet
    depth=0, -- used as offset on Y-Axis to give impression of depth

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
    newTile.group.anchorChildren = true
    newTile.image = newTile:setImageSheet()
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

function Tile:setImageSheet(imageSheet, options, sequenceData)

    local options = options or
    {
        --required parameters
        width = 256,
        height = 256,
        numFrames = 2,

        --optional parameters; used for scaled content support
        sheetContentWidth = 512,  -- width of original 1x size of entire sheet
        sheetContentHeight = 256  -- height of original 1x size of entire sheet
    }
    local imageSheet = imageSheet or graphics.newImageSheet( "tileSheet.png", options )

    local sequenceData = sequenceData or
    {
        { name="ice", frames={ 1 }, count=1 },
        { name="grass", frames={ 2 }, count=1},
    }

    local sprite = display.newSprite( imageSheet, sequenceData )
    sprite:scale( self.settings.scaleFactor, self.settings.scaleFactor )
    sprite:setSequence(self.type)
    sprite:addEventListener("touch", self) -- adding event listener on the sprite
    sprite:setMask(graphics.newMask( "maskTile.png" )) -- add mask
    return sprite

end


function Tile:touch(e)
    local phase = e.phase
    if phase == ("ended") then
        local event = { name="activateTile", message="activate", target=self } -- self is the Tile instance
        Runtime:dispatchEvent( event )
        return true -- stop propogation
    end
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

function Tile:drawLines(enter, exit)
    local line = display.newLine(
        0, 0-23*self.settings.scaleFactor,
        93*self.settings.scaleFactor, 33*self.settings.scaleFactor,
        93*self.settings.scaleFactor,33*self.settings.scaleFactor+self.settings.frontHeight
    )
    --line:append( 305,165, 243,216, 265,290, 200,245, 135,290, 157,215, 95,165, 173,165, 200,90 )
    line:setStrokeColor( 1, 0, 0, 1 )
    line.strokeWidth = 2
    self.group:insert(line)

    --line.parent:insert( line )
end


return Tile -- return the Tile instance
