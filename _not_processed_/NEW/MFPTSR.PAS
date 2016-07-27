{$A-,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-}
{$M 1024,0,0}
program mhptsr;
uses dos;
type imgbuf=array[1..64000] of char;
     antbuf=array[1..8] of char;
     mvpal=array[0..255] of array[1..3] of byte;
var img: ^imgbuf;
    pal: mvpal;
    antet: antbuf;
    old1c,old9: pointer;
    deja: boolean;
    f: file;
    s: string[12];
    loc,nr: longint;
    b,vmode: byte;
    w: word;
    r: registers;
    x,y,pozbuf: integer;
    minibuf: array[1..100] of char;

procedure freepsp; assembler;
asm
   mov  ah, $49
   mov  bx, PrefixSEG
   mov  es, bx
   mov  bx, es:[$2c]
   mov  es, bx
   int  $21
end;

procedure scriubyte(ch: byte);
begin
 pozbuf:=pozbuf+1;
 if pozbuf>sizeof(minibuf) then
 begin
  pozbuf:=1;
  blockwrite(f,minibuf,sizeof(minibuf),w);
  b:=ioresult;
 end;
 minibuf[pozbuf]:=chr(ch);
end;

procedure int1c; interrupt;
begin
 asm
  cli
 end;
 port[$20]:=$20;
 if deja then exit;
 deja:=true;
{ if port[$60]=88 then}
 begin
  r.ah:=$0f;
  intr($10,r);
  vmode:=r.al;
  nr:=nr+1;
  if nr>100000 then nr:=100000;
  str(nr:6,s);
  for w:=1 to length(s) do
  if s[w]=' ' then s[w]:='0';
  s:=s+'ms.mhp';
  if vmode=0 then {mod $0D = 320x200x16 culori}
  begin
{   pozbuf:=sizeof(minibuf);
   assign(f,'c:\'+s);
   b:=ioresult;
   rewrite(f,1);
   b:=ioresult;
   s:='MHP6';
   move(s[1],antet[1],4);
   w:=320;
   move(w,antet[5],2);
   w:=200;
   move(w,antet[7],2);
   for w:=0 to 15 do
   begin
    port[$3c7]:=w;
    pal[w][1]:=port[$3c9];
    pal[w][2]:=port[$3c9];
    pal[w][3]:=port[$3c9];
   end;
   blockwrite(f,antet,8,w);
   b:=ioresult;
   blockwrite(f,pal,768,w);
   b:=ioresult;
   loc:=-1;
   for y:=0 to 199 do
   for x:=0 to 319 do
   begin
    if x mod 2=0 then b:=ord(img^[loc])and(not $f)shr 4 else
    begin
     b:=ord(img^[loc])and(not $F0);
     loc:=loc+1;
    end;
    scriubyte(b);
   end;
   blockwrite(f,minibuf,pozbuf-1,w);
   b:=ioresult;
   close(f);
   b:=ioresult;}
  end else
  begin
   close(f);
   assign(f,'c:\'+s);
   b:=ioresult;
   reset(f,1);
   b:=ioresult;
   s:='MHP6';
   move(s[1],antet[1],4);
   w:=320;
   move(w,antet[5],2);
   w:=200;
   move(w,antet[7],2);
   for w:=0 to 255 do
   begin
    port[$3c7]:=w;
    pal[w][1]:=port[$3c9];
    pal[w][2]:=port[$3c9];
    pal[w][3]:=port[$3c9];
   end;
   blockwrite(f,antet,8,w);
   b:=ioresult;
   blockwrite(f,pal,768,w);
   b:=ioresult;
   blockwrite(f,img^,64000,w);
   b:=ioresult;
   close(f);
   b:=ioresult;
  end;
 end;
 deja:=false;
end;

begin
 assign(f,'c:\test.mfp');
 rewrite(f,1);
 img:=ptr(sega000,0);
 getintvec($1c,old1c);
 setintvec($1c,@int1c);
 freepsp;
 keep(0);
end.