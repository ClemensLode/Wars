Unit wars;
Interface
Uses newfrontier;
Const kartex = 100;
  kartey = 100;
Var fauna,_3ddat,hoehe,dorfs, gebirge, landk, temper, karte, wasserk: tselector;
  addx, addy, scrollx, scrolly: LongInt;
  framessec, race: Word;
  gridded, good, kart, getinfo, testframe: Boolean;
  see: Real;
  activ: Array [0..49] Of Word;
  screeny100: Array [0..99] Of Word;
Procedure init (Mode: Word); {Initialisiert WARS!}
Procedure paint; {Malt alles auf den Bildschirm}
Procedure showkarte; {Zeigt Karte}
Procedure initkart; {Initiert (fuellt) Karte}
Procedure mausit;
Var feinx, feiny, bax, bay: LongInt;
Function checkkey: Char; {Kommunikation mit Programm (Maus,Joystick,Tastatur etc.)}
 Implementation
Uses vesa103, crt, DOS, maus, modexlib, units;
Var
  temp, tkarte: tselector;
  ttx, tty, t1, t2, funktion, oldmp, mp, X5, Y5, klickx, klicky, oldx, oldy, X4, Y4, xx, yy, k: LongInt;
  fx, fy: Word;
  resx, resy, framestring: String;
  saveexiter: Pointer;
  ziel: LongInt;
  shotnr,inhalt, ergebnis: Byte;
procedure shot;
var shotstr:string;
begin
str(shotnr,shotstr);
inc(shotnr);
{shotstr:='WARS.sht';}
bsave32('c:\wars.sht',h,screen.memneed);
end;
Procedure mausit;
  Var
    tfx, tfy, tempus, te2: Integer;
  Begin
    oldx := fx; oldy := fy;
    oldmp := mp;
    mouse_getposition;
    mp := mouse. but;
    fx := mouse. X;
    fy := mouse. Y;
    Inc (bax, fx - oldx);
    Inc (bay, fy - oldy);
    If bax > screen.randr - 32 Then Begin Dec (scrollx); Inc (scrolly); End;
    If bax < screen.randl + 12 Then Begin Inc (scrollx); Dec (scrolly); End;
    If bay > screen.randu - 32 Then Begin Dec (scrollx); Dec (scrolly); End;
    If bay < screen.rando + 12 Then Begin Inc (scrollx); Inc (scrolly); End;
    If scrollx > 10 Then scrollx := 10;
    If scrollx < - 80 Then scrollx := - 80;
    If scrolly > 0 Then scrolly := 0;
    If scrolly < - 90 Then scrolly := - 90;
    tempus := bax Mod 64;
    te2 := bay Mod 32 + 1;
    feinx := 0; feiny := 0;
    If te2 < 16 Then Begin
      If tempus < te2 * 2 Then feinx := - 1 Else If tempus > 32 - te2 * 2 Then feiny := - 1;
    End Else If te2 > 16 Then Begin
      Dec (te2, 16);
      If tempus < te2 * 2 Then feiny := 1 Else If tempus > 32 - te2 * 2 Then feinx := 1;
    End;
    If bax < 2 Then bax := 2;
    If bay < 2 Then bay := 2;
    If bax > screen.maxx - 2 Then bax := screen.maxx - 2;
    If bay > screen.maxy - 2 Then bay := screen.maxy - 2;
    ttx := feinx + bax Div 64 + bay Div 32 - scrollx;
    tty := feiny - bax Div 64 + bay Div 32 - scrolly;
    If ttx < 1 Then ttx := 1;
    If tty < 1 Then tty := 1;
    If ttx > 98 Then ttx := 98;
    If tty > 98 Then tty := 98;
    t1 := (ttx + scrollx) * 32 - (tty + scrolly) * 32;
    t2 := (ttx + scrollx) * 16 + (tty + scrolly) * 16;
    If (mp = 0) And (oldmp = 0) Then putransprite (bax, bay, sp.hand [race, 2] ) Else
      If (mp = 2) And (oldmp = 0) Then putransprite (bax, bay, sp.hand [race, 4] ) Else
        If (mp = 2) And (oldmp = 2) Then putransprite (bax, bay, sp.hand [race, 3] ) Else
          If (mp = 0) And (oldmp = 2) Then putransprite (bax, bay, sp.hand [race, 4] ) Else
            If (mp = 1) And (oldmp = 0) Then putransprite (bax, bay, sp.hand [race, 1] ) Else
              If (mp = 1) And (oldmp = 1) Then putransprite (bax, bay, sp.hand [race, 1] ) Else
                If (mp = 0) And (oldmp = 1) Then putransprite (bax, bay, sp.hand [race, 1] ) Else
                  putransprite (bax, bay, sp.hand [race, 2] );
    If (mp = 0) And (oldmp = 0) Then Begin
      klickx := 0;
      klicky := 0;
      funktion := 0;
    End;
    {   if (mp=1) and (oldmp=0) and (funktion<>3) and (mouse.x>addx-100) and (mouse.x<addx+100) and (mouse.y+10>addy)
    and (mouse.y+10<addy+100) then begin
    klickx:=mouse.x;
    klicky:=mouse.y;
    funktion:=1;
    end;}
    If (mp = 1) And (oldmp = 0) Then Begin
      FillChar (activ, 50, 0);
      For xx := 0 To anzmann Do If (spieler [xx].AX = ttx) And (spieler [xx].ay = tty) Then activ [0] := xx;
    End;
    If ( (mp = 2) And (oldmp = 0) And (kart) And (mouse. X <= addx + 100) And (mouse. X >= addx - 100) And (mouse. Y >= addy)
       And (mouse. Y <= addy + 100) ) Or ( (mp = 2) And (oldmp = 2) And (funktion = 5) )
    Then Begin
      funktion := 5;
      klickx := mouse. X - addx;
      klicky := mouse. Y - addy;
      scrollx := - (klickx Div 2 + klicky);
      scrolly := - ( - klickx Div 2 + klicky);
      If scrollx > 10 Then scrollx := 10;
      If scrollx < - 80 Then scrollx := - 80;
      If scrolly > 0 Then scrolly := 0;
      If scrolly < - 90 Then scrolly := - 90;
    End;

    If (mp = 0) And (oldmp = 2) And (funktion = 0) Then
      For xx := 0 To 49 Do If activ [xx] > 0 Then If spieler [activ [xx] ].px = 0 Then
        gotoxye (ttx, tty, activ [xx] )
      Else spieler [activ [xx] ].weglong := spieler [activ [xx] ].wegp;
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
    screen.randu:=screen.maxy-20;
  End;
Procedure initplayer;
Begin
  For xx := 0 To anzmann Do With spieler [xx] Do Begin
    blocker:=false;
    AX := Random (94) + 3;
    ay := Random (94) + 3;
    writemem32b (Ptr48 (karte, AX + screeny100 [ay] ), 0);
    go := False;
    CX := AX;
    cy := ay;
    phase := Random (8);
    richtung := Random (8);
  End;
End;
Procedure init (Mode: Word);
 Begin
   gridded := false;
   GetMem32 (sprdata, 280000);
   Asm mov AX, $13; Int $10; End;
   Randomize;
   screen_off;
   initkart;
   initstuff;
   initcoast;
   screen_on;
   initvesa (Mode);
   screen.randl := 0; screen.rando := 0; screen.randu := screen.maxy - 1; screen.randr := screen.maxx - 1;
   mouse_setx (screen.randl, screen.randr - 21);
   mouse_sety (screen.rando, screen.randu - 21);
   scrollx := 0;
   scrolly := 0;
   schrift.format := True;
   addx := screen.maxx - 210;
   addy := screen.maxy - 200;
 End;
Procedure paint_karte;
var adder:word;
Begin
  Move32 (Ptr48 (virscr, 0), Ptr48 (h, 0), screen.memneed); {Hinterlaesst *mit Klammern* Mausspuren}
  For yy := 0 To 99 Do   {Painting}
    For xx := 0 To 99 Do
    Begin
      adder:=0;
      if (xx>0) and (xx<99) and (yy>0) and (yy<99) then begin
      adder:=readmem32b(ptr48(_3ddat,xx+screeny100[yy]));
      if adder>readmem32b(ptr48(_3ddat,xx-1+screeny100[yy])) then adder:=readmem32b(ptr48(_3ddat,xx-1+screeny100[yy]));
      if adder>readmem32b(ptr48(_3ddat,xx+screeny100[yy-1])) then adder:=readmem32b(ptr48(_3ddat,xx+screeny100[yy-1]));
      if adder>readmem32b(ptr48(_3ddat,xx-1+screeny100[yy-1])) then adder:=readmem32b(ptr48(_3ddat,xx-1+screeny100[yy-1]));
      end;
      X4 := (xx + scrollx) ShL 5 - (yy + scrolly) ShL 5;
      Y4 := (xx + scrollx) ShL 4 + (yy + scrolly) ShL 4-adder shl 3;
      inhalt := readmem32b (Ptr48 (karte, xx + screeny100 [yy] ) );
      If (inhalt >= 12) And (inhalt <= 15) Then Begin
        ziel := (xx + screeny100 [yy] ) * 4;
        putcombsprite (X4, Y4, readmem32b (Ptr48 (wasserk, ziel + 0) ), readmem32b (Ptr48 (wasserk, ziel + 1) ),
        readmem32b (Ptr48 (wasserk, ziel + 2) ), readmem32b (Ptr48 (wasserk, ziel + 3) ) );
      End Else Begin
        dec(y4,8);
        inhalt:=readmem32b(ptr48(hoehe,xx+screeny100[yy]));
{        if inhalt=10 then putsprite (X4, Y4, sp.grass [4] ) else}
        if inhalt=15 then dec(y4,8);
        if gridded then inc(inhalt,20);
        putransprite (X4, Y4, sp.hoehe [inhalt]);
        If readmem32b (Ptr48 (gebirge, xx + screeny100 [yy] ) ) > 0 Then
          putransprite (X4, Y4, sp.berg [readmem32b (Ptr48 (gebirge, xx + screeny100 [yy] ) ) - 1] );
        If readmem32b (Ptr48 (dorfs, xx + screeny100 [yy] ) ) > 0 Then
          putransprite (X4, Y4, sp.dorf);
      End;
    End;
End;
Procedure paint_frame;
Var hours, mins, secs: Word;
  nam, hourss, minss, secss, temps: String;
Begin
  Str (framessec: 2, framestring);
  Str (screen.maxx: 4, resx);
  Str (screen.maxy, resy);
  nam := '';

  Case readmem32b (Ptr48 (karte, ttx + screeny100 [tty] ) ) Of
    4..7: If readmem32b (Ptr48 (gebirge, ttx + screeny100 [tty] ) ) > 0 Then nam := 'Gebirge'#10#13 Else
      If readmem32b (Ptr48 (dorfs, ttx + screeny100 [tty] ) ) > 0 Then nam := 'Ein Dorf'#10#13 Else
        nam := 'Grassfeld'#10#13;
    12..15: If readmem32b (Ptr48 (wasserk, (ttx + screeny100 [tty] ) * 4) ) > 0 Then nam := 'Kuestenfeld'#10#13 Else
      nam := 'Wasserfeld'#10#13;
    24..27: nam := 'Randmarkierung'#10#13;
  End;
  message (0, screen.maxy - 132, 'Frames pro Sekunde :' + framestring + #10#13#10#13 + nam + #10#13'Aufloesung :' + resx + '*'
  + resy + #10#13#10#13 + 'Error : ' + errornum);

End;

Procedure paint;
 Begin
   paint_karte;
   putransprite (t1, t2, sp.grid2);
   For xx := 0 To anzmann Do With spieler [xx] Do If (AX > 0) And (ay > 0) Then Begin
     X4 := (AX + scrollx) ShL 5 + px * 2 - (ay + scrolly) ShL 5 - py * 2;
     Y4 := (AX + scrollx) ShL 4 + px + (ay + scrolly) ShL 4 + py-readmem32b(ptr48(_3ddat,ax+screeny100[ay]))*8;
     For temp := 0 To 49 Do If activ [temp] = xx Then putransprite (X4, Y4, sp.grid);
     putransprite (X4 + 28, Y4 - 11, sp.leut [phase, richtung] );
   End;
   If kart Then showkarte;
   mausit;
   If testframe Then paint_frame;
   {leute}
   copytovga;
 End;

Procedure showkarte;
Var addz: Word;
Begin
  For xx := 0 To 99 Do For yy := 0 To 99 Do Begin
    ziel := xx - yy + screen.screeny [ (xx + yy) ShR 1 + addy] + addx;
    inhalt := readmem32b (Ptr48 (karte, xx + screeny100 [yy] ) );
    Case inhalt Of
      0..3: ergebnis := 206 + Random (2) + inhalt;
      4..7: If readmem32b (Ptr48 (gebirge, xx + screeny100 [yy] ) ) > 0 Then
      ergebnis := 91-random(2) Else
        If readmem32b (Ptr48 (dorfs, xx + screeny100 [yy] ) ) > 0 Then ergebnis := 127 Else
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
    writemem32b (Ptr48 (h, ziel), ergebnis);
  End;
  rechteck ( - scrollx + scrolly + addx, ( - scrollx - scrolly) Div 2 + addy, - scrollx + scrolly + screen.maxx Div 50 + addx,
  ( - scrollx - scrolly) Div 2 + screen.maxy Div 50 + addy, 1, False);
End;

Procedure fill_c;
Begin
  If readmem32b (Ptr48 (karte, 0) ) = 0 Then Begin
    For xx := 0 To 99 Do For yy := 0 To 99 Do
      writemem32b (Ptr48 (karte, xx + screeny100 [yy] ), Random (2) ); {Wasser oder Land}
    Exit;
  End;
  For xx := 0 To 99 Do For yy := 0 To 99 Do
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
   For xx := 2 To 97 Do For yy := 2 To 97 Do
     writemem32b (Ptr48 (tkarte, xx + screeny100 [yy] ),
     Round ( (see+
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
   Move32 (Ptr48 (tkarte, 0), Ptr48 (karte, 0), 100 * 100);
 End;

 Procedure calc_coast;
 Begin
   For xx := 1 To 98 Do For yy := 1 To 98 Do Begin
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
   Move32 (Ptr48 (tkarte, 0), Ptr48 (karte, 0), 100 * 100);
   For xx := 0 To 99 Do writemem32b (Ptr48 (karte, xx), Random (4) + 24);
   For xx := 1 To 98 Do writemem32b (Ptr48 (karte, xx + 100), Random (4) + 24);
   For xx := 0 To 99 Do writemem32b (Ptr48 (karte, xx + 99 * 100), Random (4) + 24);
   For xx := 1 To 98 Do writemem32b (Ptr48 (karte, xx + 98 * 100), Random (4) + 24);
   For yy := 0 To 99 Do writemem32b (Ptr48 (karte, screeny100 [yy] ), Random (4) + 24);
   For yy := 1 To 98 Do writemem32b (Ptr48 (karte, 1 + screeny100 [yy] ), Random (4) + 24);
   For yy := 0 To 99 Do writemem32b (Ptr48 (karte, 99 + screeny100 [yy] ), Random (4) + 24);
   For yy := 1 To 98 Do writemem32b (Ptr48 (karte, 98 + screeny100 [yy] ), Random (4) + 24);
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

Procedure initkart;
var feld:array[0..3] of byte;
Begin
  GetMem32 (temper, 100 * 100);
  GetMem32 (karte, 100 * 100); {100*100 Felder}
  GetMem32 (tkarte, 100 * 100); {100*100 Felder}
  GetMem32 (wasserk, 400 * 400); {100*100 Felder}
  GetMem32 (gebirge, 100 * 100); {100*100 Felder}
  GetMem32 (dorfs, 100 * 100); {100*100 Felder}
  GetMem32 (hoehe, 100 * 100); {100*100 Felder}
  GetMem32 (_3DDAT, 100 * 100); {100*100 Felder}
  { getmem32(landk,400*400); {100*100 Felder}
  {for k:=1 to 999 do begin
  xx:=random(99)+1;
  yy:=random(99)+1;}
  fill_c;
  initplayer;
  For k := 1 To 2 Do calculate_sl;
  initplayer;
  calc_coast;

  FillChar32 (Ptr48 (gebirge, 0), 100 * 100, 0);
  FillChar32 (Ptr48 (temper, 0), 100 * 100, 0);
  FillChar32 (Ptr48 (dorfs, 0), 100 * 100, 0);
  FillChar32 (Ptr48 (hoehe, 0), 100 * 100, 0);
{  For xx := 2 To 97 Do For yy := 2 To 97 Do if random(30)=0 then writemem32b(ptr48(_3ddat,xx+screeny100[yy]),random(5));}

  FillChar32 (Ptr48 (temper, 0), 100 * 100, 0);

  For xx := 0 To 99 Do For yy := 0 To 99 Do
    If (Random (2) = 0) And (readmem32b (Ptr48 (karte, xx + screeny100 [yy] ) ) < 12) Then
      writemem32b (Ptr48 (temper, xx + screeny100 [yy] ), 1);

  For xx := 0 To 99 Do For yy := 0 To 99 Do
    If (Random (200) = 0) And (readmem32b (Ptr48 (karte, xx + screeny100 [yy] ) ) < 12) Then
      writemem32b (Ptr48 (dorfs, xx + screeny100 [yy] ), 1);

  For k := 0 To 2 Do Begin
    For xx := 2 To 97 Do For yy := 2 To 97 Do If readmem32b (Ptr48 (karte, xx + screeny100 [yy] ) ) < 12 Then
      writemem32b (Ptr48 (gebirge, xx + screeny100 [yy] ),
      Round ( (
      readmem32b (Ptr48 (temper, xx + 2 + (yy + 2) * 100) ) +
      readmem32b (Ptr48 (temper, xx + 1 + (yy + 2) * 100) ) +
      readmem32b (Ptr48 (temper, xx + (yy + 2) * 100) ) +
      readmem32b (Ptr48 (temper, xx - 1 + (yy + 2) * 100) ) +
      readmem32b (Ptr48 (temper, xx - 2 + (yy + 2) * 100) ) +
      readmem32b (Ptr48 (temper, xx + 2 + (yy + 1) * 100) ) +
      readmem32b (Ptr48 (temper, xx + 1 + (yy + 1) * 100) ) +
      readmem32b (Ptr48 (temper, xx + (yy + 1) * 100) ) +
      readmem32b (Ptr48 (temper, xx - 1 + (yy + 1) * 100) ) +
      readmem32b (Ptr48 (temper, xx - 2 + (yy + 1) * 100) ) +
      readmem32b (Ptr48 (temper, xx + 2 + (yy) * 100) ) +
      readmem32b (Ptr48 (temper, xx + 1 + (yy) * 100) ) +
      readmem32b (Ptr48 (temper, xx - 1 + (yy) * 100) ) +
      readmem32b (Ptr48 (temper, xx - 2 + (yy) * 100) ) +
      readmem32b (Ptr48 (temper, xx + 2 + (yy - 1) * 100) ) +
      readmem32b (Ptr48 (temper, xx + 1 + (yy - 1) * 100) ) +
      readmem32b (Ptr48 (temper, xx + (yy - 1) * 100) ) +
      readmem32b (Ptr48 (temper, xx - 1 + (yy - 1) * 100) ) +
      readmem32b (Ptr48 (temper, xx - 2 + (yy - 1) * 100) ) +
      readmem32b (Ptr48 (temper, xx + 2 + (yy - 2) * 100) ) +
      readmem32b (Ptr48 (temper, xx + 1 + (yy - 2) * 100) ) +
      readmem32b (Ptr48 (temper, xx + (yy - 2) * 100) ) +
      readmem32b (Ptr48 (temper, xx - 1 + (yy - 2) * 100) ) +
      readmem32b (Ptr48 (temper, xx - 2 + (yy - 2) * 100) ) ) / 24) )
    Else writemem32b (Ptr48 (gebirge, xx + screeny100 [yy] ), 0);
    Move32 (Ptr48 (gebirge, 0), Ptr48 (temper, 0), 100 * 100);
  End;

  For xx := 1 To 98 Do For yy := 1 To 98 Do
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
  FillChar32 (Ptr48 (_3DDAT, 0), 100 * 100, 3);
  FillChar32 (Ptr48 (temper, 0), 100 * 100, 3);

for xx:=0 to 99 do for yy:=0 to 99 do begin
 if readmem32b(ptr48(gebirge,xx+screeny100[yy]))>0 then writemem32b(ptr48(_3ddat,xx+screeny100[yy]),5);
 inhalt:=readmem32b(ptr48(karte,xx+screeny100[yy]));
 if (inhalt>=12) and (inhalt<=15) then begin
 writemem32b(ptr48(_3ddat,xx-1+screeny100[yy]),0);
 writemem32b(ptr48(_3ddat,xx+screeny100[yy-1]),0);
 writemem32b(ptr48(_3ddat,xx-1+screeny100[yy-1]),0);
 writemem32b(ptr48(_3ddat,xx+screeny100[yy]),0);
 end;
 if readmem32b(ptr48(dorfs,xx+screeny100[yy]))>0 then writemem32b(ptr48(_3ddat,xx+screeny100[yy]),1);
end;

  for k:=0 to 10 do
  For xx := 2 To 97 Do For yy := 2 To 97 Do begin
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
  For xx := 1 To 98 Do For yy := 1 To 98 Do begin

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

    move32(ptr48(temper,0),ptr48(hoehe,0),10000);
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
        addx := screen.maxx - 210;
        addy :=  screen.maxy - 200;
      End;
      #59: If kart Then kart := False Else kart := True;
      #60: If testframe Then testframe := False Else testframe := True;
      #61: If gridded Then gridded := False Else gridded := True;
      #67: shot;
      'c': Begin fill_c; For k := 1 To 2 Do calculate_sl; calc_coast; End;
    End;
    If scrollx > 10 Then scrollx := 10;
    If scrollx < - 80 Then scrollx := - 80;
    If scrolly > 10 Then scrolly := 10;
    If scrolly < - 90 Then scrolly := - 90;
  End;
  checkkey := a;
End;


{procedure warsproc;far;
begin
exitproc:=@saveexiter;
restorekbdinterrupt;
end;                 }


Begin
  For xx := 0 To 99 Do screeny100 [xx] := xx * 100;
  shotnr:=0;
  {setkbdinterrupt;
  saveexiter:=exitproc;
  exitproc:=@warsproc;}
End.