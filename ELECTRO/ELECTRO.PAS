{$A+,B-,D+,E+,F+,G+,I+,L+,N-,O+,P+,Q+,R+,S+,T-,V+,X+}
{$M 16384,0,0}
program elec;
uses mtast,mvbutil,getpal1,dos,tpkey;
type vp=word;
     podea=record
            x1,y1,x2,y2: integer;
           end;
     lada=record
           x,y: integer;
          end;
     ignoretab=array[1..200] of record
                                 x1,x2,y: integer;
                                end;
const eranimic: byte=0;
      era0: byte=1;
      eramult: byte=2;
      erainsuf: byte=3;
      erdnimic: byte=0;
      erdincor: byte=1;
var eraloc,erdealoc: byte;
    a,b,c,d: ^ecran;
    menupoz,maxmen,vq,mort,fundal,maxfnd,vx,vy,dx,dy,e,u,xp,yp: integer;
    zx,nrg,progres,error,fiserr,vx1,vy1,vt,nrlad,nrpod: integer;
    stele,palfade,play,iesire: boolean;
    timp: longint;
    s: string;
    f: file;
    drx,w,sarmax: word;
    buf: array[1..6400] of char;
    pt,dir,tx,ty,viata,misc,is,x,y,ix,iy: array[1..2] of integer;
    invinc,sfoc,asezat,tras,miscat,sar,cad: array[1..2] of boolean;
    fata: array[1..2] of (stanga,dreapta);
    nume: array[1..2] of string[10];
    menustr: array[1..10] of string;
    menustart: array[1..10] of integer;
    ar: array[1..2] of char;
    ts: array['a'..'z'] of byte;
    coss,sins: array[1..360] of real;
    pal: array[1..25] of mvpal;
    podele: array[1..20] of podea;
    lazi: array[1..20] of lada;
    miscare: array[1..2] of (stg,plc,drp);
    fulgi: boolean;
    bx,by: array[1..100] of integer;
    tg: array[1..2] of integer;
    const parola: string='MSoftfriend';
    var gloante: array[1..2] of array[1..20] of record
                                            x,y,dir: integer;
                                            tras: boolean;
                                           end;
    p1c: pointer;
    ctm,ct1: integer;
    terminat,gata: boolean;
    love: string[15];
    virtpoint: vp;
    imgscan: array[1..7] of ignoretab;
    maxim: array[1..7] of integer;

procedure initrobots;
var x1,x2,x3,x4,y1,y2,y3,y4: integer;
    x,y,z,t,cr,max: integer;
    inv: boolean;
begin
 for t:=0 to 6 do
 begin
  max:=0; {nr. de intrari in imgscan}
  for y:=0 to 41 do
  begin
   cr:=0; {pozitia pe verticala in linia y}
   if max>=200 then break;
   if max<200 then
   repeat
    inv:=false;
    terminat:=false;
    if not inv then
    repeat
     if c^[y,cr+t*24]=63 then
     begin
      cr:=cr+1;
      if cr=23 then inv:=true;
     end;
    until (cr>23)or(c^[y,cr+t*24]<>63);
    if cr<=23 then
    begin
     max:=max+1;
     imgscan[t+1][max].x1:=cr;
     imgscan[t+1][max].y:=y;
     repeat
      if (c^[y,cr+t*24]<>63)and(cr<23) then
      begin
       cr:=cr+1;
       if cr=23 then inv:=true;
      end;
     until (cr>=23)or(c^[y,cr+t*24]=63);
     if cr<23 then
     imgscan[t+1][max].x2:=cr-1 else
     imgscan[t+1][max].x2:=cr;
    end;
    if max>199 then terminat:=true;
    if cr>=23 then terminat:=true;
   until terminat;
   maxim[t+1]:=max;
  end;
 end;
end;

procedure displayrobot(px,py: integer;ms,fata: byte);
var x,y,z,t: integer;
begin
 if fata=0 then
 for zx:=1 to maxim[ms+1] do
 copymvb(c,b,23-imgscan[ms+1][zx].x2+ms*24,imgscan[ms+1][zx].y+42,
 23-imgscan[ms+1][zx].x1+ms*24,imgscan[ms+1][zx].y+42,px+23-imgscan[ms+1][zx].x2,py+imgscan[ms+1][zx].y);
 if fata=1 then
 for zx:=1 to maxim[ms+1] do
 copymvb(c,b,imgscan[ms+1][zx].x1+ms*24,imgscan[ms+1][zx].y,
 imgscan[ms+1][zx].x2+ms*24,imgscan[ms+1][zx].y,px+imgscan[ms+1][zx].x1,py+imgscan[ms+1][zx].y);
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

procedure inskey(ch: char);
var r: registers;
begin
 r.ch:=0;
 r.cl:=ord(ch);
 r.ah:=$05;
 intr($16,r);
end;

procedure inittimer;
begin
 asm
  mov al,00110110b
  out 43h,al
  mov al,0
  out 40h,al
  out 40h,al
 end;
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

procedure setmode(mode: byte);
var r: registers;
begin
 r.ah:=00;
 r.al:=mode;
 intr($10,r);
end;

function rad(x: real): real;
begin
  rad := pi*x/180;
end;

function cosv(u: longint): real;
begin
 if u>360 then
 repeat
  u:=u-360
 until u<=360;
 if u<0 then
 repeat
  u:=u+360
 until u>=0;
 cosv:=coss[u];
end;

function sinv(u: longint): real;
begin
 if u>360 then
 repeat
  u:=u-360
 until u<=360;
 if u<0 then
 repeat
  u:=u+360
 until u>=0;
 sinv:=sins[u];
end;

function conv(w: word): string;
const
 hexChars: array [0..$F] of Char =
   '0123456789ABCDEF';
begin
 conv[1]:=hexChars[Hi(w) shr 4];
 conv[2]:=hexChars[Hi(w) and $F];
 conv[3]:=hexChars[Lo(w) shr 4];
 conv[4]:=hexChars[Lo(w) and $F];
 conv[0]:=#4;
end;

procedure writemvs;
var eroaremvs: boolean;
    mbuf: array[1..24] of char;
    scris: word;
begin
 {$I-}
 assign(f,'optiuni.mvs');
 rewrite(f,1);
 {$I+}
 if ioresult<>0 then eroaremvs:=true;
 if eroaremvs then
 begin
  {$I-}
  assign(f,'optiuni.mvs');
  setfattr(f,0);
  rewrite(f,1);
  {$I+}
 end;
 mbuf[1]:=chr(fundal);
 mbuf[2]:=nume[1][0];
 for vx:=1 to length(nume[1]) do
 mbuf[2+vx]:=upcase(nume[1][vx]);
 for vx:=length(nume[1])+1 to 10 do
 mbuf[2+vx]:=' ';
 mbuf[13]:=nume[2][0];
 for vx:=1 to length(nume[2]) do
 mbuf[13+vx]:=upcase(nume[2][vx]);
 for vx:=length(nume[2])+1 to 10 do
 mbuf[13+vx]:=' ';
 if palfade then mbuf[24]:=#1 else
 mbuf[24]:=#0;
 {$I-}
 blockwrite(f,mbuf,24,scris);
 close(f);
 {$I+}
end;

procedure loadmvs;
var eroaremvs: boolean;
    mbuf: array[1..24] of char;
    citit: word;
begin
 eroaremvs:=false;
 {$I-}
 assign(f,'optiuni.mvs');
 setfattr(f,0);
 reset(f,1);
 {$I+}
 if ioresult<>0 then
 eroaremvs:=true;
 if not eroaremvs then
 begin
  {$I-}
  blockread(f,mbuf,24,citit);
  {$I+}
  fundal:=ord(mbuf[1]);
  nume[1][0]:=mbuf[2];
  if length(nume[1])>10 then nume[1][0]:=#10;
  for vx:=1 to length(nume[1]) do
  nume[1][vx]:=upcase(mbuf[2+vx]);
  for vx:=length(nume[1])+1 to 10 do
  nume[1][vx]:=' ';
  nume[2][0]:=mbuf[13];
  if length(nume[2])>10 then nume[2][0]:=#10;
  for vx:=1 to length(nume[2]) do
  nume[2][vx]:=upcase(mbuf[13+vx]);
  for vx:=length(nume[2])+1 to 10 do
  nume[2][vx]:=' ';
  if mbuf[24]=#0 then palfade:=false else palfade:=true;
  close(f);
  {$I+}
 end;
 if eroaremvs then
 begin
  nume[1]:='MIHAI';
  nume[2]:='VALENTIN';
  fundal:=1;
  palfade:=true;
 end;
 if fundal<1 then fundal:=1;
 if fundal>maxfnd then fundal:=maxfnd;
end;

procedure init;
begin
 virtpoint:=mhmemaloc(64000);
 if eraloc<>eranimic then halt;
 b:=ptr(virtpoint,0);
 progres:=1;
 virtpoint:=mhmemaloc(64000);
 if eraloc<>eranimic then halt;
 c:=ptr(virtpoint,0);
 progres:=2;
 virtpoint:=mhmemaloc(64000);
 if eraloc<>eranimic then halt;
 d:=ptr(virtpoint,0);
 progres:=3;
 inittimer;
end;

procedure amiesit;
var v: byte;
    r: registers;
begin
 disabscankey;
 for vx:=1 to length(love) do
 inskey(love[vx]);
 setintvec($1c,p1c);
 a^:=d^;
 error:=exitcode;
 if error=0 then
 if palfade then
 for e:=25 downto 1 do
 begin
  setpal(pal[e]);
  delay(80);
 end;
 setmode(3);
 writemvs;
 if progres>0 then mhmemdealoc(seg(b^));
 if progres>1 then mhmemdealoc(seg(c^));
 if progres>2 then mhmemdealoc(seg(d^));
 writeln('Mihai Marica - MSoft');
 if error<>0 then
 if (fiserr=0)and(progres>=3) then
 begin
  writeln('MSoft - Eroare! Cod: ',error:3,' la adresa ',conv(seg(erroraddr^)),
  ':',conv(ofs(erroraddr^)));
  writeln('Noteaza adresa si codul ERORII pentru a mi le transmite!');
  if progres<2 then writeln('Memorie insuficienta!');
 end;
 if (fiserr=0)and(progres<3) then
 begin
  writeln('MSoft - Eroare! Insuficienta memorie!');
 end;
 if fiserr<>0 then
 begin
  if fiserr=1 then writeln('Nu gasesc fisierul robot.mvs!');
  if fiserr=2 then writeln('Nu gasesc fisierul fundal.mvs!');
 end;
 if paramstr(1)=parola then
 begin
  writeln('Ai folosit parola! Esti un cunoscut de-al meu!');
  write('Efect de fulgi: ');
  if fulgi then writeln('Da') else writeln('Nu');
  write('J1 invincibil: ');
  if invinc[1] then writeln('Da') else writeln('Nu');
  write('J2 invincibil: ');
  if invinc[2] then writeln('Da') else writeln('Nu');
  write('J1 super foc: ');
  if sfoc[1] then writeln('Da') else writeln('Nu');
  write('J2 super foc: ');
  if sfoc[2] then writeln('Da') else writeln('Nu');
 end;
 r.ah:=$4C;
 r.al:=error;
 intr($21,r);
end;

procedure loadback;
var s: string;
    v: integer;
begin
 {$I-}
 assign(f,'fundal.mvs');
 reset(f,1);
 seek(f,(fundal-1)*64000);
 for vx:=0 to 9 do
 begin
  blockread(f,buf,6400,w);
  move(buf,d^[20*vx,0],6400);
 end;
 close(f);
 {$I+}
 if ioresult<>0 then
 begin
  error:=161;
  fiserr:=2;
  amiesit;
 end;
end;

procedure load;
var s: string;
    v: integer;
begin
 {$I-}
 clearbuf(c,0);
 assign(f,'robot.mvs');
 reset(f,1);
 for vx:=0 to 9 do
 begin
  blockread(f,buf,6400,w);
  move(buf,c^[20*vx,0],6400);
 end;
 close(f);
 fcolor(32*7+31);
 bara(c,293,0,319,41);
 fcolor(32*6+31);
 bara(c,294,1,318,9);
 bara(c,294,32,318,40);
 scolor(0);
 dreptunghi(c,293,0,319,41);
 linie(c,294,9,318,9);
 linie(c,294,32,318,32);
 linie(c,302,9,302,32);
 linie(c,310,9,310,32);
 {$I+}
 if ioresult<>0 then
 begin
  error:=161;
  fiserr:=1;
  amiesit;
 end;
 loadback;
end;

function citescnume(st: string): string;
var s: string[10];
    px: integer;
    cv: integer;
begin
 cv:=9;
 s:=st;
 repeat
  b^:=d^;
  cv:=cv+1;
  if cv>31 then cv:=10;
  for vx:=0 to 25 do
  if key[ts[chr(ord('a')+vx)]] then
  begin
   s:=s+chr(ord('A')+vx);
   repeat until not key[ts[chr(ord('a')+vx)]];
  end;
  if key[tsspace] then
  begin
   s:=s+' ';
   repeat
   until not key[tsspace];
  end;
  if key[tsbkspace] then
  begin
   if length(s)<>0 then
   s[0]:=chr(ord(s[0])-1);
   repeat
   until not key[tsbkspace];
  end;
  px:=160-length(s)*4;
  scolor(32*4+cv);
  mvtextxy(b,px,93,s);
  a^:=b^;
 until key[tsesc] or key[tsenter];
 repeat
 until (not key[tsenter])and(not key[tsesc]);
 citescnume:=s;
end;

procedure joc;
begin
 fillchar(gloante,sizeof(gloante),0);
 fillchar(pt,sizeof(pt),0);
 if fulgi then
 for vx:=1 to 100 do
 begin
  bx[vx]:=random(320);
  by[vx]:=random(200);
 end;
 timp:=3000;
 mort:=-1;
 for e:=1 to 2 do
 begin
  pt[e]:=1;
  y[e]:=184-42;
  viata[e]:=100;
  misc[e]:=0;
  sar[e]:=false;
  cad[e]:=false;
  tras[e]:=false;
 end;
 x[2]:=100;
 x[1]:=200;
 vq:=9;
 fata[2]:=dreapta;
 fata[1]:=stanga;
 repeat
  gata:=false;
  if fulgi then
  for vx:=1 to 100 do
  begin
   by[vx]:=by[vx]+random(4);
   if by[vx]>199 then by[vx]:=by[vx]-199;
  end;
  for e:=1 to 2 do
  begin
   pt[e]:=pt[e]+1;
   if pt[e]>2 then pt[e]:=2;
   miscat[e]:=false;
   miscare[e]:=plc;
  end;
  vq:=vq+1;
  if vq>31 then vq:=10;
  timp:=timp-1;
  for e:=1 to 2 do
  begin
   tras[e]:=true;
   tg[e]:=0;
   for vx:=1 to nrg do
   if not gloante[e][vx].tras then
   if pt[e]=2 then
   begin
    pt[e]:=0;
    tras[e]:=false;
    tg[e]:=vx;
   end;
  end;
  if not tras[1] then
  if key[tsp] then
  begin
   gloante[1][tg[1]].y:=y[1]+20;
   gloante[1][tg[1]].tras:=true;
   if fata[1]=stanga then
   begin
    gloante[1][tg[1]].dir:=-1;
    gloante[1][tg[1]].x:=x[1]+4;
   end else
   begin
    gloante[1][tg[1]].dir:=1;
    gloante[1][tg[1]].x:=x[1]+19;
   end;
  end;
  if not tras[2] then
  if key[tsq] then
  begin
   gloante[2][tg[2]].y:=y[2]+20;
   gloante[2][tg[2]].tras:=true;
   if fata[2]=stanga then
   begin
    gloante[2][tg[2]].dir:=-1;
    gloante[2][tg[2]].x:=x[2]+4;
   end else
   begin
    gloante[2][tg[2]].dir:=1;
    gloante[2][tg[2]].x:=x[2]+19;
   end;
  end;
  for e:=1 to 2 do
  for vx:=1 to nrg do
  begin
   if gloante[e][vx].tras then
   begin
    gloante[e][vx].x:=gloante[e][vx].x+gloante[e][vx].dir*9;
    if (gloante[e][vx].x<0)or(gloante[e][vx].x>317) then
    gloante[e][vx].tras:=false;
    if (gloante[e][vx].x>x[3-e])and(gloante[e][vx].x<x[3-e]+23)and
    (gloante[e][vx].y>y[3-e])and(gloante[e][vx].y<y[3-e]+41) then
    begin
     gloante[e][vx].tras:=false;
     if not invinc[e] then
     begin
      if not sfoc[3-e] then viata[3-e]:=viata[3-e]-1 else
      viata[3-e]:=viata[3-e]-10;
     end;
    end;
   end;
  end;
  for e:=1 to 2 do
  for vy:=1 to nrg do
  begin
   for vx:=1 to nrpod do
   if (gloante[e][vy].x>=podele[vx].x1)and(gloante[e][vy].x<=podele[vx].x2)and
   (gloante[e][vy].y>=podele[vx].y1)and(gloante[e][vy].y<=podele[vx].y2) then
   gloante[e][vy].tras:=false;
   for vx:=1 to nrlad do
   if (gloante[e][vy].x>=lazi[vx].x)and(gloante[e][vy].x<=lazi[vx].x+23)and
   (gloante[e][vy].y>=lazi[vx].y)and(gloante[e][vy].y<=lazi[vx].y+41) then
   gloante[e][vy].tras:=false;
  end;
  b^:=d^;
  fcolor(32*7+31);
  for vx:=1 to nrpod do
  bara(b,podele[vx].x1,podele[vx].y1,podele[vx].x2,podele[vx].y2);
  for vx:=1 to nrlad do
  copymvb(c,b,293,0,319,41,lazi[vx].x,lazi[vx].y);
  if key[tsdreapta] then
  begin
   x[1]:=x[1]+drx;
   if fata[1]=stanga then
   begin
    fata[1]:=dreapta;
    misc[1]:=0;
   end else
   misc[1]:=misc[1]+1;
   miscat[1]:=true;
   miscare[1]:=drp;
  end;
  if key[tsh] then
  begin
   x[2]:=x[2]+drx;
   if fata[2]=stanga then
   begin
    fata[2]:=dreapta;
    misc[2]:=0;
   end else
   misc[2]:=misc[2]+1;
   miscat[2]:=true;
   miscare[2]:=drp;
  end;
  if key[tsstanga] then
  begin
   x[1]:=x[1]-drx;
   if fata[1]=dreapta then
   begin
    fata[1]:=stanga;
    misc[1]:=0;
   end else
   misc[1]:=misc[1]+1;
   miscat[1]:=true;
   miscare[1]:=stg;
  end;
  if key[tsf] then
  begin
   x[2]:=x[2]-drx;
   if fata[2]=dreapta then
   begin
    fata[2]:=stanga;
    misc[2]:=0;
   end else
   misc[2]:=misc[2]+1;
   miscat[2]:=true;
   miscare[2]:=stg;
  end;
  for e:=1 to 2 do
  begin
   if misc[e]>6 then misc[e]:=0;
   if not miscat[e] then misc[e]:=0;
   if x[e]<0 then x[e]:=0;
   if x[e]>296 then x[e]:=296;
   if y[e]>199 then viata[e]:=0;
  end;
  if key[tssus] then
  if (not sar[1])and(not cad[1]) then
  begin
   sar[1]:=true;
   is[1]:=sarmax;
  end;
  if key[tst] then
  if (not sar[2])and(not cad[2]) then
  begin
   sar[2]:=true;
   is[2]:=sarmax;
  end;
  for e:=1 to 2 do
  begin
   if sar[e] then
   begin
    is[e]:=is[e]-1;
    y[e]:=y[e]-is[e];
    if is[e]<=0 then
    begin
     sar[e]:=false;
     cad[e]:=true;
    end;
   end;
   if miscare[e]=drp then
   begin
    asezat[e]:=false;
    for vx:=1 to nrpod do
    if not asezat[e] then
    if (y[e]>=podele[vx].y1-41)and(y[e]<=podele[vx].y2-41+42)and
    (x[e]>=podele[vx].x1-24)and(x[e]<=podele[vx].x1-24+drx) then
    begin
     x[e]:=podele[vx].x1-24;
     asezat[e]:=true;
    end;
    for vx:=1 to nrlad do
    if not asezat[e] then
    if (y[e]>=lazi[vx].y-41)and(y[e]<=lazi[vx].y-41+42)and
    (x[e]>=lazi[vx].x-24)and(x[e]<=lazi[vx].x-1) then
    begin
     x[e]:=lazi[vx].x-24;
     asezat[e]:=true;
    end;
   end;
   if miscare[e]=stg then
   begin
    asezat[e]:=false;
    for vx:=1 to nrpod do
    if not asezat[e] then
    if (y[e]>=podele[vx].y1-41)and(y[e]<=podele[vx].y2-41+42)and
    (x[e]>=podele[vx].x2-24)and(x[e]<=podele[vx].x2) then
    begin
     x[e]:=podele[vx].x2+1;
     asezat[e]:=true;
    end;
    for vx:=1 to nrlad do
    if not asezat[e] then
    if (y[e]>=lazi[vx].y-41)and(y[e]<=lazi[vx].y+42)and
    (x[e]>=lazi[vx].x+19)and(x[e]<=lazi[vx].x+24) then
    begin
     x[e]:=lazi[vx].x-24+50;
     asezat[e]:=true;
    end;
   end;
   if sar[e] then
   begin
    asezat[e]:=false;
    for vx:=1 to nrpod do
    if not asezat[e] then
    if (y[e]>=podele[vx].y1-41)and(y[e]<=podele[vx].y2)and
    (x[e]>=podele[vx].x1-19)and(x[e]<=podele[vx].x2-1) then
    begin
     y[e]:=podele[vx].y2+1;
     asezat[e]:=true;
     sar[e]:=false;
     cad[e]:=true;
     is[e]:=4;
    end;
   end;
   if cad[e] then
   begin
    if is[e]<=sarmax then is[e]:=is[e]+1 else is[e]:=sarmax;
    y[e]:=y[e]+is[e];
    asezat[e]:=false;
    for vx:=1 to nrpod do
    if not asezat[e] then
    if (y[e]>=podele[vx].y1-42)and(y[e]<=podele[vx].y2-42+is[e])and
    (x[e]>=podele[vx].x1-24)and(x[e]<=podele[vx].x2) then
    begin
     cad[e]:=false;
     y[e]:=podele[vx].y1-42;
     asezat[e]:=true;
    end;
    for vx:=1 to nrlad do
    if not asezat[e] then
    if (y[e]>=lazi[vx].y-42)and(y[e]<=lazi[vx].y-42+is[e])and
    (x[e]>=lazi[vx].x-24)and(x[e]<=lazi[vx].x+24) then
    begin
     cad[e]:=false;
     y[e]:=lazi[vx].y-42;
     asezat[e]:=true;
    end;
   end;
   if (not cad[e])and(not sar[e]) then
   begin
    asezat[e]:=false;
    for vx:=1 to nrpod do
    if (y[e]>=podele[vx].y1-42)and(y[e]<=podele[vx].y2)and
    (x[e]>=podele[vx].x1-24)and(x[e]<=podele[vx].x2) then
    asezat[e]:=true;
    for vx:=1 to nrlad do
    if (y[e]>=lazi[vx].y-42)and(y[e]<=lazi[vx].y)and
    (x[e]>=lazi[vx].x-24)and(x[e]<=lazi[vx].x+24) then
    asezat[e]:=true;
    if not asezat[e] then
    begin
     cad[e]:=true;
     is[e]:=0;
    end;
   end;
{   if fata[e]=stanga then
   displayrobot(x[e],y[e],misc[e],0) else
   displayrobot(x[e],y[e],misc[e],1);}
   if fata[e]=stanga then
   begin
    ignoremvb(c,b,0+misc[e]*24,42,misc[e]*24+23,41+42,x[e],y[e],63);
   end;
   if fata[e]=dreapta then
   begin
    ignoremvb(c,b,0+misc[e]*24,0,misc[e]*24+23,41,x[e],y[e],63);
   end;
   if viata[e]<0 then viata[e]:=0;
   if viata[e]>100 then viata[e]:=100;
   for vx:=1 to nrg do
   if gloante[e][vx].tras then
   begin
    fcolor(31);
    bara(b,gloante[e][vx].x,gloante[e][vx].y,gloante[e][vx].x+2,
    gloante[e][vx].y+1);
   end;
  end;
  if (viata[1]<1)and(viata[2]<1) then mort:=0 else
  if viata[1]<1 then mort:=1 else
  if viata[2]<1 then mort:=2;
  for vx:=1 to viata[2] do
  begin
   fcolor(32*4+11+vx div 6);
   bara(b,9+vx,5,9+vx+2,9);
  end;
  for vx:=1 to viata[1] do
  begin
   fcolor(32*4+11+vx div 6);
   bara(b,310-vx,5,308-vx,9);
  end;
  scolor(32*4+31);
  dreptunghi(b,9,4,112,10);
  dreptunghi(b,310,4,207,10);
  mvtextxy(b,x[1]+11-length(nume[2])*4,y[1]-15,nume[2]);
  scolor(32*5+31);
  mvtextxy(b,x[2]+11-length(nume[1])*4,y[2]-15,nume[1]);
  str(timp div 30,s);
  fcolor(32*7+vq);
  scolor(32*4+vq);
  bara(b,149,4,169,20);
  mvtextxy(b,152,5,s);
  str(viata[2]:3,s);
  bara(b,28,20,62,35);
  mvtextxy(b,30,21,s+'%');
  str(viata[1]:3,s);
  bara(b,256,20,290,35);
  mvtextxy(b,258,21,s+'%');
  copymvb(c,b,6,0,18,15,11,20);
  copymvb(c,b,5,0+42,17,15+42,296,20);
  scolor(32*7+15);
  dreptunghi(b,149,4,169,20);
  dreptunghi(b,28,20,62,35);
  dreptunghi(b,256,20,290,35);
  if fulgi then
  for vx:=1 to 100 do
  begin
   fcolor(vq);
   bara(b,bx[vx],by[vx],bx[vx]+1,by[vx]+1);
  end;
  a^:=b^;
  if key[tsesc] then
  begin
   mort:=0;
   repeat
   until not key[tsesc];
  end;
  if timp<0 then
  begin
   if viata[1]=viata[2] then mort:=0;
   if viata[1]<viata[2] then mort:=1;
   if viata[2]<viata[1] then mort:=2;
  end;
  repeat
  until gata;
  gata:=false;
 until mort<>-1;
end;

procedure moarte(mort: byte);
var numestr: string;
begin
 if mort=0 then
 begin
  for vx:=0 to 31 do
  begin
   b^:=d^;
   scolor(32*4+vx);
   mvtextxy(b,10,80,'Nici unul din jucatori nu a castigat!');
   a^:=b^;
   delay(5);
   if key[tsesc] then
   begin
    repeat
    until not key[tsesc];
    exit;
   end;
  end;
  delay(1000);
 end;
 if mort=1 then
 begin
  for vx:=0 to 31 do
  begin
   b^:=d^;
   scolor(32*6+vx);
   numestr:='A castigat '+nume[1]+'!';
   mvtextxy(b,160-length(numestr)*4,90,numestr);
   a^:=b^;
   delay(5);
   if key[tsesc] then
   begin
    repeat
    until not key[tsesc];
    exit;
   end;
  end;
  delay(1000);
 end;
 if mort=2 then
 begin
  for vx:=0 to 31 do
  begin
   b^:=d^;
   scolor(32*6+vx);
   numestr:='A castigat '+nume[2]+'!';
   mvtextxy(b,160-length(numestr)*4,90,numestr);
   a^:=b^;
   delay(5);
   if key[tsesc] then
   begin
    repeat
    until not key[tsesc];
    exit;
   end;
  end;
  delay(1000);
 end;
end;

procedure special;
var menupoz,maxmen: integer;
    menustr: array[1..10] of string;
    menustart: array[1..10] of integer;
begin
 maxmen:=5;
 menustr[1]:='Efect de fulgi   ';
 menustr[2]:='J1 invincibil   ';
 menustr[3]:='J2 invincibil   ';
 menustr[4]:='J1 foc puternic   ';
 menustr[5]:='J2 foc puternic   ';
 for e:=1 to maxmen do
 menustart[e]:=160-length(menustr[e])*4;
 repeat
  b^:=d^;
  if key[tssus] then
  begin
   menupoz:=menupoz-1;
   repeat
   until not key[tssus];
  end;
  if key[tsjos] then
  begin
   menupoz:=menupoz+1;
   repeat
   until not key[tsjos];
  end;
  if menupoz<1 then menupoz:=maxmen;
  if menupoz>maxmen then menupoz:=1;
  if key[tsenter] and (menupoz=1) then
  begin
   if not fulgi then fulgi:=true else fulgi:=false;
   repeat
   until not key[tsenter];
  end;
  for e:=1 to 2 do
  begin
   if key[tsenter] and (menupoz=1+e) then
   begin
    if not invinc[e] then invinc[e]:=true else invinc[e]:=false;
    repeat
    until not key[tsenter];
   end;
   if key[tsenter] and (menupoz=3+e) then
   begin
    if not sfoc[e] then sfoc[e]:=true else sfoc[e]:=false;
    repeat
    until not key[tsenter];
   end;
  end;
  if fulgi then
  begin
   menustr[1][length(menustr[1])-1]:='D';
   menustr[1][length(menustr[1])]:='a';
  end else
  begin
   menustr[1][length(menustr[1])-1]:='N';
   menustr[1][length(menustr[1])]:='u';
  end;
  for e:=1 to 2 do
  begin
   if invinc[e] then
   begin
    menustr[1+e][length(menustr[1+e])-1]:='D';
    menustr[1+e][length(menustr[1+e])]:='a';
   end else
   begin
    menustr[1+e][length(menustr[1+e])-1]:='N';
    menustr[1+e][length(menustr[1+e])]:='u';
   end;
   if sfoc[e] then
   begin
    menustr[3+e][length(menustr[3+e])-1]:='D';
    menustr[3+e][length(menustr[3+e])]:='a';
   end else
   begin
    menustr[3+e][length(menustr[3+e])-1]:='N';
    menustr[3+e][length(menustr[3+e])]:='u';
   end;
  end;
  scolor(32*7+20);
  for e:=1 to maxmen do
  mvtextxy(b,menustart[e],20+e*20,menustr[e]);
  scolor(32*7+31);
  mvtextxy(b,menustart[menupoz],20+menupoz*20,menustr[menupoz]);
  a^:=b^;
 until key[tsesc];
end;

procedure optiuni;
var menupoz,maxmen: integer;
    menustr: array[1..10] of string;
    menustart: array[1..10] of integer;
    st: string;
begin
 maxmen:=2;
 menustr[1]:='Fundal   ';
 menustr[2]:='Schimbari paleta   ';
 for e:=1 to maxmen do
 menustart[e]:=160-length(menustr[e])*4;
 repeat
  b^:=d^;
  if key[tssus] then
  begin
   menupoz:=menupoz-1;
   repeat
   until not key[tssus];
  end;
  if key[tsjos] then
  begin
   menupoz:=menupoz+1;
   repeat
   until not key[tsjos];
  end;
  if menupoz<1 then menupoz:=maxmen;
  if menupoz>maxmen then menupoz:=1;
  if key[tsstanga] and (menupoz=1) then
  begin
   fundal:=fundal-1;
   if fundal<1 then fundal:=maxfnd;
   loadback;
   repeat
   until not key[tsstanga];
  end;
  if key[tsdreapta] and (menupoz=1) then
  begin
   fundal:=fundal+1;
   if fundal>maxfnd then fundal:=1;
   loadback;
   repeat
   until not key[tsdreapta];
  end;
  if key[tsenter] and (menupoz=2) then
  begin
   if not palfade then palfade:=true else palfade:=false;
   repeat
   until not key[tsenter];
  end;
  scolor(32*7+20);
  if palfade then
  begin
   menustr[2][length(menustr[2])-1]:='D';
   menustr[2][length(menustr[2])]:='a';
  end else
  begin
   menustr[2][length(menustr[2])-1]:='N';
   menustr[2][length(menustr[2])]:='u';
  end;
  str(fundal:2,st);
  menustr[1][length(menustr[1])-1]:=st[1];
  menustr[1][length(menustr[1])]:=st[2];
  b^:=d^;
  for e:=1 to maxmen do
  mvtextxy(b,menustart[e],20+e*20,menustr[e]);
  scolor(32*7+31);
  mvtextxy(b,menustart[menupoz],20+menupoz*20,menustr[menupoz]);
  a^:=b^;
 until key[tsesc];
end;

procedure menu;
begin
 repeat
  b^:=d^;
  if key[tssus] then
  begin
   menupoz:=menupoz-1;
   repeat
   until not key[tssus];
  end;
  if key[tsjos] then
  begin
   menupoz:=menupoz+1;
   repeat
   until not key[tsjos];
  end;
  if menupoz<1 then menupoz:=maxmen;
  if menupoz>maxmen then menupoz:=1;
  scolor(32*7+20);
  for e:=1 to maxmen do
  mvtextxy(b,menustart[e],20+e*20,menustr[e]);
  scolor(32*7+31);
  mvtextxy(b,menustart[menupoz],20+menupoz*20,menustr[menupoz]);
  if key[tsenter] and (menupoz=1) then
  begin
   play:=true;
   repeat
   until not key[tsenter];
  end;
  if key[tsenter] and (menupoz=2) then
  begin
   repeat
   until not key[tsenter];
   nume[1]:=citescnume(nume[1]);
  end;
  if key[tsenter] and (menupoz=3) then
  begin
   repeat
   until not key[tsenter];
   nume[2]:=citescnume(nume[2]);
  end;
  if key[tsenter] and (menupoz=4) then
  begin
   repeat
   until not key[tsenter];
   optiuni;
   repeat
   until not key[tsesc];
  end;
  if key[tsenter] and (menupoz=5) then
  begin
   iesire:=true;
   repeat
   until not key[tsenter];
  end;
  if key[tsenter] and (menupoz=6) then
  begin
   repeat
   until not key[tsenter];
   special;
   repeat
   until not key[tsesc];
  end;
  if key[tsesc] then
  begin
   iesire:=true;
   repeat
   until not key[tsesc];
  end;
  a^:=b^;
 until iesire or play;
 if play then
 begin
  joc;
  moarte(mort);
 end;
end;

procedure inittst;
begin
 ts['a']:=tsa;
 ts['b']:=tsb;
 ts['c']:=tsc;
 ts['d']:=tsd;
 ts['e']:=tse;
 ts['f']:=tsf;
 ts['g']:=tsg;
 ts['h']:=tsh;
 ts['i']:=tsi;
 ts['j']:=tsj;
 ts['k']:=tsk;
 ts['l']:=tsl;
 ts['m']:=tsm;
 ts['n']:=tsn;
 ts['o']:=tso;
 ts['p']:=tsp;
 ts['q']:=tsq;
 ts['r']:=tsr;
 ts['s']:=tss;
 ts['t']:=tst;
 ts['u']:=tsu;
 ts['v']:=tsv;
 ts['w']:=tsw;
 ts['x']:=tsx;
 ts['y']:=tsy;
 ts['z']:=tsz;
end;

begin
 if not alocattext then
 begin
  writeln('Nu e destula memorie! Mai trebuie inca cel putin 200kb de memorie.');
  halt;
 end;
 love:='I love MSoft!';
 getintvec($1c,p1c);
 setintvec($1c,@int1c);
 ctm:=1;
 fulgi:=false;
 nrg:=5;
 error:=0;
 fiserr:=0;
 progres:=0;
 stele:=false;
 drx:=7;
 sarmax:=10;
 nrpod:=4;
 podele[1].x1:=0;podele[1].y1:=184;podele[1].x2:=319;podele[1].y2:=186;
 podele[2].x1:=0;podele[2].y1:=129;podele[2].x2:=120;podele[2].y2:=131;
 podele[3].x1:=204;podele[3].y1:=129;podele[3].x2:=319;podele[3].y2:=131;
 podele[4].x1:=60;podele[4].y1:=74;podele[4].x2:=259;podele[4].y2:=76;
 nrlad:=3;
 lazi[1].x:=149;lazi[1].y:=142;
 lazi[2].x:=0;lazi[2].y:=87;
 lazi[3].x:=293;lazi[3].y:=87;
 exitproc:=@amiesit;
 init;
 inittst;
 a:=ptr($A000,0);
 clearbuf(d,0);
 maxfnd:=20;
 write('Incarc optiunile...');
 loadmvs;
 writeln;
{ if stele then
 for e:=1 to 360 do
 begin
  coss[e]:=cos(rad(e));
  sins[e]:=sin(rad(e));
 end;}
 if fulgi then
 writeln('Folosesc efectul cu fulgii...');
 if palfade then
 begin
  write('Folosesc schimbari de paleta: calculez paletele...');
  for e:=1 to 25 do
  for vx:=0 to 255 do
  begin
   pal[e][vx][1]:=trunc(normpal1[vx][1]*e/25);
   pal[e][vx][2]:=trunc(normpal1[vx][2]*e/25);
   pal[e][vx][3]:=trunc(normpal1[vx][3]*e/25);
  end;
  writeln;
 end;
 write('Incarc fundalul si robotii...');
 load;
 writeln;
{ initrobots;}
 initgr;
 initscankey;
 maxmen:=5;
 menupoz:=1;
 menustr[1]:='Joc nou';
 menustr[2]:='Numele lui J1';
 menustr[3]:='Numele lui J2';
 menustr[4]:='Optiuni';
 menustr[5]:='Iesire';
 if paramstr(1)=parola then
 begin
  maxmen:=6;
  menustr[6]:='Special MSoft';
 end;
 for e:=1 to maxmen do
 menustart[e]:=160-length(menustr[e])*8 div 2;
 if palfade then
 begin
  setpal(pal[1]);
  a^:=d^;
  for e:=1 to 25 do
  begin
   setpal(pal[e]);
   delay(80);
  end;
 end;
 setpal(normpal1);
 repeat
  play:=false;
  iesire:=false;
  menu;
 until iesire;
end.