%{
#include "y.tab.h"
#include <math.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
%}
%%
[0-9]+ |
0x[0-9a-fA-F]+ { yylval=strdup(yytext); return NUMBER;  }
[a-zA-Z][a-zA-Z0-9]* {  yylval=strdup(yytext);  return IDENT;  }
[\t ]+  


\n   { return NL; }
.    {  return yytext[0];}
%%
