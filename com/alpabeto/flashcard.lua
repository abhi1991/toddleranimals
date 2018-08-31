local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be
-- executed ONCE unless "composer.removeScene()" is called.
-- -----------------------------------------------------------------------------------------

-- local forward references should go here

local helper = require 'com.alpabeto.helper'
local utils = require 'com.alpabeto.utils'
local sound = require 'com.alpabeto.sound'

local tap_enabled
local animal_name
local animal_photo
local animal_blur
local letters
local current_card = 1
local black
local arrow
local home

local function reset()
    if animal_photo ~= nil and animal_blur ~= nil then
        animal_photo:removeSelf( )        
        animal_blur:removeSelf( )
        animal_photo = nil
        animal_blur = nil
    end

    black.y = helper.BOTTOM+helper.BLACK_HEIGHT/2
    arrow:scale( 0.01, 0.01 )
    arrow.alpha = 0
    home:scale( 0.01, 0.01 )
    home.alpha = 0
    
    if letters ~= nil then
        letters:removeSelf( )
        letters = nil
    end

    animal_name_sound = nil
    animal_sound = nil
    tap_enabled = false
end

local function init()
    reset()

    animal_name = helper.animals[current_card]
    animal_name_filipino = helper.animals_filipino[animal_name]

    animal_photo = display.newImageRect( helper.animal_image(animal_name), 1024, 768 )
    animal_photo:addEventListener( 'tap', function()
        sound.play_animal_sound(animal_name)
        return true
    end )
    animal_blur = display.newImageRect( helper.animal_image(animal_name .. '-blur'), 1024, 768 )

    scene.view:insert( animal_photo )
    scene.view:insert( animal_blur )

    animal_photo.x = display.contentCenterX
    animal_photo.y = display.contentCenterY
    animal_photo.alpha = 0

    animal_blur.x = display.contentCenterX
    animal_blur.y = display.contentCenterY
    animal_blur.alpha = 1

    black:toFront( )
    arrow:toFront( )
    home:toFront( )

    letters = display.newGroup( )
    scene.view:insert( letters )
end


local function _start( event )
    local i = 0
    local word_width = 0
    -- local animal_name = animal_name_filipino
    for char in animal_name:gmatch"." do
        local letter_object = helper.letter[char]
        local l = display.newImageRect( letters, helper.letter_image(letter_object), letter_object.width, helper.letter.height )
        l.x = l.width/2 + helper.LETTER_SPACE*i + word_width
        l:scale( 0.01, 0.01 )
        l.alpha = 0
        i = i + 1
        word_width = word_width + l.width
    end

    word_width = word_width + helper.LETTER_SPACE*(i-1)
    letters.x = display.contentCenterX - word_width/2
    letters.y = display.contentCenterY

    local delay = 500
    for i=1,letters.numChildren do
        local l = letters[i]
        transition.to( l, {delay=delay, xScale=1, yScale=1, alpha=1, transition=easing.outBack,} )
        delay = delay + 125
    end

    timer.performWithDelay( delay, function()
        sound.play_animal_name_sound(animal_name)
    end )

    animal_photo.alpha = 1
    transition.fadeOut( animal_blur, {delay=delay+500, time=1000} )
    transition.to( letters, {delay=delay+1500, y=helper.BOTTOM-helper.letter.height/2, transition=easing.outCubic} )
    transition.to( black, {delay=delay+1500, y=helper.BOTTOM-black.height/2, transition=easing.outCubic} )
    transition.to( arrow, {delay=delay+1750, xScale=1, yScale=1, alpha=1, transition=easing.outBack, onComplete=function()
        arrow:addEventListener( 'tap', arrow.next_card )
    end} )
    transition.to( home, {delay=delay+1750, xScale=1, yScale=1, alpha=1, transition=easing.outBack, onComplete=function()
        home:addEventListener( 'tap', home.goto_menu )
    end} )

    timer.performWithDelay( delay+1750, function()
        sound.play_animal_sound(animal_name)
    end )

    current_card = current_card + 1
end


local function start( event )
    if current_card == #helper.animals+1 then
    -- if current_card == 3 then
        current_card = 1
        reset()
        scene.view.alpha = 1
        utils.animated_shuffle(scene.view, function()
            init()
            scene.view.alpha = 0
            transition.fadeIn( scene.view, {time=250, onComplete=_start} )
        end)
    else
        init()
        scene.view.alpha = 0
        transition.fadeIn( scene.view, {time=250, onComplete=_start} )
    end
end

-- -------------------------------------------------------------------------------


-- "scene:create()"
function scene:create( event )
    local sceneGroup = self.view

    -- Initialize the scene here.
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.
    helper.shuffle_table(helper.animals)

    black = display.newRect( display.contentCenterX, helper.BOTTOM+helper.BLACK_HEIGHT/2, display.contentWidth, helper.BLACK_HEIGHT )
    black:setFillColor( 0, .35 )
    sceneGroup:insert( black )
    black:addEventListener( 'tap', function()
        sound.play_animal_name_sound(animal_name)
        return true
    end )

    arrow = display.newImageRect( 'images/interface/arrow.png', helper.ARROW_HEIGHT, helper.ARROW_HEIGHT )
    arrow.x = display.contentWidth - 45
    arrow.y = helper.BOTTOM - helper.BLACK_HEIGHT/2
    sceneGroup:insert( arrow )

    home = display.newImageRect( 'images/interface/home.png', helper.HOME_WIDTH, helper.ARROW_HEIGHT )
    home.x = 45
    home.y = helper.BOTTOM - helper.BLACK_HEIGHT/2
    sceneGroup:insert( home )

    arrow.next_card = function( event )
        audio.stop(sound.ANIMAL_SOUND_CHANNEL)
        audio.stop(sound.ANIMAL_NAME_SOUND_CHANNEL)
        sound.pop(3)
        arrow:removeEventListener( 'tap', arrow.next_card )
        home:removeEventListener( 'tap', home.goto_menu )
        transition.fadeOut( sceneGroup, {time=250, onComplete=start} )
        return true
    end

    home.goto_menu = function( event )
        sound.pop(4)
        arrow:removeEventListener( 'tap', arrow.next_card )
        home:removeEventListener( 'tap', home.goto_menu )
        transition.fadeOut( sceneGroup, {time=250, onComplete=function()
            local current_scene = composer.getSceneName( "current" )
            composer.removeScene( current_scene )
            composer.gotoScene('com.alpabeto.menu' )
        end} )
        return true
    end
end


-- "scene:show()"
function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen.
        -- Insert code here to make the scene come alive.
        -- Example: start timers, begin animation, play audio, etc.
        reset()
        scene.view.alpha = 1
        utils.animated_shuffle(sceneGroup, function()
            init()
            transition.fadeIn( scene.view, {time=250, onComplete=_start} )
        end)
    end
end


-- "scene:hide()"
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen).
        -- Insert code here to "pause" the scene.
        -- Example: stop timers, stop animation, stop audio, etc.
    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen.
    end
end


-- "scene:destroy()"
function scene:destroy( event )

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view ("sceneGroup").
    -- Insert code here to clean up the scene.
    -- Example: remove display objects, save state, etc.
    audio.stop(sound.ANIMAL_SOUND_CHANNEL)
    audio.stop(sound.ANIMAL_NAME_SOUND_CHANNEL)
end


-- -------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene