#include <stdio.h>
#include <stdlib.h>
#include "tokens.h"
extern char *yytext;
extern int yyleng;

int main(void)
{
    int token;
    while ((token = yylex()) != EOFTOKEN);
    printf("\n");
    return 0;
}