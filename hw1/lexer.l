%{
#include "tokens.h"
%}

%x comment

digit [0-9]
hexletter [a-fA-F]
hexnumber 0(x|X)({digit}|{hexletter})+

octaldigit [0-7]
octalnumber 0{octaldigit}*

decimal [1-9]{digit}*

%%

\/\*				BEGIN(comment);
<comment>\*\/ 		BEGIN(INITIAL);
<comment>.|\n		return COMMENTTOKEN;

{hexnumber}			return NUMTOKEN;
{octalnumber}		return NUMTOKEN;
{decimal}			return NUMTOKEN;


<<EOF>>				return EOFTOKEN;

%%
