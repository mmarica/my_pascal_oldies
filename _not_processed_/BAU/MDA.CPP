#include <stdio.h>

#define nmax 200

FILE *f;
int v[nmax],s[nmax],n,x,y,z;

void main(void)
{
 printf("\nDatzi numarul de elemente ale vectorului: ");
 scanf("%d",&n);
 printf("\nDatzi elementele vectorului:\n");
 for(x=0;x<n;x++)
 scanf("%d",&v[x]);
 printf("Vectorul nesortat este:\n");
 for(x=0;x<n;x++)
 printf("%4d",v[x]);
 printf("\n");
 for(x=0;x<n;x++)
 s[x]=v[x];
 for(x=0;x<n-1;x++)
 for(y=x+1;y<n;y++)
 if (s[x]>s[y])
 {
  z=s[x];
  s[x]=s[y];
  s[y]=z;
 }
 printf("Vectorul sortat este:\n");
 for(x=0;x<n;x++)
 printf("%4d",s[x]);
 printf("\n");
 f=fopen("vh3h3h3.h3h","w+t");
 for(x=0;x<n;x++)
 fprintf(f,"%4d",v[x]);
 fprintf(f,"\n");
 fclose(f);
 f=fopen("sh3h3h3.h3h","w+t");
 for(x=0;x<n;x++)
 fprintf(f,"%4d",s[x]);
 fprintf(f,"\n");
 fclose(f);
}