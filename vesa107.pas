{Vesa-Unit Version 1.10. Lauffaehig zur Zeit in den folgenden Modi:
   101h
   103h
   105h
   16 Bit Farbunterstuetzung wird noch gemacht!
}



Unit VESA107;
Interface
Uses newfrontier, gif, modexlib;


const
  anz = 100;
gtab:array[0..18,0..47] of word=

((0,0,0,0,0,0,0,0,29,25,20,16,12,7,3,0,0,1,3,4,5,7,8,9,11,12,13,15,16,17,19,20,21,23,24,25,27,28,29,31,0,0,0,0,0,0,0,0),
(31,29,28,27,25,24,23,21,20,19,17,16,15,13,12,11,9,8,7,5,4,3,1,0,0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,0,0,0,0,0,0,0,0),
(0,0,0,0,0,0,0,0,30,28,26,24,22,20,18,16,14,12,10,8,6,4,2,0,0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,0,0,0,0,0,0,0,0),
(0,0,0,0,0,0,0,0,30,28,26,24,22,20,18,16,14,12,10,8,6,4,2,0,0,3,7,12,16,20,25,29,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
(0,0,0,0,0,0,0,0,29,25,20,16,12,7,3,0,0,1,3,4,5,7,8,9,11,12,13,15,16,17,19,20,21,23,24,25,27,28,29,31,0,0,0,0,0,0,0,0),
(31,29,28,27,25,24,23,21,20,19,17,16,15,13,12,11,9,8,7,5,4,3,1,0,0,3,7,12,16,20,25,29,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
(30,28,26,24,22,20,18,16,14,12,10,8,6,4,2,0,0,1,3,4,5,7,8,9,11,12,13,15,16,17,19,20,21,23,24,25,27,28,29,31,0,0,0,0,0,0,0,0),
(31,29,28,27,25,24,23,21,20,19,17,16,15,13,12,11,9,8,7,5,4,3,1,0,0,3,7,12,16,20,25,29,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
(0,0,0,0,0,0,0,0,29,25,20,16,12,7,3,0,0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
(30,28,26,24,22,20,18,16,14,12,10,8,6,4,2,0,0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
(30,28,26,24,22,20,18,16,14,12,10,8,6,4,2,0,0,1,3,4,5,7,8,9,11,12,13,15,16,17,19,20,21,23,24,25,27,28,29,31,0,0,0,0,0,0,0,0),
(0,0,0,0,0,0,0,0,30,28,26,24,22,20,18,16,14,12,10,8,6,4,2,0,0,3,7,12,16,20,25,29,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
(0,0,0,0,0,0,0,0,29,25,20,16,12,7,3,0,0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
(31,29,28,27,25,24,23,21,20,19,17,16,15,13,12,11,9,8,7,5,4,3,1,0,0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,0,0,0,0,0,0,0,0),
(31,29,28,27,25,24,23,21,20,19,17,16,15,13,12,11,9,8,7,5,4,3,1,0,0,3,7,12,16,20,25,29,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
(31,29,28,27,25,24,23,21,20,19,17,16,15,13,12,11,9,8,7,5,4,3,1,0,0,1,3,4,5,7,8,9,11,12,13,15,
         16,17,19,20,21,23,24,25,27,28,29,31),
(29,25,20,16,12,7,3,0,0,1,3,4,5,7,8,9,11,12,13,15,16,17,19,20,21,23,24,25,27,28,29,31,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
(0,0,0,0,0,0,0,0,29,25,20,16,12,7,3,0,0,3,7,12,16,20,25,29,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
(0,0,0,0,0,0,0,0,30,28,26,24,22,20,18,16,14,12,10,8,6,4,2,0,0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,0,0,0,0,0,0,0,0));

       glong:array[0..18,0..47] of word=
((0,0,0,0,0,0,0,0,5,11,18,24,30,37,43,48,50,51,51,52,53,53,54,55,53,50,47,43,40,37,33,30,27,23,20,17,13,
    10,7,3,0,0,0,0,0,0,0,0),
(2,6,8,10,14,16,18,22,24,26,30,32,34,38,40,42,46,48,50,54,56,58,63,64,64,60,56,52,48,44,40,36,32,28,24,20,16,12,
     8,4,0,0,0,0,0,0,0,0),
(0,0,0,0,0,0,0,0,5,11,18,24,30,37,43,48,50,52,51,52,53,53,54,55,53,50,47,43,40,37,33,30,27,23,20,17,13,10,7,3,0,
     0,0,0,0,0,0,0),
(0,0,0,0,0,0,0,0,4,8,12,16,20,24,28,32,36,40,44,48,52,56,60,64,64,58,50,40,32,24,14,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
(0,0,0,0,0,0,0,0,6,14,24,32,40,50,58,64,64,63,58,56,54,50,48,46,42,40,38,34,32,30,26,24,22,18,16,14,10,8,6,2,0,0,0,0,0,0,0,0),
(2,6,8,10,14,16,18,22,24,26,30,32,34,38,40,42,46,48,50,54,56,58,63,64,64,58,50,40,32,24,14,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
(3,7,10,13,17,20,23,27,30,33,37,40,43,47,50,53,55,55,54,55,55,54,56,55,53,50,47,43,40,37,33,30,27,23,20,17,13,10,7,3,0,0,
     0,0,0,0,0,0),
(3,7,10,13,17,20,23,27,30,33,37,40,43,47,50,53,55,54,53,53,52,51,51,50,48,43,37,30,24,18,11,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
(0,0,0,0,0,0,0,0,6,14,24,32,40,50,58,64,64,60,56,52,48,44,40,36,32,28,24,20,16,12,8,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
(3,7,10,13,17,20,23,27,30,33,37,40,43,47,50,53,55,54,53,53,52,51,52,50,48,43,37,30,24,18,11,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
(4,8,12,16,20,24,28,32,36,40,44,48,52,56,60,64,64,63,58,56,54,50,48,46,42,40,38,34,32,30,26,24,22,18,16,14,10,8,6,2,0,0,0,
     0,0,0,0,0),
(0,0,0,0,0,0,0,0,5,11,18,24,30,37,43,48,50,50,50,50,50,50,50,50,48,43,37,30,24,18,11,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
(0,0,0,0,0,0,0,0,5,11,18,24,30,37,43,48,50,50,50,50,50,50,50,50,48,43,37,30,24,18,11,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
(3,7,10,13,17,20,23,27,30,33,37,40,43,47,50,53,55,56,54,55,55,54,55,55,53,50,47,43,40,37,33,30,27,23,20,17,13,10,7,3,0,0,0,
     0,0,0,0,0),
(4,10,16,21,27,33,38,43,44,45,44,44,44,44,44,44,44,44,44,44,44,44,44,44,43,38,33,27,21,16,10,4,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0),
(2,6,8,10,14,16,18,22,24,26,30,32,34,38,40,42,46,48,50,54,56,58,63,64,64,63,58,56,54,50,48,46,42,40,38,34,32,30,26,24,
     22,18,16,14,10,8,6,2),
(4,10,16,21,27,33,38,43,44,44,44,44,44,44,44,44,44,44,44,44,44,44,45,44,43,38,33,27,21,16,10,4,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0),
(0,0,0,0,0,0,0,0,6,14,24,32,40,50,58,64,64,58,50,40,32,24,14,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
(0,0,0,0,0,0,0,0,4,8,12,16,20,24,28,32,36,40,44,48,52,56,60,64,64,60,56,52,48,44,40,36,32,28,24,20,16,12,8,4,0,0,0,0,0,0,0,0));
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
               paddington: Array [49..512] Of Byte; {Change the upper bound to 512}
               {if you are using VBE2.0}
             End;
  var

  schrift:array[0..3] of record {maximal 4 verschiedene Schriftarten *aktab*}
   blacker: Boolean;            {Hintergrund der Buchstaben schwarz/transparent}
   zhb:Record
          dx, dy: Byte;
       End;
   wx, wy, minwx, minwy, maxwx,maxwy: Word;  {Aktuelle Schriftposition, obere linke Ecke}
   format: Boolean;             {Format der Buchstabendatei}
   zeichen: Array [0..101] Of spritetyp; {Die Buchstaben...}
  end;
   aktab: byte;                 {Aktueller Schriftsatz}

  screen:record
   lfb:boolean;
   h:word;
   MaxY,  MaxX: LongInt;
   screeny: Array [ - 1..2000] Of LongInt;
   videoptr,akmodus: Word;
   kartemem,
   MemNeed,
   randl, randr, rando, randu: LongInt;
   _16bit: LongInt;
   rest, gross, granularity, winsize: LongInt;
   Totalmemory: LongInt;
   VBESignature: String [4];
   granny, akw: Word;
   light:longint;
   LFBAdress:longint;
   page:word; {Y Coordinate of the Screen}
  end;


  sp:record
   sprdatazahl:longint;
   pflanze:spritetyp;
   hoehe:array [0..40] of spritetyp;
   hand: Array [0..2, 0..4] Of spritetyp;
   wasser:array[0..3] of spritetyp;
   schalt: Array [0..7] Of spritetyp;
   leut: Array [0..7, 0..7] Of spritetyp;
   berg: Array [0..15] Of spritetyp;
   mincoast: Array [0..31] Of spritetyp;
   Min2coast: Array [0..31] Of spritetyp;
   grid1,grid2: Array [0..18] of spritetyp;
   leer, dorf: spritetyp;
   rahmo, rahmu, rahml, rahmr, k1, k2, k3, k4: spritetyp;
  end;

  sprdata: tselector;
  e:word;
  Exiter: Pointer;
  VESARec:^TVESARec;
  ModeRec:^TModeRec;

procedure start_vesa(x,y:word);
{Sets the start of the memory}
Function dez2hex (a: Integer): String;
{Konvertiert Dez Zahlen zu Hex Zahlen}
Procedure copytovga;
{Kopiert den gesamten Inhalt vom virtuellen Bildschirm "h" zur Grafikkarte}
Procedure vesastart (zeile: Word);
{Setzt neuen Vesastart. Wichtig z.B. fuer Scrolling}
Procedure Fill (col: LongInt);
{Fuellt "h" mit lauter col}
Procedure initvesa (Mode: Word);
{Holt Informationen ueber den Modus, setzt ihn und initialisiert "h"}
Procedure getspritegel (offs,form: Word; Var spr: spritetyp);
{Holt vom $13 Bildschirm eine Raute in den Speicher "sprdata"}
Procedure getsprite (offs: Word; brei, hoc: Word; Var spr: spritetyp);
{Holt vom $13 Bildschirm ein Quadrat in den Speicher "sprdata"}
Procedure putsprite (ox, oy: longint; spr: spritetyp);
{Setzt ohne Ruecksicht auf Verluste (nicht transparent) ein quadratisches Sprite}
Procedure putransprite (ox, oy: LongInt; spr: spritetyp);
{Setzt ein durchsichtiges Quadrat auf den Bildschirm. Muss noch optimiert werden!}
Procedure putgelsprite (ox, oy: LongInt; form:word; spr: spritetyp);
{Setzt eine Raut auf den Bildschirm}
Procedure rechteck (X1, Y1, X2, Y2: Word; col: Byte; Fill: Boolean);
{Ein gefuelltes (0=transparent) Rechteck}
Procedure initstuff;
{Laedt Mauszeiger, Schrift und markierte Felder}
Procedure writes (was: String);
{Schreibt was zu screen.wx,wy}
procedure line(x1,y1,x2,y2:integer;col:byte);
{Linie}
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

procedure start_vesa(x,y:word); assembler;{Sets the start of the memory}
asm
  mov ah, 4fh
  mov al, 7
  mov bx, 0
  mov cx, x
  mov dx, y
  int 10h
end;


Procedure copytovga;
Var
  temp: LongInt;
Begin
  if screen.lfb then begin
   start_vesa(0,screen.page);
   if screen.page=0 then screen.page:=1000 else screen.page:=0;       {Flip me!}
 end else begin {Beurk. Copying ...}
  Window (0);
  temp := 0;
  Repeat
    Move32 (Ptr48 (screen.h, temp), ptr48(sega000,0), screen.winsize);
    Inc (temp, screen.winsize);
    nextwindow;
  Until temp >= screen.gross;
 If screen.rest > 0 Then Move32 (Ptr48 (screen.h, temp), ptr48(sega000,0), screen.rest);
 end;
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
  filllong32 (Ptr48 (screen.h, 0), screen.memneed, col);
End;

procedure CleanUpLinearVideoStuff;
begin
  FreeDescriptor(screen.videoptr);
  FreePhysicalAddressMapping(screen.LFBAdress);
end;

Procedure VesaExit; Far;
Begin
  if lastmode<>3 then textmode(3);
  CleanUpLinearVideoStuff;
  ExitProc := Exiter;
  write('-Freeing graphic stuff...');
  FreeMem32 (sprdata);
  If moderec <> Nil Then FreeMem (moderec, SizeOf (tmoderec) );
  If vesarec <> Nil Then FreeMem (vesarec, SizeOf (tvesarec) );
  If screen.h <> 0 Then FreeMem32 (screen.h);
  If sprdata <> 0 Then FreeMem32 (sprdata);
  writeln(' OK!');
  WriteLn ('-Exiting ... Key ...');
  ReadKey;
End; { VesaExit }

Procedure error (que: Byte);
Begin
  WriteLn;
  sound(100);delay(100);nosound;
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

procedure xchg(var x,y:integer);
begin
   x:=x xor y;
   y:=y xor x;
   x:=x xor y;
end;

{ line() - Linie mittels Bresenham zeichnen }
procedure line(x1,y1,x2,y2:integer;col:byte);
var a,dx,dy,addval:integer;
begin
   addval:=1;
   if abs(x2-x1)>abs(y2-y1) then  { X-Diff. gr”áer Y-Diff.? }
   begin
      if x2<x1 then               { Ja, Eckpunkte in richtige Reihen- }
      begin                       { folge bringen }
        xchg(x1,x2);
        xchg(y1,y2);
      end;
      if y2<y1 then               { Laufrichtung (oben oder unten) ermitteln }
      begin
         y2:=2*y1-y2;
         addval:=-1;
      end;
      dy:=2*(y2-y1);              { Y-Differenz errechnen }
      a:=x2-x1;                   { Z„hler=X-Differenz }
      dx:=a+a;                    { Z„hlwert= 2*X-Diff. }
      repeat
         writemem32b(ptr48(screen.h,x1+screen.screeny[y1]),col);       { Punkt setzen }
         inc(x1);
         dec(a,dy);               { Z„hler verkleinern }
         if a<=0 then             { Bereichsberschreitung ? }
         begin
            inc(a,dx);            { Ja, Y-Position ver„ndern }
            inc(y1,addval);
         end;
      until x1>x2;                { Linie bis zum Ende zeichnen }
   end
   else                           { 2. Fall: Winkel gr”áer als 45 Grad }
   begin                          { alles weitere: wie oben! }
      if y1>y2 then
      begin
         xchg(x1,x2);
         xchg(y1,y2);
      end;
      if x2<x1 then
      begin
         x2:=2*x1-x2;
         addval:=-1;
      end;
      dy:=2*(x2-x1);
      a:=y2-y1;
      dx:=a+a;
      repeat
         writemem32b(ptr48(screen.h,x1+screen.screeny[y1]),col);       { Punkt setzen }
         inc(y1);
         dec(a,dy);
         if a<=0 then
         begin
            inc(a,dx);
            inc(x1,addval);
         end;
      until y1>y2;
   end;
end;

Procedure writeinfo;
Var temp: longint;
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
    1: If vesarec^. minversion >= 2 Then begin
     WriteLn(' Diese Version unterstuetzt zwar alle NOTWENDIGEN Funktionen, der schnellere LinearFrameBuffer ');
     writeln(' wird aber nicht unterstützt. Sie können fortfahren oder sich UNIVBE (www.scitech.com) holen, ');
     writeln(' um auf Version 2.0 upzudaten... eine neue Grafikkarte wäre auch gut.');end Else
    Begin
      WriteLn (' Diese Version unterstuetzt leider nicht alle notwendigen Funktionen!');
      WriteLn (' Die Verwendung von UNIVBE (www.scitech.com) wird empfohlen,');
      writeln (' besser wäre aber eine neue Grafikkarte!');
      error (1);
    End;
    2..3:
          Begin WriteLn (' Jau! Die Grafikkarte müsste es eigentlich packen...');
            WriteLn (' Diese Version ist untestützt alle Funktionen. Viel Spass!');
          End;
    4..100:
            Begin
              WriteLn (' Unbekannte Treiberversion. Es könnte eine hochentwickelte Grafikkarte vorliegen');
              writeln (' oder es trat ein Fehler auf. Es koennte Kompabilitaetsproblemen geben...');
              error (2);
            End;
  End;
  Write ('Grafikkarte ist mit ', vesarec^. totalmemory / 16: 2: 2, ' MB Speicher');
  if screen.lfb then temp:=2 else temp:=1;
  If (LongInt (vesarec^. totalmemory) * 64 * 1024 *temp< screen.memneed) Then Begin
    WriteLn (' unzureichend bestueckt!');
    WriteLn (' Sie haben ', LongInt (vesarec^. totalmemory) * 64 * 1024, ' Bytes, benoetigen aber ', screen.memneed,
    ' Bytes also ', screen.memneed - LongInt (vesarec^. totalmemory) * 64 * 1024, ' zuwenig!');
    writeln('Waehlen Sie einen niedriegen Videomodus!');
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
  writeln('Videoptr :',screen.videoptr);
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

procedure SetLinearVideoToPhysicalAddress(physAddr, size: longint);
{Set up a selector to point to the given physical address.}
{'size' is the size in bytes of the logical window.}
var
  rights: word;
begin
  screen.LFBAdress:= PhysicalAddressMapping(physAddr, size);
  screen.videoptr:= CreateDescriptor(screen.LFBAdress, size);
  rights:= GetSegmentAccessRights(screen.videoptr);
  rights:= (rights and $FF70) or $0093;
  SetSegmentAccessRights(screen.videoptr, rights);
end;

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
  screen.memneed := screen.MaxX * screen.MaxY * screen._16bit;
  if vesarec^. majversion>=2{boolean(moderec^.modeAttributes and $1) and boolean(moderec^.modeAttributes and $80)}
   then begin
  {linear ok!}
    For z := 0 To 2000 Do screen.screeny [z] := z * screen.maxx * screen._16bit;
    screen.lfb:=true;
    SetLinearVideoToPhysicalAddress(moderec^.physBasePtr, $200000);
    screen.winsize:=screen.memneed; {Not needed ... but who knows ...}
    screen.granularity := screen.winsize;
    screen.gross:=screen.winsize;
    screen.granny:=1;
    screen.h:=screen.videoptr; {No virtual memory needed 'cause flipping the video pages is faster with lfb}
    screen.page:=0;
 end else begin
     For z := 0 To screen.maxy Do screen.screeny [z] := z * screen.maxx * screen._16bit;
     screen.page:=0;
     screen.lfb:=false;
     screen.videoptr:=segA000;
     screen.winsize := LongInt (moderec^. WindowSize) * 1024;
     screen.rest := LongInt (screen.memneed) Mod screen.winsize;
     screen.granny := moderec^. WindowSize Div moderec^. granularity;
     screen.gross := screen.memneed - screen.rest;
     If screen.h <> 0 Then FreeMem32 (screen.h);
     GetMem32 (screen.h, screen.memneed * screen._16bit);
 end;
  writeinfo;
  screen.randr := screen.maxx; screen.randl := 0; screen.rando := 0; screen.randu := screen.maxy;
  for z:=0 to 3 do begin
   schrift[z].maxwx:=screen.maxx-1;
   schrift[z].maxwy:=screen.maxy-1;
  end;
  writeln(screen.lfb);
  readkey;
  Asm
    mov AX, $4F02
    mov BX, Mode
    mov Cl,screen.lfb
    cmp cl,0
    je @go
    or bx,$4000
    @go:
    Int $10
  End;
  lastmode:=0;
  loadgif ('zwischen'); {Palette}
End;

Procedure getspritegel (offs,form: Word; Var spr: spritetyp);
Var z, gsx, gsy: LongInt;
Begin
  spr. dtx := 64;
  spr. dty := 48;
  spr. adr := sp.sprdatazahl;
  z := 0;
  For gsy := 0 To 47 Do if glong[form,gsy]>0 then For gsx := 0 To glong [form,gsy] - 1 Do Begin
    writemem32w (Ptr48 (sprdata, z + sp.sprdatazahl), mem [SegA000: offs + gtab [form,gsy] + gsx + gsy * 320] );
    Inc (z,screen._16bit);
  End;
  sp.sprdatazahl := sp.sprdatazahl + (spr. dtx * spr. dty * screen._16bit);
End;

Procedure getsprite (offs: Word; brei, hoc: Word; Var spr: spritetyp);
Var gsx, gsy, z: LongInt;
Begin
  spr. dtx := brei;
  spr. dty := hoc;
  spr. adr := sp.sprdatazahl;
  z := 0;
  For gsy := 0 To hoc - 1 Do For gsx := 0 To brei - 1 Do Begin
    writemem32w (Ptr48 (sprdata, z + sp.sprdatazahl), mem [SegA000: offs + gsx + gsy * 320] );
    Inc (z,screen._16bit);
  End;
  sp.sprdatazahl := sp.sprdatazahl + (spr. dtx * spr. dty * screen._16bit);
End;

Procedure putsprite (ox, oy: longint; spr: spritetyp);
Var z: LongInt;
Begin
  If (ox<0) or (oy<0) or (ox + spr. dtx >= screen.maxx-1) Or (oy + spr. dty >= screen.maxy-1) Then Exit;
  For z := 0 To spr. dty - 1 Do
Move32 (Ptr48 (sprdata, z * spr. dtx * screen._16bit + spr. adr),
        Ptr48 (screen.h, ox*screen._16bit +screen.screeny [oy+screen.page + z]),
               spr. dtx * screen._16bit);
End;

Procedure putransprite (ox, oy: LongInt; spr: spritetyp);
{Machen: Case screen._16bit of ... }
Var temp, X1, X2, Y1, Y2, z, zz: longint;
  tt: Byte;
Begin
  If (ox >= screen.randr) Or (ox <= screen.randl - spr. dtx) Or (oy <= screen.rando - spr. dty) Or (oy > screen.randu) Then
              Exit;
  temp := spr. adr;
    case screen._16bit of
1:If (ox > screen.randr - spr. dtx) Or (ox < screen.randl) Or (oy < screen.rando) Or (oy > screen.randu - spr. dty) Then Begin
    X1 :=0;
    X2 := spr. dtx;
    Y1 :=0;
    Y2 := spr. dty;
    If (ox > screen.randr - spr. dtx) Then X2 := screen.randr - ox;
    If (ox < screen.randl) Then X1 := - ox;
    If (oy < screen.rando) Then Y1 := - oy;
    If (oy > screen.randu - spr. dty) Then Y2 := screen.randu - oy;
  For z := Y1 To Y2-1 Do Begin
      temp := z * spr. dtx + X1+ spr. adr;
      For zz := X1 To X2-1 Do Begin
        Inc (temp);
        tt := readmem32b (Ptr48 (sprdata, temp));
        If tt > 0 Then writemem32b (Ptr48 (screen.h, ox + zz + screen.screeny [oy+screen.page + z] ), tt);
      End;
    End;
  End Else
    For z := 0 To spr. dty - 1 Do
      For zz := 0 To spr. dtx - 1 Do Begin
        tt := readmem32b (Ptr48 (sprdata, temp) );
        Inc (temp);
        If tt > 0 Then writemem32b (Ptr48 (screen.h, ox + zz + screen.screeny [oy+screen.page + z] ), tt);
      End;
    2:If (ox > screen.randr - spr. dtx) Or (ox < screen.randl) Or (oy < screen.rando) Or (oy > screen.randu - spr. dty)
    Then Begin
    X1 :=0;
    X2 := spr. dtx;
    Y1 :=0;
    Y2 := spr. dty;
    If (ox > screen.randr - spr. dtx) Then X2 := screen.randr - ox;
    If (ox < screen.randl) Then X1 := - ox;
    If (oy < screen.rando) Then Y1 := - oy;
    If (oy > screen.randu - spr. dty) Then Y2 := screen.randu - oy;
  For z := Y1 To Y2-1 Do Begin
      temp := (z * spr. dtx + X1) shl 1 + spr. adr;
      For zz := X1 To X2-1 Do Begin
        Inc (temp,2);
        tt := readmem32w (Ptr48 (sprdata, temp));
        If tt > 0 Then writemem32w (Ptr48 (screen.h, (ox + zz) shl 1 + screen.screeny [oy+screen.page + z] ), tt+screen.light);
      End;
    End;
  End Else
    For z := 0 To spr. dty - 1 Do
      For zz := 0 To spr. dtx - 1 Do Begin
        tt := readmem32w (Ptr48 (sprdata, temp) );
        Inc (temp,2);
        If tt > 0 Then writemem32w (Ptr48 (screen.h, (ox + zz) shl 1 + screen.screeny [oy + z] ), tt+screen.light);
      End;
End;
end;

Procedure putgelsprite (ox, oy: LongInt; form:word; spr: spritetyp);
Var zz, z: word;
Begin
  If (ox >= screen.randr) Or (ox <= screen.randl - 64) Or (oy <= screen.rando - 48) Or (oy >= screen.randu) Then Exit;
  z := 0;
  zz := 0;
  case screen._16bit of
  1:If (ox >= screen.randr - 64) Or (ox < screen.randl) Or (oy < screen.rando) Or (oy >= screen.randu - 48) Then Begin
    If (ox >= screen.randr - 64) Then Begin {RECHTS}
      If (oy >= screen.randu - 48) Then Begin {UNTEN}
        For z := 0 To screen.randu - oy Do if glong[form,z]>0 then Begin
          If gtab [form,z] + ox + glong [form,z] < screen.randr Then
             Move32 (Ptr48 (sprdata, zz + spr. adr), Ptr48 (screen.h, screen.screeny [oy+screen.page + z] + ox+gtab [form,z] ),
                      glong [form,z])
          Else If gtab [form,z] + ox < screen.randr Then
            Move32 (Ptr48 (sprdata, zz + spr. adr),Ptr48 (screen.h, ox + gtab [form,z] + screen.screeny [oy+screen.page + z] ),
                       (screen.randr - (ox + gtab[form,z] )) );
          Inc (zz, glong [form,z] );
        End;
      End Else If (oy < screen.rando) Then Begin  {OBEN}
        For z := 0 To screen.rando - oy-1 Do zz := zz + glong [form,z];
        For z := screen.rando - oy To 47 Do if glong[form,z]>0 then Begin
          If gtab [form,z] + ox + glong [form,z] < screen.randr Then
            Move32 (Ptr48 (sprdata, zz + spr. adr), Ptr48 (screen.h, screen.screeny [oy+screen.page+z] +(ox+ gtab [form,z])),
                 glong [form,z])
          Else If gtab [form,z] + ox < screen.randr Then
            Move32 (Ptr48 (sprdata, zz + spr. adr), Ptr48 (screen.h, screen.screeny [oy+screen.page + z] + (ox+gtab [form,z])),
                       (screen.randr - (ox + gtab [form,z] )) );
          Inc (zz, glong [form,z] ); {Anfangs noch gelaendtab[rando-oy-1] addieren!}
        End;
      End Else
        For z := 0 To 47 Do begin               {NUR RECHTS}
         if glong[form,z]>0 then Begin
          If gtab [form,z] + ox + glong [form,z] < screen.randr Then
            Move32 (Ptr48 (sprdata, zz + spr. adr), Ptr48 (screen.h, screen.screeny [oy+screen.page + z] +(ox+ gtab [form,z])),
                glong [form,z])
          Else If gtab [form,z] + ox < screen.randr Then
            Move32 (Ptr48 (sprdata, zz + spr. adr),Ptr48 (screen.h, screen.screeny [oy+screen.page + z] +(ox+ gtab [form,z]) ),
                     (screen.randr - (ox + gtab [form,z] )) );
         End;
         Inc (zz, glong [form,z] );
        end;
    End Else If (ox < screen.randl) Then Begin    {LINKS}
      If (oy >= screen.randu - 48) Then Begin     {UNTEN}
        For z := 0 To screen.randu - oy Do if glong[form,z]>0 then Begin
          If gtab [form,z] + ox > screen.randl Then
            Move32 (Ptr48 (sprdata, zz + spr. adr), Ptr48 (screen.h, screen.screeny [oy+screen.page + z] +(ox+ gtab [form,z])),
                     glong [form,z])
          Else If gtab [form,z] + ox + glong [form,z] > screen.randl Then
            Move32 (Ptr48 (sprdata, zz + spr. adr + (gtab [form,z] + ox + glong [form,z] - screen.randl)),
                     Ptr48 (screen.h, screen.randl + screen.screeny [oy+screen.page + z] ),
                     (gtab [form,z] + ox + glong [form,z] - screen.randl));
          Inc (zz, glong [form,z] );
        End;
      End Else If (oy < screen.rando) Then Begin  {OBEN}
        For z := 0 To screen.rando - oy Do zz := zz + gtab [form,z];
        For z := screen.rando - oy To 47 Do if glong[form,z]>0 then Begin
          If gtab [form,z] + ox > screen.randl Then
            Move32 (Ptr48 (sprdata, zz + spr. adr), Ptr48 (screen.h, screen.screeny [oy+screen.page + z] + (ox+gtab [form,z])),
                      glong [form,z])
          Else If gtab [form,z] + ox + glong [form,z] > screen.randl Then
            Move32 (Ptr48 (sprdata, zz + spr. adr + (gtab [form,z] + ox + glong [form,z] - screen.randl)),
                       Ptr48 (screen.h, screen.randl + screen.screeny [oy+screen.page + z] ),
                       (gtab [form,z] + ox + glong [form,z] - screen.randl));
          Inc (zz, glong [form,z] );
        End;
      End Else                                   {NUR LINKS}
        For z := 0 To 47 Do if glong[form,z]>0 then Begin
          If (gtab [form,z] + ox > screen.randl) then
            Move32 (Ptr48 (sprdata, zz + spr. adr), Ptr48 (screen.h, screen.screeny [oy+screen.page + z] +(ox+ gtab [form,z])),
                 glong [form,z])
          Else If gtab [form,z] + ox + glong [form,z] > screen.randl Then
            Move32 (Ptr48 (sprdata, zz + spr. adr +(- gtab [form,z] - ox {+ glong [form,z]} + screen.randl)),
                    Ptr48 (screen.h, screen.randl + screen.screeny [oy+screen.page + z] ),
                       (gtab [form,z] + ox + glong [form,z] - screen.randl));
          Inc (zz, glong [form,z] );
        End;
    End Else If (oy >= screen.randu - 48) Then Begin {NUR UNTEN}
      For z := 0 To screen.randu - oy Do if glong[form,z]>0 then Begin
        Move32 (Ptr48 (sprdata, zz + spr. adr), Ptr48 (screen.h, (ox + gtab [form,z] )+screen.screeny [oy+screen.page + z]),
            glong [form,z] );
        Inc (zz, glong [form,z] );
       End;
    End Else If (oy < screen.rando) Then Begin      {NUR OBEN}
      For z := 0 To screen.rando - oy-1 Do zz := zz + glong [form,z];
      For z := screen.rando - oy To 47 Do if glong[form,z]>0 then Begin
        Move32 (Ptr48 (sprdata, zz + spr. adr), Ptr48 (screen.h, (ox + gtab [form,z] )+screen.screeny [oy+screen.page + z] ),
           glong [form,z] );
        Inc (zz, glong [form,z] );
      End;
    End;
  End Else
    For z := 0 To 47 Do if glong[form,z]>0 then Begin
      Move32 (Ptr48 (sprdata, zz + spr. adr), Ptr48 (screen.h, (ox + gtab [form,z] )+screen.screeny [oy+screen.page + z]) ,
           glong [form,z] );
      Inc (zz, glong [form,z] );
    End;

  2:If (ox >= screen.randr - 64) Or (ox < screen.randl) Or (oy < screen.rando) Or (oy >= screen.randu - 48) Then Begin
    If (ox >= screen.randr - 64) Then Begin {RECHTS}
      If (oy >= screen.randu - 48) Then Begin {UNTEN}
        For z := 0 To screen.randu - oy Do if glong[form,z]>0 then Begin
          If gtab [form,z] + ox + glong [form,z] < screen.randr Then
            Move32 (Ptr48 (sprdata, zz + spr. adr), Ptr48 (screen.h,
             screen.screeny [oy+screen.page + z] + (ox+gtab [form,z])shl 1 ),
                      glong [form,z]shl 1)
          Else If gtab [form,z] + ox < screen.randr Then
            Move32 (Ptr48 (sprdata, zz + spr. adr),
             Ptr48 (screen.h, (ox + gtab [form,z])shl 1 + screen.screeny [oy+screen.page+z] ),
                       (screen.randr - (ox + gtab[form,z] ))shl 1 );
          Inc (zz, glong [form,z]shl 1 );
        End;
      End Else If (oy < screen.rando) Then Begin  {OBEN}
        For z := 0 To screen.rando - oy-1 Do zz := zz + glong [form,z];
        zz:=zz shl 1;
        For z := screen.rando - oy To 47 Do if glong[form,z]>0 then Begin
          If gtab [form,z] + ox + glong [form,z] < screen.randr Then
            Move32 (Ptr48 (sprdata, zz + spr. adr), Ptr48 (screen.h,
             screen.screeny [oy+screen.page + z] +(ox+ gtab [form,z])shl 1 ),
                 glong [form,z]shl 1)
          Else If gtab [form,z] + ox < screen.randr Then
            Move32 (Ptr48 (sprdata, zz + spr. adr), Ptr48 (screen.h,
             screen.screeny [oy+screen.page + z] + (ox+gtab [form,z])shl 1),
                       (screen.randr - (ox + gtab [form,z] ))shl 1 );
          Inc (zz, glong [form,z]shl 1 ); {Anfangs noch gelaendtab[rando-oy-1] addieren!}
        End;
      End Else
        For z := 0 To 47 Do begin               {NUR RECHTS}
         if glong[form,z]>0 then Begin
          If gtab [form,z] + ox + glong [form,z] < screen.randr Then
            Move32 (Ptr48 (sprdata, zz + spr. adr), Ptr48 (screen.h,
             screen.screeny [oy+screen.page + z] +(ox+ gtab [form,z])shl 1 ),
                glong [form,z]shl 1)
          Else If gtab [form,z] + ox < screen.randr Then
            Move32 (Ptr48 (sprdata, zz + spr. adr),Ptr48 (screen.h,
             screen.screeny [oy+screen.page + z] +(ox+ gtab [form,z])shl 1 ),
                     (screen.randr - (ox + gtab [form,z] ))shl 1 );
         End;
         Inc (zz, glong [form,z]shl 1 );
        end;
    End Else If (ox < screen.randl) Then Begin    {LINKS}
      If (oy >= screen.randu - 48) Then Begin     {UNTEN}
        For z := 0 To screen.randu - oy Do if glong[form,z]>0 then Begin
          If gtab [form,z] + ox > screen.randl Then
            Move32 (Ptr48 (sprdata, zz + spr. adr), Ptr48 (screen.h,
             screen.screeny [oy+screen.page+ z] +(ox+ gtab [form,z])shl 1 ),
                     glong [form,z]shl 1)
          Else If gtab [form,z] + ox + glong [form,z] > screen.randl Then
            Move32 (Ptr48 (sprdata, zz + spr. adr + (gtab [form,z] + ox + glong [form,z] - screen.randl)shl 1),
                     Ptr48 (screen.h, screen.randl shl 1 + screen.screeny [oy+screen.page+ z] ),
                     (gtab [form,z] + ox + glong [form,z] - screen.randl)shl 1);
          Inc (zz, glong [form,z]shl 1 );
        End;
      End Else If (oy < screen.rando) Then Begin  {OBEN}
        For z := 0 To screen.rando - oy Do zz := zz + gtab [form,z];
        zz:=zz shl 1;
        For z := screen.rando - oy To 47 Do if glong[form,z]>0 then Begin
          If gtab [form,z] + ox > screen.randl Then
            Move32 (Ptr48 (sprdata, zz + spr. adr), Ptr48 (screen.h,
             screen.screeny [oy+screen.page+ z] + (ox+gtab [form,z])shl 1 ),
                      glong [form,z]shl 1)
          Else If gtab [form,z] + ox + glong [form,z] > screen.randl Then
            Move32 (Ptr48 (sprdata, zz + spr. adr + (gtab [form,z] + ox + glong [form,z] - screen.randl)shl 1),
                       Ptr48 (screen.h, screen.randl shl 1 + screen.screeny [oy+screen.page+ z] ),
                       (gtab [form,z] + ox + glong [form,z] - screen.randl)shl 1);
          Inc (zz, glong [form,z]shl 1 );
        End;
      End Else                                   {NUR LINKS}
        For z := 0 To 47 Do if glong[form,z]>0 then Begin
          If (gtab [form,z] + ox > screen.randl) then
            Move32 (Ptr48 (sprdata, zz + spr. adr), Ptr48 (screen.h,
             screen.screeny [oy+screen.page+ z] +(ox+ gtab [form,z])shl 1 ),
                 glong [form,z]shl 1)
          Else If gtab [form,z] + ox + glong [form,z] > screen.randl Then
            Move32 (Ptr48 (sprdata, zz + spr. adr +(- gtab [form,z] - ox {+ glong [form,z]} + screen.randl)shl 1),
                    Ptr48 (screen.h, screen.randl shl 1 + screen.screeny [oy+screen.page+ z] ),
                       (gtab [form,z] + ox + glong [form,z] - screen.randl)shl 1);
          Inc (zz, glong [form,z]shl 1 );
        End;
    End Else If (oy >= screen.randu - 48) Then Begin {NUR UNTEN}
      For z := 0 To screen.randu - oy Do if glong[form,z]>0 then Begin
        Move32 (Ptr48 (sprdata, zz + spr. adr), Ptr48 (screen.h,
         (ox + gtab [form,z] )shl 1+screen.screeny [oy+screen.page+ z]),
            glong [form,z]shl 1 );
        Inc (zz, glong [form,z]shl 1 );
       End;
    End Else If (oy < screen.rando) Then Begin      {NUR OBEN}
      For z := 0 To screen.rando - oy-1 Do zz := zz + glong [form,z];
      zz:=zz shl 1;
      For z := screen.rando - oy To 47 Do if glong[form,z]>0 then Begin
        Move32 (Ptr48 (sprdata, zz + spr. adr), Ptr48 (screen.h,
         (ox + gtab [form,z] )shl 1+screen.screeny [oy+screen.page+ z] ),
           glong [form,z]shl 1 );
        Inc (zz, glong [form,z]shl 1 );
      End;
    End;
  End Else
    For z := 0 To 47 Do if glong[form,z]>0 then Begin
      Move32 (Ptr48 (sprdata, zz + spr. adr), Ptr48 (screen.h, (ox + gtab [form,z] )shl 1+screen.screeny [oy+screen.page+ z]) ,
           glong [form,z]shl 1 );
      Inc (zz, glong [form,z]shl 1 );
    End;
End;
end;
Procedure initfont (wox, woy: Word; dx, dy: Byte);
Var temp8: Byte;
Begin
  schrift[aktab].zhb.dx := dx;
  schrift[aktab].zhb.dy := dy;
  schrift[aktab].wx := wox;
  schrift[aktab].wy := woy;
  For temp8 := 0 To anz Do Begin
    Inc (schrift[aktab].wx, schrift[aktab].zhb.dx);
    If schrift[aktab].wx + schrift[aktab].zhb.dx > 320 Then Begin
       schrift[aktab].wx := 0;
       Inc (schrift[aktab].wy, schrift[aktab].zhb.dy);
     End;
    getsprite (schrift[aktab].wx + schrift[aktab].wy * 320, schrift[aktab].zhb.dx, schrift[aktab].zhb.dy,
                schrift[aktab].zeichen [temp8] );
  End;
  getsprite (0, dX, dy, schrift[aktab].zeichen [0] );
End;

Procedure schreib (X, Y: Word; c: Byte);
Begin
  If c > 0 Then Begin
    If schrift[aktab].blacker Then putransprite (X, Y, schrift[aktab].zeichen [c - 1] )
                       Else putsprite (X, Y, schrift[aktab].zeichen [c - 1] );
  End Else
  Begin
    If schrift[aktab].blacker Then putransprite (X, Y, schrift[aktab].zeichen [0] )
                       Else putsprite (X, Y, schrift[aktab].zeichen [0] );
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
      Inc (schrift[aktab].wy, schrift[aktab].zhb.dy);
      Dec (schrift[aktab].wx, schrift[aktab].zhb.dx);
    End;
    If (Ord (was [z] ) = 10) Then Begin
      schrift[aktab].wx := screen.randl;
      Dec (schrift[aktab].wx, schrift[aktab].zhb.dx);
    End;
    If schrift[aktab].format = False Then Begin
      If (Ord (was [z] ) - 32 <= anz) And (Ord (was [z] ) - 32 >= 0) Then
              schreib (schrift[aktab].wx, schrift[aktab].wy, Ord (was [z] ) - 32)
         Else schreib (schrift[aktab].wx, schrift[aktab].wy, 0);

    End Else
      Case was [z] Of
        {   #0..#32:schreib(wx,wy,1);}
        #33..#90: schreib (schrift[aktab].wx, schrift[aktab].wy, Ord (was [z] ) - 32);
        {   #91..#96:schreib(wx,wy,1);}
        #97..#122: schreib (schrift[aktab].wx, schrift[aktab].wy, Ord (was [z] ) - 32);
        {   #123..#255:schreib(wx,wy,1);}
      End;
    If (Ord (was [z] ) > 0) Then Inc (schrift[aktab].wx, schrift[aktab].zhb.dx);
    If schrift[aktab].wx + schrift[aktab].zhb.dx > schrift[aktab].maxwx Then Begin
      schrift[aktab].wx := schrift[aktab].minwx;
      Inc (schrift[aktab].wy, schrift[aktab].zhb.dy);
      if schrift[aktab].wy + schrift[aktab].zhb.dy > schrift[aktab].maxwy Then schrift[aktab].wy := schrift[aktab].minwy;
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
  schrift[aktab].wx := ox; schrift[aktab].wy := oy;
  putsprite (ox, oy, sp.schalt [1] );
  If on > 1 Then aktab := 1 Else aktab := on;
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
    For z := Y To yy Do if z<screen.maxy then
     Filllong32 (Ptr48 (screen.h, X + screen.screeny [z+screen.page] ), xx shr 2, col);
  End Else
  Begin
    For z := X To xx Do writemem32b (Ptr48 (screen.h, z + screen.screeny [Y1+screen.page] ), col);
    For z := X To xx Do writemem32b (Ptr48 (screen.h, z + screen.screeny [Y2+screen.page] ), col);
    For z := Y To yy Do writemem32b (Ptr48 (screen.h, X1 + screen.screeny [z+screen.page] ), col);
    For z := Y To yy Do writemem32b (Ptr48 (screen.h, X2 + screen.screeny [z+screen.page] ), col);
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
xx,yy:word;
Begin
  initmen;
  loadgif ('grid4');
  show_pic13;
{  getsprite (64, 50, 32, sp.dorf);}
  getsprite (122, 21, 50, sp.pflanze);
  loadgif ('mhaus2');
  show_pic13;
  getsprite (0, 200, 140, sp.dorf);
  loadgif('grid3d1');
  show_pic13;
   for xx:=0 to 3 do for yy:=0 to 3 do getsprite(xx*64+xx+1+(yy*48+yy+1)*320,64,48,sp.grid1[xx*4+yy]);
  loadgif('grid3d2');
  show_pic13;
  for yy:=0 to 2 do getsprite(1+(yy*48+yy+1)*320,64,48,sp.grid1[16+yy]);
  loadgif('grid3d3');
  show_pic13;
  for xx:=0 to 3 do for yy:=0 to 3 do getsprite(xx*64+xx+1+(yy*48+yy+1)*320,64,48,sp.grid2[xx*4+yy]);
  loadgif('grid3d4');
  show_pic13;
  for yy:=0 to 2 do getsprite(1+(yy*48+yy+1)*320,64,48,sp.grid2[16+yy]);

  loadgif ('font172');
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
  aktab := 0;
{  initfont (0, 109,12,16);}
  initfont (0, 0,6,8);
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
  for xx:=0 to 3 do for yy:=0 to 3 do getspritegel(xx*64+xx+1+(yy*48+yy+1)*320,xx*4+yy,sp.hoehe[xx*4+yy]);
  loadgif('3d2');
  show_pic13;
  for yy:=0 to 2 do getspritegel(1+(yy*48+yy+1)*320,16+yy,sp.hoehe[16+yy]);
  loadgif('3d6');
  show_pic13;
  for xx:=0 to 3 do for yy:=0 to 3 do getspritegel(xx*64+xx+1+(yy*48+yy+1)*320,xx*4+yy,sp.hoehe[xx*4+yy+20]);
  loadgif('3d5');
  show_pic13;
  for yy:=0 to 2 do getspritegel(1+(yy*48+yy+1)*320,16+yy,sp.hoehe[36+yy]);
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
  getspritegel (192 + 0 * 320, 10, sp.wasser [0] );
  getspritegel (192 + 32 * 320, 10,  sp.wasser [1] );        {Wasser}
  getspritegel (192 + 64 * 320, 10,  sp.wasser [2] );
  getspritegel (192 + 96 * 320,10,  sp.wasser [3] );
  {
  getspritegel (0 + 0 * 320, sp.grass [0] );
  getspritegel (0 + 32 * 320, sp.grass [1] );
  getspritegel (0 + 64 * 320, sp.grass [2] );         {Strand}
 { getspritegel (0 + 96 * 320, sp.grass [3] );

  getspritegel (64 + 0 * 320, sp.grass [4] );
  getspritegel (64 + 32 * 320, sp.grass [5] );         {Grass}
  {getspritegel (64 + 64 * 320, sp.grass [6] );
  getspritegel (64 + 96 * 320, sp.grass [7] );

  getspritegel (128 + 0 * 320, sp.grass [8] );
  getspritegel (128 + 32 * 320, sp.grass [9] );        {Schnee}
{  getspritegel (128 + 64 * 320, sp.grass [10] );
  getspritegel (128 + 96 * 320, sp.grass [11] );

  getspritegel (192 + 0 * 320, sp.grass [12] );
  getspritegel (192 + 32 * 320, sp.grass [13] );        {Wasser}
{  getspritegel (192 + 64 * 320, sp.grass [14] );
  getspritegel (192 + 96 * 320, sp.grass [15] );

  getspritegel (256 + 0 * 320, sp.grass [16] );
  getspritegel (256 + 32 * 320, sp.grass [17] );        {ICe}
{  getspritegel (256 + 64 * 320, sp.grass [18] );
  getspritegel (256 + 96 * 320, sp.grass [19] );

  loadgif ('zwischen');
  show_pic13;
  getspritegel (0 * 320, sp.grass [20] );
  getspritegel (32 * 320, sp.grass [21] );        {strand}
{  getspritegel (64 * 320, sp.grass [22] );
  getspritegel (96 * 320, sp.grass [23] );

  getspritegel (64 + 0 * 320, sp.grass [24] );
  getspritegel (64 + 32 * 320, sp.grass [25] );        {Felsen}
{  getspritegel (64 + 64 * 320, sp.grass [26] );
  getspritegel (64 + 96 * 320, sp.grass [27] );}
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
  long := long * schrift[aktab].zhb.dx + 16;
  If long < 100 Then long := 100;
  {if (X1+32+long>maxx) or (y1+114>maxy) then exit;}
  vwindow (X1, Y1, X1 + 32 + long, Y1 + 132);
  rechteck (X1 + 16, Y1 + 16, X1 + 15 + long, Y1 + 114, 0, True);
  owx := schrift[aktab].wx; owy := schrift[aktab].wy;
  schrift[aktab].wx := X1 + 24; schrift[aktab].wy := Y1 + 24;
  schrift[aktab].minwx:=schrift[aktab].wx;
  schrift[aktab].minwy:=schrift[aktab].wy;
  schrift[aktab].maxwx:=X1+15+long;
  schrift[aktab].maxwy:=Y1+114;
  tt := screen.randl;
  screen.randl := schrift[aktab].wx;
  writes (was);
  screen.randl := tt;
  schrift[aktab].wx := owx; schrift[aktab].wy := owy;
End;

Procedure show_picture (X, Y: LongInt; Name: String);
Var start: LongInt;
  zyy, zxx: LongInt;
Begin
  loadgif (Name);
  start := X + screen.screeny [Y];
  For zyy := 0 To 199 Do For zxx := 0 To 319 Do
    writemem32b (Ptr48 (screen.h, start + zxx + screen.screeny [zyy] ), mem [Seg (vscreen^): Ofs (vscreen^) + zyy * 320+zxx]);
End;

Procedure load_picture (X, Y: LongInt; Name: Pointer);
Var start: LongInt;
  zyy, zxx: LongInt;
  temp: Byte;
Begin
  start := X + screen.screeny [Y];
  For zyy := 0 To 199 Do
    Move32 (Ptr48 (Seg (Name^), Ofs (Name^) + zyy * 320), Ptr48 (screen.h, screen.screeny [zyy] ), 64000);
End;

Begin
  Exiter := ExitProc;
  ExitProc := @VesaExit;
  sp.sprdatazahl := 0;
End.

