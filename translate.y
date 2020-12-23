%{
    #include <ctype.h>
    #include <stdio.h>
    #include <string.h>
    #include <lex.yy.c>
    #include <math.h>
    #define YYSTYPE double
    int yyparse(void);
    int count_id = 0;
    int count_node = 0;
    int all_node = 0;

    enum OP {root,ID,num,plus,minus,uminus,div,mul,P,L,C,S,EX};

    typedef struct Node{
        double diff;
        double val;
        char name[10];
        OP op;
        struct Node *reverse[10];
    }node;

    node* CreateNode(){
        node* x = (node*)malloc(sizeof(node));
        x->diff = x->val = 0;
        for(int i = 0; i < 10; i++){
            name[i] = '\0';
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

    node *chain[40];

    void calcVal(node *n){
        switch(n->op){
            case root:
                n->val = n->reverse[0]->val;
                break;
            case plus:
                n->val = n->reverse[0]->val + n->reverse[1]->val;
                break;
            case minus:
                n->val = n->reverse[0]->val - n->reverse[1]->val;
                break;
            case uminus:
                n->val = -n->reverse[0]->val;
                break;
            case div:
                n->val = n->reverse[0]->val / n->reverse[1]->val;
                break;
            case mul:
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
                case root:
                x->reverse[0]->diff = 1;
                test(x);
                break;
                case plus:
                x->reverse[0]->diff += x->diff;
                x->reverse[1]->diff += x->diff;
                break;
                case minus:
                x->reverse[0]->diff += x->diff;
                x->reverse[1]->diff += -x->diff;
                break;
                case div:
                x->reverse[0]->diff += x->diff / x->reverse[1]->val;
                x->reverse[1]->diff += x->diff * x->reverse[0]->val /pow(x->reverse[1]->val,2);
                break;
                case mul:
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
                x->reverse[0]->diff += pow(e,n->reverse[0]->val) * x->diff;
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

%token NUMBER SIN IDENT EOLN FUNC COMMA COLON
%token PLUS MINUS POW OPENBRACKET CLOSEBRACKET 
%token COS 
%token ASSIGN 
%left PLUS MINUS
%left MUL DIV
%left LN EXP
%%

REV_AutoDiff : func_def EOLN 
    {
        printf("val = %lf\n",chain[all_node-1]->val);
        ReverseAutoDiff(x);
    }
    ;

func_def : FUNC OPENBRACKET var_list CLOSEBRACKET COLON expr
    {
        node *x = CreateNode();
        chain[all_node++] = x;
        count_node++;
        x->op = root;
        x->seq = all_node-1;
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
    ASSIGN NUMBER
    {
        node *x = chain[all_node-1];
        x->val = $2;
    }
    ;

var_list : var_init 
    | var_list COMMA var_init
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
            x->op = num;
            x->val = $1;
        }                    
    | expr PLUS expr
        {
            node *x = CreateNode();
            chain[all_node++] = x;
            $$ = all_node;
            count_node++;
            x->op = plus;
            x->reverse[0] = chain[$1];
            x->reverse[1] = chain[$3];
            x->val = calcVal(x);
        }    
    | expr MINUS expr
        {
            node *x = CreateNode();
            chain[all_node++] = x;
            $$ = all_node;
            count_node++;
            x->op = minus;
            x->reverse[0] = chain[$1];
            x->reverse[1] = chain[$3];
            x->val = calcVal(x);
        }  
    | expr MUL expr
        {
            node *x = CreateNode();
            chain[all_node++] = x;
            $$ = all_node;
            count_node++;
            x->op = mul;
            x->reverse[0] = chain[$1];
            x->reverse[1] = chain[$3];
            x->val = calcVal(x);
        }  
    | expr DIV expr
        {
            node *x = CreateNode();
            chain[all_node++] = x;
            $$ = all_node;
            count_node++;
            x->op = div;
            x->reverse[0] = chain[$1];
            x->reverse[1] = chain[$3];
            x->val = calcVal(x);
        }  
    | MINUS expr
        {
            node *x = CreateNode();
            chain[all_node++] = x;
            $$ = all_node;
            count_node++;
            x->op = uminus;
            x->reverse[0] = chain[$2];
            x->val = calcVal(x);
        }  
    | OPENBRACKET expr CLOSEBRACKET
        {
            $$ = $2;
        }  
    | expr POW expr
        {
            node *x = CreateNode();
            chain[all_node++] = x;
            $$ = all_node;
            count_node++;
            x->op = P;
            x->reverse[0] = chain[$1];
            x->reverse[1] = chain[$3];
            x->val = calcVal(x);
        }  
    | EXP OPENBRACKET expr CLOSEBRACKET
        {
            node *x = CreateNode();
            chain[all_node++] = x;
            $$ = all_node;
            count_node++;
            x->op = EX;
            x->reverse[0] = chain[$3];
            x->val = calcVal(x);
        }  
    | LN OPENBRACKET expr CLOSEBRACKET
        {
            node *x = CreateNode();
            chain[all_node++] = x;
            $$ = all_node;
            count_node++;
            x->op = L;
            x->reverse[0] = chain[$3];
            x->val = calcVal(x);
        }  
    | SIN OPENBRACKET expr CLOSEBRACKET
        {
            node *x = CreateNode();
            chain[all_node++] = x;
            $$ = all_node;
            count_node++;
            x->op = S;
            x->reverse[0] = chain[$3];
            x->val = calcVal(x);
        }  
    | COS OPENBRACKET expr CLOSEBRACKET
        {
            node *x = CreateNode();
            chain[all_node++] = x;
            $$ = all_node;
            count_node++;
            x->op = C;
            x->reverse[0] = chain[$3];
            x->val = calcVal(x);
        }  
    ;
%%

extern FILE *yyin;
int main()
{
    yyin = stdin;
    return yyparse();
}
void yyerror(char *s)
{
    fprintf(stderr,"%s",s);
}

int yywrap(){
    return 1;
}
