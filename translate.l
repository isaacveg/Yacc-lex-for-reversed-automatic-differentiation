%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <math.h>
    #include <string.h>
    extern int yylval;
%}

/*常规定义*/
letter [A-Za-z]
NoFletter [A-Za-eg-z]
digit [0-9]
id {NoFletter}({letter}|{digit})*
number {digit}+

%%

{id}            {return IDENT;}
{number}        {yylval = atoi(yytext);return NUMBER;}
cos             return COS;
sin             return SIN;
ln              return LN;
exp             return EXP;

%%
