{Vesa-Unit Version 1.04. Lauffaehig zur Zeit in den folgenden Modi:
   101h
   103h
   105h
   16 Bit Farbunterstuetzung wird noch gemacht!
Jetzt machen : Temporaere Variablen definieren {1. bis 3. Grad}{ und externe Variablendatei erstellen}



Unit VESA103;
Interface
Uses newfrontier, gif, modexlib;
const
  anz = 100;
  gelaendtab: Array [0..31] Of LongInt =
  (30,28,26,24,22,20,18,16,14,12,10, 8, 6, 4, 2, 0, 0, 2, 4, 6, 8,10,12,14,16,18,20,22,24,26,28,30);
  gelaendlang: Array [0..31] Of LongInt =
  ( 4, 8,12,16,20,24,28,32,36,40,44,48,52,56,60,64,64,60,56,52,48,44,40,36,32,28,24,20,16,12, 8, 4);
  schaltx = 62; schalty = 22;
  schalt2X = 96;
Type
  spritetyp = Record
                dtx, dty: Word;  {Breite, Hoehe}
                adr: LongInt;   {Adresse in SPRDATA}
              End;

  TWordArray = Array [Byte] Of Word;

  TVESARec = Record
               VBESig             : Array [0..3] Of Char;
               minVersion         : Byte;
               majVersion         : Byte;
               OEMStringPtr       : Pchar;
               Capabilities       : LongInt;
               VideoModePtr       : ^TWordArray;
               TotalMemory        : Word;

               {VESA 2.0}
               OemSoftwareRev     : Word;
               OemVendorNamePtr   : Pchar;
               OemProductNamePtr  : Pchar;
               OemProductRevPtr   : Pchar;
               Paddington: Array [35..256] Of Byte; {Change the upper bound to 512}
               {if you are using VBE2.0}
             End;
  
  TModeRec = Record
               ModeAttributes     : Word;
               WindowAFlags       : Byte;
               WindowBFlags       : Byte;
               Granularity        : Word;
               WindowSize         : Word;
               WindowASeg         : Word;
               WindowBSeg         : Word;
               BankSwitch         : Pointer;
               BytesPerLine       : Word;
               XRes, YRes          : Word;
               CharWidth          : Byte;
               CharHeight         : Byte;
               NumBitplanes       : Byte;
               BitsPerPixel       : Byte;
               NumberOfBanks      : Byte;
               MemoryModel        : Byte;
               BankSize           : Byte;
               NumOfImagePages    : Byte;
               Reserved           : Byte;
               {Direct Colour fields (required for Direct/6 and YUV/7 memory models}
               RedMaskSize        : Byte;
               RedFieldPosition   : Byte;
               GreenMaskSize      : Byte;
               GreenFieldPosition : Byte;
               BlueMaskSize       : Byte;
               BlueFieldPosition  : Byte;
               RsvdMaskSize       : Byte;
               RsvdFieldPosition  : Byte;
               DirectColourMode   : Byte;
               {VESA 2.0 stuff}
               PhysBasePtr        : LongInt;
               OffScreenMemOffset : Pointer;
               OffScreenMemSize   : Word;
               paddington: Array [49..256] Of Byte; {Change the upper bound to 512}
               {if you are using VBE2.0}
             End;
  var

  schrift:record
   blacker: Boolean;            {Hintergrund der Buchstaben schwarz/transparent}
   zhb: Array [0..2] Of Record
                         dx, dy: Byte;
                        End;
   wx, wy, minwx, minwy, maxwx,maxwy: Word;  {Aktuelle Schriftposition, obere linke Ecke}
   format: Boolean;             {Format der Buchstabendatei}
   aktab: byte;                 {Aktueller Schriftsatz}
  end;

  screen:record
   MaxY,  MaxX: LongInt;
   screeny: Array [ - 100..768] Of LongInt;
   akmodus: Word;
   MemNeed,
   randl, randr, rando, randu: LongInt;
   _16bit: LongInt;
   rest, gross, granularity, winsize: LongInt;
   Totalmemory: LongInt;
   VBESignature: String [4];
   granny, akw: Word;
  end;


  sp:record
   sprdatazahl:longint;
   hoehe:array [0..40] of spritetyp;
   zeichen: Array [0..2, 0..101] Of spritetyp; {Die Buchstaben... >> Auf ein Spritetyp konzentrieren (wie beim Rest)}
   hand: Array [0..2, 0..4] Of spritetyp;
   grass: Array [0..28] Of spritetyp;
   schalt: Array [0..7] Of spritetyp;
   leut: Array [0..7, 0..7] Of spritetyp;
   berg: Array [0..15] Of spritetyp;
   mincoast: Array [0..31] Of spritetyp;
   Min2coast: Array [0..31] Of spritetyp;
   leer, dorf, grid, grid2: spritetyp;
   rahmo, rahmu, rahml, rahmr, k1, k2, k3, k4: spritetyp;
   end;

  sprdata, virscr, h: tselector;
  Exiter: Pointer;
  VESARec:^TVESARec;
  ModeRec:^TModeRec;

Procedure copytovga;
{Kopiert den gesamten Inhalt vom virtuellen Bildschirm "h" zur Grafikkarte}
Procedure vesastart (zeile: Word);
{Setzt neuen Vesastart. Wichtig z.B. fuer Scrolling}
Procedure Fill (col: LongInt);
{Fuellt "h" mit lauter col}
Procedure initvesa (Mode: Word);
{Holt Informationen ueber den Modus, setzt ihn und initialisiert "h"}
Procedure getspritegel (offs: Word; Var spr: spritetyp);
{Holt vom $13 Bildschirm eine Raute in den Speicher "sprdata"}
Procedure getsprite (offs: Word; brei, hoc: Word; Var spr: spritetyp);
{Holt vom $13 Bildschirm ein Quadrat in den Speicher "sprdata"}
Procedure putsprite (ox, oy: Word; spr: spritetyp);
{Setzt ohne Ruecksicht auf Verluste (nicht transparent) ein quadratisches Sprite}
Procedure putransprite (ox, oy: LongInt; spr: spritetyp);
{Setzt ein durchsichtiges Quadrat auf den Bildschirm. Muss noch optimiert werden!}
Procedure putgelsprite (ox, oy: LongInt; spr: spritetyp);
{Setzt eine Raut auf den Bildschirm}
Procedure rechteck (X1, Y1, X2, Y2: Word; col: Byte; Fill: Boolean);
{Ein gefuelltes (0=transparent) Rechteck}
Procedure initstuff;
{Laedt Mauszeiger, Schrift und markierte Felder}
Procedure writes (was: String);
{Schreibt was zu screen.wx,wy}
Procedure click (ox, oy: Word; on: Byte; txt: String);
{Eine Drueckbare Taste...}
Procedure message (X1, Y1: Word; was: String);
{Ein Kasten mit einer Botschaft "was"}
Procedure putcombsprite (ox, oy: LongInt; o, u, l, r: Byte);
{Setzt Kueste}
Procedure show_picture (X, Y: LongInt; Name: String);
{Laedt ein Bild von der Platte auf den Schirm}
Procedure load_picture (X, Y: LongInt; Name: Pointer);
{Laedt ein Bild aus dem Speicher auf den Schirm}
procedure initcoast;

Implementation
Uses CRT,DOS;

Procedure Window (Pos: Word);
Assembler;
Asm
  mov AH, $4F
  mov AL, 5
  XOr BX, BX
  mov DX, Pos
  mov screen.akw, DX
  Int $10
End;

Procedure nextwindow;
Assembler;
Asm
  mov AX, screen.granny
  add screen.akw, AX
  mov AH, $4F
  mov AL, 5
  XOr BX, BX
  mov DX, screen.akw
  Int $10
End;



Procedure copytovga;
Var
  temp: LongInt;
Begin
  Window (0);
  temp := 0;
  Repeat
    Move32 (Ptr48 (h, temp), Ptr48 (SegA000, 0), screen.winsize);
    Inc (temp, screen.winsize);
    nextwindow;
  Until temp >= screen.gross;
  If screen.rest > 0 Then Move32 (Ptr48 (h, temp), Ptr48 (SegA000, 0), screen.rest);
End;

Procedure vesastart; Assembler;
Asm
  mov AH, $4f
  mov AL, 7
  mov BX, 0
  mov CX, 0
  mov DX, zeile
  Int $10
End;


Procedure Fill (col: LongInt);
Begin
  filllong32 (Ptr48 (h, 0), screen.memneed, col);
End;



Procedure VesaExit; Far;
Begin
  ExitProc := Exiter;
  FreeMem32 (sprdata);
  If moderec <> Nil Then FreeMem (moderec, SizeOf (tmoderec) );
  If vesarec <> Nil Then FreeMem (vesarec, SizeOf (tvesarec) );
  If h <> 0 Then FreeMem32 (h);
  If virscr <> 0 Then FreeMem32 (virscr);
  If sprdata <> 0 Then FreeMem32 (sprdata);
  asm mov ax,3;int $10;end;
  WriteLn ('Verlasse Program ... Taste ...');
  ReadKey;
End; { VesaExit }

Procedure error (que: Byte);
Begin
  WriteLn;
  TextColor (Brown + Blink);
  WriteLn ('Fehler ', que, ' !');
  WriteLn;
  TextColor (Brown);
  Case que Of
    0: 
       Begin WriteLn (' Doch kein Fehler. Seltsam.'); Exit; End;
    1: Begin WriteLn (' Ihre Grafikkarte ist entweder nicht VESA-kompatibel oder unterstuetzt den ');
      WriteLn (' geforderten Modus nicht oder nur unzureichend!'); 
    End;
    2: 
       Begin WriteLn (' Moeglicherweise wurde eine unbekannte Grafikkarte oder Treiberversion gefunden.');
         WriteLn ('Fortfahren? [j]');
         If UpCase (ReadKey) = 'J' Then Exit; 
       End;
    3: 
       Begin WriteLn (' Eine oder mehrere Dateien wurden nicht gefunden !'); End;
    4..255: Begin WriteLn ('Ein unbekannter Fehler ist aufgetreten !!'); End;
  End;
  WriteLn;
  WriteLn ('Verlasse Program ... Taste ...');
  ReadKey; Halt;
End;

Procedure getinfo (Mode: Word);
Var temp: Word;
  smode: String;
  f: File;
Begin
  Str (Mode, smode);
  {$I-}
  Exec ('vesaset.exe', smode);
  {$I+}
  If DosError <> 0 Then Begin WriteLn ('Konfigurationsprogramm VESASET.EXE nicht gefunden!'); error (3); End;
  {$I-}
  Assign (f, 'c:\wars!.cfg');
  Reset (f, 1);
  BlockRead (f, vesarec^, 256);
  BlockRead (f, moderec^, 256);
  Close (f);
  {$I+}
  If (IOResult <> 0) Or (DosError <> 0) Then Begin
    WriteLn (' Die Datei C:\WARS!.CFG fehlt oder ist fehlerhaft!');
    error (3);
  End;
End;


Function dez2hex (a: Integer): String;
Var i: Byte;
Begin
  dez2hex [0] := #5;
  dez2hex [5] := 'h';
  For i := 4 Downto 1 Do
  Begin
    If (a And 15) < 10 Then dez2hex [i] := Char ( (a And 15) + 48)
    Else dez2hex [i] := Char ( (a And 15) + 55);
    a := a ShR 4;
  End;
End;

Procedure writeinfo;
Var temp: Word;
Begin
  TextBackground (Blue);
  ClrScr;
  TextColor (Green);
  screen.VBESignature := vesarec^. VBESig [0] + vesarec^. VBESig [1] + vesarec^. VBESig [2] + vesarec^. VBESig [3];
  If (screen.VBESignature <> 'VESA') And (screen.VBESignature <> 'VBE2') Then Begin
    WriteLn (' Die Signatur der Grafikkarte ist unbekannt. Es koennte eine nicht-VESA-kompatible oder ');
    WriteLn (' weiterentwickelte Grafikkarte vorliegen.');
    error (2);
  End Else WriteLn (' VESA Grafikkarte gefunden.');
  WriteLn ('Version :', vesarec^. majversion, '.', vesarec^. minversion);
  Case vesarec^. majversion Of
    1: If vesarec^. minversion >= 2 Then WriteLn (' Diese Version unterstuetzt alle notwendigen Funktionen. Gratulation!') Else
    Begin
      WriteLn (' Diese Version unterstuetzt leider nicht alle notwendigen Funktionen!');
      WriteLn (' Die Verwendung von UNIVBE wird empfohlen!');
      error (1);
    End;
    2..3: 
          Begin WriteLn (' Ein typischer Fall von Highend Grafikkarte oder UNIVBE.');
            WriteLn (' Diese Version ist vollkommen ausreichend. Viel Spass!'); 
          End;
    4..100: 
            Begin
              WriteLn (' Eine hochentwickelte Treiberversion wurde gefunden. Es koennte zu Kompabilitaetsproblemen kommen...');
              error (2);
            End;
  End;
  Write ('Grafikkarte ist mit ', vesarec^. totalmemory / 16: 2: 2, ' MB Speicher');
  If LongInt (vesarec^. totalmemory) * 64 * 1024 < screen.memneed Then Begin WriteLn (' unzureichend bestueckt!');
    WriteLn (' Sie haben ', LongInt (vesarec^. totalmemory) * 64 * 1024, ' Bytes, benoetigen aber ', screen.memneed,
    ' Bytes also ', screen.memneed - LongInt (vesarec^. totalmemory) * 64 * 1024, ' zuwenig!');
    error (1); 
  End Else
    WriteLn (' ausreichend bestueckt!');
  WriteLn;
  WriteLn ('Hole Informationen ueber Modus ', dez2hex (screen.akmodus), ' (', screen.MaxX, '*',
  screen.MaxY, ') ...');
  temp := moderec^. modeattributes;
  Write (' Der Grafikmodus wird ');
  If temp And 1 = 1 Then WriteLn ('vom Monitor als auch ihrer Grafikkarte unterstuetzt!') Else Begin
    WriteLn ('leider nicht vom Monitor oder Grafikkarte unterstuetzt!'); error (1); 
  End;
  WriteLn;
  If temp And 2 <> 2 Then Begin WriteLn ('Es wurden nicht alle Informationen von der Grafikkarte erhalten!'); error (2); End;
  If temp And 8 = 8 Then WriteLn ('Der Modus wird natuerlich in voller Farbenpracht dargestellt.') Else Begin
    WriteLn ('Brrr... Der Modus wird nur im Monochrom Modus unterstuetzt!');
    error (1);
  End;
  WriteLn (' Das waeren dann so ', moderec^. bitsperpixel, ' Bits pro Pixel, also '
  , LongInt (1) ShL moderec^. bitsperpixel, ' verschiedene Farben!');
  WriteLn ('Verschiebbarkeit der Fenster :', moderec^. granularity, ' KB');
  WriteLn ('Groesse der Fenster :', moderec^. WindowSize, ' KB');
  Case moderec^. memorymodel Of
    0: WriteLn ('Textmodus. Aufbau wie bei der VGA.');
    1: WriteLn ('CGA-kompatibler Speicheraufbau.');
    2: WriteLn ('Hercules-kompatibler Aufbau.');
    3: WriteLn ('VGA-kompatibler Speicheraufbau mit 4 Bitplanes.');
    4: WriteLn ('VGA-kompatibler linearer Speicheraufbau mit 256 Farben (wie Modus 13h).');
    5: WriteLn ('Aufbau wie beim Enhanced Mode 256 (Mode X).');
    6: WriteLn ('High- oder True-Color-Modus.');
    7: WriteLn ('YUV-Modus, Farben werden nicht im RGB-System eingestellt.');
    8..255: WriteLn ('Mysterioeser Speicheraufbau.');
  End;
  ReadKey;
End;
Procedure initmen;
Var xx, yy: Word;
Begin
  loadgif ('drac6');
  show_pic13;
  getsprite (290 + (1 * 27) * 320, 25, 40, sp.leer);
  For xx := 0 To 7 Do For yy := 0 To 4 Do getsprite (xx * 16 + (yy * 27) * 320, 16, 27, sp.leut [xx, yy] );
  For xx := 0 To 7 Do For yy := 0 To 2 Do getsprite (xx * 16 + (yy * 27) * 320 + 127, 16, 27, sp.leut [xx, yy + 5] );
End;
Procedure initvesa (Mode: Word);
Var z: LongInt;
Begin
  asm mov ax,3;int $10;end;
  screen.akmodus := Mode;
  If moderec <> Nil Then FreeMem (moderec, SizeOf (tmoderec) );
  If vesarec <> Nil Then FreeMem (vesarec, SizeOf (tvesarec) );
  GetMem (moderec, SizeOf (tmoderec) );
  GetMem (vesarec, SizeOf (tvesarec) );
  getinfo (Mode);

  screen._16bit := moderec^. bitsperpixel Div 8;
  screen.MaxX := moderec^. Xres;
  screen.MaxY := moderec^. Yres;
  screen.winsize := LongInt (moderec^. WindowSize) * 1024;
  screen.granularity := LongInt (moderec^. granularity) * 1024;
  screen.memneed := screen.MaxX * screen.MaxY * screen._16bit;
  screen.rest := LongInt (screen.memneed) Mod screen.winsize;
  screen.granny := moderec^. WindowSize Div moderec^. granularity;
  screen.gross := screen.memneed - screen.rest;
  If h <> 0 Then FreeMem32 (h);
  If virscr <> 0 Then FreeMem32 (virscr);
  GetMem32 (h, screen.memneed * screen._16bit);
  GetMem32 (virscr, screen.memneed * screen._16bit);
  writeinfo;
  screen.randr := screen.maxx; screen.randl := 0; screen.rando := 0; screen.randu := screen.maxy;
  For z := 0 To screen.maxy Do screen.screeny [z] := z * screen.maxx;
  Asm
    mov AX, $4F02
    mov BX, Mode
    Int $10
  End;
  loadgif ('zwischen'); {Palette}
End;

Procedure getspritegel (offs: Word; Var spr: spritetyp);
Var z, gsx, gsy: LongInt;
Begin
  spr. dtx := 64;
  spr. dty := 32;
  spr. adr := sp.sprdatazahl;
  z := 0;
  For gsy := 0 To 31 Do For gsx := 0 To gelaendlang [gsy] - 1 Do Begin
    writemem32b (Ptr48 (sprdata, z + sp.sprdatazahl), mem [SegA000: offs + gelaendtab [gsy] + gsx + gsy * 320] ); Inc (z);
  End;
  sp.sprdatazahl := sp.sprdatazahl + spr. dtx * spr. dty;
End;

Procedure getsprite (offs: Word; brei, hoc: Word; Var spr: spritetyp);
Var gsx, gsy, z: LongInt;
Begin
  spr. dtx := brei;
  spr. dty := hoc;
  spr. adr := sp.sprdatazahl;
  z := 0;
  For gsy := 0 To hoc - 1 Do For gsx := 0 To brei - 1 Do Begin
    writemem32b (Ptr48 (sprdata, z + sp.sprdatazahl), mem [SegA000: offs + gsx + gsy * 320] ); Inc (z);
  End;
  sp.sprdatazahl := sp.sprdatazahl + spr. dtx * spr. dty;
End;

Procedure putsprite (ox, oy: Word; spr: spritetyp);
Var z: LongInt;
Begin
  If (ox + spr. dtx >= screen.maxx) Or (oy + spr. dty >= screen.maxy) Then Exit;
  For z := 0 To spr. dty - 1 Do
    Move32 (Ptr48 (sprdata, z * spr. dtx + spr. adr), Ptr48 (h, ox + screen.screeny [oy + z] ), spr. dtx);
End;

Procedure putransprite (ox, oy: LongInt; spr: spritetyp);
Var temp, X1, X2, Y1, Y2, z, zz: longint;
  tt: Byte;
Begin
  If (ox >= screen.randr) Or (ox <= screen.randl - spr. dtx) Or (oy <= screen.rando - spr. dty) Or (oy >= screen.randu) Then
    Exit;
  temp := spr. adr;
  If (ox > screen.randr - spr. dtx) Or (ox < screen.randl) Or (oy < screen.rando) Or (oy > screen.randu - spr. dty) Then Begin
    X1 := 0;
    X2 := spr. dtx;
    Y1 := 0;
    Y2 := spr. dty;
    If (ox > screen.randr - spr. dtx) Then X2 := screen.randr - ox;
    If (ox < screen.randl) Then X1 := - ox;
    If (oy < screen.rando) Then Y1 := - oy;
    If (oy > screen.randu - spr. dty) Then Y2 := screen.randu - oy;
    For z := Y1 To Y2 - 1 Do Begin
      temp := z * spr. dtx + X1 + spr. adr;
      For zz := X1 To X2 - 1 Do Begin
        Inc (temp);
        tt := readmem32b (Ptr48 (sprdata, temp));
        If tt > 0 Then writemem32b (Ptr48 (h, ox + zz + screen.screeny [oy + z] ), tt);
      End;
    End;
  End Else
    For z := 0 To spr. dty - 1 Do
      For zz := 0 To spr. dtx - 1 Do Begin
        tt := readmem32b (Ptr48 (sprdata, temp) );
        Inc (temp);
        If tt > 0 Then writemem32b (Ptr48 (h, ox + zz + screen.screeny [oy + z] ), tt);
      End;
End;

Procedure putgelsprite (ox, oy: LongInt; spr: spritetyp);
Var zz, z: word;
Begin
  If (ox >= screen.randr) Or (ox <= screen.randl - 64) Or (oy <= screen.rando - 32) Or (oy >= screen.randu) Then Exit;
  z := 0;
  zz := 0;
  If (ox >= screen.randr - 64) Or (ox < screen.randl) Or (oy < screen.rando) Or (oy >= screen.randu - 32) Then Begin
    If (ox >= screen.randr - 64) Then Begin
      If (oy >= screen.randu - 32) Then Begin
        For z := 0 To screen.randu - oy Do Begin
          If gelaendtab [z] + ox + gelaendlang [z] < screen.randr Then
            Move32 (Ptr48 (sprdata, zz + spr. adr), Ptr48 (h, ox + screen.screeny [oy + z] + gelaendtab [z] ), gelaendlang [z])
          Else If gelaendtab [z] + ox < screen.randr Then
            Move32 (Ptr48 (sprdata, zz + spr. adr),
                    Ptr48 (h, ox + screen.screeny [oy + z] + gelaendtab [z] ), screen.randr - (ox + gelaendtab[z] ) );
          Inc (zz, gelaendlang [z] );
        End;
      End Else If (oy < screen.rando) Then Begin
        For z := 0 To screen.rando - oy - 1 Do zz := zz + gelaendlang [z];
        For z := screen.rando - oy - 1 To 31 Do Begin
          If gelaendtab [z] + ox + gelaendlang [z] < screen.randr Then
            Move32 (Ptr48 (sprdata, zz + spr. adr), Ptr48 (h, ox + screen.screeny [oy + z] + gelaendtab [z] ), gelaendlang [z])
          Else If gelaendtab [z] + ox < screen.randr Then
            Move32 (Ptr48 (sprdata, zz + spr. adr),
                    Ptr48 (h, ox +screen.screeny [oy + z] + gelaendtab [z] ), screen.randr - (ox + gelaendtab [z] ) );
          Inc (zz, gelaendlang [z] ); {Anfangs noch gelaendtab[rando-oy-1] addieren!}
        End;
      End Else
        For z := 0 To 31 Do Begin
          If gelaendtab [z] + ox + gelaendlang [z] < screen.randr Then
            Move32 (Ptr48 (sprdata, zz + spr. adr), Ptr48 (h, ox + screen.screeny [oy + z] + gelaendtab [z] ), gelaendlang [z])
          Else If gelaendtab [z] + ox < screen.randr Then
            Move32 (Ptr48 (sprdata, zz + spr. adr),
                    Ptr48 (h, ox + screen.screeny [oy + z] + gelaendtab [z] ), screen.randr - (ox + gelaendtab [z] ) );
          Inc (zz, gelaendlang [z] );
        End;
    End Else If (ox < screen.randl) Then Begin
      If (oy >= screen.randu - 32) Then Begin
        For z := 0 To screen.randu - oy Do Begin
          If gelaendtab [z] + ox > screen.randl Then
            Move32 (Ptr48 (sprdata, zz + spr. adr), Ptr48 (h, ox + screen.screeny [oy + z] + gelaendtab [z] ), gelaendlang [z])
          Else If gelaendtab [z] + ox + gelaendlang [z] > screen.randl Then
            Move32 (Ptr48 (sprdata, zz + spr. adr + gelaendtab [z] + ox + gelaendlang [z] - screen.randl),
            Ptr48 (h, screen.randl + screen.screeny [oy + z] ), gelaendtab [z] + ox + gelaendlang [z] - screen.randl);
          Inc (zz, gelaendlang [z] );
        End;
      End Else If (oy < screen.rando) Then Begin
        For z := 0 To screen.rando - oy - 2 Do zz := zz + gelaendtab [z];
        For z := screen.rando - oy - 1 To 31 Do Begin
          If gelaendtab [z] + ox > screen.randl Then
            Move32 (Ptr48 (sprdata, zz + spr. adr), Ptr48 (h, ox + screen.screeny [oy + z] + gelaendtab [z] ), gelaendlang [z])
          Else If gelaendtab [z] + ox + gelaendlang [z] > screen.randl Then
            Move32 (Ptr48 (sprdata, zz + spr. adr + gelaendtab [z] + ox + gelaendlang [z] - screen.randl),
                    Ptr48 (h, screen.randl + screen.screeny [oy + z] ), gelaendtab [z] + ox + gelaendlang [z] - screen.randl);
          Inc (zz, gelaendlang [z] );
        End;
      End Else
        For z := 0 To 31 Do Begin
          If gelaendtab [z] + ox > screen.randl Then
            Move32 (Ptr48 (sprdata, zz + spr. adr), Ptr48 (h, ox + screen.screeny [oy + z] + gelaendtab [z] ), gelaendlang [z])
          Else If gelaendtab [z] + ox + gelaendlang [z] > screen.randl Then
            Move32 (Ptr48 (sprdata, zz + spr. adr + gelaendtab [z] + ox + gelaendlang [z] - screen.randl),
                    Ptr48 (h, screen.randl + screen.screeny [oy + z] ), gelaendtab [z] + ox + gelaendlang [z] - screen.randl);
          Inc (zz, gelaendlang [z] );
        End;
    End Else If (oy >= screen.randu - 32) Then Begin
      For z := 0 To screen.randu - oy Do Begin
        Move32 (Ptr48 (sprdata, zz + spr. adr), Ptr48 (h, ox + screen.screeny [oy + z] + gelaendtab [z] ), gelaendlang [z] );
        Inc (zz, gelaendlang [z] );
      End;
    End Else If (oy < screen.rando) Then Begin
      For z := 0 To screen.rando - oy - 2 Do zz := zz + gelaendtab [z];
      For z := screen.rando - oy - 1 To 31 Do Begin
        Move32 (Ptr48 (sprdata, zz + spr. adr), Ptr48 (h, ox + screen.screeny [oy + z] + gelaendtab [z] ), gelaendlang [z] );
        Inc (zz, gelaendlang [z] );
      End;
    End;
  End Else
    For z := 0 To 31 Do Begin
      Move32 (Ptr48 (sprdata, zz + spr. adr), Ptr48 (h, ox + screen.screeny [oy + z] + gelaendtab [z] ), gelaendlang [z] );
      Inc (zz, gelaendlang [z] );
    End;
End;

Procedure initfont (wox, woy: Word; dx, dy: Byte);
Var temp8: Byte;
Begin
  schrift.zhb [schrift.aktab].dx := dx;
  schrift.zhb [schrift.aktab].dy := dy;
  schrift.wx := wox;
  schrift.wy := woy;
  For temp8 := 0 To anz Do Begin
    Inc (schrift.wx, schrift.zhb [schrift.aktab].dx);
    If schrift.wx + schrift.zhb [schrift.aktab].dx > 320 Then Begin
       schrift.wx := 0;
       Inc (schrift.wy, schrift.zhb [schrift.aktab].dy);
     End;
    getsprite (schrift.wx + schrift.wy * 320, schrift.zhb [schrift.aktab].dx, schrift.zhb [schrift.aktab].dy,
                sp.zeichen [schrift.aktab, temp8] );
  End;
  getsprite (0, dX, dy, sp.zeichen [0, 0] );
End;

Procedure schreib (X, Y: Word; c: Byte);
Begin
  If c > 0 Then Begin
    If schrift.blacker Then putransprite (X, Y, sp.zeichen [schrift.aktab, c - 1] )
                       Else putsprite (X, Y, sp.zeichen [schrift.aktab, c - 1] );
  End Else
  Begin
    If schrift.blacker Then putransprite (X, Y, sp.zeichen [schrift.aktab, 0] )
                       Else putsprite (X, Y, sp.zeichen [schrift.aktab, 0] );
  End;
End;

Procedure putcombsprite (ox, oy: LongInt; o, u, l, r: Byte);
Begin
  {if (ox>=randr-64) or (ox<randl) or (oy<rando) or (oy>=randu-32) then exit;}
{  If o + u + l + r = 0 Then Begin putgelsprite (ox, oy, sp.grass [12 + Random (4) ] ); Exit; End;}
  putransprite (ox + 16, oy   , sp.mincoast [0 + o ShL 2] );
  putransprite (ox + 16, oy + 16, sp.mincoast [1 + u ShL 2] );
  putransprite (ox   , oy + 8 , sp.mincoast [2 + l ShL 2] );
  putransprite (ox + 32, oy + 8 , sp.mincoast [3 + r ShL 2] );
End;

Function put2combsprite (ox, oy: Word; o, u, l, r: Byte): Byte;
Begin
  If (ox >= screen.randr - 64) Or (ox < screen.randl) Or (oy < screen.rando) Or (oy >= screen.randu - 32) Then Exit;
  If o + u + l + r = 0 Then Begin put2combsprite := 4 + Random (4); Exit; End;
  putransprite (ox + 16, oy   , sp.Min2coast [0 + o * 4] );
  putransprite (ox + 16, oy + 16, sp.Min2coast [1 + u * 4] );
  putransprite (ox   , oy + 8 , sp.Min2coast [2 + l * 4] );
  putransprite (ox + 32, oy + 8 , sp.Min2coast [3 + r * 4] );
  put2combsprite := 0;
End;
Procedure writes (was: String);
Var zzz, z: Word;
Begin
  For z := 1 To Ord (was [0] ) Do Begin
    If (Ord (was [z] ) = 0) Then Exit;
    If (Ord (was [z] ) = 13) Then Begin
      {for zzz:=1 to (1024-wx) div 32 do schreib(wx+zzz*32,wy,0);}
      Inc (schrift.wy, schrift.zhb [schrift.aktab].dy);
      Dec (schrift.wx, schrift.zhb [schrift.aktab].dx);
    End;
    If (Ord (was [z] ) = 10) Then Begin
      schrift.wx := screen.randl;
      Dec (schrift.wx, schrift.zhb [schrift.aktab].dx);
    End;
    If schrift.format = False Then Begin
      If (Ord (was [z] ) - 32 <= anz) And (Ord (was [z] ) - 32 >= 0) Then schreib (schrift.wx, schrift.wy, Ord (was [z] ) - 32)
                                                                     Else schreib (schrift.wx, schrift.wy, 0);

    End Else
      Case was [z] Of
        {   #0..#32:schreib(wx,wy,1);}
        #33..#90: schreib (schrift.wx, schrift.wy, Ord (was [z] ) - 32);
        {   #91..#96:schreib(wx,wy,1);}
        #97..#122: schreib (schrift.wx, schrift.wy, Ord (was [z] ) - 32);
        {   #123..#255:schreib(wx,wy,1);}
      End;
    If (Ord (was [z] ) > 0) Then Inc (schrift.wx, schrift.zhb [schrift.aktab].dx);
    If schrift.wx + schrift.zhb [schrift.aktab].dx > schrift.maxwx Then Begin
      schrift.wx := schrift.minwx;
      Inc (schrift.wy, schrift.zhb [schrift.aktab].dy);
      if schrift.wy + schrift.zhb [schrift.aktab].dy > schrift.maxwy Then schrift.wy := schrift.minwy;
    End;
  End;
End;

Procedure initschalt (wox, woy: Word);
Var r: Word;
Begin
  getsprite (wox + woy * 320, schaltx, schalty, sp.schalt [0] );
  getsprite (wox + (woy + schalty) * 320, schaltx, schalty, sp.schalt [1] );
  getsprite (wox + schaltx + woy * 320, schaltx, schalty, sp.schalt [2] );
  getsprite (wox + schaltx + (woy + schalty) * 320, schaltx, schalty, sp.schalt [3] );
  getsprite (wox + 2 * schaltx + woy * 320, schalt2X, schalty, sp.schalt [4] );
  getsprite (wox + 2 * schaltx + (woy + schalty) * 320, schalt2X, schalty, sp.schalt [5] );
  getsprite (wox + 2 * schaltx + schalt2X + woy * 320, schalt2X, schalty, sp.schalt [6] );
  getsprite (wox + 2 * schaltx + schalt2X + (woy + schalty) * 320, schalt2X, schalty, sp.schalt [7] );
End;


Procedure click (ox, oy: Word; on: Byte; txt: String);
Var g: Boolean;
Begin
  g := False; {screen.gross := 0;}
  {if ord(txt[0])>9 then begin g:=true;gross:=4;end;
  if g=false then begin wx:=ox+schaltx div 2-(ord(txt[0])*3);wy:=oy+schalty div 2-4;end else
  begin wx:=ox+schalt2x div 2-(ord(txt[0])*3);wy:=oy+schalty div 2-4;end;
  if (on=3) or (on=1) then begin
  inc(wx);inc(wy);
  end;}
  schrift.wx := ox; schrift.wy := oy;
  putsprite (ox, oy, sp.schalt [1] );
  If on > 1 Then schrift.aktab := 1 Else schrift.aktab := on;
  writes (txt);
End;
Procedure rechteck (X1, Y1, X2, Y2: Word; col: Byte; Fill: Boolean);
Var Y, yy, X, xx, z, zz: Word;
Begin
  
  X := X1;
  xx := X2;
  Y := Y1;
  yy := Y2;
  If Y1 > Y2 Then Begin Y := Y2; yy := Y1; End;
  If X1 > X2 Then Begin X := X2; xx := X1; End;

  If Fill Then Begin
    xx := xx - X;
    For z := Y To yy Do FillChar32 (Ptr48 (h, X + screen.screeny [z] ), xx, col);
  End Else
  Begin
    For z := X To xx Do writemem32b (Ptr48 (h, z + screen.screeny [Y1] ), col);
    For z := X To xx Do writemem32b (Ptr48 (h, z + screen.screeny [Y2] ), col);
    For z := Y To yy Do writemem32b (Ptr48 (h, X1 + screen.screeny [z] ), col);
    For z := Y To yy Do writemem32b (Ptr48 (h, X2 + screen.screeny [z] ), col);
  End;
End;
Procedure initrand;
Begin
  loadgif ('rahm10');
  show_pic13;
  getsprite (32, 100, 16, sp.rahmo);
  getsprite (32 + 16 * 320, 100, 16, sp.rahmu);
  getsprite (0 + 32 * 320, 16, 100, sp.rahml);
  getsprite (16 + 32 * 320, 16, 100, sp.rahmr);
  getsprite (0, 16, 16, sp.k1);
  getsprite (16, 16, 16, sp.k2);
  getsprite (16 * 320, 16, 16, sp.k3);
  getsprite (16 + 16 * 320, 16, 16, sp.k4);
End;
Procedure initstuff;
Var X5, Y5: Word;
Begin

  initmen;
  loadgif ('grid4');
  show_pic13;
  getsprite (0, 64, 32, sp.grid);
  getsprite (32*320, 64, 32, sp.grid2);
  getsprite (64, 64, 32, sp.dorf);
  loadgif ('font171');
  show_pic13;
  getsprite (85 * 320, 20, 20, sp.hand [0, 0] );
  getsprite (20 + 85 * 320, 20, 20, sp.hand [0, 1] );
  getsprite (40 + 85 * 320, 20, 20, sp.hand [0, 2] );
  getsprite (60 + 85 * 320, 20, 20, sp.hand [0, 3] );
  getsprite (80 + 85 * 320, 20, 20, sp.hand [0, 4] );

  getsprite (100 + 85 * 320, 20, 20, sp.hand [1, 0] );
  getsprite (120 + 85 * 320, 20, 20, sp.hand [1, 1] );
  getsprite (140 + 85 * 320, 20, 20, sp.hand [1, 2] );
  getsprite (160 + 85 * 320, 20, 20, sp.hand [1, 3] );
  getsprite (180 + 85 * 320, 20, 20, sp.hand [1, 4] );

  getsprite (200 + 85 * 320, 20, 20, sp.hand [2, 0] );
  getsprite (220 + 85 * 320, 20, 20, sp.hand [2, 1] );
  getsprite (240 + 85 * 320, 20, 20, sp.hand [2, 2] );
  getsprite (260 + 85 * 320, 20, 20, sp.hand [2, 3] );
  getsprite (280 + 85 * 320, 20, 20, sp.hand [2, 4] );
  schrift.aktab := 1;
  initfont (0, 0, 6, 8);
  initrand;
End;
Procedure initgelaend;
var xx,yy:word;
Begin
{  loadgif('test2');
  show_pic13;
  getspritegel(0+0*320,sp.hoehe[0]);
  getspritegel(0+32*320,sp.hoehe[1]);
  getspritegel(0+64*320,sp.hoehe[2]);
  getspritegel(0+96*320,sp.hoehe[3]);
  getspritegel(64+0*320,sp.hoehe[4]);
  getspritegel(64+32*320,sp.hoehe[5]);
  getspritegel(64+64*320,sp.hoehe[6]);
  getspritegel(64+96*320,sp.hoehe[7]);
  getspritegel(128+0*320,sp.hoehe[8]);
  getsprite(128+96*320,64,32,sp.hoehe[9]);
  getspritegel(128+64*320,sp.hoehe[10]);
  getspritegel(192+0*320,sp.hoehe[11]);
  getspritegel(192+32*320,sp.hoehe[12]);
  getspritegel(0+128*320,sp.hoehe[13]);
  getspritegel(64+128*320,sp.hoehe[14]);}
  loadgif('3d3');
  show_pic13;
  for xx:=0 to 3 do for yy:=0 to 3 do getsprite(xx*64+xx+1+(yy*48+yy+1)*320,64,48,sp.hoehe[xx*4+yy]);
  loadgif('3d2');
  show_pic13;
  for yy:=0 to 2 do getsprite(1+(yy*48+yy+1)*320,64,48,sp.hoehe[16+yy]);
  loadgif('3d6');
  show_pic13;
  for xx:=0 to 3 do for yy:=0 to 3 do getsprite(xx*64+xx+1+(yy*48+yy+1)*320,64,48,sp.hoehe[xx*4+yy+20]);
  loadgif('3d5');
  show_pic13;
  for yy:=0 to 2 do getsprite(1+(yy*48+yy+1)*320,64,48,sp.hoehe[36+yy]);
  { loadgif('coast3');
  show_pic13;
  getsprite(1*64+(0*32*320),64,32,wasser[15]);
  getsprite(1*64+(1*32*320),64,32,wasser[18]);
  getsprite(1*64+(2*32*320),64,32,wasser[17]);
  getsprite(1*64+(3*32*320),64,32,wasser[16]);
  getsprite(2*64+(0*32*320),64,32,wasser[11]);
  getsprite(2*64+(1*32*320),64,32,wasser[10]);
  getsprite(2*64+(2*32*320),64,32,wasser[9]);
  getsprite(2*64+(3*32*320),64,32,wasser[12]);
  getsprite(3*64+(0*32*320),64,32,wasser[14]);
  getsprite(3*64+(1*32*320),64,32,wasser[13]);
  getsprite(3*64+(2*32*320),64,32,wasser[19]);
  getsprite(3*64+(3*32*320),64,32,wasser[20]);
  getsprite(4*64+(0*32*320),64,32,wasser[7]);
  getsprite(4*64+(1*32*320),64,32,wasser[6]);
  getsprite(4*64+(2*32*320),64,32,wasser[5]);
  getsprite(4*64+(3*32*320),64,32,wasser[8]);}
  loadgif ('berg2.gif');
  show_pic13;
  getsprite (1 +   1 * 320, 64, 32, sp.berg [0] );
  getsprite (66 +  1 * 320, 64, 32, sp.berg [1] );
  getsprite (131 + 1 * 320, 64, 32, sp.berg [2] );
  getsprite (196 + 1 * 320, 64, 32, sp.berg [3] );
  getsprite (1 +  67 * 320, 64, 32, sp.berg [4] );
  getsprite (66 + 67 * 320, 64, 32, sp.berg [5] );
  getsprite (131 + 67 * 320, 64, 32, sp.berg [6] );
  getsprite (196 + 67 * 320, 64, 32, sp.berg [7] );
  getsprite (1 +  34 * 320, 64, 32, sp.berg [8] );
  getsprite (66 + 34 * 320, 64, 32, sp.berg [9] );
  getsprite (131 + 34 * 320, 64, 32, sp.berg [10] );
  getsprite (196 + 34 * 320, 64, 32, sp.berg [11] );
  getsprite (1 +  100 * 320, 64, 32, sp.berg [12] );
  getsprite (66 + 100 * 320, 64, 32, sp.berg [13] );
  getsprite (131 + 100 * 320, 64, 32, sp.berg [14] );
  getsprite (196 + 100 * 320, 64, 32, sp.berg [15] );
  
  loadgif ('ocean9');
  show_pic13;
  getspritegel (0 + 0 * 320, sp.grass [0] );
  getspritegel (0 + 32 * 320, sp.grass [1] );
  getspritegel (0 + 64 * 320, sp.grass [2] );         {Strand}
  getspritegel (0 + 96 * 320, sp.grass [3] );
  
  getspritegel (64 + 0 * 320, sp.grass [4] );
  getspritegel (64 + 32 * 320, sp.grass [5] );         {Grass}
  getspritegel (64 + 64 * 320, sp.grass [6] );
  getspritegel (64 + 96 * 320, sp.grass [7] );
  
  getspritegel (128 + 0 * 320, sp.grass [8] );
  getspritegel (128 + 32 * 320, sp.grass [9] );        {Schnee}
  getspritegel (128 + 64 * 320, sp.grass [10] );
  getspritegel (128 + 96 * 320, sp.grass [11] );
  
  getspritegel (192 + 0 * 320, sp.grass [12] );
  getspritegel (192 + 32 * 320, sp.grass [13] );        {Wasser}
  getspritegel (192 + 64 * 320, sp.grass [14] );
  getspritegel (192 + 96 * 320, sp.grass [15] );
  
  getspritegel (256 + 0 * 320, sp.grass [16] );
  getspritegel (256 + 32 * 320, sp.grass [17] );        {ICe}
  getspritegel (256 + 64 * 320, sp.grass [18] );
  getspritegel (256 + 96 * 320, sp.grass [19] );
  
  loadgif ('zwischen');
  show_pic13;
  getspritegel (0 * 320, sp.grass [20] );
  getspritegel (32 * 320, sp.grass [21] );        {strand}
  getspritegel (64 * 320, sp.grass [22] );
  getspritegel (96 * 320, sp.grass [23] );
  
  getspritegel (64 + 0 * 320, sp.grass [24] );
  getspritegel (64 + 32 * 320, sp.grass [25] );        {Felsen}
  getspritegel (64 + 64 * 320, sp.grass [26] );
  getspritegel (64 + 96 * 320, sp.grass [27] );
End;
Procedure initcoast;
Begin
  initgelaend;
  loadgif ('coast15');
  show_pic13;
  getsprite (1 + 1 * 320, 32, 16, sp.mincoast [0] );
  getsprite (1 + 18 * 320, 32, 16, sp.mincoast [1] );
  getsprite (1 + 35 * 320, 32, 16, sp.mincoast [2] );
  getsprite (34 + 35 * 320, 32, 16, sp.mincoast [3] );
  
  getsprite (67 + 1 * 320, 32, 16, sp.mincoast [4] );
  getsprite (67 + 18 * 320, 32, 16, sp.mincoast [5] );
  getsprite (67 + 35 * 320, 32, 16, sp.mincoast [6] );
  getsprite (100 + 35 * 320, 32, 16, sp.mincoast [7] );
  
  getsprite (133 + 1 * 320, 32, 16, sp.mincoast [8] );
  getsprite (133 + 18 * 320, 32, 16, sp.mincoast [9] );
  getsprite (133 + 35 * 320, 32, 16, sp.mincoast [10] );
  getsprite (166 + 35 * 320, 32, 16, sp.mincoast [11] );
  
  getsprite (199 + 1 * 320, 32, 16, sp.mincoast [12] );
  getsprite (199 + 18 * 320, 32, 16, sp.mincoast [13] );
  getsprite (199 + 35 * 320, 32, 16, sp.mincoast [14] );
  getsprite (232 + 35 * 320, 32, 16, sp.mincoast [15] );
  
  getsprite (265 + 1 * 320, 32, 16, sp.mincoast [16] );
  getsprite (265 + 18 * 320, 32, 16, sp.mincoast [17] );
  getsprite (265 + 35 * 320, 32, 16, sp.mincoast [18] );
  getsprite (1 + 86 * 320, 32, 16, sp.mincoast [19] );
  
  getsprite (34 + 52 * 320, 32, 16, sp.mincoast [20] );
  getsprite (34 + 69 * 320, 32, 16, sp.mincoast [21] );
  getsprite (34 + 86 * 320, 32, 16, sp.mincoast [22] );
  getsprite (67 + 86 * 320, 32, 16, sp.mincoast [23] );
  
  getsprite (100 + 52 * 320, 32, 16, sp.mincoast [24] );
  getsprite (100 + 69 * 320, 32, 16, sp.mincoast [25] );
  getsprite (100 + 86 * 320, 32, 16, sp.mincoast [26] );
  getsprite (133 + 86 * 320, 32, 16, sp.mincoast [27] );
  
  getsprite (166 + 52 * 320, 32, 16, sp.mincoast [28] );
  getsprite (166 + 69 * 320, 32, 16, sp.mincoast [29] );
  getsprite (166 + 86 * 320, 32, 16, sp.mincoast [30] );
  getsprite (199 + 86 * 320, 32, 16, sp.mincoast [31] );
  
  {loadgif('coastw3');
  show_pic13;
  getsprite(1+1*320,32,16,min2coast[0]);
  getsprite(1+18*320,32,16,min2coast[1]);
  getsprite(1+35*320,32,16,min2coast[2]);
  getsprite(34+35*320,32,16,min2coast[3]);
  
  getsprite(67+1*320,32,16,min2coast[4]);
  getsprite(67+18*320,32,16,min2coast[5]);
  getsprite(67+35*320,32,16,min2coast[6]);
  getsprite(100+35*320,32,16,min2coast[7]);
  
  getsprite(133+1*320,32,16,min2coast[8]);
  getsprite(133+18*320,32,16,min2coast[9]);
  getsprite(133+35*320,32,16,min2coast[10]);
  getsprite(166+35*320,32,16,min2coast[11]);

  getsprite(199+1*320,32,16,min2coast[12]);
  getsprite(199+18*320,32,16,min2coast[13]);
  getsprite(199+35*320,32,16,min2coast[14]);
  getsprite(232+35*320,32,16,min2coast[15]);
  
  getsprite(265+1*320,32,16,min2coast[16]);
  getsprite(265+18*320,32,16,min2coast[17]);
  getsprite(265+35*320,32,16,min2coast[18]);
  getsprite(1+86*320,32,16,min2coast[19]);
  
  getsprite(34+52*320,32,16,min2coast[20]);
  getsprite(34+69*320,32,16,min2coast[21]);
  getsprite(34+86*320,32,16,min2coast[22]);
  getsprite(67+86*320,32,16,min2coast[23]);
  
  getsprite(100+52*320,32,16,min2coast[24]);
  getsprite(100+69*320,32,16,min2coast[25]);
  getsprite(100+86*320,32,16,min2coast[26]);
  getsprite(133+86*320,32,16,min2coast[27]);

  getsprite(166+52*320,32,16,min2coast[28]);
  getsprite(166+69*320,32,16,min2coast[29]);
  getsprite(166+86*320,32,16,min2coast[30]);
  getsprite(199+86*320,32,16,min2coast[31]);}
End;
Procedure vwindow (X1, Y1, X2, Y2: Word);
Var z: Word;
Begin
  If (X2 - X1 < 132) Or (Y2 - Y1 < 132) Or (Y1 > Y2) Or (X1 > X2) Then Exit;
  putsprite (X1, Y1, sp.k1);
  putsprite (X2 - 17, Y1, sp.k2);
  putsprite (X1, Y2 - 17, sp.k3);
  putsprite (X2 - 17, Y2 - 17, sp.k4);
  For z := 0 To (X2 - X1 - 32) Div 100 - 1 Do putsprite (X1 + 16 + z * 100, Y1, sp.rahmo);
  putsprite (X2 - 117, Y1, sp.rahmo);
  For z := 0 To (Y2 - Y1 - 32) Div 100 - 1 Do putsprite (X1, Y1 + 16 + z * 100, sp.rahml);
  putsprite (X1, Y2 - 117, sp.rahml);
  For z := 0 To (X2 - X1 - 32) Div 100 - 1 Do putsprite (X1 + 16 + z * 100, Y2 - 17, sp.rahmu);
  putsprite (X2 - 117, Y2 - 17, sp.rahmu);
  For z := 0 To (Y2 - Y1 - 32) Div 100 - 1 Do putsprite (X2 - 17, Y1 + 16 + z * 100, sp.rahmr);
  putsprite (X2 - 17, Y2 - 117, sp.rahmr);
End;

Procedure message;
Var owx, owy, long, tt: Word;
Begin
  {Suche nach #10#13}
  long := Ord (was [0] );
  For tt := 1 To Ord (was [0] ) Do
    If (was [tt] = #10) And (was [tt + 1] = #13) Then Begin
      long := tt;
      tt := Ord (was [0] );
    End;
  long := long * schrift.zhb [schrift.aktab].dx + 16;
  If long < 100 Then long := 100;
  {if (X1+32+long>maxx) or (y1+114>maxy) then exit;}
  vwindow (X1, Y1, X1 + 32 + long, Y1 + 132);
  rechteck (X1 + 16, Y1 + 16, X1 + 15 + long, Y1 + 114, 0, True);
  owx := schrift.wx; owy := schrift.wy;
  schrift.wx := X1 + 24; schrift.wy := Y1 + 24;
  schrift.minwx:=schrift.wx;
  schrift.minwy:=schrift.wy;
  schrift.maxwx:=X1+15+long;
  schrift.maxwy:=Y1+114;
  tt := screen.randl;
  screen.randl := schrift.wx;
  writes (was);
  screen.randl := tt;
  schrift.wx := owx; schrift.wy := owy;
End;
Procedure show_picture (X, Y: LongInt; Name: String);
Var start: LongInt;
  zyy, zxx: LongInt;
Begin
  loadgif (Name);
  start := X + screen.screeny [Y];
  For zyy := 0 To 199 Do For zxx := 0 To 319 Do
    writemem32b (Ptr48 (h, start + zxx + screen.screeny [zyy] ), mem [Seg (vscreen^): Ofs (vscreen^) + zyy * 320 + zxx] );
End;

Procedure load_picture (X, Y: LongInt; Name: Pointer);
Var start: LongInt;
  zyy, zxx: LongInt;
  temp: Byte;
Begin
  start := X + screen.screeny [Y];
  For zyy := 0 To 199 Do
    Move32 (Ptr48 (Seg (Name^), Ofs (Name^) + zyy * 320), Ptr48 (h, screen.screeny [zyy] ), 64000);
End;

Begin
  Exiter := ExitProc;
  ExitProc := @VesaExit;
  sp.sprdatazahl := 0;
End.


