local M = {

    TOP = (display.contentHeight-display.actualContentHeight)/2,
    BOTTOM = display.contentHeight - (display.contentHeight-display.actualContentHeight)/2,
    BLACK_HEIGHT = 154,
    LETTER_SPACE = 10,
    stage = display.getCurrentStage( ),
    ARROW_HEIGHT = 50,
    HOME_WIDTH = 63,
    THUMBNAIL_WIDTH = 276,
    THUMBNAIL_HEIGHT = 207,

    toddler_colors = {
        { 34/255, 129/255, 238/255},
        {116/255,  76/255, 129/255},
        {  0/255, 255/255, 192/255},
        {255/255, 114/255, 153/255},
        { 95/255,  84/255, 186/255},
        {252/255, 120/255,  70/255},
        {230/255,   0/255, 255/255},
    },

    animals_colors = {
        {172/255,  95/255, 236/255},
        {250/255,  89/255, 113/255},
        {135/255, 195/255, 183/255},
        {228/255, 151/255,  30/255},
        {240/255,  66/255, 129/255},
        {112/255, 146/255,  83/255},
        { 46/255, 179/255, 139/255},
    },

    letter = {
        height = 157,
        a = { width = 65, name='a', },
        b = { width = 73, name='b', },
        c = { width = 66, name='c', },
        d = { width = 74, name='d', },
        e = { width = 70, name='e', },
        f = { width = 52, name='f', },
        g = { width = 73, name='g', },
        h = { width = 70, name='h', },
        i = { width = 24, name='i', },
        j = { width = 38, name='j', },
        k = { width = 66, name='k', },
        l = { width = 24, name='l', },
        m = { width = 108, name='m', },
        n = { width = 70, name='n', },
        o = { width = 72, name='o', },
        p = { width = 73, name='p', },
        q = { width = 73, name='q', },
        r = { width = 45, name='r', },
        s = { width = 56, name='s', },
        t = { width = 51, name='t', },
        u = { width = 66, name='u', },
        v = { width = 66, name='v', },
        w = { width = 98, name='w', },
        x = { width = 63, name='x', },
        y = { width = 66, name='y', },
        z = { width = 59, name='z', },
        _ = { width = 45, name='_', },
    },

    animals = {
        'ant',
        'bat',
        'bear',
        'bee',
        'bird',
        'butterfly',
        'camel',
        'cat',
        'chicken',
        'cow',
        'crab',
        'crocodile',
        'deer', 
        'dog',
        'dolphin',
        'dragonfly',
        'duck',
        'eagle',
        'elephant',
        'fish',
        'fly',
        'fox',
        'frog',
        'goat',
        'goose',
        'grasshopper',
        'horse',
        'iguana',
        'jellyfish', 
        'lion',
        'lizard',
        'monkey',
        'mosquito',
        'mouse',
        'owl',
        'peacock',
        'pig',
        'rabbit',
        'scorpion',
        'shark',
        'sheep',
        'shrimp',
        'snail',
        'snake',
        'spider',
        'squid',
        'squirrel',
        'stingray',
        'tiger',
        'turkey',
        'turtle',
        'whale',
        'wolf',
        'zebra',
        -- 'carabao',
        -- 'cockroach',
        -- 'crow',
        -- 'earthworm',
        -- 'firefly',
        -- 'gorilla',
        -- 'hawk',
        -- 'rooster',
        -- 'sparrow',
        -- 'tarsier',
        -- 'whale_shark',
        -- 'worm',
    },

    animals_filipino = {
        ant = 'langgam',
        bat = 'paniki',
        bear = 'oso',
        bee = 'bubuyog',
        bird = 'ibon',
        butterfly = 'paruparo',
        camel = 'kamelyo',
        carabao = 'kalabaw',
        cat = 'pusa',
        chicken = 'manok',
        cockroach = 'ipis',
        cow = 'baka',
        crab = 'alimango',
        crocodile = 'buwaya',
        crow = 'uwak',
        deer = 'usa',
        dog = 'aso',
        dolphin = 'lumba-lumba',
        dragonfly = 'tutubi',
        duck = 'pato',
        eagle = 'agila',
        earthworm = 'bulati',
        elephant = 'elepante',
        firefly = 'alitaptap',
        fish = 'isda',
        fly = 'langaw',
        fox = 'sora',
        frog = 'palaka',
        goat = 'kambing',
        goose = 'gansa',
        gorilla = 'gorilya',
        grasshopper = 'balang',
        hawk = 'lawin',
        horse = 'kabayo',
        iguana = 'bayawak',
        jellyfish = 'dikya',
        lion = 'leon',
        lizard = 'butiki',
        monkey = 'unggoy',
        mosquito = 'lamok',
        mouse = 'daga',
        owl = 'kuwago',
        peacock = "pabo_real",
        pig = 'baboy',
        rabbit = 'kuneho',
        scorpion = 'alakdan',
        shark = 'pating',
        sheep = 'tupa',
        shrimp = 'hipon',
        snail = 'suso',
        snake = 'ahas',
        sparrow = 'pipit',
        spider = 'gagamba',
        squid = 'pusit',
        stingray = 'pagi',
        tarsier = 'mamag',
        tiger = 'tigre',
        turkey = 'pabo',
        turtle = 'pagong',
        whale = 'balyena',
        whale_shark = 'butanding',
        wolf = 'lobo',
        worm = 'uod',
        zebra = 'zebra',
    },
}

M.current_card = #M.animals + 1
M.letter['-'] = { width = 45, name='-', }

function M.letter_image(letter)
    return 'images/letters/' .. letter.name .. '.png'
end


function M.animal_image(animal_name)
    return 'images/animals/' .. animal_name .. '.jpg'
end

function M.animal_thumbnail(animal_name)
    return 'images/animals/thumbs/' .. animal_name .. '.jpg'
end


function M.table_length(t)
  local count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end


function M.shuffle_table(t)
    for i = #t, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
end


function M.random_except(...)
    local indexes = {}
    for i=1,#M.animals do
        indexes[i] = i
    end

    for i=1,#arg do
        for j=#indexes,1,-1 do
            if arg[i] == indexes[j] then
                table.remove(indexes, j)
            end
        end
    end
    return indexes[math.random(#indexes)]
end

function M.get_file(filename, base)
    if not base then base = system.ResourceDirectory; end
    local path = system.pathForFile(filename, base)
    local contents
    local file = io.open(path, 'r')
    if file then
       contents = file:read('*a')
       io.close(file) -- close the file after using it
    else
        assert(filename .. ' not found')
    end
    return contents
end

return M