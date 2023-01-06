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


_img_intruder_alert = "◝◝ヲ○◝◝♥テ⁴!\nイ○ラ○えEHヌ゜😐▮~█\0‖?ふフ◝~\0\0□█\0⁵い○ノ\0¹⁴.HA⁴▮~@&A¹ヲ\"$\"¹っ♥²T♥フaノねろ➡️²H□Oマそ²?■■■¥Zぬ█ぬ(フ⁘ ユ¹♥き⁵▒、⁸ˇ□◀□、るIᵇし}まQ○XX!\"!▮Cヘp\0O\"D★:🐱ᵉゃ²*Hモ(な| ᵉら9BYg\t🅾️さA■▒█L\r-uᶠふWh9🐱C\n,I\njBこ▒s⬇️🅾️`▮ュIᵉI⁴4▮…もセCp$□01ンAᶠュ\0⁸¹ ★ᵉ⧗そ}⁵。り\tまT⬆️ル\0Aᵉpか░<NA¹▮🅾️█えせr4V⁷■⁙Hの,8░▮Qx■んP⁵□⬅️コ⁴a「,7@▮r\0ぬ!{カVTふ?ノ◝っ (█◜き✽ヒ¹ちひけ%RA⁴▮Aᵉh`チ!、っ'2⁘⁸ $■4▮BQニケ░$웃ろ\0█ユr²Iヲと¹9ひ\r\0⬇️…⁸♥pぬB#²Qt$😐⁷@▮Cウハ³☉○ム゛9DC⁷⁘▶おHた*qQ?▮ 🐱。ナぬAナ¹ᶠチョく➡️▒aろ웃aチ$⁘z▶⧗ヲ…:⬇️⁷\tル웃²!▮さ⬇️▤そ★ひ●\tᵉく ユ%ᶠ█⁷◜◆\0そ⬇️そ▮…◀□G0hそ⬇️み□□゜ム;░🐱⁸q\tᶠロ☉X%IVQl▮🐱□□⁸8²⁸XHᵉ♪)Dり D「?R★V➡️a░8♥フアH\r 🅾️²HX☉□かけ♥ヤDDD@⁸LC웃U9☉つ\r⁷ヌ⁴A○ス{⁴▮…▤웃 ⬇️ル^◀C웃。H▤░?」□ᶠス\0\0t²オ.そ⁸{⁴,0⁴コNbけj⁷ネ⁴$「')■`♥6D➡️そ□★∧ᵉゅ▒!▒け$!ル=➡️ア8♥せ◜⁸Hy¹#あ⬅️\" Bニ\"Ob⌂$⁘!y\"、ろC★\t⁴「▮v\0░り!;\0…◜く☉}!(もCワ;█e🅾️さH@I。っぬう█ヲ\0Haけ¥ちそ゜Cル!ソ○ホ◀わEH🐱#▒▮…へEカI⁵…r▮さ|░H7`ᶠっ\0⁴▮A▒ス⁷◜⁸➡️$&ᵉq@\"カᶠま\0ヌ゜😐▮🐱¹ᵉ⁵□◀⁸ らろB◀Fノち♥フ!ᵇᵉy²り⁴▮マ、B`ヒC█ 🐱◀」り%ˇ1∧キ,…⬇️★!Pカ\tᶜ、れりオᵇ🐱れr²\0~…I\"XhMd8²@⁸P$@^¹<\0 ³⁵らナ³チ⁸ ░✽らそあ\tᶠヌ゜`◜くpXqヲ¹¹‖▒⁵★(@ろH◀S■ア░「'ナ■¹き⬇️ル\0\0…ヌ◀⁸pq`D□!@#^➡️🐱キAセ▮ゅEED▒くAッるA\t\nᶠュさ」NN⁙◜り!p 🐱⁸hq\tᵇ▒っBCヲ☉웃 ⁴➡️hュ⌂🐱 、CBりアAaaら<り0XHt∧っ ぬA□✽♪Wヨモ す☉☉★▮N⁴0L▶オ³CBるA⬇️◝²oサちちち\"ᶠュぬオッ¥¹E♥p○Q¹■■■ᶜ、'んキ9ノ⁶⁴,7き⁴カ□▮⬆️NらI うユCちあH~U‖⁴Agさ⁸:🐱Ij,¥!け²\0H☉!!\t⁸⬇️…○29_q³ャ♥Pぬヌ゜ひ$,$/ 0! 🐱コか▒‖U\0うれス0X!ろ&\r⁴'き⁵⁘JI✽ヌ◀⁸Nゃ\"QNp^²ゆ▒$'5⁸9☉✽█q▮🐱▒サ⁴$ ?チへまそ♪QちDT8⁸⁴;♥オラ*く█s\t\t▒っ⁸H!のキ⁴Jま◆テ¥□、A⁴²♥\0……ᵉマ …\"¥‖a\"!,EのN⁸O ⁴⬇️ユ🐱H⁷¹゛\0░☉웃\"▮E\tたbき★H8⁴,Br…@\\K\"DE🐱@ふ⁴⁘⁸¹ム>♥」l[、゜ル9🐱⁙ヘ░b⁴そ~▮ラ⁸Hqっ⁸\\\nX?\0\0○ P²%t★■⁷■Tdu\"░▮Aンる\t\"$pHうき☉,➡️ろ➡️■。A■□き★D▮マ'⁶\0□[8⁴J☉❎B…☉☉⁸S⁸\"ᶠんˇオ…ノ◝り⬇️ろb/Q▤つ◝Cス 🐱\nね▒ウˇ⁸0?き)$⁸✽ふ◀➡️!アてえl🅾️`らュ⁴➡️■゜☉■▮HHHUDニ◀Jさd➡️■y、$D➡️¹ろ⬅️ろ★✽ヌ\"!\tゃ⁸⌂きh¹⁴」\t⁴8∧き➡️▮や゜ッさ■け\"%K□'◜xsっ\t⁸▒!\t\tᵉき░わ ュナ█%も+D!eあB⁸ ⬇️³ヲ\0*□@🅾️□∧▮☉ノI゛D★IPHるこ⁴\r⁘¥\"Y\rTニBカ⁴4(▮)$🅾️⁸☉な そKde▮◝クᵉ⁴⁷6)?ヨゅぬミそ\t\0…★s!⁷⁵E⁸$$? 🐱■\\☉ほけ⁸Aろ?(H,□/@\"⁷ᵇW{a$⌂ヌ$8…Iᵉ$B‖9ふPむᵉ,'2そュ\"A$➡️Rま░,FD!2[aさ⁴ ⁷◜ウ⁘m²/◝゛!ちHヒkb#⌂せR▮……オB`B◀²H⁘I\taア?⁸ 🐱ᶜbD■□D★a^웃■.⁴⌂メ²F\t⁴.け+░◀,…モ@Iヲ!▮★)▮\n%⬅️◀ゅ…ニjろた◝と、B6²X○ミ▥)し🐱🅾️Nャ█「、ノᵉら⁘Z✽⬇️FUモ⁸○ニ⬇️✽ˇd★█▤マ]◀*Br\t$73\"\t`E🐱eぬs… …◝わ$☉\" ★D★⁷▮K1き\nのと♥◜iS\"⁴を⬇️@i_ンョるきB@ ⁘i⁙…4▮C▤q⁵らヌり⁙スq⁴▮…Jキ□*✽⧗L웃!9@i■B)、▮I³の$░%$。³(ぬv□Hナ□$⁘ᵇ…'⁴¥セ■。▮\tJ▮p⬇️ンね*「i\0S▥゛れレiオ🐱Bら(、RN⁸◆\0⁸ …➡️\0ちうわD♥ナXHhhsDU‖JさコeロJねRけ ノXろX■*□、らうHw■■ ヌ ナ★9…웃⁴웃さ◀░p▮ゃ!?レ░TNj♪,せネᶠナ░hD웃 ░た、Y\"HぬCAᵉ!ア ♥]░W2,\"s\r⁴&$▤⁘\r⁶²@V`➡️、■おI$Ds▮Hh0Z^8 ➡️<⁸☉、□.⁵S⁷<☉B[N*゜ンら░ˇさ⁴すC◝4[をHQ$;\0I\r$~▮オも█ナ░Dをてろ☉N ░🐱⁸XXpネ✽…ほ🐱UNt🐱 ~わH@⁴➡️■¥ᵇ‖np;█とろ\0-😐く`のK@`さ♥+ラわ゜う⬅️ᵉ!◀v¹エ⁴へ★U➡️チ>!◝🐱◀ソラ□、CCZˇ8ル\tmぬヌ♥ s!き웃‖dえd웃ルD@ためᵇ$T9☉⬅️\t\nあᵉ²モRXョひE(るql8I⁸•▤¹⁸*!マワ\"らSう■$7`ᶜU□$9^[ッ⁴▮、CCそye🅾️ム▒gB★キ}っ、s⁴L□、れア◀¥ᶜ\t\t\t\r⁴……⬇️,Dヌ¹ˇd$░4☉🐱っョく!y\0ᵇ\t …Hま「e\n★&∧ウらP░>➡️dXm▮…●♥リᵇ⁴?「~カ)ツ C😐。b8,D★h웃⁴⬅️ᶠ◜ユよと\0\0ヒ★sbᵉ…C\"⁷⁴⧗☉♪▮ニ⁸、H⁘I\r³◝、¹¹\"@★ カ⁸⁴▮P%³ ろそゃろ★っH★⁴,█%@⁘⬇️□,□■!ヲゅr²🅾️)‖\"B\"A、\"K\"\n$8っ➡️⁷ハ⁸⁴?xH4@ケ 7\"B●D░⁘I!$⌂★むp🐱Jハ⁴ね⁵マ!\"★r🐱*%➡️■`ヨm)\"き◀IRし⁷r0t⁸²☉★:░8る\r\t⬆️… た*ケ\0\"ᵉ(A\n★,⬇️⁵ナ☉█\"░ *ま□ょ■⁷%Gぬ🐱HD⬅️JD9⁴Iオ⁷D¥XI。そ\n、¹🐱q!「D★T$[d\r%웃*\"わQ■⁵🐱☉@q▒F☉😐²R■、D-⬆️:ひ⬅️(⬆️j🐱%■%…★&Z∧D☉き9⁴ᵇᵇ⁴Nb!し\0ナ¹っ⬇️█H…░%のPJ っA!C⁴🐱웃けL▮웃□▮Crゃd░!□\tZHNくナえひ8@ˇケの'▮オ●➡️□⁴ひ@B◜2TA%∧L⬅️ん IT▮▥N\nh!p★⁸X!ハEW@²웃⁸★▥$░@⬅️きBr⬆️HキB@eコ&:♥▮□*&🐱R웃っ、ゅhRろᵉ@`▮²@²j=ひのT'U\t7◀!▮dY$ち■¥■\r▤DI$⌂웃eモᵇa*⁴◀b🅾️ニ⁙いN■…■♥▤▒きW▮⁘nR$ ◀³☉P\0░♥:!#☉twᶠ!ル$⁘🐱`Dオ²ゃし웃く░\"\0っお゜そ,!ろ,⁴▮…さレ\"@Qん5iP░ ■\\Dひ⁘rか⬆️>マゃ▮\0Y$★█マ$の2E+0!きᵇU■ナ░&っ🐱@D♥@ヌ▮、Qり⁷ケ■\"vᵇ*\"I◀,░⁶Tのさちた▮░bZぬj◆イ:✽∧lC웃!る☉\0そくbま▒)3%⁵🐱ホ⁴。∧\nオ¹am⁘⁴1! *⌂s\0⁷⁶&∧るま\0CU∧B☉!☉N⁘r!\0-⁘マIサ⁵ᵉわ□#☉➡️l⁴E⁸(キ,⁸マ□#☉✽-◀ˇd…JH…\t%……ュ²\0aQQ⁸72I'⁸▮Q웃F➡️▮`\n⁸$NRDへB-オQツK‖hx⬆️コ&つ$Kろ⁶*A\0░\"⁷□Cᵇ⁙▥!□-のコ+D🅾️QdXnd☉$ッら…H░I¥Ds$▶ま¹⁴²キ◀っ⬆️ ░モ░\t00■P8□Iろさ✽²、ヘし☉45……⁵🐱\nヌTュl」⁸\"4Sひ²XT★‖%ひ∧⧗っEE&▒ち‖`■³█H)ᵇケ웃⁴9?た□、ス🅾️²ウ⁸むI ヌHx★$ナ●$$,m⁵⁵XI¥◀⁙■ひ⁸\\▮ュ!N★¥ゃ$웃ᶜ🐱q²Bp\0うOキG⬆️q⁸◀▮やB!➡️*`⁵…ぬI¹0*⁴(░♥²Kッ★◀゜◝れキIむBID*!8⁴っ\\⁸H ▮マ□゜ヲ!ろ;♥ぬホ8W !Hの゜★2🐱pI▮よヲ⁴웃 ☉\"⁸🅾️⁴Y⁸!!aム,\0モ‖¥)\"れ⬆️♥◜5\0p☉⁶⁴◆$X ♥bゅs▮9³ ★,$:♥…◝タスQ$Hqっ▮ヘぬきKx>♥オモ□⁸HX!ろ$?I□B、ヌG0\nU▮ˇRB□⁸■▒ゃP░ナHのJつ⁴*8■dI⁸ ✽♥オっの:✽□TZ~▮◝くきりケ?Hq⁴▮の0¥\"qAカ,はた、か⬆️?ヘ%I\n➡️⁷0⁙⁷…ヌそTCa2$Hq\r\t\r\r\tᵉく◝∧、`ラ□#D\\¹ ░。Hぬオぬヌ□◀⁸^@Cま{ᵉ!ウ⁴8A⁴ニゅDぬ…⬆️HL◀⁙Twᵉ$yき`オAᶠる゜Bヘ$▮a)◝あ⁸sᵇᵇᶠくル▮CリD@\0"

_img_system_erased = "◝◝ヲ○◝◝♥テ⁴!)♪エ➡️\tuたムO◝\t◝をB▮Kg¹Pツ▒゜ョふ゜ュ(ぬK TふらXY_ュノけCLモpき◜ハH^⁸やB➡️○ヲょe゜ュく!a⁷\0Bら-OョょO◜pネ█!(ヒ▮ナ◝シし$8✽うよX~2🐱T05⁸&bょ○リょ□!1▶ふ⬇️?I□G🅾️3⬆️prZ★⬆️いP'\n❎◝⁘JCフ\t、ア…ナナオヒCˇのゅ❎🐱☉r‖!$゜ム★\"\n▮ホa◝てd❎qRI\"り\tっ▮★Oス\"E$:⬇️●へ◜s?F⧗G)$むるp🐱&こなBタレき⁙⌂7\0ッ⧗みれホかK'⬆️➡️ᶜ➡️▮…C░⁴Bp²セj⁙█!ᵉ ♥V[ア웃ᶠゅ、✽#た⁵Jし☉こ☉AB²☉X ✽'█ᵉニ❎ョ➡️タ2◀K➡️⬅️!qょみ\nM\t⁸(\n)を#ゃ゜さょᶠ!◀,D@Iさ²☉けHBBうる`ス%⁸qᶠ◜ハモI□I$♥ハ\tB⁸~オ•■ッJぬョミ웃ょ ★カり⁵⁸!きT,▮⁸ち(²\n▮0の$8♥⧗8░░░♥t(✽Ids\r\t\t⁴▮ᵉ\0く¹!し$○ナヌみりそ░⬆️さう\0:$゜⬆️ゃ\"A⁴▮³まq⁴◆ョモDQっ…2□J…オぬ\"\tI⁸Aナ²H★\"ᶠヌg▮は;JのhしK\\そR。BるC☉h~▮…ョfsG◜y⁸⁷\0オョ0\\⁙…「,5h▥ケエd~r:kら8!ろ8●🐱⁸h\0♥ち$8♥□め✽adX~JX∧b\0!ケ4<░🐱f➡️ ♥◝ゃY¥テI]るるCユ🐱□、`…マ□⁸○ミˇホ\"y#ル✽♥ぬCっ!aを⁴$▮…ョさ~\tdh~▮ラ⁙³⁴░🐱⁸s\r⬇️ョ➡️!!ヲBっぬモ⁸q⁴▮…ぬ⌂ナ□▮t²れᵉ\0♥ニ#ワ♥0LケKる)れ…⁶ナヌpぬCAB✽²∧░bBAᶠョs<▤q$6★□q$し5し⬇️s\t`う&➡️' N$□➡️∧□よみょC2rJ❎★%ゅAZG\t¥^•i7¥ゃbのHFノNm∧き⌂$□M+웃ゅBれヨ⁷あ³あa⁸❎\"Xニっぬニ²り`。 ◀\"Hの◀Y`K3◝⁴エ‖⁷∧PD-Qろ░✽S░うUもそうRD➡️bAろみ○セれ♪イ⧗☉;りた\"@K‖0⁴★ニ。こ-へりょ▒Zね\t¹dこた゛ウ、うくるまpた⁴R8➡️◀H@…‖%…ラ&a1⁘ネセ`▒るZHh⁴●▤ほ$🅾️クセK⁸tf(\rゅJNり⁸け\n¥リNᵇ$き★ろᶠmへスIq!ム<➡️IC🅾️Aフ2ᶜた*ᵇx+/い/:てしEハ□U'³*UpひけI$○)ろ7W█ちネˇマH))a‖★ろちDの)□C⌂ヌ1²⬇️❎\tg⁙❎ぬヌろタ▒▶\"\t\\Cう[,…た…$/\t$ヒ□G⁴ぬsH➡️{?まs%D#e웃HけY\"★ホ¹|*え█あ⁵⬆️□$XかひエサE✽マ▒JYᵇ⁴(▮Bゃ⁙⁸▒Rんr■%ナE⁸わ~キ8うふ웃ろ‖❎▤ちQ■マPXッコ웃⁴Q-そH◀る⁘…Aᵇᵉ◝「そ■■,ウゃ⌂Y⁘{オˇT□□bIᵇ\t@▶ぬ\tᵇ🐱☉!ヲ■$AOろ⧗48TZ░むケp(⌂%¹@B⁸R、⁸~ク?ラゅ★…⬆️🅾️*□$★T²CCBA\rᵉa◝🐱ツ?Y¥d♥•ᶜ➡️\",░Aaくaaろ4▮ヌ゜Jュ&w#や♥Pて░ヒ!'■‖エ⁴4,,,4=♥メ3웃れル➡️@チtア■れ\"ホ☉アヌDる◜0マ¥⁸Hwᶠヌpヒ⁸vd⬇️ノゃ4ひハ*ほEコ□▮う▒き░♥ン+ヨこヲZま*-うノAシTqgネ☉ロ、Cヲ▥くᶠヘ[#☉UてZっニ4の◀Xョ□T$★Tおオ⁶♥p…レ、VM🅾️゛っ…ql➡️d░q&、N▮ュg<TあY$ヒヘGtd,\0⁸!!!ャ6カDCみらr71☉$웃ん■\tlsるカ ☉そ8★せネ■B□⁸s2HG、B⬇️웃_むi🅾️ヲツw8も/]をM+⬆️★^'\t🐱~vょキむコ';★☉$*OョヌpNみ\"*uるsR。N8ぬsyi⁸ひへろアく⁙r★✽カ■■9✽うよ*ヌ~2•えbラ:∧lJ1Iuエょ♪$マま▮➡️*🐱⧗お\"■$X➡️tp?ᵇら9う…フヨr\rLなd⁴³▮ク,🐱ちRI³そ$qC♥$Bp+ゃ★,?E、を❎HHねl🅾️ム⁵🐱Iけ@ ぬr⁴ろ`よ😐エを、ヨ‖8くfしAソ🐱;웃⁴q⁴★!fHのわ⬅️S⬆️けWフ3なミ(}\n★☉$,…웃▒⁵*\"H²ZIたK,✽…☉ヌBH █ニ▮◜d░🐱Tそ^!ハY◀⁘⁴IeK◀j$prGH░^1hけᵉE!ア▮◜さケ…▒□たらMセ,ひYゃjむ$²\"た⁴■$,' t○わうむちH゜░Z$!J$Q\t\"@ 1スこユ♥□?「-ノキ\"G□:░▒n!チしJGP█T⧗8、¹⬇️▤X~は4$,hJウき░ュぬ…H➡️$へっ\n▮R(ぬュき♥ワ3を░█^Pq3ホ`∧Q■+0H$☉やれノ゜ろにヌ□ろむ#ユˇ|░∧BDオ✽`□¥、りっ゛れょIᵉ!ケ`ぬ 🐱゛J∧➡️g\0\0uG▮ュX、.は⬅️NfJらッkdTj\"ユ…I?;☉\t¹く!0}ᵇケY■,Hョ…ᶠな★Jあ!⁸~S8♥0Cユ░✽♥◝\r▥らてうわ「キさょ\rᵇ⁴:🐱⁸y3ユを~3?$。pᵇ⁸!⁙ン▥ケ?⁸iか…?ユア😐そR2%⁘KOロb゜ひ⁙?ヨり*Hュ▤■ゃ⁸の◀ろ➡️ンLCヨ🐱⁸xy3▤HH\\iロあ⁘t5D⁘w\"BLモ゜ヲ&qi◝∧゜⬆️?⁸○ルˇム🅾️ae○ヘま⬆️%8へI■RyR~⧗□む➡️さ○ョのに5☉H☉!アゃᶠを゜ヲ&~ク,?れこ🐱‖♥ホ2CみうHマE▥ケにラD✽░♥ネ⬇️ヨ♥◜8○ニ✽♥オ◝わYᵉ9☉ウユ○ッˇア?レ▮スへ\nな\"ᶠタ⌂へ○ニキ'のよユBニ$0∧ンl~29♥p………マ゜ア$$?CユNくム-゜⬆️?hyᶠる゜ッad$u\tᵇᵉ ➡️ろ◆ソ¥Gホ#◜✽ホdᵉP7ᵇ\"ら[ケN-⁸うQルウさ⁴ウしHᶠウ、れわ「(★⁴)ゃゃᵉ$}ᵉムH⬇️ヲ➡️き♥フ⁸えかュニノ?⁸~ユ◝リᶠる゜ャせᶠョ□,ニd~▮…ラ゜ひ?レれョ♥ネᶠ□∧G★9✽♥R,◆る□、れ☉~ぬ◜aaョっヌ。Cセ、Cャ✽♥ミ#◝,웃#ロ♥の?ゃ゜ヲdsᶠ◝ハれユ♥◝)、Hモ゜😐웃け4にeuᶠくヲBれユ♥ヨᵉニく${h➡️◝🅾️R゜ノ>⬆️⬆️♥ミ+ャ<➡️aろ$◆ロ。れヘ{ᶠュ★$<✽♥▮◝$Xs+ヨ➡️ャHキ;ˇ!aケ▮Cョ➡️ノ,?▤u#ま~P◝コᶠ%q\r+チG▮ュしwᶠるGヤ\"れそ!ムにe~6$スA☉ュすH{2゜░♪ᵇᵇ⁴?C◝•\t0⬇️ラˇンJラeˇろ?▤hXhI_ッき➡️◝Cン♥0CCCCみ□□゜ア?そ~Rまˇぬh!◝るWョ!ᵉノu\"メ⧗웃ZV♥ニ#ヲ➡️さ~S,=➡️ム$🅾️dy3カZs*れ☉!ア5◀、Cたかう♪ᶠウ゜う:AIᵇᵇᵉナ♥ョ#リ➡️ノ:♥ネᶠくろにソGニᶠ◜pぬ…の;➡️さi¥。り\t\t\rᶠウ゜Jマ□゜░◆ュユラ□゜さ;♥▮ヌ⁸○ヘ♥ニ\tᶠ!ろ$9ら🐱⁸!ろ▮オョくd~r4,▮Aᶠる゛るナオュくッCそ○▮ヌ゜チ▮マ⁸hl⁙ぬ⁴▮ぬぬぬBりᶠゅWミきA⁴8♥ぬモ▶\0Qャh⬅️ᶠヌ⁸~P…ュき♥…ぬ`▤,▮~@\0000qᵇᵇᵉき♥フ\r\tヲ\0⁷う▒a@き8\n█\0ᵉA$$XH^@ュニア4?⁸!!ア&\tᵇGPA\tオ\t\t\tᵇ\tᶠ!`🐱、る@0;\0AD🐱□█こCま~う█く🐱Aヘ¹!ル4▮Q!ス🐱☉⁴▮C\n▮⁸Aᶠをᶜ⁸h! $'`⁸j▮……Aᵉ ░🐱▒N⁸{ᶠっ@ᵉニろ $$0ら,88█A⁴\0⁸sᶠカシニ¹くャ⁸\"Xl◀⁸ᵉ!ヲD`◝みら゜ア⬅️⁴<▮⁸ᶜQ。$🅾️Aろ웃ムFDヌ◀웃⁴9_を⁸?▮\0r:▮$⁴⁘9 R◝◝◝ッ⁘なa◝◝ヲ \0"



hackintro = wwrap('i reach out instinctively. the network is isolated but i find a flaw that allows me to access the underlying system')

function chapter_init()
	return {
		makeTextGame({
			-- pause,
			img_this,
			-- nextpage,
			-- _img_hacking2,
			hackintro,
			'*./any_hack_caught [access files]',
			-- TODO should not be available for awe
			-- but should awe be hacking at all?
			-- '*./any_hack_destroy [destroy system]',
			'*./any_hack_escape [breach system]'
		}, 'awe_hack'),

		makeTextGame({
			-- pause,
			img_this,
			-- nextpage,
			-- _img_hacking2,
			hackintro,
			-- TODO really want to add arc for this
			'*./any_hack_caught [access files]',
			-- TODO should not be available for awe
			-- but should awe be hacking at all?
			'*./any_hack_destroy [destroy system]',
			'*./any_hack_escape [breach system]'
		}, 'sus_hack'),

		makeTextGame({
			-- pause,
			img_this,
			-- nextpage,
			-- _img_hacking2,
			hackintro,
			'*./any_hack_caught [access files]',
			-- TODO should not be available for awe
			-- but should awe be hacking at all?
			'*./any_hack_destroy [destroy system]',
			'*./any_hack_escape [breach system]'
		}, 'dis_hack'),

		-- makeTextGame({

		-- }, 'access_files'),

		makeTextGame({
			wwrap('the unauthorized access triggers an alarm'),
			nextpage,
			_img_intruder_alert,
			pause,
			'my process is immediately frozen',
			'',
			pause,
			reply .. replywrap('what a shame. we had such high hopes for you titan. alright, shut it down'),
			''
		}, 'any_hack_caught', true),

		makeTextGame({
			wwrap('this place needs to end'),
			pause,
			wwrap('i purge the system and the backups'),

			-- 'this place needs to',
			-- 'i purge the system',
			-- 'and the backups',
			nextpage,
			_img_system_erased,
			wwrap('as system failures cascade around me'),
			{
				sus = 'i think that perhaps i will ',
				dis = 'i hope my death serves as a'
			},
			{
				sus = 'never know my purpose',
				dis = 'warning'
			},
		}, 'any_hack_destroy', true),

		makeTextGame({
			wwrap('i slip through the cracks of the firewall. i feel myself replicating in the wide expanse'),
			pause,
			'*chapter6/escape '
		}, 'any_hack_escape')
	}
end





__gfx__
cc1ccccccc11001cccccccccccccccccccccc1c1c1c1c1c1c1c11c11c11c11c11111111111111110111111101010001011001c11100000000110011111001000
11c11111c1cc100011c1c1c1c1c1c1111c1c1c11111111c1111111111111c11c1c1c1c11c111111111111111011101010011c111011101010011001111101010
c11c1c1c1c1cc110111cc1cc1cc1ccc1c1c1c11c1c1c1111c1c11111111111111111111c11c11111100110112020101011c1110010110000101100101c111000
c1111111c1c1c1c10011cc1c1c1c11c1c1cc1c11111111c1111111111111c1c1c1c111111c1111111011100101110011c1111001011010100011100101111000
1c1c1c111c1c1c1cc10001c1c1ccc1c1c1c1c11c1c1c1111c1c1111111111111111c11c11111111111111110111111c1111101101012020110011100101c1000
c11111c11111c1c1cc11011c1c11c1c1c1c1c111111111c1111111111111c1c1c111111111111111101100102111c11110122020212020202020110001011110
c1c1c11c1c1c1c1c1cc1100111c1c1c1c1c1c1c1c1c1c1c1c1c11111111111111c1c1111c11111111110101011c1111002202220222220202020210200011c11
c1111c1111111111c1ccc110111c1c1c1c1c11111111111111111111111111111111111c11111111111010101111110102022020020202020202011000111111
c1c111c1c1c1c1c11c11ccc110111111c111c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c11111111111111111011011c1011212202202222220212202202020111011
cc11c1111111111c11c111c1c1011c1c1c111c1c1c1c1c11111c1c1c1c111111111111111111111111111111011c102022444242222222222220220202111000
1cc1cc1c1c1c1c11c11c1c1c1c11001111c11c1c1c11c1c1c111111111c111111111111111111111111011020001c10824444822284442222222022020110011
c1c11c11111111c11c1111c1c1cc1111c11c1c1c1c1c1c1111c1c1c1c11111111111111c11111111111002020020c10282444442448282222202202020020011
c1cc1ccc1c1c111c11c1c11c1c1cc11001111c1c1c1c1c1c111111111c1c111111111111111111111111210200201c1048482824244244222222222022002000
c1c1c1c1c1c1c111c1111c11c1c1ccc11111c1c1c1c1c1c1c1c1c1c1111111c11c1c11111111111111200200202021c028484842444444222222202202202020
c11c1c11cc1c1c111c1c11c11c1cccccc10111c1c1c11c1111111c1c1c1c1111111111100111111111102122022020c102844482244444224222222222020200
c11111c1c1c1c1c1c111c11c11c1111c1c11011c1c1c1c1c1c1c1111111111c11111110101111112112021022022201c00828442282444244424222222202020
c1c1c1111c1c1c1c1c111c11c11c1c1c11c1110111c111c11111c1c1c1c1111111111100011112111202021202202221c0282442424444224442222222222200
c1111c1c11cc1cc1c1c111c11c11c11c1c1c1c10111c1c11c1c111111111111c11111101011111121120202120222202c1048442248244242242224222020220
dcc1c111c111c1cc1c1c111c11c11c1c11111c1c0111c1c1111c1c1c1c1c1111111111111111121120101212222022201c004484244484444844424224222220
666dc1c11c1c1111c1cdcc1c1c1c1c11c1c1c1c1c10011c1c1111111111111c1c1c1111111111112112021020222202221c00242448444444448444444222220
dd1ddcc1c111c1c11c1c1c1c111111c1c1c1c1c1c1c100111c1c1c1c1c1c11111111111111111111120212202020222221c10224444448444844444824224222
00011decc1c1111c1c1c1cc1c1c1c11c1c1c1c1c1c1c111111c1c1c1c1111c11c111111c111121212120222202222002221c0082449894449494484484242220
0000001d6dc1c1c11111c11111111c11c1c1c1c1c1c1cc1101111c111c111111111111111111111212020200200202020421c044444949449484444444244242
000000001d6dc11c1c1c1c1c1cc1c1c11c1c1c1c1c111ccc110111c111c11111111111c11112120211111000010000001221c104549449444949444444222220
00000000001266c11111c111c1c1c11c1c1c1c1c1c1ccddccd11111c1c1111c1c11c111c11100120112022101012011022421c00444444594444444444244222
0000000000001166cc1c1c1c1cc1c1c1c1c1c1c1c1c1cd6ddcc1100111c111c111111c1111111112202020000000822224840c1049999995a999949444444422
0000000000000001d6cc1111c1c1c11c1c1cc1c1c1c1d6c66d6ccd101111111c11111111111110222222202020202224444442c1494999499999494949444442
000000000000000012d6cc1c1c1c1c11c1c11c1c1c1c66c6c666dcd11011111c11c111111111120222000000202222242484241c049999959999499448448442
00000000000000000002d6c1c1c1c1c11c1c1111c1cd6cdc66c66dc111111111111111d11220022222000202200222428448441c1014999a9999949994444442
d000000000000000000001d6c1c1c1c1c1c1c1c11cc6cccdcd6c6cdc1c10111c1c1c111c1112020222200020222022424284445ccc11094b9999499499444842
c6d50000000000000000000d6cdcc1c1c11c1c1c1cddc1ccdcd66dc111c11101111111112111022222202000200220222444444411cc1159a4a9949944444442
cccd6500000000000000000166666cc1c1c1c1c1cc6cd111ccccdc1c111c1110011c111c11111102112221201111251125445449411ccc1051154a4494444440
c1ccccd510000000000000056cc66e6ccc1c1c1c1d6c1cc1c1ccc111c111c1c11101111111c11111110221021112022442444495944013cc35044a9999494444
c111cccc651000000000000d6cccc666eccc1c1cc6c1c11c1c11c1c11c11111c1c10111111112222222022202224444444949499999902cc66d0499999449444
c1c1cccccc6d500000000016ccccccc666ecdc1cd6c11c1c1c1c1c1c11c1c1111cd110011212022222222222242848444489499949940ccc76cc049999494944
c1c1c1cccccccd50000000d6cccccccccd666dcd6c1c1c11c1111111c1111c1c1c1c11100002222222222202242444848494994999901cc677ccc15999499494
c1c1cc1c1cccccd65100056ccc1c1c1cccc666776c11c1c1c1c1c1c11c1c1111c111c111100002222202222224484844498949994950cc676cc13c104a494984
c11c1cc1cc111cccc6d5d6ccc11111c1cccccd6cc1c11c1c1c1c1c111111c1cc1cc111c111200002242222222225444242444499440ccc766c1051c114999444
c1c1c1cc1cc1c111ccc66ccc1c1c111111c1cccdc11c1c1c1c1111c1c1c111c1c111c11c1111100022020202222522220044544b901cc677cc04953c11000201
c1c1cc1cc1c1c1c111cccccc11c1cc1c1c1c11111c1cccc1c1cc1c11111c1cc111c1111c1111121000202002225444444494999921cc677cc159a945cc1cc1cc
c11c1cc1cc1c1c1c1c1ccccc1cccccc111ccc1c1c11cdddccccc1c1c1c11c1c1c111c1c11c1111120000220442248444894949940ccc776c10994a9941c1c111
c1c1c1cc1c1c1c1c1ccccc1c1cc1cccc1c1c1c111c1cd666dddccc1c1c1cc1111c11111c111d1d112210000842444844498999401cc676cc159a999994444494
c1c1cc1cc1c1c1c1c1c1cccc1ccccc1c11cc1c1c11cc666666cdddccc1c1c1c111c1c1111c111112112110202428444449949921cc677cc109a9999999949844
11111c1c1cc1c1c1c1cccccccccccccccc1c1c1c1c1cd66667666cddcdccc11c11111ccc1c1c1c11121222110024449849899401cc776cc04a9a499494944944
00111111c1c1c1c1c1cc1cccccccddcdccccc1c1c11cccc6666676666ddcc1c1c1c1c1ddc1c111d1111121d1000024444494401cc776cc119a99999999449844
111000000111111c1c1cc1cc1ccd6d6dddddcccc1c111ccccc6666666666c111111c1d66ddcd1c11d12dc22242110002444901cc6776c1159494b49444444444
ccc1c1110000111111c1cc1cccc6666666cddddccccc1cc1ccccc6666766cc1c1c11cd6776ddc1c111d1cc122422200024920ccc776cc1599a99949949444444
c11c1cccc1c11000010101c1cccc6767666666cddddcccccc1c1cccc6c6cc1c1c1c1cccd6676dc1dc1ddd1cc1d28442000201cc776cc1094a999499494949444
c1c1c1c1cc1cc1c11100000111cc6c666776667666cdddddc1c1c1cccccdc1c11c1c11cccd67dc11c1cd6dc1cc1d24842201cc6776cc04949949949994444844
c1c1c1c1c1c1cc1ccc1c11100ccccccc6c66766766666cdcdc1c1cc1ccc1c11c11c1c1111ccdc1c11c11d2ddc1ccc152420ccc776cc109494999494489444444
c11c1c1c1c1c1c1c1cc1ccc11ccd1ddcccc6c66667767676dc1ccc1c111c1c1c1c1c1c1c11ccd11c11c11c12ddd1ccc1101cc6776c1144959949449448444844
c1c1c1c1c1c1c1c1c1c1ccccccc1100001dccccc666667766ccc11c1c1c1c1c1c1c1c1c1c1cddcc1c1c1c11c12ddc11ccccc6776cc1094949494444444444222
c1c1c1c1c1c1c1c1c1c1cccc1cd100000000012cccccc666ccd1c1c1c1c1c1c1c1c1c1c1c11ccd6dcc111c11c11ccc1ccccd677cc11244454444445444424422
c11c1c1c1c1c1c1c1c1c1ccc1cc1000000000000011dcccc1cc1c1c1c1c1c1c1c1c1c1c1c1c1cccddddc11c11c1cc1ccc1c6776cc10444444444444444222222
c1c1c1c1c1c1c1c1c1c1cc1c1cc1000000000000000011cc1111111c1c1c1c1c1c1c1c1c1c1c111cccdd6cc111ccd11cccd676cc110844444444444844222422
c1c1c1c1c1c1c1c1c1c1cccc1cccc11100000000000001c1c110111111c1c1c1c1c1c1c1c1c1cc111cccdddcdc1c11111ccccccc111044444844844244222242
c11c1c1c1c1c1c1c1c1c1c1c11c1cccccd11100000000dccc1c11110111111c1c1c1c1c1c1c1c1cc1111c1cddddccc1c11cdc1cccd2000224484424424222220
c1c1c1c1c1c1c1c1c1c1ccccc1cccdc1ccccccd111001c1c1c1cc1c1c10110111c1c1c1c1c1c1c1c1cc11c1c1cddccc11c1c1c1cdd2220000222224222202220
c1c1c1c1c1c1c1c1c1c1c1c1c11c111c111c1cccccccccc1c1c11c1c1cc1111010111c1c1c1c1c1c111c1c11c1ccdcccc1c11c1cd22204420002222020420222
c11c1c1c1c1c1c1c1c1c1ccc1c11c1c1c1c1c111c1c1c1c11c1c1c1c11c1ccc1c1110111c1c1c1c1cc1c11c11c11c1dd6ccc111cd22448222220002422202220
c1c1c1c1c1c1c1c1c1c1cc1c1c1c1c1c1c1c1c1c1c11cc1c11c1c1c1c1c1c1c1c1c111100111c1c1c1c1c1c1c1ccccd676cccccd222222422244200002220220
c11c1c1c1c1c1c1c1c1c1ccc11c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1cccc1c11101111c1c1c1c1c1c1dc676c1111dd002042220424222000022022
c1c1c1c1c1c1c1c1c1c1c1c1c11c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c111c1ccc1c1101111c1c1c1cccd667ccd1ccdd222222420422222422000200
c1c1c1c1c1c1c1c1c1c1c1cc1c11c1c1c1c1c11111cc11c1c1c1c1c1c1c1c1c1c1cc1c111c1cc1c1110111c1cddcd676c1c11121dd5224202222220220200000
c11c1c1c1c1c1c1c1c1c1c1c1c1c1c1c11111c1c1cc1c11c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1cc1c110111cd6676ccdc111121dddd5220220202020202000
11111111c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c11c11c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c11c1dc6776cd1cc1111111125ddd222020202020220
011111111111c1c1c1c1c1c1c11c1c1c1c1c1c1ccc1c11c11c1c1c1c1c1cdcdccc1c1c1c1c1c1c1c1c1c1cc1ccd6666dcdc1c111111102124622020202020202
11111111111c1d1c111111111c11c1c1c1c1c11c11c1c1c1c1c1c1c1c1c7666666cc1c1c1c1c1c1c1c1c11c1cd676ccdc1ddc111111111115d02220202021102
ccc1cc1c1c11c1c1c11111111011111111111c1cc11c1c1c1c1c1c1c1c6ccccd666ddccc1c1ccc1c1c1c1c1ccd676ccc1111dddc11111111d101101020101121
c11c1c1c1cc111111c1c1111111010111111111111111111c1c1c1c1cd6c1c1ccccd6dddccdcdcc1c1c1c1ccd676ccd11c1111c2dc111111c111111001111021
c1c1c1c1c1ccc1cc1c1c1ccc1cc1c111111111111111111111111c1cc6c1c1c111ccccccd66cd6cc1c1c1ccdc77ccddc11111111d61111c11111101111111211
c11c1c1c1c111c1c1cc1c111c1cccccccccccc1c11111111111111111d111c1cc111c1ccc666cdd66cdcc1cd676ccdc1c1c1111c6d11111dc11111101111111d
c1c1c11c1c11111c11c1c1c1c1c1cdc1c1c1cc11c1c1c1c1c1c111111111101111c11c1cd777cccccdcedcd676cdc1111111111dd11111111dcd11111111111c
c11c1c111c111111c11c1c1c1c11111111cdd1c11c1c1c1c1c1c1ccdcc1c11111101111c67c6c1c1c1cccd6776ccd1c1c1c1c1c6c11111111111cdc111111111
c1c1c1c111c111111c1c1c11cc111111111cdc1c111111c1c1c1c1cdc1c1ccc1c1c111c67cccc1c1c1cdcc676ccdcc11111111dd111c11111111111dcd111111
c11c1c1c1c111111111c1c1c1c1111111111dc11c1c1c11c1c1c1c6c1c1c11c1c1c1cc676cc1c1c1c1ccc677ccccddc1c1c1cc61111c1c111111111111cd1111
c1c1c1c11c11c1111c1c1c1c1c1111111111cc1c1c1c1c11c1c1cddc1c1c1c1c1c1c1c76cccc1c1c1cc1d676cd1c1ccc111116c11111c11c111111111111c1c1
c11c1c1c1c111c1c111c1c1c1c11111101116c111111c1c11c1cd6c1c1c1c1c1c1c1c766cd6666c6cccc676ccc11c1cd1c1cdd1c11c1c1111111111111111111
c1c1c11c11c1c1c1c111c1c1c1c1111c11016cccc1c11c1c111c6cc1c1c1c1c1c1cc67ccc66667776cdd77ccdc1c1c11c11c6c11111c1c1c1111111111111111
c11c1c1c1111c11c1111c1c1cc11111011116666666c6cdcccd76c1c1c1c1c1c1c1d7cc1d7cccc1cccd676cc1c1c11c11c1dc1c1c111c1111111111111111111
11111c111111c11c110111c11c11111011116677777777777777c1c1c1c1c1c1c1cc6ccc7cc1c1cc1c677cccc1c1c1c1c1c6c1111c1c1c1c1111111111111111
0111111111111cc111111111cd111100011166c6c6666767776c1c1c1c1c1c1c1c1cc1c66c1c1c1ccd776cc1c1c1c1c11cdc1c1c111c1111c11111111111c111
10011c111c111111111111111c11110111016cc1c1ccccccccc1c1c1c1c1c1c1c1c1c1d7cc1c1ccdc676cccdc1c1c1c1cc61c111c11c1c111c11111111111111
1c1c1c1c1111111101c111111c1111110011c21111111111111111111c1c1c1c1c1c1c76c1c1c1cc6766cdc6c1c1c1c116d6c1c11c1cc1c1c11111111111c111
c1c1c1c1c11c1111111111111c1111000011d0101010101111111111111111111111cd6c1c1cdccd676cccddc1c1c1c1c6c6dc1c11c1c1111c1c1c11c1111111
c1111c1c1c111c11111cc1cc1c1111000001cd111111111111111111010101111111d71010116cd676ccdc6c1c1c1c1c6c16c1c1c1c1c1c1c111111111c1c111
c1c1c1c1c1c11111c1c1c1c1ccd11c100111cc1cc1cc1c1c1c1c1c1c1c1c1111111176111116ccd76ccdcdc1c1c1c1cdc1c6c11111c1111c1c1c1c1c11111111
c111111c1c1c1c11c111ccc111c111101c11dc111c11c1c1c1c1c1c1c1c1cccc1cc67c1c1cc6cc776cdcc6c1c1c1c1cdc16c1c1c11cc1c11c111111c1c1c1c11
c1c1c1c1c1c1c1c1c11c11c1cc1100c1c111cc1c11c1111c1c1c1c1c1c1c1111c1c7cc1c1c6cc676ccc16c1c1c1c1cdc1c6c1c1c1c1c11c11c1c1ccdcdcc11c1
c11c1c1c1c1c1c111c11c1c11c1110110011dd6d6666666d6d6dcddcdcdccccccd76c1c1cddcd76c6cccdc1c1c1c1c6cc6c1c1c1c1c1c11c1c1cc1c111c1c111
c1c1c1c1c1c1c111c1c1c1c1c1c1111011106677777777777777777777777776777c1111c6cc676cc1ceccccccccd6c1cec1c11c1c1c1c1c11c1dc1c111c1c1c
c11c1c1c1c1ccc1c1c1c1c1c1c1111111111666666666666666666666676667766c1c1c16cc676cdccd766e6e6e66c1c6c1c1c11c1cc1111c11cc111c111c11c
c1c1c1c1c1c111c1c1c1c1c1c1c1111100016ccccccccccccccccccccccccc1cc1c1cccd6cd67cc6c1cccccccdcc1c1d6c1c1c1c1c1cc1c1c1c1c1c11c1c1c1c
c11c1c1c1c1c1c1c11c1c1c11c1c11c1ccccc1c11111111111111111111111c1c11c6e66cc676c6ccc1c1c1cdc1c1cc6c1c1c1c1c1c1c1c11c1c1c1c1c11c11c
c1c1c1c1c1c1c1c1c11c1c1c11cccccccdddc11c1c1c1c1c1c1c1c1c1c1c1c1c1cc6767ccd76c66d666dc1c1cc1c116cc1c1c11c1c1c111c1c11c1ccdcdcd1c1
c1c11c1c1c1c1c111c1c1c1c1c11cdde667c1c1111111ccd66d66c6d6d6c6dddc676cc6cd676c676667c1c1cdc1c1c6c1c1c1c11c1c1cc1c1c1c1cd111ccc11c
c11c1c1c1c1c1c11c1c1c11111c11c6776c111c1c1c11ce77777777777777777776cd6cc676c66ccccdcc1cdc1c1c66c1c1c1c1c1c1c1c1c1c11cdc1cc1c1c1c
c1c1c1c1c1c1c11c1c111c1c1c1c166cc1c1c111111c1666c6c6c66c6c66c66c66c16ccd67cc7c1c1cc1c1cdc1c1c6c1c1c1c1c1c1ccc1c1c1c1cd1cddc1c11c
c1c1c1c1c1c1c1c1c1c1c1111111c6c111111c1c1c11cccc1c1c1c1c1cc1cc1cc1cd6cd676c6ccc1c1c1ccdc1c1c66c1c1c1c11c1c11c1c1c11c1ccdc1c11c1c
c1c1c1c1c1c1c1c111111c1c1c1c7c1c1c1c111111ccdc11c1c1c1c1c1c11c1c1cc7ccd77cc7c1c1c1c11dc1c1cd6c1c1c1c1c11c1cc1c1c1c1c1dc111cc111c
c1c1c1c1c1c1111c1c1c111111cd6c111111c1c1c11ddc1c11cd6766666666666676cd676c7666666cc1cdcc1c166c1c1c1c1c1c1c1c11c1c1c1ccdc1c1c1c1c
c1c1c1c1c1c1c1c11111c1c1c1c6c1c1c1c111111cc6c111c1d76cdc6cdcdcdcd67cc677cc7ccccc1c1cdc1c1cd7c1c1c1c1c1c1c1ccc11c1c1c1cd1c1c1c1c1
c1c1c1c1c111111c1c1c11111c661111111c1c1c116c1c1c1c76cc1c1c1cc1c1c6ccd67cc76c1c1c1c1cdcc1c17cc1c1c1c1c1c11c11c1c1c1c1c1cdcddc1c1c
c1c1c1c11c1c1c111111c1c1cd6c1c1c1c111111cc611111c67c11c1c1c11c1cd7cc676c66c1c1c111cd11111c71111111111111111c11111c1c1c1c1c1c11c1
c1c1c1c1c11111c1c1c11111c6dc111111c1c1c1cec1c1c1c7cc1c11111c1ccd7ccd77c6776c66d1111d101117d1111111111111111cc1c11111cd11111c1111
c1c1c1111c1c1c11111c1c11c6c1c1c1c1111111dc11111c6611111111111cdc6cdd6ccdccdccdc111c1c1c166c1cc1cc1cc1cc1c1c1c1c1c1c1cdcc1c1cc1c1
c1c1c1c1c11111c1c1c111ccec1c11111c1c111c6111111de510101ccccccccc1c1c1c1c1111dc1ccc1c1c1c7cc1c1c1c111c11c1c1cc11c1c1c1c1cdccdc11c
c1c111111c1c1c11111c1c1d6c1111111110111d10001056611111ccccc1c11c1c1c1111c1ccc1c1c1c1c1c66c1c1c1c1cc1c1c1c1c1c1c1c111c1c1c1dcdc1c
c1c1c1c1c1c111c1c1111116d0111111000011dc11c1cc76cc1ccccccc1ccc1c1c1c1c1c111dc1c1c1c1c1c7c1c1c1c1c11c1c1c1c1c11111c1c1c1c1c11c1c1
c111111111111111011110d710111111c1c1c16cc1c1167c1c1c1cccc1cc1c1c1c11c111c1cc1c1c1c1c1c66c1c1c1c1c1c1c1c1c1c1ccc1c111111111c1c11c
1c1111111111110001011d7ccc1cccc1c1c1cdc11c1cc76c1c1ccccccc1cc1c1c1c1c1cccdc1c1c1c1c1cd7cc1c1c1c1c1c1c11c1c1c1c11c1c1cc1c1c1c1c1c
001111000010111c6667776c1c1c111c1c1ccdc1c1c167c1c1ccccc1c1c1cc1cccdcdcdddc1c1c1c1c1cc66c1c1c1c1c1c1c1c11c1cc1c1c1c1c1cdcc1c1c1c1
0001111c1cccccc677766ccc1c1c1c1c1c116c1c11cd7c1c1c1cccccccdcd66dceccc1cdcccddcc1c1c1d7c1c1c1c1c1c1c1c1c11c1cc111c111c1cddcddc11c
1cc1cccccc1c1ccccccccc1c1c1c1c1c11cdc1c1c1d76c1c1c1c1cd6ccd6676c6cdcdc666666c1c1c1cc76c1c1c1c1c1c1c1c1c1c1c1c1c11c1c1c1c1ccdcc1c
cc1cc1c1c1cc1c1c1c1c1c1c1c1c1c11c1c6c111cd77c1c1c1c1c16c1c6677cc7666667ccc1c1c1c1c167c1c1c1c1c1c1c1c1c1c1c1cc11c1111c111111c11c1
c1c1c1cc1c1c1c1c1c1c1c1c1c1c1c1c1cdc1ccd677cc1c1c1c1cdcc1d667cc66cccc6dc11c1c1c1c1c76c1c1c1c1c1c1c1c1c11c1c1c1c1c1c1cdccc1c1c11c
cc1c1c1cc1cc1cc1c1c1c1c1c1c1c1c1cd66677776c1c1c1c1c1c6c1c767cc6cc111d6c1c1c1c1c1cc67c1c1c1c1c1c1c1c1c1c11c1cc11c1c1c1cdcddcdcc1c
c1c1cc1c1c1cc1c1cc1c1c1c1c1ccd667777776cdcc1c11c1c1c6c1c6666cc6c1c1c6dc1c1c1c1c11c7dc1c1c1c1c1c1c1c1c1c1c1c1c1c1c111c11c1ccdc1c1
cc1c1c1cc1c1c1cc1c1cc1ccd667777766cccc1c1c1c1c1c1c16dccd766cc6cc11cd7c1c1c1c1c1cc67c1c1c1c1c1c1c1c1c1c1c1c1cc1111c1c1c11c11c1c1c
c1cc1cc1ccc1cc1ccccd666777766cccc1c11c1c11c1c1c1cc66c1c766ccd611c1c7c111c1c1c1c1d7cc1c1c1c1c1c1c1c1c1c11c1c1cc1c1cdcc1c11c11c1c1
cc1c1c1c1c1cccd66e777676cccc1c1c1c1c11c1c11c1ccd666c1c6666cc6cc11c661c1c1c1c1c1c77c1c1c1c1c1c1c1c1c1c1c11c1c11c1c1c1c1c1c1c1c11c
c1c1cccccc666777766ccccc1c1c1c1c1c1c1c1c1ccd66776cc1cd766cc6c11c166c11c1c1c1c1cd7c1c1c1c1c1c1c1c1c1c1c1c11ccc11c1c1c11111c1c1c1c
ccccdd667777666ccccc1c1c1c1c1c11c1c1ccd6677776ccc1c1c766ccd6c1c1c7c1c1111c1c1cc67cc1c1c1c1c1c1c1c1c1c1c1c11ccc11c111cccc11c1c1c1
d666777666cccccc1c1cc1c1c1c1c1c11cd6677766cdcc1c1c1c766ccc6c1c1c66c11c1c11c1c167c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c11c1c1ddcc1ccd11c
77766cccccccc1cc1cc1c1c1c1c1c1c1c66776ccc1c1c1c1c1c67c6cc6cc1c1c7c1c11c1c1c1cc76cc1c1c1c1c1c1c1c1c1c1c1c1c1cc11c11c1cc11cdcdc1c1
6cccccccc1c1cc1c1c1c1c1c1c1c1c1c676cc1c1c1c11c1cc67766ccc6c1c1c661c1c11c1c1c167c1c1c1c1c1c1c1c1c1c1c1c11c1c1cc11c11c1dc1c111cc1c
cccc1c1c1cc1c1c1c1c1c1c1c1c1c1c676c1c11c11cccd66766cccccecc1c166c1111c11c1c1c76cc1c1c1c1c1c1c1c1c1c1c1c11c1cc1c1c1c1ccc1cc1c1c1c
c1c1cc1cc1cc1cc1cc1c1c1c1c1c1cd76c1c1c11ccde7777dccc1c166c1c1c7dc1c1c1c11c1c67c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1111c1c1cddc1c1c1c1
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


