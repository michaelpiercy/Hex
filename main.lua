
local Tile = require( "tileClass" ) --This sets Tile as a reference to the class file
local Panel = require("infoPanel")  --Set Panel as info Panel Class
--local HexArray = require("exampleMap") -- Load predefined map
local HexArray = {}
-- Set default anchor points for objects to Center, fill & background colours
display.setDefault( "anchorX", 0.5 )
display.setDefault( "anchorY", 0.5 )
display.setDefault( "fillColor", 1, 1, 0.25 )
display.setDefault( "background", 0.25, 0.15, 0.65 )


--Local Forward References
local tileDisplayGroup


--Grid and Image Settings
local scaleFactor = 0.25
local settings = {
      scaleFactor = scaleFactor,
      rows = 4, -- overridden if map is predefined
      cols = 6, -- overridden if map is predefined
      mapType = "random",
      tileWidth = 256*scaleFactor,
      tileHeight = 256*scaleFactor,
      innerWidth = 128*scaleFactor,
      innerHeight = 209*scaleFactor,
      frontHeight = 47*scaleFactor,
}


--Set up display group to hold tile objects
local function setUpTileDisplayGroup()
      local group = display.newGroup() -- Group all the tile instances together
      group.anchorChildren = true -- activate displayGroups anchors
      group.x, group.y = display.contentWidth/2, display.contentHeight/4
      return group
end
tileDisplayGroup = setUpTileDisplayGroup()


--Requires settings and array
--If array is empty then it's populated with random rows and cols values
local function setArray(settings, array)
      local settings = settings
      if #array == 0 then -- if array is empty then lets populate it
            for i = 1, settings.cols do
                  array[i] = {}
                  for j = 1, settings.rows do
                        array[i][j] = {math.random(1,2)}
                  end
            end
      else -- otherwise use the provided array and update settings row/col values
            settings.cols = #array
            settings.rows = #array[1]
            --settings.mapType = "provided"
            return array
      end
end
setArray(settings, HexArray)


--randomise the sequence base
local function randomSequence(thisTile)
      local randomTileNum = math.random(1, 3)
      local newBase
      local newDecor
      if randomTileNum == 1 then
            newBase = "grass"
            newDecor = "blue"
      elseif randomTileNum == 2 then
            newBase = "ice"
            newDecor = "red"
      elseif randomTileNum == 3 then
            newBase = "dirt"
            newDecor = "yellow"
      end
      thisTile:updateBase(newBase)
      thisTile:updateDecor(newDecor)
end


--specify the sequence base
local function specifySequence(thisTile, base)
      if base then
            return thisTile:updateBase(base)
      end
end


--Requires: an array to populate, global settings and a displayGroup to insert tile instances in to.
local function createRandomHexGrid(array, settings, displayGroup)
      --Populate the array with rows and cols variables making it a multidimentional array

      local cols = #array or 0
      for i=1, cols do
            local rows = #array[i] or {}
            for j=1, rows do
                  local mod = math.fmod(i,2)  -- get Modulo to determin if this is an odd(1) or even(0) row entry (needed for staggered depth)
                  array[i][j] = array[i][j] or {} -- set value to existing value or else empty
                  local tileInstance = Tile:new{
                        base=array[i][j].base, --could be nil, that's ok. Default will kick in.
                        decor=array[i][j].decor,
                        settings=settings,
                        row = j,
                        col = i,
                        array = array
                  }

                  --space out the instances based on cols and rows and offset
                  tileInstance.group.x = i*settings.innerWidth*1.5
                  tileInstance.group.y = j*settings.innerHeight-(mod*settings.innerHeight/2) -- use mod (1 or 0) as depth multiplyer
                  --tileInstance.label.text = tileInstance.group.y
                  --tileInstance:drawLines(1, 2)
                  if settings.mapType == "random" then
                        randomSequence(tileInstance)
                  else
                        specifySequence(tileInstance, array[i][j].base)
                  end
                  tileInstance.baseImage:play()
                  tileInstance.decorImage:play()
                  displayGroup:insert(tileInstance.group)
                  array[i][j] = tileInstance
            end
      end
end
createRandomHexGrid(HexArray, settings, tileDisplayGroup)


--Sort the passed group by Y Axis value of it's children. The Higher the Y value, the higher the order
--Requires: display group
local function sortByDepth(group)

      -- Add tile instances to a temp group
      local tileGroups = {}
      for i = 1, group.numChildren do
            tileGroups[#tileGroups+1] = group[i]
      end

      -- Reorder temp group based on y axis
      table.sort( tileGroups, function(a,b) return a.y < b.y end )

      -- Reinsert them back into the original group
      for i = 1, #tileGroups do
            group:insert( tileGroups[i] )
      end
end
sortByDepth(tileDisplayGroup)
tileDisplayGroup.anchorX, tileDisplayGroup.anchorY = 0.5, 0.5


--Examples of manipulating tiles
--HexArray[2][2].group.alpha = 0  -- hides tile group
HexArray[3][3]:setDepth(settings.frontHeight) -- adds more depth
HexArray[4][1]:setDepth(settings.frontHeight) -- adds more depth


--Create an Info Panel to show details of what tile has been selected
local infoPanel = Panel:new{message="Select a Tile"}
infoPanel.group.x, infoPanel.group.y = display.contentWidth/2, display.contentHeight-display.contentHeight/4

--Custom Runtime Listener for event dispatches
local function customEventRelay(e)
      if e.name == "activateTile" then
            local infoPanelUpdate = { name="updateInfo", target=e.target}


            --if a tile is already selected
            if settings.focusTile then
                  --unhighlight everything that's already highlighted
                  for i = 1, #HexArray do
                        for j = 1, #HexArray[i] do
                              if HexArray[i][j] then HexArray[i][j]:unhighlight() end
                        end
                  end
            end

            --if the same tile was selected again, then unhighlight that too
            if settings.focusTile == e.target then
                  e.target:unhighlight()
                  settings.focusTile = nil

                  --reset the info panel details
                  infoPanelUpdate = { name="updateInfo", reset=true}

            else -- otherwise highlight the selected tile and adjacent tiles

                  local directions = {"N", "S", "NE", "SE", "NW", "SW"}
                  for i = 1, #directions do
                        local col, row = e.target:getAdjacent(directions[i])
                        if HexArray[col] and HexArray[col][row] then HexArray[col][row]:highlight(0.95, 0.5, 0.25, 0.85) end
                  end

                  e.target:highlight()
            end

            --update the info panel
            infoPanel.group:dispatchEvent( infoPanelUpdate )
      end
end

Runtime:addEventListener("activateTile", customEventRelay)
