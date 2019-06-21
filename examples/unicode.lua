--[[
    A set of UNICODE related routines

    conversion to/from utf8
]]
local ffi = require("ffi")
local bit = require("bit")
local band, bor = bit.band, bit.bor
local lshift, rshift = bit.lshift, bit.rshift

local uint32_t = ffi.typeof("uint32_t")

UNICODE_UCS4_MAX = 0x7fffffff;
UNICODE_UCS4_INVALID = (UNICODE_UCS4_MAX + 1)
UNICODE_UCS4_REPLACEMENT = 0xfffd;
UNICODE_UCS4_MAXLEN = 10

--tsm_utf8_mach_state = {
TSM_UTF8_START      = 0;
TSM_UTF8_ACCEPT     = 1;
TSM_UTF8_REJECT     = 2;
TSM_UTF8_EXPECT1    = 3;
TSM_UTF8_EXPECT2    = 4;
TSM_UTF8_EXPECT3    = 5;
--};

local UTF8_ACCEPT = 0
local UTF8_REJECT = 12

--[[
    State table used to decode utf8
]]
local utf8d = ffi.new("const uint8_t[364]", {
  -- The first part of the table maps bytes to character classes that
  -- to reduce the size of the transition table and create bitmasks.
   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
   1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,  9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,
   7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,  7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,
   8,8,2,2,2,2,2,2,2,2,2,2,2,2,2,2,  2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
  10,3,3,3,3,3,3,3,3,3,3,3,3,4,3,3, 11,6,6,6,5,8,8,8,8,8,8,8,8,8,8,8,
 
  -- The second part is a transition table that maps a combination
  -- of a state of the automaton and a character class to a state.
   0,12,24,36,60,96,84,12,12,12,48,72, 12,12,12,12,12,12,12,12,12,12,12,12,
  12, 0,12,12,12,12,12, 0,12, 0,12,12, 12,24,12,12,12,12,12,24,12,24,12,12,
  12,12,12,12,12,12,12,24,12,12,12,12, 12,24,12,12,12,12,12,12,12,24,12,12,
  12,12,12,12,12,12,12,36,12,36,12,12, 12,36,12,12,12,12,12,36,12,36,12,12,
  12,36,12,12,12,12,12,12,12,12,12,12,
});
 
function decode_utf8_byte(state, codep, byte)
  local ctype = utf8d[byte];
  if (state ~= UTF8_ACCEPT) then
    codep = bor(band(byte, 0x3f), lshift(codep, 6))
  else
    codep = band(rshift(0xff, ctype), byte);
  end
  state = utf8d[256 + state + ctype];
  return state, codep;
end

--[[
Given a UTF-8 string, this routine will feed
out UNICODE code points as an iterator.

Usage:

for codepoint, err in utf8_string_iterator(utf8string) do
  print(codepoint)
end
--]]

function utf8_string_iterator(utf8string, len)
    len = len or #utf8string
    local state = UTF8_ACCEPT
    local codep =0;
    local offset = 0;
    local ptr = ffi.cast("uint8_t *", utf8string)
    local bufflen = len;
  
    return function()
      while offset < bufflen do
        state, codep = decode_utf8_byte(state, codep, ptr[offset])
        offset = offset + 1
        if state == UTF8_ACCEPT then
          return codep
        elseif state == UTF8_REJECT then
          return nil, state
        end
      end
      return nil, state;
    end
  end



return {
    utf8_iterator = utf8_string_iterator;
}