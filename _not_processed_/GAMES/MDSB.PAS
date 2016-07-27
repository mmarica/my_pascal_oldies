{$A+,B-,D+,E+,F+,G+,I+,L+,N-,O+,P+,Q+,R+,S+,T-,V+,X+,Y+}
{$M 16384,0,0}
program MSoft_double_player_super_ball;
uses dos,mhstring,mhmatem,mhimg,mhmem,mtast,textgraf,mhpal;
const copyright: string='Copyright (c) Mihai Marica - MSoft - 2000 *** ';
      jocstr: string='Super Ball *** ';
      cercstr: string[36]='Mihai Marica - MSoft - 2000 *** @@ ';
var a,b,c,d: ^ecran;
    points: array[1..400] of record
                                 u,r: byte;
                                 px,py: integer;
                                end;
    leg: array[1..1000] of record
                           p1,p2: integer;
                          end;
    nrleg,nrp,x,y,z,t: integer;
    s1,s2,s3,s4: string;
    oldexit,old1c: pointer;
    nom,misfil,gata: boolean;
    pl1,pl2: byte;
    mfil: string;
    ctm,ct1: integer;
    bsx,bsy,bxv,byv,byd,bxd: integer;
    scor: array[1..2] of longint;
    bx,by: real;
    pad: array[1..2] of record
                         x,y: real;
                         misc,xs,ys,dir,vit: integer;
                        end;

procedure int1c; interrupt;
begin
 if not gata then
 begin
  ct1:=ct1+1;
  if ct1>=ctm then
  begin
   ct1:=0;
   gata:=true;
  end;
 end;
end;

procedure myexit;
var eroare: longint;
    s: string;
begin
 exitproc:=oldexit;
 setintvec($1c,old1c);
 disabscankey;
 inittext80x25;
 cursor(true);
 clipire(false);
 writeln('MSoft 2000 - Super Ball la dublu sau cu computerul!');
 writeln('Programator Mihai Marica, tel. 044/271667');
 eroare:=exitcode;
 if eroare<>0 then
 begin
  str(eroare,s);
  writeln('Eroare cod: ',s,' la adresa ',wordtost(seg(erroraddr^)),':',
             wordtost(ofs(erroraddr^)),'!');
  writeln('Noteaza codul erorii si adresa si transmite-mi-le (daca vrei sa repar eroarea)!');
 end;
 if misfil then writeln('Nu pot gasi fisierul ',upstring(mfil),'!');
 if nom then writeln('Nu e destula memorie!');
end;

procedure nomem;
begin
 nom:=true;
 halt;
end;

function unadintoate(cate,total: integer): real;
begin
 if(cate<=0)or(total<=0) then
 begin
  unadintoate:=0;
  exit;
 end;
 unadintoate:=cate/total;
end;

procedure miscari;
var maxim: integer;
    mbx,mby: integer;
    dif,unax,unay,unpx,unpy: real;

procedure calcmx;
begin
 mbx:=bxd*bxv;
 if mbx<0 then mbx:=-mbx;
end;

procedure calcmy;
begin
 mby:=byd*byv;
 if mby<0 then mby:=-mby;
end;

begin
 byv:=10-bxv;
 maxim:=1;
 calcmx;
 calcmy;
 if maxim<mbx then maxim:=mbx;
 if maxim<mby then maxim:=mby;
 for x:=1 to 2 do
 if maxim<pad[x].vit then maxim:=pad[x].vit;
 unax:=unadintoate(mbx,maxim);
 unay:=unadintoate(mby,maxim);
 unpx:=unadintoate(pad[1].vit,maxim);
 for x:=0 to maxim-1 do
 begin
  bx:=bx+bxd*unax;
  by:=by+byd*unay;
  for y:=1 to 2 do
  begin
   pad[y].x:=pad[y].x+pad[y].dir*unpx;
   if pad[y].x-pad[y].xs<0 then pad[y].x:=pad[y].xs;
   if pad[y].x>319-pad[y].xs then pad[y].x:=319-pad[y].xs;
  end;
  if bx<0+bsx then
  begin
   bx:=unax+bsx;
   bxd:=1;
  end;
  if bx>319-bsx then
  begin
   bx:=319-unax-bsx;
   bxd:=-1;
  end;
  if by<0+bsy then
  begin
   by:=unay+bsy;
   byd:=1;
  end;
  if by>199-bsy then
  begin
   by:=199-unay-bsy;
   byd:=-1;
  end;
  for z:=1 to 2 do
  with pad[z] do
  begin
   if(by>=y-ys)and(by<=y+ys)and(bx>=x-xs)and(bx<=x+xs) then
   begin
    byd:=-byd;
    if bx<=x then
    begin
     if bxd=1 then bxd:=-1;
    end;
    if bx>x then
    begin
     if bxd=-1 then bxd:=1;
    end;
    dif:=x-bx;
    if dif<0 then dif:=-dif;
    if dif<1 then dif:=1;
    bxv:=trunc(9*(dif+1)/xs);
    byv:=10-bxv;
    if byd=1 then by:=y+ys else by:=y-ys;
   end;
  end;
 end;
end;

procedure joc;
var iesire: boolean;
begin
 for x:=1 to 2 do
 scor[x]:=0;
 bx:=159;
 by:=99;
 bxv:=3;
 byv:=2;
 bxd:=1;
 byd:=1;
 repeat
  for x:=1 to 2 do
  pad[x].dir:=0;
  for x:=1 to 2 do
  if pad[x].misc=0 then
  begin
   if bx<pad[x].x-pad[x].xs div 2 then pad[x].dir:=-1;
   if bx>pad[x].x+pad[x].xs div 2 then pad[x].dir:=+1;
  end;
  if pad[2].misc=1 then
  begin
   if key[tsstanga] then pad[2].dir:=-1;
   if key[tsdreapta] then pad[2].dir:=+1;
  end;
  if pad[1].misc=1 then
  begin
   if key[tsv] then pad[1].dir:=-1;
   if key[tsb] then pad[1].dir:=+1;
  end;
  miscari;
  iesire:=false;
  clearbuf(b,0);
  fcolor(31);
  elipsap(b,round(bx-1),round(by-1),bsx,bsy);
  for x:=1 to 2 do
  with pad[x] do
  bara(b,round(x-xs),round(y-ys),round(x+xs),round(y+ys));
  a^:=b^;
  repeat
   if key[tsesc] then
   begin
    iesire:=true;
    repeat until not key[tsesc];
   end;
   if iesire then gata:=true;
  until gata;
  gata:=false;
 until iesire;
end;

procedure menu;
var iesire: boolean;
    u,r,dep1: integer;
begin
 dep1:=1;
 u:=0;
 r:=80;
 repeat
  iesire:=false;
  clearbuf(b,0);
  dep1:=dep1-1;
  if dep1<-length(copyright)*10 then dep1:=0;
  u:=u+2;
  if u>360 then u:=1;
  for t:=1 to nrp do
  begin
   points[t].px:=159+round((r+points[t].r)*sinv(u+360-points[t].u*2));
   points[t].py:=99+round((r+points[t].r)*cosv(u+360-points[t].u*2));
   b^[points[t].py,points[t].px]:=32*2+31;
  end;
  scolor(32*2+31);
  for x:=1 to nrleg do
  begin
   linie(b,points[leg[x].p1].px,points[leg[x].p1].py,points[leg[x].p2].px,points[leg[x].p2].py);
  end;
  z:=0;
  repeat
   z:=z+1;
   for x:=1 to length(copyright) do
   begin
    y:=(z-1)*length(copyright)*10+(x-1)*10+dep1;
    if y>319 then break;
    if y>-10 then
    scolor(32*4+31);
    mvtextxy2(b,y,0,copyright[x]);
   end;
  until y>319;
  z:=0;
  repeat
   z:=z+1;
   for x:=1 to length(jocstr) do
   begin
    y:=(z-1)*length(jocstr)*10+(x-1)*10-length(jocstr)*10-dep1;
    if y>319 then break;
    if y>-10 then
    scolor(32*4+31);
    mvtextxy2(b,y,190,jocstr[x]);
   end;
  until y>319;
  repeat
   if key[tsesc] then
   begin
    iesire:=true;
    repeat until not key[tsesc];
   end;
   if key[tsenter] then
   begin
    repeat
    until not key[tsenter];
    joc;
    repeat
    until not key[tsesc];
   end;
   if iesire then gata:=true;
  until gata;
  a^:=b^;
  gata:=false;
 until iesire;
end;

begin
 nrp:=0;
 nrleg:=0;
 for z:=1 to length(cercstr) do
 begin
  for x:=0 to 4 do
  for y:=0 to 10 do
  if textbool2^[ord(cercstr[z]),y,x] then
  if nrp<400 then
  begin
   nrp:=nrp+1;
   points[nrp].u:=(z-1)*5+x;
   points[nrp].r:=10-y;
  end;
 end;
 for t:=1 to nrp do
 for z:=t to nrp do
 if(points[z].u>=points[t].u-1)and(points[z].u<=points[t].u+1)and
 (points[z].r>=points[t].r-1)and(points[z].r<=points[t].r+1) then
 if nrleg<1000 then
 begin
  nrleg:=nrleg+1;
  leg[nrleg].p1:=t;
  leg[nrleg].p2:=z;
 end;
 for x:=1 to 2 do
 begin
  pad[x].xs:=15;
  pad[x].ys:=3;
  pad[x].x:=159;
  pad[x].vit:=7;
  pad[x].dir:=0;
  pad[x].misc:=0;
 end;
 pad[2].misc:=1;
 pad[1].y:=20;
 pad[2].y:=179;
 bsx:=2;
 bsy:=2;
 getintvec($1c,old1c);
 oldexit:=exitproc;
 exitproc:=@myexit;
 initscankey;
 setintvec($1c,@int1c);
 a:=ptr($A000,0);
 b:=ptr(mhmemaloc(64000),0);
 if eraloc<>eranimic then nomem;
 c:=ptr(mhmemaloc(64000),0);
 if eraloc<>eranimic then nomem;
{ d:=ptr(mhmemaloc(64000),0);
 if eraloc<>eranimic then nomem;}
 clearbuf(b,0);
 clearbuf(c,0);
{ clearbuf(d,0);}
 initscankey;
 initgr;
 setpal(normpal1);
 menu;
 disabscankey;
end.