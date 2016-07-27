{$A-,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-}
{$M 1024,0,0}
program hotul;
uses dos;
type vector=record
             segm,offs: word;
            end;
     imgbuf=array[1..64000] of char;
     antbuf=array[1..8] of char;
     mvpal=array[0..255] of array[1..3] of byte;
var img: ^imgbuf;
    pal: mvpal;
    antet: antbuf;
    prim9,old9,old21,old5,old1c: pointer;
    oldv9,oldv21,oldv5,oldv1c: vector;
    f: file;
    s: string[12];
    w: word;
    x: integer;
    rg: registers;
    nr: longint;

procedure FreePSP; assembler;
asm
   mov  ah, $49
   mov  bx, PrefixSEG
   mov  es, bx
   mov  bx, es:[$2c]
   mov  es, bx
   int  $21
end;

procedure FreePROG; assembler;
asm
   mov  ah, $49
   mov  bx, PrefixSEG
   mov  es, bx
   int  $21
end;

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

procedure int5; interrupt;
var vmode: byte;
    r,g,b: byte;
begin
 rg.ah:=$0f;
 intr($10,rg);
 vmode:=rg.al;
 nr:=nr+1;
 if nr>100000 then nr:=100000;
 str(nr:6,s);
 for w:=1 to length(s) do
 if s[w]=' ' then s[w]:='0';
 s:=s+'ms.mhp';
{ if vmode=$13 then }{320x200x256}
 begin
  assign(f,'c:\'+s);
  rewrite(f,1);
  s:='MHP6';
  move(s[1],antet[1],4);
  w:=320;
  move(w,antet[5],2);
  w:=200;
  move(w,antet[7],2);
  blockwrite(f,antet,8,w);
  for x:=0 to 255 do
  begin
   port[$3c7]:=x;
   pal[x][1]:=port[$3c9];
   pal[x][2]:=port[$3c9];
   pal[x][3]:=port[$3c9];
  end;
  blockwrite(f,pal,768,w);
  img:=ptr($A000,0);
  blockwrite(f,img^,64000,w);
  close(f);
 end;
end;

procedure int9; interrupt;
begin
 if port[$60]=55 then
 begin
  meml[0:$09*4]:=longint(prim9);
  intr($9,rg);
  meml[0:$09*4]:=longint(@int9);
  port[$20]:=$20;
 end;
 asm
  push oldv9.segm
  push oldv9.offs
 end;
 callvechi;
end;

procedure int1c; interrupt;
begin
{ if port[$60]=55 then
 begin
  meml[0:$09*4]:=longint(prim9);
  intr($9,rg);
  meml[0:$09*4]:=longint(@int9);
  port[$20]:=$20;
 end;}
 if port[60]=88 then
 begin
  setintvec($5,old5);
  setintvec($9,old9);
  setintvec($1c,old1c);
  setintvec($21,old21);
  freeprog;
  port[$20]:=$20;
  exit;
 end;
 asm
  push oldv1c.segm
  push oldv1c.offs
 end;
 callvechi;
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
  mov [bp+16],ax
  mov [bp+14],bx
  mov [bp+12],cx
  mov [bp+10],dx
  mov [bp+8],si
  mov [bp+6],di
  mov [bp+4],ds
  mov [bp+2],es
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
 if rax=$3509 then
 begin
  execut:=false;
  res:=oldv9.segm;
  rbx:=oldv9.offs;
 end;
 if rax=$2509 then
 begin
  execut:=false;
  oldv9.segm:=rds;
  oldv9.offs:=rdx;
  old9:=ptr(oldv9.segm,oldv9.offs);
 end;
 if rax=$351c then
 begin
  execut:=false;
  res:=oldv1c.segm;
  rbx:=oldv1c.offs;
 end;
 if rax=$251c then
 begin
  execut:=false;
  oldv1c.segm:=rds;
  oldv1c.offs:=rdx;
  old1c:=ptr(oldv1c.segm,oldv1c.offs);
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
 end;
end;

begin
 getintvec($5,old5);
 getintvec($9,old9);
 getintvec($9,prim9);
 getintvec($1c,old1c);
 getintvec($21,old21);
 oldv5.segm:=seg(old5^);
 oldv5.offs:=ofs(old5^);
 oldv9.segm:=seg(old9^);
 oldv9.offs:=ofs(old9^);
 oldv1c.segm:=seg(old1c^);
 oldv1c.offs:=ofs(old1c^);
 oldv21.segm:=seg(old21^);
 oldv21.offs:=ofs(old21^);
 setintvec($5,@int5);
 setintvec($9,@int9);
 setintvec($1c,@int1c);
 setintvec($21,@int21);
 writeln('MSoft hotul de imagini!');
 writeln('Program pentru modul real DOS!');
 writeln('Imaginile vor fi "furate" la 320x200x256 in format MHP.');
 freepsp;
 keep(0);
end.