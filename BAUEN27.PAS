uses crt,dos,modexlib,gif{fontes},vesa2,{tools,}variab2,{intro,}rohbau2;
procedure initsprites;
begin
  screen_off;
  init_mode13;
{  loadone('rost5.gif',7,20);}
  loadgif('rost.gif');
  for i:=0 to mh-1 do getsprite(i*10+10*320,10,10,spr[i]);
  for i:=0 to 5 do getsprite(i*4+30*320,4,5,qua[i]);
  for i:=1 to 15 do getsprite(i*10-10,10,10,roh[i]);
  for i:=0 to 12 do getsprite(i*10+20*320,10,10,zus[i]);
  for i:=0 to 10 do getsprite(i*10+40*320,10,10,gel[i]);
  for i:=13 to 17 do getsprite((i-13)*10+50*320,10,10,zus[i]);
  for i:=11 to 40 do getsprite((i-11)*10+60*320,10,10,gel[i]);
  loadgif('rost5.gif');
  show_pic13;
  for i:=1 to 15 do getsprite(i*20-20,20,20,roh[i]);
  loadgif('grass6.gif');
  show_pic13;
   for i:=0 to 25 do getsprite(i*20+17*320,20,20,gel[i+20]);
  for i:=0 to 25 do getsprite(i*20+17*320,20,20,gel[i+20]);
for i:=0 to 25 do getsprite(i*20+17*320,20,20,gel[i+20]);
getsprite(178*320,20,20,zus[3]);
getsprite(180*320+20,20,20,zus[4]);
getsprite(180*320+40,20,20,zus[5]);
getsprite(180*320+60,20,20,zus[6]);
getsprite(180*320+80,20,20,zus[7]);
for i:=0 to 3 do getsprite(i*20+97*320,20,20,gel[i]);
for i:=0 to 3 do getsprite(i*20+117*320,20,20,gel[i+4]);
for i:=0 to 3 do getsprite(i*20+137*320,20,20,gel[i+8]);
for i:=0 to 3 do getsprite(i*20+157*320,20,20,gel[i+12]);
for i:=0 to 3 do getsprite(i*20+77*320,20,20,gel[i+16]);
loadgif('felder.gif');
show_pic13;
for i:=0 to 3 do for m:=0 to 2 do getsprite(i*38+(m*38)*320,20,20,regen[i+1,m+1]);
textmode(3);
screen_on;
end;
procedure handler;interrupt;
begin
asm
   mov   dx,basis
   add   dx,$E
   in    al,dx
   sub   dx,2
@irq_bereit1:
   in    al,dx
   and   al,128
   jne   @irq_bereit1
   mov   al,14h
   out   dx,al
@irq_bereit2:
   in    al,dx
   and   al,128
   jne   @irq_bereit2
   mov   ax,blockgr
   out   dx,al
@irq_bereit3:
   in    al,dx
   and   al,128
   jne   @irq_bereit3
   mov   al,ah
   out   dx,al
end;
{If gross>3*blockgr then begin}
if block2 then begin
block2:=false;
if repeatet=false then read1:=true;
end else begin
block2:=true;
if repeatet=false then read2:=true;
end;
{end else
if (gross<=3*blockgr) then begin
close(f);
seek(h,0);
end;}
port[$20]:=$20;
end;
  procedure programexit;far;
   var qi:word;
   begin
  textmode(3);
  for qi:=0 to 41 do if spr[qi].adr<>nil then freemem(spr[qi].adr,spr[qi].dtx*spr[qi].dty);
  for qi:=0 to 6 do if qua[qi].adr<>nil then freemem(qua[qi].adr,qua[qi].dtx*qua[qi].dty);
  for qi:=0 to 13 do if zus[qi].adr<>nil then freemem(zus[qi].adr,zus[qi].dtx*zus[qi].dty);
  for qi:=0 to 21 do if roh[qi].adr<>nil then freemem(roh[qi].adr,roh[qi].dtx*roh[qi].dty);
  for qi:=0 to 142 do if gel[qi].adr<>nil then freemem(gel[qi].adr,gel[qi].dtx*gel[qi].dty);
  for qi:=0 to 142 do if gel2[qi].adr<>nil then freemem(gel2[qi].adr,gel2[qi].dtx*gel2[qi].dty);
  exitproc:=oldexit;
  for qi:=0 to 1 do if s[qi]<>nil then freemem(s[qi],sizeof(s[qi]));
  writeln('Programm beendet. Speicher freigegeben. Soundkarte zurueckgesetzt.');
{    writedsp($D3);
    writedsp($DA);
    writedsp($D0);
    port[$6+basis]:=1;
    for qi:=1 to 256 do;
    port[$6+basis]:=0;
    asm
     cli
     push  es
     push  di
     mov   dx,irq
     mov   al,0d0h
     out   dx,al
     mov   ax,[WORD PTR oldintvec+0]
     mov   dx,[WORD PTR oldintvec+2]
     xor   di,di
     mov   es,di
     mov   di,irq
     shl   di,2
     add   di,20h
     mov   WORD PTR es:[di+0],ax
     mov   WORD PTR es:[di+2],dx
     mov   es,pn
     mov   ah,49h
     int   21h
     mov   dx,irq
     mov   al,0d3h
     out   dx,al
     pop   di
     pop   es
     sti
    end;}
    port[$20]:=$20;
   end;
{   procedure initdma(buf:pointer;size2:word);
    begin
     physpos:=16*longint(pt(buf).segm)+pt(buf).ofs;
     pn:=pt(physpos).segm;
     offse:=pt(physpos).ofs;
     port[dmawr_single_mask_reg[dma]]:=5;
     port[dmawr_mode_reg[dma]]:=1 or $58;
     port[dma_adress[dma]]:=lo(offse);
     port[dma_adress[dma]]:=hi(offse);
     port[dma_lower_page[dma]]:=lo(pn);
     port[dma_higher_page[dma]]:=hi(pn);
     port[dmaclear_flipflop[dma]]:=0;
     port[dma_count[dma]]:=lo(size2*2-1);
     port[dma_count[dma]]:=hi(size2*2-1);
     writedsp($40);
     writedsp(256-1000000 div frequenz);
     writedsp($14);
     writedsp(lo(size2-1));
     writedsp(hi(size2-1));
     asm
      cli
      mov di,irq
      mov cx,di
      in al,$21
      mov bl,1
      shl bl,cl
      not bl
      and al,bl
      out $21,al
      mov ax,offset handler
      xor dx,dx
      mov es,dx
      mov dx,cs
      shl di,2
      add di,$20
      xchg ax,word ptr es:[di+0]
      xchg dx,word ptr es:[di+2]
      mov [word ptr oldintvec+0],ax
      mov [word ptr oldintvec+2],dx
      mov dx,basis
      add dx,$C
      sub dx,8
      mov al,$0e
      out dx,al
      inc dx
      in al,dx
      or al,2
      out dx,al
      sti
     end;
     port[dmawr_single_mask_reg[dma]]:=1;
    end;}
procedure showb;
var mmm,te,ykky,xkkx,posx,posy,mp,phase,nx,ny,kx,ky,kxx:word;mm:string;
mn:byte;
npaint:boolean;
begin
fa:=true;
initvesa($101);
loadgif('grass6.gif');
for kxx:=1 to max do begin
{mn:=artzusprite(s[m]^.haus[kxx].art);}
if (mn>0) and (mn<29) then begin
end;
end;
kx:=5;ky:=5;
{wx:=560;}
{page:=48000;}
for kx:=1 to kmx do for ky:=1 to kmy do karte[kx,ky].art:=random(2);
for kx:=1 to kmx do for ky:=1 to kmy do begin
mmm:=0;
mmm:=karte[kx,ky+1].art+karte[kx,ky-1].art+karte[kx+1,ky+1].art+karte[kx+1,ky-1].art+karte[kx-1,ky+1].art+
karte[kx-1,ky-1].art+karte[kx+1,ky].art+karte[kx-1,ky].art;
if mmm>5 then karte[kx,ky].bon:=random(16) else if mmm<4 then karte[kx,ky].bon:=17 else begin if karte[kx,ky].art=0 then
karte[kx,ky].bon:=17 else karte[kx,ky].bon:=random(16);end;
end;
for kx:=1 to kmx do for ky:=1 to kmy do begin karte[kx,ky].art:=karte[kx,ky].bon;karte[kx,ky].bon:=random(4)+1;end;
for kx:=1 to kmx do for ky:=1 to kmy do begin
if karte[kx,ky].art>15 then begin
te:=16;
if ((karte[kx,ky-1].art<te) and (karte[kx-1,ky].art<te) and (karte[kx+1,ky].art<te) and (karte[kx,ky+1].art<te)) then
karte[kx,ky].art:=te+18 else
if ((karte[kx,ky-1].art<te) and (karte[kx-1,ky].art<te) and (karte[kx+1,ky].art<te)) then karte[kx,ky].art:=te+4 else
if ((karte[kx,ky-1].art<te) and (karte[kx-1,ky].art<te) and (karte[kx,ky+1].art<te)) then karte[kx,ky].art:=te+5 else
if ((karte[kx,ky+1].art<te) and (karte[kx-1,ky].art<te) and (karte[kx+1,ky].art<te)) then karte[kx,ky].art:=te+6 else
if ((karte[kx+1,ky].art<te) and (karte[kx,ky-1].art<te) and (karte[kx,ky+1].art<te)) then karte[kx,ky].art:=te+7 else
if ((karte[kx+1,ky].art<te) and (karte[kx-1,ky].art<te)) then karte[kx,ky].art:=te+8 else
if ((karte[kx,ky+1].art<te) and (karte[kx,ky-1].art<te)) then karte[kx,ky].art:=te+9 else
if ((karte[kx,ky-1].art<te) and (karte[kx-1,ky].art<te)) then karte[kx,ky].art:=te+10 else
if ((karte[kx,ky+1].art<te) and (karte[kx-1,ky].art<te)) then karte[kx,ky].art:=te+11 else
if ((karte[kx,ky+1].art<te) and (karte[kx+1,ky].art<te)) then karte[kx,ky].art:=te+12 else
if ((karte[kx,ky-1].art<te) and (karte[kx+1,ky].art<te)) then karte[kx,ky].art:=te+13 else
if (karte[kx-1,ky].art<te) then karte[kx,ky].art:=te+14 else
if (karte[kx+1,ky].art<te) then karte[kx,ky].art:=te+15 else
if (karte[kx,ky-1].art<te) then karte[kx,ky].art:=te+16 else
if (karte[kx,ky+1].art<te) then karte[kx,ky].art:=te+17 else
karte[kx,ky].art:=random(4)+16;
end;
end;
posx:=0;posy:=0;
npaint:=true;
kx:=5;ky:=5;
repeat
if npaint then begin for ykky:=0 to 20 do for xkkx:=0 to 20 do begin
putsprite(xkkx*20,ykky*20,gel[karte[xkkx+1+posx,ykky+1+posy].art]);
putsprite(xkkx*20,ykky*20,regen[2,2]);
npaint:=false;
end;end;
asm mov ax,3;int $33;mov x,cx;mov y,dx;mov mp,bx;end;
if kx>639 then kx:=639;if ky>479 then ky:=479;
inc(phase);if phase>39 then phase:=0;
{case a of
#75:if ax>1 then dec(ax) else ax:=1;
#77:if ax<31 then inc(ax) else ax:=31;
#72:if ay>1 then dec(ay) else ay:=1;
#80:if ay<19 then inc(ay) else ay:=19;
end;}
{waitretrace;
setstart(seite);
if seite=0 then seite:=16000 else seite:=0;}
for i:=1 to 12 do begin
putsprite(540,i*20,roh[i]);{wy:=i*20+6;}
{str(s[m]^.p[i]*10,mm);
writes(mm);}
end;
putsprite(540,360,spr[artzusprite(s[m]^.ch)]);
for kxx:=1 to max do begin
mn:=artzusprite(s[m]^.haus[kxx].art);
if (mn>0) and (mn<29) then begin
putsprite(s[m]^.haus[kxx].xx*20,s[m]^.haus[kxx].yy*20,spr[mn-1]);
putsprite(s[m]^.haus[kxx].xx*20+6,s[m]^.haus[kxx].yy*20+5,qua[s[m]^.haus[kxx].stufe-1]);
end;
end;
putsprite(x,y,zus[3]);
if x<5 then if posx>0 then begin npaint:=true;dec(posx);end;
if y<5 then if posy>0 then begin npaint:=true;dec(posy);end;
if x>635 then if posx<kmx-26 then begin npaint:=true;inc(posx);end;
if y>475 then if posy<kmy-21 then begin npaint:=true;inc(posy);end;
x:=round(x/20);
y:=round(y/20);
if y>45 then y:=45;
if x>50 then x:=50;
putsprite(x*20,y*20,zus[phase mod 8 div 2+4]);
if keypressed then begin
a:=readkey;
case a of
'a':if s[m]^.ch<hauser then inc(s[m]^.ch) else s[m]^.ch:=1;
'y':if s[m]^.ch>1 then dec(s[m]^.ch) else s[m]^.ch:=hauser;
    '+':if s[m]^.steuern<100 then inc(s[m]^.steuern) else s[m]^.steuern:=100;
    '-':if s[m]^.steuern>0 then dec(s[m]^.steuern) else s[m]^.steuern:=0;
    's':if s[m]^.steu<100 then inc(s[m]^.steu) else s[m]^.steu:=100;
    'x':if s[m]^.steu>0 then dec(s[m]^.steu) else s[m]^.steu:=0;
    #32:built(s[m]^.ch,r(s[m]^.ch));
    #13:aufw;
#75:begin npaint:=true;if posx>0 then dec(posx);end;
#77:begin npaint:=true;if posx<kmx-26 then inc(posx);end;
#72:begin npaint:=true;if posy>0 then dec(posy);end;
#80:begin npaint:=true;if posy<kmy-21 then inc(posy);end;
end;end;
{showscreen;}
until keypressed;
textmode(3);
fa:=false;
end;
procedure wachstum;
begin
inc(s[m]^.dorf,(s[m]^.dorf div 75)-s[m]^.unruhe);
if s[m]^.dorf<100 then s[m]^.dorf:=100;
for i:=1 to 80 do if round(s[m]^.steu/100*(s[m]^.dorf-s[m]^.unruhe*2))>0 then
inc(s[m]^.p[i],round(s[m]^.steu/100*(s[m]^.dorf-s[m]^.unruhe*2)));
{inc(s[m]^.p[11],round((s[m]^.dorf/2500)*s[m]^.steuern*s[m]^.steu));
inc(s[m]^.p[14],round((s[m]^.dorf/2500)*(100-s[m]^.steuern)*s[m]^.steu));
inc(s[m]^.p[15],round((s[m]^.dorf/2500)*(100-s[m]^.steuern)*s[m]^.steu));
{s[m]^.temp:=s[m]^.unruhe*s[m]^.dorf div 25;
[m]^.dorf:=s[m]^.dorf-s[m]^.temp;
    inc(s[m]^.dorf,s[m]^.dorf div 10-(s[m]^.dorf+s[m]^.temp) div 150);
    s[m]^.dorf:=s[m]^.dorf+s[m]^.temp;}
    for k:=1 to 13 do if s[m]^.p[k]>s[m]^.maxl then s[m]^.p[k]:=s[m]^.maxl;
    for k:=16 to 25 do if s[m]^.p[k]>s[m]^.maxl then s[m]^.p[k]:=s[m]^.maxl;
    if s[m]^.p[14]>s[m]^.maxe then s[m]^.p[14]:=s[m]^.maxe;
    if s[m]^.p[15]>s[m]^.maxe then s[m]^.p[15]:=s[m]^.maxe;
end;
procedure explode(welches:byte);
begin
s[m]^.haus[welches].ak:=0;
s[m]^.haus[welches].le:=0;
s[m]^.haus[welches].rs:=0;
s[m]^.haus[welches].nahrung:=false;
s[m]^.haus[welches].art:=0;
s[m]^.haus[welches].stufe:=0;
s[m]^.haus[welches].xx:=0;
s[m]^.haus[welches].yy:=0;
end;
procedure verfall;
begin
for i:=1 to max do if (s[m]^.haus[i].art>0) then begin
 if s[m]^.haus[i].hunger then begin
  if s[m]^.haus[i].le>0 then dec(s[m]^.haus[i].le,10) else explode(i);
 end else if s[m]^.haus[i].le<kosten[s[m]^.haus[i].stufe].le then inc(s[m]^.haus[i].le);
{Wenn nicht kaputtmachen dann Regenerierung}
end;
end;
procedure restauration;
var mul:byte;
begin
 for i:=1 to max do begin
  if (s[m]^.haus[i].art>0) and (s[m]^.haus[i].ak>0) then begin
   mul:=s[m]^.haus[i].stufe;
   if (s[m]^.p[32]>=reskosten[s[m]^.bauqua].lleder*mul) and (s[m]^.p[34]>=reskosten[s[m]^.bauqua].sleder*mul) and
   (s[m]^.p[35]>=reskosten[s[m]^.bauqua].knochen*mul) and (s[m]^.p[16]>=reskosten[s[m]^.bauqua].birke*mul) and
   (s[m]^.p[17]>=reskosten[s[m]^.bauqua].steineiche*mul) and (s[m]^.p[20]>=reskosten[s[m]^.bauqua].granit*mul) and
   (s[m]^.p[21]>=reskosten[s[m]^.bauqua].basalt*mul) and (s[m]^.p[24]>=reskosten[s[m]^.bauqua].ziegel*mul) and
   (s[m]^.p[44]>=reskosten[s[m]^.bauqua].gold*mul) and (s[m]^.p[27]>=reskosten[s[m]^.bauqua].moertel*mul) and
   (s[m]^.p[80]>=reskosten[s[m]^.bauqua].nahrung*mul)
   then begin
   dec(s[m]^.p[32],reskosten[s[m]^.bauqua].lleder*mul);
   dec(s[m]^.p[34],reskosten[s[m]^.bauqua].sleder*mul);
   dec(s[m]^.p[35],reskosten[s[m]^.bauqua].knochen*mul);
   dec(s[m]^.p[16],reskosten[s[m]^.bauqua].birke*mul);
   dec(s[m]^.p[17],reskosten[s[m]^.bauqua].steineiche*mul);
   dec(s[m]^.p[20],reskosten[s[m]^.bauqua].granit*mul);
   dec(s[m]^.p[21],reskosten[s[m]^.bauqua].basalt*mul);
   dec(s[m]^.p[24],reskosten[s[m]^.bauqua].Ziegel*mul);
   dec(s[m]^.p[27],reskosten[s[m]^.bauqua].moertel*mul);
   dec(s[m]^.p[44],reskosten[s[m]^.bauqua].gold*mul);
   s[m]^.haus[i].hunger:=false;inc(s[m]^.haus[i].le,s[m]^.haus[i].le div 10);s[m]^.haus[i].nahrung:=true;
   end
  else begin
s[m]^.haus[i].nahrung:=false;
s[m]^.fehler[34]:=true;
if (s[m]^.p[32]<reskosten[s[m]^.bauqua].lleder*mul) then s[m]^.fehler[23]:=true;
if (s[m]^.p[34]<reskosten[s[m]^.bauqua].sleder*mul) then s[m]^.fehler[24]:=true;
if (s[m]^.p[35]<reskosten[s[m]^.bauqua].knochen*mul) then s[m]^.fehler[25]:=true;
if (s[m]^.p[16]<reskosten[s[m]^.bauqua].birke*mul) then s[m]^.fehler[26]:=true;
if (s[m]^.p[17]<reskosten[s[m]^.bauqua].steineiche*mul) then s[m]^.fehler[27]:=true;
if (s[m]^.p[20]<reskosten[s[m]^.bauqua].granit*mul) then s[m]^.fehler[28]:=true;
if (s[m]^.p[21]<reskosten[s[m]^.bauqua].basalt*mul) then s[m]^.fehler[29]:=true;
if (s[m]^.p[24]<reskosten[s[m]^.bauqua].ziegel*mul) then s[m]^.fehler[30]:=true;
if (s[m]^.p[27]<reskosten[s[m]^.bauqua].moertel*mul) then s[m]^.fehler[31]:=true;
if (s[m]^.p[44]<reskosten[s[m]^.bauqua].gold*mul) then s[m]^.fehler[32]:=true;
if (s[m]^.p[80]<reskosten[s[m]^.bauqua].gold*mul) then s[m]^.fehler[33]:=true;
s[m]^.fehler[34]:=true;
end;
   {if haus[i].art=5 then inc(s[m]^.p[14],mul);
   if haus[i].art=8 then inc(s[m]^.p[11],mul);
   if haus[i].art=10 then inc(s[m]^.p[14],mul);
   if haus[i].art=11 then inc(s[m]^.p[15],mul);
   if haus[i].art=24 then begin inc(s[m]^.p[11],mul);inc(s[m]^.p[14],mul);inc(s[m]^.p[15],mul);end;}
{   if s[m]^.haus[i].art=24 then mul:=0;
   if s[m]^.haus[i].art=3 then mul:=mul*4;
   if s[m]^.haus[i].art=22 then mul:=mul*2;
   if s[m]^.haus[i].art=16 then mul:=mul*2;
   if s[m]^.haus[i].art=6 then mul:=mul*2;
   if s[m]^.haus[i].art=29 then mul:=mul*8;}
{   if (s[m]^.p[14]>=reskosten[mul].nahrung) and (s[m]^.p[11]>=reskosten[mul].gold) and
   (s[m]^.p[15]>=reskosten[mul].nahrung) and (s[m]^.p[1]>=reskosten[mul].holz) and
   (s[m]^.p[2]>=reskosten[mul].stein) and (s[m]^.p[19]>=reskosten[mul].moertel) and
   (s[m]^.p[9]>=reskosten[mul].stahl) and (s[m]^.p[4]>reskosten[mul].ziegel) and
   (s[m]^.p[20]>reskosten[mul].glas) then begin
   dec(s[m]^.p[14],reskosten[mul].nahrung);dec(s[m]^.p[11],reskosten[mul].gold);
   dec(s[m]^.p[15],reskosten[mul].nahrung);dec(s[m]^.p[1],reskosten[mul].holz);
   dec(s[m]^.p[2],reskosten[mul].stein);dec(s[m]^.p[19],reskosten[mul].moertel);
   dec(s[m]^.p[9],reskosten[mul].stahl);dec(s[m]^.p[4],reskosten[mul].ziegel);
   dec(s[m]^.p[20],reskosten[mul].glas);
   s[m]^.haus[i].hunger:=false;
   end else begin
   s[m]^.haus[i].hunger:=true;
{ if (s[m]^.p[14]-s[m]^.p[12] div 2>=0) and (s[m]^.p[15]-s[m]^.p[12] div 2>=0) and (s[m]^.p[11]-s[m]^.p[12] div 2>=0)
then begin
  dec(s[m]^.p[14],s[m]^.p[12] div 2);dec(s[m]^.p[15],s[m]^.p[12] div 2);dec(s[m]^.p[11],s[m]^.p[12] div 2);
 end else dec(s[m]^.p[12],s[m]^.p[12] div 10);}
{ if (s[m]^.p[14]<50) or (s[m]^.p[15]<50) then s[m]^.fehler[19]:=true;
 if s[m]^.p[11]<50 then s[m]^.fehler[18]:=true;
 if s[m]^.dorf<50 then s[m]^.fehler[21]:=true;
 if (s[m]^.p[1]<20) or (s[m]^.p[2]<20) then s[m]^.fehler[20]:=true;
 for i:=1 to soldier do if s[m]^.einheit[i].da then if (s[m]^.p[15]>0) and (s[m]^.p[14]>0) and (s[m]^.p[11]>0) then begin
  dec(s[m]^.p[11]);dec(s[m]^.p[14]);dec(s[m]^.p[15]);
 end else s[m]^.einheit[i].da:=false;}
end;
end;
end;
begin
getmem(s[0],sizeof(s[0]));
getmem(s[1],sizeof(s[1]));
{chdir('d:\wars');}
clrscr;
Randomize;
assign(f,'ta2.dat');
reset(f);
readln(f,ast);      {Mut,Klugheit, etc.}
for j:=1 to 11 do readln(f,rassen[j].name);
for i:=1 to 83 do begin readln(f,ast);for j:=1 to 11 do readln(f,rassen[j].werte[i]);end;
close(f);
assign(f,'rohlist.dat');
reset(f);
for i:=1 to 80 do readln(f,rohnam[i]);
close(f);
assign(f,'bauqua.dat');
reset(f);
for i:=1 to 9 do readln(f,bauq[i]);
close(f);
assign(f,'built2.dat');
reset(f);
for i:=1 to hauser do begin readln(f,n[i,1]);readln(f,n[i,2]);readln(f,n[i,3]);readln(f,n[i,4]);readln(f,n[i,5]);
readln(f,n[i,6]);end;
close(f);
assign(f,'help.dat');
reset(f);
for i:=1 to 25 do readln(f,help[i]);
close(F);
assign(f,'waffrues.dat');
reset(f);
close(f);
{readln(f,wanzahl);
readln(f,ranzahl);
for i:=1 to wanzahl do begin
readln(f,waf[i].s);
readln(f,waf[i].art);
readln(f,waf[i].tp);
readln(f,waf[i].boni);
readln(f,waf[i].reich);
readln(f,waf[i].wava);
readln(f,waf[i].wavp);
end;
for i:=1 to ranzahl do begin
readln(f,rus[i].s);
readln(f,rus[i].art);
readln(f,rus[i].rs);
end;
close(F);}
{assign(f,'rassen.dat');
reset(f);
for i:=1 to 8 do for j:=1 to 21 do readln(f,rassen[i][j]);}
for i:=1 to 25 do s[m]^.fehler[i]:=false;
{if paramcount>0 then begin
assign(fil,paramstr(1));
reset(fil,1);
blockread(fil,s,sizeof(s));
close(fil);
end else }
for m:=0 to 1 do begin
s[m]^.bauqua:=1;
s[m]^.esse:=1;
s[m]^.ch:=2;s[m]^.dorf:=1000;
for i:=1 to hauser do s[m]^.vor[i,1]:=true;
for i:=1 to soldier do for j:=1 to 25 do s[m]^.einheit[i].werte[j]:=0;
for i:=1 to hauser do for j:=1 to 5 do if (n[i,j][1]='-') and (n[i,j+1]<>'-') then
begin s[m]^.vor[i,j+1]:=true;s[m]^.vor[i,j]:=false;end;
 for i:=1 to 80 do s[m]^.p[i]:=2500;
{ s[m]^.p[12]:=0;}
 for i:=1 to max do begin s[m]^.haus[i].ak:=0;s[m]^.haus[i].nahrung:=false;s[m]^.haus[i].art:=0;s[m]^.haus[i].stufe:=0;
 s[m]^.haus[i].le:=0;s[m]^.haus[i].rs:=0;
 s[m]^.haus[i].imaufw:=false;
 s[m]^.haus[i].baurunden:=0;end;
 x:=14;
 y:=14;
 s[m]^.weapon:=1;
 s[m]^.akwa:=1;
 s[m]^.akru:=1;
 s[m]^.rustung:=1;
 s[m]^.bauen:=10;
 s[m]^.wissen:=1001;
 s[m]^.t:=false;
{ built(16,3);
 y:=15;x:=15;
 built(21,4);
 y:=13;x:=14;
 built(24,1);
 y:=15;x:=14;
 built(24,1);
 y:=5;x:=4;
 built(15,3);
 y:=14;x:=13;
 built(24,1);
 y:=14;x:=15;
 built(24,1);  }
 s[m]^.t:=true;
 s[m]^.wissen:=101;
main:=true;
{for i:=1 to soldier do begin s[0]^.einheit[i].da:=false;for j:=1 to 4 do begin s[0]^.einheit[i].waf[j]:=1;
s[0]^.einheit[i].rus[j]:=1;end;end;
for i:=1 to soldier do begin s[1]^.einheit[i].da:=false;for j:=1 to 4 do begin s[1]^.einheit[i].waf[j]:=1;
s[1]^.einheit[i].rus[j]:=1;end;end;
for i:=1 to soldier do begin s[1]^.einheit[i].da:=true;s[1]^.einheit[i].werte[8]:=40;s[1]^.einheit[i].werte[21]:=4;
s[1]^.einheit[i].waf[1]:=1;s[1]^.einheit[i].rus[2]:=1;s[1]^.einheit[i].werte[22]:=12;end;
for i:=1 to soldier do begin s[0]^.einheit[i].da:=true;s[0]^.einheit[i].werte[8]:=40;s[0]^.einheit[i].werte[21]:=4;
s[0]^.einheit[i].waf[1]:=1;s[0]^.einheit[i].rus[1]:=1;s[0]^.einheit[i].werte[22]:=12;end;
{for i:=1 to 15 do begin s[m]^.waffen[i].stuck:=4;s[m]^.ruestungen[i].stuck:=4;end;      }
end;
m:=0;
x:=14;
y:=14;
line2:=3;
fa:=false;
clrscr;
writeln('WARS! Version 0.00027OIOH E. Give it to all your friends...');
writeln('Verfuegbarer konventioneller Speicher : ',maxavail,' Bytes');
if maxavail<400000 then begin
writeln('WARNUNG! Es wurde ',400000-maxavail,' Bytes zuwenig freier Speicher gefunden!');
write('Weiter? [jn]');
if upcase(readkey)='N' then halt;
writeln('Auf Ihre Verantwortung ...');
end;
writeln('Moege das Setup ihre Karte richtig erkannt haben und nun ihr System nicht abstuerzen ... (He he he ...)');
{initsb;}
writeln('Im Intro auf ENDE gehen (Pfeiltasten) und dann im Textspiel ''b'' druecken.');
writeln('Abbruch des Grafikmodus mit Taste...');
writeln('Daten initialisiert ... Taste (NICHT ''anykey'' !!!)');
blockgr:=bkgr;
{getmem(temp,blockgr);
getmem(tempbuf,$1FFF-ofs(temp^));
getmem(blk1,blockgr);
getmem(blk2,blockgr);
freemem(tempbuf,$FFFF-ofs(temp^));
freemem(temp,blockgr);
writeln('Block 1:',seg(blk1^),':',ofs(blk1^),'   Block 2:',seg(blk2^),':',ofs(blk2^));}
readkey;
{init_mode13;screen_off;
GetMem(Src_Frame,320*100);    {Speicher fr Quellbild holen und l”schen}
{FillChar(Src_Frame^,320*100,0);
GetMem(Dest_Frame,320*100);   {Speicher fr Ziellbild holen und l”schen}
{FillChar(Dest_Frame^,320*100,0);
Prep_Pal;                     {Palette vorbereiten}
{getpal;
{  move(zielpal,palette,768);
  fillchar(palette1,768,0);}
  size:=160;
  sizei:=0;
{frequenz:=22050;
block2:=true;
name:='d:\wars\sound\5001.raw';
assign(h,name);
reset(h,1);
repeatet:=false;
{getmem(temp,blockgr);
getmem(tempbuf,$1FFF-ofs(temp));
getmem(blk1,blockgr);
getmem(blk2,blockgr);
freemem(tempbuf,$FFFF-ofs(temp));
freemem(temp,blockgr);}
{blockread(h,blk1^,blockgr);
blockread(h,blk2^,blockgr);}
oldexit:=exitproc;
exitproc:=@programexit;
main:=false;
{initdma(blk1,blockgr);}
read1:=false;
read2:=false;
{gross:=filesize(h);}
last:=false;
last2:=false;
i:=60;
rnd:=0;
stark:=0;
main:=true;
{fillchar(mem[$a000:0],64000,0);}
screen_on;
wait:=0;
{Repeat
if main then inc(i);
if i=100 then begin rnd:=5;stark:=5;loadgif('claw');Move(Vscreen^,Ptr($a000,0)^,32000);end;
if i=300 then begin rnd:=10;stark:=15;loadgif('present');Move(Vscreen^,Ptr($a000,0)^,32000);end;
if i=500 then begin rnd:=35;stark:=30;sizei:=1;loadgif('wars');Move(Vscreen^,Ptr($a000,0)^,32000);end;
if i=700 then begin main:=false;i:=801;loadgif('opa3');Move(Vscreen^,Ptr($a000,0)^,32000);end;
if i=800 then begin i:=801;loadgif('opnew2');Move(Vscreen^,Ptr($a000,0)^,32000);end;
if i=900 then begin i:=901;loadgif('opopo');Move(Vscreen^,Ptr($a000,0)^,32000);end;
if i=1000 then begin i:=1001;loadgif('opend2');Move(Vscreen^,Ptr($a000,0)^,32000);end;
if keypressed and (main=true) then if readkey='q' then i:=2000;
    if keypressed and (main=false) then begin
    case readkey of
    #80:if i<1000 then inc(i,99) else i:=800;
    #72:if i>801 then dec(i,101) else i:=1000;
    #27:i:=2000;
    #13:if i=1001 then i:=2000;
    end;
    end;
{    Scroll_Up;                  {Flammen nach oben}
{    Show_Screen;                {fertigen Bildschirm zeigen}
{    New_Line;                   {unten neue Linie anfgen}
{if (wait=0) and (read1=true) and (last=false) then begin
read1:=false;blockread(h,blk1^,blockgr);dec(gross,blockgr);
end;
if (wait=0) and (read2=true) and (last=false) then begin
read2:=false;blockread(h,blk2^,blockgr);dec(gross,blockgr);
end;                                                       }
{Until i=2000;}
TextMode(3);
textcolor(2);textbackground(0);
{initsprites;{showb;}
{freemem(blk1,bkgr);
freemem(blk2,bkgr);
writedsp($D3);
writedsp($DA);
writedsp($D0);
port[$6+basis]:=1;
for i:=1 to 256 do;
port[$6+basis]:=0;
asm
 cli
 push  es
 push  di
 mov   dx,irq
 mov   al,0d0h
 out   dx,al
 mov   ax,[WORD PTR oldintvec+0]
 mov   dx,[WORD PTR oldintvec+2]
 xor   di,di
 mov   es,di
 mov   di,irq
 shl   di,2
 add   di,20h
 mov   WORD PTR es:[di+0],ax
 mov   WORD PTR es:[di+2],dx
 mov   es,pn
 mov   ah,49h
 int   21h
 mov   dx,irq
 mov   al,0d3h
 out   dx,al
 pop   di
 pop   es
 sti
 end;         }

{assign(h,'loops.sam');
reset(h,1);
frequenz:=12050;
block2:=true;
read1:=false;
read2:=false;
repeatet:=true;
last:=false;
last2:=false;
{writeln('Nach Initialisierung sind noch ',maxavail,' Bytes uebrig!');
blockread(h,blk1^,blockgr);
blockread(h,blk2^,blockgr);
gross:=filesize(h);
initdma(blk1,blockgr);
{   assign(h,paramstr(1));
   reset(h,1);
   gross:=filesize(h);
   if gross>65500 then gross:=65500;
   i:=1
  getmem(blk[i],gross);
  bufinfo[i].start:=blk[i];
  blockread(h,blk[i]^,gross);
  samples[i].adresse:=blk[i];
  samples[i].laenge:=gross;
  playinfo[i].fertig:=false;
  samples[i].loop:=true;
  playinfo[i].nummer:=i;
  close(h);
  poss:=0;
  block2:=true;
  main:=true;
  mische;
  mische;}
screen;
{initsb;
initdma(blk1,bkgr);}
s[m]^.steu:=0;
 repeat
  fa:=false;
  a:=#0;
  s[m]^.z:=0;
{  inc(s[m]^.bauen,100);
  inc(zeit);if zeit>=40 then begin zeit:=0;versorgung;end;}
  repeat
  inc(ticker);
  s[m]^.bauen:=1000;
  if ticker=50 then begin
  ticker:=0;
  inc(zeit);
  baueweiter;                   {alle 1 Zeiteinheiten}
{  inc(s[m]^.p[1]);}
  if (s[m]^.steuern>100) then s[m]^.steuern:=100;
  if (s[m]^.steuern<0) then s[m]^.steuern:=0;
  if (s[m]^.steu>100) then s[m]^.steu:=100;
  if (s[m]^.steu<0) then s[m]^.steu:=0;
  if zeit mod 25=0 then begin Screen;produziere;end;
  if zeit mod 50=0 then begin Verfall;wachstum;end;
  if zeit mod 100=0 then restauration;
 { if zeit mod 2000000=0 then begin
    if m=0 then m:=1 else m:=0;
    for i:=1 to 25 do s[m]^.fehler[i]:=false;
{    inc(s[m]^.p[11],round((s[m]^.dorf/2500)*s[m]^.steuern*s[m]^.steu));
    inc(s[m]^.p[14],round((s[m]^.dorf/2500)*(100-s[m]^.steuern)*s[m]^.steu));
    inc(s[m]^.p[15],round((s[m]^.dorf/2500)*(100-s[m]^.steuern)*s[m]^.steu));}
 {   s[m]^.bauen:=0;
    {if esse=0 then dec(dorf,dorf div 100) else inc(dorf,dorf div 100+esse);}
{    produziere;versorgung;
    s[m]^.temp:=s[m]^.unruhe*s[m]^.dorf div 25;
    s[m]^.dorf:=s[m]^.dorf-s[m]^.temp;
    inc(s[m]^.dorf,s[m]^.dorf div 100-(s[m]^.dorf+s[m]^.temp) div 150);
    s[m]^.dorf:=s[m]^.dorf+s[m]^.temp;
    for k:=1 to 13 do if s[m]^.p[k]>s[m]^.maxl then s[m]^.p[k]:=s[m]^.maxl;
    for k:=16 to 25 do if s[m]^.p[k]>s[m]^.maxl then s[m]^.p[k]:=s[m]^.maxl;
    if s[m]^.p[14]>s[m]^.maxe then s[m]^.p[14]:=s[m]^.maxe;
    if s[m]^.p[15]>s[m]^.maxe then s[m]^.p[15]:=s[m]^.maxe;}
  {  screen;
    gotoxy(1,1);
    writeln('Get Ready, Player ',m+1);
    readkey;
    ticker:=0;
    zeit:=0;
{    for i:=1 to 25 do s[m]^.fehler[i]:=false;}
{    if loose2 then begin
    writeln('Congratulations Player 1!Yippey!Hooray!You destroyed the enemy village!Kauft mehr Wars!');readkey;exit;end;
    if loose1 then begin
    writeln('Congratulations Player 2!Yippey!Hooray!You destroyed the enemy village!Kauft mehr Wars!');readkey;exit;end;
    end;
end;}
   gotoxy(77,23);
   write(zeit);
   gotoxy(77,24);
   write(ticker);
   if keypressed then begin
    for i:=1 to 25 do s[m]^.fehler[i]:=false;
    a:=readkey;
    case a of
    'a':if s[m]^.ch<hauser then inc(s[m]^.ch) else s[m]^.ch:=1;
    'z':if s[m]^.ch>1 then dec(s[m]^.ch) else s[m]^.ch:=hauser;
    'd':if s[m]^.akro<80 then inc(s[m]^.akro) else s[m]^.akro:=1;
    'c':if s[m]^.akro>1 then dec(s[m]^.akro) else s[m]^.akro:=80;
    'f':if s[m]^.bauqua<9 then inc(s[m]^.bauqua) else s[m]^.bauqua:=1;
    #72:if y>1 then dec(y);
    #80:if y<20 then inc(y);
    #75:if x>1 then dec(x);
    #77:if x<25 then inc(x);
    #83:begin for l:=1 to max do if (s[m]^.haus[l].xx=x) and
    (s[m]^.haus[l].yy=y) then begin
        explode(l);
end;end;
    'e':begin
    clrscr;
    repeat
    clrscr;
    window(1,1,80,25);
    writeln('Nummer            :',line2);
    writeln('Name              :',s[m]^.einheit[line2].name);
    writeln('Ruestung A        :',rus[s[m]^.einheit[line2].rus[1]].s);
    writeln('Ruestung B        :',rus[s[m]^.einheit[line2].rus[2]].s);
    writeln('Ruestung C        :',rus[s[m]^.einheit[line2].rus[3]].s);
    writeln('Ruestung D        :',rus[s[m]^.einheit[line2].rus[4]].s);
    writeln('Waffe A           :',waf[s[m]^.einheit[line2].waf[1]].s);
    writeln('Waffe B           :',waf[s[m]^.einheit[line2].waf[2]].s);
    writeln('Waffe C           :',waf[s[m]^.einheit[line2].waf[3]].s);
    writeln('Waffe D           :',waf[s[m]^.einheit[line2].waf[4]].s);
    writeln('Aktuelle Waffe    :',waf[s[m]^.akwa].s:17,':',s[m]^.waffen[s[m]^.akwa].stuck);
    writeln('Aktuelle Ruestung :',rus[s[m]^.akru].s:17,':',s[m]^.ruestungen[s[m]^.akru].stuck);
    window(41,1,80,25);
    writeln('Mut               :',s[m]^.einheit[line2].werte[1]);
    writeln('Klugheit          :',s[m]^.einheit[line2].werte[2]);
    writeln('Charisma          :',s[m]^.einheit[line2].werte[3]);
    writeln('Intuition         :',s[m]^.einheit[line2].werte[4]);
    writeln('Fingerfertigkeit  :',s[m]^.einheit[line2].werte[5]);
    writeln('Gewandtheit       :',s[m]^.einheit[line2].werte[6]);
    writeln('Koerperkraft      :',s[m]^.einheit[line2].werte[7]);
    writeln('Lebensenergie     :',s[m]^.einheit[line2].werte[8]);
    writeln('Astralenergie     :',s[m]^.einheit[line2].werte[9]);
    writeln('Waffenlos         :',s[m]^.einheit[line2].werte[10]);
    writeln('Speere, Staebe    :',s[m]^.einheit[line2].werte[11]);
    writeln('Stichwaffen       :',s[m]^.einheit[line2].werte[12]);
    writeln('Aexte, Beile      :',s[m]^.einheit[line2].werte[13]);
    writeln('stumpfe Hiebwaffen:',s[m]^.einheit[line2].werte[14]);
    writeln('scharfe Hiebwaffen:',s[m]^.einheit[line2].werte[15]);
    writeln('Schwerter         :',s[m]^.einheit[line2].werte[16]);
    writeln('Zweihaender       :',s[m]^.einheit[line2].werte[17]);
    writeln('Infanteriewaffen  :',s[m]^.einheit[line2].werte[18]);
    writeln('Wurfwaffen        :',s[m]^.einheit[line2].werte[19]);
    writeln('Schusswaffen      :',s[m]^.einheit[line2].werte[20]);
s[m]^.einheit[line2].werte[21]:=(s[m]^.einheit[line2].werte[waf[s[m]^.einheit[line2].waf[1]].art+9]-10) div 2+
1+(s[m]^.einheit[line2].werte[1]+
s[m]^.einheit[line2].werte[7]+s[m]^.einheit[line2].werte[6]) div 5;
s[m]^.einheit[line2].werte[22]:=(s[m]^.einheit[line2].werte[waf[s[m]^.einheit[line2].waf[1]].art+9]-10) div 2+
1+(s[m]^.einheit[line2].werte[2]+
s[m]^.einheit[line2].werte[4]+s[m]^.einheit[line2].werte[6]) div 5;
    writeln('Attacke              :',s[m]^.einheit[line2].werte[21]);
    writeln('Parade               :',s[m]^.einheit[line2].werte[22]);
    window(1,1,80,25);
    gotoxy(39,line3+1);write('<');
    case readkey of
    '+':begin if line2>=soldier then line2:=1 else inc(line2);s[m]^.akwa:=1;s[m]^.akru:=1;end;
    '-':begin if line2<=1 then line2:=soldier else dec(line2);s[m]^.akwa:=1;s[m]^.akru:=1;end;
    'a':if s[m]^.akwa>=wanzahl then s[m]^.akwa:=1 else inc(s[m]^.akwa);
    'z':if s[m]^.akru>=ranzahl then s[m]^.akru:=1 else inc(s[m]^.akru);
    #72:if line3>1 then dec(line3);
    #80:if line3<9 then inc(line3);
    #13:if line3=1 then begin
    gotoxy(23,2);readln(s[m]^.einheit[line2].name);
    end else if (line3>1) and (line3<6) then begin
    if s[m]^.akru<>1 then begin
    if rus[s[m]^.akru].art=line3-1 then begin
    if s[m]^.ruestungen[s[m]^.akru].stuck>0 then begin
    dec(s[m]^.ruestungen[s[m]^.akru].stuck);inc(s[m]^.ruestungen[s[m]^.einheit[line2].rus[line3-1]].stuck);
    s[m]^.einheit[line2].rus[line3-1]:=s[m]^.akru;end;end;end else begin
    if s[m]^.einheit[line2].rus[line3-1]<>1 then inc(s[m]^.ruestungen[s[m]^.einheit[line2].rus[line3-1]].stuck);
    s[m]^.einheit[line2].rus[line3-1]:=s[m]^.akru;end;end
    else if (line3>5) then begin
    if s[m]^.akwa<>1 then begin
    if s[m]^.waffen[s[m]^.akwa].stuck>0 then begin
    dec(s[m]^.waffen[s[m]^.akwa].stuck);inc(s[m]^.waffen[s[m]^.einheit[line2].waf[line3-5]].stuck);
    s[m]^.einheit[line2].waf[line3-5]:=s[m]^.akwa;end;end else begin
    if s[m]^.einheit[line2].waf[line3-5]<>1 then inc(s[m]^.waffen[s[m]^.einheit[line2].waf[line3-5]].stuck);
    s[m]^.einheit[line2].waf[line3-5]:=s[m]^.akwa;end;end;
    #27:a:=#27;
    end;
    until a=#27;
    clrscr;
    a:=#255;
    END;
        #73:begin feld:=true;main:=false;end;
    #81:begin feld:=false;main:=true;end;
    #27:halt;
    '+':if s[m]^.steuern<100 then inc(s[m]^.steuern);
    '-':if s[m]^.steuern>0 then dec(s[m]^.steuern);
    's':if s[m]^.steu<100 then inc(s[m]^.steu);
    'x':if s[m]^.steu>0 then dec(s[m]^.steu);
    'g':gener;
    #32:built(s[m]^.ch,r(s[m]^.ch));
    #9:for l:=1 to max do if (s[m]^.haus[l].xx=x) and (s[m]^.haus[l].yy=y) then
    begin inc(s[m]^.haus[l].ak);if s[m]^.haus[l].ak>8 then s[m]^.haus[l].ak:=0;end;
    #59:if m=0 then begin
    write('Speichern unter :');readln(name);assign(fil,name);rewrite(fil,1);blockwrite(fil,s,sizeof(s));close(fil);clrscr;end;
{    #68:menu;}
    'm':if s[m]^.waffen[s[m]^.weapon].prod<20 then inc(s[m]^.waffen[s[m]^.weapon].prod) else
    s[m]^.waffen[s[m]^.weapon].prod:=0;
    'n':if s[m]^.ruestungen[s[m]^.rustung].prod<20 then inc(s[m]^.ruestungen[s[m]^.rustung].prod) else
    s[m]^.ruestungen[s[m]^.rustung].prod:=0;
    'W':if s[m]^.weapon<wanzahl then inc(s[m]^.weapon) else s[m]^.weapon:=0;
    'R':if s[m]^.Rustung<ranzahl then inc(s[m]^.rustung) else s[m]^.rustung:=0;
    #13:aufw;
    'f':FIGHT2;
    'b':showb;
  {  'w':begin
    if m=0 then m:=1 else m:=0;
    for i:=1 to 25 do s[m]^.fehler[i]:=false;
{    inc(s[m]^.p[11],round((s[m]^.dorf/2500)*s[m]^.steuern*s[m]^.steu));
    inc(s[m]^.p[14],round((s[m]^.dorf/2500)*(100-s[m]^.steuern)*s[m]^.steu));
    inc(s[m]^.p[15],round((s[m]^.dorf/2500)*(100-s[m]^.steuern)*s[m]^.steu));}
   { s[m]^.bauen:=0;
    {if esse=0 then dec(dorf,dorf div 100) else inc(dorf,dorf div 100+esse);}
{    produziere;versorgung;
    s[m]^.temp:=s[m]^.unruhe*s[m]^.dorf div 25;
    s[m]^.dorf:=s[m]^.dorf-s[m]^.temp;
    inc(s[m]^.dorf,s[m]^.dorf div 100-(s[m]^.dorf+s[m]^.temp) div 150);
    s[m]^.dorf:=s[m]^.dorf+s[m]^.temp;
    for k:=1 to 13 do if s[m]^.p[k]>s[m]^.maxl then s[m]^.p[k]:=s[m]^.maxl;
    for k:=16 to 25 do if s[m]^.p[k]>s[m]^.maxl then s[m]^.p[k]:=s[m]^.maxl;
    if s[m]^.p[14]>s[m]^.maxe then s[m]^.p[14]:=s[m]^.maxe;
    if s[m]^.p[15]>s[m]^.maxe then s[m]^.p[15]:=s[m]^.maxe;}
    {screen;
    gotoxy(1,1);
    writeln('Get Ready, Player ',m+1);
    ticker:=0;
    zeit:=0;
{    for i:=1 to 25 do s[m]^.fehler[i]:=false;}
    {if loose2 then begin
    writeln('Congratulations Player 1!Yippey!Hooray!You destroyed the enemy village!Kauft mehr Wars!');readkey;exit;end;
    if loose1 then begin
    writeln('Congratulations Player 2!Yippey!Hooray!You destroyed the enemy village!Kauft mehr Wars!');readkey;exit;end;
    end;
    end;
    screen;}
    end;
    end;
    end;
  until loose2 or loose1;
 until loose2 or loose1;
clrscr;
if loose2 then begin writeln(le1);
writeln('Congratulations Player 1!Yippey!Hooray!You destroyed the enemy village!Kauft mehr Wars!');end;
if loose1 then begin writeln(le2);
writeln('Congratulations Player 2!Yippey!Hooray!You destroyed the enemy village!Kauft mehr Wars!');end;
readln;
end.
