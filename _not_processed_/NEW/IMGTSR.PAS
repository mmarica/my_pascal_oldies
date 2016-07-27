{$A-,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-}
{$M 1024,0,0}
program imgtsr;
uses dos;
type vector=record
      segm,offs: word;
     end;
     antbuf=array[1..8] of char;
     mvpal=array[0..255] of array[1..3] of byte;
     imgbuf=array[1..64000] of byte;
var primv8,oldv8,oldv21: vector;
    antet: antbuf;
    pal: mvpal;
    img: ^imgbuf;
    f: file;
    s: string[64];
    w: word;
    prim8,old8,old21: pointer;
    r: registers;
    indos,discheta,prt21,prta1: byte;
    nr,timp: longint;
    sg,os,timpl,timph: word;

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
 timph:=memw[0:$46E];
 timpl:=memw[0:$46C];
 if timpl<65535 then timpl:=timpl+1 else
 timph:=timph+1;
 if (timph>=$18)and(timpl>=$B0) then
 begin
  timph:=0;
  timpl:=0;
  mem[0:$470]:=1;
 end;
 memw[0:$46E]:=timph;
 memw[0:$46C]:=timpl;
 discheta:=mem[0:$440];
 if discheta>0 then
 begin
  discheta:=discheta-1;
  if discheta=0 then
  begin
   mem[0:$43F]:=240;
   port[$3F2]:=$0C;
  end;
 end;
 mem[0:$440]:=discheta;
 intr($1c,r);
 if (port[$60]=88)and(indos<1) then
 begin
  nr:=nr+1;
  if nr>100000 then nr:=1;
  str(nr:6,s);
  for w:=1 to length(s) do
  if s[w]=' ' then s[w]:='0';
  s:='c:\'+s+'MH.MHP';
  assign(f,s);
  w:=ioresult;
  rewrite(f,1);
  w:=ioresult;
  if w=0 then
  begin
   antet[1]:='M';antet[2]:='H';antet[3]:='P';antet[4]:='6';
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
   w:=ioresult;
   blockwrite(f,pal,768,w);
   w:=ioresult;
   blockwrite(f,img^,64000,w);
   w:=ioresult;
   close(f);
   w:=ioresult;
  end;
 end;
 port[$21]:=port[$21]and(not(1 shl 0));
 port[$A1]:=port[$A1]and(not(1 shl 0));
end;

procedure int21; interrupt;
var rax,rbx,rcx,rdx,res,rds,rsi,rdi: word;
    vax,vbx,vcx,vdx,ves,vds,vsi,vdi: word;
    rah,ral,rbh,rbl,rch,rcl,rdh,rdl: byte;
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
 rah:=hi(rax);ral:=lo(rax);
 rbh:=hi(rbx);rbl:=lo(rbx);
 rch:=hi(rcx);rcl:=lo(rcx);
 rdh:=hi(rdx);rdl:=lo(rdx);
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

begin
 r.ah:=$34;
 intr($21,r);
 sg:=r.es;
 os:=r.bx;
 img:=ptr(sega000,0);
 prta1:=port[$A1];
 prta1:=prta1 and(not(1 shl 0));
 port[$A1]:=prta1;
 prt21:=port[$21];
 prt21:=prt21 and(not(1 shl 0));
 port[$21]:=prt21;
 getintvec($8,prim8);
 getintvec($8,old8);
 getintvec($21,old21);
 oldv8.segm:=seg(old8^);
 oldv8.offs:=ofs(old8^);
 primv8.segm:=seg(prim8^);
 primv8.offs:=ofs(prim8^);
 oldv21.segm:=seg(old21^);
 oldv21.offs:=ofs(old21^);
 setintvec($8,@int8);
 setintvec($21,@int21);
 writeln('MSoft - hotul de imagini - instalat!');
 freepsp;
 keep(0);
end.