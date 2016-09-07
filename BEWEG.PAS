uses crt;
type einheit=record
dx,dy,cx,cy,x,y:word;
gx,gy:shortint;
message:boolean;
marke:array[1..25] of record
gx,gy:shortint;
x,y:word;
end;
end;
var spieler:array[1..100] of einheit;
i,j:word;
markz,num:byte;
karte:array[1..100,1..100] of boolean;
procedure marker;
begin
with spieler[num] do begin
marke[markz].x:=x;marke[markz].x:=y;
marke[markz].gx:=-gx;
marke[markz].gy:=-gy;
inc(markz);
end;
end;

procedure golastmark;
begin
with spieler[num] do begin
dec(markz);
dx:=cx;dy:=cy;
cx:=marke[markz].x;cy:=marke[markz].y;
end;
end;

procedure go;
begin
 with spieler[num] do begin
   if (marke[markz].x=x) and (marke[markz].y=y) then begin {Auf marke gestossen}
   gx:=marke[markz].gx;gy:=marke[markz].gy;
   inc(markz);
   cx:=marke[markz].x;cy:=marke[markz].y;
   end;
   if (x<>cx) or (y<>cy) then begin
   if (x>cx) and (gx<1) then gx:=-1 else
   if x=cx               then gx:=0  else
   if (x<cx) and (gx>-1)  then gx:=1;
   if (y>cy) and (gy<1) then gy:=-1 else
   if y=cy               then gy:=0  else
   if (y<cy) and (gy>-1)  then gy:=1;
   end else
   if (x=cx) and (y=cy) then begin
    gx:=marke[markz].gx;gy:=marke[markz].gy;
    inc(markz);
    cx:=marke[markz].x;cy:=marke[markz].y;
    exit;
   end;
   if karte[x+gx,y+gy]=false then begin inc(x,gx);inc(y,gy);end else
   begin
    if (abs(gx)>0) and (gy=0) then begin
     if karte[x+gx,y+1]=false then begin inc(x,gx);inc(y,1);end else
     if karte[x+gx,y-1]=false then begin inc(x,gx);dec(y,1);end else message:=true;
    end else
    if (abs(gy)>0) and (gx=0) then begin
     if karte[x+1,y+gy]=false then begin inc(x,1);inc(y,gy);end else
     if karte[x-1,y+gy]=false then begin dec(x,1);inc(y,gy);end else message:=true;
    end else
    if (abs(gy)>0) and (abs(gx)>0) then begin
     if karte[x+gx,y]=false then begin inc(x,gx);end else
     if karte[x,y+gy]=false then begin inc(y,gy);end else message:=true;
    end else begin          {Einheit steht !? >>> Wartet wahrscheinlich... }
     if message=false then message:=true; {Zu huelf' ich steck fest!}
    end;
   end;
end;
end;
procedure Findway;
var ox,oy,ocx,ocy,odx,ody:word;ogy,ogx:shortint;
begin
 with spieler[num] do begin
  ox:=x;oy:=y;
  ocx:=cx;ocy:=cy;
  odx:=dx;ody:=dy;
  ogx:=gx;ogy:=gy;
  while (dx=0) and (dy=0) and ((x<>cx) or (y<>cy)) do begin
   if (x>cx) and (gx<1) then gx:=-1 else
   if x=cx               then gx:=0  else
   if (x<cx) and (gx>-1)  then gx:=1;
   if (y>cy) and (gy<1) then gy:=-1 else
   if y=cy               then gy:=0  else
   if (y<cy) and (gy>-1)  then gy:=1;
   if (dx>0) and (x=cx) and (y=cy) then begin
    cx:=dx;cy:=dy;dx:=0;dy:=0;      {Waypoint erreicht!}
    gx:=marke[markz].gx;gy:=marke[markz].gy;
   end;
   if karte[x+gx,y+gy]=false then begin inc(x,gx);inc(y,gy);end else
   begin
    if (abs(gx)>0) and (gy=0) then begin
     if karte[x+gx,y+1]=false then begin inc(x,gx);inc(y,1);end else
     if karte[x+gx,y-1]=false then begin inc(x,gx);dec(y,1);end else
     if (karte[x,y+1]=false) then begin gx:=0;gy:=1;marker;end else
     if (karte[x,y-1]=false) then begin gx:=0;gy:=-1;marker;end else
     golastmark;
    end else
    if (abs(gy)>0) and (gx=0) then begin
     if karte[x+1,y+gy]=false then begin inc(x,1);inc(y,gy);end else
     if karte[x-1,y+gy]=false then begin dec(x,1);inc(y,gy);end else
     if (karte[x+1,y]=false) then begin gy:=0;gx:=1;marker;end else
     if (karte[x-1,y]=false) then begin gy:=0;gx:=-1;marker;end else
     golastmark;
    end else
    if (abs(gy)>0) and (abs(gx)>0) then begin
     if karte[x+gx,y]=false then begin inc(x,gx);end else
     if karte[x,y+gy]=false then begin inc(y,gy);end else
     if (karte[x+gx,y-gy]=false) then begin gy:=-gy;marker;end else
     if (karte[x-gx,y+gy]=false) then begin gx:=-gx;marker;end else
     golastmark;
    end else begin          {Einheit steht !? >>> Wartet wahrscheinlich... }
     if message=false then message:=true; {Zu huelf' ich steck fest!}
    end;
   end;
  gotoxy(x,y);
  write(#2);
  end;
  for i:=1 to 25 do begin gotoxy(marke[i].x,marke[i].y);write('M');end;
  markz:=1;
  x:=ox;y:=oy;
  cx:=ocx;cy:=ocy;
  dx:=odx;dy:=ody;
  gx:=ogx;gy:=ogy;
 end;            {Nun ist "marke" mit dem entgueltigen Weg "gefuettert"}
end;
begin
num:=10;
randomize;
with spieler[num] do begin
x:=random(80);y:=random(25);
cx:=random(80);cy:=random(25);
gx:=0;gy:=0;
message:=false;
end;
clrscr;
for i:=1 to 80 do for j:=1 to 25 do if random(10)=0 then karte[i,j]:=true else karte[i,j]:=false;
for i:=1 to 80 do for j:=1 to 24 do if karte[i,j]=false then write(' ') else write('@');
gotoxy(1,1);
findway;
readln;
clrscr;
repeat
num:=10;
with spieler[num] do begin
if message then begin sound(100);delay(10);nosound;message:=false;end;
go;
gotoxy(1,1);
for i:=1 to 80 do for j:=1 to 24 do if karte[i,j]=false then write(' ') else write('@');
gotoxy(x,y);
write(#1);
end;
delay(200);
until keypressed;
end.
