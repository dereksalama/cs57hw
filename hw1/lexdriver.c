#include <stdio.h>
#include "tokens.h"
extern char *yytext;
extern int yyleng;

int main(void)
{
    int token;
    while((token = yylex()) != EOFTOKEN) {
        if (token != COMMENTTOKEN)
            printf("%s", yytext);
    }

    printf("%s", "\n");
    return 0;
}