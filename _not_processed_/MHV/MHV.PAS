{$A+,B-,D-,E+,F+,G+,I-,L+,N-,O+,P+,Q+,R+,S+,T-,V+,X+,Y-}
{$M 20000,0,0}
program mhviewer;
uses mhvunit,mhstring,textgraf,mhgraf,mhdisk,mhmem,mhimg,mhpal,dos,tpkey;

procedure chdir(s: string);
begin
 system.chdir(s);
 rezultat:=ioresult;
end;

procedure getdir(d: byte;var s: string);
begin
 system.getdir(d,s);
 rezultat:=ioresult;
end;

procedure blockread(var f: file;var buf;count: word;var result: word);
begin
 system.blockread(f,buf,count,result);
 rezultat:=ioresult;
end;

procedure blockwrite(var f: file;var buf;count: word;var result: word);
begin
 system.blockwrite(f,buf,count,result);
 rezultat:=ioresult;
end;

procedure seek(var f: file;n: longint);
begin
 system.seek(f,n);
 rezultat:=ioresult;
end;

procedure reset(var f: file;recsize: word);
begin
 system.reset(f,recsize);
 rezultat:=ioresult;
end;

procedure rewrite(var f: file;recsize: word);
begin
 system.rewrite(f,recsize);
 rezultat:=ioresult;
end;

procedure close(var f: file);
begin
 system.close(f);
 rezultat:=ioresult;
end;

function filesize(var f: file): longint;
begin
 filesize:=system.filesize(f);
 rezultat:=ioresult;
end;

procedure erase(var f: file);
begin
 system.erase(f);
 rezultat:=ioresult;
end;

procedure calcmrxy;
begin
 mrx:=vlx2-vlx1;
 if mrx<0 then mrx:=-mrx;
 mrx:=mrx+1;
 mry:=vly2-vly1;
 if mry<0 then mry:=-mry;
 mry:=mry+1;
end;

procedure salvezini;
var f: file;
begin
 fillchar(buf,9,0);
 filemode:=2;
 assign(f,numeini);
 rewrite(f,1);
 if rezultat<>0 then exit;
 if scanez then buf[1]:=#1;
 if elimin then buf[2]:=#1;
 if sunet then buf[3]:=#1;
 if fullscreen then buf[9]:=#1;
 buf[4]:=chr(searchmem);
 speed[1]:=speedn;
 speed[2]:=speedna;
 speed[3]:=speedc;
 speed[4]:=speedca;
 for x:=1 to 4 do
 buf[4+x]:=chr(speed[x]);
 if buf[3]<>#0 then sunet:=true;
 blockwrite(f,buf,9,w);
 close(f);
 filemode:=0;
end;

procedure gatab;
begin
 mhmemdealoc(seg(tb^));
 mhmemdealoc(seg(tc^));
 mhmemdealoc(seg(b^));
 mhmemdealoc(seg(c^));
 mhmemdealoc(seg(d^));
end;

procedure myexit;
var cod: integer;
begin
 exitproc:=oldexit;
 nascut:=false;
 gatab;
 inittext80x25;
 getdate(an,luna,zi,zis);
 for x:=1 to zin do
 if (zi=zile[x].zi)and(luna=zile[x].luna) then
 begin
  writeln('Azi e ziua lui ',zile[x].nume);
  s1:=nrtost0(zi,2);
  s2:=nrtost0(luna,2);
  s3:=nrtost0(an,4);
  s:=s1+'-'+s2+'-'+s3;
  writeln(s);
  nascut:=true;
 end;
 if nascut then
 begin
  writeln('La multi ani si multa sanatate!');
  repnokey;
  repkey;
  repnokey;
 end;
 cursor(true);
 cod:=exitcode;
 if cod<>0 then
 begin
  writeln('MSoft - Eroare!');
  writeln('Cod: ',cod:3,'.');
  writeln('Adresa: ',wordtost(seg(erroraddr^)),':',wordtost(ofs(erroraddr^)),'.');
 end;
 if nom then writeln('Memorie insuficienta!');
 salvezini;
end;

procedure umplulo(mb: membuf256;x1,x2,y1: longint;color: byte);
var x,l: longint;
    z: word;
begin
 if x1>x2 then
 begin
  x:=x2;
  x2:=x1;
  x1:=x;
 end;
 if (x2<0)or(x1>sx-1)or(y1<0)or(y1>sy-1) then exit;
 if x1<0 then x1:=0;
 if x2>sx-1 then x2:=sx-1;
 z:=x2-x1+1;
 l:=y1*sx+x1;
 seek(f1,l);
 fillchar(buf,z,color);
 blockwrite(f1,buf,z,w);
end;

procedure umplulv(mb: membuf256;y1,y2,x1: longint;color: byte);
var b1,d1,b2,d2: word;
    vx,vy,x,y: word;
    b: ^byte;
    l: longint;
begin
 if y1>y2 then
 begin
  y:=y2;
  y2:=y1;
  y1:=y;
 end;
 if (y2<0)or(y1>sy-1)or(x1<0)or(x1>sx-1) then exit;
 if y1<0 then y1:=0;
 if y2>sy-1 then y2:=sy-1;
 for y:=y1 to y2 do
 begin
  l:=sy*y+x1;
  seek(f1,l);
  blockwrite(f1,color,1,w);
 end;
end;

procedure wline256(mb1: membuf256;x1,x2,y: longint);
var l,x,vx,xy: longint;
begin
 if x1>x2 then
 begin
  x:=x2;
  x2:=x1;
  x1:=x;
 end;
 if x1<0 then x1:=0;
 if x2>sx-1 then x2:=sx-1;
 if y<0 then exit;
 if y>sy-1 then exit;
 if x2<0 then exit;
 if x1>sx-1 then exit;
 l:=y*sx+x1;
 vx:=x2-x1+1;
 seek(f1,l);
 blockwrite(f1,orzline,vx,w);
end;

procedure rline256(mb1: membuf256;x1,x2,y: longint);
var l,x,vx,xy: longint;
begin
 if x1>x2 then
 begin
  x:=x2;
  x2:=x1;
  x1:=x;
 end;
 if x1<0 then x1:=0;
 if x2>sx-1 then x2:=sx-1;
 if y<0 then exit;
 if y>sy-1 then exit;
 if x2<0 then exit;
 if x1>sx-1 then exit;
 l:=y*sx+x1;
 vx:=x2-x1+1;
 seek(f1,l);
 fillchar(orzline,sizeof(orzline),0);
 blockread(f1,orzline,vx,w);
end;

procedure ppix256(mb: membuf256;x,y: longint;color: byte);
var l: longint;
begin
 if (x<0)or(y<0)or(x>sx-1)and(y>sy-1) then exit;
 l:=y*sx+x;
 seek(f1,l);
 blockwrite(f1,color,1,w);
end;

function gpix256(mb: membuf256;x,y: longint): byte;
var color: byte;
    l: longint;
begin
 if (x<0)or(y<0)or(x>sx-1)and(y>sy-1) then exit;
 l:=y*sx+x;
 seek(f1,l);
 color:=0;
 blockread(f1,color,1,w);
 gpix256:=color;
end;

procedure createvirtual(marime: longint);
var thedir: string;
    oldmode: byte;
begin
 fillchar(minibuf^,sizeof(minibuf^),0);
 oldmode:=filemode;
 filemode:=2;
 thedir:=upstring(getenv('TEMP'));
 if thedir='' then thedir:=upstring(dirini);
 if thedir[length(thedir)]<>'\' then thedir:=thedir+'\';
 virtualmem:=true;
 writeprotect:=false;
 nom:=false;
 assign(f1,thedir+virtualn);
 rewrite(f1,1);
 if rezultat<>0 then
 begin
  writeprotect:=true;
  filemode:=oldmode;
  exit;
 end;
 repeat
  if marime>sizeof(minibuf^) then
  begin
   blockwrite(f1,minibuf^,sizeof(minibuf^),w);
   if w<sizeof(minibuf^) then
   begin
    nom:=true;
    filemode:=oldmode;
    exit;
   end;
   marime:=marime-sizeof(minibuf^);
  end else
  begin
   blockwrite(f1,minibuf^,marime,w);
   if w<marime then
   begin
    nom:=true;
    filemode:=oldmode;
    exit;
   end;
   marime:=0;
  end;
 until marime=0;
 filemode:=oldmode;
end;

procedure deletevirtual;
begin
 close(f1);
 erase(f1);
end;

function isshift: boolean;
begin
 isshift:=false;
 if (mem[0:$417] and 6)<>0 then isshift:=true;
 if (mem[0:$417] and 7)<>0 then isshift:=true;
end;

procedure afisezimagine;
var mx,my: longint;
    x,y,t: integer;
    h,m,sc,ss: word;
begin
 spatecol:=palnearpalcolor(pal,63,63,63);
 scriscol:=palnearpalcolor(pal,0,0,0);
 mx:=sx-vsx-1;
 if mx>mvx then mx:=mvx;
 my:=sy-vsy-1;
 if my>mvy then my:=mvy;
 if(vvx<>vsx)or(vvy<>vsy)or(not terminat)or(lx1<>vlx1)or(lx2<>vlx2)
 or(ly1<>vly1)or(ly2<>vly2)or(vvpt<>vpt)or(fullscreen<>fulls) then
 begin
  clearbuf(b,0);
  if virtualmem then
  begin
   if fullscreen then
   begin
    x:=sy-1;
    if x>199 then x:=199;
    for y:=0 to x do
    begin
     rline256(mbimg,vsx,sx-1,vsy+y);
     move(orzline,b^[y,0],320);
     fcolor(0);
     bara(b,sx-vsx,y,320,y);
    end;
   end else
   for y:=0 to my do
   begin
    rline256(mbimg,vsx,sx-1,vsy+y);
    move(orzline,b^[y+20,0],320);
    fcolor(0);
    bara(b,sx-vsx,y+20,320,y+20);
   end;
  end else
  begin
   if fullscreen then
   begin
    x:=sy-1;
    if x>199 then x:=199;
    for y:=0 to x do
    begin
     readline256(mbimg,vsx,sx-1,vsy+y);
     move(orzline,b^[y,0],320);
     fcolor(0);
     bara(b,sx-vsx,y,320,y);
    end;
   end else
   for y:=0 to my do
   begin
    readline256(mbimg,vsx,sx-1,vsy+y);
    move(orzline,b^[y+20,0],320);
    fcolor(0);
    bara(b,sx-vsx,y+20,320,y+20);
   end;
  end;
 end;
 if vsel then
 begin
  vcol:=1-vcol;
  if vcol=0 then scolor(scriscol) else
  scolor(spatecol);
  if fullscreen then
  begin
   linie(b,vlx1-vsx,vly1-vsy,vlx2-vsx,vly1-vsy);
   linie(b,vlx1-vsx,vly2-vsy,vlx2-vsx,vly2-vsy);
   linie(b,vlx2-vsx,vly2-vsy,vlx2-vsx,vly1-vsy);
   linie(b,vlx1-vsx,vly1-vsy,vlx1-vsx,vly2-vsy);
  end else
  begin
   linie(b,vlx1-vsx,20+vly1-vsy,vlx2-vsx,20+vly1-vsy);
   linie(b,vlx1-vsx,20+vly2-vsy,vlx2-vsx,20+vly2-vsy);
   linie(b,vlx2-vsx,20+vly2-vsy,vlx2-vsx,20+vly1-vsy);
   linie(b,vlx1-vsx,20+vly1-vsy,vlx1-vsx,20+vly2-vsy);
  end;
  if vpt=0 then
  begin
   if fullscreen then
   begin
    linie(b,vlx1-vsx-3,vly1-vsy,vlx1-vsx+3,vly1-vsy);
    linie(b,vlx1-vsx,vly1-vsy-3,vlx1-vsx,vly1-vsy+3);
   end else
   begin
    linie(b,vlx1-vsx-3,20+vly1-vsy,vlx1-vsx+3,20+vly1-vsy);
    linie(b,vlx1-vsx,20+vly1-vsy-3,vlx1-vsx,20+vly1-vsy+3);
   end;
  end else
  begin
   if fullscreen then
   begin
    linie(b,vlx2-vsx-3,vly2-vsy,vlx2-vsx+3,vly2-vsy);
    linie(b,vlx2-vsx,vly2-vsy-3,vlx2-vsx,vly2-vsy+3);
   end else
   begin
    linie(b,vlx2-vsx-3,20+vly2-vsy,vlx2-vsx+3,20+vly2-vsy);
    linie(b,vlx2-vsx,20+vly2-vsy-3,vlx2-vsx,20+vly2-vsy+3);
   end;
  end;
 end;
 if not fullscreen then
 begin
  fcolor(spatecol);
  scolor(scriscol);
  baram(b,0,0,319,19);
  baram(b,0,180,319,199);
  s:='['+upstring(fullstring(panou[epoz+dpoz].nume,panou[epoz+dpoz].ext))+'] ';
  if panou[dpoz+epoz].format=fmvb then s:=s+'MVB ' else
  if panou[dpoz+epoz].format=fmhv then s:=s+'MHV ' else
  if panou[dpoz+epoz].format=fmhb then s:=s+'MHB ' else
  if panou[dpoz+epoz].format=fmhp then s:=s+'MHP ' else
  if panou[dpoz+epoz].format=fmcb then s:=s+'MCB ' else
  if panou[dpoz+epoz].format=fmcp then s:=s+'MCP ' else
  if panou[dpoz+epoz].format=fcel then s:=s+'CEL ' else
  if panou[dpoz+epoz].format=fpcx then s:=s+'PCX ' else
  if panou[dpoz+epoz].format=fbmp then s:=s+'BMP ' else
  if panou[dpoz+epoz].format=fico then s:=s+'ICO ' else
  if panou[dpoz+epoz].format=ftga then s:=s+'TGA ' else
  s:=s+'??? ';
  str(panou[epoz+dpoz].sx,s2);
  s1:=s2+'x';
  str(panou[epoz+dpoz].sy,s2);
  s1:=s1+s2+'x';
  if panou[epoz+dpoz].bpp<=8 then
  begin
   str(1 shl panou[epoz+dpoz].bpp,s2);
   s2:=s2+ ' culori';
  end else
  begin
   str(panou[epoz+dpoz].bpp,s2);
   s2:=s2+' biti';
  end;
  for x:=length(s2)+1 to 15 do
  s2:=s2+' ';
  s1:=s1+s2;
  str(vsx,s2);
  s1:=s1+s2;
  str(vsy,s2);
  s1:=s1+':'+s2;
  s:=s+s1;
  str(trunc(bcitit*100/btotal),s2);
  s:=s+'  '+s2+'%';
  if virtualmem then s:=s+upstring(' HDD') else s:=s+upstring(' RAM');
  if terminat then s:=s+' gata' else s:=s+' incarc';
  mvtextxy2(b,3,5,s);
 end;
 if not terminat then
 begin
  citesctimp(timp2);
  calculeztimp(timp1,timp2,timp3);
  calculezestimat(timp4);
 end;
 if not vsel then
 begin
  if not fullscreen then
  begin
   if terminat then timp4:=timp3;
   transformtimp(timp3,h,m,sc,ss);
   s:='';
   s1:=nrtost0(h,2);
   s:=s+s1+':';
   s1:=nrtost0(m,2);
   s:=s+s1+':';
   s1:=nrtost0(sc,2);
   s:=s+s1+'.';
   s1:=nrtost0(ss,2);
   s:=s+s1;
   transformtimp(timp4,h,m,sc,ss);
   s:=s+' ';
   s1:=nrtost0(h,2);
   s:=s+s1+':';
   s1:=nrtost0(m,2);
   s:=s+s1+':';
   s1:=nrtost0(sc,2);
   s:=s+s1+'.';
   s1:=nrtost0(ss,2);
   s:=s+s1;
   mvtextxy2(b,3,185,s);
  end;
 end else
 begin
  if not fullscreen then
  begin
   calcmrxy;
   s:='';
   s1:=nrtost0(vlx1,4);
   s:=s+s1+'x';
   s1:=nrtost0(vly1,4);
   s:=s+s1+' ';
   s1:=nrtost0(vlx2,4);
   s:=s+s1+'x';
   s1:=nrtost0(vly2,4);
   s:=s+s1+' ';
   s1:=nrtost0(mrx,4);
   s:=s+s1+'x';
   s1:=nrtost0(mry,4);
   s:=s+s1+' ';
   mvtextxy2(b,3,185,s);
  end;
 end;
 setpal(pal);
 a^:=b^;
end;

procedure informezstatus(img,sup: string;sx,sy: longint;procent: byte);
var cat,x: integer;
begin
 setcharcolor(4);
 setbaccolor(14);
 setchar(#0);
 bara80x25(tb,1,1,80,25);
 setcharcolor(14);
 setbaccolor(4);
 ferg80x25(tb,3,2,78,5,'Informatii');
 writestring80x25(tb,1,3,'Acest program a fost creat de',false,false,true);
 writestring80x25(tb,1,4,'Mihai Marica in anul 2000',false,false,true);
 ferg80x25(tb,3,8,78,10,'Stare');
 writestring80x25(tb,1,9,sup,false,false,true);
 ferg80x25(tb,3,13,78,17,'Salvare, format '+img+' '+nrtost0(sx,4)+'x'+nrtost0(sy,4)+'x256');
 s:=nrtost0(procent,3)+'%';
 writestring80x25(tb,1,16,s,false,false,true);
 s:='';
 for x:=1 to 50 do
 s:=s+#176;
 cat:=procent*50 div 100;
 for x:=1 to 50 do
 if x<=cat then
 s[x]:=#177;
 writestring80x25(tb,1,15,s,false,false,true);
 ferg80x25(tb,3,20,78,23,'Sfat de la Mihai');
 writestring80x25(tb,1,21,'Daca dureaza prea mult pot sa-ti sugerez alt '+
 'calculator?',false,false,true);
 writestring80x25(tb,1,22,'Zambeste! Ce daca ai o rabla?',false,false,true);
 ta^:=tb^;
end;

procedure saveimg(format: byte);
type antet_bmp=record
      bftype:word;
      bfsize:longint;
      bfreserved1:word;
      bfreserved2:word;
      bfoffbits:longint;
      bisize:longint;
      biwidth:longint;
      biheigth:longint;
      biplanes:word;
      bibitcount:word;
      bicompression:longint;
      bisizeimage:longint;
      bixpelspermeter:longint;
      biypelspermeter:longint;
      biclrused:longint;
      biclrimportant:longint;
     end;
var btotal,bscris,x1,y1,x2,y2,x,y: longint;
    bmpant: antet_bmp;
    sx,sy,lng: longint;
    vx,vy,wd: word;
    procv,procent,oldmode: byte;
    f: file;
    palc: convertpal2norm;
    idstr: string;

procedure atentiespatiu(s: string);
begin
    repnokey;
    informezstatus(s,'Nu e destul spatiu pe disc! Apasa o tasta.',sx,sy,procent);
    repnokey;
    repkey;
    repnokey;
    elimintasta;
    filemode:=oldmode;
    close(f);
    erase(f);
end;

begin
 oldmode:=filemode;
 x1:=vlx1;x2:=vlx2;y1:=vly1;y2:=vly2;
 if x1>x2 then
 begin
  x:=x1;
  x1:=x2;
  x2:=x;
 end;
 if y1>y2 then
 begin
  y:=y1;
  y1:=y2;
  y2:=y;
 end;
 sx:=x2-x1+1;
 sy:=y2-y1+1;
 vx:=sx;
 vy:=sy;
 bscris:=0;
 procent:=0;
 repnokey;
 elimintasta;
 if format=fmvb then
 begin
  idstr:='MSoft MVB';
  btotal:=sx*sy+7;
  if sx<255 then btotal:=btotal-1;
  informezstatus(idstr,'Creez fisierul: '+numef,sx,sy,procent);
  filemode:=0;
  assign(f,numef);
  reset(f,1);
  if rezultat=0 then
  begin
   informezstatus(idstr,'Fisierul: '+numef+' exista. Suprascriu? (d/n)',sx,sy,procent);
   repeat
    elimintasta;
    citesctasta;
   until(tasta.citita)and(not tasta.zero)and((tasta.cod=ord('n'))or(tasta.cod=ord('N'))or
   (tasta.cod=ord('d'))or(tasta.cod=ord('D')));
   if(tasta.cod=ord('n'))or(tasta.cod=ord('N')) then
   begin
    elimintasta;
    repnokey;
    filemode:=oldmode;
    exit;
   end;
  end;
  filemode:=2;
  assign(f,numef);
  rewrite(f,1);
  if rezultat<>0 then
  begin
   informezstatus(idstr,'Nu pot crea fisierul: '+numef+'! Apasa o tasta.',sx,sy,procent);
   repnokey;
   repkey;
   repnokey;
   elimintasta;
   filemode:=oldmode;
   exit;
  end;
  informezstatus(idstr,'Calculez schimbarile de paleta...',sx,sy,procent);
  convertpal2pal(pal,normpal,palc);
  informezstatus(idstr,'Scriu fisierul...',sx,sy,0);
  buf[1]:='M';buf[2]:='V';buf[3]:='B';buf[4]:='6';
  if sx<255 then
  begin
   buf[5]:=chr(sx);
   buf[6]:=chr(sy);
   blockwrite(f,buf,6,w);
   if w<6 then
   begin
    atentiespatiu(idstr);
    exit;
   end;
   bscris:=bscris+6;
  end else
  begin
   buf[5]:=#255;
   buf[6]:=chr(sx-255);
   buf[7]:=chr(sy);
   blockwrite(f,buf,7,w);
   if w<7 then
   begin
    atentiespatiu(idstr);
    exit;
   end;
   bscris:=bscris+7;
  end;
  for x:=0 to sx-1 do
  begin
   for y:=0 to sy-1 do
   begin
    if virtualmem then buf[y+1]:=chr(palc[gpix256(mbimg,x1+x,y1+y)]) else
    buf[y+1]:=chr(palc[getpixel256(mbimg,x1+x,y1+y)]);
   end;
   blockwrite(f,buf,sy,w);
   if w<sy then
   begin
    atentiespatiu(idstr);
    exit;
   end;
   bscris:=bscris+sy;
   procent:=0;
   if btotal>0 then procent:=bscris*100 div btotal;
   if procent<>procv then informezstatus(idstr,'Scriu fisierul...',sx,sy,procent);
   procv:=procent;
  end;
  close(f);
  repnokey;
  informezstatus(idstr,'Fisierul a fost creat! Apasa o tasta.',sx,sy,procent);
  repkey;
  repnokey;
  elimintasta;
 end;
 if format=fmhb then
 begin
  idstr:='MSoft MHB';
  btotal:=sx*sy+8;
  informezstatus(idstr,'Creez fisierul: '+numef,sx,sy,procent);
  filemode:=0;
  assign(f,numef);
  reset(f,1);
  if rezultat=0 then
  begin
   informezstatus(idstr,'Fisierul: '+numef+' exista. Suprascriu? (d/n)',sx,sy,procent);
   repeat
    elimintasta;
    citesctasta;
   until(tasta.citita)and(not tasta.zero)and((tasta.cod=ord('n'))or(tasta.cod=ord('N'))or
   (tasta.cod=ord('d'))or(tasta.cod=ord('D')));
   if(tasta.cod=ord('n'))or(tasta.cod=ord('N')) then
   begin
    elimintasta;
    repnokey;
    filemode:=oldmode;
    exit;
   end;
  end;
  filemode:=2;
  assign(f,numef);
  rewrite(f,1);
  if rezultat<>0 then
  begin
   informezstatus(idstr,'Nu pot crea fisierul: '+numef+'! Apasa o tasta.',sx,sy,procent);
   repnokey;
   repkey;
   repnokey;
   elimintasta;
   filemode:=oldmode;
   exit;
  end;
  informezstatus(idstr,'Calculez schimbarile de paleta...',sx,sy,procent);
  convertpal2pal(pal,normpal1,palc);
  informezstatus(idstr,'Scriu fisierul...',sx,sy,0);
  buf[1]:='M';buf[2]:='H';buf[3]:='B';buf[4]:='6';
  move(vx,buf[5],2);
  move(vy,buf[7],2);
  blockwrite(f,buf,8,w);
  if w<8 then
  begin
   atentiespatiu(idstr);
   exit;
  end;
  bscris:=bscris+8;
  for y:=0 to sy-1 do
  begin
   if virtualmem then rline256(mbimg,x1,x1+sx-1,y1+y) else
   readline256(mbimg,x1,x1+sx-1,y1+y);
   for x:=0 to sx-1 do
   buf[x+1]:=chr(palc[orzline[x+1]]);
   blockwrite(f,buf,sx,w);
   if w<sx then
   begin
    atentiespatiu(idstr);
    exit;
   end;
   bscris:=bscris+sx;
   procent:=0;
   if btotal>0 then procent:=bscris*100 div btotal;
   if procent<>procv then informezstatus(idstr,'Scriu fisierul...',sx,sy,procent);
   procv:=procent;
  end;
  close(f);
  repnokey;
  informezstatus(idstr,'Fisierul a fost creat! Apasa o tasta.',sx,sy,procent);
  repkey;
  repnokey;
  elimintasta;
 end;
 if format=fmhv then
 begin
  idstr:='MSoft MHV';
  btotal:=sx*sy+8;
  informezstatus(idstr,'Creez fisierul: '+numef,sx,sy,procent);
  filemode:=0;
  assign(f,numef);
  reset(f,1);
  if rezultat=0 then
  begin
   informezstatus(idstr,'Fisierul: '+numef+' exista. Suprascriu? (d/n)',sx,sy,procent);
   repeat
    elimintasta;
    citesctasta;
   until(tasta.citita)and(not tasta.zero)and((tasta.cod=ord('n'))or(tasta.cod=ord('N'))or
   (tasta.cod=ord('d'))or(tasta.cod=ord('D')));
   if(tasta.cod=ord('n'))or(tasta.cod=ord('N')) then
   begin
    elimintasta;
    repnokey;
    filemode:=oldmode;
    exit;
   end;
  end;
  filemode:=2;
  assign(f,numef);
  rewrite(f,1);
  if rezultat<>0 then
  begin
   informezstatus(idstr,'Nu pot crea fisierul: '+numef+'! Apasa o tasta.',sx,sy,procent);
   repnokey;
   repkey;
   repnokey;
   elimintasta;
   filemode:=oldmode;
   exit;
  end;
  informezstatus(idstr,'Calculez schimbarile de paleta...',sx,sy,procent);
  convertpal2pal(pal,normpal,palc);
  informezstatus(idstr,'Scriu fisierul...',sx,sy,0);
  buf[1]:='M';buf[2]:='H';buf[3]:='V';buf[4]:='6';
  move(vx,buf[5],2);
  move(vy,buf[7],2);
  blockwrite(f,buf,8,w);
  if w<8 then
  begin
   atentiespatiu(idstr);
   exit;
  end;
  bscris:=bscris+8;
  for y:=0 to sy-1 do
  begin
   if virtualmem then rline256(mbimg,x1,x1+sx-1,y1+y) else
   readline256(mbimg,x1,x1+sx-1,y1+y);
   for x:=0 to sx-1 do
   buf[x+1]:=chr(palc[orzline[x+1]]);
   blockwrite(f,buf,sx,w);
   if w<sx then
   begin
    atentiespatiu(idstr);
    exit;
   end;
   bscris:=bscris+sx;
   procent:=0;
   if btotal>0 then procent:=bscris*100 div btotal;
   if procent<>procv then informezstatus(idstr,'Scriu fisierul...',sx,sy,procent);
   procv:=procent;
  end;
  close(f);
  repnokey;
  informezstatus(idstr,'Fisierul a fost creat! Apasa o tasta.',sx,sy,procent);
  repkey;
  repnokey;
  elimintasta;
 end;
 if format=fmhp then
 begin
  idstr:='MSoft MHP';
  btotal:=sx*sy+8+768;
  informezstatus(idstr,'Creez fisierul: '+numef,sx,sy,procent);
  filemode:=0;
  assign(f,numef);
  reset(f,1);
  if rezultat=0 then
  begin
   informezstatus(idstr,'Fisierul: '+numef+' exista. Suprascriu? (d/n)',sx,sy,procent);
   repeat
    elimintasta;
    citesctasta;
   until(tasta.citita)and(not tasta.zero)and((tasta.cod=ord('n'))or(tasta.cod=ord('N'))or
   (tasta.cod=ord('d'))or(tasta.cod=ord('D')));
   if(tasta.cod=ord('n'))or(tasta.cod=ord('N')) then
   begin
    elimintasta;
    repnokey;
    filemode:=oldmode;
    exit;
   end;
  end;
  filemode:=2;
  assign(f,numef);
  rewrite(f,1);
  if rezultat<>0 then
  begin
   informezstatus(idstr,'Nu pot crea fisierul: '+numef+'! Apasa o tasta.',sx,sy,procent);
   repnokey;
   repkey;
   repnokey;
   elimintasta;
   filemode:=oldmode;
   exit;
  end;
  informezstatus(idstr,'Scriu fisierul...',sx,sy,0);
  buf[1]:='M';buf[2]:='H';buf[3]:='P';buf[4]:='6';
  move(vx,buf[5],2);
  move(vy,buf[7],2);
  blockwrite(f,buf,8,w);
  if w<8 then
  begin
   atentiespatiu(idstr);
   exit;
  end;
  bscris:=bscris+8;
  blockwrite(f,pal,768,w);
  if w<768 then
  begin
   atentiespatiu(idstr);
   exit;
  end;
  bscris:=bscris+768;
  for y:=0 to sy-1 do
  begin
   if virtualmem then rline256(mbimg,x1,x1+sx-1,y1+y) else
   readline256(mbimg,x1,x1+sx-1,y1+y);
   blockwrite(f,orzline,sx,w);
   if w<sx then
   begin
    atentiespatiu(idstr);
    exit;
   end;
   bscris:=bscris+sx;
   procent:=0;
   if btotal>0 then procent:=bscris*100 div btotal;
   if procent<>procv then informezstatus(idstr,'Scriu fisierul...',sx,sy,procent);
   procv:=procent;
  end;
  close(f);
  repnokey;
  informezstatus(idstr,'Fisierul a fost creat! Apasa o tasta.',sx,sy,procent);
  repkey;
  repnokey;
  elimintasta;
 end;
 if format=fbmp then
 begin
  idstr:='Bitmap';
  btotal:=sx*sy+54+1024;
  informezstatus(idstr,'Creez fisierul: '+numef,sx,sy,procent);
  filemode:=0;
  assign(f,numef);
  reset(f,1);
  if rezultat=0 then
  begin
   informezstatus(idstr,'Fisierul: '+numef+' exista. Suprascriu? (d/n)',sx,sy,procent);
   repeat
    elimintasta;
    citesctasta;
   until(tasta.citita)and(not tasta.zero)and((tasta.cod=ord('n'))or(tasta.cod=ord('N'))or
   (tasta.cod=ord('d'))or(tasta.cod=ord('D')));
   if(tasta.cod=ord('n'))or(tasta.cod=ord('N')) then
   begin
    elimintasta;
    repnokey;
    filemode:=oldmode;
    exit;
   end;
  end;
  filemode:=2;
  assign(f,numef);
  rewrite(f,1);
  if rezultat<>0 then
  begin
   informezstatus(idstr,'Nu pot crea fisierul: '+numef+'! Apasa o tasta.',sx,sy,procent);
   repnokey;
   repkey;
   repnokey;
   elimintasta;
   filemode:=oldmode;
   exit;
  end;
  informezstatus(idstr,'Scriu fisierul...',sx,sy,0);
  bmpant.bftype:=19778;
  bmpant.bfsize:=btotal;
  bmpant.bfreserved1:=0;
  bmpant.bfreserved2:=0;
  bmpant.bfoffbits:=1078;
  bmpant.bisize:=40;
  bmpant.biwidth:=sx;
  bmpant.biheigth:=sy;
  bmpant.biplanes:=1;
  bmpant.bibitcount:=8;
  bmpant.bisizeimage:=0;
  bmpant.bicompression:=0;
  bmpant.bixpelspermeter:=2880;
  bmpant.biypelspermeter:=2880;
  bmpant.biclrused:=256;
  bmpant.biclrimportant:=0;
  move(bmpant,buf,54);
  blockwrite(f,buf,54,w);
  if w<54 then
  begin
   atentiespatiu(idstr);
   exit;
  end;
  bscris:=bscris+54;
  for x:=0 to 255 do
  begin
   buf[x*4+1]:=chr(pal[x][3]*4);
   buf[x*4+2]:=chr(pal[x][2]*4);
   buf[x*4+3]:=chr(pal[x][1]*4);
   buf[x*4+4]:=#0;
  end;
  blockwrite(f,buf,1024,w);
  if w<1024 then
  begin
   atentiespatiu(idstr);
   exit;
  end;
  bscris:=bscris+1024;
  for y:=sy-1 downto 0 do
  begin
   if virtualmem then rline256(mbimg,x1,x1+sx-1,y1+y) else
   readline256(mbimg,x1,x1+sx-1,y1+y);
   blockwrite(f,orzline,sx,w);
   if w<sx then
   begin
    atentiespatiu(idstr);
    exit;
   end;
   bscris:=bscris+sx;
   procent:=0;
   if btotal>0 then procent:=bscris*100 div btotal;
   if procent<>procv then informezstatus(idstr,'Scriu fisierul...',sx,sy,procent);
   procv:=procent;
  end;
  close(f);
  repnokey;
  informezstatus(idstr,'Fisierul a fost creat! Apasa o tasta.',sx,sy,procent);
  repkey;
  repnokey;
  elimintasta;
 end;
 if format=ftga then
 begin
  idstr:='Targa';
  btotal:=sx*sy+18+768;
  informezstatus(idstr,'Creez fisierul: '+numef,sx,sy,procent);
  filemode:=0;
  assign(f,numef);
  reset(f,1);
  if rezultat=0 then
  begin
   informezstatus(idstr,'Fisierul: '+numef+' exista. Suprascriu? (d/n)',sx,sy,procent);
   repeat
    elimintasta;
    citesctasta;
   until(tasta.citita)and(not tasta.zero)and((tasta.cod=ord('n'))or(tasta.cod=ord('N'))or
   (tasta.cod=ord('d'))or(tasta.cod=ord('D')));
   if(tasta.cod=ord('n'))or(tasta.cod=ord('N')) then
   begin
    elimintasta;
    repnokey;
    filemode:=oldmode;
    exit;
   end;
  end;
  filemode:=2;
  assign(f,numef);
  rewrite(f,1);
  if rezultat<>0 then
  begin
   informezstatus(idstr,'Nu pot crea fisierul: '+numef+'! Apasa o tasta.',sx,sy,procent);
   repnokey;
   repkey;
   repnokey;
   elimintasta;
   filemode:=oldmode;
   exit;
  end;
  informezstatus(idstr,'Scriu fisierul...',sx,sy,0);
  buf[1]:=#0;buf[2]:=#1;buf[3]:=#1;buf[4]:=#0;
  wd:=sx;
  move(wd,buf[13],2);
  wd:=sy;
  move(wd,buf[15],2);
  buf[17]:=#8;
  buf[18]:=#32;
  blockwrite(f,buf,18,w);
  if w<18 then
  begin
   atentiespatiu(idstr);
   exit;
  end;
  bscris:=bscris+18;
  for x:=0 to 255 do
  begin
   buf[x*3+1]:=chr(pal[x][3]*4);
   buf[x*3+2]:=chr(pal[x][2]*4);
   buf[x*3+3]:=chr(pal[x][1]*4);
  end;
  blockwrite(f,buf,768,w);
  if w<768 then
  begin
   atentiespatiu(idstr);
   exit;
  end;
  bscris:=bscris+768;
  for y:=0 to sy-1 do
  begin
   if virtualmem then rline256(mbimg,x1,x1+sx-1,y1+y) else
   readline256(mbimg,x1,x1+sx-1,y1+y);
   blockwrite(f,orzline,sx,w);
   if w<sx then
   begin
    atentiespatiu(idstr);
    exit;
   end;
   bscris:=bscris+sx;
   procent:=0;
   if btotal>0 then procent:=bscris*100 div btotal;
   if procent<>procv then informezstatus(idstr,'Scriu fisierul...',sx,sy,procent);
   procv:=procent;
  end;
  close(f);
  repnokey;
  informezstatus(idstr,'Fisierul a fost creat! Apasa o tasta.',sx,sy,procent);
  repkey;
  repnokey;
  elimintasta;
 end;
 elimintasta;
 repnokey;
 filemode:=oldmode;
end;

procedure vreausasalvez;
const nrfrm=11;
var iesire: boolean;
    menupoz: integer;
    sx,sy: longint;
    format: array[1..nrfrm] of record
                                minx,miny,maxx,maxy: word;
                                id: byte;
                                stiu: boolean;
                                nume: string[50];
                                ext: string[3];
                                parit: byte;
                               end;
    stemp: string;

begin
 salvez:=false;
 fillchar(stemp,64,0);
 stemp[0]:=#64;
 inittext80x25;
 cursor(false);
 clipire(false);
 if vlx1>vlx2 then sx:=vlx1-vlx2+1 else sx:=vlx2-vlx1+1;
 if vly1>vly2 then sy:=vly1-vly2+1 else sy:=vly2-vly1+1;
 for x:=1 to nrfrm do
 begin
  format[x].minx:=1;
  format[x].miny:=1;
  format[x].maxx:=maxr256;
  format[x].maxy:=maxr256;
 end;
 format[1].id:=fmvb;
 format[1].nume:='MSoft Format - paleta modului normal - vechi';
 format[1].ext:='MVB';
 format[1].stiu:=true;
 format[1].parit:=1;
 format[1].maxx:=255+255;
 format[1].maxy:=255;
 format[2].id:=fmhv;
 format[2].nume:='MSoft Format - paleta modului normal - nou';
 format[2].ext:='MHV';
 format[2].stiu:=true;
 format[2].parit:=1;
 format[3].id:=fmhb;
 format[3].nume:='MSoft Format - paleta noua a la Mihai';
 format[3].ext:='MHB';
 format[3].stiu:=true;
 format[3].parit:=1;
 format[4].id:=fmhp;
 format[4].nume:='MSoft Format - paleta inclusa in fisier';
 format[4].ext:='MHP';
 format[4].stiu:=true;
 format[4].parit:=1;
 format[5].id:=fmcb;
 format[5].nume:='MSoft Format - compresie si paleta noua';
 format[5].ext:='MCB';
 format[5].stiu:=false;
 format[5].parit:=1;
 format[6].id:=fmcp;
 format[6].nume:='MSoft Format - compresie si paleta inclusa';
 format[6].ext:='MCP';
 format[6].stiu:=false;
 format[6].parit:=1;
 format[7].id:=fbmp;
 format[7].nume:='Bitmap';
 format[7].ext:='BMP';
 format[7].stiu:=true;
 format[7].parit:=2;
 format[8].id:=fico;
 format[8].nume:='Icon';
 format[8].ext:='ICO';
 format[8].stiu:=false;
 format[8].maxx:=255;
 format[8].maxy:=255;
 format[8].parit:=2;
 format[9].id:=fpcx;
 format[9].nume:='ZSoft PC Format';
 format[9].ext:='PCX';
 format[9].stiu:=false;
 format[9].parit:=2;
 format[10].id:=fcel;
 format[10].nume:='Cel';
 format[10].ext:='CEL';
 format[10].stiu:=false;
 format[10].parit:=1;
 format[11].id:=ftga;
 format[11].nume:='Targa';
 format[11].ext:='TGA';
 format[11].stiu:=true;
 format[11].parit:=1;
 iesire:=false;
 tc^:=tb^;
 repeat
  tb^:=tc^;
  elimintasta;
  citesctasta;
  if(tasta.citita)and(not tasta.zero)and(tasta.cod=tesc) then
  begin
   iesire:=true;
   elimintasta;
  end;
  if(tasta.citita)and(tasta.zero)and(tasta.cod=tsus) then
  begin
   menupoz:=menupoz-1;
   elimintasta;
  end;
  if(tasta.citita)and(tasta.zero)and(tasta.cod=tjos) then
  begin
   menupoz:=menupoz+1;
   elimintasta;
  end;
  if(tasta.citita)and(tasta.zero)and(tasta.cod=tstanga) then
  if menupoz=nrfrm+1 then
  begin
   pozf:=pozf-1;
   elimintasta;
  end;
  if(tasta.citita)and(tasta.zero)and(tasta.cod=tdreapta) then
  if menupoz=nrfrm+1 then
  begin
   pozf:=pozf+1;
   elimintasta;
  end;
  if(tasta.citita)and(not tasta.zero)and(tasta.cod=tbkspace) then
  if menupoz=nrfrm+1 then
  begin
   eliminlitera(numef,pozf-1);
   pozf:=pozf-1;
   elimintasta;
  end;
  if(tasta.citita)and(tasta.zero)and(tasta.cod=tdel) then
  if menupoz=nrfrm+1 then
  begin
   eliminlitera(numef,pozf);
   elimintasta;
  end;
  if(tasta.citita)and(not tasta.zero)and(tasta.cod=tenter) then
  begin
   if (menupoz<=nrfrm)and(menupoz>=1) then
   if(format[menupoz].stiu=true)and(sx>=format[menupoz].minx)and
   (sy>=format[menupoz].miny)and(sx<=format[menupoz].maxx)and(numef<>'')and
   (sy<=format[menupoz].maxy)and(sx mod format[menupoz].parit=0) then
   begin
    iesire:=true;
    salvez:=true;
    elimintasta;
   end;
  end;
  if(tasta.citita)and(not tasta.zero) then
  if menupoz=nrfrm+1 then
  begin
   inserezlitera(numef,chr(tasta.cod),pozf);
   pozf:=pozf+1;
   elimintasta;
  end;
  if ord(numef[0])>64 then numef[0]:=#64;
  if pozf<1 then pozf:=1;
  if pozf>length(numef)+1 then pozf:=length(numef)+1;
  if menupoz<1 then menupoz:=nrfrm+1;
  if menupoz>nrfrm+1 then menupoz:=1;
  setcharcolor(14);
  setbaccolor(4);
  setchar(#0);
  s:=nrtost0(sx,4)+'x'+nrtost0(sy,4)+'x256';
  ferg80x25(tb,2,2,79,23,'Salvarea imaginii selectate in format specificat la '+s);
  setbaccolor(4);
  for x:=1 to nrfrm do
  begin
   setbaccolor(4);
   setcharcolor(14);
   if menupoz=x then
   begin
    setbaccolor(14);
    setcharcolor(0);
    writestring80x25(tb,7,4+x,stemp,false,false,false);
   end;
   writestring80x25(tb,7,4+x,format[x].nume,false,false,false);
   writestring80x25(tb,68,4+x,format[x].ext,false,false,false);
  end;
  numef:=upstring(numef);
  setbaccolor(4);
  setcharcolor(14);
  if menupoz=nrfrm+1 then
  begin
   setbaccolor(14);
   setcharcolor(0);
   writestring80x25(tb,7,4+menupoz,stemp,false,false,false);
  end;
  writestring80x25(tb,7,4+nrfrm+1,'Fisier: '+numef,false,false,false);
  if menupoz=nrfrm+1 then
  begin
   cursor(true);
   gotoxy(7+7+pozf,4+nrfrm+1);
  end else
  cursor(false);
  ta^:=tb^;
 until iesire;
 if salvez then saveimg(format[menupoz].id);
 elimintasta;
 tb^:=tc^;
 ta^:=tb^;
 initgr;
 setpal(pal);
 a^:=b^;
 cursor(false);
end;

procedure verificies;
begin
 lx1:=vlx1;lx2:=vlx2;ly1:=vly1;ly2:=vly2;
 fulls:=fullscreen;
 vvpt:=vpt;
 vvx:=vsx;
 vvy:=vsy;
 vmx:=sx;
 vmy:=sy;
 iesima:=false;
 repeat
  elimintasta;
  citesctasta;
  if (tasta.citita)and(tasta.zero) then
  begin
   if tasta.cod=tsus then
   begin
    if not vsel then
    begin
     vsy:=vsy-1;
     if isshift then vsy:=vsy-9;
    end else
    begin
     if vpt=0 then
     begin
      vly1:=vly1-1;
      if isshift then vly1:=vly1-9;
     end else
     begin
      vly2:=vly2-1;
      if isshift then vly2:=vly2-9;
     end;
    end;
   end;
   if tasta.cod=tjos then
   begin
    if not vsel then
    begin
     vsy:=vsy+1;
     if isshift then vsy:=vsy+9;
    end else
    begin
     if vpt=0 then
     begin
      vly1:=vly1+1;
      if isshift then vly1:=vly1+9;
     end else
     begin
      vly2:=vly2+1;
      if isshift then vly2:=vly2+9;
     end;
    end;
   end;
   if tasta.cod=tstanga then
   begin
    if not vsel then
    begin
     vsx:=vsx-1;
     if isshift then vsx:=vsx-9;
    end else
    begin
     if vpt=0 then
     begin
      vlx1:=vlx1-1;
      if isshift then vlx1:=vlx1-9;
     end else
     begin
      vlx2:=vlx2-1;
      if isshift then vlx2:=vlx2-9;
     end;
    end;
   end;
   if tasta.cod=tdreapta then
   begin
    if not vsel then
    begin
     vsx:=vsx+1;
     if isshift then vsx:=vsx+9;
    end else
    begin
     if vpt=0 then
     begin
      vlx1:=vlx1+1;
      if isshift then vlx1:=vlx1+9;
     end else
     begin
      vlx2:=vlx2+1;
      if isshift then vlx2:=vlx2+9;
     end;
    end;
   end;
  end;
  if(tasta.citita)and(not tasta.zero)and(upcase(chr(tasta.cod))='F') then
  begin
   if fullscreen then fullscreen:=false else
   fullscreen:=true;
  end;
  if vsel then
  begin
   if vlx1<0 then vlx1:=0;
   if vlx2<0 then vlx2:=0;
   if vlx1>sx-1 then vlx1:=sx-1;
   if vlx2>sx-1 then vlx2:=sx-1;
   if vly1<0 then vly1:=0;
   if vly2<0 then vly2:=0;
   if vly1>sy-1 then vly1:=sy-1;
   if vly2>sy-1 then vly2:=sy-1;
   if fullscreen then
   begin
    if vpt=0 then
    begin
     if vsy>vly1 then vsy:=vly1;
     if vsx>vlx1 then vsx:=vlx1;
     if vsy<vly1-mvy then vsy:=vly1-199;
     if vsx<vlx1-mvx then vsx:=vlx1-319;
    end else
    begin
     if vsy>vly2 then vsy:=vly2;
     if vsx>vlx2 then vsx:=vlx2;
     if vsy<vly2-mvy then vsy:=vly2-199;
     if vsx<vlx2-mvx then vsx:=vlx2-319;
    end;
   end else
   begin
    if vpt=0 then
    begin
     if vsy>vly1 then vsy:=vly1;
     if vsx>vlx1 then vsx:=vlx1;
     if vsy<vly1-mvy then vsy:=vly1-mvy+1;
     if vsx<vlx1-mvx then vsx:=vlx1-mvx+1;
    end else
    begin
     if vsy>vly2 then vsy:=vly2;
     if vsx>vlx2 then vsx:=vlx2;
     if vsy<vly2-mvy then vsy:=vly2-mvy+1;
     if vsx<vlx2-mvx then vsx:=vlx2-mvx+1;
    end;
   end;
  end;
  if fullscreen then
  begin
   if vsy>vmy-199 then vsy:=vmy-200;
   if vsx>vmx-319 then vsx:=vmx-320;
  end else
  begin
   if vsy>vmy-mvy then vsy:=vmy-mvy;
   if vsx>vmx-mvx then vsx:=vmx-mvx;
  end;
  if vsy<0 then vsy:=0;
  if vsx<0 then vsx:=0;
  if terminat then
  if (tasta.citita)and(tasta.zero)and(tasta.cod=tins) then
  begin
   if not vsel then
   begin
    vpt:=0;
    vlx1:=vsx;
    vlx2:=vsx;
    vly1:=vsy;
    vly2:=vsy;
    vsel:=true;
   end else
   begin
    vsel:=false;
    vlx1:=0;
    lx1:=1;
    afisezimagine;
   end;
  end;
  if vsel then
  if(tasta.citita)and(not tasta.zero)and(tasta.cod=ttab) then
  begin
   if vpt=0 then vpt:=1 else
   vpt:=0;
  end;
  if vsel then
  if(tasta.citita)and(not tasta.zero)and(tasta.cod=tctrla) then
  begin
   vlx1:=0;vlx2:=sx-1;
   vly1:=0;vly2:=sy-1;
  end;
  if(tasta.citita)and(not tasta.zero)and(tasta.cod=tctrln) then
  begin
   vlx1:=0;vlx2:=0;
   vly1:=0;vly2:=0;
  end;
  if vsel then
  if (tasta.citita)and(not tasta.zero)and(tasta.cod=tenter) then
  begin
   afisezimagine;
   vreausasalvez;
   repnokey;
   elimintasta;
   exit;
  end;
  if (tasta.citita)and(not tasta.zero)and(tasta.cod=tesc) then
  begin
   anuleaza:=true;
   elimintasta;
   iesima:=true;
    vsel:=false;
   exit;
  end;
  if (tasta.citita)and(tasta.zero)and((tasta.cod=tpgup)or(tasta.cod=tpgdn)) then
  begin
   if (tasta.cod=tpgup)and(epoz+dpoz>1) then
   begin
    miscate:=1;
    iesima:=true;
   end;
   if (tasta.cod=tpgdn)and(epoz+dpoz<nre) then
   begin
    miscate:=2;
    iesima:=true;
   end;
   elimintasta;
   exit;
  end;
 until not tasta.citita;
 elimintasta;
end;

procedure initimgspace(x,y: word);
var lx,ly,l: longint;
begin
 nom:=false;
 if searchmem=0 then
 begin
  initmembuf256(mbimg,x,y,true);
  if erb256 then
  begin
   nom:=true;
   lx:=x;
   ly:=y;
   l:=lx*ly;
   createvirtual(l);
   exit;
  end;
 end;
 if searchmem=1 then
 begin
  initmembuf256(mbimg,x,y,true);
  if erb256 then
  begin
   nom:=true;
   exit;
  end;
 end;
 if searchmem=2 then
 begin
  lx:=x;
  ly:=y;
  l:=lx*ly;
  createvirtual(l);
 end;
end;

function readbyte: byte;
begin
 pozbuf:=pozbuf+1;
 if pozbuf>sizeof(minibuf^) then
 begin
  pozbuf:=1;
  blockread(f,minibuf^,sizeof(minibuf^),w);
 end;
 readbyte:=minibuf^[pozbuf];
end;

procedure incarcini;
var f: file;
begin
 scanez:=false;
 elimin:=false;
 sunet:=false;
 fullscreen:=false;
 assign(f,numeini);
 reset(f,1);
 if rezultat<>0 then exit;
 blockread(f,buf,9,w);
 close(f);
 if buf[1]<>#0 then scanez:=true;
 if buf[2]<>#0 then elimin:=true;
 if buf[3]<>#0 then sunet:=true;
 searchmem:=ord(buf[4]);
 if searchmem>2 then searchmem:=2;
 for x:=1 to 4 do
 begin
  speed[x]:=ord(buf[4+x]);
  if speed[x]>4 then speed[x]:=4;
 end;
 speedn:=speed[1];
 speedna:=speed[2];
 speedc:=speed[3];
 speedca:=speed[4];
 setspeed(speedn,speedna,speedc,speedca);
 if buf[9]<>#0 then fullscreen:=true;
end;

procedure mischome;
begin
 dpoz:=0;
 epoz:=1;
end;

procedure miscend;
begin
 if nre>=dp then
 begin
  dpoz:=nre-dp;
  epoz:=dp;
 end else
 begin
  dpoz:=0;
  epoz:=nre;
 end;
end;

procedure miscsus;
begin
 epoz:=epoz-1;
 if epoz<1 then
 if dpoz<=0 then
 begin
  dpoz:=0;
  epoz:=1;
 end else
 begin
  dpoz:=dpoz-1;
  epoz:=1;
 end;
end;

procedure miscjos;
begin
 if epoz+dpoz>=nre then exit;
 if nre<dp then
 begin
  if epoz<nre then epoz:=epoz+1;
 end else
 begin
  if epoz<dp then epoz:=epoz+1 else
  if dpoz<nre-dp then
  begin
   epoz:=dp;
   dpoz:=dpoz+1;
  end;
 end;
end;

procedure miscpgdn;
begin
 for x:=1 to dp do miscjos;
end;

procedure miscpgup;
begin
 for x:=1 to dp do miscsus;
end;

procedure initb;
begin
 nom:=false;
 tb:=ptr(mhmemaloc(sizeof(tb^)),0);
 if eraloc<>0 then nom:=true;
 tc:=ptr(mhmemaloc(sizeof(tc^)),0);
 if eraloc<>eranimic then
 begin
  halt;
  nom:=true;
 end;
 nom:=false;
 b:=ptr(mhmemaloc(64000),0);
 if eraloc<>0 then
 begin
  nom:=true;
  mhmemdealoc(seg(b^));
  halt;
 end;
 mbt.adrese[1].p:=seg(b^);
 mbt.rx:=320;
 mbt.ry:=200;
 mbt.vx1:=0;
 mbt.vx2:=319;
 mbt.vy1:=0;
 mbt.vy2:=199;
 mbt.adrese[1].alocat:=true;
 mbt.alocat:=true;
 mbt.tip:=ecrmem256;
 nom:=false;
 c:=ptr(mhmemaloc(64000),0);
 if eraloc<>0 then
 begin
  nom:=true;
  mhmemdealoc(seg(c^));
  halt;
 end;
 nom:=false;
 d:=ptr(mhmemaloc(64000),0);
 if eraloc<>0 then
 begin
  nom:=true;
  mhmemdealoc(seg(d^));
  halt;
 end;
 minibuf:=ptr(seg(d^),0);
end;

procedure incarcmvb;
var vr: longint;
begin
 seek(f,0);
 size:=filesize(f);
 if sx>=255 then
 begin
  size:=size-3;
  vr:=7;
 end else
 begin
  size:=size-2;
  vr:=6;
 end;
 anuleaza:=false;
 seek(f,vr);
 pal:=normpal;
 for x:=0 to sx-1 do
 begin
  bcitit:=bcitit+sy;
  blockread(f,buf,sy,w);
  for y:=0 to sy-1 do
  begin
   if virtualmem then ppix256(mbimg,x,y,ord(buf[y+1])) else
   putpixel256(mbimg,x,y,ord(buf[y+1]));
  end;
  if bcitit>=size then
  begin
   afisezimagine;
   exit;
  end;
  if (x+1)mod speedv[0][speedn]=0 then
  begin
   afisezimagine;
   verificies;
   if iesima then exit;
  end;
 end;
 afisezimagine;
 terminat:=true;
end;

procedure incarcmhb;
begin
 seek(f,0);
 size:=filesize(f);
 anuleaza:=false;
 size:=size-8;
 seek(f,8);
 pal:=normpal1;
 for y:=0 to sy-1 do
 begin
  bcitit:=bcitit+sx;
  blockread(f,orzline,sx,w);
  if virtualmem then wline256(mbimg,0,sx-1,y) else
  writeline256(mbimg,0,sx-1,y);
  if bcitit>=size then
  begin
   afisezimagine;
   exit;
  end;
  if (y+1) mod speedv[0][speedn]=0 then
  begin
   afisezimagine;
   verificies;
   if iesima then exit;
  end;
 end;
 afisezimagine;
 terminat:=true;
end;

procedure incarcmhv;
begin
 seek(f,0);
 size:=filesize(f);
 anuleaza:=false;
 size:=size-8;
 seek(f,8);
 pal:=normpal;
 for y:=0 to sy-1 do
 begin
  bcitit:=bcitit+sx;
  blockread(f,orzline,sx,w);
  if virtualmem then wline256(mbimg,0,sx-1,y) else
  writeline256(mbimg,0,sx-1,y);
  if bcitit>=size then
  begin
   afisezimagine;
   exit;
  end;
  if (y+1) mod speedv[0][speedn]=0 then
  begin
   afisezimagine;
   verificies;
   if iesima then exit;
  end;
 end;
 afisezimagine;
 terminat:=true;
end;

procedure incarcmhp;
begin
 seek(f,0);
 size:=filesize(f);
 anuleaza:=false;
 size:=size-8;
 seek(f,8);
 blockread(f,pal,768,w);
 for y:=0 to sy-1 do
 begin
  bcitit:=bcitit+sx;
  blockread(f,orzline,sx,w);
  if virtualmem then wline256(mbimg,0,sx-1,y) else
  writeline256(mbimg,0,sx-1,y);
  if bcitit>=size then
  begin
   afisezimagine;
   exit;
  end;
  if (y+1)mod speedv[0][speedn]=0 then
  begin
   afisezimagine;
   verificies;
   if iesima then exit;
  end;
 end;
 afisezimagine;
 terminat:=true;
end;

procedure incarcmcb;
var rest: integer;
    pot,incp: longint;
    miscjos: boolean;
begin
 anuleaza:=false;
 seek(f,0);
 size:=filesize(f);
 pozbuf:=sizeof(minibuf^);
 pal:=normpal1;
 seek(f,8);
 count:=1;
 contor:=0;
 while (contor<=btotal)and(count<=size-776) do
 begin
  cv:=trunc(contor/speedv[2][speedc]);
  rep:=readbyte;
  count:=count+1;
  aux:=readbyte;
  count:=count+1;
  x:=contor mod sx-1;
  y:=trunc(contor/sx);
  incp:=x;
  bcitit:=bcitit+rep;
  repeat
   miscjos:=false;
   pot:=rep;
   if pot+incp>=sx then
   begin
    pot:=sx-incp;
    miscjos:=true;
   end;
   if virtualmem then umplulo(mbimg,incp,incp+pot-1,y,aux) else
   lo256(mbimg,incp,incp+pot-1,y,aux);
   contor:=contor+pot;
   rep:=rep-pot;
   if miscjos then
   begin
    y:=y+1;
    incp:=0;
   end;
  until rep=0;
  if trunc(contor/speedv[2][speedc])<>cv then
  begin
   afisezimagine;
   verificies;
   if iesima then
   begin
    exit;
   end;
  end;
 end;
 afisezimagine;
 terminat:=true;
end;

procedure incarcmcp;
var rest: integer;
    pot,incp: longint;
    miscjos: boolean;
begin
 anuleaza:=false;
 seek(f,0);
 size:=filesize(f);
 pozbuf:=sizeof(minibuf^);
 seek(f,8);
 blockread(f,pal,768,w);
 count:=1;
 contor:=0;
 while (contor<=btotal)and(count<=size-776) do
 begin
  cv:=trunc(contor/speedv[2][speedc]);
  rep:=readbyte;
  count:=count+1;
  aux:=readbyte;
  count:=count+1;
  x:=contor mod sx-1;
  y:=trunc(contor/sx);
  incp:=x;
  bcitit:=bcitit+rep;
  repeat
   miscjos:=false;
   pot:=rep;
   if pot+incp>=sx then
   begin
    pot:=sx-incp;
    miscjos:=true;
   end;
   if virtualmem then umplulo(mbimg,incp,incp+pot-1,y,aux) else
   lo256(mbimg,incp,incp+pot-1,y,aux);
   contor:=contor+pot;
   rep:=rep-pot;
   if miscjos then
   begin
    y:=y+1;
    incp:=0;
   end;
  until rep=0;
  if trunc(contor/speedv[2][speedc])<>cv then
  begin
   afisezimagine;
   verificies;
   if iesima then
   begin
    exit;
   end;
  end;
 end;
 afisezimagine;
 terminat:=true;
end;

procedure incarccel;
begin
 anuleaza:=false;
 seek(f,32);
 blockread(f,pal,768,w);
 for y:=0 to sy-1 do
 begin
  bcitit:=bcitit+sx;
  blockread(f,orzline,sx,w);
  if virtualmem then wline256(mbimg,0,sx-1,y) else
  writeline256(mbimg,0,sx-1,y);
  move(buf,b^[y,0],sx);
  if (y+1)mod speedv[0][speedn]=0 then
  begin
   afisezimagine;
   verificies;
   if iesima then exit;
  end;
 end;
 afisezimagine;
 terminat:=true;
end;

procedure incarcpcx;
var rest: integer;
    fsize: longint;
    pot,incp: longint;
    miscjos: boolean;
    sxv,syv: word;
begin
 anuleaza:=false;
 seek(f,0);
 size:=filesize(f);
 pozbuf:=sizeof(minibuf^);
 fsize:=size;
 if bpp=8 then
 begin
  seek(f,size-768);
  blockread(f,pal,768,w);
  for x:=0 to 255 do
  for y:=1 to 3 do
  pal[x][y]:=pal[x][y] div 4;
  seek(f,128);
  count:=1;
  contor:=0;
  while (contor<=btotal)and(count<=fsize) do
  begin
   cv:=trunc(contor/speedv[2][speedc]);
   x:=contor mod sx;
   y:=trunc(contor/sx);
   aux:=readbyte;
   if aux>$C0 then
   begin
    rep:=aux-$C0;
    count:=count+1;
    aux:=readbyte;
    count:=count+1;
    x:=contor mod sx;
    y:=trunc(contor/sx);
    incp:=x;
    bcitit:=bcitit+rep;
    repeat
     miscjos:=false;
     pot:=rep;
     if pot+incp>=sx then
     begin
      pot:=sx-incp;
      miscjos:=true;
     end;
     if virtualmem then umplulo(mbimg,incp,incp+pot-1,y,aux) else
     lo256(mbimg,incp,incp+pot-1,y,aux);
     contor:=contor+pot;
     rep:=rep-pot;
     if miscjos then
     begin
      y:=y+1;
      incp:=0;
     end;
    until rep=0;
   end else
   begin
    bcitit:=bcitit+1;
    if virtualmem then ppix256(mbimg,x,y,aux) else
    putpixel256(mbimg,x,y,aux);
    count:=count+1;
    contor:=contor+1;
   end;
   if trunc(contor/speedv[2][speedc])<>cv then
   begin
    afisezimagine;
    verificies;
    if iesima then
    begin
     sx:=sxv;
     sy:=syv;
     exit;
    end;
   end;
  end;
 end;
 afisezimagine;
 terminat:=true;
end;

procedure incarcbmp;
var z,t: integer;
    bt: byte;
begin
 anuleaza:=false;
 if compresie=0 then
 if bpp=1 then
 begin
  pozbuf:=sizeof(minibuf^);
  pal:=normpal1;
  seek(f,54);
  for x:=0 to 1 do
  begin
   blockread(f,bt,1,w);
   pal[x][3]:=bt div 4;
   blockread(f,bt,1,w);
   pal[x][2]:=bt div 4;
   blockread(f,bt,1,w);
   pal[x][1]:=bt div 4;
   blockread(f,bt,1,w);
  end;
  for y:=0 to sy-1 do
  begin
   bcitit:=bcitit+sx;
   for x:=0 to sx-1 do
   begin
    z:=x mod 8;
    if z=0 then buf[1]:=chr(readbyte);
    bt:=byte(buf[1])and(1 shl z);
    orzline[x+1]:=bt;
   end;
   if virtualmem then wline256(mbimg,0,sx-1,sy-y-1) else
   writeline256(mbimg,0,sx-1,sy-y-1);
   if (sy-y-1) mod speedv[0][speedn]=0 then
   begin
    afisezimagine;
    verificies;
    if iesima then
    begin
     elimintasta;
     exit;
    end;
   end;
  end;
 end;
 if compresie=0 then
 if bpp=4 then
 begin
  pozbuf:=sizeof(minibuf^);
  pal:=normpal1;
  seek(f,54);
  for x:=0 to 15 do
  begin
   blockread(f,bt,1,w);
   pal[x][3]:=bt div 4;
   blockread(f,bt,1,w);
   pal[x][2]:=bt div 4;
   blockread(f,bt,1,w);
   pal[x][1]:=bt div 4;
   blockread(f,bt,1,w);
  end;
  for y:=0 to sy-1 do
  begin
   bcitit:=bcitit+sx;
   for x:=0 to sx-1 do
   begin
    if x mod 2=0 then
    begin
     buf[1]:=chr(readbyte);
     bt:=(byte(buf[1]) and (not $f))shr 4;
    end else
    bt:=byte(buf[1]) and (not $F0);
    orzline[x+1]:=bt;
   end;
   if virtualmem then wline256(mbimg,0,sx-1,sy-y-1) else
   writeline256(mbimg,0,sx-1,sy-y-1);
   if (sy-y-1) mod speedv[0][speedn]=0 then
   begin
    afisezimagine;
    verificies;
    if iesima then
    begin
     exit;
    end;
   end;
  end;
 end;
 if compresie=0 then
 if bpp=8 then
 begin
  seek(f,54);
  for x:=0 to 255 do
  begin
   blockread(f,bt,1,w);
   pal[x][3]:=bt div 4;
   blockread(f,bt,1,w);
   pal[x][2]:=bt div 4;
   blockread(f,bt,1,w);
   pal[x][1]:=bt div 4;
   blockread(f,bt,1,w);
  end;
  for y:=0 to sy-1 do
  begin
   bcitit:=bcitit+sx;
   blockread(f,orzline,sx,w);
   if virtualmem then wline256(mbimg,0,sx-1,sy-y-1) else
   writeline256(mbimg,0,sx-1,sy-y-1);
   if (sy-y-1) mod speedv[0][speedn]=0 then
   begin
    afisezimagine;
    verificies;
    if iesima then exit;
   end;
  end;
 end;
 if compresie=0 then
 if bpp=16 then
 begin
  pozbuf:=sizeof(minibuf^);
  seek(f,54);
  pal:=normpal1;
  for y:=0 to sy-1 do
  begin
   bcitit:=bcitit+sx;
   blockread(f,c^[0,0],sx*2,w);
   for x:=0 to sx-1 do
   begin
    wd:=memw[seg(c^):x*2];
    b1:=0;b2:=0;b3:=0;
    for z:=0 to 4 do
    if (wd and (1 shl z))<>0 then
    b3:=b3 or (1 shl z);
    for z:=0 to 4 do
    if (wd and (1 shl (z+5)))<>0 then
    b2:=b2 or (1 shl z);
    for z:=0 to 4 do
    if (wd and (1 shl (z+10)))<>0 then
    b1:=b1 or (1 shl z);
    orzline[x+1]:=palnearpalcolor(pal,b1,b2,b3);
   end;
   if virtualmem then wline256(mbimg,0,sx-1,sy-y-1) else
   writeline256(mbimg,0,sx-1,sy-y-1);
   if(sy-y-1) mod speedv[1][speedna]=0 then
   begin
    afisezimagine;
    verificies;
    if iesima then
    begin
     exit;
    end;
   end;
  end;
 end;
 if compresie=0 then
 if bpp=24 then
 begin
  pozbuf:=sizeof(minibuf^);
  seek(f,54);
  pal:=normpal1;
  for y:=0 to sy-1 do
  begin
   bcitit:=bcitit+sx;
   blockread(f,c^[0,0],sx*3,w);
   for x:=0 to sx-1 do
   begin
    b1:=mem[seg(c^):x*3] div 4;
    b2:=mem[seg(c^):x*3+1] div 4;
    b3:=mem[seg(c^):x*3+2] div 4;
    orzline[x+1]:=palnearpalcolor(pal,b3,b2,b1);
   end;
   if virtualmem then wline256(mbimg,0,sx-1,sy-y-1) else
   writeline256(mbimg,0,sx-1,sy-y-1);
   if (sy-y-1) mod speedv[1][speedna]=0 then
   begin
    afisezimagine;
    verificies;
    if iesima then
    begin
     exit;
    end;
   end;
  end;
 end;
 afisezimagine;
 terminat:=true;
end;

procedure incarcico;
var z,t: integer;
    id,bt: byte;
    s: string[20];
    pline: integer;
    byteul,bitul: integer;
begin
 anuleaza:=false;
 if bpp=4 then
 begin
  pozbuf:=sizeof(minibuf^);
  pal:=normpal1;
  seek(f,62);
  for x:=0 to 15 do
  begin
   blockread(f,bt,1,w);
   pal[x][3]:=bt div 4;
   blockread(f,bt,1,w);
   pal[x][2]:=bt div 4;
   blockread(f,bt,1,w);
   pal[x][1]:=bt div 4;
   blockread(f,bt,1,w);
  end;
  seek(f,4);
  blockread(f,id,1,w);
  seek(f,126+(id-1)*16);
  for y:=0 to sy-1 do
  begin
   bcitit:=bcitit+sx;
   for x:=0 to sx-1 do
   begin
    if x mod 2=0 then
    begin
     buf[1]:=chr(readbyte);
     bt:=(byte(buf[1]) and (not $f))shr 4;
    end else
    bt:=byte(buf[1]) and (not $F0);
    orzline[x+1]:=bt;
   end;
   if virtualmem then wline256(mbimg,0,sx-1,sy-y-1) else
   writeline256(mbimg,0,sx-1,sy-y-1);
   if (sy-y-1) mod speedv[0][speedn]=0 then
   begin
    afisezimagine;
    verificies;
    if iesima then
    begin
     exit;
    end;
   end;
  end;
 end;
 if bpp=8 then
 begin
  seek(f,62);
  for x:=0 to 255 do
  begin
   blockread(f,bt,1,w);
   pal[x][3]:=bt div 4;
   blockread(f,bt,1,w);
   pal[x][2]:=bt div 4;
   blockread(f,bt,1,w);
   pal[x][1]:=bt div 4;
   blockread(f,bt,1,w);
  end;
  seek(f,1078+8);
  for y:=0 to sy-1 do
  begin
   bcitit:=bcitit+sx;
   blockread(f,orzline,sx,w);
   if virtualmem then wline256(mbimg,0,sx-1,sy-y-1) else
   writeline256(mbimg,0,sx-1,sy-y-1);
   if (sy-y-1) mod speedv[0][speedn]=0 then
   begin
    afisezimagine;
    verificies;
    if iesima then exit;
   end;
  end;
 end;
 if bpp=16 then
 begin
  pozbuf:=sizeof(minibuf^);
  seek(f,62);
  pal:=normpal1;
  for y:=0 to sy-1 do
  begin
   bcitit:=bcitit+sx;
   blockread(f,c^[0,0],sx*2,w);
   for x:=0 to sx-1 do
   begin
    wd:=memw[seg(c^):x*2];
    b1:=0;b2:=0;b3:=0;
    for z:=0 to 4 do
    if (wd and (1 shl z))<>0 then
    b1:=b1 or (1 shl z);
    for z:=0 to 4 do
    if (wd and (1 shl (z+5)))<>0 then
    b2:=b2 or (1 shl z);
    for z:=0 to 4 do
    if (wd and (1 shl (z+10)))<>0 then
    b3:=b3 or (1 shl z);
    orzline[x+1]:=palnearpalcolor(pal,b1,b2,b3);
   end;
   if virtualmem then wline256(mbimg,0,sx-1,sy-y-1) else
   writeline256(mbimg,0,sx-1,sy-y-1);
   if (sy-y-1) mod speedv[1][speedna]=0 then
   begin
    afisezimagine;
    verificies;
    if iesima then
    begin
     exit;
    end;
   end;
  end;
 end;
 if bpp=24 then
 begin
  if nom then exit;
  pozbuf:=sizeof(minibuf^);
  seek(f,62);
  pal:=normpal1;
  for y:=0 to sy-1 do
  begin
   bcitit:=bcitit+sx;
   blockread(f,c^[0,0],sx*3,w);
   for x:=0 to sx-1 do
   begin
    b1:=mem[seg(c^):x*3] div 4;
    b2:=mem[seg(c^):x*3+1] div 4;
    b3:=mem[seg(c^):x*3+2] div 4;
    orzline[x+1]:=palnearpalcolor(pal,b3,b2,b1);
   end;
   if virtualmem then wline256(mbimg,0,sx-1,sy-y-1) else
   writeline256(mbimg,0,sx-1,sy-y-1);
   if (sy-y-1) mod speedv[1][speedna]=0 then
   begin
    afisezimagine;
    verificies;
    if iesima then
    begin
     exit;
    end;
   end;
  end;
 end;
 afisezimagine;
 terminat:=true;
end;

procedure incarctga;
var pot,incp: longint;
    miscjos: boolean;
    z: byte;
begin
 seek(f,0);
 size:=filesize(f);
 anuleaza:=false;
 seek(f,5);
 blockread(f,z,1,w);
 seek(f,18);
 pal:=normpal1;
 if z=4 then
 begin
  for x:=0 to 15 do
  begin
   blockread(f,pal[x][3],1,w);
   blockread(f,pal[x][2],1,w);
   blockread(f,pal[x][1],1,w);
   for y:=1 to 3 do
   pal[x][y]:=pal[x][y] div 4;
  end;
 end else
 begin
  for x:=0 to 255 do
  begin
   blockread(f,pal[x][3],1,w);
   blockread(f,pal[x][2],1,w);
   blockread(f,pal[x][1],1,w);
   for y:=1 to 3 do
   pal[x][y]:=pal[x][y] div 4;
  end;
 end;
 if not compresat then
 begin
  if bpp=8 then
  begin
   for y:=0 to sy-1 do
   begin
    bcitit:=bcitit+sx;
    blockread(f,orzline,sx,w);
    if invers then
    begin
     if virtualmem then wline256(mbimg,0,sx-1,sy-y) else
     writeline256(mbimg,0,sx-1,sy-y);
    end else
    begin
     if virtualmem then wline256(mbimg,0,sx-1,y) else
     writeline256(mbimg,0,sx-1,y);
    end;
    if (y+1)mod speedv[0][speedn]=0 then
    begin
     afisezimagine;
     verificies;
     if iesima then
     begin
      exit;
     end;
    end;
   end;
  end;
 end;
 if compresat then
 if compresie=9 then
 begin
  if nom then exit;
  pozbuf:=sizeof(minibuf^);
  if bpp=8 then
  begin
   count:=1;
   contor:=0;
   while (contor<=btotal)and(count<=size-768-18) do
   begin
    cv:=trunc(contor/speedv[2][speedc]);
    rep:=readbyte;
    count:=count+1;
    aux:=readbyte;
    count:=count+1;
    x:=contor mod sx-1;
    y:=trunc(contor/sx);
    incp:=x;
    bcitit:=bcitit+rep;
    repeat
     miscjos:=false;
     pot:=rep;
     if pot+incp>=sx then
     begin
      pot:=sx-incp;
      miscjos:=true;
     end;
     if virtualmem then umplulo(mbimg,incp,incp+pot-1,y,aux) else
     lo256(mbimg,incp,incp+pot-1,y,aux);
     contor:=contor+pot;
     rep:=rep-pot;
     if miscjos then
     begin
      y:=y+1;
      incp:=0;
     end;
    until rep=0;
    if trunc(contor/speedv[2][speedc])<>cv then
    begin
     afisezimagine;
     verificies;
     if iesima then
     begin
      exit;
     end;
    end;
   end;
  end;
 end;
 afisezimagine;
 terminat:=true;
end;

procedure incarcdupaformat;
begin
 vsel:=false;
 terminat:=false;
 virtualmem:=false;
 vsx:=0;
 vsy:=0;
 iesima:=false;
 preamare:=false;
 donemembuf256(mbimg);
 if (sx>3000)or(sy>3000) then
 begin
  preamare:=true;
  btotal:=1;
  bcitit:=1;
  exit;
 end;
 if (sx<1)or(sy<1)then
 begin
  sx:=1;
  sy:=1;
  btotal:=1;
  bcitit:=1;
  exit;
 end;
 vmx:=sx;vmy:=sy;
 btotal:=vmx*vmy;
 bcitit:=0;
 initimgspace(sx,sy);
 if nom then exit;
 citesctimp(timp1);
 citesctimp(timp2);
 afisezimagine;
 if format=fmvb then incarcmvb;
 if format=fmhv then incarcmhv;
 if format=fmhb then incarcmhb;
 if format=fmhp then incarcmhp;
 if format=fmcb then incarcmcb;
 if format=fmcp then incarcmcp;
 if format=fcel then incarccel;
 if format=fpcx then incarcpcx;
 if format=fbmp then incarcbmp;
 if format=fico then incarcico;
 if format=ftga then incarctga;
 terminat:=true;
end;

procedure arataimagine(poz: integer);
var iesire: boolean;
    stx,sty: integer;
    numef: string;
begin
 vsx:=0;
 vsy:=0;
 anuleaza:=false;
 iesima:=false;
 miscate:=0;
 numef:=upstring(fullstring(panou[poz].nume,panou[poz].ext));
 assign(f,numef);
 reset(f,1);
 if rezultat<>0 then exit;
 if not panou[poz].scan then
 begin
  gasescformat;
  panou[poz].scan:=true;
  norm2rec(poz);
  if panou[poz].format<>fnecunoscut then nrimg:=nrimg+1;
  nrs:=nrs+1;
 end;
 if panou[poz].format=fnecunoscut then
 begin
  close(f);
  exit;
 end;
 nom:=false;
 elimintasta;
 if nom then
 begin
  close(f);
  exit;
 end;
 elimintasta;
 if nom then
 begin
  close(f);
  exit;
 end;
 clearbuf(b,0);
 a^:=b^;
 initgr;
 pal:=normpal1;
 iesire:=false;
 rec2norm(poz);
 nom:=false;
 incarcdupaformat;
 if (not anuleaza)and formatgasit and (not nom) then
 if sunet then sunetgata;
 if anuleaza then
 if sunet then sunetstop;
 close(f);
 repeat
  iesima:=false;
  if miscate=1 then
  begin
   miscate:=0;
   elimintasta;
   miscsus;
   poz:=epoz+dpoz;
   if ((panou[epoz+dpoz].attr and directory)<>0)or anuleaza then
   begin
    anuleaza:=false;
    donemembuf256(mbimg);
    exit;
   end;
   numef:=upstring(fullstring(panou[poz].nume,panou[poz].ext));
   assign(f,numef);
   reset(f,1);
   if rezultat<>0 then
   begin
    donemembuf256(mbimg);
    exit;
   end;
   if not panou[poz].scan then
   begin
    gasescformat;
    panou[poz].scan:=true;
    norm2rec(poz);
    nrs:=nrs+1;
    if format<>fnecunoscut then nrimg:=nrimg+1;
   end;
   clearbuf(b,0);
   a^:=b^;
   rec2norm(poz);
   nom:=false;
   incarcdupaformat;
   if (not anuleaza)and formatgasit and (not nom) then
   if sunet then sunetgata;
   if anuleaza then
   if sunet then sunetstop;
   close(f);
  end;
  if miscate=2 then
  begin
   miscate:=0;
   elimintasta;
   miscjos;
   poz:=epoz+dpoz;
   if (panou[epoz+dpoz].attr and directory)<>0 then
   begin
    donemembuf256(mbimg);
    exit;
   end;
   if epoz+dpoz<>pozv then
   begin
    numef:=upstring(fullstring(panou[poz].nume,panou[poz].ext));
    assign(f,numef);
    reset(f,1);
    if rezultat<>0 then
    begin
     donemembuf256(mbimg);
     exit;
    end;
    poz:=epoz+dpoz;
    if not panou[poz].scan then
    begin
     gasescformat;
     panou[poz].scan:=true;
     norm2rec(poz);
     nrs:=nrs+1;
     if format<>fnecunoscut then nrimg:=nrimg+1;
    end;
    clearbuf(b,0);
    a^:=b^;
    rec2norm(poz);
    nom:=false;
    incarcdupaformat;
    close(f);
    if (not anuleaza)and formatgasit and (not nom) then
    if sunet then sunetgata;
    if anuleaza then
    if sunet then sunetstop;
   end;
  end;
  verificies;
  elimintasta;
  citesctasta;
  if (tasta.citita)and(tasta.zero)and
  ((tasta.cod=ord('r'))or(tasta.cod=ord('R'))) then
  begin
   elimintasta;
   clearbuf(b,0);
   a^:=b^;
   rec2norm(poz);
   nom:=false;
   incarcdupaformat;
   if (not anuleaza)and formatgasit and (not nom) then
   if sunet then sunetgata;
   if anuleaza then
   if sunet then sunetstop;
  end;
  if ((tasta.citita)and(not tasta.zero)and(tasta.cod=tesc))or(anuleaza) then
  iesire:=true;
  if nom then iesire:=true;
  afisezimagine;
  if panou[epoz+dpoz].format=fnecunoscut then exit;
  pozv:=epoz+dpoz;
 until iesire;
 donemembuf256(mbimg);
 elimintasta;
end;

procedure selectaredrive;
var iesire,selectat,estedisc: boolean;
    st: string;
    xp,yp,nr,sdrive: integer;
    nrlinii: integer;
    linie: array[1..5] of integer;
begin
 sttemp:=curentdrivedir;
 curentvdir:=curentdrivedir;
 tc^:=tb^;
 setcharcolor(9);
 setbaccolor(1);
 setchar(#0);
 ferg80x25(tb,5,7,76,20,'Alege noul drive');
 iesire:=false;
 selectat:=false;
 estedisc:=false;
 for x:=1 to 26 do
 drive[x]:=validdrive(x);
 nr:=0;
 for x:=1 to 26 do
 if drive[x] then
 begin
  nr:=nr+1;
  xp:=15+((nr-1) mod 7)*8;
  yp:=9+trunc((nr-1)/7)*3;
  setbaccolor(14);
  setcharcolor(1);
  writestring80x25(tb,xp,yp,'  '+chr(ord('A')+x-1)+'  ',false,false,false);
 end;
 repeat
  elimintasta;
  citesctasta;
  for x:=1 to 26 do
  if (tasta.citita)and(not tasta.zero)and
  (tasta.cod=ord('a')-1+x)or(tasta.cod=ord('A')-1+x) then
  if drive[x] then
  begin
   selectat:=true;
   sdrive:=x;
   iesire:=true;
  end;
  ta^:=tb^;
  if (tasta.citita)and(not tasta.zero)and(tasta.cod=tesc) then
  begin
   ta^:=tc^;
   tb^:=tc^;
   elimintasta;
   exit;
  end;
 until iesire;
 getdir(sdrive,curentdrivedir);
 if rezultat=0 then
 begin
  chdir(curentdrivedir);
 end;
 if rezultat<>0 then
 begin
  setcharcolor(9);
  setbaccolor(1);
  setchar(#0);
  ferg80x25(tb,7,10,74,12,'??Eroare la schimbarea drive-ului??');
  writestring80x25(tb,1,11,'Nu este disc in drive-ul '+
  chr(sdrive+ord('A')-1)+':!',false,false,true);
  ta^:=tb^;
  elimintasta;
  repeat
   elimintasta;
   citesctasta;
  until tasta.citita;
  tb^:=tc^;
  elimintasta;
  chdir(sttemp);
  curentdrivedir:=sttemp;
  exit;
 end;
 scandir;
 dpoz:=0;
 epoz:=1;
 elimintasta;
 tb^:=tc^;
end;

procedure ajutor;
const nrstrings=18;
var strgs: array[1..nrstrings] of string[72];
    nrec,pozc: integer;
begin
 nrec:=16;
 tc^:=tb^;
 pozc:=1;
 strgs[1]:='MSoft - Ajutorul de care ai nevoie';
 strgs[2]:='Ca sa derulezi in sus sau in jos';
 strgs[3]:='apasa tastele de directie';
 strgs[4]:='';
 strgs[5]:='Cand nu e incarcata imaginea:';
 strgs[6]:='';
 strgs[7]:='Tasta D - Alege un nou drive';
 strgs[8]:='Tasta \ - Se duce in radacina';
 strgs[9]:='Tasta BackSpace - Iese din director';
 strgs[10]:='Tasta I - Da informatii despre fisier';
 strgs[11]:='Tasta C - Converteste formatul (inca nu)';
 strgs[12]:='Tasta S - Scaneaza directorul curent in cautare de imagini';
 strgs[13]:='Tasta O - Intra in meniul de optiuni';
 strgs[14]:='';
 strgs[15]:='Cand e incarcata imaginea:';
 strgs[16]:='';
 strgs[17]:='Tasta sus urca la imaginea de sus';
 strgs[18]:='Tasta sus coboara la imaginea de jos';
 setcharcolor(4);
 setbaccolor(14);
 ferg80x25(tc,3,3,78,22,'Ajutor! Nu sunt de la MSoft!');
 repeat
  tb^:=tc^;
  elimintasta;
  citesctasta;
  if (tasta.citita)and(tasta.zero)and(tasta.cod=tjos) then
  pozc:=pozc+1;
  if (tasta.citita)and(tasta.zero)and(tasta.cod=tsus) then
  pozc:=pozc-1;
  if (tasta.citita)and(tasta.zero)and(tasta.cod=tpgdn) then
  pozc:=pozc+10;
  if (tasta.citita)and(tasta.zero)and(tasta.cod=tpgup) then
  pozc:=pozc-10;
  if pozc>nrstrings-nrec+1 then pozc:=nrstrings-nrec+1;
  if pozc<1 then pozc:=1;
  for x:=0 to nrec-1 do
  if x+pozc<=nrstrings then
  writestring80x25(tb,1,x+5,strgs[x+pozc],false,false,true);
  ta^:=tb^;
 until (tasta.citita)and(not tasta.zero)and(tasta.cod=tesc);
 elimintasta;
end;

procedure aratainformatii(poz: longint);
var nume: string;
begin
 nume:=upstring(fullstring(panou[poz].nume,panou[poz].ext));
 if not panou[poz].scan then
 begin
  assign(f,nume);
  reset(f,1);
  if rezultat<>0 then exit;
  gasescformat;
  panou[poz].scan:=true;
  norm2rec(poz);
  nrs:=nrs+1;
  if format<>fnecunoscut then nrimg:=nrimg+1;
  close(f);
 end;
 tc^:=tb^;
 setcharcolor(4);
 setbaccolor(14);
 ferg80x25(tb,3,3,78,23,'Informatii despre '+nume+':');
 if panou[poz].format=fnecunoscut then
 begin
  strtemp:='Format: necunoscut';
  writestring80x25(tb,1,5,strtemp,false,false,true);
  str(panou[poz].marime,s1);
  strtemp:='Marime fisier: '+s1;
  writestring80x25(tb,1,6,strtemp,false,false,true);
  strtemp:='Atribute: ';
  if (panou[poz].attr and archive)<>0 then strtemp:=strtemp+'A ' else
  strtemp:=strtemp+'- ';
  if (panou[poz].attr and readonly)<>0 then strtemp:=strtemp+'R ' else
  strtemp:=strtemp+'- ';
  if (panou[poz].attr and sysfile)<>0 then strtemp:=strtemp+'S ' else
  strtemp:=strtemp+'- ';
  if (panou[poz].attr and hidden)<>0 then strtemp:=strtemp+'H ' else
  strtemp:=strtemp+'- ';
  writestring80x25(tb,1,7,strtemp,false,false,true);
 end else
 begin
  strtemp:='Format: ';
  if panou[poz].format=fmvb then strtemp:=strtemp+'MVB ' else
  if panou[poz].format=fmhv then strtemp:=strtemp+'MHV ' else
  if panou[poz].format=fmhb then strtemp:=strtemp+'MHB ' else
  if panou[poz].format=fmhp then strtemp:=strtemp+'MHP ' else
  if panou[poz].format=fmcb then strtemp:=strtemp+'MCB ' else
  if panou[poz].format=fmcp then strtemp:=strtemp+'MCP ' else
  if panou[poz].format=fcel then strtemp:=strtemp+'CEL ' else
  if panou[poz].format=fpcx then strtemp:=strtemp+'PCX ' else
  if panou[poz].format=fbmp then strtemp:=strtemp+'BMP ' else
  if panou[poz].format=fico then strtemp:=strtemp+'ICO ' else
  if panou[poz].format=ftga then strtemp:=strtemp+'TGA ' else
  strtemp:=strtemp+'??? ';
  writestring80x25(tb,1,5,strtemp,false,false,true);
  str(panou[poz].marime,s1);
  strtemp:='Marime fisier: '+s1;
  writestring80x25(tb,1,6,strtemp,false,false,true);
  strtemp:='Atribute: ';
  if (panou[poz].attr and archive)<>0 then strtemp:=strtemp+'A ' else
  strtemp:=strtemp+'- ';
  if (panou[poz].attr and readonly)<>0 then strtemp:=strtemp+'R ' else
  strtemp:=strtemp+'- ';
  if (panou[poz].attr and sysfile)<>0 then strtemp:=strtemp+'S ' else
  strtemp:=strtemp+'- ';
  if (panou[poz].attr and hidden)<>0 then strtemp:=strtemp+'H ' else
  strtemp:=strtemp+'- ';
  writestring80x25(tb,1,7,strtemp,false,false,true);
  strtemp:='Compresie: ';
  if panou[poz].compresat then
  strtemp:=strtemp+'da, metoda '''+wordtost(panou[poz].compresie)+'''' else
  strtemp:=strtemp+'nu';
  writestring80x25(tb,1,8,strtemp,false,false,true);
  strtemp:='Paleta: ';
  if panou[poz].paleta then strtemp:=strtemp+'da' else
  strtemp:=strtemp+'nu';
  writestring80x25(tb,1,9,strtemp,false,false,true);
  strtemp:='Interlace: ';
  if panou[poz].interlace then strtemp:=strtemp+'da' else
  strtemp:=strtemp+'nu';
  writestring80x25(tb,1,10,strtemp,false,false,true);
  strtemp:='Imagine rasturnata: ';
  if panou[poz].invers then strtemp:=strtemp+'da' else
  strtemp:=strtemp+'nu';
  writestring80x25(tb,1,11,strtemp,false,false,true);
  strtemp:='Marime pe orizontala: ';
  str(panou[poz].sx,s1);
  strtemp:=strtemp+s1;
  writestring80x25(tb,1,12,strtemp,false,false,true);
  strtemp:='Marime pe verticala: ';
  str(panou[poz].sy,s1);
  strtemp:=strtemp+s1;
  writestring80x25(tb,1,13,strtemp,false,false,true);
  strtemp:='Nuante: ';
  if panou[poz].bpp<=8 then
  begin
   str(1 shl panou[poz].bpp,s1);
   s1:=s1+' culori';
  end else
  begin
   str(panou[poz].bpp,s1);
   s1:=s1+' biti';
  end;
  strtemp:=strtemp+s1;
  writestring80x25(tb,1,14,strtemp,false,false,true);
 end;
 repeat
  elimintasta;
  citesctasta;
  ta^:=tb^;
 until (tasta.citita);
 elimintasta;
 tb^:=tc^;
end;

procedure dutenoptiuni;
const maxmen=8;
var men: byte;
    menustr: array[1..maxmen] of string[72];
begin
 men:=1;
 menustr[1]:='Scanare automata a formatului: ';
 menustr[2]:='Eliminarea din panou a fisierelor fara imagine: ';
 menustr[3]:='Sunet: ';
 menustr[4]:='Alocarea memoriei: ';
 menustr[5]:='Viteza necompresat, 256 culori: ';
 menustr[6]:='Viteza necompresat, alte culori: ';
 menustr[7]:='Viteza compresat, 256 culori: ';
 menustr[8]:='Viteza compresat, alte culori: ';
 tc^:=tb^;
 setcharcolor(4);
 setbaccolor(14);
 ferg80x25(tc,3,3,78,22,'Optiuni:');
 repeat
  tb^:=tc^;
  elimintasta;
  citesctasta;
  if (tasta.citita)and(tasta.zero)and(tasta.cod=tsus) then men:=men-1;
  if (tasta.citita)and(tasta.zero)and(tasta.cod=tjos) then men:=men+1;
  if men>maxmen then men:=1;
  if men<1 then men:=maxmen;
  if (tasta.citita)and(not tasta.zero)and(tasta.cod=tenter) then
  begin
   if men=1 then
   begin
    if scanez then scanez:=false else
    scanez:=true;
   end;
   if men=2 then
   begin
    if elimin then elimin:=false else
    elimin:=true;
   end;
   if men=3 then
   begin
    if sunet then sunet:=false else
    sunet:=true;
   end;
   if men=4 then
   begin
    searchmem:=searchmem+1;
    if searchmem>2 then searchmem:=0;
   end;
   if men=5 then
   begin
    speedn:=speedn+1;
    if speedn>4 then speedn:=0;
   end;
   if men=6 then
   begin
    speedna:=speedna+1;
    if speedna>4 then speedna:=0;
   end;
   if men=7 then
   begin
    speedc:=speedc+1;
    if speedc>4 then speedc:=0;
   end;
   if men=8 then
   begin
    speedca:=speedca+1;
    if speedca>4 then speedca:=0;
   end;
  end;
  setcharcolor(4);
  setbaccolor(14);
  if 1=men then
  begin
   setcharcolor(14);
   setbaccolor(1);
  end;
  strtemp:=menustr[1];
  if scanez then strtemp:=strtemp+'da' else
  begin
   strtemp:=strtemp+'nu';
   elimin:=false;
  end;
  for x:=length(strtemp)+1 to 72 do strtemp:=strtemp+' ';
  writestring80x25(tb,5,5,strtemp,false,false,false);
  setcharcolor(4);
  setbaccolor(14);
  if 2=men then
  begin
   setcharcolor(14);
   setbaccolor(1);
  end;
  strtemp:=menustr[2];
  if elimin then strtemp:=strtemp+'da' else
  strtemp:=strtemp+'nu';
  for x:=length(strtemp)+1 to 72 do strtemp:=strtemp+' ';
  writestring80x25(tb,5,6,strtemp,false,false,false);
  setcharcolor(4);
  setbaccolor(14);
  if 3=men then
  begin
   setcharcolor(14);
   setbaccolor(1);
  end;
  strtemp:=menustr[3];
  if sunet then strtemp:=strtemp+'da' else
  strtemp:=strtemp+'nu';
  for x:=length(strtemp)+1 to 72 do strtemp:=strtemp+' ';
  writestring80x25(tb,5,7,strtemp,false,false,false);
  setcharcolor(4);
  setbaccolor(14);
  if 4=men then
  begin
   setcharcolor(14);
   setbaccolor(1);
  end;
  strtemp:=menustr[4];
  if searchmem=0 then strtemp:=strtemp+'mai intai RAM, apoi HDD';
  if searchmem=1 then strtemp:=strtemp+'numai RAM';
  if searchmem=2 then strtemp:=strtemp+'numai HDD';
  for x:=length(strtemp)+1 to 72 do strtemp:=strtemp+' ';
  writestring80x25(tb,5,8,strtemp,false,false,false);
  setcharcolor(4);
  setbaccolor(14);
  if 5=men then
  begin
   setcharcolor(14);
   setbaccolor(1);
  end;
  strtemp:=menustr[5];
  strtemp:=strtemp+speeds[0][speedn];
  for x:=length(strtemp)+1 to 72 do strtemp:=strtemp+' ';
  writestring80x25(tb,5,9,strtemp,false,false,false);
  setcharcolor(4);
  setbaccolor(14);
  if 6=men then
  begin
   setcharcolor(14);
   setbaccolor(1);
  end;
  strtemp:=menustr[6];
  strtemp:=strtemp+speeds[1][speedna];
  for x:=length(strtemp)+1 to 72 do strtemp:=strtemp+' ';
  writestring80x25(tb,5,10,strtemp,false,false,false);
  setcharcolor(4);
  setbaccolor(14);
  if 7=men then
  begin
   setcharcolor(14);
   setbaccolor(1);
  end;
  strtemp:=menustr[7];
  strtemp:=strtemp+speeds[2][speedc];
  for x:=length(strtemp)+1 to 72 do strtemp:=strtemp+' ';
  writestring80x25(tb,5,11,strtemp,false,false,false);
  setcharcolor(4);
  setbaccolor(14);
  if 8=men then
  begin
   setcharcolor(14);
   setbaccolor(1);
  end;
  strtemp:=menustr[8];
  strtemp:=strtemp+speeds[3][speedca];
  for x:=length(strtemp)+1 to 72 do strtemp:=strtemp+' ';
  writestring80x25(tb,5,12,strtemp,false,false,false);
  ta^:=tb^;
 until (tasta.citita)and(not tasta.zero)and(tasta.cod=tesc);
 elimintasta;
 tb^:=tc^;
end;

procedure stergfis;
begin
 tc^:=tb^;
 s:=upstring(fullstring(panou[epoz+dpoz].nume,panou[epoz+dpoz].ext));
 s:='Chiar vrei sa stergi fisierul '+s+'?';
 setcharcolor(14);
 setbaccolor(1);
 ferg80x25(tb,5,7,76,11,'Sterg! Ah ce-mi place asta!');
 writestring80x25(tb,1,8,s,false,false,true);
 setbaccolor(4);
 writestring80x25(tb,30,10,' Da ',false,false,false);
 writestring80x25(tb,45,10,' Nu ',false,false,false);
 repeat
  elimintasta;
  citesctasta;
  ta^:=tb^;
 until (tasta.citita)and(not tasta.zero)and
 ((tasta.cod=ord('d'))or(tasta.cod=ord('D'))
 or(tasta.cod=ord('n'))or(tasta.cod=ord('N')));
 if (tasta.cod=ord('d'))or(tasta.cod=ord('D')) then
 begin
  assign(f,fullstring(panou[epoz+dpoz].nume,panou[epoz+dpoz].ext));
  setfattr(f,0);
  erase(f);
  if rezultat=0 then
  begin
   if panou[epoz+dpoz].scan then
   begin
    nrs:=nrs-1;
    if panou[epoz+dpoz].format<>fnecunoscut then nrimg:=nrimg-1;
   end;
   for y:=epoz+dpoz to nre do
   if y<=nre-1 then
   panou[y]:=panou[y+1];
   nrf:=nrf-1;
   nre:=nre-1;
  end;
  miscsus;
 end;
 tb^:=tc^;
 elimintasta;
end;

procedure renumfis;
begin
 tc^:=tb^;
 s:=upstring(fullstring(panou[epoz+dpoz].nume,panou[epoz+dpoz].ext));
 s:='Renumesc fisierul '+s+'?';
 setcharcolor(14);
 setbaccolor(1);
 ferg80x25(tb,5,7,76,11,s);
 writestring80x25(tb,1,8,s,false,false,true);
 repeat
  elimintasta;
  citesctasta;
  ta^:=tb^;
 until tasta.citita;
 tb^:=tc^;
 elimintasta;
end;

begin
 pozf:=1;
 numef:='';
 svar:=100;
 mvar:=60*svar;
 hvar:=60*mvar;
 zvar:=24*hvar;
 virtualn:=upstring('MSOFT$$$.TMP');
 dirini:=paramstr(0);
 fsplit(dirini,dirst,namest,extst);
 dirini:=upstring(dirst);
 numeini:=dirini+'MHV.INI';
 if (length(dirini)>=3)and(dirini[length(dirini)]='\') then
 dirini[0]:=chr(ord(dirini[0])-1);
 incarcini;
 setspeed(speedn,speedna,speedc,speedca);
 dp:=20;
 filemode:=0;
 sortare:=0;
 repnokey;
 mv:=3;
 oldexit:=exitproc;
 exitproc:=@myexit;
 initb;
 createvirtual(0);
 deletevirtual;
 a:=ptr(sega000,0);
 ta:=ptr(segb000,$8000);
 afis:=true;
 if paramstr(1)='usor' then afis:=false;
 schimbmf(1);
 if nom then halt;
 nom:=false;
 inittext80x25;
 clipire(false);
 cursor(false);
 epoz:=1;
 dpoz:=0;
 getdir(0,curentdrivedir);
 curentvdir:=curentdrivedir;
 setcharcolor(14);
 setbaccolor(1);
 setchar(#0);
 bara80x25(tb,1,1,80,25);
 scandir;
 desenezpanou;
 repeat
  elimintasta;
  citesctasta;
  if (tasta.citita)and(tasta.zero)and(tasta.cod=tsus) then
  begin
   elimintasta;
   miscsus;
  end;
  if (tasta.citita)and(tasta.zero)and(tasta.cod=tjos) then
  begin
   elimintasta;
   miscjos;
  end;
  if (tasta.citita)and(tasta.zero)and
  ((tasta.cod=tstanga)or(tasta.cod=tpgup)) then
  begin
   elimintasta;
   miscpgup;
  end;
  if (tasta.citita)and(tasta.zero)and
  ((tasta.cod=tdreapta)or(tasta.cod=tpgdn)) then
  begin
   elimintasta;
   miscpgdn;
  end;
  if (tasta.citita)and(tasta.zero)and(tasta.cod=thome) then
  begin
   elimintasta;
   mischome;
  end;
  if (tasta.citita)and(tasta.zero)and(tasta.cod=tend) then
  begin
   elimintasta;
   miscend;
  end;
  if (tasta.citita)and(not tasta.zero)and(tasta.cod=tbsles) then
  begin
   elimintasta;
   chdir('\');
   scandir;
   epoz:=1;
   dpoz:=0;
  end;
  if (tasta.citita)and(not tasta.zero)and(tasta.cod=tbkspace) then
  begin
   elimintasta;
   getdir(0,curentdir);
   fsplit(curentdir,dirst,namest,extst);
   if extst<>'' then curentdir:=namest+'.'+extst else curentdir:=namest;
   curentdir:=upstring(curentdir);
   if curentdir<>'' then
   begin
    chdir('..');
    scandir;
    epoz:=0;
    dpoz:=0;
    repeat
     miscjos;
     if panou[epoz+dpoz].ext='' then dirst:=panou[epoz+dpoz].nume else
     dirst:=panou[epoz+dpoz].nume+'.'+panou[epoz+dpoz].ext;
    until (dirst=curentdir)or(epoz+dpoz>=nre);
    if epoz+dpoz>=nre then
    if dirst<>curentdir then
    begin
     dpoz:=0;
     epoz:=1;
    end;
   end;
  end;
  if (tasta.citita)and(not tasta.zero)and(tasta.cod=tenter) then
  if nre>0 then
  begin
   elimintasta;
   pozdir:=false;
   if (panou[epoz+dpoz].attr and directory)<>0 then
   begin
    pozdir:=true;
    getdir(0,curentdir);
    fsplit(curentdir,dirst,namest,extst);
    if extst<>'' then curentdir:=namest+'.'+extst else curentdir:=namest;
    curentdir:=upstring(curentdir);
    curentdir:=upstring(fullstring(namest,extst));
    if panou[epoz+dpoz].ext='' then chdir(panou[epoz+dpoz].nume) else
    chdir(panou[epoz+dpoz].nume+'.'+panou[epoz+dpoz].ext);
    scandir;
    epoz:=1;
    dpoz:=0;
    if pozdir then
    begin
     dpoz:=0;
     epoz:=0;
     repeat
      miscjos;
      dirst:=upstring(fullstring(panou[epoz+dpoz].nume,panou[epoz+dpoz].ext));
     until (dirst=curentdir)or(epoz+dpoz>=nre);
     if epoz+dpoz>=nre then
     if dirst<>curentdir then
     begin
      dpoz:=0;
      epoz:=1;
     end;
    end;
   end else
   if (panou[epoz+dpoz].attr and directory)=0 then
   begin
    tc^:=tb^;
    arataimagine(epoz+dpoz);
    if virtualmem then deletevirtual;
    inittext80x25;
    cursor(false);
    clipire(false);
    tb^:=tc^;
    if writeprotect and virtualmem then
    begin
     setcharcolor(9);
     setbaccolor(1);
     setchar(#0);
     ferg80x25(tb,7,10,74,12,'??Eroare la vizualizarea imaginii??');
     writestring80x25(tb,1,11,'Discul este protejat la scriere!',false,false,true);
     ta^:=tb^;
     elimintasta;
     repeat
      citesctasta;
     until tasta.citita;
     elimintasta;
     tb^:=tc^;
    end;
    if nom then
    begin
     setcharcolor(9);
     setbaccolor(1);
     setchar(#0);
     ferg80x25(tb,7,10,74,12,'??Eroare la vizualizarea imaginii??');
     if virtualmem then
     writestring80x25(tb,1,11,'Nu e destula spatiu pe disc!',false,false,true) else
     writestring80x25(tb,1,11,'Nu e destula memorie!',false,false,true);
     ta^:=tb^;
     elimintasta;
     repeat
      citesctasta;
     until tasta.citita;
     elimintasta;
     tb^:=tc^;
    end;
    if (panou[epoz+dpoz].format=fnecunoscut)and
    ((panou[epoz+dpoz].attr and directory)=0) then
    begin
     setcharcolor(9);
     setbaccolor(1);
     setchar(#0);
     ferg80x25(tb,7,10,74,12,'??Eroare la vizualizarea imaginii??');
     writestring80x25(tb,1,11,'Nu e un format cunoscut!',false,false,true);
     ta^:=tb^;
     elimintasta;
     repeat
      citesctasta;
     until tasta.citita;
     elimintasta;
     tb^:=tc^;
    end;
    nom:=false;
   end;
  end;
  if (tasta.citita)and(not tasta.zero)and
  ((tasta.cod=ord('d'))or(tasta.cod=ord('D'))) then
  begin
   elimintasta;
   selectaredrive;
  end;
  if (tasta.citita)and(tasta.zero)and(tasta.cod=tf1) then
  begin
   elimintasta;
   ajutor;
  end;
  if (tasta.citita)and(not tasta.zero)and
  ((tasta.cod=ord('i'))or(tasta.cod=ord('I'))) then
  if nre>0 then
  if (panou[epoz+dpoz].attr and directory)=0 then
  begin
   elimintasta;
   aratainformatii(epoz+dpoz);
  end;
  if (tasta.citita)and(not tasta.zero)and
  ((tasta.cod=ord('o'))or(tasta.cod=ord('O'))) then
  begin
   elimintasta;
   dutenoptiuni;
  end;
  if (tasta.citita)and(not tasta.zero)and
  ((tasta.cod=ord('s'))or(tasta.cod=ord('S'))) then
  begin
   elimintasta;
   scaneztot;
  end;
  if (tasta.citita)and(tasta.zero)and(tasta.cod=tdel) then
  begin
   elimintasta;
   if (panou[epoz+dpoz].attr and directory)=0 then
   stergfis else
   begin
   end;
  end;
  if (tasta.citita)and(tasta.zero)and(tasta.cod=tf2) then
  begin
   elimintasta;
   if (panou[epoz+dpoz].attr and directory)=0 then
   renumfis else
   begin
   end;
  end;
  if (tasta.citita)and(not tasta.zero)and
  ((tasta.cod=ord('e'))or(tasta.cod=ord('E'))) then
  begin
   elimintasta;
   elimintot;
  end;
  if (tasta.citita)and(not tasta.zero)and
  ((tasta.cod=ord('r'))or(tasta.cod=ord('R'))) then
  begin
   elimintasta;
   scandir;
  end;
  if (tasta.citita)and(tasta.zero)and(tasta.cod=tf10) then
  begin
   elimintasta;
   iesire:=true;
  end;
  desenezpanou;
  ta^:=tb^;
  nom:=false;
 until iesire;
 repnokey;
 iesim(a,b,c,dirini);
end.