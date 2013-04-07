%{
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#define COMMENT_ERROR "Premature EOF. Comment not closed."
#define ARRAY_ERROR "Premature EOF. '[' not matched."

int printNum();
int printText();
%}

%option stack
%x COMMENT
%x NESTED_EXPRESSION

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

%%
<*>\/\*				yy_push_state(COMMENT);
<COMMENT>\*\/ 		yy_pop_state();
<COMMENT>.|\n		yymore();

<*>{hexnumber}			return printNum();
<*>{octalnumber}		return printNum();
<*>{decimal}			return printNum();

<INITIAL,NESTED_EXPRESSION>{id}\[		{
							yy_push_state(NESTED_EXPRESSION);
							printf("%s","*(");
							yytext[yyleng - 1] = '\0';
							printf("%s",yytext);
							printf("%s", "+(");
							yymore();
						}

<NESTED_EXPRESSION>\]	{
							yy_pop_state();
							printf("%s", "))");
						}
<NESTED_EXPRESSION,INITIAL>.|\n	return printText();

<COMMENT><<EOF>>				{
							printf("%s", COMMENT_ERROR);
						}
<NESTED_EXPRESSION><<EOF>> {
							printf("%s", ARRAY_ERROR);
						}


%%

int printNum() {
	long num;
	num = strtol(yytext, NULL, 0);
	printf("%#lx", num);
	return 0;
}

int printText(){
	printf("%s", yytext);
	return 0;
}
