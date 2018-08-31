local helper = require 'com.alpabeto.helper'
local sound = require 'com.alpabeto.sound'
local json = require 'json'

local particle = json.decode(helper.get_file('explosion.rg'))
local emitters = {}

local M = {
    
}

function M.animated_shuffle(view, on_complete)
    helper.shuffle_table(helper.animals)
    local MAX_ROT = 20
    local negator = {1, -1}
    local animals = display.newGroup( )
    view:insert( animals )
    animals:translate( display.contentCenterX, display.contentCenterY )
    animals:scale( 0.5, 0.5 )
    
    -- display "shuffling"
    local letters = display.newGroup( )
    view:insert( letters )
    local shuffling = "shuffling"
    local i = 0
    local word_width = 0
    for char in shuffling:gmatch"." do
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

    local delay = 0
    for i=1,letters.numChildren do
        local l = letters[i]
        transition.to( l, {delay=delay, xScale=1, yScale=1, alpha=1, transition=easing.outBack,} )
        delay = delay + 125
    end


    local function compute_quadrants()
        return {
            {x=-math.random(display.actualContentWidth), y=-display.actualContentHeight*1.5},
            {x=math.random(display.actualContentWidth), y=-display.actualContentHeight*1.5},
            {x=-math.random(display.actualContentWidth), y=display.actualContentHeight*1.5},
            {x=math.random(display.actualContentWidth), y=display.actualContentHeight*1.5},
            {x=-display.actualContentWidth*1.5, y=-math.random(display.actualContentHeight)},
            {x=-display.actualContentWidth*1.52, y=math.random(display.actualContentHeight)},
            {x=display.actualContentWidth*1.5, y=-math.random(display.actualContentHeight)},
            {x=display.actualContentWidth*1.5, y=math.random(display.actualContentHeight)},
        }
    end

    local MAX_CARDS = 18
    local delay = 0
    for i=1,MAX_CARDS do
        local animal_photo = display.newImage( helper.animal_image(helper.animals[i]) )
        animals:insert( animal_photo )

        local quadrants = compute_quadrants()
        local quadrant = quadrants[math.random(#quadrants)]

        animal_photo.x, animal_photo.y = quadrant.x, quadrant.y
        animal_photo.rotation = math.random( MAX_ROT )*negator[math.random(2)]

        local time = 1000
        local r = math.random( MAX_ROT )*negator[math.random(2)]

        if i == MAX_CARDS then
            timer.performWithDelay(delay, function()
                sound.swoosh(1)
            end )
        end

        transition.to( animal_photo, {delay=delay, time=time, x=0, y=0, rotation=r, transition=easing.outCubic, onComplete=function()
            quadrants = compute_quadrants()
            quadrant = quadrants[math.random(#quadrants)]
            local r = math.random( MAX_ROT )*negator[math.random(2)]
            if i == MAX_CARDS then sound.swoosh(2) end
            transition.to( animal_photo, {time=time/2, x=quadrant.x, y=quadrant.y, rotation=r, transition=easing.outCubic,
                onComplete=function()
                local r = math.random( MAX_ROT )*negator[math.random(2)]
                animals:insert( math.random( MAX_CARDS ), animal_photo )
                if i == MAX_CARDS then sound.swoosh(3) end
                transition.to( animal_photo, {time=time, x=0, y=0, rotation=r, transition=easing.outCubic, onComplete=function()
                    quadrants = compute_quadrants()
                    quadrant = quadrants[math.random(#quadrants)]
                    local r = math.random( MAX_ROT )*negator[math.random(2)]
                    if i == MAX_CARDS then sound.swoosh(4) end
                    transition.to( animal_photo, {time=time/2, x=quadrant.x, y=quadrant.y, rotation=r, transition=easing.outCubic,
                        onComplete=function()
                        if i == MAX_CARDS then
                            transition.fadeOut( view, {time=250, onComplete=function()
                                for j=MAX_CARDS,1,-1 do
                                    animals[j]:removeSelf( )
                                    animals[j] = nil
                                end
                                animals:removeSelf( )
                                animals = nil

                                for i=letters.numChildren,1-1 do
                                    letters[i]:removeSelf( )
                                    letters[i] = nil
                                end
                                
                                letters:removeSelf( )
                                letters = nil

                                if on_complete then on_complete() end
                            end} )
                        end
                    end} )
                end} )
            end} )
        end} )
    end
end


function M.star_explosion(x,y)
    local fill = {255/255, 215/255, 0/255}
    local image = 'images/interface/star.png'
    local x = x or display.contentCenterX
    local y = y or display.contentCenterY

    particle.textureFileName = image
    particle.startColorRed = fill[1]
    particle.startColorGreen = fill[2]
    particle.startColorBlue = fill[3]
    particle.finishColorRed = fill[1]
    particle.finishColorGreen = fill[2]
    particle.finishColorBlue = fill[3]

    local startColorAlphas =  {0.25, 0.50, 0.75}
    local finishColorAlphas = {0.10, 0.175, 0.25}
    particle.startColorAlpha = 1
    particle.finishColorAlpha = 1

    local emitter = display.newEmitter(particle)
    emitter.x, emitter.y = x, y

    -- add to emitter list for cleaning later
    emitters[#emitters+1] = emitter
end


function M.clean_explosions()
    for i=1,#emitters do
        local emitter = emitters[i]
        -- emitter:removeSelf()
        emitter:stop( )
        timer.performWithDelay( 250, function()
            emitter:removeSelf( )
        end )
    end
    emitters = {}
end

return M