package.path = "../?.lua;"..package.path;

--[[
References:
    http://www.columbia.edu/~fdc/utf8/
]]
local U = require("examples.unicode")

utf8_iterator = U.utf8_iterator

-- Some test cases
local test1 = "An preost wes on leoden, Laȝamon was ihoten"
local test2 = "He wes Leovenaðes sone -- liðe him be Drihten."
local test3 = "ᚠᛇᚻ᛫ᛒᛦᚦ᛫ᚠᚱᚩᚠᚢᚱ᛫ᚠᛁᚱᚪ᛫ᚷᛖᚻᚹᛦᛚᚳᚢᛗ"

-- I can eat glass and it doesn't hurt me
local test4 = "मैं काँच खा सकता हूँ और मुझे उससे कोई चोट नहीं पहुंचती"


--[[
    Given a UTF8 string, decode it and print all the 
    codepoint values
]]
function test_decode_utf8()
    --for codep in utf8_iterator(test4) do
    for codep in utf8_iterator(test3) do
        print(string.format("0x%04X",codep))
    end
end

test_decode_utf8();
