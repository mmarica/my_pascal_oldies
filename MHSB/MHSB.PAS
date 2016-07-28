{$A+,B-,D+,E+,F+,G+,I+,L+,N-,O+,P+,Q+,R+,S+,T-,V+,X+}
{$M 16384,0,0}
program mhsb;
uses mhmatem,dos,mtast,mhpal,mhmem,mhimg,tpkey;
type block=record
            invincibil: boolean;
            viata: byte;
            tip: byte;
            pozx,pozy: integer;
            bonus: byte;
           end;
var a,b,c,d: ^ecran;
    x,y,z,t: integer;
    p1c,exitvechi: pointer;
    gata: boolean;
    ct1,ctm: integer;
    blx,bly,pdx,pdy: real;
    mpx,mpy,miscmax,miscpad,miscbx,miscby: integer;
    pdmarx,pdmary,marbx,marby: integer;
    tempval: real;
    paddir,bdirx,bdiry,bvit,rap: byte;
    resetare,nomem,terminat,mort: boolean;
    locminx,locminy,locmaxx,locmaxy: integer;
    tempstr: string;
    patrate: array[1..100] of block;
    nrblock: byte;
    f: file;
    w: word;
    vieti: byte;
    estetext: boolean;
    valtext,nrpuncte,contortext,maxpuncte: integer;
    textvect: array[1..4000] of record
                                x,y: integer;
                                dir: byte;
                                este: boolean;
                                viteza: integer;
                               end;
    stringtext: string;
    pozitietext,lungimetext: integer;

procedure elimintext;
begin
 estetext:=false;
 fillchar(textvect,sizeof(textvect),0);
end;

procedure inserttext(s: string;sec: byte);
begin
 contortext:=18*sec;
 nrpuncte:=0;
 estetext:=true;
 stringtext:=s;
 lungimetext:=length(s);
 pozitietext:=159-8*lungimetext-8;
 for z:=1 to lungimetext do
 for x:=0 to 7 do
 for y:=0 to 13 do
 if textbool1^[ord(s[z]),y,x] then
 if nrpuncte<maxpuncte then
 begin
  nrpuncte:=nrpuncte+1;
  textvect[nrpuncte].x:=pozitietext+z*16+x*2;
  textvect[nrpuncte].y:=80+y*2;
  textvect[nrpuncte].dir:=random(4);
  textvect[nrpuncte].este:=true;
  textvect[nrpuncte].viteza:=3+random(10);
 end;
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

procedure afiseztext(p: pointer);
var f: ^ecran;
    culoaretext,tempval: integer;
    fv: byte;
begin
 fv:=fcl;
 culoaretext:=32*4+31;
 fcl:=culoaretext;
 valtext:=valtext+10;
 if valtext>360 then valtext:=valtext-360;
 f:=p;
 for x:=1 to nrpuncte do
 if textvect[x].este then
 begin
  if contortext<1 then
  bara(f,textvect[x].x,textvect[x].y,textvect[x].x+1,textvect[x].y+1);
  if contortext>0 then
  begin
   tempval:=textvect[x].x mod 36*10+valtext;
   tempval:=round(5*cosv(tempval));
   bara(f,textvect[x].x,textvect[x].y+tempval,textvect[x].x+1,textvect[x].y+1+tempval);
  end;
 end;
 fcl:=fv;
end;

procedure resetareminge;
begin
 resetare:=true;
 pdx:=149;pdy:=170;
 blx:=149;bly:=159;
 bdirx:=1;
 bdiry:=0;
 rap:=60;
 bvit:=10;
 pdmarx:=20;
 pdmary:=2;
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

function unadintoate(dincate,total: integer): real;
begin
 if (dincate<1)or(total<1) then
 begin
  unadintoate:=0;
  exit;
 end;
 unadintoate:=total/dincate;
end;

procedure nom;
begin
 nomem:=true;
 halt;
end;

procedure exitnou;
var eroare: integer;
    adresa: pointer;
begin
 exitproc:=exitvechi;
 setintvec($1c,p1c);
 mhmemdealoc(seg(b^));
 mhmemdealoc(seg(c^));
 mhmemdealoc(seg(d^));
 eroare:=exitcode;
 adresa:=erroraddr;
 writeln('MSoft - Super Ball!');
 if nomem then writeln('Nu e destula memorie!');
 if eroare<>0 then
 begin
  closegr;
  writeln('MSoft - Super Ball!');
  writeln('Eroare: ',eroare:5,', la adresa: ',conv(seg(adresa^)),':',
  conv(ofs(adresa^)),'!');
 end;
end;

procedure aratamort;
begin
 ctm:=1;
 inserttext('Ai murit! Ha ha ha!',1);
 repeat
  clearbuf(b,0);
  repeat
  until gata;
  gata:=false;
  misctext;
  afiseztext(b);
  a^:=b^;
 until not maiestetext;
 elimintext;
end;

procedure verificstare;
var tempval: integer;
begin
 if pdx<locminx+pdmarx then
 begin
  pdx:=locminx+pdmarx;
  paddir:=2;
 end;
 if pdx>locmaxx-pdmarx then
 begin
  pdx:=locmaxx-pdmarx;
  paddir:=2;
 end;
 if not resetare then
 begin
  if blx<locminx+marbx then
  begin
   if bdirx=0 then
   begin
    bdirx:=1;
    blx:=locminx+marbx+1;
   end;
  end;
  if blx>locmaxx-marbx then
  begin
   if bdirx=1 then
   begin
    bdirx:=0;
    blx:=locmaxx-marbx-1;
   end;
  end;
  if bly<locminy+marby then
  begin
   if bdiry=0 then
   begin
    bdiry:=1;
    bly:=locminy+marby+1;
   end;
  end;
  if bly>locmaxy-marby then
  begin
   if bdiry=1 then
   begin
    bdiry:=0;
    bly:=locmaxy-marby;
   end;
   vieti:=vieti-1;
   resetareminge;
  end;
  if (bly+marby>=pdy-pdmary)and(bly-marby<=pdy+pdmary)and
  (blx+marbx>=pdx-pdmarx)and(blx-marbx<=pdx+pdmarx) then
  begin
   if bdiry=1 then
   begin
    if bdirx=1 then
    begin
    end;
   end;
   if bdiry=0 then
   begin
    if bdirx=1 then
    begin
     if (blx-marbx<pdx) then
     begin
      tempval:=round(pdx-blx);
      bdirx:=0;
      if tempval<0 then tempval:=0;
      tempval:=trunc(tempval*4/pdmarx)+1;
      rap:=tempval*15;
     end;
     bdiry:=1;
    end;
    if bdirx=0 then
    begin
     if (blx+marbx>pdx) then
     begin
      tempval:=round(blx-pdx);
       bdirx:=1;
      if tempval<0 then tempval:=0;
      tempval:=trunc(tempval*4/pdmarx)+1;
      rap:=tempval*15;
     end;
     bdiry:=1;
    end;
   end;
  end;
 end else
 if x mod 10=0 then
 if resetare then
 begin
  if bdirx=1 then
  begin
   blx:=blx+1;
   if blx>locmaxx-marbx then
   begin
    blx:=locmaxx-marbx-1;
    bdirx:=0;
   end;
  end else
  begin
   blx:=blx-1;
   if blx<locminx+marbx then
   begin
    blx:=locminx+marbx+1;
    bdirx:=1;
   end;
  end;
  bly:=155;
 end;
 for y:=1 to nrblock do
 with patrate[y] do
 if viata>0 then
 if (bly+marby>=pozy-1+locminy)and(bly-marby<=pozy+2+locminy)and
 (blx+marbx>=pozx-9+locminx)and(blx-marbx<=pozx+10+locminx) then
 begin
  if bdiry=0 then
  begin
   bdiry:=1;
   if not invincibil then viata:=viata-1;
  end else
  {if bdiry=1}
  begin
   bdiry:=0;
   if not invincibil then viata:=viata-1;
  end;
  if bdirx=0 then
  if blx+marbx>=pozx+9+locminx then
  bdirx:=1;
  if bdirx=1 then
  if blx+marbx<=pozx-8+locminx then
  bdirx:=0;
  if (bly+marby>=pozy+locminy)and(bly+marby<=pozy+locminy+1) then
  begin
   if bdiry=0 then bdiry:=1 else bdiry:=1;
  end;
 end;
 if vieti<=0 then mort:=true;
end;

procedure joc;
var tbx,tby: integer;
begin
 vieti:=1;
 locminx:=11;
 locminy:=30;
 locmaxx:=250;
 locmaxy:=180;
 ctm:=1;
 marbx:=1;
 marby:=1;
 mort:=false;
 resetareminge;
 nrblock:=12;
 for x:=1 to nrblock do
 begin
  patrate[x].pozx:=(x-1)*20+9;
  patrate[x].pozy:=0;
  patrate[x].invincibil:=false;
  patrate[x].tip:=random(6);
  patrate[x].viata:=patrate[x].tip+1;
  patrate[x].bonus:=0;
  if patrate[x].tip=5 then
  begin
   patrate[x].invincibil:=true;
  end;
 end;
 repeat
  miscpad:=0;
  miscmax:=30;
  repeat
   if key[tsspace] then
   begin
    resetare:=false;
    rap:=60;
    bdiry:=0;
   end;
   if key[tsstanga] then
   begin
    miscpad:=10;
    paddir:=0;
   end;
   if key[tsdreapta] then
   begin
    miscpad:=10;
    paddir:=1;
   end;
  until gata;
  gata:=false;
  tbx:=trunc(rap/100*bvit);
  tby:=trunc((100-rap)/100*bvit);
  for x:=1 to miscmax do
  begin
   tempval:=unadintoate(miscmax,miscpad);
   if paddir=0 then pdx:=pdx-tempval;
   if paddir=1 then pdx:=pdx+tempval;
   tempval:=unadintoate(miscmax,tbx);
   if bdirx=0 then blx:=blx-tempval;
   if bdirx=1 then blx:=blx+tempval;
   tempval:=unadintoate(miscmax,tby);
   if bdiry=0 then bly:=bly-tempval;
   if bdiry=1 then bly:=bly+tempval;
   verificstare;
  end;
  terminat:=true;
  for x:=1 to nrblock do
  begin
   if (patrate[x].viata>0)and(not patrate[x].invincibil) then terminat:=false;
  end;
  clearbuf(b,0);
  fcolor(32*4+31);
  scolor(32*4+25);
  baram(b,round(pdx-pdmarx),round(pdy-pdmary),round(pdx+pdmarx),
  round(pdy+pdmary));
  fcolor(32*7+31);
  scolor(32*4+31);
  elipsam(b,round(blx),round(bly),marbx,marby);
  scolor(32*1+31);
  dreptunghi(b,locminx-1,locminy-1,locmaxx+1,locmaxy+1);
  for x:=1 to nrblock do
  with patrate[x] do
  if viata>0 then
  begin
   if not invincibil then
   copymvb(c,b,0+20*(tip+1-viata),5*tip,19+20*(tip+1-viata),5*tip+4,locminx+pozx-9,locminy+pozy) else
   copymvb(c,b,0,25,19,29,locminx+pozx-9,locminy+pozy);
  end;
  scolor(32*2+31);
  str(rap:2,tempstr);
  for x:=1 to 2 do
  if tempstr[x]=' ' then tempstr:='0';
  tempstr:=tempstr+'%';
  tempstr:='O/V '+tempstr;
  mvtextxy2(b,260,170,tempstr);
  str(vieti,tempstr);
  for x:=1 to 2 do
  if tempstr[x]=' ' then tempstr:='0';
  tempstr:='Vieti '+tempstr;
  mvtextxy2(b,260,155,tempstr);
  a^:=b^;
  if key[tsesc] then mort:=true;
 until mort or terminat;
 if mort then aratamort;
end;

procedure menu;
begin
 joc;
end;

begin
 maxpuncte:=4000;
 getintvec($1c,p1c);
 a:=ptr($A000,0);
 b:=ptr(mhmemaloc(64000),0);
 if eraloc<eranimic then nom;
 c:=ptr(mhmemaloc(64000),0);
 if eraloc<eranimic then nom;
 d:=ptr(mhmemaloc(64000),0);
 if eraloc<eranimic then nom;
 initgr;
 exitvechi:=exitproc;
 exitproc:=@exitnou;
 setintvec($1c,@int1c);
 setpal(normpal1);
 clearbuf(b,0);
 clearbuf(c,0);
 clearbuf(d,0);
 assign(f,'mhoid.mhb');
 reset(f,1);
 seek(f,8);
 blockread(f,c^,64000,w);
 close(f);
 initscankey;
 menu;
 disabscankey;
 closegr;
 mhmemdealoc(seg(b^));
 mhmemdealoc(seg(c^));
 mhmemdealoc(seg(d^));
end.