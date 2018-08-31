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

local animal_name
local black
local letters
local tap_enabled
local word_width
local animals
local arrow
local home
local star_timer

-- -------------------------------------------------------------------------------

local function shake(object)
    transition.to(object, {time=60, rotation=10, onComplete=function(obj)
        transition.to(obj, {time=60, rotation=-10, onComplete=function(obj)
            transition.to(obj, {time=60, rotation=10, onComplete=function(obj)
                transition.to(obj, {time=60, rotation=0, onComplete=function(obj)
                    tap_enabled = true
                end})
            end})
        end})
    end})
end


local function goto_cutscene()
    local current_scene = composer.getSceneName( "current" )
    composer.removeScene( current_scene )
    composer.gotoScene('com.alpabeto.cutscene' )
end


local function select(event)
    if not tap_enabled then return true end
    tap_enabled = false

    local choice = event.target
    choice.parent:insert( choice.parent.numChildren-3, choice )
    if choice.animal_name == animal_name then
        choice:removeEventListener( 'tap', select )
        for i=1,4 do
            if animals[i] ~= choice then
                transition.fadeOut( animals[i], {} )
            end
        end
        transition.to( choice, {x=display.contentCenterX, y=display.contentCenterY,
            width=display.actualContentWidth, height=display.actualContentHeight, transition=easing.outCubic, onComplete=function()
                choice:addEventListener( 'tap', function()
                    sound.play_animal_sound(animal_name)
                    return true
                end )
            end} )
        transition.to( choice[1], {xScale=1.0, yScale=1.0, transition=easing.outCubic} )
        local black_height = black.height
        transition.to( black, {y=helper.BOTTOM-(black_height*1.75/2), width=display.contentWidth + 32,
            height=black_height*1.75, transition=easing.outCubic} )
        transition.to( letters, {y=helper.BOTTOM-helper.letter.height/2, xScale=1, yScale=1,
            x=letters.x - word_width/4, transition=easing.outCubic} )
        transition.to( arrow, {delay=500, xScale=1, yScale=1, alpha=1, transition=easing.outBack, onComplete=function()
            tap_enabled = true
            
            local function next_quiz(event)
                tap_enabled = false
                arrow:removeEventListener( 'tap', next_quiz )
                audio.stop(sound.ANIMAL_SOUND_CHANNEL)
                audio.stop(sound.ANIMAL_NAME_SOUND_CHANNEL)
                sound.pop(3)
                if star_timer then timer.cancel( star_timer ) end
                goto_cutscene()
                helper.current_card = helper.current_card + 1
                return true
            end

            arrow:addEventListener( 'tap', next_quiz)
        end} )
        sound.correct()
        sound.stars()

        utils.star_explosion(event.x, event.y)
        star_timer = timer.performWithDelay( 500, function()
            local x, y = math.random( display.actualContentWidth ), math.random( display.actualContentHeight )
            utils.star_explosion(x, y)
        end, -1 )
    else
        sound.oops()
        shake(choice)
        return false
    end

    return true
end


-- "scene:create()"
function scene:create( event )

    local sceneGroup = self.view

    -- Initialize the scene here.
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.

    if helper.current_card == #helper.animals+1 then
        return
    end

    black = display.newRoundedRect( sceneGroup, display.contentCenterX, display.contentCenterY,
        display.contentWidth, helper.BLACK_HEIGHT/1.75, 16 )
    black:addEventListener( 'tap', function(event)
        sound.play_animal_name_sound(animal_name)
        return true
    end )
    
    letters = display.newGroup( )
    sceneGroup:insert( letters )

    arrow = display.newImageRect( sceneGroup, 'images/interface/arrow.png', helper.ARROW_HEIGHT, helper.ARROW_HEIGHT )
    arrow.x = display.contentWidth - 45
    arrow.y = helper.BOTTOM - helper.BLACK_HEIGHT/2

    home = display.newImageRect( sceneGroup, 'images/interface/home.png', helper.HOME_WIDTH, helper.ARROW_HEIGHT )
    home.x = 45
    home.y = helper.BOTTOM - helper.BLACK_HEIGHT/2
    home:scale( 0.01, 0.01 )
    home.alpha = 0

    local function go_home(event)
        tap_enabled = false
        home:removeEventListener( 'tap', go_home)
        sound.pop(4)
        transition.cancel( )
        if star_timer then timer.cancel( star_timer ) end
        -- point to last card to for the shuffle on next open
        helper.current_card = #helper.animals + 1
        transition.fadeOut( scene.view, {time=250, onComplete=function()
            local current_scene = composer.getSceneName( "current" )
            composer.removeScene( current_scene )
            composer.gotoScene('com.alpabeto.menu' )
        end} )
        utils.clean_explosions()
        return true
    end

    home:addEventListener( 'tap', go_home)
end


-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
        if helper.current_card == #helper.animals+1 then
            return
        end

        tap_enabled = false
        word_width = 0
        animals = {}

        local choices = {helper.current_card}

        for i=2,4 do
            local random_index = helper.random_except(unpack(choices))
            choices[i] = random_index
        end
        helper.shuffle_table(choices)

        for i=1,4 do
            local choice = display.newContainer( sceneGroup, display.actualContentWidth/2, display.actualContentHeight/2 )
            local offset_y = .25 + ( .5 * ( i % 2 ) )
            local offset_x = .25 + ( .5 * ( ( math.floor( ( i-1 ) / 2 ) ) % 2 ) )
            choice.x = display.actualContentWidth * offset_x
            choice.y = helper.TOP + display.actualContentHeight * offset_y
            local animal_name = helper.animals[choices[i]]
            local animal_photo = display.newImageRect( choice, helper.animal_image(animal_name), 1024, 768 )
            animal_photo:scale( .5, .5 )
            choice.animal_name = animal_name
            animals[i] = choice
        end

        black.x = display.contentCenterX
        black.y = display.contentCenterY
        black.height = helper.BLACK_HEIGHT/1.75
        black:setFillColor( 0, .5 )
        black:scale( 0.01, 0.01 )
        black.alpha = 0

        animal_name = helper.animals[helper.current_card]
        local i = 0

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
        letters:scale( .5, .5 )
        letters.x = display.contentCenterX - word_width/4
        letters.y = display.contentCenterY

        black.width = word_width/2 + 50

        -- add the tap handlers
        for i=1,4 do
            animals[i]:addEventListener( 'tap', select )
        end

        arrow:scale( 0.01, 0.01 )
        arrow.alpha = 0

        black:toFront( )
        letters:toFront( )
        arrow:toFront( )
    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen.
        -- Insert code here to make the scene come alive.
        -- Example: start timers, begin animation, play audio, etc.
        if helper.current_card == #helper.animals+1 then
            utils.animated_shuffle(sceneGroup, goto_cutscene)
            helper.current_card = 1
            return
        end

        local function show_letters()
            local delay = 0
            transition.to( black, {delay=delay, xScale=1, yScale=1, alpha=1, transition=easing.outBack,} )
            for i=1,letters.numChildren do
                local l = letters[i]
                transition.to( l, {delay=delay, xScale=1, yScale=1, alpha=1, transition=easing.outBack,} )
                delay = delay + 125
            end

            -- enable tap event
            home:toFront( )
            transition.to( home, {delay=500 + (125 * letters.numChildren), xScale=1, yScale=1, alpha=1,
                transition=easing.outBack, onComplete=function()
                -- tap_enabled = true
            end} )
        end

        for i=1,#animals do
            local offset_y = -.25 + ( 1.5 * ( i % 2 ) )
            local offset_x = -.25 + ( 1.5 * ( ( math.floor( ( i-1 ) / 2 ) ) % 2 ) )
            transition.from( animals[i], {x=display.actualContentWidth * offset_x, y=helper.TOP + display.actualContentHeight * offset_y,
                transition=easing.outCubic})
        end

        timer.performWithDelay( 500, function()
            sound.where_is_the(function()
                show_letters()
                tap_enabled = true
                sound.play_animal_name_sound(animal_name, function()
                    sound.play_animal_sound(animal_name)
                end)
            end)
        end )
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


    if animals then
        for i=1,4 do
            animals[i]:removeSelf( )
            animals[i] = nil
        end
    end

    if letters then
        for i=letters.numChildren,1,-1 do
            letters[i]:removeSelf( )
            letters[i] = nil
        end

        letters:removeSelf( )
        letters = nil
    end

    if black then
        black:removeSelf( )
        black = nil
    end

    if arrow then
        arrow:removeSelf( )
        arrow = nil
    end

    if home then
        home:removeSelf( )
        home = nil
    end

    audio.stop(sound.ANIMAL_SOUND_CHANNEL)
    audio.stop(sound.ANIMAL_NAME_SOUND_CHANNEL)

    -- stop all timers
    -- for k,v in pairs(timer._runlist) do
    --     timer.cancel(v)
    -- end
end


-- -------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene