%{
#include "./ast/ast.h"
#include "semantic_analysis.h"
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *str);
extern int yylex();
extern int yylex_destroy();
extern FILE *yyin;
extern int yylineno;
extern char* yytext;
astNode* root;
%}

%union {
    char* string;
    int integer;
    astNode* nptr;
    vector<astNode*> *vect_ptr;
}

%token EXTERN VOID INT WHILE IF ELSE RETURN 
%token PLUS MINUS TIMES DIVIDE EQUALS LESSTHAN GREATERTHAN LESSTHANEQUALS GREATERTHANEQUALS
%token <string> VARIABLE PRINT READ
%token <integer> NUM

%type <vect_ptr> statement_list var_declarations
%type <nptr> program extern_dec  function_def func_header var_declaration statement assignment_statement block_statement condition  multiplicative_expression divisive_expression unary_minus_expression subtractive_expression equals_condition less_than_condition greater_than_condition less_than_equals_condition greater_than_equals_condition if_statement while_loop call_statement return_statement expression additive_expression term   

%nonassoc IF 
%nonassoc ELSE

%left PLUS MINUS
%left EQUALS 
%left LESSTHAN GREATERTHAN LESSTHANEQUALS GREATERTHANEQUALS
%left TIMES DIVIDE


%start program


%%
program: extern_dec extern_dec function_def {
    $$ = createProg($1, $2, $3); 
    root = $$; 
}

extern_dec: EXTERN VOID VARIABLE '(' INT ')' ';' {
    $$ = createExtern("print");
    free($3);
} | EXTERN INT VARIABLE '(' ')' ';' {
    $$ = createExtern("read");
    free($3);
}

function_def: func_header block_statement {
    $$ = $1;
    $$ -> func.body = $2;
};

func_header: INT VARIABLE '(' INT VARIABLE ')' {
    astNode *var = createVar($5);
    $$ = createFunc($2, var, NULL);
    free($2);
    free($5);
} | INT VARIABLE '(' ')' {
    $$ = createFunc($2, NULL, NULL);
    free($2);
};

block_statement: '{' statement_list '}'{
    $$ = createBlock($2);
} | '{' var_declarations statement_list '}' {
    $2->insert($2->end(), $3->begin(), $3->end()); 
    $$ = createBlock($2);
};

var_declarations: var_declarations var_declaration {
    $$ = $1; 
    $$->push_back($2);
} | var_declaration {
    $$ = new vector<astNode*>();
    $$ -> push_back($1);
};

var_declaration: INT VARIABLE ';' {
    $$ = createDecl($2);
    free($2);
};

statement_list: statement_list statement {
    $$ = $1;
    $$ -> push_back($2);
} | statement {
    $$ = new vector<astNode*>();
    $$ -> push_back($1);
};

statement: assignment_statement {
    $$ = $1;
} | if_statement {
    $$ = $1;
} | while_loop {
    $$ = $1;
} | call_statement {
    $$ = $1;
} | block_statement {
    $$ = $1;
} | return_statement {
    $$ = $1;
};

assignment_statement: VARIABLE EQUALS expression ';' {
    astNode *var = createVar($1);
    $$ = createAsgn(var, $3);
    free($1);
}

if_statement: IF '(' condition ')' statement %prec IF {
    $$ = createIf($3, $5, NULL);
} | IF '(' condition ')' statement ELSE statement {
    $$ = createIf($3, $5, $7);
};

while_loop: WHILE '(' condition ')' block_statement {
    $$ = createWhile($3, $5);
};

call_statement: VARIABLE '(' ')' ';' {
    $$ = createCall($1, NULL);
    free($1);
} | VARIABLE '(' expression ')' ';' {
    $$ = createCall($1, $3);
    free($1);
};

return_statement: RETURN '(' expression ')' ';' {
    $$ = createRet($3);
};

term : VARIABLE {
    $$ = createVar($1);
    free($1);
} | NUM {
    $$ = createCnst($1);
};


expression: additive_expression {
    $$ = $1;
} | subtractive_expression {
    $$ = $1;
} | multiplicative_expression {
    $$ = $1;
} | divisive_expression {
    $$ = $1;
} | unary_minus_expression {
    $$ = $1;
} | term {
    $$ = $1;
};

condition : equals_condition {
    $$ = $1;
} | greater_than_condition {
    $$ = $1;
} | less_than_condition {
    $$ = $1;
} | greater_than_equals_condition {
    $$ = $1;
} | less_than_equals_condition {
    $$ = $1;
};

equals_condition: expression EQUALS expression {
    $$ = createRExpr($1, $3, eq);
};

greater_than_condition: expression GREATERTHAN expression {
    $$ = createRExpr($1, $3, gt);
};

less_than_condition: expression LESSTHAN expression {
    $$ = createRExpr($1, $3, lt);
};

greater_than_equals_condition: expression GREATERTHANEQUALS expression {
    $$ = createRExpr($1, $3, ge);
};

less_than_equals_condition: expression LESSTHANEQUALS expression {
    $$ = createRExpr($1, $3, le);
};

additive_expression: expression PLUS expression {
    $$ = createBExpr($1, $3, add);
};

subtractive_expression: expression MINUS expression {
    $$ = createBExpr($1, $3, sub);
};

multiplicative_expression: expression TIMES expression {
    $$ = createBExpr($1, $3, mul);
};

divisive_expression: expression DIVIDE expression {
    $$ = createBExpr($1, $3, divide);
};

unary_minus_expression: MINUS expression {
    $$ = createUExpr($2, uminus);
};

%%

void yyerror(const char *str)
{
    fprintf(stdout, "Syntax error %d\n", yylineno);
}
 
int main(int argc, char** argv){

	if (argc == 2){
		yyin = fopen(argv[1], "r");
	}

	yyparse();
    if (root == NULL) {
        fprintf(stdout, "Syntax error\n");
        return 1;
    } else {
        semanticAnalyzer(root);
    }

	freeNode(root);

	if (yyin != stdin)
		fclose(yyin);

	yylex_destroy();

	return 0;
}

