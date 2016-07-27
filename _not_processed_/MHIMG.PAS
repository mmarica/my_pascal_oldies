{$A+,B-,D+,E+,F+,G+,I+,L+,N-,O+,P+,Q+,R+,S+,T-,V+,X+}
{$M 16384,0,0}
unit mhimg;
interface
uses dos,utilmv;
type ecran=array[0..199,0..319] of byte;
     temp=array[1..320] of byte;
     fnt8_14=array[0..255,0..13,0..7] of boolean;
     fnt5_11=array[0..255,0..10,0..4] of boolean;
var g,h,d,e,cfx,cfy,mar: integer;
    afara: boolean;
    w1,w2: ^temp;
    textbool1: ^fnt8_14;
    textbool2: ^fnt5_11;
    cn,x,y: integer;
    mv,scl,fcl: integer;
    eroaregrafica: boolean;

procedure loriz(p: pointer;x1,x2,y: integer;culoare: byte);
procedure linie(p: pointer;a,b,c,d:integer);
procedure drawpoly4(p: pointer;x1,y1,x2,y2,x3,y3,x4,y4:integer;plin,trasat: boolean);
procedure clearbuf(p: pointer;c: byte);
procedure elipsa(p: pointer;x,y,xr,yr: integer);
procedure elipsap(p: pointer;x,y,xr,yr: integer);
procedure elipsam(p: pointer;x,y,xr,yr: integer);
procedure cerc(p: pointer;x,y,r: integer);
procedure cercp(p: pointer;x,y,r: integer);
procedure cercm(p: pointer;x,y,r: integer);
procedure bara(p: pointer;x1,y1,x2,y2: integer);
procedure baram(p: pointer;x1,y1,x2,y2: integer);
procedure dreptunghi(p: pointer;x1,y1,x2,y2: integer);
procedure ignoremvb(p1,p2: pointer;x1,y1,x2,y2,x3,y3,ic: integer);
procedure loadmvb(p: pointer;s: string;var error: byte);
function getscolor: byte;
function getfcolor: byte;
procedure initgr;
procedure closegr;
procedure schimbmf(marime: integer);
procedure scolor(culoare: integer);
procedure fcolor(culoare: integer);
procedure mvtextxy1(adrs: pointer;px,py: integer;coment: string);
procedure mvtextxy2(adrs: pointer;px,py: integer;coment: string);
procedure copymvb(p1,p2: pointer;x1,y1,x2,y2,x3,y3: integer);
function rad(x: real): real;

implementation

procedure loriz(p: pointer;x1,x2,y: integer;culoare: byte);
var x: ^ecran;
    vx: integer;
begin
 x:=p;
 if x1>x2 then
 begin
  vx:=x1;
  x1:=x2;
  x2:=vx;
 end;
 if (x1>319)or(x2<0)or(y<0)or(y>199) then exit;
 if x1<0 then x1:=0;
 if x2>319 then x2:=319;
 fillchar(x^[y,x1],x2-x1+1,culoare);
end;

function sgn(a:integer):integer;
begin
  if a>0 then sgn:=+1;
  if a<0 then sgn:=-1;
  if a=0 then sgn:=0;
end;

procedure linie(p: pointer;a,b,c,d:integer);
var u,s,v,d1x,d1y,d2x,d2y,m,n:integer;
    i:integer;
    x: ^ecran;
begin
 x:=p;
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
  if (a>=0)and(a<=319)and(b>=0)and(b<=199) then
  x^[b,a]:=scl;
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

procedure drawpoly4(p: pointer;x1,y1,x2,y2,x3,y3,x4,y4:integer;plin,trasat: boolean);
var
  x:integer;
  mny,mxy:integer;
  mnx,mxx,yc:integer;
  mul1,div1,
  mul2,div2,
  mul3,div3,
  mul4,div4:integer;
  buf: ^ecran;
begin
 if (not plin)and(not trasat) then exit;
 buf:=p;
 if plin then
 begin
  mny:=y1; mxy:=y1;
  if y2<mny then mny:=y2;
  if y2>mxy then mxy:=y2;
  if y3<mny then mny:=y3;
  if y3>mxy then mxy:=y3;    { Choose the min y mny and max y mxy }
  if y4<mny then mny:=y4;
  if y4>mxy then mxy:=y4;
  if mny<0 then mny:=0;
  if mxy>199 then mxy:=199;
  if mny>199 then exit;
  if mxy<0 then exit;        { Verticle range checking }
  mul1:=x1-x4; div1:=y1-y4;
  mul2:=x2-x1; div2:=y2-y1;
  mul3:=x3-x2; div3:=y3-y2;
  mul4:=x4-x3; div4:=y4-y3;  { Constansts needed for intersection calc }
  for yc:=mny to mxy do
    begin
      mnx:=320;
      mxx:=-1;
      if (y4>=yc) or (y1>=yc) then
        if (y4<=yc) or (y1<=yc) then   { Check that yc is between y1 and y4 }
          if not(y4=y1) then
            begin
              x:=(yc-y4)*mul1 div div1+x4; { Point of intersection on x axis }
              if x<mnx then
                mnx:=x;
              if x>mxx then
                mxx:=x;       { Set point as start or end of horiz line }
            end;
      if (y1>=yc) or (y2>=yc) then
        if (y1<=yc) or (y2<=yc) then   { Check that yc is between y1 and y2 }
          if not(y1=y2) then
            begin
              x:=(yc-y1)*mul2 div div2+x1; { Point of intersection on x axis }
              if x<mnx then
                mnx:=x;
              if x>mxx then
                mxx:=x;       { Set point as start or end of horiz line }
            end;
      if (y2>=yc) or (y3>=yc) then
        if (y2<=yc) or (y3<=yc) then   { Check that yc is between y2 and y3 }
          if not(y2=y3) then
            begin
              x:=(yc-y2)*mul3 div div3+x2; { Point of intersection on x axis }
              if x<mnx then
                mnx:=x;
              if x>mxx then
                mxx:=x;       { Set point as start or end of horiz line }
            end;
      if (y3>=yc) or (y4>=yc) then
        if (y3<=yc) or (y4<=yc) then   { Check that yc is between y3 and y4 }
          if not(y3=y4) then
            begin
              x:=(yc-y3)*mul4 div div4+x3; { Point of intersection on x axis }
              if x<mnx then
                mnx:=x;
              if x>mxx then
                mxx:=x;       { Set point as start or end of horiz line }
            end;
      if mnx<0 then
        mnx:=0;
      if mxx>319 then
        mxx:=319;          { Range checking on horizontal line }
      if mnx<=mxx then
      loriz(buf,mnx,mxx,yc,fcl);   { Draw the horizontal line }
    end;
 end;
 if trasat then
 begin
  linie(buf,x1,y1,x2,y2);
  linie(buf,x2,y2,x3,y3);
  linie(buf,x3,y3,x4,y4);
  linie(buf,x4,y4,x1,y1);
 end;
end;

procedure clearbuf(p: pointer;c: byte);
var x: ^ecran;
begin
 x:=p;
 fillchar(x^,64000,c);
end;

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

procedure mvtextxy1;
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
   if textbool1^[ord(coment[g]),y,x] then
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

procedure mvtextxy2;
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
   for y:=0 to 10 do
   for x:=0 to 4 do
   if (cfy+y*mar>=0)and(cfy+y*mar<=199)and(cfx+x*mar>=0)and(cfx+x*mar<=319) then
   if textbool2^[ord(coment[g]),y,x] then
   begin
    bara(b1,x*mar+cfx,y*mar+cfy,x*mar+cfx+mar-1,y*mar+cfy+mar-1);
   end;
   cfx:=cfx+5*mar;
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

procedure chartext1; external;
{$L charmv1.obj}

procedure chartext2; external;
{$L charmv2.obj}

var r: registers;
begin
 mv:=3;
 textbool1:=@chartext1;
 textbool2:=@chartext2;
 mar:=1;
 scl:=15;
 fcl:=4;
end.