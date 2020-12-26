%{
    #include <ctype.h>
    #include <stdio.h>
    #include <string.h>
    #include "lex.yy.c"
    #include <math.h>
    #define YYSTYPE int
    int yyparse(void);
    int yyerror(char *s);
    int count_id = 0;
    int count_node = 0;
    int all_node = 0;

    enum OP {zs,ROOT,ID,NU,PL,MN,UMN,DI,MU,P,L,C,S,EX};

    typedef struct Node{
        double diff;
        double val;
        char name[10];
        enum OP op;
        struct Node *reverse[10];
    }node;

    node *chain[40];

    node* CreateNode();
    void calcVal(node *n);
    int FindID(char name[]);
    void ReverseAutoDiff(node *chain[]);
%}

%token EQUA
%left PLUS MINUS
%left  MUL DIV
%token COS SIN
%left LN EXP POW 
%token NUMBER IDENT FUNC LEFTPA RIGHTPA COMMA COLON EOL


%%

Start : REV_AutoDiff
        | REV_AutoDiff Start
        ;

REV_AutoDiff : func_def EOL
    {
        printf("val = %lf\n",chain[all_node-1]->val);
        ReverseAutoDiff(chain);
    }
    ;

func_def : FUNC LEFTPA var_list RIGHTPA COLON expr
    {
        node *x = CreateNode();
        chain[all_node++] = x;
        count_node++;
        x->op = ROOT;
        x->reverse[0] = chain[$6];
        // printf("x->reverse[0]: %d, val: %lf\n",$6, chain[$6]->val);
        calcVal(x);
    }
    ;

var_init : IDENT 
    {
        node *x = CreateNode();
        chain[all_node++] = x;
        count_id++;
        x->op = ID;
        strcpy(x->name,yytext);
        // printf("yytext: %s, x->name: %s\n",yytext, x->name);
    }
    EQUA NUMBER
    {
        node *x = chain[all_node-1];
        // printf("ident name:%s, ident val:%d\n",x->name,$4);
        x->val = $4;
    }
    ;

var_list : var_init 
    | var_list COMMA var_init
    ;

expr : IDENT
        {
            int x = FindID(yytext);
            // printf("x value: %d\n",x);
            $$ = x;
            
        }
    | NUMBER
        {
            node *x = CreateNode();
            chain[all_node++] = x;
            count_node++;
            $$ = all_node-1;
            x->op = NU;
            x->val = $1;
        }                    
    | expr PLUS expr
        {
            node *x = CreateNode();
            chain[all_node++] = x;
            $$ = all_node-1;
            count_node++;
            x->op = PL;
            x->reverse[0] = chain[$1];  
            x->reverse[1] = chain[$3];
            calcVal(x);
        }    
    | expr MINUS expr
        {
            node *x = CreateNode();
            chain[all_node++] = x;
            $$ = all_node-1;
            count_node++;
            x->op = MN;
            x->reverse[0] = chain[$1];
            x->reverse[1] = chain[$3];
            calcVal(x);
        }  
    | expr MUL expr
        {
            node *x = CreateNode();
            chain[all_node++] = x;
            $$ = all_node-1;
            count_node++;
            x->op = MU;
            x->reverse[0] = chain[$1];
            x->reverse[1] = chain[$3];
            calcVal(x);
        }  
    | expr DIV expr
        {
            node *x = CreateNode();
            chain[all_node++] = x;
            $$ = all_node-1;
            count_node++;
            x->op = DI;
            x->reverse[0] = chain[$1];
            x->reverse[1] = chain[$3];
            calcVal(x);
        }  
    | MINUS expr 
        {
            node *x = CreateNode();
            chain[all_node++] = x;
            $$ = all_node-1;
            count_node++;
            x->op = UMN;
            x->reverse[0] = chain[$2];
            calcVal(x);
        }  
    | LEFTPA expr RIGHTPA
        {
            $$ = $2;
        }  
    | expr POW expr
        {
            node *x = CreateNode();
            chain[all_node++] = x;
            $$ = all_node-1;
            count_node++;
            x->op = P;
            x->reverse[0] = chain[$1];
            x->reverse[1] = chain[$3];
            calcVal(x);
        }  
    | EXP LEFTPA expr RIGHTPA
        {
            node *x = CreateNode();
            chain[all_node++] = x;
            $$ = all_node-1;
            count_node++;
            x->op = EX;
            x->reverse[0] = chain[$3];
            calcVal(x);
        }  
    | LN LEFTPA expr RIGHTPA
        {
            node *x = CreateNode();
            chain[all_node++] = x;
            $$ = all_node-1;
            count_node++;
            x->op = L;
            x->reverse[0] = chain[$3];
            calcVal(x);
        }  
    | SIN LEFTPA expr RIGHTPA
        {
            node *x = CreateNode();
            chain[all_node++] = x;
            $$ = all_node-1;
            count_node++;
            x->op = S;
            x->reverse[0] = chain[$3];
            calcVal(x);
        }  
    | COS LEFTPA expr RIGHTPA
        {
            node *x = CreateNode();
            chain[all_node++] = x;
            $$ = all_node-1;
            count_node++;
            x->op = C;
            x->reverse[0] = chain[$3];
            calcVal(x);
        }
    ;
%%
#include <stdio.h>

extern FILE *yyin;
int main()
{
    yyin = stdin;
    return yyparse();
}

yyerror(s) 
char *s;
{
    fprintf(stderr, "%s\n", s );
}

int yywrap(){
    return 1;
}

node* CreateNode(){
    node* x = (node*)malloc(sizeof(node));
    x->diff = x->val = 0;
    for(int i = 0; i < 10; i++){
        x->name[i] = '\0';
        x->reverse[i] = NULL;
    }
    /* printf("Build node: %d\n",all_node); */
    return x;
}

int FindID(char name[]){
        int i = 0;
        for(;i < count_id; i++){
            if(!strcmp(chain[i]->name,name)){
                return i;
            }
        }
    }

void calcVal(node *n){
        switch(n->op){
            case ROOT:
                n->val = n->reverse[0]->val;
                break;
            case PL:
                n->val = n->reverse[0]->val + n->reverse[1]->val;
                break;
            case MN:
                n->val = n->reverse[0]->val - n->reverse[1]->val;
                break;
            case UMN:
                n->val = -n->reverse[0]->val;
                break;
            case DI:
                n->val = n->reverse[0]->val / n->reverse[1]->val;
                break;
            case MU:
                n->val = n->reverse[0]->val * n->reverse[1]->val;
                break;
            case P:
                n->val = pow(n->reverse[0]->val,n->reverse[1]->val);
                break;
            case L:
                n->val = log(n->reverse[0]->val);
                break;
            case C:
                n->val = cos(n->reverse[0]->val);
                break;
            case S:
                n->val = sin(n->reverse[0]->val);
                break;
            case EX:
                n->val = pow(2.71828,n->reverse[0]->val);
                break;
        }
        /* printf("Now opr:%d, value: %lf\n",n->op,n->val); */
    }


void Reset(){
    count_id = 0;
    count_node = 0;
    all_node = 0;
}

void ReverseAutoDiff(node *chain[]){
        int n = count_id + count_node;
        while(count_node--){
            node *x = chain[n-1];
            if(x->reverse[0]){
                switch(x->op){
                case ROOT:
                    x->reverse[0]->diff = 1;
                    break;
                case PL:
                    x->reverse[0]->diff += x->diff;
                    x->reverse[1]->diff += x->diff;
                break;
                    case MN:
                    x->reverse[0]->diff += x->diff;
                    x->reverse[1]->diff += -x->diff;
                    break;
                case DI:
                    x->reverse[0]->diff += x->diff / x->reverse[1]->val;
                    x->reverse[1]->diff += x->diff * x->reverse[0]->val /pow(x->reverse[1]->val,2);
                    break;
                case MU:
                    x->reverse[0]->diff += x->diff * x->reverse[1]->val;
                    x->reverse[1]->diff += x->diff * x->reverse[0]->val;
                    break;
                case P:
                    x->reverse[0]->diff += x->diff * x->reverse[1]->val * pow(x->reverse[0]->val,x->reverse[1]->val-1);
                    x->reverse[1]->diff += x->diff * log(x->reverse[0]->val) * pow(x->reverse[0]->val,x->reverse[1]->val);
                    break;
                case L:
                    x->reverse[0]->diff += x->diff / x->reverse[0]->val;
                    break;
                case C:
                    x->reverse[0]->diff += -sin(x->reverse[0]->val) * x->diff;
                    break;
                case S:
                    x->reverse[0]->diff += cos(x->reverse[0]->val) * x->diff;
                    break;
                case EX:
                    x->reverse[0]->diff += pow(2.7182818284590,x->reverse[0]->val) * x->diff;
                    break;
                default:break;
                }
            }
            n--;
        }
        int c = 0;
        while(count_id > c){
            node *x = chain[c++];
            printf("f-PDF@%s = %lf\n",x->name, x->diff);
        }
        Reset();
    }

