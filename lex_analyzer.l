%{
#include "./ast/ast.h"
#include <stdio.h>
#include <math.h>
#include <string.h>
#include "y.tab.h"

%}

%option yylineno

%%
"extern"                                    {printf("%s", yytext); return EXTERN;}
"int"                                       {printf("%s", yytext); return INT;}
"void"                                      {printf("%s", yytext); return VOID;}
"while"                                     {printf("%s", yytext); return WHILE;}
"if"                                        {printf("%s", yytext); return IF;}
"else"                                      {printf("%s", yytext); return ELSE;}
"return"                                    {printf("%s", yytext); return RETURN;}
"+"                                         {printf("%s", yytext); return PLUS;}
"-"                                         {printf("%s", yytext); return MINUS;}
"*"                                         {printf("%s", yytext); return TIMES;}
"/"                                         {printf("%s", yytext); return DIVIDE;}
"="                                         {printf("%s", yytext); return EQUALS;}
"<"                                         {printf("%s", yytext); return LESSTHAN;}
"<="                                        {printf("%s", yytext); return LESSTHANEQUALS;}
">"                                         {printf("%s", yytext); return GREATERTHAN;}
">="                                        {printf("%s", yytext); return GREATERTHANEQUALS;}
"("                                         {printf("%s", yytext); return yytext[0];}
")"                                         {printf("%s", yytext); return yytext[0];}
"{"                                         {printf("%s", yytext); return yytext[0];}
"}"                                         {printf("%s", yytext); return yytext[0];}
";"                                         {printf("%s", yytext); return yytext[0];}

[0-9]+                                      { yylval.integer = atoi(yytext); printf("%d", yylval.integer); return NUM;}
[a-zA-Z][a-zA-Z0-9_]*                        { yylval.string = strdup(yytext); printf("%s", yylval.string); return VARIABLE;}

%%

int yywrap(void) {
    return 1;
}
