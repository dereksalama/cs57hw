%{
#include "tokens.h"
#include <string.h>
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
<COMMENT>.|\n		return COMMENTTOKEN;

<*>{hexnumber}			return NUMTOKEN;
<*>{octalnumber}		return NUMTOKEN;
<*>{decimal}			return NUMTOKEN;

<INITIAL,NESTED_EXPRESSION>{id}\[		{
							yy_push_state(NESTED_EXPRESSION);
							*(string_buf_ptr++) = '*';
							*(string_buf_ptr++) = '(';
							strncpy(string_buf_ptr, yytext, yyleng - 1);
							*(string_buf_ptr++) = '+';
							*(string_buf_ptr++) = '(';
							yytext = string_buf;
							return EXPRESSIONTOKEN;
						}

<NESTED_EXPRESSION>\]	{
							yy_pop_state();
							*(string_buf_ptr++) = ')';
							*(string_buf_ptr++) = ')';
							yytext = string_buf;
							string_buf_ptr = string_buf;
							return EXPRESSIONTOKEN;
						}
<NESTED_EXPRESSION>.	return EXPRESSIONTOKEN;


<<EOF>>				return EOFTOKEN;

%%
