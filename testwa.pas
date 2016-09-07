Uses crt, wars, DOS, vesa103, newfrontier, units ;
Var
  X3, Y3, xx, yy, X4, Y4, kk, k: LongInt;
  a: Char;
  err, lon: Word;
  xer, yer, nummer: Array [0..20] Of LongInt;
  zz, frames, Hour, Sec, Sec2: Word;
Const MULTIPLEX  = $2F;     { Interrupt-Nummer des Multiplex-Interrupt }
  NO_WIN     = $00;                          { Windows nicht aktiv }
  W_386_X    = $01;                      { Windows /386 V2.X lÑuft }
  W_REAL     = $81;                  { Windows lÑuft im Real-Modus }
  W_STANDARD = $82;              { Windows lÑuft im Standard-Modus }
  W_ENHANCED = $83;           { Windows lÑuft im Erweiterten-Modus }
  
  Function windows ( 
Var HVersion, NVersion : Integer ) : Integer;

Var regs : Registers;                  { Register fÅr Interrupt-Aufruf }
  Erg  : Integer;
  
Function Int2fcall : Integer;

Begin
  Inline ( $b8 / $00 / $16 /                      { mov   ax,1600h      }
  $cd / $2f /                            { int   2Fh           }
  $89 / $46 / $FE );                     { mov   [bp-2], ax    }
End;

Begin
  HVersion := 0;                        { Initialisiere Versionsnummer }
  NVersion := 0;
  
  erg := Int2fcall;              { Installationstest Erweiterter-Modus }
  
  Case ( Lo (Erg) ) Of
    $01,
    $FF:  Begin
      HVersion := 2;                              { Hauptversion }
      NVersion := 0;                    { Nebenversion unbekannt }
      Windows := W_386_X;
    End;
    $00,
    $80:  
          Begin
            regs. AX := $4680;  { Real- u. Standardmodus identifizieren }
            Intr ( MULTIPLEX, regs );
            If ( regs. AL = $80 ) Then
              Windows := NO_WIN                  { Windows lÑuft nicht }
            Else
            Begin
              {-- Windows im Real- oder Standardmodus ---------------}
              
              regs. AX := $1605;   { Installation DOS-Extender simul. }
              regs. BX := $0000;
              regs. SI := $0000;
              regs. CX := $0000;
              regs. ES := $0000;
              regs. DS := $0000;
              regs. DX := $0001;
              Intr ( MULTIPLEX, regs );
              If ( regs. CX = $0000 ) Then
              Begin
                {-- Windows im Real-Modus -------------------------}
                
                regs. AX := $1606;
                Intr ( MULTIPLEX, regs );
                Windows := W_REAL;
              End
              Else
                Windows := W_STANDARD;
            End;
          End;
    
    {-- Windows im Erweiterten-Modus, ax enthÑlt Versionsnummer -------}
    
    Else
    Begin
      HVersion := Lo (Erg);                { Windows Version ausgeben }
      NVersion := Hi (Erg);
      Windows := W_ENHANCED;          { Windows im Erweiterten-Modus }
    End;
  End;
End;

Var WindowsAktiv,                                      { Windows-Modus }
  HVer,                                   { Hauptversion von Windows }
  NVer         : Integer;                 { Nebenversion von Windows }
  
Begin
  WriteLn ('€€€€€€€€€€€€€€€€€€€€€€€€€ WARS! (C) by CLAW-Software€€€€€€€€€€€€€€€€€€€€€€€€€€€€' );
  WriteLn ('      Unverkaeufliche Demoversion. Alle Rechte liegen bei CLAW-Software');
  WriteLn;
  WindowsAktiv := windows ( HVer, NVer );
  {  halt( WindowsAktiv );}
  WriteLn (' Hi zur Beta Version der 2. Demo ...');
  If windowsaktiv <> no_win Then Begin TextBackground (White); TextColor (Red + Blink); End;
  Case ( WindowsAktiv ) Of
    NO_WIN:     WriteLn ( 'Gut. Windows nicht aktiv.' );
    W_REAL:     WriteLn ( 'WARNING : Windows im Real-Modus. Interessant.' );
    W_STANDARD: WriteLn ( 'WARNING : Windows aktiv im Standard-Modus.' );
    W_386_X:    WriteLn ( 'WARNING : Windows/386 V 2.x aktiv' );
    W_ENHANCED: WriteLn ( 'WARNING : Windows V ', Hver, '.', NVer,
                  ' aktiv im erweiterten Modus' );
  End;
  
  {if windowsaktiv<>no_win then begin sound(300);delay(300);nosound;sound(100);delay(500);nosound;end;}
  TextBackground (Black);
  TextColor (Green);
  If windowsaktiv <> no_win Then Begin
    WriteLn (' WARS! sollte moeglichst unter DOS laufen, um Abstuerze etc. zu vermeiden!');
    Write (' wollen Sie WIRKLICH fortfahren?');
    a := ReadKey; If a = #0 Then a := ReadKey;
    If (UpCase (a) <> 'J') And (UpCase (a) <> 'Y') Then Begin
      WriteLn (' Sie haben sich richtig entschieden. Starten Sie nun DOS.');
      ReadKey; Halt; 
    End;
  End;
  WriteLn;
  Write (' Auswahl: Wollen Sie ein See- oder Landszenario? (S,Z) ');
  If UpCase (ReadKey) = 'S' Then Begin WriteLn (' Seeszenario. OK.'); see := 1; End Else
  Begin WriteLn (' Landszenario. OK.'); see := 0; End;
  WriteLn (' Funktionstasten im Spiel :');
  WriteLn (' Pfeiltasten : Scrollen');
  WriteLn (' +/-         : Mauszeiger aendern');
  WriteLn (' F1          : Minimap');
  WriteLn (' F2          : Informationen anzeigen');
  WriteLn (' F10         : Videomodus wechseln');
  WriteLn (' C           : Waessern/Landen');
  ReadKey;
  If ParamCount = 0 Then Begin WriteLn ('Sie koennen auch einen anderen Videomodus waehlen:');
    WriteLn ('Als Parameter einfach 257, 259 oder 261 angeben (640*480,800*600,1024*768)');
    ReadKey;
    init (257);
  End Else Begin
    Val (ParamStr (1), lon, err);
    If (lon <> 261) And (lon <> 259) And (lon <> 257) Then err := 1;
    If err = 0 Then init (lon) Else Begin
      WriteLn ('Fehlerhafter Parameter! Bitte geben Sie das naechste mal 257,259 oder 261 an!');
      WriteLn ('Stelle nun die niedrigste Aufloesung ein...');
      init (257);
    End;
  End;
  show_picture (screen.maxx Div 2 - 160, screen.maxy Div 2 - 100, 'wars9');
  While KeyPressed Do ReadKey;
  For zz := 0 To 20 Do Begin
    xer [zz] := Random (screen.maxx - 50) + 10;
    yer [zz] := Random (screen.maxy - 30);
    nummer [zz] := Random (8);
  End;
  Repeat
    FillChar32 (Ptr48 (h, 0), screen.memneed, 0);
    show_picture (screen.maxx Div 2 - 160, screen.maxy Div 2 - 100, 'wars9');
    For zz := 0 To 20 Do Begin
      Inc (xer [zz], 3);
      If xer [zz] > screen.maxx - 30 Then Begin
        putsprite (xer [zz] - 8, 100, sp.leer);
        xer [zz] := 0 - Random (50);
        yer [zz] := Random (screen.maxy - 30);
      End;
      Inc (nummer [zz] );
      If nummer [zz] > 7 Then nummer [zz] := 0;
      putransprite (xer [zz], yer [zz], sp.leut [nummer [zz], 2] );
    End;
    copytovga;
  Until KeyPressed;
  for zz:=0 to 10 do putsprite(zz*64,100,sp.hoehe[zz]);
  for zz:=0 to 7 do putsprite(zz*64,140,sp.hoehe[zz+11]);
  copytovga;
  readkey;
  readkey;
  Repeat
    weiter_schritt;
    If testframe Then Begin
      Inc (frames);
      Sec2 := Sec;
      GetTime (Hour, Hour, Sec, Hour);
      If Sec <> Sec2 Then Begin
        framessec := frames;
        frames := 0;
      End;
    End;
    paint;
    a := checkkey;
  Until a = #27;
  ReadKey;
  TextMode (3);
End.

