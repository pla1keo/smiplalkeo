script_version('3.9')
script_author('plalkeo')

if MONET_DPI_SCALE == nil then MONET_DPI_SCALE = 1.0 end

function isMonetLoader() return MONET_VERSION ~= nil end

require "lib.moonloader"
local bLib = {}
bLib['mimgui'],						imgui = pcall(require, 'mimgui')
bLib['inicfg'],						inicfg = pcall(require, 'inicfg')
bLib['encoding'],					encoding = pcall(require, 'encoding')
bLib['Samp Events'],				sampev = pcall(require, "lib.samp.events")
bLib['fAwesome6'],					faicons = pcall(require, 'fAwesome6')
bLib['ffi'],						ffi = pcall(require, 'ffi')
if not isMonetLoader() then
	bLib['vkeys'],						vkeys = pcall(require, 'vkeys')
	bLib['mimgui hotkeys by chapo'],	hotkey = pcall(require, 'mimhotkey')
	bLib['MoonMonet'],					monet = pcall(require, 'MoonMonet')
	ffi.cdef [[
		void* __stdcall ShellExecuteA(void* hwnd, const char* op, const char* file, const char* params, const char* dir, int show_cmd);
		uint32_t __stdcall CoInitializeEx(void*, uint32_t);
		short GetKeyState(int nVirtKey);
		bool GetKeyboardLayoutNameA(char* pwszKLID);
		int GetLocaleInfoA(int Locale, int LCType, char* lpLCData, int cchData);
	]]


	local shell32 = ffi.load 'Shell32'
	local keys = require 'vkeys'
else
	local widgets = require('widgets')
end

function getFontsPath() 
	return not isMonetLoader() and getWorkingDirectory()..'\\lib\\Trebucbd.ttf' or 'Trebucbd.ttf'
end
	
local bitex = require 'bitex'
local memory = require 'memory'
encoding.default = 'CP1251'
u8 = encoding.UTF8
local print, clock, sin, cos, floor, ceil, abs, format, gsub, gmatch, find, char, len, upper, lower, sub, u8, new, str, sizeof = print, os.clock, math.sin, math.cos, math.floor, math.ceil, math.abs, string.format, string.gsub, string.gmatch, string.find, string.char, string.len, string.upper, string.lower, string.sub, encoding.UTF8, imgui.new, ffi.string, ffi.sizeof

-- ����� �� ADDONS.lua - https://www.blast.hk/threads/127255/
addons = {}
local AI_TOGGLE = {}
local ToU32 = imgui.ColorConvertFloat4ToU32
local ToVEC = imgui.ColorConvertU32ToFloat4
function bringVec4To(from, to, start_time, duration)
    local timer = os.clock() - start_time
    if timer >= 0.00 and timer <= duration then
        local count = timer / (duration / 100)
        return imgui.ImVec4(
            from.x + (count * (to.x - from.x) / 100),
            from.y + (count * (to.y - from.y) / 100),
            from.z + (count * (to.z - from.z) / 100),
            from.w + (count * (to.w - from.w) / 100)
        ), true
    end
    return (timer > duration) and to or from, false
end
function bringVec2To(from, to, start_time, duration)
    local timer = os.clock() - start_time
    if timer >= 0.00 and timer <= duration then
        local count = timer / (duration / 100)
        return imgui.ImVec2(
            from.x + (count * (to.x - from.x) / 100),
            from.y + (count * (to.y - from.y) / 100)
        ), true
    end
    return (timer > duration) and to or from, false
end
function bringFloatTo(from, to, start_time, duration)
    local timer = os.clock() - start_time
    if timer >= 0.00 and timer <= duration then
        local count = timer / (duration / 100)
        return from + (count * (to - from) / 100), true
    end
    return (timer > duration) and to or from, false
end
function addons.AlignedText(text, align, color)
	color = color or imgui.GetStyle().Colors[imgui.Col.Text]
	local width = imgui.GetWindowWidth()
	for line in text:gmatch('[^\n]+') do
		local lenght = imgui.CalcTextSize(line).x
		if align == 2 then
			imgui.SetCursorPosX((width - lenght) / 2)
		elseif align == 3 then
			imgui.SetCursorPosX(width - lenght - imgui.GetStyle().WindowPadding.x)
		end
		imgui.TextColored(color, line)
	end
end
function addons.ToggleButton(str_id, value, size)
    local size = size or imgui.ImVec2(40 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE)
	local duration = 0.3
	local p = imgui.GetCursorScreenPos()
    local DL = imgui.GetWindowDrawList()
	--local size = imgui.ImVec2(40, 20)
    local title = str_id:gsub('##.*$', '')
    local ts = imgui.CalcTextSize(title)
    local cols = {
    	enable = imgui.GetStyle().Colors[imgui.Col.ButtonActive],
    	disable = imgui.GetStyle().Colors[imgui.Col.TextDisabled]	
    }
    local radius = 6 * MONET_DPI_SCALE
    local o = {
    	x = 4,
    	y = p.y + (size.y / 2)
    }
    local A = imgui.ImVec2(p.x + radius + o.x, o.y)
    local B = imgui.ImVec2(p.x + size.x - radius - o.x, o.y)

    if AI_TOGGLE[str_id] == nil then
        AI_TOGGLE[str_id] = {
        	clock = nil,
        	color = value[0] and cols.enable or cols.disable,
        	pos = value[0] and B or A
        }
    end
    local pool = AI_TOGGLE[str_id]
    
    imgui.BeginGroup()
	    local pos = imgui.GetCursorPos()
	    local result = imgui.InvisibleButton(str_id, imgui.ImVec2(size.x, size.y))
	    if result then
	        value[0] = not value[0]
	        pool.clock = os.clock()
	    end
	    if #title > 0 then
		    local spc = imgui.GetStyle().ItemSpacing
		    imgui.SetCursorPos(imgui.ImVec2(pos.x + size.x + spc.x, pos.y + ((size.y - ts.y) / 2)))
	    	imgui.Text(title)
    	end
    imgui.EndGroup()

 	if pool.clock and os.clock() - pool.clock <= duration then
        pool.color = bringVec4To(
            imgui.ImVec4(pool.color),
            value[0] and cols.enable or cols.disable,
            pool.clock,
            duration
        )

        pool.pos = bringVec2To(
        	imgui.ImVec2(pool.pos),
        	value[0] and B or A,
        	pool.clock,
            duration
        )
    else
        pool.color = value[0] and cols.enable or cols.disable
        pool.pos = value[0] and B or A
    end

	DL:AddRect(p, imgui.ImVec2(p.x + size.x, p.y + size.y), ToU32(pool.color), 10, 15, 1)
	DL:AddCircleFilled(pool.pos, radius, ToU32(pool.color))

    return result
end

-- ADDONS

function hex2rgb(hex)
	hex = hex:gsub("#","")
	return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end

function rgb2hex(r,g,b)
	local rgb = (r * 0x10000) + (g * 0x100) + b
    return string.format("%x", rgb)
end

function join_argb(a, r, g, b)
	local argb = b
	argb = bit.bor(argb, bit.lshift(g, 8)) 
	argb = bit.bor(argb, bit.lshift(r, 16))
	argb = bit.bor(argb, bit.lshift(a, 24))
	return argb
end

function explode_argb(argb)
	local a = bit.band(bit.rshift(argb, 24), 0xFF)
	local r = bit.band(bit.rshift(argb, 16), 0xFF)
	local g = bit.band(bit.rshift(argb, 8), 0xFF)
	local b = bit.band(argb, 0xFF)
	return a, r, g, b
end

local mainIni = inicfg.load({
	config =
	{
		c_nick = "",
		c_cnn = "",
		c_rang = "",
		c_rang_n = "",
		c_city = "",
		c_tag = "",
		auto_edit = true,
		alovlya = false,
		dopka = false,
		nick_v = false,
	},
	settings = {
		bind = 'R'
	},
	edit = {
		on = true,
		slots = 1000,
		last = 0
	},
	binder = {
	},
	theme = {
		theme = "blue",
		selected = 0,
		moonmonet = 759410733,
	},
	vrtag = {
		text = "SMI-plalkeo",
		color = 759410733,
		sts = false
	},
	rpbind = {
		expel = true,
		giverank = true,
		blacklist = true,
		unblacklist = true,
		fwarn = true,
		unfwarn = true,
		uninvite = true,
		invite = true,
		fmute = true,
		funmute = true
	},
	chat = {
		vr = false,
		ad = false,
		job = false,
		r = false
	},
	accent = {
		accent = false,
		text = '',
		def = false,
		s = false,
		r = false
	},
	pos = {
		x = 0,
		y = 0
	},
	efir = {
		reklama_text = '',
		dep = true,
	},
	tags = {
		math 		= u8'[����������]',
		country 	= u8'[�������]',
		translate 	= u8'[����������]',
		himia 		= u8'[�����]',
		inter		= u8'[��������]',
		sobes		= u8'[�������������]',
		reklama 	= u8'[�������]',
	}
}, 'smi.ini')


if not doesFileExist('moonloader/config/smi.ini') then inicfg.save(mainIni,'smi.ini') end

function saveInfo(first_razdel, second_razdel, value) 
	mainIni[first_razdel][second_razdel] = value
	inicfg.save(mainIni,'smi.ini')
end

local trstl1 = {['ph'] = '�',['Ph'] = '�',['Ch'] = '�',['ch'] = '�',['Th'] = '�',['th'] = '�',['Sh'] = '�',['sh'] = '�', ['ea'] = '�',['Ae'] = '�',['ae'] = '�',['size'] = '����',['Jj'] = '��������',['Whi'] = '���',['whi'] = '���',['Ck'] = '�',['ck'] = '�',['Kh'] = '�',['kh'] = '�',['hn'] = '�',['Hen'] = '���',['Zh'] = '�',['zh'] = '�',['Yu'] = '�',['yu'] = '�',['Yo'] = '�',['yo'] = '�',['Cz'] = '�',['cz'] = '�', ['ia'] = '�', ['ea'] = '�',['Ya'] = '�', ['ya'] = '�', ['ove'] = '��',['ay'] = '��', ['rise'] = '����',['oo'] = '�', ['Oo'] = '�'}
local trstl = {['B'] = '�',['Z'] = '�',['T'] = '�',['Y'] = '�',['P'] = '�',['J'] = '��',['X'] = '��',['G'] = '�',['V'] = '�',['H'] = '�',['N'] = '�',['E'] = '�',['I'] = '�',['D'] = '�',['O'] = '�',['K'] = '�',['F'] = '�',['y`'] = '�',['e`'] = '�',['A'] = '�',['C'] = '�',['L'] = '�',['M'] = '�',['W'] = '�',['Q'] = '�',['U'] = '�',['R'] = '�',['S'] = '�',['zm'] = '���',['h'] = '�',['q'] = '�',['y'] = '�',['a'] = '�',['w'] = '�',['b'] = '�',['v'] = '�',['g'] = '�',['d'] = '�',['e'] = '�',['z'] = '�',['i'] = '�',['j'] = '�',['k'] = '�',['l'] = '�',['m'] = '�',['n'] = '�',['o'] = '�',['p'] = '�',['r'] = '�',['s'] = '�',['t'] = '�',['u'] = '�',['f'] = '�',['x'] = 'x',['c'] = '�',['``'] = '�',['`'] = '�',['_'] = ' '}

function trst(name)
	if name:match('%a+') then
		for k, v in pairs(trstl1) do
			name = name:gsub(k, v) 
		end
		for k, v in pairs(trstl) do
			name = name:gsub(k, v) 
		end
		return name
	end
	return name
end

local curcolor = '{00FF00}'
local curcolor1 = 0x00FF00

if mainIni.theme['theme'] == 'blue' then
	curcolor = '{3399FF}'
	curcolor1 = 0x3399FF
elseif mainIni.theme['theme'] == 'red' then
	curcolor = '{FF3333}'
	curcolor1 = 0xFF3333
elseif mainIni.theme['theme'] == 'purple' then
	curcolor = '{BC33FF}'
	curcolor1 = 0xBC33FF
elseif mainIni.theme['theme'] == 'black' then
	curcolor = '{AEAEAE}'
	curcolor1 = 0xAEAEAE
elseif mainIni.theme['theme'] == 'monet' then
	if not isMonetLoader() then
		local gen_color = monet.buildColors(mainIni.theme.moonmonet, 1.0, true)
		local a, r, g, b = explode_argb(gen_color.accent1.color_300)
		curcolor = '{'..rgb2hex(r, g, b)..'}'
		curcolor1 = '0x'..('%X'):format(gen_color.accent1.color_300)
	else
		curcolor = '{3399FF}'
		curcolor1 = 0x3399FF
		mainIni.theme['theme'] = 'blue'
	end
end

print(curcolor..'[SMI-plalkeo] {FFFFFF}�������� ���������...')
for lib, bool in pairs(bLib) do 
	if not bool then
		if not isMonetLoader() then
			error('{FF0000}ERROR\n\n'..curcolor..'[SMI-plalkeo] {FFFFFF}���������� "' .. lib .. '" �� �������. ������ �� ����� ���� �������\n'..curcolor..'[SMI-plalkeo] {FFFFFF}�������� ���������� �� ������: https://github.com/pla1keo/smiplalkeo/raw/main/smiplalkeo_libs.rar\n')
		else
			print('{FF0000}ERROR\n\n'..curcolor..'[SMI-plalkeo] {FFFFFF}���������� "' .. lib .. '" �� �������. ������ �� ����� ���� �������\n'..curcolor..'[SMI-plalkeo] {FFFFFF}�������� ���������� �� ������: https://github.com/pla1keo/smiplalkeo/raw/main/smiplalkeo_libs.rar\n')
		end
		break
	end 
end
print(curcolor..'[SMI-plalkeo] {FFFFFF}�������� ������ �������!')
print(curcolor..'[SMI-plalkeo] {FFFFFF}���� � ��� ��������� ������ � ������� ��:')
print(curcolor..'[SMI-plalkeo] {FFFFFF}�������� ���������� �� ������: https://github.com/pla1keo/smiplalkeo/raw/main/smiplalkeo_libs.rar')

changelogtext = u8[[
������ 3.7:
���������� ������������������ ����������

������ 3.8:
��������� �������� ������
������ ������ �������
������� ����� ��������� ������
��������� ���� ��������������
��������� ��������� ��� MonetLoader (MOBILE)
]]

local posX, posY = mainIni.pos['x'], mainIni.pos['y']
local pos = false
local font = {}

local gen_color = nil

-- faicons = {}


imgui.OnInitialize(function()
	-- THEME
	

	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4
	
    imgui.GetStyle().WindowBorderSize = 0
    imgui.GetStyle().ChildBorderSize = 0.5
    imgui.GetStyle().PopupBorderSize = 0
    imgui.GetStyle().FrameBorderSize = 0
    imgui.GetStyle().TabBorderSize = 0

    --==[ ROUNDING ]==--
    imgui.GetStyle().WindowRounding = 5
    imgui.GetStyle().ChildRounding = 5
    imgui.GetStyle().FrameRounding = 5
    imgui.GetStyle().PopupRounding = 5
    imgui.GetStyle().ScrollbarRounding = 5
    imgui.GetStyle().GrabRounding = 5
    imgui.GetStyle().TabRounding = 5

    --==[ ALIGN ]==--
    imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().SelectableTextAlign = imgui.ImVec2(0.5, 0.5)

	apply_n_t()
	style:ScaleAllSizes(MONET_DPI_SCALE)
	-- THEME

	-- // ������
	local FONTS = imgui.GetIO().Fonts
	local builder = imgui.ImFontGlyphRangesBuilder()
	 builder:AddRanges(FONTS:GetGlyphRangesCyrillic())
	 builder:AddText("��������������-���")
	 local range = imgui.ImVector_ImWchar()
	 builder:BuildRanges(range)
	local defGlyph = imgui.GetIO().Fonts.ConfigData.Data[0].GlyphRanges
	imgui.GetIO().Fonts:Clear() -- ������� ������
	local font_config = imgui.ImFontConfig() -- � ������� ������ ���� ���� ������
	font_config.SizePixels = 14.0 * MONET_DPI_SCALE;
	font_config.GlyphExtraSpacing.x = 0.1 * MONET_DPI_SCALE
	-- �������� �����
	imgui.GetIO().Fonts:AddFontFromFileTTF(getFontsPath(), font_config.SizePixels, font_config, defGlyph)
	
    -- local configForFA = imgui.ImFontConfig()
    -- configForFA.MergeMode = true
    -- configForFA.PixelSnapH = true

	local config = imgui.ImFontConfig()
	config.MergeMode = true
	config.PixelSnapH = true
	config.FontDataOwnedByAtlas = false
	config.GlyphOffset.y = 1.0 * MONET_DPI_SCALE -- �������� �� 1 ������� ����
    iconRanges = imgui.new.ImWchar[3](faicons.min_range, faicons.max_range, 0)
	local fa_glyph_ranges = new.ImWchar[3]({ faicons.min_range, faicons.max_range, 0 })
	-- ������
	imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(faicons.get_font_data_base85('solid'), 14 * MONET_DPI_SCALE, config, iconRanges) -- solid - ��� ������, ��� �� ���� thin, regular, light � duotone
	font = {B = {}}
	for i = 15, 25 do
		font['B'][i] = imgui.GetIO().Fonts:AddFontFromFileTTF(getFontsPath(), i * MONET_DPI_SCALE, font_config, defGlyph)
		-- font['B'][i] = FONTS:AddFontFromMemoryCompressedBase85TTF(base85.SF_B, i * MONET_DPI_SCALE, nil, range[0].Data)
	end
	-- imgui.GetIO().ConfigWindowsMoveFromTitleBarOnly = true
	if not isMonetLoader() then
		local tmp = imgui.ColorConvertU32ToFloat4(mainIni.theme['moonmonet'])
		gen_color = monet.buildColors(mainIni.theme.moonmonet, 1.0, true)
		mmcolor = new.float[3](tmp.z, tmp.y, tmp.x)
	end
end)

function imgui.TextColoredRGB(text,align)
	local width = imgui.GetWindowWidth()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local ImVec4 = imgui.ImVec4

	local col = imgui.Col

	local getcolor = function(color)
		if upper(color:sub(1, 6)) == 'SSSSSS' then
			local r, g, b = colors[0].x, colors[0].y, colors[0].z
			local a = color:sub(7, 8) ~= 'FF' and (tonumber(color:sub(7, 8), 16)) or (colors[0].w * 255)
			return ImVec4(r, g, b, a / 255)
		end
		local color = type(color) == 'string' and tonumber(color, 16) or color
		if type(color) ~= 'number' then return end
		local r, g, b, a = explode_argb(color)
		return ImVec4(r / 255, g / 255, b / 255, a / 255)
	end

	local render_text = function(text_)
		for w in gmatch(text_, '[^\r\n]+') do
			local textsize = gsub(w, '{.-}', '')
			local text_width = imgui.CalcTextSize(u8(textsize))
			if align == 1 then imgui.SetCursorPosX( width / 2 - text_width .x / 2 )
			elseif align == 2 then imgui.SetCursorPosX(imgui.GetCursorPosX() + width - text_width.x - imgui.GetScrollX() - 2 * imgui.GetStyle().ItemSpacing.x - imgui.GetStyle().ScrollbarSize)
			end
			local text, colors_, m = {}, {}, 1
			w = gsub(w, '{(......)}', '{%1FF}')
			while find(w, '{........}') do
				local n, k = find(w, '{........}')
				local color = getcolor(w:sub(n + 1, k - 1))
				if color then
					text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
					colors_[#colors_ + 1] = color
					m = n
				end
				w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
			end
			if text[0] then
				for i = 0, #text do
					imgui.TextColored(colors_[i] or colors[0], u8(text[i]))
					imgui.SameLine(nil, 0)
				end
				imgui.NewLine()
			else imgui.Text(u8(w)) end
		end
	end
	render_text(text)
end

function imgui.CenterTextColoredRGB(text)
	imgui.TextColoredRGB(text, 1)
end


-- ���/���/�����

pro_vopr_text = {u8'����� �� �� 10��', u8'����� ���. ������: 5��', u8'��� ����� � ������ ������ �����', u8'���� ����� � ������ �� 7 ����', 
				 u8'������ ������ � 3� ������� �� 4��', u8'����� ���� �� �����', u8'����� ������� �� 10��', u8'����� ��� � ��. ������', 
				 u8'������� � ����, �������', u8'������ ����. 120��', u8'��� ����������� ����� "��������" � �����������?', u8'������ ���',
				 u8'����� ������ 1 ���� �� 1.5��', u8'������ ����� 636', u8'�������� ����� � ���� ����� SMIPLALKEO', u8'������ �� �� 90��'}

ystav_vopr_text = {u8'������� ���� ��� � �����?', u8'� ����� ��������� �������� ������ ���?', u8'����� �� ������������� ���� ����������?', 
				   u8'����� �� ������� � ������������?', u8'����� �� ������������� ���-���� � �����?', u8'�� ����� ����� ���������� ������� � �����?', 
				   u8'����� ���������� ��������?', u8'������ �������� ��� �� ��������?', u8'� ����� ��������� ����� ����� �������?', 
				   u8'� ����� ��������� ����� ����� �������� ������?'}

ppe_vopr_text = {u8'� ����� ��������� ����� ��������� �����?', u8'� ����� ��������� ����� ��������� ��������� �����?',
				 u8'����� ���� �� ������������� � ������� ���������?', u8'����� ������������ � ����������� �����?',
				 u8'�� ����� ������ ������� ���� ����� �������� ����?', u8'����� �� ����� �������� � ����� �����������?',
				 u8'������� ������ ���� ����������� � �����?', u8'������ ���� ����� ���������?', u8'��� ��������� � ��������?', 
				 u8'����� �� �������� ��������� ����� � ������ �����?'}

interv_quest = {u8'��� ���� ����������?', u8'���������� � ����.', u8'���� �� � ��� ����, ����?',
				u8'���� �� � ��� ���, ����������?', u8'������ �� �� �������� ����-������ �������?', u8'������� �� ������ �� ������ ���������?',
				u8'������� � ���� ����� � ��� �������� �� ���� "������ = �����". �� ��������?', u8'���������� � ����.',
				u8'������� ��������� � ���?', u8'������ �� �� �������� ����-������ �������?', u8'������ �� �� ��������?',
				u8'��� �� ���������� � ����������� ��������?', u8'��� �� ���������� � ������ � �������� �����?'}				 


-- �����

local function has_value(tab, val)
	for index, value in ipairs(tab) do
		if value == val then
			return true
		end
	end

	return false
end

function join_rgb(rr, gg, bb)
	return bit.bor(bit.bor(bb, bit.lshift(gg, 8)), bit.lshift(rr, 16))
end

local rektext = new.char[10000]()
dep = imgui.new.bool(mainIni.efir['dep'])

nick_v = imgui.new.bool(mainIni.config['nick_v'])

interv = {
	name = new.char[256](),
	rang = new.char[256](),
}

bnd = {
	imgui.new.int(0),
	new.char[100](),
	""
}

ae = {
	imgui.new.int(0),
	"",
	new.char[2048](),
	false
}

accent = {
	imgui.new.bool(mainIni.accent['accent']), -- ��������� �������
	new.char[256](mainIni.accent['text']), -- ������
	imgui.new.bool(mainIni.accent['def']), -- ������� ���
	imgui.new.bool(mainIni.accent['s']), -- ����
	imgui.new.bool(mainIni.accent['r']) -- �����
}

expel_rp = imgui.new.bool(mainIni.rpbind['expel'])
giverank_rp = imgui.new.bool(mainIni.rpbind['giverank'])
blacklist_rp = imgui.new.bool(mainIni.rpbind['blacklist'])
unblacklist_rp = imgui.new.bool(mainIni.rpbind['unblacklist'])
fwarn_rp = imgui.new.bool(mainIni.rpbind['fwarn'])
unfwarn_rp = imgui.new.bool(mainIni.rpbind['unfwarn'])
uninvite_rp = imgui.new.bool(mainIni.rpbind['uninvite'])
invite_rp = imgui.new.bool(mainIni.rpbind['invite'])
fmute_rp = imgui.new.bool(mainIni.rpbind['fmute'])
funmute_rp = imgui.new.bool(mainIni.rpbind['funmute'])

vr_c = imgui.new.bool(mainIni.chat['vr'])
ad_c = imgui.new.bool(mainIni.chat['ad'])
r_c = imgui.new.bool(mainIni.chat['r'])
job_c = imgui.new.bool(mainIni.chat['job'])

select_id = imgui.new.int(-1)

selected_theme = imgui.new.int(mainIni.theme['selected'])

city = {u8'�. ���-������', u8'�. ���-������', u8'�. ���-��������', u8'����� ����� �����', u8'������� ������', u8'�. �������� ����', u8'�. ��� �������', u8'�. ��� ��������', u8'�. ����� ����', u8'�. ��� ��������', u8'�. ��� ��������', u8'�. ������ ������', u8'�. ��������', u8'�. ����������', u8'�. ����-���'}
city_items = imgui.new['const char*'][#city](city)
selected_city = imgui.new.int(0)

biz = {u8'���', u8'���', u8'�����', u8'����������', u8'����� � ����', u8'������� 24 �� 7', u8'��������', u8'��������������', u8'������� �������', u8'������ ����������', u8'������� �����������', u8'������� ������', u8'������� ������������ ������������', u8'����������� "�����"', u8'����������� "���������"', u8'����������� "���������� ��������"', u8'����������� "��������� �������"', u8'����������� "���������� �����"', u8'����� ������', u8'�������� ���-��������', u8'����������'}
biz_items = imgui.new['const char*'][#biz](biz)
selected_biz = imgui.new.int(0)

house_dop = {'', u8'� ��������', u8'� �������', u8'� ������� � ��������'}
house_dop_items = imgui.new['const char*'][#house_dop](house_dop)
selected_house_dop = imgui.new.int(0)

types = {
	{u8'�.�', u8'�.�', u8'�.�', u8'�.�', u8'�.�', u8'�.�', u8'�.�', u8'�.�', u8'�.�'},
	nil,
	imgui.new.int(0)
}
types[2] = imgui.new['const char*'][#types[1]](types[1])
types2 = {
	{u8'�/�', u8'�/�', u8'�/�', u8'�/�', u8'�/�', u8'�/�', u8'�/�', u8'�/�', u8'�/�'},
	nil,
	imgui.new.int(0)
}
types2[2] = imgui.new['const char*'][#types2[1]](types2[1])

orgs = {u8'��', u8'����', u8'����', u8'����', u8'����', u8'���', u8'��', u8'���', u8'���', u8'���', u8'���-��', u8'��', u8'���', u8'���', u8'��', u8'����', u8'����', u8'����', u8'���', u8'��� ��', u8'��� ��', u8'��� ��'}

theme_a = {u8'�����', u8'�������', u8'����������', u8'׸����', 'MoonMonet'}
theme_t = {u8'blue', u8'red', u8'purple', u8'black', 'monet'}
local items = imgui.new['const char*'][#theme_a](theme_a)

list_another = {u8'�������� "���� �����"'}


function car(car)
	return '����� "' .. car .. '"'
end

local white_color = 0xFFFFFF
local red = 0xC41E3A
local yellow = 0xFFFF00
local orange = 0xC17C2D
local smi_menu = 'default'
local fast_menu = 'own'
local ppy = 'pro'
local ef = 'math'
local spawn = true
local st_s = true

local price = new.char[32]()
local price_c = new.char[32]()
local grav = imgui.new.int()

local nick = new.char[64](mainIni.config['c_nick'])
local rang = new.char[32]()

local await = {
	members = true,
	next_page = {
		bool = false,
		i = 0
	}
}
local members = {}
local orga = {
	name = '�����������',
	online = 0,
	afk = 0
}

local cmd_text = new.char[40]()
local bind_text = new.char[10000]()
local bind_time = new.char[40]()

local primer = new.char[32]()
local money_math = new.char[32]()
local chel_ball_c = new.char[32]()

local auto_edit = imgui.new.bool(mainIni.config['auto_edit'])

local math_tag = new.char[64](mainIni.tags['math'])
local country_tag = new.char[64](mainIni.tags['country'])
local translate_tag = new.char[64](mainIni.tags['translate'])
local himia_tag = new.char[64](mainIni.tags['himia'])
local inter_tag = new.char[64](mainIni.tags['inter'])
local sobes_tag = new.char[64](mainIni.tags['sobes'])
local reklama_tag = new.char[64](mainIni.tags['reklama'])

local sobes_i = {
	false,
	false,
	false
}

local sobes_info = {
	pass = u8'�� ���������',
	mc = u8'�� ���������',
	lic = u8'�� ���������'
}

local smi_t = imgui.new.bool(false)
local window = imgui.new.bool(false)
local edit_helper = imgui.new.bool(false)
local edit_dialog = imgui.new.bool(false)
local dop_f = imgui.new.bool(false)
local autoedit_slots = imgui.new.bool(false)

local iScreenWidth, iScreenHeight = getScreenResolution()

local dopka = {
	imgui.new.bool(false)
}

local adska = {
	0,
	0,
	0
}


function ColorAccentsAdapter(color)
	local function ARGBtoRGB(color)
		return bit.band(color, 0xFFFFFF)
	end
	local a, r, g, b = explode_argb(color)

	local ret = {a = a, r = r, g = g, b = b}

	function ret:apply_alpha(alpha)
		self.a = alpha
		return self
	end

	function ret:as_u32()
		return join_argb(self.a, self.b, self.g, self.r)
	end

	function ret:as_vec4()
		return imgui.ImVec4(self.r / 255, self.g / 255, self.b / 255, self.a / 255)
	end

	function ret:as_argb()
		return join_argb(self.a, self.r, self.g, self.b)
	end

	function ret:as_rgba()
		return join_argb(self.r, self.g, self.b, self.a)
	end

	function ret:as_chat()
		return format('%06X', ARGBtoRGB(join_argb(self.a, self.r, self.g, self.b)))
	end

	return ret
end

function blackw()
	imgui.SwitchContext()
    --==[ COLORS ]==--
    imgui.GetStyle().Colors[imgui.Col.Text]                   = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
    imgui.GetStyle().Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Border]                 = imgui.ImVec4(1, 1, 1, 1)
    imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.51, 0.51, 0.51, 1.00)
    imgui.GetStyle().Colors[imgui.Col.CheckMark]              = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Button]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Header]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.47, 0.47, 0.47, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Separator]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(1.00, 1.00, 1.00, 0.25)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(1.00, 1.00, 1.00, 0.67)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(1.00, 1.00, 1.00, 0.95)
    imgui.GetStyle().Colors[imgui.Col.Tab]                    = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.28, 0.28, 0.28, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabActive]              = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocused]           = imgui.ImVec4(0.07, 0.10, 0.15, 0.97)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocusedActive]     = imgui.ImVec4(0.14, 0.26, 0.42, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.61, 0.61, 0.61, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(1.00, 0.43, 0.35, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.90, 0.70, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(1.00, 0.60, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(1.00, 0.00, 0.00, 0.35)
    imgui.GetStyle().Colors[imgui.Col.DragDropTarget]         = imgui.ImVec4(1.00, 1.00, 0.00, 0.90)
    imgui.GetStyle().Colors[imgui.Col.NavHighlight]           = imgui.ImVec4(0.26, 0.59, 0.98, 1.00)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingHighlight]  = imgui.ImVec4(1.00, 1.00, 1.00, 0.70)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingDimBg]      = imgui.ImVec4(0.80, 0.80, 0.80, 0.20)
    imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.00, 0.00, 0.00, 0.70)
end

function apply_custom_style()
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4

	colors[clr.FrameBg]				= ImVec4(0.16, 0.29, 0.48, 0.54)
	colors[clr.FrameBgHovered]		 = ImVec4(0.26, 0.59, 0.98, 0.40)
	colors[clr.FrameBgActive]		  = ImVec4(0.26, 0.59, 0.98, 0.67)
	colors[clr.TitleBg]				= ImVec4(0.04, 0.04, 0.04, 1.00)
	colors[clr.TitleBgActive]		  = ImVec4(0.16, 0.29, 0.48, 1.00)
	colors[clr.TitleBgCollapsed]	   = ImVec4(0.00, 0.00, 0.00, 0.51)
	colors[clr.CheckMark]			  = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.SliderGrab]			 = ImVec4(0.24, 0.52, 0.88, 1.00)
	colors[clr.SliderGrabActive]	   = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.Button]				 = ImVec4(0.26, 0.59, 0.98, 0.40)
	colors[clr.ButtonHovered]		  = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.ButtonActive]		   = ImVec4(0.06, 0.53, 0.98, 1.00)
	colors[clr.Header]				 = ImVec4(0.26, 0.59, 0.98, 0.31)
	colors[clr.HeaderHovered]		  = ImVec4(0.26, 0.59, 0.98, 0.80)
	colors[clr.HeaderActive]		   = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.Separator]			  = colors[clr.Border]
	colors[clr.SeparatorHovered]	   = ImVec4(0.26, 0.59, 0.98, 0.78)
	colors[clr.SeparatorActive]		= ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.ResizeGrip]			 = ImVec4(0.26, 0.59, 0.98, 0.25)
	colors[clr.ResizeGripHovered]	  = ImVec4(0.26, 0.59, 0.98, 0.67)
	colors[clr.ResizeGripActive]	   = ImVec4(0.26, 0.59, 0.98, 0.95)
	colors[clr.TextSelectedBg]		 = ImVec4(0.26, 0.59, 0.98, 0.35)
	colors[clr.Text]				   = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.TextDisabled]		   = ImVec4(0.50, 0.50, 0.50, 1.00)
	colors[clr.WindowBg]			   = ImVec4(0.06, 0.06, 0.06, 0.94)
	colors[clr.PopupBg]				= ImVec4(0.08, 0.08, 0.08, 0.94)
	colors[clr.Border]				 = ImVec4(0.43, 0.43, 0.50, 0.50)
	colors[clr.BorderShadow]		   = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.MenuBarBg]			  = ImVec4(0.14, 0.14, 0.14, 1.00)
	colors[clr.ScrollbarBg]			= ImVec4(0.02, 0.02, 0.02, 0.53)
	colors[clr.ScrollbarGrab]		  = ImVec4(0.31, 0.31, 0.31, 1.00)
	colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
	colors[clr.ScrollbarGrabActive]	= ImVec4(0.51, 0.51, 0.51, 1.00)
	colors[clr.PlotLines]			  = ImVec4(0.61, 0.61, 0.61, 1.00)
	colors[clr.PlotLinesHovered]	   = ImVec4(1.00, 0.43, 0.35, 1.00)
	colors[clr.PlotHistogram]		  = ImVec4(0.90, 0.70, 0.00, 1.00)
	colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
end
function apply_red_theme()
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4

	colors[clr.FrameBg]				= ImVec4(0.48, 0.16, 0.16, 0.54)
	colors[clr.FrameBgHovered]		 = ImVec4(0.98, 0.26, 0.26, 0.40)
	colors[clr.FrameBgActive]		  = ImVec4(0.98, 0.26, 0.26, 0.67)
	colors[clr.TitleBg]				= ImVec4(0.04, 0.04, 0.04, 1.00)
	colors[clr.TitleBgActive]		  = ImVec4(0.48, 0.16, 0.16, 1.00)
	colors[clr.TitleBgCollapsed]	   = ImVec4(0.00, 0.00, 0.00, 0.51)
	colors[clr.CheckMark]			  = ImVec4(0.98, 0.26, 0.26, 1.00)
	colors[clr.SliderGrab]			 = ImVec4(0.88, 0.26, 0.24, 1.00)
	colors[clr.SliderGrabActive]	   = ImVec4(0.98, 0.26, 0.26, 1.00)
	colors[clr.Button]				 = ImVec4(0.98, 0.26, 0.26, 0.40)
	colors[clr.ButtonHovered]		  = ImVec4(0.98, 0.26, 0.26, 1.00)
	colors[clr.ButtonActive]		   = ImVec4(0.98, 0.06, 0.06, 1.00)
	colors[clr.Header]				 = ImVec4(0.98, 0.26, 0.26, 0.31)
	colors[clr.HeaderHovered]		  = ImVec4(0.98, 0.26, 0.26, 0.80)
	colors[clr.HeaderActive]		   = ImVec4(0.98, 0.26, 0.26, 1.00)
	colors[clr.Separator]			  = colors[clr.Border]
	colors[clr.SeparatorHovered]	   = ImVec4(0.75, 0.10, 0.10, 0.78)
	colors[clr.SeparatorActive]		= ImVec4(0.75, 0.10, 0.10, 1.00)
	colors[clr.ResizeGrip]			 = ImVec4(0.98, 0.26, 0.26, 0.25)
	colors[clr.ResizeGripHovered]	  = ImVec4(0.98, 0.26, 0.26, 0.67)
	colors[clr.ResizeGripActive]	   = ImVec4(0.98, 0.26, 0.26, 0.95)
	colors[clr.TextSelectedBg]		 = ImVec4(0.98, 0.26, 0.26, 0.35)
	colors[clr.Text]				   = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.TextDisabled]		   = ImVec4(0.50, 0.50, 0.50, 1.00)
	colors[clr.WindowBg]			   = ImVec4(0.06, 0.06, 0.06, 0.94)
	colors[clr.PopupBg]				= ImVec4(0.08, 0.08, 0.08, 0.94)
	colors[clr.Border]				 = ImVec4(0.43, 0.43, 0.50, 0.50)
	colors[clr.BorderShadow]		   = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.MenuBarBg]			  = ImVec4(0.14, 0.14, 0.14, 1.00)
	colors[clr.ScrollbarBg]			= ImVec4(0.02, 0.02, 0.02, 0.53)
	colors[clr.ScrollbarGrab]		  = ImVec4(0.31, 0.31, 0.31, 1.00)
	colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
	colors[clr.ScrollbarGrabActive]	= ImVec4(0.51, 0.51, 0.51, 1.00)
	colors[clr.PlotLines]			  = ImVec4(0.61, 0.61, 0.61, 1.00)
	colors[clr.PlotLinesHovered]	   = ImVec4(1.00, 0.43, 0.35, 1.00)
	colors[clr.PlotHistogram]		  = ImVec4(0.90, 0.70, 0.00, 1.00)
	colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
end
function apply_purple_theme()
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4
	colors[clr.WindowBg]			  = ImVec4(0.14, 0.12, 0.16, 1.00);
	colors[clr.ChildBg]		 			= ImVec4(0.30, 0.20, 0.39, 0.10);
	colors[clr.PopupBg]			   = ImVec4(0.30, 0.20, 0.39, 0.80);
	colors[clr.Border]				= ImVec4(0.89, 0.85, 0.92, 0.30);
	colors[clr.BorderShadow]		  = ImVec4(0.00, 0.00, 0.00, 0.00);
	colors[clr.FrameBg]			   = ImVec4(0.30, 0.20, 0.39, 1.00);
	colors[clr.FrameBgHovered]		= ImVec4(0.41, 0.19, 0.63, 0.68);
	colors[clr.FrameBgActive]		 = ImVec4(0.41, 0.19, 0.63, 1.00);
	colors[clr.TitleBg]			   = ImVec4(0.41, 0.19, 0.63, 1.00);
	colors[clr.TitleBgCollapsed]	  = ImVec4(0.41, 0.19, 0.63, 1.00);
	colors[clr.TitleBgActive]		 = ImVec4(0.41, 0.19, 0.63, 1.00);
	colors[clr.MenuBarBg]			 = ImVec4(0.30, 0.20, 0.39, 0.57);
	colors[clr.ScrollbarBg]		   = ImVec4(0.30, 0.20, 0.39, 1.00);
	colors[clr.ScrollbarGrab]		 = ImVec4(0.41, 0.19, 0.63, 0.31);
	colors[clr.ScrollbarGrabHovered]  = ImVec4(0.41, 0.19, 0.63, 0.78);
	colors[clr.ScrollbarGrabActive]   = ImVec4(0.41, 0.19, 0.63, 1.00);
	colors[clr.CheckMark]			 = ImVec4(0.56, 0.61, 1.00, 1.00);
	colors[clr.SliderGrab]			= ImVec4(0.41, 0.19, 0.63, 0.24);
	colors[clr.SliderGrabActive]	  = ImVec4(0.41, 0.19, 0.63, 1.00);
	colors[clr.Button]				= ImVec4(0.41, 0.19, 0.63, 0.44);
	colors[clr.ButtonHovered]		 = ImVec4(0.41, 0.19, 0.63, 0.86);
	colors[clr.ButtonActive]		  = ImVec4(0.64, 0.33, 0.94, 1.00);
	colors[clr.Separator]			  = colors[clr.Border]
	colors[clr.SeparatorHovered]	   = ImVec4(0.41, 0.19, 0.63, 0.78)
	colors[clr.SeparatorActive]		= ImVec4(0.41, 0.19, 0.63, 1.00)
	colors[clr.Header]				= ImVec4(0.41, 0.19, 0.63, 0.76);
	colors[clr.HeaderHovered]		 = ImVec4(0.41, 0.19, 0.63, 0.86);
	colors[clr.HeaderActive]		  = ImVec4(0.41, 0.19, 0.63, 1.00);
	colors[clr.ResizeGrip]			= ImVec4(0.41, 0.19, 0.63, 0.20);
	colors[clr.ResizeGripHovered]	 = ImVec4(0.41, 0.19, 0.63, 0.78);
	colors[clr.ResizeGripActive]	  = ImVec4(0.41, 0.19, 0.63, 1.00);
	colors[clr.PlotLines]			 = ImVec4(0.89, 0.85, 0.92, 0.63);
	colors[clr.PlotLinesHovered]	  = ImVec4(0.41, 0.19, 0.63, 1.00);
	colors[clr.PlotHistogram]		 = ImVec4(0.89, 0.85, 0.92, 0.63);
	colors[clr.PlotHistogramHovered]  = ImVec4(0.41, 0.19, 0.63, 1.00);
	colors[clr.TextSelectedBg]		= ImVec4(0.41, 0.19, 0.63, 0.43);
end
function apply_monet()
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4
	local generated_color				= monet.buildColors(mainIni.theme['moonmonet'], 1.0, true)
	colors[clr.Text]					= ColorAccentsAdapter(generated_color.accent2.color_50):as_vec4()
	colors[clr.TextDisabled]			= ColorAccentsAdapter(generated_color.neutral1.color_600):as_vec4()
	colors[clr.WindowBg]				= ColorAccentsAdapter(generated_color.accent2.color_900):as_vec4()
	colors[clr.ChildBg]					= ColorAccentsAdapter(generated_color.accent2.color_800):as_vec4()
	colors[clr.PopupBg]					= ColorAccentsAdapter(generated_color.accent2.color_700):as_vec4()
	colors[clr.Border]					= ColorAccentsAdapter(generated_color.accent1.color_200):apply_alpha(0xcc):as_vec4()
	colors[clr.Separator]				= ColorAccentsAdapter(generated_color.accent1.color_200):apply_alpha(0xcc):as_vec4()
	colors[clr.BorderShadow]			= imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.FrameBg]					= ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x60):as_vec4()
	colors[clr.FrameBgHovered]			= ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x70):as_vec4()
	colors[clr.FrameBgActive]			= ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x50):as_vec4()
	colors[clr.TitleBg]					= ColorAccentsAdapter(generated_color.accent2.color_700):apply_alpha(0xcc):as_vec4()
	colors[clr.TitleBgCollapsed]		= ColorAccentsAdapter(generated_color.accent2.color_700):apply_alpha(0x7f):as_vec4()
	colors[clr.TitleBgActive]			= ColorAccentsAdapter(generated_color.accent2.color_700):as_vec4()
	colors[clr.MenuBarBg]				= ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x91):as_vec4()
	colors[clr.ScrollbarBg]				= imgui.ImVec4(0,0,0,0)
	colors[clr.ScrollbarGrab]			= ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x85):as_vec4()
	colors[clr.ScrollbarGrabHovered]	= ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
	colors[clr.ScrollbarGrabActive]		= ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xb3):as_vec4()
	colors[clr.CheckMark]				= ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xcc):as_vec4()
	colors[clr.SliderGrab]				= ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xcc):as_vec4()
	colors[clr.SliderGrabActive]		= ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x80):as_vec4()
	colors[clr.Button]					= ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xcc):as_vec4()
	colors[clr.ButtonHovered]			= ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
	colors[clr.ButtonActive]			= ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xb3):as_vec4()
	colors[clr.Header]					= ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xcc):as_vec4()
	colors[clr.HeaderHovered]			= ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
	colors[clr.HeaderActive]			= ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xb3):as_vec4()
	colors[clr.ResizeGrip]				= ColorAccentsAdapter(generated_color.accent2.color_700):apply_alpha(0xcc):as_vec4()
	colors[clr.ResizeGripHovered]		= ColorAccentsAdapter(generated_color.accent2.color_700):as_vec4()
	colors[clr.ResizeGripActive]		= ColorAccentsAdapter(generated_color.accent2.color_700):apply_alpha(0xb3):as_vec4()
	colors[clr.PlotLines]				= ColorAccentsAdapter(generated_color.accent2.color_600):as_vec4()
	colors[clr.PlotLinesHovered]		= ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
	colors[clr.PlotHistogram]			= ColorAccentsAdapter(generated_color.accent2.color_600):as_vec4()
	colors[clr.PlotHistogramHovered]	= ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
	colors[clr.TextSelectedBg]			= ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
	colors[clr.ModalWindowDimBg]		= ColorAccentsAdapter(generated_color.accent1.color_200):apply_alpha(0x26):as_vec4()
end

-- // ��� ��� ��� ������: ���� ����� �� https://www.blast.hk/threads/25442/
-- // MoonMonet ���� ����� ��: https://www.blast.hk/threads/87533/

function apply_n_t()
	if mainIni.theme['theme'] == 'blue' then
		curcolor = '{3399FF}'
		curcolor1 = 0x3399FF
		apply_custom_style()
	elseif mainIni.theme['theme'] == 'red' then
		curcolor = '{FF3333}'
		curcolor1 = 0xFF3333
		apply_red_theme()
	elseif mainIni.theme['theme'] == 'purple' then
		curcolor = '{BC33FF}'
		curcolor1 = 0xBC33FF
		apply_purple_theme()
	elseif mainIni.theme['theme'] == 'black' then
		curcolor = '{AEAEAE}'
		curcolor1 = 0xAEAEAE
		blackw()
	elseif mainIni.theme['theme'] == 'monet' then
		if not isMonetLoader() then
			gen_color = monet.buildColors(mainIni.theme.moonmonet, 1.0, true)
			local a, r, g, b = explode_argb(gen_color.accent1.color_300)
			curcolor = '{'..rgb2hex(r, g, b)..'}'
			curcolor1 = '0x'..('%X'):format(gen_color.accent1.color_300)
			apply_monet()
		else
			curcolor = '{3399FF}'
			curcolor1 = 0x3399FF
			apply_custom_style()
			mainIni.theme['theme'] = 'blue'
		end
	end
end

function imgui.verticalSeparator()
	local p = imgui.GetCursorScreenPos()
	imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x, p.y-20), imgui.ImVec2(p.x, p.y + imgui.GetContentRegionMax().y), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.Separator]))
end

function sampev.onSendDialogResponse(dId, button, listboxId, text)
	if dId == 557 and button == 1 then
		lua_thread.create(function ()
			if text ~= nil then 
				mainIni.edit['last'] = tonumber(mainIni.edit['last']) +1
				i = mainIni.edit['last']
				inicfg.save(mainIni,'smi.ini')
				mainIni.edit[i] = u8(msg)
				mainIni.edit[i .. "_input"] = u8(text)
				inicfg.save(mainIni,'smi.ini')
			end
		end)
		edit_dialog[0] = false
	end
end

function check_rank(arg)
	if mainIni.config['c_rang_n'] == "nil" then
		sampAddChatMessage("[SMI-plalkeo] {FFFFFF}������ ������ ������������ ��� ���, ������ ���.", curcolor1)
		return true
	elseif mainIni.config['c_rang_n'] < arg then
		sampAddChatMessage("[SMI-plalkeo] {FFFFFF}� " .. arg .. " �����.", curcolor1)
		return false
	else
		return true
	end
end

local dialog_text = {}
local dialog_title = 'title'
local dialog_btn1 = 'button1'
local dialog_btn2 = 'button2'
local dysp_text = {}
local dysp_title = 'title'
local dysp_btn1 = 'button1'
local dysp_btn2 = 'button2'

local custom_lmenu = imgui.new.bool(false)

local lmenu_frame = imgui.OnFrame(
	function() return custom_lmenu[0] end,
	function(player)
		local resX, resY = getScreenResolution()
		local sizeYB = 30 * MONET_DPI_SCALE
		local sizeX, sizeY = 600 * MONET_DPI_SCALE, 235 * MONET_DPI_SCALE
		imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY), imgui.Cond.Always)
		imgui.Begin('##LMENU1', custom_lmenu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
		imgui.PushFont(font['B'][16])
		addons.AlignedText(u8'���� ������', 2)
		imgui.SameLine()
		imgui.SetCursorPos(imgui.ImVec2(560 * MONET_DPI_SCALE, 5 * MONET_DPI_SCALE))
		if imgui.Button('X', imgui.ImVec2(30 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
			custom_lmenu[0] = false
			sampSendDialogResponse(1214, 0, 0, "")
		end
		imgui.Separator()
		addons.AlignedText(u8'����: '..lmenu_info['bank'], 2)
		if imgui.Button(u8'���������� � �����������', imgui.ImVec2(288 * MONET_DPI_SCALE, sizeYB)) then custom_lmenu[0] = false; sampSendDialogResponse(1214, 1, 0, "") end
		imgui.SameLine()
		if imgui.Button(u8'���������� ������� �����������', imgui.ImVec2(288 * MONET_DPI_SCALE, sizeYB)) then custom_lmenu[0] = false; sampSendDialogResponse(1214, 1, 1, "") end
		if imgui.Button(u8'���������� ��������� ��������', imgui.ImVec2(240 * MONET_DPI_SCALE, sizeYB)) then custom_lmenu[0] = false; sampSendDialogResponse(1214, 1, 2, "") end
		imgui.SameLine()
		if imgui.Button(u8'����� ����������', imgui.ImVec2(158 * MONET_DPI_SCALE, sizeYB)) then custom_lmenu[0] = false; sampSendDialogResponse(1214, 1, 3, "") end
		imgui.SameLine()
		if imgui.Button(u8'�������� ��������', imgui.ImVec2(170 * MONET_DPI_SCALE, sizeYB)) then custom_lmenu[0] = false; sampSendDialogResponse(1214, 1, 4, "") end
		if imgui.Button(u8'���������� �������', imgui.ImVec2(200 * MONET_DPI_SCALE, sizeYB)) then custom_lmenu[0] = false; sampSendDialogResponse(1214, 1, 5, "") end
		imgui.SameLine()
		if imgui.Button(u8'���� ������� � ��� ['..lmenu_info['eat']..u8' ����]', imgui.ImVec2(208 * MONET_DPI_SCALE, sizeYB)) then custom_lmenu[0] = false; sampSendDialogResponse(1214, 1, 6, "") end
		imgui.SameLine()
		if imgui.Button(u8'�������������', imgui.ImVec2(160 * MONET_DPI_SCALE, sizeYB)) then custom_lmenu[0] = false; sampSendDialogResponse(1214, 1, 7, "") end
		if imgui.Button(u8'������������ Vice City', imgui.ImVec2(180 * MONET_DPI_SCALE, sizeYB)) then custom_lmenu[0] = false; sampSendDialogResponse(1214, 1, 8, "") end
		imgui.SameLine()
		if imgui.Button(u8'���������', imgui.ImVec2(88 * MONET_DPI_SCALE, sizeYB)) then custom_lmenu[0] = false; sampSendDialogResponse(1214, 1, 9, "") end
		imgui.SameLine()
		if imgui.Button(u8'��������� �������������� ����������', imgui.ImVec2(300 * MONET_DPI_SCALE, sizeYB)) then custom_lmenu[0] = false; sampSendDialogResponse(1214, 1, 10, "") end
		if imgui.Button(u8'�� �����������', imgui.ImVec2(288 * MONET_DPI_SCALE, sizeYB)) then custom_lmenu[0] = false; sampSendDialogResponse(1214, 1, 11, "") end
		imgui.SameLine()
		if imgui.Button(u8'���� ������� � /d ['..lmenu_info['d']..u8' ����]', imgui.ImVec2(288 * MONET_DPI_SCALE, sizeYB)) then custom_lmenu[0] = false; sampSendDialogResponse(1214, 1, 12, "") end
		imgui.PopFont()
		imgui.End()
	end
)

local jobprogress = imgui.new.bool(false)
local newJobProgress = imgui.OnFrame(
	function() return jobprogress[0] end,
	function(player)
		local resX, resY = getScreenResolution()
		local sizeX, sizeY = 500 * MONET_DPI_SCALE, 330 * MONET_DPI_SCALE
		imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY), imgui.Cond.Always)
		imgui.Begin('##JobProgress', jobprogress, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
		imgui.PushFont(font['B'][16])
		addons.AlignedText(u8'������������', 2)
		imgui.SameLine()
		imgui.SetCursorPos(imgui.ImVec2(460 * MONET_DPI_SCALE, 10 * MONET_DPI_SCALE))
		if imgui.Button('X', imgui.ImVec2(30 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
			jobprogress[0] = false
			sampSendDialogResponse(0, 1, 1, "")
		end
		imgui.SetCursorPosY(25)
		addons.AlignedText(u8:encode(jp_info['org']).. ' | '..jp_info['name'], 2)
		imgui.Separator()
		
		addons.AlignedText(u8'�� ��� �����', 2)
		imgui.BeginChild('##za all time', imgui.ImVec2(-1, 110 * MONET_DPI_SCALE))
		imgui.SetCursorPosY(5)
		imgui.CenterTextColoredRGB('���������� ���������������: '..curcolor..jp_info['ads']['all'])
		imgui.CenterTextColoredRGB('VIP-���������� ���������������: '..curcolor..jp_info['ads']['all_vip'])
		imgui.CenterTextColoredRGB('���������� � �����: '..curcolor..jp_info['ads']['all_vip']+jp_info['ads']['all'])
		imgui.CenterTextColoredRGB('������� �����: '..curcolor..jp_info['newspaper']['all_created'])
		imgui.CenterTextColoredRGB('������� �����: '..curcolor..jp_info['newspaper']['all_sell'])
		imgui.EndChild()
		
		addons.AlignedText(u8'�� �������', 2)
		imgui.BeginChild('##za today', imgui.ImVec2(-1, 110 * MONET_DPI_SCALE))
		imgui.SetCursorPosY(5)
		imgui.CenterTextColoredRGB('���������� ���������������: '..curcolor..jp_info['ads']['today'])
		imgui.CenterTextColoredRGB('VIP-���������� ���������������: '..curcolor..jp_info['ads']['today_vip'])
		imgui.CenterTextColoredRGB('���������� � �����: '..curcolor..jp_info['ads']['today_vip']+jp_info['ads']['today'])
		imgui.CenterTextColoredRGB('������� �����: '..curcolor..jp_info['newspaper']['today_created'])
		imgui.CenterTextColoredRGB('������� �����: '..curcolor..jp_info['newspaper']['today_sell'])
		imgui.EndChild()

		imgui.PopFont()
		imgui.End()
	end
)

users = {}
stop = false

parama = ''

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
	if dialogId == 2015 and title:find('�����������') then
		if mem then
			local lineIndex = -2
			cur_slot = 0
			for line in text:gmatch("[^\n]+") do
				lineIndex = lineIndex + 1
				line = line:gsub(' | MUTED', '')
				if line:match('([a-zA-z]+)_([a-zA-z]+)%((%d+)%)	(.+)%((%d+)%)	(%d+) %((%d+)%)	(%d+) ��') then
					name, surname, id, rank, rank_id, warn, afk, quest = line:match('([a-zA-z]+)_([a-zA-z]+)%((%d+)%)	(.+)%((%d+)%)	(%d+) %((%d+)%)	(%d+) ��')
					table.insert(users, {name..'_'..surname, id, rank, rank_id, warn, afk, quest})
				end
				if line:find('��������� ��������') then
					cur_slot = lineIndex
					sampSendDialogResponse(dialogId, 1, cur_slot, "")
					return false
				end
			end
			sampSendDialogResponse(dialogId, 0, -1, "")
			mem = false
			for k, v in pairs(users) do
				local id, arg = string.match(parama, "(%d+)%s(.+)")
				if v[2] == id then
					if tonumber(v[5]) == 0 then
						if arg ~= nil and tonumber(id) < 1000 then
							if check_rank(9) then
								if mainIni.rpbind['uninvite'] then
									lua_thread.create(function()
										sampSendChat("/do ������� � ����� ������ ����������� � �����.")
										wait(2500)
										sampSendChat("/me ����� � ������ \"����������\"")
										wait(2000)
										sampSendChat("/do ������ ������.")
										wait(2000)
										sampSendChat("/me ���� ���������� � ������ \"����������\"")
										wait(1000)
										sampSendChat("/uninvite ".. id .. " " .. arg)
									end)
								else
									sampSendChat("/uninvite ".. id .. " " .. arg)
								end
							end
						else
							sampAddChatMessage("[SMI-plalkeo] {FFFFFF}�������: /uninvite [id] [�������]", curcolor1)
						end
					else
						sampAddChatMessage("[SMI-plalkeo] {FFFFFF}������ ����� ����� �������. ��� ������ ������� ��������.", curcolor1)
					end
				end
			end
			
			return false
		end
	end
	if dialogId == 1214 and title:find("����") then
		lmenu_info = {
			bank = '',
			eat = '',
			d = '',
		}
		lmenu_info['bank'] = string.match(title, '{BFBBBA}{FFFFFF}����: {E1E948}(.+)')
		lmenu_info['eat'] = string.match(text, '%{ff6666%}%[7%] %{FFFFFF%}���� ������� � ���: %{407930%}(%d+) %((.+)%)%{AFAFAF%} �����\n')
		lmenu_info['d'] = string.match(text, '%{ff6666%}%[13%] %{FFFFFF%}���� ������� � %/d: %{407930%}(%d+) %((.+)%)%{AFAFAF%} �����\n')
		custom_lmenu[0] = true
		return false
	end
	if dialogId == 235 and title == "{BFBBBA}�������� ����������" and st_s then
		st_s = false
		if string.match(text, "�����������: {B83434}%[(%D+)%]") == "TV ������" or string.match(text, "�����������: {B83434}%[(%D+)%]") == "TV ������ SF" or string.match(text, "�����������: {B83434}%[(%D+)%]") == "TV ������ LV" then
			org = string.match(text, "�����������: {B83434}%[(%D+)%]")
			dol = string.match(text, "���������: {B83434}(%A+)%(%d+%)")
			dl = u8(dol)
			if org == 'TV ������' then org_g = u8'���-��'; ccity = u8'���-������'; org_tag = 'R-LS' end
			if org == 'TV ������ SF' then org_g = u8'���-��'; ccity = u8'���-������'; org_tag = 'R-SF' end
			if org == 'TV ������ LV' then org_g = u8'���-��'; ccity = u8'���-��������'; org_tag = 'R-LV' end
			rang_n = tonumber(string.match(text, "���������: {B83434}%A+%((%d+)%)"))
		else
			org = 'nil'
			dl = 'nil'
			org_g = 'nil'
			ccity = 'nil'
			rang_n = 'nil'
			org_tag = 'nil'
		end
		mainIni.config.c_cnn = org_g
		mainIni.config['c_rang_n'] = rang_n
		mainIni.config['c_rang'] = dl
		mainIni.config['c_city'] = ccity
		mainIni.config['c_tag'] = org_tag
		inicfg.save(mainIni,'smi.ini')
		sampSendDialogResponse(dialogId, 0, 0, "")
		return false
	end
	if dialogId == 1234 and selected_user ~= nil then
		if (selected_user >= 0 and selected_user <= 1000) and (sampIsPlayerConnected(selected_user)) then
			if sobes_i[1] and title == "{BFBBBA}�������" and string.find(text, sampGetPlayerNickname(selected_user)) then
				let = string.match(text, "��� � �����: {FFD700}(%d+)")
				zakon = string.match(text, "�����������������: {FFD700}(%d+)/100")
				if tonumber(let) < 3 then
					lua_thread.create(function ()
						sampSendChat("/me ���� ������� �������� �������� � ����� ��������� ���")
						wait(2000)
						sampSendChat("/todo � ���������, �� ��� �� ���������.*� �������������� �� ����")
						wait(2000)
						sampSendChat("�� ������ ��������� � ����� ������� 3 ����.")
						wait(2000)
						sampSendChat("/b ����� 3 �������.")
						sobes_info['pass'] = u8'��� 3 ������'
						sobes_i = {
							false,
							false,
							false
						}
					end)
					sampSendDialogResponse(dialogId, 1, 0, "")
					return false
				end
				if tonumber(zakon) < 35 then
					lua_thread.create(function ()
						sampSendChat("/me ���� ������� �������� �������� � ����� ��������� ���")
						wait(2000)
						sampSendChat("/todo � ���������, �� ��� �� ���������.*� �������������� �� ����")
						wait(2000)
						sampSendChat("�� ����������������.")
						wait(2000)
						sampSendChat("/b ����� 35 �����������������.")
						sobes_info['pass'] = u8'��� 35 �����������������'
						sobes_i = {
							false,
							false,
							false
						}
					end)
					sampSendDialogResponse(dialogId, 1, 0, "")
					return false
				end
				if string.find(text, "�����������:", 1, true) then
					lua_thread.create(function ()
						sampSendChat("/me ���� ������� �������� �������� � ����� ��������� ���")
						wait(2000)
						sampSendChat("/todo � ���������, �� ��� �� ���������.*� �������������� �� ����")
						wait(2000)
						sampSendChat("�� ��� �������� � ������ �����������.")
						wait(2000)
						sampSendChat("/b ��������� �� ����� �����������.")
						sobes_info['pass'] = u8'������� � �����������'
						sobes_i = {
							false,
							false,
							false
						}
					end)
					sampSendDialogResponse(dialogId, 1, 0, "")
					return false
				end
				if string.find(text, "���������� �������� ���. �����") then
					lua_thread.create(function ()
						sampSendChat("/me ���� ������� �������� �������� � ����� ��������� ���")
						wait(2000)
						sampSendChat("/todo � ���������, �� ��� �� ���������.*� �������������� �� ����")
						wait(2000)
						sampSendChat("�� �������� � ��������������� ��������.")
						wait(2000)
						sampSendChat("/b �������� ���. �����.")
						sobes_info['pass'] = u8'����� � ���������'
						sobes_i = {
							false,
							false,
							false
						}
					end)
					sampSendDialogResponse(dialogId, 1, 0, "")
					return false
				end
				if u8:decode(mainIni.config.c_cnn) == "���-��" and string.find(text, "������� � �� {FF6200}TV ������", 1, true) or u8:decode(mainIni.config.c_cnn) == "���-��" and string.find(text, "������� � �� {FF6200}TV ������ SF", 1, true) or u8:decode(mainIni.config.c_cnn) == "��� ��" and string.find(text, "������� � �� {FF6200}TV ������ LV", 1, true) then
					lua_thread.create(function ()
						sampSendChat("/do ������� � ����� ������ � �����.")
						wait(2000)
						sampSendChat("/me ����� � ���� �������� ��������")
						wait(2000)
						sampSendChat("/todo � ���������, �� ��� �� ���������.*� �������������� �� ����")
						wait(2000)
						sampSendChat("� ��� ������� �� ��� �. " .. u8:decode(ccity) .. ".")
						wait(2000)
						sampSendChat("/b �������� ��������� �� ����� ��� ������� �� �� �� az � ������.")
						sobes_info['pass'] = u8'����� �� ���'
						sobes_i = {
							false,
							false,
							false
						}
					end)
					sampSendDialogResponse(dialogId, 1, 0, "")
					return false
				end
				lua_thread.create(function ()
					sampSendChat("/me ���� ������� �������� �������� � ����� ��������� ���")
					wait(1500)
					sampSendChat("/do ������� � �����.")
					wait(1500)
					sampSendChat("/todo �� � �������.*������� ������� �������")
				end)
				sobes_info['pass'] = u8'�� � �������'
				sobes_i[1] = false
				sampSendDialogResponse(dialogId, 1, 0, "")
				return false
			end
			if sobes_i[2] and title == "{BFBBBA}���. �����" and string.find(text, sampGetPlayerNickname(selected_user)) then
				narko = string.match(text, '����������������: (%d+)')
				if tonumber(narko) > 19 then
					sobes_info['mc'] = u8'���������������� ������ 19'
					lua_thread.create(function ()
						sampSendChat("/me ���� ���. ����� � �������� ��������")
						wait(2000)
						sampSendChat("/me ����� ��������� ��������")
						wait(2000)
						sampSendChat("/todo � ���������, �� ��� �� ���������.*� �������������� �� ����")
						wait(2000)
						sampSendChat("� ��� � ���. ����� �������� ��� �� ������ ����������������.")
						wait(2000)
						sampSendChat("/b ���������� � ��������� � ��������.")
						sobes_i = {
							false,
							false,
							false
						}
					end)
					sampSendDialogResponse(dialogId, 1, 0, "")
					return false
				end
				lua_thread.create(function ()
					sampSendChat("/me ���� ���. ����� �������� �������� � ����� ��������� �")
					wait(1500)
					sampSendChat("/do ���-����� � �����.")
					wait(1500)
					sampSendChat("/todo �� � �������.*������� ���. ����� �������")
				end)
				sobes_info['mc'] = u8'�� � �������'
				sobes_i[2] = false
				return false
			end
			if sobes_i[3] and title == "{BFBBBA}��������" and string.find(title, sampGetPlayerNickname(selected_user)) then
				lua_thread.create(function ()
					sobes_info['lic'] = u8'�� � �������'
					sampSendChat("/me ���� �������� �������� �������� � ����� ��������� ��")
					wait(1500)
					sampSendChat("/do �������� � �����.")
					wait(1500)
					sampSendChat("/todo �� � �������.*������� �������� �������")
					sobes_i[3] = false
				end)
				sampSendDialogResponse(dialogId, 1, 0, "")
				return false
			end
		end
	end
	if dialogId == 25693 and title:find("�������� �����������") and selected_user ~= nil then
		if sobes_i[1] then 
			local lineIndex = -2
			for line in text:gmatch("[^\n]+") do
				lineIndex = lineIndex + 1
				if string.find(line, '�������') and string.find(line, sampGetPlayerNickname(selected_user))  then
					cur_slot = lineIndex
					break
				end
			end
			sampSendDialogResponse(dialogId, 1, cur_slot, "")
			return false
		end
		if sobes_i[2] then 
			local lineIndex = -2
			for line in text:gmatch("[^\n]+") do
				lineIndex = lineIndex + 1
				if string.find(line, '����������� �����') and string.find(line, sampGetPlayerNickname(selected_user)) then
					cur_slot = lineIndex
					break
				end
			end
			sampSendDialogResponse(dialogId, 1, cur_slot, "")
			return false
		end
		if sobes_i[3] then 
			local lineIndex = -2
			for line in text:gmatch("[^\n]+") do
				lineIndex = lineIndex + 1
				if string.find(line, '��������') and string.find(line, sampGetPlayerNickname(selected_user)) then
					cur_slot = lineIndex
					break
				end
			end
			sampSendDialogResponse(dialogId, 1, cur_slot, "")
			return false
		end
	end
	if dialogId == 25694 and title:find("�������� �����������") and selected_user ~= nil then
		if sobes_i[1] or sobes_i[2] or sobes_i[3] then 
			local lineIndex = -1
			for line in text:gmatch("[^\n]+") do
				lineIndex = lineIndex + 1
				if string.find(line, '������� �����������') then
					cur_slot = lineIndex
					break
				end
			end
			sampSendDialogResponse(dialogId, 1, cur_slot, "")
			return false
		end
	end
	if title:find("��������������") and dialogId == 557 then
        for line in text:gmatch("[^\n]+") do
            if line:find('{FFFFFF}���������� ��%s+{FFD700}(.+),') then
                author = line:match('{FFFFFF}���������� ��%s+{FFD700}(.+),')
            end
        end
		msga = string.match(text, "{FFFFFF}���������:\t{33AA33}(.+)\n\n{FFFFFF}")
		msga = msga:gsub('=','rv')
		msga = string.gsub(msga, "^%s*(.-)%s*$", "%1")
		test = tonumber(msga)
		if test then msga = msga .. 'a' end
		dialog_text[1] = '{FFFFFF}���������:\t{33AA33}'..msga
		dialog_text[2] = '{FFFFFF}���������� �� {FFD700}'..author
		dialog_text[3] = msga
		dialog_title = title
		dialog_btn1 = button1
		dialog_btn2 = button2
		focus = true
		edit_helper[0] = true
		mainIni = inicfg.load({}, 'smi.ini')
		tst = nil
		for tt = 1, 100000 do
			if mainIni.edit[tt] ~= nil then
				if u8:decode(mainIni.edit[tt]) == msga then
					tst = tt
					break
				end
			end
		end
		if tst ~= nil and mainIni.config['auto_edit'] then
			if mainIni.edit[tst .. "_input"] ~= nil then
				sampSendDialogResponse(557, 1, -1, u8:decode(mainIni.edit[tst .. "_input"]))
			elseif mainIni.edit[tst .. "_cancel"] ~= nil then
				sampSendDialogResponse(557, 0, -1, u8:decode(mainIni.edit[tst .. "_cancel"]))
			end
			edit_helper[0] = false
			return false
		end
		return false
	end
	if title:find('������������') and dialogId == 0 then 
		jp_info = {
			org = '',
			name = '',
			ads = {
				all = '',
				all_vip = '',
				today = '',
				today_vip = ''
			},
			newspaper = {
				all_created = '',
				all_sell = '',
				today_created = '',
				today_sell = ''
			},
			rang = {
				first = '',
				last = ''
			}
		}
		jp_info['org'], jp_info['name'] = 											string.match(text, '{FFFFFF}���������� ������������ ���������� %{66FF6C%}(.+){FFFFFF}: ([A-Za-z_]+)\n')
		jp_info['ads']['all'], jp_info['ads']['all_vip'] = 							string.match(text, '���������� ���������������: %{FFB323%}(%d+)%{FFFFFF%}\n'), string.match(text, 'VIP%-���������� ���������������: %{FFB323%}(%d+)%{FFFFFF%}\n')
		jp_info['ads']['today'], jp_info['ads']['today_vip'] = 						string.match(text, '���������� ��������������� �� ������� %{F9FF23%}(%d+)%{FFFFFF%}\n'), string.match(text, 'VIP%-���������� ��������������� �� ������� %{F9FF23%}(%d+)%{FFFFFF%}\n')

		jp_info['newspaper']['all_created'], jp_info['newspaper']['all_sell'] = 		string.match(text, '������� �����: %{FFB323%}(%d+)%{FFFFFF%}\n'), string.match(text, '������� �����: %{FFB323%}(%d+)%{FFFFFF%}\n')
		jp_info['newspaper']['today_created'], jp_info['newspaper']['today_sell'] = 	string.match(text, '������� ����� �� �������: %{F9FF23%}(%d+)%{FFFFFF%}\n'), string.match(text, '������� ����� �� �������: %{F9FF23%}(%d+)%{FFFFFF%}\n')
		jp_info['rang']['first'], jp_info['rang']['last'] = 							string.match(text, '���� ���������� � �����������:\n%{cccccc%}(.+)%{FFFFFF%}\n��������� ���������:\n%{cccccc%}(.+)')
		jobprogress[0] = true
		return false
	end
end


function imgui.Ques(text)
	imgui.SameLine()
	imgui.TextDisabled("(?)")
	if imgui.IsItemHovered() then
		imgui.BeginTooltip()
		imgui.TextUnformatted(u8(text))
		imgui.EndTooltip()
	end
end

function changeColorAlpha(argb, alpha)
	local _, r, g, b = explode_U32(argb)
	return join_argb(alpha, r, g, b)
end

efir_counter = {}

function addball(name)
	if efir_counter[name] ~= nil then
		efir_counter[name] = efir_counter[name] + 1
	else 
		efir_counter[name] = 1
	end
end

function addWithTag(text)
	sampAddChatMessage("[SMI-plalkeo] {FFFFFF}"..text, curcolor1)
end


function checkAds(text)
	text = u8:decode(text)
	t1 = text:sub(1,10)
	t2 = text:sub(1,12)
	t3 = text:sub(1,5)
	t4 = text:sub(1,6)
	if text:match("[��]����") or text:match("[��]�����") or text:match("[��]���") or text:match("[��]�����") then 
		return false
	else
		return true
	end
end

function obrezer(text)
	a = text:sub(1,4)
	if a ~= mainIni.config['c_tag'] then 
		return mainIni.config['c_tag']..' // '..text
	else
		return text 
	end
end 

function LimitedInput()
	text = ad_d[0]
end

local ad_d = new.char[180]()

function obrez(text)
	text = u8:decode(text)
	return text:sub(1,80)
end

function render_input()
end

function send_ad()
	if #u8:decode(str(ad_d)) > 6 then
		if #u8:decode(str(ad_d)) <= 80 then
			edit_helper[0] = false
			sampSendDialogResponse(557, 1, -1, u8:decode(str(ad_d)))
			mainIni.edit['last'] = tonumber(mainIni.edit['last']) + 1
			i = mainIni.edit['last']
			mainIni.edit[tostring(mainIni.edit['last'])] = u8:encode(dialog_text[3])
			mainIni.edit[tostring(mainIni.edit['last']) .. '_input'] = str(ad_d)
			inicfg.save(mainIni, 'smi.ini')
			imgui.StrCopy(ad_d, '')
		else
			focus = true
			sampAddChatMessage("[SMI-plalkeo] {FFFFFF}������������ ����� ���������� - " .. curcolor.. "80", curcolor1)
		end
	else
		focus = true
		sampAddChatMessage("[SMI-plalkeo] {FFFFFF}����������� ����� ���������� - " .. curcolor.. "6", curcolor1)
	end
end

function cancel_ad()
	if checkAds(str(ad_d)) then 
		if #u8:decode(str(ad_d)) > 6 then
			edit_helper[0] = false
			imgui.StrCopy(ad_d, obrezer(str(ad_d)))

			sampSendDialogResponse(557, 0, -1, u8:decode(str(ad_d)))
			lastob = 0
			mainIni.edit['last'] = tonumber(mainIni.edit['last']) + 1
			i = mainIni.edit['last']
			mainIni.edit[tostring(mainIni.edit['last'])] = u8:encode(dialog_text[3])
			mainIni.edit[tostring(mainIni.edit['last']) .. '_cancel'] = str(ad_d)
			inicfg.save(mainIni, 'smi.ini')
			imgui.StrCopy(ad_d, '')
		else
			focus = true
			sampAddChatMessage("[SMI-plalkeo] {FFFFFF}����������� ����� ���������� - " .. curcolor.. "6", curcolor1)
		end
	else
		addWithTag('������ ���������� �������� "�����" ��� "������" � ��� �� ����� ���� ���������.')
	end
end

function MenuButton(r,g,b, key, icon, text, sizeX, sizeY)
    if smi_menu == key then
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(r / 255, g / 255, b / 255, 0.86))
    end

    if imgui.Button(faicons(icon) .. text, imgui.ImVec2(sizeX, sizeY)) then
        smi_menu = key
    end

    if smi_menu == key then
        imgui.PopStyleColor(1)
    end
end


function colored_button_main(r, g, b)
	local sizeX, sizeY = 200 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE
	if smi_menu == 'default' then
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(r / 255, g / 255, b / 255, 0.86))
		if imgui.Button(faicons('BARS') .. u8' ��������', (imgui.ImVec2(sizeX, sizeY))) then smi_menu = 'default' end
		imgui.PopStyleColor(1)
	else
		if imgui.Button(faicons('BARS') .. u8' ��������', (imgui.ImVec2(sizeX, sizeY))) then smi_menu = 'default' end
	end
	if smi_menu == 'sobes' then
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(r / 255, g / 255, b / 255, 0.86))
		if imgui.Button(faicons('ID_CARD') .. u8' �������������', (imgui.ImVec2(sizeX, sizeY))) then smi_menu = 'sobes' end
		imgui.PopStyleColor(1)
	else
		if imgui.Button(faicons('ID_CARD') .. u8' �������������', (imgui.ImVec2(sizeX, sizeY))) then smi_menu = 'sobes' end
	end
	if smi_menu == 'efir' then
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(r / 255, g / 255, b / 255, 0.86))
		if imgui.Button(faicons('MICROPHONE') .. u8' �����', (imgui.ImVec2(sizeX, sizeY))) then smi_menu = 'efir' end
		imgui.PopStyleColor(1)
	else
		if imgui.Button(faicons('MICROPHONE') .. u8' �����', (imgui.ImVec2(sizeX, sizeY))) then smi_menu = 'efir' end
	end
	if smi_menu == 'settings' then
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(r / 255, g / 255, b / 255, 0.86))
		if imgui.Button(faicons('GEAR') ..u8' ���������', (imgui.ImVec2(sizeX, sizeY))) then smi_menu = 'settings' end
		imgui.PopStyleColor(1)
	else
		if imgui.Button(faicons('GEAR') ..u8' ���������', (imgui.ImVec2(sizeX, sizeY))) then smi_menu = 'settings' end
	end
	if smi_menu == 'dopka' then
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(r / 255, g / 255, b / 255, 0.86))
		if imgui.Button(faicons('SLIDERS') .. u8' ���. �������', (imgui.ImVec2(sizeX, sizeY))) then smi_menu = 'dopka' end
		imgui.PopStyleColor(1)
	else
		if imgui.Button(faicons('SLIDERS') .. u8' ���. �������', (imgui.ImVec2(sizeX, sizeY))) then smi_menu = 'dopka' end
	end
	if smi_menu == 'pro' then
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(r / 255, g / 255, b / 255, 0.86))
		if imgui.Button(faicons('FILE_SIGNATURE') .. u8' ���/���/�����', (imgui.ImVec2(sizeX, sizeY))) then smi_menu = 'pro' end
		imgui.PopStyleColor(1)
	else
		if imgui.Button(faicons('FILE_SIGNATURE') .. u8' ���/���/�����', (imgui.ImVec2(sizeX, sizeY))) then smi_menu = 'pro' end
	end
	if smi_menu == 'about' then
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(r / 255, g / 255, b / 255, 0.86))
		if imgui.Button(faicons('INFO') .. u8' � �������', (imgui.ImVec2(sizeX, sizeY))) then smi_menu = 'about' end
		imgui.PopStyleColor(1)
	else
		if imgui.Button(faicons('INFO') .. u8' � �������', (imgui.ImVec2(sizeX, sizeY))) then smi_menu = 'about' end
	end
end

function render_main()
	if mainIni.theme['theme'] == 'blue' then
		colored_button_main(61, 146, 250)
	elseif mainIni.theme['theme'] == 'red' then
		colored_button_main(170, 30, 30)
	elseif mainIni.theme['theme'] == 'purple' then
		colored_button_main(110, 60, 150)
	elseif mainIni.theme['theme'] == 'black' then
		colored_button_main(50, 50, 50)
	elseif mainIni.theme['theme'] == 'monet' then
		if not isMonetLoader() then
			local a, r, g, b = explode_argb(gen_color.accent1.color_400)
			colored_button_main(r, g, b)
		else
			colored_button_main(61, 146, 250)
			mainIni.theme['theme'] = 'blue'
		end
	end
end

local price = new.char[32]()
local price_c = new.char[32]()

local edit_h = imgui.OnFrame(
	function() return edit_helper[0] and not isPauseMenuActive() end,
	function(self)
		imgui.SetNextWindowPos(imgui.ImVec2(iScreenWidth / 2, iScreenHeight / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(790 * MONET_DPI_SCALE, 290 * MONET_DPI_SCALE)) -- 200
		imgui.Begin(u8'����������', edit_helper, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoSavedSettings)
		imgui.BeginChild('##text##12a3123', imgui.ImVec2(-1, 150 * MONET_DPI_SCALE), true)
		imgui.CenterTextColoredRGB('����������')
		imgui.TextColoredRGB(dialog_text[2])
		imgui.TextColoredRGB(dialog_text[1])
		imgui.PushItemWidth(700 * MONET_DPI_SCALE)
		if focus then 
			imgui.SetKeyboardFocusHere(0)
			focus = false
		end
		if imgui.Button(u8"���������� ����������") then 
			imgui.StrCopy(ad_d, u8(dialog_text[3]))
		end
		imgui.InputText("##MGDKJGNJKSDGNJKDSJGNKS", ad_d, ffi.sizeof(ad_d))
		imgui.PopItemWidth()
		imgui.SameLine()
		if imgui.Button(faicons('TRASH'), imgui.ImVec2(20 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE)) then
			imgui.StrCopy(ad_d, '')
		end
		imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8(dialog_btn1)).x) / (4.5 * MONET_DPI_SCALE))
		if imgui.Button(u8(dialog_btn1), imgui.ImVec2(200 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE)) then
			send_ad()
		end
		imgui.SameLine()
		if imgui.Button(u8(dialog_btn2), imgui.ImVec2(200 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE)) then 
			cancel_ad()
		end
		imgui.EndChild()

		imgui.BeginChild("##M", imgui.ImVec2(330 * MONET_DPI_SCALE, 120 * MONET_DPI_SCALE), true)
		if imgui.Button(u8'�����', imgui.ImVec2(60 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE)) then
			imgui.StrCopy(ad_d, u8"����� ")
		end
		imgui.SameLine(75 * MONET_DPI_SCALE)
		if imgui.Button(u8'������', imgui.ImVec2(70 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE)) then
			imgui.StrCopy(ad_d, u8"������ ")
		end
		imgui.SameLine()
		imgui.PushItemWidth(50 * MONET_DPI_SCALE)
		if imgui.Combo(u8'##TYPES', types[3], types[2], #types[1]) then
			imgui.StrCopy(ad_d, str(ad_d)..types[1][types[3][0]+1])
		end
		imgui.PopItemWidth()
		imgui.SameLine()
		imgui.Ques('�.� - ���������\n�.� - ����������\n�.� - ������\n�.� - ��������\n�.� - ���������\n�.� - ��������\n�.� - ��������� ���������\n�.� - �����\n�.� - ������ �������')
		imgui.PushItemWidth(75 * MONET_DPI_SCALE)
		if imgui.InputInt(u8"##GRAVIROVKA", grav) then 
			grav[0] = grav[0] < 0 and 0 or grav[0] > 12 and 12 or grav[0]
		end
		imgui.PopItemWidth()
		imgui.SameLine()
		if imgui.Button(u8'����������', imgui.ImVec2(90 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE)) then
			imgui.StrCopy(ad_d, str(ad_d)..u8' � ����������� "+'..grav[0]..'"')
		end
		if imgui.Button(u8'���', imgui.ImVec2(40 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE)) then
			imgui.StrCopy(ad_d, str(ad_d)..u8'��� � '..city[selected_city[0]+1]..' '..house_dop[selected_house_dop[0]+1])
		end
		imgui.SameLine(55 * MONET_DPI_SCALE)
		if imgui.Button(u8'������', imgui.ImVec2(60 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE)) then
			imgui.StrCopy(ad_d, str(ad_d)..u8'�.� "'..biz[selected_biz[0]+1]..'"')
		end
		imgui.SameLine(120 * MONET_DPI_SCALE)
		imgui.PushItemWidth(173 * MONET_DPI_SCALE)
		if imgui.Combo('##COMBOBIZ', selected_biz, biz_items, #biz) then 
		end
		imgui.PopItemWidth()
		imgui.PushItemWidth(145 * MONET_DPI_SCALE)
		if imgui.Combo('##COMBOHOUSE', selected_city, city_items, #city) then 
		end
		imgui.PopItemWidth()
		imgui.SameLine(155 * MONET_DPI_SCALE)
		imgui.PushItemWidth(130 * MONET_DPI_SCALE)
		if imgui.Combo('##COMBOHOUSEDOP', selected_house_dop, house_dop_items, #house_dop) then 
		end
		imgui.PopItemWidth()
		imgui.EndChild()
		imgui.SameLine()

		---
		imgui.BeginChild("##ASDASDM", imgui.ImVec2(-1, 120 * MONET_DPI_SCALE), true)
		if imgui.Button(u8'������: ���������', imgui.ImVec2(140 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE)) then
			imgui.StrCopy(ad_d, str(ad_d)..u8". ������: ���������")
		end
		imgui.SameLine(155 * MONET_DPI_SCALE)
		if imgui.Button(u8'����: ����������', imgui.ImVec2(130 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE)) then
			imgui.StrCopy(ad_d, str(ad_d)..u8". ����: ����������")
		end
		imgui.PushItemWidth(100 * MONET_DPI_SCALE)
		imgui.InputText("##PRICE", price, ffi.sizeof(price))
		imgui.PopItemWidth()
		imgui.SameLine(115 * MONET_DPI_SCALE)
		if imgui.Button(u8'����', imgui.ImVec2(60 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE)) then
			imgui.StrCopy(ad_d, str(ad_d)..u8". ����: "..str(price):gsub(u8'���',u8'����'):gsub(u8"��",u8'���'):gsub(u8'�',u8'���'))
		end
		imgui.SameLine(180 * MONET_DPI_SCALE)
		if imgui.Button(u8'������', imgui.ImVec2(70 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE)) then
			imgui.StrCopy(ad_d, str(ad_d)..u8". ������: "..str(price):gsub(u8'���',u8'����'):gsub(u8"��",u8'���'):gsub(u8'�',u8'���'))
		end
		if imgui.Button(u8'������ �� ��: ���������', imgui.ImVec2(175 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE)) then
			imgui.StrCopy(ad_d, str(ad_d)..u8". ������ �� ��: ���������")
		end
		imgui.SameLine(190 * MONET_DPI_SCALE)
		if imgui.Button(u8'���� �� ��: ����������', imgui.ImVec2(160 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE)) then
			imgui.StrCopy(ad_d, str(ad_d)..u8". ���� �� ��: ����������")
		end
		imgui.PushItemWidth(100 * MONET_DPI_SCALE)
		imgui.InputText("##PRICE", price, ffi.sizeof(price))
		imgui.PopItemWidth()
		imgui.SameLine(115 * MONET_DPI_SCALE)
		if imgui.Button(u8'���� �� ��', imgui.ImVec2(80 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE)) then
			imgui.StrCopy(ad_d, str(ad_d)..u8". ���� �� ��: "..str(price):gsub(u8'���',u8'����'):gsub(u8"��",u8'���'):gsub(u8'�',u8'���'))
		end
		imgui.SameLine(200 * MONET_DPI_SCALE)
		if imgui.Button(u8'������ �� ��', imgui.ImVec2(100 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE)) then
			imgui.StrCopy(ad_d, str(ad_d)..u8". ������ �� ��: "..str(price):gsub(u8'���',u8'����'):gsub(u8"��",u8'���'):gsub(u8'�',u8'���'))
		end		
		imgui.EndChild()
		---

		imgui.End()
	end
)
function save()
	mainIni.config['c_nick'] = str(nick)
	inicfg.save(mainIni,'smi.ini')
end

-- INTERACTION MENU

local fastmenuID = 0

function string.split(inputstr, sep)
	if sep == nil then
		sep = '%s'
	end
	local t={} ; i=1
	for str in gmatch(inputstr, '([^'..sep..']+)') do
		t[i] = str
		i = i + 1
	end
	return t
end

function string.separate(a)
	if type(a) ~= 'number' then
		return a
	end
	local b, e = gsub(format('%d', a), '^%-', '')
	local c = gsub(b:reverse(), '%d%d%d', '%1.')
	local d = gsub(c:reverse(), '^%.', '')
	return (e == 1 and '-' or '')..d
end

function string.rlower(s)
	local russian_characters = {
		[155] = '[', [168] = '�', [184] = '�', [192] = '�', [193] = '�', [194] = '�', [195] = '�', [196] = '�', [197] = '�', [198] = '�', [199] = '�', [200] = '�', [201] = '�', [202] = '�', [203] = '�', [204] = '�', [205] = '�', [206] = '�', [207] = '�', [208] = '�', [209] = '�', [210] = '�', [211] = '�', [212] = '�', [213] = '�', [214] = '�', [215] = '�', [216] = '�', [217] = '�', [218] = '�', [219] = '�', [220] = '�', [221] = '�', [222] = '�', [223] = '�', [224] = '�', [225] = '�', [226] = '�', [227] = '�', [228] = '�', [229] = '�', [230] = '�', [231] = '�', [232] = '�', [233] = '�', [234] = '�', [235] = '�', [236] = '�', [237] = '�', [238] = '�', [239] = '�', [240] = '�', [241] = '�', [242] = '�', [243] = '�', [244] = '�', [245] = '�', [246] = '�', [247] = '�', [248] = '�', [249] = '�', [250] = '�', [251] = '�', [252] = '�', [253] = '�', [254] = '�', [255] = '�',
	}
	s = lower(s)
	local strlen = len(s)
	if strlen == 0 then return s end
	s = lower(s)
	local output = ''
	for i = 1, strlen do
		local ch = s:byte(i)
		if ch >= 192 and ch <= 223 then output = output .. russian_characters[ch + 32]
		elseif ch == 168 then output = output .. russian_characters[184]
		else output = output .. char(ch)
		end
	end
	return output
end
function dump(o)
	if type(o) == 'table' then
	   local s = '{ '
	   for k,v in pairs(o) do
		  if type(k) ~= 'number' then k = '"'..k..'"' end
		  s = s .. '['..k..'] = ' .. dump(v) .. ','
	   end
	   return s .. '} '
	else
	   return tostring(o)
	end
end
function getDownKeys()
	local curkeys = ''
	local bool = false
	for k, v in pairs(vkeys) do
		if isKeyDown(v) and (v == VK_MENU or v == VK_CONTROL or v == VK_SHIFT or v == VK_LMENU or v == VK_RMENU or v == VK_RCONTROL or v == VK_LCONTROL or v == VK_LSHIFT) then
			if v ~= VK_MENU and v ~= VK_CONTROL and v ~= VK_SHIFT then
				curkeys = v
			end
		end
	end
	for k, v in pairs(vkeys) do
		if isKeyDown(v) and (v ~= VK_MENU and v ~= VK_CONTROL and v ~= VK_SHIFT and v ~= VK_LMENU and v ~= VK_RMENU and v ~= VK_RCONTROL and v ~= VK_LCONTROL and v ~= VK_LSHIFT) then
			if len(tostring(curkeys)) == 0 then
				curkeys = v
				return curkeys,true
			else
				curkeys = curkeys .. ' ' .. v
				return curkeys,true
			end
			bool = false
		end
	end
	return curkeys, bool
end

local tHotKeyData = {
	edit 							= nil,
	save 							= {},
	lasted 							= clock(),
}

function imgui.GetKeysName(keys)
	if type(keys) ~= 'table' then
	   	return false
	else
	  	local tKeysName = {}
	  	for k = 1, #keys do
			tKeysName[k] = vkeys.id_to_name(tonumber(keys[k]))
	  	end
	  	return tKeysName
	end
end

function isKeysDown(keylist, pressed)
	if keylist == nil then return end
	keylist = (find(keylist, '.+ %p .+') and {keylist:match('(.+) %p .+'), keylist:match('.+ %p (.+)')} or {keylist})
	local tKeys = keylist
	if pressed == nil then
		pressed = false
	end
	if tKeys[1] == nil then
		return false
	end
	local bool = false
	local key = #tKeys < 2 and tKeys[1] or tKeys[2]
	local modified = tKeys[1]
	if #tKeys < 2 then
		if wasKeyPressed(vkeys.name_to_id(key, true)) and not pressed then
			bool = true
		elseif isKeyDown(vkeys.name_to_id(key, true)) and pressed then
			bool = true
		end
	else
		if isKeyDown(vkeys.name_to_id(modified,true)) and not wasKeyReleased(vkeys.name_to_id(modified, true)) then
			if wasKeyPressed(vkeys.name_to_id(key, true)) and not pressed then
				bool = true
			elseif isKeyDown(vkeys.name_to_id(key, true)) and pressed then
				bool = true
			end
		end
	end
	if nextLockKey == keylist then
		if pressed and not wasKeyReleased(vkeys.name_to_id(key, true)) then
			bool = false
		else
			bool = false
			nextLockKey = ''
		end
	end
	return bool
end

function imgui.HotKey(name, path, pointer, defaultKey, width)
	local width = width or 90
	local cancel = isKeyDown(0x08)
	local tKeys, saveKeys = string.split(getDownKeys(), ' '),select(2,getDownKeys())
	local name = tostring(name)
	local keys, bool = path[pointer] or defaultKey, false

	local sKeys = keys
	for i=0,2 do
		if imgui.IsMouseClicked(i) then
			tKeys = {i==2 and 4 or i+1}
			saveKeys = true
		end
	end

	if tHotKeyData.edit ~= nil and tostring(tHotKeyData.edit) == name then
		if not cancel then
			if not saveKeys then
				if #tKeys == 0 then
					sKeys = (ceil(imgui.GetTime()) % 2 == 0) and '______' or ' '
				else
					sKeys = table.concat(imgui.GetKeysName(tKeys), ' + ')
				end
			else
				path[pointer] = table.concat(imgui.GetKeysName(tKeys), ' + ')
				tHotKeyData.edit = nil
				tHotKeyData.lasted = clock()
				inicfg.save(mainIni,'smi.ini')
			end
		else
			path[pointer] = defaultKey
			tHotKeyData.edit = nil
			tHotKeyData.lasted = clock()
			inicfg.save(mainIni,'smi.ini')
		end
	end

	imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.FrameBg])
	imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.GetStyle().Colors[imgui.Col.FrameBgHovered])
	imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.GetStyle().Colors[imgui.Col.FrameBgActive])
	if imgui.Button((sKeys ~= '' and sKeys or u8'��������') .. '## '..name, imgui.ImVec2(width, 0)) then
		tHotKeyData.edit = name
	end
	imgui.PopStyleColor(3)
	return bool
end

local renderWindow = new.bool(false)

function clear_sobes()
	sobes_i = {
		false,
		false,
		false
	}

	sobes_info = {
		pass = u8'�� ���������',
		mc = u8'�� ���������',
		lic = u8'�� ���������'
	}
end



function get_org(color)
	clr = '{'..("%06X"):format(bit.band(color, 0xFFFFFF))..'}'
	orgs = {
		[2164228096] = '���',
		[23486046] = '���������� [� �����]',
		[4294967295] = '����������� [��� �����]',
		[2164260863] = '����������� [��� �����]',
		[368966908] = '����������� [��� �����]',
		[2149720609] = '������',
		[2147503871] = '������� ��',
		[2147502591] = '�������',
		[2164227710] = '��������',
		[2159918525] = '���',
		[2157536819] = '�����',
		[2580667164] = '�����',
		[2152104628] = '���',
		[2566951719] = '���� �����',
		[2157523814] = '���',
		[2580283596] = '������',
		[2158524536] = '������ �����',
		[2161094470] = '�������',
		[2566979554] = '�����',
		[2164221491] = '���������',
		[2150206647] = '����������� ����',
		[2573625087] = '����',
		[2150852249] = '������� �����',
		[2160918272] = '�������������',
		[2157314562] = '������',
	}
	if color == 2149720609 or color == 23486046 then clr = '{FDFCFC}' end
	return {clr, orgs[color]}
end

local newFrame = imgui.OnFrame(
	function() return renderWindow[0] and not isPauseMenuActive() end,
	function(self)
		local resX, resY = getScreenResolution()
		local sizeX, sizeY = 600 * MONET_DPI_SCALE, 330 * MONET_DPI_SCALE
		imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY), imgui.Cond.Always)
		imgui.Begin('Main Window', renderWindow, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)

		imgui.CenterTextColoredRGB('���� ��������������', 2)

		imgui.BeginChild('##LEFT COLONKA', imgui.ImVec2(200 * MONET_DPI_SCALE, -1))
		imgui.BeginChild('##FFMK', imgui.ImVec2(200 * MONET_DPI_SCALE, 85 * MONET_DPI_SCALE), true)
		imgui.CenterTextColoredRGB('������ �����:', 2)
		imgui.CenterTextColoredRGB(curcolor..''..sampGetPlayerNickname(fastmenuID)..'{FFFFFF} ['..fastmenuID..']', 2)
		imgui.CenterTextColoredRGB('��� � �����: '..sampGetPlayerScore(fastmenuID), 2)
		local orgaf = get_org(sampGetPlayerColor(fastmenuID))
		imgui.CenterTextColoredRGB(orgaf[1]..orgaf[2], 2)
		imgui.EndChild()
		imgui.BeginChild('##FFMKa', imgui.ImVec2(200 * MONET_DPI_SCALE, 80 * MONET_DPI_SCALE))
		if imgui.Button(faicons('BARS') .. u8' �������� ��������', imgui.ImVec2(-1, 30 * MONET_DPI_SCALE)) then fast_menu = 'own' end
		if imgui.Button(faicons('ID_CARD') .. u8' �������������', imgui.ImVec2(-1, 30 * MONET_DPI_SCALE)) then fast_menu = 'sobes' end
		imgui.EndChild()
		imgui.EndChild()
		imgui.SameLine()
		imgui.BeginChild('##RIGHT COLONKA', imgui.ImVec2(-1, -1), true)
		if fast_menu == 'sobes' then
			imgui.BeginChild('sobesvverh', imgui.ImVec2(-1, -1))
			imgui.BeginChild('sobes', imgui.ImVec2(120 * MONET_DPI_SCALE, 160 * MONET_DPI_SCALE), true)
			imgui.Text(faicons('USER_XMARK') .. u8(" ������"))
			imgui.Separator()
			if imgui.Selectable(u8("��� ��������")) then
				clear_sobes()
				lua_thread.create(function ()
					sampSendChat("/todo � ���������, �� ��� �� ���������.*� �������������� �� ����")
					wait(2000)
					sampSendChat("� ��� ��� ��������.")
					wait(2000)
					sampSendChat("/b �������� ������� � �����.")
				end)
			end
			if imgui.Selectable(u8("��� ���. �����")) then
				clear_sobes()
				lua_thread.create(function ()
					sampSendChat("/todo � ���������, �� ��� �� ���������.*� �������������� �� ����")
					wait(2000)
					sampSendChat("� ��� ��� ���. �����.")
					wait(2000)
					sampSendChat("/b �������� ���. ����� � ��������.")
				end)
			end
			if imgui.Selectable(u8("������� � ���.")) then
				clear_sobes()
				lua_thread.create(function ()
					sampSendChat("/todo � ���������, �� ��� �� ���������.*� �������������� �� ����")
					wait(2000)
					sampSendChat("�� ��� �������� � �����������.")
					wait(2000)
					sampSendChat("/b ��������� �� ����� �����������.")
				end)
			end
			if imgui.Selectable(u8("����� ���")) then
				clear_sobes()
				lua_thread.create(function ()
					sampSendChat("/do ������� � ����� ������ � �����.")
					wait(2000)
					sampSendChat("/me ����� �������� � ���� ������")
					wait(2000)
					sampSendChat("/todo � ���������, �� ��� �� ���������.*� �������������� �� ����")
					wait(2000)
					sampSendChat("� ��� �������� ���, �������� ��� ��������.")
					wait(2000)
					sampSendChat("/b ������� ��� ����� ���.")
				end)
			end
			if imgui.Selectable(u8("��� ��")) then
				clear_sobes()
				lua_thread.create(function ()
					sampSendChat("/do ������� � ����� ������ � �����.")
					wait(2000)
					sampSendChat("/me ����� �������� � ���� ������")
					wait(2000)
					sampSendChat("/todo � ���������, �� ��� �� ���������.*� �������������� �� ����")
					wait(2000)
					sampSendChat("�� ����. �� �������� ��� ����� ������.")
					wait(2000)
					sampSendChat("/b �� ����� �������� ��.")
				end)
			end
			imgui.EndChild()
			imgui.SameLine()
			imgui.BeginChild('sobes2', imgui.ImVec2(-1, 160 * MONET_DPI_SCALE), true)
			if imgui.Button(faicons("PLAY") .. u8" ������ �������������", imgui.ImVec2(-1, 25 * MONET_DPI_SCALE)) then
				if mainIni.config.c_nick ~= '' then
					sampSendChat("������������, ���� ����� " .. u8:decode(mainIni.config.c_nick) .. ". �� ������ �� �������������?")
				else
					lua_thread.create(function ()
						sampSendChat("������������, ���� ����� " .. mainIni.config.c_nicken .. ". �� ������ �� �������������?")
						wait(300)
						sampAddChatMessage("[SMI-plalkeo] {FFFFFF}�������� ������� ���� ������� �������. "..curcolor.."/smi {FFFFFF} - "..curcolor.." �������", curcolor1)
					end)
				end
			end
			if imgui.Button(faicons('FILE_ALT') .. u8" ��������� ���������", imgui.ImVec2(-1, 25 * MONET_DPI_SCALE)) then
				if fastmenuID > -1 and fastmenuID <= 1000 and sampIsPlayerConnected(fastmenuID) then
					sobes_i = {
						true,
						true,
						true
					}
					lua_thread.create(function ()
						sampSendChat("�������, ����� �� ���� ������������? �������, ���. ����� � ��������.")
						wait(1000)
						sampSendChat("/b ����� �������� ������������ �������: /showpass " .. u_id .. ", /showmc " .. u_id .. ", /showlic " .. u_id)
						wait(2000)
						sampSendChat("/b �� ������ ���� �����������!")
					end)
				else
					sampAddChatMessage("[SMI-plalkeo] {FFFFFF}����� �����.", curcolor1)
				end
			end
			if imgui.Button(faicons('QUESTION') .. u8" ���������� � ����", imgui.ImVec2(-1, 25 * MONET_DPI_SCALE)) then
				lua_thread.create(function ()
					sampSendChat("������, ������ � ����� ���� ��������.")
					wait(2000)
					sampSendChat("���������� � ����.")
				end)
			end
			if imgui.Button(faicons('QUESTION') .. u8" ������ ������ ��?", imgui.ImVec2(-1, 25 * MONET_DPI_SCALE)) then
				sampSendChat("������ �� ������� ������ ��� ����������?")
			end
			if imgui.Button(faicons('USER_CHECK') .. u8" ������������� ��������", imgui.ImVec2(-1, 25 * MONET_DPI_SCALE)) then
				if fastmenuID > -1 and fastmenuID <= 1000 and sampIsPlayerConnected(fastmenuID) then
					lua_thread.create(function ()
						sampSendChat("/todo ����������! �� ������ �������������!* � ������� �� ����")
						sobes_i = {
							false,
							false,
							false
						}
		
						sobes_info = {
							pass = u8'�� ���������',
							mc = u8'�� ���������',
							lic = u8'�� ���������'
						}
						wait(2000)
						invite(fastmenuID)
					end)
				else
					sampAddChatMessage("[SMI-plalkeo] {FFFFFF}����� �����.", curcolor1)
				end
			end
			imgui.EndChild()
			imgui.BeginChild('sobes3', imgui.ImVec2(-1, -1), true)
			
			imgui.Text(u8'�������: '..sobes_info['pass'])
			imgui.Text(u8'���. �����: '..sobes_info['mc'])
			imgui.Text(u8'��������: '..sobes_info['lic'])
			imgui.Separator()
			if imgui.Selectable(u8'�������� ����������') then
				select_id[0] = -1
				sobes_i = {
					false,
					false,
					false
				}

				sobes_info = {
					pass = u8'�� ���������',
					mc = u8'�� ���������',
					lic = u8'�� ���������'
				}
			end
			imgui.EndChild()
			imgui.EndChild()
		end
		if fast_menu == 'own' then 
			imgui.BeginChild('##123 leviy', imgui.ImVec2(-1, 135 * MONET_DPI_SCALE), true)
			imgui.CenterTextColoredRGB('��� �������')
			if imgui.Button(faicons('USER')..u8' �������� �������������', imgui.ImVec2(-1, 30 * MONET_DPI_SCALE)) then fast_menu = 'sobes' end
			if imgui.Button(faicons('USER_PLUS')..u8' ���������� � �����������', imgui.ImVec2(-1, 30 * MONET_DPI_SCALE)) then sampSendChat('/invite '..fastmenuID); renderWindow[0] = false end
			if imgui.Button(faicons('ARROW_TURN_DOWN_LEFT')..u8' ������� �� ������', imgui.ImVec2(-1, 30 * MONET_DPI_SCALE)) then sampSendChat('/expel '..fastmenuID..' �.�.�'); renderWindow[0] = false end
			imgui.EndChild()
			imgui.BeginChild('##123 in org', imgui.ImVec2(-1, -1), true)
			imgui.CenterTextColoredRGB('��� �����������')
			if imgui.Button(faicons('ARROW_UP')..u8' �������� ����������', imgui.ImVec2(-1, 30 * MONET_DPI_SCALE)) then sampSetChatInputText('/giverank '..fastmenuID..' '); sampSetChatInputEnabled(true); renderWindow[0] = false end
			if imgui.Button(faicons('ARROW_DOWN')..u8' �������� ����������', imgui.ImVec2(-1, 30 * MONET_DPI_SCALE)) then sampSetChatInputText('/giverank '..fastmenuID..' '); sampSetChatInputEnabled(true); renderWindow[0] = false end
			if imgui.Button(faicons('USER_MINUS')..u8' ������� ����������', imgui.ImVec2(-1, 30 * MONET_DPI_SCALE)) then sampSetChatInputText('/uninvite '..fastmenuID..' '); sampSetChatInputEnabled(true); renderWindow[0] = false end
			imgui.EndChild()
		end
		imgui.EndChild()
		
		imgui.End()
	end
)

-- INTERACTION MENU

local helpMenu = imgui.new.bool(false)

local helpMenu_ = imgui.OnFrame(
	function() return helpMenu[0] end,
	function(player)
		local resX, resY = getScreenResolution()
		local sizeX, sizeY = 300 * MONET_DPI_SCALE, 300 * MONET_DPI_SCALE
		imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY), imgui.Cond.FirstUseEver)
		if imgui.Begin('Main Window', helpMenu) then
			     
			imgui.End()
		end
	end
)

local main_menu = imgui.OnFrame(
	function() return window[0] and not isPauseMenuActive() end,
	function(self)
		imgui.SetNextWindowPos(imgui.ImVec2(iScreenWidth / 2, iScreenHeight / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(800 * MONET_DPI_SCALE, 277 * MONET_DPI_SCALE))
		imgui.Begin('SMI-plalkeo', window, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
		addons.AlignedText('SMI-plalkeo', 2)
		local wsize = imgui.GetWindowSize()
		imgui.SetCursorPos(imgui.ImVec2(wsize.x - (30 * MONET_DPI_SCALE), 5 * MONET_DPI_SCALE))
		if imgui.Button(faicons('XMARK'), imgui.ImVec2(20 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE)) then
            save()
            window[0] = false
        end
		imgui.BeginChild('text', imgui.ImVec2(200 * MONET_DPI_SCALE, 240 * MONET_DPI_SCALE))
			render_main()
		imgui.EndChild()
		imgui.SameLine()
		if smi_menu == 'pro' then 
			imgui.BeginChild('text##123', imgui.ImVec2(-1, 233 * MONET_DPI_SCALE), true)
				if imgui.Button(u8'���', (imgui.ImVec2(40 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE))) then ppy = 'pro' end
				imgui.SameLine()
				if imgui.Button(u8'���', (imgui.ImVec2(40 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE))) then ppy = 'ppe' end
				imgui.SameLine()
				if imgui.Button(u8'�����', (imgui.ImVec2(60 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE))) then ppy = 'ystav' end
				imgui.Separator()
				if ppy == 'pro' then
					if imgui.Button(faicons('QUESTION') .. u8' ���������� ����� ���', (imgui.ImVec2(170 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE))) then
						sampSendChat('������������, �� ������ ����� ���?')
					end
					imgui.SameLine()
					if imgui.Button(faicons('USER_CHECK') .. u8' ���� �������', (imgui.ImVec2(130 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE))) then
						sampSendChat('/todo ����������, �� ����� ���!*� ������� �� ����')
					end
					imgui.SameLine()
					if imgui.Button(faicons('USER_XMARK') .. u8' �� ���� �������', (imgui.ImVec2(140 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE))) then
						lua_thread.create(function()
						sampSendChat('/todo � ��������� �� �� ����� ���.*� �������������� �� ����')
						wait(2000)
						sampSendChat('������� ��� �������� ��� � ������ �� ��������� ����� 10 �����.')
						end)
					end
					imgui.Text(u8'�������:')
					imgui.BeginChild('   ', imgui.ImVec2(-1, -1), true)
					for i, v in ipairs(pro_vopr_text) do
						if imgui.Selectable(v) then
							sampSendChat('"'..u8:decode(v)..'"')
						end
					end
					imgui.EndChild()
				end
				if ppy == 'ppe' then
					if imgui.Button(faicons('QUESTION') .. u8' ���������� ����� ���', (imgui.ImVec2(180 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE))) then
						sampSendChat('������������, �� ������ ����� ���?')
					end
					imgui.SameLine()
					if imgui.Button(faicons('USER_CHECK') .. u8' ���� �������', (imgui.ImVec2(130 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE))) then
						sampSendChat('/todo ����������, �� ����� ���!*� ������� �� ����')
					end
					imgui.SameLine()
					if imgui.Button(faicons('USER_XMARK') .. u8' �� ���� �������', (imgui.ImVec2(140 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE))) then
						lua_thread.create(function()
						sampSendChat('/todo � ��������� �� �� ����� ���.*� �������������� �� ����')
						wait(2000)
						sampSendChat('������� ��� �������� ��� � ������ �� ��������� ����� 10 �����.')
						end)
					end
					imgui.Text(u8'�������:')
					imgui.BeginChild('   ', imgui.ImVec2(-1, -1), true)
					for i, v in ipairs(ppe_vopr_text) do
						if imgui.Selectable(v) then
							sampSendChat('"'..u8:decode(v)..'"')
						end
					end
					imgui.EndChild()
				end
				if ppy == 'ystav' then
					if imgui.Button(faicons('QUESTION') .. u8' ���������� ����� �����', (imgui.ImVec2(180 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE))) then
						sampSendChat('������������, �� ������ ����� �����?')
					end
					imgui.SameLine()
					if imgui.Button(faicons('USER_CHECK') .. u8' ���� �������', (imgui.ImVec2(130 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE))) then
						sampSendChat('/todo ����������, �� ����� �����!*� ������� �� ����')
					end
					imgui.SameLine()
					if imgui.Button(faicons('USER_XMARK') .. u8' �� ���� �������', (imgui.ImVec2(140 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE))) then
						lua_thread.create(function()
						sampSendChat('/todo � ��������� �� �� ����� �����.*� �������������� �� ����')
						wait(2000)
						sampSendChat('������� ��� �������� ����� � ������ �� ��������� ����� 10 �����.')
						end)
					end
					imgui.Text(u8'�������:')
					imgui.BeginChild('   ', imgui.ImVec2(-1, -1), true)
					for i, v in ipairs(ystav_vopr_text) do
						if imgui.Selectable(v) then
							sampSendChat(u8:decode(v))
						end
					end
					imgui.EndChild()
				end
			imgui.EndChild()
		end
		if smi_menu == 'dopka' then 
			imgui.BeginChild('tt', imgui.ImVec2(-1, 233 * MONET_DPI_SCALE), true)
				if imgui.Button(u8'������', (imgui.ImVec2(100 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE))) then dop_f_t = 'binder' end
				imgui.SameLine()
				if imgui.Button(u8'������', (imgui.ImVec2(100 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE))) then dop_f_t = 'akcent' end
				imgui.SameLine()
				if imgui.Button(u8'�� ���������', (imgui.ImVec2(100 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE))) then dop_f_t = 'rp_play' end
				imgui.SameLine()
				if imgui.Button(u8'���', (imgui.ImVec2(50 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE))) then dop_f_t = 'chat' end
				imgui.Separator()
			if dop_f_t == 'binder' then
				imgui.BeginChild("", imgui.ImVec2(115 * MONET_DPI_SCALE, -1), true)
				for number = 1, 50, 1 do
					if mainIni.binder[number..'_cmd'] ~= nil and mainIni.binder[number..'_cmd'] ~= '' then 
						title_binder_test = '/'..mainIni.binder[number..'_cmd']
					else 
						title_binder_test = u8'���� �' .. number
					end
					if imgui.Selectable(title_binder_test) then
						for bind_n = 1, 50, 1 do
							if mainIni.binder[bind_n .. "_text"] == "" and bind_n ~= number then
								mainIni.binder[bind_n .. "_text"] = ""
								mainIni.binder[bind_n .. "_time"] = ""
								mainIni.binder[bind_n .. "_cmd"] = ""
							end
						end

						if mainIni.binder[number .. "_text"] == nil then
							mainIni.binder[number .. "_text"] = ""
							mainIni.binder[number .. "_time"] = 1
							mainIni.binder[number .. "_cmd"] = ""
						end

						inicfg.save(mainIni, 'smi.ini')

						imgui.StrCopy(bind_text, string.gsub(tostring(mainIni.binder[number .. "_text"]), "&", "\n"))
						imgui.StrCopy(bind_time, tostring(mainIni.binder[number .. "_time"]))
						imgui.StrCopy(cmd_text, tostring(mainIni.binder[number .. "_cmd"]))
						bnd[1] = 1

						ttax = number
					end
				end
				imgui.EndChild()
				imgui.SameLine()
				imgui.BeginChild("##��", imgui.ImVec2(-1, -1), true)
					if bnd[1] == 1 then
						imgui.Text(u8("������� �������: /"))
						imgui.SameLine()
						imgui.PushItemWidth(100 * MONET_DPI_SCALE)
						if imgui.InputText("", cmd_text, ffi.sizeof(cmd_text)) then
							mainIni.binder[ttax .. "_cmd"] = str(cmd_text)
							inicfg.save(mainIni,'smi.ini')
						end
						imgui.PopItemWidth()
						imgui.Text(u8("��������"))
						imgui.SameLine()
						imgui.PushItemWidth(70 * MONET_DPI_SCALE)
						if imgui.InputText(u8'������(�)',bind_time, ffi.sizeof(bind_time)) then
							mainIni.binder[ttax .. "_time"] = str(bind_time)
							inicfg.save(mainIni, 'smi.ini')
						end
						imgui.PopItemWidth()
						imgui.Text(u8("������� �����:"))
						if imgui.InputTextMultiline("	 ", bind_text, ffi.sizeof(bind_text),imgui.ImVec2(-1, -1)) then
							mainIni.binder[ttax .. "_text"] = string.gsub(str(bind_text), "\n", "&")
		
							inicfg.save(mainIni, 'smi.ini')
						end
					end
				imgui.EndChild()
			end
			if dop_f_t == 'akcent' then
				imgui.Text(u8"������")
				imgui.SameLine()
				if addons.ToggleButton("####acc##1", accent[1]) then
					mainIni.accent['accent'] = accent[1][0]
					inicfg.save(mainIni, 'smi.ini')
				end
				if imgui.InputText("", accent[2], ffi.sizeof(accent[2])) then
					mainIni.accent['text'] = str(accent[2])
					inicfg.save(mainIni,'smi.ini')
				end
			end
			if dop_f_t == 'rp_play' then
				imgui.Text(u8"/expel")
				imgui.SameLine(80 * MONET_DPI_SCALE)
				if addons.ToggleButton("####rp##1", expel_rp) then
					mainIni.rpbind['expel'] = expel_rp[0]
					inicfg.save(mainIni, 'smi.ini')
				end
				imgui.SameLine(150 * MONET_DPI_SCALE)
				imgui.Text(u8"/giverank")
				imgui.SameLine(225 * MONET_DPI_SCALE)
				if addons.ToggleButton("##rp##2", giverank_rp) then
					mainIni.rpbind['giverank'] = giverank_rp[0]
					inicfg.save(mainIni, 'smi.ini')
				end
				imgui.Text(u8"/fwarn")
				imgui.SameLine(80 * MONET_DPI_SCALE)
				if addons.ToggleButton("##rp##10", fwarn_rp) then
					mainIni.rpbind['fwarn'] = fwarn_rp[0]
					inicfg.save(mainIni, 'smi.ini')
				end
				imgui.SameLine(150 * MONET_DPI_SCALE)
				imgui.Text(u8"/unfwarn")
				imgui.SameLine(225 * MONET_DPI_SCALE)
				if addons.ToggleButton("##rp##4", unfwarn_rp) then
					mainIni.rpbind['unfwarn'] = unfwarn_rp[0]
					inicfg.save(mainIni, 'smi.ini')
				end
				imgui.Text(u8"/blacklist")
				imgui.SameLine(80 * MONET_DPI_SCALE)
				if addons.ToggleButton("##rp##blacklist", blacklist_rp) then
					mainIni.rpbind['blacklist'] = blacklist_rp[0]
					inicfg.save(mainIni, 'smi.ini')
				end
				imgui.SameLine(150 * MONET_DPI_SCALE)
				imgui.Text(u8"/unblacklist")
				imgui.SameLine(225 * MONET_DPI_SCALE)
				if addons.ToggleButton("##rp##3", unblacklist_rp) then
					mainIni.rpbind['unblacklist'] = unblacklist_rp[0]
					inicfg.save(mainIni, 'smi.ini')
				end
				imgui.Text(u8"/invite")
				imgui.SameLine(80 * MONET_DPI_SCALE)
				if addons.ToggleButton("##rp##6", invite_rp) then
					mainIni.rpbind['invite'] = invite_rp[0]
					inicfg.save(mainIni, 'smi.ini')
				end
				imgui.SameLine(150 * MONET_DPI_SCALE)
				imgui.Text(u8"/uninvite")
				imgui.SameLine(225 * MONET_DPI_SCALE)
				if addons.ToggleButton("##rp##5", uninvite_rp) then
					mainIni.rpbind['uninvite'] = uninvite_rp[0]
					inicfg.save(mainIni, 'smi.ini')
				end
				imgui.Text(u8"/fmute")
				imgui.SameLine(80 * MONET_DPI_SCALE)
				if addons.ToggleButton("##rp##7", fmute_rp) then
					mainIni.rpbind['fmute'] = fmute_rp[0]
					inicfg.save(mainIni, 'smi.ini')
				end
				imgui.SameLine(150 * MONET_DPI_SCALE)
				imgui.Text(u8"/funmute")
				imgui.SameLine(225 * MONET_DPI_SCALE)
				if addons.ToggleButton("##rp##8", funmute_rp) then
					mainIni.rpbind['funmute'] = funmute_rp[0]
					inicfg.save(mainIni, 'smi.ini')
				end
			end
			if dop_f_t == 'chat' then
				imgui.Text(u8'���������� ��������� � ���:')
				imgui.Text(u8"VIP ��� (/vr)")
				imgui.SameLine(120 * MONET_DPI_SCALE)
				if addons.ToggleButton("##chat##1", vr_c) then
					mainIni.chat['vr'] = vr_c[0]
					inicfg.save(mainIni, 'smi.ini')
				end
				imgui.Text(u8"������� ��� (/j)")
				imgui.SameLine(120 * MONET_DPI_SCALE)
				if addons.ToggleButton("##chat##2", job_c) then
					mainIni.chat['job'] = job_c[0]
					inicfg.save(mainIni, 'smi.ini')
				end
				imgui.Text(u8"����������")
				imgui.SameLine(120 * MONET_DPI_SCALE)
				if addons.ToggleButton("##chat##3", ad_c) then
					mainIni.chat['ad'] = ad_c[0]
					inicfg.save(mainIni, 'smi.ini')
				end
			end
			
			imgui.EndChild()
		end
		if smi_menu == 'default' then
			imgui.BeginChild('a', imgui.ImVec2(-1, 233 * MONET_DPI_SCALE), true)
				imgui.Text(u8"������������������ ����������")
				imgui.SameLine()
				if addons.ToggleButton("##Test##3", auto_edit) then
					mainIni.config['auto_edit'] = auto_edit[0]
					inicfg.save(mainIni, 'smi.ini')
				end
				imgui.SameLine()
				imgui.Ques('��� ��� ��������?\n����� �� ����������� ���������� ������ ���������� ���������� �\n��� �� ��� ���������������. ����� �� ����� ���������� ��\n�������������� ������ ���� � ���� ������ ��������������� �� ��\n�����-���� ��� ����������. ���� ������ ������� ���������� � ����\n������ �� ����� �������� ��� � ���� ��� ����� � ���������.')
				if imgui.Button(u8'��������', (imgui.ImVec2(200 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE))) then
					mainIni = inicfg.load({}, 'smi.ini')
					autoedit_slots[0] = not autoedit_slots[0]
				end
				imgui.Text(u8'���: '..mainIni.config['c_nick'])
				imgui.Text(u8'���������: '..mainIni.config['c_rang'])
				imgui.Text(u8'���: '..mainIni.config['c_city'] .. ' ['.. mainIni.config['c_cnn'] ..']')
			imgui.EndChild()
		end
		
		if smi_menu == 'sobes' then
			imgui.BeginChild('sobes', imgui.ImVec2(120 * MONET_DPI_SCALE, -1), true)
			imgui.Text(faicons('USER_TIMES') .. u8" ������")
			imgui.Separator()
			if imgui.Selectable(u8"��� ��������") then
				sobes_i = {
					false,
					false,
					false
				}
				lua_thread.create(function ()
					sampSendChat("/todo � ���������, �� ��� �� ���������.*� �������������� �� ����")
					wait(2000)
					sampSendChat("� ��� ��� ��������.")
					wait(2000)
					sampSendChat("/b �������� ������� � �����.")
				end)
			end
			if imgui.Selectable(u8"��� ���. �����") then
				sobes_i = {
					false,
					false,
					false
				}
				lua_thread.create(function ()
					sampSendChat("/todo � ���������, �� ��� �� ���������.*� �������������� �� ����")
					wait(2000)
					sampSendChat("� ��� ��� ���. �����.")
					wait(2000)
					sampSendChat("/b �������� ���. ����� � ��������.")
				end)
			end
			if imgui.Selectable(u8"������� � ���.") then
				sobes_i = {
					false,
					false,
					false
				}
				lua_thread.create(function ()
					sampSendChat("/todo � ���������, �� ��� �� ���������.*� �������������� �� ����")
					wait(2000)
					sampSendChat("�� ��� �������� � �����������.")
					wait(2000)
					sampSendChat("/b ��������� �� ����� �����������.")
				end)
			end
			if imgui.Selectable(u8"����� ���") then
				sobes_i = {
					false,
					false,
					false
				}
				lua_thread.create(function ()
					sampSendChat("/do ������� � ����� ������ � �����.")
					wait(2000)
					sampSendChat("/me ����� �������� � ���� ������")
					wait(2000)
					sampSendChat("/todo � ���������, �� ��� �� ���������.*� �������������� �� ����")
					wait(2000)
					sampSendChat("� ��� �������� ���, �������� ��� ��������.")
					wait(2000)
					sampSendChat("/b ������� ��� ����� ���.")
				end)
			end
			if imgui.Selectable(u8"��� ��") then
				sobes_i = {
					false,
					false,
					false
				}
				lua_thread.create(function ()
					sampSendChat("/do ������� � ����� ������ � �����.")
					wait(2000)
					sampSendChat("/me ����� �������� � ���� ������")
					wait(2000)
					sampSendChat("/todo � ���������, �� ��� �� ���������.*� �������������� �� ����")
					wait(2000)
					sampSendChat("�� ����. �� �������� ��� ����� ������.")
					wait(2000)
					sampSendChat("/b �� ����� �������� ��.")
				end)
			end
			imgui.EndChild()
			imgui.SameLine()
			imgui.BeginChild("sobes2", imgui.ImVec2(250 * MONET_DPI_SCALE, -1), true)
			imgui.Text(u8("������� id ������:"))
			imgui.SameLine()
			imgui.PushItemWidth(85 * MONET_DPI_SCALE)
			imgui.InputInt("                ##select id for sobes", select_id)
			selected_user = select_id[0]
			imgui.PopItemWidth()
			if imgui.Button(faicons("PLAY") .. u8" ������ �������������", imgui.ImVec2(-1, 25 * MONET_DPI_SCALE)) then
				if mainIni.config.c_nick ~= '' then
					sampSendChat("������������, ���� ����� " .. u8:decode(mainIni.config.c_nick) .. ". �� ������ �� �������������?")
				else
					lua_thread.create(function ()
						sampSendChat("������������, ���� ����� " .. mainIni.config.c_nicken .. ". �� ������ �� �������������?")
						wait(300)
						sampAddChatMessage("[SMI-plalkeo] {FFFFFF}�������� ������� ���� ������� �������. "..curcolor.."/smi {FFFFFF} - "..curcolor.." �������", curcolor1)
					end)
				end
			end
			if imgui.Button(faicons("QUESTION") .. u8" ��������� ���������", imgui.ImVec2(-1, 25 * MONET_DPI_SCALE)) then
				if select_id[0] > -1 and select_id[0] < 1000 and sampIsPlayerConnected(select_id[0]) then
					sobes_i = {
						true,
						true,
						true
					}
					lua_thread.create(function ()
						sampSendChat("�������, ����� �� ���� ������������? �������, ���. ����� � ��������.")
						wait(1000)
						sampSendChat("/b ����� �������� ������������ �������: /showpass " .. u_id .. ", /showmc " .. u_id .. ", /showlic " .. u_id)
						wait(2000)
						sampSendChat("/b �� ������ ���� �����������!")
					end)
				else
					sampAddChatMessage("[SMI-plalkeo] {FFFFFF}������� id ������.", curcolor1)
				end
			end
			if imgui.Button(faicons('QUESTION') .. u8" ���������� � ����", imgui.ImVec2(-1, 25 * MONET_DPI_SCALE)) then
				lua_thread.create(function ()
					sampSendChat("������, ������ � ����� ���� ��������.")
					wait(2000)
					sampSendChat("���������� � ����.")
				end)
			end
			if imgui.Button(faicons('QUESTION') .. u8" ������ ������ ��?", imgui.ImVec2(-1, 25 * MONET_DPI_SCALE)) then
				sampSendChat("������ �� ������� ������ ��� ����������?")
			end
			if imgui.Button(faicons("CHECK") .. u8" ������������� ��������", imgui.ImVec2(-1, 25 * MONET_DPI_SCALE)) then
				if select_id[0] > -1 and select_id[0] < 1000 and sampIsPlayerConnected(select_id[0]) then
					lua_thread.create(function ()
						sampSendChat("/todo ����������! �� ������ �������������!* � ������� �� ����")
						select_id[0] = -1
						sobes_i = {
							false,
							false,
							false
						}
		
						sobes_info = {
							pass = u8'�� ���������',
							mc = u8'�� ���������',
							lic = u8'�� ���������'
						}
						wait(2000)
						invite(select_id[0])
					end)
				else
					sampAddChatMessage("[SMI-plalkeo] {FFFFFF}������� id ������.", curcolor1)
				end
			end
			imgui.EndChild()
			imgui.SameLine()
			imgui.BeginChild("sobes3", imgui.ImVec2(-1, -1), true)
			if select_id[0] >= 0 and select_id[0] < 1000 then
				if sampIsPlayerConnected(select_id[0]) then
					imgui.Text(sampGetPlayerNickname(select_id[0]))
				else
					imgui.Text(u8'����� �� ������')
				end
			else
				imgui.Text(u8'����� �� ������')
			end
			imgui.Text(u8'�������: '..sobes_info['pass'])
			imgui.Text(u8'���. �����: '..sobes_info['mc'])
			imgui.Text(u8'��������: '..sobes_info['lic'])
			imgui.Separator()
			if imgui.Selectable(u8'�������� ����������') then
				select_id[0] = -1
				sobes_i = {
					false,
					false,
					false
				}

				sobes_info = {
					pass = u8'�� ���������',
					mc = u8'�� ���������',
					lic = u8'�� ���������'
				}
			end
			imgui.EndChild()
		end
		if smi_menu == 'efir' then --- IT'S NEW
			imgui.BeginChild('## EFIRS ##', imgui.ImVec2(-1, -1))
			imgui.BeginChild('a##Efir', imgui.ImVec2(-1, 205 * MONET_DPI_SCALE), true)
			if imgui.Button(u8'����������', (imgui.ImVec2(110 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE))) then smi_menu = 'math_efir' end
			imgui.SameLine()
			if imgui.Button(u8'�������', (imgui.ImVec2(90 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE))) then smi_menu = 'country_efir' end
			imgui.SameLine()
			if imgui.Button(u8'�������������', (imgui.ImVec2(130 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE))) then smi_menu = 'sobes_efir' end
			imgui.SameLine()
			if imgui.Button(u8'�������', (imgui.ImVec2(90 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE))) then smi_menu = 'reklama_efir' end
			imgui.SameLine()
			if imgui.Button(u8'��������', (imgui.ImVec2(100 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE))) then smi_menu = 'inter_efir' end
			if imgui.Button(u8'�����', (imgui.ImVec2(110 * MONET_DPI_SCALE, 30 * MONET_DPI_SCALE))) then smi_menu = 'himia_efir' end
			imgui.EndChild()
			imgui.BeginChild('##Efir_Settings', imgui.ImVec2(-1, 25 * MONET_DPI_SCALE))
			if imgui.Button(faicons("GEAR")..u8' ��������� ������', imgui.ImVec2(200 * MONET_DPI_SCALE, -1)) then smi_menu = 'settings_efir' end
			imgui.EndChild()
			imgui.EndChild()
		end

		if smi_menu == 'settings_efir' then 
			imgui.BeginChild('## EFIRS SETTINGS ##', imgui.ImVec2(-1, 233 * MONET_DPI_SCALE), true)
			imgui.Text(u8"���������� � ����� ������������ (/d)")
			imgui.SameLine()
			if addons.ToggleButton("##dEfirs##1", dep) then
				mainIni.efir['dep'] = dep[0]
				inicfg.save(mainIni, 'smi.ini')
			end
			imgui.SameLine()
			imgui.Ques('������ ��������� �������� �� ��, ����� �� ������ ��������� � /d � ������/���������� �����')
			imgui.SameLine(420 * MONET_DPI_SCALE)

			if imgui.Button(faicons('FLOPPY_DISK')..u8' ���������', imgui.ImVec2(150 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then 
				save()
			end

			imgui.Text(u8'��� ���������� - ')
			imgui.SameLine(160 * MONET_DPI_SCALE)
			imgui.PushItemWidth(130 * MONET_DPI_SCALE)
			imgui.InputText(u8'##math_tag', math_tag, ffi.sizeof(math_tag))
			imgui.PopItemWidth()

			imgui.Text(u8'��� ������ - ')
			imgui.SameLine(160 * MONET_DPI_SCALE)
			imgui.PushItemWidth(130 * MONET_DPI_SCALE)
			imgui.InputText(u8'##country_tag', country_tag, ffi.sizeof(country_tag))
			imgui.PopItemWidth()

			imgui.Text(u8'��� ������������ - ')
			imgui.SameLine(160 * MONET_DPI_SCALE)
			imgui.PushItemWidth(130 * MONET_DPI_SCALE)
			imgui.InputText(u8'##translate_tag', translate_tag, ffi.sizeof(translate_tag))
			imgui.PopItemWidth()

			imgui.Text(u8'��� ����� - ')
			imgui.SameLine(160 * MONET_DPI_SCALE)
			imgui.PushItemWidth(130 * MONET_DPI_SCALE)
			imgui.InputText(u8'##himia_tag', himia_tag, ffi.sizeof(himia_tag))
			imgui.PopItemWidth()

			imgui.Text(u8'��� �������� - ')
			imgui.SameLine(160 * MONET_DPI_SCALE)
			imgui.PushItemWidth(130 * MONET_DPI_SCALE)
			imgui.InputText(u8'##inter_tag', inter_tag, ffi.sizeof(inter_tag))
			imgui.PopItemWidth()

			imgui.Text(u8'��� ������������� - ')
			imgui.SameLine(160 * MONET_DPI_SCALE)
			imgui.PushItemWidth(130 * MONET_DPI_SCALE)
			imgui.InputText(u8'##sobes_tag', sobes_tag, ffi.sizeof(sobes_tag))
			imgui.PopItemWidth()

			imgui.Text(u8'��� ������� - ')
			imgui.SameLine(160 * MONET_DPI_SCALE)
			imgui.PushItemWidth(130 * MONET_DPI_SCALE)
			imgui.InputText(u8'##reklama_tag', reklama_tag, ffi.sizeof(reklama_tag))
			imgui.PopItemWidth()
			
			imgui.EndChild()
		end

		if smi_menu == 'math_efir' then 
			imgui.BeginChild('##EFIR MATH', imgui.ImVec2(340 * MONET_DPI_SCALE, -1))--, true)
			if imgui.Button(faicons('ARROW_LEFT') .. u8' �����', (imgui.ImVec2(100 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE))) then smi_menu = 'efir' end
			imgui.CenterTextColoredRGB('���� ����������')
			imgui.PushItemWidth(100 * MONET_DPI_SCALE)
			imgui.InputText(u8'�������� ����(��� $)', money_math, ffi.sizeof(money_math))
			imgui.PopItemWidth()
			if imgui.Button(u8'������ ����', (imgui.ImVec2(100 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE))) then
				if mainIni.config.c_nick ~= nil then
					lua_thread.create(function()
						sampSendChat('/todo ������..*������� ��������')
						wait(2000)
						if mainIni.efir['dep'] then sampSendChat('/d ['.. u8:decode(mainIni.config.c_cnn) ..'] - [���] ������� ��������� ����� 95.5 ��! ������� �� ����������') end
						wait(2000)
						sampSendChat('/news �������� ����������� �������� ������������ � ��� �. ' .. u8:decode(mainIni.config.c_city) ..' � ���������')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['math'])..' ������ ����, ��������� ��������������! � ���������..')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['math'])..' '.. u8:decode(mainIni.config.c_rang) .. ' ��� �. ' .. u8:decode(mainIni.config.c_city) ..' - ' .. u8:decode(mainIni.config.c_nick)  ..'!')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['math'])..' ������� � ������� ����������� "����������"..')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['math'])..' ..� ������� ������ - �� � ��� �� ������ ��� �����!')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['math'])..' ������� ������, � ���� �������..')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['math'])..' �������� ���� ���������� ����� ' .. str(money_math) ..'$!')
						wait(6000)
					end)
				else
					sampAddChatMessage("[SMI-plalkeo] {FFFFFF}� ��� �� ������ ���-����, ������� � "..curcolor.."/smi {FFFFFF}� � ���������� �������� ���!", curcolor1)
				end
			end
			imgui.SameLine()
			if imgui.Button(u8'��������� ����', (imgui.ImVec2(120 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE))) then
				if mainIni.config.c_nick ~= nil then
					lua_thread.create(function()
						sampSendChat('/news '..u8:decode(mainIni.tags['math'])..' �� ���� ��� ���� �������� � �����.')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['math'])..' � ���� ��� '.. u8:decode(mainIni.config.c_rang) .. ' ��� �. ' .. u8:decode(mainIni.config.c_city) ..' - ' .. u8:decode(mainIni.config.c_nick)  ..'!')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['math'])..' �� ��������, ����. ����������� �� ����� 95.5 ��!')
						wait(6000)
						sampSendChat('/news �������� ����������� �������� ������������ � ��� �. ' .. u8:decode(mainIni.config.c_city) ..' � ���������')
						wait(2000)
						if mainIni.efir['dep'] then sampSendChat('/d ['.. u8:decode(mainIni.config.c_cnn) ..'] - [���] ��������� ��������� ����� 95.5 ��!') end
						wait(2000)
						sampSendChat('/todo ��� � ��..*�������� ��������')
					end)
				else
					sampAddChatMessage("[SMI-plalkeo] {FFFFFF}� ��� �� ������ ���-����, ������� � "..curcolor.."/smi {FFFFFF}� � ���������� �������� ���!", curcolor1)
				end
			end
			imgui.PushItemWidth(100 * MONET_DPI_SCALE)
			imgui.InputText(u8'##������', primer, ffi.sizeof(primer))
			imgui.PopItemWidth()
			imgui.SameLine()
			if imgui.Button(u8'������� ������', (imgui.ImVec2(115 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE))) then
				lua_thread.create(function()
					sampSendChat('/news '..u8:decode(mainIni.tags['math'])..' ��������� ������..')
					wait(6020)
					sampSendChat('/news '..u8:decode(mainIni.tags['math'])..' '.. u8:decode(str(primer)))
				end)
			end
			imgui.SameLine()
			if imgui.Button(u8'������� ����', (imgui.ImVec2(100 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE))) then
				sampSendChat('/news '..u8:decode(mainIni.tags['math'])..' ����!')
			end
			imgui.Text("ID: ")
			imgui.SameLine()
			imgui.PushItemWidth(40 * MONET_DPI_SCALE)
			imgui.InputText(u8'##������� id', chel_ball_c, ffi.sizeof(chel_ball_c))
			imgui.PopItemWidth()
			if str(chel_ball_c) ~= "" then
				u_name = sampGetPlayerNickname(str(chel_ball_c))
				u_name = u_name:gsub("_"," ")
			end
			imgui.SameLine()
			if imgui.Button(u8'�������� ����', (imgui.ImVec2(110 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE))) then
				addball(u_name)
				if tostring(efir_counter[u_name]) == '1' then
					sampSendChat('/news '..u8:decode(mainIni.tags['math'])..' ������ ��� '.. u8:decode(u_name) .. ' � � ���� '.. efir_counter[u_name] .. ' ����!')
				end
				if tostring(efir_counter[u_name]) == '2' then
					sampSendChat('/news '..u8:decode(mainIni.tags['math'])..' ������ ��� '.. u8:decode(u_name) .. ' � � ���� '.. efir_counter[u_name] .. ' �����!')
				end
				if tostring(efir_counter[u_name]) == '3' then 
					lua_thread.create(function()
						efir_counter = {}
						sampSendChat('/news '..u8:decode(mainIni.tags['math'])..' � � ��� ���� ����������!')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['math'])..' ��������� ' .. u8:decode(u_name).. ' �� ������ ������ 3 ����� � �������� ����!')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['math'])..' ������ ���������� ������ � ���� ��� �.'..u8:decode(mainIni.config.c_city)..' ��� ��������� �����.')
						addWithTag("�� �������� ��������� ����.")
					end)
				end
			end
			if imgui.Button(u8'����������', (imgui.ImVec2(100 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE))) then
				lua_thread.create(function()
					efir_counter = {}
					sampSendChat('/news '..u8:decode(mainIni.tags['math'])..' � � ��� ���� ����������!')
					wait(6000)
					sampSendChat('/news '..u8:decode(mainIni.tags['math'])..' ��������� ' .. u8:decode(u_name).. ' �� ������ ������ 3 ����� � �������� ����!')
					wait(6000)
					sampSendChat('/news '..u8:decode(mainIni.tags['math'])..' ������ ���������� ������ � ���� ��� �.'..u8:decode(mainIni.config.c_city)..' ��� ��������� �����.')
					addWithTag("�� �������� ��������� ����.")
				end)
			end
			imgui.EndChild()
			imgui.SameLine()
			imgui.BeginChild('a##Math1', imgui.ImVec2(-1, -1), false)
			imgui.CenterTextColoredRGB("�����")
			imgui.Separator()
			lua_thread.create(function()
				for i in pairs(efir_counter) do
					imgui.Text(i..' = '..efir_counter[i])
				end
			end)
			imgui.EndChild()
		end
		if smi_menu == 'country_efir' then 
			imgui.BeginChild('##EFIR COUNTRY', imgui.ImVec2(340 * MONET_DPI_SCALE, -1))--, true)
			if imgui.Button(faicons('ARROW_LEFT') .. u8' �����', (imgui.ImVec2(100 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE))) then smi_menu = 'efir' end
			imgui.CenterTextColoredRGB('���� �������')
			imgui.PushItemWidth(100 * MONET_DPI_SCALE)
			imgui.InputText(u8'�������� ����(��� $)', money_math, ffi.sizeof(money_math))
			imgui.PopItemWidth()
			if imgui.Button(u8'������ ����', (imgui.ImVec2(100 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE))) then
				if mainIni.config.c_nick ~= nil then
					lua_thread.create(function()
						sampSendChat('/todo ������..*������� ��������')
						wait(2000)
						if mainIni.efir['dep'] then sampSendChat('/d ['.. u8:decode(mainIni.config.c_cnn) ..'] - [���] ������� ��������� ����� 95.5 ��! ������� �� ����������') end
						wait(2000)
						sampSendChat('/news �������� ����������� �������� ������������ � ��� �. ' .. u8:decode(mainIni.config.c_city) ..' � ���������')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['country'])..' ������ ����, ��������� ��������������! � ���������..')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['country'])..' '.. u8:decode(mainIni.config.c_rang) .. ' ��� �. ' .. u8:decode(mainIni.config.c_city) ..' - ' .. u8:decode(mainIni.config.c_nick)  ..'!')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['country'])..' ������� � ������� ����������� "�������"..')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['country'])..' ..� ������� ������ - �� � ��� �� ������ � �������!')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['country'])..' ������� ������, � ���� �������..')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['country'])..' �������� ���� ���������� ����� ' .. str(money_math) ..'$!')
						wait(6000)
					end)
				else
					sampAddChatMessage("[SMI-plalkeo] {FFFFFF}� ��� �� ������ ���-����, ������� � "..curcolor.."/smi {FFFFFF}� � ���������� �������� ���!", curcolor1)
				end
			end
			imgui.SameLine()
			if imgui.Button(u8'��������� ����', (imgui.ImVec2(120 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE))) then
				if mainIni.config.c_nick ~= nil then
					lua_thread.create(function()
						sampSendChat('/news '..u8:decode(mainIni.tags['country'])..' �� ���� ��� ���� �������� � �����.')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['country'])..' � ���� ��� '.. u8:decode(mainIni.config.c_rang) .. ' ��� �. ' .. u8:decode(mainIni.config.c_city) ..' - ' .. u8:decode(mainIni.config.c_nick)  ..'!')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['country'])..' �� ��������, ����. ����������� �� ����� 95.5 ��!')
						wait(6000)
						sampSendChat('/news �������� ����������� �������� ������������ � ��� �. ' .. u8:decode(mainIni.config.c_city) ..' � ���������')
						wait(2000)
						if mainIni.efir['dep'] then sampSendChat('/d ['.. u8:decode(mainIni.config.c_cnn) ..'] - [���] ��������� ��������� ����� 95.5 ��!') end
						wait(2000)
						sampSendChat('/todo ��� � ��..*�������� ��������')
					end)
				else
					sampAddChatMessage("[SMI-plalkeo] {FFFFFF}� ��� �� ������ ���-����, ������� � "..curcolor.."/smi {FFFFFF}� � ���������� �������� ���!", curcolor1)
				end
			end
			imgui.PushItemWidth(100 * MONET_DPI_SCALE)
			imgui.InputText(u8'##������', primer, ffi.sizeof(primer))
			imgui.PopItemWidth()
			imgui.SameLine()
			if imgui.Button(u8'������� ������', (imgui.ImVec2(115 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE))) then
				lua_thread.create(function()
					sampSendChat('/news '..u8:decode(mainIni.tags['country'])..' ��������� ������..')
					wait(6020)
					sampSendChat('/news '..u8:decode(mainIni.tags['country'])..' '.. u8:decode(str(primer)))
				end)
			end
			imgui.SameLine()
			if imgui.Button(u8'������� ����', (imgui.ImVec2(100 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE))) then
				sampSendChat('/news '..u8:decode(mainIni.tags['country'])..' ����!')
			end
			imgui.Text("ID: ")
			imgui.SameLine()
			imgui.PushItemWidth(40 * MONET_DPI_SCALE)
			imgui.InputText(u8'##������� id', chel_ball_c, ffi.sizeof(chel_ball_c))
			imgui.PopItemWidth()
			if str(chel_ball_c) ~= "" then
				u_name = sampGetPlayerNickname(str(chel_ball_c))
				u_name = u_name:gsub("_"," ")
			end
			imgui.SameLine()
			if imgui.Button(u8'�������� ����', (imgui.ImVec2(110 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE))) then
				addball(u_name)
				if tostring(efir_counter[u_name]) == '1' then
					sampSendChat('/news '..u8:decode(mainIni.tags['country'])..' ������ ��� '.. u8:decode(u_name) .. ' � � ���� '.. efir_counter[u_name] .. ' ����!')
				end
				if tostring(efir_counter[u_name]) == '2' then
					sampSendChat('/news '..u8:decode(mainIni.tags['country'])..' ������ ��� '.. u8:decode(u_name) .. ' � � ���� '.. efir_counter[u_name] .. ' �����!')
				end
				if tostring(efir_counter[u_name]) == '3' then 
					lua_thread.create(function()
						efir_counter = {}
						sampSendChat('/news '..u8:decode(mainIni.tags['country'])..' � � ��� ���� ����������!')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['country'])..' ��������� ' .. u8:decode(u_name).. ' �� ������ ������ 3 ����� � �������� ����!')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['country'])..' ������ ���������� ������ � ���� ��� �.'..u8:decode(mainIni.config.c_city)..' ��� ��������� �����.')
						addWithTag("�� �������� ��������� ����.")
					end)
				end
			end
			if imgui.Button(u8'����������', (imgui.ImVec2(100 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE))) then
				lua_thread.create(function()
					efir_counter = {}
					sampSendChat('/news '..u8:decode(mainIni.tags['country'])..' � � ��� ���� ����������!')
					wait(6000)
					sampSendChat('/news '..u8:decode(mainIni.tags['country'])..' ��������� ' .. u8:decode(u_name).. ' �� ������ ������ 3 ����� � �������� ����!')
					wait(6000)
					sampSendChat('/news '..u8:decode(mainIni.tags['country'])..' ������ ���������� ������ � ���� ��� �.'..u8:decode(mainIni.config.c_city)..' ��� ��������� �����.')
					addWithTag("�� �������� ��������� ����.")
				end)
			end
			imgui.EndChild()
			imgui.SameLine()
			imgui.BeginChild('a##country1', imgui.ImVec2(-1, -1), false)
			imgui.CenterTextColoredRGB("�����")
			imgui.Separator()
			lua_thread.create(function()
				for i in pairs(efir_counter) do
					imgui.Text(i..' = '..efir_counter[i])
				end
			end)
			imgui.EndChild()
		end
		if smi_menu == 'sobes_efir' then
			imgui.BeginChild('##EFIR SOBES', imgui.ImVec2(-1, -1), true)
			if imgui.Button(faicons('ARROW_LEFT') .. u8' �����', (imgui.ImVec2(100 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE))) then smi_menu = 'efir' end
			imgui.Text(u8'���� �������������')
			if imgui.Button(u8'������ ����', (imgui.ImVec2(200 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE))) then
				if mainIni.config.c_nick ~= nil then
					lua_thread.create(function()
						sampSendChat('/todo ������..*������� ��������')
						wait(2000)
						if mainIni.efir['dep'] then sampSendChat('/d ['.. u8:decode(mainIni.config.c_cnn) ..'] - [���] ������� ��������� ����� 95.5 ��! ������� �� ����������') end
						wait(2000)
						sampSendChat('/news �������� ����������� �������� ������������ � ��� �. ' .. u8:decode(mainIni.config.c_city) ..' � ���������')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['sobes'])..' ������ ����� �����, ��������� ��������������!')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['sobes'])..' � ���� '.. u8:decode(mainIni.config.c_rang) .. ' ��� �. ' .. u8:decode(mainIni.config.c_city) ..' - ' .. u8:decode(mainIni.config.c_nick)  ..'!')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['sobes'])..' �� ���������� �� ����� 95.5 ��.')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['sobes'])..' �������� �� ����� ������ ����������� ���� � ���� ��������?')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['sobes'])..' ������������ �� 1.000.000$ � ����?')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['sobes'])..' ����� ���������� � ���������� ��������� � �����?')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['sobes'])..' ������ ������, � ��� ���� ����� �����������, ���� ����� ������...')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['sobes'])..' ...�������� ������������� � ��� �. ' .. u8:decode(mainIni.config.c_city))
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['sobes'])..' ��� ���������� ������ �� ����, ��� ���� � �����')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['sobes'])..' ������������� �������� � ����� ������ �����������.')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['sobes'])..' ����� ������ ������������� ��� ����� ����� ��� ����...')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['sobes'])..' ...�������, ���. �����, � ���� ��������������� �����������.')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['sobes'])..' ���-�� �� ������������ ������� ����� ������� ������...')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['sobes'])..' ...�� ��������� "��������".')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['sobes'])..' �� ������� ���� ���� ����������, � ����� ���������� ���������!')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['sobes'])..' �� ���� ��� ���� �������� � �����.')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['sobes'])..' � ���� ��� '.. u8:decode(mainIni.config.c_rang) .. ' ��� �. ' .. u8:decode(mainIni.config.c_city) ..' - ' .. u8:decode(mainIni.config.c_nick)  ..'.')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['sobes'])..' �� ��������, ����. ����������� �� ����� 95.5 ��.')
						wait(6000)
						sampSendChat('/news �������� ����������� �������� ������������ � ��� �. ' .. u8:decode(mainIni.config.c_city) ..' � ���������')
						wait(2000)
						if mainIni.efir['dep'] then sampSendChat('/d ['.. u8:decode(mainIni.config.c_cnn) ..'] - [���] ��������� ��������� ����� 95.5 ��.') end
						wait(2000)
						sampSendChat('/todo �� ���� ��..*�������� ��������')
					end)
				else
					sampAddChatMessage("[SMI-plalkeo] {FFFFFF}� ��� �� ������ ���-����, ������� � "..curcolor.."/smi {FFFFFF}� � ���������� �������� ���!", curcolor1)
				end
			end
			imgui.EndChild()
		end
		if smi_menu == 'reklama_efir' then 
			imgui.BeginChild('##EFIR REKLAMA', imgui.ImVec2(-1, -1))
			if imgui.Button(faicons('ARROW_LEFT') .. u8' �����', (imgui.ImVec2(100 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE))) then smi_menu = 'efir' end
			imgui.StrCopy(rektext, string.gsub(tostring(mainIni.efir['reklama_text']), "&", "\n"))
			imgui.Text(u8'���� �������')
			imgui.SameLine()
			if imgui.Button(u8'������ ����', (imgui.ImVec2(200 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE))) then
				lua_thread.create(function ()
					sampSendChat('/todo ������..*������� ��������')
					wait(2000)
					if mainIni.efir['dep'] then sampSendChat('/d ['.. u8:decode(mainIni.config.c_cnn) ..'] - [���] ������� ��������� ����� 95.5 ��! ������� �� ����������') end
					wait(2000)
					sampSendChat('/news �������� ����������� �������� ������������ � ��� �. ' .. u8:decode(mainIni.config.c_city) ..' � ���������')
					wait(6000)
					sampSendChat('/news '..u8:decode(mainIni.tags['reklama'])..' ������ ����� �����, ��������� ��������������!')
					wait(6000)
					sampSendChat('/news '..u8:decode(mainIni.tags['reklama'])..' � ���� '.. u8:decode(mainIni.config.c_rang) .. ' ��� �. ' .. u8:decode(mainIni.config.c_city) ..' - ' .. u8:decode(mainIni.config.c_nick)  ..'!')
					wait(6000)
					sampSendChat('/news '..u8:decode(mainIni.tags['reklama'])..' �� ���������� �� ����� 95.5 ��.')
					wait(6000)
					sampSendChat('/news '..u8:decode(mainIni.tags['reklama'])..' '..u8:decode(string.match(mainIni.efir['reklama_text'], "([^&]+)")))
					for ttext in string.gmatch(mainIni.efir['reklama_text'], "&([^&]+)") do
						wait(tonumber(6 * 1000))
						sampSendChat('/news '..u8:decode(mainIni.tags['reklama'])..' '..u8:decode(ttext))
					end
					wait(6000)
					sampSendChat('/news '..u8:decode(mainIni.tags['reklama'])..' �� ���� ��� ���� �������� � �����.')
					wait(6000)
					sampSendChat('/news '..u8:decode(mainIni.tags['reklama'])..' � ���� ��� '.. u8:decode(mainIni.config.c_rang) .. ' ��� �. ' .. u8:decode(mainIni.config.c_city) ..' - ' .. u8:decode(mainIni.config.c_nick)  ..'.')
					wait(6000)
					sampSendChat('/news '..u8:decode(mainIni.tags['reklama'])..' �� ��������, ����. ����������� �� ����� 95.5 ��.')
					wait(6000)
					sampSendChat('/news �������� ����������� �������� ������������ � ��� �. ' .. u8:decode(mainIni.config.c_city) ..' � ���������')
					wait(2000)
					if mainIni.efir['dep'] then sampSendChat('/d ['.. u8:decode(mainIni.config.c_cnn) ..'] - [���] ��������� ��������� ����� 95.5 ��.') end
					wait(2000)
					sampSendChat('/todo �� ���� ��..*�������� ��������')
				end)
			end
			imgui.SameLine()
			imgui.Ques("��� ��������� ��������� �������?\n1. ���������� ������ ������ ����� ������� ����������� (��� �����, ����������� � ��.)\n2. /d, ����, ����������� �������� ���� �� ����")
			if imgui.InputTextMultiline("	 ", rektext, ffi.sizeof(rektext), imgui.ImVec2(500 * MONET_DPI_SCALE, -1)) then
				mainIni.efir['reklama_text'] = string.gsub(rektext[0], "\n", "&")
				inicfg.save(mainIni, 'smi.ini')
			end
		end
		if smi_menu == 'inter_efir' then 
			imgui.BeginChild('##EFIR INTER', imgui.ImVec2(-1, -1))
			if imgui.Button(faicons('ARROW_LEFT') .. u8' �����', (imgui.ImVec2(100 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE))) then smi_menu = 'efir' end
			imgui.Text(u8'��������')
			if imgui.Button(u8'������ ����', (imgui.ImVec2(100 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE))) then
				lua_thread.create(function ()
					sampSendChat('/todo ������..*������� ��������')
					wait(2000)
					sampSendChat('/d ['.. u8:decode(mainIni.config.c_cnn) ..'] - [���] ������� ��������� ����� 95.5 ��! ������� �� ����������')
					wait(2000)
					sampSendChat('/news �������� ����������� �������� ������������ � ��� �. ' .. u8:decode(mainIni.config.c_city) ..' � ��������')
					wait(6000)
					sampSendChat('/news '..u8:decode(mainIni.tags['inter'])..' ������ ����, ��������� ��������������! � ���������..')
					wait(6000)
					sampSendChat('/news '..u8:decode(mainIni.tags['inter'])..' '.. u8:decode(mainIni.config.c_rang) .. ' ��� �. ' .. u8:decode(mainIni.config.c_city) ..' - ' .. u8:decode(mainIni.config.c_nick)  ..'!')
					wait(6000)
					sampSendChat('/news '..u8:decode(mainIni.tags['inter'])..' �� ���������� �� ����� 95.5 ��...')
					wait(6000)
					sampSendChat('/news '..u8:decode(mainIni.tags['inter'])..' � ������ � ������� ��������.')
				end)
			end
			imgui.SameLine()
			if imgui.Button(u8'��������� ����', (imgui.ImVec2(120 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE))) then
				lua_thread.create(function ()
					sampSendChat('/news '..u8:decode(mainIni.tags['inter'])..' �� ���� ���� �������� �������� � �����.')
					wait(6000)
					sampSendChat('/news '..u8:decode(mainIni.tags['inter'])..' � ���� ��� '.. u8:decode(mainIni.config.c_rang) .. ' ��� �. ' .. u8:decode(mainIni.config.c_city) ..' - ' .. u8:decode(mainIni.config.c_nick)  ..'!')
					wait(6000)
					sampSendChat('/news '..u8:decode(mainIni.tags['inter'])..' �� ��������, ����. ����������� �� ����� 95.5 ��!')
					wait(6000)
					sampSendChat('/news �������� ����������� �������� ������������ � ��� �. ' .. u8:decode(mainIni.config.c_city) ..' � ��������')
					wait(2000)
					sampSendChat('/d ['.. u8:decode(mainIni.config.c_cnn) ..'] - [���] ��������� ��������� ����� 95.5 ��!')
					wait(2000)
					sampSendChat('/todo ��� � ��..*�������� ��������')
				end)
			end
			imgui.SameLine()
			if imgui.Button(u8'������� �� �����') then
				lua_thread.create(function ()
					sampSendChat('������ ������ ����� ����� ������ ���� �������..')
					wait(2000)
					sampSendChat('����������� ���� ������� �� ��� ����������!')
				end)
			end
			imgui.PushItemWidth(180 * MONET_DPI_SCALE)
			imgui.InputText(u8'��� � �������', interv['name'], ffi.sizeof(interv['name']))
			imgui.SameLine()
			imgui.InputText(u8'���������', interv['rang'], ffi.sizeof(interv['rang']))
			if imgui.Button(u8'�������', (imgui.ImVec2(60 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE))) then
				lua_thread.create(function ()
					sampSendChat('������������ ������� ������ �����!')
					wait(2000)
					if str(interv['rang']) == '' then
						sampSendChat('������� � ��� � ������ '.. u8:decode(str(interv['name'])))
					else
						sampSendChat('������� � ��� � ������ '.. u8:decode(str(interv['rang'])) ..' - '.. u8:decode(interv['name'][0]))
					end
					wait(2000)
					sampSendChat('� ������ � ����� ��� ��������� ��������.')
				end)
			end
			imgui.PopItemWidth()
			imgui.BeginChild('   ', imgui.ImVec2(-1, -1), true)
				for i, v in ipairs(interv_quest) do
					if imgui.Selectable(v) then
						sampSendChat(u8:decode(v))
					end
				end
			imgui.EndChild()
			imgui.EndChild()
		end
		if smi_menu == 'himia_efir' then 
			imgui.BeginChild('##EFIR HIMIA', imgui.ImVec2(340 * MONET_DPI_SCALE, -1))
			if imgui.Button(faicons('ARROW_LEFT') .. u8' �����', (imgui.ImVec2(100 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE))) then smi_menu = 'efir' end
			imgui.CenterTextColoredRGB('���� �����')
			imgui.PushItemWidth(100 * MONET_DPI_SCALE)
			imgui.InputText(u8'�������� ����(��� $)', money_math, ffi.sizeof(money_math))
			imgui.PopItemWidth()
			if imgui.Button(u8'������ ����', (imgui.ImVec2(100 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE))) then
				if mainIni.config.c_nick ~= nil then
					lua_thread.create(function()
						sampSendChat('/todo ������..*������� ��������')
						wait(2000)
						if mainIni.efir['dep'] then sampSendChat('/d ['.. u8:decode(mainIni.config.c_cnn) ..'] - [���] ������� ��������� ����� 95.5 ��! ������� �� ����������') end
						wait(2000)
						sampSendChat('/news �������� ����������� �������� ������������ � ��� �. ' .. u8:decode(mainIni.config.c_city) ..' � ���������')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['himia'])..' ������ ����, ��������� ��������������! � ���������..')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['himia'])..' '.. u8:decode(mainIni.config.c_rang) .. ' ��� �. ' .. u8:decode(mainIni.config.c_city) ..' - ' .. u8:decode(mainIni.config.c_nick)  ..'!')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['himia'])..' ������� � ������� ����������� "�����"..')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['himia'])..' ..� ������� ������� - �� � ��� �� ������ ��� ��������!')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['himia'])..' ������� ������, � ���� �������..')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['himia'])..' �������� ���� ���������� ����� ' .. str(money_math) ..'$!')
						wait(6000)
					end)
				else
					sampAddChatMessage("[SMI-plalkeo] {FFFFFF}� ��� �� ������ ���-����, ������� � "..curcolor.."/smi {FFFFFF}� � ���������� �������� ���!", curcolor1)
				end
			end
			imgui.SameLine()
			if imgui.Button(u8'��������� ����', (imgui.ImVec2(120 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE))) then
				if mainIni.config.c_nick ~= nil then
					lua_thread.create(function()
						sampSendChat('/news '..u8:decode(mainIni.tags['himia'])..' �� ���� ��� ���� �������� � �����.')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['himia'])..' � ���� ��� '.. u8:decode(mainIni.config.c_rang) .. ' ��� �. ' .. u8:decode(mainIni.config.c_city) ..' - ' .. u8:decode(mainIni.config.c_nick)  ..'!')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['himia'])..' �� ��������, ����. ����������� �� ����� 95.5 ��!')
						wait(6000)
						sampSendChat('/news �������� ����������� �������� ������������ � ��� �. ' .. u8:decode(mainIni.config.c_city) ..' � ���������')
						wait(2000)
						if mainIni.efir['dep'] then sampSendChat('/d ['.. u8:decode(mainIni.config.c_cnn) ..'] - [���] ��������� ��������� ����� 95.5 ��!') end
						wait(2000)
						sampSendChat('/todo ��� � ��..*�������� ��������')
					end)
				else
					sampAddChatMessage("[SMI-plalkeo] {FFFFFF}� ��� �� ������ ���-����, ������� � "..curcolor.."/smi {FFFFFF}� � ���������� �������� ���!", curcolor1)
				end
			end
			imgui.PushItemWidth(100 * MONET_DPI_SCALE)
			imgui.InputText(u8'##�������', primer, ffi.sizeof(primer))
			imgui.PopItemWidth()
			imgui.SameLine()
			if imgui.Button(u8'������� �������', (imgui.ImVec2(115 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE))) then
				lua_thread.create(function()
					sampSendChat('/news '..u8:decode(mainIni.tags['himia'])..' ��������� �������..')
					wait(6020)
					sampSendChat('/news '..u8:decode(mainIni.tags['himia'])..' '.. u8:decode(str(primer)))
				end)
			end
			imgui.SameLine()
			if imgui.Button(u8'������� ����', (imgui.ImVec2(100 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE))) then
				sampSendChat('/news '..u8:decode(mainIni.tags['himia'])..' ����!')
			end
			imgui.Text("ID: ")
			imgui.SameLine()
			imgui.PushItemWidth(40 * MONET_DPI_SCALE)
			imgui.InputText(u8'##������� id', chel_ball_c, ffi.sizeof(chel_ball_c))
			imgui.PopItemWidth()
			if str(chel_ball_c) ~= "" then
				u_name = sampGetPlayerNickname(str(chel_ball_c))
				u_name = u_name:gsub("_"," ")
			end
			imgui.SameLine()
			if imgui.Button(u8'�������� ����', (imgui.ImVec2(110 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE))) then
				addball(u_name)
				if tostring(efir_counter[u_name]) == '1' then
					sampSendChat('/news '..u8:decode(mainIni.tags['himia'])..' ������ ��� '.. u8:decode(u_name) .. ' � � ���� '.. efir_counter[u_name] .. ' ����!')
				end
				if tostring(efir_counter[u_name]) == '2' then
					sampSendChat('/news '..u8:decode(mainIni.tags['himia'])..' ������ ��� '.. u8:decode(u_name) .. ' � � ���� '.. efir_counter[u_name] .. ' �����!')
				end
				if tostring(efir_counter[u_name]) == '3' then 
					lua_thread.create(function()
						efir_counter = {}
						sampSendChat('/news '..u8:decode(mainIni.tags['himia'])..' � � ��� ���� ����������!')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['himia'])..' ��������� ' .. u8:decode(u_name).. ' �� ������ ������ 3 ����� � �������� ����!')
						wait(6000)
						sampSendChat('/news '..u8:decode(mainIni.tags['himia'])..' ������ ���������� ������ � ���� ��� �.'..u8:decode(mainIni.config.c_city)..' ��� ��������� �����.')
						addWithTag("�� �������� ��������� ����.")
					end)
				end
			end
			if imgui.Button(u8'����������', (imgui.ImVec2(100 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE))) then
				lua_thread.create(function()
					efir_counter = {}
					sampSendChat('/news '..u8:decode(mainIni.tags['himia'])..' � � ��� ���� ����������!')
					wait(6000)
					sampSendChat('/news '..u8:decode(mainIni.tags['himia'])..' ��������� ' .. u8:decode(u_name).. ' �� ������ ������ 3 ����� � �������� ����!')
					wait(6000)
					sampSendChat('/news '..u8:decode(mainIni.tags['himia'])..' ������ ���������� ������ � ���� ��� �.'..u8:decode(mainIni.config.c_city)..' ��� ��������� �����.')
					addWithTag("�� �������� ��������� ����.")
				end)
			end
			imgui.EndChild()
			imgui.SameLine()
			imgui.BeginChild('a##country1', imgui.ImVec2(-1, -1), false)
			imgui.CenterTextColoredRGB("�����")
			imgui.Separator()
			lua_thread.create(function()
				for i in pairs(efir_counter) do
					imgui.Text(i..' = '..efir_counter[i])
				end
			end)
			imgui.EndChild()
		end

		if smi_menu == 'settings' then
			imgui.BeginChild('settings', imgui.ImVec2(-1, 233 * MONET_DPI_SCALE), true)
			imgui.Text(u8"������� ���:")
			imgui.SameLine(100 * MONET_DPI_SCALE)
			imgui.PushItemWidth(150 * MONET_DPI_SCALE)
			if imgui.InputText(u8'##������� ���', nick, ffi.sizeof(nick)) then
				mainIni.config['c_nick'] = str(nick)
				inicfg.save(mainIni,'smi.ini')
			end
			imgui.PopItemWidth()
			imgui.Text(u8'����: ')
			imgui.SameLine()
			if imgui.Combo(u8'##theme', selected_theme, items, #theme_a) then
				themeta = theme_t[selected_theme[0]+1]
				mainIni.theme['theme'] = themeta
				mainIni.theme['selected'] = selected_theme[0]
				inicfg.save(mainIni, 'smi.ini')
				apply_n_t()
			end
			if not isMonetLoader() then
				imgui.Text(u8'���� MoonMonet  -')
				imgui.SameLine()
				if imgui.ColorEdit3('## COLOR', mmcolor, imgui.ColorEditFlags.NoInputs) then
					local r,g,b = mmcolor[0] * 255, mmcolor[1] * 255, mmcolor[2] * 255
					local argb = join_argb(0, r, g, b)
					mainIni.theme.moonmonet = argb
					apply_n_t()
					inicfg.save(mainIni, 'smi.ini')
				end
				imgui.Text(u8'\n���� ��������������:')
				imgui.SetCursorPosY(imgui.GetCursorPosY() + 2)
				imgui.Text(u8'��� +')
				imgui.SameLine(nil, 5)
				imgui.SetCursorPosY(imgui.GetCursorPosY() - 4)
				imgui.HotKey('���� �������� �������', mainIni.settings, 'bind', 'R', string.find(mainIni.settings.bind, '+') and 150 * MONET_DPI_SCALE or 75 * MONET_DPI_SCALE)
				if imgui.Button(u8'�������� ����', imgui.ImVec2(150 * MONET_DPI_SCALE, 25 * MONET_DPI_SCALE)) then
					mainIni.settings.bind = 'R'
					inicfg.save(mainIni, 'smi.ini')
				end
			end
			imgui.EndChild()
		end
		if smi_menu == 'changelog' then 
			imgui.BeginChild('changelog', imgui.ImVec2(580 * MONET_DPI_SCALE, 233 * MONET_DPI_SCALE), true)
			imgui.Text(changelogtext)
			imgui.EndChild()
		end
		if smi_menu == 'about' then
			imgui.BeginChild('about', imgui.ImVec2(-1, 233 * MONET_DPI_SCALE), true)
			imgui.TextColoredRGB('����� �������: plalkeo')
			imgui.TextColoredRGB('VK: ' .. curcolor .. 'vk.com/plalkeo')
			if not isMonetLoader() then
				if imgui.IsItemHovered() then imgui.SetTooltip(u8"�������� ���, ����� �����������, ��� ���, ����� ������� � ��������")  end
				if imgui.IsItemClicked(0) then setClipboardText("https://vk.com/plalkeo") end
				if imgui.IsItemClicked(1) then shell32.ShellExecuteA(nil, 'open', 'https://vk.com/im?sel=238453770', nil, nil, 1) end
			end
			imgui.TextColoredRGB('������ VK: ' .. curcolor .. 'vk.com/smiplalkeo')
			if not isMonetLoader() then
				if imgui.IsItemHovered() then imgui.SetTooltip(u8"�������� ���, ����� �����������, ��� ���, ����� ������� � ��������")  end
				if imgui.IsItemClicked(0) then setClipboardText("https://vk.com/smiplalkeo") end
				if imgui.IsItemClicked(1) then shell32.ShellExecuteA(nil, 'open', 'https://vk.com/smiplalkeo', nil, nil, 1) end
			end
			imgui.Text(u8[[blast hk: plalkeo
������ ��� ���������� ��� Arizona RP]])
			if imgui.Button(u8'�������������') then
				lua_thread.create(function() wait(5) thisScript():reload() end)
				imgui.ShowCursor = false
			end
				if imgui.IsItemHovered() then imgui.SetTooltip(u8"�������� ���, ����� ������������� ������")  end -- ��� ������������
			imgui.SameLine()
			if imgui.Button(u8'���������') then
				lua_thread.create(function() wait(1) thisScript():unload() end)
				imgui.ShowCursor = false
			end
				if imgui.IsItemHovered() then imgui.SetTooltip(u8"�������� ���, ����� ��������� ������")  end -- ��� ��������
			if not isMonetLoader() then
				imgui.SameLine()
				if imgui.Button(u8'��������� ����������') then
					buttonupdate('https://raw.githubusercontent.com/pla1keo/smiplalkeo/main/smiplalkeo.json','[SMI-plalkeo]{FFFFFF}','url')
				end
					if imgui.IsItemHovered() then imgui.SetTooltip(u8"�������� ���, ����� ��������� ���������� �������")  end -- ��� �����
			end
			imgui.Text(u8'���� � ��� ���� �����-�� ��������/���� - �������� ������������ �������')
			if not isMonetLoader() then
				if imgui.Button(u8'�������� � ��������/����') then
					shell32.ShellExecuteA(nil, 'open', 'https://vk.com/im?sel=238453770', nil, nil, 1)
				end
					if imgui.IsItemHovered() then imgui.SetTooltip(u8"�������� ���, ����� �������� ������������")  end -- ��� ��������� � ������/����
			end
			imgui.TextColoredRGB('������: '..thisScript().version, 3)
			if imgui.Button(faicons('INFO') .. u8' ���������', (imgui.ImVec2(200 * MONET_DPI_SCALE, 20 * MONET_DPI_SCALE))) then smi_menu = 'changelog' end
			imgui.EndChild()
		end
		imgui.End()
	end
)
local russian_characters = {
    [168] = '�', [184] = '�', [192] = '�', [193] = '�', [194] = '�', [195] = '�', [196] = '�', [197] = '�', [198] = '�', [199] = '�', [200] = '�', [201] = '�', [202] = '�', [203] = '�', [204] = '�', [205] = '�', [206] = '�', [207] = '�', [208] = '�', [209] = '�', [210] = '�', [211] = '�', [212] = '�', [213] = '�', [214] = '�', [215] = '�', [216] = '�', [217] = '�', [218] = '�', [219] = '�', [220] = '�', [221] = '�', [222] = '�', [223] = '�', [224] = '�', [225] = '�', [226] = '�', [227] = '�', [228] = '�', [229] = '�', [230] = '�', [231] = '�', [232] = '�', [233] = '�', [234] = '�', [235] = '�', [236] = '�', [237] = '�', [238] = '�', [239] = '�', [240] = '�', [241] = '�', [242] = '�', [243] = '�', [244] = '�', [245] = '�', [246] = '�', [247] = '�', [248] = '�', [249] = '�', [250] = '�', [251] = '�', [252] = '�', [253] = '�', [254] = '�', [255] = '�',
}
function string.rlower(text)
	text = tostring(text)
    s = text:lower()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:lower()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 192 and ch <= 223 then -- upper russian characters
            output = output .. russian_characters[ch + 32]
        elseif ch == 168 then -- �
            output = output .. russian_characters[184]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end

buffer = new.char[160]()

ads_change = 500

if isMonetLoader() then ads_change = 200 end

local autoedit = imgui.OnFrame(
	function() return autoedit_slots[0] and not isPauseMenuActive() end,
	function(self)
		imgui.SetNextWindowPos(imgui.ImVec2(iScreenWidth / 2, iScreenHeight / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(1100 * MONET_DPI_SCALE, 350 * MONET_DPI_SCALE), imgui.Cond.Always)
		imgui.Begin(u8'������������������', autoedit_slots, imgui.WindowFlags.NoResize)
		imgui.PushItemWidth(500 * MONET_DPI_SCALE)
		imgui.InputTextWithHint('##SEARCHINPUT', faicons('magnifying_glass')..u8' �����', buffer, ffi.sizeof(buffer))
		imgui.PopItemWidth()
		imgui.BeginChild("", imgui.ImVec2(500 * MONET_DPI_SCALE, -1), true)
		if #u8:decode(str(buffer)) ~= 0 then 
			for number = 1, mainIni.edit['last'], 1 do 
				if string.rlower(u8:decode(mainIni.edit[number])):find(string.rlower(u8:decode(str(buffer)))) then
					if imgui.Selectable(mainIni.edit[number]) then
						if mainIni.edit[number] ~= nil then
							if mainIni.edit[number..'_input'] ~= nil then
								imgui.StrCopy(ae[3], mainIni.edit[number..'_input'])
								ae[4] = false
							elseif mainIni.edit[number..'_cancel'] ~= nil then
								imgui.StrCopy(ae[3], mainIni.edit[number..'_cancel'])
								ae[4] = true
							end
							ae[2] = mainIni.edit[number]
							ae[1] = 1
							ttax = number
						else
							ae[1] = 0
						end
					end
				end
			end
		else
			if tonumber(mainIni.edit['last']) < ads_change then
				for number = 1, ads_change, 1 do
					if mainIni.edit[number] ~= nil then
						if imgui.Selectable(mainIni.edit[number]) then
							if mainIni.edit[number] ~= nil then
								if mainIni.edit[number..'_input'] ~= nil then
									imgui.StrCopy(ae[3], mainIni.edit[number..'_input'])
									ae[4] = false
								elseif mainIni.edit[number..'_cancel'] ~= nil then
									imgui.StrCopy(ae[3], mainIni.edit[number..'_cancel'])
									ae[4] = true
								end
								ae[2] = mainIni.edit[number]
								ae[1] = 1
								ttax = number
							else
								ae[1] = 0
							end
						end
					else
						if imgui.Selectable(u8("���� �") .. number) then
							if mainIni.edit[number] ~= nil then
								if mainIni.edit[number..'_input'] ~= nil then
									imgui.StrCopy(ae[3], mainIni.edit[number..'_input'])
									ae[4] = false
								elseif mainIni.edit[number..'_cancel'] ~= nil then
									imgui.StrCopy(ae[3], mainIni.edit[number..'_cancel'])
									ae[4] = true
								end
								ae[2] = mainIni.edit[number]
								ae[1] = 1
								ttax = number
							else
								ae[1] = 0
							end
						end
					end
				end
			else
				for number = tonumber(mainIni.edit['last'])-50, tonumber(mainIni.edit['last'])+5, 1 do
					if mainIni.edit[number] ~= nil then
						if imgui.Selectable(mainIni.edit[number]) then
							if mainIni.edit[number] ~= nil then
								if mainIni.edit[number..'_input'] ~= nil then
									imgui.StrCopy(ae[3], mainIni.edit[number..'_input'])
									ae[4] = false
								elseif mainIni.edit[number..'_cancel'] ~= nil then
									imgui.StrCopy(ae[3], mainIni.edit[number..'_cancel'])
									ae[4] = true
								end
								ae[2] = mainIni.edit[number]
								ae[1] = 1
								ttax = number
							else
								ae[1] = 0
							end
						end
					else
						if imgui.Selectable(u8("���� �") .. number) then
							if mainIni.edit[number] ~= nil then
								if mainIni.edit[number..'_input'] ~= nil then
									imgui.StrCopy(ae[3], mainIni.edit[number..'_input'])
									ae[4] = false
								elseif mainIni.edit[number..'_cancel'] ~= nil then
									imgui.StrCopy(ae[3], mainIni.edit[number..'_cancel'])
									ae[4] = true
								end
								ae[2] = mainIni.edit[number]
								ae[1] = 1
								ttax = number
							else
								ae[1] = 0
							end
						end
					end
				end
			end
		end
		imgui.EndChild()
		imgui.SameLine()
		imgui.BeginChild("##�����", imgui.ImVec2(-1, -1), true)
			if ae[1] == 1 then
				imgui.Text(u8'��������: '.. ae[2])
				imgui.TextColoredRGB('������ ���������� ����������� ��� '..curcolor..(ae[4] and "����������" or "�����������"))
				imgui.PushItemWidth(500 * MONET_DPI_SCALE)
				imgui.InputText(" ", ae[3], ffi.sizeof(ae[3]))
				imgui.PopItemWidth()
				if imgui.Button(u8'���������') then
					if not ae[4] then
						mainIni.edit[ttax..'_input'] = str(ae[3])
					else
						mainIni.edit[ttax..'_cancel'] = str(ae[3])
					end
					inicfg.save(mainIni, 'smi.ini')
					sampAddChatMessage('[SMI-plalkeo] {FFFFFF}������� ���������.', curcolor1)
				end
			end
		imgui.EndChild()
		imgui.End()
	end
)

function sampev.onSendSpawn()
	if spawn and isMonetLoader() then
		spawn = false
		_, u_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
		u_name = sampGetPlayerNickname(u_id)
		sampSendChat('/stats')
		if u8:decode(mainIni.config['c_nick']) == '' or u8:decode(mainIni.config['c_nick']) == ' ' then
			saveInfo('config','c_nick',u8(trst(u_name)))
		end
		saveInfo('config','c_nicken',u_name)
		sampAddChatMessage("[SMI-plalkeo] {FFFFFF}������������ ���: "..curcolor.. u_name .. '[' .. u_id .. ']', curcolor1)
		sampAddChatMessage("[SMI-plalkeo] {FFFFFF}��� �������� �������� ���� ������� "..curcolor.."/smi", curcolor1)
	end
end

jobs = {
	'�������',
	'�������',
	'������',
	'�������� ��������',
	'�������',
	'��������� ���������',
	'��������� �����',
	'������',
	'�������� ���������',
	'����������',
	'������������',
	'�������������',
	'��������',
	'��������',
	'�����',
	'�������� �������',
	'�������� �������������',
	'������� ������',
	'������������ ���������',
	'������������ ������',
	'��������� �����',
	'�������� ��������'
}

function sampev.onServerMessage(color, msg)
	if msg:find('�����������') and msg:find(sampGetPlayerNickname(fastmenuID)) then
		sampSendChat('/offer')
	end
	if msg:find('�� ���������. ���������� ����� ��������') then
		mms = string.match(msg,'�������� (%d+) ������.')
		return {color, '�� ���������. ���������� ����� �������� ~'..string.format("%2.0f", tonumber(mms)/60)..' �����.('.. mms ..' ������)'}
	end
	if msg:find('� ��� ������� ������ � %/newsredak') then
		mms = string.match(msg,'newsredak �� (%d+) ������.')
		return {color, '� ��� ������� ������ � /newsredak �� ~'..string.format("%2.0f", tonumber(mms)/60)..' �����.('.. mms ..' ������)'}
	end
	local job, name_job, id_job, msg_job = string.match(msg, '%[(.+)%] (.+)%[(%d+)%]: (.+)')
	if job and name_job and msg_job then
		local message = ''
		if has_value(jobs,job) then
			if msg:sub(0, 2) == '((' and msg:sub(msg:len()-1) == '))' then
				message = '(( '
			end
			if mainIni.chat['job'] then
				return false
			else
				result, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
				if name_job == sampGetPlayerNickname(id) then
					name_job = '{ffffff}'..name_job .. '{FAAC58}'
				end
				return {color, message..'['..job..'] '.. name_job ..'['.. id_job ..']: '..msg_job}
			end
		end
	end
	local ad_text, ad_author, ad_a_id = string.match(msg,'����������: (.+). ��������: (.+)%[(%d+)%]')
	if ad_author and ad_text and ad_a_id and mainIni.chat['ad'] then
		return false
	end
	if msg:find('��������� �� ��������') then
		if mainIni.chat['ad'] then
			return false
		end
	end
	local ad_z_smi, ad_z_name, ad_z_id = string.match(msg,'��������� ��� %[ (.+) %] : (.+)%[(%d+)%]')
	if ad_z_smi and ad_z_name and ad_z_id and mainIni.chat['ad'] then
		return false
	end

end

function sampev.onSendChat(cmd)
	if accent[1][0] then
		if cmd == ')' or cmd == '(' or cmd ==  '))' or cmd == '((' or cmd == 'xD' or cmd == ':D' or cmd == ':d' or cmd == 'XD' then 
			return{cmd}
		end
		return{'['..u8:decode(str(accent[2]))..' ������]: '..cmd}
	end
end

function sampev.onSendCommand(cmd)
	for number = 1, 50, 1 do
		if mainIni.binder[number .. "_text"] ~= nil and mainIni.binder[number .. "_text"] ~= "" and mainIni.binder[number .. "_time"] ~= "" and cmd == '/' ..mainIni.binder[number .. "_cmd"] then
			lua_thread.create(function ()
				sampSendChat(u8:decode(string.match(mainIni.binder[number .. "_text"], "([^&]+)")))

				for ttext in string.gmatch(mainIni.binder[number .. "_text"], "&([^&]+)") do
					wait(tonumber(mainIni.binder[number .. "_time"]) * 1000)
					sampSendChat(u8:decode(ttext))
				end
			end)

			return false
		end
	end
end

mem = false

function main()
	if not isSampLoaded() then
		return
	end
	while not isSampAvailable() do
		wait(0)
	end
	sampAddChatMessage("[SMI-plalkeo] {FFFFFF}��������. �����: "..curcolor.."plalkeo", curcolor1)
	sampRegisterChatCommand("smi",test)
	if not isMonetLoader() then sampRegisterChatCommand("update", update) end
	sampRegisterChatCommand("r", function(text) 
		if accent[5][0] and accent[1][0] then sampSendChat('/r ['..u8:decode(accent[2][0])..' ������]: '..text) 
		else sampSendChat('/r '..text) end 
	end)
	sampRegisterChatCommand("s", function(text) 
		if accent[4][0] and accent[1][0] then sampSendChat('/s ['..u8:decode(accent[2][0])..' ������]: '..text) 
		else sampSendChat('/s '..text) end 
	end)
	-- ��������� ������� �� �� ���������
	sampRegisterChatCommand("expel", expel)
	sampRegisterChatCommand("giverank", giverank)
	sampRegisterChatCommand("fwarn", fwarn)
	sampRegisterChatCommand("unfwarn", unfwarn)
	sampRegisterChatCommand("invite", invite)
	sampRegisterChatCommand("blacklist", blacklist)
	sampRegisterChatCommand("unblacklist", unblacklist)
	sampRegisterChatCommand("uninvite", uninvite)
	sampRegisterChatCommand("funmute", funmute)
	sampRegisterChatCommand("fmute", fmute)
	while true do wait(0)
		if not isMonetLoader() then
			if isKeyJustPressed(VK_H) then
				if not sampIsChatInputActive() and not window[0] and not sampIsDialogActive() then
					sampSendChat('/opengate')
				end
			end

			if isKeysDown(mainIni.settings.bind) and not sampIsChatInputActive() then -- ����� �� https://www.blast.hk/threads/87533/
				if sampGetPlayerIdByCharHandle(select(2,getCharPlayerIsTargeting())) then
					setVirtualKeyDown(0x02,false)
					fastmenuID = select(2,sampGetPlayerIdByCharHandle(select(2,getCharPlayerIsTargeting())))
					selected_user = fastmenuID
					wait(0)
					addWithTag('����� ������� ���� - ������� '..curcolor..'ESC')
					renderWindow[0] = true
				end
			end
		else
			if isWidgetSwipedLeft(WIDGET_RADAR) then
				test()
			end
		end

		if not isMonetLoader() then
			if sampIsLocalPlayerSpawned() and spawn then
				spawn = false
				_, u_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
				u_name = sampGetPlayerNickname(u_id)
				sampSendChat('/stats')
				if u8:decode(mainIni.config['c_nick']) == '' or u8:decode(mainIni.config['c_nick']) == ' ' then
					saveInfo('config','c_nick',u8(trst(u_name)))
				end
				saveInfo('config','c_nicken',u_name)
				sampAddChatMessage("[SMI-plalkeo] {FFFFFF}������������ ���: "..curcolor.. u_name .. '[' .. u_id .. ']', curcolor1)
				sampAddChatMessage("[SMI-plalkeo] {FFFFFF}��� �������� �������� ���� ������� "..curcolor.."/smi", curcolor1)
				buttonupdate('https://raw.githubusercontent.com/pla1keo/smiplalkeo/main/smiplalkeo.json','[SMI-plalkeo]{FFFFFF}')
			end
		end
	end
end
function test(arg)
	window[0] = not window[0]
end


function onWindowMessage(msg, wparam, lparam)
	if keys == nil then 
		keys = require 'vkeys'
	end
	if msg == 0x100 or msg == 0x101 then
		if (wparam == keys.VK_RETURN and edit_helper[0]) and not isPauseMenuActive() then
		   consumeWindowMessage(true, false)
		   if msg == 0x101 then
				send_ad()
		   end
		end
		if (wparam == keys.VK_ESCAPE and edit_helper[0]) and not isPauseMenuActive() then
			consumeWindowMessage(true, false)
			cancel_ad()
		end
		if (wparam == keys.VK_ESCAPE and jobprogress[0]) and not isPauseMenuActive() then
			consumeWindowMessage(true, false)
			jobprogress[0] = false
			sampSendDialogResponse(0, 1, 1, "")
		end
		if (wparam == keys.VK_ESCAPE and custom_lmenu[0]) and not isPauseMenuActive() then
			consumeWindowMessage(true, false)
			custom_lmenu[0] = false
			sampSendDialogResponse(1214, 0, 0, "")
		end
		if (wparam == keys.VK_ESCAPE and renderWindow[0]) and not isPauseMenuActive() then
			consumeWindowMessage(true, false)
			selected_user = nil
			renderWindow[0] = false
		end
	end
end

function expel(params)
	local id, arg = string.match(params, "(%d+)%s(.+)")
	if arg ~= nil and tonumber(id) < 1000 then
		if check_rank(2) then
			if mainIni.rpbind['expel'] then
				lua_thread.create(function()
					sampSendChat("/do ����� �� �����.")
					wait(2500)
					sampSendChat("/me ������ ����� � ������ ������ �� ���")
					wait(2000)
					sampSendChat("/do ������ ������ �������� �� �����������.")
					wait(1000)
					sampSendChat("/expel ".. id .. " " .. arg)
				end)
			else
				sampSendChat("/expel ".. id .. " " .. arg)
			end
			return false
		end
	else
		sampAddChatMessage("[SMI-plalkeo] {FFFFFF}�������: /expel [id] [�������]", curcolor1)
	end
end

function giverank(params)
	local id, arg = string.match(params, "(%d+)%s(%d)")
	if arg ~= nil and tonumber(id) < 1000 and tonumber(arg) < 10 then
		if check_rank(9) then
			if mainIni.rpbind['giverank'] then
				lua_thread.create(function()
					sampSendChat("/do ����� ������� � �������.")
					wait(2500)
					sampSendChat("/me ������ �� ������� �������")
					wait(2000)
					sampSendChat("/todo � ����������, ������� ���������*������� ������� ����������")
					wait(2000)
					sampSendChat("����������� �������� � ��� �� ����.")
					wait(1000)
					sampSendChat("/giverank ".. id .. " " .. arg)
				end)
			else
				sampSendChat("/giverank ".. id .. " " .. arg)
			end
		end
	else
		sampAddChatMessage("[SMI-plalkeo] {FFFFFF}�������: /giverank [id] [����]", curcolor1)
	end
end

function fwarn(params)
	local id, arg = string.match(params, "(%d+)%s(.+)")
	if arg ~= nil and tonumber(id) < 1000 then
		if check_rank(9) then
			if mainIni.rpbind['fwarn'] then
				lua_thread.create(function()
					sampSendChat("/do ������� � ����� ������ ����������� � �����.")
					wait(2500)
					sampSendChat("/me ����� � ������ \"��������\"")
					wait(2000)
					sampSendChat("/do ������ ������.")
					wait(2000)
					sampSendChat("/me ����� ������� ���������� � ������� \"��������\"")
					wait(1000)
					sampSendChat("/fwarn ".. id .. " " .. arg)
				end)
			else
				sampSendChat("/fwarn ".. id .. " " .. arg)
			end
		end
	else
		sampAddChatMessage("[SMI-plalkeo] {FFFFFF}�������: /fwarn [id] [�������]", curcolor1)
	end
end

function unfwarn(params)
	local id = params:match('(%d+)')
	if id ~= nil and id ~= '' then
		if tonumber(id) < 1000 then
			if check_rank(9) then
				if mainIni.rpbind['unfwarn'] then
					lua_thread.create(function()
						sampSendChat("/do ������� � ����� ������ ����������� � �����.")
						wait(2500)
						sampSendChat("/me ����� � ������ \"��������\"")
						wait(2000)
						sampSendChat("/do ������ ������.")
						wait(2000)
						sampSendChat("/me ���� ������� ���������� � ������� \"��������\"")
						wait(1000)
						sampSendChat("/unfwarn ".. id)
					end)
				else
					sampSendChat("/unfwarn ".. id)
				end
			end
		end
	else
		sampAddChatMessage("[SMI-plalkeo] {FFFFFF}�������: /unfwarn [id]", curcolor1)
	end
end

function invite(params)
	local id = params
	if id ~= nil and id ~= '' then
		if tonumber(id) < 1000 then
			if check_rank(9) then
				if mainIni.rpbind['invite'] then
					lua_thread.create(function()
						sampSendChat("/do ���� �� ���������� � �������.")
						wait(2500)
						sampSendChat("/me ������ ���� �� ���������� �� �������")
						wait(2000)
						sampSendChat("/todo ����� ����������!*������� ���� �������� ��������")
						wait(2000)
						sampSendChat("���������� �� 2 �����.")
						wait(1000)
						sampSendChat("/invite ".. id)
					end)
				else
					sampSendChat("/invite ".. id)
				end
			end
		end
	else
		sampAddChatMessage("[SMI-plalkeo] {FFFFFF}�������: /invite [id]", curcolor1)
	end
end

function blacklist(params)
	local id = params:match('(%d+)')
	if id ~= nil and id ~= '' then
		if tonumber(id) < 1000 then
			if check_rank(9) then
				if mainIni.rpbind['blacklist'] then
					lua_thread.create(function()
						sampSendChat("/do ������� � ����� ������ ����������� � �����.")
						wait(2500)
						sampSendChat("/me ����� � ������ \"׸���� ������\"")
						wait(2000)
						sampSendChat("/do ������ ������.")
						wait(2000)
						sampSendChat("/me ������� �������� � ������ \"׸���� ������\"")
						wait(1000)
						sampSendChat("/blacklist ".. id)
					end)
				else
					sampSendChat("/blacklist ".. id)
				end
			end
		end
	else
		sampAddChatMessage("[SMI-plalkeo] {FFFFFF}�������: /blacklist [id]", curcolor1)
	end
end

function unblacklist(params)
	local id = params:match('(%d+)')
	if id ~= nil and id ~= '' then
		if tonumber(id) < 1000 then
			if check_rank(9) then
				if mainIni.rpbind['unblacklist'] then
					lua_thread.create(function()
						sampSendChat("/do ������� � ����� ������ ����������� � �����.")
						wait(2500)
						sampSendChat("/me ����� � ������ \"׸���� ������\"")
						wait(2000)
						sampSendChat("/do ������ ������.")
						wait(2000)
						sampSendChat("/me ����� �������� �� ������� \"׸���� ������\"")
						wait(1000)
						sampSendChat("/unblacklist ".. id)
					end)
				else
					sampSendChat("/unblacklist ".. id)
				end
			end
		end
	else
		sampAddChatMessage("[SMI-plalkeo] {FFFFFF}�������: /unblacklist [id]", curcolor1)
	end
end

function uninvite(params)
	mem = true
	users = {}
	parama = params
	sampSendChat('/members')
end

function funmute(params)
	local id = params:match('(%d+)')
	if id ~= nil and id ~= '' then
		if tonumber(id) < 1000 then
			if check_rank(9) then
				lua_thread.create(function()
					sampSendChat("/funmute ".. id)
				end)
			end
		end
	else
		sampAddChatMessage("[SMI-plalkeo] {FFFFFF}�������: /funmute [id]", curcolor1)
	end
end

function fmute(params)
	local id, arg = string.match(params, "(%d+)%s(.+)")
	if arg ~= nil and tonumber(id) < 1000 then
		if check_rank(9) then
			lua_thread.create(function()
				sampSendChat("/fmute ".. id .. " " .. arg)
			end)
		end
	else
		sampAddChatMessage("[SMI-plalkeo] {FFFFFF}�������: /fmute [id] [�������]", curcolor1)
	end
end

function update()
	prefix = '[SMI-plalkeo]{FFFFFF}'
	color = curcolor1
	local dlstatus = require('moonloader').download_status
	downloadUrlToFile('https://github.com/pla1keo/smiplalkeo/raw/main/smiplalkeo.lua', thisScript().path,
		function(id3, status1, p13, p23)
		if status1 == dlstatus.STATUS_DOWNLOADINGDATA then
			print(string.format('��������� %d �� %d.', p13, p23))
		elseif status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
			print('�������� ���������� ���������.')
			sampAddChatMessage((prefix..' ���������� ���������!'), color)
			goupdatestatus = true
			lua_thread.create(function() wait(500) thisScript():reload() end)
		end
		if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
			if goupdatestatus == nil then
				sampAddChatMessage((prefix..' ���������� ������ ��������. �������� ���������� ������..'), color)
			end
		end
	end)
end

function buttonupdate(json_url, prefix)
	local dlstatus = require('moonloader').download_status
	local json = getWorkingDirectory() .. '\\smiplalkeo.json'
	if doesFileExist(json) then os.remove(json) end
	downloadUrlToFile(json_url, json,
	function(id, status, p1, p2)
		if status == dlstatus.STATUSEX_ENDDOWNLOAD then
			if doesFileExist(json) then
				local f = io.open(json, 'r')
				if f then
					local info = decodeJson(f:read('*a'))
					updateversion = info.version
					f:close()
					os.remove(json)
					if updateversion ~= thisScript().version then
						local color = curcolor1
						sampAddChatMessage((prefix..' ���������� ����������. v'..updateversion), color)
						sampAddChatMessage(prefix..' ��� ���������� ����������� ������� '..curcolor..'/update', color)
					else
						update = false
						sampAddChatMessage(prefix..' ���������� �� �������.', curcolor1)
						print('v'..thisScript().version..': ���������� �� ���������.')
					end
				end
			else
				print('v'..thisScript().version..': �� ���� ��������� ����������.')
				update = false
			end
		end
	end)
end