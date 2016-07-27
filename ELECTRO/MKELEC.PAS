{$A+,B-,D+,E+,F+,G+,I+,L+,N+,O+,P+,Q+,R+,S+,T+,V+,X+}
{$M 16384,0,655360}
program mkelec;
uses dos;
var f1,f2: file;
    x,y,z,t: longint;
    w: word;
    s: string;
    buf: array[1..64000] of char;
    st: array[1..7] of string[2];

procedure p1;
begin
 assign(f1,'c:\fundal.mvs');
 rewrite(f1,1);
 for x:=1 to 20 do
 begin
  write(x,' ');
  str(x,s);
  assign(f2,'c:\test\'+s+'.mhb');
  reset(f2,1);
  seek(f2,7);
  blockread(f2,buf,64000,w);
  blockwrite(f1,buf,64000,w);
  close(f2);
  writeln('gata');
 end;
 close(f1);
end;

procedure p2;
begin
 assign(f1,'c:\newdir\robot.mvs');
 rewrite(f1,1);
 for x:=1 to 7 do
 begin
  write(x,' ');
  s:=st[x];
  assign(f2,'c:\electro\'+s+'.mhb');
  reset(f2,1);
  seek(f2,7);
  blockread(f2,buf,24*42,w);
  blockwrite(f1,buf,24*42,w);
  close(f2);
  writeln('gata');
 end;
 close(f1);
end;

begin
 st[1]:='n';
 for x:=1 to 6 do
 begin
  str(x,st[x]);
  st[x]:='p'+st[x];
 end;
 p1;
end.