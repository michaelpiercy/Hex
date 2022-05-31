
local Tile = require( "tileClass" ) --This sets Tile as a reference to the class file
--local hexArray = {} -- Keep track of all the tiles
local hexArray = require("exampleMap") -- load predefined map
local tileDisplayGroup = display.newGroup() -- Group all the tile instances together


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
    frontHeight = 47*scaleFactor
}


--Requires settings and array
--If array is empty then it's populated with random rows and cols values
local function setArray(settings, array)
    local settings = settings
    if #array == 0 then -- if array is empty then lets populate it
        for i = 1, settings.rows do
            array[i] = {}
            for j = 1, settings.cols do
                array[i][j] = {math.random(1,2)}
            end
        end
    else -- otherwise use the provided array and update settings row/col values
        settings.cols = #array
        settings.rows = #array[1]
        settings.mapType = "provided"
        return array
    end
end
setArray(settings, hexArray)


--randomise the sequence type
local function randomSequence(thisTile)
    if math.random(0, 1) > 0 then
        thisTile.image:setSequence("grass")
    else
        thisTile.image:setSequence("ice")
    end
end


--specify the sequence type
local function specifySequence(thisTile, type)
    if type then
        return thisTile.image:setSequence(type)
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
                type=array[i][j].type, --could be nil, that's ok. Default will kick in.
                settings=settings
            }

            --space out the instances based on cols and rows and offset
            tileInstance.group.x = i*settings.innerWidth*1.5
            tileInstance.group.y = j*settings.innerHeight-(mod*settings.innerHeight/2) -- use mod (1 or 0) as depth multiplyer
            --tileInstance.label.text = tileInstance.group.y
            tileInstance:drawLines(1, 2)
            if settings.mapType == "random" then
                randomSequence(tileInstance)
            else
                specifySequence(tileInstance, array[i][j].type)
            end
            tileInstance.image:play()
            displayGroup:insert(tileInstance.group)
            array[i][j] = tileInstance
        end
    end
end
createRandomHexGrid(hexArray, settings, tileDisplayGroup)



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
--hexArray[5][3]:setDepth(settings.frontHeight) -- adds more depth
--hexArray[5][4]:setDepth(settings.frontHeight*2) -- adds more depth
--hexArray[6][4]:setDepth(settings.frontHeight*3) -- adds more depth
