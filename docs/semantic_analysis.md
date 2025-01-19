# Semantic Analysis

## Typing

Given the program
```c

int i = 0; // variable declaration

int main() { // function declaration
  bool b = false;
  i = i + 1; // variable assignment statement
}
```

The AST would be parsed into this pseudocode:
```
Program { declarations: {
  VarDecl { identifier: "i", assignment: Integer {
    literal: "0"
  }}
  FuncDecl { identifier: "main", parameters: [], block: [
    VarDecl { identifier: "b", assignment: Boolean {
      literal: "true"
    }},
    AssignmentStmt { identifier: "i", expression: BinaryExpr {
    lhs: Integer, op: "+", rhs: Integer,
    }}
  ]}
}}
```

The scope expected final would be:
```
Program {
  scope: Scope {
    Variable { name: "i", type: :Integer },
    Function { name: main, type: :Integer, parameters: [],
      scope: Scope {
        Variable { name: "b", type: :Boolean }
      }
    }
  }
}
```

Type-checking this program, would follow:

For a Program, check each declaration.

For a VariableDecl, generate its declared type and add it to the current scope.
Next, check the assignment, if not nil, and derive its type. Compare types.
If the expression contains a variable or function reference, look up its type
in the current scope, moving up to the parent scope until nil.

For a FunctionDecl, generate its declared type and add it to the current scope.
Next, check the block. The block's type is the parent function's return type.
Step through each statement. The function's block must terminate with a return
statement that matches the function's return type.

A BinaryExpr would have it's lhs compared with its rhs to ensure they match.
The operator determines the final type of the expression. Equality operators
are of type boolean, and arithmetic operators are type of the operands.

Literals are of a matching basic type.
