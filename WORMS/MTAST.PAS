{$A+,B-,D-,E-,F-,G+,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X+}
{Copyright (c) Mihai Marica - MSoft 2000}
unit mtast;

interface
const                tsesc        = $01;
                     ts1        = $02;
	             ts2        = $03;
	             ts3        = $04;
	             ts4        = $05;
	             ts5        = $06;
	             ts6        = $07;
	             ts7        = $08;
	             ts8        = $09;
	             ts9        = $0A;
	             ts0        = $0B;
                     tsbkspace  = $0E;
	             tsq          = $10;
	             tsw          = $11;
	             tse          = $12;
	             tsr          = $13;
	             tst          = $14;
	             tsy          = $15;
	             tsu          = $16;
	             tsi          = $17;
	             tso          = $18;
	             tsp          = $19;
	             tsenter      = $1C;
	             tsctrl       = $1D;
	             tsa          = $1E;
	             tss          = $1F;
	             tsd          = $20;
	             tsf          = $21;
	             tsg          = $22;
	             tsh          = $23;
	             tsj          = $24;
	             tsk          = $25;
	             tsl          = $26;
	             tsshifts     = $2A;
	             tsz          = $2C;
	             tsx          = $2D;
	             tsc          = $2E;
	             tsv          = $2F;
	             tsb          = $30;
	             tsn          = $31;
	             tsm          = $32;
	             tsshiftd     = $36;
	             tsalt        = $38;
	             tsspace      = $39;
	             tscslock     = $3A;
	             tsF1         = $3B;
	             tsF2         = $3C;
	             tsF3         = $3D;
	             tsF4         = $3E;
	             tsF5         = $3F;
	             tsF6         = $40;
	             tsF7         = $41;
	             tsF8         = $42;
	             tsF9         = $43;
	             tsF10        = $44;
	             tshome       = $47;
	             tssus        = $48;
	             tspgup       = $49;
	             tsminus      = $4A;
	             tsstanga     = $4B;
	             tsdreapta    = $4D;
	             tsplus       = $4E;
	             tsend        = $4F;
	             tsjos        = $50;
	             tspgdn       = $51;
	             tsins        = $52;
	             tsdel        = $53;
var	keyhitc: boolean;
	key: array[ 0 .. 127 ] of boolean;
	saveexit: pointer;

procedure initscankey;
procedure disabscankey;
procedure waitforkey(scan: byte);

implementation

var int9h: pointer absolute $0000:$0024;
    saveint: pointer;
    ind: word;

procedure keyinterrupt; interrupt;
var p: byte;
begin
 p:=port[$60];
 if port[$60]<128 then key[p]:=true else
 key[p-128]:=false;
 port[$20]:=$20;
end;

procedure initscankey;
begin
  fillchar(key,sizeof(key),0);
  keyhitc:=false;
  int9h:=@keyinterrupt;
end;

procedure disabscankey;
begin
  int9h:=saveint
end;

procedure waitforkey(scan: byte);
begin
  while not key[scan] do;
  while key[scan] do;
END;

procedure safeexit; far;
begin
  exitproc:=saveexit;
  disabscankey;
end;

begin
  fillchar(key,sizeof(key),0);
  keyhitc:=false;
  saveint:=int9h;
  saveexit:=exitproc;
  exitproc:=@safeexit;
end.