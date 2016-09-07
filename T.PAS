px,py: Aktuelle Position beim Gehen (wird zu ax,ay dazugezaehlt)
x,y: Aktuelle Position in Kaestchen
aphase: Aktuelle Spritephase
gpx,gpy: Aktuelle Gehrichtung (NUR fuer px,py)
gx,gy: Aktuelle Gehrichtung in Kaestchen (NUR fuer x,y)
lf:array[1..16] of record
x,y:byte;
end; {die letzten beschrittenen Felder... um nicht im Kreis zu laufen...}
ogx,ogy: Hauptrichtung. Bei bestimmten Situationen bewegt sich die Einheit
in diese Richtung.
cx,cy:Ziel



repeat
inc(px,gpx);inc(py,gpy);
if (abs(px)=16) and (abs(py)=8) then begin
inc(x,gx);inc(y,gy);
px:=-gx*16;py:=-gy*8;
kreuzung;       {aendert gx,gy,gpx,gpy}
end;

procedure kreuzung;
begin
if x>cx then tgx:=-1 else
if x=cx then tgx:=0 else
if x<cx then tgx:=1;
if y>cy then tgy:=-1 else
if y=cy then tgy:=0 else
if y<cy then tgy:=1;
if karte[x+tgx,y+tgy]=0 then begin
gx:=tgx;gy:=tgy;
pgx:=tgx-tgy;



function washere(num,ix,iy:byte):boolean;
begin
with spieler[num] do begin
for i:=1 to 16 do if (lf[i].x=ix) and (lf[i].y=iy) then begin washere:=true;exit;end;
end;
washere:=false;
end;