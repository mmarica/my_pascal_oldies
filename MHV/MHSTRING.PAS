unit mhstring;
interface

procedure eliminlitera(var s: string;poz: longint);
{elimina un caracter dintr-un string la pozitia specificata}
procedure inserezlitera(var s: string;c: char;poz: longint);
{adauga un caracter intr-un string la pozitia specificata}
function nrtost0(nr: longint;nrd: byte): string;
{converteste un numar intreg intr-un string care are la inceput zerouri
atatea cate e nevoie ca sa ajunga la lungimea nrd}
function longtost(l: longint): string;
{converteste un longint intr-un string (hexazecimal)}
function wordtost(w: word): string;
{converteste un word intr-un string (hexazecimal)}
function bytetost(b: byte): string;
{converteste un byte intr-un string (hexazecimal)}
function downcase(c: char): char;
{daca c este 'A'..'Z', atunci il transforma in litera mica}
function upcase(c: char): char;
{daca c este 'a'..'a', atunci il transforma in litera mare}
function downstring(s: string): string;
{transforma tot string-ul in litere mici}
function upstring(s: string): string;
{transforma tot string-ul in litere mari}
function longtozerost(l: longint): string;
{transforma un longint in string cu zerouri in fata ('0000000021')}
function wordtozerost(w: word): string;
{transforma un word in string cu zerouri in fata ('00021','00003')}
function bytetozerost(b: byte): string;
{transforma un byte in string cu zerouri in fata ('001','002')}
function fullstring(nume,ext: string): string;
{transforma numele si extensia intr-un singur string (cu sau fara punct)}
implementation

procedure eliminlitera(var s: string;poz: longint);
var x: integer;
begin
 if (poz<1)or(poz>length(s)) then exit;
 for x:=poz to length(s)-1 do
 s[x]:=s[x+1];
 s[0]:=chr(length(s)-1)
end;

procedure inserezlitera(var s: string;c: char;poz: longint);
var x: integer;
begin
 if (poz<1)or(poz>length(s)+1)or(length(s)>=sizeof(s)) then exit;
 for x:=length(s) downto poz do
 s[x+1]:=s[x];
 s[poz]:=c;
 s[0]:=chr(length(s)+1)
end;

function nrtost0(nr: longint;nrd: byte): string;
var st: string;
    x: integer;
begin
 str(nr:nrd,st);
 for x:=1 to length(st) do
 if st[x]=' ' then st[x]:='0';
 nrtost0:=st;
end;

function longtost(l: longint): string;
const hexchars: array[0..$F]of char='0123456789ABCDEF';
begin
 longtost[1]:=hexchars[hi(l shr 16) shr 4];
 longtost[2]:=hexchars[hi(l shr 16) and $F];
 longtost[3]:=hexchars[lo(l shr 16) shr 4];
 longtost[4]:=hexchars[lo(l shr 16) and $F];
 longtost[5]:=hexchars[hi(l shr 0) shr 4];
 longtost[6]:=hexchars[hi(l shr 0) and $F];
 longtost[7]:=hexchars[lo(l shr 0) shr 4];
 longtost[8]:=hexchars[lo(l shr 0) and $F];
 longtost[0]:=#8;
end;

function wordtost(w: word): string;
const hexchars: array[0..$F]of char='0123456789ABCDEF';
begin
 wordtost[1]:=hexchars[hi(w)shr 4];
 wordtost[2]:=hexchars[hi(w)and $F];
 wordtost[3]:=hexchars[lo(w)shr 4];
 wordtost[4]:=hexchars[lo(w)and $F];
 wordtost[0]:=#4;
end;

function bytetost(b: byte): string;
const hexchars: array[0..$F]of char='0123456789ABCDEF';
begin
 bytetost[1]:=hexchars[b shr 4];
 bytetost[2]:=hexchars[b and $F];
 bytetost[0]:=#2;
end;

function downcase(c: char): char;
var x: integer;
begin
 x:=ord(c);
 if (x<ord('A'))or(x>ord('Z')) then downcase:=c else
 begin
  x:=x-ord('A');
  downcase:=chr(x+ord('a'));
 end;
end;

function upcase(c: char): char;
var x: integer;
begin
 x:=ord(c);
 if (x<ord('a'))or(x>ord('z')) then upcase:=c else
 begin
  x:=x-ord('a');
  upcase:=chr(x+ord('A'));
 end;
end;

function downstring(s: string): string;
var x: integer;
begin
 for x:=1 to length(s) do
 downstring[x]:=downcase(s[x]);
 downstring[0]:=s[0];
end;

function upstring(s: string): string;
var x: integer;
begin
 for x:=1 to length(s) do
 upstring[x]:=upcase(s[x]);
 upstring[0]:=s[0];
end;

function longtozerost(l: longint): string;
var s: string[10];
    x: byte;
begin
 str(l:10,s);
 for x:=1 to 10 do
 if s[x]=' ' then s[x]:='0';
 longtozerost:=s;
end;

function wordtozerost(w: word): string;
var s: string[5];
    x: byte;
begin
 str(w:5,s);
 for x:=1 to 5 do
 if s[x]=' ' then s[x]:='0';
 wordtozerost:=s;
end;

function bytetozerost(b: byte): string;
var s: string[3];
    x: byte;
begin
 str(b:3,s);
 for x:=1 to 3 do
 if s[x]=' ' then s[x]:='0';
 bytetozerost:=s;
end;

function fullstring(nume,ext: string): string;
begin
 if ext<>'' then nume:=nume+'.'+ext;
 fullstring:=nume;
end;

begin
end.