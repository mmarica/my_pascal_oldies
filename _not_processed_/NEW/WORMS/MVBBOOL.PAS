unit mvbbool;
interface
uses dos,utilmv;
type ecran=array[0..199,0..319] of byte;
     temp=array[1..320] of byte;
     point=record
            x: integer;
            y: integer;
           end;
     fnt8_14=array[0..255,0..13] of byte;
     vp=word;
     bftext=array[0..255,0..13,0..7] of boolean;
const eranimic: byte=0;
      era0: byte=1;
      eramult: byte=2;
      erainsuf: byte=3;
      erdnimic: byte=0;
      erdincor: byte=1;
var mvf,mvf2: ^fnt8_14;
    g,h,d,e,cfx,cfy,mar: integer;
    afara: boolean;
    w1,w2: ^temp;
    textbool: ^bftext;
    cn,x,y: integer;
    eraloc,erdealoc: byte;
    oldexit: pointer;
    mv,scl,fcl: integer;
    alocattext,eroaregrafica: boolean;

procedure clearbuf(p: pointer;c: byte);
procedure elipsa(p: pointer;x,y,xr,yr: integer);
procedure elipsap(p: pointer;x,y,xr,yr: integer);
procedure elipsam(p: pointer;x,y,xr,yr: integer);
procedure cerc(p: pointer;x,y,r: integer);
procedure cercp(p: pointer;x,y,r: integer);
procedure cercm(p: pointer;x,y,r: integer);
procedure linie(p: pointer;x1,y1,x2,y2: integer);
procedure bara(p: pointer;x1,y1,x2,y2: integer);
procedure baram(p: pointer;x1,y1,x2,y2: integer);
procedure dreptunghi(p: pointer;x1,y1,x2,y2: integer);
procedure ignoremvb(p1,p2: pointer;x1,y1,x2,y2,x3,y3,ic: integer);
procedure loadmvb(p: pointer;s: string;var error: byte);
function getscolor: byte;
function getfcolor: byte;
procedure initgr;
procedure closegr;
procedure movefp(x,y: integer);
procedure schimbmf(marime: integer);
procedure scolor(culoare: integer);
procedure fcolor(culoare: integer);
procedure mvtextxy(adrs: pointer;px,py: integer;coment: string);
procedure invertmvb(p1,p2: pointer;x1,y1,x2,y2,x3,y3,ic: integer);
procedure rastymvb(p1,p2: pointer;x1,y1,x2,y2,x3,y3: integer);
procedure rastxmvb(p1,p2: pointer;x1,y1,x2,y2,x3,y3: integer);
procedure stretchmvb(p1,p2: pointer;x1,y1,x2,y2,x3,y3,x4,y4: integer);
procedure copymvb(p1,p2: pointer;x1,y1,x2,y2,x3,y3: integer);
function rad(x: real): real;

implementation
function mhmemaloc(marime: longint): word;
var r: registers;
    i,n: longint;
    w: word;
    fl: byte;
begin
 eraloc:=eranimic;
 if marime<=0 then
 begin
  eraloc:=era0;
  mhmemaloc:=0;
  exit;
 end;
 if marime>65536 then
 begin
  eraloc:=eramult;
  mhmemaloc:=0;
  exit;
 end;
 i:=trunc(marime/16);
 n:=marime mod 16;
 if n<>0 then i:=i+1;
 w:=i;
 r.ax:=$4800;
 r.bx:=w;
 intr($21,r);
 if (r.flags and fcarry)<>0 then
 begin
  eraloc:=erainsuf;
  mhmemaloc:=0;
  exit;
 end;
 mhmemaloc:=r.ax;
end;

procedure mhmemdealoc(poz: vp);
var r: registers;
begin
 erdealoc:=erdnimic;
 r.ax:=$4900;
 r.es:=poz;
 intr($21,r);
 if (r.flags and fcarry)<>0 then erdealoc:=erdincor;
end;

procedure clearbuf(p: pointer;c: byte);
var x: ^ecran;
begin
 x:=p;
 fillchar(x^,64000,c);
end;

procedure charmv;external;
{$L charmv.obj}

procedure elipsa(p: pointer;x,y,xr,yr: integer);
var mr,t,v1,v2,v3,v4: longint;
    u,f,r1,r2,r3,r4: real;
    b1: ^ecran;
begin
 if xr<=0 then exit;
 if xr>300 then xr:=300;
 if yr<=0 then exit;
 if yr>300 then yr:=300;
 if xr>yr then mr:=xr else mr:=yr;
 b1:=p;
 f:=(45/mr);
 t:=mr*2;
 for v1:=0 to t do
 begin
  v3:=round(x+xr*cos(rad(v1*f)));
  v4:=round(y+yr*sin(rad(v1*f)));
  if v3>=0 then
  if v4>=0 then
  if v3<=319 then
  if v4<=199 then
  b1^[v4,v3]:=scl;
  if x-(v3-x)>=0 then
  if v4>=0 then
  if x-(v3-x)<=319 then
  if v4<=199 then
  b1^[v4,x-(v3-x)]:=scl;
  if v3>=0 then
  if y-(v4-y)>=0 then
  if v3<=319 then
  if y-(v4-y)<=199 then
  b1^[y-(v4-y),v3]:=scl;
  if x-(v3-x)>=0 then
  if y-(v4-y)>=0 then
  if x-(v3-x)<=319 then
  if y-(v4-y)<=199 then
  b1^[y-(v4-y),x-(v3-x)]:=scl;
 end;
end;

procedure elipsap(p: pointer;x,y,xr,yr: integer);
var mr,t,r1,r2,r3,r4,v5,v6,v1,v2,v3,v4: longint;
    u,f: real;
    b1: ^ecran;
    w1,w2: ^temp;
begin
 if xr<=0 then exit;
 if xr>300 then xr:=300;
 if yr<=0 then exit;
 if yr>300 then yr:=300;
 if xr>yr then mr:=xr else mr:=yr;
 b1:=p;
 f:=(45/mr);
 t:=mr*2;
 for v1:=0 to t do
 begin
  v5:=round(x+xr*cos(rad(v1*f)));
  v6:=round(y+yr*sin(rad(v1*f)));
  v3:=v5;v4:=v6;
  v2:=x;
   if v2>v3 then
   begin
    r1:=v2;
    v2:=v3;
    v3:=r1;
   end;
   if v4<=199 then
   if v4>=0 then
   if v3>=0 then
   if v2<=319 then
   begin
    if v2<0 then v2:=0;
    if v3>319 then v3:=319;
    r1:=v3-v2+1;
    w2:=ptr(seg(p^),ofs(p^)+320*v4+v2);
    move(w1^,w2^,r1);
    fillchar(w2^,r1,fcl);
   end;
  v2:=x-1;
  v3:=x-(v5-x);v4:=v6;
   if v2>v3 then
   begin
    r1:=v2;
    v2:=v3;
    v3:=r1;
   end;
   if v4<=199 then
   if v4>=0 then
   if v3>=0 then
   if v2<=319 then
   begin
    if v2<0 then v2:=0;
    if v3>319 then v3:=319;
    r1:=v3-v2+1;
    w2:=ptr(seg(p^),ofs(p^)+320*v4+v2);
    fillchar(w2^,r1,fcl);
   end;
  v2:=x-1;
  v3:=x-(v5-x);v4:=y-(v6-y);
   if v2>v3 then
   begin
    r1:=v2;
    v2:=v3;
    v3:=r1;
   end;
   if v4<=199 then
   if v4>=0 then
   if v3>=0 then
   if v2<=319 then
   begin
    if v2<0 then v2:=0;
    if v3>319 then v3:=319;
    r1:=v3-v2+1;
    w2:=ptr(seg(p^),ofs(p^)+320*v4+v2);
    fillchar(w2^,r1,fcl);
   end;
  v2:=x-1;
  v3:=v5;v4:=y-(v6-y);
   if v2>v3 then
   begin
    r1:=v2;
    v2:=v3;
    v3:=r1;
   end;
   if v4<=199 then
   if v4>=0 then
   if v3>=0 then
   if v2<=319 then
   begin
    if v2<0 then v2:=0;
    if v3>319 then v3:=319;
    r1:=v3-v2+1;
    w2:=ptr(seg(p^),ofs(p^)+320*v4+v2);
    fillchar(w2^,r1,fcl);
   end;
  end
end;

procedure elipsam(p: pointer;x,y,xr,yr: integer);
begin
 elipsap(addr(p^),x,y,xr,yr);
 elipsa(addr(p^),x,y,xr,yr);
end;

procedure cercp(p: pointer;x,y,r: integer);
var t,r1,r2,r3,r4,v5,v6,v1,v2,v3,v4: longint;
    u,f: real;
    b1: ^ecran;
    w1,w2: ^temp;
begin
 if r<=0 then exit;
 if r>300 then r:=300;
 b1:=p;
 f:=(45/r);
 t:=r*2;
 for v1:=0 to t do
 begin
  v5:=round(x+r*cos(rad(v1*f)));
  v6:=round(y+r*sin(rad(v1*f)));
  v3:=v5;v4:=v6;
  v2:=x;
   if v2>v3 then
   begin
    r1:=v2;
    v2:=v3;
    v3:=r1;
   end;
   if v4<=199 then
   if v4>=0 then
   if v3>=0 then
   if v2<=319 then
   begin
    if v2<0 then v2:=0;
    if v3>319 then v3:=319;
    r1:=v3-v2+1;
    w2:=ptr(seg(p^),ofs(p^)+320*v4+v2);
    fillchar(w2^,r1,fcl);
   end;
  v2:=x-1;
  v3:=x-(v5-x);v4:=v6;
   if v2>v3 then
   begin
    r1:=v2;
    v2:=v3;
    v3:=r1;
   end;
   if v4<=199 then
   if v4>=0 then
   if v3>=0 then
   if v2<=319 then
   begin
    if v2<0 then v2:=0;
    if v3>319 then v3:=319;
    r1:=v3-v2+1;
    w2:=ptr(seg(p^),ofs(p^)+320*v4+v2);
    fillchar(w2^,r1,fcl);
   end;
  v2:=x-1;
  v3:=x-(v5-x);v4:=y-(v6-y);
   if v2>v3 then
   begin
    r1:=v2;
    v2:=v3;
    v3:=r1;
   end;
   if v4<=199 then
   if v4>=0 then
   if v3>=0 then
   if v2<=319 then
   begin
    if v2<0 then v2:=0;
    if v3>319 then v3:=319;
    r1:=v3-v2+1;
    w2:=ptr(seg(p^),ofs(p^)+320*v4+v2);
    fillchar(w2^,r1,fcl);
   end;
  v2:=x-1;
  v3:=v5;v4:=y-(v6-y);
   if v2>v3 then
   begin
    r1:=v2;
    v2:=v3;
    v3:=r1;
   end;
   if v4<=199 then
   if v4>=0 then
   if v3>=0 then
   if v2<=319 then
   begin
    if v2<0 then v2:=0;
    if v3>319 then v3:=319;
    r1:=v3-v2+1;
    w2:=ptr(seg(p^),ofs(p^)+320*v4+v2);
    fillchar(w2^,r1,fcl);
   end;
  end
end;

procedure cerc(p: pointer;x,y,r: integer);
var t,v1,v2,v3,v4: longint;
    u,f,r1,r2,r3,r4: real;
    b1: ^ecran;
begin
 if r<=0 then exit;
 if r>300 then r:=300;
 b1:=p;
 f:=(45/r);
 t:=r*2;
 for v1:=0 to t do
 begin
  v3:=round(x+r*cos(rad(v1*f)));
  v4:=round(y+r*sin(rad(v1*f)));
  if v3>=0 then
  if v4>=0 then
  if v3<=319 then
  if v4<=199 then
  b1^[v4,v3]:=scl;
  if x-(v3-x)>=0 then
  if v4>=0 then
  if x-(v3-x)<=319 then
  if v4<=199 then
  b1^[v4,x-(v3-x)]:=scl;
  if v3>=0 then
  if y-(v4-y)>=0 then
  if v3<=319 then
  if y-(v4-y)<=199 then
  b1^[y-(v4-y),v3]:=scl;
  if x-(v3-x)>=0 then
  if y-(v4-y)>=0 then
  if x-(v3-x)<=319 then
  if y-(v4-y)<=199 then
  b1^[y-(v4-y),x-(v3-x)]:=scl;
 end;
end;

procedure cercm(p: pointer;x,y,r: integer);
begin
 cercp(addr(p^),x,y,r);
 cerc(addr(p^),x,y,r);
end;

procedure linie(p: pointer;x1,y1,x2,y2: integer);
var dx,dy,x,y,m,v: longint;
    v1,v2,v3,v4: longint;
    b1,b2: ^ecran;
    w1,w2: ^temp;
begin
 dx:=x2-x1+1;if dx<0 then dx:=-dx;
 dy:=y2-y1+1;if dy<0 then dy:=-dy;
 if dx=1 then
 begin
  if y1<0 then y1:=0;
  if y2>199 then y2:=199;
  if x1<0 then exit;
  if x1>319 then exit;
  if y1>y2 then
  begin
   m:=y2;
   y2:=y1;
   y1:=m;
  end;
  b2:=p;
  for y:=y1 to y2 do
  b2^[y,x1]:=scl;
  exit;
 end;
 if dy=1 then
 begin
  if x1<0 then x1:=0;
  if x2>319 then x2:=319;
  if y1<0 then exit;
  if y1>199 then exit;
  if x1>x2 then
  begin
   m:=x2;
   x2:=x1;
   x1:=m;
  end;
  b2:=p;
  for x:=x1 to x2 do
  b2^[y1,x]:=scl;
  exit;
 end;
 if dx>=dy then
 begin
  b2:=p;
  if x1<x2 then
  begin
   dy:=y2-y1;
   dx:=x2-x1;
   for x:=0 to x2-x1 do
   begin
    v1:=round(y1+x*dy/dx);
    if (v1>=0) then if (v1<=199) then if (x+x1>=0) then if (x+x1<=319) then
    b2^[v1,x+x1]:=scl;
   end;
   exit;
  end;
  if x1>x2 then
  begin
   m:=x1;
   x1:=x2;
   x2:=m;
   m:=y1;
   y1:=y2;
   y2:=m;
   dy:=y2-y1;
   dx:=x2-x1;
   for x:=0 to x2-x1 do
   begin
    v1:=round(y1+x*dy/dx);
    if (v1>=0) then if (v1<=199) then if (x+x1>=0) then if (x+x1<=319) then
    b2^[v1,x+x1]:=scl;
   end;
   exit;
  end;
 end;
 if dx<=dy then
 begin
  b2:=p;
  if y1<y2 then
  begin
   dy:=y2-y1;
   dx:=x2-x1;
   for y:=0 to y2-y1 do
   begin
    v1:=round(x1+y*dx/dy);
    if (v1>=0) then if (v1<=319) then if (y+y1>=0) then if (y+y1<=199) then
    b2^[y+y1,v1]:=scl;
   end;
   exit;
  end;
  if y1>y2 then
  begin
   m:=y1;
   y1:=y2;
   y2:=m;
   m:=x1;
   x1:=x2;
   x2:=m;
   dy:=y2-y1;
   dx:=x2-x1;
   for y:=0 to y2-y1 do
   begin
    v1:=round(x1+y*dx/dy);
    if (v1>=0) then if (v1<=319) then if (y+y1>=0) then if (y+y1<=199) then
    b2^[y+y1,v1]:=scl;
   end;
   exit;
  end;
 end;
end;

procedure ignoremvb(p1,p2: pointer;x1,y1,x2,y2,x3,y3,ic: integer);
var b1,b2: ^ecran;
    x,y,px,py: integer;
begin
 b1:=p1;
 b2:=p2;
 for y:=y1 to y2 do
 for x:=x1 to x2 do
 begin
  py:=y-y1+y3;
  px:=x-x1+x3;
  if (py>=0)and(py<=199)and(px>=0)and(px<=319)and
  (y>=0)and(y<=199)and(x>=0)and(x<=319)and(b1^[y,x]<>ic) then
  b2^[py,px]:=b1^[y,x];
 end;
end;

function rad;
begin
  rad := pi*x/180
end;

procedure loadmvb;
var x,y,m,v: longint;
    f: file;
    bsx,bsy: longint;
    p1,p2: integer;
    size: longint;
    rz: word;
    b1: ^ecran;
    tp: longint;
    gata: boolean;
    citit: longint;
    antet: byte;
    test: char;
begin
 b1:=p;
 {$I-}
 assign(f,s);
 reset(f);
 blockread(f,test,rz);
 blockread(f,test,rz);
 blockread(f,test,rz);
 blockread(f,test,rz);
 blockread(f,test,rz);
 if ord(test)<255 then
 begin
  bsx:=ord(test);
  blockread(f,test,rz);
  bsy:=ord(test);
 end else
 begin
  blockread(f,test,rz);
  bsx:=255+ord(test);
  blockread(f,test,rz);
  bsy:=ord(test);
 end;
 for x:=0 to bsx-1 do
 for y:=0 to bsy-1 do
 begin
  blockread(f,test,rz);
  b1^[y,x]:=ord(test);
 end;
 close(f);
 {$I+}
 if ioresult<>0 then
 begin
  error:=1;
  exit;
 end;
end;

function getscolor: byte;
begin
 getscolor:=scl;
end;

function getfcolor: byte;
begin
 getfcolor:=fcl;
end;

procedure initgr;
begin
 mv:=getm;
 setm(19);
 if getm<>19 then eroaregrafica:=true else eroaregrafica:=false;
end;

procedure closegr;
begin
 setm(mv);
end;

procedure movefp;
begin
 if x<0 then x:=0;
 if y<0 then y:=0;
 if x>319 then x:=319;
 if y>199 then y:=199;
 cfx:=x;cfy:=y;
end;

procedure schimbmf;
begin
 if marime<1 then marime:=1;
 if marime>10 then marime:=10;
 mar:=marime;
end;

procedure scolor;
begin
 repeat
  if culoare<0 then culoare:=320+culoare;
  if culoare>319 then culoare:=culoare-320;
 until (culoare>=0)and(culoare<=319);
 scl:=culoare;
end;

procedure fcolor;
begin
 repeat
  if culoare<0 then culoare:=320+culoare;
  if culoare>319 then culoare:=culoare-320;
 until (culoare>=0)and(culoare<=319);
 fcl:=culoare;
end;

procedure mvtextxy;
var bx,by,x,y,sx,sy: integer;
    b1: ^ecran;
    culv: byte;
begin
 culv:=fcl;
 fcl:=scl;
 bx:=cfx;
 by:=cfy;
 afara:=false;
 cfx:=px;cfy:=py;
 b1:=adrs;
 for g:=1 to length(coment) do
 begin
  if cfy>199 then afara:=true;
  if not afara then
  begin
   for y:=0 to 13 do
   for x:=0 to 7 do
   if (cfy+y*mar>=0)and(cfy+y*mar<=199)and(cfx+x*mar>=0)and(cfx+x*mar<=319) then
   if textbool^[ord(coment[g]),y,x] then
   begin
    bara(b1,x*mar+cfx,y*mar+cfy,x*mar+cfx+mar-1,y*mar+cfy+mar-1);
   end;
   cfx:=cfx+8*mar;
  end;
 end;
 cfx:=bx;
 cfy:=by;
 fcl:=culv;
end;

procedure dreptunghi(p: pointer;x1,y1,x2,y2: integer);
var m,v,mv,x,y,px,py: longint;
    v1,v2,v3,v4: longint;
    b1,b2: ^ecran;
begin
 if x1>x2 then
 begin
  m:=x2;
  x2:=x1;
  x1:=m;
 end;
 if y1>y2 then
 begin
  m:=y2;
  y2:=y1;
  y1:=m;
 end;
 if x2<0 then exit;
 if y2<0 then exit;
 if x1>319 then exit;
 if y1>199 then exit;
 if x1<0 then x1:=0;
 if y1<0 then y1:=0;
 if x2>319 then x2:=319;
 if y2>199 then y2:=199;
 v1:=x2-x1+1;
 y:=y1;
 b2:=ptr(seg(p^),ofs(p^)+y*320+x1);
 fillchar(b2^,v1,scl);
 y:=y2;
 b2:=ptr(seg(p^),ofs(p^)+y*320+x1);
 fillchar(b2^,v1,scl);
 b1:=addr(p^);
 for y:=y1 to y2 do
 begin
  b1^[y,x1]:=scl;
  b1^[y,x2]:=scl;
 end;
end;

procedure bara(p: pointer;x1,y1,x2,y2: integer);
var m,v,mv,x,y,px,py: longint;
    v1,v2,v3,v4: longint;
    b1,b2: ^ecran;
begin
 if x1>x2 then
 begin
  m:=x2;
  x2:=x1;
  x1:=m;
 end;
 if y1>y2 then
 begin
  m:=y2;
  y2:=y1;
  y1:=m;
 end;
 if (x2<0)and(x1<0) then exit;
 if (y2<0)and(y1<0) then exit;
 if (x1>319)and(x2>319) then exit;
 if (y1>199)and(y2>319) then exit;
 if x1<0 then x1:=0;
 if y1<0 then y1:=0;
 if x2<0 then x2:=0;
 if y2<0 then y2:=0;
 if x2>319 then x2:=319;
 if y2>199 then y2:=199;
 if x1>319 then x1:=319;
 if y1>199 then y1:=199;
 v1:=x2-x1+1;
 for y:=y1 to y2 do
 begin
  b2:=ptr(seg(p^),ofs(p^)+y*320+x1);
  fillchar(b2^,v1,fcl);
 end;
end;

procedure baram(p: pointer;x1,y1,x2,y2: integer);
begin
 bara(p,x1,y1,x2,y2);
 dreptunghi(p,x1,y1,x2,y2);
end;

procedure copymvb(p1,p2: pointer;x1,y1,x2,y2,x3,y3: integer);
var m,v,mv,x,y,px,py: longint;
    v1,v2,v3,v4: longint;
    b1,b2: ^ecran;
begin
 if x1>x2 then
 begin
  m:=x2;
  x2:=x1;
  x1:=m;
 end;
 if y1>y2 then
 begin
  m:=y2;
  y2:=y1;
  y1:=m;
 end;
 if x2<0 then exit;
 if y2<0 then exit;
 if x1>319 then exit;
 if y1>199 then exit;
 if x2-x1<0 then exit;
 if y2-y1<0 then exit;
 if x3<=(x1-x2) then exit;
 if y3<=(y1-y2) then exit;
 if x3>319 then exit;
 if y3>199 then exit;
 if x1<0 then x1:=0;
 if y1<0 then y1:=0;
 if x2>319 then x2:=319;
 if y2>199 then y2:=199;
 if x3<0 then
 begin
  x1:=x1-x3;
  x3:=0;
 end;
 if y3<0 then
 begin
  y1:=y1-y3;
  y3:=0;
 end;
 if x3+x2-x1+1>319 then x2:=319-x3+x1;
 if y3+y2-y1+1>199 then y2:=199-y3+y1;
  b1:=p1;
  b2:=p2;
  x:=y2-y1;
  for m:=0 to x do
  begin
   v:=m+y1;
   mv:=ofs(b1^)+v*320+x1;
   y:=ofs(b2^)+(y3+m)*320+x3;
   v1:=x2-x1+1;
   w1:=ptr(seg(b1^),mv);
   w2:=ptr(seg(b2^),y);
   move(w1^,w2^,v1);
  end;
end;

procedure stretchmvb(p1,p2: pointer;x1,y1,x2,y2,x3,y3,x4,y4: integer);
var b1,b2: ^ecran;
    x,y,px,py: integer;
begin
 if ((x4-x2)<>(x3-x1))and((y4-y2)<>(y3-y1)) then
 begin
  b1:=p1;
  b2:=p2;
   for y:=y3 to y4 do
   for x:=x3 to x4 do
   begin
    if (y4-y3<>0) then py:=round(y*((y2-y1+1)/(y4-y3+1)));
    if (x4-x3<>0) then px:=round(x*((x2-x1+1)/(x4-x3+1)));
    if (px>=0)and(px<=319)and(py>=0)and(py<=199) then
    b2^[y,x]:=b1^[py,px];
   end;
 end else
 if ((y4-y2)=(y3-y1))and((x4-x2)<>(x3-x1)) then
 begin
  b1:=p1;
  b2:=p2;
   for y:=y3 to y4 do
   for x:=x3 to x4 do
   begin
    py:=y;
    if (x4-x3<>0) then px:=round(x*((x2-x1+1)/(x4-x3+1)));
    if (px>=0)and(px<=319)and(py>=0)and(py<=199) then
    b2^[y,x]:=b1^[y,px];
   end;
 end else
 if ((x4-x2)=(x3-x1))and((y4-y2)<>(y3-y1)) then
 begin
  b1:=p1;
  b2:=p2;
   for y:=y3 to y4 do
   for x:=x3 to x4 do
   begin
   px:=x;
   if (y4-y3<>0) then py:=round(y*((y2-y1+1)/(y4-y3+1)));
   if (px>=0)and(px<=319)and(py>=0)and(py<=199) then
   b2^[y,x]:=b1^[py,px];
 end;
 end else
 if ((y4-y2)=(y3-y1))and((x4-x2)=(x3-x1)) then
 begin
  b1:=p1;
  b2:=p2;
  for x:=x1 to x2 do
  for y:=y1 to y2 do
  if(x>=0)and(x<=319)and(y>=0)and(y<=199) then
  b2^[y,x]:=b1^[y,x];
 end;
end;

procedure rastxmvb(p1,p2: pointer;x1,y1,x2,y2,x3,y3: integer);
var b1,b2: ^ecran;
    x,y,px,py: integer;
begin
 b1:=p1;
 b2:=p2;
 for y:=y1 to y2 do
 for x:=x1 to x2 do
 begin
  py:=y;
  px:=x1+(x2-x);
  if (py>=0)and(py<=199)and(px>=0)and(px<=319)and
  (y>=0)and(y<=199)and(x>=0)and(x<=319) then
  b2^[py,px]:=b1^[y,x];
 end;
end;

procedure rastymvb(p1,p2: pointer;x1,y1,x2,y2,x3,y3: integer);
var b1,b2: ^ecran;
    x,y,px,py: integer;
begin
 b1:=p1;
 b2:=p2;
 for y:=y1 to y2 do
 for x:=x1 to x2 do
 begin
  px:=x;
  py:=y1+(y2-y);
  if (py>=0)and(py<=199)and(px>=0)and(px<=319)and
  (y>=0)and(y<=199)and(x>=0)and(x<=319) then
  b2^[py,px]:=b1^[y,x];
 end;
end;

procedure invertmvb(p1,p2: pointer;x1,y1,x2,y2,x3,y3,ic: integer);
var b1,b2: ^ecran;
    x,y,px,py: integer;
begin
 b1:=p1;
 b2:=p2;
 for y:=y1 to y2 do
 for x:=x1 to x2 do
 begin
  px:=x;
  py:=y;
  if (py>=0)and(py<=199)and(px>=0)and(px<=319)and
  (y>=0)and(y<=199)and(x>=0)and(x<=319) then
  b2^[py,px]:=b1^[y,x] xor ic;
 end;
end;

procedure mvbutilexit;
begin
 exitproc:=oldexit;
 if alocattext then mhmemdealoc(seg(textbool^));
end;

var r: registers;
begin
 oldexit:=exitproc;
 exitproc:=@mvbutilexit;
 mvf:=@charmv;
 textbool:=ptr(mhmemaloc(sizeof(textbool^)),0);
 if eraloc<>eranimic then alocattext:=false else alocattext:=true;
 if alocattext then
 begin
  for cn:=0 to 255 do
  for y:=0 to 13 do
  for x:=0 to 7 do
  if (mvf^[cn,y] and (1 shl (7-x)))<>0 then
  textbool^[cn,y,x]:=true else
  textbool^[cn,y,x]:=false;
 end;
 mar:=1;
 scl:=15;
 fcl:=4;
end.