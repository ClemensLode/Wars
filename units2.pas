Unit units2;
Interface
Uses crt, wars2, vesa106, newfrontier;

Const anzmann = 75;

Type
  eig = Record
          weglong,                      {Laenge des aktuellen Weges in Feldern}
          phase,                        {Phase fuer Bewegung der Sprites}
          richtung,                     {Richtung fuer Sprites}
          wegp,                         {Fortschritt auf dem berechneten Weg (<weglong)}
          muede,hunger,wait          : Byte;          {Restliche Wartezeit in Bewegungszyklen}
          px, py         : ShortInt;      {Feine Positionseinstellung zwischen den Feldern}
          eatx,eaty,eatziel,sx, sy,                        {Startfeld des aktuellen Wegs}
          AX, ay,                        {Aktuelle Feldposition (Start)}
          CX, cy         : Integer;       {Aktuelles Ziel}
          goback,goeat,blocker,go: Boolean;
          weg           : Array [0..99] Of Record
                                             kx, ky: ShortInt;  {Aenderung der Richtung in der jeweiligen Phase}
                                           End;
          material: Array [0..100] Of Byte;               {Art und Menge des gerade transportierten Stoffes}
          prio:array[0..4] of byte;
        End;

Var spieler: Array [0..anzmann] Of eig;
  i: Word;
  errornum: String;
  besetzt:array[0..kartex,0..kartey] of byte;
  xx,yy:word;
  inhalt:byte;
Procedure stop (num1: LongInt); {sofortiger Stop;Kann nur nach px>=33 gestartet werden}
Function kompass (gox, goy: Integer): Byte;
Procedure gotoxye (gox, goy, num7: LongInt);
Procedure weiter_schritt;
procedure fill_besetzt;

Implementation

 Procedure stop (num1: LongInt); {sofortiger Stop;Kann nur nach px>=33 gestartet werden}
 Begin
   spieler [num1].go := False;
   spieler [num1].CX := spieler [num1].AX;
   spieler [num1].cy := spieler [num1].ay;
   spieler [num1].sx := spieler [num1].AX;
   spieler [num1].sy := spieler [num1].ay;
   spieler [num1].px := 0; spieler [num1].py := 0;
   FillChar (spieler [num1].weg, 200, 0);
   spieler [num1].weglong := 0;
   spieler [num1].wegp := 0;
   spieler [num1].phase := 0;
   spieler[num1].goback:=false;
   spieler[num1].goeat:=false;
   spieler[num1].wait:=0;
   spieler[num1].blocker:=false;
   spieler[num1].eatx:=0;
   spieler[num1].eaty:=0;
   spieler[num1].eatziel:=0;
 End;

 Function kompass (gox, goy: Integer): Byte;
 Begin
   Case gox Of
     - 1: Case goy Of
       - 1: kompass := 4;
       0: kompass := 7;
       1: kompass := 6;
     End;

     0: Case goy Of
       - 1: kompass := 3;
       1: kompass := 5;
     End;

     1: Case goy Of
       - 1: kompass := 2;
       0: kompass := 1;
       1: kompass := 0;
     End;
   End;
 End;
 Procedure error (num: Byte);
 Begin
   if num>0 then errornum:='Unbekannter Fehler!';
   Case num Of
     0: errornum := 'Alles OK!';
     1: errornum := 'Weg nicht gefunden';
     2: errornum := 'Zielfeld blockiert';
     3: errornum := '';
     4: errornum := 'Ziel bereits gesetzt';
   End;
 End;

 Function findway (gox, goy, num2: LongInt): Integer;
 {Moegliche Optimierung: Annaehrung von Start und Ziel}
  Type
    tempkarttyp = Array [0..kartex, 0..kartey] Of Record
                                            kx, ky: ShortInt;
                                          End;
    behinderung = array[0..kartex,0..kartey] of byte;
  Var
    num7, yyy, kkk, mx, my, long, tx, ty, X, Y, X1, Y1, t3, t4: Integer;
    erfolg: Boolean;
    tempkart:^tempkarttyp;
    behind:^behinderung;
    size:longint;
  Begin
    size:=(kartex+1)*(kartey+1);
    error (0);
    findway:=0;
    GetMem (tempkart, Size shl 1);
    GetMem (behind, Size);
    spieler [num2].go := False;
    FillChar (tempkart^, Size shl 1, 0);
    FillChar (behind^, Size, 0);
    move(besetzt,behind^,size);
{    for kkk:=0 to anzmann do behind^[spieler[kkk].ax,spieler[kkk].ay]:=2; {Feld von Spieler besetzt}

{    For yyy := 0 To kartey Do
      For kkk := 0 To kartex Do Begin
        num7 := readmem32b (Ptr48 (karte, 1 + screeny100 [1] ) );
        If (num7 < 4) Or (num7 > 7) Or (readmem32b (Ptr48 (gebirge, kkk + screeny100 [yyy] ) ) > 0) Then
          behind^ [kkk, yyy] := 1;
      End;

    {  for yyy:=1 to hanz do begin
    tempkart^[haus[yyy].x,haus[yyy].y].ti:=yyy+20;
    tempkart^[haus[yyy].x+1,haus[yyy].y].ti:=yyy+20;
    end;}
    If ( (gox = spieler [num2].CX) And (goy = spieler [num2].cy) ) Then begin findway:=4;error (4);end
    Else
{      If (behind^[gox,goy] > 0) And (behind^[gox,goy] < 3) Then begin
            error (2);
            stop (num2);
            FreeMem (tempkart, Size shl 1);
            FreeMem (behind, Size);
            Exit;
           end
      Else}
      Begin
        spieler [num2].CX := gox;
        spieler [num2].cy := goy;
        spieler [num2].wegp := 0;
        FillChar (spieler [num2].weg, 200, 0);
        If (Abs (spieler [num2].CX - spieler [num2].AX) <= 1) And (Abs (spieler [num2].cy - spieler [num2].ay) <= 1) Then
        Begin {Ziel nur 1 Feld entfernt...}
          spieler [num2].weglong := 0;
          spieler [num2].go := True;
          spieler [num2].weg [0].kx := spieler [num2].CX - spieler [num2].AX;
          spieler [num2].weg [0].ky := spieler [num2].cy - spieler [num2].ay;
          FreeMem (tempkart, size shl 1);
          FreeMem (behind, Size);
          Exit;
        End;
        {  for x:=0 to maxx do
        for y:=0 to maxy do
        if (tempkart^[x,y].ti<3) and (tempkart^[x,y].ti>0) then tempkart^[x,y].ti:=1;}

        behind^ [spieler [num2].CX, spieler [num2].cy] := 4; {Ziel}
        behind^ [spieler [num2].AX, spieler [num2].ay] := 3; {Start}

        For long := 0 To 99 Do Begin
          {#1}
          erfolg := False;
          For X := 0 To kartex Do
            For Y := 0 To kartey Do
              If behind^[x,y] = 10 Then Begin
              erfolg := True;
              behind^[x,y] := 3;
              End;

          For X := 1 To kartex-1 Do
            {#2} For Y := 1 To kartey-1 Do Begin
              {#3} If behind^[x,y] = 3 Then Begin
                For mx := - 1 To 1 Do
                  For my := - 1 To 1 Do
                    {#4}    If (X + mx >= 0) And (Y + my >= 0) And (X + mx <= 99) And (Y + my <= 99) Then Begin

                      If (behind^ [X + mx, Y + my] = 0) Then Begin
                        behind^ [X + mx, Y + my] := 10;
                        tempkart^ [X + mx, Y + my].kx := mx;
                        tempkart^ [X + mx, Y + my].ky := my;
                      End;

                      {#5}  If (behind^ [X + mx, Y + my] = 4) Then Begin {Da!}
                        tempkart^ [X + mx, Y + my].kx := mx;
                        tempkart^ [X + mx, Y + my].ky := my;
                        t3 := spieler [num2].CX;
                        t4 := spieler [num2].cy;

                        For tx := long Downto 0 Do Begin
                          spieler [num2].weg [tx].kx := tempkart^ [t3, t4].kx;
                          spieler [num2].weg [tx].ky := tempkart^ [t3, t4].ky;
                          Dec (t3, spieler [num2].weg [tx].kx);
                          Dec (t4, spieler [num2].weg [tx].ky);
                        End;
                        spieler [num2].weglong := long;
                        FreeMem (tempkart, Size shl 1);
                        FreeMem (behind, Size);
                        spieler [num2].go := True;
                        Exit;
                        {@5}
                      End;

                      {@4}
                    End;
                behind^ [X, Y] := 1;

                {@3}
              End;

            End;
          {@2}
          If (erfolg = False) And (long > 98) Then Begin
            findway:=1;
            error (1);
            stop (num2);
            FreeMem (tempkart,size shl 1);
            FreeMem (behind, Size);
            Exit;
          End;
        End;
        {@1}
        findway:=1;
        error (1); stop (num2);
      End;
  End;

Procedure suche (num2: LongInt);
 {Moegliche Optimierung: Annaehrung von Start und Ziel}
  Type
    tempkarttyp = Array [0..kartex, 0..kartey] Of Record
                                            kx, ky: ShortInt;
                                          End;
    behinderung = array[0..kartex,0..kartey] of byte;
  Var
    num7, yyy, kkk, mx, my, long, tx, ty, X, Y, X1, Y1, t3, t4: Integer;
    erfolg: Boolean;
    tempkart:^tempkarttyp;
    behind:^behinderung;
    size:longint;
  Begin
    size:=(kartex+1)*(kartey+1);
    error (0);
    findway:=0;
    GetMem (tempkart, Size shl 1);
    GetMem (behind, Size);
    spieler [num2].go := False;
    FillChar (tempkart^, Size shl 1, 0);
    FillChar (behind^, Size, 0);
    move(besetzt,behind^,size);
{    for kkk:=0 to anzmann do behind^[spieler[kkk].ax,spieler[kkk].ay]:=2; {Feld von Spieler besetzt}

{    For yyy := 0 To kartey Do
      For kkk := 0 To kartex Do Begin
        num7 := readmem32b (Ptr48 (karte, 1 + screeny100 [1] ) );
        If (num7 < 4) Or (num7 > 7) Or (readmem32b (Ptr48 (gebirge, kkk + screeny100 [yyy] ) ) > 0) Then
          behind^ [kkk, yyy] := 1;
      End;

    {  for yyy:=1 to hanz do begin
    tempkart^[haus[yyy].x,haus[yyy].y].ti:=yyy+20;
    tempkart^[haus[yyy].x+1,haus[yyy].y].ti:=yyy+20;
    end;}
    If ( (gox = spieler [num2].CX) And (goy = spieler [num2].cy) ) Then begin findway:=4;error (4);end
    Else
{      If (behind^[gox,goy] > 0) And (behind^[gox,goy] < 3) Then begin
            error (2);
            stop (num2);
            FreeMem (tempkart, Size shl 1);
            FreeMem (behind, Size);
            Exit;
           end
      Else}
      Begin
        spieler [num2].CX := gox;
        spieler [num2].cy := goy;
        spieler [num2].wegp := 0;
        FillChar (spieler [num2].weg, 200, 0);
        If (Abs (spieler [num2].CX - spieler [num2].AX) <= 1) And (Abs (spieler [num2].cy - spieler [num2].ay) <= 1) Then
        Begin {Ziel nur 1 Feld entfernt...}
          spieler [num2].weglong := 0;
          spieler [num2].go := True;
          spieler [num2].weg [0].kx := spieler [num2].CX - spieler [num2].AX;
          spieler [num2].weg [0].ky := spieler [num2].cy - spieler [num2].ay;
          FreeMem (tempkart, size shl 1);
          FreeMem (behind, Size);
          Exit;
        End;
        {  for x:=0 to maxx do
        for y:=0 to maxy do
        if (tempkart^[x,y].ti<3) and (tempkart^[x,y].ti>0) then tempkart^[x,y].ti:=1;}

        behind^ [spieler [num2].CX, spieler [num2].cy] := 4; {Ziel}
        behind^ [spieler [num2].AX, spieler [num2].ay] := 3; {Start}

        For long := 0 To 99 Do Begin
          {#1}
          erfolg := False;
          For X := 0 To kartex Do
            For Y := 0 To kartey Do
              If behind^[x,y] = 10 Then Begin
              erfolg := True;
              behind^[x,y] := 3;
              End;

          For X := 1 To kartex-1 Do
            {#2} For Y := 1 To kartey-1 Do Begin
              {#3} If behind^[x,y] = 3 Then Begin
                For mx := - 1 To 1 Do
                  For my := - 1 To 1 Do
                    {#4}    If (X + mx >= 0) And (Y + my >= 0) And (X + mx <= 99) And (Y + my <= 99) Then Begin

                      If (behind^ [X + mx, Y + my] = 0) Then Begin
                        behind^ [X + mx, Y + my] := 10;
                        tempkart^ [X + mx, Y + my].kx := mx;
                        tempkart^ [X + mx, Y + my].ky := my;
                      End;

                      {#5}  If (behind^ [X + mx, Y + my] = 4) Then Begin {Da!}
                        tempkart^ [X + mx, Y + my].kx := mx;
                        tempkart^ [X + mx, Y + my].ky := my;
                        t3 := spieler [num2].CX;
                        t4 := spieler [num2].cy;

                        For tx := long Downto 0 Do Begin
                          spieler [num2].weg [tx].kx := tempkart^ [t3, t4].kx;
                          spieler [num2].weg [tx].ky := tempkart^ [t3, t4].ky;
                          Dec (t3, spieler [num2].weg [tx].kx);
                          Dec (t4, spieler [num2].weg [tx].ky);
                        End;
                        spieler [num2].weglong := long;
                        FreeMem (tempkart, Size shl 1);
                        FreeMem (behind, Size);
                        spieler [num2].go := True;
                        Exit;
                        {@5}
                      End;

                      {@4}
                    End;
                behind^ [X, Y] := 1;

                {@3}
              End;

            End;
          {@2}
          If (erfolg = False) And (long > 98) Then Begin
            findway:=1;
            error (1);
            stop (num2);
            FreeMem (tempkart,size shl 1);
            FreeMem (behind, Size);
            Exit;
          End;
        End;
        {@1}
        findway:=1;
        error (1); stop (num2);
      End;
  End;

 Procedure gotoxye (gox, goy, num7: LongInt);
   Var r, rx, ry, rx1, ry1: LongInt;
  Begin
{    stop (num7,false);}
    If (gox <= 0) Or (gox >= kartex) Or (goy <= 0) Or (goy >= kartey) Or (num7 < 0) Or (num7 > anzmann) Then Exit;
    findway (gox, goy, num7);
    With spieler [num7] Do Begin
      px := 0;
      py := 0;
      richtung := kompass (weg [wegp].kx, weg [wegp].ky);
      rx := AX; ry := ay;
    End;
  End;


procedure fill_besetzt;
var kkk:integer;
begin
fillchar(besetzt,(kartex+1)*(kartey+1),0);
for kkk:=0 to anzmann do with spieler[kkk] do if (ax>0) and (ay>0) then begin
 besetzt[ax,ay]:=2;
 if wait=0 then besetzt[ax+weg[wegp].kx,ay+weg[wegp].ky]:=2;
end;
for xx:=0 to kartex do for yy:=0 to kartey do begin
 inhalt:=readmem32b(ptr48(karte,xx+screeny100[yy]));
 if (inhalt>=12) and (inhalt<=15) then besetzt[xx,yy]:=5; {Wasser}
end;

end;

procedure waitnow(num1:longint);
begin
 spieler[num1].wait:=64;
end;

Procedure weiter_feld (num1: LongInt);
Begin
  With spieler [num1] Do Begin
    px := weg [wegp + 1].kx;
    py := weg [wegp + 1].ky;
    Inc (AX, weg [wegp].kx);
    Inc (ay, weg [wegp].ky);
    Inc (wegp);
    If wegp > weglong Then Begin
     if goeat then gotoxye(sx,sy,num1) else stop(num1);
     Exit;
    End;
    richtung := kompass (weg [wegp].kx, weg [wegp].ky);
    if besetzt[ax+px,ay+py]>0 then waitnow(num1);
  End;
End;

Procedure weiter_schritt;
Begin
  For xx := 0 To anzmann Do If spieler [xx].go Then With spieler [xx] Do
    If (Abs (px) < 16) And (Abs (py) < 16) Then Begin
     if wait>0 then begin
      if wait>1 then begin if besetzt[ax+weg[wegp].kx,ay+weg[wegp].ky]>0 then dec(wait) else wait:=0;end else begin
      wait:=0;
      if besetzt[ax+weg[wegp].kx,ay+weg[wegp].ky]>0 then gotoxye(cx,cy,xx);
      end;
      end else begin
      {      if (readmem32b(ptr48(hoehe,ax+screeny100[ay]))=18) or (readmem32b(ptr48(hoehe,ax+screeny100[ay]))=38) then begin
      if blocker then blocker:=false else blocker:=true;
      end else blocker:=false;
      if blocker=false then begin}
      Inc (phase); If phase > 7 Then phase := 0;
      Inc (px, weg [wegp].kx); Inc (py, weg [wegp].ky);
      end;
    End
  Else weiter_feld (xx);
End;

Begin
  error (0);
End.