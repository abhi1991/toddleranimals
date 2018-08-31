local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be
-- executed ONCE unless "composer.removeScene()" is called.
-- -----------------------------------------------------------------------------------------

-- local forward references should go here
local helper = require 'com.alpabeto.helper'
local color = require 'com.alpabeto.color'
local sound = require 'com.alpabeto.sound'
local utils = require 'com.alpabeto.utils'
local animal_blurs = display.newGroup( )
local title
local flashcard_button
local quiz_button
local logo
local tap_enabled = false
local delay
local animals
local black
local animal_indexes = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}
local stage = display.currentStage
local color_timer

-- parents section
local parents_bubble

local credits
local family
local family_message
local please_rate
local star_timer

local rate_app
local facebook
local privacy_policy
local email_support
local arrow
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

-- "scene:create()"
function scene:create( event )

    local sceneGroup = self.view

    -- Initialize the scene here.
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.
    animals = display.newGroup( )
    sceneGroup:insert(animals)
    helper.shuffle_table(helper.animals)
    local index = 1
    for i=1,4 do
        for j=1,4 do
            local c = display.newContainer( animals, helper.THUMBNAIL_WIDTH, helper.THUMBNAIL_HEIGHT )
            local animal_image = display.newImageRect( c, helper.animal_thumbnail(helper.animals[index]),
                helper.THUMBNAIL_WIDTH, helper.THUMBNAIL_HEIGHT )
            animal_image.alpha = 0
            animal_image:scale( 0.01, 0.01 )
            c.anchorX = 1
            c.x = display.contentWidth - (i-1) * c.width
            if j % 2 > 0 then
                c.anchorX = 0
                c.x = (i-1) * c.width
            end
            c.y = helper.TOP + (c.height/2)*(j*2-1)
            index = index + 1
        end
    end

    black = display.newRect( sceneGroup, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight )
    black:setFillColor( 0, 1 )
    black.alpha = 0

    -- Create and prepare the game title
    title = display.newImageRect( sceneGroup, 'images/interface/title.png', 580, 270 )
    title:translate( display.contentCenterX, display.contentCenterY )
    title:scale( 0.01, 0.01 )
    title.alpha = 0

    -- create the buttons
    flashcard_button = display.newGroup( )
    sceneGroup:insert( flashcard_button )
    display.newImageRect( flashcard_button, 'images/interface/button_border.png', 400, 95 )
    display.newImageRect( flashcard_button, 'images/interface/flashcard.png', 364, 68 )
    local fc = helper.toddler_colors[1]
    flashcard_button[2]:setFillColor( fc[1], fc[2], fc[3]  )
    flashcard_button:translate( display.contentCenterX, display.contentCenterY+flashcard_button.height/2+60 )
    flashcard_button:scale( 0.01, 0.01 )
    flashcard_button.alpha = 0

    quiz_button = display.newGroup( )
    sceneGroup:insert(quiz_button)
    display.newImageRect( quiz_button, 'images/interface/button_border.png', 400, 95 )
    display.newImageRect( quiz_button, 'images/interface/quiz.png', 356, 68 )
    local qc = helper.animals_colors[1]
    quiz_button[2]:setFillColor( qc[1], qc[2], qc[3]  )
    quiz_button:translate( display.contentCenterX, display.contentCenterY+quiz_button.height*1.5+80 )
    quiz_button:scale( 0.01, 0.01 )
    quiz_button.alpha = 0

    -- create the alpabeto logo
    logo = display.newImageRect( sceneGroup, 'images/interface/logo.png', 80, 64 )
    logo:translate( display.contentWidth-logo.width/2 - 20, helper.BOTTOM-logo.height/2 - 20 )
    logo:scale( 0.01, 0.01 )
    logo.alpha = 0

    if stage.music_volume == nil then
        stage.music_volume = display.newGroup( )
        display.newImageRect( stage.music_volume, 'images/interface/musicon.png', 46, 50 )
        display.newImageRect( stage.music_volume, 'images/interface/musicoff.png', 50, 50 )
        stage.music_volume[2].alpha = 0
        stage.music_volume:translate( display.contentWidth - 25 - 20, helper.TOP + 25 + 20 )
        stage.music_volume:scale( 0.01, 0.01 )
        stage.music_volume.alpha = 0
    end

    -- create the parents section elements
    credits = display.newImageRect( sceneGroup, 'images/interface/credits.png', 861, 303 )
    credits.anchorX = 0
    credits.anchorY = 1
    credits:translate( 20, helper.BOTTOM - 20 )
    credits:scale( 0.01, 0.01 )
    credits.alpha = 0

    local function handle_tap(event)
        local result = system.openURL( event.target.url )
        print( result )
        if not result then
            print( event.target.name, event.target.url, event.target.url2  )
            if event.target.url2 then
                system.openURL( event.target.url2 )
            end
        end
        return true
    end

    local parents_button = {width=300, height=50, x=display.actualContentWidth - 300/2 - 100}

    rate_app = display.newImageRect( sceneGroup, 'images/interface/rate_app.png', parents_button.width, parents_button.height )
    rate_app:translate( parents_button.x, helper.TOP + rate_app.height/2 + 140 )
    rate_app:scale( 0.01, 0.01 )
    rate_app.alpha = 0
    rate_app.url = 'itms-apps://itunes.apple.com/app/id1036507421'
    -- rate_app.url = 'itms-apps://itunes.apple.com/app/id996361234'
    rate_app:addEventListener( 'tap', handle_tap )

    facebook = display.newImageRect( sceneGroup, 'images/interface/facebook.png', parents_button.width, parents_button.height )
    facebook:translate( parents_button.x, rate_app.y + 20 + parents_button.height)
    facebook:scale( 0.01, 0.01 )
    facebook.alpha = 0
    facebook.url = 'fb://profile/811650298900862'
    facebook.url2 = 'https://m.facebook.com/alpabeto.games'
    facebook:addEventListener( 'tap', handle_tap )

    privacy_policy = display.newImageRect( sceneGroup, 'images/interface/privacy_policy.png', parents_button.width, parents_button.height )
    privacy_policy:translate( parents_button.x, facebook.y + 20 + parents_button.height)
    privacy_policy:scale( 0.01, 0.01 )
    privacy_policy.alpha = 0
    privacy_policy.url = 'http://j.mp/alpabetoprivacy'
    privacy_policy:addEventListener( 'tap', handle_tap )

    email_support = display.newImageRect( sceneGroup, 'images/interface/email_support.png', parents_button.width, parents_button.height )
    email_support:translate( parents_button.x, privacy_policy.y + 20 + parents_button.height)
    email_support:scale( 0.01, 0.01 )
    email_support.alpha = 0
    email_support.url = 'mailto:support@alpabeto.com?subject=Support%20Request'
    email_support:addEventListener( 'tap', handle_tap )


    family = display.newImageRect( sceneGroup, 'images/interface/family.png', 100, 130 )
    family:translate( family.width/2 + 325, helper.TOP + family.height/2 + 240 )
    family:scale( 0.01, 0.01 )
    family.alpha = 0

    family_message = display.newImageRect( sceneGroup, 'images/interface/family_message.png', 316, 215 )
    family_message.anchorX = 1
    family_message.anchorY = 1
    family_message:translate( family_message.width + 140, helper.TOP + family_message.height + 20 )
    family_message:scale( 0.01, 0.01 )
    family_message.alpha = 0

    please_rate = display.newImageRect( sceneGroup, 'images/interface/please_rate.png', 314, 102 )
    please_rate:translate( display.actualContentWidth - please_rate.width/2 - 210, helper.TOP + please_rate.height/2 + 35 )
    please_rate:scale( 0.01, 0.01 )
    please_rate.alpha = 0

    local function back_to_menu()
        if not tap_enabled then return true end
        tap_enabled = false
        sound.pop(3)
        local interval = 65
        utils.clean_explosions()

        transition.cancel( family_message )
        transition.cancel( please_rate )
        timer.cancel( star_timer )

        transition.to( parents_bubble, {delay=interval*13, xScale=1, yScale=1, alpha=1, time=300, transition=easing.outBack,
            onComplete=function()
            tap_enabled = true
            logo:addEventListener( 'touch', logo.handle_parents_touch )
        end} )

        transition.to( title, {delay=interval*12, xScale=1, yScale=1, alpha=1, time=300, transition=easing.outBack,})

        transition.to( flashcard_button, {delay=interval*11, xScale=1, yScale=1, alpha=1, time=300, transition=easing.outBack,} )
        transition.to( quiz_button, {delay=interval*10, xScale=1, yScale=1, alpha=1, time=300, transition=easing.outBack,} )

        -- hide parents section elements
        transition.to( black, {delay=interval*9, time=300, alpha=.5} )
        transition.to( credits, {delay=interval*8, xScale=.01, yScale=.01, alpha=0, time=300, transition=easing.inBack,} )
        
        transition.to( rate_app, {delay=interval*7, xScale=.01, yScale=.01, alpha=0, time=300, transition=easing.inBack,} )
        transition.to( facebook, {delay=interval*6, xScale=.01, yScale=.01, alpha=0, time=300, transition=easing.inBack,} )
        transition.to( privacy_policy, {delay=interval*5, xScale=.01, yScale=.01, alpha=0, time=300, transition=easing.inBack,} )
        transition.to( email_support, {delay=interval*4, xScale=.01, yScale=.01, alpha=0, time=300, transition=easing.inBack,} )

        transition.to( family, {delay=interval*3, xScale=.01, yScale=.01, alpha=0, time=300, transition=easing.inBack,} )
        transition.to( arrow, {delay=interval*2, xScale=.01, yScale=.01, alpha=0, time=300, transition=easing.inBack,} )

        transition.to( family_message, {delay=interval*1, xScale=.01, yScale=.01, alpha=0, time=300, transition=easing.inBack,} )
        transition.to( please_rate, {delay=0, xScale=.01, yScale=.01, alpha=0, time=300, transition=easing.inBack,})
    end

    arrow = display.newImageRect( sceneGroup, 'images/interface/arrow.png', helper.ARROW_HEIGHT, helper.ARROW_HEIGHT )
    arrow:translate( arrow.width/2 + 20, helper.TOP + arrow.height/2 + 20 )
    arrow.rotation = 180
    arrow:scale( 0.01, 0.01 )
    arrow.alpha = 0
    arrow:addEventListener( 'tap', back_to_menu )
end


-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
        sound.play_bg_music_intro()
    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen.
        -- Insert code here to make the scene come alive.
        -- Example: start timers, begin animation, play audio, etc.
        helper.shuffle_table(helper.animals)
        helper.shuffle_table(animal_indexes)
        delay = 125
        for i=1,#animal_indexes do
            local index = animal_indexes[i]
            local c = animals[index]
            transition.scaleTo( c[1], {delay=delay, xScale=1, yScale=1, alpha=1, transition=easing.outBack} )
            delay = delay + 30
        end

        transition.to( black, {delay=delay, time=1000, alpha=.5} )
        delay = delay + 1000

        -- Show the Title
        title:toFront( )
        transition.to( title, {delay=delay, xScale=1, yScale=1, alpha=1, time=300, transition=easing.outBack,} )
        delay = delay + 300

        timer.performWithDelay( delay, function()
            transition.moveTo( title, {delay=80, y=display.contentCenterY -  title.height/2, time=300, transition=easing.outBack,} )
            transition.to( flashcard_button, {delay=80, xScale=1, yScale=1, alpha=1, time=300, transition=easing.outBack,} )
            transition.to( quiz_button, {delay=160, xScale=1, yScale=1, alpha=1, time=300, transition=easing.outBack,} )

            transition.to( logo, {delay=240, xScale=1, yScale=1, alpha=1, time=300, transition=easing.outBack, onComplete=function()
                parents_bubble = display.newImageRect( sceneGroup, 'images/interface/parents_bubble.png', 126, 97 )
                parents_bubble:translate( display.contentWidth-parents_bubble.width/2 - 55, helper.BOTTOM-parents_bubble.height/2 -85 )
                parents_bubble:scale( 0.01, 0.01 )
                parents_bubble.alpha = 0
                transition.to( parents_bubble, {xScale=1, yScale=1, alpha=1, time=300, transition=easing.outBack, onComplete=function()
                    -- show parents section
                    local function show_parents_section()
                        sound.pop(3)
                        local interval = 65
                        logo:removeEventListener( 'touch', logo.handle_parents_touch )
                        transition.to( title, {xScale=.01, yScale=.01, alpha=0, time=300, transition=easing.inBack,} )
                        transition.to( flashcard_button, {delay=interval, xScale=.01, yScale=.01, alpha=0, time=300, transition=easing.inBack,} )
                        transition.to( quiz_button, {delay=interval*2, xScale=.01, yScale=.01, alpha=0, time=300, transition=easing.inBack,} )
                        transition.to( parents_bubble, {delay=interval*3, xScale=.01, yScale=.01, alpha=0, time=300, transition=easing.inBack,} )

                        -- show parents section elements
                        transition.to( black, {delay=interval*4, time=300, alpha=.75} )
                        transition.to( credits, {delay=interval*5, xScale=1, yScale=1, alpha=1, time=300, transition=easing.outBack,} )
                        
                        transition.to( rate_app, {delay=interval*6, xScale=1, yScale=1, alpha=1, time=300, transition=easing.outBack,} )
                        transition.to( facebook, {delay=interval*7, xScale=1, yScale=1, alpha=1, time=300, transition=easing.outBack,} )
                        transition.to( privacy_policy, {delay=interval*8, xScale=1, yScale=1, alpha=1, time=300, transition=easing.outBack,} )
                        transition.to( email_support, {delay=interval*9, xScale=1, yScale=1, alpha=1, time=300, transition=easing.outBack,} )

                        transition.to( family, {delay=interval*10, xScale=1, yScale=1, alpha=1, time=300, transition=easing.outBack,} )
                        transition.to( arrow, {delay=interval*11, xScale=1, yScale=1, alpha=1, time=300, transition=easing.outBack,
                            onComplete=function()
                            tap_enabled = true
                        end} )

                        transition.to( family_message, {delay=interval*18, xScale=1, yScale=1, alpha=1, time=300, transition=easing.outBack,
                            onComplete=function()
                            sound.swoosh()
                        end} )
                        star_timer = timer.performWithDelay( 10000, function()
                            sound.stars()
                            utils.star_explosion(please_rate.x, please_rate.y)
                        end )
                        transition.to( please_rate, {delay=10000, xScale=1, yScale=1, alpha=1, time=300, transition=easing.outBack,
                            onComplete=function()
                                shake(please_rate)
                            end} )
                    end

                    local touch_timer
                    local function handle_parents_touch(event)
                        if not tap_enabled then return true end

                        if event.phase == 'began' then
                            print( event.phase )
                            display.currentStage:setFocus(event.target)
                            event.target.is_focus = true
                            touch_timer = timer.performWithDelay( 5000, function()
                                display.currentStage:setFocus(nil)
                                event.target.is_focus = nil
                                show_parents_section()
                                tap_enabled = false
                             end)
                        elseif event.phase == 'ended' or event.phase == 'cancelled' then
                            print( event.phase )
                            display.currentStage:setFocus(nil)
                            event.target.is_focus = nil
                            timer.cancel( touch_timer )
                            shake(parents_bubble)
                            sound.oops()
                        end
                        return true
                    end

                    logo.handle_parents_touch = handle_parents_touch
                    logo:addEventListener( 'touch', handle_parents_touch )
                    parents_bubble:addEventListener( 'touch', handle_parents_touch )
                end})
                if stage.music_volume.xScale < 1 then
                    transition.to( stage.music_volume, {xScale=1, yScale=1, alpha=1, time=300, transition=easing.outBack, onComplete=function()
                        -- add touch event handler
                        stage.music_volume:addEventListener( 'tap', function()
                            if stage.music_volume[1].alpha == 0 then
                                -- turn bg music ON
                                stage.music_volume[1].alpha = 1
                                stage.music_volume[2].alpha = 0
                                sound.turn_bg_music_on()
                            else
                                -- turn bg music OFF
                                stage.music_volume[1].alpha = 0
                                stage.music_volume[2].alpha = 1
                                sound.turn_bg_music_off()
                            end

                            return true
                        end )
                    end })
                end
                -- add the touch event handlers
                title:addEventListener( 'tap', function()
                    if not tap_enabled then return true end
                    tap_enabled = false
                    shake(title)
                end )

                local function transition_out(on_complete)
                    audio.fadeOut({channel=sound.CHANNEL_INTRO, time=500})
                    -- stop all timers
                    if color_timer then timer.cancel( color_timer ) end

                    transition.to( title, {xScale=.01, yScale=.01, alpha=0, time=300, transition=easing.inBack,} )
                    transition.to( flashcard_button, {delay=65, xScale=.01, yScale=.01, alpha=0, time=300, transition=easing.inBack,} )
                    transition.to( quiz_button, {delay=130, xScale=.01, yScale=.01, alpha=0, time=300, transition=easing.inBack,} )
                    transition.to( parents_bubble, {delay=260, xScale=.01, yScale=.01, alpha=0, time=300, transition=easing.inBack,} )
                    local delay = 260 + 30
                    helper.shuffle_table(animal_indexes)
                    for i=1,#animal_indexes do
                        local index = animal_indexes[i]
                        local c = animals[index]
                        transition.to( c, {delay=delay, xScale=.01, yScale=.01, alpha=0, time=300, transition=easing.inBack,} )
                        delay = delay + 30
                    end
                    delay = delay + 270
                    transition.to( logo, {delay=delay, xScale=.01, yScale=.01, alpha=0, time=300,
                        transition=easing.inBack, onComplete=function()
                        local current_scene = composer.getSceneName( "current" )
                        composer.removeScene( current_scene )
                        on_complete()
                    end })
                end

                flashcard_button:addEventListener( 'tap', function()
                    if not tap_enabled then return true end
                    tap_enabled = false
                    sound.pop(1)
                    transition_out(function()
                        sound.play_bg_music_flashcards()
                        composer.gotoScene('com.alpabeto.flashcard')
                    end)
                end )

                quiz_button:addEventListener( 'tap', function()
                    if not tap_enabled then return true end
                    tap_enabled = false
                    sound.pop(2)
                    transition_out(function()
                        sound.play_bg_music_quiz()
                        composer.gotoScene('com.alpabeto.quiz')
                    end)
                end )

                tap_enabled = true

                -- add color cycling effect
                local current_color = 2
                color_timer = timer.performWithDelay( 6000, function()
                    local delay = 0
                    local j = 1

                    local fc = helper.toddler_colors[current_color]
                    transition.to( flashcard_button[2].fill, {time=3000, r=fc[1], g=fc[2], b=fc[3]} )
                    local qc = helper.animals_colors[current_color]
                    transition.to( quiz_button[2].fill, {time=3000, r=qc[1], g=qc[2], b=qc[3]} )
                    
                    current_color = current_color + 1
                    if current_color > #helper.toddler_colors then
                        current_color = 1
                    end

                    -- change to a different animal background
                    helper.shuffle_table(helper.animals)
                    helper.shuffle_table(animal_indexes)
                    local delay = 0
                    for i=1,#animal_indexes do
                        local index = animal_indexes[i]
                        local c = animals[index]
                        local animal_image = display.newImageRect( c, helper.animal_thumbnail(helper.animals[i]),
                            helper.THUMBNAIL_WIDTH, helper.THUMBNAIL_HEIGHT )
                        animal_image.alpha = 0
                        transition.fadeIn( animal_image, {delay=delay, onComplete=function()
                            c[1]:removeSelf( )
                            c[1] = nil
                        end} )
                        delay = delay + 65
                    end
                end, -1 )
            end} )
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