{$A+,B-,D+,E+,F+,G+,I-,L+,N-,O+,P+,Q+,R+,S+,T-,V+,X+,Y+}
unit mhvunit;
interface
uses dos,mhmatem,mhimg,mhstring,textgraf,mhgraf,mhpal,tpkey;
const fnecunoscut=0;
      fmvb=1;
      fmhv=2;
      fmhb=3;
      fmhp=4;
      fmcp=5;
      fmcb=6;
      fcel=7;
      fpcx=8;
      fbmp=9;
      fico=10;
      ftga=11;
      ttab: byte=9;
      tins: byte=82;
      tesc: byte=27;
      tenter: byte=13;
      tdel=83;
      tf1: byte=59;
      tf2: byte=60;
      tf10: byte=68;
      tsus: byte=72;
      tjos: byte=80;
      tpgup: byte=73;
      tpgdn: byte=81;
      tstanga: byte=75;
      tdreapta: byte=77;
      thome: byte=71;
      tend: byte=79;
      tbsles: byte=92;
      tbkspace: byte=8;
      tctrla: byte=1;
      tctrln: byte=14;
const copyright: string[80]='MhViewer v1.0 2000 - Copyright (c) MSoft - Mihai Marica';
      speeds: array[0..3] of array[0..4] of string[30]=
              (('10 linii','40 linii','70 linii','100 linii','200 linii'),
               ('1 linie','3 linii','5 linii','10 linii','20 linii'),
               ('1000 pixeli','3000 pixeli','6000 pixeli','12000 pixeli',
               '24000 pixeli'),
               ('10 pixeli','50 pixeli','100 pixeli','500 pixeli','1000 pixeli'));
      speedv: array[0..3] of array[0..4] of word=((10,40,70,100,200),
                                                  (1,3,5,10,20),
                                                  (1000,3000,6000,12000,24000),
                                                  (10,50,100,500,100));
      mvx: word=320;
      mvy: word=160;
      maxfiles=1000;
      zin=4;
      maxsc=25;
type zidenastere=record
                  zi,luna: byte;
                  an: word;
                  nume: string[80];
                 end;
     finfo=record
            nume: string[8];
            ext: string[3];
            compresie,marime: longint;
            invers,scan,interlace,paleta,compresat: boolean;
            attr,sx,sy,bpp: word;
            format: byte;
           end;
     mbuf=array[1..64000] of byte;
const zile: array[1..zin] of zidenastere=((zi:11;luna:10;an:1982;
                                          nume:'Mihai Marica- directorul MSoft'),
                                          (zi:25;luna:1;an:1986;
                                          nume:'Valentin Marica, fratele lui Mihai'+
                                          ' (directorul MSoft)'),
                                          (zi:25;luna:8;an:1955;
                                          nume:'Nicolae Marica, tatal lui Mihai'+
                                          ' (directorul MSoft)'),
                                          (zi:8;luna:2;an:1955;
                                          nume:'Rodica Marica, mama lui Mihai'+
                                          ' (directorul MSoft)'));
var panou: array[1..maxfiles] of finfo;
    a,b,c,d: ^ecran;
    ta,tb,tc: ^ecran80x25;
    oldexit: pointer;
    minibuf: ^mbuf;
    pal: mvpal;
    mbt,mbimg: membuf256;
    vcol,searchmem,spatecol,scriscol: byte;
    speed: array[1..4] of byte;
    zi,luna,an,zis: word;
    pozf,mrx,mry,timp1,timp2,timp3,timp4,zvar,hvar,mvar,svar: longint;
    vvpt,vpt,speedn,speedna,speedc,speedca: byte;
    loop,aux,format,bt,sortare,miscate,b1,b2,b3: byte;
    spn,spna,spc,spca: word;
    btotal,bcitit: longint;
    nrimg,nrs,nrf,nrd,nre,ppan: integer;
    numef,virtualn,numeini,dirini,curentvdir,sttemp,curentdrivedir: string;
    fulls,fullscreen,salvez,tomany,formatgasit,iesire,anuleaza,afis,dir2p,speciala,apasata: boolean;
    terminat,writeprotect,virtualmem,iesima,scanez,elimin,sunet: boolean;
    invers,nascut,pozdir,nom,compresat,paleta,interlace,vsel,preamare: boolean;
    drive: array[1..26] of boolean;
    epoz,dpoz,pozv,pcopy,up,ud,dp: integer;
    vvx,vvy,vmx,vmy,vsx,vsy,lx1,lx2,ly1,ly2,vlx1,vly1,vlx2,vly2: longint;
    rep: integer;
    bpp,wd,w,sx,sy,px,py: word;
    count,contor,cv,compresie,pozbuf,size,x,y: longint;
    antet: array[1..4] of char;
    curentdir,st,cdir,strtemp: string;
    dirst: dirstr;
    namest: namestr;
    extst: extstr;
    f,f1: file;
    buf: array[1..maxr256] of char;
    contorsc: longint;
var tasta: record
            citita,zero: boolean;
            cod: byte;
           end;
    rezultat: longint;
    s,s1,s2,s3: string;


procedure norm2rec(x: integer);
procedure rec2norm(x: integer);
procedure gasescformat;
procedure sunetgata;
procedure sunetstop;
procedure repkey;
procedure repnokey;
procedure citesctasta;
procedure elimintasta;
procedure afisezceas(p: pointer);
procedure eliminintrare(poz: longint);
procedure desenezpanou;
procedure iesim(p1,p2,p3: pointer;dirini: string);
procedure afisezinfo;
procedure scaneztot;
procedure elimintot;
procedure quicksortnume(l,r: integer);
procedure scandir;
procedure setspeed(sp1,sp2,sp3,sp4: word);
procedure citesctimp(var timp: longint);
procedure calculeztimp(timp1,timp2: longint;var timp3: longint);
procedure calculezestimat(var timp: longint);
procedure transformtimp(timp: longint;var h,m,s,ss: word);

implementation

procedure norm2rec(x: integer);
begin
 panou[x].invers:=invers;
 panou[x].paleta:=paleta;
 panou[x].interlace:=interlace;
 panou[x].compresat:=compresat;
 panou[x].compresie:=compresie;
 panou[x].sx:=sx;
 panou[x].sy:=sy;
 panou[x].bpp:=bpp;
 panou[x].format:=format;
end;

procedure rec2norm(x: integer);
begin
 invers:=panou[x].invers;
 paleta:=panou[x].paleta;
 interlace:=panou[x].interlace;
 compresat:=panou[x].compresat;
 compresie:=panou[x].compresie;
 sx:=panou[x].sx;
 sy:=panou[x].sy;
 bpp:=panou[x].bpp;
 format:=panou[x].format;
end;

procedure gasescformat;
begin
 fillchar(buf,sizeof(buf),0);
 fillchar(antet,sizeof(antet),0);
 formatgasit:=false;
 format:=fnecunoscut;
 compresat:=false;
 paleta:=false;
 interlace:=false;
 invers:=false;

 {MVB}
 if not formatgasit then
 begin
  seek(f,0);
  blockread(f,antet,4,w);
  if antet='MVB6' then
  begin
   format:=fmvb;
   formatgasit:=true;
   seek(f,4);
   blockread(f,buf,1,w);
   if ord(buf[1])<255 then
   begin
    sx:=ord(buf[1]);
    blockread(f,buf,1,w);
    sy:=ord(buf[1]);
   end else
   begin
    blockread(f,buf,1,w);
    sx:=ord(buf[1])+255;
    blockread(f,buf,1,w);
    sy:=ord(buf[1]);
   end;
   bpp:=8;
  end;
 end;

 {MHV}
 if not formatgasit then
 begin
  seek(f,0);
  blockread(f,antet,4,w);
  if antet='MHV6' then
  begin
   format:=fmhv;
   formatgasit:=true;
   blockread(f,buf,4,w);
   move(buf[1],sx,2);
   move(buf[3],sy,2);
   bpp:=8;
  end;
 end;

 {MHB}
 if not formatgasit then
 begin
  seek(f,0);
  blockread(f,antet,4,w);
  if antet='MHB6' then
  begin
   format:=fmhb;
   formatgasit:=true;
   seek(f,4);
   blockread(f,buf,4,w);
   move(buf[1],sx,2);
   move(buf[3],sy,2);
   bpp:=8;
  end;
 end;

 {MHP}
 if not formatgasit then
 begin
  seek(f,0);
  blockread(f,antet,4,w);
  if antet='MHP6' then
  begin
   format:=fmhp;
   formatgasit:=true;
   seek(f,4);
   blockread(f,buf,4,w);
   move(buf[1],sx,2);
   move(buf[3],sy,2);
   paleta:=true;
   bpp:=8;
  end;
 end;

 {MCB}
 if not formatgasit then
 begin
  seek(f,0);
  blockread(f,antet,4,w);
  if antet='MCB6' then
  begin
   format:=fmcb;
   formatgasit:=true;
   seek(f,4);
   blockread(f,buf,4,w);
   move(buf[1],sx,2);
   move(buf[3],sy,2);
   bpp:=8;
   compresie:=0;
   compresat:=true;
  end;
 end;

 {MCP}
 if not formatgasit then
 begin
  seek(f,0);
  blockread(f,antet,4,w);
  if antet='MCP6' then
  begin
   format:=fmcp;
   formatgasit:=true;
   seek(f,4);
   blockread(f,buf,4,w);
   move(buf[1],sx,2);
   move(buf[3],sy,2);
   paleta:=true;
   bpp:=8;
   compresie:=0;
   compresat:=true;
  end;
 end;

 {CEL}
 if not formatgasit then
 begin
  seek(f,0);
  blockread(f,buf,32,w);
  if(buf[1]=#25)and(buf[2]=#145)and(buf[11]=#8)and(buf[12]=#0) then
  begin
   format:=fcel;
   formatgasit:=true;
   seek(f,2);
   blockread(f,buf,4,w);
   move(buf[1],sx,2);
   move(buf[3],sy,2);
   paleta:=true;
   bpp:=8;
  end;
 end;

 {PCX}
 if not formatgasit then
 begin
  seek(f,0);
  blockread(f,buf,2,w);
  if(buf[1]=#10)and(buf[2]in[#0,#2,#3,#4,#5]) then
  begin
   format:=fpcx;
   formatgasit:=true;
   seek(f,2);
   blockread(f,buf,1,w);
   compresie:=byte(buf[1]);
   seek(f,3);
   blockread(f,buf,1,w);
   bpp:=byte(buf[1]);
   seek(f,65);
   blockread(f,buf,1,w);
   bpp:=bpp*byte(buf[1]);
   seek(f,4);
   blockread(f,px,2,w);
   blockread(f,py,2,w);
   blockread(f,sx,2,w);
   blockread(f,sy,2,w);
   if (px>sx)or(py>sy) then
   begin
    formatgasit:=false;
    format:=fnecunoscut;
   end else
   begin
    sx:=sx-px+1;
    sy:=sy-py+1;
   end;
   seek(f,1);
   blockread(f,bt,1,w);
   if (bt>=3)and(bpp<=8) then paleta:=true;
   if compresie<>0 then compresat:=true;
   if bpp=8 then
   if sx mod 2<>0 then sx:=sx+2-(sx mod 2);
  end;
 end;

 {BMP}
 if not formatgasit then
 begin
  seek(f,0);
  blockread(f,antet,2,w);
  move(antet,wd,2);
  if (wd=19778{'BM'}) then
  begin
   invers:=true;
   format:=fbmp;
   formatgasit:=true;
   seek(f,18);
   blockread(f,sx,2,w);
   seek(f,22);
   blockread(f,sy,2,w);
   seek(f,28);
   blockread(f,buf,2,w);
   move(buf,bpp,2);
   blockread(f,buf,4,w);
   move(buf[1],compresie,4);
   if compresie<>0 then compresat:=true;
   if bpp<=8 then paleta:=true;
   if sx mod 2<>0 then sx:=sx+2-(sx mod 2);
  end;
 end;

 {ICO}
 if not formatgasit then
 begin
  seek(f,0);
  blockread(f,buf,4,w);
  move(buf,s[1],4);
  s[0]:=#4;
  if s=#0#0#1#0 then
  begin
   invers:=true;
   format:=fico;
   formatgasit:=true;
   seek(f,36);
   blockread(f,buf,1,w);
   bpp:=ord(buf[1]);
   if buf[1]=#0 then bpp:=4;
   seek(f,6);
   blockread(f,buf,2,w);
   sx:=byte(buf[1]);
   sy:=byte(buf[2]);
   if bpp<=8 then paleta:=true;
   if sx mod 2<>0 then sx:=sx+2-(sx mod 2);
  end;
 end;

 {TGA}
 if not formatgasit then
 begin
  seek(f,0);
  blockread(f,antet,2,w);
  seek(f,3);
  blockread(f,antet[3],1,w);
  if (antet[1]=#0)and(antet[2]=#1)and(antet[3]=#0) then
  begin
   format:=ftga;
   formatgasit:=true;
   seek(f,2);
   blockread(f,antet,1,w);
   compresie:=byte(antet[1]);
   if compresie<>1 then compresat:=true;
   seek(f,12);
   blockread(f,buf,4,w);
   move(buf[1],sx,2);
   move(buf[3],sy,2);
   seek(f,16);
   blockread(f,antet,1,w);
   bpp:=byte(antet[1]);
   if bpp<=8 then paleta:=true;
   seek(f,17);
   blockread(f,buf,1,w);
   if buf[1]=#0 then invers:=true;
  end;
 end;
 if (sx<1)or(sy<1)or(sx>maxr256)or(sy>maxr256)or(bpp<1) then
 begin
  formatgasit:=false;
  format:=fnecunoscut;
 end;
end;

procedure sunetgata;
var x: byte;
begin
 for x:=10 to 100 do
 begin
  sound(x*10);
  delay(3);
 end;
 nosound;
end;

procedure sunetstop;
var x: byte;
begin
 for x:=100 downto 10 do
 begin
  sound(x*10);
  delay(3);
 end;
 nosound;
end;

procedure repkey;
begin
 while not keypressed do;
end;

procedure repnokey;
begin
 while keypressed do readkey;
end;

procedure citesctasta;
begin
 if tasta.citita then exit;
 tasta.zero:=false;
 if keypressed then
 begin
  tasta.cod:=ord(readkey);
  if tasta.cod=0 then
  begin
   tasta.cod:=ord(readkey);
   tasta.zero:=true;
  end;
  tasta.citita:=true;
 end;
end;

procedure elimintasta;
begin
 tasta.citita:=false;
end;

procedure afisezceas(p: pointer);
var x,m,h,s,ss: word;
    tb: ^ecran80x25;
begin
 tb:=p;
 gettime(h,m,s,ss);
 s2:='';
 s1:=nrtost0(h,2);
 s2:=s2+s1+':';
 s1:=nrtost0(m,2);
 s2:=s2+s1;
 if odd(s) then s2:=s2+':' else s2:=s2+' ';
 s1:=nrtost0(s,2);
 s2:=s2+s1+'.';
 s1:=nrtost0(ss,2);
 s2:=s2+s1;
 setbaccolor(1);
 setcharcolor(14);
 writestring80x25(tb,70,1,s2,false,false,false);
end;

procedure eliminintrare(poz: longint);
var x,y: longint;
begin
 if (nre<1)or(nre<poz)or(poz<1) then exit;
 if(panou[poz].attr and directory)<>0 then nrd:=nrd-1 else
 begin
  if panou[poz].scan then
  begin
   nrs:=nrs-1;
   if panou[poz].format<>fnecunoscut then nrimg:=nrimg-1;
  end;
  nrf:=nrf-1;
 end;
 for x:=poz to nre do
 if x<nre then panou[x]:=panou[x+1];
 nre:=nre-1;
end;

procedure desenezpanou;
begin
 setcharcolor(4);
 setbaccolor(14);
 setchar(#0);
 bara80x25(tb,1,1,80,25);
 setcharcolor(14);
 setbaccolor(4);
 bara80x25(tb,1,1,80,1);
 bara80x25(tb,1,25,80,25);
 writestring80x25(tb,1,1,copyright,false,false,true);
 setcharcolor(4);
 setbaccolor(14);
 if (length(curentdrivedir)>3)and(curentdrivedir[length(curentdrivedir)]='\')
 then curentdrivedir[0]:=chr(ord(curentdrivedir[0])-1);
 ferg80x25(tb,1,3,80,24,upstring(curentdrivedir));
 if nre>0 then
 begin
  for x:=1 to dp do
  if dpoz+x<=nre then
  begin
   setcharcolor(4);
   setbaccolor(14);
   if x=epoz then
   begin
    setcharcolor(14);
    setbaccolor(1);
   end;
   strtemp:=panou[dpoz+x].nume;
   for y:=length(strtemp)+1 to 9 do
   strtemp:=strtemp+' ';
   strtemp:=strtemp+panou[dpoz+x].ext;
   for y:=length(panou[dpoz+x].ext)+1 to 4 do
   strtemp:=strtemp+' ';
   if (panou[dpoz+x].attr and directory)<>0 then
   strtemp:=strtemp+'    DIR     ' else
   begin
    str(panou[dpoz+x].marime:10,s1);
    if panou[dpoz+x].marime=0 then s1:='         0';
    strtemp:=strtemp+s1+'  ';
   end;
   if panou[dpoz+x].nume<>'..' then
   begin
    if (panou[dpoz+x].attr and archive)<>0 then strtemp:=strtemp+'A ' else
    strtemp:=strtemp+'- ';
    if (panou[dpoz+x].attr and readonly)<>0 then strtemp:=strtemp+'R ' else
    strtemp:=strtemp+'- ';
    if (panou[dpoz+x].attr and sysfile)<>0 then strtemp:=strtemp+'S ' else
    strtemp:=strtemp+'- ';
    if (panou[dpoz+x].attr and hidden)<>0 then strtemp:=strtemp+'H ' else
    strtemp:=strtemp+'- ';
    strtemp:=strtemp+' ';
   end else strtemp:=strtemp+'         ';
   if panou[dpoz+x].scan then
   begin
    if panou[dpoz+x].format=fmvb then strtemp:=strtemp+'MVB ' else
    if panou[dpoz+x].format=fmhv then strtemp:=strtemp+'MHV ' else
    if panou[dpoz+x].format=fmhb then strtemp:=strtemp+'MHB ' else
    if panou[dpoz+x].format=fmhp then strtemp:=strtemp+'MHP ' else
    if panou[dpoz+x].format=fmcb then strtemp:=strtemp+'MCB ' else
    if panou[dpoz+x].format=fmcp then strtemp:=strtemp+'MCP ' else
    if panou[dpoz+x].format=fcel then strtemp:=strtemp+'CEL ' else
    if panou[dpoz+x].format=fpcx then strtemp:=strtemp+'PCX ' else
    if panou[dpoz+x].format=fbmp then strtemp:=strtemp+'BMP ' else
    if panou[dpoz+x].format=fico then strtemp:=strtemp+'ICO ' else
    if panou[dpoz+x].format=ftga then strtemp:=strtemp+'TGA ' else
    strtemp:=strtemp+'??? ';
    if panou[dpoz+x].format<>fnecunoscut then
    begin
     str(panou[dpoz+x].sx,s1);
     str(panou[dpoz+x].sy,s2);
     s1:=s1+'x'+s2+'x';
     if panou[dpoz+x].bpp<=8 then
     begin
      str(1 shl panou[dpoz+x].bpp,s2);
      s2:=s2+ ' culori';
     end else
     begin
      str(panou[dpoz+x].bpp,s2);
      s2:=s2+ ' biti';
     end;
     s1:=s1+s2;
     for y:=length(s1)+1 to 25 do
     s1:=s1+' ';
     strtemp:=strtemp+s1;
    end;
   end;
   for y:=length(strtemp)+1 to 76 do
   strtemp:=strtemp+' ';
   writestring80x25(tb,3,3+x,strtemp,false,false,false);
  end;
 end else
 begin
  setcharcolor(4);
  setbaccolor(14);
  writestring80x25(tb,1,4,'Discul e gol!',false,false,true);
 end;
 setcharcolor(4);
 setbaccolor(14);
 if panou[1].nume='..' then str(nrd-1:4,s1) else
 str(nrd:4,s1);
 strtemp:='Directoare: '+s1;
 str(nrf:4,s1);
 strtemp:=strtemp+' Fisiere: '+s1;
 str(nrimg:4,s1);
 strtemp:=strtemp+' Imagini: '+s1;
 str(nrs:4,s1);
 strtemp:=strtemp+' Scanate '+s1;
 writestring80x25(tb,1,2,strtemp,false,false,false);
 afisezceas(tb);
end;

procedure iesim(p1,p2,p3: pointer;dirini: string);
var a,b,c: ^ecran;
begin
 a:=p1;b:=p2;c:=p3;
 if dirini[length(dirini)]='\' then
 assign(f,dirini+'MSOFT.MHP') else
 assign(f,dirini+'\MSOFT.MHP');
 reset(f,1);
 if rezultat<>0 then exit;
 seek(f,8);
 blockread(f,pal,768,w);
 seek(f,776);
 blockread(f,c^,64000,w);
 close(f);
 initgr;
 setpal(pal);
 bt:=palnearpalcolor(pal,63,0,0);
 scolor(bt);
 s1:='MSoft - Mihai Marica';
 s2:='Tel. 044/271667';
 up:=0;
 ud:=1;
 repeat
  b^:=c^;
  if ud=0 then up:=up-5 else up:=up+5;
  if up>179 then
  begin
   up:=179;
   ud:=0;
  end;
  if up<0 then
  begin
   up:=0;
   ud:=1;
  end;
  x:=round(159+30*cosv(up));
  y:=round(10+30*sinv(up));
  mvtextxy1(b,x-length(s1)*4,y,s1);
  x:=round(159+30*cosv(179-up));
  y:=round(130+30*sinv(179-up));
  mvtextxy1(b,x-length(s2)*4,y,s2);
  elimintasta;
  citesctasta;
  delay(50);
  a^:=b^;
 until(tasta.citita)and(not tasta.zero)and(tasta.cod=tesc);
end;

procedure afisezinfo;
begin
  contorsc:=0;
  tc^:=tb^;
  setcharcolor(14);
  setbaccolor(4);
  setchar(#0);
  ferg80x25(tb,3,11,78,13,'Informatii despre director');
  if panou[1].nume='..' then str(nrd-1:4,s1) else
  str(nrd:4,s1);
  strtemp:='Directoare: '+s1;
  str(nrf:4,s1);
  strtemp:=strtemp+' Fisiere: '+s1;
  str(nrimg:4,s1);
  strtemp:=strtemp+' Imagini: '+s1;
  str(nrs:4,s1);
  strtemp:=strtemp+' Scanate '+s1;
  writestring80x25(tb,1,12,strtemp,false,false,true);
  ta^:=tb^;
  elimintasta;
  citesctasta;
  tb^:=tc^;
end;

procedure scaneztot;
begin
 elimintasta;
 for x:=nrd+1 to nrd+nrf do
 if not panou[x].scan then
 begin
  contorsc:=contorsc+1;
  if (contorsc mod maxsc=0)and(maxsc<>0) then afisezinfo;
  assign(f,upstring(fullstring(panou[x].nume,panou[x].ext)));
  reset(f,1);
  if rezultat=0 then
  begin
   gasescformat;
   close(f);
   panou[x].scan:=true;
   norm2rec(x);
   if format<>fnecunoscut then nrimg:=nrimg+1;
   nrs:=nrs+1;
  end;
  citesctasta;
  if tasta.citita and(not tasta.zero)and(tasta.cod=tesc) then
  begin
   exit;
  end;
  elimintasta;
 end;
end;

procedure elimintot;
var x,y: longint;
begin
 x:=1;
 if nrf>0 then
 if nrs>0 then
 begin
  while x<=nrf do
  begin
   contorsc:=contorsc+1;
   if (contorsc mod maxsc=0)and(maxsc<>0) then afisezinfo;
   if panou[x+nrd].scan then
   begin
    if panou[x+nrd].format=fnecunoscut then
    begin
     eliminintrare(nrd+x);
     x:=x-1;
    end;
    citesctasta;
    if tasta.citita and(not tasta.zero)and(tasta.cod=tesc) then
    begin
     elimintasta;
     exit;
    end;
    elimintasta;
   end;
   x:=x+1;
  end;
  dpoz:=0;
  epoz:=1;
 end;
end;

procedure quicksortnume(l,r: integer);
procedure sort(l,r: integer);
var i,j: integer;
    x,y: finfo;
begin
 i:=l;j:=r;x:=panou[(l+r) div 2];
 repeat
  while panou[i].nume<x.nume do i:=i+1;
  while x.nume<panou[j].nume do j:=j-1;
  if i<=j then
  begin
   y:=panou[i];panou[i]:=panou[j];panou[j]:=y;
   i:=i+1;j:=j-1;
  end;
 until i>j;
 if l<j then sort(l,j);
 if i<r then sort(i,r);
end;
begin
 sort(l,r);
end;

procedure scandir;
var sr: searchrec;
    dirn: dirstr;
    namen: namestr;
    extn: extstr;
    incep,numar,x,y,z,t: integer;
    numev: string;
    bp1,bp2: ^byte;
begin
 contorsc:=0;
 tomany:=false;
 nrimg:=0;
 nrs:=0;
 filemode:=0;
 getdir(0,curentdrivedir);
 fillchar(panou,sizeof(panou),0);
 nrf:=0;nrd:=0;nre:=0;dir2p:=false;ppan:=0;
 findfirst('*.*',$3F-volumeid,sr);
 while (doserror=0) do
 begin
  contorsc:=contorsc+1;
  if (contorsc mod maxsc=0)and(maxsc<>0) then afisezinfo;
  if (sr.name<>'.')and((sr.attr and directory)<>0) then
  begin
   ppan:=ppan+1;
   if ppan>maxfiles then
   begin
    tomany:=true;
    break;
   end;
   nrd:=nrd+1;
   extn:='';
   if sr.name='..' then
   begin
    panou[ppan].nume:='..';
    panou[ppan].attr:=sr.attr;
    dir2p:=true;
   end else
   begin
    fsplit(sr.name,dirn,namen,extn);
    panou[ppan].nume:=upstring(namen);
    if extn[1]='.' then
    begin
     for x:=1 to 3 do
     extn[x]:=extn[x+1];
     extn[0]:=chr(ord(extn[0])-1);
    end;
    panou[ppan].ext:=upstring(extn);
    panou[ppan].attr:=sr.attr;
   end;
  end;
  findnext(sr);
 end;
 findfirst('*.*',$3F-volumeid,sr);
 while (doserror=0) do
 begin
  contorsc:=contorsc+1;
  if (contorsc mod maxsc=0)and(maxsc<>0) then afisezinfo;
  if (sr.attr and directory)=0 then
  begin
   ppan:=ppan+1;
   if ppan>maxfiles then
   begin
    tomany:=true;
    break;
   end;
   nrf:=nrf+1;
   panou[ppan].marime:=sr.size;
   extn:='';
   fsplit(sr.name,dirn,namen,extn);
   panou[ppan].nume:=downstring(namen);
   if extn[1]='.' then
   begin
    for x:=1 to 3 do
    extn[x]:=extn[x+1];
    extn[0]:=chr(ord(extn[0])-1);
   end;
   panou[ppan].ext:=downstring(extn);
   panou[ppan].attr:=sr.attr;
  end;
  findnext(sr);
 end;
 nre:=nrd+nrf;
 {Sortare 0=nume, 1=extensie, 2=marime, 3=nesortate}
 if sortare=0 then {sortare dupa nume si extensie}
 if nre>0 then
 begin
  if nrd>0 then
  begin
   if (panou[1].nume='..') then
   begin
    if nrd>1 then
    quicksortnume(2,nrd);
   end else
   quicksortnume(1,nrd);
  end;
  if nrf>0 then
  begin
   quicksortnume(nrd+1,nre);
  end;
 end;
 if tomany then
 begin
  x:=epoz;
  y:=dpoz;
  epoz:=1;
  dpoz:=0;
  desenezpanou;
  epoz:=x;
  dpoz:=y;
  tc^:=tb^;
  setcharcolor(14);
  setbaccolor(4);
  setchar(#0);
  ferg80x25(tb,3,11,78,13,'E prea mult! Nu mai rezist!');
  str(maxfiles,s);
  writestring80x25(tb,1,12,'Sunt mai mult de '+s+' de intrari in director!',false,false,true);
  repeat
   elimintasta;
   citesctasta;
  until(not tasta.citita);
  repeat
   ta^:=tb^;
   elimintasta;
   citesctasta;
  until(tasta.citita);
  repeat
   elimintasta;
   citesctasta;
  until(not tasta.citita);
  tb^:=tc^;
  ta^:=tb^;
 end;
 if scanez then scaneztot;
 if elimin then elimintot;
end;

procedure setspeed(sp1,sp2,sp3,sp4: word);
begin
 spn:=sp1;
 spna:=sp2;
 spc:=sp3;
 spca:=sp4;
end;

procedure citesctimp(var timp: longint);
var h,m,s,ss: word;
    hl,ml,sl,ssl: longint;
begin
 gettime(h,m,s,ss);
 timp:=h*hvar+m*mvar+s*svar+ss;
end;

procedure calculeztimp(timp1,timp2: longint;var timp3: longint);
begin
 if timp1>timp2 then timp3:=timp2+(zvar-timp1) else
 timp3:=timp2-timp1;
end;

procedure calculezestimat(var timp: longint);
begin
 if bcitit<1 then
 begin
  timp:=0;
  exit;
 end;
 timp:=trunc((btotal/bcitit)*timp3);
end;

procedure transformtimp(timp: longint;var h,m,s,ss: word);
begin
 if timp>zvar then timp:=zvar;
 h:=trunc(timp/hvar);
 timp:=timp-h*hvar;
 m:=trunc(timp/mvar);
 timp:=timp-m*mvar;
 s:=trunc(timp/svar);
 timp:=timp-s*svar;
 ss:=timp;
end;

begin
end.