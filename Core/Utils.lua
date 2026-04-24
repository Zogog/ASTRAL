--========================================================--
--                 ASTRAL.Core.Utils
--        General-purpose helper utilities
--========================================================--

local Utils = {}

--========================================================--
--                 STRING HELPERS
--========================================================--

-- Natural alphanumeric sort (e.g. "Pet2" < "Pet10")
function Utils.NaturalSort(a, b)
    local function pad(n)
        return ("%09d"):format(tonumber(n) or 0)
    end
    a = a:gsub("(%d+)", pad)
    b = b:gsub("(%d+)", pad)
    return a < b
end

-- First 6 characters of a string
function Utils.FirstSix(str)
    return string.sub(str, 1, 6)
end

-- Check if a string contains only A–Z letters
function Utils.IsLetters(str)
    return str:match("^[A-Za-z]+$") ~= nil
end

-- Extract the number before "=" in strings like "12=Dog"
function Utils.NumberBeforeEqual(str)
    return tonumber(str:match("^(%d+)"))
end

-- Extract content inside parentheses "(example)"
function Utils.InBrackets(str)
    return str:match("%((.-)%)")
end

--========================================================--
--                 TABLE HELPERS
--========================================================--

-- Returns true if table is empty
function Utils.IsEmpty(tbl)
    return next(tbl) == nil
end

-- Deep copy a table
function Utils.DeepCopy(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = (type(v) == "table") and Utils.DeepCopy(v) or v
    end
    return copy
end

-- Shallow merge two tables (b overwrites a)
function Utils.Merge(a, b)
    local result = {}
    for k, v in pairs(a) do result[k] = v end
    for k, v in pairs(b) do result[k] = v end
    return result
end

--========================================================--
--                 STRING CLEANING
--========================================================--

-- Remove special characters
function Utils.CleanString(str)
    return str:gsub("[^%w%s]", "")
end

-- Lowercase + trim
function Utils.Normalize(str)
    return str:lower():gsub("^%s*(.-)%s*$", "%1")
end

--========================================================--
--                 MATH HELPERS
--========================================================--

function Utils.Clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

function Utils.Round(num, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(num * mult + 0.5) / mult
end

--========================================================--
--                 EXPORT
--========================================================--

return Utils
