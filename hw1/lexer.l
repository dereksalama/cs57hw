%{
#include "tokens.h"
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
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
					char string_buf[2048];
					char *string_buf_ptr = string_buf;

<*>\/\*				yy_push_state(COMMENT);
<COMMENT>\*\/ 		yy_pop_state();
<COMMENT>.|\n		yymore();

<*>{hexnumber}			return printNum();
<*>{octalnumber}		return printNum();
<*>{decimal}			return printNum();

<INITIAL,NESTED_EXPRESSION>{id}\[		{
							yy_push_state(NESTED_EXPRESSION);
							*(string_buf_ptr++) = '*';
							*(string_buf_ptr++) = '(';
							strncpy(string_buf_ptr, yytext, yyleng - 1);
							*(string_buf_ptr++) = '+';
							*(string_buf_ptr++) = '(';
							yymore();
						}

<NESTED_EXPRESSION>\]	{
							yy_pop_state();
							*(string_buf_ptr++) = ')';
							*(string_buf_ptr++) = ')';
							string_buf_ptr = string_buf;
							printf("%s",string_buf_ptr);
							return 0;
						}
<NESTED_EXPRESSION>.	yymore();


<<EOF>>				return EOFTOKEN;

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
