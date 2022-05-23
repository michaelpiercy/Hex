
local Tile = require( "tileClass" ) --This sets Tile as a reference to the class file
local hexArray = {} -- Keep track of all the tiles
local tileDisplayGroup = display.newGroup() -- Group all the tile instances together


--Grid and Image Settings
local scaleFactor = 0.5
local settings = {
    rows = 4,
    cols = 6,
    tileWidth = 256*scaleFactor,
    tileHeight = 256*scaleFactor,
    innerWidth = 128*scaleFactor,
    innerHeight = 209*scaleFactor,
    frontHeight = 47*scaleFactor
}


--Requires: an array to populate, global settings and a displayGroup to insert tile instances in to.
local function createHexGrid(array, settings, displayGroup)
    --Populate the array with rows and cols variables making it a multidimentional array
    for i=1, settings.cols do
        array[i] = {}   -- create a new col
        for j=1, settings.rows do
            local mod = math.fmod(i,2)  -- get Modulo to determin if this is an odd(1) or even(0) row entry (needed for staggered depth)
            local tileInstance = Tile:new{color="grass", depth=j, settings=settings}
            tileInstance.group.x = i*settings.innerWidth*1.5
            tileInstance.group.y = j*settings.innerHeight-(mod*settings.innerHeight/2) -- use mod (1 or 0) as depth multiplyer
            --tileInstance.label.text = tileInstance.group.y
            displayGroup:insert(tileInstance.group)
            array[i][j] = tileInstance
        end
    end
end
createHexGrid(hexArray, settings, tileDisplayGroup)


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


--Examples of manipulating tiles
hexArray[2][2].group.alpha = 0  -- hides tile group
hexArray[3][3]:setDepth(settings.frontHeight) -- adds more depth
hexArray[4][1]:setDepth(settings.frontHeight) -- adds more depth
hexArray[5][3]:setDepth(settings.frontHeight) -- adds more depth
hexArray[5][4]:setDepth(settings.frontHeight*2) -- adds more depth
hexArray[6][4]:setDepth(settings.frontHeight*3) -- adds more depth
