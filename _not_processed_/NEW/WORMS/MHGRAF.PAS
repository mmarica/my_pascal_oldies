{$A+,B-,D+,E+,F+,G+,I+,L-,N-,O+,P+,Q+,R+,S+,T-,V+,X+}
{$M 65520,0,0}
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
                                         alocat: boolean;
                                        end;
                alocat: boolean;
               end;
var eraloc,erdealoc: byte;
    eroare,erb256: boolean;
    orzline,verline: bitline;
    w1,w2: ^bitline;
    sterg256,scl256,fcl256: byte;

 function mhmemaloc(marime: longint): word;
 procedure mhmemdealoc(poz: vp);
 procedure calcbuf256(marime: longint; var nrb,mru: word);
 procedure initmembuf256(var mb: membuf256;mx,my: longint;sterg: boolean);
 procedure pixelbufpoz256(mb: membuf256;x,y: longint;var buf,dep: word);
 procedure lo256(mb: membuf256;x1,x2,y1: longint;color: byte);
 procedure lv256(mb: membuf256;y1,y2,x1: longint;color: byte);
 procedure showmembuf256(mb: membuf256);
 procedure copyimg256(mb1,mb2: membuf256;x1,y1,x2,y2,x3,y3: longint);
 procedure putpixel256(mb: membuf256;x,y: longint;color: byte);
 function getpixel256(mb: membuf256;x,y: longint): byte;
 procedure setcolor256(c: byte);
 function getcolor256: byte;
 procedure setfillcolor256(c: byte);
 function getfillcolor256: byte;

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

 procedure calcbuf256(marime: longint; var nrb,mru: word);
 var i,u: longint;
 begin
  i:=trunc(marime/mblock256)+1;
  u:=marime mod mblock256;
  if u=0 then u:=mblock256;
  nrb:=i;
  mru:=u;
 end;

 procedure initmembuf256(var mb: membuf256;mx,my: longint;sterg: boolean);
 var nrb,mru: word;
     a: byte;
     x,y: word;
     p: vp;
     l,z: longint;
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
    mb.adrese[x].alocat:=true;
    a:=a+1;
   end;
  end;
  if not eroare then
  begin
   p:=mhmemaloc(mru);
   if eraloc<>eranimic then eroare:=true;
   if not eroare then
   begin
    mb.adrese[nrb].p:=p;
    mb.adrese[nrb].alocat:=true;
    a:=a+1;
   end;
  end;
  if eroare then
  begin
   for x:=a downto 1 do
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

 procedure pixelbufpoz256(mb: membuf256;x,y: longint;var buf,dep: word);
 var r: longint;
 begin
  r:=mb.rx*y+x;
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
   if (x2>mb.vx1)or(x1>mb.vx2)or(y<mb.vy1)or(y>mb.vy2) then exit;
   if x1<mb.vx1 then x1:=mb.vx1;
   if x2<mb.vx2 then x2:=mb.vx2;
   pixelbufpoz256(mb,x1,y1,b1,d1);
   pixelbufpoz256(mb,x2,y1,b2,d2);
   if b1=b2 then
   begin
    b:=ptr(mb.adrese[b1].p,d1);
    fillchar(b^,d2-d1+1,color);
   end else
   begin
    b:=ptr(mb.adrese[b1].p,d1);
    fillchar(b^,mblock256-d1+1,color);
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
  b1:=ptr(SEGA000,0);
  b2:=ptr(mb.adrese[1].p,0);
  move(b2^,b1^,64000);
 end;

 procedure copyimg256(mb1,mb2: membuf256;x1,y1,x2,y2,x3,y3: longint);
 var x,y,vx,xy: longint;
     px1,py1,px2,py2: word;
     b1,d1,b2,d2: word;
 begin
  if (not mb1.alocat)or(mb1.tip<>ecrmem256)or(not mb2.alocat)or
  (mb2.tip<>ecrmem256) then exit;
  if (x3>mb2.vx2)or(y3>mb2.vy2) then exit;
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
  if (x2<mb1.vx1)or(x1>mb1.vx2)or(y2<mb1.vy1)or(y1>mb1.vy2) then exit;
  if x3<mb2.vx1 then
  begin
   x1:=x1+mb2.vx1-x3;
   x3:=mb2.vx1;
  end;
  if y3<mb2.vy1 then
  begin
   y1:=y1+mb2.vy1-y3;
   y3:=mb2.vy1;
  end;
  if x1<mb1.vx1 then x1:=mb1.vx1;
  if y1<mb1.vy1 then y1:=mb1.vy1;
  if x2>mb1.vx2 then x2:=mb1.vx2;
  if y2>mb1.vy2 then y2:=mb1.vy2;
  px1:=x1;px2:=x2;py1:=y1;py2:=y2;
  for y:=y1 to y2 do
  begin
   pixelbufpoz256(mb1,x1,y,b1,d1);
   pixelbufpoz256(mb1,x2,y,b2,d2);
   if b1=b2 then
   begin
    w1:=ptr(mb1.adrese[b1].p,d1);
    w2:=ptr(seg(orzline),ofs(orzline));
    move(w1^,w2^,d2-d1+1);
   end else
   begin
    w1:=ptr(mb1.adrese[b1].p,d1);
    w2:=ptr(seg(orzline),ofs(orzline));
    move(w1^,w2^,mblock256-d1);
    w1:=ptr(mb1.adrese[b2].p,d2);
    w2:=ptr(seg(orzline),ofs(orzline));
    move(w1^,w2^,d2+1);
   end;
   pixelbufpoz256(mb2,x3,y3+y-y1,b1,d1);
   pixelbufpoz256(mb2,x3+x2-x1,y3+y-y1,b2,d2);
   if b1=b2 then
   begin
    w1:=ptr(seg(orzline),ofs(orzline));
    w2:=ptr(mb2.adrese[b1].p,d1);
    move(w1^,w2^,d2-d1+1);
   end else
   begin
    w1:=ptr(seg(orzline),ofs(orzline));
    w2:=ptr(mb2.adrese[b1].p,d1);
    move(w1^,w2^,mblock256-d1);
    w1:=ptr(seg(orzline),ofs(orzline));
    w2:=ptr(mb2.adrese[b2].p,d2);
    move(w1^,w2^,d2+1);
   end;
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