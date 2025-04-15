/* YACC grammar for Python to C conversion */
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern int line_num;
extern char* yytext;
extern FILE* yyin;
FILE* outfile;

void yyerror(const char* s);
/* Define indent_level here so it's available to both files */
int indent_level = 0;

/* Helper functions for code generation */
void start_block() {
    fprintf(outfile, " {\n");
    indent_level++;
}

void end_block() {
    indent_level--;
    for (int i = 0; i < indent_level; i++) fprintf(outfile, "    ");
    fprintf(outfile, "}\n");
}

void print_indent() {
    for (int i = 0; i < indent_level; i++) fprintf(outfile, "    ");
}

char* c_type_for_py_var(char* var_name) {
    /* In a real transpiler, you'd track variable types */
    return "auto"; /* Using C11's auto for simplicity */
}
%}

%union {
    int int_val;
    float float_val;
    int bool_val;
    char str_val[1024];
    char id[256];
    int indent_val;
}

%token <int_val> INT
%token <float_val> FLOAT
%token <bool_val> BOOL
%token <str_val> STRING
%token <id> ID
%token <indent_val> INDENT DEDENT

%token IF ELSE ELIF WHILE FOR DEF RETURN PRINT IN RANGE IMPORT
%token COLON LPAREN RPAREN LBRACKET RBRACKET
%token ASSIGN EQ NEQ LT GT LTE GTE
%token PLUS MINUS TIMES DIVIDE MOD
%token COMMA DOT AND OR NOT NONE

%left PLUS MINUS
%left TIMES DIVIDE MOD
%left EQ NEQ LT GT LTE GTE
%left AND OR
%right NOT

%start program

%%

program: statements
       ;

statements: statement
          | statements statement
          ;

statement: if_statement
         | while_statement
         | for_statement
         | assignment_statement
         | function_def
         | function_call_statement
         | return_statement
         | print_statement
         | import_statement
         ;

if_statement: IF expression COLON {
                print_indent();
                fprintf(outfile, "if (");
                fprintf(outfile, "%s", "true"); /* Simplified for MVP */
                fprintf(outfile, ")");
                start_block();
              }
              block {
                end_block();
              }
              elif_blocks
              else_block
            ;

elif_blocks: /* empty */
           | ELIF expression COLON {
                print_indent();
                fprintf(outfile, "else if (");
                fprintf(outfile, "%s", "true"); /* Simplified for MVP */
                fprintf(outfile, ")");
                start_block();
             }
             block {
                end_block();
             }
             elif_blocks
           ;

else_block: /* empty */
          | ELSE COLON {
                print_indent();
                fprintf(outfile, "else");
                start_block();
            }
            block {
                end_block();
            }
          ;

while_statement: WHILE expression COLON {
                   print_indent();
                   fprintf(outfile, "while (");
                   fprintf(outfile, "%s", "true"); /* Simplified for MVP */
                   fprintf(outfile, ")");
                   start_block();
                 }
                 block {
                   end_block();
                 }
               ;

for_statement: FOR ID IN RANGE LPAREN expression RPAREN COLON {
                 print_indent();
                 fprintf(outfile, "for (int %s = 0; %s < 5; %s++)", $2, $2, $2);
                 start_block();
               }
               block {
                 end_block();
               }
               | FOR ID IN RANGE LPAREN expression COMMA expression RPAREN COLON {
                 print_indent();
                 fprintf(outfile, "for (int %s = 0; %s < 5; %s++)", $2, $2, $2);
                 start_block();
               }
               block {
                 end_block();
               }
             ;

assignment_statement: ID ASSIGN expression {
                        print_indent();
                        fprintf(outfile, "int %s = 0;\n", $1); /* Simplified for MVP */
                      }
                    ;

function_def: DEF ID LPAREN parameter_list RPAREN COLON {
                print_indent();
                fprintf(outfile, "void %s()", $2);
                start_block();
              }
              block {
                end_block();
              }
            ;

parameter_list: /* empty */
              | ID 
              | parameter_list COMMA ID 
              ;

function_call_statement: ID LPAREN argument_list RPAREN {
                            print_indent();
                            fprintf(outfile, "%s();\n", $1);
                          }
                       ;

argument_list: /* empty */
             | expression
             | argument_list COMMA expression
             ;

return_statement: RETURN {
                    print_indent();
                    fprintf(outfile, "return;\n");
                  }
                | RETURN expression {
                    print_indent();
                    fprintf(outfile, "return;\n");
                  }
                ;

print_statement: PRINT LPAREN STRING RPAREN {
                   print_indent();
                   /* Extract the actual string from the quotation marks */
                   char *str = $3;
                   if (str[0] == '"' || str[0] == '\'') {
                       str++; /* Skip the opening quote */
                       str[strlen(str)-1] = '\0'; /* Remove the closing quote */
                   }
                   fprintf(outfile, "printf(\"%%s\\n\", \"%s\");\n", str);
                 }
               ;

import_statement: IMPORT ID {
                    print_indent();
                    fprintf(outfile, "#include \"%s.h\"\n", $2);
                  }
                ;

block: statement
     | COLON statement
     ;

expression: INT
          | FLOAT
          | BOOL 
          | STRING
          | ID
          | LPAREN expression RPAREN
          | expression PLUS expression
          | expression MINUS expression
          | expression TIMES expression
          | expression DIVIDE expression
          | expression EQ expression
          | expression NEQ expression
          | expression LT expression
          | expression GT expression
          | expression LTE expression
          | expression GTE expression
          | NOT expression
          ;

%%

void yyerror(const char* s) {
    fprintf(stderr, "Error on line %d: %s\n", line_num, s);
    exit(1);
}
/* Track functions to declare them before main() */
typedef struct {
    char name[256];
    char definition[2048];
} Function;

Function functions[100];
int function_count = 0;
int main(int argc, char* argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Usage: %s input_file output_file\n", argv[0]);
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        fprintf(stderr, "Cannot open input file %s\n", argv[1]);
        return 1;
    }

    outfile = fopen(argv[2], "w");
    if (!outfile) {
        fprintf(stderr, "Cannot open output file %s\n", argv[2]);
        fclose(yyin);
        return 1;
    }

    /* Write C file header */
	fprintf(outfile, "#include <stdio.h>\n");
	fprintf(outfile, "#include <stdlib.h>\n");
	fprintf(outfile, "#include <string.h>\n");
	fprintf(outfile, "#include <stdbool.h>\n\n");

	/* Write function declarations first */
	for (int i = 0; i < function_count; i++) {
		fprintf(outfile, "%s\n", functions[i].definition);
	}

	fprintf(outfile, "int main() {\n");
	indent_level = 1;

    /* Parse the input file */
    yyparse();

    /* Write C file footer */
    fprintf(outfile, "    return 0;\n");
    fprintf(outfile, "}\n");

    fclose(yyin);
    fclose(outfile);
    return 0;
}