.RADIX 16
; constante:
PORT_A    equ  60h        ; adresa port A 8255
PORT_B    equ  61h        ; adresa port B 8255
TIMER     equ  40h        ; adresa port timer 8253

;  Macro-definitie

get_set_vect         MACRO n      ; citeste un vector de intrerupere
   mov  ax,35&n                   ; si scrie in loc unul nou
   int  21
   mov  cs:oldo&n,bx
   mov  cs:olds&n,es
   mov  ax,25&n
   mov  dx,offset newint&n
   int  21
ENDM

cseg  SEGMENT
      ASSUME  cs:cseg
      ORG 2c
env_seg label    word
      ORG 100
start:
      jmp entry

oldvec1c  label    dword
oldo1c    dw       ?
olds1c    dw       ?
oldvec13  label    dword
oldo13    dw       ?
olds13    dw       ?
oldvec09  label    dword
oldo09    dw       ?
olds09    dw       ?
tabela    db       0,0,1,1,1,1,0,0,0,0,0,1,1,0,0,1,1
          db       10 dup(0)
contor    db       0         ; daca < 6 are voie sa cinte
steag     db       1         ; steag=1, are voie sa cinte

newint1c PROC far
   pushf
   call   cs:oldvec1c
   cmp    byte ptr cs:steag,1
   jne    short gata
   inc    cs:contor
   cmp    byte ptr cs:contor,4
   jne    short gata
   push   ax
   in     al,PORT_B
   and    al,0fch
   out    PORT_B,al
   pop    ax
   mov    byte ptr cs:contor,0
gata:
   iret
newint1c ENDP

newint13 PROC far
   cmp    ax,0ff00
   jne    short ok
   xchg   ah,al
   iret
ok:
   cmp    byte ptr cs:steag,1
   jne    short gata2
   push   ax
   push   bx
   lea    bx,tabela
   mov    al,ah
   xlat   tabela
   cmp    al,1
   jne    short gata1

;  construieste sunetul dupa formula empirica (NrSector*16) OR ((NrCap+1)*128)

   push   cx
   push   dx
   and    cl,3f     ; mascheaza bitii de pista
   xor    ch,ch
   mov    bx,cx     ; NrSector in BX
   mov    cl,4
   shl    bx,cl     ; NrSector*16
   xor    dl,dl     ; DX va contine NrCap*256...
   inc    dh        ; ... +256
   shr    dx,1      ; ... /2
   or     bx,dx     ; BX contine frecventa sunetului
   mov    ax,34ddh
   mov    dx,0012
   div    bx
   mov    bx,ax
   in     al,PORT_B
   test   al,3
   jne    short go
   or     al,3
   out    PORT_B,al
   mov    al,0b6
   out    TIMER+3,al
go:
   mov    al,bl
   out    TIMER+2,al
   mov    al,bh
   out    TIMER+2,al
   mov    byte ptr cs:contor,0
   pop    dx
   pop    cx
gata1:
   pop    bx
   pop    ax
gata2:
   jmp    cs:[oldvec13]
newint13 ENDP

newint09 PROC far
   push   ax
   in     al,PORT_A
   cmp    al,46
   jne    short iese
   xor    byte ptr cs:steag,1
   in     al,PORT_B
   and    al,0fc
   out    PORT_B,al
iese:
   pop    ax
   jmp    cs:[oldvec09]
newint09 ENDP

last_adr  label byte
mess      db    "Play installed, press Scroll Lock to commute."
          db    0d,0a,"$"
mess2     db    "Play already installed.",0d,0a,"$"

entry:
   mov    ax,0ff00
   int    13
   cmp    ax,0ff
   jne    short inst
   mov    ah,09
   lea    dx,mess2
   int    21
   mov    ax,4c00
   int    21
inst:
   IRP    int_no,1c,13,09
   get_set_vect   int_no
   ENDM

   lea    dx,cs:mess
   mov    ah,09
   int    21
   mov    es,cs:env_seg
   mov    ah,49
   int    21
   mov    dx,offset cs:last_adr
   mov    cl,4
   shr    dx,cl
   inc    dx
   mov    ax,3100
   int    21
cseg ENDS
     END start
