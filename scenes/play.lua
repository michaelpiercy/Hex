local Tile = require( "classes.tileClass" ) --This sets Tile as a reference to the class file
local Panel = require("classes.infoPanel")  --Set Panel as info Panel Class
local helper = require("functions.helper")
local composer = require( "composer" )
local scene = composer.newScene()


-- -----------------------------------------------------------------------------------
-- Local Forward References
-- -----------------------------------------------------------------------------------
local tileDisplayGroup
local HexArray = {}
local infoPanel
--HexArray = require("maps.exampleMap") -- Load predefined map

--Grid and Image Settings
local scaleFactor = .15
local settings = {
      scaleFactor = scaleFactor,
      rows = 6, -- overridden if map is predefined
      cols = 8, -- overridden if map is predefined
      mapType = "random",
      tileWidth = 256*scaleFactor,
      tileHeight = 256*scaleFactor,
      innerWidth = 128*scaleFactor,
      innerHeight = 209*scaleFactor,
      frontHeight = 46*scaleFactor,
}
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

--Custom Runtime Listener for event dispatches
local function customEventRelay(e)
      local target = e.target
      local name = e.name
      if name == "activateTile" then
            local infoPanelUpdate = { name="updateInfo", target=target}


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
            if settings.focusTile == target then
                  target:unhighlight()
                  settings.focusTile = nil

                  --reset the info panel details
                  infoPanelUpdate = { name="updateInfo", reset=true}

            else -- otherwise highlight the selected tile and adjacent tiles

                  local directions = {"N", "S", "NE", "SE", "NW", "SW"}
                  for i = 1, #directions do
                        local col, row = target:getAdjacent(directions[i])
                        if HexArray[col] and HexArray[col][row] then HexArray[col][row]:highlight(0.95, 0.5, 0.25, 0.85) end
                  end

                  target:highlight()
            end

            --update the info panel
            infoPanel.group:dispatchEvent( infoPanelUpdate )
      end
end

-- create()
function scene:create( event )

      local sceneGroup = self.view
      -- Code here runs when the scene is first created but has not yet appeared on screen

      -- Create an Info Panel to show details of what tile has been selected
      infoPanel = Panel:new{message="Select a Tile"}
      infoPanel.group.x, infoPanel.group.y = display.contentWidth/2, display.contentHeight-display.contentHeight/4
      sceneGroup:insert(infoPanel.group)


end


-- show()
function scene:show( event )

      local sceneGroup = self.view
      local phase = event.phase

      if ( phase == "will" ) then
            -- Code here runs when the scene is still off screen (but is about to come on screen)

            -- Set up array based on settings
            helper:setArray(settings, HexArray)

            -- Set up display group for hex tiles
            tileDisplayGroup = helper:setUpTileDisplayGroup()

            -- Populate the HexArray with new Tile instances
            helper:createRandomHexGrid(HexArray, settings, tileDisplayGroup)

            -- Arrange the display order of the Tile instances based on their Y value
            helper:sortByDepth(tileDisplayGroup)

            sceneGroup:insert(tileDisplayGroup)
            
            Runtime:addEventListener("activateTile", customEventRelay)



      elseif ( phase == "did" ) then
            -- Code here runs when the scene is entirely on screen
            -- Function to handle button events
            local function handleButtonEvent( event )

                  if ( "ended" == event.phase ) then
                        print( "Button was pressed and released" )
                        composer.gotoScene( "scenes.cut" )
                  end
            end

            local widget = require( "widget" )
            -- Create the widget
            local button1 = widget.newButton(
            {
                  left = display.contentWidth/2,
                  top = display.contentHeight-200,
                  id = "button1",
                  label = "Restart",
                  onEvent = handleButtonEvent
            }
            )
      end
end


-- hide()
function scene:hide( event )

      local sceneGroup = self.view
      local phase = event.phase

      if ( phase == "will" ) then
            -- Code here runs when the scene is on screen (but is about to go off screen)
            Runtime:removeEventListener("activateTile", customEventRelay)


      elseif ( phase == "did" ) then
            -- Code here runs immediately after the scene goes entirely off screen

      end
end


-- destroy()
function scene:destroy( event )

      local sceneGroup = self.view
      -- Code here runs prior to the removal of scene's view

end





-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )


-- -----------------------------------------------------------------------------------

return scene
