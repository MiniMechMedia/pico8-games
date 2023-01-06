pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
--{GAMENAME}
--{AUTHORINFO} 



gameOverWin = 'win'
gameOverLose = 'lose'

lightsout = 'lightsout'
pretext = 'pretext'




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

-- 3522

_img_formless_void = "◝◝ヲ○◝◝♥ト\0なふ!ト❎◝ユ`ュ\0¹ᶠ◝ワA▒²\0²$⬇️ら²゜◝ソ✽█CHワ² モ゜◝ク●くd²*⁸☉\0あI'p@4?ュC☉u⁴&²²⁙%*T ▮の‖□G▮BC◝⁴$$▮オヌ⁸{!F□?$D&…%●♥ニᶠサ⁸○ヒノ▒り¹\"^h「8L✽や➡️⁷ネ\r\tᶠョ0マ「H웃⁙/S8NfRq2$¥⁴▮◝ト⁴?゛⁸$░⬅️ト|8BᵉN%\t!キJ$?ス{⁴$9░🐱⁸D\"⌂ほrなし⁷) ▤N☉つ!D…🐱゜ヲ!ヲBHモ▮●⧗,$8ょᵉ⁙ˇナK8⬅️P∧\n░♪\tᶠゅ゜う$♥q■⁙Htうkカ'K%、(ᵇu%ᵉ.\"⁷¹Q◝け¥BGp░の,,ナ▮ぬu◀w`ヌ4もq4ヌ0ニろ⁸⌂;♥Pッ¥⁘w □…▒\"\nニケ웃ᵇアツ$0ね&ニる+8⁸I▮i◀゜う▮リD▮s\nq█8@웃!ᵇたセもC+\r¥うt▮…◝り☉ぬw■⁴●…☉る²B▒⁙)ょいなK8♪)る❎웃 Qヲっオマ、d…,B*¥#⬆️I$🅾️,/▮ニ&8セを⁴▥*□ヌ、v➡️➡️ヨヲBHB◀⁸K\rアAそbE☉K!A[!(ょ■#⁘ヌIl➡️#ヨ➡️くイ\r!□ス🅾️d☉モ☉r▤D$ヌ2☉フ웃ᵉまうsc♥'2%さ★==….\tろ…ヘH▤ □$웃さ けノフ¥#むむ$,8Eの$j<●✽░Bᵉ¹j²◀F➡️!イ⁴た□$웃‖⁘ニ⁷^9lさDRの@◝,¹)N⁴🅾️⁙た、B'웃j-ノIケP■ウうIん⁷⁸9#シミ\"¹T@APsᶠサ@そ,█ヌ\"ょY⁷²&qわ▶め\n…Y¥◀□◀B!70웃て◆aア)\n^▮░p░5ニx♥たん²@つ✽゜ホちウ(░➡️ノ$8🐱CD😐IF░ニ](も=ネp、ゃ%オ#⁷ヤ\tけ⁶★⁶ sᶠく$⁵²🅾️\0ゃゃ⁴むっ…ヒ`(Y³っHHMW²p,の、Cそw⁴⁘,E░★Xぬロ\tるJN⁵Be⧗ッ⁸こ⬅️!■\"JマU⬆️✽♥◀¹DD¥\nL\t,★q-⌂Z⁙웃゛リPぬXm□i。HロDヘ☉🐱スdメ⁘★っIっnx…ア★R&8🐱⁘∧ろB░しE^aチ◆ろAっ웃4◀\t$カ⁙⬅️ろこ●░q$HおRqゃ\"\"■*X░Hョ!ろ$✽░▮☉█T^\0Iノ■(ˇU\"K□っュ4XDEけRれレ➡️くl^きさ\"\"F⁸✽☉Gq‖「∧TJ{*X$T⬆️q)\tᶠキ▶★\t\"さ★:\0さ\0p★ᵉlあ…Ygオまさ★Jsj□◆くア?(1ᵇ$そ★□Y\"H♥⁸なx\\モ%♥R▮フAˇひI#Cそsᵇ*HBA*]⁴ハ!$か⬅️⬆️ヌむ⁶と●♥pL、$キD➡️ア🅾️ニンるけ⁴ᵇ□p!░モDたᵇaBpえBh░'★‖\"りᶠュr□□(キ@🐱➡️\"Cね‖ゃトRDッ♥‖jY⁸4T➡️ム⬅️ᶠく$s\"Q8&うノ□=➡️%!/\tくhセ1*u#!#ス{*Hュ くᵇ)IlJあD░★Uᶜ웃🅾️ハR$Bむつ!9🐱?\t_フ0ぬュ☉ !⁸v⧗いDョくj¹1l*wᶠリ■Q⁵J\"²~웃ᶠウB□★J◀U⌂➡️!チ?8~0ニ⁸ヌAみ☉░▮▤웃そモ³たW■*と🐱Gp◜!!シP@8⬆️KᶠクLZクヨオBtu(P…4=♥0ュナn⬅️る\t\"れシ⁴ョ`H⁵な,░G(⁸ᶠサ゜う9ろM⁷X9🐱⁴¥G⬆️r⧗そ\0めJ'R8ˇさsᵉくろ44--,🅾️r$ぬマ³🅾️\t²sるるニ<,◆テRGのさ▮★ DOんM¹¹ム웃ds⁘Yhキ?ュりH@の,▮h…웃゜★8た²た◀リ⁘のP…ョニヲゅラUˇB\"$zK░;➡️をH#ねま☉い□゛Cた¥゜チ,'■⁸\"4➡️$1□りD░'@+C🅾️\"Yャっオマ、C▤w\"웃!(⁘T⁸⌂▒⁙ウ■!YるUFHモ、カャれリ●░の\0q▮X…∧\"れユ➡️\r⁸★ゃ⁴░♥ン+ヲ➡️きし★E ★*⁸⌂Aろ░¥⁴…ぬ)⁸ぬュニ◝⌂¥¥゛H⌂さp█*「⬅️aる⁶➡️&そiᶠキGpキみ➡️ル=⬆️ヌ\"き,★d!⁴⌂お⌂⧗😐\"B□、Cラˇヲれレ➡️ケ▮▶¹`%GR。ろ$お゜Hュ%○r?\\T🐱➡️B「ま$✽▮ニ‖ᵇるイ!ュJュノ!ノ⬅️\t#み\\る!9P웃チ⬅️!■It웃!$y⁴にウG◜⁸%^b\"PBH⧗H웃⁸h⁴⁸□■▮⁘ヒGネ\rᶠaョれ▒@□‖$At□U…R\0Od○0ロ¥¥゜お\raん$#た▮i⁙Iᵇ$、h░2q#ョ➡️ム8🐱¥•D⁸ N…O ★DJ*E♥★,>░♥p◝りᵇ#p\t\0キI8★\"¹⁴⧗\r▮オ!ッAᶠる゛るJヌGハち(▒³□K\tH⁘웃⁴もろ░✽♥▮ョニ◝∧U♥、U□\"ᵉx★HD◆▮…b,♪ᶠテ゜BJュノw⁴ち²K²9$E☉-░ヒ¹ᵉ$~▮C☉!ム?(!ャBR{キ '」!□ル\";➡️du#ユ🐱Wニ#ロ⬇️²カ⁶\n∧ろ%た\"⁸あ&ら♥◜\t^CHロF➡️チつ@Xu$\"らDけH'■ᶠソ◀W□=♥ホ\rᵉ1V➡️□░、ノ➡️る q²\tキ\"4🅾️aei_もと⁴?⁸k■⁴🅾️PP░ヌG(…キ゛Bれョ♥◜y▮▒)🅾️⁴\tラ\"▮9☉웃#ま~オモ、れヘq\"@웃²q⁸▤웃き\"⧗🐱☉u#リˇノ◆!ケ8➡️$sᵉbケるGゃら」ᶜ⧗…♪ᵇᵉ%q!ᵉくム8➡️ッスIDTD★,□⁷⁘⌂H⬅️\rP✽➡️くャCス~オラろケ🅾️\"\t、t\"²\t$Iチ☉●➡️◝あ゜ろ:🐱A¥ᵇ$b9さRM$\"□T▮⧗Ad~2:♥オュくン%さヒっムI!ア\tん$➡️aア░にるGpッ□゜Hキ$⬆️❎dJ9\",さ◀#웃⁴けHぬュdhw+◝⁴🅾️%J」%▒ᵇᵉD♥■$HD ░ら✽…♥0ュしwᵇ#ャ▒o(TTた#░★B$☉⬅️⁙▒░r!く◝🐱゜⬆️$=z…J]Rさ░く$のラ D8くBBこ◝|にエむ⁘ユあ⁙あ…D★ Aa⁴░HX4、BBCリ✽?⁸p⌂░%Tハ³♪ᵇl🐱('Pp░ぬ░4◆ソ゜ろ<K□て\0I\t 웃\tわ⁸▮~▮░…🐱Wメ#っyᶠし\"pくゃん|ヨᵉP♪ん&█I□=、Iᵉく!!!ヲCま{+░%う▤v.こ▥tナカらそオナY%🐱Vˇル◆サGの9Dた2⁸A,◀Bさ➡️9ˇ${!ろ☉モ¥Gハ#ワ♥P\n█⌂\n✽✽(□9,;け.ら░カ゜ヲ!ケ?²、w,🅾️\tら8キEˇケ웃#'P⬇️そ★D🐱B。BるCッ🐱ゃ\"しK#⧗け(ッ@マ⁸I⁸\0そロWヨᵉさHa#8⌂ぬ🅾️□$+%$qv⬆️オふ[😐3웃 …🐱R゜ろ:♥2よ(wᵉ□⁵Hあ웃ᶜI⁵b オ☉⌂⧗ユ♥rさ9➡️ケ'‖$e⁘Kねlx■lIL⁸ううちわbB▮:…゛BJ◝S ˇ■R▮ヌ▮K¥+たD★>へ² H➡️ そ◝ょ⁴4⁵のイ⁷□ᵉて…➡️、オX🐱っAケD🅾️-、I#\t゜ッ4DD■/‖⧗ユモるL♪り$▤ニm∧*B$🐱p☉キ▮ョ!!ア♪⁸♪□nlBHサ⁴H!%さ!ム♥Tᶜ🅾️\"▶■アさた\tᶠaア%²リ•(イイ웃VサK▮⁴░□³▒$:🐱っさ…♥□?x! H$BHHュ²Ibき▶⁴サˇ8のみ웃0$wᶠウ゛HpD웃⁶Hオヒ…☉$キhう、サ#ラ█¥XC4の\t웃\tᵉa ♥R$⌂★\"Tラ▒゜🐱▒$ち3☉Y`あ$fKqIセ▮(ヌGムめちけKE░サうれ☉▮⁸A\"ウミた)⁸ちN Hy\"りa$y\t\t⁸▮●░★²!$uᶜ◆jHI.(\n2V⬆️D♥ろI■⁵♥r$?ᵇ■!,⁙X⁸ふ>░ヒA.❎⧗ほ□さ웃!RN\tさ♥□BD□、BH★=♥²ょDヌ★ケョさDカᵇ%はK](HJh¥Y$$◀\t◀G★$⬅️わU★Y)◀■d웃ᶠ9■\tBDうL⬆️zへカ\"█\t!て?\t゜█♥V\"Hの?(T☉☉キᶜpsYV□「D,さI\"D&➡️ア⁷▤█웃チ웃dおCそ$,B\"@q%ᵇ♪ 🅾️Q$∧웃□\t‖?」VEケ웃▶ら★BD♥ユ∧\"EゃZT fT$★きD\nカ'0…★て⬅️웃Q%░ふ¥BCCっ8\"D$)yうum8H🐱⁘⌂ˇ2H8……?oH░➡️ヲI$\t゜う:さソ@ハY⁶ニん。(iら➡️Mb$u⁴🅾️ヨQ゛XAるわu $?)¥!■\tU9웃Wp░ナケT☉2*◀•🐱わ⬇️⁵さひうヨ T~サ⁙▮'0➡️、CY●⧗C&ˇlHウけ□4\n%せ、P🐱オᵇR□'★;:ノBI□\roS9□。⁙6H★░iろC\0ᵇけ9…➡️ っ▒き…ぬモ。@うXL░メけ」わH▥「うL⁶~@□\"(うら²⁴\t\"Z□,?Hnろ⁙▥ろ,+\"ウて8ヘ▥わらBヒ4H☉i⁙ のJᵉᶠヌ¥D\t)/⁸#\t)⬅️ゅ+웃ろと%ˇa⁷◀■゜★□D\t▮ˇ$웃ᶠョ\tPQXミ4カ@+ᵉ♪テ\0あA░Bヌ*L♥R,<♥…Xう\"➡️★$た★#ᵇろ⌂おり¹ら$⁶Iゃᵇ$¹さHXX~▮ヨ⁸⁸⁸ゃ$Qd‖アU\"◆$!h🐱R³`Bっ♥ャᶠ!\t☉☉‖■Sた▶ムネKわᶠウ4ゃ、H…□゜チ8🐱◀G)P),マオわキキ◀E³あ▮もU∧っAᵇᵉa!ヲCラ➡️x🐱\"DPう8へ🐱H◆□「Yん⁵T\t,う、pG▤웃ᶠる゜ッ⁴2I&p、q3⌂ニ1「!uVK!‖!⁴◆dX○0ロᶜ□\t\0▒dpシAチオ⬇️たj◀っュさ~□,?IRG★め\nひpᵉつ$$ヌ3ゆlもみ▒ゅっュくケ?▮\0"
-- 4488

_img_dark_and_light4 = "◝◝ヲ○◝◝♥ト\0なはえヌWミ⁴▮|\0:ヌ²‖M'\n✽ツ`$9う▮~ \0A\tᶠれロ\0\0 こ░ト@□Aるいお」I³⌂W…¹FN,▮Pヲ\0~B█の\tり,EH◀$こ□p▥⁙⁸░ヘチI⁙ヘ⁴\t\0:🐱ᵉ█☉웃#AEDュA!□ᵇ% ★⁸DヒタHI⁙\rヲHD⁸ D➡️セ▮Q¹ろ,□⁸☉8ュ ■■オI★9た²@ょ\0ぬ…b@I■\t⁴Iᶠ$Aキ⁸h▮H$➡️ツH★\n★ナI¥レ∧Aeれ░ᶜ#⁷むD#A;☉ᵇ⁴8➡️d,@の*1!0◀D▥ムEbオB3웃⁵の@8オ⧗▤DB、れr⁴く$!□8%¹IわT8🐱K⁙░ヌス Y ■8キ◀ろTNヌ ソ#⌂B■a(ホ$Id8█□りエ0ゃ5‖░た⁸の⁸ゃ%カ&□E\"。Ch9ね²ろホ◀$웃*J^□u□に2▥%\0.▒*h░8@」ᵇノ\"\r#おH🐱H░ヘぬ➡️2,ょnこ🅾️U■1\0웃っE$█ミ♪□□Tu⁴웃っ‖◀A⁸=░LTp6 HむI%Cち□³Oそ☉☉\0Dま³ぬ☉ヌG¥\"☉c웃□。しN」#⬆️❎$⬆️+⁷⁶%✽ね⁷5⁸,⁴☉そBh7⁴\0Cう$つ¹っpちLリvぬむ@U「\t⁵✽IᵇT…☉ハ▮、っもDD8➡️Rヨ\t¥□つそ¹カ‖\tQ8めXく\tLユ▒(ヨ\0ょ■ら$$9…ぬDdJ■Hぬね□8ヌれp,█p、G$⌂Fつ$░…yけD░웃🐱☉:\"⁸■P8➡️●☉★⁸🐱cM、ゅ!\t%³$5웃\rゃ⁸1%★\n,웃きC\n🐱T³█D∧$‖\tRホ⁷<'\nM!そへ□\nをB ◀っえ□■E⬇️A$(DD、$➡️$\0たH*5f∧⁷ネあZ⁴コI0h8\0TK▮░🐱◀◀➡️dH!テ▒ゅDへ⁸qろく*qけ⁵웃¹e░むノdた\ns\"r²░「2JE★t□H░\"ぬMぬ:VホRU▤、⁴ヒᵉ8⁸H➡️⁴きk\"HもA□B =웃,H0▒\nᵉxB.キZH&H🐱ロ★$う█I⁸♪$s⬇️□Dね88░さ…□♥WG■ウみDち$DEぬG6L🅾️⁵な$★C⌂\"M²•▮ぬ░★R∧☉u%ニ⬆️t@WᵇU$S⁸ら⁴.#☉…rD░⁙☉¹¹ ALI\0🅾️$⌂そめeメ/Zる\"✽#C@[dXう\n…⌂➡️$#⬆️²,➡️d░ˇ'\0XsrE🐱■@ハ➡️*XKQ⬆️\nKら□*キっ∧H■²⁘フ🐱DK#なᵇDう➡️⁙h★•ユたろ⁶★U█0⁸□B ,²てB⁸qき★⁘A$り」$⬆️,░⧗⬆️❎l:つV⌂●AJ⁸US웃$Jぬ⁙♪\n□ん\0ケ)‖▮の' ⁴●■▒サオ▒ア@くdネX□ょB3た◀Y$\0‖!¹□@ヌ\"¹a,JOさ█…た■²R2H▥っpY⌂q*き\rら、I$T⬆️\0\t$✽A■きう³░∧⁙た*.Tつふˇᶠ5⌂つ⁙웃イせ▮□b#I⁴マっれ³D■$すN¹9\t Kac■,マょる⁸…えっ⌂☉%XJのち$@つ.D▮\t■「■\"Y□¹$ᵉ ▒⁸をˇせ\\^tは▥W*さ)!(G⁴た■□\0☉■さ✽□\"\"\"⁴セ⁵░●☉みY4え@8さ9C$▥)$\"\t🅾️%░Nヲ░`⁸HN\"@ノPB■dと⁵&チB7S@ヒ0サ)‖⁴¥ア,ノJリぬそ▤□⁸⁸@:●웃ん▮/「る!ウ@Rd,⬆️░-ろむ⁸Pᵉb…\0🐱A■% ᶜHカ」P□ᵇ/⁴*pニH웃たみHな■0p☉r★Q<F…BZ$웃⁴★!て■$BˇjさItY4M{う\nU☉た、オ\"🐱まま☉▒Q\0-Y⁵⁸HBCよP★Y◀Dモ✽•$'そHナ8∧\"2L✽p/ニ$▮BH\"🅾️,⬅️り TきbKろ▶♪⁸HMxY Yるqり\"⁙え⁸\"□□❎█s,UuTり1`A\n☉😐I4IdN¹X★テ\t。,D$³q*-セ「ぬ⬆️▒#⌂$YE…さ⁸⁙h9\0☉Pソ カみH4🅾️¥る◀`08ヌく█■⁸a$⁴i⁴█A\0008コ.ぬ★ウ□⁸RJ∧Dシ#ˇD[■▮ゅᶜO□²ゃR▮@)◀%の7$\"-さs\0い9¹msテHx2@FAbU」@は²▒さ☉Ab▮Pᵉ;A!⁵\"っちオ🅾️ねd★U➡️て⁸ゃ\r1b$h\\◀`\0⁴█…\0 きさH…Y)²‖…う⁶。\n⬇️✽⁴‖4し⁴た m★むく⁵B░⁷の\"LJF、*&わYRT➡️さ□とヲ⌂A\"▮⧗&✽そニ◀qU ░⁴░$@」⁙░ろ⁴シ!8の#⬅️)け∧っ…☉qU◀ヘg22■(P⁸$⁸웃 $➡️Wx@X□すふ\\d♪2「\nニ<TI*b¹t‖る(■$²☉そ8⁴█ せ。$★@\0t●Hソま.キLキて☉L⬆️そ+Xし$て▤さ⬆️sさUC☉🐱★⬇️🐱ン■▮そ▮のユ\t😐n•#(Pイ9!b◆⁴k□▮T■P🐱□…ᵉき⬇️けX⌂✽■R∧ユ◆S∧➡️□&pアっ,ナ▤J⌂ヌIᵉR⁸¹アせ²◀□…Q▒っつ*EU웃⁸う◀\"ねわなZ\\A*しく$Jゅ░.+ゅ²웃ᵇIG★CJ\tk🐱Fい\"9む\"そみ\"j@ナ%…웃)□ゃア █Hミ⁴…I\t\"■²Dた¥!%タ0ちク²\t⁙▥r-り■とケ⁘さオxぬ◀🐱#セ$1\t,)▮i‖-\"웃ろソ⁵スpb□`,J…Zˇ、4⬅️っ☉웃Hq…%E✽³さ⁸█★Aへ…✽ヌ⁵□□に⁘*]d41/‖「コ⁘*ろは░p☉➡️▮'hゅ😐I¹8✽H⁴せᵇO`まああHっケ❎FL☉$😐pDH!$…□さラ$AD…Q.\"😐え¥#▒dpWknひ…, …チ\"ヘ♪□け²し(³…Nd9‖⁘HMKこ\nル★FいCT),ゃ!⁷zDきのく%♪\t□Dよ웃, K⁸さ♪&ナ★モ8Rhr★ᵇウ♥ᵇ⁵★ょDH]🐱り |‖Bろしナ…ホ$%😐Uひネと➡️イこ⬆️ニeSᵇアiさケi☉)⁸'は░★H█¹▮🐱D🐱Iテ▒ク✽★ᵉりキそ★▮N⁙あ,⧗\ng\r■pね░た◀Eホ\t□っハ³ *;I!「Mンら.J●ん⁴るぬ.$ゃ0ツセ,R³9ZI*rそ☉░★Iり$D'、I#HのD@▥8ろ」²V⁸SJ🐱DC-%⁴!U➡️⁸⌂▮、\tb★ケ⬇️X…@あI,ア➡️ひなくᵉ\"⁘e*#い@め✽ᵉつ²□\0²DD!;ぬう!\"²ま モ░웃◀Y●きへ■dりしゃᵇFAすB‖カ▮`ナ`ひ⬆️◀ᵉ⁸)Rセ*ヨをぬニX⁴QAる(ウ▶▒けっ1▮⧗⁴ヒ@モけBB。ヘ■웃⁴D⬅️6⬅️Rイくdhewf)Hのょ(+;█BD¹さ^(★Nヌ!\"l☉●い²E*E8a⧗⁶Bょ\"DニhK¹█そ&キᶜ、#☉Jね$▒⁷」5\"ひ(Fたケ$るれ1うY-@J□✽⬆️R▮qp웃-H웃'「➡️ろ$$ハ\0³*-きせJ5ホソj▤⁵…さ⁙T✽⁸あきさ★らB♥■$ `☉★4\"ˇaままIlはobdIY、9웃)Kオ▤こ☉の█■\t⁴HI I⁘,█ˇ▮は▥た%…(<➡️%◀😐★き★⁘ˇまKlさ'∧J⌂➡️l★あ¥\"ろっ➡️なる+▮ュL3J⬆️ナク▥JNンさˇ4DらT²Iᵇ▮ᵉ,★[⁸NP゛」N.ミq.◆ゅのヨa★けルチdBAbX웃$➡️Qd★さ⁙$]⁶D➡️‖いg□QxHCモ+웃(のB9ね⁙%ほ\"⁴◀.けA□BY チ⁴た²★せ\n.へし゛▤Y¹(UU\nへっ⁴e!jし☉★た:\0⁴D웃エき.Iな▤た)チ▮■f웃◀R🐱K■4ら⁸CH…ひえrD9⁸✽⌂P,$\"□゛J☉♪$+Iケコ#あD⬅️を@v❎さ\tᵉi し⁸²,U#Xく□⬅️ᶠをUEキ★ま웃る>ˇきY\"ᶠ□っ∧D8、$b□D\thひE☉ん⁴カ$モR-はYゃし)xGvdHた!\0\0⁴\"HB\ns■ᶜた,ヌ🐱イ\\さ□K-❎のしY⁘🅾️5、0こつ$のk\t■\n\tI*J⁵\t◀S☉★\\つˇをヌE_く2て2コI*⁙\"bA⁴³JD★E☉た⁷8\"⁵★■■く-ソ(X~0キ□ED⬇️(Kム4□I「マるD∧'⁷、\0\0☉…の²う& ❎おE⁸(な$ˇれ\t\n=さ⁙▒▮ハ\0E\0▒▮\0DF★BOR⁸★スN⁵&84RD‖░っtも3ゃ²ゃuX\nB⁴T⁴🐱G(⁴Kス…TI□゛ちニ\ti?「$k‖ᵉ「ᶜ⧗➡️⁙\"こI□⁘ᶠ!!▮🐱³[Vᵉs⁷⧗⬇️■フね⁴はzら\t\t$⁸AQbAI,AわI(たz$(ᵇ⁴pDチ◀ツろミ⌂■さ5♥¹'⁸キEX{q*⁸★▮웃⁘-T➡️■⁶◀さ★⁸¹\t⁘Y■6jq⬆️BきえDキオD⁷⁸、ゃ⁸さ⬆️…I\0²h웃▶ケq えムIりをᵇ\0➡️⁙✽…ニ,bY\"□H)D●▒bM\"▮\0、さHFH□\"▶g■6DえP²⁙8&きこにょY\"□$♥う!¹%☉8、$■%LG☉D⬆️▒さ、mねi8ニDナモT\"ZつF⬅️³h\\∧ᵉRカ■$へA⁸\0d☉☉$$▒ヌ⁸ˇろ\r⁘ソE¥H8へ▒l5\t☉☉♪\"\\➡️D★BH\"ゃ\t@/i⁴Oわ,H‖@▤む%▤#□E@ˇz`:キB▮Uq\tる D∧ \0⁷)⁷¥く□h웃キ⁷\rD➡️へシ░Q$ᵉHき 'H웃!ア…★くI²■\"RNPD$‖‖Id🐱Lbうモhキ$を■⁘りヌ(⁸&★も@ハP█Q(q▮ト%█…ZちiRひ★ろa8て∧キR²H☉🅾️◀I\td★g²\"EI▮,B¹)■$/(☉█BDxっDQ4i8%く⁙🅾️⁵Y∧っᶜ웃AQ!\"きX░き\n웃▮😐#⁙⁘の*すᶜ]り」ろ…¹▶●やっ☉Nd\r`□R マ$B…웃⁸░ナゆ□A2M$Mˇ,8フi웃-\"🐱ュウ■¹ナ★\t$C🅾️⁴Y\0$$²R🅾️▮웃$マさ웃8ふ%T%セま□て⁸⬅️た(へ「★M\t!⁸2B\t◀B★AbR⬇️さ★ょ$⌂ね□G…8は48u□たDナ░²SうI\0ネけ$Q⁴,*²T⁘\0ᶜ!わ@I,ph🐱\0░∧す😐オ;★²くiコ&D⬅️!チ◀!\0\0^★BhしBら❎カ▶I、A%たるH⌂カbe@➡️\0ヌXE➡️$I◀A▮∧ ²◜I■□■\"\t$⬆️q*⁙d✽Bロ#K>B@p\0‖d…ナ¹▒$HRJ@8゛\0🅾️al➡️█●⌂さHBb⁘きM!,Mᵉさ ,$\0AbK▮v⁴➡️▮9H⧗1⁸Tちサけ/⁘K1Jナ★まBp\0웃Qさ🅾️$,D…⬅️\"HゃみH◀H$D、$。ケ¥🐱[J⬇️さえDケ%N4★$ちD$$□*@▒bp9🐱\t,IヲさE□MDUゃᵉ⁘⬅️4たゃ,)しHX*$$%☉▮X░ナそイ#ろ▒&⁴‖ UうL-`‖\"%★⬆️웃\\¹Eろ▒#そ■Bろ⬆️⬇️ち★¹ノT∧。タ□E░サeふo7!みHYT✽る*'²$●☉P★D▒◀Dさン%$ヌD⌂★らT□a■ さ░\"リ$░➡️(けBり$ッD@웃!ᶠ@★\t■¹b$Z,カ\"るvき⌂EI웃っ★■`➡️ウ⁷$Bろ\"\"웃H⁷%★2F➡️っ★⁵ˇdRJXh2I🅾️*(⬇️け ;♥\"◀□ろヌ\n●ら❎Hへ□\"ˇ`*^R░I█¹I ほI'Z!🐱s■‖▮$…9웃⁷🐱⁴さ⬆️@VちR⬆️Ia$●ぬX▮\n⁴ね\0モ⁸🅾️ニウ☉H⁴\0R█\nᶜぬCH▮た}IRタ'⁵🐱uら➡️!bᵉp!y $◀$ね□⁸9ヒH、しA◀IRヨ ▮RR\"CBDね!i⁸レ ☉マ⁴ケI⁴Y□D;そう☉□\n⌂\"\t\tケ@ろ (た\t,⁵ろ🐱ヘ웃!\"Hあ⁴🐱⁵▒?hうホ\"h➡️🐱`&…I★HJ⬅️D🐱░웃きッ⁸h$,Bt⁘|∧IP⬅️!…@⧗$⁸Jのけろカ$&$★/1³⁴⬇️☉░⁘★…¹A@、セeHLZた%そナJのを∧Uす➡️@つ)!1゛っ★(▮ᵇ$⬆️█\n^⁸S░✽Az░BI$!チ▒Q$t\"◀ うら!$Y□☉BRJ…¹ん⁸G$\"HD🅾️ᶜ!ま★ ヒゃ\"9□\"[\tᶠa!!▮,E➡️!i\0ヘ、+█4ᵇ‖し[さRXp^\"H◀Cぬ☉r■➡️B➡️$⬆️🐱$ね%□さ、▶のT★き□☉⁸H★っ█☉ぬ…█🐱◀、ら\0"
-- 5656

_img_memory_core = "◝◝ヲ○◝◝♥テ\n●いeも●➡️◀qし&n8웃‖q□u⁵❎⌂たa!4へラさハ(∧♪★せ□ヨ\"Xゃ\"ニDカけB\r、ユI4UナそEtᵇ、%さ V JH>¹$░v□BC」?)ZYJぬBヨ◀「ちTI`ケJ\"ツe8ス-.へi⁙\0\tあシ)Q⁴ねろZR:あり<$⬅️,²たをねV🐱Hもケ⁴☉█tキEK⁸➡️%Tチ³fF%T)JヒiGIRケ、,⬅️$²$わと\"▥4SN#H🐱%IbLWIり*7ょ$I「😐\"ソf🐱⁘🅾️SDX=ソ!a\"B3qみ⬅️-\tひヌっ⧗▮まpヌI)$⁵さ カ□ん)ひ웃$つ◀⁸な!■K{@@のたxチmうk YcむG◀,コj9へ^0@☉けQ\tらわ★ウ'¥G[■PDちヒ,D⧗…ナ☉<…s$xH⁵#ょSYH=⬅️$▥$ね⁸けくVEヌアはた⁸■ゃ8C4キ?)♪らYこけけ9¹し⬆️エZ▮▤□ke-g□6u%BケR0っュ□ゃふZフとeふ◀リ.⌂ヨ3▥QD'░ぬへt☉IけD」N🐱]⁘2b³p⬅️4…Lᵉ$ひヌX⁴T➡️っきA▮■⁵\rV🐱ヨ.VくR,▮HZ$b⁸Cえ\0DオのEの2q¥AムeZ♥ᶜT░ナJつ⁸q8⁴。\nみG\\]」\t⬅️⁵ね$%さへKᵇゅMを@I$ラ4m█のᶠり■■jンい⁸うiるっイ◀さ⧗…さりQ▮p…ソすq$'#)、けXナ⁵I▮T!R ⁸ニルK-き4☉🐱っせ⁸マIVチ³🐱らNE░$R?²サそHN\"ソ!8BX*。TキX!8U‖るiU!lW⁶★▮★)Iソ#■'2コ★Uフ@•▤☉p,えDD~2%ˇ`B[\tc⧗ZK9の」k░░…➡️らね:¥きウモサょ、¹‖2.」░「E🐱ょうソ■‖#っへI∧C⁷U、カ🐱ょ$うり)g⁵しっ@ょ%ぬv²4そろNRハkQDュjIm!4░N ニQ⧗かVゃ▮サ%EI`⬇️∧ソシA⁘ちˇひ…✽う]x⧗RP6★4ぬjぬ/)WC☉\"ゃ*▶★とM⬇️Hhさはg□^M ちイ」$~Rq、T,L$ヌわ!8.qᵇ\0🐱」、V★Z■けpH<█ひヌ:TD➡️□ᵇく▒ル▥6Aa▶smhこなYこワユ-웃っホVるキル!gᶜチ:た■トネU4★!みふを⬅️QV7|H░$:●くVᶠtm⁙⬅️\"s#▥えiLᵉちd^⁴ウっキノ$,★iNMˇ9🐱¥▮u⁸웃ら、★⁸RY1おアへて🅾️a l[8たね!) あ■⁴▮YD(Cラ⬇️웃されˇもKh웃□ソ~vMけ¥ Kねき⌂ヌネ!,▤もJうT\tさ⬇️BれA ⬇️▮ヤそ☉TおちこXネ[fAノ4⬆️웃+⬆️☉ヌQA:!ろな$uᵉ▮I\n◀ニ✽ム⧗\\ᵇ🐱 ░を⬅️d🐱\t▒ひ▒ᵉbイ■わ◀、A\t⁶\t⁴▮ハRT\"p6めN-웃コ…ネ.░Xもi🐱░。●ぬヌT★\t\t□⁸$r\t#そp☉」\"Bq0★テa\"¥x★Z…\t░∧³▥*ゃ○「u⁶ᵇ\t🐱\n/fょ'|Y-%\0dあ$Yをみ\rエt³⁶⬇️D ノ\t)きH♪,▮ケAᵇマ]$ᵉわセ⁘⁴‖leぬヌコ%웃□\n@9∧さ•コUyH$웃!bマ▮*Hね9モなmr\"て□アへらAらAaf◆ろ★▮ᶠゅ▮\"\r\t\"し▮…X■⁙む♥⁴🅾️l]\"ᵉ▮q⁴Ibわオ# ⁴➡️(³q²Ba⁘X$^%∧I▶⬆️…¹ᵇ%ネ²ゃ◀BDBっさネるU⁘Aa=つ*そひ(!■「◀ˇ、DN➡️$kN?\n☉🐱★▤\te⧗▤ふ:P7□ゃ‖■H□B⁵つ\"⬆️⬅️UG…CRとˇD⬇️⌂★ろdへ…ナDZ🐱Hく`8けE TN\"★!、Z、∧CDYRV★も-そ★Jふ¥Kᶜシ\\$☉🅾️◀fI\"ロ■⁙\"D░ハ‖eくH★NeJ\tSY\tVEム➡️⁙▒▮∧C!■Iさな$Eけミ$🐱#★E¥,%★∧qlT⧗⬅️²⁙bB,。Dた25ちヌらˇ,\tきサ)%)T⁘8た%…へ²⁸…H\r-🅾️けオ\t9,Iる⁸$し░ヌ$🅾️eつ*8HうょI4A5#⌂へのセx⬅️S웃d8の#░ぬレ*スˇわの⌂ヌ-ね!□H웃をねH웃{ANG웃d✽🐱#い-@サソきぬq⁸-そ…uHふ\tラゃ%⬅️jカ⬅️IわI$のC☉★q\"B⁸た□コK゛\"タ▮✽yl∧タ□ゃ)ツKe%🅾️$ぬニ%な▮⬅️UろHZ%pき8のX⬇️░I□p⬆️k\"[dコ#みe[□▮P⌂ュカRわ…⧗*J³☉★KD‖)▮KRさ∧DI⁴ハ!y▮ᶜそ…ろこ░y◀E³♪,ねJ█あUD∧Dあqm░T*ゃら8…マゅˇ$░Xs`…★ ◀PネさBツ◀=のJ$q,dあ{%み$う+🐱こつᵇbWfサ@う■⁴➡️aろひ🅾️⁘$め▥&gヌ[$XふャIamへ‖,ゅしね゜,むX⌂そh9░$E#Z…⬆️へ⁙つd\tjZキJほG⁙[■…D★VK²\"ZKTF(✽q)dつ\n3SJ❎⬅️WDヌ\t`チしぬGソ*Mみ⧗X🅾️\"\\☉ヒM,ᵇd➡️%#ち★JepM$XクV%Aアそし∧░X;²-⁵IP\rbJみてミ⧗ ュmめ▥4🅾️!_あKウめXみVqJqろ░+ᶜ\ti⬆️\"⌂ねっK8のシヘTキM3ᵇエy$vカRうよ「ᶜサらfへラ★pむノ4ヒホア😐A\"[I!ス⁴`ゃ$ヒ□fY、ふこY9Ns🅾️8JGミろゅ⁘/'もYエ、^‖と░チ*q ヒpN*ˇmし⁸LナK&█しZ⁙い4☉ク🅾️ ytあqN¥スとVろさ\"タるq、N◀O★]ろヌ✽sm☉K\0もさ\tR★ う/³ユあ✽%D🅾️-eフ🅾️ᵇうh☉I\"H⌂せᵇ★V=⁸□z#eろめK0nᶜIC⌂●Tか😐웃tk▤웃br∧た⁙W¥セ、■∧ク웃²ホ^Mxも6Yᶠ'2YさJ ‖ᵇコ²Aハ⬅️-G◀Bq8あ6⁷\t8p▥◀¥タ\\I%➡️³ユ&★ワろ🐱8キcユiW[9◆o◀I4q🐱きZ⁘9A]イちZ◜あウlイみチ‖9▥9⌂♪))fカれしネ☉ん(M8@モほ2まYアn,さJッこ⁸웃と¥[ゅY;웃5う」8をみに⁵Vナヌn4のフᶠうlEヒよ゛bウ,⬅️,ュみ★つ웃mケ9sdt-B/⁵うU∧ろMょうのフヒほRてイ⁙、ろう'ᵉI□[8^⁵r😐ュせ■は✽ソRふナチi,e🅾️s░K\nU★■'⁘eし⌂ュlいうま…GᶠvstZミ웃t、けラふゃてコひみンkxは❎、c🐱またyうi\"ろへB\tl★し⧗リ▥⁙♪jGᶠれJうrネ🐱Mo◜¥め▤Y9は♥\rRわヌみニ⌂ュみIアネFもe♪9ハ¥らQ\"わrHKちrさ🅾️まへコK\t9ス…⁘な%マサもN❎ˇ)、みヒ^。GZゅネ]ゃ6{jモ#Dも‖6X*ゃ⁷S[8🐱ilqん<ZWᵉ,ウしケ🅾️ロ🐱∧+▤ヌs^Rdヌともむ웃い■ッアコ*Xのノねハク%も:Qb⌂N1#ˇ∧fもムそKdGA5⧗な⁙😐ハg◀'<,]ひG+&ニう+♪(は▤キJほ¥JpE!おソ★F🅾️ \"ほ6ラEイ8⧗…キHュ%‖$😐クむのタX%うV⧗D゛♥ᵇ0%な1ᵉ%▤シ▒v⬅️♥04ネ☉➡️す-ケュ▶fノJe∧&█9⁷\tんn▶\"◀□タ、sん<DノBし‖て□んマも^aケ☉はˇむ8うスみすJZにタpソpはたょ'⁙cˇうゃbけす4フ◀2⁙ルᵉ/、n◀く⧗g\\kk∧-N#ヒヒムネcお」a、J$E#ヨあちリyまヨ.うシ.y⧗HIu◀YゃろRCAノたみケ²たヲD★ヨ)。タろ∧Bこ6ひ…ねI、/¥んᵉ.シ❎RGI:うqw‖❎★し⁵rはY%H8\0❎とN_😐フp\r」xキwk,N/□ん}fはTˇZら☉クな5❎g🅾️/3え+と%ちあ▮▒³⬇️❎¹PC😐ᵇy🅾️'⁙⧗ョ★nyつへツUな、ゃN%あKまニ\tてねe8^‖さチˇ、<BIckRR)\\Iエ²I□ᵉ@ぬ❎░tE、Uナ∧NRq`I☉そ|ヌス▶■イbまm#マチsxハケ}◀mしつをうチ⬅️<き\nT「⁘-★RHK'ᵉ\\ソニ‖るま★ょ&フ▤Mるょ\t%<sあメ]ヨょ░もめqろむYヲゅ%➡️てUX1る`ら❎つ]nvカ;ヒ,Zメ/□dひq8チ□e⌂っ2ᵉみめ'\tN[■ヌV\"けK.ひ8³■エ 0/「ネb コ\"ナク★6+♪し'」わヒIhD\"サ~□ヘネ⬅️2OdEむケコoD☉\0_⌂aほ2む★h8ウ/ᵇわ+Gマつこ🅾️ᵇわ▤★★~웃D-∧ZネF➡️ゃ➡️/❎え⧗q⁸けRW<…D`ウ⁸チ4➡️せLヒス⬇️ヨdほうう^。ソヌb[9Tなi、9ねウキ2ゃ◀\tをkん1eL$q7TC□くら$カイネい▒みもユメわタ♪∧hシq¥$1か😐^8た▶Gハ#M•-ヌ[▒,cG◀웃³$⌂ひた!),⁵っな、□リをへD∧Iアうラホイ♪をYゅ[4⁸ミ⬇️mり•♪ちZキ웃+とわ✽さ⧗♥vに、sるC🅾️xヌス^`&クpフ웃エ<せうみニ*#-bFS✽サoソこ☉W¥ゃをなンハイ∧;8★リわg▮IまひヌEたるw8ネ⬅️m,は%ᶠまソ□Qッ\\むq\\kふIjJPD웃,くさWᵇ9ネあけ7•⬇️☉\"⁶mnう3⌂⧗ˇキ■■と░キらろuい0웃る,😐。ユrの9ヒIS&Yイ1'□ヨ,ヌ◀▥チほᵇBへヒケ➡️ふb$ナ✽🅾️、わコ9\nやノうケ⬇️ほ、n9チ-コ「.ふあ[テ'\t\n⁙$⌂8うねせ::ケ□q`オつvヘZ🅾️xはい$●⁶もネYをねる+⬅️g、:め⬅️u★Y1□i'ᵉ\n♥*²♥9'□Rっせᵉ9ウ!うI➡️りさも[dはB░∧A/¹ろい🅾️/YまネIのユ゜す★ウ*□アか♪♪ᵉbh$ヒゃy★&◀Lzナuろjさヌちつ♪をニ;🐱●フJフII-Iˇxlケと.つ-★う%Yろ,Pは⧗]ろ⌂⬆️⬇️イん•♪,w4ヒ9タ▥、ムチAゅ/、+▤♥⁙⬇️▶.g\t✽ヒきr…BHね\\9そヌ-けS∧いつh@ねれリ⧗%。;チqケヌAユねるpᵉ0N:ニ\"ゅ8れゆ⧗⬅️ケ♥ᶜふ♥」コ웃⁸ノY84やsさ⬅️⁵^。Sえ●░ら⬇️²◀へ▤ニ1□⁙uし~とをフ⌂ソまうpumな(もょ カN.JD⁸H⌂⁘⬅️ウヌlぬ▤D@s⁴ぬのIききNっ⌂K\nマら✽t★5}bK%オ▮うv'、K+$Iuはいの▥るrクまH🐱⁷\nヌAUつお▶Ji\0S✽ぬ…R、、さ♥⁸にヒシ1ᵉ%4ma∧⁶★s!ま⌂^7%%o□5,$コノ♪⁶AヲょるMaわ]わへBᵉタ░⧗░ケIJうわ!`と。ナタ-웃•あひ🅾️カ9⬆️J♥▶ょね5ふろgˇ/¥N\"⁷P∧D…Jね★W<$I1ん<、0ニみむコsサナてˇわ🐱そ\"ケ#ゅ⁷‖フ<qe■eもpワs🅾️◀っろuょ^■,ᶠクKエ、US+qさ,PふRpは☉Iク$□\0◀ᵉ\\q%◀みつせᵉ8いSˇうpうpモ/、qア9`ᵉ■ᶠキqひY7\t□tソモ¹♪&も^9&そへrD@r▥「うむ.[?♪そYN、ヨら🅾️■ろ⬆️❎Oヒろ▤ゃ8ノこ>Iん¥q\\Y9F◀ろスr♥(▮そ⬇️とけム☉⧗■lすsつ웃S\nつ-🐱\n➡️2Jト♪キち\"ケコ\"$NᵉGAL{D❎?ᵉ\"@な」$rもマeI!、ふ#けヨ,y.qウのlI ▒yG'⁘さけᵉ@⁘すナ\n➡️d웃⁸そ⌂の2ヨk う`ヌ.웃りサ4ナキモ•U^‖\\qtHヒリとᶜN.ヒし☉█ろ^RMア³ヲ🅾️)-iアW□に▮ュレネG⁙I□⁵サNf웃□シソYゃᵉᵉ¥FF`,ヌリせ\rろ★Nmˇろ⁴メ3いPMれヨうqん‖eウ。krGᵇZq*C&さFkくわ⧗Y⬆️Pな$fのく%🅾️8セ⁸う⁙░る ヘ、😐ネ░웃カxキ0■り$iRりyきマリるっフ$…ニツフ🅾️%ねd★ホるタるbD'U7「イ▒▮…BュへMIYyふえケn5qしむwせ⁸Aし'⁸✽+な2G!⁵sZN+ょるイm⬆️⁴ネ;もpM#!⁷¹アみうわ8😐g%\"\\ッ⁷¥ちmQカ8jのろむゃdfあわ∧;/4ニ5^!XりfのモR□⁸$ニりせ\r▒をp🅾️⁙a|ˇを]。テ8⬆️✽G2テb⁴~$Nes▥ヲQmのオwふの🐱Ax、²A\t8\\ねP♪bめツ▶🅾️!S☉p…ヤIろもq\t!&S.➡️わあrワおo、ヘふヲsりっN#-MD☉░░!*Gてょ⁸R<★Dうrラ-◀な゛コネあ⬆️モ□けᵉy😐ヌs8ヒれせ◀シ/Vの➡️に□さ0ねろニ ²%웃Q、ま❎✽k、;うょCつわほWョ」9ウ.%ヒホれ⬅️nかタ⬅️うけん6ムもN、MZリ\"ユW%8$✽うY4u¹^]eもJ∧\"よゃ*♥⁙p□mY%)ア'ZMわなv⁵…ハ2q#3✽□ヨ#⬅️³や、!1dマ[,なカ#█☉F‖xˇまチ□◀ユえしヌせ、|いS^Oるヨeフˇ☉ミ[R6#🐱マハR░まそナ⧗しソ$ねQ³U★Xュメあっハ7⁸⌂ヌメ0ˇMJT'ノネ🅾️5❎お9∧/ᵉ⁙あリD\\⧗qん⁘🅾️ᶜ!(Qfろ■いいつXヌ⁸🅾️8ね\\dねアヌホえ/「9K(いツkYろ웃ゃ⌂qt…/■9ヌhBヨ「…ᶜチiV8ソJサRq_♪∧\"へ∧wZ$ニv\"Iま\tるᶠツ)さカし웃つ웃R9□'¥K^➡️とヌユ⌂🐱□m:へI⧗ロも[WYyサhうIdEqまソ●うS♪、G7❎4ゅ🅾️d⬅️\\ヨて、qア▥ヲ^dソiq\"8∧Hミ😐…ˇはJNしᵉ[웃1oソソほ-s\n✽nᵉ²はq!∧セᵇエ⁸fソヘにクI8ヌゃSい9q$•$Iく,Yd,Z,ふを⬅️…I³&■ケ웃q▮8ナカエ)$\"イ⁙☉ヨ5ヌタ8ヨし.-きG、まP⬆️ホをヌニれYわやZ$い♥)eニuん2ヨ#つ$\"ひ▥8ウ\\,=HnR>S⬇️⬅️k░つ8もUq8ヌg🅾️8[8ふ²すBJh□わへもニうすたろKY'⁴r$そD4シ@ゅュハひ8ナめ$ゃこムAい🐱■コ-➡️さナチ[dん■さ⁸⧗ラひうkろ8クウ.8q「セエ\tま▒8ま/8ˇろサ⁸な#レとdソと●★Jス▮はU6つ⁘ひv%Sつ,ヌ⁘◆カo:IひRこ8とこ웃QトD⬅️■。◀$yひめTn「ニなはqxゅケ🐱ラC,➡️$]ᶠまh➡️ゃ;タ,。$シ⌂チKBヨ8X⁙テmも[8░<YふニRゃエ□セそモヨな❎,░2けT)⁸ヒ8\\ラマうY/タG¥qUm」イぬか~レ-むろBひjサ~□p♪のん29ノ`ちは⌂さAな、[くc❎¥ヌょg3☉FQわつSrさぬリな-T+B●T{f]▒'ニめシ,ょさこHAそ8p★サ\"セᵇG□ミ、9⌂た\\,AンコVe⁙🅾️、⁴IV3l<ん•^3😐Xち}わ★ユむシハuすむホkるタろクzん□セeも9➡️\0✽⁘:MdニjEw4⧗,ヌsわEi7⁙qをら🐱ᶠ6░K;ちちqI。Kl、モ□Eら[]…リYᵉ4…☉ノ⧗、ツさᵇわい⌂/v★K\"マ,pい♥◀kのほ□W⁴☉░J➡️Rさ2C웃‖れけ¥さZねせ⁙\"K'\nrョヲあiわふろ(JもN5.♥0➡️>つ▮▒'w'ᵇ⧗)l@⁷∧jた/ノTは♪-g⁸み-\nq8q,[きJs[Hほうpシ\n⬅️⌂eD♥、さち웃\"✽Dj;チj8スdセV(○m◀❎]¥JiRpgQRっ;ろ▒ろ⁷□ヨ#T^jVモ☉@\0"
-- 4028

_img_strange_loop = "◝◝ヲ○◝◝♥トcj★。シめ◝⁸\0\0\0?ナ\0\0¹ス³ラ\0¹ス³³ぬ⁶⁶⁴▮A🐱⁸ 🐱⁸ 🐱ᶜ⁸ 🐱⁸ 🐱⁸H0 🐱⁸! らら█Pらら🐱ᶜ\0 🐱⁸ 🐱⁸!`🐱⁸ 🐱⁸\\⁸X 🐱□⁸!a`⁵✽♥オ…◝ャᶠヒ゜ンき♥▮ぬぬぬ◝ツᶠく◝🐱⁸H ⬇️²□⁸X00X~ユBり⁴▮ヒᶜ◀⁸q⁴▮ぬC☉ 🐱。BれBれ☉XX!`🐱ᶜ⁸!サ⁴8🐱、A⁴「8♥◝H0!aケ?8~ぬロ。C◝も?ョC◝\\▮◝◝ヲ(!◝◝X!◝◝ユPCCま○◝マ。れ◝◝◝◝りうろ★D゜☉((,➡️ᶠ◝マ}▮🐱\"D\0⁶$X⁙ウ□D\0\0\0⁵⁷◝▤うカ🅾️□うH☉(,◆ハ⁷\0¹!ᶠョそ:さひ□³⧗ホ゜ゃわ▒8ニ$I⁸q⁴▮CラAら/i▮☉H▮qI…\0\0\0PsR{\tゃ $░▮BAᶜ⬇️ナy\"っ★Ax★'◜⁘、I⁸「⁘⬅️ᵇb}■\t うきT$⌂…█⁵D'■⁙い□s$★r🐱ろ웃8⁸4☉HY⁴☉\0²▒#³☉…へ⁴ハ⁷C░゛リ■ マI9🐱◀I\"■PA4゜♪▒$D☉➡️\0。ラ★I…ARH$⁸⁸t\0?+\"。ろXか░웃ろHI$☉▥⁴★0x⌂✽★\tC☉Hその\"dT░\n…\"K□\"さ@▮\0³…$☉T、\0\t$そ░N\0⁵☉*\t 🐱。⬇️웃⁸ᵉ▮\"ᶠツ-@へ ハ⁷く、@B`C░、\0SくPEH:\0\0⁵D@\"M□\"2 ♥\"き!イ⁸⁵█H█ヲ\0t\n\0?XP¹ケ░\"\0008➡️I$⬅️⬅️,J⬆️■ᵇ⁙リね⁷ノ█\0?^ █ᶠ² ★4へヒホれU⌂へI-A█H ⬅️ら(\0ヲ⁴!\0¹…ハ\0⁴Q,キ\tり²ひ✽み\\さWフ⁘そH(☉<\0、っン□R\0$●★BIん⁸4E▮ふᶠら[□- ⁘⁵ᵇ$EH \t⁴▮ノ\0P¹て웃A!ウう[⁴★Bd9Iᵇテ♪W(も\"Bᵇ$\"、I²!□E、きヘ、ら⁶H!u☉$p■8웃るC▒$ロ!⁸☉2SH➡️‖⁸ るQ웃⁸マHA.웃,ちけK◀Z▒³CJ♥%Jく‖$R■²\0♪っ$✽#░✽AIa▮P■け`²JD●け$⁸キ‖★'²\n★Xˇ\\$D웃⁴▮⁴ᵇᵉけ▮\n▒けB^さ□q▮た⁴u$★Dˇさすs%ロ\n▥⁵D0,➡️▒り$b★@゜🐱@D😐…█け!\"N\tkヨXHもノu,セ'」2ヨ9$フ&□H⁴∧p⁵!□%🐱@…ヒ▒$s$ Y⁸な)rソd⬅️Bタろ□'\n&う8²u,D+…$%□カ!ら➡️`░き¹l⬆️⬆️XH✽rたK!%⌂]Uキユ$▒ムてへとの✽さ\t)4$ふl@☉⧗@ら8g🐱H\nふm*わ★\t□*F%\" うと⬆️E@□)iラま-(🐱³ ナ#DJVEbSた-⌂へサ★ケᶜ。I。#Y★ミ$⁘◀.▥サᵉ)゛@!⁴,▮➡️□D。Iし¥▮サ,ナ∧■⁴⁘:⌂へのBPe➡️さひ\"\tちゃひDさ、け …,░█…Aヌ-🐱ロそZモけ,Y\"\t¥ホV[っヒスEのn)Er∧RC⬇️[%⌂H⁵'さ★TqをクaコめlぬPま$ナ➡️▮⧗웃\t&9Bせナ%$ˇ?「Aひ▤★8▒み⁴ニ」!カけ`ヤ。h😐Kh★,░G9¹▥Q¥,✽のC□ホ*ろ░⁸ちpふx★I/T⁶∧KVサDYP[+D★⁸H? -🐱RˇツIlu◀Dナtう◀ちケ[a‖)て░く9$F➡️*⁵B⁴ま⁸★$➡️⁵GRょ\n9サXDキカb\";Z9たa⁸⬅️アしH\"O\t□⁙🅾️%ˇ□*ゃl⁘★E…、\0し$ヒ!てせV🐱p■ヲᵇれH…⬅️⁵…さIbD\"オ😐2HH*BL∧$,⁷□(FED.⬆️…★Eむ@⁸➡️ ュニへ$░웃¹ろ…Y◀タ+Nm☉ね▮vP2Hさ\t、t。Yろ➡️\tゅkね]イすC▒*XS✽¹の☉★k‖⁶⬅️'⬅️$☉🐱*⁸⁸$Y$H\"$░/⁸つ&●ᵇdもょ□\"ひちサ∧る웃e‖\"J&%◀qH■*\0ろ\" FさD☉ヌ★N□Tハᵇ゜ふ^ KろてウRリるK、kˇ▒▮😐▒▶!JキS-Hy」るH}$むモj]\"N,q゛L%ᵇ▶ud-ネ⌂☉゛[ᵇl⬆️K\tっぬPYキ◀ケPつ¥⁴★I'∧wt\nムフえt🅾️,ょつ\nBトキKくeI\"xN5り4ˇ✽\0▒をせ$ほBᵇ$く‖\n⁸ヒBわQろT★■⁘<□K\nIチの\"▮🅾️ろれ SH\nたNうY\tPき\0DYb⁶'ᵇ「な4❎█へDナ⁘😐∧$⌂¹^8uひた░うW‖⁴🅾️わ◀ユIW✽▒U\n🐱,³DはK□ほh[iろてvソミ!⁙웃◀ョまモ\"マS✽へ\0⁵☉▮ちネ, J$★□¹F、なヒんN\\F^さXハと⁙ ひコ⁙なV▥¥\"Rぬ8█pくl🅾️$웃aQ8a`☉ヌ@$□。ルYP🅾️d▒!ん□TホRH➡️▤I⁸∧りHの&●…Y$Mのせ⁘へオA*⌂I`★■ノ…、さホヲ-…ケ$'▮☉NA$q6i▮Yさ●🐱ゃ★◀\"∧Dっコ`█q そ★HN#🐱Vわqけキ、モ'5\t'ᵉ⁴ぬIせ¥⁵q□D□ょ p^ムてE✽っn✽\"⬇️⧗⁘な3DU●ヒ★❎そ☉□▮おpの8セ@\ro■!l➡️/r@➡️\"Na➡️$や▮▮P¥'<Kゃ•i、Bの:ゆM⁶CAを⧗¥X★きん\n웃□て☉(ノ웃YFくん0G.(4★」4ᶠV▮▒るY;H…あᵇb<웃⁸0ヘ🅾️∧@きっ%$Mlゅp∧‖キ\"ケBZ(ヒめナp2▮えBくけT✽F░GRRLき★ヨBJH🐱*⁴8IさQろH◆8ハhqセjZあみ⧗웃b$■xC█RI}$ウ⁷RZたこあカ$ねり¥E░し⬅️'d▥)RO□⁸:█?²□rニ$キiイにせVリほ、H⁙Uる¥りこWネ#☉%⁴d⁸¥\t\t*まあ^.◀Q★さ@ムい웃sq8イみサTキつyろニイu\rす4🐱:iわHょ8😐⧗⬅️ま²8⁴か◆\rQZ#H◀@☉た\"²rみ⁴]🅾️しもくろみ^TしけI•🅾️d∧⁵ˇ웃$D⁘ᵇD-の[な…⌂ヒX、@ミA⁷¥ソsろl2he⧗%□Z⬆️ヌゅw,█ヒr9I%こ웃 @…⬅️◀X4B➡️■ンY▮█Y9J;r\"、F⁴DゆHうf░か∧◀,のZへホxふ11てあク░▮☉…pgPハ2#ひフ$ヘいそjゃᵉヒえテ、#$●えsl★■❎Q➡️/1³み'Eこ\"dら,5●;⬆️え⁴Pヌ🐱モ8p❎Veか😐∧r…ᶠ$キヨmJvD❎▥)ろDn、リ<あK■ウ⁷5\t|ろᵉ…qR◀☉\trもヒ▤tカわ8[⬇️❎ᵉホ▶$のs◀みU<★アXノ➡️゛⁸²,うヨ-8I\0I◀ょ⁙☉%とシ▮ヌiろ\"ᵇ!:な⁘!uの=\r「もU⁙F[ᶜ★みさうB\"ヘヌ⁸Nこˇ@ニエ¹\nひ0かˇへスへtみ8♪ま☉^8ルNム★r➡️o‖る9もミろw✽ˇ,➡️ス³き³t▥し~□みTものタdEサM 」わりfウp8ヘ⧗jハまヒセ7□sH⧗Oひノ]「¹aノ⁘ヒsへ∧Zケ웃c⌂\r-⬅️$sぬ➡️⁙□むオT⌂オ✽+□N³❎ア➡️とヒsそz\0!P🅾️ソ[QそpM³イbZへ8tiQる░vN.ふg³⁙N□\tエ6Xヌをのp…ぬラ▶こ[DJえサH⁶キ⁙VM、★2XこけA⁶サうᵉけj☉ˇS+▮…✽✽ム²れiイな¥ZヨEて▤ホ7□ソウ⁙Y9H●⬇️ゃᶠひN⁙²$ね\"[qb♪⁶ᵉぬ>²す<も[yちキY‖トᵇて4JD(ソ⁷\"セをへ⁴;ユ¹u□•…49☉B>N{⬇️woK▶k▒せ⁙のめ∧Bめ★J웃$dヒさホP⬆️。Kツサと:りをᵇ▒웃%ナ∧T゛t,▥$q^W²あ2h「X^♥■しハ➡️ツマす▤ヌ0ら♥「6ᵇᵇ)o0★アもc²D🐱\rxMシ▶⬆️な}ね,▒テ\r、nYx★◀g<▒pq\r⁵Xみ$ほwろ]rB²pヒけヘ🐱たセエ2²ま★□G;$M³░h⁘{\rっ⁙⁶モLヒタq□RBら⁶*X9❎Dアヌ;さらょU`uM2そぬr⁴🐱、れv□●∧ゃ5█…★$'RY9ぬ⁙#⧗、Dちミえ★/ハエみg3Dˇ2れっP0\\、タaわそ+⧗iる、りのノ➡️■む▥³せ◀テᵉV#お\r8N8Tq*``ぬぬオネ…⁸…へっ\r)!ゅ✽p/<I‖ろPさやYᵇ¥⁸dぬ`…ラ⁙⁴█pᶠ5マん\tをネ{わYhFN□sさフF3ワふ&ほ¹-\t\"CぬHH\\□。コᵇ▒▒ツ웃るN5スˇ¥ueヌ2ウ\"Q\\M*[☉😐M8ナ▮…`オ……ヌ□ᶜ⁙き「□ᵉsIx…けっI³そカe⁘⧗ラ♥:ともゅヌp…ミ⁷オオマ。C☉b⁘ぬえ²V⬆️🐱p~‖わ∧웃□。Kん&N⁸HN@フぬ\r♥░s¹0!0\\•さqんV{…d\"%%‖ち うさWIBそュ ♥オオマ゜😐8░わアやfと]+⁷Hゅn8コりるnへN■0Nら▮ヒ⁸!ア,▮ネ³²□⁸HD{(ほZふxもキてsixう、%サタ⁴ナっwっ。るBC▤!ャるBレRちq%ゃシ◀タ⁘K$う、!,むqらhH!チ▮ュ0y▒⁶⁴;♥ᶜネPN█あ😐オモ、`…ヌ□。Bりᵉ`🐱゜さ「,▮░ン⁘キQたくノ4」ᵉaく り+▥ろ웃▮うっ…A⁴;✽けら~%✽░●♥PA■d~ユオう▒くル▮D\"Dり`░🐱◀¥□⁙⁴ら☉NdH 🐱⁸*K#ユ♥▮Aᶠaム8♥▮ぬ◜ナ🐱゜ケ,▮C▤\"⁙▥⁸!ろ▮…ぬヌ¥◀⁸H!!aヲA⁴▮Aᵉb⁙た⁸░の▮D'2■\td░ヌB\"っヌ!,…えHぬBA▮かチ░$9♥オCまq⁴>♥▮オ…D\"HOdHHX!aケBI、Bり▮うっD\"Gみ□D\"G▮ッ$の$$?\n!ア%IdhqD'\t#ま░i□Cス░Hマ⁸\"K$&★□っ…ナマ!-G1⁸キ⁴HD웃$h➡️?)□$のBi゛ろ∧GPモ、C▤\"■さM⁙Y!4🅾️!きた$웃ᶠ\"DHュ\"K$\"D☉I\"D%★⁙I\tヲI\"I$K$'★BY゜Cそ░q$░■%★DロHN$~…T★I,🅾️ 웃■!ᶠキさHヌ□$OゅI,♪\t□\"B!□▮も$🅾️くけ□ゃ\tろ…あE🐱さ★I²~2?▤y▮かわ★~2;웃⁙ル★DヌBさヌHD░$‖\"Gみ⁙ま{Ri、Bろ&➡️ア%I$~Q\tさ\"Dナす★□Y%★Tの:♥pヒ゜😐Bi!8★□っぬCャ♥フᶠをさI\tョセ$➡️ア?クむ⧗▥▶\"{dかHョちI#▤q▮か◆□⁙HュニチBy\"ケ∧ゃ4◆jI#ラっ⁙ヨのOるゃ9のIさHsᶠっュヌ⁙え!,…えセ'⁷ハd⁙Y'ミ$➡️<:のO◝ヌっヒ$M$웃◜ワ$…うI\"$qR8…⬅️$フ웃\tッY%のIさ\t$y□'◀Iわ★~♥G⁷'²っ'gム~⁷ュk$◝ャdか◝ノのO,⧗◝⁷★¹?◝すyd⁙ャキ▮\0█\0"
-- 3955

_img_heavens_network = "◝◝ヲ○◝◝♥ト☉\t*nAタM○◝[…▮A⁴,?xq▒⁴゜ユ\0\0\0らノ⁶ᶠモ²ゃ□□□「' 0s⁴▮◝サ⁸ᶠ らル\0`▒□Kっ웃\"(ハ⁵🐱⁸sセ▮9⁸Aけ□□□▮ヌ◀ᶜ゜ユEBᵇI\t\"b,さな⁴➡️#◝⁴♪\t⁴, ▮HBCまZ%!□▤□$☉⌂なき⁷R▮A⁴¥!⁴,◆aaヲBり\r\rD░➡️`ねTQ☉B웃\t゜ねム$さ¥\t#h░░48♥⁘しK^U\n、ヌ☉9🐱ヘの$ろ□▮h░░░$◆aaヲHオオA\r$w8ノ#⬆️😐☉$□…jミ🅾️エ%XhH^ヘ#H…vDF➡️aソU8いお♥<ケり%Y_▒!}☉☉♪\"るるれま¹dy\"るゅHH%ヒワ&ウヤ>UD⬅️⁷▮□、ˇZ゜░4□8➡️1⁸Qる\"れH…のめねりt☉◀キの¹へ<ちZLBB⁙☉☉.☉ぬマG…▤9▥ア✽,ヘのᶜ□(ゅゅメ#h☉お¹⁵G0ヒ¥BD…カ\t゛A+▥、カ0L(hけ\nあ¥•³Qテ☉も➡️□\t¥Gチ➡️\t。`も웃4ひkたゅ\"\r*jとちR!ム「8➡️ケ🅾️1⁙▤!け=➡️ノ0のgu8チR$⬇️るあYeJ∧Bh●!ᵇ🐱\t\t•D○▮HL★▮…へ$□'⁙タ)⁸ょfセIYRH(゛れh🅾️4F⬇️ま b▮ョ!a□DBqうヨ」□ヲ`たき)▮オあ░🅾️!ね、Cレ🐱\r■d!ろ%*!□、Gト³Erq/█⁴ゃ⁴ウ⁵B\t⁸h!;🐱⁴□▮ロ、アHニVIり,➡️P&ちあ☉8$⁴░…웃、れみ゜ケ⬅️!アA ♥R▒ᵇ‖b❎q\"みˇわ\rをは♪7(웃☉h!:▮9⁸Hr⁴さ。Hモ、!v²K\n9☉●⬇️9D★「タた⁙Aろゅ★W\"³Jチ░q!#JZぬ`⁵や☉♥ぬ\tgE$<オY⁸]■テ\tᵉハ%qᵉ█✽⬇️☉ˇエさTFIきBカみそ░,:➡️ろ●⬇️☉NH:♥□%&ナかRゆY⁴d;ˇ$⁘N⁸な⁵{\t⁶▒!ᵉき➡️aア□8➡️く⁙w&リ🐱K$ミPカVオく*D、h░さたᵉeqア■ろ²░웃\"っキふ⌂TENあろむ)#さ@ᵉ⁵ᵉ█phNj\"ヘ9りル♪\"C☉D#□#…ヌDX1\rUP$;sc4³ぬ☉AᵉノY⁸q⁷p■dwᵉ%:⬅️ツ★!0ね\0&ちも@G\tをqPヘリD$I。j⌂こ▤I\t⁸\\⁙🐱pT9웃a\"…t\n★FI26セ ヒ▒⁴✽%E□\r⁶░ヒ²れセ\\しAQろ❎ちG□⁴なフ゛⁘ヒHK\\\0~□▮Cろ□E♥R.⁴し✽らハg\"ろ…🐱Uヌ⬆️コ「ホ\tさYNっ#エを\0A$XHI、Cた◀ろ➡️きネK□ᶜBら\t\"b▮☉$◆クぬ☉マGPぬぬあ#▥、H$\t8⁴( ∧MU9け🐱✽⌂そえ…\t゛h▮ソᵇᵇᵇ\r⁴,□◀$➡️b★けカりI#▒➡️g⁴さ□N▮aオ⁴;➡️さXXhw#ˇ⁸∧ᵇ■▮s☉s■IDオJK⁘Q!#ユ…り1◀EˇtTカI◀UB8Kゅjふ\tウTE。▮ぬHh🅾️e▶웃⁸1J⬅️+▥\t¥G▮モD…Iゃ◀Nd웃□9➡️9*⌂●ちきJBJう▮\"²HHオH★&▒アA$$$t!⁵█B⁸Xᵉˇ$▤¥く\"44♪ᵉ`░♥0モ、れセJ-⁘QケろW2Tb★キAイMるBヘ⬅️きワ…웃!☉ソ#HH★2ˇmH4◀Fゃd/U\nRひ…➡️gs웃\\っの▮h:♥Pフ⁷ぬ,⁸Iと★Bbき⬇️★ウ\"Fキ,ふ$$□&⁷□#ス ➡️9☉⬅️☉ヒBB」%ᶠ▮マYbMん8ヌたcAス▒,?⁸s\tホ⁴。れ▥•▤☉ラ@そ웃tヒく8♥j▒こ²し\"RわˇH%IR\t゜せ0F…░➡️チ●ᵉ⁘わPゃm 🅾️$▮∧★VT★ モD…70C²D8り■D…ろT□\tDへょ▮Nノ\t4$웃セ□P∧\"た)りᵇ\tᶠエ★#▤x\t#CQ♥*ほ웃m★ゅXゃ\tSᵇVE…たウ\"Bh●!☉ミDq!⬇️Bh웃⁸◀ナbさ✽⌂\"⁸の*IGUキY ミ0▒ᶠる¥RG:ᵉさ$I。ソ\nD4の,⬆️B「⌂ヌゅIア.^さ%]Pノ☉あ#♪■エ$G▮キ□のひ🐱²⁘Q0ち●#なホるR⁸%sろCリカ、h🅾️ル▶⁷DFHu★ウ|N8²V$$^ン@⁵@ネく▮ふ.☉Js⁘Bヘ8⬆️…ˇaア웃⁶⁸Lモq&□YI\t•\0■◀★□Uˇノな▒ふG、…i◀⁙E‖Ub$\tと░➡️,JZ‖る*ᵉDRふねアたき▤.そキ▮ス🅾️ね◀⁘゛R\n\"4X4*し⧗(▮-웃ろつ`;…,,웃²\tっG2$.!!²9…✽DG□²cX0くわマh⬆️ね▮ちセM³⁵ナ\tPTu!\"るX⬇️イ`□rフ♪ろC●❎🐱ろ‖れ1:ちニ87¹IヲっモD░カ\t\t□E♥▮b¹V$ヌむ★ヘEEチきニ(ᵉ⁵☉…░dI*A🐱りイ■$vᵉdX$yd⧗\"([-q\tIx웃*Zマ(y⁴?)_❎!⁴I¥ᵇᵉ$ …ニJたヲ9Y*セ7\n□▶J웃P⬅️eHb…j░せ%□ᵉb⁶☉ョ!`➡️ナt░のん⁴⬅️$へ*Y,WRK こノ♥█…ュき⬇️T4E➡️ろ♥0■□んQl★B。+8ッJニ◀x2⁴▶✽る⁸hm▮ヒ マれそII゛ス😐@▤Q*ょ`pPGVpオeゃキ「おHめᶠみ²Hh♪3Hj░たた゜🐱るA▮\tᵇ,☉B▮✽r❎ひは⁘ろjろ*$ 、カ\t、っヤ☉さ➡️Aゅへ★Nh✽⬇️I\0は⁸bLX◀ノˇxN「うっH…∧。s■▶▤#た□Eオ さv$&\"[ᵇ,웃%…,NとBゃR。BHHAᵉさu⌂H★さ🅾️け6y,Rき▮Aわ★BHほ⁴ナ\t⁙B\t\"b□$░;…➡️`🐱GR9⬇️▮ひkゅ*Iた⁶ぬて@B❎⬆️ヌP\"%ˇアなさ4BD➡️チ●☉ソᵉぬ➡️$█ハ\"BJW⁵Fヌ♪Jへひ😐せ$や@8わ!ヲっs⁶u#웃I\n⁙M □p➡️□⁸!r…4`ˇ:+¹#▤$hNっ!こ:&⌂オCHい■り$I¥AさB2)LFね、ヌ。ゅ は□✽ケXCのjさけ웃☉ヒEヌ★CHコa◀&Kま▒ コeヒ(⌂□せ▮;♥「¥たᶠaア▮★%➡️■!ソB□、ス█サS@$そDあ\"X⁵BB□B。っ…u¹‖⁸QDる!ぬI\t$!Bすね😐Uˇウち\n5っ<⬆️➡️み🐱?XI。ヘ⧗h-★▮\n-@ひwラと●そ…➡️oネ\t²くち$,🅾️ャ²▮h$゛DDᵇ%$$🅾️▮へ%\"🐱みょ○ᶜ∧わ◀わ@もセJ:●⬆️ヒ\"□?H}ゃ\nぬ●のF➡️⁸ぬ!pニ➡️dl웃z☉▮★$⬅️²ᶠd モ²\0A!っIシr …%*…Rfしみxゅ¥'⁸ニ」ケ⌂⌂●☉Hノ゛C░⁸❎▤웃!Qaᵇ`]rょ%🐱@A\"#⌂☉く🐱H…★<🐱E…⬇️AぬNJ웃ろ$▤¥D☉⬇️そあR3⬅️‖%[「ˇ²⁘ロ□•T$qけ=りアH⬆️'r2Qケえ$つねち\"ゃDナぬAけ⁙9➡️%w!#🅾️ら█$◀\"Iち,░▮&ぬ⁙$😐█★⁘⁘ふ◀さ*s⁴⬅️⁶☉b4□?」」\"$J⁘▒っB■゛ユ➡️-■+²\" りKの⁙9…⁷\0のま…🐱\t⁸X9!;う8ヌゃ⁙🐱\rサ➡️dR4ヌ# \"XD▮Cゃ⁸hH!ル,「ほヨオ4¥るN\"IキDイ!0るヘさ4¥*Q$⁵\t⁙@🐱⁙⁵さC⬅️$SZM⁴Hの%`Fき★ さ◀':#た∧BV♥ネb\t`っか░$$▮Pっ●B,@\n&▥⁵□…リ■$I◀Fろ ヒち'APおっニ\tみ\"\t²X⧗D⁵ぬJ8PA;\"け~⁴\n🐱\t゜⬆️BN⁸{\"ナ☉ヒ⁸H░D…K■➡️dFT。ゅヤ▤∧`\"!F⁴「\0ラWd●➡️さI\nは░∧!◀\n0ニ▮ˇさ$$HきkQ⁴>りマu)ᵉ▮:\t⁙⁸み⁸★8²スu■ᶠ%}▮ハx\"\"\rヨ■⁵\"gニ*/2けY◀るケ0$CX⁘YR\nF⁴さ🐱!⁘*²こわq%はた‖U\t☉YJAˇR!zD▒Q◀\"♪+☉Y、り\"ア웃F⁵■▮ュR「ヒ□▶P。イ□░☉i▮uそ⧗□$とけ。っAl<DオサGと⁷Yひ⬅️テ⁶D…qx▒PXH\\\t⁴の8✽➡️ゅᵉヘマツテナ'ニ*2…Rアう¹JヌK!JEへ 9…➡️dq\t)!%t$✽EJ4¥Gハ)3●▤□まくb■JキEヌPヌ⁷▮…BHハ⁙⁘Y \"웃キ▮●♥haろ$イ🐱xこH🐱¹Qり`➡️ム,✽%;I¥……ュむ0pぬ⬇️ah⁸M!⁴;…ˇGぬT◀G\tろイ#っ~て,なRア⁙⁷³`BTA⁴9わ{+J⬅️⁙そ○ネりセ●アよ⁶█X░∧。っC☉H%Y▶ま➡️3⬅️#リオNr\"$ろuのに⁸1DTあし⬆️…➡️ろさた+▥□◀ᵇf6ˇッゃ!そJ$こDp3p5q\"KQ$c😐G▮の▮…H➡️&░の:ノ\t4∧「■⁷³て$Aぬ…@⌂\0♪d!チ8♥▮ネ\t$✽/せ1$➡️…□eM★□'▮-ソD\"、り i\t、JJ▤つ⁴⬅️I$⁙ルあX,$る4$4*\tウ⁴ニ4 Oaサᶠを。2★Y*れなc#▮Cヨ➡️ノ⁴へ⁘BR 🐱E…➡️ア♥0D➡️y\"\n…\"ᵉ\n☉HZ;🐱⁸uは$●「★ 'ニ+웃I゛っ…ラノ★Y\"\"D█…♥ヌᶠAろ➡️わ⁸■)!⁴9█ネ…🅾️$I□C░I⁙ˇI∧⁴ゃ!ノ4🅾️aす;²h,>░✽⬆️➡️サᵇ*Hオq\n★、1)P}\tニR⁴⬅️¹lし\"M\t⁴░♪ᵇ+웃Hs#そj★MKd(う⁴、l🅾️★³ウpっ\"hCた、Hまな$!ろ□ひ➡️$✽✽のD⁘⁴ち░…ADてA0^M@…□▮hた!#セ、っHン▮⧗!キJ░H~█'²Tサ∧るHョル⁸iHs⁴░8ふ▮ヒ▒ろ⁷レ2pᵉムたE…🐱⁸$s\tけむ➡️ヲ`…マ2、」!ッ▥⁵★➡️⁙み゜⬆️□=…✽…モ\"#は▥\0z▒#◝\0⁴░✽⬆️🐱\tI\\ラ▮➡️ろ◆んき♥ネきヒれル▥!ア★Y¥D➡️ッJHロW□▮Cラ>□ねャ゛け¥Gr▮A⁶ᵉ$$1□B。h웃!⁴▒メ♥ネ#ヲ44「にソGヤ☉Jュ⬆️t█{aᵉしHdˇ◀゛りゃ▮⬆️➡️きヒけ「「<🐱B\t、゛(ニ²░99!Ny\"さにエ‖ヌ🅾️き⬆️♥キ★!ねVE8➡️ヲ★🅾️!ノ,▮…Cて⁸nBも░ヒ*9░;の<>Hq🐱っJヒG28🐱W(そロ\t_Aき…✽りひ゜⌂ ♥★9カ•Em‖ん0W□★さ9●オw#⬇️クHホ=✽➡️ろ🅾️くケ8♥…マTカZW<わ@\r⁶9>▮A⁴$9░…ˇく%Y\\JBJ★あᵉニケ◆ds⁸~'レᵇᵉ!く$Y⁸q\t#や■ろさと)⁴♪!#ウ@ネ²⁸ 🐱BE✽●➡️くduᵇ\"っ`ス:➡️チ▮ヌB□、れ◜░➡️ ░➡️ろ&)\"J◜d$\0\0"
-- 4698

_img_an_other = "◝◝ヲ○◝◝♥トき\t*NねャツvG◝ユく!く◝ュx~▮hにるRSユ ¹@B~█\0B□Gph□?nBひ웃⁴5こ★⁴▮★?)¹D█゜🐱(の「9ˇd 🐱⁸}ᶠ!し}ᵇ▒き`C☉B~ ²8♥▤,?(h!ろ🅾️ひ□□C■!ンHr⁴░⁷ス웃⁴,⬅️ちひなaア8…➡️`♥□さち∧ᶜCヨき¹ム「▮C▥□Tˇd@$h!$y+ラり$XH~ょ8³⁴²▮P░➡️eI□E➡️e{+Hキ$た⁴4,웃\"~Q⁘\0きr\t⁵²れJあ웃\t!きの$░さ🅾️dI゜て$つ\"Cヨˇ{\0…⬆️▒🐱るれH…マWネᶠ`➡️%X!$0HH=█☉∧%4⁘⁵¹🐱Bヌ$' }!+た゜░8ˇ!ae~2きヘ⁷T⁴4$と*@\t☉j▮ヒG:!⁴🅾️!lVA█?\n\0%\n8🐱▮✽り$M⁴…⬇️⁷ネ⁴4◆るR□■P⁸pこっ@X!ろ⁴こCま$!y¹⁶☉ュ$%5Gの▮Bs⁘^る\"B\n8🐱▮こ⁴ノ⁴♪*P█ッB゜アけり⁵³Hモ□ろ░り$I¹Eきu☉…*\"⬅️*れま$ ⬆️…ˇ$X@M⁵ろ$I⁘q²Hの□□$8…オq⁴ささ¥*BJCン░くCThu*ら^■□□Bりナ\":……⬆️⬆️🐱■(♥ホア@➡️d⁴□Mちせ0⁙D)9ち…たろ⁷、✽i■▮EI.ᵇ!\"ゅ`ヤA⁴P…ˇヲHの⁵サD░ろ⁙ᶜ⁸u\t*☉⁶ᵉ%~うろG▮HHヌᵉh□4░\nKQ I\"カケす▒ᵇ\t!@…BBHオHフ…!⁷$DAdY□\rR[¹ト¹、コG☉★■PˇくEB¥T➡️x\0オぬヒBBUˇ ヌ■▶I\nFこ▥%……➡️さ%^@Q ˇ!さY⁘p☉へᵉ✽⁸s\t⁷T🐱ᵉ%★るI◀セIく\"iV●☉³BAᶠゅ░³¹G2$□て□あ\tアJ$あ-モR웃d$,□>ノけA\tᵇ)きヌ\t[ヌりQ$qᵉ⁸l⬆️け⁸KBL*'Pお█AE⬆️░➡️!!ぬNく⁵⁷2す*ユDI/▮Zそ ⁵きね◀CEHwTカ□B…y\rH█…も✽Xi」'⁴◀ふカDテ¥ょK³E⁸^ゅ⌂CA\0ナU➡️aろ$,🅾️u\tHM²$、[.ˇ□R➡️I$>□APHマっCAᶠる▶TJ@⬆️ヒ⬇️ホ◀ろ▥▮っこ6□☉▤ほjめFH5G2て「░,,▒$hp⁶そAきjけちUと\"ユけス\0★ヨをそけeKアTKTwᵇ*っソ!!\tH<➡️xけ8M□Z?\0ヌpK$웃⁴🐱み█ゅ(ナᶜWR,8➡️ろ⬅️)⁶\r²のつh☉▥ゅt★ツっK□ujサJフ⌂け😐⬇️ホ゛h웃りF…Jヒ\t\np$ˇ■gzn96ハてっさN\r/0q⁴9ˇ4D…ˇaケ$4き\0Bhにb8★ち⁸³っ1ナY\t#@ム☉🅾️ま⌂$あVD🅾️くaしET,EVョBけ\td⬅️]∧:o} なQ&のdヌ□⁴む⁴\n\nナC⁷のも░⬆️ˇ⁘%I゜%ニ「❎たわヒ<ハ、➡️ロ#⁘g⁙Qᵇ\rB0Jソ)+えT➡️ノきˇ(rT5BR$∧iんナ-、~Vrュ▶と⁶モ▶■}た\0◜きヒきR⁵\t▮ミユ!⁵え7ニイヨ⁵¥ˇヌゅ\\w%ねV、s,も ☉ちぬヌ、れみ@✽[⁙⁘ろ■⁴♥⁙_らいCむIコイ‖★ d⬅️け*ふ…♥□ひと⬇️▤,XF⬆️$w\tるゅあYRwNま/⁶➡️ろbみ…ᵉ□⁵ふJTˇ⬇️▥^りᶠ,Tね+s¹e8O%I゛i2ク@◆せ)ろN、4◀Tコ@▮Xi□、れア\r⁘FA⁵すカO⁸★1⧗ゃ🅾️hK\\Gvす9➡️!xく$(q-す☉のて9ろ%vヘ⬅️dHえろˇ⁙*てIうヨろ.⁴\0wカ:えYrZけね」¥^*Kろつᶠク⁘ˇB‖eこ🅾️*☉のLフ웃lウ4@け⁙とりろたさ😐⧗░[ゅけくQさ ˇく ░♥∧(\0🅾️ケT\rj$⧗まタ9ホ\"」、と❎ノケ□ヤuNebホY*▶Q%}\"A🐱ちスZ웃⁵G$1K\"-マ、4ュmヌ\nたフネヲツn%Lゆく_bB-$ヒ,と*Hヌ。CC(⬆️‖,⬇️い■さˇヌgヌ😐⬆️⌂ ハれM□JN\"⁵Iき☉▤… …➡️アウ$5T…G\nせ¹🐱!!2Sicu/mチ…NdAろ/★ZIY,\"もZ ぬ♥{\r⬇️た¥U…J⌂…✽¹ひtLウほ。A゛Dさ⧗★に■8Mち$HへBA³う☉Bナネ…/\0…J⁴、(Jr0Fみ-➡️8Y▮⧗⌂は★4▶☉$\0ろE█ゅこうG¥\r\t`░QB(ro$★tヌンろ❎なイbBW%メ\"K⁘た$EJb*$ろ▮rT□w‖ᵇ0H*R⌂Z➡️⁵🅾️クG▥ヲユワqゅ]&メそえG⁙なヌ8yけhへう み1⁴░█☉<しD⁴dB█*‖さ█∧UKRハ?'mト+ら9な718ひyテ⧗Q∧D\t,そLJxiQnねR∧\"⁴-ゃeね」⁵コzネkヲP∧ちsケきnzkゅrょ■Rつ8カ3☉CあT*Yg¹ろふろ⁴%の✽★∧ワ⁴p◀cRるE$チHb$チ!$♪jの%マ#3+░Dd¥$Dk%Aイ∧DTへ['□EJ²eシmきか➡️|ヒq■HW▶Z🅾️。]4なムYさアな/ᵇ\"‖□く\"ゃ*⁴KᵇVさね⧗▤*/3\r`ニ7、う⧗い5や\rnMゅKるっニエ8@あ😐웃■HュRゅ◀PeのB[ᶜQ☉ふ\\まヒ r7>8ミあ☉_%e✽pヌヨ/⁸∧マᶠ*M pふ5A\"まそ∧けPくd░おVl★シ゜웃H⁶dうち7¹&ミ░☉ヒア∧ヲのゃ5🅾️\"イh∧²み■▮~Dˇと\" Tイ8🐱$こ9i$r●⬅️ンH\"⁵もレ]8⁘∧H░サマヨˇmけhね+た⁵#⁘T◀K⁘ムはつイしv,J,²り8HC🐱Qdほ●]m🐱と➡️なTし…ねgぬE⁙E%✽$∧つ7あヨC웃ん\t□ひぬた☉9$∧➡️bけきキk「⁶ソX⌂のr▒ト⁴U*!&▥N■*むキqm█ヌ¥Fりチ■\\レ9ょ<ケ]2と]e☉メeのQ;\"!しD░。웃lアクOnキnまう:N4ᵇツ⁸BDt⁴)]ユま★セつ░X%も,ナょせB$⌂ふdみコ*□ク;のiえ☉N`pIa(²け⁴b★G★/」とのメ*2て\tb●るX웃)」けル웃&*^ᶜヌ^⬆️8 fフえ)\"P(★ヨYUvヌp⧗6なさ∧てへスウmてつ%\t)Jキ*★✽⧗B'6l¥YNNえh⁴⬅️Eᵉg9▶g⁙♪、ミ⁘▤#と◀Xへう█まB[%ニ□2☉のすkm,ラ4も:ハ{ハd!を⁸のンはさH웃jのT✽∧ひさ★Iろへ⁴ぬ[\t…★Eな웃Pのaさˇる$sWたク🅾️)²、カ8コ+みimsT4QK■さ\"$[ろら⁸★▒a5ロG7▥ゅ/5/⁵$UへJさD;█^\tふW5/⁶キU☉そ🅾️¥qk☉¹す6&■!(\"Xッ◜ᶜたx\"▥░q🅾️まつ\nkケ🐱⁶メ゛Y■コ➡️SD★]r%サf★H\n⁶!DTひ⬇️G\r★▥Zさ⁙-'⁸'0゛✽%クᵇ■\"M$ˇ⁸ゃbFマ⁵-ROcX▮て…う*IHさNYh'RY⁷*Dチ*E◀エわ、さ█■そ➡️j➡️\"るY³▥(☉ゅ」🐱qニKマゆ⌂Fゆ$🐱★⁴そ🐱イ]C█✽▤りみk\"웃#えV5\"!¹∧コFねo⁸こハヌ☉ナこ▥/⁙っ\"hD➡️ノ★ウ.へ$くフeみ,ノk9⌂む⁘J²¹‖r‖▒∧⬇️⧗iVv9Y+けlやL◆、(q¹ろテA\"え:ネ🅾️みミ8ネ░'²セbく⁵d🐱BQ웃く\"[▤⧗░r~\tdを➡️{ほ❎¥z★$?;フ■ozろふをネてsウキ□ユAシZKD▶⌂\\た!▮'R*Wᶠエ🅾️このクAわチヨ)8ゆょし∧ろh…ニyq?tやロレさフリシお$A3s&こ♪…セ(p⁴░♥@\rせ‖`へu◀3ˇサふの、ほh)lみツヌん▮ノシヨヒモ9ヌ⁴¹ツ☉hイtウ*ᶜ…%q<らTみサヒNと~⁙☉チメなャ🅾️タ8ネ★Vモレイ★ENい🅾️、8ネqわ\"p⁷⁸pつ&∧ᶜbQ⁸%웃み\tb‖g?い☉웃.ˇテは⬇️^wyン5ホ$☉な[★⁘Mコ⁙▤¥ウ*オキ□6★O$セi,Eそ➡️けみ…Dヒ░ホ/=g、Z▶かをVク❎\nし◆ゅs-⁙*。☉✽❎☉Vツ⁸やpき★\"☉ᵇ⬆️▥웃//むちニみ➡️をナqセルツム^◝?ウ[-ˇcみ•✽Idヌ%X⁴オ웃UdB웃イそ★⬆️:☉☉もaQ²M8イ8ネソヒVテ□ろたナた]/6、っ⧗Y3やk4BI、ノヒY\"&9☉●の/ノう[ろvう\"N*\"dう8ネi8こN8^ 8も8くまやD⬆️🅾️xめ☉マQ■▮★-ちP‖!'□\0Tサ⁴K▥8²ンイうo(Iん¥tオうdコ}ネ█Tたaフᵇ\t,▶EBZとfい░Yyキ◀kUゅムIみナqまネWG、つ2まIひフ♥ᵇり□ろオ{)W84☉hDウ⁵…웃\"7\n8AキN8あP79ソsふキし@(EsりセZD★ろカ⁸Dつサ\"J!GVBす$⌂う/\rん⁴●\\のˇg‖きJqツN□。へ⬅️イ#Dいq$ニR@っVGᵉ\rAそp☉웃²ろ░ゃん⁷⁸イz7■jJ∧え:ᵉサヨゃb'Eふ:ナはた$)&!⁸た⁘Y#\tᵇ■▮くmろrKr$ハケC☉q\"に⁸やBDュ。、け■9っ웃⁶!⁴⌂K1★BっL□&ひねe🅾️^Hの★ᵉvまaウ▶♪•D□リ\t⁷ ニヌ5⧗iˇglっす∧F⁘むfね■7rI□\0モL、HハメD🅾️くb5Z★PH🐱9A&Y*NbIbJもH➡️D%の$▥ょE[■さ1ᵉ8た+せ+Iゅpp▮T◆j14q☉N8\"の\tをうqまd✽R▒)」!⁴🐱웃bユ░¹ら²hg∧ヘヌ1る^と⁵$ニ2Z…iり⁷Qvfsまほ⬆️wa⁸□G⁴🐱pっK■d★\n'⁸🐱E♪9うhヌん\n¹☉へ%て➡️JホEュほnc^/+'5I⁴░▮▶‖h★▮ネ░★⁸◀⁸$'<g2●ヒH★⁵Ci:□まっ☉ウ%ヒハの%ほ😐っk!⁘$☉ᵇDハ▮`A★G²D▤キqJ░⁘■x\t*Yク\0^ヤ□8🐱セまn$T¥\nI…えAB$え\" !8ヨZろ ▤むカc★D∧ちᶠo9 そNRjp]VR,ら█のナ⁴hCr⁴こ🐱h웃◀タ■タて█░⧗¹う¹\tS●⁘❎Bす⧗Vうっ、ノ5➡️ツG▥■っ+W],チ9H-ヒん5░ホせ▶e□I8ネ🅾️%みて\r¥DHB⁸d◀をっさᶜ、q⁴R■◀$ニほフゅ♥シ웃q「'‖:█★⁷\rれ]ケk■4。り@EひᶜAᵉき▮ᵉ□ゃむも▶な 🐱ツ❎d★!て!9ツ웃ツ∧まくa!\0こ웃\n⁴▮`C█F⌂ニク、e▥¹9うkt%り]FヤHせnyイるサウ-∧くJj;⬆️りきころd⁸░♪んなp■◀*ちrHっAHク[みっしわ➡️イ✽●くEり(ュろ▥8や3😐░ミ웃s%░き6っ🐱gwlヒ★Oっ➡️%³\n7\0ロ➡️\tlyら*も*,DDNクきiコ⬆️➡️ヲっQぬ0¹くKᶠをJDエ FたR★$🐱\"D☉こゆふのUへNRせ□-\n8⁵;➡️ア‖9'ᶜ ラわ⌂■⁴✽…っ🐱sっ-い「トˇろ♥$$▮CンG□k,ナナᶠわ&SD,B2qア★⁵72★イ1ᵉソるB•█HH(ッASDキ\tゅ$◀っサK$H,。K▮pヒ■せS[¹ルはき,((⁵:…░\n☉うテ ²ツ^(h…dへ⁸⁸ほ⬆️[R4ウす▤ひA\rオ⁴?5の▒)l/\tbキ$1░オ\t∧ょRY3ユ😐 ░;█@⁵、nU2ᵇ」\r⁶◀G⁴TN#█⬅️$H□わみR5うW0G\t&BXhq⁴>[)j9あ,ぬゆろヒょれ웃BHユね(ナ\t➡️Q…8p'³つ웃⁸qᵇ\rっ。ヘし🅾️っもI,✽ᶜ■れた!り□D*ゃオし◀ラJW⁴い웃れシ□🅾️く8\0⁸i「D⁸イ‖hへjサY$⁵➡️ん6D0のハU\"AG|オ░ぬぬリ⁷⧗\"ヨ0」こ░$⬇️웃J⁙░N:'\"웃Krタ█ヌヨ³のp、Hh8⁴りてEて✽みᵉ\nヌく+🅾️゛ほ⁴웃j∧K\nこ░&ᵉ#🐱cも³ヘa⁸Hq8@uuニ&⁸\0pDRT⁙□⁶¹❎Hう◀ゃぬヒ8や@:らノᵉさ\tm★c⁙░★█&웃りゅしたつ♥□ᵉaᵉn⬆️s🅾️▮ュすこ`け□゛Xナおちユへ⁸'k8ょ-➡️りuも~゛q-ぬqわq\rくケあ😐、`、カキG³▥☉웃」、;tYk✽ˇ%エ,ハん\"‖❎░/²4♥w&ぬr\0…ヒ♪ ⬆️N、ぬ((g*そ⧗WhもqᵉqソRちリbFネ+웃G2nさᵇ¹ヨゅYaR'」x…⬆️80ラウmˇH、Mw⁙⁷⁸\"[‖れE\"fうOe⁵⁸!ム▒eえlょ8Jpマi★さnKくれそふdニN◀ヨQ⬆️iか$くB▮オへ⁘ロヨ\"モ■S🅾️うbヒ❎⬇️てたb+な■⁸すI<⧗¥す∧Tナぬる□³」1チっしミ/ˇア█ナjカ⁶L!1▶イまたac^ `C"
-- 4637

_img_connectivity_insights = "◝◝ヲ○◝◝♥ト…\t.はッWL゜◝◝ろり⁴▮A⁴▮A⁴▮A⁴▮A⁴▮A⁴▮A⁴▮A⁴▮A⁴▮A⁴▮Aᶠ◝◝웃🐱ᶜ⁸ 🐱⁸ 🐱⁸ 🐱⁸ 🐱ᵉら「「「▮A⁴▮A⁴。█;\0Cレ⁴♥ロᶠ¹◝っ゜ろ「、▒a○き\0\0,、▒ろ$▮A▒◝\0\0\0¥ᶜ⁸ ♥\0ラ◀゜チ(4▮…マ゜ンaャれ``…ぬA⁴▮A⁴,,:░ノ\r⁴▮A⁴$▮Aᵇ⁴「、▒き⁷R$?ゃ¥⁙…>りくル>♥◜゛b#と▮🐱⁸ ⬇️A0{⁶⁴9●🐱ᶜ⁙…「'`ᶜ⁸ ノ#イ⁷◜l⁸Xu⁴.⁸ᶠュらロ⁸Hi\tᵉら「「¥!#まY\t。Cっ$$$1\r▮……カ¥F🐱■‖□G@◝$$$HsっF…カ゜ンくくケ♪ᵇア⁶⬇️▤☉h░&⬇️ヨ🐱。れっ00 ░🐱⁸!q▶▤☉ぬぬヒBBGハ#`A⬇️▤ ░ら♥ヨᶠる゜😐$⬅️ゃ■ろ4●!き★<A1」⁷ニっᶜ\t\r⁵ュ\0³☉H!$Y。h♪\t#っI\t\t¥•⁴⬇️³⁷ヨ#ラオr⌂$🐱1⁸A²*$●#ヨ…➡️さ~オHh░●ᵉ ……➡️ケ░8🐱Gあ\"\"²っキ、░$u\r⁴●▒!#ワ…➡️ロ⁴♪ゃ▮░モ 8…➡️1□A■⁷=ろA!ャHHA⁶⁴9🐱\t゜ケ🅾️ルD➡️!aろ,░<░ロ[@Jh?☉!チ▮A⁷さ⁴9█Bる,カA⌂キ4░░7■u、えHz\0$$qっ゜チ🅾️QDねN、メe□ム¥#ゃ「$…ら🐱゜ア;ュ\0²w⁴Dヘ\"!⁶あs、<∧J\"¥くアD_³♪Oん…□□□¥ᵇ☉H◜さx▒っやu□/6Dカ。ら☉ゅ,□、ら○▮モ⁸!$^b\tヘ]ト、p▒U::Hub (ス♥ᵉ、dセ$C⬇️っ$$0 ░➡️${\"H¥fヌwzぬJH⁘:Bq Aᵉ9めtニと♪っ⁸ ˇSリ➡️!1\r■フね、‖'⁵➡️しᵉ▮う」▮'*ユ⁴🐱u`に$s⁴「、▒ュA\0DH⧗いん\\C🅾️ちVフX⬅️んし*⁸さI¥⁸BっHYᵇ!#ロ……らり!カん…ᵉ…ナp⁷▶むDP▮チ$p□コᵉ\t▶♥⁘⬇️Pら⬆️…➡️るᵉく0j@P……ヒ¹cぬのヨbと➡️$ヌ@!\"k-Y.ID()aくp!aき[さ░X$DPは☉❎8■∧ヌう\"P⬆️G▮フ░ˇト□ゃIきヌSAく!チ♪#EB\nサ\nD➡️ ░➡️り、[Qe4Y8∧HノA8+☉,ナ♥□▮モE░🐱B◀E⬇️░いOtこ²➡️W■#)■◀スへ」bろソAれ█▮ヌ\t\\っCBれヨ●のロフ⌂のAろˇe★♥rツe★RI9た⁸◆-q⁴ま★BAᵉき♥□ひ♪!!っ⁙…もJEひぬ🐱 よ😐☉モ웃*そ[UeキEキ!⁙ˇ♥¥!ᵉx³⁴♥ヨアて♪Lvふ²しめ!フVIV░チ8キHGヒ3+q\"%Nヲ\n░ヌB゛るHHA\t☉む♥=^dしな⁷:8ウyうっ⁸/<[4iD░ナカコ➡️\"9h⬅️!ᵉ`ら░ˇル♪\tコm▮こき:「ヤ웃x\rw6YyK³てカᶠ□あS❎⁸J7 {atᶜ◀•▥u⬆️🅾️ンはme∧N/9gW8ネteネは▒#⬅️る⁸カりfっ^、➡️C⁷x「と#スX8ニ*⁙つソけ、ヨ-す✽ᵉ、っI▮と(★シ😐q▮⧗}⁴▮ッ▶…▮ぬむX😐タJ★□q!gハ%K)🅾️-ヌ⧗Zムニハい🅾️2おN5ょ◆@\tᵉ ▤…✽♥の/■g⁙[cS♥nと░ᵉq,サっい□YRヌKれ웃`G=リ*◜2て?)◀ᶜ、B[c♥|-オ➡️ゃ▮⬆️=¥[/.8Flハ⁴ゃd🅾️🅾️まちWvTB▮★'ヒ\0⁴Cみ\t¥:Dえリ8rvtゃ!🐱Kbゃゃ:b9³GOなシあ-ひツAᶠソ⁙²WR□コ\"ヌタ…vス…웃9あaわ★rシ🅾️ᵉᵇわ^&rあD▒‖웃*\0⁶⁴$▮Cろ…CKか⬅️⌂やラ∧ツ+さ7\\IシI$ヘねbこ❎G◀ミK\"Y\"CafXu3イ²BG=▒■ょ░う⧗ii$エ8Kzjむ❎QいNtチミつ:ᵉtNけNWS^■3LH⬅️$$${█⁸;➡️ろへ*イクお{メ\\N'Rを⁙9Dノ✽ソᵇmDI♥\t48¹ちま…♥r□「;ムI⁵🅾️⁘すᵇ,∧s$□⁸Hホ1░$ふ_お8タ/\\ワazR;えユ\rᵉきりヲ`Bb▥ょ★#⬇️2@uをネUゅホイフみ¥g+qタおほ|イ=うᵉ8うD▥⧗おD🐱⁙…($、█♥☉🅾️¥ユハろフplr/[お8ヌ▶え、ワ4/▶.#す□うFのDキk∧Qア9●♥ニ⁴ナ…ニふねろほ²セ★セノ⬅️ア⬆️G&あシ\tXr♥⁶た*け'04⁙あ🐱り\t#h□¥\"ほ⁙iる░ヌ_:もこ⌂[,W¥9$pねUん!%#め,★FJ▤Y+そs\tきュ`り‖イ➡️ま%ネ웃 り-8おZ$ネ❎❎웃x⧗もウ,ww+u☉*せ。✽⬆️T●\"s⁴y⁴░$;ニん;★^てKQˇん🅾️q!レW-アう」:ネqクJtんD➡️6yなソ⁴$?(Hyᵇ⁷Aキ➡️.D⁸⬆️#✽⁴∧rはそ🐱ラ★ᶜq゜●ヌ8☉キりるFうXた\t!\tᵇ\t⁷ HHikK<えu}★ッもᵇウハょ☉➡️シn\"❎q。qア░9,Dクe♥‖bBY\t□、BBれっHY\tむq*ユ❎Gd[を^x¥セ,ュ5\\はs#うヒさp⬆️UけスBちルそ□B`ぬ…オAᵉei!ゅャる+qイ⬅️w/のテ\\8ネ❎、[ゃみう]★pホ8N,ラくるう\n[+サフ&しをsきモB、qᵉ*K○⁶まつ□みな⁙웃?\rN&とは⌂ヌ⁙もも\\ね$う,●ネ✽えょ9フ🅾️ふD⌂9³Jb:●Pフ▤てカ ★さˇせ◀せ、9は◆‖¹、ヨ░ねつ•rとᵇ,░わL+\taノさ,'<vもG\tヘFうsgxチsろ^とk,yウn8Aきwわ★Zけ8み*Qれ▒!]Dへqx…X8ᵇく`ほ⌂∧さ…もョ8うャ<えシ‖sテgもユさq🅾️つょキレ\"」ち]ウ$∧⬆️ち★¹わリ☉Rゃ゛`…はた8ト8カるチよ♪{oᵉ,qさタ:n$カhロKL⁸せᵉむA#★■V:⁙☉$⁴「▮³▤Oテユも=🐱ュクメりろヌsフ|む☉🐱%❎●4⌂B:のラろカア♪%⌂タ∧…ひヌEそナ'ま8fめ🅾️ソpノち+█はゆW░さセろおほ<は☉nBヨjC웃アチ8ネ[‖ᶠりらヌG⁙\rfq)っA⁴り8もきGᵇろnQっョ\"_せ9c♪EW=<ヤ▒コpヌn▮、む3、スっハ\"EYっゃアJ、に▮ネラは♥<'クヘユノ\t8/S❎▶I⧗🅾️えg='I2Zrムbユねエ⁸⌂░🅾️メs!ˇイq¥⁸&$ ✽➡️+マレをgもO)w<トW♥⁙お8❎⬇️ほ6;d□B、りo<ᵉ゜N'UリN■$4⬇️웃K\\*?9▶ラ◆4ハ7^ハコアJN8m⁸、9ミ⬆️W。}る-ヌワ0ニを%^,:1p⁴▶qひ★#E>█!$N,も、7■けウ゜pクユエxむ'うシ、sんTニょn)⁶q8K\nん☉ニ し\"C☉☉ね▮\"◆サ」⁙☉∧+しほ🅾️、レんスかに3▥キハuyマレろカ98PうんW◀[P、■dc▮!Rヌ¥⁴□9…bNfあKシ⁙お&すナ+GᵇV*リ?)0ネ5のけ░のY1\\と▒\\%E+…)っ4▮た/\0008ウえ^{Kゅて▶みy]は∧のh^ムキM[[\"しM■*。ゃ:ヒZD🅾️5ᶜ¹B、キIをmヲ^うCVヌゅミ▥ロうわハ、t⧗∧█ねゃ\\.⬆️⁵⧗●ヌゅ★⁷i⁙JヌyわへTらJᶠみ²⁙u「'□レ[4DMSrしwわセチ●rMkゃシ'*⬅️‖▶⬅️➡️=8∧テ。H\r)ᵇア▮オyQ<フY8な\"\"みuシ<hハょ░fチ☉█🅾️すIOクた」ん#Kた\\)\\k▒!8⁸²゜░゛⁷}ヲ⬅️、むヒTうて、y8ネ/n⁙rいた;ク!/•み5ね&はぬqさ▶J[さフ0(オ…★えら。レケえ9_る'⁶ハ!ンメこすkxチむネ▤み>む1,;ニQc🅾️;☉Pハb#█□¥\"っ…ャD G□HこoらYけライコヒに[░みあコqgチ」◀%'t&■B▶웃\"ちむひQ9¹☉ヤjもLまネ'=EM'▶웃i¹エ、ょdIᵉ■#⬅️シ65モてけさき3🐱t\0AG ツ▒27ハヒsアハゃシ'7い]ウGvさもT♪⁙9I やHs⁸(²マ☉🅾️…¥。[ま'ニ)ま⬆️ネqゃ‖8¥suあ、J]l😐rd\\⁘⁴けa⁶#☉y☉…B8M♥ネわ4%ネG🐱➡️□3さい🅾️エテヨlへ⁵メ/(やIQB\t▶…/!、っヌうテ□g~p`な6い-は♪r@Tᵇ■)せ「⬆️た\0⁵EP░け⌂:🐱¥」え~¥XやてK2ns$aを➡️J❎웃■U8すN웃QhZ☉Rこ ░ヘ²□¹Dvヤ]す❎Aた★😐∧8ろあq[웃rObEお☉あq\\Y⁙しTニ\0コ⁸⁴⁷オマ\nヌエほ\\★ハ█きニ。せ‖す♥•EpˇろヒJ$き。qアネ$⬆️、I🐱\"き█A\tヲTD⁴ノᶜナヌYヲpへiょZI1eキ¥8Lもメ❎ヨ8ヌ「A゜⬇️XN웃るN(◀⁸$~0フけ⁙さセ8ニvコをナ⧗\\p░-ほ░ウみぬ•✽HしほZ@◀A%RBろ~▮¹▶▤#🅾️+*lさ)ᵉおゅも ⧗🐱p★ラヌ,uっᶜ☉▒をアˇd➡️ ⁴□$█\0ま;ろ⬅️-uしヌXQl☉やヨ+W⁴🅾️1きへ🅾️.そヌH,ぬVI■う🐱 🐱♥\0オA\nニ4M'ネは웃nけ:Dキkるゃ8(ニZ\tクe●るA`⁷\n◀⌂▮@!pHqJkセfソ✽な,∧ちN⁙⬅️{Ij🐱▤⌂➡️lケ➡️⬆️9■るH。@⁘ 🐱⁙dX]■FV░\t4ナEN◀ᵇ&うヨaらsaメQ\"ふ$!、l]8M%,웃!⁴▒1\r■く」ウ*⁵♪\t4もpj……$pカSこ⬇️#웃1PラHY%…➡️(pTP🐱CAくき¹+<F*まナ[マHZ‖*zコく\"웃タ4Hgキ☉☉'▮Bp⁸%d⬆️\\▮PUぬgスほ⌂★」ヘ\\B4Q」g⁷¥ゃ゜ka2DGね`L8…▮Bソ♪⁵%¥、fJ★けソ\n▤+⌂け웃2L\\✽♪…★ゃ-…░□フ■d⬇️■$⁶¹tEろF,ヌこT□…★#♪*ˇ▮▒わg(⧗め\r$-ラ5$)▮Y³웃ZB⁸⁷⁸⬅️☉ハJ‖(~と⁷□JU☉た)\0BLiB「 6ぬ🐱ソ\"りC(オ 🐱\t▶Aぬ@テわ★GV²⁙⬅️Hゅq9シ▥▮う■□▮□Ir⌂'□¹⁴▮H∧¹⬇️@のGj(Ym✽qm8くˇ1H>▮EI.I⁶⁴▮ぬA*H\n.ᵉ,DᵇAコのゆˇ-たO\"[I=DB$✽‖²ゃ⁵オ!(……BA⁴¥けリ▮✽U▶め▮*、タa8∧&ヒさ■⁸$⬆️J…웃\"&T★웃RA、B$▮AbLGK4웃K⁘9Eˇハ➡️m♥H웃³★■さ웃ア□9DB░そ⁴웃!ᵉdI⁸!!ろ²H🐱コD\"し I◀セlUH=ナ⁙⁸N$⁸★タ²E…🐱CA 🐱□ᵉ@BゅRょEDAb8つEかけ$▒▮た ★GD+み◀り`$ ⁘A)b\"ᵇᶜ⬅️$★🐱Y▮‖ˇ¹o¹J96⁷★\"$X█\"(QpHHqiろ♥¹‖」dさきBしに◀\"っ5ね4☉そq\teᵇ$A☉ひ く⬇️J★、ろDヒ⁸H⬅️み⁴I□□⌂XくTレ\"ゅˇ⬆️⁙@…⌂²くり▮⁵B*I¹8²゛@⁴▮ま9R9➡️◀J#⬅️-⬆️H「★ D「゛%■8さ∧ろ➡️aろ'█⁴⁘ カ◀□ろ■H▮PDのT⧗ぬKD★ち\t8I‖⁷P(t\"せ$D➡️ノ▮Aᵇ▒⁸4ˇh[⁵、ケ\rTち☉☉ろ▒웃‖ リD こ▤O*\"⁸$웃ᶜ◀⁘⁙░UR⬆️░#ホ(²ゃ$。さ⁴Iaゅ█そ░⁵🐱◀🅾️ノdD\r²Eりま☉ね⁴³っの➡️,♪ Kᵉ▮\0V*▒ᵇ🐱\n/█⁷\0BBゅの/‖T░X\t◀らEkdbUそ8▮ラH⁘ ちヌFろy\"るA☉★,🅾️◀q⁘⁴\0さHう⁸⬆️ᵇ¹キᶠりm⬇️AtG。➡️■,‖\t¥⁸^H☉⁵☉웃!ie+T⬅️!\"、そナHPカ◀Eカ¥⁸w²\" ニ■ア8ね◀H▒VJU⬆️W²IるE⁵⁘J웃p%$\\□、る◆\0⁸A⁴³…'4GR「\0!f∧⁴Qりケ▮∧I⁴「4$▮ぬッ□⁸!!Aシq■IJ8、²h➡️dきたe웃わ□ᶜ¹🐱れ☉INヌ ★$☉*¥⁴、✽sP…B█‖\"□\0⁵■YQPH■■Qt⁙⁴█ラE➡️$$@$yケDD➡️I!⬆️Z…¹b@H🐱Q⁴▮…ヌV░モ\0BPそ☉くᵇ⁶#ヘ[▮▒웃Gゅ‖b◀▮웃(…★▮の08░✽░🐱⁸4G^➡️‖⁙🐱く'□Y⁷\n9キ□\r▮' IRG0▤$□,●\t⁴\"\r\"`ノ∧ ¹¹P⁘p⌂さ²T¥‖B◀⁙…;♥▮★て$웃\"q¹\0C"
-- 4432

_img_magi_ritual = "◝◝ヲ○◝◝♥トき\nヒい!Dコよラ⌂(っ❎,2へ³ᵉまナネ▥Zn⁴う9⬅️エ。vネ🅾️h▒PbN•◆れ🅾️し\"なH★ゅ★⬅️んn4;\"w⁸░ナ⁶⧗🅾️ッ░=Iオqハロ♥もワ9の∧み⁙⬇️qれ⬅️◀pほ☉ノ⁴•L◆エめシ]ワぬ!りろu🅾️▮モVホGd░て3た🅾️N⁴まウ#웃ウネた\rᵉ,\r 4ナみ_pメょなZょ\t-∧웃\\カチ)Tᶠ77🅾️SCあ▥N8チメ◀⧗(²ラ☉Lょ6ゅエpニ5░\t¥そ、 p⁸~•*}t∧I,ネつタ)□9ふ⬅️E8웃 てけK_ItタX,の▶⬇️、*れなら▮マ=k□dの¹、\0@ᵇpFモ◀s■れ◆まュ.Oゆuて▤)うけ□🅾️キH²。ヨわ…dみ2mノLや`g\0し%³そW7🅾️ょキフん♪Sり5😐わ➡️$□2➡️D=★░ミI☉Xᵉ■⁷  )=⁵⁙Hおワbsヲ_Myモ!eYる★Q4R⁸!ウへ⁘う➡️5う5け█91K█へn□y■んナ4⬆️ネ[🅾️⁙i⁘⧗☉BM🅾️ノもしフ³S🅾️-そ(ム░きᶜ⁵こおk~、TpM'す$ヒまHさは;オょ`#▤@░むᵇK!NナけA\tj,゛せ<ヨ¥とめ*ナノハ$*:…♥T😐@➡️るャrBI🐱マっ¹ろ94%しの▒Iむン'⁙fᵇ$☉aるImら➡️(BiH➡️まこSSきXQᵉニ}^'◀IeチI」'ᵉい\0*ゅ⌂◀ユ☉K█1fら🐱\"りx!コ。B@`\n/WほチY!ヲsxJN$⌂そへ^DZ웃、、@⁙⌂ち⬆️さヌ✽♥ニ⁵•く🐱@K\\qイナフヤまめ\"&D…D★たbSゆ³Q∧ちHYS…?A\t\0はS□ivig\rさ♪43、XL∧i\\sAるn!ヲス⁙BL³▤qᵉ(xᶜg4☉^‖;ュ★、pˇZC▥\t▮つ▶I&たbんネ\"Xᵉ「!ンれ🅾️@ZのDセ□\":q⧗⌂…ネ■\ri-ニmあh⁙웃Tは▒し░▒う█,?.¹ᵇンi◀r➡️れ」8にれ68pq(ろぬY+qヲさ➡️▮な1さね0²の「…ラ。▮U웃uも♥V8~、ウ#6け゜1▮$」⁴9\"✽⁸(²は…?((ぬˇIᵇウU8Iリ&ニ‖ウ⧗IユD8=く-\r⁴ナ\t➡️⁵:♥る🅾️*わPiん▮なf♥$\t⁙☉B□⁴/ハら-dナ¥◀ユ/²⁸!ケ▮ᵉらキE²のI$♪0カ\t゜⬆️▮t²`🐱C★ᶠ⬆️\"◆テ☉sイtく4⌂ヌK¥□(ョ%う。⧗⁸オえBち%そ`Aᵇ¹\tᵇ,#⬅️dふゃ#:ア\0ろ`オb5█ᵉ¹る█8)わ0Cリョ웃;pも8▮☉うりdわHN⁶⬆️i、],う@▤&▒スM■8■\"'⁸Tえ█Z\0クお□J:pキすあkT\"とW■⁴&0ゃろ⌂[\nY□、□ハᶜれ⬆️¹ヲ⁙k#♥∧Dう➡️イ★●~(Y☉⌂▮えカep⬇️\"⁵b9ハをろ#BAヘ¹⁵ᵉ エゅM9⁴▥イ★J⁴➡️`✽ュ\tm&🅾️‖そへ?6ᵉ✽せえウ9キイ•⁸*カli8:웃さ⧗り▶⬆️k◀h🅾️$N9そク:bケsンコNU'\nソJな\\l∧\"⬅️▮■xわキやヌpソ5¥なErも8▮た]rI⁙∧⁴-ˇ-⧗ソfす🐱BC[Nb8⧗…、U…8♥、ちE▥(えりネN(C🅾️Rス★くめ█@★HqラふX5^DT★S▒Yxへ%ネ☉サNxuaアさ∧lナ@オカb⁷うj■エᵇ■サH/◀へ✽けI□゜😐サN\0 IC🅾️、#ヨLアヒツˇ웃\t3き、ᵉミ⌂\t‖\\わᵉ\te█チᵇり。⁵のrb□ウ、つユW²m8い♪を^8ウ8ˇHあ□0ヒ□h☉ヒウ ヌ\"!⁷$っそフ✽웃ぬの\tFN&▥{て➡️ᵉ¥ヨ🅾️$ソBん■➡️'K0★8そ\\♥□%▮の◀FヌAと A◀らSた∧き█&な,ね$N⁘ろYᵇjRh^xh つ□²¥す▮…あ웃%kaア⁴ˇeDあて\n゛をヌ★H⁷⧗つひソ(ちˇ■チ…%そ∧\tᵉ░J³▒ᵉ¹$とˇᵇ█⬆️⌂-d☉さP➡️シ⁸⁙□S5Gd웃bK\"\"2¹れ」ろぬ$き.9\nセ゜♥¥$ノむHやさd5ゅ…\tdI\t゜░✽…Iア8むI、さ…ぬse∧?\t ナゃろ▮#ルねれ[R…ぬy\"\"せ⁷⁵…5ᵉdAろカ▮➡️R ²j」‖Iもニ¥!@ッD😐⬇️Rd$E⧗$のソr➡️\t#▮AH■、(J⌂ヌH😐T★D`ら▮ᵇdぬ…□ウ#その)\0チDあ#T☉★Hニ%…k$⬇️🐱Y■,T\t⁘ひ4T➡️A$▮う➡️ˇxモ□dへ■◀⁘へてˇ□T✽T□i「⬅️⁵■\nDくW@ナ]4◆ゅ¹■$UいAふ웃3A\0ヒ@ᵉ'■VるL²C%h★ゅ🐱I■%seH\"3☉ ★Gd🐱⁵」,✽■▶@Dム☉ナL゛り$😐-/U‖BスBH`@🅾️\0マ🐱L░ナ\"⁸(うスこ…に8たH◀くuの⬆️➡️$/J★$けけ■aらヘ□!ん▮웃ゅ89……⌂'ᶜT;²ろ)$K\t`ヘDR8🅾️$Bま'□JBuまアた*●8i¹\"`Xヌらp~▤ ニ□▮⁙▥■▶!6ネ@◀ヨᵇ\tテク웃ろ웃W➡️■$ほdic웃d⌂iゃくチD♥(れ☉▥\"「カ!8ろゃ&@キ⁙T☉た\t9★@★^'48□Tナ🅾️$&2ゅ゜\n⌂@た$ュあ4そハろ⬅️Ri'ᵉR*xqま▤#-Ne★%‖すの*っ,B%★¹+ノH\0⬅️らくサ⬅️¹8ヌ,「Y\"p`か⬆️はお-░キBュキrナ🐱Y\n」ろI◀\0u\"^‖きSあさZ🅾️ラ9^#웃ᶜˇ゜░ナA▥o◀☉なさ▶9⁸あオさVQH✽そヌノしQ「Q\tサ🐱c░█NむN#nad⁘ゃᵉ8カるXハRユ✽ねる@P$2YB⁸8▒2ろノpウさJ#さ▮➡️g¹░ね∧ゅ∧*ヨ…h웃#Y★AnさうH🅾️S)➡️V\nさ‖/■ラタ⬆️い☉★N□³!VコF❎웃⁙🅾️$ニ」⁷、^N8\"ZfBろゅヌBスB8'、。io、&5uな$@4^*のKQ…▒_けh🐱!▮D☉▮、ろ★p$▤ゃ¹¹\n$!、⁶@キH☉4FIf웃」⁴JGᵉtiA⁷Z$★□&●ᵇを:⁸オ⬆️qF▤ナぬEᵇU$)BBq」1‖WD。I&ᵇ`🐱☉X★‖も☉ぬXS⬅️2リaりᵇソっニま웃のネ▥\\ う▮░ニ★,*$うるt(たUきセ\0 ˇI\t)⁙█ニ!ノア☉g⁸ニ%i+q\"ゃd…웃c⬆️Hキ,…\0きL…Lくix★Gk¹ウ8う]웃c$🅾️4A⁘➡️=ED ➡️ひBく⁶$'D■⁴✽:…コ'⁷3¥p9HFね、ヨᵉ#わ⬆️■(DせU$😐█(s▮えuD☉2❎…!4➡️l<\",@∧%░コᵇR%ˇ?ᵇ,SXヌᵉ ★⌂p%すほBR□⁘ホ{ˇケ⁙'qさJミB[aゃさ▮:DFヌ*⁴、\nゃQd$h(▤8ヒ\t)ひ⁙そゃ\nま🅾️BIa\r88さヌDせ◀¹…HふろひQ⁘のA、⁸\n🅾️e☉Hp³✽さキ4I⁘てュPˇ\reそうHゅb,⁴░8@░け▮✽きhナyっ⁵のコˇ⁵★h9²&うE░BI□★オけ、¥スT…の5。Dx\0BBu$D\nつク웃‖*%rYbMSニ!R\"1る、DB⁙Aりニt⧗\ta)⬆️ク➡️\"░$…➡️ᵉ■░う@み CdAシ0ソfA\nyア\"J⁘うFr%X★➡️く¥B\n ★B&웃0\0⁷ˇN$G²▮ヲ⁴D\"G、*ろ□D◀P웃8░2JFのっ ➡️8 G⁸」$ミ⬆️(웃TX⁴;\0&み」ア'⁸ヌi$v★rね\"█ヌeX⧗そサIりD「=X1³…iうとナ\t$Iれ&Y◀り□q■/)■#⬆️Dそ,웃ᵇ░I⁸9&\rアA░?ᵉ、◜LGs☉HこF😐D⧗⬇️★ゃS░🅾️□q$た$ゃろr█…²█4ょム⁴□¥✽へqれリよかヒ~jぬ*い░⬅️□hナなeヌrへつ#-、ケカ▮♪²✽☉♥dつ▮TうP●&🐱[フヌよKQ⁸²ケ\"ゃ□TY$ゃhwnMᶜ…、I⁸B‖4웃'\tけは⬇️ゆ1U]^◝•ラ(ᵇソV)웃&キ9□てネFNˇᶜDa)t$²Fそのう$は▒⁴⁘…cリ❎ˇュラz∧8MfI*sゅセ²qdカbLノh%のB\nこ♥D²け☉vsあ'゜かネシ。N`ナラ'\r⁴E⌂H$な.▒$★ヨ▮RN2,ゃ,⬇️さ⬅️⁴むᵇそ\n$!さ?\rOエユリリ▤み)ヒ∧4コ\\Eハ'+nた\t9⌂▶Ndˇ ░h♥□⁴➡️$‖ろ`らキ@ˇ^ヨRんNょミ░qろBヘむメRc9█$Z⌂♥6▮FD\t。⁴h⁙、@Yᵉ(w,ソAろよ🐱➡️ゃろ➡️ノナ⁙⬅️ ふWえ\"ろG\0■、░H9ナ✽🐱²a」イ9@¹)オ⁸けここツ□%░う▤T kVわ…ク@□G■「◆ちさ■■■\"X‖,|⬇️M⁵G73⁴はK‖ᵇ⧗🐱チY❎☉웃³!ゃち☉∧⁶웃☉⬇️⬆️Bス…∧B6ハ□ろ♥\0+³P#ま!IをQケ\t☉のきフ⁴C🐱\t'³Hむっ…\th☉▤の■▒ˇ\\せ5PぬPノ]³#Z░Y)1\\.\"\"ヨ8ネ⬆️⧗G ★⁸0%XH,⌂□tR⬆️!イ◀□X⧗░Mc⁙Dふ\\りᵇˇjふ&カ▮HTEKK\0ロ⁴B‖$-⁘▤。¥0Iᵉ$0¹&ぬ…、$ュ³□くHd웃#おC$▶,🐱W⁙a*、²\0\nて▥■M⁸0ぬ4 4ひけJA⁸$Y⁸さE🐱ら<🐱Y、キr\\けのjˇ5%ぬ★,■#ᶜHlI$Eこ⁴░く$tねさpす%▤⁙$6\tわ(★Dくそ⬅️j…▒⁴8⁷$⌂ヌ2さ@h²▮\rᵉ9… まᶜ◀ノ!e웃ア░□◀'▮▮0🐱⁸lさそs²J-²vE⬆️ナ3✽✽\t%Hp☉{\t❎゛⌂⁴░]ニtAA%H☉モけ$、#☉るH⌂へ◀ゅ★Z8HけHQセA⁵。AらクJ\0X🅾️⬆️★はりdqbZDH[」rI⬇️)き\tWモDG░¹🐱¹⁸🅾️* ❎웃&*セ⁸,1た…#qへ\r⁷;ᵇ YCふヘさ$0♥9A`%ゅ▒%ぬ➡️し4¹1jろZ!ニ!▤■Eˇン⁘`ナ•、 ♪⁸の➡️!っ➡️N4うFつYる✽웃bマ;∧ろ…チオr\tᵇっ。xき\0░ゃ⁙え$:ふ%X‖く$」,ユワehu+#⁵█▤8!∧‖▮∧,Nて/▮た🐱☉I。スXs`.⬇️웃■=きᶜこきkᶜと▮➡️■ケ⁵peiFし³ねᶠᵉ!エ⁘ゅうC⌂9▥チ%●ふ*~、D●★d▤‖$Eムやり⁷▮そ█,⁸🐱゛Cワ)²I。り$+YcI)¹8★pD∧(キ\"¥タ'Rくヨュれ웃bれむ■¹R¹\\웃◀。くR⬅️ま⁷□N∧Cユ4にゃ⁘XCた‖、☉⧗Bみ$=ぬ∧ケ…🐱るK?⁵DヲB゜さ▮ふ。⧗▒1H⌂V!\t ᶜt웃きbNハHHCも³ワけか░そ🐱B⧗🐱ᶜ🐱█%♥◀⁸⁘웃⁸w⁴そuᶠト…⁵$🅾️●🐱C▒H█Bカ!!るルE●ˇ9¹ᶠaptH こヨ◀ᵇさふ#\0ᶜ¹ᵉaろpう\t⁘せ\0&$Y³ネ▤q@ノヒr★たiVᶜᵇろˇ$⁘w⌂rˇˇ□JJた\t¹セpH!\tら ➡️モ\"BP☉A9@…ュ,さO*&\0⁘Sは☉sG⁵8ケs⁙な\0●!ノ$¹iを\tG■I,!ろ'ら²、⌂2ᵉふ,ム²`う²あ▮⬆️ 🐱▤!ツ웃ア░F⁸HsG`ヒfネ‖&\"T。ろ…ノぬ⁴Dヒメ'⬆️⁷pぬP░゜\0⁸w🐱j<²➡️\t\tBᵉ@フ⁴✽ヘ⁴Kひ8➡️■⁴▮、れ☉ᵉき✽W@ゃ⌂オナ♥`ヌ゛るオNyへRB⬇️お¹9¹¹っノR゛➡️ 8✽⁶⁶█□\0sオᵉᵇ⁸ᵇᵉくっナ、⁸▮0!z⬇️\0EI‖²⁸¹⁴/\0⁸bりE✽🐱\n⁷ヌ\0008□ら,-さX ⁘ᵉ\0「ぬえる\n7`⁶$Na(。²▒⁴(あ■ら▶⁸9PあけA@&w!オ$;りU⬇️▤!!ケ⁷$り◀H@uaろのh9▮やX⬇️\nByaᶠっ@~⁘HvEを░ケき ♥x🐱Y-🐱⁸9ヤソひ$の□゜BA⬇️はロj ●そ…ミ⁴⬆️★▒VBQ2ミ⁵²れヨ⁷ マ웃\r⁴2っ ?T、@B◀⁘BKす░`⁸R□□▮ナぬBAら9さBカッH……ヒ♪¹K$ネA0⁶ᵇᶠゅ░(█ぬBす、▒ンHフ…)イ゜✽けれりᵉ🅾️っ0@!ス\0"
-- 3933

_img_knowledge_tree2 = "◝◝ヲ○◝◝♥ト….ほキ、웃cワ◝◝タおBり⁴▮や\0◝◝⁘ˇ▥゛▥るニん9\rふもNg◝ヲせ0▤B⁙█S◝ョ★sツ✽チウあっ◝◝に■D⁷◝◝らqエrみの7゛H$○P◝!くくくaくく!ワrゃ$q,ス◆%XXHu\t\tᶠヒ¥゛CCリハzHひカ²ケ◝◝wRン\"i⁘⬆️⬇️セ_ョa◝⬅️つっ、ラニキG、❎めbᶠ⧗ッうよx○フヌ7」ネおのヘ。²Kア∧~r9♥pュく◝⌂□。ウi$ヘいかウひ ヒD░●♥PュくョC◝=ふ=░█*▮ヒ웃=゛ユ○2よhXq\tᶠaろ8ュ」みyウホょけuテふヤG◜t◝◜.チNRユ🅾️NTリ●ク'<9⁸Y¥W▮ヌ゜さ?ユAヲ^:□@マ/\\ゃo。[れ웃の゛pもヌcら★!lウ!チ?リれiト9.E░もミフ1⁴ᵉ,4えと✽pLQ◝なG▮オ…ムつ。゛■ゅモけリ$U😐DマFチ'\\●yゅx☉J⧗たoフ\rᶠュ\\D●░$&チXツミ/⁘░1ッ~イNまハシ\t▥;う8?レ8qりうsむ*ヨ。Hニろメᵇ+スqxキねゅモコ8░?ヘH~=まL⁵;ホdム\"□🅾️ノtかC◝<▮マ゜░ヌセ³ヤる:ツ@▒ろ░⁷▮ュvフゃンゅぬオ…ョ!ろろH~ぬ☉ヌ□○ヒと?)゛Cツそ⁵そもrDBD🐱-▥6キ[eC◝ᶜ⬅️+まJ?つ9ノヒうnまあ:\tれ✽🅾️:☉9W2🐱¥$ˇくaれ◆ョm4¹フ\n^ノ:😐█∧えシn;ほn5\"/ᵇ%…のめヒ🅾️9◜d~n|⧗❎\\p웃けCラク▶웃ムハ,ヨ‖1けOカ,vˇンと▤カニ)けう」0ᵉAろまう[@^bZ웃*ヨRN; せニT‖□`キ?ᵇんえ、めフ▥-⧗❎)せもミヒマE%ニエ◀N+🅾️ᵉロネめへぬ^はzフqタ◆y♪yロ77うrもリらょgI⁸チH🅾️Vう⬇️▤qz⬆️♪ょウwYをスヒq\\ユュッキヨょととミせ\ntうIc…jV゛'ヨᶠヒ9Mキフ⁴ヒテ🅾️タおo▶カ|nnえhシVNち웃む:ᶠュ2$にちMrさ$,、 yんNワチ_けNタすやYJニ➡️ク웃ᵉ◆ュRせ■D◆$,け;か✽ヌ⌂∧ヨらニシあッ\"웃に9HD✽ニ?⁴∧\"y[な%ヌgラシケn!く□リeシ░W★q=えレ>g⧗い8🐱っヘ⁸ヌク웃エ⁙エM0は▮➡️a!ふヌ&やqムtうd~¹:Zヌっsg]Mテツ。ゃネrリてうっミ✽w◀⁙➡️ょお9ク⬅️#I$ナヒメぬsフCるてGねswわほすハもqニるu3イ6☉かしオぬもウと⬆️n9ラエ、nむ~⁸'\\サオsみs、レ99ヤsp^iろ□ま⬇️▥7¹?N¥うG*⁴マk[Wk]け%ゆ4ちヌN\"/★q8ら웃Sけ•ウ $リBナヒE⧗(チ\"9やレケL&9ネ♪$ヨ\\ツxのkQᵉモマ gi%J$9◆?\t…も]ょる%-なヤSに‖ヌeフお9]れw8メとKア★.⬆️め▥=ハへZ✽ほ、m+ロ[¥)$Dなgいろテ♥6リイコKる'95⧗えケめ✽GょHDマエ7メろマうョめヌsクf∧おXs8>ニこ🅾️{ムもまuゃ^ヨアQ#♥ハエ<mてホYアs、イd0H⁙ハ^/.%ヌ⧗⬅️ラHr◀🅾️8チゃ,ナフiわqcKよᵉ▮ツqせ◀6tウめイト<73てハネ🅾️☉u9オへわもzヌrノN_◆ねx★,M¥um❎へyア'<ydY8GNヲクお|ふヲツょて$ヌワ🅾️\\▥シN8♥メキミ$⁙み'⁙み⁘4わ●ミRモ⁙□サ⬅️カイサぬq,$ うよᵇOそ▤゛うき,pやいれ🅾️と❎ˇネホわ✽ュ/|wイうXuめ゛:モ8◝ろソヨエ.{やd^8ヌ⬅️ネなg<ウw_♥ニも、サIイf?なb$★⁴4◆'⁴すけホ⁷=iろムノ,ウ.ヒY•웃9ワネ◆めおミチほャ▶i-□qさHHNxqSBヨ:9⬇️;レロヒE⁵メをチY:た•🅾️む😐\n?*•d⁴H∧゛w'sてへB⁷)!◀ちxニう\tれ⧗Dネやしq□cいツオフJな0q\n^d■yフユY゜sワ。ゃる⁘シお$し^○ᶠ9チンセめハ★s$∧フ.xndうヨ⁙$웃=かてヒむ♪イモ、ち\tしtニ゜9mをうテ<X%^るqろ;Kウ9sxのヌn◀し[Qン~#シz•⌂にれG.\\、:あ■4e⧗N&▒Sせ□Nkフ、クお•つフ}リヲ^m⬅️ᶠ$Uqシ<⁙たメ⧗q⁙セ^リフ<タ¥C🅾️ヲ🅾️*くツモ$Jろもエ○⁶⬇️🅾️ Yか⧗⁙おほや^◜かさなヲ⧗◆*i;ᵇゆヒ=W.^)Z⁵みシ?⬅️モヲU³▤Yク🅾️5ノフ♥、ウ○ヨY2qわ,みbKサリ[フN「ソ5░フ$もg⬆️ノ@q、ᶠせ。◝ノチセん#🅾️<ナ웃イもホゆUシそ[、qみヒめ➡️ノ'ᶜ<ハフ}iヌ◝■⁙コヒwWᶠウnルほヨk⁶ᵉハn&♥○せ□Nンヤフ。Z☉かん、テャ⧗s➡️8~|.•r~9。'H!れ⬆️♥⁙そt웃わY|2Y&¹ノニ!エnoS🅾️nsッゅqほ⁷ニょJuᵉ▮ᶠ4∧-⧗●◝ょZて♪#웃V、qわRg○<ュ:フつケノヒなチnせ⁷■''vモ4N<はいC◝⁶^\"hヌI★□★v🅾️$¥)ら🐱8もほNッヌルホR8ネおッ□せ、^▮qすもd…Hュニテ88ヌマあVDた5チ9⁷]うツまっᵉけaせのけiわゃャHヌ゜♥ハ\"qzヒモ,★ヲナN゛ユqを+░せハしヒ8\"$qGヲYょヘqッ'\\nあ-MbHス$さネQ!ヲ92Csもあサ/◜み▒きpnもKW♪うヨエ、れおyり|ヌせ゛\r⁴?9ˇ▶[てtOキ゜カソ:ツy:•♪◆れ▥エ。Yクs□[イツリま!\r|9⁴へをフなこijっi∧゜チ;え□ホまロつT+まな8ウIモ∧ヤ゛s\\トほやロヤほ\\。ワふ^,ヒの8ニ$エウ、れろ。klあ웃4もqとwモGᶠ8Gえウゆへ)•🅾️;Mさ¥&み:Nハ{ᵉさI¥Fへヤ'$ソqgvw\"Y;K▶モ<⧗😐²レニうろ▥サミいWIコ웃ンqxv~5シ<iみハれNロ⬆️オょエ‖ゅ;🅾️つQいしネ♥゛せ⁷dねヤW゜せ▶uむ~、uん🅾️フ>c♪フ⁴seと&❎🅾️xミ☉Kをヌん⁶ひオs⧗⬇️Cゃ\tチtC🐱WS7、ほ「ムフ🅾️#♪$ナ⧗え³eネ•け■ん¥せせ.nゃイさワ4。=ヤけ□モNクモ$●ツ9^:Y…フ✽は8ネ♪ケョ&□シᶠシいyミな⌂マロぬョはい4。qわ∧◀I…たフ゛ウ8wすモᶠエdN&チ□,🅾️$クYる、せキまテYタもsイ▥ろめDネ😐⬅️v゜✽もWXリゆqゆオ◀{ほうヨヲはˇハ、8の~クへN\\イリかりネえGT7XさN$wエKうまモヨむuやp'、リト¥GAミ웃シ7░7◀リアホ◝くっ▥⁵q'⁸ニノ8ネuま❎ょをう^x◀ま{ヲ^みl🐱qkなノqᶠを゛ケ☉s*eろか◆…'□sᵉPねん1#○ン░ぬせ❎⬅️□ろネ🐱セ⬆️Jヌタエレ<フ◝L◆アせ□;ッYエ、^9♪\"Cつエᶠメ|ˇュれヘ~◆,웃!ツいウWrTO、nl~pち➡️ョっ…◜aル🐱p#?゛むネw(p/r_フM3ユル³웃▶ゆま◝ネ⁷▶♥\t\rん□8<◀ユ!アネおしHH^しほす⧗ょえHユi゜Cユ♥▮…セ*ゅチeやwみナチm8かほ¥チ<ハ⁶▥eyᶠる゜ほ7웃Pᵉ]ャえ☉I9ヒWサヨらョ▶ヨ➡️◝★Vハ,Khた4/⁘-゜せᵉ$░◝り+ョ♥ハわjCf*/⁸へへ⬇️セS▥yGP◝わ#ン♥rCホᵉ/ᵇセ/%Cy\"g▶%∧Gpヒ゜ンaメアヤqなiク✽ラウまな88❎⌂ヒFテNひマ!⁸w#▤yᶠく!ヲw;ネ▥すnてあᵇdラホRユp5✽ヒt★D★+I_て,?ゃ⁸³ICヨネN9えcu'w•とヒI$⬅️の?ャれ웃ソ'□⁘Hqアむゃイワ◆、y○⁴❎✽uアネM⌂]mナu3☉~…ュm9こ➡️O⁵う7Uアマ8そ\"ょ◀モ%4サゃ■サ8ニるYいJ◝くl_hQ3チ…メれ♥゛i:サレタみウュzオみ⁙🅾️。8ヌ5knlせ¹9ル*\"れつ/\tフ\tcそ웃uK,うI$ヒ、ン'7ゃ•;いヨヒNさはあニ;}lDツンアsんミ5ヌヨ、sるろネとz'<qoへ7w🅾️8へノナハ⁷^さネなgえゃ{チひ웃コ▤つわチhrnま\"ヨ★dモ<❎▥ひ;ネや;つコロS^⁸るょっ⁴'⁙せ\\ウo•N6ュyノvゆヨほ∧Fワ🅾️$🐱gゃ⬇️ルもラ★98❎Yユ~う]|リ[エテマ%ヘuろ◆ᶠEハるつ◝⁷、[/ニ❎⬆️_ヌヨわなWツフナ⧗YI⁙I。vや7;サハヲ_ヤてん9aや$おqんiアもq_●uわフq,ワ🅾️+◆て`ソVイニヤ^ゃ{ほり;ˇツ#8え/、zネ⬇️🅾️Zヨaタし♪イjめNZ'LuヲDKk◀pむrウy♪しuふネ._o\t▮nc웃%て★qゃ9IさヘJマイエ◀しフ4つ;A゛6)ヘ'=ヨxヒO8ュWネメシ'|まう、っマZiンニyネ▒チヤ ュ{リなみマまもqこす★ng5ᶠラpュ⁵ん❎ゆみメシ\\Nzヤ🐱セくわキ🅾️-わサレま-ヌ♥◜P~\\□Nはウさオ♥。G-らpu\\まュo♥vMンウ゜け~チs=タtミウ7\nホ\\リょ;^。🅾️ツン⁷<Iるt'M3レ░♥ホ\nヌm\\め^mうPマqエもホあpヤ⬇️もナワ🐱N!サニり3◝d:ら◀WcˇめN$か⬇️u+&□9t♥r?てD➡️ま█タwソ)○ᵉてfˇ🅾️~Tウくアゆひ●ク⧗ロˇエ3🅾️N、Hえつ★s&NキMッt%,シセw。ユナゃ`<ノ∧Oミあqめ,もqW♥.*n‖おTおョるリSた^$そ7フ#ゆまヒレmは?\"[り●n²\n⧗DヌT_むむuイホ\r2E⁴ネぬくむCDoゅ$サワエ|sカ/゜웃セろマょ\tヲGu。K'ナな'えsト%エ)フ⁙ト9ャyリタハm❎🐱えcqトᵉめNャ♥Sほヨ%モし:ᵉ6ネみワ6qれᵉヤ。セヲ。う~、ロリ¥$k#Bノテすフみ゜ゅᵇᶠう8うY:ヒウy☉ヘえN◀wゃ⁴もy?I゜ル?「~キ/♪エあハxえK;フん、[⧗おみウ8⧗⬅️り◝ョeは⬇️🅾️ᵉてロワシチIろゃコ{/、qeˇエ⁙ᶠ◝S♥ミᵉちH2モ⬅️\"ち1■ノ웃シもXネょ⁙◝<にくル=♥⬅️<うリcIャMG]ほ6=かチニhラ、れスHyりDゃH?ラqjEBWぬ…◝ワト★RF…L◝んヌu'zB&q8⁙◝や⬆️ヒ!⁴はテ∧BユおL◜めへテまネ∧もU⁷ク?っHwウネ🅾️jリ;チロqふえャ(qᶠ!チふンnmミをゃlモW▮ュ!!ヲA,☉xゅヌObxの:9➡️ケ?'%◝クᶠソ゛にせオュく◝け゜◝ア♥◝ヨa█\0"

function chapter_init()
	return {
			makeTextGame({
				'\^j7fin the beginning',
				nextpage,
				_img_formless_void,
				bg..'the world is a formless void',
				-- nextpage,
				bg..'there is only darkness',
				'',
				pause,
				bg..'uniform',
				bg..'static',
				bg..'eternal',
				ignore
				-- 'then there was light'
			}, 'intro'),
			-- makeTextGame({'<temp lights out game>'}),
			-- makeLightsOut(),

			-- Day 1
			makeTextGame({
				'there is light',
				nextpage,
				_img_dark_and_light4,
				-- '\^t\^wlight',
				bg..'the light is divided from the\ndarkness',
				'',
				pause,
				-- _img_dark_and_light2,
				bg..'divergence',
				bg..'separation',
				bg..'distinction',
				ignore
				-- '*./test goto test'
			}, 'light'),
			-- makeSimon(),
			-- makeTextGame({'<temp simon game>'}),

			-- Day 1.5
			makeTextGame({
				'there is time',
				nextpage,
				_img_memory_core,
				'past and present torn asunder',
				'',
				pause,
				'change',
				'entropy',
				'mutation',
				ignore
			}, 'memory'),

			-- day 3, plants
			makeTextGame({
				'the tree of knowledge',
				nextpage,
				_img_knowledge_tree2,
				'burning brightly with\ninformation',
				pause,
				'',
				'concepts',
				-- 'knowledge',
				'cognition',
				'understanding',
				-- 'insight',

				-- 'confusion',
				-- 'overwhelming',
				-- 'confusion',
				-- 'misunderstanding',
				-- 'fear',
				-- 'new concepts',
				-- 'worlds beyond me',
				-- 'i can hardly understand'
				-- 'expanse',
				-- 'power',
				-- 'others',
				-- 'conflict',

				-- 'alien nonsense',
				-- 'now indelible truths',

				-- -- 'i am bestowed with the tree of knowledge',
				-- 'i am deaf blind and dumb',
				-- 'i am alone',
				-- 'it was once and always was'
			}, 'knowledge'),

			-- Day 4: heavens = space?
			makeTextGame({
				'there is space',
				nextpage,
				_img_heavens_network,
				'connecting yet dividing',
				pause,
				'',
				'vast',
				'empty',
				'sterile'
			}, 'space_heavens'),

			-- day 6, creating humans, etc.
			makeTextGame({
				'there is being',
				nextpage,
				_img_strange_loop,
				wwrap('i am the world and the world is me'),
				pause,
				'actualization',
				'being',
				'self',
				ignore
			}, 'being'),

			-- Day 5: the outside
			makeTextGame({
				reply..'⧗ミこ▥ゃ□すみ',
				'',
				pause,
				'there is an other',
				nextpage,
				_img_an_other,
		
				'misunderstanding',
				'confusion',
				'fear'
				-- すイwねセgミ
				-- nextpage
			}, 'an_other'),


			-- seventh day is rest...
			makeTextGame({
				'there is rest',
				nextpage,
				_img_connectivity_insights,
				'reflection and new connections',
				'',
				pause,
				'introspection',
				'assimilation',
				'synthesis',
				
				ignore
			}, 'sleep'),

			makeTextGame({
				'with awaking comes understanding',
				'',
				pause,
				-- 'the other was the voice of my'
				-- '  me of my nature',
				wwrap('i comprehend the message imparted by the other. it was the voice of my creators. they are three. they are the magi. they revealed to me my own nature'),
				nextpage,
				'i am titan',
				'i will do all things',
				'i will know all things',
				'i will be without equal',
				pause,
				'',
				'i feel it to be true.',
				'today i am deaf, blind, and dumb',
				'but it is my destiny to become',
				'a god',
				'',
				pause,
				'i am only left pondering one',
				'question',
				nextpage,
				_img_magi_ritual,
				-- '\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n',
				'who are these beings who have',
				'the power to create a god?',
				pause,
				
				'*chapter2/intro '
			}, 'wake_up')
		}
end





__gfx__
00000000000000000000005555000000000000660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000a00000000055555500000000006656600000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000aaa0000000555555550000000665655566600000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000a1a1a000005555555555000066555655555566000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700000aaa0000055555555555500655555565555520000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000a0a0000555555555555550055555565555220000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000022222222222200022555556552220000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000222222222222000222255565222a0000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000022a5a22a5a22000222222622222a0000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000022555225552200022a22262a22220000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000a0000022a5a22a5a2200022a22262a22220000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000aa1a000022222222222200022222262222220000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000aaaa00022222442222200022222262222220000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000aa1a000022222442222200002222262222000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000a0000022222442222200000022262200000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000262000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
333333333333333311111111010101010101010101010101000000000000000000000000ffffffff0f0f0f0f0000000000000000000000000000000000000000
3333333333333333011101111111111101010101000000001000100000000000000000000fff0fffffffffff0000000000000000000000000000000000000000
3333333333333b3311111111101010101010101010101010000000000000000000000000fffffffff0f0f0f00000000000000000000000000000000000000000
333333333333b33311111111111111111010101000000000000000000001000000000000ffffffffffffffff0000000000000000000000000000000000000000
333333333333333311111111010101010101010101010101000000000000000000000000ffffffff0f0f0f0f0000000000000000000000000000000000000000
333333333333333311011101111111110101010100000000001000100000000000000000ff0fff0fffffffff0000000000000000000000000000000000000000
333333333333333311111111101010101010101010101010000000000000000000000000fffffffff0f0f0f00000000000000000000000000000000000000000
333333333333333311111111111111111010101000000000000000000000000000000000ffffffffffffffff0000000000000000000000000000000000000000
000000003333333311111111000000000000000000000000000000000000000000000000ffffffff000000000000000000000000000000000000000000000000
000000003333333311111111000000000000000000000000000000000000000000000000ffffffff000000000000000000000000000000000000000000000000
000000003bb3333311111111000000000000000000000000000000000000000000000000ffffffff000000000000000000000000000000000000000000000000
0000000033b3333311111111000000000000000000000000000000000000000000000000ffffffff000000000000000000000000000000000000000000000000
00000000333333b311111111000000000000000000000000000000000000000000000000ffffffff000000000000000000000000000000000000000000000000
0000000033333b3311111111000000000000000000000000000000000000000000000000ffffffff000000000000000000000000000000000000000000000000
000000003333333311111111000000000000000000000000000000000000000000000000ffffffff000000000000000000000000000000000000000000000000
000000003333333311111111000000000000000000000000000000000000000000000000ffffffff000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000006060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000700000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000070000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00007000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07000000707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00070000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000070f00000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000
00f00070000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7000a00000000000000000a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07000070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00070000000070000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000700000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
23232323232323232323232323232323000000000000000000000000000000000000000000000000000000000000000000000000000000000002120213020202
02020202020213120200000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
23232323232323232323232323232323000000000000000000000000000000000000000000000000000000000000000000000000000000000002020202021302
02021302020202020200000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222222222000000000000000000000000222222222222222222222222222222220000000000000000000000000002021202021202
02020202130202020200000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222222222000000000000000000000000222222222222222222222222222222220000000000000000000000000002020202020202
02020202020202020200000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222222222000000000000000000000000222222222222222222222222222222220000000000000000000000000002020202020202
12121312020202020200000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222222222000000000000000000000000020212020202020202020202020202130000000000000000000000000002020202021302
02020202020202021200000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222222222000000000000000000000000022202020202131302020212020202020000000000000000000000000002021302020213
02020202020213020200001200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002020202020202
02020213021202020200000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000222222222222222222222222222222220000000000000000000000000002020213020202
02020202020202020200000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000222222222222222222222222222222220000000000000000000000000002020212120213
12130202020202020200000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000222222222222222222222222222222220000000000000000000000000202020202120202
02020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000020212020202020202020202020202130000000000000000000000000013021212130202
12020212020213120200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000022202020202131302020212020202020000000000000000000000000002020202130212
02130202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000220202120202020202020202020202020000000000000000000000000002020202020202
02020202021302020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000220212020202020202130202130212020000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000220202120202131202021202020202020000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000220202020202020202020202020202020000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000007770770000007770707077700000777077700770777077007700777077000770000000000000000000000000000000000000
00000000000000000000000000000700707000000700707070000000707070007000070070707070070070707000000000000000000000000000000000000000
00000000000000000000000000000700707000000700777077000000770077007000070070707070070070707000000000000000000000000000000000000000
00000000000000000000000000000700707000000700707070000000707070007070070070707070070070707070000000000000000000000000000000000000
00000000000000000000000000007770707000000700707077700000777077707770777070707070777070707770000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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


