UNIT wars3;

INTERFACE

USES
 newfrontier;

CONST
 kartex = 42;kartey = 42; {Ausdehnung der Karte}
 anzdorf=0;
VAR
 fauna,_3ddat,hoehe,gebirge, landk, temper, karte, wasserk: tselector;
 pflanzen:array[0..100] of record
  beeren:byte;
  x,y:word;
 end;
 dorfs:array[0..anzdorf] of record
  x,y:word;
 end;
 screeny100: Array [0..kartey+1] Of Word;
 feld:array[0..3] of byte;
 feinx, feiny, bax, bay, addx, addy, scrollx, scrolly: LongInt;
 adder, framessec, race: Word;
 gridded, good, kart, getinfo, testframe: Boolean;
 bstr: string;
 see: Real;

PROCEDURE init (Mode: Word);
{Initialisiert WARS!}
PROCEDURE paint;
{Malt alles auf den Bildschirm}
PROCEDURE initkart;
{Initiert (fuellt) Karte}
PROCEDURE mausit;
{Alle Mausroutinen}
FUNCTION checkkey: Char;
{Kommunikation mit Programm (Maus,Joystick,Tastatur etc.)}
PROCEDURE intro;
{Ja was wohl!}
Implementation

Uses vesa107, crt, dos, maus, modexlib,units3;

Var
  activ: Array [0..anzmann] Of Word;
  temp, tkarte: tselector;
  ttx, tty, t1, t2, funktion, oldmp, mp, X5, Y5, klickx, klicky, oldx, oldy, X4, Y4, xx, yy, k: LongInt;
  fx, fy: Word;
  resx, resy, framestring: String;
  saveexiter: Pointer;
  ziel: LongInt;
  shotnr,inhalt, ergebnis: Byte;

procedure testscrollxy;
begin
  If scrollx > 10 Then scrollx := 10;
  If scrollx < -kartex+10 Then scrollx := - kartex+10;
  If scrolly > 0 Then scrolly := 0;
  If scrolly < - kartey Then scrolly := - kartey;
end;

procedure shot;
var shotstr:string;
begin
str(shotnr,shotstr);
inc(shotnr);
{shotstr:='WARS.sht';}
bsave32('c:\wars.sht',screen.h,screen.memneed);
end;

Procedure mausit;
  Var
    tfx, tfy, tex, tey: Integer;
  Begin
    oldx := fx; oldy := fy; oldmp := mp;
    mouse_getposition;
    fx := mouse. X; fy := mouse. Y; mp := mouse. but;
    Inc (bax, fx - oldx); Inc (bay, fy - oldy);    {Koordinaten berechnen}
    If bax > screen.randr - 32 Then Begin Dec (scrollx); Inc (scrolly); End;
    If bax < screen.randl + 12 Then Begin Inc (scrollx); Dec (scrolly); End;
    If bay > screen.randu - 32 Then Begin Dec (scrollx); Dec (scrolly); End;
    If bay < screen.rando + 12 Then Begin Inc (scrollx); Inc (scrolly); End;
    testscrollxy; {Auf Randueberschreitung checken}
    tex := bax Mod 64;
    tey := bay Mod 32 + 1;
    feinx := 0; feiny := 0;

    If tey < 16 Then Begin
      If tex < tey * 2 Then feinx := - 1 Else If tex > 32 - tey * 2 Then feiny := - 1;
    End Else If tey > 16 Then Begin
      Dec (tey, 16);
      If tex < tey * 2 Then feiny := 1 Else If tex > 32 - tey * 2 Then feinx := 1;
    End; {Feineinstellung fuer Feldkoordinaten}

    ttx := feinx + bax Div 64 + bay Div 32 - scrollx; If ttx < 1 Then ttx := 1; If ttx > kartex-1 Then ttx := kartex-1;
    tty := feiny - bax Div 64 + bay Div 32 - scrolly; If tty < 1 Then tty := 1; If tty > kartey-1 Then tty := kartey-1;
    {Feldkoordinaten berechnet}

    t1 := (ttx + scrollx) * 32 - (tty + scrolly) * 32; t2 := (ttx + scrollx) * 16 + (tty + scrolly) * 16;
    {Koordinaten des Feldes ausrechnen}

    If (mp = 0) And (oldmp = 0) Then putransprite (bax, bay, sp.hand [race, 2] ) Else
    If (mp = 2) And (oldmp = 0) Then putransprite (bax, bay, sp.hand [race, 4] ) Else
    If (mp = 2) And (oldmp = 2) Then putransprite (bax, bay, sp.hand [race, 3] ) Else
    If (mp = 0) And (oldmp = 2) Then putransprite (bax, bay, sp.hand [race, 4] ) Else
    If (mp = 1) And (oldmp = 0) Then putransprite (bax, bay, sp.hand [race, 1] ) Else
    If (mp = 1) And (oldmp = 1) Then putransprite (bax, bay, sp.hand [race, 1] ) Else
    If (mp = 0) And (oldmp = 1) Then putransprite (bax, bay, sp.hand [race, 1] ) Else
                  putransprite (bax, bay, sp.hand [race, 2] );
    {Mauscursor}

    If (mp = 0) And (oldmp = 0) Then Begin
      klickx := 0;
      klicky := 0;
      funktion := 0;
    End;
    {Alle Tasten losgelassen}

    If (mp = 1) And (oldmp = 0) Then Begin
     FillChar (activ, 50, 0);
      For xx := 0 To anzmann Do If (spieler [xx].AX = ttx) And (spieler [xx].ay = tty) Then activ [0] := xx;
    End;
    {Einheit auswaehlen}

    If ( (mp = 2) And (oldmp = 0) And (kart) And (mouse. X <= addx + 100) And (mouse. X >= addx - 100) And (mouse. Y >= addy)
       And (mouse. Y <= addy + 100) ) Or ( (mp = 2) And (oldmp = 2) And (funktion = 5) )
    Then Begin
      funktion := 5;
      klickx := mouse. X - addx;
      klicky := mouse. Y - addy;
      scrollx := - (klickx Div 2 + klicky);
      scrolly := - ( - klickx Div 2 + klicky);
      testscrollxy;
    End;
    {Auf der Minimap scrollen}
If (mp = 0) And (oldmp = 2) And (funktion = 0) Then
      For xx := 0 To anzmann Do If activ [xx] > 0 Then If spieler [activ [xx] ].px = 0 Then
        gotoxye (ttx, tty, activ [xx])
      Else spieler [activ [xx] ].weglong := spieler [activ [xx] ].wegp;
    {Rumgehen}

    Case funktion Of
      1:
         Begin
           klickx := mouse. X - addx; klicky := mouse. Y - addy + 10;
           funktion := 3{verschieben}
         End
      {   else rechteck(klickx,klicky+10,mouse.x,mouse.y+10,3,false)} ;
      3:
         Begin
           addx := mouse. X - klickx;
           addy := mouse. Y - klicky;
           If addx < 110 Then addx := 110;
           If addy < 10 Then addy := 10;
           If addx >= screen.maxx - 110 Then addx := screen.maxx - 110;
           If addy >= screen.maxy - 110 Then addy := screen.maxy - 110;
         End;
    End;
    {   if (mp>0) and (oldmp=0) then begin if runde<16 then inc(runde) else runde:=1;end;}
    {lichtpunkt(bax,bay+row,180);}
    {   x4:=(spieler[xx].ax+scrollx);
    y4:=(spieler[xx].ay+scrolly);
    if (x4>ttx) then begin
    if (y4>tty) then runde:=10;
    if (y4<tty) then runde:=6;
    if y4=tty then runde:=8;
    end else
    if x4<ttx then begin
    if (y4>tty) then runde:=14;
    if (y4<tty) then runde:=2;
    if y4=tty then runde:=16;
    end else
    if x4=ttx then begin
    if (y4>tty) then runde:=4;
    if (y4<tty) then runde:=12;
    end;
    newput(t1,t2+row,grid);
    {newput(bax-35,bay+row-30,pfeil[runde]);}
  End;

Procedure initplayer;
Begin
  For xx := 1 To anzmann Do With spieler [xx] Do Begin
    goeat:=false;
    hunger:=150;
    blocker:=false;
    ax := Random (kartex-5) + 3;
    ay := Random (kartey-5) + 3;
    writemem32b (Ptr48 (karte, AX + screeny100 [ay] ), 0);
    go := False;
    cx := AX;
    cy := ay;
    gotox:=ax;
    gotoy:=ay;
    phase := Random (8);
    richtung := Random (8);
  End;
End;

Procedure init (Mode: Word);
 Begin
   gridded := false;
   GetMem32 (sprdata, 900000);
   Asm mov AX, $13; Int $10; End;
   Randomize;
   screen_off;
   screen._16bit:=2;
   case mode of
   $101,$103,$105:screen._16bit:=1;
   end;
   initkart;
   initstuff;
   initcoast;
   screen_on;
   initvesa (mode);
   screen.randl := 0; screen.rando := 0; screen.randu := screen.maxy - 1; screen.randr := screen.maxx - 1;
   mouse_setx (screen.randl, screen.randr - 21);
   mouse_sety (screen.rando, screen.randu - 21);
   scrollx := 0;
   scrolly := 0;
   schrift[aktab].format := True;
   addx := screen.maxx div 2;
   addy := 10;
 End;

Procedure paint_karte;
var te1,te2:word;
Begin
  Move32 (Ptr48 (virscr, 0), Ptr48 (screen.h, 0), screen.memneed);
    {Hinterlaesst *mit Klammern* Mausspuren}
  For yy := 0 To kartey Do   {Painting}
    For xx := 0 To kartex Do
    Begin
      adder:=0;
      if (xx>0) and (xx<kartex) and (yy>0) and (yy<kartey) then begin
      adder:=readmem32b(ptr48(_3ddat,xx+screeny100[yy]));
      if adder>readmem32b(ptr48(_3ddat,xx-1+screeny100[yy])) then adder:=readmem32b(ptr48(_3ddat,xx-1+screeny100[yy]));
      if adder>readmem32b(ptr48(_3ddat,xx+screeny100[yy-1])) then adder:=readmem32b(ptr48(_3ddat,xx+screeny100[yy-1]));
      if adder>readmem32b(ptr48(_3ddat,xx-1+screeny100[yy-1])) then adder:=readmem32b(ptr48(_3ddat,xx-1+screeny100[yy-1]));
      end;
      X4 := (xx + scrollx) ShL 5 - (yy + scrolly) ShL 5;
      Y4 := (xx + scrollx) ShL 4 + (yy + scrolly) ShL 4-adder shl 3;
      inhalt := readmem32b (Ptr48 (karte, xx + screeny100 [yy] ) );
      If (inhalt >= 12) And (inhalt <= 15) Then Begin
        ziel := (xx + screeny100 [yy] ) shl 2;
        te1:=readmem32w (Ptr48 (wasserk, ziel + 0) );
        te2:=readmem32w (Ptr48 (wasserk, ziel + 2) );
        if te1+te2=0 then putgelsprite(X4, Y4, 10, sp.wasser[inhalt-12]) else
                putcombsprite (X4, Y4, lo(te1), hi(te1), lo(te2) ,hi(te2));
      End Else Begin
        dec(y4,8);
        inhalt:=readmem32b(ptr48(hoehe,xx+screeny100[yy]));
        if inhalt=15 then dec(y4,8);
        if gridded then putgelsprite (X4, Y4, inhalt, sp.hoehe [inhalt+20]) else
             putgelsprite (X4, Y4, inhalt, sp.hoehe [inhalt]);
{        If readmem32b (Ptr48 (gebirge, xx + screeny100 [yy] ) ) > 0 Then
          putransprite (X4, Y4, sp.berg [readmem32b (Ptr48 (gebirge, xx + screeny100 [yy] ) ) - 1] );}
      End;
    End;
      for i:=0 to 100 do begin
      xx:=pflanzen[i].x;
      yy:=pflanzen[i].y;
      adder:=readmem32b(ptr48(_3ddat,xx+screeny100[yy]));
      if adder>readmem32b(ptr48(_3ddat,xx-1+screeny100[yy])) then adder:=readmem32b(ptr48(_3ddat,xx-1+screeny100[yy]));
      if adder>readmem32b(ptr48(_3ddat,xx+screeny100[yy-1])) then adder:=readmem32b(ptr48(_3ddat,xx+screeny100[yy-1]));
      if adder>readmem32b(ptr48(_3ddat,xx-1+screeny100[yy-1])) then adder:=readmem32b(ptr48(_3ddat,xx-1+screeny100[yy-1]));
      X4 := (xx + scrollx) ShL 5 - (yy + scrolly) ShL 5;
      Y4 := (xx + scrollx) ShL 4 + (yy + scrolly) ShL 4-adder shl 3;
      putransprite (x4+20, y4-14, sp.pflanze);
     end;
     for i:=0 to anzdorf do begin
      xx:=dorfs[i].x;
      yy:=dorfs[i].y;
      adder:=readmem32b(ptr48(_3ddat,xx+screeny100[yy]));
      if adder>readmem32b(ptr48(_3ddat,xx-1+screeny100[yy])) then adder:=readmem32b(ptr48(_3ddat,xx-1+screeny100[yy]));
      if adder>readmem32b(ptr48(_3ddat,xx+screeny100[yy-1])) then adder:=readmem32b(ptr48(_3ddat,xx+screeny100[yy-1]));
      if adder>readmem32b(ptr48(_3ddat,xx-1+screeny100[yy-1])) then adder:=readmem32b(ptr48(_3ddat,xx-1+screeny100[yy-1]));
      X4 := (xx + scrollx) ShL 5 - (yy + scrolly) ShL 5;
      Y4 := (xx + scrollx) ShL 4 + (yy + scrolly) ShL 4-adder shl 3;
      putransprite (x4-8, y4-16, sp.dorf);
      end;

{      str(pflanzen[0].beeren,bstr);
      schrift[aktab].wx:=x4;
      schrift[aktab].wy:=y4;
      writes(bstr);}
End;

Procedure paint_frame;
Var tempx: Word;
  ein,nam, temps: String;
  ready:boolean;
Begin
  Str (framessec: 2, framestring);
  Str (screen.maxx: 4, resx);
  Str (screen.maxy, resy);
  nam := '';
  Case readmem32b (Ptr48 (karte, ttx + screeny100 [tty] ) ) Of
    4..7:begin
          ready:=false;
    for tempx:=0 to anzmann do if (spieler[tempx].ax=ttx) and (spieler[tempx].ay=tty) then begin
     Str (tempx,ein);nam:='Einheit '+ein+#10#13;ready:=true;
     if spieler[tempx].goeat then nam:=nam+'Hunger !!'+#10#13;
     end;
     if ready=false then begin
    If readmem32b (Ptr48 (gebirge, ttx + screeny100 [tty] ) ) > 0 Then nam := 'Gebirge'#10#13 Else
{      If readmem32b (Ptr48 (dorfs, ttx + screeny100 [tty] ) ) > 0 Then nam := 'Ein Dorf'#10#13 Else}
        nam := 'Grassfeld'#10#13;
      end;
      end;
    12..15: If readmem32b (Ptr48 (wasserk, (ttx + screeny100 [tty] ) * 4) ) > 0 Then nam := 'Kuestenfeld'#10#13 Else
      nam := 'Wasserfeld'#10#13;
    24..27: nam := 'Randmarkierung'#10#13;
  End;
  message (0, screen.maxy - 132, 'Frames pro Sekunde :' + framestring + #10#13#10#13 + nam + #10#13'Aufloesung :' + resx + '*'
  + resy + #10#13#10#13 + 'Error : ' + errornum);

End;
Procedure showkarte;
Var addz: Word;
Begin
  For xx := 0 To kartex Do For yy := 0 To kartey Do Begin
    ziel := xx - yy + screen.screeny [ (xx + yy) ShR 1 + addy] + addx;
    inhalt := readmem32b (Ptr48 (karte, xx + screeny100 [yy] ) );
    Case inhalt Of
      0..3: ergebnis := 206 + Random (2) + inhalt;
      4..7: If readmem32b (Ptr48 (gebirge, xx + screeny100 [yy] ) ) > 0 Then
      ergebnis := 91-random(2) Else
{        If readmem32b (Ptr48 (dorfs, xx + screeny100 [yy] ) ) > 0 Then ergebnis := 127 Else}
        ergebnis:= 224 + inhalt - 4+readmem32b(ptr48(_3ddat,xx+screeny100[yy]))*3;
      8..11: ergebnis := 92 + inhalt - 8;
      12..15:
              Begin
                addz := Random (4);
                If addz < 4 Then
                  ergebnis := 38 + addz
                Else
                  ergebnis := 199 + addz;
                writemem32b (Ptr48 (karte, xx + screeny100 [yy] ), 12 + Random (4) ); {Vielleicht raustun...}
              End;
      16..19: ergebnis := 72 + inhalt - 16;
      20..23: ergebnis := 254 + Random (2);
      24..27: ergebnis := 82 + inhalt - 24;
    End;
    writemem32b (Ptr48 (screen.h, ziel), ergebnis);
  End;
  rechteck ( - scrollx + scrolly + addx, ( - scrollx - scrolly) Div 2 + addy, - scrollx + scrolly + screen.maxx Div 50 + addx,
  ( - scrollx - scrolly) Div 2 + screen.maxy Div 50 + addy, 1, False);
End;

Procedure paint;
 var fer,sstring:string;
 Begin
   paint_karte;
   mausit;
   if (ttx>2) and (tty>2) and (ttx<kartex-2) and (tty<kartey-2) then begin
   adder:=readmem32b(ptr48(_3ddat,ttx+screeny100[tty]));
   if adder>readmem32b(ptr48(_3ddat,ttx-1+screeny100[tty])) then adder:=readmem32b(ptr48(_3ddat,ttx-1+screeny100[tty]));
   if adder>readmem32b(ptr48(_3ddat,ttx+screeny100[tty-1])) then adder:=readmem32b(ptr48(_3ddat,ttx+screeny100[tty-1]));
   if adder>readmem32b(ptr48(_3ddat,ttx-1+screeny100[tty-1])) then adder:=readmem32b(ptr48(_3ddat,ttx-1+screeny100[tty-1]));
   if readmem32b(ptr48(hoehe,ttx+screeny100[tty]))=15 then dec(t2,8);
   putransprite (t1, t2-adder shl 3-8, sp.grid1[readmem32b(ptr48(hoehe,ttx+screeny100[tty]))]);
   end;
   fill_besetzt;
   For xx := 3 To kartex-3 Do for yy:=3 to kartey-3 do if besetzt[xx,yy]>0 then begin
     adder:=readmem32b(ptr48(_3ddat,xx+screeny100[yy]));
     if adder>readmem32b(ptr48(_3ddat,xx-1+screeny100[yy])) then adder:=readmem32b(ptr48(_3ddat,xx-1+screeny100[yy]));
     if adder>readmem32b(ptr48(_3ddat,xx+screeny100[yy-1])) then adder:=readmem32b(ptr48(_3ddat,xx+screeny100[yy-1]));
     if adder>readmem32b(ptr48(_3ddat,xx-1+screeny100[yy-1])) then adder:=readmem32b(ptr48(_3ddat,xx-1+screeny100[yy-1]));
     X4 := (XX + scrollx) ShL 5 - (yy + scrolly) ShL 5;
     Y4 := (XX + scrollx) ShL 4 + (yy + scrolly) ShL 4-adder shl 3;
     inhalt:=readmem32b(ptr48(hoehe,xx+screeny100[yy]));
     if inhalt=15 then dec(y4,8);
     putransprite (x4, y4-8, sp.grid2[inhalt]);
end;
   For xx := 0 To anzmann Do With spieler [xx] Do If (AX > 0) And (ay > 0) Then Begin
     adder:=readmem32b(ptr48(_3ddat,ax+screeny100[ay]));
     if adder>readmem32b(ptr48(_3ddat,ax-1+screeny100[ay])) then adder:=readmem32b(ptr48(_3ddat,ax-1+screeny100[ay]));
     if adder>readmem32b(ptr48(_3ddat,ax+screeny100[ay-1])) then adder:=readmem32b(ptr48(_3ddat,ax+screeny100[ay-1]));
     if adder>readmem32b(ptr48(_3ddat,ax-1+screeny100[ay-1])) then adder:=readmem32b(ptr48(_3ddat,ax-1+screeny100[ay-1]));
     X4 := (AX + scrollx) ShL 5 + px * 2 - (ay + scrolly) ShL 5 - py * 2;
     Y4 := (AX + scrollx) ShL 4 + px + (ay + scrolly) ShL 4 + py-adder shl 3;
     inhalt:=readmem32b(ptr48(hoehe,xx+screeny100[yy]));
     if inhalt=15 then dec(y4,8);
     For temp := 0 To anzmann Do If activ [temp] = xx Then putransprite (x4, y4-8, sp.grid1[inhalt]);
     putransprite (X4 + 28, Y4 - 11, sp.leut [phase, richtung] );
     if xx=1 then begin
     str(prio[0],sstring);
     fer:='nix tun: '+sstring;
     str(prio[1],sstring);
     fer:=fer+' Durst: '+sstring;
     str(durst,sstring);fer:=fer+sstring;
     str(prio[2],sstring);
     fer:=fer+' Schlaf: '+sstring;
     str(hunger,sstring);fer:=fer+sstring;
     str(prio[3],sstring);
     fer:=fer+' Hunger: '+sstring;
     str(hunger,sstring);fer:=fer+sstring;
     str(prio[5],sstring);
     fer:=fer+' Befehl: '+sstring;
     schrift[aktab].wx:=0;
     schrift[aktab].wy:=0;
     writes(fer);
     end;
{     if (x4>=screen.randl+10) and (y4>=screen.rando+10) and (x4<=screen.randr-50) and (y4<=screen.randu-40) then begin
     schrift.wx:=x4;schrift.wy:=y4;
     str(hunger,bstr);
     writes(bstr);
      end;         }
   End;
   If kart Then showkarte;
   If testframe Then paint_frame;
   {leute}
   copytovga2;
 End;

Procedure fill_c;
Begin
  If readmem32b (Ptr48 (karte, 0) ) = 0 Then Begin
    For xx := 0 To kartex Do For yy := 0 To kartey Do
      writemem32b (Ptr48 (karte, xx + screeny100 [yy] ), Random (2) ); {Wasser oder Land}
    Exit;
  End;
  For xx := 0 To kartex Do For yy := 0 To kartey Do
    If (readmem32b (Ptr48 (karte, xx + screeny100 [yy] ) ) >= 12) And (readmem32b (Ptr48 (karte, xx + screeny100 [yy] ) ) <=15)
      Then writemem32b (Ptr48 (karte, xx + screeny100 [yy] ), 1)
      Else writemem32b (Ptr48 (karte, xx + screeny100 [yy] ), 0);
  {move32(ptr48(tkarte,0),ptr48(karte,0),100*100);
  {writemem32b(ptr48(karte,xx+1+(yy+1)*100),1);
  writemem32b(ptr48(karte,xx+(yy+1)*100),1);
  writemem32b(ptr48(karte,xx-1+(yy+1)*100),1);
  writemem32b(ptr48(karte,xx+1+screeny100[yy]),1);
  writemem32b(ptr48(karte,xx-1+screeny100[yy]),1);
  writemem32b(ptr48(karte,xx+screeny100[yy]),1);
  writemem32b(ptr48(karte,xx+1+(yy-1)*100),1);
  writemem32b(ptr48(karte,xx+(yy-1)*100),1);
  writemem32b(ptr48(karte,xx-1+(yy-1)*100),1);}
End;

Procedure calculate_sl;
 Begin
   For xx := 2 To kartex-2 Do For yy := 2 To kartey-2 Do
     writemem32b (Ptr48 (tkarte, xx + screeny100 [yy] ),
     Round ( (see-2+
     readmem32b (Ptr48 (karte, xx + 2 + screeny100 [yy + 2] ) ) +
     readmem32b (Ptr48 (karte, xx + 1 + screeny100 [yy + 2] ) ) +
     readmem32b (Ptr48 (karte, xx + screeny100 [yy + 2] ) ) +
     readmem32b (Ptr48 (karte, xx - 1 + screeny100 [yy + 2] ) ) +
     readmem32b (Ptr48 (karte, xx - 2 + screeny100 [yy + 2] ) ) +
     readmem32b (Ptr48 (karte, xx + 2 + screeny100 [yy + 1] ) ) +
     readmem32b (Ptr48 (karte, xx + 1 + screeny100 [yy + 1] ) ) +
     readmem32b (Ptr48 (karte, xx + screeny100 [yy + 1] ) ) +
     readmem32b (Ptr48 (karte, xx - 1 + screeny100 [yy + 1] ) ) +
     readmem32b (Ptr48 (karte, xx - 2 + screeny100 [yy + 1] ) ) +
     readmem32b (Ptr48 (karte, xx + 2 + screeny100 [yy] ) ) +
     readmem32b (Ptr48 (karte, xx + 1 + screeny100 [yy] ) ) +
     readmem32b (Ptr48 (karte, xx - 1 + screeny100 [yy] ) ) +
     readmem32b (Ptr48 (karte, xx - 2 + screeny100 [yy] ) ) +
     readmem32b (Ptr48 (karte, xx + 2 + screeny100 [yy - 1] ) ) +
     readmem32b (Ptr48 (karte, xx + 1 + screeny100 [yy - 1] ) ) +
     readmem32b (Ptr48 (karte, xx + screeny100 [yy - 1] ) ) +
     readmem32b (Ptr48 (karte, xx - 1 + screeny100 [yy - 1] ) ) +
     readmem32b (Ptr48 (karte, xx - 2 + screeny100 [yy - 1] ) ) +
     readmem32b (Ptr48 (karte, xx + 2 + screeny100 [yy - 2] ) ) +
     readmem32b (Ptr48 (karte, xx + 1 + screeny100 [yy - 2] ) ) +
     readmem32b (Ptr48 (karte, xx + screeny100 [yy - 2] ) ) +
     readmem32b (Ptr48 (karte, xx - 1 + screeny100 [yy - 2] ) ) +
     readmem32b (Ptr48 (karte, xx - 2 + screeny100 [yy - 2] ) ) ) / 24) );
   Move32 (Ptr48 (tkarte, 0), Ptr48 (karte, 0), screen.kartemem);
 End;

 Procedure calc_coast;
 Begin
   For xx := 1 To kartex-1 Do For yy := 1 To kartey-1 Do Begin
     If readmem32b (Ptr48 (karte, xx + screeny100 [yy] ) ) = 1 Then Begin
       {oben}  If (readmem32b (Ptr48 (karte, xx - 1 + screeny100 [yy] ) ) > 0)
              And (readmem32b (Ptr48 (karte, xx - 1 + screeny100 [yy - 1] ) ) > 0)
              And (readmem32b (Ptr48 (karte, xx + screeny100 [yy - 1] ) ) > 0)
             Then writemem32b (Ptr48 (wasserk, (xx + screeny100 [yy] ) * 4), 0) Else
	       If (readmem32b (Ptr48 (karte, xx - 1 + screeny100 [yy] ) ) = 0)
	      And (readmem32b (Ptr48 (karte, xx - 1 + screeny100 [yy - 1] ) ) > 0)
	      And (readmem32b (Ptr48 (karte, xx + screeny100 [yy - 1] ) ) > 0)
	     Then writemem32b (Ptr48 (wasserk, (xx + screeny100 [yy] ) * 4), 1) Else
	       If (readmem32b (Ptr48 (karte, xx - 1 + screeny100 [yy] ) ) > 0)
              And (readmem32b (Ptr48 (karte, xx - 1 + screeny100 [yy - 1] ) ) = 0)
	      And (readmem32b (Ptr48 (karte, xx + screeny100 [yy - 1] ) ) > 0)
	     Then writemem32b (Ptr48 (wasserk, (xx + screeny100 [yy] ) * 4), 2) Else
	       If (readmem32b (Ptr48 (karte, xx - 1 + screeny100 [yy] ) ) = 0)
              And (readmem32b (Ptr48 (karte, xx - 1 + screeny100 [yy - 1] ) ) = 0)
	      And (readmem32b (Ptr48 (karte, xx + screeny100 [yy - 1] ) ) > 0)
	     Then writemem32b (Ptr48 (wasserk, (xx + screeny100 [yy] ) * 4), 3) Else
	       If (readmem32b (Ptr48 (karte, xx - 1 + screeny100 [yy] ) ) > 0)
              And (readmem32b (Ptr48 (karte, xx - 1 + screeny100 [yy - 1] ) ) > 0)
	      And (readmem32b (Ptr48 (karte, xx + screeny100 [yy - 1] ) ) = 0)
	     Then writemem32b (Ptr48 (wasserk, (xx + screeny100 [yy] ) * 4), 4) Else
	       If (readmem32b (Ptr48 (karte, xx - 1 + screeny100 [yy] ) ) = 0)
              And (readmem32b (Ptr48 (karte, xx - 1 + screeny100 [yy - 1] ) ) > 0)
              And (readmem32b (Ptr48 (karte, xx + screeny100 [yy - 1] ) ) = 0)
	     Then writemem32b (Ptr48 (wasserk, (xx + screeny100 [yy] ) * 4), 5) Else
	       If (readmem32b (Ptr48 (karte, xx - 1 + screeny100 [yy] ) ) > 0)
              And (readmem32b (Ptr48 (karte, xx - 1 + screeny100 [yy - 1] ) ) = 0)
	      And (readmem32b (Ptr48 (karte, xx + screeny100 [yy - 1] ) ) = 0)
             Then writemem32b (Ptr48 (wasserk, (xx + screeny100 [yy] ) * 4), 6) Else
	       If (readmem32b (Ptr48 (karte, xx - 1 + screeny100 [yy] ) ) = 0)
              And (readmem32b (Ptr48 (karte, xx - 1 + screeny100 [yy - 1] ) ) = 0)
              And (readmem32b (Ptr48 (karte, xx + screeny100 [yy - 1] ) ) = 0)
	     Then writemem32b (Ptr48 (wasserk, (xx + screeny100 [yy] ) * 4), 7) Else Halt;

       {unten} If (readmem32b (Ptr48 (karte, xx + 1 + screeny100 [yy] ) ) > 0)
              And (readmem32b (Ptr48 (karte, xx + 1 + screeny100 [yy + 1] ) ) > 0)
              And (readmem32b (Ptr48 (karte, xx + screeny100 [yy + 1] ) ) > 0)
             Then writemem32b (Ptr48 (wasserk, (xx + screeny100 [yy] ) * 4 + 1), 0) Else
               If (readmem32b (Ptr48 (karte, xx + 1 + screeny100 [yy] ) ) = 0)
              And (readmem32b (Ptr48 (karte, xx + 1 + screeny100 [yy + 1] ) ) > 0)
              And (readmem32b (Ptr48 (karte, xx + screeny100 [yy + 1] ) ) > 0)
             Then writemem32b (Ptr48 (wasserk, (xx + screeny100 [yy] ) * 4 + 1), 1) Else
               If (readmem32b (Ptr48 (karte, xx + 1 + screeny100 [yy] ) ) > 0)
              And (readmem32b (Ptr48 (karte, xx + 1 + screeny100 [yy + 1] ) ) = 0)
              And (readmem32b (Ptr48 (karte, xx + screeny100 [yy + 1] ) ) > 0)
             Then writemem32b (Ptr48 (wasserk, (xx + screeny100 [yy] ) * 4 + 1), 2) Else
               If (readmem32b (Ptr48 (karte, xx + 1 + screeny100 [yy] ) ) = 0)
              And (readmem32b (Ptr48 (karte, xx + 1 + screeny100 [yy + 1] ) ) = 0)
              And (readmem32b (Ptr48 (karte, xx + screeny100 [yy + 1] ) ) > 0)
             Then writemem32b (Ptr48 (wasserk, (xx + screeny100 [yy] ) * 4 + 1), 3) Else
               If (readmem32b (Ptr48 (karte, xx + 1 + screeny100 [yy] ) ) > 0)
              And (readmem32b (Ptr48 (karte, xx + 1 + screeny100 [yy + 1] ) ) > 0)
              And (readmem32b (Ptr48 (karte, xx + screeny100 [yy + 1] ) ) = 0)
             Then writemem32b (Ptr48 (wasserk, (xx + screeny100 [yy] ) * 4 + 1), 4) Else
               If (readmem32b (Ptr48 (karte, xx + 1 + screeny100 [yy] ) ) = 0)
              And (readmem32b (Ptr48 (karte, xx + 1 + screeny100 [yy + 1] ) ) > 0)
              And (readmem32b (Ptr48 (karte, xx + screeny100 [yy + 1] ) ) = 0)
             Then writemem32b (Ptr48 (wasserk, (xx + screeny100 [yy] ) * 4 + 1), 5) Else
               If (readmem32b (Ptr48 (karte, xx + 1 + screeny100 [yy] ) ) > 0)
              And (readmem32b (Ptr48 (karte, xx + 1 + screeny100 [yy + 1] ) ) = 0)
              And (readmem32b (Ptr48 (karte, xx + screeny100 [yy + 1] ) ) = 0)
             Then writemem32b (Ptr48 (wasserk, (xx + screeny100 [yy] ) * 4 + 1), 6) Else
               If (readmem32b (Ptr48 (karte, xx + 1 + screeny100 [yy] ) ) = 0)
              And (readmem32b (Ptr48 (karte, xx + 1 + screeny100 [yy + 1] ) ) = 0)
              And (readmem32b (Ptr48 (karte, xx + screeny100 [yy + 1] ) ) = 0)
             Then writemem32b (Ptr48 (wasserk, (xx + screeny100 [yy] ) * 4 + 1), 7)
             Else Halt;

       {links} If (readmem32b (Ptr48 (karte, xx - 1 + screeny100 [yy] ) ) > 0)
           And (readmem32b (Ptr48 (karte, xx - 1 + screeny100 [yy + 1] ) ) > 0)
              And (readmem32b (Ptr48 (karte, xx + screeny100 [yy + 1] ) ) > 0)
             Then writemem32b (Ptr48 (wasserk, (xx + screeny100 [yy] ) * 4 + 2), 0) Else
               If (readmem32b (Ptr48 (karte, xx - 1 + screeny100 [yy] ) ) > 0)
               And (readmem32b (Ptr48 (karte, xx - 1 + screeny100 [yy + 1] ) ) > 0)
              And (readmem32b (Ptr48 (karte, xx + screeny100 [yy + 1] ) ) = 0)
             Then writemem32b (Ptr48 (wasserk, (xx + screeny100 [yy] ) * 4 + 2), 1) Else
               If (readmem32b (Ptr48 (karte, xx - 1 + screeny100 [yy] ) ) > 0)
               And (readmem32b (Ptr48 (karte, xx - 1 + screeny100 [yy + 1] ) ) = 0)
              And (readmem32b (Ptr48 (karte, xx + screeny100 [yy + 1] ) ) > 0)
           Then writemem32b (Ptr48 (wasserk, (xx + screeny100 [yy] ) * 4 + 2), 2) Else
             If (readmem32b (Ptr48 (karte, xx - 1 + screeny100 [yy] ) ) > 0)
             And (readmem32b (Ptr48 (karte, xx - 1 + screeny100 [yy + 1] ) ) = 0)
                And (readmem32b (Ptr48 (karte, xx + screeny100 [yy + 1] ) ) = 0)
             Then writemem32b (Ptr48 (wasserk, (xx + screeny100 [yy] ) * 4 + 2), 3) Else
               If (readmem32b (Ptr48 (karte, xx - 1 + screeny100 [yy] ) ) = 0)
               And (readmem32b (Ptr48 (karte, xx - 1 + screeny100 [yy + 1] ) ) > 0)
                  And (readmem32b (Ptr48 (karte, xx + screeny100 [yy + 1] ) ) > 0)
               Then writemem32b (Ptr48 (wasserk, (xx + screeny100 [yy] ) * 4 + 2), 4) Else
                 If (readmem32b (Ptr48 (karte, xx - 1 + screeny100 [yy] ) ) = 0)
                 And (readmem32b (Ptr48 (karte, xx - 1 + screeny100 [yy + 1] ) ) > 0)
                    And (readmem32b (Ptr48 (karte, xx + screeny100 [yy + 1] ) ) = 0)
                 Then writemem32b (Ptr48 (wasserk, (xx + screeny100 [yy] ) * 4 + 2), 5) Else
                   If (readmem32b (Ptr48 (karte, xx - 1 + screeny100 [yy] ) ) = 0)
                   And (readmem32b (Ptr48 (karte, xx - 1 + screeny100 [yy + 1] ) ) = 0)
                      And (readmem32b (Ptr48 (karte, xx + screeny100 [yy + 1] ) ) > 0)
                   Then writemem32b (Ptr48 (wasserk, (xx + screeny100 [yy] ) * 4 + 2), 6) Else
                     If (readmem32b (Ptr48 (karte, xx - 1 + screeny100 [yy] ) ) = 0)
                     And (readmem32b (Ptr48 (karte, xx - 1 + screeny100 [yy + 1] ) ) = 0)
                        And (readmem32b (Ptr48 (karte, xx + screeny100 [yy + 1] ) ) = 0)
                     Then writemem32b (Ptr48 (wasserk, (xx + screeny100 [yy] ) * 4 + 2), 7)
                     Else Halt;

       {rechts} If (readmem32b (Ptr48 (karte, xx + 1 + screeny100 [yy] ) ) > 0)
       And (readmem32b (Ptr48 (karte, xx + 1 + screeny100 [yy - 1] ) ) > 0)
              And (readmem32b (Ptr48 (karte, xx + screeny100 [yy - 1] ) ) > 0)
       Then writemem32b (Ptr48 (wasserk, (xx + screeny100 [yy] ) * 4 + 3), 0) Else
         If (readmem32b (Ptr48 (karte, xx + 1 + screeny100 [yy] ) ) > 0)
         And (readmem32b (Ptr48 (karte, xx + 1 + screeny100 [yy - 1] ) ) > 0)
            And (readmem32b (Ptr48 (karte, xx + screeny100 [yy - 1] ) ) = 0)
         Then writemem32b (Ptr48 (wasserk, (xx + screeny100 [yy] ) * 4 + 3), 1) Else
           If (readmem32b (Ptr48 (karte, xx + 1 + screeny100 [yy] ) ) > 0)
           And (readmem32b (Ptr48 (karte, xx + 1 + screeny100 [yy - 1] ) ) = 0)
              And (readmem32b (Ptr48 (karte, xx + screeny100 [yy - 1] ) ) > 0)
           Then writemem32b (Ptr48 (wasserk, (xx + screeny100 [yy] ) * 4 + 3), 2) Else
             If (readmem32b (Ptr48 (karte, xx + 1 + screeny100 [yy] ) ) > 0)
             And (readmem32b (Ptr48 (karte, xx + 1 + screeny100 [yy - 1] ) ) = 0)
                And (readmem32b (Ptr48 (karte, xx + screeny100 [yy - 1] ) ) = 0)
             Then writemem32b (Ptr48 (wasserk, (xx + screeny100 [yy] ) * 4 + 3), 3) Else
               If (readmem32b (Ptr48 (karte, xx + 1 + screeny100 [yy] ) ) = 0)
               And (readmem32b (Ptr48 (karte, xx + 1 + screeny100 [yy - 1] ) ) > 0)
                  And (readmem32b (Ptr48 (karte, xx + screeny100 [yy - 1] ) ) > 0)
               Then writemem32b (Ptr48 (wasserk, (xx + screeny100 [yy] ) * 4 + 3), 4) Else
                 If (readmem32b (Ptr48 (karte, xx + 1 + screeny100 [yy] ) ) = 0)
                 And (readmem32b (Ptr48 (karte, xx + 1 + screeny100 [yy - 1] ) ) > 0)
                    And (readmem32b (Ptr48 (karte, xx + screeny100 [yy - 1] ) ) = 0)
                 Then writemem32b (Ptr48 (wasserk, (xx + screeny100 [yy] ) * 4 + 3), 5) Else
                   If (readmem32b (Ptr48 (karte, xx + 1 + screeny100 [yy] ) ) = 0)
                   And (readmem32b (Ptr48 (karte, xx + 1 + screeny100 [yy - 1] ) ) = 0)
                      And (readmem32b (Ptr48 (karte, xx + screeny100 [yy - 1] ) ) > 0)
                   Then writemem32b (Ptr48 (wasserk, (xx + screeny100 [yy] ) * 4 + 3), 6) Else
                     If (readmem32b (Ptr48 (karte, xx + 1 + screeny100 [yy] ) ) = 0)
                     And (readmem32b (Ptr48 (karte, xx + 1 + screeny100 [yy - 1] ) ) = 0)
                        And (readmem32b (Ptr48 (karte, xx + screeny100 [yy - 1] ) ) = 0)
                     Then writemem32b (Ptr48 (wasserk, (xx + screeny100 [yy] ) * 4 + 3), 7)
                     Else Halt;
       writemem32b (Ptr48 (tkarte, xx + screeny100 [yy] ), 12);
     End
     Else
       {  begin
       if readmem32b(ptr48(karte,xx+1+(yy+1]))+
       readmem32b(ptr48(karte,xx+(yy+1)*100))+
       readmem32b(ptr48(karte,xx-1+(yy+1)*100))+
       readmem32b(ptr48(karte,xx+1+screeny100[yy]))+
       readmem32b(ptr48(karte,xx-1+screeny100[yy]))+
       readmem32b(ptr48(karte,xx+1+(yy-1)*100))+
       readmem32b(ptr48(karte,xx+(yy-1)*100))+
       readmem32b(ptr48(karte,xx-1+(yy-1)*100))>0 then writemem32b(ptr48(tkarte,xx+screeny100[yy]),4) else}
       writemem32b (Ptr48 (tkarte, xx + screeny100 [yy] ), 4 + Random (4) );
     {end;}
   End;
   Move32 (Ptr48 (tkarte, 0), Ptr48 (karte, 0), screen.kartemem);
   For xx := 0 To kartex Do writemem32b (Ptr48 (karte, xx), Random (4) + 24);
   For xx := 1 To kartex-1 Do writemem32b (Ptr48 (karte, xx + screeny100[1]), Random (4) + 24);
   For xx := 0 To kartex Do writemem32b (Ptr48 (karte, xx + screeny100[kartey]), Random (4) + 24);
   For xx := 1 To kartex-1 Do writemem32b (Ptr48 (karte, xx + screeny100[kartey-1]), Random (4) + 24);
   For yy := 0 To kartey Do writemem32b (Ptr48 (karte, screeny100 [yy] ), Random (4) + 24);
   For yy := 1 To kartey-1 Do writemem32b (Ptr48 (karte, 1 + screeny100 [yy] ), Random (4) + 24);
   For yy := 0 To kartey Do writemem32b (Ptr48 (karte, kartex + screeny100 [yy] ), Random (4) + 24);
   For yy := 1 To kartey-1 Do writemem32b (Ptr48 (karte, kartex-1 + screeny100 [yy] ), Random (4) + 24);
   {for yy:=1 to 9999 do begin
   writeln(readmem32b(ptr48(wasserk,yy*4)));
   writeln(readmem32b(ptr48(wasserk,yy*4+1)));
   writeln(readmem32b(ptr48(wasserk,yy*4+2)));
   writeln(readmem32b(ptr48(wasserk,yy*4+3)));
   writeln;
   writeln;
   delay(5);
   if keypressed then begin readkey;readkey;end;
   end;}
 End;
procedure calculate3d;
begin
  FillChar32 (Ptr48 (_3DDAT, 0), screen.kartemem, 1);
  FillChar32 (Ptr48 (temper, 0), screen.kartemem, 1);

for xx:=0 to kartex do for yy:=0 to kartey do begin
 if readmem32b(ptr48(gebirge,xx+screeny100[yy]))>0 then writemem32b(ptr48(_3ddat,xx+screeny100[yy]),5+random(3));
 inhalt:=readmem32b(ptr48(karte,xx+screeny100[yy]));
 if (inhalt>=12) and (inhalt<=15) then begin
 writemem32b(ptr48(_3ddat,xx-1+screeny100[yy]),0);
 writemem32b(ptr48(_3ddat,xx+screeny100[yy-1]),0);
 writemem32b(ptr48(_3ddat,xx-1+screeny100[yy-1]),0);
 writemem32b(ptr48(_3ddat,xx+screeny100[yy]),0);
 end;
end;
 for k:=0 to anzdorf do begin
  writemem32b(ptr48(_3ddat,dorfs[k].x+screeny100[dorfs[k].y]),1);
  writemem32b(ptr48(_3ddat,dorfs[k].x+1+screeny100[dorfs[k].y]),1);
  writemem32b(ptr48(_3ddat,dorfs[k].x+2+screeny100[dorfs[k].y]),1);
  writemem32b(ptr48(_3ddat,dorfs[k].x+screeny100[dorfs[k].y+1]),1);
  writemem32b(ptr48(_3ddat,dorfs[k].x+screeny100[dorfs[k].y+1]),1);
  writemem32b(ptr48(_3ddat,dorfs[k].x+screeny100[dorfs[k].y+1]),1);
 end;
  for k:=0 to 10 do
  For xx := 2 To kartex-2 Do For yy := 2 To kartey-2 Do begin
  feld[0]:=readmem32b(ptr48(karte,xx+screeny100[yy]));
  if (feld[0]>=12) and (feld[0]<=15) then continue;
  feld[0]:=readmem32b(ptr48(_3ddat,xx-1+screeny100[yy]));
  feld[1]:=readmem32b(ptr48(_3ddat,xx-1+screeny100[yy-1]));
  feld[2]:=readmem32b(ptr48(_3ddat,xx+screeny100[yy]));
  feld[3]:=readmem32b(ptr48(_3ddat,xx+screeny100[yy-1]));
  if feld[2]-feld[1]<-2 then writemem32b(ptr48(_3ddat,xx-1+screeny100[yy-1]),feld[1]-1);
  if feld[2]-feld[1]>2 then writemem32b(ptr48(_3ddat,xx+screeny100[yy]),feld[2]-1);
  if feld[2]-feld[0]<-1 then writemem32b(ptr48(_3ddat,xx-1+screeny100[yy]),feld[0]-1);
  if feld[2]-feld[0]>1 then writemem32b(ptr48(_3ddat,xx+screeny100[yy]),feld[2]-1);
  if feld[2]-feld[3]<-1 then writemem32b(ptr48(_3ddat,xx+screeny100[yy-1]),feld[3]-1);
  if feld[2]-feld[3]>1 then writemem32b(ptr48(_3ddat,xx+screeny100[yy]),feld[2]-1);

  if feld[3]-feld[1]<-1 then writemem32b(ptr48(_3ddat,xx-1+screeny100[yy-1]),feld[1]-1);
  if feld[3]-feld[1]>1 then writemem32b(ptr48(_3ddat,xx+screeny100[yy-1]),feld[3]-1);
  if feld[3]-feld[0]<-2 then writemem32b(ptr48(_3ddat,xx-1+screeny100[yy]),feld[0]-1);
  if feld[3]-feld[0]>2 then writemem32b(ptr48(_3ddat,xx+screeny100[yy-1]),feld[3]-1);

  if feld[1]-feld[0]<-1 then writemem32b(ptr48(_3ddat,xx-1+screeny100[yy]),feld[0]-1);
  if feld[1]-feld[0]>1 then writemem32b(ptr48(_3ddat,xx-1+screeny100[yy-1]),feld[1]-1);

  end;
  For xx := 1 To kartex-1 Do For yy := 1 To kartey-1 Do begin

   feld[0]:=readmem32b(ptr48(_3ddat,xx-1+screeny100[yy]));
   feld[1]:=readmem32b(ptr48(_3ddat,xx+screeny100[yy]));
   feld[2]:=readmem32b(ptr48(_3ddat,xx+screeny100[yy-1]));
   feld[3]:=readmem32b(ptr48(_3ddat,xx-1+screeny100[yy-1]));

   if (feld[0]=feld[3]+1) and (feld[1]=feld[2]) and (feld[2]=feld[3]) then
      writemem32b(ptr48(temper,xx+screeny100[yy]),0) else
   if (feld[3]=feld[0]+1) and (feld[1]=feld[2]) and (feld[2]=feld[0]) then
      writemem32b(ptr48(temper,xx+screeny100[yy]),1) else
   if (feld[2]=feld[3]+1) and (feld[1]=feld[0]) and (feld[3]=feld[1]) then
      writemem32b(ptr48(temper,xx+screeny100[yy]),2) else
   if (feld[1]=feld[0]+1) and (feld[3]=feld[2]) and (feld[2]=feld[0]) then
      writemem32b(ptr48(temper,xx+screeny100[yy]),3) else
   if (feld[0]=feld[1]+1) and (feld[2]=feld[3]+1) and (feld[3]=feld[1]) then
      writemem32b(ptr48(temper,xx+screeny100[yy]),4) else
   if (feld[3]=feld[0]+1) and (feld[1]=feld[2]+1) and (feld[2]=feld[0]) then
      writemem32b(ptr48(temper,xx+screeny100[yy]),5) else
   if (feld[0]=feld[3]) and (feld[1]=feld[2]) and (feld[3]=feld[2]+1) then
      writemem32b(ptr48(temper,xx+screeny100[yy]),6) else
   if (feld[3]=feld[0]+1) and (feld[1]=feld[2]) and (feld[2]=feld[3]) then
      writemem32b(ptr48(temper,xx+screeny100[yy]),7) else
   if (feld[0]=feld[3]+1) and (feld[1]=feld[2]) and (feld[2]=feld[0]) then
      writemem32b(ptr48(temper,xx+screeny100[yy]),8) else
   if (feld[3]=feld[2]+1) and (feld[1]=feld[0]) and (feld[0]=feld[3]) then
      writemem32b(ptr48(temper,xx+screeny100[yy]),9) else
   if (feld[0]=feld[1]+1) and (feld[3]=feld[2]) and (feld[2]=feld[0]) then
      writemem32b(ptr48(temper,xx+screeny100[yy]),10) else
   if (feld[0]=feld[3]) and (feld[2]=feld[1]) and (feld[2]=feld[0]+1)
      then writemem32b(ptr48(temper,xx+screeny100[yy]),11) else

   if (feld[0]=feld[1]) and (feld[3]=feld[2]) and (feld[0]=feld[3]+1)
      then writemem32b(ptr48(temper,xx+screeny100[yy]),12) else
   if (feld[0]=feld[1]) and (feld[3]=feld[2]) and (feld[3]=feld[0]+1)
      then writemem32b(ptr48(temper,xx+screeny100[yy]),13) else
   if (feld[3]=feld[1]) and (feld[2]=feld[1+1]) and (feld[3]=feld[0]+1)
      then writemem32b(ptr48(temper,xx+screeny100[yy]),14) else
   if (feld[0]=feld[2]) and (feld[3]=feld[2]+1) and (feld[2]=feld[1]+1)
      then writemem32b(ptr48(temper,xx+screeny100[yy]),15) else
   if (feld[0]=feld[3]+1) and (feld[3]=feld[1]) and (feld[1]=feld[2]+1)
      then writemem32b(ptr48(temper,xx+screeny100[yy]),16) else
   if (feld[0]=feld[3]+1) and (feld[0]=feld[2]) and (feld[1]=feld[2]+1)
      then writemem32b(ptr48(temper,xx+screeny100[yy]),17) else

   writemem32b(ptr48(temper,xx+screeny100[yy]),18)
  end;

    move32(ptr48(temper,0),ptr48(hoehe,0),screen.kartemem);
end;
Procedure initkart;
Begin
  screen.kartemem:=(kartex+1) * (kartey+1);
  GetMem32 (temper,screen.kartemem);
  GetMem32 (karte,screen.kartemem);
  GetMem32 (tkarte,screen.kartemem);
  GetMem32 (wasserk,4*screen.kartemem);
  GetMem32 (gebirge,screen.kartemem);
  GetMem32 (hoehe,screen.kartemem);
  GetMem32 (_3DDAT,screen.kartemem);
  { getmem32(landk,400*400); {100*100 Felder}
  {for k:=1 to 999 do begin
  xx:=random(99)+1;
  yy:=random(99)+1;}
  fill_c;
  initplayer;
  For k := 1 To 2 Do calculate_sl;
  initplayer;
  calc_coast;

  FillChar32 (Ptr48 (gebirge, 0), screen.kartemem, 0);
  FillChar32 (Ptr48 (temper, 0), screen.kartemem, 0);
  FillChar32 (Ptr48 (hoehe, 0), screen.kartemem, 0);
{  For xx := 2 To 97 Do For yy := 2 To 97 Do if random(30)=0 then writemem32b(ptr48(_3ddat,xx+screeny100[yy]),random(5));}

  FillChar32 (Ptr48 (temper, 0), screen.kartemem, 0);

  For xx := 0 To kartex Do For yy := 0 To kartey Do
    If (Random (2) = 0) And (readmem32b (Ptr48 (karte, xx + screeny100 [yy] ) ) < 12) Then
      writemem32b (Ptr48 (temper, xx + screeny100 [yy] ), 1);

  for xx:=0 to anzdorf do begin
   dorfs[xx].x:=random(kartex-7)+3;
   dorfs[xx].y:=random(kartey-7)+3;
  end;

  For k := 0 To 2 Do Begin
    For xx := 2 To kartex-2 Do For yy := 2 To kartey-2 Do If readmem32b (Ptr48 (karte, xx + screeny100 [yy] ) ) < 12 Then
      writemem32b (Ptr48 (gebirge, xx + screeny100 [yy] ),
      Round ( (
      readmem32b (Ptr48 (temper, xx + 2 + screeny100[yy + 2]) ) +
      readmem32b (Ptr48 (temper, xx + 1 + screeny100[yy + 2]) ) +
      readmem32b (Ptr48 (temper, xx + screeny100[yy + 2]) ) +
      readmem32b (Ptr48 (temper, xx - 1 + screeny100[yy + 2]) ) +
      readmem32b (Ptr48 (temper, xx - 2 + screeny100[yy + 2]) ) +
      readmem32b (Ptr48 (temper, xx + 2 + screeny100[yy + 1]) ) +
      readmem32b (Ptr48 (temper, xx + 1 + screeny100[yy + 1]) ) +
      readmem32b (Ptr48 (temper, xx + screeny100[yy + 1]) ) +
      readmem32b (Ptr48 (temper, xx - 1 + screeny100[yy + 1]) ) +
      readmem32b (Ptr48 (temper, xx - 2 + screeny100[yy + 1]) ) +
      readmem32b (Ptr48 (temper, xx + 2 + screeny100[yy]) ) +
      readmem32b (Ptr48 (temper, xx + 1 + screeny100[yy]) ) +
      readmem32b (Ptr48 (temper, xx - 1 + screeny100[yy]) ) +
      readmem32b (Ptr48 (temper, xx - 2 + screeny100[yy]) ) +
      readmem32b (Ptr48 (temper, xx + 2 + screeny100[yy - 1]) ) +
      readmem32b (Ptr48 (temper, xx + 1 + screeny100[yy - 1]) ) +
      readmem32b (Ptr48 (temper, xx + screeny100[yy - 1]) ) +
      readmem32b (Ptr48 (temper, xx - 1 + screeny100[yy - 1]) ) +
      readmem32b (Ptr48 (temper, xx - 2 + screeny100[yy - 1]) ) +
      readmem32b (Ptr48 (temper, xx + 2 + screeny100[yy - 2]) ) +
      readmem32b (Ptr48 (temper, xx + 1 + screeny100[yy - 2]) ) +
      readmem32b (Ptr48 (temper, xx + screeny100[yy - 2]) ) +
      readmem32b (Ptr48 (temper, xx - 1 + screeny100[yy - 2]) ) +
      readmem32b (Ptr48 (temper, xx - 2 + screeny100[yy - 2]) ) ) / 24) )
    Else writemem32b (Ptr48 (gebirge, xx + screeny100 [yy] ), 0);
    Move32 (Ptr48 (gebirge, 0), Ptr48 (temper, 0), screen.kartemem);
  End;

  For xx := 1 To kartex-1 Do For yy := 1 To kartey-1 Do
    If readmem32b (Ptr48 (temper, xx + screeny100 [yy] ) ) > 0 Then Begin
      If    (readmem32b (Ptr48 (temper, xx - 1 + screeny100 [yy] ) ) = 0)
      And (readmem32b (Ptr48 (temper, xx + 1 + screeny100 [yy] ) ) = 0)
            And (readmem32b (Ptr48 (temper, xx + screeny100 [yy - 1] ) ) = 0)
            And (readmem32b (Ptr48 (temper, xx + screeny100 [yy + 1] ) ) = 0)
      Then writemem32b (Ptr48 (gebirge, (xx + screeny100 [yy] ) ), 1) Else

        If    (readmem32b (Ptr48 (temper, xx - 1 + screeny100 [yy] ) ) = 0)
        And (readmem32b (Ptr48 (temper, xx + 1 + screeny100 [yy] ) ) = 0)
              And (readmem32b (Ptr48 (temper, xx + screeny100 [yy - 1] ) ) > 0)
              And (readmem32b (Ptr48 (temper, xx + screeny100 [yy + 1] ) ) = 0)
        Then writemem32b (Ptr48 (gebirge, (xx + screeny100 [yy] ) ), 2) Else

          If    (readmem32b (Ptr48 (temper, xx - 1 + screeny100 [yy] ) ) = 0)
          And (readmem32b (Ptr48 (temper, xx + 1 + screeny100 [yy] ) ) > 0)
                And (readmem32b (Ptr48 (temper, xx + screeny100 [yy - 1] ) ) = 0)
                And (readmem32b (Ptr48 (temper, xx + screeny100 [yy + 1] ) ) = 0)
          Then writemem32b (Ptr48 (gebirge, (xx + screeny100 [yy] ) ), 3) Else

            If    (readmem32b (Ptr48 (temper, xx - 1 + screeny100 [yy] ) ) = 0)
            And (readmem32b (Ptr48 (temper, xx + 1 + screeny100 [yy] ) ) > 0)
                  And (readmem32b (Ptr48 (temper, xx + screeny100 [yy - 1] ) ) > 0)
                  And (readmem32b (Ptr48 (temper, xx + screeny100 [yy + 1] ) ) = 0)
            Then writemem32b (Ptr48 (gebirge, (xx + screeny100 [yy] ) ), 4) Else

              If    (readmem32b (Ptr48 (temper, xx - 1 + screeny100 [yy] ) ) = 0)
              And (readmem32b (Ptr48 (temper, xx + 1 + screeny100 [yy] ) ) = 0)
                    And (readmem32b (Ptr48 (temper, xx + screeny100 [yy - 1] ) ) = 0)
                    And (readmem32b (Ptr48 (temper, xx + screeny100 [yy + 1] ) ) > 0)
              Then writemem32b (Ptr48 (gebirge, (xx + screeny100 [yy] ) ), 5) Else

                If    (readmem32b (Ptr48 (temper, xx - 1 + screeny100 [yy] ) ) = 0)
                And (readmem32b (Ptr48 (temper, xx + 1 + screeny100 [yy] ) ) = 0)
                      And (readmem32b (Ptr48 (temper, xx + screeny100 [yy - 1] ) ) > 0)
                      And (readmem32b (Ptr48 (temper, xx + screeny100 [yy + 1] ) ) > 0)
                Then writemem32b (Ptr48 (gebirge, (xx + screeny100 [yy] ) ), 6) Else

                  If    (readmem32b (Ptr48 (temper, xx - 1 + screeny100 [yy] ) ) = 0)
                  And (readmem32b (Ptr48 (temper, xx + 1 + screeny100 [yy] ) ) > 0)
                        And (readmem32b (Ptr48 (temper, xx + screeny100 [yy - 1] ) ) = 0)
                        And (readmem32b (Ptr48 (temper, xx + screeny100 [yy + 1] ) ) > 0)
                  Then writemem32b (Ptr48 (gebirge, (xx + screeny100 [yy] ) ), 7) Else

                    If    (readmem32b (Ptr48 (temper, xx - 1 + screeny100 [yy] ) ) = 0)
                    And (readmem32b (Ptr48 (temper, xx + 1 + screeny100 [yy] ) ) > 0)
                          And (readmem32b (Ptr48 (temper, xx + screeny100 [yy - 1] ) ) > 0)
                          And (readmem32b (Ptr48 (temper, xx + screeny100 [yy + 1] ) ) > 0)
                    Then writemem32b (Ptr48 (gebirge, (xx + screeny100 [yy] ) ), 8) Else

                      If    (readmem32b (Ptr48 (temper, xx - 1 + screeny100 [yy] ) ) > 0)
                      And (readmem32b (Ptr48 (temper, xx + 1 + screeny100 [yy] ) ) = 0)
                            And (readmem32b (Ptr48 (temper, xx + screeny100 [yy - 1] ) ) = 0)
                            And (readmem32b (Ptr48 (temper, xx + screeny100 [yy + 1] ) ) = 0)
                      Then writemem32b (Ptr48 (gebirge, (xx + screeny100 [yy] ) ), 9) Else

                        If    (readmem32b (Ptr48 (temper, xx - 1 + screeny100 [yy] ) ) > 0)
                        And (readmem32b (Ptr48 (temper, xx + 1 + screeny100 [yy] ) ) = 0)
                              And (readmem32b (Ptr48 (temper, xx + screeny100 [yy - 1] ) ) > 0)
                              And (readmem32b (Ptr48 (temper, xx + screeny100 [yy + 1] ) ) = 0)
                        Then writemem32b (Ptr48 (gebirge, (xx + screeny100 [yy] ) ), 10) Else

                          If  (  readmem32b (Ptr48 (temper, xx - 1 + screeny100 [yy] ) ) > 0)
                          And (readmem32b (Ptr48 (temper, xx + 1 + screeny100 [yy] ) ) > 0)
                              And (readmem32b (Ptr48 (temper, xx + screeny100 [yy - 1] ) ) = 0)
                              And (readmem32b (Ptr48 (temper, xx + screeny100 [yy + 1] ) ) = 0)
                          Then writemem32b (Ptr48 (gebirge, (xx + screeny100 [yy] ) ), 11) Else

                            If    (readmem32b (Ptr48 (temper, xx - 1 + screeny100 [yy] ) ) > 0)
                            And (readmem32b (Ptr48 (temper, xx + 1 + screeny100 [yy] ) ) > 0)
                                  And (readmem32b (Ptr48 (temper, xx + screeny100 [yy - 1] ) ) > 0)
                                  And (readmem32b (Ptr48 (temper, xx + screeny100 [yy + 1] ) ) = 0)
                            Then writemem32b (Ptr48 (gebirge, (xx + screeny100 [yy] ) ), 12) Else

                              If    (readmem32b (Ptr48 (temper, xx - 1 + screeny100 [yy] ) ) > 0)
                              And (readmem32b (Ptr48 (temper, xx + 1 + screeny100 [yy] ) ) = 0)
                                    And (readmem32b (Ptr48 (temper, xx + screeny100 [yy - 1] ) ) = 0)
                                    And (readmem32b (Ptr48 (temper, xx + screeny100 [yy + 1] ) ) > 0)
                              Then writemem32b (Ptr48 (gebirge, (xx + screeny100 [yy] ) ), 13) Else

                                If    (readmem32b (Ptr48 (temper, xx - 1 + screeny100 [yy] ) ) > 0)
                                And (readmem32b (Ptr48 (temper, xx + 1 + screeny100 [yy] ) ) = 0)
                                      And (readmem32b (Ptr48 (temper, xx + screeny100 [yy - 1] ) ) > 0)
                                      And (readmem32b (Ptr48 (temper, xx + screeny100 [yy + 1] ) ) > 0)
                                Then writemem32b (Ptr48 (gebirge, (xx + screeny100 [yy] ) ), 14) Else

                                  If    (readmem32b (Ptr48 (temper, xx - 1 + screeny100 [yy] ) ) > 0)
                                  And (readmem32b (Ptr48 (temper, xx + 1 + screeny100 [yy] ) ) > 0)
                                        And (readmem32b (Ptr48 (temper, xx + screeny100 [yy - 1] ) ) = 0)
                                        And (readmem32b (Ptr48 (temper, xx + screeny100 [yy + 1] ) ) > 0)
                                  Then writemem32b (Ptr48 (gebirge, (xx + screeny100 [yy] ) ), 15) Else

                                    If    (readmem32b (Ptr48 (temper, xx - 1 + screeny100 [yy] ) ) > 0)
                                    And (readmem32b (Ptr48 (temper, xx + 1 + screeny100 [yy] ) ) > 0)
                                          And (readmem32b (Ptr48 (temper, xx + screeny100 [yy - 1] ) ) > 0)
                                          And (readmem32b (Ptr48 (temper, xx + screeny100 [yy + 1] ) ) > 0)
                                    Then writemem32b (Ptr48 (gebirge, (xx + screeny100 [yy] ) ), 16);
    End;
calculate3d;
End;

Function checkkey;
Var a: Char;
Begin
  If KeyPressed Then Begin
    a := ReadKey; If a = #0 Then a := ReadKey;
    While KeyPressed Do ReadKey;
    Case a Of
      #77:
           Begin Dec (scrollx); Inc (scrolly); End;
      #75: Begin Inc (scrollx); Dec (scrolly); End;
      #80: Begin Dec (scrolly); Dec (scrollx); End;
      #72: Begin Inc (scrolly); Inc (scrollx); End;
      '+': If race < 2 Then Inc (race) Else race := 0;
      '-': If race > 0 Then Dec (race) Else race := 2;
      #68: Begin If screen.akmodus < $105 Then Inc (screen.akmodus, 2) Else screen.akmodus := $101;
        initvesa (screen.akmodus);
        screen.randl := 0; screen.rando := 0; screen.randu := screen.maxy - 1; screen.randr := screen.maxx;
        mouse_setx (screen.randl, screen.randr - 21);
        mouse_sety (screen.rando, screen.randu - 21);
        addx := screen.maxx div 2;
        addy := 10;

      End;
      #59: If kart Then kart := False Else kart := True;
      #60: If testframe Then testframe := False Else testframe := True;
      #61: If gridded Then gridded := False Else gridded := True;
      #67: shot;
      'c': Begin fill_c; For k := 1 To 2 Do calculate_sl; calc_coast; calculate3d;End;
    End;
    testscrollxy;
  End;
  checkkey := a;
End;


{procedure warsproc;far;
begin
exitproc:=@saveexiter;
restorekbdinterrupt;
end;                 }
procedure intro;
var xer, yer, nummer: Array [0..20] Of LongInt;
zz:longint;
t:text;
readstring:string;
begin
schrift[aktab].blacker:=true;
copytovga2;
readkey;
readkey;
show_picture (screen.maxx Div 2 - 160, screen.maxy Div 2 - 100, 'wars9');
  While KeyPressed Do ReadKey;
  For zz := 0 To 20 Do Begin
    xer [zz] := Random (screen.maxx - 50) + 10;
    yer [zz] := Random (screen.maxy - 30);
    nummer [zz] := Random (8);
  End;
assign(t,'d:\wars\history.txt');
reset(t);
repeat
readln(t,readstring);
writes(readstring);
writes(#13#10);
copytovga2;
until readkey=#27;
{  Repeat
{    FillChar32 (Ptr48 (h, 0), screen.memneed, 0);}
{    show_picture (screen.maxx Div 2 - 160, screen.maxy Div 2 - 100, 'wars9');}
{    For zz := 0 To 20 Do Begin
      Inc (xer [zz], 3);
      If xer [zz] > screen.maxx - 30 Then Begin
        putsprite (xer [zz] - 8, 100, sp.leer);
        xer [zz] := 0 - Random (50);
        yer [zz] := Random (screen.maxy - 30);
      End;
      Inc (nummer [zz] );
      If nummer [zz] > 7 Then nummer [zz] := 0;
      putsprite (xer [zz], yer [zz], sp.leut [nummer [zz], 2] );
    End;
    copytovga;
  Until KeyPressed;}
end;

Begin
  For xx := 0 To kartey+1 Do screeny100 [xx] := xx * (kartex+1);
  shotnr:=0;
  {setkbdinterrupt;
  saveexiter:=exitproc;
  exitproc:=@warsproc;}
End.