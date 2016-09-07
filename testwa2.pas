Uses crt, wars2, DOS, vesa107, newfrontier, units3,eat2;
Var
f,timero,  X3, Y3, xx, yy, X4, Y4, kk, k: LongInt;
  a: Char;
  err, lon: Word;
counter, zz, frames, Hour, Sec, Sec2: Word;
Const
  MULTIPLEX  = $2F;     { Interrupt-Nummer des Multiplex-Interrupt }
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
  $cd / $2f /                             { int   2Fh           }
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
  WriteLn ('             NO SELLABLE DEMOVERSION. ALL RIGHTS BY CLAW-Software!');
  writeln ('                              Alpha Release V0.16.');
  writeln ('Please note: We won''t take responsibility of any damages this program may cause.');
  writeln ('                        Run it on your own risk. Continue?');
  if upcase(readkey)<>'Y' then halt;
  writeln ('                              System requirements:');
  writeln ('                                  -- 486 CPU --');
  writeln ('                                  -- 4MB RAM --');
  writeln ('                                  -- a mouse --');
  writeln ('                         -- SVGA Grafik card with VBE1.2--');
  WriteLn;
  WindowsAktiv := windows ( HVer, NVer );
  {  halt( WindowsAktiv );}
  If windowsaktiv <> no_win Then Begin TextBackground (White); TextColor (Red + Blink); End;
  Case ( WindowsAktiv ) Of
    NO_WIN:     WriteLn ( 'Good!. No active Windows decteted.' );
    W_REAL:     WriteLn ( 'WARNING : Windows in Real-Mode. Interesting.' );
    W_STANDARD: WriteLn ( 'WARNING : Windows active in normal mode.' );
    W_386_X:    WriteLn ( 'WARNING : Windows/386 V 2.x active' );
    W_ENHANCED: WriteLn ( 'WARNING : Windows V ', Hver, '.', NVer,
                  ' active in extended mode' );
  End;
  {if windowsaktiv<>no_win then begin sound(300);delay(300);nosound;sound(100);delay(500);nosound;end;}
  TextBackground (Black);
  TextColor (Green);
  If windowsaktiv <> no_win Then Begin
    WriteLn (' WARS! should run under a stable DOS to avoid hang-ups or head-crashes!');
    Write (' REALLY Continue?');
    a := ReadKey; If a = #0 Then a := ReadKey;
    If (UpCase (a) <> 'J') And (UpCase (a) <> 'Y') Then Begin
      WriteLn (' Yes. You chose the right way. Restart now with DOS.');
      ReadKey; Halt;
    End;
  End;
  WriteLn;
  Write (' Choose sea- or landscenario? (S,L) ');
  If UpCase (ReadKey) = 'S' Then Begin WriteLn (' Seeszenario. OK.'); see := 3; End Else
  Begin WriteLn (' Landszenario. OK.'); see := 2; End;
  WriteLn (' Keys in game :');
  WriteLn (' Cursorkeys  : Scrolling');
  WriteLn (' +/-         : Change hand');
  WriteLn (' F1          : Minimap');
  WriteLn (' F2          : Show some informations');
  writeln (' F3          : Show gridlines');
  WriteLn (' F10         : Change video mode');
  WriteLn (' C           : Earthquake');
  ReadKey;
  If ParamCount = 0 Then init (257) Else begin
    Val (ParamStr (1), lon, err);
    If err = 0 Then init (lon) Else Begin
      WriteLn ('Error in parameters. Please check this... You wrote ',paramstr(1),' ...');
      WriteLn ('Setting up lowest resolution...');
      init (257);
    End;
  End;
  intro;
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
  if counter=32 then begin counter:=0;verdauen;end else inc(counter);
  inc(screen.light,random(1000));
  Until a = #27;
End.

