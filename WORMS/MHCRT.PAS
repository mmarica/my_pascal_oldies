unit mhcrt;

interface

uses dos;
var lastmode: word;
    checkbreak: boolean;
    checkeof: boolean;
    directvideo: boolean;
    checksnow: boolean;
    textattr: byte;
    windmin,windmax: word;

procedure wherex(var px: byte);
procedure wherey(var py: byte);
procedure gotoxy(px,py: integer);
procedure wherexy(var px,py: byte);
procedure textmode(mode: byte);
procedure clrscr;
procedure setvideopage(page: byte);
function getvideopage: byte;
function keypressed: boolean;
function readkey: char;
function getvideomode: byte;
procedure setvideomode(mode: byte);
procedure textcolor(color: byte);
procedure textbackground(color: byte);
function isgraficmode(mode: byte): boolean;

implementation

var tcol,tbac: byte;
    cmode: byte;
    cursch: char;
    oldexit: pointer;

procedure desfacattr;
begin
 tbac:=trunc(textattr/16);
 tcol:=textattr-16*tbac;
 if tbac>15 then
 repeat
  tbac:=tbac-16;
 until tbac<16;
 if tcol>15 then
 repeat
  tcol:=tcol-16;
 until tcol<16;
end;

procedure facattr;
begin
 if tbac>15 then
 repeat
  tbac:=tbac-16;
 until tbac<16;
 if tcol>15 then
 repeat
  tcol:=tcol-16;
 until tcol<16;
 textattr:=16*tbac+tcol;
end;

function isgraficmode(mode: byte): boolean;
var ral: byte;
begin
 asm
  mov ah,15
  mov al,mode
  int 10h
  mov ral,al
 end;
 if ral>4 then isgraficmode:=true else isgraficmode:=false;
end;

procedure wherexy(var px,py: byte);
var x,y: byte;
begin
 if isgraficmode(cmode) then exit;
 asm
  mov ah,03H
  mov bh,0
  int 10h
  mov x,dl
  mov y,dh
 end;
 px:=x+1;
 py:=y+1;
end;

procedure wherex(var px: byte);
var x,y: byte;
begin
 wherexy(x,y);
 px:=x;
end;

procedure wherey(var py: byte);
var x,y: byte;
begin
 wherexy(x,y);
 py:=y;
end;

procedure gotoxy(px,py: integer);
var x,y: byte;
begin
 px:=px-1;
 py:=py-1;
 if (px<0)or(py<0) then exit;
 x:=px;
 y:=py;
 if isgraficmode(cmode) then exit;
 asm
  mov ah,02H
  mov bh,0
  mov dh,y
  mov dl,x
  int 10h
 end;
end;

procedure proceduradeiesire;
begin
 exitproc:=oldexit;
 writeln(exitcode);
 if not checkbreak then
 if exitcode=255 then exit;
end;

procedure textmode(mode: byte);
var vt: byte;
begin
 vt:=cmode;
 if not isgraficmode(mode) then
 cmode:=vt else
 begin
  setvideomode(mode);
  lastmode:=cmode;
  cmode:=mode;
 end;
end;

procedure getchattr;
var attr,nrc: byte;
begin
 if isgraficmode(cmode) then exit;
 asm
  mov ah,08h
  mov bh,0
  int 10h
  mov nrc,al
 end;
 cursch:=chr(nrc);
end;

procedure setchattr;
var attr,nrc: byte;
begin
 if isgraficmode(cmode) then exit;
 getchattr;
 desfacattr;
 facattr;
 nrc:=ord(cursch);
 asm
  mov ah,09h
  mov al,nrc
  mov bh,0
  mov bl,textattr
  mov cx,1
  int 10h
 end;
end;

procedure clrscr;
var w: word;
begin
 w:=$FFFF;
 if not isgraficmode(cmode) then
 asm
  mov dx,w {1850h}
  mov cx,0
  mov bh,textattr
  mov ax, 0600h
  int 10h
 end;
 gotoxy(1,1);
end;

procedure setvideopage(page: byte);
begin
 asm
  mov ah,05h
  mov al,page
  int 10h
 end;
end;

function getvideopage: byte;
var page: byte;
begin
 asm
  mov ah,0Fh
  int 10h
  mov page,bh
 end;
 getvideopage:=page;
end;

function keypressed: boolean;
var stare: byte;
begin
 asm
  mov ah,0Bh
  int 21h
  mov stare,al
 end;
 if stare=$FF then keypressed:=true;
 if stare=0 then keypressed:=false;
end;

function readkey: char;
var tasta: byte;
begin
 asm
  mov ah,08h
  int 21h
  mov tasta,al
 end;
 readkey:=chr(tasta);
end;

function getvideomode: byte;
var mode: byte;
begin
 asm
  mov ah,0fh
  int 10h
  mov mode,al
 end;
 getvideomode:=mode;
end;

procedure setvideomode(mode: byte);
begin
 asm
  mov ah,0
  mov al,mode
  int 10h
 end;
end;

procedure textcolor(color: byte);
begin
 getchattr;
 desfacattr;
 tcol:=color;
 facattr;
 setchattr;
end;

procedure textbackground(color: byte);
begin
 getchattr;
 desfacattr;
 tbac:=color;
 facattr;
 setchattr;
end;

begin
 oldexit:=exitproc;
 exitproc:=@proceduradeiesire;
 checkbreak:=true;
 lastmode:=getvideomode;
 cmode:=lastmode;
 if not isgraficmode(lastmode) then lastmode:=3;
 tcol:=7;
 tbac:=0;
 facattr;
 desfacattr;
end.