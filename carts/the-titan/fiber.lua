cartdata('mmm_project_titan')
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
add(textList, '')
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
replywrap('')
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