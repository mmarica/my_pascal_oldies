{$A+,B-,D+,E+,F-,G+,I+,L+,N-,O-,P-,Q-,R-,S+,T-,V+,X+}

(***************************************************************)
{								}
{	Turbo Pascal Mouse Interface, Version 1.0		}
{	Developed by Tanescu A. Horatiu				}
{	December 1996						}
{								}
(***************************************************************)


unit Mouse;


interface


{ Graphic cursor shape record used by SetGraphicCursor }

type
  TGraphicCursor = record
    HotSpotX, HotSpotY : Integer;
    Masks : array [0..1, 0..15] of Word;
  end;

{ Mouse installed flag }

const
  MouseInstalled : Boolean = False;

{ Number of buttons on the mouse }

var
  ButtonCount : Integer;

{ Mouse driver internal flag }

var
  MouseState : ShortInt;

{ Mouse buttons state variables }

var
  RightButtonPressed  : Boolean;
  LeftButtonPressed   : Boolean;
  CenterButtonPressed : Boolean;

{ Current position of the mouse }

var
  MouseX : Integer;
  MouseY : Integer;

{ Initializes mouse software and hardware }
function  InitMouse : Integer;

{ Shows the mouse cursor}
procedure ShowMouse;

{ Hides the mouse cursor }
procedure HideMouse;

{ Reads the position of the mouse and the state of the buttons }
procedure ReadMouse;

{ Places the mouse cursor at the specified position }
procedure MouseTo(const X, Y : Integer);

{ Returns the number of times a button was pressed since the last call }
function  GetMouseDown(const Button : Integer; var LastX, LastY : Integer) : Integer;

{ Returns the number of times a button was released since the last call }
function  GetMouseUp(const Button : Integer; var LastX, LastY : Integer) : Integer;

{ Sets the minimum and maximum coordinates for mouse movements }
procedure SetMouseRange(const MinX, MinY, MaxX, MaxY : Integer);

{ Defines the shape of the graphic mouse cursor }
procedure SetGraphicCursor(const NewShape : TGraphicCursor);

{ Defines the mouse cursor appearance in text modes }
procedure SetTextCursor(const ScreenMask, CursorMask : Word);

{ Selects the existing hardware cursor as the text mouse cursor }
procedure SetHardwareCursor(const FirstLn, LastLn : Word);

{ Returns the number of mickeys moved since last call }
procedure GetMouseMove(var X, Y : Integer);

{ Enables or disables the light pen emulation mode }
procedure SetLightPenEmulation(const LightPen : Boolean);

{ Defines the mickey/pixel ratio }
procedure SetMickeyRatio(const X, Y : Integer);

{ Defines a region where the mouse cursor will be hidden }
procedure HideMouseIn(const X1, Y1, X2, Y2 : Integer);

{ Defines a large graphic cursor block }
function  DefineGraphicCursor(const Width, Height, HotSpotX, HotSpotY : Byte; const Masks) : Integer;

{ Sets the mouse double speed threshold }
procedure SetMouseThreshold(const Threshold : Integer);

{ Returns the size of the buffer needed to store the mouse driver state }
function  DriverStateSize : Integer;

{ Saves the mouse driver state into a buffer }
procedure SaveDriverState(const Size : Integer; var Buf);

{ Restores the mouse driver state from a buffer }
procedure RestoreDriverState(const Size : Integer; const Buf);

{ Sets the mouse sensitivity and the double speed threshold }
procedure SetMouseSensitivity(const Horiz, Vert, Threshold : Integer);

{ Returns the mouse sensitivity and the double speed threshold }
procedure GetMouseSensitivity(var Horiz, Vert, Threshold : Integer);

{ Sets the display page number for the mouse cursor }
procedure SetMousePage(const Page : Integer);

{ Returns the display page number for the mouse cursor }
function  GetMousePage : Integer;

{ Initializes mouse software }
function  SoftwareReset : Integer;

{ Sets the language for the international version of the mouse driver }
procedure SetMouseLanguage(const Language : Integer);

{ Returns the language for the international version of the mouse driver }
function  GetMouseLanguage : Integer;

{ Returns the mouse driver version number }
function  MouseVersion : Integer;

{ Returns the mouse interrupt }
function  MouseIRQ : Byte;

{ Returns the mouse type: bus, serial, InPort, PS/2, HP }
function  MouseType : Byte;

{ Returns the mouse cursor type: text software, text hardware or graphic }
function  MouseCursor : Byte;

{ Returns the maximum coordinates for mouse movements }
procedure GetMouseMaxRange(var MaxX, MaxY : Integer);

{ Returns the shape of the text cursor }
procedure GetTextCursor(var ScreenMask, CursorMask : Word);

{ Returns the shape of the existing hardware cursor }
procedure GetHardwareCursor(var FirstLn, LastLn : Word);

{ Returns the mouse driver internal counter }
function  GetMouseState : ShortInt;

{ Returns the column of the hot spot }
function  GetMouseHotSpotX : Integer;

{ Returns the row of the hot spot }
function  GetMouseHotSpotY : Integer;

{ Returns the minimum X coordinate for mouse movements }
function  GetMouseMinX : Integer;

{ Returns the minimum Y coordinate for mouse movements }
function  GetMouseMinY : Integer;

{ Returns the maximum X coordinate for mouse movements }
function  GetMouseMaxX : Integer;

{ Returns the maximum Y coordinate for mouse movements }
function  GetMouseMaxY : Integer;

{ Returns the minimum and maximum coordinates for mouse movements }
procedure GetMouseRange(var MinX, MinY, MaxX, MaxY : Integer);

{ Converts a virtual X coordinate into a text coordinate }
function  TextX(const X : Integer) : Integer;

{ Converts a virtual Y coordinate into a text coordinate }
function  TextY(const Y : Integer) : Integer;

{ Converts a text Y coordinate into a virtual coordinate }
function  VirtualX(const X : Integer) : Integer;

{ Converts a text Y coordinate into a virtual coordinate }
function  VirtualY(const Y : Integer) : Integer;


implementation


var
  ScreenWidth  : Word absolute $0040:$004A;


procedure ButtonsState; assembler;
asm
	MOV	LeftButtonPressed, AL
	MOV	RightButtonPressed, AL
	MOV	CenterButtonPressed, AL
	AND	LeftButtonPressed, 0001H
	AND	RightButtonPressed, 0002H
	AND	CenterButtonPressed, 0004H
end;

function InitMouse : Integer; assembler;
asm
	MOV	AX, 0000H
	INT	33H
	CMP	AX, 0FFFFH
	JE	@@1
	MOV	MouseInstalled, 0
	JMP	@@2
@@1:	MOV	MouseInstalled, 1
@@2:	CMP	BX, 0FFFFH
	JNZ	@@3
	MOV	ButtonCount, 0002H
	JMP	@@4
@@3:	MOV	ButtonCount, BX
@@4:	MOV	MouseState, -1
end;

procedure ShowMouse; assembler;
asm
	MOV	AX, 0001H
	INT	33H
	CMP	MouseState, 0H
	JE	@@1
	INC	MouseState
@@1:
end;

procedure HideMouse; assembler;
asm
	MOV	AX, 0002H
	INT	33H
	CMP	MouseState, -128
	JE	@@1
	DEC	MouseState
@@1:
end;

procedure ReadMouse; assembler;
asm
	MOV	AX, 0003H
	INT	33H
	MOV	MouseX, CX
	MOV	MouseY, DX
	MOV	AX, BX
	CALL	ButtonsState
end;

procedure MouseTo(const X, Y : Integer); assembler;
asm
	MOV	AX, 0004H
	MOV	CX, X
	MOV	DX, Y
	INT	33H
	CALL	ReadMouse
end;

function GetMouseDown(const Button : Integer; var LastX, LastY : Integer) : Integer; assembler;
asm
	MOV	AX, 0005H
	MOV	BX, Button
	INT	33H
	CALL	ButtonsState
	LES	DI, LastX
	MOV	AX, CX
	STOSW
	LES	DI, LastY
	MOV	AX, DX
	STOSW
	MOV	AX, BX
end;

function GetMouseUp(const Button : Integer; var LastX, LastY : Integer) : Integer; assembler;
asm
	MOV	AX, 0006H
	MOV	BX, Button
	INT	33H
	CALL	ButtonsState
	LES	DI, LastX
	MOV	AX, CX
	STOSW
	LES	DI, LastY
	MOV	AX, DX
	STOSW
	MOV	AX, BX
end;

procedure SetMouseRange(const MinX, MinY, MaxX, MaxY : Integer); assembler;
asm
	MOV	AX, 0007H
	MOV	CX, MinX
	MOV	DX, MaxX
	INT	33H
	MOV	AX, 0008H
	MOV	CX, MinY
	MOV	DX, MaxY
	INT	33H
	CALL	ReadMouse
end;

procedure SetGraphicCursor(const NewShape : TGraphicCursor); assembler;
asm
	PUSH	DS
	LDS	SI, NewShape
	LODSW
	MOV	BX, AX
	LODSW
	MOV	CX, AX
	POP	DS
	LES	DX, NewShape
	ADD	DX, OFFSET TGraphicCursor.Masks
	MOV	AX, 0009H
	INT	33H
end;

procedure SetTextCursor(const ScreenMask, CursorMask : Word); assembler;
asm
	MOV	AX, 000AH
	XOR	BX, BX
	MOV	CX, ScreenMask
	MOV	DX, CursorMask
	INT	33H
end;

procedure SetHardwareCursor(const FirstLn, LastLn : Word); assembler;
asm
	MOV	AX, 000AH
	MOV	BX, 0001h
	MOV	CX, FirstLn
	MOV	DX, LastLn
	INT	33H
end;

procedure GetMouseMove(var X, Y : Integer); assembler;
asm
	MOV	AX, 000BH
	INT	33H
	MOV	AX, CX
	LES	DI, X
	STOSW
	MOV	AX, DX
	LES	DI, Y
	STOSW
end;

procedure SetLightPenEmulation(const LightPen : Boolean); assembler;
asm
	CMP	LightPen, False
	JE	@@1
	MOV	AX, 000DH
	JMP	@@2
@@1:	MOV	AX, 000EH
@@2:	INT	33H
end;

procedure SetMickeyRatio(const X, Y : Integer); assembler;
asm
	MOV	AX, 000FH
	MOV	CX, X
	MOV	DX, Y
	INT	33H
end;

procedure HideMouseIn(const X1, Y1, X2, Y2 : Integer); assembler;
asm
	MOV	AX, 0010H
	MOV	CX, X1
	MOV	DX, Y1
	MOV	SI, X2
	MOV	DI, Y2
	INT	33H
end;

function DefineGraphicCursor(const Width, Height, HotSpotX, HotSpotY : Byte;
                             const Masks) : Integer; assembler;
asm
	MOV	AX, 0012H
	MOV	BH, Width
	MOV	CH, Height
	MOV	BL, HotSpotX
	MOV	CL, HotSpoty
	LES	DX, Masks
	INT	33H
end;

procedure SetMouseThreshold(const Threshold : Integer); assembler;
asm
	MOV	AX, 0013H
	MOV	DX, Threshold
	INT	33H
end;

function DriverStateSize : Integer; assembler;
asm
	MOV	AX, 0015H
	INT	33H
	MOV	AX, BX
end;

procedure SaveDriverState(const Size : Integer; var Buf); assembler;
asm
	MOV	AX, 0016H
	MOV	BX, Size
	LES	DX, Buf
	INT	33H
end;

procedure RestoreDriverState(const Size : Integer; const Buf); assembler;
asm
	MOV	AX, 0017H
	MOV	BX, Size
	LES	DX, Buf
	INT	33H
end;

procedure SetMouseSensitivity(const Horiz, Vert, Threshold : Integer); assembler;
asm
	MOV	AX, 001AH
	MOV	BX, Horiz
	MOV	CX, Vert
	MOV	DX, Threshold
	INT	33H
end;

procedure GetMouseSensitivity(var Horiz, Vert, Threshold : Integer); assembler;
asm
	MOV	AX, 001BH
	INT	33H
	MOV	AX, BX
        LES	DI, Horiz
        STOSW
	MOV	AX, CX
        LES	DI, Vert
        STOSW
	MOV	AX, DX
        LES	DI, Threshold
        STOSW
end;

procedure SetMousePage(const Page : Integer); assembler;
asm
	MOV	AX, 001DH
	MOV	BX, Page
	INT	33H
end;

function GetMousePage : Integer; assembler;
asm
	MOV	AX, 001EH
	INT	33H
	MOV	AX, BX
end;

function SoftwareReset : Integer; assembler;
asm
	MOV	AX, 0021H
	INT	33H
	CMP	AX, 0FFFFH
	JE	@@1
	MOV	MouseInstalled, 0
	JMP	@@2
@@1:	MOV	MouseInstalled, 1
@@2:	CMP	BX, 0FFFFH
	JNZ	@@3
	MOV	ButtonCount, 0002H
	JMP	@@4
@@3:	MOV	ButtonCount, BX
@@4:	MOV	MouseState, -1
end;

procedure SetMouseLanguage(const Language : Integer); assembler;
asm
	MOV	AX, 0022H
	MOV	BX, Language
	INT	33H
end;

function GetMouseLanguage : Integer; assembler;
asm
	MOV	AX, 0023H
	INT	33H
	MOV	AX, BX
end;

function MouseVersion : Integer; assembler;
asm
	MOV	AX, 0024H
	INT	33H
	CMP	AX, 0FFFFH
	JE	@@1
	MOV	AX, BX
@@1:
end;

function MouseIRQ : Byte; assembler;
asm
	MOV	AX, 0024H
	INT	33H
	CMP	AX, 0FFFFH
	JE	@@1
	MOV	AL, CL
@@1:
end;

function MouseType : Byte; assembler;
asm
	MOV	AX, 0024H
	INT	33H
	CMP	AX, 0FFFFH
	JE	@@1
	MOV	AL, CH
@@1:
end;

function MouseCursor : Byte; assembler;
asm
	MOV	AX, 0025H
	INT	33H
	SHL	AH, 2
	SHR	AH, 6
	MOV	AL, AH
end;

procedure GetMouseMaxRange(var MaxX, MaxY : Integer); assembler;
asm
	MOV	AX, 0026H
	INT	33H
	MOV	AX, CX
	LES	DI, MaxX
	STOSW
	MOV	AX, DX
	LES	DI, MaxY
	STOSW
end;

procedure GetTextCursor(var ScreenMask, CursorMask : Word); assembler;
asm
	MOV	AX, 0027H
	INT	33H
	LES	DI, ScreenMask
	STOSW
	MOV	AX, BX
	LES	DI, CursorMask
	STOSW
end;

procedure GetHardwareCursor(var FirstLn, LastLn : Word); assembler;
asm
	MOV	AX, 0027H
	INT	33H
	LES	DI, FirstLn
	STOSW
	MOV	AX, BX
	LES	DI, LastLn
	STOSW
end;

function GetMouseState : ShortInt; assembler;
asm
	MOV	AX, 002AH
	INT	33H
	MOV	MouseState, AL
end;

function GetMouseHotSpotX : Integer; assembler;
asm
	MOV	AX, 002AH
	INT	33H
	MOV	AX, BX
end;

function GetMouseHotSpotY : Integer; assembler;
asm
	MOV	AX, 002AH
	INT	33H
	MOV	AX, CX
end;

function GetMouseMinX : Integer; assembler;
asm
	MOV	AX, 0031H
	INT	33H
end;

function GetMouseMinY : Integer; assembler;
asm
	MOV	AX, 0031H
	INT	33H
	MOV	AX, BX
end;

function GetMouseMaxX : Integer; assembler;
asm
	MOV	AX, 0031H
	INT	33H
	MOV	AX, CX
end;

function GetMouseMaxY : Integer; assembler;
asm
	MOV	AX, 0031H
	INT	33H
	MOV	AX, DX
end;

procedure GetMouseRange(var MinX, MinY, MaxX, MaxY : Integer); assembler;
asm
	MOV	AX, 0031H
	INT	33H
	LES	DI, MinX
	STOSW
	MOV	AX, BX
	LES	DI, MinY
	STOSW
	MOV	AX, CX
	LES	DI, MaxX
	STOSW
	MOV	AX, DX
	LES	DI, MaxY
	STOSW
end;

function TextX(const X : Integer) : Integer;
begin
  TextX := X div (640 div ScreenWidth) + 1
end;

function TextY(const Y : Integer) : Integer;
begin
  TextY := Y div 8 + 1
end;

function VirtualX(const X : Integer) : Integer;
begin
  VirtualX := X * (640 div ScreenWidth) + 1
end;

function VirtualY(const Y : Integer) : Integer;
begin
  VirtualY := Y * 8 + 1
end;

begin
end.