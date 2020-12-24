%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <math.h>
    #include <string.h>
    extern double yylval;
    extern char IDNAME[20];
%}

/*常规定义*/
letter [A-Za-z]
digit [0-9]
id {letter}({letter}|{digit})*
number {digit}+

%%

{id}            {strcpy(IDNAME,yytext);return IDENT;}
{number}        {yylval = atoi(yytext);return NUMBER;}
cos             return COS;
sin             return SIN;
ln              return LN;
exp             return EXP;

%%
