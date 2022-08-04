local Tile = require( "classes.tileClass" ) --This sets Tile as a reference to the class file

-- helper functions
local helper = {}


-- Set up display group to hold tile objects.
function helper:setUpTileDisplayGroup()
      local group = display.newGroup() -- Group all the tile instances together
      group.anchorChildren = true -- activate displayGroups anchors
      group.x, group.y = display.contentWidth/2, display.contentHeight/4
      return group
end

-- Requires settings and array.
-- If array is empty then it's populated with random rows and cols values.
function helper:setArray(settings, array)
      if settings then
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
      else
            error( "No Settings passed from:", 2 )
      end
end


-- Randomise a tile's base image sequence
-- Requires tile[object]
function helper:randomSequence(tile)
      if tile then
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
            tile:updateBase(newBase)
            tile:updateDecor(newDecor)
            return true
      else
            error( "No Tile object passed to randomise the base", 2 )
            return false
      end
end


-- Update a tile base to specific sequence
-- Requires tile[object] and base[string]
function helper:specificSequence(tile, base)
      if tile and base then
            tile:updateBase(base)
            return true
      else
            error( "No Tile or Base passed to update", 2 )
            return false
      end
end


--Requires an array to populate, settings and a displayGroup to insert tile instances in to.
function helper:createRandomHexGrid(array, settings, displayGroup)
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
                        array = array,
                        depth=math.random(0, 1)*settings.frontHeight -- randomise depth
                  }

                  --space out the instances based on cols and rows and offset
                  tileInstance.group.x = i*settings.innerWidth*1.5
                  tileInstance.group.y = j*settings.innerHeight-(mod*settings.innerHeight/2) -- use mod (1 or 0) as depth multiplyer
                  --tileInstance.label.text = tileInstance.group.y
                  --tileInstance:drawLines(1, 2)
                  if settings.mapType == "random" then
                        helper:randomSequence(tileInstance)
                  else
                        helper:specifySequence(tileInstance, array[i][j].base)
                  end
                  tileInstance.baseImage:play()
                  tileInstance.decorImage:play()
                  displayGroup:insert(tileInstance.group)
                  array[i][j] = tileInstance
            end
      end
      return true
end


-- Arrange the display object of the passed group sorted by Y Axis value. The Higher the Y value, the higher the order.
-- Requires: group [display group]
function helper:sortByDepth(group)

      if group then
            -- Add tile instances to a temp group
            local tileGroups = {}
            for i = 1, group.numChildren do
                  tileGroups[#tileGroups+1] = group[i]
            end

            -- Reorder temp group based on y axis
            table.sort( tileGroups, function(a,b) return a.y < b.y end )

            -- Reinsert them back into the original group in new order
            for i = 1, #tileGroups do
                  tileGroups[i].instance:setDepth()
                  group:insert( tileGroups[i] )
            end
      else
            error("No group to arrange displays", 2)
      end
end



return helper
