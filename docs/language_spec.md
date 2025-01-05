# Minic Language Specification

This language is not meant to be ideal but more of a learning exercise. It is intentially limited. Having globally scoped variables or no notion of visibility (limiting scope) is an intentional flaw for ease of design.

There are no arrays, no complex data types (structures, unions, enums, etc), limited looping mechanisms (`for` or `do...until` loops), limited comparison statements (`switch` or `elsif`), limited comparison operators (`!=`, `<=`, `>=`, etc), limited assignment operators (`+=`, `&=`, etc), limited binary operators (`&`, `|`, etc), limited types (`short`, `long`, `float`, etc), no bitwise operators (`<<`, `>>`, etc), and so on.

With any luck, something more interesting will come out of it.

## Language Specification Format

The language specification uses an EBNF-like syntax as detailed below:

|symbol|description/purpose|
|---|---|
|;  |terminator|
|::=|definition|
|"" |literal, terminating|
|[] |optional; zero or one|
|{} |repetition; zero or more|
|() |grouping|
|...|range of values (inclusive)|

## Program

A Minic program consists of statements and function declarations. It must contain at least one top-level function called `main`. Any variables declared in the program scope are global.

```ebnf
program ::= { declaration | comment } ;
declaration ::= ( variable_decl  “;” ) | function_decl ;
```

## Variable declaration

Integers will probably be 64 bit only. Floating point numbers are 64 bit, double precision values. Since a string can't be indexed, everything is a string. Boolean values can only be `true` or `false`. `void` types represent "nothing". In the case of a function call, a void function would not a return a value. A void variable can be declared but it is meaningless (no operation) since nothing may be assigned to it.

```ebnf
variable_decl ::= type_decl identifier [ “=” expression ] ;
type_decl ::= "void" | “bool” | “int” | “double” | “string” ;
```

Variables that are not assigned a value when declared will be assigned a zero value.
|Type|Zero Value|
|---|---|
|void  |     |
|bool  |false|
|int   |0    |
|double|0.0  |
|string|""   |

## Expressions

Not equal is expressed as the equality binary expression wrapped in a sub-expression and preceded by a negation unary expression. Example: “!(a == b)”

```ebnf
expression ::= literal_expr | unary_expr | binary_expr | sub_expr | function_call | block_expr;
unary_expr ::= “!” | “-” expression ;
binary_expr ::= expression operator expression;
operator ::= arithmetic_operators | logical_operators | comparison_operators;
arithmetic_operators ::= “+” | “-” | “*” | “/” | “%” ;
logical_operators ::= “&&” | “||” :
comparison_operators ::= “==” | “<” | “>” ;
sub_expr ::= “(“ expression “)” ;
```

## Literals

```ebnf
literal_expr ::= bool_literal | int_literal | double_literal | string_literal ;
bool_literal ::= “false” | “true” ;
int_literal ::= “0” | “1” … “9” [ decimal_digit ] ;
decimal_digit ::= “0” … “9” ;
double_literal ::= int_literal “.” decimal_digit [ decimal_digit ] ;
string_literal ::= ‘“‘ { character_literal } ‘“‘ ;
character_literal ::= byte_value | newline ;
```

# Function Calling

Calling a function. Example: `add(16, 26)`;

```ebnf
function_call ::= identifier “(“ argument_list “)” ;
argument_list ::= expression { “,” expression } ;
```

## Function Declaration

Functions may only be declared at the top-level program scope. Parameters are scoped to the function's block scope. See blocks for information on block-level scoping.

```ebnf
function_decl ::= return_type identifier “(“ parameter_list “)” block ;
parameter_list ::= parameter_decl { “,” parameter_decl } ;
parameter_decl ::= type_decl identifier ;
```

Example:

```c
int add(int a, int b) {
  return a + b;
}
```

## Block Expression

A block has its own scope. Technically, this would allow the shadowing of variables (though not recommended). Blocks are not limited to function declarations, loops, and conditionals. You may use them inline. A block may be empty (no statements).

Function parameters are passed into the block at the block-level. Therefore, function parameters may not be shadowed.

```ebnf
block ::= “{“ { statement | block } “}” ;
```

Example:

```c
int i = 0;
{
  i = i + 1;  // parent scope
  int i = 41; // shadowed; block scoped
  i = i + 1;  // i == 42
}
// i == 1
```

## Statements

```ebnf
statement ::= variable_decl | if_statement | while_statement | assignment_statement | return_statement ";" ;
```

## Looping

Looping can only be done with `while` statements. The conditional expression may only resolve to a boolean value.

```ebnf
while_statement ::= “while” “(“ expression “)” block ;
```

To similate a `for` loop, you may write:

```c
int i = 0;
while (i < 10) {
  i = i + 1;
}
```

## Conditionals

There are only `if` statements. The conditional expression may only resolve to a boolean value.

```ebnf
if_statement ::= “if” “(“ expression “)” block ( else_clause );
else_clause ::= “else” block ;
```

## Assignment Statement

Assignments are statements. They may not be used as an expression.

```ebnf
assignment_statement ::= identifier "=" expression ;
```

## Return Statement

From within the context of a function, returns (exits) from the function. A `void` method does not need a return value.

```ebnf
return_statement ::= “return” [ expression ] ;
```

## Comments

Comments start at the beginning of a line (excluding whitespace), contain any number of printable characters (`ANY_PRINTABLE`), and end at the end of the line (`EOL`).

```ebnf
comment :== "//" { ANY_PRINTABLE } EOL ;
```
