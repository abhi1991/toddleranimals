-----------------------------------------------------------------------------------------
--
-- color.lua
--
-----------------------------------------------------------------------------------------

--[[
 * Converts an HSV color value to RGB. Conversion formula
 * adapted from http://en.wikipedia.org/wiki/HSV_color_space.
 * Assumes h, s, and v are contained in the set [0, 1] and
 * returns r, g, and b in the set [0, 255].
 *
 * @param   Number  h       The hue
 * @param   Number  s       The saturation
 * @param   Number  v       The value
 * @return  Array           The RGB representation
 *
 * from https://github.com/EmmanuelOga/columns/blob/master/utils/color.lua
]]
local function hsv_to_rgb(h, s, v, a)
  local r, g, b

  local i = math.floor(h * 6);
  local f = h * 6 - i;
  local p = v * (1 - s);
  local q = v * (1 - f * s);
  local t = v * (1 - (1 - f) * s);

  i = i % 6

  if i == 0 then r, g, b = v, t, p
  elseif i == 1 then r, g, b = q, v, p
  elseif i == 2 then r, g, b = p, v, t
  elseif i == 3 then r, g, b = p, q, v
  elseif i == 4 then r, g, b = t, p, v
  elseif i == 5 then r, g, b = v, p, q
  end

  -- return r * 255, g * 255, b * 255, a * 255
  return {r, g, b}
end

-- use golden ratio
local golden_ratio_conjugate = 0.618033988749895
-- local golden_ratio_conjugate = 2^.5

local h
local function random_color(s, v)
  h = h + golden_ratio_conjugate
  h = h % 1
  -- return hsv_to_rgb(h, 0.5, 0.95)
  return hsv_to_rgb(h, s, v, 1)
end

local M = {}


M.rgb = function(r, g, b)
    return {r/255, g/255, b/255}
end

M.DEFAULT_BG = M.rgb(173, 210, 25)
M.gold = M.rgb(255, 215, 0)

M.is_light = true

local light_colors
local dark_colors

function M.generate_colors(num_colors)
    num_colors = num_colors or 10
    light_colors = {}
    dark_colors = {}

    local s,v = 1.0, 1.0

    local start = math.random( )
    for i=1,num_colors do
        local h = i/(num_colors*7) + start
        light_colors[i] = hsv_to_rgb(h, s, v, 1)
    end

    repeat
        v = math.random( )
    until v >= .5 and v <= .62

    for i=1,num_colors do
        local h = i/num_colors
        dark_colors[i] = hsv_to_rgb(h, s, v, 1)
    end

    return M.is_light and light_colors or dark_colors
end

M.generate_colors()

local bool = {true, false}

-----------------------------------------------------------------------------------------
-- PUBLIC FUNCTIONS
-----------------------------------------------------------------------------------------

local function list()
    local colors = M.is_light and light_colors or dark_colors

    local colors_copy = {}
    for i=1,#colors do
        colors_copy[i] = {}
        for j=1,#colors[i] do
            colors_copy[i][j] = colors[i][j]
        end
    end

    return colors_copy
end


function M.random()
    local colors = list()
    local color = colors[math.random(#colors)]
    return {color[1], color[2], color[3]}
end



function M.random_except(...)
    local colors = list()
    for k,v in ipairs(arg) do
        for i=#colors,1,-1 do
            local fill = colors[i]
            if fill[1] == v[1]
                and fill[2] == v[2]
                and fill[3] == v[3] then
                table.remove(colors, i)
            end
        end
    end

    local color = colors[math.random(#colors)]
    -- local color = colors[1]
    return {color[1], color[2], color[3]}
end


return M