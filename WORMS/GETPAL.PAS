unit getpal;
interface
uses dos;
type mvpal=array[0..255] of array[1..3] of byte;
     convertpal2norm=array[0..255] of byte;
const normpal: mvpal=((0,0,0),(0,0,42),(0,42,0),(0,42,42),(42,0,0),(42,0,42),
(42,21,0),(42,42,42),(21,21,21),(21,21,63),(21,63,21),(21,63,63),(63,21,21),
(63,21,63),(63,63,21),(63,63,63),(0,0,0),(5,5,5),(8,8,8),(11,11,11),
(14,14,14),(17,17,17),(20,20,20),(24,24,24),(28,28,28),(32,32,32),(36,36,36),
(40,40,40),(45,45,45),(50,50,50),(56,56,56),(63,63,63),(0,0,63),(16,0,63),
(31,0,63),(47,0,63),(63,0,63),(63,0,47),(63,0,31),(63,0,16),(63,0,0),
(63,16,0),(63,31,0),(63,47,0),(63,63,0),(47,63,0),(31,63,0),(16,63,0),
(0,63,0),(0,63,16),(0,63,31),(0,63,47),(0,63,63),(0,47,63),(0,31,63),
(0,16,63),(31,31,63),(39,31,63),(47,31,63),(55,31,63),(63,31,63),(63,31,55),
(63,31,47),(63,31,39),(63,31,31),(63,39,31),(63,47,31),(63,55,31),(63,63,31),
(55,63,31),(47,63,31),(39,63,31),(31,63,31),(31,63,39),(31,63,47),(31,63,55),
(31,63,63),(31,55,63),(31,47,63),(31,39,63),(45,45,63),(49,45,63),(54,45,63),
(58,45,63),(63,45,63),(63,45,58),(63,45,54),(63,45,49),(63,45,45),(63,49,45),
(63,54,45),(63,58,45),(63,63,45),(58,63,45),(54,63,45),(49,63,45),(45,63,45),
(45,63,49),(45,63,54),(45,63,58),(45,63,63),(45,58,63),(45,54,63),(45,49,63),
(0,0,28),(7,0,28),(14,0,28),(21,0,28),(28,0,28),(28,0,21),(28,0,14),
(28,0,7),(28,0,0),(28,7,0),(28,14,0),(28,21,0),(28,28,0),(21,28,0),
(14,28,0),(7,28,0),(0,28,0),(0,28,7),(0,28,14),(0,28,21),(0,28,28),
(0,21,28),(0,14,28),(0,7,28),(14,14,28),(17,14,28),(21,14,28),(24,14,28),
(28,14,28),(28,14,24),(28,14,21),(28,14,17),(28,14,14),(28,17,14),(28,21,14),
(28,24,14),(28,28,14),(24,28,14),(21,28,14),(17,28,14),(14,28,14),(14,28,17),
(14,28,21),(14,28,24),(14,28,28),(14,24,28),(14,21,28),(14,17,28),(20,20,28),
(22,20,28),(24,20,28),(26,20,28),(28,20,28),(28,20,26),(28,20,24),(28,20,22),
(28,20,20),(28,22,20),(28,24,20),(28,26,20),(28,28,20),(26,28,20),(24,28,20),
(22,28,20),(20,28,20),(20,28,22),(20,28,24),(20,28,26),(20,28,28),(20,26,28),
(20,24,28),(20,22,28),(0,0,16),(4,0,16),(8,0,16),(12,0,16),(16,0,16),
(16,0,12),(16,0,8),(16,0,4),(16,0,0),(16,4,0),(16,8,0),(16,12,0),
(16,16,0),(12,16,0),(8,16,0),(4,16,0),(0,16,0),(0,16,4),(0,16,8),
(0,16,12),(0,16,16),(0,12,16),(0,8,16),(0,4,16),(8,8,16),(10,8,16),
(12,8,16),(14,8,16),(16,8,16),(16,8,14),(16,8,12),(16,8,10),(16,8,8),
(16,10,8),(16,12,8),(16,14,8),(16,16,8),(14,16,8),(12,16,8),(10,16,8),
(8,16,8),(8,16,10),(8,16,12),(8,16,14),(8,16,16),(8,14,16),(8,12,16),
(8,10,16),(11,11,16),(12,11,16),(13,11,16),(15,11,16),(16,11,16),(16,11,15),
(16,11,13),(16,11,12),(16,11,11),(16,12,11),(16,13,11),(16,15,11),(16,16,11),
(15,16,11),(13,16,11),(12,16,11),(11,16,11),(11,16,12),(11,16,13),(11,16,15),
(11,16,16),(11,15,16),(11,13,16),(11,12,16),(0,0,0),(0,0,0),(0,0,0),
(0,0,0),(0,0,0),(0,0,0),(0,0,0),(0,0,0));

procedure getcolorpal(col: byte; var r,g,b: byte);
procedure setcolorpal(color,red,green,blue: byte);
procedure getcurentpal(var cpal: mvpal);
procedure setpal(cpal: mvpal);
function getnearestnormcolor(r,g,b: byte): byte;
procedure convertpaln(npal: mvpal; var cvpal: convertpal2norm);

implementation

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

{function getnearestnormcolor(r,g,b: byte): byte;
var posib: array[0..255] of byte;
    x,posnr: integer;
    ccol,min: byte;
    cr,cg,cb: byte;
    dif: array[0..255] of integer;
begin
 ccol:=0;
 for x:=0 to 255 do
 begin
  dif[x]:=normpal[x][1]-r;
  if dif[x]<0 then dif[x]:=-dif[x];
 end;
 min:=dif[ccol];
 for x:=0 to 255 do
 if min>dif[x] then
 begin
  min:=dif[x];
  ccol:=x;
 end;
 cr:=normpal[ccol][1];
 posnr:=-1;
 for x:=0 to 255 do
 if normpal[x][1]=cr then
 begin
  posnr:=posnr+1;
  posib[posnr]:=x;
 end;
 min:=normpal[ccol][2];
 for x:=0 to posnr do
 if min>normpal[x][2] then
 begin
  min:=normpal[x][2];
  ccol:=posib[x];
 end;
 cg:=normpal[ccol][2];
 posnr:=-1;
 for x:=0 to 255 do
 if (normpal[x][1]=cr)and(normpal[x][2]=cg) then
 begin
  posnr:=posnr+1;
  posib[posnr]:=x;
 end;
 min:=normpal[ccol][3];
 for x:=0 to posnr do
 if min>normpal[x][3] then
 begin
  min:=normpal[x][3];
  ccol:=posib[x];
 end;
 cb:=normpal[ccol][3];
 getnearestnormcolor:=ccol;
end;}

function getnearestnormcolor(r,g,b: byte): byte;
var x,y,posnr: longint;
    ccol,min: longint;
    cr,cg,cb: longint;
    dif: array[0..255] of longint;
    tmp: array[1..3] of longint;
begin
 ccol:=0;
 for x:=0 to 255 do
 begin
  tmp[1]:=normpal[x][1]-r;
  tmp[2]:=normpal[x][2]-g;
  tmp[3]:=normpal[x][3]-b;
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
 getnearestnormcolor:=ccol;
end;

procedure convertpaln(npal: mvpal; var cvpal: convertpal2norm);
var x: byte;
begin
 for x:=0 to 255 do
 cvpal[x]:=getnearestnormcolor(npal[x][1],npal[x][2],npal[x][3]);
end;

end.