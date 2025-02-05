# Learnings

A collection of thoughts and observations from this exercise to carry forward into future designs.

As an overall observation, the language syntax is an initial barrier to the standard library. The syntax and semantics are akin to physical beauty whereas the standard library is a language's personality. The Ruby language exemplifies this characteristic. What makes Ruby great isn't its basic syntax but the expressiveness of the overall language. Its flexible syntax makes it approachable but it's the integration and interopability of its objects that make it so easy to work with. Being able to do meta-programming, implement your own class operators, and meta-programming are what make Ruby a great language to use. It's the syntax and standard library working in harmony that makes for a truly expressive and enjoyable language to use.

Go took a language like C and asked "Why are there so many looping statements?" and decided to make a single `for` statement with a flexible syntax. Other modern languages, like Javascript and Ruby, took this a step further and added methods to array objects to perform looping over elements. For a developer, it feels much more natural and expressive to use a `array.forEach((element) => {})` loop over a `for (int i = 0; i < len(array); i++) { element = array[i]}` loop, even though they effectively do the same thing. Abstracting away tedium (boilerplate) is a enjoyable. There's also something more natural about handling each element at a time, rather than indexing it.

Minic as a way to explore language syntax demonstrates this case. It's not so much the language that makes it useless but the lack of a standard library to allow anything meaningful to be constructed. Creating a good standard library is what's truly hard and would likely take the most amount of time. That's something I've underappreciated.

Overall, I appreciate Minic's simplicity. The inspiration I hope to take into my next project is the combination of paring a language down to its absolute essense, building a sytax that feels familiar and easy, and building a standard library that brings out the best of the language.


## Implementation Language

Ruby is absolutely fantastic for getting an idea off the ground. Writing a lexer, parser, and semantic analyzer isn't incredibly difficult to write by hand and gives a lot of flexibility. If writing a compiler I wanted to release to the public, I would probably consider C, Rust, or Go as the implemenation language as I could compile native binaries and libaries.

Go is bootstrapped in C but is now self-compiling. Similarly, Rust is bootstrapped in OCaml but is now self-compiling. JVM languages are typically bootstrapped with Java. Python's reference implementation is written in C. I would prefer to install a standalone compiler binary rather than a language dependency to run a compiler script.

Sorbet caught a lot of early mistakes and I'm glad I used it.


## Paradigm

Minic is procedural and imperative. Elements are missing from the language that would allow functional or object-oriented programming from being possible. In the case of the functional paradigm, if a user only used methods, they could employ the paradigm. However, the use of variables to define and hold state means that it can not be purely functional. Likewise, the complete lack of complex data types, namely structures, means that object-oriented programming is impossible.

I think that a language should allow for non-pure functional programming but should not strive for purity. Practically, most programs will need state and using closures to hold state seems like a needless mental hurdle.


## Types

Non-scalar types like strings, structs, and arrays are integral to a language. Having only scalar types or very basic strings is not adequate for achieving anything of any practical use.

C strings are arrays of characters terminated by a NUL character. Lacking arrays and scalar sub-type (character) makes representing this somewhat difficult. The implementation of using a fixed (at runtime) character array makes mutations like concatenation impossible.

Type inferance can save a lot of typing. Performing an assignment at the time of variable declaration should make the type obvious.

Minic's lack of being able to declare variables as immutable/mutatable (constant), setting the signedness of an integer, or allowing references to object is similarly restrictive. Other considerations are being able to promote a variable to a semi-permanent state (C's static) or suspending execution by `yield`'ing from blocks are useful tools missing from the language.

Functions types are missing. See: [Declarations](#declarations) and [Functions](#functions) for more thoughts on this subject.


### Mutability

In Minic, all variables are effectively mutatable, though strings should not have been. Being able to set constants would be useful as making data immutable can be a handy safety net. There are many ways to achieve that:

- using modifiers to declare a variable as a constant: `const int i = 0;`
- defaulting to immutable, and requiring flagging a variable as mutation: `mut int i = 0;`
- declaring constants

### Zero Values

I think ensuring declared variables have a zero value felt very good. It eliminates the undefined behaviour of declaring a value and using it without first assigning a value. It makes things feel safe.


## Declarations

Declaring a type, followed by an identifier, means that the type of declaration can't be resolved until at least the third token, whereby it may be a terminator, assignment operator, or a parenthesis. This makes parsing unnecessarily complicated.

Instead, use of a keyword makes parsing much simpler. For example, Javascript's `var`, `let` and `function`.

Some languages allow type inference, eliding the type in a declaration. Some take it a step further and skip the keyword. For instance, Go specifies a difference between `i := 0` (declaration with inferred type) and assignment `i = 0` (an error, if `i` is not defined).

Amusingly, languages based on LISP don't have variables but do use `define` for function declarations.

Encapsulation, binding methods to objects, isn't possible in C. While it is just synatical sugar, it can help develop a better mental model. For instance, in a practical sense, C's `void method(struct object* receiver) {}` is effectively the same as a bound reciever `void (struct object* receiver) method() {}`. In many languages, classes represent encapsulation by allowing a developer to define both data and methods on a single object.

The lack of pointers, passing values by reference, is also keenly felt in Minic.


## Objects

Objects are common, if not integral, to modern programming languages but add much more complexity to a language. They necessarily require the concept of instantiation, pointers, memory management, receivers, etc. C feels very much like being just a step above assembly whereas most modern languages are far more abstract, hiding away the complexity of word sizes, stack pointers, and memory management.

A future iteration of Minic, or an entirely different language, feels like it should have objects. Whether it's a simple building block of taking a C-like struct that methods can be bound to, or full on classes like `C++` and friends, is a decision to be made. Both have advantages and disadvantages.

One key thing that sticks in my mind is that an object should know how to clean itself up (free up memory).

Making everything an object, like Ruby, is very appealing from a design point of view. Having an Integer object on which messages like `+` or `-` are defined, make the language syntax itself incredibly simple. It also means these "operators" can take on new meaning, depending how each object chooses to implement them. They are natually exclusive (incompatible types). Unfortunately, this comes at the cost of generate a lot of garbage. What appears to be a literal is in fact an object allocated in memory and it doesn't take long for that to get out of hand. This requires a great deal of effort and complexity to wrangle at runtime.


## Operators

Languages descended from C all use operators that require special handling by the language. Ruby (inspired by Smalltalk?) and LISP do not use operators in the conventional sense, rather they are messages that can be sent to any object. This could potentially make lexing and parsing simpler by treating these characters as identifiers that are method calls. This removes binary expressions entirely from the language. Conversely, parsing could be become more challenging if the infix notation for operations is still desired, since an implicit receiver would need to be employed. Example: `1 + 2` becomes `1.+(2)`.


## Blocks

Minics blocks feel very standard and for the most part make a lot of sense. Not enforcing a semicolon terminal character made parsing a little more difficult but is otherwise a welcome feature common in many languages. Nested blocks, while possible, don't feel useful outside of statements like `if` and `while` that require block. Using braces to deliniate blocks feels comfortable to me and I'm not sure I see any reason to change that at this stage.

### Scope

Minic is lexically scoped and I see no reason to change that. It's intuitive and familiar.


## Functions

Minics functions are just like C's, and they're perfectly servicable. Compared to modern high-level langauges, there a lot of omitions: default values, optional arguments, keyword arguments, variadic arguments, etc.


# Future Language Thoughts

Three languages stand out to me for being interesting in different ways: Go, Ruby, and LISP. I've tried or used many different langauges. BASIC, C, C++, Java, PHP, and so on, but those three each taught me something the others didn't. What I liked, rather than what I didn't.

I love how with LISP s-expressions that operators behave like functions. The operator or identifier comes first and arguments after. The parentheses around expressions makes for natural nesting. Example: `(+ 1 2 (* 3 4))`. Unfortunately, this diverges from how most people write mathematical expression, eschewing infix notation for prefix. I like how functional methods should not have side effects and that functions are a first class citizen.

Go demonstrated how you can take a very C-like, "closer to the metal", language and pare it down to the bare essentials. I appreciated how they tried to take C and strip out repetative keywords. For instance, there's only one looping contruct `for` with a flexible syntax. I also love how they handle interfaces where you don't declare what interface(s) a class implements but rather it does something close to duck-typing where a class can implicitly match an interface, after the fact. I love that the interface fits the class rather than the class fits the interface. That has lead to complications around nil interfaces and the empty interface. Go made tooling a first class citizen, defining the preferred formatting of the language.

Ruby demonstrates that you can make a "toy" language, a language designed to be erganomic and fun, and make it something powerful. Ruby really shows that it's not the language itself that makes it great but the standard library. With parentheses being optional, being able to choose between keywords and braces for blocks, and having statements that behave like expressions (like in functional languages), Ruby lets the developer do what they want. It's a very freeing language. But that's not the real success. The fact that everything is a class is truly amazing. That any you write class can be adapted to use almost any operator is awesome. Being able to monkey-patch something core to the language is incredible. Unfortunately, all this power comes with a downside. Everything being an object means that a lot of garbage gets created. The GC has to work pretty hard in poorly optimized applications. Memory bloat becomes a problem. Thankfully, memory is pretty cheap in our virtual server world, but it's still a concern.

I think, somehow, I'd love to take all the best parts of these languages and create something truly amazing. A love-child of all their best elements. I have no idea what that would be but it intrigues me. I think it'll take a lot of attempts to get right, or maybe might be something impossible.

All of this made me realize there's three pillars to a great language.


## The 3 Pillars of a Good Language

1. They have limited operators and keywords. Get more out of less. The less you have to think about the language, the better.
2. The standard library makes or breaks a language. Again, do more (library) with less (syntax, grammer).
3. Tooling takes a good language and makes it great. Formatting, linting, LSP (Language Server Protocol), etc.
