%{
#include "tokens.h"

%}

%x code
%x rules
%x comment

white [ \t\n]+
letter [a-zA-Z]
digit [0-9]
definedPattern '{'({letter}|{digit})+'}'
pattern ('['.+']')|{definedPattern}

%%

{white}				/* ignore */

"%{"				BEGIN(code);
<code>"%}"			BEGIN(INITIAL);
<code>.*			return CODETOKEN;

"%%"				BEGIN(rules);
<rules>"%%"			BEGIN(code);
<rules>.*			/* skip for now */
<<EOF>>				return EOFTOKEN;
%%