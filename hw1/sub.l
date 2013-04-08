%{
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#define COMMENT_ERROR "Error - Comment not closed."
#define ARRAY_ERROR "Error - '[' not matched."

void printNum();
void printText();
int isEmpty(char *str);
%}

%option stack
%x COMMENT
%x ARRAY
%x NESTED_ARRAY

white				[ \t\n]
nonwhite			[^ \t\n]
anything			(.|\n)
digit 				[0-9]

hexletter 			[a-fA-F]
hexnumber 			0(x|X)({digit}|{hexletter})+

octaldigit 			[0-7]
octalnumber 		0{octaldigit}*

decimal 			[1-9]{digit}*

letter 				[a-zA-Z]
id 					({letter}|_)({letter}|{digit}|_)*

comment 			\/\*{anything}*\*\/
%%
						char arrayId[1024];
						char arrayBuf[1024];
						char *bufPtr;
<INITIAL,ARRAY,NESTED_ARRAY>{comment}				{
								yy_push_state(COMMENT);
								yyless(2);
							}
<COMMENT>\*\/ 				yy_pop_state();
<COMMENT>{anything}			/*do nothing*/

<INITIAL,ARRAY,NESTED_ARRAY>\/\*						{
								printf("%s\n", COMMENT_ERROR);
								yyterminate();
							}

<INITIAL,ARRAY,NESTED_ARRAY>{hexnumber}			printNum();
<INITIAL,ARRAY,NESTED_ARRAY>{octalnumber}		printNum();
<INITIAL,ARRAY,NESTED_ARRAY>{decimal}			printNum();

						
<INITIAL>{id}\[{anything}*\]		{
							yy_push_state(ARRAY);
							int i = 0;
							while(yytext[i++] != '[');
							yyless(i);
							yytext[yyleng - 1] = '\0';
							strcpy(arrayId, yytext);
						}
<ARRAY,NESTED_ARRAY>{id}\[{anything}*\]		{
							yy_push_state(NESTED_ARRAY);
							/*we know something is in the array so cpy*/
							appendToPtr(bufPtr, "*(");
							appendToPtr(bufPtr, arrayId);
							appendToPtr(bufPtr, "+(");
							int i = 0;
							while(yytext[i++] != '[');
							yyless(i);
							yytext[yyleng - 1] = '\0';
							strcpy(arrayId, yytext);
						}
<NESTED_ARRAY>\]			{
							yy_pop_state();
							if(isEmpty(bufPtr)) {
								appendToPtr(bufPtr, arrayId);
								appendToPtr(bufPtr, "[]");
							} else {
								appendToPtr("))");
							}
						}		
<ARRAY>\]				{
							if(isEmpty(arrayBuf)) {
								printf("%s", arrayId);
								printf("[]");
							} else {
								printf("%s",arrayBuf);
								printf("))");
							}
							yy_pop_state();
							bufPtr = arrayBuf;
						}
<INITIAL,ARRAY>{id}\[   {
							printf("%s\n", ARRAY_ERROR);
							yyterminate();
						}					


<INITIAL,ARRAY,NESTED_ARRAY>{anything}	printText();

%%
int isEmpty(char *str) {
	char *ptr = str;
	for(;*ptr != '\0'; ptr++) {
		if(!(*ptr == ' ' || *ptr == '\t' || *ptr == '\n')) {
			return 0;
		}
	}

	return 1;
}

void appendToPtr(char *ptr, char *str) {
	int i = 0;
	while (str[i] != '\0') {
		*(ptr++) = str[i++];
	}
}

void printNum() {
	long num;
	num = strtol(yytext, NULL, 0);
	printf("%#lx", num);
}

void printText(){
	printf("%s", yytext);
}
