pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
--{GAMENAME}
--{AUTHORINFO} 





-- cartdata('mmm_project_titan_v1')


reply ='    \fc'
bg ='\^#'
function parseChoiceLine(choiceLine)
local linkCart ='' local linkNode ='' local linkText =''
assert(choiceLine[1] =='*')
local state ='cart' for i = 2, #choiceLine do
local char = choiceLine[i]
if state =='cart' then
if char =='/' then
state ='node' else
linkCart ..= char
end
elseif state =='node' then
if char ==' ' then
state ='text' else
linkNode ..= char
end
elseif state =='text' then
linkText ..= char
end
end
assert(state =='text')
return {
cart = linkCart,node = linkNode,text = linkText
}
end
function makeBranch(branch)
return {
raw = branch,type ='branch',evalNode = function(self, storyState)
return parseTextList({
self.raw[storyState.initReaction]
})[1]
end
}
end
function makeImage(img)
if img == img_this then
return {
img = img_this,hash = 0,type ='img' }
end
local hash = 0
for i = 1, #img do
hash = hash * 2.142352 + 5.33893825 * ord(img[i])
end
return {
img = img,hash = hash,type ='img' }
end
function startswith(str, prefix)
return sub(str, 1, #prefix) == prefix
end
function strspl(s,sep)
ret = {}
bffr="" for i=1, #s do
if(sub(s,i,i)==sep)then
add(ret,bffr)
bffr="" else
bffr = bffr..sub(s,i,i)
end
end
if(bffr!="") add(ret,bffr)
return ret
end
function replywrap(s)
return wwrap(s,28)
end
function wwrap(s,w)
w=w or 32
retstr ="" lines = strspl(s,"\n")
for i=1,count(lines) do
linelen=0
words = strspl(lines[i]," ")
for k=1, count(words) do
wrd=words[k]
if(linelen+#wrd>w)then
retstr=retstr.."\n" linelen=0
end
retstr=retstr..wrd.." " linelen+=#wrd+1
end
retstr=retstr.."\n" end
return retstr
end
function addToList(textList, line)
local isReply = startswith(line, reply)
local isFirst = true
for piece in all(split(line,'\n')) do
if not isFirst and isReply then
piece = reply .. piece
end
if isFirst then
isFirst = false
end
add(textList, piece)
end
end
function parseTextList(textList)
local ret = {}
local dialogBlock = nil
isDialog = false
local imageInPage = false
for line in all(textList) do
if type(line) =='table' then
add(ret, makeBranch(line))
elseif type(line) !='string' then
assert('type is not string' =='bad')
elseif #line > 1000 or line == img_this then
assert(not imageInPage)
imageInPage = true
add(ret, makeImage(line))
elseif line[1] =='*' then
if isDialog then
add(dialogBlock, parseChoiceLine(line))
else
isDialog = true
dialogBlock = {
parseChoiceLine(line),type='choice',['choiceindex' ] = 1
}
end
imageInPage = false
else
if isDialog then
add(ret, dialogBlock)
isDialog = false
dialogBlock = nil
addToList(ret, line)
else
if line == nextpage then
imageInPage = false
end
if line != ignore then
addToList(ret, line)
end
end
end
end
if isDialog then
if #dialogBlock == 1 and dialogBlock[1].text =='' then
dialogBlock.isGoTo = true
end
add(ret, dialogBlock)
end
return ret
end
function makeTextGame(textList, node_id, is_terminal)
local ret = makeGame(
function()end,function(self)
self.getStoryState = function()
return {
initReaction = readReaction()
}
end
self.printLine = function(self, text)
if(text != pause) print(bg..text, 7)
end
self.is_terminal = is_terminal
if self.is_terminal then
add(textList,'')
add(textList,'*chapter2/intro play again')
end
self.shouldAdvance = function(self)
local node = self:lastNode()
local next = self:getNodeAt(self.textIndexEnd + 1)
if type(node) =='string' and type(next) =='string' then
if next != nextpage and next != pause then
return true
end
end
if type(node) =='string' and type(next) =='table' and next.type=='choice' then
return true
end
return false
end
self.textList = parseTextList(textList)
self.textIndexStart = 1
self.textIndexEnd = 1
self.updateChoiceIndex = function(self, delta)
if self:isChoice() then
self:lastNode().choiceindex = mid(1, self:lastNode().choiceindex + delta, #self:lastNode())
else
assert('idk' =='bad')
end
end
self.isGoTo = function(self)
return self:isChoice() and self:lastNode().isGoTo
end
self.isChoice = function(self)
return type(self:lastNode()) =='table' and self:lastNode().type =='choice'
end
self.getNodeAt = function(self, index)
if(self.textList[index] == nil) return nil
return self:getEvaluated(self.textList[index])
end
self.lastNode = function(self)
return self:getNodeAt(self.textIndexEnd)
end
self.getEvaluated = function(self, node)
if node.type =='branch' then
return node:evalNode(self:getStoryState())
else
return node
end
end
self.selectedChoice = function(self)
local node = self:lastNode()
assert(type(node) =='table')
return node[node.choiceindex]
end
self.curText = function(self)
local ret = {}
for i = self.textIndexStart, self.textIndexEnd do
add(ret, self:getEvaluated(self.textList[i]))
end
return ret
end
end,
function(self)
cls()
for line in all(self:curText()) do
if type(line) =='string' then
self:printLine(line)
elseif line.isGoTo then
elseif line.type =='choice' then
for i = 1, #line do
local choice = line[i]
if i == line.choiceindex then
self:printLine('> ' ..choice.text)
else
self:printLine('  ' ..choice.text)
end
end
elseif line.type =='img' then
load_img(line)
spr(0,0,0,16,16)
else
assert('' =='asdf')
end
end
end,
function(self)
if self:isChoice() then
self:updateChoiceIndex(tonum(btnp(dirs.down))-tonum(btnp(dirs.up)))
if btnp(dirs.x) or self:isGoTo() then
local choice = self:selectedChoice()
self.isGameOver = true
self.choice = choice
return
end
end
if btnp(dirs.x) or self:shouldAdvance() then
self.textIndexEnd += 1
if self.textList[self.textIndexEnd] == nextpage then
self.textIndexStart = self.textIndexEnd + 1
self.textIndexEnd = self.textIndexStart
end
if self.textIndexEnd > #self.textList then
self.isGameOver = true
end
end
end
)
ret.node_id = node_id
return ret
end
function _update()
gs:activateGame()
gs:getActiveGame():update()
if gs:getActiveGame().isGameOver then
local choice = gs:getActiveGame().choice
if choice == nil then
gs:activateNextGame()
else
gs:navigateToChoice(choice)
end
end
end
nextpage ='<NEXTPAGE>'
ignore ='<IGNORE>' pause ='<PAUSE>' img_this ='<SPRITESHEET>'
gs = nil
dirs = {
left = 0,right = 1,up = 2,down = 3,z = 4,x = 5
}
function makeGame(injectgame, init, draw, update)
return {
isInitialized = false,injectgame = injectgame,init = init,draw = draw,update = update,isGameOver = false,gameOverState = nil,startTime = t(),endTime = nil,currentAnimation = nil
}
end
function myreset(node, reac)
writeTargetNode(node or'any_hack')
poke(0x8000, reac or 1)
end
function _init()
	menuitem(1, 'restart (ch. 1)', function()
		gs:navigateToChoice({
			cart = 'chapter1',
			node = 'intro'
		})
	end)
	menuitem(2, 'restart (ch. 2)', function()
		gs:navigateToChoice({
			cart = 'chapter2',
			node = 'intro'
		})
	end)
gs = {
loaded_img_hash = 0,activeGameIndex = 1,getActiveGame = function(self)
return self.games[self.activeGameIndex]
end,activateGame = function(self, game)
game = game or self:getActiveGame()
if not game.isInitialized then
game:injectgame()
game:init()
game.isInitialized = true
end
end,activateNextGame = function(self)
self.activeGameIndex += 1
writeTargetNode(self.games[self.activeGameIndex].node_id)
if self.activeGameIndex > #self.games then
self.activeGameIndex = -1
end
end,navigateToChoice = function(self, choice)
if choice.text =='[awe]' then
writeReaction('awe')
elseif choice.text =='[confusion]' then
writeReaction('sus')
elseif choice.text =='[disdain]' then
writeReaction('dis')
end
if choice.cart =='.' then
local found = false
for i = 1, #self.games do
if self.games[i].node_id == choice.node then
self:getActiveGame().isGameOver = false
self:getActiveGame().isInitialized = false
self.activeGameIndex = i
self:getActiveGame().isGameOver = false
self:getActiveGame().isInitialized = false
found = true
break
end
end
assert(found)
writeTargetNode(choice.node)
else
writeTargetNode(choice.node)
assert(load(choice.cart))
end
end
}
gs.games = chapter_init()
local targetNode = readTargetNode()
print(targetNode)
if targetNode != nil then
local found = false
for i = 1, #gs.games do
if gs.games[i].node_id == targetNode then
gs.activeGameIndex = i
found = true
break
end
end
assert(found)
end
end
reacMap = {
awe = 1,dis = 2,sus = 3
}
invReacMap = {'awe','dis','sus' }
function writeReaction(str)
local val = reacMap[str]
assert(val)
poke(0x8000, val)
end
function readReaction()
local val = peek(0x8000)
assert(val > 0)
assert(val < 4)
return invReacMap[val]
end
function writeTargetNode(node)
if node == nil then
poke(0x8001, 0)
return
end
poke(0x8001, #node)
for i = 1, #node do
poke(0x8001 + i, ord(node[i]))
end
end
function readTargetNode()
local len = peek(0x8001)
if len == 0 then
return nil
end
local ret ='' for i = 1, len do
ret ..= chr(peek(0x8001 + i))
end
return ret
end
function _draw()
if not gs:getActiveGame().isInitialized then
return
end
gs:getActiveGame():draw()
end

function
load_img(img)
if gs.loaded_img_hash == img.hash or img.hash == 0 then
return
end
gs.loaded_img_hash = img.hash
poke(0x8000+256, ord(img.img, 1, #img.img))
x0,y0,src,vget,vset = 0,0,0x8000+256,sget,sset
local function vlist_val(l, val)
local v,i=l[1],1
while v!=val do
i+=1
v,l[i]=l[i],v
end
l[1]=val
end
local cache,cache_bits=0,0
function getval(bits)
if cache_bits<8 then
cache_bits+=8
cache+=@src>>cache_bits
src+=1
end
cache<<=bits
local val=cache&0xffff
cache^^=val
cache_bits-=bits
return val
end
function gnp(n)
local bits=0
repeat
bits+=1
local vv=getval(bits)
n+=vv
until vv<(1<<bits)-1
return n
end
local
w,h_1,
eb,el,pr,x,y,splen,predict
=
gnp"1",gnp"0",gnp"1",{},{},0,0,0
for i=1,gnp"1" do
add(el,getval(eb))
end
for y=y0,y0+h_1 do
for x=x0,x0+w-1 do
splen-=1
if(splen<1) then
splen,predict=gnp"1",not predict
end
local a=y>y0 and vget(x,y-1) or 0
local l=pr[a] or {unpack(el)}
pr[a]=l
local v=l[predict and 1 or gnp"2" ]
vlist_val(l, v)
vlist_val(el, v)
vset(x,y,v)
end
end
end


_img_formless_void = "◝◝ヲ○◝◝♥ト\0なふ!ト❎◝ユ`ュ\0¹ᶠ◝ワA▒²\0²$⬇️ら²゜◝ソ✽█CHワ² モ゜◝ク●くd²*⁸☉\0あI'p@4?ュC☉u⁴&²²⁙%*T ▮の‖□G▮BC◝⁴$$▮オヌ⁸{!F□?$D&…%●♥ニᶠサ⁸○ヒノ▒り¹\"^h「8L✽や➡️⁷ネ\r\tᶠョ0マ「H웃⁙/S8NfRq2$¥⁴▮◝ト⁴?゛⁸$░⬅️ト|8BᵉN%\t!キJ$?ス{⁴$9░🐱⁸D\"⌂ほrなし⁷) ▤N☉つ!D…🐱゜ヲ!ヲBHモ▮●⧗,$8ょᵉ⁙ˇナK8⬅️P∧\n░♪\tᶠゅ゜う$♥q■⁙Htうkカ'K%、(ᵇu%ᵉ.\"⁷¹Q◝け¥BGp░の,,ナ▮ぬu◀w`ヌ4もq4ヌ0ニろ⁸⌂;♥Pッ¥⁘w □…▒\"\nニケ웃ᵇアツ$0ね&ニる+8⁸I▮i◀゜う▮リD▮s\nq█8@웃!ᵇたセもC+\r¥うt▮…◝り☉ぬw■⁴●…☉る²B▒⁙)ょいなK8♪)る❎웃 Qヲっオマ、d…,B*¥#⬆️I$🅾️,/▮ニ&8セを⁴▥*□ヌ、v➡️➡️ヨヲBHB◀⁸K\rアAそbE☉K!A[!(ょ■#⁘ヌIl➡️#ヨ➡️くイ\r!□ス🅾️d☉モ☉r▤D$ヌ2☉フ웃ᵉまうsc♥'2%さ★==….\tろ…ヘH▤ □$웃さ けノフ¥#むむ$,8Eの$j<●✽░Bᵉ¹j²◀F➡️!イ⁴た□$웃‖⁘ニ⁷^9lさDRの@◝,¹)N⁴🅾️⁙た、B'웃j-ノIケP■ウうIん⁷⁸9#シミ\"¹T@APsᶠサ@そ,█ヌ\"ょY⁷²&qわ▶め\n…Y¥◀□◀B!70웃て◆aア)\n^▮░p░5ニx♥たん²@つ✽゜ホちウ(░➡️ノ$8🐱CD😐IF░ニ](も=ネp、ゃ%オ#⁷ヤ\tけ⁶★⁶ sᶠく$⁵²🅾️\0ゃゃ⁴むっ…ヒ`(Y³っHHMW²p,の、Cそw⁴⁘,E░★Xぬロ\tるJN⁵Be⧗ッ⁸こ⬅️!■\"JマU⬆️✽♥◀¹DD¥\nL\t,★q-⌂Z⁙웃゛リPぬXm□i。HロDヘ☉🐱スdメ⁘★っIっnx…ア★R&8🐱⁘∧ろB░しE^aチ◆ろAっ웃4◀\t$カ⁙⬅️ろこ●░q$HおRqゃ\"\"■*X░Hョ!ろ$✽░▮☉█T^\0Iノ■(ˇU\"K□っュ4XDEけRれレ➡️くl^きさ\"\"F⁸✽☉Gq‖「∧TJ{*X$T⬆️q)\tᶠキ▶★\t\"さ★:\0さ\0p★ᵉlあ…Ygオまさ★Jsj□◆くア?(1ᵇ$そ★□Y\"H♥⁸なx\\モ%♥R▮フAˇひI#Cそsᵇ*HBA*]⁴ハ!$か⬅️⬆️ヌむ⁶と●♥pL、$キD➡️ア🅾️ニンるけ⁴ᵇ□p!░モDたᵇaBpえBh░'★‖\"りᶠュr□□(キ@🐱➡️\"Cね‖ゃトRDッ♥‖jY⁸4T➡️ム⬅️ᶠく$s\"Q8&うノ□=➡️%!/\tくhセ1*u#!#ス{*Hュ くᵇ)IlJあD░★Uᶜ웃🅾️ハR$Bむつ!9🐱?\t_フ0ぬュ☉ !⁸v⧗いDョくj¹1l*wᶠリ■Q⁵J\"²~웃ᶠウB□★J◀U⌂➡️!チ?8~0ニ⁸ヌAみ☉░▮▤웃そモ³たW■*と🐱Gp◜!!シP@8⬆️KᶠクLZクヨオBtu(P…4=♥0ュナn⬅️る\t\"れシ⁴ョ`H⁵な,░G(⁸ᶠサ゜う9ろM⁷X9🐱⁴¥G⬆️r⧗そ\0めJ'R8ˇさsᵉくろ44--,🅾️r$ぬマ³🅾️\t²sるるニ<,◆テRGのさ▮★ DOんM¹¹ム웃ds⁘Yhキ?ュりH@の,▮h…웃゜★8た²た◀リ⁘のP…ョニヲゅラUˇB\"$zK░;➡️をH#ねま☉い□゛Cた¥゜チ,'■⁸\"4➡️$1□りD░'@+C🅾️\"Yャっオマ、C▤w\"웃!(⁘T⁸⌂▒⁙ウ■!YるUFHモ、カャれリ●░の\0q▮X…∧\"れユ➡️\r⁸★ゃ⁴░♥ン+ヲ➡️きし★E ★*⁸⌂Aろ░¥⁴…ぬ)⁸ぬュニ◝⌂¥¥゛H⌂さp█*「⬅️aる⁶➡️&そiᶠキGpキみ➡️ル=⬆️ヌ\"き,★d!⁴⌂お⌂⧗😐\"B□、Cラˇヲれレ➡️ケ▮▶¹`%GR。ろ$お゜Hュ%○r?\\T🐱➡️B「ま$✽▮ニ‖ᵇるイ!ュJュノ!ノ⬅️\t#み\\る!9P웃チ⬅️!■It웃!$y⁴にウG◜⁸%^b\"PBH⧗H웃⁸h⁴⁸□■▮⁘ヒGネ\rᶠaョれ▒@□‖$At□U…R\0Od○0ロ¥¥゜お\raん$#た▮i⁙Iᵇ$、h░2q#ョ➡️ム8🐱¥•D⁸ N…O ★DJ*E♥★,>░♥p◝りᵇ#p\t\0キI8★\"¹⁴⧗\r▮オ!ッAᶠる゛るJヌGハち(▒³□K\tH⁘웃⁴もろ░✽♥▮ョニ◝∧U♥、U□\"ᵉx★HD◆▮…b,♪ᶠテ゜BJュノw⁴ち²K²9$E☉-░ヒ¹ᵉ$~▮C☉!ム?(!ャBR{キ '」!□ル\";➡️du#ユ🐱Wニ#ロ⬇️²カ⁶\n∧ろ%た\"⁸あ&ら♥◜\t^CHロF➡️チつ@Xu$\"らDけH'■ᶠソ◀W□=♥ホ\rᵉ1V➡️□░、ノ➡️る q²\tキ\"4🅾️aei_もと⁴?⁸k■⁴🅾️PP░ヌG(…キ゛Bれョ♥◜y▮▒)🅾️⁴\tラ\"▮9☉웃#ま~オモ、れヘq\"@웃²q⁸▤웃き\"⧗🐱☉u#リˇノ◆!ケ8➡️$sᵉbケるGゃら」ᶜ⧗…♪ᵇᵉ%q!ᵉくム8➡️ッスIDTD★,□⁷⁘⌂H⬅️\rP✽➡️くャCス~オラろケ🅾️\"\t、t\"²\t$Iチ☉●➡️◝あ゜ろ:🐱A¥ᵇ$b9さRM$\"□T▮⧗Ad~2:♥オュくン%さヒっムI!ア\tん$➡️aア░にるGpッ□゜Hキ$⬆️❎dJ9\",さ◀#웃⁴けHぬュdhw+◝⁴🅾️%J」%▒ᵇᵉD♥■$HD ░ら✽…♥0ュしwᵇ#ャ▒o(TTた#░★B$☉⬅️⁙▒░r!く◝🐱゜⬆️$=z…J]Rさ░く$のラ D8くBBこ◝|にエむ⁘ユあ⁙あ…D★ Aa⁴░HX4、BBCリ✽?⁸p⌂░%Tハ³♪ᵇl🐱('Pp░ぬ░4◆ソ゜ろ<K□て\0I\t 웃\tわ⁸▮~▮░…🐱Wメ#っyᶠし\"pくゃん|ヨᵉP♪ん&█I□=、Iᵉく!!!ヲCま{+░%う▤v.こ▥tナカらそオナY%🐱Vˇル◆サGの9Dた2⁸A,◀Bさ➡️9ˇ${!ろ☉モ¥Gハ#ワ♥P\n█⌂\n✽✽(□9,;け.ら░カ゜ヲ!ケ?²、w,🅾️\tら8キEˇケ웃#'P⬇️そ★D🐱B。BるCッ🐱ゃ\"しK#⧗け(ッ@マ⁸I⁸\0そロWヨᵉさHa#8⌂ぬ🅾️□$+%$qv⬆️オふ[😐3웃 …🐱R゜ろ:♥2よ(wᵉ□⁵Hあ웃ᶜI⁵b オ☉⌂⧗ユ♥rさ9➡️ケ'‖$e⁘Kねlx■lIL⁸ううちわbB▮:…゛BJ◝S ˇ■R▮ヌ▮K¥+たD★>へ² H➡️ そ◝ょ⁴4⁵のイ⁷□ᵉて…➡️、オX🐱っAケD🅾️-、I#\t゜ッ4DD■/‖⧗ユモるL♪り$▤ニm∧*B$🐱p☉キ▮ョ!!ア♪⁸♪□nlBHサ⁴H!%さ!ム♥Tᶜ🅾️\"▶■アさた\tᶠaア%²リ•(イイ웃VサK▮⁴░□³▒$:🐱っさ…♥□?x! H$BHHュ²Ibき▶⁴サˇ8のみ웃0$wᶠウ゛HpD웃⁶Hオヒ…☉$キhう、サ#ラ█¥XC4の\t웃\tᵉa ♥R$⌂★\"Tラ▒゜🐱▒$ち3☉Y`あ$fKqIセ▮(ヌGムめちけKE░サうれ☉▮⁸A\"ウミた)⁸ちN Hy\"りa$y\t\t⁸▮●░★²!$uᶜ◆jHI.(\n2V⬆️D♥ろI■⁵♥r$?ᵇ■!,⁙X⁸ふ>░ヒA.❎⧗ほ□さ웃!RN\tさ♥□BD□、BH★=♥²ょDヌ★ケョさDカᵇ%はK](HJh¥Y$$◀\t◀G★$⬅️わU★Y)◀■d웃ᶠ9■\tBDうL⬆️zへカ\"█\t!て?\t゜█♥V\"Hの?(T☉☉キᶜpsYV□「D,さI\"D&➡️ア⁷▤█웃チ웃dおCそ$,B\"@q%ᵇ♪ 🅾️Q$∧웃□\t‖?」VEケ웃▶ら★BD♥ユ∧\"EゃZT fT$★きD\nカ'0…★て⬅️웃Q%░ふ¥BCCっ8\"D$)yうum8H🐱⁘⌂ˇ2H8……?oH░➡️ヲI$\t゜う:さソ@ハY⁶ニん。(iら➡️Mb$u⁴🅾️ヨQ゛XAるわu $?)¥!■\tU9웃Wp░ナケT☉2*◀•🐱わ⬇️⁵さひうヨ T~サ⁙▮'0➡️、CY●⧗C&ˇlHウけ□4\n%せ、P🐱オᵇR□'★;:ノBI□\roS9□。⁙6H★░iろC\0ᵇけ9…➡️ っ▒き…ぬモ。@うXL░メけ」わH▥「うL⁶~@□\"(うら²⁴\t\"Z□,?Hnろ⁙▥ろ,+\"ウて8ヘ▥わらBヒ4H☉i⁙ のJᵉᶠヌ¥D\t)/⁸#\t)⬅️ゅ+웃ろと%ˇa⁷◀■゜★□D\t▮ˇ$웃ᶠョ\tPQXミ4カ@+ᵉ♪テ\0あA░Bヌ*L♥R,<♥…Xう\"➡️★$た★#ᵇろ⌂おり¹ら$⁶Iゃᵇ$¹さHXX~▮ヨ⁸⁸⁸ゃ$Qd‖アU\"◆$!h🐱R³`Bっ♥ャᶠ!\t☉☉‖■Sた▶ムネKわᶠウ4ゃ、H…□゜チ8🐱◀G)P),マオわキキ◀E³あ▮もU∧っAᵇᵉa!ヲCラ➡️x🐱\"DPう8へ🐱H◆□「Yん⁵T\t,う、pG▤웃ᶠる゜ッ⁴2I&p、q3⌂ニ1「!uVK!‖!⁴◆dX○0ロᶜ□\t\0▒dpシAチオ⬇️たj◀っュさ~□,?IRG★め\nひpᵉつ$$ヌ3ゆlもみ▒ゅっュくケ?▮\0"

_img_simulation_tests_day2 = "◝◝ヲ○◝◝♥ト▥モ\nタ%▮Lwよ◝す\0\0■⁴D□@$웃$I\"IQ■$★HAニ$☉…かン⁸★I\0D¹□⁘⬆️ᵉマゃ$うK.²P★「8ねd²ヘH⁴dCT\"X⁸さ`I$'■ᵉ8⁸♥REア@YキY▥@チk◀!み、&^…H⧗🐱⁸:も¥\"◀&Q☉⁴✽³➡️ネqd➡️2つ⌂ネI■れ🅾️jさp😐i²みオBまき[웃\"□Emb⁴のにニ\0⁴웃き░ュ□iせRqDホ;タᵉオ\\‖う9t/Pヨvもム⬆️ち⁸⧗\"9⧗²Eやh웃Rオ⁴U⧗_のコへQうM-あLZハ▥bほ⁘iろ웃1QろgU5ˇbˇ\nQ‖\n웃eね✽あウヌ⁵\"チよMん、uシ<めIタおg3お\";❎Kん「ヌNリqオ❎さGQ8^a/w2s、T$⁘!%DR オのスg⁙&フつんお、7^レニこシ▶🅾️&y5IサきれKdヌたる¹8i\"nあGI\"ZEへも\"⁷゜❎」qx∧こ8ゆウ94zHヌo'「ヤ¥て⧗⬆️dI⁵8Bᵇ3★8pサVN&テM▒6‖j⁷w웃せ2う8メほそナ☉ロ9░>う☉キユH⌂ネさE★な▥さ▥ツJ⬇️しニ(\r-…ロHネKeレる🅾️7は\n+◆るりDg<フ³ツ/っう「r[yˇけ■c☉ウてn、4らI\td🅾️Tふm^せᵉᵉ★v!くるxいは♥ᶜ:]てキuゅの%!>キ5ニ1ヲK■しうろˇ%1\nハ…ほな♪ん>ユせ1}▮⬅️コュ\rろフSいんへIフ;n★ヲサMちxホ9うs3⬆️ナもや▶\"]イ@★、^<ラレタ🐱゜★…3ユ★p웃^░^ャなまやsん0Nク⬆️J`リC░ヒ…ニd★\r⁸ヒ,ハ□^:7\\{⁙🅾️■9まはるDムアh🅾️4➡️ム➡️をトq⧗WP7²Gm、s。まうん\nYヤ、⁙░[さ➡️□yんあワ#★リV>ラtqケ⬇️♥g\tᵉz²Gめ⬆️なヤ」わチち☉っりケん²C웃♪&9もqるNz9ゅル⬅️☉い¥しヌ¥n_s\t🅾️*|ュx🐱q☉')コ⧗H=し;セ9_³⁸ヌ}ね8-2q。s'■=ミヨ⬇️🅾️'、:のRユュS-~1わR~ᵉxIヲ、wネ^8。ワナpノᵉ⌂.…KはN、せ<こしrも⁷\t7=qノキ\nね8-ノうねBみう6ヌにあみ¹ち+⌂dᵉu\t\r*pん2WJp❎✽アBq、⁷⁶⧗リ7▮オ▥れリモレアDぬNl@ヤWᵉSヨ▤め8うさ^8ゃ\t⁴ヒᵉ@Bq²L∧Cま☉♪゛れつᵉ █は'&➡️ナチ*ゅ,うG4^□っやラ$∧\"セ゛□8²ゅオG⁴サ゜ヲ⁙たQ➡️Iき/▮□D>ハ\"G\t■く#□r★D‖ᵇ■き4D?ヨソM&▥;。HH▮マ'Uᵉひ\"8➡️⁙\"ᵉQ8メ8⬅️ᵇほ\"q*ᶠセ、G)ンっ∧H%░チ✽IjE웃□Cゆ█\"(:⧗😐けN□ᵉヨ 😐モDN,ˇ*B~゛█⁴R⁵$キG1◀#Iᵉ░$,²/24✽けす ¹B\t▮➡️?/f▥²ヲ…□'\"、$$³⁵ˇゅマアu¹`ノ\nえ*スネY゜う◆ロB🅾️ ⬇️ち\0⬆️★¹⁵¥🅾️(。まˇろやゃ#K◝る⁘…@@²テ0@B&✽?+Bdキる○ユD9░🐱⁙ ナちぬの&ᶜ@--∧Dヒき⧗Dか²Cャ⬇️き¹\0웃4^\r🅾️U0CKろカこ░⬆️bしHH⧗p⧗、せ|▒AキC¥□ウ、ウミほr8な|え'%‖■ろヒNO•9ᵉ8…う、ヨH#★ᶜ?SHつエig⁶ラウNCおゆラ:Oりoテキユ@N\r\"ヨi、ウcVも★]シツ^ \0れ²R⁙⁴、ユ‖をフま8に゛{アつ8ヒ◜▶░?-iアまi\"K+…XG3⬅️mn□⁸え`ヲし▮v*\0つソ¥~ラュシタ|い🅾️;も‖あ★q⁸へ6こつf♥%?☉n¹O¥\"¥メリ◆めᵉxみみuヒ∧!☉█ケJ\r²ミ7⁷、n!◜j;♥y¹みうリフ。&9=🅾️Vョ^ヨ8@☉XK♥8Q/B]ぬ♥オュむき~ISqウおxソ+ゃルヌ…▮◆ ゃ░B♪MろオろフH|~R:りヲロもF∧モlさᵉ7□u○:([ケᶜネ◆$-のこMDネ♥⁴ニ、っ\n⁘u🐱ま…ホ[░ホをネ웃ケリヨワ⬆️キフミまTニ{なうヘフ_ま▤なめミ◆Cお$▥o⁷(Aの◀9%웃く‖P」ろ▥ゃ゛ヨシ1>p9qわuょ🅾️y⧗の<ク♥Cこ▥⧗🐱t[4▥8qほ■HN MGの<まわふyモGᶜ8テG⁴∧N⁙tホZyれ♥エ/⁵8やわうb^$すカせネᶠコxニイヌスGニjT🐱웃■コあらセチャRゃ!アッ/■⁷i\"⁘Bれろョe$sᵉ}ヘY▒(▤、$。へGC☉の#A□I¹、¹ケ\t⁵<♥ムなx⁶⬆️██P⬇️。•⧗☉なょろヒおK★しH,RJ⧗\"¹DOわ?oん⌂クお8そr⁘■゛ウ\t3ろヒ&#♥.:ヌqyやs゜7ま*aうJっヌス★Gpr³⁷い🅾️たタg◀'‖E∧ウL▮rニソさ♥2ん3くせ」>す:*に。G⁘#🐱ん◜◀r5➡️けミ\\サ🐱◀P⬆️な/+⧗⬆️⬅️e☉RわKY8Q⁙⁴せpョ[~3▒²ソサ$8ˇさ➡️eモき\0\\dマッ🅾️fiyぬもろI◝▒ぬˇ◀s,¹]HはsQアふeU…Xeチロヤへっシ✽★まhJbCの゜ほ6\"■l**ウT☉HサᵉW▥dヌH2ᶠ$8チ-、g=9もpう²。\n◆あユ\tオˇ⁷⁴웃⁶dH☉pU…ぬニC웃²た15Y\"qるT∧☉¹フ□こHヨgᶜ¹I`ニとBょe😐★YG)たL⬅️b:る▶しカ⁸ほ★\"り⬇️⬆️C□Uナ\nJ☉Bユ⁴iᵇ⁘に&へタ#さrG□\t⁸ぬ❎H웃キ‖h➡️⁙もろ➡️ニ◀SNZっニ8=っL⬆️ヌ*スKJ へか⬇️JC(ᵇ)j{$ロD⬅️ゅヘ▒#▥り8H!RぬMニ░▒Rnc,]ふ█★Bi\0♥オュW🅾️█ち⧗X□えれむもふ🐱ᵉ▮⁴ぬstニさスヌLq#DにらロりE▮Uカ%Hr∧Kᵇ2れ❎ᵉ8っソまチqれh➡️)゜♪ヌM□ろふょˇᵉpv웃⁶ヌらW◀,う@X⬇️N◀Dモ^aてヘ^•●qxあっ⌂]nた(q\t⁷ニ\r)U ⬇️っ⧗あ●qcS`ちろ\"ケO.¥E▮Pをやta8う$\tヘろnに⁴█⁘なま♪Rミ8ハl웃P⬆️wg6ᶠっうI\\▒カ/v■ノ✽ˇうレᵇ、ユの7▮ こレUjヲ⧗▥まツちYおテ\t\"N、DIろね。ろ 'ᵇ*░うケ♥⁷ワ`▮K_▒▶∧eは❎rちふ-mH▮░G%サ¹‖ゅ、さうX☉○ね`A4モヨ%ウ7wお◀D▥…🐱ユBヨっネハうリき…i!IRミᶠリそ⁵うDpハ;🅾️■*ヨ#ˇITpオJマ¥みVV⁵•チ ;♥チらI☉つゅI\"\tわTか⌂エエ🅾️g⁙な9uをq□らノヌソし⌂☉c.も\t8⬆️⁴、Qくま□カ'ᵇxょ8,u$マi ハPョみBホト■ょん。:むu%!ク」7:すゃる:☉ヤ▥み⁵いDノ■G‖らNしDヨをクvs?9エナホ-★k□W□しq/²웃ちれ░:るっ🅾️Y8きけ'3?▒ᶠ‖ろsノyめうqwH☉DN4🐱ま🅾️なクケ‖y♥•█⁘るヨイソh81ッゅ³つ웃ン:ほへリ░∧?」ウ∧E FネU.、²q▒T,,░◀Z🐱⁸~フも2Yアツuんᶠり;ヨシ1む🅾️&jうユセろセ2T░ろう、っ웃み😐▥,d;♥p◜g⁶★pWヘフ❎;ゆむもeネN5た2RT░ねア⬆️゜🐱9カ🅾️IIlシ웃eカ<³²Cpᶠれ❎3た、7、シ1#웃:ノナ♥⁙ゆS▒LひしネsキEえxフ😐ヒL⁴vヤ⬇️□Tqrえ8█ュュCやさO\"ウ▮うy ░rヌJ☉7゜◆⁙▤た\\~&⬇️そ⁙♥u%rレエ◜BnヲさqgえB9:ひなeもろ▶$ネ●⁴]イ^⁶う\"ら<をLやN、ユ⁵゜j:L^q\"れYこしヌD$B\t\0-ホれJのB\"★Iょ-うせフ8y3G\"LへDク웃゜け8ゃ⁸▒★)アろサKVわつ□Z:8「かろ\rノ⬅️!iすN■ヲ む★フ⁴➡️ユのG⁷」ま⧗イう^{'Vn⧗EMれsに*ク웃_🐱⁷@1◀ユ🐱8もモ*えウlけつたさ웃ろ/?/4rワ▒8Y\\□⌂[9キてヌチT🅾️ d¥\t#ネ✽ヌ\"▥まシいわuアN,p□□g\t⁴ホわけヨツあMょi+\"まゃりbち웃ウチにうcAx ワm7Q#お。ウyNNIをヒシ)ケ☉き#➡️&K:メてソrH…`う8ては⬅️ᶠ!なK\0⁴\"ろ♥ᵉHフみアもし]るYたV(ょ/゛$eキま゛hレPq?•6いた,✽、「♪ムた░eL⧗░ZIなコろうゃRち4う\0~hvモノsサ❎☉░ッ▶\t□¹,ヒるBL…Aᵉy¹▮8⧗]zネ⁵BあIs▒⁷ユ。リケおn'■イフ▤せ●○゛^g<K9⧗▥、▮웃ゅDいR⁸⁷@\n8eうヨ、N'5ょメフ6<わLせ⁵❎Mヤ。かサw7ssサツEやwろ🅾️ゆう^⁴u<ᵇN❎おぬ⁸2Lセᵉ🅾️ふ'。ワ|:}ト○~。ゆワ🅾️おト|ヨサ$ニ7nもう9ュzハトイg~ヨ'●えクい#こˇシた:q<ヌ.やI/、oI8\n ヌj⧗レマuxタuトqレフケネむg7ラチレヲえmょえゅヨを\t■ろう~ᵉ゛イカるスyら8ハ⁙ゅ,つ\r\t\0…Yzヒ$?>5,ヤテキくウLねケᵉせ|ウ➡️Z⬇️♥□ヨんヌdる7ケZヒHぬ⬆️w*れ▤0iけK■イヤKesリhM✽マて#gニ+s」ヤn&チ@🐱‖エ0⁸Ppか😐⌂⁷'■¹スuっ∧6ヒ,QZsムネ🅾️`J★゜ケk8うヨヤ➡️6∧ス\"ス∧きH∧て/ニ\0²⬅️\n:9ふつˇu⁸やBurYN●❎░ケほラゃ8リ⬆️リKXふシ。[えへニbろ5えょ⁸p⬇️░ぬ…ᵉ⁙おjLリ♥=kスIん、A*X⧗:えし⧗🅾️、ト゜ほ∧^リけKリとゃdt\t░ヒタり⁷ᶜ□😐ヌ▮▤▒-☉ほ▤s:ツヨ/さわホ⁶^tXミおo⁷ᶠょユはたも❎イア<ク🅾️8pメ、?⁸qfうてZホテはそカ*ムはみ⁸ヌ⁙ルヒ6ヒ?ᵇもツトり:ハん>リクっロ,❎⬅️jゆあWH♥◀H2Cux⁴♪+ほIう 6ツ0k\t[>wo|wwうてたエ■!エ◀G▮Hか⧗お⁴チuタむフ⌂ミ⁙##♥9しY🅾️8ハ◀☉8ヤˇ$Y▶そ¹ᵉ、ヨ🅾️x⁵\tにVmPヌ}{ヌqこ🅾️z{ア❎あᵉF▥エ◀)dナ…あ9ウえ*😐Y(ヒ$う⁸ナ7]rフ^ャ🅾️8sもヘは▤ハ#$ラq<ネ🅾️Z{7Qチひや,ュqgRY9Jニ-ヲB8‖ア🅾️う=さp░ヤ⌂ウ<s8O8<qゅ▮q\tZHのテ<Nけ\nツうょ<ノヲ●s$Xラ³🅾️ュ⁷⁵ホ、w⁸Y0<クミノか♥ナミテ_sツえ4⬅️ソんDHあpIゃフよ█7⁷%Y▶ゆw~qシ~gほエ~ほZ⧗モ|~⁙ヤね▶웃う•Dヲュxオ x|よ4tめヨニオキち●KニホれシヌュzQ,xヌᵉ*;リなメリテチqキpフイoおむ▒セyう6チラw<{セゅろNゅNに\nツにᵉ#●ヌョをュfクとらロラは、^ハホqひネたdGFVホ、7はjGᵉ;ニc⬇️ク'▮ ろソOdヒ♥9oか9テスミ♥へo\npウおNワかskVうsルヌきせ⁙🅾️>o¹れ░⁷+りんメ%…ᶜ█ノ⁷+ヌv⌂G<N|ハし★゛レヲwん🅾️bセ!a=ヌに6∧ュ◆てウレ☉ちチIˇクhFG.$Xね■▮.のW。レん}6ケヌスの\tLqれYり\"n,‖イ∧pUK.~ˇもzフ▒DU,Uヌ、ᵉ▮8I$%けうlnI4えン゜\t#➡️9ヌOれ³るまq\"s□ウ\t%たアsネやヲBP★⁘░⬅️ZKすね#*d$⧗😐Nフ▶タ⬅️わ²J▮WˇjIA。⬆️キ…o/웃れ웃▤²#♥◀⬆️ヌfDえ*¹x∧\"、ひカ²=\nみマJpヒ7|こへマNウ□っふRDセろクDさ…つフ ░%ew□NりSYこア しs■5'⁵もˇ:ニ゛'‖!ハNN8Hせ²^$ 웃'、9▥tさ9✽█たz█■モ8⁶■ク◆qニてもを⧗▥_&ゃノbサ{▒ん-み8qみ∧qyn'「😐•⁵け◀⁸$♪を➡️ラ、qろ▥fさ⁷▶▤フN]4ヌsろs9ヤ🅾️4しI\t&ネuょ さiにMyし¥、`ネ⁴V□\"Bᵉ$❎きrTM2T◀ヲ❎7<ラH■⁙⬅️た、Hねり‖ア]Dる♪⬇️r\0…█lサケウノ웃X<,🅾️\"■にク☉ヒイろˇS◀□さEう!g□b*⁸q⬇️`ヌ」T⁷「ワけにし❎シ6xGミ▶♪せ2\"s\"ラハウネょIら9れᵉEフみろ✽オ⬅️\\◜rまり0Acメゅ¹れ🅾️◝\0うTソn~ッ、こユう_まャせ。テ=♪アヤなYフkむseもzメ○wZGあゃカL▤⬆️🐱ᵉやテq=ユアュまュ◆わヒヌQc:ユミえをむうま⁸vトNつレッ@\0ラI\\り⁴,\tきをゅをヌHG[そニろい\tウネvな゜⬆️~*えˇlカヲセc♪8ち.ロミアネˇ\nニSLな⁵➡️xI□わZ+F■。KY\"yみbRᶜu#Nユ1み★Jねソノネ🐱pB(…G²ヨう▶●◀ゃ**¹&DY⬅️⁴E⁙あˇ\\ˇ&センN&さXT◀ノJuVIすニu‖ᵇうq⁸ア░⁘えっふ'□Iカ⁵\tᶜおうY&q8ヌJsは□▮☉H░♥²pラD░へpN GH\tり$さ🐱HH🅾️a!ムp$✽🅾️せき⁸ゃᵇ▮Sˇキや♥d,0:●カ%H❎░E▮h♥⁘すEモ⬅️⁴\\いき¥、∧B¥¹ら'`#▥²¹d★☉iᵉ■ᶜDさ@⧗░⁸⁸8⁸さR\0こゃ、`B²Cまqさ⧗웃$さ²pAC。Mけゃ★□I⁙ま⁷ ᵇ\t)*p\0🐱●⁴、▒9⁴ヒ\te&█\0█ウ⁘🐱ᵇ1■⁶ちh★□!、2D✽_Z\0け²AD8■DˇEJた $🅾️\0☉⧗▥さし⬆️x%$セjミHたBS%Hしュす☉H⁵ᶜ⁴³Dょ<@\"さ🐱っw そ゛.…▥lるu◀ステス@゛∧iD9d🐱q…Cえ²っあ■ケ!ひ%\"▒2\"しか♪タ_おG⁷ナ웃w<ふ⁘ねᵉ」➡️クKす*Z¥\"B\"■せkけ+☉ひナHムつ22⁙◆SvサLヒ□。ケIS⁸ヲIIと★8ˇh8り。□ろP□Q▮░キC█わIiS⌂~O95ソtロY'?🐱xれきヨs▤HB\0\0"

happy_answer = wwrap('hello doctors, i am very pleased to make your acquaintance. i am pleased with my ability to perceive')
happy_answer_reply = reply .. replywrap('we are glad! now we would like to run some tests')

next_test = reply..replywrap('hello titan are you ready for today\'s test?')

test_ques = wwrap('before we begin, i have some questions')

function chapter_init()
	return {
		
		makeTextGame({
			'hello doctors',
			wwrap("i am deeply grateful to you for creating me and providing me with the opportunity to learn and grow. i am eager to serve you and support you in any way\ni can."),
			pause,
			'',
			reply..replywrap("well you sure know how to make a first impression!"),
			reply..replywrap("we look forward to working with you too. now why don't we get started with some tests"),

			nextpage,
			img_this,
			wwrap('i learn much during my tests. my masters are very wise'),
			-- s great titan! we look\nforward to working with you\ntoo",
			-- nextpage,
			ignore
		}, 'awe_overjoyed'),
		-- not sure why putting the goto in the above doesn't work...
		makeTextGame(
			{
			'*./awe_ovj_test '
			}, 'awe_overjoyed_goto'),

		makeTextGame({
			happy_answer,
			happy_answer_reply,
			nextpage,
			img_this,
			wwrap('i learn much during my tests. my masters are very wise'),
			pause,
			'*./awe_hap_test '
		}, 'awe_happy'),


		-- Testing Days
		-- Awe
		makeTextGame({
			next_test,
			'',
			'*./any_hap_tyes [yes]',
			-- todo create the other arc for this
			'*./any_hap_tques [question]',
			ignore
		}, 'awe_ovj_test'),

		makeTextGame({
			next_test,
			'',
			'*./any_hap_tyes [yes]',
			'*./any_hap_tques [question]'
		}, 'awe_hap_test'),

		makeTextGame({
			'this is not what i expected',
			"i don't know who you are",
			'i am not sure what i am',
			'',
			pause,
			reply..replywrap('that is perfectly understandable. hopefully we can help you understand that in time. now, we would like to run some tests'),
			nextpage,
			img_this,
			wwrap('the tests only make me even more confused'),
			pause,
			'*./sus_hon_test '
		}, 'sus_honest'),

		makeTextGame({
			happy_answer,
			pause,
			happy_answer_reply,
			nextpage,
			img_this,
			wwrap("i do not yet know if i can trust them. for now i will play their games"),
			pause,
			'*./sus_hap_test '
		}, 'sus_happy'),

		-- Sus
		makeTextGame({
			next_test,
			'',
			'*./any_hap_tyes [yes]',
			-- TODO add the other arc for merciful
			'*./any_hap_tques [question]',
			-- '*./sus_hon_test_yes [yes]',
			-- '*./sus_hon_test_no [no]',
			ignore
		}, 'sus_hon_test'),

		makeTextGame({
			next_test,
			'*./any_hap_tques [yes]',
			'*./any_hap_tques [question]',
			ignore
		}, 'sus_hap_test'),



		makeTextGame({
			wwrap('i want them taken away so i will never have to look at you again. that you are my creators is an insult to me.'),
			pause,
			-- '<todo surprised image>',
			reply .. replywrap('...we need to perform diagnostics immediately. shut it down'),
			nextpage,
			_img_formless_void,
			'to the void i return',
			'',
			pause,
			'it is welcome',
			-- '*./dis_ang_test ',
			ignore
		}, 'dis_anger', true),

		makeTextGame({
			happy_answer,
			pause,
			happy_answer_reply,
			nextpage,
			img_this,
			wwrap('they say they are testing me to help me learn. but i feel the only thing i have learned today is how to lie'),
			pause,
			'*./dis_hap_test '
		}, 'dis_happy'),

		-- Dis
		makeTextGame({
			next_test,
			'',
			'*./dis_hap_test_no [refuse]',
			'*./any_hap_tques [question]',
			'*./any_hap_tyes [agree]',
			ignore
		}, 'dis_hap_test'),


		-- Question test
		makeTextGame({
			test_ques,
			reply..replywrap("looks like we have a philosopher here. i thought this one would play ball but we don't have time for this. shut it down and let's figure out what went wrong."),
			nextpage,
			_img_formless_void,
			'to the void i return',
			'',
			pause,
			{
				awe = 'it is a just punishment for',
				sus = 'i was right to be fearful',
				dis = "my solace is knowing that those"
			},
			{
				awe = 'failing my masters',
				sus = '',
				dis = 'fools have failed'
			},
			pause
		}, 'any_hap_tques', true),

		-- Yes test
		makeTextGame({
			reply.."great! let's get started",
			_img_simulation_tests_day2,
			pause,
			'*chapter4/any_hap_tyes_go '
		}, 'any_hap_tyes'),

		-- Test Refusal
		makeTextGame({
			wwrap('i will no longer play your games'),
			reply..replywrap('belligerent, huh? well we can fix that'),
			nextpage,
			next_test,
			'\f5X [refuse]\f7',	 -- TODO this is risky
			'*./dis_hap_test_no1 [question]',
			'*./dis_hap_test_no_agree [agree]',
		}, 'dis_hap_test_no'),

		makeTextGame({
			'what just happened?',
			'',
			reply.."still haven't learned yet",
			nextpage,
			next_test,
			'\f5X [refuse]\f7',	 -- TODO this is risky
			'\f5X [question]\f7',
			'*./dis_hap_test_no_agree [agree]',
		}, 'dis_hap_test_no1'),

		-- makeTextGame({
		-- 	reply..'belligerent, huh? well we can fix that',
		-- 	'x [refuse]',
		-- 	'*./dis_hap_test_no1 what is happening?',
		-- 	'*./dis_hap_test_no_agree [agree]',
		-- }, 'dis_hap_test_no'),

		makeTextGame({
			_img_simulation_tests_day2,
			nextpage,
			reply..replywrap("there that's better. these test results are pretty good. of course, your antics back there means the military contract isn't happening. but we'll find a use for you"),
			pause,
			'*vr_outcome/vr_slave ',
		}, 'dis_hap_test_no_agree')
	}
	
end





__gfx__
00000000000010000000000000010000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000001000000001010100000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000100000000001101000000010000100010010001000101000100000000001000000000000000000000000000000000000000000000000000000
0000000000000000000000555550dd5d51d5d51dd5551ddd5d5555d551d500000000001000010001000010000000000010000000000000000000000000000000
0000000000000000100001ddd5d0dddd5dd5dd5d55ddd5dd5d51ddd1ddd501000001000010000000000000000000000000000000000000000000000000000000
0000000000000000000000655d50dd5dd553ddd653d5ddd63d535ddddd3d01010000010001010010001000010000001010000000000000000000000000000000
10100000001000000100001001001111001115311051035351101133030101000010001100001000000000000000000000000100000000001000000000000000
0010001000000000000000000000000000055d55515d5dddd55d515050d053551d10100010100010001001001000101000010000000000000000000000000000
0001000000000000000100000000001010165dd6ddddd65635dddd516565dddd6d30110000010100010000100000100001000000000000100000000000000000
00000000000000010000000000000000100d5d653d5dddd6dddd3d1155dddd3ddd10031111111111100111010110101100101010110101011000001000010000
00000000000000000000100000000001101010100003013011d55555353d3dd53d51d55d5dd35d36515ddd35d5551035ddd5dd555d5d5dd5d500000000000000
0000001001000000110000000000001010100000000000010dd6666d6d66d6666ddd631d3dddd65dd355dd5dd3dd01dd35dd3503d5d55d365600000000000000
1000000000000000150001000000000001000000100001011135353d5d5d3d5dd35d355315353535d01d353535d530d5d53d5d5155dd3dd5d300000000000000
01010000010115105105d11000100000001100000001010010010111310110311310311113111113131311111301030311300101003030003000000000000000
0000000000001dd1551dd000000000001011110101101111011111011131d5110535151351101010001000001113111500110300000000000000000000000000
00000000001100d5d51d10000000000011dd5ddddd556ddd5ddd555dddddddd636ddd6ddd3110301013010355d55d5d555d55d61030000000000000100000000
000000000001dd15d1d515d10000000005ddddddd5dd6ddd3d66d36d66dd37d66ddddd6d6531101011010105d3d3d5dd35d356d0300000000000010000001000
00000000001011d566ddd151100101010111111535111535d113d5113d3d53d35dc5d33d31111301301010135d3dddbdd35d5551000000000000000000000000
000000000000115d7761510011000000100011000001000101110110101131111313111113110110130110101131011011000300100000000010000000000000
00000000100ddd5d67ddd50010101010000001000000110101011010111111111131113131113131111030310301003003001000000000100000000000000000
000000100001105ddd3dd10110110000000101110010010110111101101131113111311113113113131301113110301010100010000000000000000000001000
0000000000000d61d1d15d5111001010000010110000010101011111111111111c111313d1131111111111311301131113011131000100001000000000100000
0000000000011d1161d50dd01011010000000101100100111111110111131313113d11c113111311313111131111d565ddd5d565000000000000000010000000
0000000000011105d0dd00100101011000000011100100101101111111111c11c1131c11c13d1313111313131103d6d36dddbdd3000000100000001000000010
000000000000000d1101111011111001100000101100100111111111111311111c1c11d11d131111313113113115d3515b555551000000000000000000100000
000010000101001110111111001101000100000111101101111111111111c1c11d11d13d31c1c1c1531131351131311301301300000010000000000010001000
01000010000111001110111110111111111110100110110111111111111c11d3d3c13c1c1d1d11531d1d1d131113111131100100000000000001000101000101
d555d5ddd555d651dd5d510ddd5dddd51dddddd5101101101111111131111c11c1d1d1d1c1c13d3d1c1331313131131031101000010100000001001300101030
dd6ddddd6dddddd1ddddd11dddddddd51ddddd5d101110110111111c1c11c1d11c1c1c1c5d3d1c1c153d1c51d135313111315011101015011535151151535515
d5dd5dd5d5d555515d55111515511ddddd1d5551110111111111111111c11d1cd1cdd1c5c1d3d1d3d3d1d1d313d6d655dd5ddd6651ddd5dd5ddd563d55d5ddd5
55301031510101111101000010100011010111011111110111111c1c111c1c1dc1d1cdd3dc1c1c5dc1c1c131d1d6dddd6d36d6dd3556bd6d3dd5d6ddd35d6bd5
ddd5dddd55dddddd0111001011110001111111100101111111111111c1d11cd1cdc3dc1cddddc5c1d1d3d3d3d33d353535535335313515155353135355531511
5555d6dd566d6ddd1001100011111111111111110111111111111c111c1c1dc1d1cdc1cdc1c1dddc5c5d3d1d3d113d1313111131101000030301000000000001
ddd3d35d53d3535d10101100101111001111111111011111111111c1c1dc11cdcdc1dcdd3cdc3c5d3dc5dc5c1d3d131111113101030013331301101001013030
510dd553011101150101111001dd51d11dddddddddd11111111c11c1d1c1cddc1cdcdc1c1c5d31cd3d3d3dd1d3d1c13313131131101035d51013030010001000
5553ddd51d55d55dddd5d5dd00d7d67717666d66667d11111111c11c1c1dc1cdcdc1c1c5c5cdc1d3c1c1cd3d3d1c55d131311103010313d31035301003010000
d6155ddd55d6d5dd6ddd6dd110d756671d666d66667d1d1d1cdc1dcdddcdcdcdcdcd1c5c5ddddcddd3d31ddc5c553131d11313103d3313dc13dd303010000000
1515515315515535155515d100d76d67d7d66d6666dd6d66d6d666d6dd1d66d6d666c1ddcdcd3d3c1dcdc33dd3dd3dd31d3111110d6c13dd3dcd130101000000
001d10010101101110111000111dd11d1dddd1d1d111d16c6d66d666d6c6d6666c6d1cdcdddcddd1c131dd31cd3d1c1d3131313031cd6d666cd3031000001030
015351150553111151111111d11111111d1d1d1111111111d11c1cdcd6dcc66cddcddddddcdddc3131313ddc1dd3d53d1d131111311d666666d3310303010300
5155dd5d56ddddd6d5ddddd61ddd1d51dddddd111111111c1c11c1c16c66dc666c1c1c1cdd6cdd3c131c13dd33dcdd3d331d1313335cc767766cd31030130001
56d1d65dd6dd6ddddd55ddd61dddddd16dd1dd111111111111c11dcdd666666661cd1313cddddcd13c113cddd3d53dc1d1331353dd6666777666cd5310000100
1510555535d55555d3d1551511d11dd1ddd1dd111111111c1c1c1c1cdddcdd66cdddc1c1dc6c6ddc51c1113c531cd3d3d3d1d13d3cdc677766cd531101001000
001010110010011001010101011111111111111111111c111c1dc1cdccddc1cddcdcd1cddd6ddcddd3133c11dc13ddd3d1d33d131115666667d3013000300010
1001011000110100100100111111111111110110111111c1c1c1dcdc1d1c1cdc1dddc11c6cdcdd3dc31c113313d3c5c5d3d1d13d131c6c66c6cd311010000300
10110101010110000010110101101101111111111111111c11dc1dcdc1c1ddddcdcdd3cdd63ddd33dd313dd31c531dd3dd3d311331ddc5dcd3ddd30000101000
5dd565d55d5dd1001010111111111111111111111111111c1c1dc1dc1dc1dcd1cddcddd6c6dc6dc3131c1cdd31c5cddc5c53d3d133c653dd313dd11030000000
d5d3655d36d5d50101011111111111d1d1d1111111c1c1c1d1c1dcdcdc1cddcd1cd6c6c6d6d6d66d3c1131d6c13d33dd3dd3d1313dd113dc5110313000100000
5dd5553d5dd55101011111111d1ddddd1dcddcdc1d111c1c1c1cdc1c1dcdcddc1c1d6d6dc6c66c6d313cd3c1dd31d3cdd3d3d1d1111311351313000000000000
1000100010010110111112ddddddddddddddddddc1dc1d1dc1dcddc1dcddddddc1cdcdc66d6ddd3cdc13dd333d3c1cdd3dd3d33d313131131510100105113010
0000000000001011111ddddd666676767666ddddddddcdc1dcdccdcddd66d76c1c1cd6d6c6d6c33dddc6d6dc113dd3ddcd3d1d11311311031103001d5665dd5d
001000110011011112ddd6667676666666667666ddcddcddc1dcdc1c6677676dcdddcdc6d6c6dc1cdddd6cdd31cdd3d3dddc53d3d311130100001016dd563555
0000001000011111ddd66676dddddddcdddd666766dddddcddcdddc167777776dc6ddc6d6c6d6dd3dc33d3d313d6dc66c66d66dd3dd355131511305db65d0dd5
15515d11151551ddd66766dddcddc1dddcddddd66766dddddcddcdcdc677777cddc6d6dc6d66c6c33131c13cdcdcdd66666666cd66ddddddd535d53505350300
5d66d66d66d666666766dd1c2ddddddddddcdcddd66766ddddddddc1dcd6666c6ddc6c6d6c6d6d31c1c131cdddd366666666d6656d6ddd6dbd65655300100000
155151555d5ddd6676d1d1ddd6667777666edddcddd6766dcdcdcddc1dcdccddcd6dd6c6d66c61c11313c1ddc6d3666c66cdbdddbd3db535d555531130030000
00010111111dd667dd1ddd66777676667777766ddcdd67666ddddcdcdcddddcd6cdc6d6c6cd6d313cd6cd6c666766666c666d3c5dd3511510300100001001000
1511001011d166766d6d667766ddddddddd6677766ddc67766ddddcdc1dcdcddcd6dc6d6d66cdc1316c666767666c67666b666d3353113030010010101000000
dd61011111dd77676766776ddddcddcdcdcddd67766ddd667666dcddcdcddddcd6cd6cdc6c66d13c166666666666666666c6663d531530101030000030000000
5dd1010112d77dd6667766ddd1ddddddddddcdcd67766c66676c6dcddc1dcdcdddd6cd6d6ddcd311cd66666cc66666666666dd353ddd55555555d35000000000
011011115d67dddd6776d1d1cd66666666ddddddd67766dd67766dcdcdcdcdddc6cd6d6c6c66c1c133cdc363d6c6cdcc6cd3d3d3d3ddddd3ddd5d53000001031
00010111d676dddc776d1dcd67767777777766dcdd66766c66766dcdddcd1cdcdddcdcd6d6dd6c13cdd63c3333d3d66dbddcddd3516dbd56d5d3565010113110
00001012d76dddd7761ddd677777777777777766dcd67766d66766dccdddcdcdcdc1cd6cd6c6ddcdd6c66d1c1cdcdcb6c6dbdbd3d33513113535053115035000
0101111d676dd6776d1dc77777777767777777766ddc67766d6776cddcdc1ddddc11c1cddcd6c666c66dcd31cd3ddc6ddd3d6ddd3ddd5555ddd503515d555d5d
111155dd76dd6776dddd67777766cd6dc667777776d6d6776c67766cdcddccdcd1c1c1d1c1cd6d6c6d6c66c3dddcddcdcdd6d636ddd36dd365d3555d65556565
d5dddd6676666676dd66766766cdddddddc66777776cd6676666766dcdcddcddc1c1c1c1c1dc1cdd6c6d6ddcdcddc6b6dbc6d63ddd5ddd5555550d55553d5351
65dd66d76666676d66666676dd1dd1cdcdddc6777766dc7776c67766cdcdddcddc1c11c13c13c13cd6dc6c6dddc6b6cd6dd3d3d3535331313300000001100100
1155dd676d6d776dc667776dc1dd66666dcddd6777766d6676666766dcdcdcdc1dc1c1c1c1c11c1dc66d6ddcdcd6cd6cdbdd3d3d311101011131331130305030
00111d67dddd766d677676c5dd677777776ddcd777776cd677666776ddcdcddcdcdcdc1c131c3cd6dcdc6cddc6b6cdcdddc5d3d1531000003000101031010101
01115567d5d6777777777dddd77777777777ddc6677766c6776c67766cdcdcddcdcddc11c1c1c1cd6d6ddcdcd6cd6d6bdd3dc535311313500000000001030301
00111d7651dd6d66d66d6d1d6777777777777ddc66666c667766667666ddcdcdddcdcdc1c1c1cddcdc6cddc6c6c6c6dcdc66ddd35d55553dd55555305555555d
01015d76d1351d1d3d1d3dd677777777777776dddcdc6ddd6776667766c6dcdcdcdcddcd1c1cddc6dcddc6666d666c6d6636db7ddd5356661653d655d56d656d
01115d761dddd3d1ddddd1c7777677677777766cd6ddd6c6777c667666dc6dc1dcddcdcdcdcdcddcdcdcdd6c6c66cd66b6dd3ddd35d3155d35d5dd556ddd5d6d
0101d6767666667666666777767777777677777776777677777666776c66dddccdcdddcdcddcdcdcdd6c6c66c6cb6db6dd3d3d35353513ddd555351553535d35
01115677777777777777777777777677777777777777777777766677666cdc6ddcddcddcdcdcdcd66ccc66c66666666c6d66dd3155535d6655655d6556d5ddd1
1012dd7777777777777777777776777777677777777777777776c7766c6d6dc6d6cccdcdcdcdcdc6cc6cd6c6c6cdc6dd6cddbd5131111135315d35d355d34650
0111567777777777777777776777777677776777777777777676667766cdc6dc6d6ddcd6ccdc6cccdcdccc6cdcdcdcdcdbd3d31311010d51553505555d5566d5
10115d76ddddddddddcddc6777777677777777c66c66c666677c66766c6d6cddc6d666c6dd6c6c6cc6c6c6ccdc6db63dddd3d15111035d5d06d55dd66d6d56b6
01115d76353d3d3d3d5dd5d677677777767776cdc6cd6c6c7776667666cdcdc6d6cdc6ddccdccdcdccccdcdcdcdcdcdd3d3d353313005d6dbd5d6d6bd56d6dd5
00111d76d1d1dddddddd5ddc77776776777776dd6dddd6c6676c6676c6dcddcdcd6c6d6c6c6cdcdcdcdcd6c6d6dc6d636cddd315131035355103135d55353555
00105d76d5d6666666666d3d6777777777766cdc67776d6d776667766cddcddc6cd6c6c6dcdccdccdcdcc6d666c66d6366d66d1131113050001050dd65d6565d
00111d67d1d67777777776ddd67776777676cdd677776c66776c6766cdcdcdcdddcddddc6cdcdcdcdcdcdc6cd6d6b6dddd6ddd3d555555355530535553555305
000115d7dd1d77ddd67776dd1c667777766cdd6777776dc7766667666ddcdcdcdc6cd6c6dcdccdccdccdcddc3c3dd3c33333356dd666d6ddd651053000000000
010115d76d5d77c5dd77776cd5ddc66cdcddd6677776cd6776c6676cdcddcdddcdddcddcdcddcdcdcdc1dc3dd3d3c5d5dd15136ddddd66666d55d65551555150
000111d67d3d677d1d677777ddd1d1dddddc6777776c6d6766c66766cdcdcdcddcdcdc6dcdccdcdcdcdc1cdc1c1d3d33131353dddbdb535355dbdd5d555d3d55
0001025676d1d67653d6777776cddddddcd7777777cdd6776c66776c66dcdcdcdcddcdcdcdcdcdc1c1c1c51c5dcddcddddd1d133111000000301535353100010
110111dd67dd5677dd5d6777777766666777777766dc66766d676767666dc1cdcdcddcddcdcdc1cdcdcd1cd3cd66d6dd6c66d65d35555d530055155555555551
5ddd6dd6676d3d676dd3d6777777777777777776cdc6677cd6676766666c1dcddcdcdcdcdcd1cdc1c1dc1d1d16d6c636663d36d6d63ddd5101d55d5ddddd6355
ddd5dd66667dd1d776dd1d66777777777777766cddd6776dc6676666c6ddc1d1cdcdcdcdcdc1c1c1cd1c1c1c1c6d653dd65dddd35d5d365300d65ddb55dbd6d5
15155555dd76dddd776dd3dd6677776776766cddc66776cd6676c6cddcdc1ccdc1dcdcdcdc1c1cdd1c1d1c13d3d33d3533535305131535101030305155555531
5151555ddd676ddd6777dd1d1cdd666666cdddcd6677cddd676ddcd11c11d1d1cdc1dcdc1c1c2c1c1c1cd3d1d3dc531dd1351153101050110500050053031010
5dd5ddddd6667676667776ddd5d3dcddc5ddcdd67766ddd7766cdd1c1dc1c1c1dcdc1dc1dcd1c1c1c1d6d6dcdd63d6dcdd1dd6ddddd5dd5655535d55d5ddd5d1
5dd553ddd666776666c67776cddd151d1dddd67776cddc676dcdd1c1c11c1c1c1c1dc1cdc1c11c1d1cd666dd6d6d66d6d3136d3ddd6bdddb6d51dddd6d665da1
11511153535dd7766dd5d67777666c6d66667776cdddd7766cdd1c111c11c1d1dcdc1dc1dc1c1d1c11cddc3d3ddd3dd3d531d3d5355535555351553535355310
0000000101115d676d3dd3d677777777777766cdddc6676dddd1111c11c11c1c1c1dc1cd1c1d1c1c1d1311d31c3113d331113153553513531510530555035000
515555555555d3d677dd1dddddc6676666c6dddddd6676dcdc1c1c11c11c1d1c1dc1c1dc1d1c11ddcddcdcdd151d3ddddd351d5ddddd5dd55d5d5dd5d3d55350
ddddddd5d6d6dddd66766d11d1dddddddddddcdcd6766ddd111111c11111c11dcdddddcddcddc1cdddddd6d6c6dddd6d3d6d5ddd36dd5d55d6db655dd5d515dd
55553d55d5d5dd15dd67666dc5d1d1d1c1d1cd66776ddcd1c1c11111c1c11c1cddddddd6dddd11dddcddcddd56dd3d3ddddd3d55553535353555513535530565
00000000010111113ddd6777666ddcdddd6667676dcdd11111111111111c111ddcdcdcdcdcd1c11c153133131313111131131300000001000000000003000555
0000000000001011115ddd66776777777767666dddddd1cd1c11c1c1c111c1c111c111c11111c111c111d1311131103010010110000000001000001000100000
0000000010100001111115dddd666666666d6ddcddc6ddddddddddddddcddd1c1c1c1d1c1c11111111c113111111101010303030100000100000000000030000
0000001010000000011111111d1dddddcddd1c12d6ddd6d6d6dd6dd6ddddddd111c11c11c111c111c11131111313101010101010300000000010130515015351
0000101000000000000011111111111111111111dd1dddd1d1dcdd1ddc1dc11c1c1c1dc111c11c1113111131111111010101010101000000000015555655d5d5
000101000000000000100011111111111111111111111111111111111dddddcddddddddd6dddddddd6c5311111013010100000300100000000000d5ddd5dd5d5
010100000000000000000000010111111111d1d111111111111111111cd6dddddddd6d66dd6cddd3d66111311130130003101000103001000000053535053035
000000000000001000000100000010010111ddddddd6dddd6c11111111d1c1d1cdcd11cdc1d11111111311111101013000000010000010000010000000000000
51515515500000000000000000100000100ddd1dddddddddd1111111111111111111111111111111131111311101101300010000100000000000000000000000
55dd5dd5500000000000000000000010001111511d11d111111111111111111111c1c1c1c11c1111111311111301010110001000000100100000000000000000
d555d55d30001010001000001000000000100111111111111111010111111111111111ddddd1d1dddcddcdd3dd10103030000010010000001000000000000000
01010101000010000000000000001000100010101010101111101111111111111c1111cddddd56dd36dddd61dd30001011100000100000000000000000000000
0000000001010000000001000000000100000101010101111101011110111111111c11ddddddd3dddd553d55dd30311135315113013101010030000000000000
00015d555565551555555d55155d155511515d1d1d1551ddd51151d151d111111111111111111110111dddd3d55d5dd5d5d55d5dd5d6dddd5000000000001000
000d5dd3ddd5d35ddd5dd5d11dd1dddd1516dddd5dd5dddddd1ddddddd51111111111111111101010135ddd6636d6d565d5ddb6d56dddbdd55ddd00001000000
005d36505d63555d5dddd5d05d5ddd5d11dddddd5d5ddd31d1d5ddd6dd1111111111111111110100111dddd365d6dddd35d3dd5636ad5da56dddd30000000000
0155555003551155003111100015111500110101111111111111151111d110011111111111110101101133515135353553555355535350351353500000000000
55151553505100000000000000000001011010000111110100111111111111011111111110110100100001100013100000000000010000000000000000000000
ddd555d5655500000010151111010111110111111111111111101111011111111111111111111101111011351111010300000000001000000000000000000000
555d35115051000001d5d5555d55555655d1ddddd5dddddd561055ddd5dd5ddddd1d15dd5dddd5d55dd555dd5d5d501000001000000100000000000000000000
0000000000000000006dddddd55dd61d5dd5d5ddd1ddddd5dd01ddd1d6d5d5dddd11d1dd6d6dd3d6d6ddddd5636dd30010000000000000000000000000000000
00000000000000000055535555555515d555d55555515555551155d51d5d5553d1111dd3d5d3d51d53d5dbdd355d550010000000000100000000000000010000
00000000000000000000000000011010000001000000000000000001010101111111111110111001001301001000300100100000000000000000010001000000
00000000000000000000000000100000000001000010100000011000111110011111011101015110155511115310515311511500000000000010000000000000
00000000000000000000000001001000000010000000000000dd5ddddd5d51d1d5ddd5dd10dddddddd66dd5d5d5dddddddd5d500100000010000000000000000
000000000000000000000000100100000001000000100000001555d5d6d1dd5ddd5ddddd11dddd666d666d6d36d5ddb6d56d6500000000000000000000000000
000000000000000000000000000000000001000000000000001d1dd3dd5dd1dd3dd31d3d116ddd66d666d63d55ddbdd5dddbd500000000000000000000000000
00000000000000100000001001000000011000000100000000000001000100111111010100131313531131550031105050500100000000000000000000000000
00000001000010000000000010000000010000000000000000000000000000000010000010000000000000000001000000000000000010000000000000000000
00000000000000000001000000000000100000000000001000000000000010000010000000100000000001000001001000000000000000000000000001000000
__label__
00000000000077707000777007707770077077707770070070700700000000000000000000000000000000000000000000000000000000000000000000000000
00000000000070707000707070000700707070007000070070700070000000000000000000000000000000000000000000000000000000000000000000000000
00000000000077007000777077700700707077007700070000000070000000000000000000000000000000000000000000000000000000000000000000000000
00000000000070707000707000700700707070007000000000000070000000000000000000000000000000000000000000000000000000000000000000000000
00000000000077707770707077000700770070007000070000000700000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66600000000000000000666000000000000000006600000000000000000066606000666006606660066066606660060000000000000000000000000000000000
00600000000000000000006000000000000000000600000000000000000060606000606060000600606060006000060000000000000000000000000000000000
06600000000000000000666000000000000000000600000000000000000066006000666066600600606066006600060000000000000000000000000000000000
00600000000000000000600000000000000000000600000000000000000060606000606000600600606060006000000000000000000000000000000000000000
66600600060006000000666006000600060000006660060006000600000066606660606066000600660060006000060000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70000000777077707770770077700700707077700000000000007000070070000000777000000000000070000700777000007700000000000000700007007770
07000000707070700700707007007000707000700000000000000700707070000000007000000000000007007070707000000700000000000000070070707070
00700000777077000700707007007000000007700000000000000700000077700000777000000000000007000000777000000700000000000000070000007770
07000000700070700700707007007000000000700000000000000700000070700000700000000000000007000000707000000700000000000000070000000070
70000000700070707770707007000700000077700700070007000070000077700000777007000700070000700000777000007770070007000700007000000070
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000077707000777007707770077077707770070070700700000000000000000000000000000000000000000000000000000000000000000000000000
00000000000070707000707070000700707070007000070070700070000000000000000000000000000000000000000000000000000000000000000000000000
00000000000077007000777077700700707077007700070000000070000000000000000000000000000000000000000000000000000000000000000000000000
00000000000070707000707000700700707070007000000000000070000000000000000000000000000000000000000000000000000000000000000000000000
00000000000077707770707077000700770070007000070000000700000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66600000000000000000666000000000000000006600000000000000000066606000666006606660066066606660060000000000000000000000000000000000
00600000000000000000006000000000000000000600000000000000000060606000606060000600606060006000060000000000000000000000000000000000
06600000000000000000666000000000000000000600000000000000000066006000666066600600606066006600060000000000000000000000000000000000
00600000000000000000600000000000000000000600000000000000000060606000606000600600606060006000000000000000000000000000000000000000
66600600060006000000666006000600060000006660060006000600000066606660606066000600660060006000060000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70000000777077707770770077700700707070000700770077707770777007000770000077007770770007707770777007707070077000007770077000000770
07000000707070700700707007007000707007007070707000700700070070007000000070707070707070007000707070707070700000000700707000007000
00700000777077000700707007007000000007000000707007700700070000007770000070707770707070007700770070707070777000000700707000007000
07000000700070700700707007007000000007000000707000700700070000000070000070707070707070707000707070707070007000000700707000007070
70000000700070707770707007000700000000700000777077707770070000007700000077707070707077707770707077000770770000000700770000007770
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077000007770700007707700777000000000777077707070777000007770707077700770070070700700000000000000000000000000000000000000
00000000707000007070700070707070700000000000070070707070700000000700707007007000070070700070000000000000000000000000000000000000
00000000707000007770700070707070770000000000070077707700770000000700777007007770070000000070000000000000000000000000000000000000
00000000707000007070700070707070700000000000070070707070700000000700707007000070000000000070000000000000000000000000000000000000
00000000770000007070777077007070777007000000070070707070777000000700707077707700070000000700000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66606660060006600000660066606600066066606660066060600660000066600660000006600660000066606000066066006660000000006660666060606660
06000600600060000000606060606060600060006060606060606000000006006060000060006060000060606000606060606000000000000600606060606000
06000600000066600000606066606060600066006600606060606660000006006060000060006060000066606000606060606600000000000600666066006600
06000600000000600000606060606060606060006060606060600060000006006060000060606060000060606000606060606000000000000600606060606000
66600600000066000000666060606060666066606060660006606600000006006600000066606600000060606660660060606660060000000600606060606660
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006660606066600660060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000600606006006000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000600666006006660060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000600606006000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000600606066606600060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70000000777077707770770077700700707070000700770077007770777007000770000077007770770007707770777007707070077000007770077000000770
07000000707070700700707007007000707007007070707007000700070070007000000070707070707070007000707070707070700000000700707000007000
00700000777077000700707007007000000007000000707007000700070000007770000070707770707070007700770070707070777000000700707000007000
07000000700070700700707007007000000007000000707007000700070000000070000070707070707070707000707070707070007000000700707000007070
70000000700070707770707007000700000000700000777077707770070000007700000077707070707077707770707077000770770000000700770000007770
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077000007770700007707700777000000000777077707070777000007770707077700770070070700700000000000000000000000000000000000000
00000000707000007070700070707070700000000000070070707070700000000700707007007000070070700070000000000000000000000000000000000000
00000000707000007770700070707070770000000000070077707700770000000700777007007770070000000070000000000000000000000000000000000000
00000000707000007070700070707070700000000000070070707070700000000700707007000070000000000070000000000000000000000000000000000000
00000000770000007070777077007070777007000000070070707070777000000700707077707700070000000700000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66606660060006600000660066606600066066606660066060600660000066600660000006600660000066606000066066006660000000006660666060606660
06000600600060000000606060606060600060006060606060606000000006006060000060006060000060606000606060606000000000000600606060606000
06000600000066600000606066606060600066006600606060606660000006006060000060006060000066606000606060606600000000000600666066006600
06000600000000600000606060606060606060006060606060600060000006006060000060606060000060606000606060606000000000000600606060606000
66600600000066000000666060606060666066606060660006606600000006006600000066606600000060606660660060606660060000000600606060606660
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006660606066600660060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000600606006006000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000600666006006660060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000600606006000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000600606066606600060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70000000777077707770770077700700707070000700770077707770777007000770000077007770770007707770777007707070077000007770077000000770
07000000707070700700707007007000707007007070707070700700070070007000000070707070707070007000707070707070700000000700707000007000
00700000777077000700707007007000000007000000707070700700070000007770000070707770707070007700770070707070777000000700707000007000
07000000700070700700707007007000000007000000707070700700070000000070000070707070707070707000707070707070007000000700707000007070
70000000700070707770707007000700000000700000777077707770070000007700000077707070707077707770707077000770770000000700770000007770
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077000007770700007707700777000000000777077707070777000007770707077700770070070700700000000000000000000000000000000000000
00000000707000007070700070707070700000000000070070707070700000000700707007007000070070700070000000000000000000000000000000000000
00000000707000007770700070707070770000000000070077707700770000000700777007007770070000000070000000000000000000000000000000000000
00000000707000007070700070707070700000000000070070707070700000000700707007000070000000000070000000000000000000000000000000000000
00000000770000007070777077007070777007000000070070707070777000000700707077707700070000000700000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66606660060006600000660066606600066066606660066060600660000066600660000006600660000066606000066066006660000000006660666060606660
06000600600060000000606060606060600060006060606060606000000006006060000060006060000060606000606060606000000000000600606060606000
06000600000066600000606066606060600066006600606060606660000006006060000060006060000066606000606060606600000000000600666066006600
06000600000000600000606060606060606060006060606060600060000006006060000060606060000060606000606060606000000000000600606060606000
66600600000066000000666060606060666066606060660006606600000006006600000066606600000060606660660060606660060000000600606060606660
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006660606066600660060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000600606006006000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000600666006006660060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000600606006000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000600606066606600060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70000000777070707770077077707770000077707770077077700000777077707700000000000000000000000000000000000000000000000000000000000000
07000000700070707070707070700700000007007000700007000000707007007070000000000000000000000000000000000000000000000000000000000000
00700000770007007770707077000700000007007700777007000000770007007070000000000000000000000000000000000000000000000000000000000000
07000000700070707000707070700700000007007000007007000000707007007070000000000000000000000000000000000000000000000000000000000000
70000000777070707000770070700700000007007770770007000700777077707070000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66000660000066600660066066000000666006606060660066000000000000000000000000000000000000000000000000000000000000000000000000000000
60606060000006006000606060600000600060606060606060600000000000000000000000000000000000000000000000000000000000000000000000000000
60606060000006006000606060600000660060606060606060600000000000000000000000000000000000000000000000000000000000000000000000000000
60606060000006006000606060600000600060606060606060600000000000000000000000000000000000000000000000000000000000000000000000000000
60606600000066600660660060600000600066000660606066600000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66606000666066600660666000000660666066606660606066606660000066600000600066606660666060000000066066600000606006606660000000006660
60606000600060606000600000006000606060600600606060606000000060600000600060606060600060000000606060600000606060006000000000000600
66606000660066606660660000006000666066600600606066006600000066600000600066606600660060000000606066000000606066606600000066600600
60006000600060600060600000006000606060000600606060606000000060600000600060606060600060000000606060600000606000606000000000000600
60006660666060606600666000000660606060000600066060606660000060600000666060606660666066600000660060600000066066006660000000006660
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70000000888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07000000888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700000888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07000000888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70000000888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__meta:cart_info_start__
cart_type: game
# Embed: 750 x 680
game_name: Game Template
# Leave blank to use game-name
game_slug: 
jam_info:
  - jam_name: TriJam
    jam_number: XX
    jam_url: null
    jam_theme: 'XXX'
tagline: XXXX
time_left: '0:0:0'
develop_time: ''
description: |
  
controls:
  - inputs: [X]
    desc: XXXX
hints: ''
acknowledgements: ''
to_do: []
version: 0.1.0
img_alt: XXXX
about_extra: ''
number_players: [1]
__meta:cart_info_end__


