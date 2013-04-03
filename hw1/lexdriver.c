#include <stdio.h>
#include "tokens.h"
extern char *yytext;
extern int yyleng;

#define OUTPUT_FILE_NAME "output.c"
int main(void)
{
    int token;
    FILE *fp;
    fp = fopen(OUTPUT_FILE_NAME, "w");
    if (fp == NULL) {
    	fprintf(stderr, "Can't open output file.\n");
    	return 1;
    }

    while ((token = yylex()) != EOFTOKEN) {
        if (token <= 256)
            printf("%c (%d): \"%s\" (%d)\n", token, token, yytext, yyleng);
        else if (token == CODETOKEN) {
        	fprintf(fp, "%s", yytext);
        }
    }

    fclose(fp);
    return 0;
}