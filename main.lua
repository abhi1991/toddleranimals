-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

display.setStatusBar(display.HiddenStatusBar)
system.activate( "multitouch" )
math.randomseed(os.time())

local helper = require 'com.alpabeto.helper'
local utils = require 'com.alpabeto.utils'

local composer = require 'composer'

-- Code to initialize your app
local scene_options = {
    params = {}
}

audio.reserveChannels(3)
-- audio.setVolume( 0 )

-- composer.gotoScene('com.alpabeto.flashcard', scene_options)
-- composer.gotoScene('com.alpabeto.quiz', scene_options)
composer.gotoScene('com.alpabeto.menu', scene_options)

-- display.currentStage:addEventListener( 'tap', function(event)
--     local sc = display.captureScreen(true)
--     sc:removeSelf( )
--     audio.play( helper.stars )
--     utils.star_explosion(event.x, event.y)
-- end )