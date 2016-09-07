uses crt,vesa6,modexlib,gif;
var
x,y:word;
i,j:integer;
z:longint;
a:char;
over:array[1..8,1..10] of spritetyp;
gel:array[0..4,0..3] of spritetyp;
karte:array[1..25,1..25] of record
zahler,overart,overnum,art,num:byte;
y:longint;
end;
fluss:array[1..11] of spritetyp;
reg:array[1..8,1..8] of spritetyp;
geb:array[1..4,1..4] of spritetyp;
begin
asm mov ax,$13;int $10;end;
loadgif('d:\wars\winter3.gif');
show_pic13;
for i:=0 to 8 do getsprite(i*32+1,32,32,gel[1,i+1]);
loadgif('d:\wars\grass3.gif');
show_pic13;
for i:=0 to 8 do getsprite(i*32+1,32,32,gel[2,i+1]);
loadgif('d:\wars\praire3.gif');
show_pic13;
for i:=0 to 8 do getsprite(i*32+1,32,32,gel[3,i+1]);
loadgif('d:\wars\desert3.gif');
show_pic13;
for i:=0 to 8 do getsprite(i*32+1,32,32,gel[4,i+1]);
loadgif('e:\civ2\over.gif');
show_pic13;
for i:=0 to 7 do getsprite(i*32+1+i+200,32,32,over[1,i+1]);
for i:=0 to 7 do getsprite(i*32+1+i+200,32,32,over[2,i+1]);
for i:=0 to 7 do getsprite(i*32+1+i+200,32,32,over[3,i+1]);
loadgif('d:\wars\fluss.gif');
show_pic13;
getsprite(0,64,32,fluss[1]);
getsprite(64,64,32,fluss[2]);
getsprite(128,64,32,fluss[3]);
getsprite(192,64,32,fluss[4]);
getsprite(256,64,32,fluss[5]);
getsprite(0+32*320,64,32,fluss[6]);
getsprite(64+32*320,64,32,fluss[7]);
getsprite(128+32*320,64,32,fluss[8]);
getsprite(192+32*320,64,32,fluss[9]);
getsprite(256+32*320,64,32,fluss[10]);
{loadgif('d:\wars\over.gif');
show_pic13;                  }
for i:=0 to 4 do for j:=0 to 3 do getsprite(i*128+96*320+j*64,128,64,gel[i,j]);
{getsprite(0,65,96,geb[1]);
{getsprite(97*320,128,64,geb[2]);}
loadgif('e:\civ2\regen.gif');
show_pic13;
for i:=0 to 3 do
for j:=0 to 5 do getsprite((j+i*320)*32,32,32,reg[i+1,j+1]);
for j:=0 to 5 do getsprite((j+140*320)*32,32,32,reg[5,j+1]);
textmode(3);
initvesa($101);
{loadgif('e:\civ2\stras3.gif');
for j:=-8 to 8 do for i:=0 to 8 do putsprite(i*64,i*32+j*64,gel[random(5),random(4)]);
{for j:=-8 to 8 do for i:=0 to 2 do putsprite(i*64+32,i*32+j*64+16,geb[1]);}
{for j:=1 to 30 do begin i:=random(9);putsprite(i*64+32,i*32+(random(15)-8)*64+16,geb[1]);end;}
readkey;
randomize;
for j:=0 to 14 do
for i:=0 to 19 do karte[i+1,j+1].num:=random(8)+1;
for j:=0 to 2 do
for i:=0 to 19 do karte[i+1,j+1].art:=1;
for j:=3 to 5 do
for i:=0 to 19 do karte[i+1,j+1].art:=2;
for j:=6 to 8 do
for i:=0 to 19 do karte[i+1,j+1].art:=3;
for j:=9 to 11 do
for i:=0 to 19 do karte[i+1,j+1].art:=4;
for j:=12 to 14 do
for i:=0 to 19 do karte[i+1,j+1].art:=2;
for j:=0 to 14 do
for i:=0 to 19 do karte[i+1,j+1].overart:=2;

for j:=0 to 14 do
for i:=0 to 19 do karte[i+1,j+1].overnum:=random(5)+1;
for j:=0 to 14 do
for i:=0 to 19 do karte[i+1,j+1].zahler:=random(30);

x:=2;y:=2;
for j:=0 to 14 do
for i:=0 to 19 do putsprite((i+1)*32,(j+1)*32,gel[karte[i+1,j+1].art,karte[i+1,j+1].num]);
repeat
{inc(z);
waitretrace;
{for i:=0 to 9 do putsprite(i*64,100,fluss[z mod 10+1]);}
{for i:=0 to 9 do putsprite(i*64,32,fluss[z mod 2+1]);}
if keypressed then begin a:=readkey;
case a of
#75:if x>2 then begin z:=99;dec(x);end;
#77:if x<18 then begin z:=99;inc(x);end;
#72:if y>2 then begin z:=99;dec(y);end;
#80:if y<13 then begin z:=99;inc(y);end;
'a':for j:=0 to 14 do for i:=0 to 19 do karte[i+1,j+1].art:=1;
'b':for j:=0 to 14 do for i:=0 to 19 do karte[i+1,j+1].art:=2;
'c':for j:=0 to 14 do for i:=0 to 19 do karte[i+1,j+1].art:=3;
'd':for j:=0 to 14 do for i:=0 to 19 do karte[i+1,j+1].art:=4;
end;
{for i:=0 to 9 do putsprite(i*64,128,fluss[2]);
for i:=0 to 9 do putsprite(i*64,224,fluss[3]);
for i:=0 to 9 do putsprite(i*64,224,fluss[4]);}
putsprite((x+1)*32,(y+1)*32,gel[karte[x+1,y+1].art,karte[x+1,y+1].num]);
putsprite(x*32,(y+1)*32,gel[karte[x,y+1].art,karte[x,y+1].num]);
putsprite((x+1)*32,y*32,gel[karte[x+1,y].art,karte[x+1,y].num]);
putsprite((x+1)*32,(y-1)*32,gel[karte[x+1,y-1].art,karte[x+1,y-1].num]);
putsprite(x*32,(y-1)*32,gel[karte[x,y-1].art,karte[x,y-1].num]);
putsprite((x-1)*32,(y-1)*32,gel[karte[x-1,y-1].art,karte[x-1,y-1].num]);
putsprite((x-1)*32,(y+1)*32,gel[karte[x-1,y+1].art,karte[x-1,y+1].num]);
putsprite((x-1)*32,y*32,gel[karte[x-1,y].art,karte[x-1,y].num]);
{for i:=0 to 7 do putsprite(i*80,1,geb[1]);
{putsprite((x+1)*32,(y+1)*32,reg[karte[x+1,y+1].overart,karte[x+1,y+1].overnum]);
putsprite(x*32,(y+1)*32,reg[karte[x,y+1].overart,karte[x,y+1].overnum]);
putsprite((x+1)*32,y*32,reg[karte[x+1,y].overart,karte[x+1,y].overnum]);
putsprite((x+1)*32,(y-1)*32,reg[karte[x+1,y-1].overart,karte[x+1,y-1].overnum]);
putsprite(x*32,(y-1)*32,reg[karte[x,y-1].overart,karte[x,y-1].overnum]);
putsprite((x-1)*32,(y-1)*32,reg[karte[x-1,y-1].overart,karte[x-1,y-1].overnum]);
putsprite((x-1)*32,(y+1)*32,reg[karte[x-1,y+1].overart,karte[x-1,y+1].overnum]);
putsprite((x-1)*32,y*32,reg[karte[x-1,y].overart,karte[x-1,y].overnum]);
{putsprite((i+1)*32,(j+1)*32,reg[karte[i+1,j+1].overart,karte[i+1,j+1].overnum]);}
{putsprite(x*32,(y+1)*32,reg[karte[x,y+1].overart,karte[x,y+1].overnum]);
putsprite((x+1)*32,y*32,reg[karte[x+1,y].overart,karte[x+1,y].overnum]);
putsprite((x+1)*32,(y-1)*32,reg[karte[x+1,y-1].overart,karte[x+1,y-1].overnum]);
putsprite(x*32,(y-1)*32,reg[karte[x,y-1].overart,karte[x,y-1].overnum]);
putsprite((x-1)*32,(y-1)*32,reg[karte[x-1,y-1].overart,karte[x-1,y-1].overnum]);
putsprite((x-1)*32,(y+1)*32,reg[karte[x-1,y+1].overart,karte[x-1,y+1].overnum]);
putsprite((x-1)*32,y*32,reg[karte[x-1,y].overart,karte[x-1,y].overnum]);
{putsprite((x+1)*32,(y+1)*32,over[karte[x+1,y+1].overart,karte[x+1,y+1].overnum]);
putsprite(x*32,(y+1)*32,over[karte[x,y+1].overart,karte[x,y+1].overnum]);
putsprite((x+1)*32,y*32,over[karte[x+1,y].overart,karte[x+1,y].overnum]);
putsprite((x+1)*32,(y-1)*32,over[karte[x+1,y-1].overart,karte[x+1,y-1].overnum]);
putsprite(x*32,(y-1)*32,over[karte[x,y-1].overart,karte[x,y-1].overnum]);
putsprite((x-1)*32,(y-1)*32,over[karte[x-1,y-1].overart,karte[x-1,y-1].overnum]);
putsprite((x-1)*32,(y+1)*32,over[karte[x-1,y+1].overart,karte[x-1,y+1].overnum]);
putsprite((x-1)*32,y*32,over[karte[x-1,y].overart,karte[x-1,y].overnum]);}
{end;}
end;
until a=#27;
readkey;
textmode(3);
end.


{bei 320*200 y Koordinate mit 320 multiplizieren !!!!!}