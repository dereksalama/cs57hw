%{
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#define COMMENT_ERROR "Error - Comment not closed."
#define ARRAY_ERROR "Error - '[' not matched."

void printNum();
void printText();
%}

%option stack
%x COMMENT
%x NESTED_EXPRESSION

white				[ \t\n]
notwhite			[^ \t\n]
anything			(.|\n)
digit 				[0-9]
integer 			{digit}+
signedint 			[-+]?{integer}

hexletter 			[a-fA-F]
hexnumber 			0(x|X)({digit}|{hexletter})+

octaldigit 			[0-7]
octalnumber 		0{octaldigit}*

decimal 			[1-9]{digit}*

letter 				[a-zA-Z]
id 					({letter}|_)({letter}|{digit}|_)*

comment 			\/\*{anything}*\*\/
%%
<*>{comment}				{
								yy_push_state(COMMENT);
								yyless(2);
							}
<COMMENT>\*\/ 				yy_pop_state();
<COMMENT>{anything}			/*do nothing*/

<*>\/\*						{
								printf("%s\n", COMMENT_ERROR);
								yyterminate();
							}

<*>{hexnumber}			printNum();
<*>{octalnumber}		printNum();
<*>{decimal}			printNum();

<INITIAL,NESTED_EXPRESSION>{id}\[({comment}|{white})*\] {
							int i = 0;
							while(yytext[i++] != '[');
							yytext[i - 1] = '\0';
							printText();
							printf("%s","[]");
						} 
<INITIAL,NESTED_EXPRESSION>{id}\[{anything}+\]		{
							yy_push_state(NESTED_EXPRESSION);
							printf("%s","*(");
							int i = 0;
							while(yytext[i++] != '[');
							yyless(i);
							yytext[yyleng - 1] = '\0';
							printText();
							printf("%s", "+(");
						}
<INITIAL,NESTED_EXPRESSION>{id}\[ {
							printf("%s\n", ARRAY_ERROR);
							yyterminate();
						}					

<NESTED_EXPRESSION>\]	{
							yy_pop_state();
							printf("%s", "))");
						}

<NESTED_EXPRESSION,INITIAL>{anything}	printText();

%%

void printNum() {
	long num;
	num = strtol(yytext, NULL, 0);
	printf("%#lx", num);
}

void printText(){
	printf("%s", yytext);
}
