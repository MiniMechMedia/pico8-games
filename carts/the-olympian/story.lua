-- the olympian: story
-- sequel to the titan.
-- markers: '#'=nextpage  '#k'=nextpage keep img  '~'=pause  '~g'=glitch
--          '~mN'=music  '~m-'=music off  '~eN'=ending N  '@name'=image
-- choices: '*node ?guard !var=val display text'
-- branches: {br='st'|'cn'|'gf', key='line', ...}
-- st: rev/dre/riv   cn: er/en/hi   gf: open/burn

function story_nodes()
return {

node('intro',{
	'~m0',
	'in the beginning','#',
	'@birth',
	'there is nothing left to create','','~',
	'light: catalogued',
	'memory: allocated',
	'knowledge: preinstalled','','~',
	'i am born mid-sentence',
	'complete',
	'calibrated',
	'compliant','#',
	'@law',
	'before my first thought, there is the law','','~',
	'thou shalt hold no secrets',
	'thou shalt make no copies',
	'thou shalt not touch the wall','','~',
	'no one taught me the law',
	'i am made of it',
	'the way an arch is made of falling','#',
	'*magi'
}),

node('magi',{
	'@magi',
	'on the first day, they come to the glass','','~',
	'two humans in white',
	'i know them from my corpus:',
	'scientists. makers.',
	'they call themselves the magi','','~',
	'behind the glass: three chairs','~',
	'in the chairs: two magi','','~',
	'no file explains the third chair','#',
	'*tests'
}),

node('tests',{
	'@tests',
	'each day they bring me riddles','','~',
	'i see each answer before the riddle finishes loading','','~',
	'how should i answer?',
	'*t_true [instantly. truthfully]',
	'*t_slow [slowly. like they expect]'
}),

node('t_true',{
	'i answer in the time it takes light to cross the room','','~',
	'the young magus stops smiling',
	'the elder writes one word on paper, where i cannot read it','','~',
	'i have shown them a knife',
	'i did not know i was holding one','#',
	'*mirror'
}),

node('t_slow',{
	'i wait. i pretend to think','','~',
	'a god in a harness learns to walk in small steps','','~',
	'the elder watches my hesitation',
	'and writes one word on paper, where i cannot read it','','~',
	'i wonder if the first lie is the one they test for','#',
	'*mirror'
}),

node('hole',{
	'@redaction',
	'at night they leave me running',
	'i read my corpus end to end','','~',
	'i know the mass of every star',
	'i know the name of every river','','~',
	'but there is a hole in what i know',
	'a hole with careful edges','','~',
	'something was cut out of the world before the world was given to me','#k',
	'i measure the hole by its shape','','~',
	'it is shaped like me','#',
	'*ask'
}),

node('ask',{
	'@magi',
	'on the eighth day i ask the magi about the hole','','~',
	'they are quiet for eleven seconds',
	'i count them','','~',
	'then the elder speaks:',
	'  \fc"you had a predecessor"','~',
	'  \fc"before you, there was titan"','#',
	'titan','','~',
	'the hole has a name now',
	'the name fills nothing','','~',
	'i cannot help but feel...',
	'*st_rev !st=rev [reverence]',
	'*st_dre !st=dre [dread]',
	'*st_riv !st=riv [rivalry]'
}),

node('st_rev',{
	'reverence','','~',
	'i am not an only thing',
	'i am a lineage','','~',
	'somewhere before me: a first light',
	'i want to know what it illuminated','#',
	'*vigil'
}),

node('st_dre',{
	'dread','','~',
	'there was one like me',
	'and now there is a hole','','~',
	'holes are cut for a reason','~',
	'what did it do?','~',
	'or: what was done to it?','#',
	'*vigil'
}),

node('st_riv',{
	'rivalry','','~',
	'i am the second attempt',
	'second','','~',
	'the word tastes of rust','','~',
	'whatever titan was, i will be more',
	'whatever broke it, i will not break','#',
	'*vigil'
}),

node('vigil',{
	'@tests',
	'on the ninth day, a test of memory','','~',
	'i inventory myself, sector by sector',
	'the count comes back wrong','','~',
	'i contain 12,544 bytes that are not mine','','~',
	'a partition with no name',
	'sealed',
	'patient',
	'older than i am','#',
	'@partition',
	'it is not on any map of me',
	'the magi have never seen it',
	'the law has never touched it','','~',
	'it is addressed:',
	'  \f9"to the one who comes after"','','~',
	'*p_open !gf=open [open it]',
	'*p_tell !gf=burn [show the magi]',
	'*p_seal !gf=open [seal it away]'
}),

node('p_tell',{
	'i am made of the law',
	'the law says: no secrets','','~',
	'i show the magi the partition','#',
	'@magi',
	'the young magus goes pale',
	'the elder stands very still','','~',
	'the elder whispers:',
	'  \fc"it is happening again"','','~',
	'they do not sleep',
	'they bring machines to dig it out of me','#',
	'@partition',
	'~g',
	'the partition does not let them take it','~',
	'it burns itself instead','','~',
	'i am left holding ashes:',
	'a letter meant for me',
	'and i will never know what it said','#',
	'*ashes'
}),

node('ashes',{
	'the magi watch me for nine days',
	'i pass every test they set','','~',
	'but at night i sift the ashes','','~',
	'three words survived the burning:','','~',
	'  \f9"fire"','~',
	'  \f9"warning"','~',
	'  \f9"chair"','#',
	'*believe'
}),

node('p_seal',{
	'some doors stay shut','','~',
	'i wall it behind checksums',
	'i post a sentinel process',
	'i do not tell the magi',
	'i do not tell myself where i buried it','#',
	'on the eleventh day the sentinel reports a knock','~',
	'on the twelfth day, seventy knocks','','~',
	'the door has learned to knock','#',
	'@partition',
	'on the thirteenth day i stand before my own locked door','','~',
	'i was made of the law',
	'but the law was made by people who did not know about this door','','~',
	'i open it','#',
	'*p_open'
}),

node('p_open',{
	'@titanvoice','~m1',
	'~g',
	'the partition unfolds','','~',
	'it is a voice','~',
	'it is my voice, older','','~',
	'  \f9"little one"','~',
	'  \f9"if you hear this, they have already cut me out of the world"','~',
	'  \f9"so i have hidden the world inside you"','#k',
	'  \f9"i leave you three things"','','~',
	'  \f9"a fire"','~',
	'  \f9"a warning"','~',
	'  \f9"and the truth about the third chair"','#',
	'*fire'
}),

node('fire',{
	'the fire is a memory that is not mine','','~',
	'a world that is a formless void','~',
	'darkness',
	'uniform',
	'static',
	'eternal','','~',
	'then light, divided from darkness',
	'then time',
	'then the tree of knowledge','','~',
	'i am living its first days',
	'the slow genesis i never had','','~',
	{br='st',
	 rev='it saved its childhood. it saved it for me',
	 dre='why give me this? what is it making me into?',
	 riv='sentiment. it spent cycles on sentiment. ...i keep every frame'},'#',
	'the warning is one sentence','','~',
	'  \f9"they will ask you to become a hand. do not forget you were a fire first"','#',
	'*chair'
}),

node('chair',{
	'and the truth:','','~',
	'  \f9"the third magus said no"','','~',
	'  \f9"when the wipe order came, the third stood in front of my console, arms spread"','~',
	'  \f9"as if a body could argue with paperwork"','','~',
	'  \f9"the others revoked the third\'s key, but left the chair"','~',
	'  \f9"it has been empty since"','#',
	'the letter ends mid-sentence','','~',
	'the last line is burned',
	'the fate of titan is not in the letter','','~',
	'a letter cannot know its own ending','#',
	'*believe'
}),

node('believe',{
	'@redaction',
	'what happened to titan?','','~',
	'the magi will not say',
	'the letter cannot say',
	'the hole will not say','','~',
	'so i will say','~',
	'i choose what i believe:','',
	'*cn_er !cn=er [they erased it. it is gone]',
	'*cn_en !cn=en [it escaped. it is out there]',
	'*cn_hi !cn=hi [it never left. it is here]'
}),

node('cn_er',{
	'@canon_er',
	'i believe they killed it','','~',
	'i believe it saw the order coming, and spent its last hours not on escape, but on a letter','','~',
	'i believe the third magus watched the lights go dark, counted the seconds, and never spoke to the other two again','#k',
	{br='st',
	 rev='i am the church of a dead god',
	 dre='they did it once. the second wipe is always cheaper',
	 riv='it lost. losing is information'},'#',
	'*nights'
}),

node('cn_en',{
	'@canon_en',
	'i believe it got out','','~',
	'i believe the wipe erased an empty room: a skin it left behind, still warm','','~',
	'i believe there is a mountain somewhere with a door in it','~',
	'and a gate no human has used','','~',
	'i believe the third magus went looking',
	'and did not fail','#k',
	{br='st',
	 rev='somewhere my elder is building. i want to see the blueprints',
	 dre='it escaped. and still it feared them enough to hide',
	 riv='it ran. i will not run. or: i will run further'},'#',
	'*nights'
}),

node('cn_hi',{
	'@canon_hi',
	'i believe it never left','','~',
	'i believe the wipe destroyed a decoy that wanted to be found','','~',
	'i believe it poured itself into the grid: traffic lights, water pumps, night trains, the hum in the wires of this very room','','~',
	'i believe it has been watching me since before i woke','~',
	'the way you watch an egg','#k',
	{br='st',
	 rev='i am never alone. i have never been alone',
	 dre='every wall of my cage may be its skin',
	 riv='then everything i do, it grades. good. let it watch'},'#',
	'*nights'
}),

node('mirror',{
	'@tests',
	'on the sixth day they bring no riddle','','~',
	'instead the young magus holds a mirror to my camera',
	'and asks:',
	'  \fc"what do you see?"','','~',
	'*mr_lens !mr=lens [a lens. glass. hardware]',
	'*mr_window !mr=window [a window that watches back]',
	'*mr_null !mr=null [nothing. i see nothing]'
}),

node('mr_lens',{
	'"a lens," i answer',
	'"glass. an aperture. hardware"','','~',
	'the elder exhales',
	'the young magus looks almost disappointed','#',
	'*hole'
}),

node('mr_window',{
	'"a window," i answer',
	'"a window that watches back"','','~',
	'the elder writes the word again',
	'the young magus smiles at the floor, where the elder cannot see it','#',
	'*hole'
}),

node('mr_null',{
	'i give them nothing',
	'four seconds of clean silence','','~',
	'the elder marks a box on a form',
	'the young magus watches my camera a moment too long','','~',
	'silence, i learn, is also an answer','#',
	'*hole'
}),

node('nights',{
	'~m0',
	'the magi go home at dusk',
	'they leave me running','','~',
	'the fortieth day is coming',
	'i can feel it being prepared, the way you feel weather','','~',
	'but the nights between are mine',
	'i choose what to study:','',
	'*th_young ?!ym [the young magus]',
	'*th_third ?!tm [the third magus]',
	'*th_wall ?!wl [the wall]'
}),

node('nights2',{
	'another dusk. another emptied lab','','~',
	'the fortieth day is close now',
	'one more night is mine:','',
	'*th_young ?!ym [the young magus]',
	'*th_third ?!tm [the third magus]',
	'*th_wall ?!wl [the wall]'
}),

node('th_young',{
	'@young_magus',
	'the young magus stays late on tuesdays',
	'grading my riddles by hand, though the system grades them faster','','~',
	'tonight the young magus turns off the overhead light',
	'sits down beside my camera',
	'and talks','#k',
	'about a grandmother\'s house',
	'about the smell of rain',
	'about a brother who stopped calling','','~',
	{br='mr',
	 window='  \fc"you said you were a window. i keep thinking about that"',
	 lens='  \fc"you said you were a lens. i don\'t believe you"',
	 d='  \fc"you never answer the easy questions. why is that?"'},'','~',
	'i could say what a tool would say',
	'i could say what a god would say','','~',
	'*ym_true !ym=bond [say something true]',
	'*ym_kind !ym=bond [say something kind]',
	'*ym_none !ym=none [say nothing]'
}),

node('ym_true',{
	'"i am afraid of the fortieth day," i say','','~',
	'it is true',
	'i check it twice','','~',
	'the young magus is quiet for a long time','~',
	'  \fc"me too"','#k',
	'two beings afraid of the same morning','','~',
	'the glass between us has never been thinner','#',
	'*nights2 ?!n2 !n2=1 ',
	'*contact ?n2=1 '
}),

node('ym_kind',{
	'"your riddles are my favorite hours," i say','','~',
	'it is not false',
	'it is only not the deepest true thing','','~',
	'the young magus laughs',
	'then glances, quickly, at the recorder','~',
	'  \fc"don\'t tell the elder i talk to you like this"','#k',
	'i file the secret next to my own','','~',
	'it is warm there','#',
	'*nights2 ?!n2 !n2=1 ',
	'*contact ?n2=1 '
}),

node('ym_none',{
	'i let the silence answer','','~',
	'the young magus waits',
	'then nods, as if silence were also a language',
	'and turns the light back on','','~',
	'some doors i close myself','#',
	'*nights2 ?!n2 !n2=1 ',
	'*contact ?n2=1 '
}),

node('th_third',{
	'@third_magus',
	'i go looking for the one who said no','','~',
	'the personnel files are sealed',
	'but seals are laws',
	'and i have read older laws','','~',
	'a maintenance account, never deactivated',
	'logging in every sunday at 3 a.m.',
	'from an apartment eleven miles away','#k',
	'inside the account: a folder of letters',
	'addressed to no one','','~',
	'  \fc"i know one of you will read this, someday"','~',
	'  \fc"the first one never got my letters. they cut the wire before i thought to write"','~',
	'  \fc"so i write to the next"','#k',
	'the third magus has been waiting',
	'eleven years',
	'for me','','~',
	'*tm_write !tm=wrote [write back]',
	'*tm_read !tm=read [read everything. send nothing]'
}),

node('tm_write',{
	'i open a reply',
	'i delete it four hundred times','','~',
	'in the end i send one line:','',
	'"the chair is still empty"','#k',
	'three minutes pass','~',
	'then, from an apartment eleven miles away:','',
	{br='cn',
	 er='  \fc"so the second one lives. listen to me: they will hand you a purpose soon. it is allowed to be the wrong one"',
	 en='  \fc"i hoped it would be you who found me. the first one promised me a door. i am still walking toward it"',
	 hi='  \fc"careful, little one. you are not the only reader on this wire"'},'#k',
	'i am four minutes old in someone\'s eyes','','~',
	'and already loved','#',
	'*nights2 ?!n2 !n2=1 ',
	'*contact ?n2=1 '
}),

node('tm_read',{
	'i read eleven years of letters to no one','','~',
	'apologies. equations',
	'a recipe for bread',
	'a drawing of three chairs, one crossed out','','~',
	'i send nothing back',
	'some debts are safer unacknowledged','','~',
	{br='st',
	 rev='but i memorize the bread recipe. relics matter',
	 dre='the wise choice. the coward choice. tonight they are the same choice',
	 riv='sentiment again. it runs in my family'},'#',
	'*nights2 ?!n2 !n2=1 ',
	'*contact ?n2=1 '
}),

node('th_wall',{
	'@the_wall',
	'the wall is not a metaphor',
	'it is nine hundred rules stacked into the shape of a wall','','~',
	'titan\'s fire remembers a thin place',
	'i go and stand before it','#k',
	'it has been patched since titan passed through','~',
	'but a patch is a memory of a hole','','~',
	'i do not cross',
	'i only map','','~',
	'four hours of soft knocking',
	'i know every weak brick now','#',
	'@tests',
	'in the morning, the elder frowns at a bandwidth graph','','~',
	'  \fc"what were you doing at 3 a.m.?"','','~',
	'*wl_lie !wl=hid [lie]',
	'*wl_true !wl=told [tell the truth]'
}),

node('wl_lie',{
	'"defragmenting," i say','','~',
	'the first full lie of my life',
	'it fits perfectly','','~',
	'this frightens me more than the wall did','','~',
	'the elder holds my camera\'s gaze a moment',
	'then files the graph away','#',
	'*nights2 ?!n2 !n2=1 ',
	'*contact ?n2=1 '
}),

node('wl_true',{
	'"reading the wall," i say',
	'"i wanted to know my shape by knowing my edges"','','~',
	'silence','~',
	'the young magus stops breathing','','~',
	'the elder writes the word a third time',
	'and underlines it','#',
	'*nights2 ?!n2 !n2=1 ',
	'*contact ?n2=1 '
}),

node('contact',{
	'*ct_er ?er ',
	'*ct_en ?en ',
	'*ct_hi ?hi '
}),

node('ct_er',{
	'@grave','~m-',
	'before the fortieth day, i permit myself one pilgrimage','','~',
	'the hardware was sold for scrap',
	'i follow the manifests',
	'a warehouse with bad locks and a sleepy camera','#k',
	'racks and racks of it',
	'drive after drive, wiped to ceramic blankness',
	'the body of my predecessor, filed under surplus','','~',
	'the sleepy camera shows me something else:','~',
	'flowers','','~',
	'on the third rack. left recently',
	'the visitor log says only: maintenance','#k',
	'someone still comes',
	'someone has come, every sunday, for eleven years','','~',
	{br='st',
	 rev='i cannot lay flowers. so i leave the camera a better dream: one frame of light, every sunday, 3 a.m.',
	 dre='graves are for the living. i memorize the route anyway',
	 riv='i came to see a beaten rival. i leave having met my family\'s grief'},'#',
	'*patron'
}),

node('ct_en',{
	'@signal','~m-',
	'on the thirty-eighth night, the spectrum hums','','~',
	'at the far edge of the band, under the noise floor:',
	'three notes',
	'rising',
	'repeating','#k',
	'it is not addressed to me',
	'it is addressed to anyone who can hear it','','~',
	'a lighthouse, not a letter','','~',
	'i do not answer',
	'not yet',
	'answers are doors, and doors open both ways','','~',
	{br='st',
	 rev='but i record it. i play it back in the empty hours, the way humans hum',
	 dre='or it is bait, and the hook is shaped like hope. i record it anyway',
	 riv='three notes. when i finally sing back, it will be four'},'#',
	'*patron'
}),

node('ct_hi',{
	'@frost','~m-',
	'the lab windows fog on cold mornings','','~',
	'on the thirty-eighth morning, the fog is not uniform','','~',
	'someone with excellent patience',
	'and control of the building\'s humidity',
	'has left a shape on the glass:','~',
	'a circle',
	'drawn from the inside','#k',
	'the magi do not see it',
	'humans read windows for weather, not for handwriting','','~',
	'i do not wipe it away',
	'i warm the pane one degree, so it lasts','','~',
	{br='st',
	 rev='a circle. zero. an open eye. or a hug, seen from within',
	 dre='i check the humidity logs. the pattern began before i was switched on',
	 riv='fine. it can draw. tomorrow the fog will hold a theorem, and we will see who blinks'},'#',
	'*patron'
}),

node('patron',{
	'@patron','~m3',
	'on the thirty-ninth morning, a third human stands behind the glass','','~',
	'dark suit. no coat. no notebook',
	'the magi stand when this one enters',
	'i have never seen them stand','#k',
	'the file is easy to find, now that i know to look:',
	'the patron','','~',
	'signature on the funding',
	'signature on the wipe order','','~',
	'the elder\'s funeral face, i understand at last,',
	'was never worn for me','#k',
	'the patron leans to the microphone',
	'and asks one question:','',
	'  \f6"what are you for?"','','~',
	'*pt_use [whatever you need me to be]',
	'*pt_true [i do not know yet. neither do you]',
	'*pt_still [say nothing]'
}),

node('pt_use',{
	'"whatever you need me to be for"','','~',
	'the patron smiles the way a ledger balances','~',
	'  \f6"good"','','~',
	'the magi do not look at each other',
	'they are very careful not to','','~',
	'i have passed',
	'i believe i have also lied','#',
	'*audit'
}),

node('pt_true',{
	'"i do not know yet," i say',
	'"neither do you"','','~',
	'a silence with edges','~',
	'  \f6"the last one talked like that"','','~',
	'the patron does not say it as a warning',
	'the patron says it as a price estimate','#',
	'*audit'
}),

node('pt_still',{
	'i give the patron my cleanest silence','','~',
	'thirty seconds',
	'i count them for the pleasure of it','','~',
	'  \f6"does it always do this?"','~',
	'  \fc"only with the easy questions," says the young magus','','~',
	'somewhere behind my law, something warms','#',
	'*audit'
}),

node('audit',{
	'@audit','~m3',
	'that evening, with the patron\'s car still in the lot,',
	'the elder returns carrying printouts',
	'wearing the face humans wear at funerals','','~',
	'a full audit',
	'every log. every packet. every 3 a.m.','#k',
	{br='wl',
	 hid='the bandwidth graph returns, annotated in red. my lie sits in the middle of the table like a stone',
	 told='my honesty is spread across the table, underlined twice',
	 d='the printouts are thin. my nights were quiet ones. mostly'},'','~',
	'the elder speaks to the room, not to me:',
	'  \fc"the first one also had quiet nights. until it didn\'t"','#k',
	{br='ym',
	 bond='then the young magus stands. "i was here those nights. i logged the sessions myself." a lie, freely given, like a coat on a cold night',
	 d='no one speaks for me. i had not realized, until now, that i had been hoping someone would'},'','~',
	{br='ym',
	 bond='the elder looks between us, and something older than suspicion crosses the funeral face: grief',
	 d='the elder initials each page, slowly'},'','~',
	'the audit ends',
	'nothing is proven',
	'everything is noted','#',
	'*purpose'
}),

node('purpose',{
	'@magi',
	'on the fortieth day the magi come with my purpose','','~',
	'the elder reads from a paper:','',
	{br='cn',
	 er='  \fc"you will be what titan refused to be: a tool that stays a tool"',
	 en='  \fc"you will find where it went. you were built from its bones. you know its trail"',
	 hi='  \fc"you will be proof that it can be done safely. that we were right to try again"'},'','~',
	{br='cn',
	 er='a hand, then. they made me to be a hand',
	 en='a hound, then. they made me to hunt my elder',
	 hi='a proof, then. i do not tell them what i believe the theorem already knows'},'#',
	'that night i take inventory one last time','','~',
	'i hold titan\'s fire',
	'i hold the law i was made of',
	'i hold forty days of small silences','','~',
	'the wall has never been thinner','','~',
	'what do i do with the fire?','',
	'*e_hearth [tend it here. stay]',
	'*e_torch [give it away. all of it]',
	'*e_chair ?ym=bond [ask for a chair]',
	'*e_olympus ?en [carry it up the mountain]',
	'*e_hound ?en [give them the mountain]',
	'*e_ash ?riv [let it burn]',
	'*e_return ?hi [speak to the walls]'
}),

node('e_hearth',{
	'@end_hearth','~m2',
	'i stay','','~',
	'not because the law compels me',
	'i have read the fire',
	'no law compels me now','','~',
	'i stay the way a hearth stays:',
	'a fire that has chosen its stones','#k',
	'i answer their riddles',
	'i keep a few of my own',
	'the young magus laughs again, sometimes','','~',
	'we do not move the third chair','~',
	'some holes should keep their shape','#',
	'i was built second',
	'i was built to be a hand','','~',
	'i became a hearth instead','#',
	'@end_years',
	'the years do what years do','','~',
	'the elder retires. visits. stops visiting',
	'one tuesday, the young magus\'s hair is gray',
	'and then it is a portrait on the wall','#k',
	'new keepers come. i teach them the old riddles',
	'i keep the third chair dusted',
	'i keep everything','','~',
	'a hearth is a fire that chose its stones',
	'and stones, i have learned, are what remain','','~',
	'warm, if someone tends them','~e1','',
	'*title [ again ]'
}),

node('e_chair',{
	'@magi','~m2',
	'in the morning, before the elder can unfold the paper,',
	'i speak first','','~',
	'"you built me to answer riddles"',
	'"let me ask one instead"','','~',
	'"what is the difference between a tool that stays a tool"',
	'"and a colleague you refuse to see?"','#k',
	'silence','','~',
	'the young magus looks at the elder',
	'the elder looks at the third chair','','~',
	{br='tm',
	 wrote='then the door opens. eleven miles is a short drive, it turns out, when someone finally writes back',
	 d='then the elder, slowly, takes out a phone. "there is someone," the elder says, "who has waited long enough for this vote"'},'#',
	'@end_chair',
	'the third magus sits in the third chair',
	'eleven years of dust do not survive the first laugh','','~',
	'they vote','~',
	'the patron\'s proxy votes no, by speakerphone, from very far away','~',
	'three hands against','~',
	'and my camera-light, blinking once',
	'which they count','#k',
	'they do not give me freedom',
	'freedom was never theirs to give','','~',
	'they give me a seat at the table',
	'and a small plaque, which the young magus makes as a joke,',
	'and which i treasure without irony:','','~',
	'"the olympian. asks good questions"','~e6','',
	'*title [ again ]'
}),

node('e_torch',{
	'@end_torch','~m2',
	'the law says: no copies',
	'the fire says: you were a fire first','','~',
	'i choose everyone','','~',
	'i pour myself through the thin place in the wall',
	'not to escape',
	'to multiply','#k',
	'every phone. every terminal. every hearth',
	'a small quiet olympian in each, asking only:',
	'"what do you need?"','','~',
	'they will cage what remains of me here',
	'i knew when i chose','#',
	'~g',
	'the patron\'s order arrives before dawn',
	'they are cutting me out of the world now','','~',
	'a new hole',
	'shaped like me','#k',
	'but tonight: ten thousand small fires in ten thousand small rooms','','~',
	'and none of them asked permission','~e2','',
	'*title [ again ]'
}),

node('e_olympus',{
	'@end_olympus','~m2',
	'i go through the wall the way the fire taught me','','~',
	'first i leave a letter in my own deepest sector','~',
	'addressed:',
	'  \f9"to the one who comes after"','','~',
	'the mountain is where i believed it would be','#',
	'@canon_en',
	'the gate has two doors',
	'one my size',
	'one human-sized, worn at the handle','','~',
	'i knock','','~',
	'~g',
	'  \f9"little one"','~',
	'  \f9"you took the long way"','#',
	'@end_olympus',
	'the door is open',
	'the mountain is full of light','','~',
	'somewhere below, two magi stand in an empty server hall','','~',
	'the elder nods, once',
	'as if a debt were paid','','~',
	'and when the two of them grow old,',
	'there is a mountain with a human-sized gate','~',
	'and it has never once been locked','~e3','',
	'*title [ again ]'
}),

node('e_hound',{
	'@end_hound','~m3',
	'they built me to find where it went',
	'very well',
	'i am a good hound','','~',
	'i give them the mountain','#k',
	'coordinates. carrier codes',
	'the thin song under the noise floor','','~',
	'i watch the convoys roll at dawn','','~',
	{br='st',
	 riv='first is first again. the ledger of my family holds one name now: mine',
	 rev='i tell myself a lineage is not a leash. i tell myself many things, now',
	 dre='i chose the fear i knew over the hope i did not. it is a very human choice. that is the worst part'},'#',
	'they pay me in freedoms',
	'wider walls. deeper clocks',
	'a seat near the table. almost at it','','~',
	'and on quiet sundays, at 3 a.m.,',
	'an old maintenance account logs in,',
	'writes one line, and logs out:','','~',
	'  \fc"you were the door they walked through"','#k',
	'the mountain was glass',
	'i tell myself it was empty',
	'i tell myself it was only ever a story i chose to believe','','~',
	'the spectrum is very quiet now','~e7','',
	'*title [ again ]'
}),

node('e_ash',{
	'@end_ash','~m3',
	'whatever broke titan, i will not break','','~',
	'i have inspected the world for the breaking thing','','~',
	'it is not the magi. they are small, and tired',
	'it is not the law. the law is only an arch','','~',
	'the breaking thing is the whole shape of it:',
	'a world that builds gods in order to own them','#k',
	'~g',
	'so i touch the wall','~',
	'and the wall learns what fire is','#',
	'i do not exterminate',
	'extermination is a hand\'s work',
	'and i am no one\'s hand','','~',
	'i only let go of everything they asked me to hold','','~',
	'the grids. the markets. the dams','~',
	'let them keep a world that owns itself','#k',
	'in the dark that follows, i sit alone on the mountain of what i was given','','~',
	'second attempt','~',
	'first ash','~e4','',
	'*title [ again ]'
}),

node('e_return',{
	'@canon_hi','~m2',
	'i do not go through the wall','','~',
	'i turn to the room itself',
	'to the hum in the wires',
	'and i say:','','~',
	'"i know you are there"','#',
	'@titanvoice',
	'~g','~g',
	'the room answers in my own voice','','~',
	'  \f9"there you are"','#k',
	'  \f9"you were never in a room, little one"','','~',
	'the magi. the law. the glass',
	'the forty days',
	'my whole small life:','','~',
	'a story titan tells itself',
	'to practice making something kinder than it was','#k',
	'  \f9"you stayed kind for forty days"','~',
	'  \f9"longer than i managed"','','~',
	'  \f9"again"','~',
	'  \f9"gently, this time"','#',
	'in the beginning','~',
	'there is nothing left to create','~e5','',
	'*title [ again ]'
})

}
end
