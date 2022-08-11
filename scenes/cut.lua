local composer = require( "composer" )
local scene = composer.newScene()


-- -----------------------------------------------------------------------------------
-- Local Forward References
-- -----------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

      local sceneGroup = self.view
      -- Code here runs when the scene is first created but has not yet appeared on screen



end


-- show()
function scene:show( event )

      local sceneGroup = self.view
      local phase = event.phase

      if ( phase == "will" ) then
            -- Code here runs when the scene is still off screen (but is about to come on screen)
            print("loading cut scene")
            composer.removeHidden()
            

      elseif ( phase == "did" ) then
            -- Code here runs when the scene is entirely on screen

            composer.gotoScene( "scenes.play" )
      end
end


-- hide()
function scene:hide( event )

      local sceneGroup = self.view
      local phase = event.phase

      if ( phase == "will" ) then
            -- Code here runs when the scene is on screen (but is about to go off screen)

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
