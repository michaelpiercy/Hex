--Default Tile object and properties.
local Tile = {
    type = "plant", -- not used yet
    base = "grass", -- determins what sequence to use in sprite imageSheet
    decor = "yellow", -- not used yet
    depth = 0, -- used as offset on Y-Axis to give impression of depth
    row = 0,
    col = 0,
    array = {}, -- record of the hexarray this tile belongs to
    defaultImageSheet = "images/decorPlant.png", -- default imagery to set up baseline
    defaultBaseImageSheet = "images/tileSheet.png",
    defaultBaseMask = "images/maskTile4px.png",
    defaultOutline = "images/outlineTile.png"
}


--Constructor
--Args will default to property values above, or can override (optional) by passing same as parameters
function Tile:new( ... )

    --Create a local table for new tile instance and set Meta and Index
    local newTile = ... or {}
    setmetatable( newTile, self )
    self.__index = self

    --Set up new display group with baseImage and label for this tile instance
    newTile.group = display.newGroup()
    newTile.group.anchorChildren = true
    newTile.group.instance = newTile -- useful for referencing instance from group level
    newTile.baseImage = newTile:baseImageSheet()
    newTile.label = newTile:setLabel(--[[newTile.depth]])
    newTile.outline = newTile:setOutline(newTile.alpha)
    newTile.decorImage = newTile:decorImageSheet()
    newTile.group:insert(newTile.baseImage)
    newTile.group:insert(newTile.decorImage)
    newTile.group:insert(newTile.label)
    newTile.group:insert(newTile.outline)


    return newTile -- return new tile instance

end


--Display an outline image used for highlighting the Tile
--Optional Alpha: int used for alpha between 0 and 1
--Returns outline image object
function Tile:setOutline(alpha)
      local outline = display.newImageRect(self.defaultOutline, self.settings.tileWidth, self.settings.tileHeight )
      outline.alpha=alpha or 0

      return outline
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
    local imageSheet = imageSheet or graphics.newImageSheet( self.defaultBaseImageSheet, options )

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
    sprite:setMask(graphics.newMask( self.defaultBaseMask )) -- add mask
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
    local imageSheet = imageSheet or graphics.newImageSheet( self.defaultImageSheet, options )

    local sequenceData = sequenceData or
    {
        { name="blue",   frames={ 1 },     count=1},
        { name="red",    frames={ 2 },     count=1},
        { name="yellow", frames={ 3 },     count=1},
    }

    local sprite = display.newSprite( imageSheet, sequenceData )
    sprite:scale( self.settings.scaleFactor, self.settings.scaleFactor )
    sprite.y = sprite.y - (sprite.height/4)*self.settings.scaleFactor -- temproary placement - testing for height overlapping
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
--Optional an amount to drop in depth. Typically one unit is settings.frontHeight
function Tile:setDepth(passedDepth)
    local newDepth = passedDepth or self.depth
    self.depth = newDepth
    self.group.y = self.group.y + self.depth -- move the group down by new depth amount
    --self:updateLabel(1-(self.depth/self.settings.frontHeight)*0.20) -- optional update label
    --self.baseImage:setFillColor(1, 1, 1, (1-(self.depth/self.settings.frontHeight)*0.20)) -- reduce opacity for deeper groups.
    if self.depth > 0 then
          self.baseImage.fill.effect = "filter.desaturate"
          self.baseImage.fill.effect.intensity = 0.35
    end

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
