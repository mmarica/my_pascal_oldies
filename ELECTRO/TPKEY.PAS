{ TPKEY.PAS - Simplified version of unit Crt }

Unit TPKey;

Interface

Const
  Black        = 0;
  Blue         = 1;
  Green        = 2;
  Cyan         = 3;
  Red          = 4;
  Magenta      = 5;
  Brown        = 6;
  LightGray    = 7;
  DarkGray     = 8;
  LightBlue    = 9;
  LightGreen   = 10;
  LightCyan    = 11;
  LightRed     = 12;
  LightMagenta = 13;
  Yellow       = 14;
  White        = 15;
  Blink        = 128;

Var
  LastMode     : Word;

Procedure ClrScr;
Procedure Delay(time : Word);
Procedure Sound(pitch : Word);
Procedure NoSound;
Function KeyPressed : Boolean;
Function ReadKey : Char;
Function WhereXY : Word;
Procedure GotoXY(x, y : Byte);

Implementation

{$R-,S-,I-
 ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  Unit TPKey ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³   Procedures description:                                              ³
 ³   Delay                   Delay Time miliseconds                       ³
 ³   Sound                   Emit sound of Pitch Hertz                    ³
 ³   NoSound                 Switch off speaker                           ³
 ³   KeyPressed              True if keystroke entered                    ³
 ³   ReadKey                 Return keystroke                             ³
 ³   GotoXY                  Locate cursor at column x, row y             ³
 ³   ClrScr                  Clears whole screen                          ³
 ³   WhereXY                 Return cursor location                       ³
 ³                                                                        ³
 ³  Note that the active window is always the whole screen.               ³
 ³                                                                        ³
 ³  (c) Wilbert van Leijen, 1989-92                                       ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ }

Const
  Timer0       = $40;                  { 8253 Timer 0 (Ticker timer) }
  CtrlWord     = $43;                  { 8253 Control Word }
  Mode2        = $34;                  { Free running 16-bit counter }
  TickLength   = 55;                   { Tick length = 55 ms }
  TickAddr     = $46C;                 { Lower word in BIOS data area }
  MiliSec      = 1192;                 { Number of Timer 0 cycles in 1 ms }
  Speaker      = $61;                  { Speaker port }

Var
  Scancode        : Char;                { Extended keystroke character }
  BIOSVideoMode : Byte absolute $0000:$0449;

{ Clear screen (does not home cursor or preserve screen colour }

Procedure ClrScr; Assembler;

ASM
        XOR     CX, CX
        MOV     DX, 1850h
        XOR     BH, BH
        MOV     AX, 0600h
        INT     10h
end;  { ClrScr }

{ Return cursor location }

Function WhereXY; Assembler;

ASM
        XOR     BH, BH
        MOV     AH, 3
        INT     10h
        INC     DX
        INC     DH
        XCHG    DH, DL
        XCHG    DX, AX
end;  { WhereXY }

{ Locate cursor }

Procedure GotoXY; Assembler;

ASM
        MOV     DH, y
        MOV     DL, x
        DEC     DX
        DEC     DH
        XOR     BX, BX
        MOV     AH, 2
        INT     10h
end;  { GotoXY }

{ Read out the current value of the timer 0 }

Procedure ReadTimer; Assembler;

ASM
        IN     AL, Timer0
        XOR    AH, AH
        MOV    DX, AX
        IN     AL, Timer0
        XCHG   AH, AL
        ADD    AX, DX
end;  { ReadTimer }

{ Timed delay function }

Procedure Delay; Assembler;

ASM
    { Clear DX to prevent divide overflow.
      Devide DelayTime in ticks (blocks of 55 ms).
      Store the offset in ticks in OfsTicks.       }

        XOR     DX, DX
        MOV     AX, time
        MOV     CX, TickLength
        DIV     CX
        MOV     BX, AX

    { Reset timer for the sake of accuracy }

        MOV     AL, Mode2
        OUT     CtrlWord, AL
        XOR     AX, AX
        OUT     Timer0, AL
        OUT     Timer0, AL

    { Get the current value of the ticker timer at address 0000h:046Ch }

        MOV     ES, AX
        MOV     DI, TickAddr
        MOV     AX, ES:[DI]
        ADD     AX, BX
        MOV     SI, AX

    { Repeat
      Until ticker timer value = SI; }

@1:     MOV     AX, ES:[DI]
        CMP     AX, SI
        JNZ     @1

    { Calculate remainder of delay time in cycles of Timer 0.
      1192 cycles = 0.001 seconds
      SI = (current value of Timer 0) - (1192*(DelayTime mod 55)); }

        XCHG   AX, DX
        MOV    CX, MiliSec
        MUL    CX
        MOV    BX, AX
        CALL   ReadTimer
        SUB    AX, BX
        MOV    SI, AX

    { Repeat }

@2:     CALL   ReadTimer
        CMP    AX, SI
        JNB    @2

    { Until Timer 0 value < SI }

end;  { Delay }

Procedure Sound; Assembler;

Const
  FreqHi       = $34DD;                { DX:AX division constant }
  FreqLo       = $12;
  ModeSelect   = $0B6;                 { Enable speaker }
  On           = 3;                    { Speaker on mask }
  Timer2       = $42;                  { 8253 Timer 2 }
  Control      = $43;                  { 8253 Control word }

ASM
        MOV    BX, pitch
        MOV    AX, FreqHi
        MOV    DX, FreqLo
        CMP    DX, BX
        JNB    @2
        DIV    BX
        MOV    BX, AX
        IN     AL, Speaker
        TEST   AL, 3
        JNZ    @1
        OR     AL, 3
        OUT    Speaker, AL
        MOV    AL, ModeSelect
        OUT    Control, AL
@1:     MOV    AL, BL
        OUT    Timer2, AL
        MOV    AL, BH
        OUT    Timer2, AL
@2:
end;  { Sound }

{ Switch off the internal speaker }

Procedure NoSound; Assembler;

Const
  Off          = $FC;                  { Speaker off mask }

ASM
        IN     AL, Speaker
        AND    AL, Off
        OUT    Speaker, AL
end;  { NoSound }

{ Returns True if keystroke is pending }

Function KeyPressed : Boolean; Assembler;

ASM
        CMP    [Scancode], 0
        JNE    @1
        MOV    AH, 1
        INT    16h
        MOV    AL, False
        JZ     @2
@1:     MOV    AL, True
@2:
end;  { KeyPressed }

Function ReadKey; Assembler;

ASM
        XOR    AX, AX
        MOV    AL, [Scancode]
        OR     AL, AL
        JNZ    @1

        INT    16h
        OR     AL, AL
        JNZ    @2
@1:     MOV    [Scancode], AH
@2:
end;  { ReadKey }

Begin  { TPKey }
  ASM
        MOV    AH, 0Fh
        INT    10h
        XOR    AH, AH
        MOV    [LastMode], AX
  end;
end.  { TPKey }