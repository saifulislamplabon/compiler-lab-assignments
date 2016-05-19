%{
#include "y.tab.h"
#include <math.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
%}
%%
"while"  {return WHILE; }
"if"     { return IF;}
"else"   { return ELSE; }
"&&"     { return AND; }
"||"     { return OR; }
">" 	 { return GT; }
"<"      { return LT;}
">=" {return GE;}
"<=" {return LE;}
"==" {return EQU;}
"!=" {return NEQU;}

[0-9]+ |
0x[0-9a-fA-F]+ { yylval.E.place=strdup(yytext); return NUMBER;  }
[a-zA-Z][a-zA-Z0-9]* {  yylval.E.place=strdup(yytext);  return IDENT;  }
[\t ]+  

\n   { return NL; }
.    {  return yytext[0];}
%%
