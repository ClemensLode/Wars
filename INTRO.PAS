unit intro;
interface
procedure writes(sss:string);
procedure play(nummerp:byte);
procedure mische;
Procedure Scroll_Up;
Procedure New_Line;             {baut die untersten Zeilen neu auf}
Procedure Show_Screen;          {kopiert fertigen Bilschirm auf VGA}
Procedure Prep_Pal;             {Palette auf Flames vorbereiten}
procedure writedsp(b:byte);
function readdsp:byte;
procedure initsb;
implementation
uses dos,variable,modexlib;
procedure writes(sss:string);
begin
end;
procedure play(nummerp:byte);
var p:byte;
begin
for p:=1 to stimmen do if playinfo[p].fertig=true then begin
playinfo[p].fertig:=false;
playinfo[p].nummer:=nummerp;
playinfo[p].pos:=0;
exit;
end;
end;

procedure mische;
var mmm,divisor,ll,jj:word;
 begin
  divisor:=0;
  for ll:=1 to stimmen do if playinfo[ll].fertig=false then inc(divisor);
  for j:=1 to bkgr do
  begin
   m:=0;
   for ll:=1 to stimmen do begin
   inc(playinfo[i].pos);
   if playinfo[ll].pos+blockgr>=samples[playinfo[ll].nummer].laenge then if samples[playinfo[ll].nummer].loop then
   playinfo[ll].pos:=0 else
   playinfo[ll].fertig:=true;
    if playinfo[ll].fertig=false then
     inc(m,blk[playinfo[ll].nummer]^[playinfo[ll].pos]-128);
   end;
   if divisor>0 then mm[jj]:=m div divisor+128 else mm[jj]:=128;
  end;
  if block2 then begin
  block2:=false;for jj:=1 to bkgr do blk1^[jj]:=mm[jj];end else begin
  block2:=true;for jj:=1 to bkgr do blk2^[jj]:=mm[jj];end;
 end;  {Buffer blk1 oder blk2 gefuellt!!!!}
Procedure Scroll_Up;assembler;
{scrollt das Bild um eine Zeile nach oben und interpoliert}
asm
  push ds
  les di,Dest_Frame             {Zeiger auf Zielbild laden}
  lds si,Src_Frame              {Zeiger auf Quellbild}
  add si,320                    {im Quellbild auf Zeile 1}
  mov cx,320*98                 {99 Zeilen scrollen}
  xor bl,bl                     {wird als Dummy fÅr High-Byte benîtigt}
@lp1:
  xor ax,ax
  xor bx,bx
  mov al,[si-321]               {ersten Punkt holen}
  mov bl,[si-320]               {zweiten Punkt addieren}
  add ax,bx
  mov bl,[si-319]               {nÑchsten Punkt addieren}
  add ax,bx
  mov bl,[si-1]                 {usw...}
  add ax,bx
  mov bl,[si+1]
  add ax,bx
  mov bl,[si+319]
  add ax,bx
  mov bl,[si+320]
  adc ax,bx
  mov bl,[si+321]
  adc ax,bx
  shr ax,3
  or ax,ax                      {bereits 0 ?}
  je @null
  dec al                        {wenn nein, dann verringern}
@null:
  stosb                         {Wert ins Ziel}
  inc si                        {nÑchsten Punkt}
  dec cx                        {weitere Punkte ?}
  jne @lp1
  pop ds
End;

Procedure New_Line;             {baut die untersten Zeilen neu auf}
Var qi,qx:Word;
Begin
  For qx:=1 to 319 do Begin      {untere 3 Zeilen mit zufÑlligen Werten fÅllen}
    Dest_Frame^[97,qx]:=Random(rnd)+stark;
    Dest_Frame^[98,qx]:=Random(rnd)+stark;
    Dest_Frame^[99,qx]:=Random(rnd)+stark;
  End;
  For qx:=0 to Random(35) do Begin {zuf. Anzahl Hotspots einfÅgen}
    qx:=Random(size*2)+160-size;             {an zufÑllige Koordinaten}
    asm
      les di,Dest_Frame         {Zielbild adressieren}
      add di,97*320             {Zeile 98 (zweitunterste) bearbeiten}
      add di,qx                  {x-Koordinate dazu}
      mov al,0ffh               {hellste Farbe}
      mov es:[di-321],al        {gro·en Hotspot erzeugen (9 Punkte)}
      mov es:[di-320],al
      mov es:[di-319],al
      mov es:[di-1],al
      mov es:[di],al
      mov es:[di+1],al
      mov es:[di+319],al
      mov es:[di+320],al
      mov es:[di+321],al
    End;
  End;
End;

Procedure Show_Screen;          {kopiert fertigen Bilschirm auf VGA}
Begin
asm
  push ds
  lds si,Dest_Frame             {fertiges Bild als Quelle}
  mov ax,0a000h                 {VGA als Ziel}
  mov es,ax
  mov di,320*100                {ab Zeile 100}
  mov cx,320*100/4              {100 Zeilen als Dwords kopieren}
  db 66h                          {Operand Size Prefix (32 Bit)}
  rep movsw                     {kopieren}
  pop ds
End;
  temp:=Dest_Frame;             {Zeiger auf Quell- und Zielbild tauschen}
  Dest_Frame:=Src_Frame;
  Src_Frame:=temp;
End;

Procedure Prep_Pal;             {Palette auf Flames vorbereiten}
Var qi:Word;
Begin
  FillChar(Palette,80*3,0);     {Grundlage: alles schwarz}
  For qi:=0 to 7 do Begin
    Palette[qi*3+2]:=qi*2;        {Farbe 0-7: Anstieg Blau}
    Palette[(qi+8)*3+2]:=16-qi*2; {Farbe 0-7: abfallendes Blau}
  End;
  For qi:=8 to 31 do             {Farbe 8 -31: Anstieg Rot}
    Palette[qi*3]:=(qi-8)*63 div 23;
  For qi:=32 to 55 do Begin      {Farbe 32-55: Anstieg GrÅn, Rot konstant}
    Palette[qi*3]:=63;
    Palette[qi*3+1]:=(qi-32)*63 div 23;
  End;
  For qi:=56 to 79 do Begin      {Farbe 56-79: Anstieg Blau,Rot u. Blau konst.}
    Palette[qi*3]:=63;
    Palette[qi*3+1]:=63;
    Palette[qi*3+2]:=(qi-56)*63 div 23;
  End;
  FillChar(Palette[80*3],176*3,63);  {Rest wei·}
  SetPal;                       {fertige Palette setzen}
End;
 procedure writedsp(b:byte);assembler;
  asm
   mov dx,basis
   add dx,$C;
   @warten:
   in al,dx;
   test al,$80;
   jne @warten;
   mov al,b;
   out dx,al;
 end;
 function readdsp:byte;
  var t:byte;
 begin
  asm
   mov dx,basis
   add dx,$E;
   @warten:
   in al,dx;
   test al,$80;
   je @warten;
   sub dl,4;
   in al,dx;
   mov t,al;
  end;
  readdsp:=t;
 end;
    procedure initsb;
    var dir:searchrec;
    begin
     write('Hole Daten aus CONFIG.WRS ... ');
     findfirst('CONFIG.WRS',archive,dir);
     if doserror<>0 then begin writeln('nicht gefunden! SETUP.EXE ausfuehren!');halt;end;
     assign(h,'config.wrs');
     reset(h,1);
     blockread(h,sb,sizeof(sb));
     close(h);
     basis:=sb.basis;irq:=sb.irq;dma:=sb.dma;
     writeln('Initialisiere DSP ...');
     port[$6+basis]:=1;
     for i:=1 to 256 do;
     port[$6+basis]:=0;
     if readdsp<>$AA then begin
      writeln('Soundblaster oder kompatible wurden nicht gefunden! SETUP.EXE erneut versuchen.');
      halt;
     end;
     writedsp($E1);
     writeln('DSP-Versionsnummer: ',readdsp,'.',readdsp);
     writeln('Aktiviere Lautsprecher ...');
     writedsp($d1);
    end;
begin
end.