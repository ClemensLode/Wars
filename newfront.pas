unit NewFrontier;

{ New Frontier  Version 6.00  09.09.1995  Dietmar Meschede }
{ New Frontier  Version 6.02  20.08.1996  Mark Iuzzolino   }
{ New Frontier  Version 6.03  11.07.1997  Mark Iuzzolino   }
{                                                          }
{ Copyright (c) 1993,1995 Dietmar Meschede                 }
{ Slight modifications by Mark Iuzzolino                   }
{                                                          }
{ Use at OWN risk!                                         }

{ BP 7.0 protected mode 32 bit DPMI support unit. }

{$DEFINE PROTECTED}
{$IFDEF PROTECTED} {$IFNDEF DPMI}
  -->  Error:  Target must be Protected Mode!              <--
{$ENDIF} {$ENDIF}

{$A+,B-,D-,E-,F-,G+,I-,K+,L-,N-,O-,P-,Q-,R-,S+,T+,V+,W+,X+,Y-}

{$IFDEF PROTECTED} {$DEFINE P386} {$ENDIF}

interface

uses
  WinAPI;

type
  TPtr        = record
                  Ofs, Seg: Word;
                end;
  TSelector   = Word;
  TOffset32   = Longint;
  Pointer48   = Real;
  TSelOfs32   = record
                  Offset32: TOffset32;
                  Selector: TSelector;
                end;
  TDescriptor = record
                  SegmentLimit0: Word;
                  BaseAddress0 : Word;
                  BaseAddress1 : Byte;
                  Flags0       : Byte;
                  Flags1       : Byte;
                  BaseAddress2 : Byte;
                end;

function AllocateDescriptor(No: Word): TSelector;
procedure FreeDescriptor(Selector: TSelector);

function SetSegmentBaseAddress(Selector: TSelector; Base: Longint): Boolean;
function SetSegmentLimit(Selector: TSelector; Limit: Longint): Boolean;

function GetSegmentAccessRights(Selector: TSelector): Word;
function SetSegmentAccessRights(Selector: TSelector; Rights: Word): Boolean;

procedure SetDescriptorLimit(var Descr: TDescriptor; Limit: LongInt);

function CreateDescriptor(Base, Limit: Longint): TSelector;
function CreateCodeDescriptor(Base, Limit: Longint): TSelector;

function CreateAliasDescriptor(Selector: TSelector): TSelector;

function GetDescriptor(Selector: TSelector; var Descr: TDescriptor): Boolean;
function SetDescriptor(Selector: TSelector; var Descr: TDescriptor): Boolean;

function CreateCode32Alias(Selector: TSelector): TSelector;
function CreateData32Alias(Selector: TSelector): TSelector;

function PhysicalAddressMapping(Address, Size: Longint): Longint;
function FreePhysicalAddressMapping(LinearAddress: Longint): Boolean;

function MaxAvail32: Longint;
function MemAvail32: Longint;

procedure GetMem32(var Selector: TSelector; Size: Longint);
procedure FreeMem32(var Selector: TSelector);

procedure Move32(Source, Dest: Pointer48; Count: Longint);

procedure FillChar32(P: Pointer48; Count: Longint; Value: Byte);
procedure FillWord32(P: Pointer48; Count: Longint; Value: Word);
procedure FillLong32(P: Pointer48; Count: Longint; Value: Longint);

procedure BlockReadWrite32(var F: file; SourceDest: Pointer48; Count: Longint;
                           var Result: Longint; Write: Boolean);

procedure BlockRead32(var F: file; P: Pointer48; Count: Longint; var Result: Longint);
procedure BlockWrite32(var F: file; P: Pointer48; Count: Longint; var Result: Longint);

function BLoadSave32(Name: string; P: Pointer48; Count: Longint; Write: Boolean): Boolean;

function BLoad32(Name: string; P: Pointer48; Count: Longint): Boolean;
function BSave32(Name: string; P: Pointer48; Count: Longint): Boolean;

function MapRealPointer(P: Pointer): Pointer48;

function Ptr48(Selector: TSelector; Offset32: TOffset32): Pointer48;
  inline($58/           { POP AX }
         $5B/           { POP BX }
         $5A            { POP DX }
        );

function Seg48(P: Pointer48): TSelector;
  inline($58/           { POP AX }
         $58/           { POP AX }
         $58            { POP AX }
        );

function Ofs48(P: Pointer48): TOffset32;
  inline($58/           { POP AX }
         $5A/           { POP DX }
         $5B);          { POP BX }

function FarPtr(P: Pointer): Pointer48;
  inline($58/           { POP AX    }
         $31/$DB/       { XOR BX,BX }
         $5A            { POP DX    }
        );

function ReadMem32B(P: Pointer48): Byte;
  inline($66/$5E/               { POP  ESI          }
         $07/                   { POP  ES           }
         $26/$67/$8A/$06        { MOV  AL,[ES:ESI]  }
        );

function ReadMem32W(P: Pointer48): Word;
  inline($66/$5E/               { POP  ESI          }
         $07/                   { POP  ES           }
         $26/$67/$8B/$06        { MOV  AX,[ES:ESI]  }
        );

function ReadMem32L(P: Pointer48): Longint;
  inline($66/$5E/               { POP  ESI          }
         $07/                   { POP  ES           }
         $66/$26/$67/$8B/$06/   { MOV  EAX,[ES:ESI] }
         $8B/$D0/               { MOV  DX,AX        }
         $66/$C1/$E8/$10/       { SHR  EAX,16       }
         $92                    { XCHG AX,DX        }
        );

function ReadMem32R(P: Pointer48): Real;
  inline($66/$5E/               { POP  ESI          }
         $07/                   { POP  ES           }
         $26/$67/$8B/$06/       { MOV  AX,[ES:ESI]  }
         $26/$67/$8B/$5e/$02/   { MOV  BX,[ES:ESI+2]}
         $26/$67/$8B/$56/$04    { MOV  DX,[ES:ESI+4]}
        );

procedure WriteMem32B(P: Pointer48; Value: Byte);
  inline($58/                   { POP  AX           }
         $66/$5F/               { POP  EDI          }
         $07/                   { POP  ES           }
         $26/$67/$88/$07        { MOV  [ES:EDI],AL  }
        );

procedure WriteMem32W(P: Pointer48; Value: Word);
  inline($58/                   { POP  AX           }
         $66/$5F/               { POP  EDI          }
         $07/                   { POP  ES           }
         $26/$67/$89/$07        { MOV  [ES:EDI],AX  }
        );

procedure WriteMem32L(P: Pointer48; Value: Longint);
  inline($66/$58/               { POP  EAX          }
         $66/$5F/               { POP  EDI          }
         $07/                   { POP  ES           }
         $66/$26/$67/$89/$07    { MOV  [ES:EDI],EAX }
        );

procedure WriteMem32R(P: Pointer48; Value: Real);
  inline($58/                   { pop  ax           }
         $5B/                   { pop  bx           }
         $5A/                   { pop  dx           }
         $66/$5f/               { pop  edi          }
         $07/                   { pop  es           }
         $26/$67/$89/$07/       { MOV  [ES:EDI],AX  }
         $26/$67/$89/$5f/$02/   { mov  [es:edi+2],bx}
         $26/$67/$89/$57/$04    { mov  [es:edi+4],dx}
        );

procedure IncMem32b(P:pointer48; value:byte);
  inline($58/                   { pop  ax           }
         $66/$5f/               { pop  edi          }
         $07/                   { pop  es           }
         $26/$67/$00/$07        { add  es:[edi],al  }
        );

procedure IncMem32w(P:Pointer48; value:word);
  inline($58/                   { pop  ax           }
         $66/$5f/               { pop  edi          }
         $07/                   { pop  es           }
         $26/$67/$01/$07        { add  es:[edi],ax  }
        );

procedure IncMem32L(P:Pointer48; value:longint);
  inline($66/$58/               { pop  eax          }
         $66/$5f/               { pop  edi          }
         $07/                   { pop  es           }
         $66/$26/$67/$01/$07    { add  es:[edi],eax }
        );

procedure DecMem32b(P:pointer48; value:byte);
  inline($58/                   { pop  ax           }
         $66/$5f/               { pop  edi          }
         $07/                   { pop  es           }
         $26/$67/$28/$07        { sub  es:[edi],al  }
        );

procedure DecMem32w(P:Pointer48; value:word);
  inline($58/                   { pop  ax           }
         $66/$5f/               { pop  edi          }
         $07/                   { pop  es           }
         $26/$67/$29/$07        { sub  es:[edi],ax  }
        );

procedure DecMem32L(P:Pointer48; value:longint);
  inline($66/$58/               { pop  eax          }
         $66/$5f/               { pop  edi          }
         $07/                   { pop  es           }
         $66/$26/$67/$29/$07    { sub  es:[edi],eax }
        );

var
  LowMem: TSelector;

implementation

const
  DPMI = $31;   { Interruptnumber for DPMI functions }

{ export }
function AllocateDescriptor(No: Word): TSelector; assembler;
asm
        MOV     AX,$0000                { Allocate LDT Descriptor }
        MOV     CX,[No]
        OR      CX,CX
        JE      @@End
        INT     DPMI
        JNC     @@End
        XOR     AX,AX
@@End:
end; { AllocateDescriptor }

{ export }
procedure FreeDescriptor(Selector: TSelector); assembler;
asm
        MOV     AX,$0001                { Free LDT Descriptor }
        MOV     BX,[Selector]
        OR      BX,BX
        JE      @@End
        INT     DPMI
@@End:
end; { FreeDescriptor }

procedure SetDescriptorBaseAddress(var Descr: TDescriptor; Base: Longint);
begin
  with Descr do begin
    BaseAddress0 := Word(Base);
    BaseAddress1 := Byte(Base shr 16);
    BaseAddress2 := Byte(Base shr 24);
  end; { with }
end; { SetDescriptorBaseAddress }

{ export }
function SetSegmentBaseAddress(Selector: TSelector; Base: Longint): Boolean;
var
  Descr: TDescriptor;
begin
  SetSegmentBaseAddress := False;
  if Selector = 0 then Exit;
  if not GetDescriptor(Selector, Descr) then Exit;
  SetDescriptorBaseAddress(Descr, Base);
  SetSegmentBaseAddress := SetDescriptor(Selector, Descr);
end; { SetSegmentBaseAddress }

procedure SetDescriptorLimit(var Descr: TDescriptor; Limit: LongInt);
begin
  with Descr do begin
    if Limit > 0 then Dec(Limit);
    if Limit >= $100000 then begin      { > 1MB ? }
      Limit  := Limit shr 12;
      Flags1 := Flags1 or $80;          { Granularity = 4KB }
    end; { if }
    SegmentLimit0 := Word(Limit);
    Flags1 := Flags1 or Byte(Limit shr 16);
  end; { with }
end; { SetSegmentLimit }

{ export }
function SetSegmentLimit(Selector: TSelector; Limit: Longint): Boolean;
var
  Descr: TDescriptor;
begin
  SetSegmentLimit := False;
  if Selector = 0 then Exit;
  if not GetDescriptor(Selector, Descr) then Exit;
  SetDescriptorLimit(Descr, Limit);
  SetSegmentLimit := SetDescriptor(Selector, Descr);
end; { SetSegmentLimit }

{ export }
function GetSegmentAccessRights(Selector: TSelector): Word;
var
  Descr: TDescriptor;
begin
  if GetDescriptor(Selector, Descr) then
    GetSegmentAccessRights := (Word(Descr.Flags1) shl 8) or Descr.Flags0
  else GetSegmentAccessRights := 0;
end; { GetSegmentAccessRights }

procedure SetDescriptorAccessRights(var Descr: TDescriptor; Rights: Word);
begin
  with Descr do begin
    Flags0 := Byte(Rights);
    Flags1 := Byte(Rights shr 8);
  end; { with }
end; { SetDescriptorAccressRights }

{ export }
function SetSegmentAccessRights(Selector: TSelector; Rights: Word): Boolean;
var
  Descr: TDescriptor;
begin
  SetSegmentAccessRights := False;
  if Selector = 0 then Exit;
  if not GetDescriptor(Selector, Descr) then Exit;
  SetDescriptorAccessRights(Descr, Rights);
  SetSegmentAccessRights := SetDescriptor(Selector, Descr);
end; { SetSegmentAccessRights }

{ export }
function CreateDescriptor(Base, Limit: Longint): TSelector;
var
  Selector: TSelector; Descr: TDescriptor;
begin
  CreateDescriptor := 0;
  Selector := AllocateDescriptor(1);
  if Selector <> 0 then begin
    if not GetDescriptor(Selector, Descr) then Exit;
    SetDescriptorBaseAddress(Descr, Base);
    SetDescriptorLimit(Descr, Limit);
    Descr.Flags1 := Descr.Flags1 and $BF;               { 16-Bit-Segment }
    if not SetDescriptor(Selector, Descr) then Exit;
  end; { if }
  CreateDescriptor := Selector;
end; { CreateDescriptor }

{ export }
function CreateCodeDescriptor(Base, Limit: Longint): TSelector;
var
  Selector: TSelector; Descr: TDescriptor;
begin
  CreateCodeDescriptor := 0;
  Selector := AllocateDescriptor(1);
  if Selector <> 0 then begin
    if not GetDescriptor(Selector, Descr) then Exit;
    SetDescriptorBaseAddress(Descr, Base);
    SetDescriptorLimit(Descr, Limit);
    Descr.Flags0 := (Descr.Flags0 and $FB) or $0A;    { no conforming, code segment, readable }
    Descr.Flags1 := Descr.Flags1 and $BF;             { 16-Bit-Segment }
    if not SetDescriptor(Selector, Descr) then Exit;
  end; { if }
  CreateCodeDescriptor := Selector;
end; { CreateCodeDescriptor }

{ export }
function CreateAliasDescriptor(Selector: TSelector): TSelector; assembler;
asm
        MOV     AX,$000A        { Create Code Segment Alias Descriptor }
        MOV     BX,[Selector]
        INT     DPMI
        JNC     @@End
        XOR     AX,AX
@@End:
end; { CreateAliasDescriptor }

{ export }
function GetDescriptor(Selector: TSelector; var Descr: TDescriptor): Boolean; assembler;
asm
        MOV     AX,$000B        { Get Descriptor (LDT) }
        MOV     BX,[Selector]
        LES     DI,[Descr]
        INT     DPMI
        MOV     AX,False
        JC      @@End
        MOV     AX,True
@@End:
end; { GetDescriptor }

{ export }
function SetDescriptor(Selector: TSelector; var Descr: TDescriptor): Boolean; assembler;
asm
        MOV     AX,$000C        { Set Descriptor (LDT) }
        MOV     BX,[Selector]
        OR      BX,BX
        JE      @@End
        LES     DI,[Descr]
        INT     DPMI
        MOV     AX,False
        JC      @@End
        MOV     AX,True
@@End:
end; { SetDescriptor }

{ export }
function CreateCode32Alias(Selector: TSelector): TSelector;
var
  Descr: TDescriptor;
begin
  Selector := CreateAliasDescriptor(Selector);
  if Selector <> 0 then begin
    GetDescriptor(Selector, Descr);
    with Descr do begin
      Flags1 := Flags1 or $40;                  { 32-Bit-Segment }
      Flags0 := (Flags0 and $F0) or $0B;        { Code Segment   }
    end; { with }
    SetDescriptor(Selector, Descr);
  end; { if }
  CreateCode32Alias := Selector;
end; { CreateCode32Alias }

{ export }
function CreateData32Alias(Selector: TSelector): TSelector;
var
  NewSelector: TSelector; Descr: TDescriptor;
begin
  NewSelector := AllocateDescriptor(1);
  if NewSelector <> 0 then begin
    GetDescriptor(Selector, Descr);
    with Descr do begin
      Flags1 := Flags1 or $40;                  { 32-Bit-Segment }
      Flags0 := (Flags0 and $F0) or $03;        { Data Segment   }
    end; { with }
    SetDescriptor(NewSelector, Descr);
  end; { if }
  CreateData32Alias := NewSelector;
end; { CreateCode32Alias }

{ export }
function PhysicalAddressMapping(Address, Size: Longint): Longint; assembler;
asm
        MOV     AX,$0800                        { Physical Address Mapping }
        MOV     CX,WORD [Address]
        MOV     BX,WORD [Address+2]
        MOV     DI,WORD [Size]
        MOV     SI,WORD [Size+2]
        INT     DPMI
        MOV     AX,CX
        MOV     DX,BX
        JNC     @@End
        XOR     AX,AX
        XOR     DX,DX
@@End:
end; { PhysicalAddressMapping }

{ export }
function FreePhysicalAddressMapping(LinearAddress: Longint): Boolean; assembler;
asm
        MOV     AX,$0801                        { Free Physical Address Mapping }
        MOV     CX,WORD [LinearAddress]
        MOV     BX,WORD [LinearAddress+2]
        INT     DPMI
        MOV     AX,False
        JC      @@End
        MOV     AX,True
@@End:
end; { FreePhysicalAddressMapping }

{ export }
function MaxAvail32: Longint;
begin
  MaxAvail32 := GlobalCompact(0);
end; { MaxAvail32 }

{ export }
function MemAvail32: Longint;
begin
  MemAvail32 := GetFreeSpace(0);
end; { MemAvail32 }

{ export }
procedure GetMem32(var Selector: TSelector; Size: Longint);
var
  P: Pointer; SelectorNo: Word; Base: Longint;
  Ok: Boolean; i: Word; Descr: TDescriptor;
begin
  P := GlobalAllocPtr(gmem_Fixed, Size);
  if (P <> nil) and (Ofs(P^) = 0) then begin
    Ok := True;
    Selector := Seg(P^);
    Base := GetSelectorBase(Selector);
    SelectorNo := Size div $10000;
    if (Size mod $10000) <> 0 then Inc(SelectorNo);
    for i := 1 to SelectorNo-1 do begin
      Inc(Base, $10000);
      if Base <> GetSelectorBase(Selector+SelectorInc*i) then begin
        Ok := False; Break;
      end; { if }
    end; { for }
    ok:=true;
    if Ok then begin
      GetDescriptor(Selector, Descr);
      SetDescriptorLimit(Descr, Size);
      Descr.Flags1 := Descr.Flags1 and $BF;     { 16-Bit-Segment }
      SetDescriptor(Selector, Descr);
    end; { if }
    if not Ok then begin
      GlobalFreePtr(P);
      Selector := 0;
    end; { if }
  end { if }
  else Selector := 0;
end; { GetMem32 }

{ export }
procedure FreeMem32(var Selector: TSelector);
begin
  if Selector <> 0 then begin
    GlobalFreePtr(Ptr(Selector, 0));
    Selector := 0;
  end; { if }
end; { FreeMem32 }

{ export }
{$L newfront}

procedure Move32(Source, Dest: Pointer48; Count: Longint); external;
procedure FillChar32(P: Pointer48; Count: Longint; Value: Byte); external;
procedure FillWord32(P: Pointer48; Count: Longint; Value: Word); external;
procedure FillLong32(P: Pointer48; Count: Longint; Value: Longint); external;

{ export }
procedure BlockReadWrite32(var F: file; SourceDest: Pointer48; Count: Longint;
                           var Result: Longint; Write: Boolean);
var
  i, Pages: Longint; Remainder, Tmp: Word; Buffer: Pointer;
begin
  Pages := Count div $8000; Remainder := Count mod $8000;
  Tmp := $8000; Result := 0;
  GetMem(Buffer, $8000);
  if Buffer = nil then Exit;
  for i := 1 to Pages do begin
    case Write of
      False: begin
               BlockRead(F, Buffer^, $8000, Tmp);
               Move32(FarPtr(Buffer), SourceDest, Tmp);
             end;
      True:  begin
               Move32(SourceDest, FarPtr(Buffer), $8000);
               BlockWrite(F, Buffer^, $8000, Tmp);
             end;
    end; { case }
    Inc(TSelOfs32(SourceDest).Offset32, $8000);
    Inc(Result, Tmp);
    if Tmp < $8000 then Break;
  end; { for }
  if (Tmp = $8000) and (Remainder > 0) then begin
    case Write of
      False: begin
               BlockRead(F, Buffer^, Remainder, Tmp);
               Move32(FarPtr(Buffer), SourceDest, Tmp);
             end;
      True:  begin
               Move32(SourceDest, FarPtr(Buffer), Remainder);
               BlockWrite(F, Buffer^, Remainder, Tmp);
             end;
    end; { case }
    Inc(Result, Tmp);
  end; { if }
  FreeMem(Buffer, $8000);
end; { BlockReadWrite32 }

{ export }
procedure BlockRead32(var F: file; P: Pointer48; Count: Longint; var Result: Longint);
begin
  BlockReadWrite32(F, P, Count, Result, False);
end; { BlockRead32 }

{ export }
procedure BlockWrite32(var F: file;P: Pointer48; Count: Longint; var Result: Longint);
begin
  BlockReadWrite32(F, P, Count, Result, True);
end; { BlockWrite32 }

{ export }
function BLoadSave32(Name: string; P: Pointer48; Count: Longint; Write: Boolean): Boolean;
var
  F: file; var Size, Result: Longint;
begin
  InOutRes := 0;
  BLoadSave32 := False;
  Assign(F, Name);
  case Write of
    False: Reset(F, 1);
    True:  Rewrite(F, 1);
  end; { case }
  if IOResult <> 0 then Exit;
  if not Write then begin
    Size := FileSize(F);
    if IOResult <> 0 then Exit;
  end; { if }
  BlockReadWrite32(F, P, Count, Result, Write);
  case Write of
    False: BLoadSave32 := (Result = Count) or (Result = Size);
    True:  BLoadSave32 := (Result = Count);
  end; { case }
  Close(F);
  if IOResult <> 0 then BLoadSave32 := False;
end; { BLoadSave32 }

{ export }
function BLoad32(Name: string; P: Pointer48; Count: Longint): Boolean;
begin
  BLoad32 := BLoadSave32(Name, P, Count, False);
end; { BLoad32 }

{ export }
function BSave32(Name: string; P: Pointer48; Count: Longint): Boolean;
begin
  BSave32 := BLoadSave32(Name, P, Count, True);
end; { BSave32 }

function MapRealPointer(P: Pointer): Pointer48;
var
  P48: TSelOfs32;
begin
 if LowMem <> 0 then
  begin
   P48.Selector := LowMem;
   P48.Offset32 := (Longint(TPtr(P).Seg) shl 4) + Longint(TPtr(P).Ofs);
   MapRealPointer := Pointer48(P48);
  end { if }
 else MapRealPointer := 0
end; { MapRealPointer }

var
  SaveExit: Pointer;

procedure NewFrontierExit; far;
begin
  ExitProc := SaveExit;
  FreeDescriptor(LowMem);
end; { NewFrontierExit }

begin
  SaveExit := ExitProc;
  ExitProc := @NewFrontierExit;
  LowMem := CreateDescriptor(0, $100000);
end. { unit NewFrontier }
