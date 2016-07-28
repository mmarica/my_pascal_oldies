unit textgraf;
interface
uses dos;
const char1=#205;
      char2=#186;
      char3=#201;
      char4=#187;
      char5=#200;
      char6=#188;
type ecran80x25=array[1..25,1..80] of record
                                       c: char;
                                       b: byte;
                                      end;
var charcolor,baccolor,attr: byte;
    fchar: char;

procedure cursor(afisare: boolean);
procedure clipire(on: boolean);
procedure setvideomode(mode: byte);
function getvideomode: byte;
procedure inittext80x25;
procedure bara80x25(p: pointer;x1,y1,x2,y2: integer);
function getcharcolor: byte;
procedure setbaccolor(b: byte);
function getbaccolor: byte;
procedure setcharcolor(b: byte);
procedure setchar(c: char);
function getchar: char;
procedure writestring80x25(p: pointer;xs,ys: integer;s: string;wrap,scroll,centrat: boolean);
function wherex80x25: integer;
function wherey80x25: integer;
procedure cursorto80x25(x,y: integer);
procedure ferg80x25(p: pointer;x1,y1,x2,y2: integer;titlu: string);

implementation

procedure cursor(afisare: boolean);
var r: registers;
begin
 r.ah:=1;
 if afisare then
  begin
   r.ch:=6;
   r.cl:=7;
  end
 else
  begin
   r.ch:=32;
   r.cl:=7;
  end;
 intr($10,r);
end;

procedure clipire(on: boolean);
var r: registers;
begin
 r.ah:=$10;
 r.al:=$03;
 if on then r.bl:=1 else r.bl:=0;
 intr($10,r);
end;

procedure setvideomode(mode: byte);
var r: registers;
begin
 r.ah:=00;
 r.al:=mode;
 intr($10,r);
end;

function getvideomode: byte;
var r: registers;
begin
 r.ah:=$0f;
 intr($10,r);
 getvideomode:=r.al;
end;

procedure inittext80x25;
begin
 setvideomode(3);
end;

procedure bara80x25(p: pointer;x1,y1,x2,y2: integer);
var a: ^ecran80x25;
    linieb: array[1..160] of char;
    char2: array[1..2] of char;
    distanta,x,y: integer;
begin
 a:=p;
 if x1>x2 then
 begin
  x:=x2;
  x2:=x1;
  x1:=x;
 end;
 if y1>y2 then
 begin
  y:=y2;
  y2:=y1;
  y1:=y;
 end;
 if (x2<1)or(y2<1)or(x1>80)or(y1>25) then exit;
 if x1<1 then x1:=1;
 if x2>80 then x2:=80;
 if y1<1 then y1:=1;
 if y2>25 then y2:=25;
 distanta:=x2-x1+1;
 char2[1]:=fchar;
 char2[2]:=chr(attr);
 for x:=1 to distanta do
 move(char2,linieb[x*2-1],2);
 for y:=y1 to y2 do
 move(linieb,a^[y,x1],distanta*2);
end;

procedure facattr;
begin
 attr:=16*baccolor+charcolor;
end;

procedure setcharcolor(b: byte);
begin
 if b>15 then
 repeat
  b:=b-1;
 until b<=15;
 charcolor:=b;
 facattr;
end;

function getcharcolor: byte;
begin
 getcharcolor:=charcolor;
end;

procedure setbaccolor(b: byte);
begin
 if b>15 then
 repeat
  b:=b-1;
 until b<=15;
 baccolor:=b;
 facattr;
end;

function getbaccolor: byte;
begin
 getbaccolor:=baccolor;
end;

procedure setchar(c: char);
begin
 fchar:=c;
end;

function getchar: char;
begin
 getchar:=fchar;
end;

procedure writestring80x25(p: pointer;xs,ys: integer;s: string;wrap,scroll,centrat: boolean);
var x,y,z: integer;
    poz,lungime: integer;
    terminat: boolean;
    a: ^ecran80x25;
    pozitie: integer;
begin
 if length(s)<1 then exit;
 a:=p;
 terminat:=false;
 lungime:=length(s);
 if centrat then pozitie:=40-length(s)div 2;
 x:=xs-1;
 y:=ys;
 if centrat then x:=xs-1+pozitie;
 poz:=0;
 repeat
  poz:=poz+1;
  x:=x+1;
  if x>80 then
  begin
   if not wrap then exit;
   x:=1;
   y:=y+1;
  end;
  if y>25 then
  begin
   if not scroll then exit;
   for z:=1 to 24 do
   move(a^[z+1,1],a^[z,1],160);
   bara80x25(a,1,25,80,25);
   y:=25;
  end;
  if (x>=1)and(y>=1)and(x<=80)and(y<=25) then
  begin
   a^[y,x].c:=s[poz];
   a^[y,x].b:=attr;
  end;
  if poz>=lungime then terminat:=true;
 until terminat;
end;

function wherex80x25: integer;
var r: registers;
begin
 r.ah:=$03;
 r.bh:=0;
 intr($10,r);
 wherex80x25:=r.dl+1;
end;

function wherey80x25: integer;
var r: registers;
begin
 r.ah:=$03;
 r.bh:=0;
 intr($10,r);
 wherey80x25:=r.dh+1;
end;

procedure cursorto80x25(x,y: integer);
var r: registers;
begin
 if(x<1)or(y<1)or(x>80)or(y>25) then exit;
 r.ah:=$02;
 r.bh:=0;
 r.dh:=y-1;
 r.dl:=x-1;
 intr($10,r);
end;

procedure ferg80x25(p: pointer;x1,y1,x2,y2: integer;titlu: string);
var a: ^ecran80x25;
    x,y: integer;
begin
 if (x1=x2)or(y1=y2) then exit;
 if x1>x2 then
 begin
  x:=x2;
  x2:=x1;
  x1:=x;
 end;
 if y1>y2 then
 begin
  y:=y2;
  y2:=y1;
  y1:=y;
 end;
 if (y2<1)or(y1>25)or(x2<1)or(x1>80) then exit;
 bara80x25(p,x1,y1,x2,y2);
 for x:=x1+1 to x2-1 do
 begin
  writestring80x25(p,x,y1,char1,false,false,false);
  writestring80x25(p,x,y2,char1,false,false,false);
 end;
 for y:=y1+1 to y2-1 do
 begin
  writestring80x25(p,x1,y,char2,false,false,false);
  writestring80x25(p,x2,y,char2,false,false,false);
 end;
 writestring80x25(p,x1,y1,char3,false,false,false);
 writestring80x25(p,x2,y1,char4,false,false,false);
 writestring80x25(p,x1,y2,char5,false,false,false);
 writestring80x25(p,x2,y2,char6,false,false,false);
 y:=x2-x1+1;y:=y div 2;
 y:=y-length(titlu) div 2;
 writestring80x25(p,x1+y,y1,titlu,true,false,false);
end;

begin
 setcharcolor(7);
 setbaccolor(0);
 setchar(' ');
 facattr;
end.