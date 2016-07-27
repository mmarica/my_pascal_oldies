{$A-,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-}
{$M 1024,0,0}
{ACTIUNE 0=nimic
         1=creeaza alt fisier
         2=scrie frame-uri in fisier
         3=inchide fisierul}
program filmtsr;
uses dos;
type vector=record
      segm,offs: word;
     end;
     antbuf=array[1..8] of char;
     mvpal=array[0..255] of array[1..3] of byte;
     imgbuf=array[1..64000] of byte;
var oldv8,oldv21,oldv65: vector;
    antet: antbuf;
    pal: mvpal;
    img: ^imgbuf;
    f: file;
    s: string[64];
    w: word;
    p65,p21,old8,old21,old65: pointer;
    r: registers;
    actiune,indos: byte;
    nr: longint;
    sg,os: word;
    x: integer;
    schimbate,inmemorie: boolean;

procedure callvechi; assembler;
asm
   push  bp
   mov   bp, sp
   mov   ax, [bp+6]
   mov   bx, [bp+4]
   pop   bp
   mov   sp, bp
   xchg  ax, [bp+$10]
   xchg  bx, [bp+$0E]
   pop   bp
   pop   es
   pop   ds
   pop   di
   pop   si
   pop   dx
   pop   cx
   retf
end;

procedure freepsp; assembler;
asm
   mov ah,$49
   mov bx,prefixseg
   mov es,bx
   mov bx,es:[$2c]
   mov es,bx
   int $21
end;

procedure freeprog; assembler;
asm
   mov ah,$49
   mov bx,prefixseg
   mov es,bx
   int $21
end;

procedure int8; interrupt;
begin
 port[$20]:=$20;
 port[$A0]:=$20;
 port[$21]:=port[$21]or(1 shl 0);
 port[$A1]:=port[$A1]or(1 shl 0);
 indos:=mem[sg:os];
 if port[$60]=88 then
 begin
  repeat
  until port[$60]<>88;
  if actiune=0 then actiune:=1;
  if actiune=2 then actiune:=3;
 end;
 if indos<1 then
 begin
  if actiune=1 then
  begin
   nr:=nr+1;
   if nr>999999 then nr:=999999;
   str(nr:6,s);
   for w:=1 to length(s) do
   if s[w]=' ' then s[w]:='0';
   s:='c:\'+s+'MS.MFP';
   assign(f,s);
   x:=ioresult;
   rewrite(f,1);
   x:=ioresult;
   if x<>0 then actiune:=0;
   antet[1]:='M';antet[2]:='F';antet[3]:='P';antet[4]:='6';
   w:=320;
   move(w,antet[5],2);
   w:=200;
   move(w,antet[7],2);
   blockwrite(f,antet,8,w);
   x:=ioresult;
   if (x<>0)or(w<8) then
   begin
    close(f);
    x:=ioresult;
    erase(f);
    x:=ioresult;
    actiune:=0;
   end;
   actiune:=2;
  end;
  if actiune=2 then
  begin
   for w:=0 to 255 do
   begin
    port[$3c7]:=w;
    pal[w][1]:=port[$3c9];
    pal[w][2]:=port[$3c9];
    pal[w][3]:=port[$3c9];
   end;
   blockwrite(f,pal,768,w);
   x:=ioresult;
   if (w<768)or(x<>0) then
   begin
    actiune:=0;
    close(f);
    x:=ioresult;
   end;
   blockwrite(f,img^,64000,w);
   x:=ioresult;
   if (w<64000)or(x<>0) then
   begin
    actiune:=0;
    seek(f,filepos(f)-768);
    x:=ioresult;
    truncate(f);
    x:=ioresult;
    close(f);
    x:=ioresult;
   end;
  end;
  if actiune=3 then
  begin
   close(f);
   x:=ioresult;
   actiune:=0;
  end;
 end;
 port[$21]:=port[$21]and(not(1 shl 0));
 port[$A1]:=port[$A1]and(not(1 shl 0));
 asm
  push oldv8.segm
  push oldv8.offs
 end;
 callvechi;
end;

procedure int21; interrupt;
var rax,rbx,rcx,rdx,res,rds,rsi,rdi: word;
    vax,vbx,vcx,vdx,ves,vds,vsi,vdi: word;
    execut: boolean;
begin
 asm
  mov vax,ax
  mov vbx,bx
  mov vcx,cx
  mov vdx,dx
  mov ves,es
  mov vds,ds
  mov vsi,si
  mov vdi,di
  mov ax,[bp+16]
  mov bx,[bp+14]
  mov cx,[bp+12]
  mov dx,[bp+10]
  mov si,[bp+8]
  mov di,[bp+6]
  mov ds,[bp+4]
  mov es,[bp+2]
  mov rax,ax
  mov rbx,bx
  mov rcx,cx
  mov rdx,dx
  mov res,es
  mov rds,ds
  mov rsi,si
  mov rdi,di
  mov ax,vax
  mov bx,vbx
  mov cx,vcx
  mov dx,vdx
  mov es,ves
  mov ds,vds
  mov si,vsi
  mov di,vdi
 end;
 execut:=true;
 if rax=$3508 then
 begin
  execut:=false;
  res:=oldv8.segm;
  rbx:=oldv8.offs;
 end;
 if rax=$2508 then
 begin
  execut:=false;
  oldv8.segm:=rds;
  oldv8.offs:=rdx;
  old8:=ptr(oldv8.segm,oldv8.offs);
 end;
 if execut then
 begin
  asm
   push oldv21.segm
   push oldv21.offs
  end;
  callvechi;
 end;
 asm
  mov ax,rax
  mov bx,rbx
  mov cx,rcx
  mov dx,rdx
  mov es,res
  mov ds,rds
  mov si,rsi
  mov di,rdi
  mov [bp+16],ax
  mov [bp+14],bx
  mov [bp+12],cx
  mov [bp+10],dx
  mov [bp+8],si
  mov [bp+6],di
  mov [bp+4],ds
  mov [bp+2],es
  mov ax,vax
  mov bx,vbx
  mov cx,vcx
  mov dx,vdx
  mov es,ves
  mov ds,vds
  mov si,vsi
  mov di,vdi
 end;
end;

procedure int65; interrupt;
var rax,rbx,rcx,rdx,res,rds,rsi,rdi: word;
    vax,vbx,vcx,vdx,ves,vds,vsi,vdi: word;

procedure verificschimbate;
begin
 schimbate:=false;
 getintvec($21,p21);
 getintvec($65,p65);
 if (p21<>@int21)or(p65<>@int65) then
 schimbate:=true;
end;

begin
 asm
  mov vax,ax
  mov vbx,bx
  mov vcx,cx
  mov vdx,dx
  mov ves,es
  mov vds,ds
  mov vsi,si
  mov vdi,di
  mov ax,[bp+16]
  mov bx,[bp+14]
  mov cx,[bp+12]
  mov dx,[bp+10]
  mov si,[bp+8]
  mov di,[bp+6]
  mov ds,[bp+4]
  mov es,[bp+2]
  mov rax,ax
  mov rbx,bx
  mov rcx,cx
  mov rdx,dx
  mov res,es
  mov rds,ds
  mov rsi,si
  mov rdi,di
  mov ax,vax
  mov bx,vbx
  mov cx,vcx
  mov dx,vdx
  mov es,ves
  mov ds,vds
  mov si,vsi
  mov di,vdi
 end;
 if(rax=$FF00)and(rbx=$00FF) then {prezenta in memorie}
 begin
  rax:=$00FF;
  rbx:=$FF00;
 end;
 if(rax=$FFFF)and(rbx=$EEEE) then {intoarce numarul de filme create}
 begin
  rax:=nr;
 end;
 if(rax=$DDEE)and(rbx=$AABB) then {eliberarea memoriei ocupate de TSR}
 begin
  verificschimbate;
  if schimbate then
  rax:=$FFFF else
  begin
   rax:=$00FF;
   setintvec($21,old21);
   setintvec($65,old65);
   setintvec($8,old8);
   freepsp;
   freeprog;
  end;
 end;
 asm
  mov ax,rax
  mov bx,rbx
  mov cx,rcx
  mov dx,rdx
  mov es,res
  mov ds,rds
  mov si,rsi
  mov di,rdi
  mov [bp+16],ax
  mov [bp+14],bx
  mov [bp+12],cx
  mov [bp+10],dx
  mov [bp+8],si
  mov [bp+6],di
  mov [bp+4],ds
  mov [bp+2],es
  mov ax,vax
  mov bx,vbx
  mov cx,vcx
  mov dx,vdx
  mov es,ves
  mov ds,vds
  mov si,vsi
  mov di,vdi
 end;
end;

procedure verificinmemorie;
begin
 inmemorie:=false;
 if old65<>nil then
 begin
  r.ax:=$FF00;
  r.bx:=$00FF;
  intr($65,r);
  if (r.ax=$00FF)and(r.bx=$FF00) then inmemorie:=true;
 end;
end;

begin
 r.ah:=$34;
 intr($21,r);
 sg:=r.es;
 os:=r.bx;
 img:=ptr(sega000,0);
 getintvec($8,old8);
 getintvec($21,old21);
 getintvec($65,old65);
 oldv8.segm:=seg(old8^);
 oldv8.offs:=ofs(old8^);
 oldv21.segm:=seg(old21^);
 oldv21.offs:=ofs(old21^);
 oldv65.segm:=seg(old65^);
 oldv65.offs:=ofs(old65^);
 verificinmemorie;
 s:=paramstr(1);
 for x:=1 to length(s) do
 s[x]:=upcase(s[x]);
 if s='OFF' then
 begin
  if not inmemorie then
  begin
   writeln('FILMTSR nu este deja prezent in memorie.');
   halt;
  end;
  r.ax:=$DDEE;
  r.bx:=$AABB;
  intr($65,r);
  if r.ax=$FFFF then
  begin
   writeln('FILMTSR nu poate fi scos din memorie deoarece a fost schimbata una din');
   writeln('intreruperile 21H si 65H!');
   halt;
  end;
  if r.ax=$00FF then
  begin
   writeln('FILMTSR a fost eliberat din memorie.');
   halt;
  end;
 end;
 if inmemorie then
 begin
  r.ax:=$FFFF;
  r.bx:=$EEEE;
  intr($65,r);
  nr:=r.ax;
  writeln('FILMTSR este deja in memorie si a inregistrat deja ',nr,' filme.');
  halt;
 end;
 setintvec($8,@int8);
 setintvec($21,@int21);
 setintvec($65,@int65);
 writeln('MSoft - camera de filmat - instalat!');
 writeln('Acest program inregistreaza sub forma de film MFP tot ce faceti.');
 writeln('Puteti sa inregistrati oricand, dar pentru a se vedea ceva in inregistrare');
 writeln('trebuie sa va aflati in modul video 320x200x256. E posibil ca in cazul');
 writeln('in care incarcati TSR-ul in DOS si vreti sa inregistrati o aplicatie FULL');
 writeln('SCREEN de Windows, sa nu iasa nimic in MFP.');
 writeln('Fisierele rezultate cu extensia MFP se vor afla in radacina discului C:');
 writeln('Activarea si dezactivarea se face cu F12.');
 writeln('Eliberarea memoriei ocupate de TSR se face cu comanda FILMTSR OFF.');
{ freepsp;}
 keep(0);
end.