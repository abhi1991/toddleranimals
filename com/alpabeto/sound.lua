local helper = require 'com.alpabeto.helper'
local stage = display.currentStage

-- load sound effects only once to the stage
stage.ANIMAL_NAME_SOUNDS = {}
stage.ANIMAL_SOUNDS = {}

if not stage.WHERE_IS_THE then
    stage.WHERE_IS_THE = {
        audio.loadSound('audio/interface/where-is-the.mp3'),
        audio.loadSound('audio/interface/find-the.mp3'),
        audio.loadSound('audio/interface/which-one-is-the.mp3'),
    }
end

if not stage.CORRECT then
    stage.CORRECT = {
        audio.loadSound('audio/interface/correct.mp3'),
        audio.loadSound('audio/interface/good-job.mp3'),
        audio.loadSound('audio/interface/very-good.mp3'),
        audio.loadSound('audio/interface/great.mp3'),
    }
end

if not stage.MAGICAL then stage.MAGICAL = audio.loadSound('audio/interface/magical.mp3') end
if not stage.OOPS then stage.OOPS = audio.loadSound('audio/interface/oops.mp3') end
if not stage.STARS then stage.STARS = audio.loadSound('audio/interface/stars.mp3') end

if not stage.BG_MUSIC_INTRO then stage.BG_MUSIC_INTRO = audio.loadStream('music/bensound-ukulele.mp3') end
if not stage.BG_MUSIC_FLASHCARDS then stage.BG_MUSIC_FLASHCARDS = audio.loadStream('music/bensound-cute.mp3') end
if not stage.BG_MUSIC_QUIZ then stage.BG_MUSIC_QUIZ = audio.loadStream('music/bensound-buddy.mp3') end

if not stage.POP_SOUNDS then
    stage.POP_SOUNDS = {
        audio.loadSound('audio/interface/pop1.wav'),
        audio.loadSound('audio/interface/pop2.wav'),
        audio.loadSound('audio/interface/pop3.wav'),
        audio.loadSound('audio/interface/pop4.wav'),
    }
end

if not stage.SWOOSH_SOUNDS then
    stage.SWOOSH_SOUNDS = {
        audio.loadSound('audio/interface/swoosh1.mp3'),
        audio.loadSound('audio/interface/swoosh2.mp3'),
        audio.loadSound('audio/interface/swoosh3.mp3'),
        audio.loadSound('audio/interface/swoosh4.mp3'),
    }
end

local M = {
    is_mute = false,
    ANIMAL_SOUND_CHANNEL = 4,
    ANIMAL_NAME_SOUND_CHANNEL = 5,
    CHANNEL_INTRO = 1,
    CHANNEL_FLASHCARDS = 2,
    CHANNEL_QUIZ = 3,
}


-- type is 1 to 4
function M.pop(type)
    if type == nil then
        audio.play(stage.POP_SOUNDS[math.random(#stage.POP_SOUNDS)])
    else
        audio.play(stage.POP_SOUNDS[type])
    end
end

-- type is 1 to 4
function M.swoosh(type)
    if type == nil then
        audio.play(stage.SWOOSH_SOUNDS[math.random(#stage.SWOOSH_SOUNDS)])
    else
        audio.play(stage.SWOOSH_SOUNDS[type])
    end
end

function M.where_is_the(on_complete)
    audio.play(stage.WHERE_IS_THE[math.random(#stage.WHERE_IS_THE)], {onComplete=on_complete})
end

function M.correct()
    audio.play(stage.CORRECT[math.random(#stage.CORRECT)])
end

function M.magical() audio.play(stage.MAGICAL) end
function M.oops() audio.play(stage.OOPS) end
function M.stars() audio.play(stage.STARS) end

-- load animal sound as needed

function M.play_animal_name_sound(animal, on_complete)
    local animal_name_sound = stage.ANIMAL_NAME_SOUNDS[animal]
    
    if not animal_name_sound then
        animal_name_sound = audio.loadSound('audio/' .. animal .. '.mp3')
        if animal_name_sound ~= nil then
            stage.ANIMAL_NAME_SOUNDS[animal] = animal_name_sound
        end
    end

    if not animal_name_sound then return end

    audio.play(animal_name_sound, { channel=M.ANIMAL_NAME_SOUND_CHANNEL, onComplete=function()
        if on_complete then on_complete() end
    end })
end

function M.play_animal_sound(animal, on_complete)
    if audio.isChannelPlaying( M.ANIMAL_SOUND_CHANNEL ) then return end

    local animal_sound = stage.ANIMAL_SOUNDS[animal]
    
    if not animal_sound then
        animal_sound = audio.loadSound('audio/sounds/' .. animal .. '.mp3')
        if animal_sound ~= nil then
            stage.ANIMAL_SOUNDS[animal] = animal_sound
        end
    end

    if not animal_sound then return end

    audio.play(animal_sound, { channel=M.ANIMAL_SOUND_CHANNEL, onComplete=function()
        if on_complete then on_complete() end
    end })
end

function M.play_bg_music_intro()
    audio.fadeOut({channel=M.CHANNEL_FLASHCARDS, time=500})
    audio.fadeOut({channel=M.CHANNEL_QUIZ, time=500})

    audio.rewind(stage.BG_MUSIC_INTRO)
    if not M.is_mute then
        audio.setVolume(1, {channel=M.CHANNEL_INTRO})
    else
        audio.setVolume(0, {channel=M.CHANNEL_INTRO})
    end

    timer.performWithDelay( 500, function()
        audio.play(stage.BG_MUSIC_INTRO, {channel=M.CHANNEL_INTRO, loops=-1})
    end )
end

function M.play_bg_music_flashcards()
    audio.rewind(stage.BG_MUSIC_QUIZ)
    if not M.is_mute then
        audio.setVolume(.1, {channel=M.CHANNEL_QUIZ})
    end
    audio.play(stage.BG_MUSIC_QUIZ, {channel=M.CHANNEL_QUIZ, loops=-1})
end

function M.play_bg_music_quiz()
    audio.rewind(stage.BG_MUSIC_FLASHCARDS)
    if not M.is_mute then
        audio.setVolume(.1, {channel=M.CHANNEL_FLASHCARDS})
    end
    audio.play(stage.BG_MUSIC_FLASHCARDS, {channel=M.CHANNEL_FLASHCARDS, loops=-1})
end

function M.turn_bg_music_on()
    audio.setVolume(1, {channel=M.CHANNEL_INTRO})
    audio.setVolume(.1, {channel=M.CHANNEL_FLASHCARDS})
    audio.setVolume(.1, {channel=M.CHANNEL_QUIZ})
    M.is_mute = false
end

function M.turn_bg_music_off()
    audio.setVolume(0, {channel=M.CHANNEL_INTRO})
    audio.setVolume(0, {channel=M.CHANNEL_FLASHCARDS})
    audio.setVolume(0, {channel=M.CHANNEL_QUIZ})
    M.is_mute = true
end

return M