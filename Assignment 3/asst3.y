%{
	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>

	int i=1;
	int label=1;

	int line=0;

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

%token CLASS EXTENDS INT BOOL VOID WRITE WRITELN NEW READ THIS null//New Token for asst3



 %token <E> NUMBER IDENT BOOLEAN
 %type  <E> S StmtBlock Stmt SimpleStmt Assignment IfStmt WhileStmt
 %type  <E> Expr SimpleExpr Term Factor NoSignFactor MethodCall ActualParam
 %type <E> Unit ClassDec SimpleDeclSeq DeclSeq VarDecl IdentList IdentAccess FormalParam
 %type <E> ElemSelector QualifiedType SelectorSeq SimpleSelectorSeq FieldSelector PrimitiveType
 %type  <E> ArrayType Type

%left '-' '+'
%left '*' '/'
%nonassoc UMINUS

%%

S: Unit NL{
	
	$<E.place>$=$<E.place>1;$<E.code>$=$<E.code>1;
	
	
	printf("%s\n",$<E.code>$);

	
	printf("Successfully Parsed %d Lines\n",line);
	exit(0);
}
;

Unit: ClassDec {
		$<E.place>$=$<E.place>1;$<E.code>$=$<E.code>1;
		
	}
	| ClassDec Unit {
		$<E.code>$=strdup(strcat($<E.code>1,$<E.code>2));
		
	}
	;

ClassDec: CLASS IDENT '{' NL DeclSeq '}' NL {
		line+=2;
		//only counting methods
		$<E.place>$=$<E.place>5;$<E.code>$=$<E.code>5;
		
	}
	| CLASS IDENT EXTENDS IDENT '{'NL DeclSeq '}' NL {
		line+=2;
		$<E.place>$=$<E.place>7;$<E.code>$=$<E.code>7;
	

	}

	| CLASS IDENT '(' NL  {
		line+=2;
		
		$$.code=strdup("");

		printf("%s\n","There must be { after class declaration." );
	}
	;



DeclSeq: SimpleDeclSeq {$<E.place>$=$<E.place>1;$<E.code>$=$<E.code>1;}
	| DeclSeq SimpleDeclSeq {
		$<E.code>$=strdup(strcat($<E.code>1,$<E.code>2));
	
	}
	;


SimpleDeclSeq: VarDecl {}
	| MethodDecl NL{
		line++;
		$<E.place>$=$<E.place>1;$<E.code>$=$<E.code>1;
		

	}
	;


VarDecl: Type IdentList ';' NL{
	line++;
	}
	;

	
MethodDecl: MethodHeading MethodBody {
		$<E.code>$=strdup(strcat($<E.code>1,$<E.code>2));
			
	}
	;


MethodHeading: VOID IDENT '('')' {

		$<E.code>$=(char *)malloc(sizeof(char)*1000);

		sprintf($<E.code>$,"%s:\nBeginFunc %d;\n",$2.place,line++);		

	}
	| VOID IDENT '('FormalParam')'{
		$<E.code>$=(char *)malloc(sizeof(char)*1000);
		sprintf($<E.code>$,"%s: \nBeginFunc %d;\n%s",$2.place,line++,$4.code);

	}
	;


MethodBody : '{' NL DeclSeq Stmt '}' {
	 line++;
	 $<E.code>$=(char *)malloc(sizeof(char)*1000);
	
	 sprintf($<E.code>$,"%s%s_EndFunc\n",$<E.code>3,$<E.code>4);
	

	}  
	| '{' NL Stmt '}' {
		line++;	
		 $<E.code>$=(char *)malloc(sizeof(char)*1000);
		sprintf($<E.code>$,"%s\n_EndFunc\n",$3.code);
		
	}
	;

FormalParam: Type IDENT { 
		$<E.code>$=(char *)malloc(sizeof(char)*1000);
		sprintf($<E.code>$,"Pop %s\n",$2.place);

	}
	| Type IDENT ',' FormalParam{
		$<E.code>$=(char *)malloc(sizeof(char)*1000);
		sprintf($<E.code>$,"Pop %s\n%s",$2.place,$4.code);

	}
	;

IdentList: IDENT
	| IDENT ',' IdentList
	;

StmtBlock: '{'NL Stmt'}'NL {
	line+=2;
	$<E.place>$=$<E.place>3;$<E.code>$=$<E.code>3;

	}

Stmt: SimpleStmt {$<E.place>$=$<E.place>1;$<E.code>$=$<E.code>1;}
	| Stmt SimpleStmt {
		$<E.code>$=strdup(strcat($<E.code>1,$<E.code>2));
		
	}
	;

SimpleStmt: Assignment { $<E.place>$=$<E.place>1;$<E.code>$=$<E.code>1; }
	| IfStmt{ $<E.place>$=$<E.place>1;$<E.code>$=$<E.code>1; }
	| WhileStmt{ $<E.place>$=$<E.place>1;$<E.code>$=$<E.code>1; }
	| MethodCall{ $<E.place>$=$<E.place>1;$<E.code>$=$<E.code>1; }
	;



WhileStmt: WHILE '(' Expr ')' StmtBlock {
		char *begin_while=strdup(new_label());
		char *end_while=strdup(new_label());

		$<E.code>$=(char *)malloc(sizeof(char)*1000);			
		sprintf($<E.code>$,"%s:\n%sif %s==0 goto %s\n%sgoto %s\n%s:\n",begin_while,$<E.code>3,$<E.place>3,end_while,$<E.code>5,begin_while,end_while);
	
	}
	| WHILE '(' Expr  StmtBlock {
		$<E.code>$=strdup("");
		printf(") is missing at line %d\n",line-1);
	} 
	| WHILE  Expr ')' StmtBlock {
		$<E.code>$=strdup("");
		printf(" ( is missing at line %d\n",line-1);
	} 
	;

IfStmt: IF '(' Expr ')' StmtBlock {
		char *label_end=strdup(new_label());

		$<E.code>$=(char *)malloc(sizeof(char)*1000);
		
		sprintf($<E.code>$,"%sif %s==0 goto %s\n%s\n%s:\n",$<E.code>3,$<E.place>3,label_end,$<E.code>5,label_end);
	}
	| IF '(' Expr ')' StmtBlock ELSE StmtBlock{
		
	}
	;

ActualParam: Expr {
		$<E.code>$=(char *)malloc(sizeof(char)*1000);
		sprintf($<E.code>$,"Push %s\n",$1.place);
	}
	| Expr ',' ActualParam {
		$<E.code>$=(char *)malloc(sizeof(char)*1000);
		sprintf($<E.code>$,"Push %s\n%s\n",$1.place,$3.code);
	}
	| {$$.code=strdup("");}
	;



MethodCall: IdentAccess '(' ActualParam ')' ';' NL {
		line++;
		$<E.code>$=(char *)malloc(sizeof(char)*1000);
		sprintf($<E.code>$,"%s Call %s\n",$3.code,$1.place);


	}
	| WRITE '(' ActualParam ')' ';' NL{
		line++;

	}
	| WRITELN '(' ActualParam ')' ';' NL{
		line++;
	}
	;

Assignment: IdentAccess '=' Expr ';' NL {
		line++;

		$<E.code>$=(char *)malloc(sizeof(char)*1000);

		sprintf($<E.code>$,"%s%s=%s\n",$<E.code>3,$<E.place>1,$<E.place>3);
	}
	| IdentAccess '=' NEW QualifiedType ';' NL {
		line++;
		$<E.code>$=(char *)malloc(sizeof(char)*1000);
		sprintf($<E.code>$,"%s=new %s\n",$<E.place>1,$<E.code>4);
	}
	
	| IdentAccess '='  READ '('')' ';' NL{
		line++;
	}
	| IdentAccess '=' Expr  NL {
		//ERROR
		$<E.code>$=strdup("");
		printf(" ; is missing.");
	}
	;



Expr: SimpleExpr {$<E.place>$=$<E.place>1;$<E.code>$=$<E.code>1;}
	| SimpleExpr EQU SimpleExpr{
		$<E.place>$=strdup(new_temp());
		$<E.code>$=(char *)malloc(sizeof(char)*1000);

		char *true_label=strdup(new_label());
		char *end_label=strdup(new_label());


		sprintf($<E.code>$,"%s%sif %s==%s goto %s\n%s=0\ngoto %s\n%s:\n%s=1\n%s:\n",$1.code,$3.code,$1.place,$3.place,true_label,$$.place,end_label,true_label,$$.place,end_label);
	}
	| SimpleExpr NEQU SimpleExpr{
		$<E.place>$=strdup(new_temp());
		$<E.code>$=(char *)malloc(sizeof(char)*1000);

		char *true_label=strdup(new_label());
		char *end_label=strdup(new_label());


		sprintf($<E.code>$,"%s%sif %s!=%s goto %s\n%s=0\ngoto %s\n%s:\n%s=1\n%s:\n",$1.code,$3.code,$1.place,$3.place,true_label,$$.place,end_label,true_label,$$.place,end_label);
	}
	| SimpleExpr LT SimpleExpr {
		$<E.place>$=strdup(new_temp());
		$<E.code>$=(char *)malloc(sizeof(char)*1000);

		char *true_label=strdup(new_label());
		char *end_label=strdup(new_label());


		sprintf($<E.code>$,"%s%sif %s<%s goto %s\n%s=0\ngoto %s\n%s:\n%s=1\n%s:\n",$1.code,$3.code,$1.place,$3.place,true_label,$$.place,end_label,true_label,$$.place,end_label);
	}
	| SimpleExpr GT SimpleExpr {
		$<E.place>$=strdup(new_temp());
		$<E.code>$=(char *)malloc(sizeof(char)*1000);

		char *true_label=strdup(new_label());
		char *end_label=strdup(new_label());


		sprintf($<E.code>$,"%s%sif %s>%s goto %s\n%s=0\ngoto %s\n%s:\n%s=1\n%s:\n",$1.code,$3.code,$1.place,$3.place,true_label,$$.place,end_label,true_label,$$.place,end_label);
	}
	| SimpleExpr GE SimpleExpr {
		$<E.place>$=strdup(new_temp());
		$<E.code>$=(char *)malloc(sizeof(char)*1000);

		char *true_label=strdup(new_label());
		char *end_label=strdup(new_label());


		sprintf($<E.code>$,"%s%sif %s>=%s goto %s\n%s=0\ngoto %s\n%s:\n%s=1\n%s:\n",$1.code,$3.code,$1.place,$3.place,true_label,$$.place,end_label,true_label,$$.place,end_label);
	}
	| SimpleExpr LE SimpleExpr {
		$<E.place>$=strdup(new_temp());
		$<E.code>$=(char *)malloc(sizeof(char)*1000);

		char *true_label=strdup(new_label());
		char *end_label=strdup(new_label());


		sprintf($<E.code>$,"%s%sif %s<=%s goto %s\n%s=0\ngoto %s\n%s:\n%s=1\n%s:\n",$1.code,$3.code,$1.place,$3.place,true_label,$$.place,end_label,true_label,$$.place,end_label);
	}
	;

SimpleExpr: Term {$$.place=strdup($1.place);$$.code=strdup($1.code);}
	| Term '+' SimpleExpr	{
		$<E.place>$=strdup(new_temp());
		$<E.code>$=(char *)malloc(sizeof(char)*1000);
		sprintf($<E.code>$,"%s%s%s=%s+%s\n",$<E.code>1,$<E.code>3,$<E.place>$,$<E.place>1,$<E.place>3);
	}
	| Term '-' SimpleExpr	{
		$<E.place>$=strdup(new_temp());
		$<E.code>$=(char *)malloc(sizeof(char)*1000);
		sprintf($<E.code>$,"%s%s%s=%s-%s\n",$<E.code>1,$<E.code>3,$<E.place>$,$<E.place>1,$<E.place>3);
	}
	| Term OR SimpleExpr {
		$<E.place>$=strdup(new_temp());
		$<E.code>$=(char *)malloc(sizeof(char)*1000);
		sprintf($<E.code>$,"%s%s%s= %s || %s \n",$<E.code>1,$<E.code>3,$<E.place>$,$<E.place>1,$<E.place>3);
		 
	}
	;

Term: Factor {$$.place=strdup($1.place);$$.code=strdup($1.code);}
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
	| Factor AND Term {
		$<E.place>$=strdup(new_temp());
		$<E.code>$=(char *)malloc(sizeof(char)*1000);
		sprintf($<E.code>$,"%s%s%s=%s && %s\n",$<E.code>1,$<E.code>3,$<E.place>$,$<E.place>1,$<E.place>3);
	}
	;

RefType : IDENT
	 | IDENT '['']'
	 | INT '[' ']' 
	 | BOOL '[' ']'
	 ;

Factor: NoSignFactor {$<E.place>$=$<E.place>1;$<E.code>$=$<E.code>1;}
	| '-' NoSignFactor %prec UMINUS {
		$<E.place>$=strdup(new_temp());
		$<E.code>$=(char *)malloc(sizeof(char)*1000);

		sprintf($<E.code>$,"%s%s=-%s\n",$<E.code>2,$<E.place>$,$<E.place>2);
	}
	;


NoSignFactor: IdentAccess {$$.place=strdup($1.place);$$.code=strdup("");}
	| NUMBER {$$.place=strdup($1.place);$$.code=strdup("");}
	| BOOLEAN {$$.place=strdup($1.place);$$.code=strdup("");}
	| '(' Expr ')' {$$.place=strdup($2.place);$$.code=strdup($2.code);}
	| '!' Factor {$$.place=strdup($2.place);$$.code=strdup($2.code);}
	| '(' RefType ')' NoSignFactor {
		$$.place=strdup($4.place);$$.code=strdup($4.code);	
	} 
	| null { $$.code=strdup("null");}
	;

IdentAccess: IDENT {$$.place=strdup($1.place);$$.code=strdup("");}
	| IDENT SelectorSeq {
		$<E.code>$=strdup(strcat($<E.place>1,$<E.code>2));
	}
	| THIS SelectorSeq {

		$$.code=strdup($2.place);
	}
	;

SelectorSeq: SimpleSelectorSeq { $<E.code>$=$<E.code>1;}
	| SelectorSeq SimpleSelectorSeq {}
	;

SimpleSelectorSeq: FieldSelector 
	| ElemSelector {
		$<E.code>$=$<E.code>1;
	}
	;

ElemSelector : '[' SimpleExpr ']' {

		$<E.code>$=(char *)malloc(sizeof(char)*1000);
		sprintf($<E.code>$,"[%s]",$<E.place>2);
	}
	;


FieldSelector : '.' IDENT{

		$<E.code>$=(char *)malloc(sizeof(char)*1000);
		sprintf($<E.code>$,"[%s]\n",$<E.code>2);
	}
	;
QualifiedType : IDENT '(' ')' { 
		$<E.code>$=(char *)malloc(sizeof(char)*1000);
		sprintf($<E.code>$,"%s()\n",$<E.place>1);

	}
	| IDENT ElemSelector { 
		$<E.code>$=(char *)malloc(sizeof(char)*1000);
		sprintf($<E.code>$,"%s %s",$<E.place>1,$<E.code>2);

	 }
	| PrimitiveType ElemSelector { 
		$<E.code>$=(char *)malloc(sizeof(char)*1000);
		sprintf($<E.code>$,"%s %s",$<E.code>1,$<E.code>2);
	}
	;



ArrayType: IDENT '['']'
	| PrimitiveType '['']' {$$.code=strdup("");}
	;

Type: PrimitiveType {$$.code=strdup("");}
	| IDENT 
	| ArrayType
	;

PrimitiveType: INT {$$.code=strdup("int");}
	| BOOL {$$.code=strdup("boolean");}
	;



%%

int main(void)
{
   yyparse();
   
}
int yyerror(char *s)
{
    printf("Error: %s\n",s);
    
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

