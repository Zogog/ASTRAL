--========================================================--
--                 ASTRAL.Core.Utils
--========================================================--

local Utils = {}

function Utils.Normalize(str)
    if not str then return "" end
    return string.lower(tostring(str))
end

function Utils.NaturalSort(a, b)
    local function pad(n) return ("%09d"):format(tonumber(n) or 0) end
    a = tostring(a):gsub("(%d+)", pad)
    b = tostring(b):gsub("(%d+)", pad)
    return a < b
end

function Utils.FirstSix(str)
    return string.sub(str, 1, 6)
end

function Utils.IsLetters(str)
    return str:match("^[A-Za-z]+$") ~= nil
end

return Utils
