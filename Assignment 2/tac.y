%{
	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>

	int i=1;
	int label=1;

	char *new_temp();
	char *new_label();
%}

%union{
	struct token_type
	{
		char *code;
		char *place;
	}E;
}



%token  NL IF ELSE WHILE AND OR GT LT GE LE EQU NEQU

%token <E> NUMBER IDENT 
%type  <E> S NestedStmt StmtBlock Stmt SimpleStmt Assignment IfStmt WhileStmt 
%type  <E> Expr SimpleExpr Term Factor NoSignFactor


%left '-' '+'
%left '*' '/'
%nonassoc UMINUS

%%

S: NestedStmt {
		$<E.place>$=$<E.place>1;$<E.code>$=$<E.code>1;
		printf("%s\n",$<E.code>$);
		exit(0);
	}

NestedStmt: StmtBlock {$<E.place>$=$<E.place>1;$<E.code>$=$<E.code>1;}
	|'{' NL NestedStmt '}' NL {$<E.place>$=$<E.place>3;$<E.code>$=$<E.code>3;}
	| '{' NL StmtBlock NestedStmt  '}' NL {
	
		$<E.code>$=strdup(strcat($<E.code>3,$<E.code>4));
	}
	;

StmtBlock: '{' NL StmtBlock '}' NL {$<E.place>$=$<E.place>3;$<E.code>$=$<E.code>3;}
	| '{' NL Stmt  StmtBlock '}' NL {

		$<E.code>$=strdup(strcat($<E.code>1,$<E.code>2));
	}
	| '{' NL StmtBlock Stmt'}' NL {
		
			$<E.code>$=strdup(strcat($<E.code>3,$<E.code>4));
		}
	| '{' NL Stmt  StmtBlock Stmt '}' NL {
			char *temp=strdup(strcat($<E.code>3,$<E.code>4));
			$<E.code>$=strdup(strcat(temp,$<E.code>5));			

		}
	| '{' NL Stmt '}' NL {$<E.place>$=$<E.place>3;$<E.code>$=$<E.code>3;}
	;

Stmt: SimpleStmt {$<E.place>$=$<E.place>1;$<E.code>$=$<E.code>1;}
	| Stmt SimpleStmt {
	
		$<E.code>$=strdup(strcat($<E.code>1,$<E.code>2));
	}
	;

SimpleStmt: Assignment {$<E.place>$=$<E.place>1;$<E.code>$=$<E.code>1;}
	|IfStmt {$<E.place>$=$<E.place>1;$<E.code>$=$<E.code>1;}
	|WhileStmt {$<E.place>$=$<E.place>1;$<E.code>$=$<E.code>1;}
	;

WhileStmt: WHILE '(' Expr ')' StmtBlock {
			
			char *begin_while=strdup(new_label());
			char *end_while=strdup(new_label());

			$<E.code>$=(char *)malloc(sizeof(char)*1000);

			sprintf($<E.code>$,"%s:\n%sif %s==0 goto %s\n%sgoto %s\n%s:\n",begin_while,$<E.code>3,$<E.place>3,end_while,$<E.code>5,begin_while,end_while);


		}
	;


IfStmt: IF '(' Expr ')' StmtBlock { 

			char *label_end=strdup(new_label());

			$<E.code>$=(char *)malloc(sizeof(char)*1000);

			sprintf($<E.code>$,"%sif %s==0 goto %s\n%s\n%s:\n",$<E.code>3,$<E.place>3,label_end,$<E.code>5,label_end);

			

	}
	| IF '(' Expr ')' StmtBlock ELSE StmtBlock {


	}
	;

Assignment: IDENT '=' Expr ';' NL {

		$<E.code>$=(char *)malloc(sizeof(char)*1000);

		sprintf($<E.code>$,"%s%s=%s\n",$<E.code>3,$<E.place>1,$<E.place>3);


	}
	;

Expr: SimpleExpr {$<E.place>$=$<E.place>1;$<E.code>$=$<E.code>1;}
	| SimpleExpr EQU SimpleExpr{

		$<E.place>$=strdup(new_temp());
		$<E.code>$=(char *)malloc(sizeof(char)*1000);
		sprintf($<E.code>$,"%s%s%s=%s==%s\n",$<E.code>1,$<E.code>3,$<E.place>$,$<E.place>1,$<E.place>3);
	}
	| SimpleExpr NEQU SimpleExpr{

		$<E.place>$=strdup(new_temp());
		$<E.code>$=(char *)malloc(sizeof(char)*1000);
		sprintf($<E.code>$,"%s%s%s=%s!=%s\n",$<E.code>1,$<E.code>3,$<E.place>$,$<E.place>1,$<E.place>3);
	}
	| SimpleExpr LT SimpleExpr{

		$<E.place>$=strdup(new_temp());
		$<E.code>$=(char *)malloc(sizeof(char)*1000);
		sprintf($<E.code>$,"%s%s%s=%s<%s\n",$<E.code>1,$<E.code>3,$<E.place>$,$<E.place>1,$<E.place>3);
	}
	| SimpleExpr GT SimpleExpr{

		$<E.place>$=strdup(new_temp());
		$<E.code>$=(char *)malloc(sizeof(char)*1000);
		sprintf($<E.code>$,"%s%s%s=%s>%s\n",$<E.code>1,$<E.code>3,$<E.place>$,$<E.place>1,$<E.place>3);
	}
	| SimpleExpr LE SimpleExpr{

		$<E.place>$=strdup(new_temp());
		$<E.code>$=(char *)malloc(sizeof(char)*1000);
		sprintf($<E.code>$,"%s%s%s=%s<=%s\n",$<E.code>1,$<E.code>3,$<E.place>$,$<E.place>1,$<E.place>3);
	}
	| SimpleExpr GE SimpleExpr{

		$<E.place>$=strdup(new_temp());
		$<E.code>$=(char *)malloc(sizeof(char)*1000);
		sprintf($<E.code>$,"%s%s%s=%s>=%s\n",$<E.code>1,$<E.code>3,$<E.place>$,$<E.place>1,$<E.place>3);
	}
	;

SimpleExpr: Term {$<E.place>$=$<E.place>1;$<E.code>$=$<E.code>1;}
	
	| Term '+' SimpleExpr { 

		//printf("%s\n","SimpleExpr -> Term + SimpleExpr" );

		$<E.place>$=strdup(new_temp());
		$<E.code>$=(char *)malloc(sizeof(char)*1000);
		sprintf($<E.code>$,"%s%s%s=%s+%s\n",$<E.code>1,$<E.code>3,$<E.place>$,$<E.place>1,$<E.place>3);
	 }
	
	| Term '-' SimpleExpr  { 

		$<E.place>$=strdup(new_temp());
		$<E.code>$=(char *)malloc(sizeof(char)*1000);
		sprintf($<E.code>$,"%s%s%s=%s-%s\n",$<E.code>1,$<E.code>3,$<E.place>$,$<E.place>1,$<E.place>3);
	 }

	| Term OR SimpleExpr {

	}
	;


Term: Factor {$<E.place>$=$<E.place>1;$<E.code>$=$<E.code>1;}
	
	| Factor '*' Term { 

		$<E.place>$=strdup(new_temp());
		$<E.code>$=(char *)malloc(sizeof(char)*1000);
		sprintf($<E.code>$,"%s%s%s=%s*%s\n",$<E.code>1,$<E.code>3,$<E.place>$,$<E.place>1,$<E.place>3);

	 }
	
	| Factor '/' Term {  

		$<E.place>$=strdup(new_temp());
		$<E.code>$=(char *)malloc(sizeof(char)*1000);
		sprintf($<E.code>$,"%s%s%s=%s/%s\n",$<E.code>1,$<E.code>3,$<E.place>$,$<E.place>1,$<E.place>3);
	}
	| Factor AND Factor {


	}
	;

Factor: NoSignFactor {$<E.place>$=$<E.place>1;$<E.code>$=$<E.code>1;}
	
	| '-' NoSignFactor %prec UMINUS {
		
		$<E.place>$=strdup(new_temp());
		$<E.code>$=(char *)malloc(sizeof(char)*100);

		sprintf($<E.code>$,"%s%s=-%s\n",$<E.code>2,$<E.place>$,$<E.place>2);

	}
	;

NoSignFactor: '(' Expr ')' {$<E.place>$=strdup($<E.place>2);$<E.code>$=$<E.code>2;}
	|  IDENT   {$<E.place>$=strdup($<E.place>1);$<E.code>$=strdup("");}
	|  NUMBER  {$<E.place>$=strdup($<E.place>1);$<E.code>$=strdup("");}
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


char *new_temp()
{

	char *s=(char *)malloc(sizeof(char)*10);;
	sprintf(s,"t%d",i++);
	return s;
}

char *new_label()
{

	char *s=(char *)malloc(sizeof(char)*20);;
	sprintf(s,"label_%d",label++);
	return s;
}

