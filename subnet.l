%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "subnet.tab.h"
%}

digit       [0-9]+
ip          {digit}"."{digit}"."{digit}"."{digit}
whitespace  [ \t\n]+

%%

{ip}          { strcpy(yylval.str, yytext); return IP; }
{whitespace}  { /* ignorar espaços em branco */ }
.             { return yytext[0]; }

%%

int yywrap() {
    return 1;
}
