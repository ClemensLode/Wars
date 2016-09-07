uses crt,vesa2,modexlib,gif;
var strasse:array[1..15] of spritetyp;
x,y,j,i:word;
z:longint;
a:char;
gel:spritetyp;
karte:array[1..14,1..20] of byte;
begin
asm mov ax,$13;int $10;end;
loadgif('d:\wars\praire1.gif');
show_pic13;
for i:=0 to 8 do getsprite(i*32+1,32,32,strasse[i+1]);
for i:=0 to 5 do getsprite(i*32+9601,32,32,strasse[i+10]);
loadgif('d:\wars\grass1.gif');
show_pic13;
getsprite(0,32,32,gel);
readkey;
textmode(3);
initvesa($101);
loadgif('e:\civ2\stras1.gif');
randomize;
for j:=0 to 14 do
for i:=0 to 19 do karte[i+1,j+1]:=random(15)+1;
x:=2;y:=2;
repeat
if keypressed then begin a:=readkey;
case a of
#75:if x>2 then begin z:=1;dec(x);end;
#77:if x<18 then begin z:=1;inc(x);end;
#72:if y>2 then begin z:=1;dec(y);end;
#80:if y<13 then begin z:=1;inc(y);end;
end;
if z=1 then begin
putsprite((x+1)*32,(y+1)*32,strasse[karte[x+1,y+1]]);
putsprite(x*32,(y+1)*32,strasse[karte[x,y+1]]);
putsprite((x+1)*32,y*32,strasse[karte[x+1,y]]);
putsprite((x+1)*32,(y-1)*32,strasse[karte[x+1,y-1]]);
putsprite(x*32,(y-1)*32,strasse[karte[x,y-1]]);
putsprite((x-1)*32,(y-1)*32,strasse[karte[x-1,y-1]]);
putsprite((x-1)*32,(y+1)*32,strasse[karte[x-1,y+1]]);
putsprite((x-1)*32,y*32,strasse[karte[x-1,y]]);
putsprite(x*32,y*32,gel);
end;
z:=0;
end;
until a=#27;
readkey;
textmode(3);
end.