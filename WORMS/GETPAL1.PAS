unit getpal1;
interface
uses dos;
type mvpal=array[0..255] of array[1..3] of byte;
     convertpal2norm=array[0..255] of byte;
var normpal1: mvpal;

procedure initpal;
procedure getcolorpal(col: byte; var r,g,b: byte);
procedure setcolorpal(color,red,green,blue: byte);
procedure getcurentpal(var cpal: mvpal);
procedure setpal(cpal: mvpal);
function getnearestnormcolor1(r,g,b: byte): byte;
procedure convertpaln1(npal: mvpal; var cvpal: convertpal2norm);

implementation

procedure initpal;
const paldiv: array[1..8] of array[1..3] of byte=((63,63,63),(0,0,63),(0,63,0),
      (0,63,63),(63,0,0),(63,0,63),(63,31,0),(63,63,21));
var x,y,z: integer;
begin
 for x:=1 to 8 do
 for y:=1 to 3 do
 for z:=1 to 32 do
 normpal1[(x-1)*32+z-1][y]:=round((paldiv[x][y]/32)*z);
end;

procedure getcolorpal(col: byte; var r,g,b: byte);
var color,auxr,auxg,auxb: byte;
begin
  color:=col;
  asm
    mov dx,3C7H
    mov al,color
    out dx,al
    add dx,2
    in  al,dx
    mov auxr,al
    in  al,dx
    mov auxg,al
    in  al,dx
    mov auxb,al
  end;
  r:=auxr;g:=auxg;b:=auxb;
end;

procedure setcolorpal(color,red,green,blue: byte);
begin
 asm
   mov dx,3C8h
   mov al,color
   out dx,al
   inc dx
   mov al,red
   out dx,al
   mov al,green
   out dx,al
   mov al,blue
   out dx,al
 end;
end;

procedure getcurentpal(var cpal: mvpal);
var x,r,g,b: byte;
begin
 for x:=0 to 255 do
 begin
  getcolorpal(x,r,g,b);
  cpal[x][1]:=r;
  cpal[x][2]:=g;
  cpal[x][3]:=b;
 end;
end;

procedure setpal(cpal: mvpal);
var x: byte;
begin
 for x:=0 to 255 do
 setcolorpal(x,cpal[x][1],cpal[x][2],cpal[x][3]);
end;

function getnearestnormcolor1(r,g,b: byte): byte;
var x,y,posnr: integer;
    ccol,min: integer;
    cr,cg,cb: byte;
    dif: array[0..255] of integer;
    tmp: array[1..3] of integer;
begin
 ccol:=0;
 for x:=0 to 255 do
 begin
  tmp[1]:=normpal1[x][1]-r;
  tmp[2]:=normpal1[x][2]-g;
  tmp[3]:=normpal1[x][3]-b;
  for y:=1 to 3 do
  if tmp[y]<0 then tmp[y]:=-tmp[y];
  dif[x]:=tmp[1]+tmp[2]+tmp[3];
 end;
 min:=dif[ccol];
 for x:=0 to 255 do
 if min>dif[x] then
 begin
  min:=dif[x];
  ccol:=x;
 end;
 getnearestnormcolor1:=ccol;
end;

procedure convertpaln1(npal: mvpal; var cvpal: convertpal2norm);
var x: byte;
begin
 for x:=0 to 255 do
 cvpal[x]:=getnearestnormcolor1(npal[x][1],npal[x][2],npal[x][3]);
end;

begin
 initpal;
end.