--Default Tile object and properties.
local Tile = {
    type = "plant",
    base = "grass", -- determins what sequence to use in sprite imageSheet
    decor = "yellow", --not used yet
    depth = 0, -- used as offset on Y-Axis to give impression of depth
    row = 0,
    col = 0,
    array = {}
}


--Constructor
--Args will default to property values above, or can pass parameters directly
function Tile:new( ... )

    --Create a local table for new tile instance and set Meta and Index
    local newTile = ... or {}
    setmetatable( newTile, self )
    self.__index = self

    --Set up new display group with baseImage and label for this tile instance
    newTile.group = display.newGroup()
    newTile.group.anchorChildren = true
    newTile.baseImage = newTile:baseImageSheet()
    newTile.label = newTile:setLabel(--[[newTile.depth]])
    newTile.outline = newTile:setImage("outlineTile.png")
    newTile.decorImage = newTile:decorImageSheet()
    newTile.group:insert(newTile.baseImage)
    newTile.group:insert(newTile.decorImage)
    newTile.group:insert(newTile.label)
    newTile.group:insert(newTile.outline)
    newTile.outline.alpha=0
    return newTile -- return new tile instance

end


--Display an image based on the Tile's base property
--Requires: String of image to be used
function Tile:setImage(filename)
    return display.newImageRect(filename, self.settings.tileWidth, self.settings.tileHeight )
end

function Tile:baseImageSheet(imageSheet, options, sequenceData)

    local options = options or
    {
        --required parameters
        width = 256,
        height = 256,
        numFrames = 3,

        --optional parameters; used for scaled content support
        sheetContentWidth = 768,  -- width of original 1x size of entire sheet
        sheetContentHeight = 256  -- height of original 1x size of entire sheet
    }
    local imageSheet = imageSheet or graphics.newImageSheet( "tileSheet.png", options )

    local sequenceData = sequenceData or
    {
        { name="ice",   frames={ 1 },     count=1},
        { name="grass", frames={ 2 },     count=1},
        { name="dirt",  frames={ 3 },     count=1},
    }

    local sprite = display.newSprite( imageSheet, sequenceData )
    sprite:scale( self.settings.scaleFactor, self.settings.scaleFactor )
    sprite:setSequence(self.base)
    sprite:addEventListener("touch", self) -- adding touch event listener on the sprite
    sprite:addEventListener("updateBase", self) -- adding update base event listener on the sprite
    sprite:setMask(graphics.newMask( "maskTile4px.png" )) -- add mask
    return sprite

end


function Tile:decorImageSheet(imageSheet, options, sequenceData)

    local options = options or
    {
        --required parameters
        width = 254,
        height = 220,
        numFrames = 3,

        --optional parameters; used for scaled content support
        sheetContentWidth = 763,  -- width of original 1x size of entire sheet
        sheetContentHeight = 220  -- height of original 1x size of entire sheet
    }
    local imageSheet = imageSheet or graphics.newImageSheet( "decorPlant.png", options )

    local sequenceData = sequenceData or
    {
        { name="blue",   frames={ 1 },     count=1},
        { name="red",    frames={ 2 },     count=1},
        { name="yellow", frames={ 3 },     count=1},
    }

    local sprite = display.newSprite( imageSheet, sequenceData )
    sprite:scale( self.settings.scaleFactor, self.settings.scaleFactor )
    sprite.y = sprite.y - 17 -- temproary placement - testing for height overlapping
    sprite:setSequence(self.decor)
    sprite:addEventListener("updateDecor", self) -- adding update decor event listener on the sprite
    return sprite

end

--Listener for when this tile is activated via touch or click
--Requires a touch event to be dispatched
--The event listener is added where the imagesheet is created
function Tile:touch(e)
    local phase = e.phase
    if phase == ("ended") then
        local event = { name="activateTile", target=self } -- self is the Tile instance
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
    self.baseImage:setFillColor(1, 1, 1, (1-(self.depth/self.settings.frontHeight)*0.20)) -- reduce opacity for deeper groups.
end


--Draws some lines outward from the center of the tile and then vertically down the edge
function Tile:drawLines(enter, exit)
    local line = display.newLine(
        0, 0-23*self.settings.scaleFactor,
        93*self.settings.scaleFactor, 33*self.settings.scaleFactor,
        93*self.settings.scaleFactor,33*self.settings.scaleFactor+self.settings.frontHeight
    )
    line:setStrokeColor( 1, 0, 0, 1 )
    line.strokeWidth = 2
    self.group:insert(line)
end


--Returns the adjacent row and col values of a particular side
--Requires side - a string of value N, S, NW, NE, SW or SE
function Tile:getAdjacent(side)
      local mod = math.fmod(self.col,2) -- use Modulo to determine if it's an even or odd column
      local adjacents = {
            N = {self.row-1,self.col},
            S = {self.row+1,self.col},
            NW = {self.row-mod,self.col-1},
            SW = {self.row+1-mod,self.col-1},
            SE = {self.row+1-mod,self.col+1},
            NE = {self.row-mod,self.col+1}
      }
      if side then
            local row, col = adjacents[side][2],adjacents[side][1]
            return row, col, adjacents
      else
            return adjacents
      end
end


--Turns off visibility of the outline on the tile
function Tile:unhighlight()
      self.outline.alpha = 0
end


--Turns on the highlight of the tile in focus - and associates focusTile in settings
--Optional r,g,b,a - decimal fraction values for specific colour settings
function Tile:highlight(r, g, b, a)
      self.settings.focusTile = self
      self.outline.alpha = a or 0.75
      self.outline:setFillColor( r or 1, g or 1, b or 1 )
end


--Updates the tile base and respectively the image sequence of that tile
--Requires: base -- a string matching a sequence data entry for the Tile image
function Tile:updateBase(base)
      self.base = base
      self.baseImage:setSequence(base)
      return true
end


--Updates the tile decor and respectively the image sequence of that tile
--Requires: decor -- a string matching a sequence data entry for the Tile image
function Tile:updateDecor(decor)
      self.decor = decor
      self.decorImage:setSequence(decor)
      return true
end

return Tile -- return the Tile instance
