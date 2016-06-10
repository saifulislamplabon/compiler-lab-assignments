%{
	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	#define YYSTYPE char *
	int i=1;

	char *binary_to_tac(char *first,char op,char *second);
	char *uminus_to_tac(char *NoSignFactor);
%}

%token  NUMBER
%token  IDENT
%token NL

%left '-' '+'
%left '*' '/'
%nonassoc UMINUS

%%

S: NestedStmt {exit(0);}

NestedStmt: StmtBlock 
	|'{' NL NestedStmt '}' NL 
	| '{' NL StmtBlock NestedStmt  '}' NL
	;

StmtBlock: '{' NL StmtBlock '}' NL
	| '{' NL Stmt  StmtBlock '}' NL
	| '{' NL StmtBlock Stmt'}' NL
	| '{' NL Stmt  StmtBlock Stmt '}' NL
	| '{' NL Stmt '}' NL 
	;

Stmt: Assignment
	| Stmt Assignment
	;

Assignment: IDENT '=' Expr ';' NL {printf("%s = %s\n",$1,$3);}
	;

Expr: SimpleExpr
	;

SimpleExpr: Term {$$=$1;}
	| Term '+' Term1 { $$ = binary_to_tac($1,'+',$3); }
	| Term '-' Term1  { $$ = binary_to_tac($1,'+',$3); }
	;

Term1: Term {$$=$1;}
	| Term '+' Term1 { $$ = binary_to_tac($1,'+',$3); }
	| Term '-' Term1  { $$ = binary_to_tac($1,'+',$3); }
	;

Term: Factor {$$=$1;}
	| Factor '*' Factor1 { $$ = binary_to_tac($1,'*',$3); }
	| Factor '/' Factor1 { $$ = binary_to_tac($1,'/',$3); }
	;

Factor1: Factor {$$=$1;}
	| Factor '*' Factor1 { $$ = binary_to_tac($1,'*',$3); }
	| Factor '/' Factor1 { $$ = binary_to_tac($1,'/',$3); }
	;

Factor: NoSignFactor {$$=$1;}
	| '-' NoSignFactor %prec UMINUS {$$=uminus_to_tac($2);}
	;

NoSignFactor: '(' Expr ')' { $$=$2; }
	|  IDENT
	|  NUMBER 
	;
%%
int main(void)
{
   yyparse();
   
}
int yyerror(void)
{
    printf("Syntax Error\n");
    
}


char *binary_to_tac(char *first,char op,char *second)
{		
		char *str = (char *) malloc(sizeof(char) * 10);
		
		sprintf(str, "t%d", i++);

        printf("%s = %s %c %s\n",str,first,op,second);
        return str;
}

char *uminus_to_tac(char *NoSignFactor)
{
	char *str = (char *) malloc(sizeof(char) * 10);
		
	sprintf(str, "t%d", i++);

    printf("%s = -%s\n",str,NoSignFactor);
    return str;

}
