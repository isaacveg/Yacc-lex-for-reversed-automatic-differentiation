%{
    #include <ctype.h>
    #include <stdio.h>
    #include <string.h>
    #include "lex.yy.c"
    #include <math.h>
    #define YYSTYPE double
    int yyparse(void);
    int count_id = 0;
    int count_node = 0;
    int all_node = 0;

    enum OP {ROOT,ID,NU,PL,MN,UMN,DIV,MUL,P,L,C,S,EX} opr;

    typedef struct Node{
        double diff;
        double val;
        char name[10];
        enum OP op;
        struct Node *reverse[10];
    }node;

    node *chain[40];

    node* CreateNode(){
        node* x = (node*)malloc(sizeof(node));
        x->diff = x->val = 0;
        for(int i = 0; i < 10; i++){
            x->name[i] = '\0';
            x->reverse[i] = NULL;
        }
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
            case DIV:
                n->val = n->reverse[0]->val / n->reverse[1]->val;
                break;
            case MUL:
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
                case DIV:
                x->reverse[0]->diff += x->diff / x->reverse[1]->val;
                x->reverse[1]->diff += x->diff * x->reverse[0]->val /pow(x->reverse[1]->val,2);
                break;
                case MUL:
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
                x->reverse[0]->diff += -sin(n->reverse[0]->val) * x->diff;
                break;
                case S:
                x->reverse[0]->diff += cos(n->reverse[0]->val) * x->diff;
                break;
                case EX:
                x->reverse[0]->diff += pow(2.73,n->reverse[0]->val) * x->diff;
                break;
                default:break;
                }
            }
            n--;
        }
        int c = 0;
        while(count_id > c){
            node *x = chain[c];
            printf("f-PDF@%s = %lf\n",x->name, x->diff);
        }
    }

%}

%token NUMBER IDENT 
%token COS SIN
%left LN EXP
%%

REV_AutoDiff : func_def '\n'
    {
        printf("val = %lf\n",chain[all_node-1]->val);
        ReverseAutoDiff(chain);
    }
    ;

func_def : 'f' '(' var_list ')' ':' expr
    {
        node *x = CreateNode();
        chain[all_node++] = x;
        count_node++;
        x->op = ROOT;
        x->reverse[0] = chain[$6];
        calcVal(x);
    }
    ;

var_init : IDENT 
    {
        node *x = CreateNode();
        chain[all_node++] = x;
        count_id++;
        x->op = ID;
        strcpy(x->name,IDNAME);
    }
    '=' NUMBER
    {
        node *x = chain[all_node-1];
        x->val = $2;
    }
    ;

var_list : var_init 
    | var_list ',' var_init
    ;

expr : IDENT
        {
            int x = FindID(IDNAME);
            $$ = x;
        }
    | NUMBER
        {
            node *x = CreateNode();
            chain[all_node++] = x;
            count_node++;
            $$ = all_node;
            x->op = NU;
            x->val = $1;
        }                    
    | expr '+' expr
        {
            node *x = CreateNode();
            chain[all_node++] = x;
            $$ = all_node;
            count_node++;
            x->op = PL;
            x->reverse[0] = chain[$1];
            x->reverse[1] = chain[$3];
            calcVal(x);
        }    
    | expr '-' expr
        {
            node *x = CreateNode();
            chain[all_node++] = x;
            $$ = all_node;
            count_node++;
            x->op = MN;
            x->reverse[0] = chain[$1];
            x->reverse[1] = chain[$3];
            calcVal(x);
        }  
    | expr '*' expr
        {
            node *x = CreateNode();
            chain[all_node++] = x;
            $$ = all_node;
            count_node++;
            x->op = MUL;
            x->reverse[0] = chain[$1];
            x->reverse[1] = chain[$3];
            calcVal(x);
        }  
    | expr '/' expr
        {
            node *x = CreateNode();
            chain[all_node++] = x;
            $$ = all_node;
            count_node++;
            x->op = DIV;
            x->reverse[0] = chain[$1];
            x->reverse[1] = chain[$3];
            calcVal(x);
        }  
    | '-' expr
        {
            node *x = CreateNode();
            chain[all_node++] = x;
            $$ = all_node;
            count_node++;
            x->op = UMN;
            x->reverse[0] = chain[$2];
            calcVal(x);
        }  
    | '(' expr ')'
        {
            $$ = $2;
        }  
    | expr '^' expr
        {
            node *x = CreateNode();
            chain[all_node++] = x;
            $$ = all_node;
            count_node++;
            x->op = P;
            x->reverse[0] = chain[$1];
            x->reverse[1] = chain[$3];
            calcVal(x);
        }  
    | EXP '(' expr ')'
        {
            node *x = CreateNode();
            chain[all_node++] = x;
            $$ = all_node;
            count_node++;
            x->op = EX;
            x->reverse[0] = chain[$3];
            calcVal(x);
        }  
    | LN '(' expr ')'
        {
            node *x = CreateNode();
            chain[all_node++] = x;
            $$ = all_node;
            count_node++;
            x->op = L;
            x->reverse[0] = chain[$3];
            calcVal(x);
        }  
    | SIN '(' expr ')'
        {
            node *x = CreateNode();
            chain[all_node++] = x;
            $$ = all_node;
            count_node++;
            x->op = S;
            x->reverse[0] = chain[$3];
            calcVal(x);
        }  
    | COS '(' expr ')'
        {
            node *x = CreateNode();
            chain[all_node++] = x;
            $$ = all_node;
            count_node++;
            x->op = C;
            x->reverse[0] = chain[$3];
            calcVal(x);
        }  
    ;
%%

extern FILE *yyin;
int main()
{
    yyin = stdin;
    return yyparse();
}

int yywrap(){
    return 1;
}
