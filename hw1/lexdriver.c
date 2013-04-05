#include <stdio.h>
#include <stdlib.h>
#include "tokens.h"
extern char *yytext;
extern int yyleng;

int main(void)
{
    int token;
    long hexvalue;
    while(1) {
        token = yylex();
        switch(token) {
            case EOFTOKEN:
                //print endline for nice formatting
                printf("%s", "\n");
                return 0;
            case NUMTOKEN:
                hexvalue = strtol(yytext, NULL, 0);
                printf("%#lx", hexvalue);
                break;
            default:
                printf("%s", yytext);
                break;
        }
    }


    return 0;
}