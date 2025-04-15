/* Lexical analyzer for Python */
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"

int line_num = 1;
/* Change indent_level to extern to avoid duplicate definition */
extern int indent_level;
int current_indent = 0;
int prev_indent = 0;
int indent_stack[100];
int stack_top = 0;
int pending_dedents = 0;
int ignore_next_newline = 0;

void update_indentation(void);

/* Remove duplicate yylval definition - it's defined in y.tab.c */
%}

%option noyywrap
%option never-interactive

%%
[ \t]*\n        { line_num++; ignore_next_newline = 1; }
^[ \t]+         { 
                  if (!ignore_next_newline) {
                    current_indent = strlen(yytext);
                    update_indentation();
                  }
                  ignore_next_newline = 0;
                }
\n              { 
                  line_num++; 
                  if (!ignore_next_newline) {
                    current_indent = 0;
                    update_indentation();
                  }
                  ignore_next_newline = 0;
                }

"if"            { ignore_next_newline = 1; return IF; }
"else"          { ignore_next_newline = 1; return ELSE; }
"elif"          { ignore_next_newline = 1; return ELIF; }
"while"         { ignore_next_newline = 1; return WHILE; }
"for"           { ignore_next_newline = 1; return FOR; }
"def"           { ignore_next_newline = 1; return DEF; }
"return"        { return RETURN; }
"print"         { return PRINT; }
"in"            { return IN; }
"range"         { return RANGE; }
"import"        { return IMPORT; }
"True"          { yylval.bool_val = 1; return BOOL; }
"False"         { yylval.bool_val = 0; return BOOL; }
"None"          { return NONE; }
"and"           { return AND; }
"or"            { return OR; }
"not"           { return NOT; }

":"             { ignore_next_newline = 1; return COLON; }
"("             { ignore_next_newline = 1; return LPAREN; }
")"             { return RPAREN; }
"["             { ignore_next_newline = 1; return LBRACKET; }
"]"             { return RBRACKET; }
"="             { return ASSIGN; }
"=="            { return EQ; }
"!="            { return NEQ; }
"<"             { return LT; }
">"             { return GT; }
"<="            { return LTE; }
">="            { return GTE; }
"+"             { return PLUS; }
"-"             { return MINUS; }
"*"             { return TIMES; }
"/"             { return DIVIDE; }
"%"             { return MOD; }
","             { return COMMA; }
"."             { return DOT; }
"#".*           { /* Ignore comments */ }

[0-9]+          { yylval.int_val = atoi(yytext); return INT; }
[0-9]+\.[0-9]+  { yylval.float_val = atof(yytext); return FLOAT; }

\"([^\"\n]|\\.)*\"    { 
                        strcpy(yylval.str_val, yytext);
                        return STRING; 
                      }
\'([^\'\n]|\\.)*\'    { 
                        strcpy(yylval.str_val, yytext);
                        return STRING; 
                      }

[a-zA-Z_][a-zA-Z0-9_]* { 
                        strcpy(yylval.id, yytext); 
                        return ID; 
                      }

[ \t]           { /* Ignore whitespace */ }
.               { /* Ignore other characters */ }

%%

void update_indentation(void) {
    if (current_indent > prev_indent) {
        /* Indent */
        indent_stack[stack_top++] = current_indent;
        prev_indent = current_indent;
        pending_dedents = 0;
        yylval.indent_val = current_indent;
        return;
    } 
    else if (current_indent < prev_indent) {
        /* Dedent */
        while (stack_top > 0 && indent_stack[stack_top-1] > current_indent) {
            stack_top--;
            pending_dedents++;
        }
        prev_indent = (stack_top > 0) ? indent_stack[stack_top-1] : 0;
        
        if (pending_dedents > 0) {
            pending_dedents--;
            yylval.indent_val = current_indent;
            return;
        }
    }
}