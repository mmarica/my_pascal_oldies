var w: word;

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

begin
 readln(w);
 writeln(conv(w));
end.