shell-router
============

Express.js-esque routing for script arguments

Copyright
---------
(C) 2015 Jeff Walter <jeff@404ster.com>, http://jwalter.sh/

License
-------

The MIT License (MIT)

Copyright (c) 2015 Jeff Walter <jeff@404ster.com>

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
        * `:<NAME>*` - An optional parameter that captures the remainder of arguments, if any. This must be the last element of the route.
        * `:<NAME>+` - A required parameter that captures the remainder of arguments. This must be the last element of the route.
        * `:<NAME>?` - An optional parameter that captures only the last argument. This must be the last element of the route.
        * `:<NAME>` - A required parameter that captures one argument.
        * `<STRING>?` - An optional static parameter.
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
