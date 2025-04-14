_G.addSnippet("defg", function()
    local filename = vim.api.nvim_buf_get_name(0)
    local guard = vim.fn.fnamemodify(filename, ":t")
    guard = guard:gsub("%.", "_")
    local str = [[#ifndef __%s__
#define __%s__

$0

#endif]]
    return string.format(str, guard, guard)
end)

_G.addSnippet(
    "main",
    [[#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    $1
    return EXIT_SUCCESS;
}]]
)

_G.addSnippet("if", "if (${1:1}) {\n\t$2\n}")
_G.addSnippet("ifelse", "if (${1:1}) {\n\t$2\n} else {\n\t$3\n}")
_G.addSnippet("switch", [[switch (${1:expr}) {
    case ${2:0}: $3
    break;
    default: $4
    break;
}]])

_G.addSnippet("while", "while (${2:1}) {\n\t$1\n}")
_G.addSnippet("dowhile", "do {\n\t$1\n} while (${2:0});")
_G.addSnippet("for", "for ($1;$2;$3) {\n\t$4\n}")
_G.addSnippet("forc", "for (${1:size_t} ${2:i} = ${3:0}; $2 < ${4:count}; $2${5:++}) {\n\t$6\n}")

_G.addSnippet("fn", "${2:void} ${1:fn}(${3:void}) {\n\t$4\n}")
_G.addSnippet("fnd", "${2:void} ${1:fn}(${3:void})")
_G.addSnippet("struct", "typedef struct {\n\t$2\n} ${1:Name};")
_G.addSnippet("union", "typedef union {\n\t$2\n} ${1:Name};")
_G.addSnippet("enum", "typedef enum {\n\t$2\n} ${1:Name};")
_G.addSnippet("malloc", "malloc(sizeof(${1:int}) * ${2:10});")
_G.addSnippet("printf", "printf(\"${1:%s}\\n\"$2);")
_G.addSnippet("printvar", "printf(\"$1 = %${2:d}\\n\", ${1:var}$3);")
_G.addSnippet("arrlen", "(sizeof ${1:int} * ${2:size})")
