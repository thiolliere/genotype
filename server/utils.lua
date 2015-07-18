function string.2char(int)
	local up = int/(2^8)
	local down = int % (2^8)
	return string.char(up,down)
end
