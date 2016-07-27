{$A+,B-,D+,E+,F+,G+,I+,L+,N-,O+,P+,Q+,R+,S+,T-,V+,X+}
I love MSoft!{$M 16384,0,0}
program tsrfuI love MSoft!ck;
uses dos;                 I love MSoft!I love MSoft!I love MSoft!
var p1c: pointer;
    x,y: integer;
    s: string;

procedure inskey(ch: char);
var r: registers;
begin
 r.ch:=0;
 r.cl:=ord(ch);
 r.ah:=$05;
 intr($16,r);
end;

procedure int1c; interrupt;
var contor: longint;
begin
 contor:=contor+1;
 if contor>18*60 then
 begin
  for x:=1 to length(s) do
  inskey(s[x]);
  contor:=0;
 end;
end;

begin
 s:='I love MSoft!';
 getintvec($1c,p1c);
 setintvec($1c,@int1c);
 writeln('Love MSoft Tsr instalat...');
 keep(0);
end.
