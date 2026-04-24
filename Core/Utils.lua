--========================================================--
--                 ASTRAL.Core.Utils
--========================================================--

local Utils = {}

function Utils.Normalize(str)
    if not str then return "" end
    return string.lower(tostring(str))
end

function Utils.NaturalSort(a, b)
    local function pad(n)
        return ("%09d"):format(tonumber(n) or 0)
    end

    a = tostring(a):gsub("(%d+)", pad)
    b = tostring(b):gsub("(%d+)", pad)
    return a < b
end

function Utils.FirstSix(str)
    if not str then return "" end
    return string.sub(tostring(str), 1, 6)
end

function Utils.IsLetters(str)
    if not str then return false end
    return tostring(str):match("^[A-Za-z]+$") ~= nil
end

-- "12=dog: 3 -- abc" → 12
function Utils.NumberBeforeEqual(str)
    if not str then return nil end
    local num = tostring(str):match("^(%d+)")
    return num and tonumber(num) or nil
end

-- Generic table emptiness check
function Utils.IsEmpty(t)
    if type(t) ~= "table" then
        return true
    end
    return next(t) == nil
end

return Utils
