shell-router
============

Express.js-esque routing for script arguments

Copyright
---------
(C) 2015-2017 Jeff Walter <jeff@404ster.com>, http://jeffw.org/

License
-------

The MIT License (MIT)

Copyright (c) 2015-2017 Jeff Walter <jeff@404ster.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

Contributions
-------------
*None yet*

Requirements
------------
* `bash` >= 3.x
* `grep` with `-E` support
* `sed`

Seriously, that's it. I'm as shocked as you are.

Usage
-----

* `shellrouteAdd <COMMAND> <ROUTE>`:
    * `<COMMAND>`: When the route matches this command will be called any parameters passed as `eval`able strings.
    * `<ROUTE>`: This is what the command line arguments will be matched against. It follows the same idea as Express.js with some additions.
        * `::<OPTIONS>*` - An optional set of options that must be the last element of the route. Options are separated with commas, not spaces. The syntax for the options is as follows:
            * `<OPTION>:` - An option that requires an argument. Beware, if a user fails to provide the argument and follows the option with another option, the second option will be interpreted as the argument. So ALWAYS check input. Assigns value to `OPT_<OPTION>`.
            * `<OPTION>` - An option that can be thought of as a flag. Assigns `1` to `OPT_<OPTION>`.
        * `::<OPTIONS>+` - A required set of options that must be the last element of the route. Options are separated with commas, not spaces. The syntax for the options is as follows:
            * `<OPTION>:` - An option that requires an argument. Beware, if a user fails to provide the argument and follows the option with another option, the second option will be interpreted as the argument. So ALWAYS check input. Assigns value to `OPT_<OPTION>`.
            * `<OPTION>` - An option that can be thought of as a flag. Assigns `1` to `OPT_<OPTION>`.
        * `:<NAME>*` - An optional parameter that captures the remainder of arguments, if any. This must be the last element of the route. Assigns remaining arguments to `ARGV_<NAME>` as a string.
        * `:<NAME>+` - A required parameter that captures the remainder of arguments. This must be the last element of the route. Assigns remaining arguments to `ARGV_<NAME>` as a string.
        * `:<NAME>@` - A required set of parameters that captures the remainder of arguments. This must be the last element of the route. Assigns remaining arguments to `ARGV_<NAME>` as an array.
        * `:<NAME>?` - An optional parameter that captures only the last argument. This must be the last element of the route. Assigns value to `ARG_<NAME>`.
        * `:<NAME>` - A required parameter that captures one argument. Assigns value to `ARG_<NAME>`.
        * `<STRING>?` - An optional static parameter. Assigns `1` to `STATIC_<STRING>`.
        * `<STRING>^` - A required static parameter. Assigns `1` to `STATIC_<STRING>`.
        * `<STRING>` - A required static element.
* `shellrouteProcess <ARGS...>`:
    * `<ARGS...>` - The arguments you want to test your routes against. Typically you'll want to take from the command line so you'd use `"${@}"`.

Routes are evaluated in the order they are defined.

Example(s)
----------

    #!/bin/bash

    source shell-router.lib.sh

    handlerHelp() {
        # Set environment variables for any passed parameters
        eval "${@}"

        if [ -n "${ARG_extra}" ]; then
            echo "Extra help!"
        else
            echo "Help!"
        fi
    }
    handlerHelpCommand() {
        # Set environment variables for any passed parameters
        eval "${@}"

        if [ -n "${ARG_extra}" ]; then
            if [ -n "${ARG_amount}" ]; then
                echo "A ${ARG_amount} extra help for ${ARG_command}!"
            else
                echo "Extra help for ${ARG_command}!"
            fi
        else
            echo "Help for ${ARG_command}!"
        fi
    }
    handlerDescribe() {
        # Set environment variables for any passed parameters
        eval "${@}"

        echo "You want me to describe ${ARG_target}? Sorry, I can't do that."
    }
    handlerDescribeHelp() {
        echo "Help me describe how to help you."
    }
    handlerStory() {
        # Set environment variables for any passed parameters
        eval "${@}"

        if [ -n "${ARG_target}" ]; then
            echo "You want me to tell you a story about ${ARG_target}? Once upon a time..."
        else
            echo "You want me to tell you a story? Once upon a time..."
        fi
    }

    shellrouteAdd handlerHelp "help extra?"
    shellrouteAdd handlerHelpCommand "help :command extra? :amount?"
    shellrouteAdd handlerDescribeHelp "describe help"
    shellrouteAdd handlerDescribe "describe :target+"
    shellrouteAdd handlerStory "story :target*"

    if ! shellrouteProcess "${@}"; then
        echo "Error: Unknown command. Try help"
        exit 1
    fi

    exit 0
