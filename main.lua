local composer = require( "composer" )


-- Set default anchor points for objects to Center, fill & background colours
display.setDefault( "anchorX", 0.5 )
display.setDefault( "anchorY", 0.5 )
display.setDefault( "fillColor", 1, 1, 0.25 )
display.setDefault( "background", 0.25, 0.15, 0.65 )


composer.gotoScene( "scenes.play" )
