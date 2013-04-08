%{
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#define COMMENT_ERROR "Error - Comment not closed."
#define ARRAY_ERROR "Error - '[' not matched."

void printNum();
void printNumToString(char *dest);
void printText();
void appendToPtr(char *ptr, char str[]);
int isEmpty(char *str);
void setToLast(char* ptr, char str[]);
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

<INITIAL>{hexnumber}		printNum();
<INITIAL>{octalnumber}		printNum();
<INITIAL>{decimal}			printNum();
<ARRAY,NESTED_ARRAY>{hexnumber} printNumToString(arrayBuf);
<ARRAY,NESTED_ARRAY>{octalnumber}	printNumToString(arrayBuf);
<ARRAY,NESTED_ARRAY>{decimal} printNumToString(arrayBuf);

						
<INITIAL>{id}\[{anything}*\]		{
							yy_push_state(ARRAY);
							bufPtr = arrayBuf;
							memset(arrayBuf, 0, sizeof arrayBuf);

							int i = 0;
							while(yytext[i++] != '[');
							yyless(i);
							yytext[yyleng - 1] = '\0';
							strcpy(arrayId, yytext);
						}
<ARRAY,NESTED_ARRAY>{id}\[{anything}*\]		{
							yy_push_state(NESTED_ARRAY);
							/*we know something is in the array so cpy*/
							strcat(arrayBuf, "*(");
							strcat(arrayBuf, arrayId);
							strcat(arrayBuf, "+(");
							setToLast(bufPtr, arrayBuf);

							int i = 0;
							while(yytext[i++] != '[');
							yyless(i);
							yytext[yyleng - 1] = '\0';
							strcpy(arrayId, yytext);
						}
<NESTED_ARRAY>\]		{
							yy_pop_state();
							if(isEmpty(bufPtr)) {
								strcat(arrayBuf, arrayId);
								strcat(arrayBuf, "[]");
							} else {
								strcat(arrayBuf,"))");
							}
						}		
<ARRAY>\]				{
							if(isEmpty(bufPtr)) {
								printf("%s", arrayId);
								printf("[]");
							} else {
								printf("%s",arrayBuf);
								printf("))");
							}
							yy_pop_state();
						}
<INITIAL,ARRAY>{id}\[   {
							printf("%s\n", ARRAY_ERROR);
							yyterminate();
						}					


<INITIAL>{anything}	printText();
<ARRAY,NESTED_ARRAY>{anything}	{
							strcat(arrayBuf, yytext);
						}

%%
void setToLast(char *ptr, char str[]) {
	int i;
	for(i = 0; str[i] != '\0'; i++);
	ptr = str + i + 1;
}
int isEmpty(char str[]) {
	int i;
	for(i = 0; str[i] != '\0'; i++) {
		char c = str[i];
		if(!(c == ' ' || c == '\t' || c == '\n')) {
			return 0;
		}
	}

	return 1;
}

void appendToPtr(char *ptr, char str[]) {
	int i;
	for(i = 0; str[i] != '\0'; ptr++, i++) {
		*(ptr) = str[i];
	}
	*(++ptr) = '\0';
}

void printNumToString(char *dest) {
	long num;
	char temp[1024];
	num = strtol(yytext, NULL, 0);
	sprintf(temp, "%#lx", num);
	strcat(dest, temp);
}
void printNum() {
	long num;
	num = strtol(yytext, NULL, 0);
	printf("%#lx", num);
}

void printText(){
	printf("%s", yytext);
}
