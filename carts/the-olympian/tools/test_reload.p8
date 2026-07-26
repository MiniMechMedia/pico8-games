pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- round-trip test: verify pack.py section encoding via reload
function _init()
	reload(0x0000, 0x0000, 0x3100, "prom_imgtest.p8")
	local ok=true
	for i=0,0x30ff do
		local expect=(i*7+13)&0xff
		if peek(i)!=expect then
			printh("!!mismatch at "..i.." got "..peek(i).." want "..expect)
			ok=false
			break
		end
	end
	printh(ok and "!!roundtrip ok" or "!!roundtrip fail")

	-- can reload write directly to upper memory?
	memset(0x8000,0,64)
	reload(0x8000, 0x100, 64, "prom_imgtest.p8")
	local ok2=true
	for i=0,63 do
		local expect=((0x100+i)*7+13)&0xff
		if peek(0x8000+i)!=expect then ok2=false break end
	end
	printh(ok2 and "!!upper ok" or "!!upper fail")
	extcmd("shutdown")
end
