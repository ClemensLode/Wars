uses crt,sprites,modexlib,gif;
const all=500;
var
ei:array[1..all] of record
ax,ay,
bx,by,
cx,cy,
dx,dy:word;
haupt,holzer,gold,baum:boolean;
wait,gx,gy,px,py:integer;end;
a:char;
ix,iy,baums,leute,muenzen,seite,z,zz,tempus2,xe,ye,mp,mx,my,c,temp,temp2:word;
sprite:array[1..10] of spritetyp;
mp1d,mp2d:boolean;
map:array[1..32,1..20] of byte;
aks:array[1..all] of boolean;
haus:array[1..100] of record
x,y,art:byte;end;
baumland:array[1..32,1..20] of boolean;
Procedure PutPix(x,y,col:word);assembler;
asm
  mov ax,0a000h                 {Segment laden}
  mov es,ax
  mov cx,x                      {Write Plane bestimmen}
  and cx,3                      {als x mov 4}
  mov ax,1
  shl ax,cl                     {entsprechendes Bit setzen}
  mov ah,al
  mov dx,03c4h                  {Timing Sequenzer}
  mov al,2                      {Register 2 - Write Plane Mask}
  out dx,ax
  mov ax,80                     {Offset = Y*80 + X div 4}
  mul y
  mov di,ax
  mov ax,x
  shr ax,2
  add di,ax                     {Offset laden}
  add di,seite
  mov al,byte ptr col           {Farbe laden}
  mov es:[di],al                {und Punkt setzen}
End;
procedure quad(x1,x2,y1,y2:word);
var txx,tempus:word;
begin
if x1>x2 then begin tempus:=x2;x2:=x1;x1:=tempus;end;
if y1>y2 then begin tempus:=y2;y2:=y1;y1:=tempus;end;
for txx:=x1 to x2 do putpix(txx,y1,10);
for txx:=y1 to y2 do putpix(x2,txx,10);
for txx:=x2 downto x1 do putpix(txx,y2,10);
for txx:=y2 downto y1 do putpix(x1,txx,10);
end;
procedure pruf(e:word);
var abx,aby,ver,tx,ty:integer;t,o:boolean;s:shortint;
begin
if ei[e].bx<ei[e].cx then ei[e].px:=1;
if ei[e].bx=ei[e].cx then ei[e].px:=0;
if ei[e].bx>ei[e].cx then ei[e].px:=-1;
if ei[e].by<ei[e].cy then ei[e].py:=1;
if ei[e].by=ei[e].cy then ei[e].py:=0;
if ei[e].by>ei[e].cy then ei[e].py:=-1;
tx:=ei[e].px;ty:=ei[e].py;
abx:=tx;aby:=ty;
o:=false;
{while (ver<9000) and (map[ei[e].bx+tx,ei[e].by+ty]=1) do begin                {besetzt ?}
{tx:=random(3)-2;
ty:=random(3)-2;
{inc(ver);}
{if map[ei[e].bx+tx,ei[e].by+ty]=0 then ver:=9000;
{if ver>=89 then ei[e].wait:=10;}
{end;}
if map[ei[e].bx+tx,ei[e].by+ty]=0 then begin ei[e].px:=tx;ei[e].py:=ty;end
else if map[ei[e].bx+tx,ei[e].by+ty]=1 then begin
if map[ei[e].bx+tx,ei[e].by]=0 then begin
ei[e].px:=tx;ei[e].py:=0;end else
if map[ei[e].bx,ei[e].by+ty]=0 then begin
ei[e].px:=0;ei[e].py:=ty;end else if ((tx<>0) or (ty<>0)) and ((ei[e].bx<>ei[e].cx) and (ei[e].by<>ei[e].cy)) then begin
if map[ei[e].bx+tx,ei[e].by-1]=0 then begin
ei[e].px:=tx;ei[e].py:=-1;end else
if map[ei[e].bx+tx,ei[e].by+1]=0 then begin
ei[e].px:=tx;ei[e].py:=1;end else
if map[ei[e].bx+1,ei[e].by+ty]=0 then begin
ei[e].px:=1;ei[e].py:=ty;end else
if map[ei[e].bx-1,ei[e].by+ty]=0 then begin
ei[e].px:=-1;ei[e].py:=ty;end else
if map[ei[e].bx+ty,ei[e].by+tx]=0 then begin
ei[e].px:=ty;ei[e].py:=tx;end;end else begin
ei[e].px:=0;ei[e].py:=0;ei[e].wait:=10;end;end;
{if map[ei[e].bx+tx,ei[e].by]=0 then begin
ei[e].px:=-tx;ei[e].py:=0;end else
if map[ei[e].bx+tx,ei[e].by]=0 then begin
ei[e].px:=0;ei[e].py:=-ty;end else
if map[ei[e].bx+tx,ei[e].by]=0 then begin
ei[e].px:=tx;ei[e].py:=0;end else
if map[ei[e].bx+tx,ei[e].by]=0 then begin
ei[e].px:=tx;ei[e].py:=0;end else
if map[ei[e].bx+tx,ei[e].by]=0 then begin
ei[e].px:=tx;ei[e].py:=0;end else}



{ei[e].px:=tx;ei[e].py:=ty;}
end;
  procedure kasten;
  begin
  if mp=1 then begin
   if mp1d=false then mp2d:=true;
   if mp2d then begin mp2d:=false;xe:=mx;ye:=my;end;
   quad(Xe,mx,ye,my);
   mp1d:=true;
  end;
  if ((mp=0) and mp1d) then begin
   mp1d:=false;
   if mx<xe then begin tempus2:=xe;xe:=mx;mx:=tempus2;end;
   if my<ye then begin tempus2:=ye;ye:=my;my:=tempus2;end;
      for z:=1 to leute do begin
    if (mx>ei[z].ax*10+ei[z].gx) and (xe<ei[z].ax*10+ei[z].gx) and (my>ei[z].ay*10+ei[z].gy) and (ye<ei[z].ay*10+ei[z].gy)
    then aks[z]:=true else aks[z]:=false;end;end;
end;
procedure newone(wer:byte);
begin
with ei[wer] do begin
ax:=haus[1].x;
ay:=haus[1].y;
bx:=ax-1;
by:=ay-1;
px:=-1;
py:=-1;
cx:=haus[1].x;
cy:=haus[1].y;
dx:=haus[2].x;
dy:=haus[2].y;
wait:=244;
gold:=false;
end;end;
procedure bew;
begin
for c:=1 to leute do begin with ei[c] do begin
if aks[c] then putsprite(seite,ax*10+gx,ay*10+gy,sprite[1]) else putsprite(seite,ax*10+gx,ay*10+gy,sprite[2]);
if wait<244 then dec(wait);
if (wait<0) or (wait=244) then begin
if baumland[ax,ay] then begin inc(gx,px*2);inc(gy,py*2);end else begin inc(gx,px*5);inc(gy,py*5);end;
if (gx=px*10) and (gy=py*10) then begin
gx:=0;
gy:=0;
map[ax,ay]:=0;
ax:=bx;
ay:=by;
pruf(c);
{if (pruf(c)=false) and (wait=244) then wait:=10;}
if wait=-1 then wait:=244;
inc(bx,px);
inc(by,py);
if (bx=cx) and (by=cy) then begin
if holzer then begin
if baumland[cx+1,cy+1] then begin inc(cx);inc(cy);end;
if baumland[cx,cy+1] then begin inc(cy);end;
if baumland[cx-1,cy+1] then begin dec(cx);inc(cy);end;
if baumland[cx+1,cy] then begin inc(cx);end;
if baumland[cx-1,cy] then begin dec(cx);end;
if baumland[cx+1,cy-1] then begin inc(cx);dec(cy);end;
if baumland[cx,cy-1] then begin dec(cy);end;
if baumland[cx-1,cy-1] then begin dec(cx);dec(cy);end;
end;
if (cx=haus[2].x) and (cy=haus[2].y) then gold:=true;
if (cx=haus[1].x) and (cy=haus[1].y) then begin
HAUPT:=TRUE;
if gold then begin gold:=false;inc(muenzen);end;
if baum and not holzer then begin
holzer:=true;
baum:=false;inc(baums);end;
end else haupt:=false;
if baumland[bx,by] and (baum=false) then begin
wait:=0;
dx:=cx;dy:=cy;cx:=haus[1].x;holzer:=false;cy:=haus[1].y;baumland[bx,by]:=false;baum:=true;end;
if baum or gold or haupt then begin
temp:=cx;cx:=dx;dx:=temp;
temp:=cy;cy:=dy;dy:=temp;
end;
end;end;
end;
{if baum then begin
dx:=cx;
dy:=cy;
cx:=haus[1].x;
cy:=haus[1].y;end;}
map[ax,ay]:=1;
map[bx,by]:=1;
end;
end;
end;
begin
randomize;
asm mov ax,$00;int $33;end;
asm mov ax,$07;mov cx,1;mov dx,300;int $33;end;
asm mov ax,$08;mov cx,1;mov dx,180;int $33;end;
leute:=15;
for z:=2 to 30 do for zz:=1 to 20 do begin
if (zz mod 2=0) then baumland[z,zz]:=true else baumland[z,zz]:=false;
end;
haus[1].x:=1;haus[1].y:=3;haus[1].art:=6;
haus[2].x:=30;haus[2].y:=18;haus[2].art:=5;
for c:=1 to leute do with ei[c] do begin
ax:=random(25);
ay:=random(15);
bx:=ax+1;
by:=ay+1;
px:=1;
py:=1;
cx:=haus[1].x;
cy:=haus[1].y;
dx:=haus[2].x;
dy:=haus[2].y;
wait:=244;
gold:=true;
end;
muenzen:=2;
init_modex;
loadgif('d:\tp7\1.dat');
getsprite(111+59*320,9,9,sprite[1]);
getsprite(1+1*320,9,9,sprite[2]);
getsprite(1+11*320,9,9,sprite[3]);
getsprite(21+1*320,8,9,sprite[4]);
getsprite(29+1*320,9,9,sprite[5]);
getsprite(40+1*320,9,9,sprite[6]);
seite:=48000;
{for temp:=1 to 32 do for temp2:=1 to 200 do putpix(temp*10,temp2,1);
for temp:=1 to 320 do for temp2:=1 to 20 do putpix(temp,temp2*10,1);}
seite:=0;
repeat
asm mov ax,$03;int $33;mov mx,cx;mov my,dx;mov mp,bx;end;
if mx>320 then mx:=320;
if my>200 then my:=200;
waitretrace;
copyscreen(seite,48000);
putsprite(seite,mx,my,sprite[3]);
putsprite(seite,haus[1].x*10,haus[1].y*10,sprite[haus[1].art]);
putsprite(seite,haus[2].x*10,haus[2].y*10,sprite[haus[2].art]);
kasten;
bew;
{for c:=2 to 29 do begin
map[c,5]:=1;putsprite(seite,c*10,50,sprite[4]);end;}
if muenzen>0 then begin
for c:=1 to muenzen do putsprite(seite,c*2,1,sprite[5]);
end;
if baums>0 then begin
for c:=1 to baums do putsprite(seite,c*2,10,sprite[4]);
end;
for z:=1 to 32 do for zz:=1 to 20 do begin
if baumland[z,zz] then putsprite(seite,z*10,zz*10,sprite[4]);
end;
setstart(seite);
if seite=32000 then seite:=0 else seite:=32000;
if mp=1 then begin
if (mx div 10=haus[1].x) and (my div 10=haus[1].y) then begin
if (muenzen>5) and (baums>0) then begin dec(baums);dec(muenzen,5);inc(leute);newone(leute);end;
end;
end;
if mp=2 then begin
for z:=1 to leute do begin
with ei[z] do begin
if aks[z] then begin
cx:=mx div 10;
cy:=my div 10;
dx:=cx;
dy:=cy;
end;end;end;end;
if mp=3 then begin
for z:=1 to leute do begin
with ei[z] do begin
if aks[z] then begin
cx:=mx div 10;
cy:=my div 10;
dx:=haus[2].x;
dy:=haus[2].y;
end;end;end;end;
if keypressed then begin
a:=readkey;
case a of
's':begin for z:=1 to leute do begin if aks[z] then begin with ei[z] do begin cx:=bx;cy:=by;dx:=cx;dy:=cy;end;end;end;end;
'e':for z:=1 to leute do aks[z]:=true;
end;
end;
{for ix:=1 to 32 do for iy:=1 to 20 do if baumland[ix,iy] then map[ix,iy]:=1;}
until a=#27;
end.
