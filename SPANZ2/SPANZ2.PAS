{$A+,B-,D+,E+,F+,G+,I-,L-,N-,O+,P+,Q+,R+,S+,T-,V+,X+,Y+}
{$M 16384,0,0}
program spanzuratoarea;
uses mhstring,mouse,dos,mhpal,mhmem,mhimg,tpkey;
const fisiere: array[1..4] of string=('orase.mvo','judete.mvo','ape.mvo','munti.mvo');
var reg,msx,msy,rez,x,y,z,t: integer;
    pal: array[1..25] of mvpal;
    pal0: mvpal;
    cuvant: string[20];
    a,b,c: ^ecran;
    f: file;
    oldexit: pointer;
    nom,nomouse: boolean;
    p1c: procedure;
    long,trebuie: longint;
    s,s1,s2,s3,dirini: string;
    ctm,ct1,greseli: integer;
    ghicit,fnegasit,gata: boolean;
    cv: array[1..20] of boolean;
    fape,forase,fmunti,fjudete,numefis,fismenu,fisjoc: string;
    w: word;
    fsize,nrcuv,rand: longint;
    tasta: record
            citita,zero: boolean;
            cod: byte;
           end;
    litere: array[1..26] of record
                             c: char;
                             pozx: integer;
                             aleasa: boolean;
                            end;

procedure spanzexit;
begin
 exitproc:=oldexit;
 closegr;
 setintvec($1c,@p1c);
 writeln('Spanzuratoarea - noua versiune - o noua productie MSoft+VSoft - 2000.');
 if nom then
 begin
  writeln('Nu e destula memorie!');
  writeln('Mai trebuie ',trebuie,' octeti de memorie!');
 end;
 if nomouse then writeln('Nu am detectat un mouse instalat!');
 if fnegasit then writeln('Nu pot gasi fisierul: ',numefis,'!');
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

procedure fadein(p: pointer);
var buf: ^ecran;
    x: integer;
begin
 buf:=p;
 setpal(pal0);
 a^:=buf^;
 for x:=1 to 25 do
 begin
  setpal(pal[x]);
  repeat
  until gata;
  gata:=false;
 end;
 setpal(normpal1);
end;

procedure fadeout;
var x: integer;
begin
 setpal(normpal1);
 for x:=25 downto 1 do
 begin
  setpal(pal[x]);
  repeat
  until gata;
  gata:=false;
 end;
 setpal(pal0);
end;

procedure citescmouse;
begin
 readmouse;
 msx:=mousex div 2;
 msy:=mousey;
end;

procedure textscris(persoana: byte;textul: string);
begin
 if persoana=1 then textul:='Peggy: '+textul;
 if persoana=2 then textul:='Bud: '+textul;
 if persoana=3 then textul:='Al: '+textul;
 if persoana=4 then textul:='Kelly: '+textul;
 t:=80*persoana-length(textul)*8;
 if t<3 then t:=3;
 scolor(0);
 fcolor(32*0+31);
 baram(b,t-3,2,t+8*length(textul)+3,25);
 mvtextxy1(b,t,5,textul);
end;

procedure initlitere;
begin
 for x:=1 to 26 do
 litere[x].aleasa:=false;
 for x:=1 to 20 do
 cv[x]:=false;
end;

procedure desenezmouse;
var fcolv,scolv: byte;
begin
 scolv:=getscolor;
 fcolv:=getfcolor;
 fcolor(32*0+31);
 scolor(0);
 drawpoly4(b,msx,msy,msx+10,msy+5,msx+5,msy+10,msx,msy,true,true);
 scolor(scolv);
 fcolor(fcolv);
end;

procedure optiuni;
begin
end;

procedure incarcjoc;
begin
 assign(f,dirini+fisjoc);
 rez:=ioresult;
 reset(f,1);
 rez:=ioresult;
 if rez<>0 then
 begin
  fnegasit:=true;
  numefis:=upstring(fisjoc);
  halt;
 end;
 seek(f,8);
 rez:=ioresult;
 blockread(f,c^[0,0],64000,w);
 rez:=ioresult;
 close(f);
 rez:=ioresult;
end;

procedure aratamasmecher;
begin
 b^:=c^;
 fadein(b);
 textscris(1,'Am reusit!');
 for x:=1 to 25 do
 begin
  a^:=b^;
  repeat
  until gata;
  gata:=false;
 end;
 b^:=c^;
 textscris(3,'Ba eu am reusit!');
 for x:=1 to 25 do
 begin
  a^:=b^;
  repeat
  until gata;
  gata:=false;
 end;
 b^:=c^;
 textscris(2,'Mama, da-mi niste bani.');
 for x:=1 to 25 do
 begin
  a^:=b^;
  repeat
  until gata;
  gata:=false;
 end;
 b^:=c^;
 textscris(1,'Va da Al bani.');
 for x:=1 to 25 do
 begin
  a^:=b^;
  repeat
  until gata;
  gata:=false;
 end;
 b^:=c^;
 textscris(2,'Da-ne tata!');
 textscris(4,'Da-ne tata!');
 for x:=1 to 36 do
 begin
  a^:=b^;
  repeat
  until gata;
  gata:=false;
 end;
 fadeout;
end;

procedure mamplictisit;
begin
 b^:=c^;
 fadein(b);
 textscris(1,'Eu m-am plictisit!');
 for x:=1 to 25 do
 begin
  a^:=b^;
  repeat
  until gata;
  gata:=false;
 end;
 b^:=c^;
 textscris(3,'Si eu!');
 for x:=1 to 25 do
 begin
  a^:=b^;
  repeat
  until gata;
  gata:=false;
 end;
 b^:=c^;
 textscris(1,'Eu ma uit la Oprah.');
 for x:=1 to 25 do
 begin
  a^:=b^;
  repeat
  until gata;
  gata:=false;
 end;
 b^:=c^;
 textscris(3,'Eu plec la Sexi-Club.');
 for x:=1 to 25 do
 begin
  a^:=b^;
  repeat
  until gata;
  gata:=false;
 end;
 b^:=c^;
 textscris(4,'Oare sunt acasa acum?');
 for x:=1 to 36 do
 begin
  a^:=b^;
  repeat
  until gata;
  gata:=false;
 end;
 b^:=c^;
 textscris(2,'Kelly avea dreptate.');
 for x:=1 to 36 do
 begin
  a^:=b^;
  repeat
  until gata;
  gata:=false;
 end;
 b^:=c^;
 textscris(2,'Chiar m-am murdarit pe barba!');
 for x:=1 to 36 do
 begin
  a^:=b^;
  repeat
  until gata;
  gata:=false;
 end;
 fadeout;
end;

procedure habarnam;
begin
 b^:=c^;
 fadein(b);
 textscris(3,'Peg, sunt cei de la Fisc!');
 for x:=1 to 25 do
 begin
  a^:=b^;
  repeat
  until gata;
  gata:=false;
 end;
 b^:=c^;
 textscris(1,'Si ce daca! Ma uit la Oprah.');
 for x:=1 to 25 do
 begin
  a^:=b^;
  repeat
  until gata;
  gata:=false;
 end;
 b^:=c^;
 textscris(3,'Peg, ghiceste cuvantul!');
 for x:=1 to 25 do
 begin
  a^:=b^;
  repeat
  until gata;
  gata:=false;
 end;
 b^:=c^;
 textscris(1,'??!!??!!??!!');
 for x:=1 to 25 do
 begin
  a^:=b^;
  repeat
  until gata;
  gata:=false;
 end;
 b^:=c^;
 textscris(3,'Ma spanzura astia!');
 for x:=1 to 36 do
 begin
  a^:=b^;
  repeat
  until gata;
  gata:=false;
 end;
 fadeout;
end;

procedure incarcaorase;
begin
 assign(f,dirini+forase);
 rez:=ioresult;
 reset(f,1);
 rez:=ioresult;
 if rez<>0 then
 begin
  fnegasit:=true;
  numefis:=upstring(fisjoc);
  halt;
 end;
 seek(f,8);
 rez:=ioresult;
 blockread(f,c^[0,0],64000,w);
 rez:=ioresult;
 close(f);
 rez:=ioresult;
end;

procedure incarcajudete;
begin
 assign(f,dirini+fjudete);
 rez:=ioresult;
 reset(f,1);
 rez:=ioresult;
 if rez<>0 then
 begin
  fnegasit:=true;
  numefis:=upstring(fisjoc);
  halt;
 end;
 seek(f,8);
 rez:=ioresult;
 blockread(f,c^[0,0],64000,w);
 rez:=ioresult;
 close(f);
 rez:=ioresult;
end;

procedure incarcamunti;
begin
 assign(f,dirini+fmunti);
 rez:=ioresult;
 reset(f,1);
 rez:=ioresult;
 if rez<>0 then
 begin
  fnegasit:=true;
  numefis:=upstring(fisjoc);
  halt;
 end;
 seek(f,8);
 rez:=ioresult;
 blockread(f,c^[0,0],64000,w);
 rez:=ioresult;
 close(f);
 rez:=ioresult;
end;

procedure incarcaape;
begin
 assign(f,dirini+fape);
 rez:=ioresult;
 reset(f,1);
 rez:=ioresult;
 if rez<>0 then
 begin
  fnegasit:=true;
  numefis:=upstring(fisjoc);
  halt;
 end;
 seek(f,8);
 rez:=ioresult;
 blockread(f,c^[0,0],64000,w);
 rez:=ioresult;
 close(f);
 rez:=ioresult;
end;

procedure incarcacuvant(fisier: integer);
begin
 if fisier=1 then incarcaorase;
 if fisier=2 then incarcajudete;
 if fisier=3 then incarcaape;
 if fisier=4 then incarcamunti;
 if (fisier<1)or(fisier>4) then
 begin
  cuvant:=upstring('nu gasesc fisierul');
  exit;
 end;
 assign(f,dirini+fisiere[fisier]);
 rez:=ioresult;
 reset(f,1);
 rez:=ioresult;
 if rez<>0 then
 begin
  cuvant:=upstring('nu gasesc fisierul');
  exit;
 end;
 fsize:=filesize(f);
 rez:=ioresult;
 nrcuv:=trunc(fsize/21);
 if nrcuv=0 then
 begin
  cuvant:=upstring('nu e nimic in fisier');
  close(f);
  rez:=ioresult;
  exit;
 end;
 randomize;
 rand:=random(nrcuv);
 seek(f,rand*21);
 rez:=ioresult;
 blockread(f,cuvant[0],21,w);
 rez:=ioresult;
 close(f);
 rez:=ioresult;
end;

procedure alegecuvant;
const maxmen=4;
      menustr: array[1..maxmen] of string[64]=('Orase','Judete','Ape','Munti');
var startx,starty: array[1..maxmen] of integer;
    iesire: boolean;
    x,y: integer;
begin
 b^:=c^;
 fadein(b);
 iesire:=false;
 for x:=1 to maxmen do
 begin
  startx[x]:=159-(length(menustr[x])+1)*5 div 2+3;
  starty[x]:=99-maxmen*20+x*20+10+2;
 end;
 repeat
  b^:=c^;
  while keypressed do readkey;
  fcolor(32*1+31);
  scolor(32*2+31);
  baram(b,100,starty[1]-10,219,starty[maxmen]+20);
  scolor(32*7+31);
  citescmouse;
  for x:=1 to maxmen do
  begin
   mvtextxy2(b,startx[x],starty[x],menustr[x]);
   if(msx>=startx[x]-3)and(msx<=159+159-startx[x]+3)and(msy>=starty[x]-3)and
   (msy<=starty[x]+13) then
   dreptunghi(b,startx[x]-3,starty[x]-3,159+159-startx[x]+3,starty[x]+13);
   if(msx>=startx[x]-3)and(msx<=159+159-startx[x]+3)and(msy>=starty[x]-3)and
   (msy<=starty[x]+13)and(leftbuttonpressed) then
   begin
    repeat
     citescmouse;
    until not leftbuttonpressed;
    iesire:=true;
    reg:=x;
    incarcacuvant(reg);
   end;
  end;
  desenezmouse;
  a^:=b^;
 until iesire;
 fadeout;
end;

procedure verificlitera(litera: integer);
var nrg,nrv: byte;
begin
 nrv:=0;
 for x:=1 to length(cuvant) do
 if cv[x] then nrv:=nrv+1;
 for x:=1 to length(cuvant) do
 if upcase(cuvant[x])=chr(ord('A')-1+litera) then
 cv[x]:=true;
 nrg:=0;
 for x:=1 to length(cuvant) do
 if cv[x] then nrg:=nrg+1;
 if (nrv=nrg)and(nrg<>length(cuvant)) then
 greseli:=greseli+1;
 litere[litera].aleasa:=true;
end;

procedure cautacuvantul;
begin
 if(reg<1)or(reg>4) then s3:=upstring('ai jucat doom2');
 assign(f,dirini+fisiere[reg]);
 rez:=ioresult;
 reset(f,1);
 rez:=ioresult;
 if rez<>0 then
 begin
  s3:=upstring('nu gasesc fisierul');
  exit;
 end;
 fsize:=filesize(f);
 rez:=ioresult;
 nrcuv:=trunc(fsize/21);
 if nrcuv=0 then
 begin
  s3:=upstring('nu e nimic in fisier');
  close(f);
  rez:=ioresult;
  exit;
 end;
 for long:=1 to nrcuv do
 begin
  seek(f,long*21);
  rez:=ioresult;
  blockread(f,s3[0],21,w);
  rez:=ioresult;
  if length(s3)>20 then s3[0]:=#20;
  s3:=upstring(s3);
  for x:=1 to length(s3) do
  if (ord(s3[x])<ord('A'))or(ord(s3[x])>ord('Z')) then
  s3[x]:=' ';
  if (length(s3)=length(cuvant))and(s3<>cuvant) then
  begin
   close(f);
   rez:=ioresult;
   exit;
  end;
 end;
 rand:=random(nrcuv);
 seek(f,rand*21);
 rez:=ioresult;
 blockread(f,s3[0],21,w);
 rez:=ioresult;
 if length(s3)>20 then s3[0]:=#20;
 s3:=upstring(s3);
 for x:=1 to length(s3) do
 if (ord(s3[x])<ord('A'))or(ord(s3[x])>ord('Z')) then
 s3[x]:=' ';
 close(f);
 rez:=ioresult;
end;

procedure joc;
var iesire: boolean;
begin
 incarcjoc;
 initlitere;
 iesire:=false;
 alegecuvant;
 greseli:=0;
 b^:=c^;
 fadein(b);
 if length(cuvant)>20 then cuvant[0]:=#20;
 cuvant:=upstring(cuvant);
 for x:=1 to length(cuvant) do
 if (ord(cuvant[x])<ord('A'))or(ord(cuvant[x])>ord('Z')) then
 begin
  cuvant[x]:=' ';
  cv[x]:=true;
 end;
 cv[1]:=true;
 cv[length(cuvant)]:=true;
 if (ord(cuvant[1])>=ord('A'))and(ord(cuvant[1])<=ord('Z')) then
 litere[ord(cuvant[1])-ord('A')+1].aleasa:=true;
 if (ord(cuvant[length(cuvant)])>=ord('A'))and(ord(cuvant[length(cuvant)])<=ord('Z')) then
 litere[ord(cuvant[length(cuvant)])-ord('A')+1].aleasa:=true;
 for x:=1 to length(cuvant) do
 if (cuvant[x]=cuvant[1])or(cuvant[x]=cuvant[length(cuvant)]) then cv[x]:=true;
 repeat
  ghicit:=true;
  b^:=c^;
  citescmouse;
  for x:=1 to 26 do
  begin
   scolor(32*2+31);
   fcolor(32*1+31);
   baram(b,litere[x].pozx,0,litere[x].pozx+11,15);
   scolor(32*7+31);
   if litere[x].aleasa then scolor(32*4+31);
   mvtextxy1(b,litere[x].pozx+3,1,upcase(litere[x].c));
  end;
  t:=5;
  scolor(32*2+31);
  fcolor(32*1+31);
  bara(b,t-3,157,t+length(cuvant)*10+17,188);
  scolor(32*7+31);
  for x:=1 to length(cuvant) do
  if cv[x] then mvtextxy1(b,t+x*10,160,cuvant[x]) else
  mvtextxy1(b,t+x*10,160,'_');
  scolor(32*7+31);
  fcolor(32*4+31);
  baram(b,240,100,240+79,100+99);
  str(greseli,s);
  mvtextxy1(b,240+35,100+35,s);
  if greseli=0 then s:='0';
  desenezmouse;
  if leftbuttonpressed and((mem[0:$417] and 3)=3) then
  begin
   cautacuvantul;
   fcolor(32*1+31);
   scolor(32*7+31);
   baram(b,0,30,0+8*length(s3)+8,30+17);
   mvtextxy1(b,5,32,s3);
   a^:=b^;
   repeat
    citescmouse;
   until not leftbuttonpressed;
  end;
  if (port[$60]=62)and(leftbuttonpressed) then
  begin
   fcolor(32*1+31);
   scolor(32*7+31);
   baram(b,0,30,0+8*length(cuvant)+8,30+17);
   mvtextxy1(b,5,32,cuvant);
   a^:=b^;
   repeat
    citescmouse;
   until (port[$60]<>62)and(not leftbuttonpressed);
  end;
  a^:=b^;
  if rightbuttonpressed then
  begin
   repeat
    citescmouse;
   until not rightbuttonpressed;
   iesire:=true;
  end;
  for x:=1 to 26 do
  begin
   baram(b,litere[x].pozx,0,litere[x].pozx+11,15);
   if (msx>=litere[x].pozx)and(msx<=litere[x].pozx+11)and(msy>=0)and(msy<=15)
   and(leftbuttonpressed)and(not litere[x].aleasa) then
   begin
    repeat
     citescmouse;
    until (not leftbuttonpressed);
    verificlitera(x);
   end;
  end;
  for x:=1 to length(cuvant) do
  if not cv[x] then ghicit:=false;
  if ghicit then iesire:=true;
  if greseli>=5 then iesire:=true;
  while keypressed do readkey;
  repeat
  until gata;
  gata:=false;
 until iesire;
 incarcjoc;
 fadeout;
 if ghicit then aratamasmecher else
 begin
  if greseli<5 then mamplictisit else
  habarnam;
 end;
end;

procedure incarcmenu;
begin
 assign(f,dirini+fismenu);
 rez:=ioresult;
 reset(f,1);
 rez:=ioresult;
 if rez<>0 then
 begin
  fnegasit:=true;
  numefis:=upstring(fismenu);
  halt;
 end;
 seek(f,8);
 rez:=ioresult;
 blockread(f,c^[0,0],64000,w);
 rez:=ioresult;
 close(f);
 rez:=ioresult;
end;

procedure menu;
const maxmen=3;
      menustr: array[1..maxmen] of string[64]=('Joc nou','Optiuni','Iesire');
var startx,starty: array[1..maxmen] of integer;
    iesire: boolean;
    x,y: integer;
begin
 incarcmenu;
 b^:=c^;
 fadein(b);
 iesire:=false;
 for x:=1 to maxmen do
 begin
  startx[x]:=159-(length(menustr[x])+1)*5 div 2+3;
  starty[x]:=99-maxmen*20+x*20+10+2;
 end;
 repeat
  b^:=c^;
  while keypressed do readkey;
  citescmouse;
  fcolor(32*1+31);
  scolor(32*2+31);
  baram(b,100,starty[1]-10,219,starty[maxmen]+20);
  scolor(32*7+31);
  for x:=1 to maxmen do
  begin
   mvtextxy2(b,startx[x],starty[x],menustr[x]);
   if(msx>=startx[x]-3)and(msx<=159+159-startx[x]+3)and(msy>=starty[x]-3)and
   (msy<=starty[x]+13) then
   dreptunghi(b,startx[x]-3,starty[x]-3,159+159-startx[x]+3,starty[x]+13);
  end;
  desenezmouse;
  a^:=b^;
  if(msx>=startx[1]-3)and(msx<=159+159-startx[1]+3)and(msy>=starty[1]-3)and
  (msy<=starty[1]+13)and(leftbuttonpressed) then
  begin
   repeat
    citescmouse;
   until not leftbuttonpressed;
   fadeout;
   joc;
   incarcmenu;
   b^:=c^;
   fadein(b);
  end;
  if(msx>=startx[2]-3)and(msx<=159+159-startx[2]+3)and(msy>=starty[2]-3)and
  (msy<=starty[2]+13)and(leftbuttonpressed) then
  begin
   repeat
    citescmouse;
   until not leftbuttonpressed;
   optiuni;
  end;
  if(msx>=startx[3]-3)and(msx<=159+159-startx[3]+3)and(msy>=starty[3]-3)and
  (msy<=starty[3]+13)and(leftbuttonpressed) then
  begin
   repeat
    citescmouse;
   until not leftbuttonpressed;
   iesire:=true;
  end;
 until iesire;
 fadeout;
end;

begin
 fape:=upstring('ape.mhb');
 forase:=upstring('orase.mhb');
 fjudete:=upstring('judete.mhb');
 fmunti:=upstring('munti.mhb');
 for x:=1 to 25 do
 for y:=0 to 255 do
 begin
  pal[x][y][1]:=trunc(normpal1[y][1]*x/25);
  pal[x][y][2]:=trunc(normpal1[y][2]*x/25);
  pal[x][y][3]:=trunc(normpal1[y][3]*x/25);
 end;
 fismenu:=upstring('inele.mhb');
 fisjoc:=upstring('bundy.mhb');
 dirini:=upstring(paramstr(0));
 repeat
  if dirini[length(dirini)]<>'\' then delete(dirini,length(dirini),1);
 until (dirini[length(dirini)]='\')or(dirini[0]=#0);
 initmouse;
 a:=ptr(sega000,0);
 getintvec($1c,@p1c);
 oldexit:=exitproc;
 exitproc:=@spanzexit;
 setintvec($1c,@int1c);
 b:=ptr(mhmemaloc(64000),0);
 if eraloc<>eranimic then
 begin
  trebuie:=128000;
  nom:=true;
  halt;
 end;
 c:=ptr(mhmemaloc(64000),0);
 if eraloc<>eranimic then
 begin
  trebuie:=64000;
  nom:=true;
  halt;
 end;
 if not mouseinstalled then nomouse:=true else nomouse:=false;
 for x:=1 to 26 do
 begin
  litere[x].c:=chr(ord('A')-1+x);
  litere[x].pozx:=159-26*6+(x-1)*12;
 end;
 initgr;
 setpal(normpal1);
 menu;
end.