%{
    #include <stdio.h>
    #include <string.h>
    extern int yylval;

//    enum op{zs, NUMBER, IDENT ,FUNC ,LEFTPA,RIGHTPA ,COMMA ,COLON,EQUA,PLUS ,MINUS,MUL ,DIV,COS ,SIN, LN ,EXP, POW };
%}

/*常规定义*/
letter [A-Za-z]
digit [0-9]


%%

"\n"            {
                    // printf("enter\n");
                    return EOL;
                }

"cos"            {
                    // printf("%s, cos\n",yytext);
                    return COS;
                }
"sin"           {   
                    // printf("%s, sin\n",yytext);
                    return SIN;
                }
"ln"             {   
                    // printf("%s, ln\n",yytext);
                    return LN;
                }
"exp"            {   
                    // printf("%s, exp\n",yytext);
                    return EXP;
                }

"f"            {
                    // printf("%s, function\n",yytext);
                    return FUNC;
                }

"="             {
                    // printf("%s, equal\n",yytext);
                    return EQUA;
                }

"-"             {
                    // printf("%s, minus\n",yytext);
                    return MINUS;
                }     

"+"             {
                    // printf("%s, equal\n",yytext);
                    return PLUS;
                }           

"/"             {
                    // printf("%s, divide\n",yytext);
                    return DIV;
                }  

"*"             {
                    // printf("%s, multiply\n",yytext);
                    return MUL;
                }  

"^"             {
                    // printf("%s, power\n",yytext);
                    return POW;
                }  

"("             {
                    // printf("%s, Lparen\n",yytext);
                    return LEFTPA;
                }  

")"             {
                    // printf("%s, Rparen\n",yytext);
                    return RIGHTPA;
                }  

":"             {
                    // printf("%s, colon\n",yytext);
                    return COLON;
                }  

","             {
                    // printf("%s, comma\n",yytext);
                    return COMMA;
                }  

{letter}({letter}|{digit})*             {   
                                            // printf("%s,ident\n",yytext);
                                            return IDENT;
                                        }
{digit}+        {
                    // printf("%s, number\n",yytext);
                    yylval = atoi(yytext);
                    return NUMBER;
                }

%%
    /* int main(){
    int sym;
    while(1){
        sym = yylex();
        switch(sym)
        {
            case COS: printf("COS(\n");
        }
    }
    return 0;
    } */