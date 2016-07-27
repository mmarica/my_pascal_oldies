{$A+,B-,D+,E+,F+,G+,I+,L-,N-,O+,P+,Q+,R+,S+,T-,V+,X+}
unit mhgraf;

interface
uses dos;
const mblock256=65520;
      maxr256=3000;
      ecrmem256: byte=0;
      ecr320x200x256: byte=1;
      ecr640x480x256: byte=2;
      ecr800x600x256: byte=3;
      ecr1024x768x256: byte=4;
      ecr1280x1024x256: byte=5;
      eranimic: byte=0;
      era0: byte=1;
      eramult: byte=2;
      erainsuf: byte=3;
      erdnimic: byte=0;
      erdincor: byte=1;
type vp=word;
     bitline=array[1..maxr256] of byte;
     membuf256=record
                tip: byte;
                rx,ry: word;
                vx1,vy1,vx2,vy2: word;
                adrese: array[1..40] of record
                                         p: vp;
                                         marime: word;
                                         alocat: boolean;
                                        end;
                alocat: boolean;
               end;
var eraloc,erdealoc: byte;
    eroare,erb256: boolean;
    orzline,verline: bitline;
    w1,w2: ^bitline;
    gol,sterg256,scl256,fcl256: byte;

procedure readline256(mb1: membuf256;x1,x2,y: longint);
procedure writeline256(mb1: membuf256;x1,x2,y: longint);
function mhmemaloc(marime: longint): word;
procedure mhmemdealoc(poz: vp);
procedure calcbuf256(marime: longint; var nrb,mru: word);
procedure initmembuf256(var mb: membuf256;mx,my: longint;sterg: boolean);
procedure clearbuf256(var mb: membuf256);
procedure donemembuf256(var mb: membuf256);
procedure pixelbufpoz256(mb: membuf256;x,y: integer;var buf,dep: word);
procedure lo256(mb: membuf256;x1,x2,y1: longint;color: byte);
procedure lv256(mb: membuf256;y1,y2,x1: longint;color: byte);
procedure showmembuf256(mb: membuf256);
procedure copyimg256(mb1,mb2: membuf256;x1,y1,x2,y2,x3,y3: longint);
procedure putpixel256(mb: membuf256;x,y: longint;color: byte);
function getpixel256(mb: membuf256;x,y: longint): byte;
procedure linie256(mb: membuf256;a,b,c,d:integer);
procedure setcolor256(c: byte);
function getcolor256: byte;
procedure setfillcolor256(c: byte);
function getfillcolor256: byte;

implementation

function sgn(a:integer):integer;
begin
  if a>0 then sgn:=+1;
  if a<0 then sgn:=-1;
  if a=0 then sgn:=0;
end;

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

procedure calcbuf256(marime: longint; var nrb,mru: word);
var i,u: longint;
begin
 i:=trunc(marime/mblock256)+1;
 u:=marime mod mblock256;
 if u=0 then
 begin
  u:=mblock256;
  i:=i-1;
 end;
 nrb:=i;
 mru:=u;
end;

procedure clearbuf256(var mb: membuf256);
var nrb,mru: word;
    a: byte;
    x,y: word;
    p: vp;
    l,z: longint;
    bt: ^byte;
begin
 l:=mb.rx*mb.ry;
 calcbuf256(l,nrb,mru);
 for x:=1 to nrb-1 do
 fillchar(byte(mem[mb.adrese[x].p:0]),mblock256,gol);
 fillchar(byte(mem[mb.adrese[nrb].p:0]),mblock256,gol);
end;

procedure initmembuf256(var mb: membuf256;mx,my: longint;sterg: boolean);
var nrb,mru: word;
    a: byte;
    x,y: word;
    p: vp;
    l,z: longint;
    bt: ^byte;
begin
 eroare:=false;
 a:=0;
 if (mx<1)or(my<1)or(mx>maxr256)or(my>maxr256)or(mb.alocat) then
 begin
  eroare:=true;
  erb256:=true;
  exit;
 end;
 l:=mx*my;
 calcbuf256(l,nrb,mru);
 for x:=1 to nrb-1 do
 if not eroare then
 begin
  p:=mhmemaloc(mblock256);
  if eraloc<>eranimic then eroare:=true;
  if not eroare then
  begin
   mb.adrese[x].p:=p;
   bt:=ptr(mb.adrese[x].p,0);
   mb.adrese[x].alocat:=true;
   mb.adrese[x].marime:=mblock256;
   if sterg then
   fillchar(bt^,mblock256,gol);
   a:=a+1;
  end;
 end;
 if not eroare then
 if nrb>0 then
 begin
  p:=mhmemaloc(mru);
  if eraloc<>eranimic then eroare:=true;
  if not eroare then
  begin
   mb.adrese[nrb].p:=p;
   bt:=ptr(mb.adrese[nrb].p,0);
   mb.adrese[nrb].alocat:=true;
   mb.adrese[nrb].marime:=mru;
   if sterg then
   fillchar(bt^,mru,gol);
   a:=a+1;
  end;
 end;
 if eroare then
 begin
  for x:=nrb downto 1 do
  if mb.adrese[x].alocat then
  begin
   p:=mb.adrese[x].p;
   mhmemdealoc(p);
  end;
  fillchar(mb,sizeof(mb),0);
  erb256:=true;
 end else
 begin
  mb.alocat:=true;
  mb.vx1:=0;
  mb.vy1:=0;
  mb.vx2:=mx-1;
  mb.vy2:=my-1;
  mb.rx:=mx;
  mb.ry:=my;
  mb.tip:=ecrmem256;
  erb256:=false;
 end;
end;

procedure donemembuf256(var mb: membuf256);
var x,y: word;
    p: vp;
begin
 if mb.tip<>ecrmem256 then exit;
 if not mb.alocat then exit;
 for x:=1 to 40 do
 if mb.adrese[x].alocat then
 mhmemdealoc(mb.adrese[x].p);
 fillchar(mb,sizeof(mb),0);
end;

procedure pixelbufpoz256(mb: membuf256;x,y: integer;var buf,dep: word);
var r: longint;
begin
 r:=y*mb.rx+x;
 buf:=trunc(r/mblock256)+1;
 dep:=r mod mblock256;
end;

procedure lo256(mb: membuf256;x1,x2,y1: longint;color: byte);
var b1,d1,b2,d2: word;
    vx,vy,x,y: word;
    b: ^byte;
begin
 if not mb.alocat then exit;
 if mb.tip=ecrmem256 then
 begin
  if x1>x2 then
  begin
   x:=x2;
   x2:=x1;
   x1:=x;
  end;
  if (x2<mb.vx1)or(x1>mb.vx2)or(y1<mb.vy1)or(y1>mb.vy2) then exit;
  if x1<mb.vx1 then x1:=mb.vx1;
  if x2>mb.vx2 then x2:=mb.vx2;
  pixelbufpoz256(mb,x1,y1,b1,d1);
  pixelbufpoz256(mb,x2,y1,b2,d2);
  if b1=b2 then
  begin
   b:=ptr(mb.adrese[b1].p,d1);
   fillchar(b^,d2-d1+1,color);
  end else
  begin
   b:=ptr(mb.adrese[b1].p,d1);
   fillchar(b^,mblock256-d1,color);
   b:=ptr(mb.adrese[b2].p,0);
   fillchar(b^,d2+1,color);
  end;
 end;
end;

procedure lv256(mb: membuf256;y1,y2,x1: longint;color: byte);
var b1,d1,b2,d2: word;
    vx,vy,x,y: word;
    b: ^byte;
begin
 if not mb.alocat then exit;
 if mb.tip=ecrmem256 then
 begin
  if y1>y2 then
  begin
   y:=y2;
   y2:=y1;
   y1:=y;
  end;
  if (y2<mb.vy1)or(y1>mb.vy2)or(x1<mb.vx1)or(x1>mb.vx2) then exit;
  if y1<mb.vy1 then y1:=mb.vy1;
  if y2>mb.vy2 then y2:=mb.vy2;
  for y:=y1 to y2 do
  begin
   pixelbufpoz256(mb,x1,y,b1,d1);
   b:=ptr(mb.adrese[b1].p,d1);
   b^:=color;
  end;
 end;
end;

procedure showmembuf256(mb: membuf256);
var b1,b2: ^byte;
begin
 if (mb.tip<>ecrmem256)or(not mb.alocat)or(mb.rx<>320)or(mb.ry<>200) then exit;
 b1:=ptr(sega000,0);
 b2:=ptr(mb.adrese[1].p,0);
 move(b2^,b1^,64000);
end;

procedure writeline256(mb1: membuf256;x1,x2,y: longint);
var x,vx,xy: longint;
    dif,b1,d1,b2,d2: word;
begin
 if (not mb1.alocat)or(mb1.tip<>ecrmem256) then exit;
 if x1>x2 then
 begin
  x:=x2;
  x2:=x1;
  x1:=x;
 end;
 if x1<mb1.vx1 then x1:=mb1.vx1;
 if x2>mb1.vx2 then x2:=mb1.vx2;
 if y<mb1.vy1 then exit;
 if y>mb1.vy2 then exit;
 if x2<mb1.vx1 then exit;
 if x1>mb1.vx2 then exit;
 pixelbufpoz256(mb1,x1,y,b1,d1);
 pixelbufpoz256(mb1,x2,y,b2,d2);
 dif:=mblock256-d1+1;
 if b1=b2 then
 begin
  w1:=ptr(mb1.adrese[b1].p,d1);
  w2:=ptr(seg(orzline),ofs(orzline));
  move(w2^,w1^,d2-d1+1);
 end else
 begin
  w1:=ptr(mb1.adrese[b1].p,d1);
  w2:=ptr(seg(orzline),ofs(orzline));
  move(w2^,w1^,dif-1);
  w1:=ptr(mb1.adrese[b2].p,d2);
  w2:=ptr(seg(orzline),ofs(orzline)+x2-x1-d2);
  move(w2^,w1^,d2+1);
 end;
end;

procedure readline256(mb1: membuf256;x1,x2,y: longint);
var x,vx,xy: longint;
    dif,b1,d1,b2,d2: word;
begin
 if (not mb1.alocat)or(mb1.tip<>ecrmem256) then exit;
 if x1>x2 then
 begin
  x:=x2;
  x2:=x1;
  x1:=x;
 end;
 if x1<mb1.vx1 then x1:=mb1.vx1;
 if x2>mb1.vx2 then x2:=mb1.vx2;
 if y<mb1.vy1 then exit;
 if y>mb1.vy2 then exit;
 if x2<mb1.vx1 then exit;
 if x1>mb1.vx2 then exit;
 pixelbufpoz256(mb1,x1,y,b1,d1);
 pixelbufpoz256(mb1,x2,y,b2,d2);
 dif:=mblock256-d1+1;
 if b1=b2 then
 begin
  w1:=ptr(mb1.adrese[b1].p,d1);
  w2:=ptr(seg(orzline),ofs(orzline));
  move(w1^,w2^,d2-d1+1);
 end else
 begin
  w1:=ptr(mb1.adrese[b1].p,d1);
  w2:=ptr(seg(orzline),ofs(orzline));
  move(w1^,w2^,dif-1);
  w1:=ptr(mb1.adrese[b2].p,d2);
  w2:=ptr(seg(orzline),ofs(orzline)+x2-x1-d2);
  move(w1^,w2^,d2+1);
 end;
end;

procedure copyimg256(mb1,mb2: membuf256;x1,y1,x2,y2,x3,y3: longint);
var x,y,vx,xy: longint;
    px1,py1,px2,py2: word;
    dif,b1,d1,b2,d2: word;
begin
 if (not mb1.alocat)or(mb1.tip<>ecrmem256)or(not mb2.alocat)or
 (mb2.tip<>ecrmem256) then exit;
 if x1>x2 then
 begin
  x:=x2;
  x2:=x1;
  x1:=x;
 end;
 if y1>y2 then
 begin
  x:=y2;
  y2:=y1;
  y1:=x;
 end;
 if x1<mb1.vx1 then x1:=mb1.vx1;
 if x2>mb1.vx2 then x2:=mb1.vx2;
 if y1<mb1.vy1 then y1:=mb1.vy1;
 if y2>mb1.vy2 then y2:=mb1.vy2;
 if x2<mb1.vx1 then exit;
 if y2<mb1.vx1 then exit;
 if x1>mb1.vx2 then exit;
 if y1>mb1.vy2 then exit;
 if x3>mb2.vx2 then exit;
 if y3>mb2.vy2 then exit;
 if x3<mb2.vx1 then
 begin
  x1:=x1-x3;
  x3:=mb2.vx1;
 end;
 if y3<mb2.vy1 then
 begin
  y1:=y1-y3;
  y3:=mb2.vy1;
 end;
 if x3+x2-x1+1>mb2.vx2 then x2:=mb2.vx2-x3+x1-1;
 if y3+y2-y1+1>mb2.vy2 then y2:=mb2.vy2-y3+y1-1;
 for y:=y1 to y2 do
 begin
  readline256(mb1,x1,x2,y);
  writeline256(mb2,x3,x3+x2-x1,y3+y-y1);
 end;
end;

procedure putpixel256(mb: membuf256;x,y: longint;color: byte);
var b1,d1: word;
    b: ^byte;
begin
 if not mb.alocat then exit;
 if(x<mb.vx1)or(x>mb.vx2)or(y<mb.vy1)or(y>mb.vy2) then exit;
 pixelbufpoz256(mb,x,y,b1,d1);
 b:=ptr(mb.adrese[b1].p,d1);
 b^:=color;
end;

function getpixel256(mb: membuf256;x,y: longint): byte;
var b1,d1: word;
    b: ^byte;
begin
 if not mb.alocat then
 begin
  getpixel256:=0;
  exit;
 end;
 if(x<mb.vx1)or(x>mb.vx2)or(y<mb.vy1)or(y>mb.vy2) then
 begin
  getpixel256:=0;
  exit;
  end;
 pixelbufpoz256(mb,x,y,b1,d1);
 b:=ptr(mb.adrese[b1].p,d1);
 getpixel256:=b^;
end;

procedure linie256(mb: membuf256;a,b,c,d:integer);
var u,s,v,d1x,d1y,d2x,d2y,m,n:integer;
    b1,d1: word;
    i:integer;
begin
 u:= c - a;
 v:= d - b;
 d1x:= SGN(u);
 d1y:= SGN(v);
 d2x:= d1x;
 d2y:= 0;
 m:= ABS(u);
 n := ABS(v);
 IF (M<=N) then
 BEGIN
  d2x := 0 ;
  d2y := SGN(v);
  m := ABS(v);
  n := ABS(u);
 END;
 s := m SHR 1;
 FOR i := 0 TO m DO
 BEGIN
  if (a>=mb.vx1)and(a<=mb.vx2)and(b>=mb.vy1)and(b<=mb.vy2) then
  begin
   pixelbufpoz256(mb,a,b,b1,d1);
   mem[mb.adrese[b1].p:d1]:=scl256;
  end;
  s := s + n;
  IF (s>=m) THEN
  BEGIN
   s := s - m;
   a:= a + d1x;
   b := b + d1y;
  END ELSE
  BEGIN
   a := a + d2x;
   b := b + d2y;
  END;
  end;
END;

procedure setcolor256(c: byte);
begin
 scl256:=c;
end;

function getcolor256: byte;
begin
 getcolor256:=scl256;
end;

procedure setfillcolor256(c: byte);
begin
 fcl256:=c;
end;

function getfillcolor256: byte;
begin
 getfillcolor256:=fcl256;
end;

end.