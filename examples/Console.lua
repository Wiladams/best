--[[
    Representation of a console, which can display
    text, and act as the general canvas for a Terminal program
]]

local ffi = require("ffi")
local C = ffi.C 
local bit = require("bit")
local band, bor = bit.band, bit.bor
local bnot = bit.bnot
local unicode = require("unicode")

local exports = {}

local TSM_SCREEN_INSERT_MODE	= 0x01;
local TSM_SCREEN_AUTO_WRAP	= 0x02;
local TSM_SCREEN_REL_ORIGIN	= 0x04;
local TSM_SCREEN_INVERSE	    = 0x08;
local TSM_SCREEN_HIDE_CURSOR	= 0x10;
local TSM_SCREEN_FIXED_POS	= 0x20;
local TSM_SCREEN_ALTERNATE	= 0x40;

ffi.cdef[[
typedef uint32_t tsm_age_t;
typedef uint32_t tsm_symbol_t;

]]





local SymbolTable = {
--	unsigned long ref;
--	uint32_t next_id;
--	struct shl_array *index;
--	struct shl_htable symbols;
}

function SymbolTable.new(self)
    local obj = {
        ref = 1;
        next_id = TSM_UCS4_MAX + 2;
        symbols = {};
    }

    setmetatable(obj, SymbolTable_mt)
    return obj
end

function SymbolTable.make(self, ucs4)
    if ucs4 > UNICODE_UCS4_MAX then
        return 0;
    end

    return ucs4
end

function SymbolTable.append(self, sym, ucs4)
end

function SymbolTable.get(self, sym, size)
end

function SymbolTable.getWidth(self, sym)
    local ch, len = self:get(sym)
    if len == 0 then
        return 0;
    end

    return tsm_ucs4_get_width(ch)
end



--	const uint32_t * get(tsm_symbol_t *sym, size_t *size);
--	tsm_symbol_t make(uint32_t ucs4);
--	tsm_symbol_t append(tsm_symbol_t sym, uint32_t ucs4);


ffi.cdef[[
enum attr_style {
	bold		= 0x01,
	underline	= 0x02,
	inverse		= 0x04,
	protect		= 0x08,
	blink		= 0x10
};
]]

ffi.cdef[[
struct tsm_screen_attr {
	int8_t fccode;			/* foreground color code or <0 for rgb */
	int8_t bccode;			/* background color code or <0 for rgb */
	uint8_t fr;			/* foreground red */
	uint8_t fg;			/* foreground green */
	uint8_t fb;			/* foreground blue */
	uint8_t br;			/* background red */
	uint8_t bg;			/* background green */
	uint8_t bb;			/* background blue */
	unsigned int bold : 1;		/* bold character */
	unsigned int underline : 1;	/* underlined character */
	unsigned int inverse : 1;	/* inverse colors */
	unsigned int protect : 1;	/* cannot be erased */
	unsigned int blink : 1;		/* blinking character */
};
]]

tsm_screen_attr = ffi.typeof("struct tsm_screen_attr")
ffi.metatype(tsm_screen_attr, {
    __new = function(ct,...)
        local obj = ffi.new(ct, ...);
        obj.fccode = -1;
        obj.bccode = -1;
        
        obj.fr = 255;
        obj.fg = 255;
        obj.fb = 255;

        obj.br = 0;
        obj.bg = 0;
        obj.bb = 0;

        obj.bold = 0;
        obj.underline = 0;
        obj.inverse = 0;
        obj.protect = 0;
        obj.blink = 0;

        return obj;
    end;
})

ffi.cdef[[
struct cell {
	tsm_symbol_t ch;		    // stored character
	size_t width;		    // character width 
	struct tsm_screen_attr attr;	// cell attributes 
	tsm_age_t age;			    // age of the single cell 
};
]]
local cell = ffi.typeof("struct cell")

ffi.metatype("struct cell", {
    __new = function(ct, con)
        local obj = ffi.new("struct cell");

        if not con then
            obj.ch = 0;
            obj.width = 1;
            obj.age = 0;
        else
            obj:init(con) 
        end


        return obj;
    end;

    __index = {
        init = function(self, con)
            self.ch = 0;
            self.width = 1;
            self.age = con.age_cnt;
            self.attr = con.def_attr;
        end;
    }
})


local line = {}
setmetatable(line, {
    __call = function(self, ...)
        return self:new(...)
    end;
})
local line_mt = {
    __index = line;
}

function line.new(self, con, width)
    local obj = {
        next = nil;
        prev = nil;
        size = width;
        age = con.age_cnt;
        sb_id = 0;
        cells = ffi.new("struct cell[?]", width)
    }
    setmetatype(obj, line_mt)

    return obj
end

function line.initCells(self, con)
    for i=0, self.size-1 do 
        self.cells[i]:init(con);
    end
end

function line.resize(self, con, width)
    local tmp;

    if width == 0 then
        return false, "invalid width";
    end

    if self.size < width then
        tmp = ffi.new("cell[?]", width)
        if not tmp then
            return false, "not enough memory"
        end
        -- copy all current cells
        for i=0,self.size-1 do
            tmp[i] = self.cells[i];
        end

        self.cells = tmp

        -- initialize new cells
        while self.size < width do
            self.cells[size]:init(con)
            self.size = self.size + 1;
        end
    end

    return true;
end


local SELECTION_TOP = -1;

local selection_pos = {}
local selection_pos_mt = {
    __index = selection_pos;
}


function selection_pos.new(self, line, x, y) 
    local obj = {
        line = line;
        x = x or 0;
        y = y or 0;
    }
    setmetatable(obj, selection_pos_mt)

    return obj;
end



local ScrollbackBuffer ={}
setmetatable(ScrollbackBuffer, {
    __call = function(self, ...)
        return self:new(...)
    end;
})
local ScrollbackBuffer_mt = {
    __index = ScrollbackBuffer;
}

function ScrollbackBuffer.new(self, con, lmax)
    obj = obj or {
        con = con;
        sb_count = 0;       -- number of lines in sb
        sb_first = nil;     -- first line; was moved first
        sb_last = nil;      -- last line; was moved last
        sb_max = 0;         -- max-limit of lines in sb
        sb_pos = nil;       -- current position in sb or NULL
        sb_last_id = 0;     -- last id given to sb-line
    }
    setmetatable(obj, ScrollbackBuffer_mt);

    obj:setMax(lmax)

    return obj
end	

function ScrollbackBuffer.getCount(self)
    return self.sb_count;
end

function ScrollbackBuffer.getFirst(self)
    return self.sb_first;
end

function ScrollbackBuffer.getLast(self)
    return self.sb_last;
end

function ScrollbackBuffer.getLastId(self)
    return self.sb_last_id;
end

function ScrollbackBuffer.getMax(self)
    return self.sb_max;
end

function ScrollbackBuffer.getPosition(self)
    return self.sb_pos;
end

function ScrollbackBuffer.setFirst(self, aline)
    self.sb_first = aline;
end

function ScrollbackBuffer.setLast(self, aline)
    self.sb_last = aline;
end

function ScrollbackBuffer.setMax(self, num)
    self.con:incrementAge();
    self.con:alignAge();

    local aline;
    while (self.sb_count > num) do
        aline = self.sb_first;
        self.sb_first = aline.next;
        if line.next then
            line.next.prev = nil;
        else
            self.sb_last = nil;
        end

        self.sb_count = self.sb_count - 1;

        if self.sb_pos == aline then
            self.sb_pos = self.sb_first;
        end
        
        if (self.con:getSelection():isActive()) then
            if (self.con:getSelection():getStart().line == aline) then
                self.con:getSelection():getStart().line = nil;
                self.con:getSelection():getStart().y = SELECTION_TOP;
            end

            if (self.con:getSelection():getEnd().line == aline) then
                self.con:getSelection():getEnd().line = nil;
                self.con:getSelection():getEnd().y = SELECTION_TOP;
            end
        end

        -- delete aline
    end

    self.sb_max = num;
end


function ScrollbackBuffer.setPosition(self, pos)
    self.sb_pos = pos;
end

function ScrollbackBuffer.decrementCount(self)
    self.sb_count = self.sb_count - 1;
    return self.sb_count;
end

function ScrollbackBuffer.incrementCount(self)
    self.sb_count = self.sb_count + 1;
    return self.sb_count;
end

function ScrollbackBuffer.incrementLastId(self)
    self.sb_last_id = self.sb_last_id + 1;
    return self.sb_last_id;
end

function ScrollbackBuffer.reset(self)
    self.con:incrementAge();
    self.sb_pos = nil;
    
    return true;
end

function ScrollbackBuffer.clear(self)
    self.con:incrementAge();

    -- by unhooking the lines, we'll just let the garbage
    -- collector clean them up over time.

    self.sb_first = nil;
    self.sb_last = nil;
    self.sb_count = 0;
    self.sb_pos = nil;

    return true;
end

function ScrollbackBuffer.down(self, num)
    if num < 1 then
        return false, "number must be greater than 0"
    end

    self.con:incrementAge();

    while num > 0 do
        if self.sb_pos then
            self.sb_pos = self.sb_pos.next;
        else
            return ;
        end
        num = num - 1;
    end
end

function ScrollbackBuffer.up(self, num)
    if num < 1 then
        return false, "number must be greater than 0"
    end

    self.con:incrementAge();

    while (num > 0) do
        if self.sb_pos then
            if not self.sb_pos.prev then
                return  
            end
            self.sb_pos = self.sb_pos.prev;
        elseif not self.sb_last then
            return 
        else
            self.sb_pos = self.sb_last;
        end
        num = num -1;
    end
end

function ScrollbackBuffer.pageUp(self, num)
    if num < 1 then
        return false;
    end

    self.con:incrementAge();
    return self:up(num * self.con:getHeight())
end

function ScrollbackBuffer.pageDown(self, num)
    if num < 1 then
        return false;
    end
    self.con:incrementAge();
    return self:down(num * self.con:getHeight())
end



local tsm_screen = {}
setmetatable(tsm_screen, {
    __call = function(self, ...)
        return self:new(...)
    end;
})
local tsm_screen_mt = {
    __index = tsm_screen;
}

local uint = ffi.typeof("unsigned int")
local size_t = ffi.typeof("size_t")

function tsm_screen.new(self, obj)
	--llog_submit_t llog;
    --void *llog_data;
    obj = obj or {
	    ref = size_t();
        opts = uint();
        flags = uint();
        sym_table = SymbolTable();


	    -- default attributes for new cells
        def_attr = tsm_scrren_attr();

	    --   aging
	    age = 0ULL;		        -- whole screen age
	    age_cnt = 0ULL;		-- current age counter
        age_reset = 0;         -- age overflow flag

		-- current buffer
	    size_x = 0;		        -- width of screen
	    size_y = 0;		        -- height of screen
	    margin_top = 0;	        -- top-margin index
	    margin_bottom = 0;	    -- bottom-margin index
	    line_num = 0;		    -- real number of allocated lines
	    lines = nil;		-- active lines; copy of main/alt
	    main_lines = nil;	-- real main lines
	    alt_lines = nil;	-- real alternative lines

		-- scroll-back buffer

	    sb_count = 0;		-- number of lines in sb 
	    sb_first = nil;		-- first line; was moved first 
	    sb_last = nil;		-- last line; was moved last
	    sb_max = 0;		    -- max-limit of lines in sb 
	    sb_pos = nil;		-- current position in sb or NULL 
	    sb_last_id = 0;		-- last id given to sb-line 

							-- cursor: positions are always in-bound, but cursor_x might be
							-- bigger than size_x if new-line is pending
	    cursor_x = 0;		-- current cursor x-pos
	    cursor_y = 0;		-- current cursor y-pos

		-- tab ruler
	    tab_ruler = nil;		-- tab-flag for all cells of one row

		-- selection
		sel_active = false;
		sel_start = selection_pos();
        sel_end = selection_pos();
    }
    setmetatable(obj, tsm_screen_mt)

    return obj
end


--[[
/*
	Console

	A class encapsulating the concept and rendering of a generic console.
	This class has the simple writing functions necessary to put symbols
	on the screen in a structured manner.

	Construction of a more complex virtual terminal requires parsing input
	and interpreting the commands, turning them into console instructions.

	This console object assumes it is drawing into the general drawproc window,
	so it makes use of the global drawproc drawing calls, such as 'text()'.
*/
--]]

local Console = {}
local Console_mt = {
    __index = Console;
}

function Console.init(self, obj, width, height)
    if not obj then
        return nil;
    end

    obj.screen = tsm_screen();
    self.screen.ref = 1;
    
    setmetatable(obj, Console_mt)

    --obj.Width = width;
    --obj.Height = height;

    obj:resize(width, height)
end

function Console.new(self, width, height)
    local obj = {}

    obj.defaultattr = tsm_screen_attr();
    obj.scrollBuffer = ScrollbackBuffer();
    obj.selection = ScreenSelection();

    return self:init(ob, width, height)
end

--[[
	// internal routines
	int _init(const size_t width, const size_t height);
	void eraseRegion(unsigned int x_from,
		unsigned int y_from,
		unsigned int x_to,
		unsigned int y_to,
		bool protect);
	
	void link_to_scrollback(struct line *aline);
	void scrollScreenUp(size_t num);
	void scrollScreenDown(size_t num);

public:
	// Construction
	Console(const size_t width, const size_t height);
	~Console();

    void incrementAge();
--]]

function Console.alignAge(self)
    self.screen.age = self.screen.age_cnt;
    return true;
end

function Console.getLines(sekf)
    return self.screen.lines;
end

function Console.getScrollbackBuffer(self)
    return self.scrollBuffer;
end

function Console.getSelection()
    return self.selection;
end

--[[
	void setFlags(unsigned int flags);
	void resetFlags(unsigned int flags);
	unsigned int getFlags() const;
-]]

function Console.setOptions(self, opts)
    if not opts or opts == 0 then
        return false;
    end

    self.screen.opts = bor(self.screen.opts, opts)
    
    return true;
end

function Console.resetOptions(self, opts)
    if not opts or opts == 0 then
        return false;
    end

	self.screen.opts = band(self.screen.opts, bnot(opts));
    
    return true;
end

function Console.getOptions(self)
	return self.screen.opts;
end

--[[
	void setDefaultAttribute(const struct tsm_screen_attr & attr);

	void reset();
	int resize(size_t x, size_t y);
	int createNewLine(struct line **out, size_t width);
--]]

-- Various screen attributes
function Console.getCursorX(self)
    return self.screen.cursor_x;
end

function Console.getCursorY(self)
    return self.screen.cursor_y;
end

function Console.getWidth(self)
    return self.screen.size_x;
end

function Console.getHeight(self)
    return self.screen.size_y;
end

--[[
	// writing text
	void writeSymbolAt(size_t x, size_t y, tsm_symbol_t ch, unsigned int len, const struct tsm_screen_attr *attr);
	void writeSymbol(tsm_symbol_t ch, const struct tsm_screen_attr *attr);
--]]
function Console.writeSymbolAt(self, x, y, ch, len, attr)

	if len == 0 then
		return;
    end

	if (x >= self.screen.size_x or y >= self.screen.size_y) then
		--llog_warning(con, "writing beyond buffer boundary");
		return;
    end

	local line = self.screen.lines[y];

	if (band(self.screen.flags, TSM_SCREEN_INSERT_MODE)~=0 and
		x < (self.screen.size_x - len)) then
        line.age = self.screen.age_cnt;
        -- move all the elements to the right by one
        -- BUGBUG
        -- do this in a simple loop
		memmove(&line->cells[x + len], &line->cells[x], sizeof(struct cell) * (screen.size_x - len - x));
    end

	line.cells[x].age = self.screen.age_cnt;
	line.cells[x].ch = ch;
    line.cells[x].width = len;
    line.cells[x].attr = attr;
	--memcpy(&line.cells[x].attr, attr, sizeof(*attr));

    local i = 1;
	while i < len and i + x < self.screen.size_x do
		line.cells[x + i].age = self.screen.age_cnt;
        line.cells[x + i].width = 0;
        
        i = i + 1;
    end
end

--[[
	writeSymbol(ch, attr)

	write the given symbol at the current screen cursor location
--]]
function Console.writeSymbol(self, ch, attr)

	local len = screen.sym_table:getWidth(ch);
	if len == 0 then
        return;
    end

	self:incrementAge();

    local last = 0;

	if (self.screen.cursor_y <= self.screen.margin_bottom or
		self.screen.cursor_y >= self.screen.size_y) then
        last = self.screen.margin_bottom;
	else
		last = self.screen.size_y - 1;
    end

	if (screen.cursor_x >= screen.size_x) then
		if band(screen.flags, TSM_SCREEN_AUTO_WRAP) ~= 0 then
			self:moveCursor(0, self.screen.cursor_y + 1);
		else
            self:moveCursor(self.screen.size_x - 1, self.screen.cursor_y);
        end
    end

	if (self.screen.cursor_y > last) then
		self:moveCursor(screen.cursor_x, last);
		self:scrollUp(1);
    end

	self:writeSymbolAt(self.screen.cursor_x, self.screen.cursor_y, ch, len, attr);
	self:moveCursor(self.screen.cursor_x + len, self.screen.cursor_y);
end

-- null terminated strings, or lua strings?
-- need to decide.  Maybe add a specific
-- writeCString?
-- BUGBUG
function Console.writeCString(self, str) 
	local idx = 0;
	while (str[idx] ~= 0) do 
	
		self:writeSymbol(str[idx], self.defaultattr);

		idx = idx + 1;
    end
end

function Console.write(self, str) 
    local n = #str
    str = ffi.cast("const char *", str)
    for counter=1,n do
		self:writeSymbol(str[counter-1], self.defaultattr);
		idx = idx + 1;
    end
end

function Console.writeLine(self, str)
	self:write(str);
    self:newline();
    
    return true;
end



--[[
	// Erasing parts of screen
	void eraseScreen(bool protect);
	void eraseCursor();
	void eraseChars( size_t num);
	void eraseCursorToEnd( bool protect);
	void eraseHomeToCursor( bool protect);
	void eraseCurrentLine( bool protect);
	void eraseScreenToCursor( bool protect);
	void eraseCursorToScreen( bool protect);
    --]]
    
    --[[
	// Deleting and inserting chars and lines
	void deleteChars(size_t num);
	void insertChars(size_t num);
	void deleteLines(size_t num);
	void insertLines(size_t num);
--]]

function Console.newline(self)

	self:incrementAge();

	self:moveDown(1, true);
	self:moveLineHome();
end

local function get_cursor_cell(con)
	local cur_x = con.cursor_x;
	if (cur_x >= con.size_x) then
		cur_x = con.size_x - 1;
    end

	local cur_y = con.cursor_y;
	if (cur_y >= con.size_y) then
		cur_y = con.size_y - 1;
    end

	return con.lines[cur_y].cells[cur_x];
end

function Console.moveCursor(self, x, y)

	-- if cursor is hidden, just move it
	if band(self.screen.flags , TSM_SCREEN_HIDE_CURSOR) ~= 0 then
		self.screen.cursor_x = x;
		self.screen.cursor_y = y;
		return;
    end

	-- If cursor is visible, we have to mark the current and the new cell
	-- as changed by resetting their age. We skip it if the cursor-position
	-- didn't actually change.

	if (self.screen.cursor_x == x and self.screen.cursor_y == y) then
        return;
    end

	local c = get_cursor_cell(self.screen);
	c.age = self.screen.age_cnt;

	self.screen.cursor_x = x;
	self.screen.cursor_y = y;

	c = get_cursor_cell(self.screen);
	c.age = self.screen.age_cnt;
end

function Console.moveTo(self, x, y)
    self:incrementAge();

    local last;

    if band(self.screen.flags, TSM_SCREEN_REL_ORIGIN) ~= 0 then
        last = self.screen.margin_bottom;
    else
        last = self.screen.size_y - 1;
    end

    x = self:to_abs_x(self.screen, x)
    if x >= self:getWidth() then
        x = self.screen.size_x - 1;
    end

    y = self:to_abs_y(self.screen, y);
    if y > last then
        y = last;
    end

    self:moveCursor(x,y)
end

--[[
	void moveDown(size_t num, bool scroll);
	void moveUp(size_t num, bool scroll);
	void moveLeft(size_t num);
	void moveRight(size_t num);
--]]
function Console.moveLineEnd(self)
	self:incrementAge();
	self:moveCursor(self.screen.size_x - 1, self.screen.cursor_y);
end


function Console.moveLineHome(self)
	self:incrementAge();
	self:moveCursor(0, self.screen.cursor_y);
end

--[[
	// Scrolling Control
	void setMaxScrollback(size_t num);
	void scrollBufferUp(size_t num);
	void scrollBufferDown(size_t num);

	void scrollUp(size_t num);
	void scrollDown(size_t num);

	// Margins
	int setMargins(size_t top, size_t bottom);


	// Tabbing
	void setTabstop();
	void resetTabstop();
	void resetAllTabstops();
	void tabLeft(size_t num);
	void tabRight(size_t num);



	// Drawing current state of screen
	tsm_age_t drawScreen(void *data);
};
--]]
function Console.draw(self, ctx)
end

return Console