{$A+,B-,D+,E+,F+,G+,I+,L+,N-,O+,P+,Q+,R+,S+,T-,V+,X+}
{$M 16384,0,0}
program masina;
uses mhmatem,mhgraf,mtast,dos,mvbutil,getpal1;
type vectormasina=record
                   fatax,fatay,spatex,spatey: integer;
                   mijlocrotifatax,mijlocrotifatay: integer;
                   mijlocrotispatex,mijlocrotispatey: integer;
                   roatafatastangax,roatafatastangay: integer;
                   roatafatadreaptax,roatafatadreaptay: integer;
                   roataspatestangax,roataspatestangay: integer;
                   roataspatedreaptax,roataspatedreaptay: integer;
                   un,ur,xp,yp,viteza: real;
                   lm,lrf,lrs: integer;
                  end;
var a,b,c,d: ^ecran;
    ex,ey,x,y: integer;
    oldexit: pointer;
    nom: boolean;
    coss,sins: array[1..360] of real;
    mparam: vectormasina;
    lmaxx,lmaxy,lminx,lminy: integer;
    gata: boolean;
    ctm,ct1: integer;
    p1c: pointer;

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
begin
 exitproc:=oldexit;
 setintvec($1c,p1c);
 closegr;
 if nom then writeln('Memorie insuficienta!');
end;

procedure calcule;
begin
 with mparam do
 begin
  xp:=xp-viteza*cosv(round(un+90+ur));
  yp:=yp-viteza*sinv(round(un+90+ur));
  un:=un+viteza*ur/30;
  fatax:=round(xp-(lm+4)*cosv(round(un+90)));
  fatay:=round(yp-(lm+4)*sinv(round(un+90)));
  spatex:=round(xp+(lm+4)*cosv(round(un+90)));
  spatey:=round(yp+(lm+4)*sinv(round(un+90)));
  mijlocrotifatax:=round(xp-lm*cosv(round(un+90)));
  mijlocrotifatay:=round(yp-lm*sinv(round(un+90)));
  roatafatastangax:=round(mijlocrotifatax+lrf*cosv(round(un+ur)));
  roatafatastangay:=round(mijlocrotifatay+lrf*sinv(round(un+ur)));
  roatafatadreaptax:=round(mijlocrotifatax-lrf*cosv(round(un+ur)));
  roatafatadreaptay:=round(mijlocrotifatay-lrf*sinv(round(un+ur)));
  mijlocrotispatex:=round(xp+lm*cosv(round(un+90)));
  mijlocrotispatey:=round(yp+lm*sinv(round(un+90)));
  roataspatestangax:=round(mijlocrotispatex-lrs*cosv(round(un)));
  roataspatestangay:=round(mijlocrotispatey-lrs*sinv(round(un)));
  roataspatedreaptax:=round(mijlocrotispatex+lrs*cosv(round(un)));
  roataspatedreaptay:=round(mijlocrotispatey+lrs*sinv(round(un)));
 end;
end;

procedure desenlinii;
begin
 scolor(32*4+31);
 with mparam do
 begin
  linie(b,fatax,fatay,spatex,spatey);
  linie(b,roatafatastangax,roatafatastangay,roatafatadreaptax,roatafatadreaptay);
  linie(b,roataspatestangax,roataspatestangay,roataspatedreaptax,roataspatedreaptay);
 end;
end;

procedure desentextura;
var dxx,dxy: integer;
begin
 with mparam do
 begin
  for x:=0 to fatax-spatex do
  begin
   b^[round(fatay+x*(fatay-yp)/(fatax-xp)),round(fatax+x)]:=d^[(fatay-spatey)div x,(fatay-spatey)div x];
  end;
 end;
end;

procedure crescinx(cx: integer);
begin
 with mparam do
 begin
  xp:=xp+cx;
  fatax:=fatax+cx;
  spatex:=spatex+cx;
  mijlocrotifatax:=mijlocrotifatax+cx;
  mijlocrotispatex:=mijlocrotispatex+cx;
  roatafatastangax:=roatafatastangax+cx;
  roatafatadreaptax:=roatafatadreaptax+cx;
  roataspatestangax:=roataspatestangax+cx;
  roataspatedreaptax:=roataspatedreaptax+cx;
 end;
end;

procedure cresciny(cy: integer);
begin
 with mparam do
 begin
  yp:=yp+cy;
  fatay:=fatay+cy;
  spatey:=spatey+cy;
  mijlocrotifatay:=mijlocrotifatay+cy;
  mijlocrotispatey:=mijlocrotispatey+cy;
  roatafatastangay:=roatafatastangay+cy;
  roatafatadreaptay:=roatafatadreaptay+cy;
  roataspatestangay:=roataspatestangay+cy;
  roataspatedreaptay:=roataspatedreaptay+cy;
 end;
end;

begin
 getintvec($1c,p1c);
 lmaxx:=319;
 lmaxy:=199;
 lminx:=0;
 lminy:=0;
 mv:=3;
 oldexit:=exitproc;
 exitproc:=@myexit;
 a:=ptr($A000,0);
 b:=ptr(mhmemaloc(64000),0);
 if eraloc<>eranimic then
 begin
  nom:=true;
  halt;
 end;
 c:=ptr(mhmemaloc(64000),0);
 if eraloc<>eranimic then
 begin
  nom:=true;
  halt;
 end;
{ d:=ptr(mhmemaloc(64000),0);
 if eraloc<>eranimic then
 begin
  nom:=true;
  halt;
 end;}
 clearbuf(c,32*2+31);
{ clearbuf(d,32*5+31);}
 initcossin;
 initgr;
 setpal(normpal1);
 with mparam do
 begin
  xp:=159;
  yp:=99;
  lm:=10;
  lrf:=6;
  lrs:=8;
  un:=0;
  ur:=0;
 end;
 initscankey;
 setintvec($1c,@int1c);
 ctm:=1;
 ct1:=0;
 repeat
  with mparam do
  begin
   b^:=c^;
   if key[tsstanga] then ur:=ur-4;
   if key[tsdreapta] then ur:=ur+4;
   if ur>30 then ur:=30;
   if ur<-30 then ur:=-30;
   if key[tssus] then
   begin
    viteza:=viteza+2;
    if viteza>10 then viteza:=10;
   end else
   if key[tsjos] then
   begin
    viteza:=viteza-2;
    if viteza<-10 then viteza:=-10;
   end else
   begin
    if viteza>0 then
    begin
     viteza:=viteza-1;
     if viteza<0 then viteza:=0;
    end;
    if viteza<0 then
    begin
     viteza:=viteza+1;
     if viteza>0 then viteza:=0;
    end;
   end;
   calcule;
   if fatax<lminx then
   crescinx(lminx-fatax);
   if fatay<lminy then
   cresciny(lminy-fatay);
   if spatex<lminx then
   crescinx(lminx-spatex);
   if spatey<lminy then
   cresciny(lminy-spatey);
   if roatafatastangax<lminx then
   crescinx(lminx-roatafatastangax);
   if roatafatastangay<lminy then
   cresciny(lminy-roatafatastangay);
   if roatafatadreaptax<lminx then
   crescinx(lminx-roatafatadreaptax);
   if roatafatadreaptay<lminy then
   cresciny(lminy-roatafatadreaptay);
   if roataspatestangax<lminx then
   crescinx(lminx-roataspatestangax);
   if roataspatestangay<lminy then
   cresciny(lminy-roataspatestangay);
   if roataspatedreaptax<lminx then
   crescinx(lminx-roataspatedreaptax);
   if roataspatedreaptay<lminy then
   cresciny(lminy-roataspatedreaptay);
   if fatax>lmaxx then
   crescinx(lmaxx-fatax);
   if fatay>lmaxy then
   cresciny(lmaxy-fatay);
   if spatex>lmaxx then
   crescinx(lmaxx-spatex);
   if spatey>lmaxy then
   cresciny(lmaxy-spatey);
   if roatafatastangax>lmaxx then
   crescinx(lmaxx-roatafatastangax);
   if roatafatastangay>lmaxy then
   cresciny(lmaxy-roatafatastangay);
   if roatafatadreaptax>lmaxx then
   crescinx(lmaxx-roatafatadreaptax);
   if roatafatadreaptay>lmaxy then
   cresciny(lmaxy-roatafatadreaptay);
   if roataspatestangax>lmaxx then
   crescinx(lmaxx-roataspatestangax);
   if roataspatestangay>lmaxy then
   cresciny(lmaxy-roataspatestangay);
   if roataspatedreaptax>lmaxx then
   crescinx(lmaxx-roataspatedreaptax);
   if roataspatedreaptay>lmaxy then
   cresciny(lmaxy-roataspatedreaptay);
   desenlinii;
   a^:=b^;
  end;
  repeat
  until gata;
  gata:=false;
 until key[tsesc];
 disabscankey;
 closegr;
 mhmemdealoc(seg(b));
 mhmemdealoc(seg(c));
end.