%{
#include "tokens.h"
%}

%x comment

%%

\/\*				BEGIN(comment);
<comment>\*\/ 		BEGIN(INITIAL);
<comment>.|\n		return COMMENTTOKEN;

<<EOF>>				return EOFTOKEN;

%%
