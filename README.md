Thud
====
— when you Bash hard

Thud is a library of modules aimed at making general Bash programming easier.
It only concerns itself with augmenting the language and the built-in library.
Among the included modules and functions are:

    thud_arr.sh     - Array operations:
                      push, pop, peek into an indexed array; copy, convert
                      to/from a string either an indexed or an associative
                      array as a whole.
    
    thud_attrs.sh   - Attribute set operations (those set with "set"):
                      push/pop attribute state to/from a global state stack.

    thud_opts.sh    - Option set operations (those set with "shopt"):
                      push/pop option state to/from a global state stack.

    thud_strict.sh  - Operations on "strict" mode (a set of attributes and
                      options improving error checking):
                      enable/disable, push/pop state to/from a global state
                      stack.

    thud_func.sh    - Function operations:
                      copy, rename functions.

    thud_cmd.sh     - Operations on commands:
                      execute commands with/without strict mode, ignoring exit
                      status; define functions executing commands as such.

    thud_misc.sh    - Miscellaneous functions:
                      print backtraces, abort execution, verify programming
                      assertions, unindent blocks of text, etc.

    thud_trace.sh   - Debug tracing support:
                      enable/disable trace output via DEBUG trap,
                      push/pop tracing state to/from a global state stack,
                      disable tracing of functions matching glob patterns.

    thud_traps.sh   - Trap set operations:
                      push/pop trap state to/from a global state stack.

Installing
----------

Requirements:

* Bash >= 3.2
* GNU Awk >= 3.1 (for thud_unindent only)

Installing from Git (autotools required):

    ./bootstrap && ./configure && make install

Installing from distribution tarball:

    ./configure && make install

Usage
-----

Add library location to PATH:

    . <(thud-env || echo exit 1)

Source modules:

    . thud_misc.sh
    . thud_strict.sh
    . thud_arr.sh
    # Etc.

Running from the source tree requires the "src" directory in PATH.
