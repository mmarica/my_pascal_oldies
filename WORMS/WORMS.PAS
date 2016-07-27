{$A+,B-,D+,E+,F+,G+,I+,L+,N-,O+,P+,Q+,R+,S+,T-,V+,X+}
{$M 16384,0,0}
program worms;
uses mhmatem,mtast,mhgraf,dos,mvbutil,getpal1;
const fusor: byte=0;
      usor: byte=1;
      normal: byte=2;
      greu: byte=3;
      fgreu: byte=4;
      difstr: array[0..4] of string=('Foarte usor','Usor','Normal','Greu',
      'Foarte greu');
      colstr: array[0..8] of string=('RGB','Gri','Albastru','Verde','Bleu','Rosu',
              'Violet','Maron','Galben');
type scortype=record
               nume: string[10];
               scor: longint;
               lungime: integer;
              end;
var a,b,c,d:^ecran;
    p1c: procedure;
    oldexit: pointer;
    timp: longint;
    texte,mancat,video,gata,iesire,castigat,mort,nom: boolean;
    variatie,ct1,ctm,vx,x,y,z,t,fiserr,lungime: integer;
    lungstart,lungmax,scor,scormax: longint;
    st,fisstr: string;
    w: word;
    moarte,ms,miscare,dx,dy,mx,my: integer;
    buf: array[1..6400] of char;
    pozitii: array[1..416] of record
                               x,y: integer;
                              end;
    pal: mvpal;
    mancare: record
              x,y: integer;
             end;
    tabela: record
             minx,miny,maxx,maxy: integer;
            end;
    dificultate: integer;
    scoruri: array[1..10] of scortype;
    paleta: integer;
    semnt,semntadd: byte;
    menu1fadd,menu1badd,menu1tadd,menu1t,menu1bac,menu1for: byte;
    scort,scortadd,scorbac,scorfor,scorbadd,scorfadd: byte;
    difbac,diffor,dift,difbadd,diffadd,diftadd: byte;
    colbac,colfor,colbadd,colfadd,colt: byte;
    t1,t2,t3,t1add,t2add,t3add: byte;
    ram,ramadd,manc,mancadd: byte;
    estebonus: boolean;
    bonusrand,tipbonus: byte;
    timpbonus,bonusval: longint;
    const cenzurari: string='HipHop';
    var bonuspoz: record
               x,y: integer;
              end;
    valtext,contortext,culoaretext,nrpuncte,pozitietext,lungimetext: integer;
    maxpuncte: integer;
    stringtext: string;
    estetext: boolean;
    textvect: array[1..4000] of record
                                x,y: integer;
                                dir: byte;
                                este: boolean;
                                viteza: integer;
                               end;
    msoftstr: array[1..10] of string[20];
    strrand: byte;

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

procedure enable1c;
begin
 setintvec($1c,@int1c);
end;

procedure disable1c;
begin
 setintvec($1c,@p1c);
end;

procedure setm(mode: byte);
var r: registers;
begin
 r.ah:=00;
 r.al:=mode;
 intr($10,r);
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

procedure salvezscor;
var f: file;
    buf: array[1..170] of char;
    b: byte;
begin
 for x:=1 to 10 do
 begin
  if scoruri[x].lungime<lungstart then scoruri[x].lungime:=lungstart;
  if scoruri[x].scor<0 then scoruri[x].scor:=0;
  if scoruri[x].scor>9999999 then scoruri[x].scor:=9999999;
 end;
 {$I-}
 assign(f,'scoruri.ram');
 rewrite(f,1);
 if ioresult<>0 then
 exit;
 for x:=1 to 10 do
 begin
  b:=length(scoruri[x].nume);
  if b>10 then b:=10;
  move(b,buf[(x-1)*17+1],1);
  move(scoruri[x].nume[1],buf[(x-1)*17+2],10);
  move(scoruri[x].scor,buf[(x-1)*17+12],4);
  move(scoruri[x].lungime,buf[(x-1)*17+16],2);
 end;
 blockwrite(f,buf,10*(10+4+2+1),w);
 close(f);
 {$I+}
end;

procedure salvezoptiuni;
var f: file;
    buf: array[1..2] of char;
    b: byte;
begin
 {$I-}
 assign(f,'optiuni.ram');
 rewrite(f,1);
 if ioresult<>0 then
 exit;
 buf[1]:=chr(paleta);
 buf[2]:=chr(dificultate);
 blockwrite(f,buf,2,w);
 close(f);
 {$I+}
end;

procedure wormsexit;
var error: byte;
begin
 exitproc:=oldexit;
 disable1c;
 disabscankey;
 setm(3);
 writeln('MSoft - Mihai Marica!');
 salvezoptiuni;
 mhmemdealoc(seg(b^));
 mhmemdealoc(seg(c^));
 mhmemdealoc(seg(d^));
 if fiserr<>0 then writeln('Nu pot deschide fisierul de date: ',fisstr);
 error:=exitcode;
 if error<>0 then
 begin
  writeln('MSoft - Eroare! Cod: ',error:3,' la adresa ',conv(seg(erroraddr^)),
  ':',conv(ofs(erroraddr^)));
  writeln('Noteaza adresa si codul ERORII pentru a mi le transmite!');
 end;
 halt;
end;

procedure sortezscor;
var sortat: boolean;
    scr: scortype;
begin
 sortat:=true;
 repeat
  for x:=1 to 10 do
  for y:=x to 10 do
  if scoruri[x].scor<scoruri[y].scor then
  begin
   scr:=scoruri[x];
   scoruri[x]:=scoruri[y];
   scoruri[y]:=scr;
   sortat:=false;
  end;
 until sortat;
end;

procedure incarcscor;
var f: file;
    buf: array[1..170] of char;
    b: byte;
begin
 {$I-}
 assign(f,'scoruri.ram');
 reset(f,1);
 if ioresult<>0 then
 exit;
 blockread(f,buf,10*(10+4+2+1),w);
 for x:=1 to 10 do
 begin
  move(buf[(x-1)*17+1],b,1);
  scoruri[x].nume[0]:=chr(b);
  move(buf[(x-1)*17+2],scoruri[x].nume[1],10);
  move(buf[(x-1)*17+12],scoruri[x].scor,4);
  move(buf[(x-1)*17+16],scoruri[x].lungime,2);
  if scoruri[x].lungime<lungstart then
  begin
   scoruri[x].lungime:=lungstart;
   scoruri[x].scor:=0;
  end;
  if scoruri[x].scor<0 then scoruri[x].scor:=0;
  if scoruri[x].scor>9999999 then scoruri[x].scor:=9999999;
 end;
 close(f);
 {$I+}
 sortezscor;
end;

procedure incarcoptiuni;
var f: file;
    buf: array[1..2] of char;
    b: byte;
begin
 {$I-}
 assign(f,'optiuni.ram');
 reset(f,1);
 if ioresult<>0 then
 exit;
 blockread(f,buf,2,w);
 b:=ord(buf[1]);
 if b>8 then b:=8;
 paleta:=b;
 b:=ord(buf[2]);
 if b>4 then b:=4;
 dificultate:=b;
 close(f);
 {$I+}
end;

procedure introducscor(scor: scortype;poz: byte);
begin
 if poz=10 then scoruri[10]:=scor;
 if poz<10 then
 begin
  for x:=9 downto poz do
  scoruri[x+1]:=scoruri[x];
  scoruri[poz]:=scor;
 end;
end;

function verificscor(scor: longint): byte;
var scr: scortype;
    poz: integer;
begin
 poz:=11;
 for x:=10 downto 1 do
 if scor>scoruri[x].scor then poz:=x;
 verificscor:=poz;
end;

procedure loadback;
var f: file;
begin
{ disable1c;}
 {$I-}
 assign(f,fisstr);
 setfattr(f,0);
 reset(f,1);
 seek(f,8);
 for vx:=0 to 9 do
 begin
  blockread(f,buf,6400,w);
  move(buf,d^[20*vx,0],6400);
 end;
 close(f);
 {$I+}
 if ioresult<>0 then
 begin
  fiserr:=2;
  wormsexit;
 end;
 enable1c;
end;

function citescnume(loc: byte): string;
const taste: array['a'..'z'] of byte=(tsa,tsb,tsc,tsd,tse,tsf,tsg,tsh,tsi,tsj,
       tsk,tsl,tsm,tsn,tso,tsp,tsq,tsr,tss,tst,tsu,tsv,tsw,tsx,tsy,tsz);
var st: string;
    ch: char;
    strg: string[10];
begin
 ct1:=0;
 ctm:=1;
 loadback;
 scolor(32*4+31);
 str(loc:2,st);
 for x:=1 to 2 do
 if st[x]=' ' then st[x]:='0';
 st:='Ai iesit pe locul '+st;
 mvtextxy(d,159-4*length(st),30,st);
 st:='Inscrie-ti numele';
 for vx:=1 to paramcount do
 begin
  if paramstr(vx)=cenzurari then st:='Zi-mi numele tau, muistule!';
 end;
 mvtextxy(d,159-4*length(st),50,st);
 strg:='Nume';
 repeat
 until not key[tsenter];
 repeat
  b^:=d^;
  variatie:=variatie+1;
  if variatie>31 then variatie:=15;
  scolor(32*4+variatie);
  for ch:='a' to 'z' do
  if key[taste[ch]] then
  begin
   if (key[tsshifts])or(key[tsshiftd]) then
   strg:=strg+upcase(ch) else
   strg:=strg+ch;
   repeat
   until not key[taste[ch]];
  end;
  if key[tsbkspace] then
  begin
   if length(strg)>0 then strg[0]:=chr(ord(strg[0])-1);
   repeat
   until not key[tsbkspace];
  end;
  mvtextxy(b,159-4*length(strg),80,strg);
  a^:=b^;
  repeat
  until gata;
  gata:=false;
 until key[tsenter];
 repeat
 until not key[tsenter];
 loadback;
 citescnume:=strg;
end;

procedure prezentare;
var delay,ct,del,poz: integer;
    oprit: boolean;
    strg: string;
    litere: array[1..255] of char;
begin
 oprit:=false;
 del:=1;
 delay:=0;
 ct1:=0;
 ctm:=1;
 for y:=39 downto 0 do
 if not oprit then
 begin
  delay:=delay+1;
  if delay>=7 then
  begin
   del:=del+1;
   delay:=0;
  end;
  copymvb(d,b,0,0,319,199,0,y*5);
  a^:=b^;
  for x:=1 to del do
  begin
   repeat
   if key[tsesc] then
   begin
    repeat
    until not key[tsesc];
    oprit:=true;
   end;
   until gata;
   gata:=false;
  end;
 end;
 ct1:=0;
 ctm:=3;
 strg:='MSoft';
 if not oprit then
 for x:=10 downto 1 do
 if not oprit then
 begin
  scolor(31*7+21+11-x);
  b^:=d^;
  schimbmf(x);
  poz:=159-x*length(strg)*4;
  mvtextxy(b,poz,20+7*(11-x),strg);
  a^:=b^;
  repeat
  if key[tsesc] then
  begin
   repeat
   until not key[tsesc];
   oprit:=true;
  end;
  until gata;
  gata:=false;
 end;
 c^:=b^;
 strg:='WORMS - Mihai Marica';
 if not oprit then
 for x:=10 downto 1 do
 if not oprit then
 begin
  scolor(31*1+21+11-x);
  b^:=c^;
  schimbmf(x);
  poz:=159-x*length(strg)*4;
  mvtextxy(b,poz,7*(11-x),strg);
  a^:=b^;
  repeat
  if key[tsesc] then
  begin
   repeat
   until not key[tsesc];
   oprit:=true;
  end;
  until gata;
  gata:=false;
 end;
 c^:=b^;
 strg:='Apasa enter';
 ct:=1;
 if not oprit then
 begin
  for x:=10 downto 1 do
  if not oprit then
  begin
   scolor(31*4+21+11-x);
   b^:=c^;
   schimbmf(x);
   poz:=159-x*length(strg)*4;
   mvtextxy(b,poz,40+7*(11-x),strg);
   a^:=b^;
   repeat
   if key[tsesc] then
   begin
    repeat
    until not key[tsesc];
    oprit:=true;
    ct:=x;
   end;
   until gata;
   gata:=false;
  end;
  if ct=1 then
  begin
   repeat
   until key[tsenter];
   repeat
   until not key[tsenter];
  end;
 end;
 ct1:=0;
 ctm:=1;
 schimbmf(1);
end;

procedure verificmort;
begin
 for x:=3 to lungime do
 if (pozitii[x].x=pozitii[1].x)and(pozitii[x].y=pozitii[1].y) then
 begin
  mort:=true;
  moarte:=2;
 end;
 if pozitii[1].x<tabela.minx then
 begin
  mort:=true;
  moarte:=1;
 end;
 if pozitii[1].y<tabela.miny then
 begin
  mort:=true;
  moarte:=1;
 end;
 if pozitii[1].x>tabela.maxx-1 then
 begin
  mort:=true;
  moarte:=1;
 end;
 if pozitii[1].y>tabela.maxy-1 then
 begin
  mort:=true;
  moarte:=1;
 end;
end;

procedure facaltloc;
var xt,yt: integer;
begin
 repeat
  xt:=random(tabela.maxx);
  yt:=random(tabela.maxy);
  mancat:=false;
  for x:=1 to lungime do
  if (xt=pozitii[x].x)and(yt=pozitii[x].y) then mancat:=true;
  if estebonus then
  if (xt=bonuspoz.x)and(yt=bonuspoz.y) then mancat:=true;
 until not mancat;
 mancare.x:=xt;
 mancare.y:=yt;
end;

procedure facaltbonus;
var xt,yt: integer;
    nuebine: boolean;
begin
 tipbonus:=random(3);
 if tipbonus=0 then {timp}
 bonusval:=(10+random(11))*18;
 if tipbonus=1 then {lungime}
 bonusval:=1+random(3);
 if tipbonus=2 then {puncte}
 bonusval:=(1+random(3))*1000;
 timpbonus:=(3+random(3))*18;
 repeat
  xt:=random(tabela.maxx);
  yt:=random(tabela.maxy);
  nuebine:=false;
  for x:=1 to lungime do
  if (xt=pozitii[x].x)and(yt=pozitii[x].y) then nuebine:=true;
  if (xt=mancare.x)and(yt=mancare.y) then nuebine:=true;
 until not nuebine;
 bonuspoz.x:=xt;
 bonuspoz.y:=yt;
end;

procedure inserttext(s: string;sec: byte);
begin
 contortext:=18*sec;
 nrpuncte:=0;
 {nrpuncte:=-3;}
 estetext:=true;
 stringtext:=s;
 lungimetext:=length(s);
 pozitietext:=159-8*lungimetext-8;
 for z:=1 to lungimetext do
 for x:=0 to 7 do
 for y:=0 to 13 do
 if textbool^[ord(s[z]),y,x] then
 if nrpuncte<maxpuncte then
 begin
  nrpuncte:=nrpuncte+1;
{  nrpuncte:=nrpuncte+4;}
  textvect[nrpuncte].x:=pozitietext+z*16+x*2;
  textvect[nrpuncte].y:=20+y*2;
  textvect[nrpuncte].dir:=random(4);
  textvect[nrpuncte].este:=true;
  textvect[nrpuncte].viteza:=3+random(10);
{  textvect[nrpuncte+1].x:=textvect[nrpuncte].x+1;
  textvect[nrpuncte+1].y:=textvect[nrpuncte].y;
  textvect[nrpuncte+1].dir:=random(4);
  textvect[nrpuncte+1].este:=true;
  textvect[nrpuncte+1].viteza:=3+random(10);
  textvect[nrpuncte+2].x:=textvect[nrpuncte].x;
  textvect[nrpuncte+2].y:=textvect[nrpuncte].y+1;
  textvect[nrpuncte+2].dir:=random(4);
  textvect[nrpuncte+2].este:=true;
  textvect[nrpuncte+2].viteza:=3+random(10);
  textvect[nrpuncte+3].x:=textvect[nrpuncte].x+1;
  textvect[nrpuncte+3].y:=textvect[nrpuncte].y+1;
  textvect[nrpuncte+3].dir:=random(4);
  textvect[nrpuncte+3].este:=true;
  textvect[nrpuncte+3].viteza:=3+random(10);}
 end;
end;

procedure verificbonus;
var atins: boolean;
    s: string;
begin
 for x:=1 to lungime do
 if (bonuspoz.x=pozitii[x].x)and(bonuspoz.y=pozitii[x].y) then
 begin
  if tipbonus=0 then
  begin
   timp:=timp+bonusval;
   str(bonusval div 18:2,s);
   s:='Timp: '+s+' secunde!';
   for vx:=1 to paramcount do
   if paramstr(vx)=cenzurari then
   begin
    str(bonusval div 18:2,s);
    s:='Muie '+s+' secunde!';
   end;
   inserttext(s,3);
  end;
  if timp>999*18 then timp:=999*18;
  if tipbonus=1 then
  begin
   lungime:=lungime-bonusval;
   str(bonusval:1,s);
   s:='Lungime: -'+s+'!';
   for vx:=1 to paramcount do
   if paramstr(vx)=cenzurari then
   begin
    str(bonusval:1,s);
    s:='Muie '+s+'000 metri!';
   end;
   inserttext(s,3);
  end;
  if lungime<lungstart then lungime:=lungstart;
  if tipbonus=2 then
  begin
   scor:=scor+bonusval;
   str(bonusval:4,s);
   s:='Scor: '+s+' puncte!';
   for vx:=1 to paramcount do
   if paramstr(vx)=cenzurari then
   begin
    str(bonusval:4,s);
    s:='Ai supt '+s+' puncte!';
   end;
   inserttext(s,3);
   randomize;
  end;
  estebonus:=false;
  exit;
 end;
end;

procedure elimintext;
begin
 estetext:=false;
 pozitietext:=0;
 lungimetext:=0;
 fillchar(textvect,sizeof(textvect),0);
end;

procedure afiseztext(p: pointer);
var f: ^ecran;
    tempval: integer;
    fv: byte;
begin
 fv:=fcl;
 culoaretext:=32*4+variatie;
 fcl:=culoaretext;
 valtext:=valtext+10;
 if valtext>360 then valtext:=valtext-360;
 f:=p;
 for x:=1 to nrpuncte do
 if textvect[x].este then
 begin
  if contortext<1 then
{  if (textvect[x].x>=0)and(textvect[x].x<=319) then
  f^[textvect[x].y,textvect[x].x]:=culoaretext;}
  bara(f,textvect[x].x,textvect[x].y,textvect[x].x+1,textvect[x].y+1);
  if contortext>0 then
  begin
   tempval:=textvect[x].x mod 36*10+valtext;
   tempval:=round(5*cosv(tempval));
{   if (textvect[x].x>=0)and(textvect[x].x<=319) then
   if (textvect[x].y+tempval>=0)and(textvect[x].y+tempval<=199) then
   f^[textvect[x].y+tempval,textvect[x].x]:=culoaretext;}
   bara(f,textvect[x].x,textvect[x].y+tempval,textvect[x].x+1,textvect[x].y+1+tempval);
  end;
 end;
 fcl:=fv;
end;

procedure misctext;
begin
 contortext:=contortext-1;
 if contortext<1 then contortext:=0;
 if contortext>1 then exit;
 for x:=1 to nrpuncte do
 begin
  if textvect[x].dir=0 then
  begin
   textvect[x].x:=textvect[x].x-textvect[x].viteza;
   textvect[x].y:=textvect[x].y-textvect[x].viteza;
  end;
  if textvect[x].dir=1 then
  begin
   textvect[x].x:=textvect[x].x+textvect[x].viteza;
   textvect[x].y:=textvect[x].y-textvect[x].viteza;
  end;
  if textvect[x].dir=2 then
  begin
   textvect[x].x:=textvect[x].x-textvect[x].viteza;
   textvect[x].y:=textvect[x].y+textvect[x].viteza;
  end;
  if textvect[x].dir=3 then
  begin
   textvect[x].x:=textvect[x].x+textvect[x].viteza;
   textvect[x].y:=textvect[x].y+textvect[x].viteza;
  end;
  if (textvect[x].x<0)or(textvect[x].y<0)or(textvect[x].x>319)or(textvect[x].y>199) then
  textvect[x].este:=false;
 end;
{ contortext:=contortext-1;
 if contortext<1 then contortext:=0;
 if contortext>1 then exit;
 for x:=1 to nrpuncte do
 begin
  if textvect[x].dir=0 then
  begin
   textvect[x].x:=textvect[x].x-textvect[x].viteza;
   textvect[x].y:=textvect[x].y-textvect[x].viteza;
  end;
  if textvect[x].dir=1 then
  begin
   textvect[x].x:=textvect[x].x+textvect[x].viteza;
   textvect[x].y:=textvect[x].y-textvect[x].viteza;
  end;
  if textvect[x].dir=2 then
  begin
   textvect[x].x:=textvect[x].x-textvect[x].viteza;
   textvect[x].y:=textvect[x].y+textvect[x].viteza;
  end;
  if textvect[x].dir=3 then
  begin
   textvect[x].x:=textvect[x].x+textvect[x].viteza;
   textvect[x].y:=textvect[x].y+textvect[x].viteza;
  end;
  if (textvect[x].x<0)or(textvect[x].y<0)or(textvect[x].x>319)or(textvect[x].y>199) then
  textvect[x].este:=false;
 end;}
end;

function maiestetext: boolean;
begin
 maiestetext:=false;
 for x:=1 to nrpuncte do
 if textvect[x].este then
 begin
  maiestetext:=true;
  exit;
 end;
end;

procedure joc;
var incx,incy: integer;
    dir: integer;
    tasta: byte;
    nscor: scortype;
    pozitie: byte;
begin
 randomize;
 moarte:=0;
 timp:=99*18;
 pozitie:=11;
 loadback;
 mort:=false;
 ct1:=0;
 if dificultate=fusor then ctm:=9;
 if dificultate=usor then ctm:=7;
 if dificultate=normal then ctm:=5;
 if dificultate=greu then ctm:=3;
 if dificultate=fgreu then ctm:=1;
 incx:=12;
 incy:=7;
 scolor(31);
 facaltloc;
 for x:=tabela.minx to tabela.maxx do
 linie(d,dx+x*mx,dy+tabela.miny*my,dx+x*mx,dy+tabela.maxy*my);
 for y:=tabela.miny to tabela.maxy do
 linie(d,dx+tabela.minx*mx,dy+y*my,dx+tabela.maxx*mx,dy+y*my);
 scor:=0;
 variatie:=15;
 iesire:=false;
 lungime:=lungstart;
 for x:=1 to lungime do
 begin
  pozitii[x].x:=incx;
  pozitii[x].y:=incy;
 end;
 b^:=d^;
 for x:=1 to lungime do
 copymvb(c,b,0,0,10,10,dx+tabela.minx*mx+1+pozitii[x].x*mx,dy+tabela.miny*my+1+pozitii[x].y*my);
 copymvb(c,b,12,1,22,11,dx+tabela.minx*mx+1+mancare.x*mx,dy+tabela.miny*my+1+mancare.y*my);
 a^:=b^;
 gata:=false;
 dir:=5;
 estebonus:=false;
 inserttext('Start!',3);
 for vx:=1 to paramcount do
 if paramstr(vx)=cenzurari then
 begin
  inserttext('Suge-o de inceput!',3);
 end;
 repeat
  if not estebonus then
  begin
   bonusrand:=random(30);
   if bonusrand=0 then
   begin
    facaltbonus;
    estebonus:=true;
   end;
  end;
  if estebonus then
  begin
   timpbonus:=timpbonus-1;
   if timpbonus<=0 then estebonus:=false;
  end;
  timp:=timp-1;
  if key[tst] then if texte then texte:=false else texte:=true;
  repeat
   if key[tssus] then tasta:=1;
   if key[tsjos] then tasta:=2;
   if key[tsstanga] then tasta:=3;
   if key[tsdreapta] then tasta:=4;
   if key[tsesc] then iesire:=true;
  until gata;
  if key[tsp] then
  begin
   b^:=d^;
   fcolor(32*scorbac+scorbadd);
   scolor(32*scorfor+scorfadd);
   baram(b,7,3,312,196);
   st:='Pauza';
   mvtextxy(b,159-length(st)*4,80,st);
   st:='Cenzurat';
   mvtextxy(b,159-length(st)*4,100,st);
   dir:=5;
   a^:=b^;
   repeat
   until not key[tsp];
   repeat
   until key[tsp];
   repeat
   until not key[tsp];
  end;
  gata:=false;
  if lungime<=1 then
  begin
   if tasta=1 then dir:=0;
   if tasta=2 then dir:=1;
   if tasta=3 then dir:=2;
   if tasta=4 then dir:=3;
  end else
  begin
   if tasta=1 then if dir<>1 then dir:=0;
   if tasta=2 then if dir<>0 then dir:=1;
   if tasta=3 then if dir<>3 then dir:=2;
   if tasta=4 then if dir<>2 then dir:=3;
  end;
  for x:=lungime downto 2 do
  pozitii[x]:=pozitii[x-1];
  if dir=0 then pozitii[1].y:=pozitii[1].y-1;
  if dir=1 then pozitii[1].y:=pozitii[1].y+1;
  if dir=2 then pozitii[1].x:=pozitii[1].x-1;
  if dir=3 then pozitii[1].x:=pozitii[1].x+1;
  variatie:=variatie+1;
  if variatie>31 then variatie:=15;
  b^:=d^;
  if (pozitii[1].x=mancare.x)and(pozitii[1].y=mancare.y)then
  begin
   scor:=scor+(10-ctm)*lungime;
   lungime:=lungime+1;
   pozitii[lungime]:=pozitii[lungime-1];
   facaltloc;
  end;
  if estebonus then verificbonus;
  if texte then
  begin
   scolor(32*4+variatie);
   str(scor:7,st);
   for x:=1 to length(st) do
   if st[x]=' ' then st[x]:='0';
   st:='Scor: '+st;
   mvtextxy(b,0,0,st);
   str(lungime:3,st);
   for x:=1 to length(st) do
   if st[x]=' ' then st[x]:='0';
   st:='Lungime: '+st;
   mvtextxy(b,319-8*length(st),0,st);
   str(trunc(timp/18)+1:3,st);
   for x:=1 to length(st) do
   if st[x]=' ' then st[x]:='0';
   mvtextxy(b,159-length(st),0,st);
  end;
  for x:=1 to lungime do
  copymvb(c,b,0,0,10,10,dx+tabela.minx*mx+1+pozitii[x].x*mx,dy+tabela.miny*my+1+pozitii[x].y*my);
  copymvb(c,b,12,1,22,11,dx+tabela.minx*mx+1+mancare.x*mx,dy+tabela.miny*my+1+mancare.y*my);
  if estebonus then
  begin
   if tipbonus=0 then
   copymvb(c,b,24,0,34,10,dx+tabela.minx*mx+1+bonuspoz.x*mx,dy+tabela.miny*my+1+bonuspoz.y*my);
   if tipbonus=1 then
   copymvb(c,b,36,0,46,10,dx+tabela.minx*mx+1+bonuspoz.x*mx,dy+tabela.miny*my+1+bonuspoz.y*my);
   if tipbonus=2 then
   copymvb(c,b,48,0,58,10,dx+tabela.minx*mx+1+bonuspoz.x*mx,dy+tabela.miny*my+1+bonuspoz.y*my);
  end;
  if estetext then
  begin
   misctext;
   if not maiestetext then elimintext;
   afiseztext(b);
  end;
  if not estetext then
  begin
   strrand:=1+random(10);
   inserttext(msoftstr[strrand],3);
  end;
  verificmort;
  if mort then iesire:=true;
  if not iesire then a^:=b^;
  if key[tsesc] then iesire:=true;
  if timp<=0 then
  begin
   iesire:=true;
   moarte:=3;
  end;
 until iesire;
 iesire:=false;
 repeat
 until not key[tsesc];
 ct1:=0;
 ctm:=1;
 loadback;
 b^:=d^;
 nscor.scor:=scor;
 pozitie:=verificscor(nscor.scor);
 if pozitie<11 then
 begin
  st:=citescnume(pozitie);
  nscor.scor:=scor;
  nscor.nume:=st;
  nscor.lungime:=lungime;
  introducscor(nscor,pozitie);
  salvezscor;
 end;
 ct1:=0;
 ctm:=1;
 begin
  if moarte=0 then inserttext('Te-ai plictisit?',5);
  if moarte=1 then inserttext('Iti plac peretii?',5);
  if moarte=2 then inserttext('Dai cap in coada?',5);
  if moarte=3 then inserttext('Ai prea mult timp?',5);
 end;
 for vx:=1 to paramcount do
 if paramstr(vx)=cenzurari then
 begin
  if moarte=0 then inserttext('Ai supt destul?',5);
  if moarte=1 then inserttext('Futi peretii?',5);
  if moarte=2 then inserttext('Dai cap in pula?',5);
  if moarte=3 then inserttext('Ai prea multa muie?',5);
 end;
end;

procedure alegdificultate;
begin
 loadback;
 ct1:=0;
 ctm:=1;
 fcolor(32*difbac+difbadd);
 scolor(32*diffor+diffadd);
 baram(d,89,80,229,100);
 repeat
  b^:=d^;
  variatie:=variatie+1;
  if variatie>31 then variatie:=15;
  if key[tsstanga] then
  begin
   dificultate:=dificultate-1;
   repeat
   until not key[tsstanga];
  end;
  if key[tsdreapta] then
  begin
   dificultate:=dificultate+1;
   repeat
   until not key[tsdreapta];
  end;
  if dificultate<0 then dificultate:=4;
  if dificultate>4 then dificultate:=0;
  scolor(32*dift+variatie);
  mvtextxy(b,159-4*length(difstr[dificultate]),83,difstr[dificultate]);
  if estetext then
  begin
   misctext;
   if not maiestetext then elimintext;
   afiseztext(b);
  end;
  if not estetext then
  begin
   strrand:=1+random(10);
   inserttext(msoftstr[strrand],3);
  end;
  a^:=b^;
  repeat
  until gata;
  gata:=false;
 until key[tsenter];
 repeat
 until not key[tsenter];
 loadback;
 ct1:=0;
 ctm:=1;
end;

procedure setezculori;
begin
 if (paleta>=1)and(paleta<=8) then
 begin
  pal:=normpal1;
  for y:=0 to 7 do
  move(pal[(paleta-1)*32],pal[y*32],32*3);
  setpal(pal);
 end else
 setpal(normpal1);
end;

procedure culori;
begin
 loadback;
 ct1:=0;
 ctm:=1;
 fcolor(32*colbac+colbadd);
 scolor(32*colfor+colfadd);
 baram(d,89,80,229,100);
 repeat
  b^:=d^;
  variatie:=variatie+1;
  if variatie>31 then variatie:=15;
  if key[tsstanga] then
  begin
   paleta:=paleta-1;
   repeat
   until not key[tsstanga];
  end;
  if key[tsdreapta] then
  begin
   paleta:=paleta+1;
   repeat
   until not key[tsdreapta];
  end;
  if paleta<0 then paleta:=8;
  if paleta>8 then paleta:=0;
  scolor(32*colt+variatie);
  mvtextxy(b,159-4*length(colstr[paleta]),83,colstr[paleta]);
  setezculori;
  if estetext then
  begin
   misctext;
   if not maiestetext then elimintext;
   afiseztext(b);
  end;
  if not estetext then
  begin
   strrand:=1+random(10);
   inserttext(msoftstr[strrand],3);
  end;
  a^:=b^;
  repeat
  until gata;
  gata:=false;
 until key[tsenter] or key[tsesc];
 repeat
 until (not key[tsenter])and(not key[tsesc]);
 loadback;
 ct1:=0;
 ctm:=1;
end;

procedure afisarescoruri;
var numestr: string[10];
    nrstr: string[3];
    fstr: string;
    scorstr: string[7];
    lungstr: string[5];
begin
 ct1:=0;
 ctm:=1;
 loadback;
 b^:=d^;
 fcolor(32*scorbac+scorbadd);
 scolor(32*scorfor+scorfadd);
 baram(b,7,3,312,196);
 scolor(32*scort+31);
 for x:=1 to 10 do
 begin
  str(x:2,nrstr);
  for y:=1 to length(nrstr) do
  if nrstr[y]=' ' then nrstr[y]:='0';
  nrstr:=nrstr+'.';
  numestr:=scoruri[x].nume;
  if numestr='' then numestr:='Anonim';
  for y:=length(numestr)+1 to 10 do
  numestr:=numestr+'.';
  str(scoruri[x].scor:7,scorstr);
  for y:=1 to length(scorstr) do
  if scorstr[y]=' ' then scorstr[y]:='0';
  str(scoruri[x].lungime:5,lungstr);
  for y:=1 to length(lungstr) do
  if lungstr[y]=' ' then lungstr[y]:='0';
  fstr:=nrstr+numestr+'....'+scorstr+'....'+lungstr;
  mvtextxy(b,30,x*15+20,fstr);
 end;
 fstr:='Cele mai bune scoruri:';
 for vx:=1 to paramcount do
 if paramstr(vx)=cenzurari then
 begin
  fstr:='Cele mai bune sugeri de pula:';
 end;
 mvtextxy(b,159-4*length(fstr),10,fstr);
 d^:=b^;
 repeat
  variatie:=variatie+1;
  if variatie>31 then variatie:=15;
  b^:=d^;
  if estetext then
  begin
   misctext;
   if not maiestetext then elimintext;
   afiseztext(b);
  end;
  if not estetext then
  begin
   strrand:=1+random(10);
   inserttext(msoftstr[strrand],3);
  end;
  a^:=b^;
 until (key[tsesc])or(key[tsenter]);
 repeat
 until (not key[tsesc])and(not key[tsenter]);
 loadback;
 ct1:=0;
 ctm:=1;
end;

procedure menu;
var menupoz: integer;
    menustr: array[1..10] of string[40];
    startx,starty: array[1..10] of integer;
    maxmen,minx,maxx,miny,maxy: integer;
    apasat: boolean;
begin
 iesire:=false;
 ct1:=0;
 ctm:=1;
 menupoz:=1;
 maxmen:=4;
 menustr[1]:='Joc nou';
 menustr[2]:='Dificultate';
 menustr[3]:='Scoruri';
 menustr[4]:='Paleta';
 minx:=159;
 maxx:=159;
 for x:=1 to maxmen do
 begin
  startx[x]:=159-4*length(menustr[x]);
  starty[x]:=99-7*maxmen+x*14;
  if minx>startx[x] then
  begin
   minx:=startx[x]-10;
   maxx:=startx[x]+8*length(menustr[x])+10;
  end;
 end;
 miny:=starty[1]-10;
 maxy:=starty[maxmen]+24;
 iesire:=false;
 if minx<0 then minx:=0;
 if maxx>319 then maxx:=319;
 if miny<0 then miny:=0;
 if maxy>199 then maxy:=199;
 fcolor(32*menu1bac+menu1badd);
 scolor(32*menu1for+menu1fadd);
 baram(d,minx,miny,maxx,maxy);
 scolor(32*menu1t+menu1tadd);
 for x:=1 to maxmen do
 mvtextxy(d,startx[x],starty[x],menustr[x]);
 repeat
  variatie:=variatie+1;
  if variatie>31 then variatie:=15;
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
  if menupoz>maxmen then menupoz:=1;
  if menupoz<1 then menupoz:=maxmen;
  scolor(32*menu1t+menu1tadd+10);
  mvtextxy(b,startx[menupoz],starty[menupoz],menustr[menupoz]);
  if key[tsenter] then
  begin
   repeat
   until not key[tsenter];
   if menupoz=1 then joc;
   if menupoz=2 then alegdificultate;
   if menupoz=3 then afisarescoruri;
   if menupoz=4 then culori;
   repeat
   until (not key[tsenter])and(not key[tsesc]);
   fcolor(32*menu1bac+menu1badd);
   scolor(32*menu1for+menu1fadd);
   baram(d,minx,miny,maxx,maxy);
   scolor(32*menu1t+menu1tadd);
   for x:=1 to maxmen do
   mvtextxy(d,startx[x],starty[x],menustr[x]);
  end;
  if key[tsesc] then
  begin
   iesire:=true;
   repeat
   until not key[tsesc];
  end;
  if estetext then
  begin
   misctext;
   if not maiestetext then elimintext;
   afiseztext(b);
  end;
  if not estetext then
  begin
   strrand:=1+random(10);
   inserttext(msoftstr[strrand],3);
  end;
  a^:=b^;
  repeat
  until gata;
  gata:=true;
 until iesire;
 loadback;
 ct1:=0;
 ctm:=1;
end;

procedure verificcenzurat;
begin
 begin
  msoftstr[1]:='Iti place MSoft?';
  msoftstr[2]:='Vrei sa joci?';
  msoftstr[3]:='Il stii pe Mihai?';
  msoftstr[4]:='Iti place Worms?';
  msoftstr[5]:='Esti cam tacut!';
  msoftstr[6]:='Nu stii sa joci?';
  msoftstr[7]:='Iti plac paletele?';
  msoftstr[8]:='Mihai-271667';
  msoftstr[9]:='MSoft e prima!';
  msoftstr[10]:='www.???.MSoft';
  inserttext('MSoft te saluta!',3);
 end;
 for vx:=1 to paramcount do
 if paramstr(vx)=cenzurari then
 begin
  msoftstr[1]:='Iei muie?';
  msoftstr[2]:='O mai sugi?';
  msoftstr[3]:='Te fut in gura!';
  msoftstr[4]:='Nu e vina ta!';
  msoftstr[5]:='E vina naturii!';
  msoftstr[6]:='Ai frecat-o bine?';
  msoftstr[7]:='Dupa blocuri!';
  msoftstr[8]:='Sa mananci worms!';
  msoftstr[9]:='MSoft ti-o da!';
  msoftstr[10]:='Muie, fraiere!';
  inserttext('MSoft iti da muie!',3);
 end;
end;

procedure iesim;
var terminat: boolean;
    imagine: array[1..32,1..20] of boolean;
    x,y,z: integer;
begin
 loadback;
 z:=0;
 terminat:=false;
 fillchar(imagine,sizeof(imagine),0);
 fillchar(b^,sizeof(b^),32*4+31);
 repeat
  z:=z+1;
  repeat
   x:=1+random(32);
   y:=1+random(20);
  until not imagine[x,y];
  imagine[x,y]:=true;
  copymvb(d,b,(x-1)*10,(y-1)*10,(x-1)*10+9,(y-1)*10+9,(x-1)*10,(y-1)*10);
  terminat:=true;
  for x:=1 to 32 do
  for y:=1 to 20 do
  if not imagine[x,y] then
  terminat:=false;
  if key[tsesc] then
  begin
   terminat:=true;
   repeat
   until not key[tsesc];
  end;
  if z mod 10=0 then a^:=b^;
 until terminat;
 z:=0;
 terminat:=false;
 fillchar(imagine,sizeof(imagine),0);
 b^:=d^;
 fcolor(32*4+31);
 repeat
  z:=z+1;
  repeat
   x:=1+random(32);
   y:=1+random(20);
  until not imagine[x,y];
  imagine[x,y]:=true;
  bara(b,(x-1)*10,(y-1)*10,(x-1)*10+9,(y-1)*10+9);
  terminat:=true;
  for x:=1 to 32 do
  for y:=1 to 20 do
  if not imagine[x,y] then
  terminat:=false;
  if key[tsesc] then
  begin
   terminat:=true;
   repeat
   until not key[tsesc];
  end;
  if z mod 10=0 then a^:=b^;
 until terminat;
 for x:=31 downto 1 do
 begin
  fcolor(32*4+x);
  bara(b,0,0,319,199);
  terminat:=false;
  if key[tsesc] then
  begin
   terminat:=true;
   repeat
   until not key[tsesc];
  end;
  if terminat then break;
  a^:=b^;
 end;
end;

begin
 randomize;
 strrand:=1+random(10);
 maxpuncte:=4000;
 incarcoptiuni;
 culoaretext:=32*4+31;
 semnt:=4;
 semntadd:=31;
 t1:=4;
 t1add:=31;
 t2:=7;
 t2add:=31;
 t3:=1;
 t3add:=31;
 menu1bac:=2;
 menu1badd:=20;
 menu1for:=2;
 menu1fadd:=31;
 menu1t:=3;
 menu1tadd:=21;
 ram:=7;
 ramadd:=16;
 manc:=4;
 mancadd:=16;
 scort:=7;
 scortadd:=31;
 scorbac:=2;
 scorbadd:=20;
 scorfor:=2;
 scorfadd:=31;
 difbac:=7;
 difbadd:=20;
 diffor:=7;
 diffadd:=31;
 dift:=2;
 diftadd:=31;
 colbac:=4;
 colbadd:=20;
 colfor:=4;
 colfadd:=31;
 colt:=7;
 lungstart:=1;
 if lungstart<1 then lungstart:=1;
 for x:=1 to 10 do
 scoruri[x].lungime:=lungstart;
 texte:=true;
 mv:=3;
 ct1:=0;
 ctm:=1;
 fisstr:='wormsbac.mhb';
 getintvec($1c,@p1c);
 initscankey;
 oldexit:=exitproc;
 exitproc:=@wormsexit;
 enable1c;
 if not alocattext then
 begin
  writeln('Nu e destula memorie conventionala!');
  writeln('Mai trebuie peste 200kb de memorie!');
  wormsexit;
 end;
 nom:=false;
 a:=ptr(sega000,0);
 b:=ptr(mhmemaloc(64000),0);
 if eraloc<>eranimic then nom:=true;
 c:=ptr(mhmemaloc(64000),0);
 if eraloc<>eranimic then nom:=true;
 d:=ptr(mhmemaloc(64000),0);
 if eraloc<>eranimic then nom:=true;
 if nom then
 begin
  writeln('Nu e destula memorie conventionala!');
  wormsexit;
 end;
 initcossin;
 clearbuf(b,0);
 clearbuf(c,0);
 clearbuf(d,0);
 loadback;
 incarcscor;
 initgr;
 setezculori;
 video:=true;
 prezentare;
 iesire:=false;
 clearbuf(c,0);
 for x:=5 downto 1 do
 begin
  fcolor(32*ram+ramadd+(6-x)*3);
  elipsap(c,round(x*2/3)+2,round(x*2/3)+2,x,x);
 end;
 for x:=3 downto 1 do
 begin
  fcolor(32*manc+mancadd+(6-x)*3);
  elipsap(c,round(x*2/3)+4+11,round(x*2/3)+4,x,x);
 end;
 for x:=5 downto 1 do
 begin
  fcolor(32*ram+ramadd+(6-x)*3);
  elipsap(c,round(x*2/3)+2+24,round(x*2/3)+2,x,x);
  elipsap(c,round(x*2/3)+2+36,round(x*2/3)+2,x,x);
  elipsap(c,round(x*2/3)+2+48,round(x*2/3)+2,x,x);
 end;
 scolor(32*semnt+semntadd);
 mvtextxy(c,24+2,0-1,'+');
 mvtextxy(c,36+2,0-1,'-');
 mvtextxy(c,48+2,0-1,'!');
 variatie:=15;
 dx:=10;
 dy:=15;
 mx:=12;
 my:=12;
 tabela.minx:=0;
 tabela.miny:=0;
 tabela.maxx:=25;
 tabela.maxy:=15;
 miscare:=0;
 ms:=0;
 key[tsesc]:=false;
 verificcenzurat;
 menu;
 iesim;
end.