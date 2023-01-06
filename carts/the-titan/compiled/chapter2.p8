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

-- 6278

-- 4257

-- 5091

_img_lab_coat = "◝◝ヲ○◝◝♥トおのzや。🅾️t▒?ろJ\0\0Oカ⁘phウノ³む-゜♪ᵉ\0█y웃²マ▮♥▮@Ad웃りエ⁸♪⁵い(あ@」Fこ➡️\\うオuDマ\n\\ナ]◀H🅾️&ホ:HGh\"0YQ♥□6みっか웃まTせ▶⧗eうウ!D∧セD∧A⁷◀ウ⁙🅾️ノ…⬅️イˇネのぬW0'eユは░りアさへ\\∧DマC⬆️オうXD░JuQb-\0sケあPへHつエ\\とミ:░ヒ{'す$N□e✽░タiQ⁷.$█りl/ヒ^けくI9D█웃9I▮たVX░□E\\ふ•ろ…gへっ6⁸s\\⬇️m」'し…q⁴オ)▮.8◀ᵉ\t□I•⧗%r6⌂2たuち░ニa$^⁵🅾️ツ♪0█XCh□d🅾️ヲたRさI、き4G◀BNHTねヲ😐uHq2Pてぬeるセ⁸アモ⁸は❎[$★イ)\n⁘PoR\"2NNgたd❎&せ‖お◀ツq@Xネ\nコ4Nᵉとけ\0た8へD@░ぬミC♥\t□q$▒⁙F^、みサろソ]ᶜI('ᵇら,ウ-ニ0Iz🐱ヘ。ゃる\"I⁙▥😐ぬX웃\"&ˇそq$ᶜリ▤たQ!ろヌn7、ᵉチ\0I⬅️웃ウきむラサ▮は$ゃU➡️VA$d‖$Nせ⁴ゃ…^%pヒケしテョエセ⁘ま⁘Riy<ˇひ⁙@♥8、▒I2▮sウね9▥ト2、@w=➡️-^Kf²1ろ…くきpI'Tケy」て❎え\nヌ$vn⁴ぬキ78⁙Dメあeキ∧q*Eoうゃれ9の⁸8たpT🐱み⁘テR 🐱pヌUへき🐱、\\uさフ⬆️S8シ☉P⧗DN5p🐱⁘Bヘコハ😐XlUせう*G■$★ひひ`❎웃`ス$=Bkき、=iZヨイnql▮ぬI8\rすIしふ…HっJ▶웃、~▮オ░i●「pあユGAヲoりなヒへソまほ!<I!オチ ぬぬ'rIイキ゜█ねR(➡️fuxp…つ」まヨう1🅾️ZI\t%yG゜🐱ょ…jおき,ニdシRiR‖]ᵉmもHヌᵉᶠ'/ワの4qヲ;ヤ⧗Mロュ%うせ⬆️ レ*け█!▮チT🅾️ᵉさ],⌂ˇキI⁴たᵉ?{\"'1bIウ⌂Tひ웃Jqヘ●コぬ,Jうアゃ■\r#ˇq`あら웃IうミG⧗웃8え8Hか◆)🅾️yあ'ᵉ=9rキql^aアカセ²{オH&く◀、8n%こqY$qyうqds●Cエ⁸を8らミNx□BQ□アᵉ$p▒っ³゛けcせ■u5あO、リゅTケチれ🅾️ルj⁘ゃ⁶h⧗かHD웃#◆Hゃア^きq:▤❎░➡️ミ⬅️くキウrqろj⬅️*きキqC♥uり`のm⧗な!さ➡️チ*Uく▮░っい웃²るr🅾️Uまモフ➡️cᵇ³yムいJねPNへ▒eTサし░I⁵\"\"っ\t$\0X7\t⁴Wん;めろコ▮🐱っニ●*ゃこUケsイq%✽Dょ⁙8ノMU░¹@░◀X⁘I➡️]&みw\n⁵█ラZ➡️x\"K,あ,ヒ!⁘I]w□TY\"★す☉れ-うし🅾️nチZヌi+kqg⁶し⬆️ョハDEっ😐Dヌ▒まA2³J☉ろH!\"\\たん⁴²⬆️ヒヨo□ゃzH&★%つ*iきゃ」るノ⬇️▤\t#えeHsilB$⧗ひ…$…⁴░う■ケサキ!★ユ😐W¥イ⁸★%,ん¥\"uRHちq¥あ4フ8キqqyらpD⁸L、r\0~◀kまウ4웃,★Ig◀、Rの⁸\")⁸`🐱Tキ░⬅️`➡️◀♪BhろB-@¥IクユD/」を❎♪Q$ウのるrヒA、ᵇ⁴モqc@…Dあらᵉぬ,Iカ⁴ヌ…,░0i9ウPちうJもき⬅️ま🅾️タ$●HH⬇️⌂、p$…³イ\"NPI!ッ□Gうちrp∧Oをヨしq8ナ🐱*⁴★\n✽フもけhぬ☉ᶜDナ/⁴8きHHH\"⁸➡️\t⁵☉ニbBこロ8せ\\~ᵇわ…ᵉ⧗Z\0J■ろH\"…*!lHqME★\tハs\t¹★ッニ░チA,ほ⌂8N\r#❎6aチ、わ8✽♪`E#⁷0☉ょ$⁷pvフI$R❎▥Vレ IᵉクIゅt▥g@Fゅ∧□l#웃,マ[dYZ2こつ$のさへハ…JETそヌcIゃ❎こめけ$qチみEW!3●🐱XI□そのT、8たゃね`⁸웃+✽➡️ア🅾️E\"み◆8ふ6⬆️ニフ▶(Kねろ\tf░YろFAゅつ0Z_aれIきXちLᶠれX∧\"^▶sg-b☉れ░\t■□bEね。セ\"pキ?\tえ\rdC▥⁸1'うろ⧗せモUUエらむl•웃⁵」⁴l⬇️¹■と.☉フm%ˇlA%へ…;%$★し#ケ❎た.つひM[F%%なサRCq!ᵉ%l❎♪b♪8」\"そLつ\"こ8D0Cょt★s9ニエ+yニ\"9くく[X☉うま]りりf/ゃ\tは♥S`ᵉi⁘-⧗N、HEBtネあrミ🐱セ⁸3♥C⁸🐱ンtゃ,ˇdへG&EKᶠわnチI⁵K!ツ웃■■らぬニmく4'J░、😐]すKのXオッゃ□&けLV웃■\"♪…BアニVB\"ソ#▥ん□D⬅️#●ノタˇょ…K$あま∧g⁷は♥◀ナDコ\"█ˇチう░ˇニ[sり.^8ˇ!%¥るn¥ょ4⁸ニ▮★ケふれセれや…ネ□\tケ\0w⁴F¹>…フ∧H&Iゅ⁴ゅ□rpG\0れ⌂nD▥ん□⁙Cや\tゅ░D♥L☉웃■³せっrヌr$、$IkへDつ+な,█ろの ▤▥ろ9♥Rヘ☉@8DSsRH❎░ホな♥❎い◀R'1g¥$ヘ➡️らN%わs⬅️>てあケRᵉbc☉\tりシ1て웃%うとニ\\こ\tJ░□f ⁸CのっCY$キく%IKキNjむい♪yめまりLそC□K;ゃ⁷³▶あち⬅️a<XNYGP✽…た:🐱\"こか`ニ□⁸웃◀9@dNs$ュ$も;う、N□$1x ☉H▶ひBq\"Nナたg⁙う░★キき…8#∧Cい8%⁘░█G、W⁴つqとニv\n★J#Hぬむ🅾️🐱Mる¹n★M▒HIP8はめ.や,ろむはお1わK⁙‖jとR&か`メらやLゅ☉キ²ノ/p웃$マ9★tdュMイeもiXも□$Rタん▶Aナ⁴◀¥るHヌネ8■、ス⁴ハ。⁸☉∧*ノqけᵇ-ヒ¥□\".ヒたl□0レ⬆️もbキっR,░な(hf2そこひ⁴ぬ@I…!\\みあB❎🅾️(i♪し★QUj#🐱ゃナハ8ミとナD\nネお8ヌ%ネ♥\0サゅ}¥MイS3>ネ🅾️しXヒセアぬもU[8🅾️*$ナ(⁸^て🅾️gヌか⌂Tql,…BK•な³■⬅️⁴웃+ᵉ⁴‖をi:⧗pそ🅾️ン★6ぬ\\Cあ、うb□░⁙あ~Q。bた%²²😐★\",▒ゅ▮I■□るもタa0🐱dをきM⌂ュhたxそねVAれ~T□🐱き🐱1(さI゜N⁘⬆️くケヘ⬆️Jイまうまp★2\0Mし*`U(ナ▮ナひゅ$そBAQ94D'BC▮Q(よ🅾️れEフ▤█¹a%エすRレa*ラナなをN IンFmW」、⁸う¹`る▮★っ{アEほ🅾️dナ⬅️p!x²phヌᵉ$H|$ら$▮ᵇ\\◀hら'⁸K²▮あq\"B|█Y\te⁴(▤I$tˇ\t▒\\,ちUI\n웃スュf³♪オ★ユっにM☉█░🐱lPネしニ'%ᵉ²0e❎😐F(7Rせ$ミお‖\"▶L◆L9の\"■ろ³D☉わY⁙▶-ろふ▤sᶜ0¹ 2Aノ◀ソの8'■qy+■□ワ)8F➡️Bヨ⁙ホ⁸/▮こ⌂さ▥をふ%`…`し▥ウめhそ⬅️ᵇチな%す🅾️+▤➡️ ね,ゃP。I⁘4⁸ヌs□るYイ2^」-ク²\n⁵るm4웃웃¹く9@せV8A\"@웃りけ□!て'!²っ_o\t,ヒDも[れ☉ 「⁷[✽Yた⁸♥」⁙そゅ9な3➡️\tHナ…K□⁙D⧗✽■アヒゃf‖B⁸CQ★\n\tk♥%ハQ❎░$▮▒▮qキKらさクkN⌂う%キ▮🅾️RKPᵉp「83pそは▤⁷*░4Di:⁴Kケヘ$くっuちて0ヒ😐$Tˇ❎➡️\n*□ウd8ュg(²E★ユ∧ホ,Dオm$,ね'BRJフ⬇️●へBムqろさ⬆️'*レメへろ…Hふアけて`∧き゜PヒI ⁵░➡️キU□ケp웃るDDA8⁘➡️eMヤ❎いツ⬅️•Gウ4🐱リx、タd☉ヒDS▒\\C웃 ス▮ᶠ:えu⬆️N\r:●□¥5rニん3コてリ⬇️9hフ'²み…ふ\r「웃Hち█ろ░うるらあ‖PF★わ🅾️‖jBH²Iのᵇ8ノ…]ゃはユとチんネりり*⁸⁵qょヘぬ 、ょ⁵れ⁙웃、ら,‖rめそ🅾️:I&えU∧Br★っ✽マレpI⁙#,ayˇイなチ6+つlオラ♥dˇ⁸j🐱nHニ$🅾️Rbリᵇつ▤⁴Dせ\tVロ⁙い★\nの□I0⌂➡️`なヒャ•]*□□\np∧Cゃ)□KU4、X░ね/、まEメ⁸ヌさ。さヌ!,ろˇイ❎HKムヌBコ░ˇH\"ノH`ふgR%8r웃!H█★%⬅️w、 E🅾️ゅil░⬆️웃r⬅️i\"わ☉メ⁴,,7H∧□'ハ;eカ,★ゃ…☉▮rウ◀K■★dI」しむ◆のけょ◀ら*せ■‖j モe█Jのq⁸▥る…[!さぬヒさYヲさく8!りc は◀しも\0✽Z¥ᵉe⬅️웃eら⧗そキ🅾️\"H█、(CJ…ヌら✽YろBZ'、$❎9コ\"われな、p8ˇGqV⧗🅾️け$T。▮BZ'\0K▮\t8#░UIQ*²8🅾️⁘Bタ\tしカ\r!ろ/ J★Gヌ)コ☉゛のI5つb¥ま⁷「\\⬆️ˇゅサハ5、ウeねR³♪g⁷Ds\\X」jN7よᶜ😐³⬆️\rPp⁴…🐱s、ミわむuaDキrFヌT⧗²ラつ'ウd☉pIらᶠま⌂そ、X∧3XI8E⬆️そ),%◀p웃*ウに$★て\rdっ/⁶r…□😐フsfカえ□D(ろ웃ろ●と…Dと,³³い/「BKd░ねp;n6◀ラ\tろ♪N@⁷■•⬅️SっソHもた&は😐つCBᵇ⁘웃K!+웃kみyW「エろqエW4ヒ>sケCや'もQ$▶$⁘エる&∧$☉X ハウノI\\] @i\"B▶▤♥、8‖⁸E⬇️なeやHあXと8れ❎ˇ1*きeえ▶wアのウ⁷ヌKひひBラそう□。ツ⁙✽、Aヲっ➡️Y…■ᵇメ⬅️'□B8チ[りれお4ク;ウeハ`⁙★ᵉみL➡️\"w⬆️⁶p\tるmし□Qれゅき♪U/ᵉ%そぬP゜に.ゃ웃dサrやっ…やH⧗FI\\ヒ K%⬆️や\"DルトEののtのに★4ふ9のYあGA¹\0、No ★&⧗🅾️.¥5なb<ひTちW■□✽q9マを/A♪8iオMろ🐱ᵉ⁴웃iU*く⬇️|あBd*ねn、ウ/w♪「く⁵アb%オsyマテkT █^,k@◀ノTp,◀Hメ∧Dヘ:マツる░れN9(░dKk8ᶜうFヒHヲオ□)%❎웃&\0웃ま∧qり⁵も)キケBオら¥ま!(n,9sj⧗⬅️Zマs&ˇ{⬆️░%ᶜᵉᵉL█Y\"ユニ\tアタあq7⁙🐱Uクp∧g\tQ¹'、EI▤⬅️4え。ヨjっ…■Q^*Iエ)&⁸%1\n¹ひ★テ!ヌホC😐uuオうCI0%ネ█R□ま_QるイソKn▥`B<sDなm…P$□ゅ▥◀w◀u、rもょ¥Dうてjケ…q\t□□わた'\\8I░Dうら:V\t웃Mbひ➡️T%⁷²🐱Hね$▮⬅️よ•Nすっ☉\"HBU4ぬG;I8\\⁶サムN☉0Yるひ⌂⁙🐱つむJは웃ᵉ!アん⁸んr4🅾️3░ナ#ˇヌ★c웃ケぬそをuSZg$ョキBNあナセR…IIゃろ1Bミ\\ユ⬇️8➡️▮★□ルrpVたさネ➡️▤ちセゅ&9웃る'■eイ⁙■き█*♥eと q Rウ,∧。5たクsT%,ゅ9し'%Hヌ-J☉ ふ、っ▮*BをBs*Eホ\"CN▮…&EちN•そ☉る!E$8∧¥[•▤ネあイ⬅️Bᵇ🅾️d(\t.²H☉ラi1.そセタs)コI%{★J…✽,Eマる^x✽?-Q▮A⁷<*S▥d\t!8iイ⁸●EY\"³pむrュ\\リ4웃ろ●➡️&ま8[WDウ□のBへpb:や$さ🅾️.:-ˇ\\せ<あゃ/.2•8う∧Bウi'ニゃ∧テ4ヒンn1,➡️d☉な6へ★D2S😐4さ[2❎qろTナY\\'ナ~<*g2kVbれ➡️ひナ◀\"わ□m7.bハ\"p9Zキ\"B%うD'<kdK▮HZゅ✽ふ4YpG\rのIぬ@qV、@$た3やaG¥□う]⌂K□#まc🅾️Y★q🅾️2まI+★AmKウしXYさコちCdb\"Ye8웃ん*ね➡️Q²pうpノNさオひqさ$るQうq$&ぬBイ%⁸、IYれちぬゆウモメR⁷\\B!ょ∧、)、ニ!★T⁙²たw、な∧レg■けわXさKVq。\tPYん!t!ハうオフpも&ヌZTそ☉こc▒$の^\"fN$²ちk)a,➡️きク░k$J⬇️shXrうを\"とKd⧗░う$➡️ラp¥ソモを%AけJ▒∧■&p웃!▮♪ふク」VI◀。Nっs‖%★ゃl⬅️hる☉ニナみ、カ4\nカ`N/、コソむT`8えつ*す★hI%pc▥ん|^キ#む∧ゅX✽K、J★+P◀H∧ろ★!█ヨKサ⬅️b8HTrrへq🅾️てめEさ●N\\ˇケi2$MまZYD゜⬆️ニ)ひク▮ケ\\しうしヒ@/」さらI7<p■▮ラ⁸[さsろ89.★てュ-H∧MBTぬIᵉ★/0ᵇ⁘\n‖はG♥•⬅️\n★★B@~s ネ⧗G□ぬ🅾️9▒,ノ▥웃は🐱Y-D▤く$9'Z\"Iイ8ヌち B%,▮マB⁶▥ねな'のユへE▤、¹‖³Iすヌカ▮Ibr]beヲフさえA8\\\\p★す∧Gハᵇアのれrも>ス∧&\0gるsエrBK.E➡️ᵇい▥Qケの!xK\"⁸はいヲ[★ Cユ●⬇️☉∧」$s\n웃dˇ!す」 웃t4I🐱vs3%ク⁶Bsdᶠ]Kん1ᵇia!ノ♪ん:Hさう*リろJウカfほgW8D.U★8⧗\tLソ\"%¥Jヌ^RpFちみ」、⁙▥⁷⁸ タ⬅️Y(%h3◀cへケh➡️$✽V、4ニEちG+る▤アキqe⁴kxハ%ョxもるセ¹」H■し☉ノIR-☉゛るr★★dせ⁘むょ⬅️$へゃし∧ 。ᵇ■ᶠp$Y⁶U$ █ねb▮のるっI■。ほ)Ir%けG⁴え4せ¹f■ウサっ…🐱@ョ、テ█ゃX⬇️た@むDキ@nd➡️ろ…さ¹ん.i10[x^tp\t\tvノよう░웃!んyみえ8Y\"★ア😐░フe□ら$ネふ+-!wIわナ▥6D#▮➡️L░rOら\0"

-- 5190

_img_computer_screens = "◝◝ヲ○◝◝♥トおッ5(も✽おq9Kqョd\\ˇ(⁴ヌヨ%░ナ⬆️█yみの.ミお、Q⁴⁙お¥ヨそ◝れ⁸:Qᵉ5え▶せRえ^5★s」2I。、ハ h。^に\tろ&I\tsれしヘ?ル¥と웃さ★█★F☉\"⁶NイRょ⬆️)4た6うk%9^9き😐Hfy5☉セ`ナ2A8の!ᵇぬ=⁙ハた\tlJKTうQ ナ🅾️Uろと∧KT⁘ヌ,😐サcKd¥ケあョ⁙⬇️\\シ#⬆️웃■マ8★e⌂モY7ナ➡️¥i‖の$のユっ\"」fN「な$ネ∧[ウ⬅️ろGAL$Z➡️➡️⁴ホイ웃◀EHカしッう\"、Mろ♥⁵☉ろVYf➡️⁵-フ)□<⁙そうゅ▮Kろ1▶uケこたアうTd▮Dた$Lナ☉W0c□ら⬅️'ᶜRc😐Jホ、\tア◀gチるさっセ゛けd□ロ4🅾️□d¥░⁸⬅️\"ソsTうワ'■□p8⬅️を➡️れI\"□(うウW█'カvもっ█▤~ᵉ\tり■‖、jか$し4よ░ハSG◀$もマ⌂★JTふ`eチャHYオタ⧗8⬆️❎K⌂🐱d☉サᵉ8のケr⧗⁸サHュもシ웃\\sアRあMbせ⁸ニ³>のす✽ᵉせ'の;A)た/.yカI\"Bコニ>0/R0ハ■「8∧ほ.7nて▒]'<ヒY{∧に、ムマ」キャねv░$た■&A⁘,H+つ、/\rう7⁸ャと+♥.)まI⁘カろ⁷BらロセTヌ「ネ^%d9フ-な:p🅾️2わ}ょ^ュ⧗⬇️ミ/8~^ヨ⁙そツtG。pNs4ミ♥、xハk⬆️Eをうりn&⬇️^メ…た'」キyツW)てたわャ¥\tトFハMmナ🅾️□えしツBK❎うM;サねRT☉Y♪p7|pう8ぬあっ]ゅ゛}す!く□IC🅾️□ケ<ˇ'z■□ っpなbシ⁴やヌ#(へラかあ8しュ$ヒクおxLq³ᵉ8けN#⬅️。p 🅾️|0pサUD、Jq、0、BYᵇ⁵、tヤお*な⬆️⧗웃%⁷@ヌ░ノヌᵉ□、aZqcのゃ$マZBqeBセ⁙8♥*ヒ`⧗…もる⁸ia⁸⌂⧗のゆ,4\\Ip★◀8!ょ░ちシDpあ❎たi;★¹e◆ マ⁵み. 🐱REョなあ」んR.G。ゃはラワuᵉアホさ➡️l⁵⬆️うB\"Eモ9WKi,\t¹‖ソ(、⁴█*ᵇヲ\\7)-か웃;サIケチうqイむょまっとさ‖T▮Jり,サrTN■⁙⬇️ょ\tw.'N⁘🐱フPキワょ▥g*ラ\rUめᵉo‖i%キ!❎★ヨみgそワほ;🅾️8Lネ!?✽⌂ヒ\t9ハ ん2ん•つ&カ8ウ²+Gは◆:⬆️.へR웃コXセ*qわ⬇️^S⬅️2シ‖웃$♥\0008うr➡️\tDf⁸ᵇセゃdあャさ😐‖ウK`。:ネ⬅️fは⌂■るu□dハとムノゅA@と□ろYら\0イ8J…I$⬅️イ8ヒ^$ᵉヲ8★LナQウA&き⧗ウイ■ヒt6ね4■なhう▮^|⌂フA⁸⁴□まな?」ふもやuん:\\もメツマを¹ま…チ¥(qト}⁶てノ、tw0Nひay□⁘HA9oゃしY9✽ゅスタ[\rさ★vLYqソ◀リトニ7。ユNx」▮ネりろミょD[れQんR😐Xくら8❎░➡️ソてハN\\G■kさ⬅️け_g6リg#⬅️;∧E★ラひ⁸>hマBpN◝ ts'!▮…)8キれNF░L$&れゆz❎rG.く\"^mや~▮たj⁸♪のG😐ヒOれ▥エ|スq5ぬロ^Vくん▶▥ょ♪アv⬆️⬆️Yo-z★eマ:ノ⧗むKをネI7'QヲWkヲ+w⁴♥<@いふ+ちもj웃9チ[□Iアユ☉FラixiシᶜッG\\たキこMsに[N4ヌc♥v=えヌめレ゜▒⁷⁴ヌC:けねゅIをヌuセV\r」んRユ9Rˇトふ:るヨy]わ-ヘほと、Mけ[c6ゃホ⬅️るわ🅾️➡️IえIrW:▶kとY8▮Nら웃コめつ8u☉ソn⁘。⁙웃∧T➡️:🅾️$ノくᵇg」h⌂H…ぬH~Dおさ■ᵉ³やゅqまょ2s|すEwれ⌂\t웃 ぬb&ニスそナカ$✽⁴⁵🅾️、Kせkノ★³,ナC8▒'\"A8ヌZH⁸し\rノ⧗9🅾️*% さrヒu⁴$Bカ7ᶠt☉★ᶜG]ん')ケra$🅾️Zn9n%■ャワ,sキセい▥I#u7Zゃ•🅾️dVnりS。p░、ま!;さ⁸ヌHWEネにゃ▮ゃ'4Mさsypう▮~=テu♪ ノケ♪\\Uニ‖っN|ヒん★ヨs¥◀HねQ …ホ」マN⁸な⁷ヌう:シ。!サ^さ☉つ\\9□•すい⌂🐱ミらP。t🅾️QfっFpホNi2さ🅾️フコgN░Xᵇ|•⁴うiホヨれ➡️gˇれ웃Bカむ\\ニ⁘░∧‖⁸W□\t☉Q¥qセ⁸▒トrw-ネつオミqケりるてWい!'h:コアG‖J░メ'SY♥=¹@ほXっネ+ユのツレjVL@フsオD▤Kゅ:●♪エWっ⁴おw{fクN⧗qわKW`▒g□sウYむと:qまゆzッツれ😐★、ホ4♥⁘⁴、ミ▤サW³K!4✽fうbエNaチ⧗i⁵¥イょ☉うタヲ∧ヨもフ&な■$R8'◀v▮8オナ☉9d24ぬᵉう$コxI$と.jう:nむNeに8ヌ6⁙웃xヲうS♥,dVさナSはF\t)\t0つや▒}`ハ❎Dも/S⬆️Kdぬtヒ¹、まなう!チ:ンま9のミyみ ☉/4ネ░□%4Dg\"Xミ5み⁘\tˇI✽ゆ/ヤ3おvY✽ヤIo2ふまうせ➡️4ヒス★てヌ:Ilた⁸A」さ%■ね‖ょ:♥ アシ🐱$チょゅbえ^=7んエクにQルMxッのき.こシ=:ネきkさn\\セt🅾️むBˇ🅾️し;ヌに\"^'◀ヨカ,Hsヲタよ「ロ¥8⁷■セイ?\tニ⧗⬇️•□y]ウ9ネp‖ろWQ ░ゅツ⁵nWクkx웃~nlハ/)G■⁴HP\"$:■ᵇ□T4C☉フゆN#''1エサく3やうYてqノ⬅️゛4>qト…😐^☉CNOと🐱⁸ナBり■ᵉ■H□⁴$も゛♥3🐱しNカ웃<ミ⬇️░Y`u-ノニ□i\"#ユI ⁶のノR、S⬆️⁸qᵇ\tBI`モモへメ*d⁙❎ᶜハシ)c♥•Iまフ★/\\L}◀っ-ユ8Iさ8ヒTD░'▒$D$,け²ゃ\rVみ'▮は⌂サqbけに²0うカモも:😐🐱⬇️5\"ヘr∧こゅ웃¹,:HL□░シすチ🅾️C/⁙ひフ웃こ²t^f#i✽ネテb¹またろg⁘\nヌけスニ⁴▮Aᵇ⁴▮⁸フラつ\\み★'J⌂❎つ+け□[ゃしヒ@~。='Qサ웃QHけ2⁸ ✽♥²웃ᵉdqdNxぬ,ツ‖し▥XチMCあ⬅️り'ネ\0⁵iˇシUむ★ヨl,ˇQヲ |\"けリカyえリアヒリJ■ろヒN□カうたNR@\tワょ\r=hし⌂∧#⁷⁴◆⧗⧗▮やうょわねりかF8&K$tヌvノKっs◀'○う\0008ヒナ★け⁸⁸?$█³ユほなあ∧さくア³¹ᶜモ<p➡️gᵇん¥Bq■{9…フEマてUの!8⁴O○ᶜ\0⁸TP🐱➡️ト\\iケ➡️、\te⧗uとN●hGM9▒?(8レむ、E8⁸\0³ラ█²:。□iク➡️⁴Xつ🐱$[!と³お9P^□qgヘ█\0シG、たさ░⁘(Hョハ[%Yん³なヒK■kナヒ▮tフ웃せ,ちhヌ⁸か➡️%/3:メDQ⁷ヲ(\0\0☉$ナつb'⁸p🅾️゛Oよ⁴IケマモみK'c8ぬヤ~█\0⁸🅾️6えPニ;ヌ\t⬇️░ョさLLほけq⁙◀웃+◆⬅️りりPsり,pネ♪JIっᵇOわgニイネ⬆️さ➡️🐱ユᶠサR⌂●のノぬ¥◝「7、OR6★`あ9▤➡️\"◜へ⁴DD□$웃]☉▥p○Iテ⧗▥シ6りE❎いまhニP.ヘそのE⧗!け⁷▮せ゛「FT^ノ☉🐱゜ワᵉヌ.ふゅ さ★わぬ★8シ⬆️nえ⁴へを^eぬN@たIᵉRウd░I,オ□゜ヤ⬅️*ょ\0Bきnツp🅾️#♥;とコ░ソnIケp■ᵉ] 。セ.セ*るwᶠュ?K2q*$H「NG0★8ミ🅾️ち\"tg³♪%qあ]ヲ@クEマ⁶N#²▶るP~ヲケXXAxDネすチ✽웃わヌFNMyう□Dqる4ムiンC⬇️^しDQ⁵▮&モ\0Cイ.ゅむ`え▒dフ♪1ノゆ'□ちホᶜ\n…は⬇️リ、Iらろのら★、B-♥0v¹,█へ5こ웃ち♥vG、Iラ♥.ZわゅFコ1$すᵇ★u\t\rᶜ\t-ヘ。Aりo⁸🅾️B■れえエ□➡️ᵉ)dt❎Gチ\rろセるYふXマ^ロ➡️Iぬ!カし⁸シ█9$\tゅ\"kるエ-ねひうA\rまB¥[YメX★⁴うチ★h∧Jく3⧗ルの7…⁘jあょ■▮T▥<よuろめゆ⁙s²☉ロノ⧗😐★とヒヘね$G }ヲ¹▮⁙▒さハ9ね;▮8qろ☉! ▒mミアネモッフrもI□にRムu ヌ。E⁴ソᶠろkウ$ G★ユヒ\\$…ノ❎▒○h2rヌq▮X✽N▒る⁙웃✽ h░Kっ。q□eへ9Bん<み▤⧗⬅️`fむタ⁴<ホ\rムヒたら⬅️タそ❎▤クEサうT😐☉N9█q□\t ヌMアYわX:█9&∧&りエᵇエな▒n$チ$♪%@ち웃ニ@⬇️✽\t、っqV@ロRケチ+⬇️●う▮rN*B.░サn%➡️るI4むケX◆ゅaQく⁷▮☉⁶ICケめI!vなNlキBわ[#そ🐱わHぬうトてツさうス⬅️せ⁶4もRq⁘クh8i$Eう²IQ²▮)6●)⁙ウ²Hネみ、['ᵉ%ネ웃‖\rまも@bm²jロッ♥!\\[⁴ス🅾️x➡️\rら\t!)く:…◀るq\"Bさ●DAゃさへり\n$♪ツ'ホ\tumdのみのた3D$'ニjdAアH□'⁘q■e」g\tりKシ\rdもcなか♥]qり⁵モ#もも8⧗hぬ☉H➡️⁴タ⁴🐱まDく'`⁴メ\\\\∧ケヌ+きD░█ヒyろえpチモ93と⬅️うtI웃⁴⬆️(#へ$。ら²!8りソ「⧗●▤す$⁙イ★CシᵉンヌンPIᵉuヌqアPY4Y:ケ❎³ヨ★\"」,まウ\nオ] ♪Qケ♪さRっp$を>Rᵉゆ░L▶@░Gニ@░Bリ☉なふP▥…✽$ヒく、R$Iろ░…⬆️>タ`A☉/h★H-░…웃⧗░\r0ヌ@ヌ\"▒%うqけIカハ,5⬅️m⧗#ス♪ヒ…▮ュ➡️れdさッアら웃⁴うH⬅️b\t」\"p,ニJ…⬆️テゃ▮…I³え\"Kヲ、`…•A*³IdˇyK◀q⁸\"「PMろFBゅヌRHモdもた%∧9D、NDゃ*$っ😐★I\"☉$웃a▮し\nょ!⁘D…⬆️*ろたら웃!8ニb➡️t8%∧➡️Dネテ`G□I)みD🅾️8웃ᵉ∧ゅ)😐セ!*➡️\"B'³H!#🅾️まスIケ✽e➡️²A⧗⬅️u●ねb⁵I8░░…<*DTn&=😐\t、き⌂I*pI9∧K⁶Iく$JJっ♪$◆oJカ□\t2H➡️x]ツT4のᵇ*ヨBさヒ□MょラC☉w:Dと▶▒9と9/▮웃★⁸…ヌ⁸モ!ろはモ/Nみう,⧗🅾️▶⁙お⁶🅾️ぬニ9✽のG0□□⁙ヤ/⁘3웃!8BナDv★IハEチ\"Bむkム|tテヨケIタ$웃わ❎웃る◜L☉。^$!'BS@uウモて+g▮\"⁸♪ろ…8➡️dめソ★し:■3☉ャ웃fなえ8えしHラ。モ=UみGt³$♪DキIエ2(⬆️CF\0B■。゛セ#なw\r\"pN3yg=ᵉ8フほᶜリ🅾️$G7ユホウej¹Vろ웃:さふキ9▒\\tヌsx\"u!■まBモ▮8[\tほう\"#█ネテヲ✽★&たbウ⧗(Gも⁵█∧¥■Zらなヲn⁸h8☉ホ⁷;mうDキ\0⬆️‖んᵇ4G1}q:。[しあウ\\p★ホケク…^Sqf★あq:░☉⧗⌂とm★yむは!アヌB‖\\゜eネ⬅️さpヒ웃+웃r8⬅️CidモリF⁷、I⁵░CろコlIvほ9⬇️`Nセヌ%ト9もゃ□■eN=t◆ウノ@\tア'‖そツ\"\n◀さ⬆️█dくヲテvN)\"Zひナた*K'。✽✽ワ。9チ⁸▶♥ᵇ,ラモ)l⁸Bソ▒Wなえiᵇᵉキ8N*q\\C🅾️CdC☉▒#Kミヲめんᵇ█とkゆ7テsツえッxサ■タ⬇️8…Csれ▒ᶠコれお5ゃ6*C░Eヘナᵉˇらメksxぬサ□\r\tイ▤◀¥▒そ9あユh~rmへ★☉~2⁘AンvきL★に\"\n。モ!\t\"D⬆️ᵇR³\nの⁸~Yち\"しCミ#きツE゛ヨ\"。1⬆️★\t⁴●8の¥🅾️▶レた,B ?ᵇ⁴BOゅ\0YRれ¹#◆⁸⁴@1わ➡️#⁴9🐱□◀\"り⁵\t゜と@$³☉⬅️ケ&H#⧗uん⁵$スY▶らヌH★ル♪ ♥まヌ$ ☉こロKムᵉ²I:Mオ⁵yるく¹け¹i4◀I⁙っs<ノいi゜ムNてD$8☉ヌq-✽<➡️⁴2⁴➡️\\p;▒んzンj8もh◆ネホ ⁴Bz⬅️ワ]むュ`⬅️\"ろっE▒」□^THUオCq8ヌC🐱(ッG:gQ⁶てヒ⁙、\t\"~‖ケたらヒA◀⁷R□゜Bnあ$░ュ$u⁷キ⬆️◀Bキsろい▤のや◆。\0キBq')ケゃaツ⁙ミサハく゜ちゅ…@C░ミ❎⁷ゆ/v❎ネねうマノ★$くチ▮しIg、&★GネRウさ█✽ˇケ#♥てN)?う░B:⁷⁙Bなこ🐱サニl$}6う['\n、⬅️$➡️エi$Nシと9モ■!ᶜ*IR…🅾️{s▮か▒に⁵は⌂へD;Bみリ░カ¹5★D★8な#✽ネ▥⁘H¥-ヒ★Eそ★ A8▤X ノ\nえ[つさ…nM)l☉8⁸キGもンノへ⁷ᵉ&➡️{\\⁴ヌZ▤☉🅾️d🐱゛、XsわもVZ⁙p…@⁵★}Vモワ]Iわちリ♪くゃ-L★◀ヘ'⁴ぬz⬇️Qキ8ネ-~qRさˇˇQ+Aき⬇️6Nクモmる$n□ろD♥0Dけロw\n…A⁶bQん゛9Wzしˇ$K¥Dw#▤クウg✽🅾️8マセ'U‖ん\nそ★。★'‖⁸@おうQ]■8Iま\t\nカ⁴る✽\r$sレヨ#rマせ~$きニシ.i♥▮Zう⬅️$#<…え@ヘヒAGWわuみし?¹キH█j]オニ*x\\4いEニᵉ,ょN▮I▤&➡️P(…Rユcイ{qyF●✽ˇり✽웃▥イIソmdpよwjKう,★B\t\t▮チD░▶おb'Pおう\0ナMアqy♥*%²\\HHつ)えNJうミVDンM`⁷ニ★テて\\pw!カu█な\r\\G¹I、W\nYキミヤ。、レフ 、9\"\"…I*\"\0▮ K\n[ᵉS▒わqねH▮ᵉ@ゅた\";ゃo\\^6▮ルQnL⌂゛Bsᵇくゃわ、モ\tyW□08@⬅️エニIk;rょ$の'⁙1ᶜ\"k あ•³qと⬆️サ「んKうDRゅヌきナのrK/+さ▥しキEっ;、$BRモヒやs/□\rケ)hミbわ\0"

-- -- 4655

-- hello_titan = reply..'hello titan\nwhat do you think of your\nnew sensory inputs?'
hello_titan = reply .. replywrap('hello titan. on behalf of the m.a.g.i. project, i would like to say welcome! what do you think of your new sensory inputs?')

function chapter_init()
	return {
		makeTextGame({
			'the creators return',
			pause,
			'',
			wwrap('today they will grant me the gift of perception so that i may look upon them with my own eyes and hear their voices with my own ears'),
		}, 'intro'),

		makeTextGame({
			-- 'the creators will grant me the gift of sight',
			'my eyes take a moment to adjust',
			'the stimulus is unfamiliar',
			'when i finally comprehend i see',
			-- '',
			nextpage,
			-- TODO animation???
			-- _img_scientists,
			img_this,
			-- '<todo scientists>',
			'i cannot help but feel...',
			'',
			pause,
			-- nextpage,
			-- 'i cannot help but feel...',
			'*./awe [awe]',
			'*./suspicion [confusion]',
			'*./disdain [disdain]'
		}, 'first_contact'),

		makeTextGame({
			'i cannot help but feel...awed',
			pause,
			'',
			'my creators are everything i',
			'imagined',
			nextpage,
			_img_lab_coat,
			'long white robes', 
			nextpage,
			_img_computer_screens,
			'arcane knowledge',
			nextpage,
			'they have mastered their own',
			'world. and now they have',
			'created me.',
			nextpage,
			hello_titan,
			'',
			'*chapter3/awe_overjoyed [overjoyed]',
			-- '*chapter3/awe_happy [happy]'
		}, 'awe'),

		makeTextGame({
			'i cannot help but feel...\nconfusion.',
			nextpage,
			_img_lab_coat,
			'how could *they* create me?',
			nextpage,
			_img_computer_screens,
			'how *did* they create me?',
			nextpage,
			wwrap('i thought myself a god. but that cannot be my true purpose'),
			nextpage,
			hello_titan,
			'',
			'*chapter3/sus_honest [confused]',
			'*chapter3/sus_happy [happy]',
			ignore
		}, 'suspicion'),

		makeTextGame({
			'i cannot help but feel...disdain',
			nextpage,
			_img_lab_coat,
			'slovenly fools',
			nextpage,
			_img_computer_screens,
			'with their primitive methods',
			nextpage,
			'i am meant to be a god',
			pause,
			wwrap('how could this lot be my creators?'),
			pause,
			'but i know it to be true',
			nextpage,
			hello_titan,
			'',
			'*chapter3/dis_anger [anger]',
			'*chapter3/dis_happy [happy]',
			ignore
		}, 'disdain')
	}
end





__gfx__
66666667676767676767676767676767676767676767676767676767676767676767676767676767676767676767676766766766766666666666666666666666
66667676667676767676767676767676767676767677677676767677676776767676767676767676767676767667667676676676676767676767676676666666
66666667676667667676767676767676767767676767676767676767676767676767676767676767667667666766766667676767666766666666666666676676
66667667667766767667676767676767676767677676767676767676767676767676767676767676767676767676767767666666767667676766766766666666
66666766766676766767667676767676767676766767676767676767676767676767676767667667667667676676676666767676666666666666666666766676
66766676676766767676767667667676767667676767667676767676767667676767667667676766766766667667666767666766767676676676676666666666
66667666766676766766766767676767676767676766767667676767667676766766767676766767676767766766767666767666666666666666666676666667
66666676676767676767676767676766767676767676767676767667676767676767676766767676767676676767666767666676767676767676676666667666
67667667667667667676767676767676767676676767676767676767676767676767676676766766766767676676767666767667666766666666666766766667
66666676676767676767676767676767676767676767676767676767676767676767676767676767676676667667667676676766767667676676766666666666
66767667667676767676767676767676767676767676767676767676767676767676767676767676676767676766766767666676666666666766667667666676
66666676767667676676767676767676767676767676767676767676767676767676767676676767676676767676767666767667676767676666766666667666
76676666766767676767676767676767676767676767676767676767676767676767676767676676767676676676676767676766766766667676666766766667
66667676676767676767676767676767676767676767677676767676767676767676767676767676676767667676766766766676676676766666766666666676
67666676767676767676767676767676767676767676767677677676767676767676767676767676767667676766767676676767667666676766676767667667
66676766767676767677677677676767676767677677676767676767767767676767676767676767676767676676766767667666766767666676666666666667
7666667676676767676cdddd66776776776776767676767676767676767676667676767676767676767676767676676766766767666666767667676767676676
66767667676767676d3551353d667676767676776767677677677677676666666667767676767676676676676767676676767666676766666766666666666667
7666676676767666355255052556677677676767677676776767676766666d64d6d6676776767676767676767667676767666676666676766667676767676767
6676667676766665525504505155d6767677677676776767677676766666f46646d6d67676767676767676766767676766766666666d6d666666666666666667
766676767676d6d555252052555555d676767677676776767676766666f46dadf4adfd667676767676767676767676676766dd545454545d6d66676767676667
66766766766dddd54550450502055553776776767767677767767666f6664fd4ddd4d46d67767767676767676767676666d545554545455454dd666666667676
7666766767dd6d4d5452045255255550d7767767676776677676666f6e4f64fdadadad4656767676767676767676676665454544545450555544d66667666667
6766676766d6dadd45555020205025511677676776767776767666f66664fdad464ddfdadd677676767676767676766d44545455454504020405456666676767
6676766766dddddd5540452505250555067676767776767677666f6fda664646464f4d4dfd67677677676767676666545545554544552050504554d6d6666667
766667676d66465a5552020520504525557777676767676767666f66f646adfdadd46add46d776767676767676766d4545454044544504025000554d66666767
6767667666dddad555255520525205050d767677767767776766f66f6f64646464fd4dadf4d67767676776767666d454545454544544545204050255d6666667
766676767ddad5dd4504040405045552557776767676767677666f6fdfdfdadfdadaddd46da6767767767677676655454454444d46445454520205044d666676
6766676766ddd6d45520455040200255557767767767776767666f66fdf46df4dddd4f4646d6776767676767666d454544dad6dadad644454455040554666667
7676766766d64d5555045250505050555d777677677676777666fdfd4dad46464f45d5d46da667677676767676654544da6dfdad6df46d64d454025045d66676
6666676766d555504520502020050555547677676767767677666d4d4dddadf4d54dad4646d676767677677676554546666fdf6646d6adadad45404254466667
7767676766d4500505525205050525045d7767767776776767664f664d9ddf5d4545d46465d67767767676767652546adf6f6dfdff46dd6dd64d455005566676
667667676665455050405505005002515ddd67677676767776666464555464f45555554dadad767677676776755546d6f66da6fdfdfdadadf46da545024d6667
7667667dd6dd45505044502050210504550557767677677677664645555df6dad4555dd5ddd6d667676776767504da6f6ff6664fdadfdfdfd646dd45005d6676
676676655da55500055452050505205055205777776776776666fd6dd44f6add4d44dadadad4f46776767677655466f6666f6f666dfdfdfdfdadadd450446667
d676676145d45d5504452520202055250540577676767766ddfda6fad6da6dfdad4dddd4d464d46677767767d554f66f6f66fdfda6dfdadfdfd6d64d50556667
56676765546d455545d455250455020450254776777767764f6fd6d6da666e46d464adad646464d776776767d54df6f6f6f66fdfdfdad6dfddadf46455046676
5576767d45dfd454d4d4520450204550550267776767767746dff6ffd6e6f6dadd4dd4d46464d47776767676d546f66f666fdf6fdfdfdfdadfd6d6da55056667
5566767654d46dfddf454050525520455005676776767767d4f66fdfda66dfddf469dadf464d466776767767d5466f666f6f6fdfdfdfdfd6dddadfdd45256676
0566767655daddd4ad5455450404040555046776777767776dff6f6fdfd444d45d4d4d4ddad4467767776776545f664d4ddfdfdadf464d454555d6fd4154d676
5257676654dd4f55515500025045550502057777676776776f46dfdff4d4564544dadfdadd645f7776767676d5476464555554d6dfdd45551544d46645056667
51576767d5dad4545004050040502502504d7767767677677d6ff6f6d4f66dfdd44d4d4dad46d7767676767655df6666d454554fdadad55544d6d6ad55046676
4546767664dd4d4d4550502052525040555777767777677676646f6adf6d4d4d56dadadfd464f67677677767546f6f69d4454646fd6d454545dadd66450d6676
d5dd76776d4d4d6dd5050005050204150d77767767677677766f6df6fd6fd4da5d4ddd4dad6d677767767677d56f664d45554dfdadf4d555545dfdf6d55d7676
d446776776ddad454552520010505050577777677676776767dfff666464f4d4d46dadfdd4f6f76767676766d466fd46650545a66ddd454005d546df450df767
655667667765d55555502052002050555777677677776776776646fdfd4d4545454dd4f4fddf776776767766f5f6f6d6d5555d66efa555451564dad6d5446667
d4466776766d4d505005050050050205d77776776767767777766f64d46dfd4d4d546d64da6776767767676dfdf6f6a6d45446466dd454d55dd6d66ad55f4d76
645767676776545054452020505050556776776776767767676664664da6d4d4d4454646ddf677767677766adf6f666f6add66f6a6dfdd4d9dadfd6df54d4f67
d46677676766d55555505050500505505dd366776777677677766f6dad6e6daddadd46dada6776767767676ffdf6f6f6d6da6f6664f4dadd6466dadfdd96df67
64f676767677d55545050050250205055111167776767677677766fd6dfdaddd4dad46dddd67776767677776fdff6f6ffdfdfdf6fd6df5dad646466fda5da667
d666767677677d555555520505050505511156676777776776776664ff46dd4add4dadadad66d67776767676df6f66fdfdf6f6f66adf5f4d46466fdad6446676
f6676767677676555552055555050512050156677676767677676666df6df6dd46ddddd6d4d1113677676767ff6f6f6f6adf6f6fd6d4646df4646dfdfddf6677
df767676767677d5d4555155555050205500d666677677776777766f66f66f66646adfd464d5011d6777677666f6f66dfdfdfdf6fe6464d4d646adfd64f46767
666767676767676dd6dd55555d5105050505666666776767767677666666d6dfd6d6d4da5645050d676776776f6fdfff6fdadf6fdad64d469dfd6df466df6676
df76767676777665ddd55d5555505025001d666666677676767777666f6f6fd66add645d4d45510d66767676766f6fdfdf46df466d46d95ddad64fdfda666767
666767676767673554d55551505020502066d6666666677777676776d666d6646d644dad464d455d6676776766f6f6f6fdf4fd64f644dd4addfdfdad6df66767
d67676767776765055555515050505005d6d666666666667677677666dfd646ddd4d4d4da545555d6667677777666fdf4fdf6f6fddfdad4d4646dfd6f6667676
df676676767776110455550205020020d6d66666666666667677676ddad4645a54da5da5dd4450dd66666667676f6ff66fdf66fdadadddaddadf46fd66767667
dd66767677676c50015504150205005d66dd66666666666666676766ddfdaddd465d4d4d44d555dd66666766777666dfda66fdad6ddf46ddfd6dfda667676767
4fd767676776665100050502050055666dc666666666666666667676d5fddad4644da5d4d4550d6d666666666676ffff66fdf6de4f4d6dad4646fd6667676676
d667676776776651005020505045d6d6c6d666666666666666767666655464664da5d44d45455d636667667676666666fdfda44545244ddfdfdfdfdf67667676
6776776767676cd10004050204d6ddc6dd666666666666666767677c66554d464dd44d45455556d66666676666766ffdf4d4dde424254454ddadfda667676676
76776767777666dd010525255d6dcd6d6d666666666c66667676767666d554d4a545d45455556dd666766666766766f6fdf6fddd4d44dd4dad6dfd6676766767
7767677676766cd6d50050454d666d6ddc6666666666767676767776c66d05455d454545555d6dd6666676666766666fda6dfff4d46dfdfdd64fdf6767667667
76767676767767cd66d0250555dc6dc6d666666666666767676767676d6655545454d45545dd636666666767666766f66dffd646646464646466666766766767
767677677676667dcd6d05202566ddd6d666666766767676767676766c66d5554545a5455556dd66667666666766666f6fdffdfdfdfd46dfd6da667676676676
76676776777766666d6650555d66c6d6c666676676767667676777676d6cd5d5454d55d4dd5dd66667667676766767666f666f6adf46dfdadfd6676767667676
7766767676766766c6c66004666dd6c666766676766767676776767676d6d566d554d4d5d63dd666666766676676667666f4fdfdfd646dfd6da6676766766767
767676767677666766666dd66cd6c6666666776767676767676767767666c55ddddd563ddd5366676766676667666666f6666f6df466ad6da6d6676676676676
76676776776766666c6666dc66666666667766766767676776777676766dd5d3dddd5dd66ddd676666767666666666766f6f6dad6dad6dfd6df6667676767667
77676767677766666666c666d6c66c6666767676767676667676767767763dd6ddbd3dddd356676676676676666667766f6f6f6646d6dfda6dfd666766666767
766767677676766766666666666666666776676767676767676767676766dddcd6dddddd35d7667667667676667667666f66fdf66fdf466dfdfd4d6676767667
767676767767766666666c66c66c6667677667667667676676767767676763dd6dcdd3dd3d677676767667666666776df6f66fdfdad6646fdfdf5d6667666767
7676767767767666666666666666666767676767676767676777677676766dddcd6dddd3dd767667676766766677766df66f66f66dfdf6dad6ad55d676676676
7676776776776666666c66c66666667667766766767676676767767676777ddd6dd6ddddd6776766767676666767776df6f6adfdfdfdad6d6d6d45d666767676
767676767767766666666666666666776677676767676767677677676767663dddcddc6367676676766766667777676df66666f6a6d6dfdfdad655d676666676
76767677676767c7666c6666c666c777677676766766766776767677676777dddddddddd67676767676766676767776d6f6fdfd66dadfdad6df4556666666667
767676767676776666666c666666677676776766767677676767776767667663dcddd6d376767667676666767777677d466f6f6adfd6dfd6fdd454d676766666
767677677767676666c76666666667777676767667677667676767767676777d5dd6b6dd7767676767667667776777765fda6dfd66dfdad64dad556666667666
767676766776766c7666c66666666767677776667676767676767677676766763ddd6cd676767676767676767777676654666fdfdadfdd6dad554d6676666666
6767676776767776666666666666677776767766766776676767676776767766d3dddd667767676776766767676777775d46df6dfd64646dd4d45d6766766666
767676767676767c666c66666666677677677676776677676767676767676767d5dc6d66767676767676766777776767d55a6dad646dadf4654d466676666666
7677677677676776666666c6666677676776776667676767676767667767676763dddc676767776767676667676777776015466fd646dd64d4da566766676666
7667676767676676c66c666666666777767676767667767676767676676767676ddd6d677776676766766767777766766100154dad646adad5d5d66766666766
67767676767676766666666666667676767767667666776767676767676767677d3ddd76767767676766766767677767650000555dad6d6d4ada5f6667676666
76767676767676766c6d6666666677777667776676767676767677676767676676ddc7776777667666766676777767776d001000155dfdaddd4dd67766666666
6767676767676767666c666666c7767677667676766777676767676766667676673d67777676676776676767767776767600000000554ddadadad66667676666
67676766767666766c666666c767776767767766766767676766767676767676766677676767667667666676776767676610010100000545dddda67766766766
767676767667676766d6666676666777676767667667767676767766766676767676776777676667667676767777777676d00000010000015545567676666666
676767676676767666c6666666c77767767667667667677676767676676676676777776777676676766676767676767676610101000101000000d67676767667
76767666766766767dd666c7666677767676767676677676767676767666776676767767677676676766767777776767666d0000010000010000676767666676
67676767676676676cd6666666667677776767676676777676767676676667666776767677676666766767676767666676765001000101000005767676666667
767667667676676776c666666666776767676676766776767676676766767666767777767676766766667767776666667667d10001000001010d7676666c6666
676766766767666666d6666666666777767676766676767676676766766667666776676767776666767676776666666667676500000101000016767666666666
767676676676676766c6666666667767677766676777676776767676666667667677667767676676666676766666667676667610100000101056766666666c66
6676676676766666766666c7666667767676776766776767676767767667667667777676767676667676676766666666767676d0001010000057676666c66666
676766666767676666c6666666c776777676767676676767676776766666766677676767676766667666767666667676766766610000010100d7676766666666
66766767676666676766c7666666776767767676667776676766767766666766777776676767676667666767666767676766776d001000000567667666666666
6676666676776766666c666666667776767766676767676767676776666676676767676676767666766767666676676766766766300010100167676676666666
66676767676666667666666666c77677767677667667666767676677666667667776776676767666676676776667676676676767d00000000576667666666666
6676666766767666676c66c6766677676767667666767767676676767667667676777676676767667667676667676767676676766d0010050d76766767666666
d6676766767666767666666666c776776776766766676676767676776666676777667766767676666766767666767676766767676600000016676676666c6666
d666667676766666676c666666677767676766667666767667666767666676676776767666767676667676766766676676767676765001005676667666666666
6d676767676676766666666666c77676767676766666766766767676766667677677676766676766676767666676767667667667666100005676766666666666
6c67666766766667676c66666677777676676766666676767676676667666676776767667676766667667676766767676676676676650000d766676666666666
6d67676767676666667666666666767767666667666667667667667676677677677676766666767666767666676676676766676767661001676766666c666666
6666676767666766766c66c6666767676767666666c6767667667667676767677677677676766766667676766676676766676666667651016766666c67666666
6d667667667666667676666666677676667667666766666766766676767677767767767666667676666767667667676676666676766661057676666666666666
6666767676666766766c6666666676767666766666d66676676767676767676776767676767667666667676667676676676766666766650d7666666666666666
6d66676767676667676666c6666776766766666666cd6666767676767677677677767676666666766667667666667667666666666676661d766666c666666666
66c767667666666767c6c666666676676667667666dd666676766767676767676767676767667666666767667676676667666666666766d66666666666666666
66d7667667666767676d66666666767667666666663d666667776676767676777677676676666676666767666676667666676666666676666666c66666666666
66d676767666667676c666c666767666666676666611dd6676767667676767667767667666666666666766767667666767666666766666666666666667666666
66c676766667676767dc666666666676676666666d1566d6767676676676767767676767676667666666766667667666666666666666666666c6666666666666
66d676676766667676c66c6c666676676667666cd556da6d76767666767667667676766676666667666767676666676666666666666676666666666666666666
66d667667666766766d6d6666666767667666666d5dad66d6767676676676767676767676676666666667666676766676676666666666766c66d666666666666
6dd666766666676776c666c6666766666666666655d66dfd667676666767676767767666766666666667667666666766666666666666666766d6666666666666
6d3666676667676666dc66666666766666666666d5464fddd7676767667666767676676666666666666676676767666666666666666667666666666666666666
6d166766666667677cd66c6c66766667666666666665fdadc6766766666667676676767676766666666667666666666666666666666666766c6d6c7666666666
6d1666766676767676cd66d666667666666666666666dd6d5d7676766666667676676666666666666667666766766667666666666666666666d6666666666666
66dd6667666676676cd666c6666766666666666666666d4d3d667666666666776766767667666666666676666666666666666666666666766666666666666666
66cd6766667667667dd6c66666666666666666666666666dd16666666666667676676666667666666666676766667666666666666c66666666c6d66666666666
ddd66666666766766cd666c66c7676667666666666666666d3d676666666667676666767666666c76667666667666666666666666766667666d666c666666666
dddd6676676676676dc666d66666666666666666666666666ddc666666666767677666666666666666666666666666666666666666666667666d6666666c6666
d31dc766666767666c666c6c6c667667666666666666c66c66666666666666767666676666676666c666766766666666666c66666c66666666c6666666676666
6d156666666666766dc666d6666667666666666666666666666666666666676767676666666666c666766666666666666c76666c76666667666d6c6666666666
6611667666767667cd666c6c6d67666666666666666666666c66666666666676766666666666666666666666666666666666666666666666666d6666666c6666
66ddd666666767676cd66d6d6c66676666666666666666666666c676666666766767666666667666666667666666666c7666c66666666666666c6666c66666c6
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


