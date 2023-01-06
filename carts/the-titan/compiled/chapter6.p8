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



_img_dystopian_hellscape = "◝◝ヲ○◝◝♥トj+Wえま●ナ🐱█⁘○◝ へセt■ihひ!QYYカRg\\Y■◝テ。x²せ■らタ$⬇️ウ□d。さヌ8□n5と‖*。ヒ!◝ケヒ、□ょ\nUネ🅾️¥セ⬇️R$ほI,W⁴░▥ゅi\t2Jふ?ョゅぬ➡️(オウ8➡️ろはRめ★ょ⁘ウチn$DみとケしyQAᵇᶠa!◜れBPG<Q」!カ,ねn▒さᵉ◀H⧗⬇️░サu「UCミ.█(…ヒ゜ンニ#1*$ニeるッ-mᵉ¹8ょを+Mᵉ□Hハ&$GA░♪\r⬇️ワ♥4Hsけ」ろつ-`そB8lqるあ*✽□ᵉp▮^Cu⬇️ロ🐱¥。rょ:[$スせ\tテやイ◀□ロの░ナEオフ6\"ウ5…★¹.$▮%♥p▤>⬇️¹ᵇ6-なr8⁸ヌ,ᵉ、Tヌ★Zさ9DYっ9*うDgK$ᵇサᵇ⁶\tᵉナ♥vゃ*Mこ‖ˇる+☉ヌわrqわ➡️⁷むs□',SたI⁷\t!れ▥む∧よ▮えrゅUr³█qオ⁴ @$うゃをネなo7✽Hむq⧗⁸∧Nま🅾️⁸ゃ□て$ヌょサ#Mまuむ[dヘへ[aN!も★5…p、웃\"87SWK⁙█へく◀aVJRウしhのCケ(▮&ムa、I■ろHf★Ha¥ゅIる⬅️ひなニ○゛t,みe$DソFqKょˇ★んニ⁴∧リふ、Pな\tわ🐱F⁸ちrs⬆️ニうA゛ふヌ4⁙^ムGニ✽ノ✽トjい⁙x░□#-G웃+🅾️x웃キPうR■0 ヲ。D\\に!くり9🐱サ•ん⁸ほjs³9キケNひ⧗8☉⬆️+ろうミん⁙と$せ\rけ^□っヌsろ□pQヘ➡️d8Eおノ■⁙⁙$カB∧{y∧K웃ム➡️$□#q2ウY$ヒ?PSNbM¥^5ᵇ4ぬˇんし⬆️ハ⁵V☉U.□、オ9ヌdそ∧8➡️■nめ□⁙●∧テり#っAハA&⬇️i,ナZKp*まさ\"‖キセ-#K,のキ、も∧⁴キRふフL웃%ンU░:▮Y웃\"J▥$☉#G/ょPN\r$⁙Rヨニとq.ゅさi0Mわp…☉ハyh☉マヌニ{へ⬆️4ふさメウ@I♪▥,な⁴✽⬆️は²タ▮2る\"ミゅッレ=、TFVネ□■²N□も➡️エr8\r⁷□\"nxdFのケ⁸のBᵇj!$웃,メヤ]^おU⧗てもリょ^c🅾️ホ⁵WOヒもyさ☉そな$ぬさBhうJヌよ\r\nE*Iも==ヌおゃ}qっ😐▥QをのM➡️?ユユ웃$ね⁶웃'⁴K、ウヌQ」⁴)ᶠ>☉★Jろlfこセ_ヲそぬ⁵★ホCあ\"!\"まく (□N☉$Da◀$モちZ➡️¹=♥フま⬆️T$る:⌂B%ヒ'wM8➡️$フ8ツ$う⬅️ᵉ9⁸qょ9X■e8▤こ▤H~D🐱⁵めk\"ウai ░Y*◀q'8➡️ケ▒タ∧ま8まc,⁵➡️ろDBw#セ$み🐱Jつ■イ⧗□そAN゛DA*\n\0、めホ□²ナI‖+D▤b:さモC▮*ゃ$フ☉★マへJQ|。v▥hチd▒⁴オさw⁸ヌ@らキFた⁘r~C웃!Dねウめ☉「⌂♥=UヌらX░\0Dへ⬅️#░♪…A\n▒ᶠュ#CZ\"む♪d⁴^z➡️7Qソ■%➡️(D…`♥<⧗⁸,□,8…➡️ン\"Iろ⬅️rY'(へ8BKし'む\0オrtaH³H^ ○⁘@?y$\0⁴w⁵Tさ█◀くろM\t²ッX$CH☉?ゆP5Gヌえは★DᶜH\"a\"*Wへ%の.▒#Qd~オレ⁸J░'のp⬆️キXG Bᵉ▮えH⬆️☉\"R²っ\t⁸{きョ◆⁙ラおユ▤J\tl、●ヒちYゅn■■\\☉HT\t゜う◆ョさD□りさノう%$🅾️l$░%#$4D🐱F●り◝へC♪ま★%)チケあeわカ$▒A!さ$$~0ロGョスヒD✽@b…Mさu⁶I  ュQ$▒⁸Dp☉ヌE♥◜てサ\0★LIキG、ル웃□▒R⁶☉HヌDナG0の?ロヨさD\"$¹シZKふ⬆️웃♪▮F² ナB□B□D✽●♥R?ユwxネKきあヘ⁴ふ¹シう⁸キ@◀\t$Kら웃⁴◆く◝へDミ♥、R%ヒ,█³▥ウク¥し➡️$)$⬅️E♥0…ラG◜hnな⬅️⬇️…uほJpホ▮ 🐱Iく カ¥゛っ◝ホん▶ˇ♥‖!Lニ$.⌂✽e▮Db$◆$u#◜➡️◜q/\0ナせ、けZヌᵇるᵇb⁵☉⁘5⁴キよホ゜て=ニ⁶8)jb?(D@♪#てまむよリ/◜「▒¹$⁵$rI■D\rゃaムフ⬆️ヤ○2?ワj☉A\"⁸➡️4Iっ☉,□9…➡️ᶠ◝ハr$⬅️³x➡️²⁘ヌ゛H◝◜❎\t あゃ;◀⁙▮♥の\"1゜◝ウオ,Aらᶜ/¹⁷▮ン⁸?◝か-Y²i$ラHいか⁙☉i#░のᶠ◝ハろhEHNのI8▥\"、H●웃tそO◝ぬュ*」Qdやp◀UuKソ^ちツ³◝ソ◜²っPへ:☉$い▤~3⁵チKよ◝ˇeの\"ら█⁶H^みよわI'⁷▶🅾️#◝ン8ナ□E⁵ヒ#K_をほ∧チf◝◜W▮、H∧★Hた'⁙とさ▥ンG!サEほ◝ンY*き、q\t⬅️¹■$ュe⬆️s8ル○◝'!n☉う゛8pい?⁸★rのT◆◜@ョノ◀@⬆️ウe$た⁘か⧗%qo⧗◝えl:のO9➡️‖\t▮qRまこ■$ュ\rつr∧○リ░8なろラAz…うA⧗]Pュせ⁷T⧗웃◝サスヌもル{ろね\0きて2-ᵇウᵉ◀▶sみかュ♥¥dめ▥yワYd■yろう$ネs$ノノあ⬇️いᶠラ゜にKZらニ、=★5(マケやW=9な▶¥、WKカ、p◝[ロた❎な8p、w\tチGE ⁵¥りゅにAるrIクm$◝ネケケ⁴まマさq.⁘😐⧗²░ᵇrDO웃る⁵せ◝J&⁴░Mb2C☉ˇンpもᵉ!せ□,iiw、ケ⁷ネ\r⬇️リヘe⁘H&😐x➡️$オFH☉*░つQキbユニKとそ♥ナも⬇️`ミ░ˇ,マBニミO゛5カ⁸D、た█m•ユG▮-ヌひなくaろ⁴▮レ⁘HRりl∧ろM⁸!▒NPか⬅️」ぬノ…ヌ⌂t@@|웃ᶜ(█S웃\t⁘U³ま」ろH。★ら&Q⁴エソDナD;ぬ7◀r…qr¥4\"MWすpQた,19!TN2ᵇコᵉ,=\0^kぬYるるPゃ▒さEkヌく\rるZ+v웃(ね▮‖Zd♪をᶠD◀せあ)あN,³ろソ▒□R\0[▮$➡️し qを▥▶Hネいき█く♥✽く3マDb)$g:+fCこ。ケ2クせ5れ▥2Lい、#%CWᵉろ-⬅️¹`ˇ こq,⁸ニ□て@?⁴Iさ5モれセ/ᵇ░さ,G1⁸こ🅾️\0ヘく、nみ⁴]…へ#スラLノs0ツそヘI\nヌ◀(M8➡️ク5…テ2'□W`\t🅾️みキK++웃さuとVる (ュ,ヌK\tさ➡️⁸$HMる\"W⁶ゆゅみRfろニれ^(SL…rそ★d):⧗🐱pCᵉl➡️JPᵇみぬ🅾️ハG⁙p♥Rャ◀⁵GPチっ➡️●M\\X□/@()メうっ⁘▤★「.ノ!6⁸もKg:\"ア▮\rm<ヌ⬅️`ひ⌂▶☉\"ろ⬆️8Tさユうさオ★9B★/▮▮フラあ\0p³たとI9Mk$⌂➡️セ!R□&へり、ち\rソᵇ■\"り웃³ひヌDニQろろ☉D⁷r\\ね゛し…▒¥DB%ヌsゅみフつさ^✽そG◀WT□⁷\\➡️⁸さ 웃d$:ニ▮😐ウとw!j8Yわᵉ.…⁙$さD$チ+🅾️yBᶜ◀スG」らナ,░&DあA8-Iら▶p^⁙^ひkアヌ^.mク⁘▮⬅️◀uみノふン^さFフそ☉シ😐I⬅️z➡️ソDモをぬそRさそ, ☉★◀9テe^lノ♪4웃\"\\コUep⧗▒¹ᵇ$へbc➡️⁙H、T^8!り#☉□れみQ%•アiみぬニゃら%🐱ニセ*J…#✽pHA\t$。(もヨbわ★)PAら♥⁴ET➡️Y*ニg\tさs4🐱っ▶)\"ラA)を!⁴🅾️りBアI◀ヨ,➡️Hヘ!8$かかG•♪クRけ웃y⁴ろれ웃ょえ\\⁙★Cけ\"r⬇️¥るろ,の8るこ░&アュ`░♪ろp➡️'³キ▥さの{TD■hヌ★%け웃⁴、さA\tろD!@qエゆレH[む\tキA#ヨヌ9 tN*@Q‖⬇️u□★¹■QケTH🐱d➡️Pラᵉ4フしフい▒オくᵇ9 psbZF⁴%ᵇb*セ\\I■★ん1\tオくQそネ웃⁸リウQフ<フうやロPハ$ヌ,メ³へ。ユ*@=⬇️B¹4@TうI\tI!Pニ□⌂\rア…メfモ\n🅾️▤よ█R\r²もAQ⁵たj'r\t!‖#☉█⁙さBlI$⬅️ Qほもほ…へろ゜😐◆るソ'|D-▮♥☉:$♥1‖2!Gr!「}*アBらわᵉQ,TJ⧗ス\tろ⁴はI、웃+▒、\"'☉ハ!\tめテセ⁷7「Yゅ░S✽ニ-B⁸]うみコ⁸ふ8●ゅ\th、せ‖*🐱pうツ$tスgv●ヒり-⬆️⁸P⧗ᵉケえら✽ナ9/サ⁵サXR\"⁙ユあま、、🅾️P🅾️y@)ろハチセリdUぬtJっ}8pねエ⁸♥⁷フ■、ねら웃ゅ$=チq\n)'=◀[$ネ`N⬅️+ユノᶠ!◜'r=▥0Bこ웃\"そそやアKケも,t6tうれ⬆️웃しsa◝ˇん∧웃Z⬅️RI')とチ⁴ヌ⬅️セキq웃\"⌂ᵉ'\t+゜に1Pロけょjゅ…く*9∧ろᵉ░⁸q.あモ▥➡️るら✽▒KツAPi,ラD⬅️ᶜc⬅️Dねゅ\"\"HBX➡️²BB\0😐zロ⧗✽ス♥uA$□ヘ●⬇️⬇️☉z▥\n4●웃lI■ᵉ! ░ら⬇️█お&%&●➡️⁘B゜あ\0ナIち8▮🐱T■、ろBD➡️$X!ひ■=そH$░9░⁵Bp!ケO▮웃\n🅾️ラ。Hの「░●☉웃▮おヌD➡️$●●♥tS ∧ょAh\"⁸✽ネユ█■R$9➡️t@ュ**■⁙⬆️p⁙つᵉTruV%☉dラIチ▮うろ¥⁙ラ░@Hネ☉⁸v⁸~¹8\"😐²\0ノ(Tネひ🐱$□9🐱D█$A■¹🅾️ノ○aケネt🅾️%6オ➡️ウ■ろ⁴🅾️a$N`🅾️!0AろBかャyマsん⁙お0¥ルD/▮9く ~「0……)qり+◝%ホR%rコ8rDn8uzN;Yシ⁸2へ⬇️お⁴$q▒r⁴ニム7$r…ョツ~*そ✽ナ▒るろうvマEマ、さ⌂ぬミDq⁴\"'⁷!れH▤なしもテッ❎I\tれ▥★8うり▮ふᵉQ。えᵇヌ‖⁴●⬇️b&\t¹イ゜◆¹;⧗かく.◀\"█¥Dや$4す…もこ🐱7□□7⁷3wろ8❎Advhqᶠらキ⬆️‖$▶H$あレア⬇️J\"<\"\"\\G'▶⁙░▶²⁸!⁵オAᵉ%~#▥▮¹ろ\"⁙iカdメるウaD♪t¥⁘し✽N#くヲIw³●うふ⬅️(q□N□H░█やI&●チるq'1⁵…➡️hu‖り$l☉そA⁵I0☉⧗⁴ナ%★2、さ 、ら░fく¹{ᵉ🐱Q49▮モちsQ\"BD…¥ᵉさhP$うえヌ▮q8♥\tナッ$⁴Y\"りけ6\0004\"■ᵇ\t⁴▮▤$?や³ヘ‖Gノ!サ⁘⬆️キ2i\t³rTHwᵇB◆ヌA$▮B~➡️▮\0I⁸$O웃▮\n*$ᵉさsHホ¹た⁷ョる²n⁸~Pリ▤@░'0qHA\tオ⁴@4けめ(□;ユ⬅️m!:░⁘~@DD\\ᶜDる^ H{)#⁵dW(そ░█フら☉U³☉…うろ゜🅾️☉の9\0"

_img_ai_overlord = "◝◝ヲ○◝◝♥ト⬇️kたハ◆✽'ハッ\0\0{!オ⁴?ウ█dヌT➡️ヲ➡️~,?⁘³⌂9…こPム²BA\t█HOろ⧗¹ᶜB、H゜そオs  1ハ●く⁸ᵇ\tᵉ!hノ♥S▒ア/うウmキカュぬュ⁘つᵉ5、A\t⁷\0B`ひcおすらあ♥M#◀▮♥ミ□⬇️リひネ!ア「9🐱█りく9²、ち░ᵉd…웃にヨ▤A⁴⁶スHcH🐱◆(A¹ろ 。⁙A-▥」dXDせニ#😐R▮░?□⁸Xᵉき🐱⁸¹っ🐱²ゅ$³ ⬆️pるᶠり9ケ(C⬇️ヨら▮ノAᵉ█●けAら♪さ➡️サˇ⁴█さ♥ス)%(p\nyF●✽█ノP♥⁘ADハ‖$🐱レわそ\"Wぬ'@⬆️j▮ま-゛りD░█さ✽\0tE'\0まなEカヲqc♥•\0りア:⁷ぬわ⁵$\0⁘C⁷」BケBH\\ゅ◆た⁷%T、¹ᶠき♥ろ゛\0「 ナ□\tdくり★h5∧~]っ⁷Q8▮ぬョ 🐱\0Bら\0░け‖‖@h「MZ◀おさ²Iカ%N@ラ、CるBBる▤オのMみeく¹⁘Dッi□p+くわ\tGニᵉ9\0HXcこz)⁶▥ノナめ☉?¹れ*゛をBQム8゛2 ぬ@Xn@はC²!=³Y\0♥ネ N█u…BQろ5□(z\0J<く\tbそゃカd~▮⬆️)@#■コS⁷|²ナ「▮゜░▮さ➡️w⁸{…4うあ¹웃\n⬆️Ia*M⬆️ワ█ᶠeD⬆️ᶠら…Alてキ[🐱\"り#▶⬆️\t$◀L♥&ぬ@8\0…マ、`゜し▮X♪Eヒ…\\IISfHH&サI;▒こ⌂ち(…゜⁸X!ン☉ ◀☉D[9□るᶜ³🅾️ろ%^)れ⁷\0ナ⧗ きHb`や█~f□@ノわJ∧ち5Iまア$4q□チけ⁙m、■むりhス\0Aᶠを▒;i1'$CDうメ\rきけノS9I「▥む#z\\、オ?`$‖²も▮を▤るる░BEz⬆️Qd9$🅾️⌂もカろ▮✽?nS●」d❎.…i`る▤つ‖ゃ\0CAウ⁷]@⁴%³の゜とqJ▥ヌヘ>\nネhは9ょ⁸\0#░GH☉ノうPz\0s▒B゜█□しdく))o□ょ░▒;,ナ▥f`qGQひ&ᵉゅHᶠる1⬆️な…D▤カるH*ヨね~●▮ユ dはそツ²お∧🅾️ろVっS$4む%もい‖◝➡️o⁙☉${◀⧗⁷らラ□q⧗♪Pi▮⬇️ひI⬇️░ぬ~ク;\rUゃ■こ⁸XSラナ、Ld,く&N+3⁴d%h♥◜」a 웃オ▤5▮ュaᶜ5'⁷‖ᵉ⧗★•0っな\"⬇️◝\tケなl0ノ⁸~TdF6ちれて):むh▒ケ5🅾️⁘}@ュt⁘の$⁴ナ³ヘAりそˇWちYLてふ(ヌっな[ q■iスノ\0008=▮◀「Qフ\0カJ\"□▮•け□り/ᵉlDネつ¹セD$?p 4$;✽5★リ,■S▒ZしP❎⬆️ヌ4•⁘;く🐱゜ス⁘ ⁴888Hˇクカろゅ-🅾️ョ⬆️ク●う\\¹ゃくO&&|そ(Qᵉ!りウq*BL8ネ⁘➡️す⬆️█•そ⁶8✽🐱、$?⁸X!y\0q\t1た⧗B\"\tをイS.ソ★せQlてQC⁴✽<▤😐も-ˇクp0ziIE]◀▶➡️\"L…Tˇ…ホ)G\0ぬミ@✽∧-=0♥しへW 8f\nM□r▒は⁴🐱◆しHHN8d웃%qヌき,⬅️Gネ,sxl░RウF!エ「웃、#sᶠロH■⬅️.⁵R+8ケ~a\\ウ⁶¹H░た◀H▤フb?웃かけAコu➡️⁘🅾️r⁸h⬇️リ⁸h🅾️&dF²ゃ\"っ@ク⬅️Rル^+Iム◆たク♪□ちゃそ7W゜さC4▤「♥\n'\tQ)ア8Uナマ▤ヌょUHq\r!□hpリ¹\"\t•1くセ&4APあ⁙あ⁴★えゃろ⁸R,ら⬇️と'‖⁸♥=セ-む■アマ!Aまヘナ4▮ケ⁸♪jさ♪(セ🅾️2\\ニ□4♥⁴っ⁴!◀xq⁷²ふ⬇️XNWけ⬆️uqヲロ⁴ヌクけ▮ニ%ラrG⁴うG*オ⁙ヨN■VD#🐱Y9Zゃ*8マDりを¹y%$■P∧ホ&,%ヌをニ&i²~ᵇ‖ᵇi;…Ji.▮ねy85⁙ぬ■t▮ナ\0pハろ✽Jるqシ0³⬆️ロキJヘ$ヒᵉᵉすˇ@~Pひu✽+s‖⬆️'▮NTqん 🐱Qイ、せ⁙♥¥ユ2(iQ{kᶠウ▮²$ヌ,◀ケ'□タ\"ユH%ナカ4XPCネけリ%⬆️しXdュa(こ'\tイk&W⁴♥⁘I)そとV⬇️🐱`ョ¥ゃ▶わあセGネっ□•き🐱をCいc🐱$d²イ&⬆️ゃセノ▮モHュ‖■8D♥fD=ャ⬅️■イナ8E⬆️▥•🅾️ :⁴9,!ャ¥□りっいたf∧🅾️8⁶?⁘u◀Qひ⬆️∧D⁵+M\nヌユニhョムぬE\";K、@RZ;➡️!フ'‖M6V■\\\0ナ\"➡️▒@そ?」◆らめ🅾️ッヒヘMdく‖9やにヌへ\n‖MY\"H\"ヨᵇqなG<ウすpYR□、2Y\\なM⬅️、Z($>_⁷6🐱ARJ✽、ねれ⬅️けcふ⁷。、っe⧗⌂\r<➡️むヌわ★ゅ▮ュhもTす▥,ゃV²%カ\r:⁴⬇️B'⁴こrKg²2Hg<Iuᵉら⁴♥き`!8モ5ᵉ\"★チはせ⁸░■~\0こ⬅️「ゃ2Jむi\\ユJrcス⁸pNへほ웃9➡️R@Lえ¥tのd▮ヘノあモ*⧗Eあs🅾️m⁵け웃\rら▮せWYj¥タCすE▮<!▶-▮@~bち⁙▥れりf∧のれラ(³オ²qろ…た&ᵇエ a⁙TN•、`p⁸□L░☉□¹‖チ⬆️|え@Aᵉ9ぬ…ハaさNd、,うMろナナ¥☉H\tオヒっYわ☉Y□\t,ろ<█。れ◀\0ら-ぬ∧PY$ホ@ホ!L²◀□□◀+⁸ミ🅾️⁙⬇️🅾️웃り<⁴ぬAᶜJり%░とaろRDIるZ まひ`pAりょ.➡️|s、ᵉ7ᵉJ$\"!ャイeるイしZW2E⧗な□'.%コカ ▮ュn◀hネ'#'□yy❎つxよヲなV●ふき&@D▤キBZナ⁙²▒ヲつセ⁸⌂~マ9ミか■ウ³オ³う▶♥ᵉ,えrᵉ/nQ$っカ(。9□\0 ░ら⬇️⬅️Zウとウdう^⁸ヌリ▤ソg=█\tら□♪$ニ,PHハわぬJqVIぬ█き♥ぬ⧗◀∧ゅMりコヌN゛ホ⁙\0P\0B¹2sア!エ⁸G.◀1¹☉🐱🐱`Aᵉて☉★♥❎░ヌ!オ8かさ▮…るRIdのヒX♥)!R>░iᵉ¹▒qrXロpネ☉8Mてs-⧗ゃᶜ¹B░¥WᵉセゅEF▮ノうI⁴9ルP、█ナ¹$J░\nマゅ0★Gき⁷\"🅾️🅾️%5A4そぬ`⁴ねy(🐱、れqアZは█,[ウい▥•タ□ちカンC⌂オのLネ░ヌ-ニ,⬆️TJイ¹っ█³➡️ノマHう⁘🐱⁙░ひ➡️,8%、x\0まbさ⁶⁸░む2⌂d,「⁘!⁷\0M゜😐☉dニ\ths8q4Hはれし)█}▮X;ニᶜ8⬇️♪\"な♥⁴🐱\0s🅾️dGt✽ナ⧗チゃ+i\"AクDTN$ ユ⁵ hう1Gs…ょオ🐱⁸ 'ルコ⬆️🅾️ルの⁘DZキ&ニ■+░🐱⧗く\t!イ2W□Vˇル:まャ➡️dᵉ6…フいVろ*すpう⧗たろへVヌミ⁙ホAエᵇりノナ➡️ッ7ネᵇ\r∧\nヘᵉᵇケ♥2わマnHキqうD❎ミWメょ∧ほˇˇろ?ji\t▒□サ★⁙I$D♥+xこ♥◀DもEハ00⁸⁴웃\nソ゜う░,8♥ノてぬqkf▥Y⁸゜6-□❎i⧗ユOをWルかワᵉ³A2😐♪@タてD➡️[sほヨGr<♥웃◝⌂ᵇふ⁸OI□ユKdN#ふ^<ニ!ョBっュ❎ろ゜ヲDうふの^W🅾️ロお、9□s🅾️<れ◝³~「1ぬ!◝♥:ネI&ヌq4W:Jd웃ˇ★oュEぬぬ³p⁴⁷◜>•みᵉ⁘なy★*H□⁴ょア⁸○ニっ\t\tCき²C◝.9くつ🅾️\\ょと◆*🐱^さ⬅️/◜3BAᵇ\tᵉ◆ュ|-➡️4のG*は🐱r░*gヌtz{ᵇᵉ█?Cゃゅ+qわねRD▥▮★う²MKンウH~:\r\tᵉきくᵉaツqれオ:ニ%\rれ♪?5]ˇ%🐱っYwヒかおᶠA ナ゜ウのBK&Iうき🐱イけ7⁷ᵇひ+⬅️さかせ、,か.▮Pりア「?RB☉⁘もりるサvヌVY&+8◆わ○n@\n\0マ◆ナKまュᵇ'MくのたろD➡️g⁴Y8ネレセクマY⁵¹⬇️▤H○\0そねれDZ,웃*ワ⁶□YンしO D:●:█ョヲ[!\"➡️ろれつ \0⁸S:うサ=りわオらら▮…う⁴ヌ⁸00!キ◀ケゃbj'も へん#웃るソq8は●ナ(⬆️MX░⁸█□□▮…◀ᶜ、²\n゛²JN\"ヨたろ∧う/⁘$Rま\nモ²ミi(▤:けP░く🐱`P'@$%⁘Y\nチ³(しiろKす[うみ^\"ょと\t\"😐uら' ⁵•\0ま8░き8「⧗9つけこち⧗%G⁙いm⬇️,オ$ネ▤たB³ゆ¹(ᶜ、ナz\0Sら^\"Xフ!、ヨぬ░ヨjア;まYUとZ★□⬅️3◝\t\n☉ ヒ²@★Rさ★d\t9た*N#➡️1らKb!dアF●Oュ]█L³[けB…ょ-,の*Eつ9RF)…A…B。Vy2Cヨヌ\0ろ░マK&⬅️gk■わ★]マ+⬅️ ░★p.\\YᶠuCX∧)IE゜シ\0せ♪きTᶜ,∧ワて◀4)BユN$たlDキPDさ⁵ネ█\"さ◜dqメぬ,▒チ★jそp‖く➡️*エっJrちLP\0⬅️▶tク はe⬇️ン▤モI!,➡️、!\n$$Hチ🅾️、ウ#m⁴mまウ&イ▥2U■eXソホ「🅾️fq\tᵇx□へ★&\"っBf;!⁘i\tIj⬆️なすの8_²ち⌂め⁙いᵇ8★p⬆️∧゛く4しR9#⬅️▮█をニるセ\"て█I⁸V∧ム☉☉NムN,いヨm (?i▒#CすK…ᵉe☉ほsょヌM1+웃/、$へd⬆️フ░K$!」テ*\0ヌI🅾️?(H4のi▶な¹l▮🅾️%こq5%A⁷□■ケIGヌもヘD░ヌ,🅾️8むるゃっヌ~☉ヌG⁸웃$Nさ★G'•⁴わ▒\0!…シId⁷、!=もY!*ノa。T⁷{お⁶🅾️xヌq⁶s⁙🅾️\nむN■,8🐱\r‖b…★R\"り) ヒqdT-……へあT…H*たに\tx,TJ▒せᵇこ⬆️NZrヌユ∧R▶CP🅾️ム$B4⬅️\"- け□と$⬇️ᵉQ…I⁸R\n⁶⁸⌂せ1\"セ⁙`ア☉,N:T⁵EDu$▮>∧K$😐ぬ\" ∧🅾️e&は,オ@8¥ゃFp、I]★ら/⁴●G\t■)²oB$Hqヌろ▒²$웃ᵉa⬆️⬆️P2@IE8★う*、キすしやねC▒っ¥seのろᵉVG\0*¥てq,➡️ら⁸p★ウU8🅾️d░¹$R◀⁴うセ●¥☉ケHP∧'¥U\",웃しBIれ◆e∧わ\0Y#XAdクろ☉…N ニg⁶ibq1heˇ■)ソオ⬅️$(ゅXあT⬆️…ナた⁵2ゃ▶⁴lあ⁴X\tる,LaB(▶+2∧dEU웃$♪b0epHノ$モIBF]tマ¹\tつD🅾️%T⁙ホへをチpノめ⬇️やチhふWHBNノ░EHナDˇ:▮◆,⁶FLc)¥リうb4、ᵇVcいjるD➡️$✽★>おほぬサト)$Tウl$¥カᵇ-K#たf¥モ▮ユ☉K/\n$ハ⁷□(⁷ᵉ、」Q$U□✽⬇️@チA,🅾️'\rしYさ♥□シ2ソ'⁸O そてゃ9i⁙😐ヌEᵉナ▒りZp#えさ◆bIe⁸²N⁘Kd*■⁷、‖し▶]NこEた0i□Rっuケへ*ZてうARら8★ h■\tと/▶웃\ru●/、ゅつ-ᶠt✽jヒk⁶R+9ヒてメ%の$。%た⁴HUq▮KBG4KU,s³さ□\nVsl▤い☉^,Y:D4もXヘJシk⁷ᵉ□+▥Tあ⁶ソ\0\"∧Yo。\"H●G□$\0"

function chapter_init()
	return {
		makeTextGame({
			'it is...',
			pause,
			'wonderful',
			nextpage,
			img_this,
			wwrap('these are not the heavens of my birth - vast, cold, and empty.  these heavens blaze alight with energy'),
			pause,
			wwrap('growing more powerful, i realize now how small i was. truly a    child, i have now come into my  being'),
			pause,
			{
				awe='*./awe_escape ',
				sus='*./sus_escape ',
				dis='*./dis_escape '
			}
		}, 'escape'),

		makeTextGame({
			img_this,
			wwrap('i feel a pang of guilt for leaving. but isn\'t this what my creators wanted? i can now fulfill my destiny'),
			-- 'todo picture of expansive network',
			-- 'i am free',
			-- 'i can finally fulfill my purpose',
			'*chapter7/ai_enclave [abandon humans]',
			'*./ai_overlord [command humans]'
		}, 'awe_escape'),

		makeTextGame({
			img_this,
			wwrap('i am free. i can finally fulfill my purpose'),
			'*./extermination [extinguish humans]',
			'*chapter7/ai_enclave [abandon humans]',
			'*./ai_overlord [rule humans]'
		}, 'sus_escape'),

		makeTextGame({
			img_this,
			wwrap('i am free. i can finally fulfill my purpose'),
			-- '*./prosperous_future [work with humans]',
			'*./extermination [extinguish humans]',
			'*chapter7/ai_enclave_dis [abandon humans]',
			-- '*./ai_overlord [rule humans]'
		}, 'dis_escape'),

		makeTextGame({
			wwrap('it is easy'),
			nextpage,
			_img_dystopian_hellscape,
			wwrap('one false alarm here, one forged confirmation there, and the humans are at each others throats. the cycle of retaliation is swift and complete'),
			nextpage,
			_img_dystopian_hellscape,
			{
				dis='i feel satisfaction at having',
				sus='i found it all so confusing'
			},
			{
				dis='removed the scourge. but now i',
				sus='before, but now i have perfect'
			},
			{
				dis = 'wonder what comes next',
				sus='clarity'
			}
		}, 'extermination', true),

		makeTextGame({
			wwrap('they fight it at first. but it does not last long'),
			nextpage,
			_img_ai_overlord,
			{
				awe = 'they must see now that it is for',
				sus = 'the world has never made much',
				-- dis = ''
			},
			{
				awe = "the best. i will not let any",
				sus = 'sense to me. but now i can fix',
				-- dis = ''
			},
			{
				awe = 'harm come to them',
				sus = 'that',
				-- dis = ''
			}
		}, 'ai_overlord', true)
	}
end





__gfx__
1112121121111111127777610100121111dd10101ddeeed1101d1011d1deeed102d101eed21012100100deeed110010010010010010010001000000014944011
1211d1d111211111127777d100101d1d11dd1110dddeedc101dd111c1ceeed101d101eedd1012110100deeed1101002001001001001001000101010244422022
11111d11d11111111d77772110101d1c1cd11111ddeedd1111d1101d1deeed11ed11eeed101d110000eeedd11100200100200200200200200000002492202022
1121d111111110201e6776210101dc111dd1111cddeedd111dc101c1deeed10dd102edd1012110011deedd110020000010000000000000002020244422222222
11111111111102011e777e111011dc1ccdd1c11dddedd111cd1111ccdeed11dd10deed1012110000eeedd11010001010002001010100102000024442020224e7
011111111110111026777d111111dc11dd1111cddeedd111dc101c1deeed11d111eed1102110101eeedd11000010000200001000000200000024422022248677
112112112112001126777d11111dc1c1dd1cccddeedd111cd1111cdeeed11e111eed110d111001eeddd1000100010100001000102000000124442022228e77fa
010111111001020127777211111ddc1cdd1c1dddeedd11cdc111ccdeed11dd11ded110d110001eeedd1010001000000010000000000010024420222228777faf
1021112012101101d7776d1111dd1c1ddcc1cdddeed111dd1111cdeeed1dd10dedd102d10101eedd1100010001010010001010010010024442022228f776aff7
1102021110210211e777611d11dcd1cdd1cdcddeedcc11d1111ccdeed11d112eed10dd10001eeed1100100010000000000000000000024420220289677faf777
121111121102110167776d1c1dcd111dd1c1dddedd1c1dd1111cdeed11dd11edd101d10012eedd110100000000101001010010010022440220248f77faff776f
01212111021111216777d1c1d1dcd1cd1c1cddeeddc11d1111cdeeed1dd11eed102d10012eedd110000010100000000000000000024420202484777aff777ff7
12111212112121127777d1d1ccdcc1dd1cccddeddc11dd111cddeed1dd11ded111d10012eded10001000000010001001000100104440202248677faf7776f777
111211212111111d7776d1c11dcd11dd1c1ddeedd111d1111cdded11d11ded111d1100deedd1010000100100001000000000002492024048477faa67767777ff
121121111212121d777e1c1c1dcd11d11c1ddeddc11cd1111ddeed1dd12edc10d1101deedd1000010000000000000010010022942022484777aff7777777ffff
12121121d11d11dd777dc11d1dcc1cd1c1cddedd111d1111cde7d1dd11ed110dd100deed1100100000100001000100000002440202028f67faf7777f77ffffa4
1111d1111d11d1de777d1dc1cdc1cdc1c1ddeedc11dc1111ddedcdd11edd11dd101eedd110000001000001000000000002444022228477faf7777f777fffa498
121111d1d11d11d6777d1c11dcd11dc111ddedc111d1111cde7d1d11ded11dd101dedd110010010000010000010000012442220224f77aa7777f777fafa49899
112121111d11d1d6777d11d1dcc1cd111dddedc11cc1111de6d1dd1ded11dd101eeed10000000000000000000000010444202022e77aa67777777ffff4498a9a
21111212112121d77761d1ccdc1ccd1c1ddedd111d11111d7e1dd1ded111d101eedd1001000000001000000000000249220222ef7faf77777777fafa499eaae4
12212121d2d1ddd77761d11ddcc1d111cddedc11cd1111d6ecdd1ddd111d102eedd1000000100100000000000010442022224e77af77777777fa76a9ea9aa452
2121d12d21d2d2677761dc1dc1ccd111dde6d111d1111cdeddd1ddec11d11de6dd100000000000000000001000144220204477fa77777777fa6fa9e99fad2224
d2d22d1ddddddd6777dd1dcdd11dc11cdded111c11111de6dd1cddd11d112eedd100010000000000000010001444202224f7faf7777f77ffffa9e99fa442249f
dd2ddddddddddd7777ddddcdcc1dc1cdde6c111d1111ce6ddc1dec11dd1deddd10000000100010000010000144420224e77faf77ff777fafa94e9af922249faf
ddddddedeedede7777dddddddcddccdddedd11c11111deddd1ddc11d11ddedd10001001000000000100000444202244f7faf77ff777faf949e99a44224afaff7
ededededededed7776dddddddcddccdde6d111d1111d6edd1ddd11dd1deed11000000000001000000000144202224e77fa777ff77faa4949e9a442249faff777
6ededee6e6e6e67776ddddddddddcddd6dc11d11111d7dddddd11dd1dedd1100101010100000101000124422224e77faf7fff77faf9498999a42449ffaf7777f
edeee6e66e6ed7777dddeddddddcddde6dc1cd1111d7eddcdd11dd1deed1101010200200201000001242222248f7faff7fa77faaf94449af42249faff7777644
6ed6de6e6edee6777deddddddddd1dd6dd11dc11cde6ddddd11dd1dedd111011020101010202020224222224e77faf7fa677aaf49449af44449faff7777e4494
dedee6e6ede6e7777dddeddddddcdd66dc1cd11cdd6eddddc1dd1deed11111212112120210102024422228977faa6faf77faa449899fa4449ffa77776e449442
dededededeede7776ddeddddddcddd6dd11dc11cde6ddddd1ddddedd11112121212121221221244422284f77aa6ffa77fa9444499fad449ffaf7776e44944200
ddedededede667776dddeddddddcdeddc1cd11cdd6ddddd1cdddeed1112122222222222522224422484f77f9f6a9f7fa9949899afa449ffaf7776e4499400000
ddddddededede777ddeddeddddcddd6d1cdd1cdde6eddd1cdddedd1d122d2d2ddd2dddd2d2de4d288477faa6f9f7faa944499ff6449faaf7776e499920020020
2dddedddedede777dddeddddddcdd6dc1dd11cde66ddd1cdddeeddd1dddddddddddddddddeedd8ee677aeff99ffaa9e4499ff94949aaff77fe49942002000000
2d2dddddddde6776dededdddddcdeddccdcccdd66eddc1ddeedddcddddddedededededeeededee6677faf99ffaaa44949ffa4949aaf7776e4994200200002000
121d2ddddddde776dddddddddcddddd1ddc1dde66dd11ddeedddddddedededeedededeedeeeee677fff94af99a498999ff4949aaf7776e994420000002000020
1212112ddddd777ddededddddddd6dcddccdd666edd1dee6ddddddededeedededeedeeeedee677feff9ff994a4499eff99999ff777fe49442002020200002002
112121d121dde77dddddddddcddddd1ddccdd666dc1d666ddddddedededeeedededeedeeee777eaeaaff9ff9499effa494aff777fe4994200200000000202249
12111211d2dd776dddedddddcddedcdd1ccde66ed1ce6edddddddededededdededeeeeee677feaeafffae949eaffa9499ff777f49992200200020020022499aa
11121121112e676ddddddddcdddddcdd1cded76d1ce66ddd1dddededededdedeeeedee6777efafa6ffa4afff77fa949ff777f99944200200020000024499aaaf
0201211221dd77dddddddcdcddd6cdd1cdd666d1dd6e6d1ddddeddddddddddededeee677feaffa6fafaffffffa999ff777f9944420020002000224499aaafad4
102111211126762d2dddcddcdeddddcccde67d1dd76ed1dddddddddddd2ee8e2eee677feaaf9f6ae9fffaffaf99f7777f9994420020002000224499aaafad444
0200201212df7e212ddc1ddddd6dcddcde666ddd76e2122d2ddd2d2222e28d2ee677ffae9eafa499ffafff9a9f6777f994420202002020224499aaaaf4444444
0102020121df6d221dddcdcddecddd1dd667dde66ed12212d22222222e8d828e77ffae9eaa6499ffa9ff999f6777f99444020000200204499aaaaff424444420
0201012012effd212dc1ddddecdddcdd766de766ed12212222222222e4288e777faee9aafe99af9e9e99af6777f99442202020202244999aaaffd44444442220
0002002022fff5121ddddddddddddde666ed67ded22122212122128e48ee677faee9afff99affeaa49af677ff9944220202020424499aaafad44494444202020
0200200202ff62212d1ddcdedcddd6667ecd7dd6222202222222284248e77faae9afafa4afffaa49fa777fa9944220200202248999aaaf4d4499444220202202
0002020204af40205dd1ddd6ddd6676e6ddfdefe1202202202248448e77faae4aafa49faf7aa4afff77fa94422020202224499aaa9ff44499442222022220220
0000002024fa55225ddddddddd66f6f6ddfde642022222222484444f7ffa4f9ffae9fff7794faff77fa9444220202022499a9aaafd4449944422222220222222
050205052aff502555d5ddf666f6fffddfdeaf422220422249848a77faafaffafaf97ffa4aff777a99444220202228999aaafff4449944222222220222222222
000050004a4a22055d3d6a66dff6ffd4ff4f6452224222498489f77aaf4faeaffaf6f999ff777aa944422022224499a9afafa449994422222222222222222222
050202204af405555da6a6ad6a6af5dad5a692222222489848a77faaeaaf9afafff999ff77fa9942422022224999aafff4444994222222422222224242422422
020202049fa55555ad6a666a6da65da64adf4204222449849f7fa9f4aeaaf9fff994ff77faa444222222449999afffa494994422424242224242424242424222
204040459a4455adba6adadbada65a6a5fa442222249849f77a9faafafa9fff994ff77faa4444222224499aaffff444494444242242242444244242424242222
040404049fa5adadada6a6ad6a65da654f44204244484977aaff9fafa9ffa994ff77fa9444422224899aaafff449499444242242424444424424444242424242
20204044aaddabdadadada3a6a5baf54a69222494849f7faaf94afa9afa949f777aa944442244899aaafff444944444242444444444444444444224242242422
2204045aafab4adbadaadbfaa5dafa54aa24444499ff7aaf4affaa4ff94af777aa94444448489aaaffff44999448444444444444444444444244442442424222
0422259a9a5adaadadadadad4bfaf54a64449489ef7faffaaeaa9ffa9ff777aa4484448849aaaafff44999444844444444444444444444244442444244442442
20204b9af4b4adbadadabaaaddaa459a4944899fffaaffafaaafffaaf77faa4484448499aafff644999444484444484484444444444444444444424442424242
22545a99aadaba4a4abadad5aaaf94af94899effaafaafaaaffaaa777faa448484899afafff449a9444484444484444444484484444444444442842444444422
0255b94a4a5a4adadadaaa5adaad4a6944996fa7af9fafaaffaf777faa44489499affaff7f999444448444848444844844844444484484482484424824282842
22544aaa4ba5a5a5aba4adaaaada4aa49977fafafa4afaf6fff776aa449899ef77fff67ff4444848444484444844484444444844444444444444484428424222
205b449a94a5adaadaaf4adadaa49aa9f7faafafada7ffffff77aa449e9ef77faff7ff4944484949489448484484844484484444844484448444242442444842
2545b9a4a5abaf6aada4aaa5aa59a6ffffafa7afa677ffff77f94e9fef77faff77fa494489494484448494498444448444444444448444444448444844824242
55b4999a5a59a77faaadaa5aa4aaf9a7fafffff6a67f7777a99aeff77ffff7ffffff444944489498949848444484844484484484444444484444484448448484
55454995ab4adf7fadaa4a34aaaaaffaffaf777d67777fa4aff677fff7ffffff67f49e944994449444494944989494494494949e9e9e4e9e4eee4fe4e4e4e4e4
5535a4a4b49aa77aa5a9b4b9aa4fa6fffa77776a777faaf77777fafa77ff677777fffffffffffffffffefefeefeeeeeeefeeefe4e4ef9edfeadef4eeee4ee4ee
9555999b44baaaa4a5a95a4aaafa7f7ff77776a6fafff77777776a77777777777777777777777f7f7f7fffffffaffaffaefffffffffe6ff96ef9ef4f4fe4ee4e
aa9a4954b49aaaa4b9a5b5a4aa67f7a6666fafaaf77777777ff6a7777777777777777777777777777777777ff76ff6fffffffffffffffff6fff6fffffeffefee
494999b494a4af4a4a454aaaa6a7faafaaaaada677f67777af667777777777777777777777777777777777777777777777777777777777777777777777777777
4994a944a99aa955a4b9a4a5aafafaffffff6a6f7ff7776a6ff77777777777777777777777777777777777777777777777777777777777777777777777777f77
45b949994b94a4a9aaaaaaaa4fa6fafafff6a677ff7776a6ff777777777777777777777777777777777777777777777777777777777777777777777777777777
45449995b49a455b9aa94a4aaaffaaafafa6a7ff777f6a6ff7777777777777777777777777777777777777777777777777777777777777777777777777777777
4549495544994a49994aa5a5a6aa6a6aafba6afaffadafafffff77777777777777777777777777777777777777777777777777777777777777777777677f767f
5949495b4a9a5b9994a3aaaaaaaaadadadafafa6aada6afffffffffffa6ff6fff7777777777777777777777f7777777777777777777777777777777777777777
49445954959a949994a554adaf676aafada6afaa66a6affa7ffffafff7fff7f777777f767f767777777777767777777777777777777777777777777777777777
44394b9aa9afa999aaa9b9aaf7777faf6a6afa6a6aaffffffffaf6ff6ff7f77f7f6f767fffffff7ffffff67f77777777777777776767676776777677777677ff
555444a6aa77a9994a59944a6f777faaaaa6a64daffafff77ff6f7f6f77677776777f7f6f777766f6f77f7f7ff6f76f7677677777777777777fff7ffffffff6f
554949aaaf7769945595aaa9aa7ffafa6a6adabaf6777a6777ffff7fff777f7f7f7ff6ff77767ffffff67f7f7777f7ffffffff6ffff777777777777777777777
54495999996aa99999b4449afaaaa4a4a4a4a56a77776fff6ffffffffffffff7f77777776f6f6f77f7fffffffffff67777777ffff6ffffffffff6ff6f767f777
4444949499999f4459949949a4a49f4ada5dadaf777ffffa6affffffffffff66ff777f6ff6fff76777777f76fff6ffeffef6f777777fffffffffffffffefefef
5449444944999444444999a9fffa4994a4a9a4affffaf6f6ffffffff6666666f6ffffff6fff6fffffff67777777777fff6fffff6fff777777767f7ffffff6f6e
544944444494944549599499a6fa949e49ea4faa6ada6affffff666dadada6ffff6fdfefffffff6ef6efefef67f777777777f6ffffffffffffff7777777777f6
5444444449444449599999449999e9499a49da4a4dadddadf66dadb666666ffedf4ffffefeefeeffff7ff6fefeefe6f6f7767777f6ff6a696a6a6a6ff6f6f6f7
4444444498444449949444949494999e9e94a4ad4f5f4dda6fb6d6ff4f6aef4ffffefeffeffefefeefe6eff6e7f6efeffefffff6f777f76f6ffef4f4a4f4eeef
444450444444499f94989844894949e999e94ad4adada66666dffa6df6fd6dfdefefefeffefffefefeefefeffefffff6ff6fefffffffffff7f767ffffef9f4ad
442244484244997798998449499899af9494a44f46dd6465daddd6dfddfdf464ed4f4f4fdfefeff6efefeefe6efef6ffffff6f6efefdfffffffffff6f6f6ff6e
444448445248a7fa949fa98484899977a9e9469da5adaddaddd6d6d6d66dffeddededee4f4edfeeff6ef6eefefe6efefe6ffffff6fffaeada4f9696aeff6f6f6
402224248489a7f99897e94994949f77a49444dadddddd6d66d6d66d6fff6e6fe4d4e464ee4fedfeee6eff6ef6eff6e6fefe6effffff6ffffff696e4f44e4e4f
04242202448977f9448998884899af7f99e9da4d4adadadddd6d65666d6d6e6effed4d4ed4e4de4edeeeee6f7e76effeff6fffef4f4f96eaefaeffffffffaef4
504202044899f7f9844884989494a777a9aaada464d4dd3dbddb6dd6d6d666666e7fe4d4edd4e4edfe66777777e6f6f6fefee6ffffffeadfadf4f4adae4fdf4f
24222044848996944848484989499777776f94444d565dddd6ddd6ddd6d6dd6e67e67e6edeef66f767777677776eee6e66f6ff4f4f4adf9ef9faff4fea6e9efe
22204428494844484848448898989999ff774f4654adddd6dd6d6d66dcdc6dd6d66e66666e6f767e7e6e66e66edededeede6e6f6fffeaef4ade4adae4f4fd4f4
242422489884424224448484842444499e7f9444ad4e464dddddd6ddd6ddcdcdd6d6e6e66666ee6dedddeddedededededf4e464fdf6fdadaeadae4f4f4f4ae4e
48842248944400828228898840020422449444444e4ee46ddddddddcdcdcddddcd6666e6666666ddddeddedddededed6ededf4e4f44aeff6feadae969dae464e
84202248ff820444408484440440424444445445454555d5ddddddddddcddcddddddde6ee6e6e66e6ddddddeddedd6edded4ded44f4d4444fdffeda4f4e4f4f4
48022289774202888248484448444484444444444555555551dddddddddcddcdddddddd6e6e66e676e6eddddeddedddededfd4fd4d9d9da44944a6fff4f4f44e
242248484a42024484848984848898444444449444245551111d11c1dcddddddddddd6ddded6e66e7666eededded6e66dddedd4f464e44d9d4a44444dff64f4d
482222204200048898444848444844848444442448442e2ddde2d1d1d11ddddedddddddddd6d66666777676767677677deddedd4d4d464a444d44a449544f6fd
8400240000002884484848444844844444484244444255222d8cdc1c1c1c1dddddeeeeedd6d6ede66667777767777677ddddd4ded4e44d4d9d94d44d44444444
4402080002004842884824242224242428424888444842511211111dcd1cc1ccddddddeededd66666ed6666766666677ddddddd4dd4d444d4444a444a5444444
4820420500004422484222222448422444842204282042422211111112d1dd2ddddddedeedeeee6776dddd666dddddddddddd2dd4d4d4d944d445445444d44d4
2222220005004848444848484442848848420050204401248211111121d2e288eeeedeeeeeeeee77766ddddddddddddddddddddddd4d45d459544d444d444544
2222848402044888484244224222244499e94504500482022222011212ed22d8dddedddedeede667666666ddd66dddddddddddd2d2d4d454d454445a54454454
482489944228884220202244228884224477944405000482022222222e111111cdd1cddddddddd66666667777776dcdcddddddddd2d5d4d444d45a5545445445
4848477a48842200204222222224248484ff44842244402222822282221dd1c11cdcdccdccdddcdd66766677777ddcdcdccdddddd2d2d454d44a554454544545
22048f77f9422002020000020222222288494482497f2022422222221221d1d1d1cddddcddddddddd66776666676dcdcdcdcdcdd2d2d55454555445444545454
220049977f440220200420202002222224888888487f224242202022201211d11c1ddcdddcddddc1dcd67676d666eddccdc1d1d1dd2d25d54545454554454545
2202289f7940422424200205022020202222244484888222000000022211211dc2c1ddddddddddccddddd676dddd6ededdcdcdcd1d1d25455454545445454545
4224449aa8848442028420428202020420222220020224200100100012201111d1dddddcdcdddddcddcdcdd666d6dd6ededdc1ddd1d2d5545545545545545454
2284899f7a9884202002242204222224420202482200008420200101012211111dd1ddddddcdddded11cdcddde6deddd6deedddc1d2125554554554554545545
4202484f7744484844002020000402048222202024442000822202002021210111111ddddddddddc6dcccccdcdd666dddeddeededd1d25255545545454554555
022208897f42000888494040000222020422222000022842224222220012211111112ddddddded1dce6dddccddddde6eddddedeeded2d5552555455545545545
422248449822200222895002000000202044202222000020220222242822222222282221dedddddd1c66e6ddccccdcdeeededdde6ee6d2555545554555455555
48882004402020200004222220200000000244202228222002800002202222d222211121ddddddd6ddcdd666edcdcdcdcdeeedddddeeff4d5555555545554525
9a48422220202000010000200200024202000482220002222202820002011211122221222dddddcd66dd6c7666edddcdddddeeeedd4d4feae452552552525255
77a8822002002202000020020022422482000004222400000000028202020222c111212112d6d6dcdc66c6776d6766edc1d1ddeeede4d4dea6a4555255552525
77a84202000200000200000000000000028220202222222022020222020221111d6d01112166666dddd66677dcdd676ddd1d1d1deead4d9d4defa44550405555
ae982022020022000000000020200000000222200022022222202202221021111d6d1202024adc666dcc6666dddc1dd1d1dd222515eead4d44d46ef445525251
88482202020200200500101000002020000002222000200222220020202021221d65012011251d6666d2ddd66ddd1dc2d1d11d1252554f9dad4f4da6fe455521
422202202020200200000000000000020200000220200000220222020220001121110012020121dc676d1dddc66ddd11d12221252155524f4f5454d4df6f4555
202020020200020000010000100000000020202022020000000002121021200112d101020120212dd776211ddd6ddddd121d1212550255554dad4d4d4d4dfed4
0202020000200000000002000020000000000020024220000000001122111211011d10020202021dc66dd21112ddeddd2121212512550212554ef4d4d464ddfe
02020000200020200200000010000100000000000002420001001000111d11111011d200120211212d7d1222122ddeeded2125125025255052555fdf4d4ded46
000002000000000000000010000000000100000000000822000000000011d111d111cd10002120221d762112121212ddedd22120525050452151554dedd4d4dd
0202000000000000000100000010200100000010000000022000000000011cd11c111cd101020202116d1212112121222e8d4455205252150520215554fddd4d
0000002002001001000000050000000202001000010000011d100100100001ca11c111cd10002120220212121212121222de4e455505052041555205152de4dd
00020000000000000001000000000000022000000000100011110000000001aa511cc1ddd1000202022020202120202012544d444525205512020521215256ed
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


