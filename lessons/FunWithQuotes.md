# Lesson 5 - Fun With Quotes #

Quotation marks, or quotes, play a significant role in shell scripting. This short lesson will explain the difference between the __double quote (")__, the __single quote (')__ and the __back quote (`)__ in the context of shell scripting.

Click here if you would like a fuller description of [single quotes](http://www.gnu.org/software/bash/manual/html_node/Single-Quotes.html) and [double quotes](http://www.gnu.org/software/bash/manual/html_node/Double-Quotes.html) behaviours, from the __gnu.org__ bash documentation.

Mostly, the differences between single and double quotes in shell programming is related to how the shell evaluates and changes (interpolates) what is inside the quotes. For example, variables that start with `$` are expanded inside of double quotes but are not expanded inside of single quotes.

It is easiest to describe quote behaviour using some examples. Note that in this lesson, the `%` sign is included to signify the shell prompt, and is used to differentiate the shell command and the output. It is not part of the shell command, so do not include it if copying and pasting examples to your own shell.

## Single Quotes (') and Double Quotes (") ##

Here are a few examples that should show how variable expansion behaves within single and double quotes.

```shell
% VAR=Hello

% echo $VAR
hello

% echo "$VAR"
hello

% echo '$VAR'
$VAR
```

Using single quotes (') can also be used to print double quotes (") and other special characters.

```shell
% echo '"$VAR"'
"$VAR"
```

It is important to realise that if the variable is followed by other characters in a string, then it is not expanded.

```shell
% echo "hello$VARhello"
hello
```

To print out variables that are surrounded by other text or variables, you need to use the special curly braces or curly brackets `{}` to expand it.

```shell
% echo "hello${VAR}hello"
hellohellohello
```

And if we try the same thing with single quotes?

```shell
% echo 'hello${VAR}hello'
hello${VAR}hello
```

## The back quote (`) ##

The back quote has special significance is shell programming. The shell executes the command or commands _enclosed inside the back quotes_ before running the rest of the command.

By way of a quick example, let's try to set a variable `$today` to display today's date.

```shell
% date '+%D'
03/05/21

% today=date '+%D'
bash: fg: %D: no such job
% echo $today
```

Note that in the example above, the shell is unable to assign the output of the `date '+%D'` command to the `$today` variable due to the order in which the command line is interpreted. Also, using double quotes does not run the `date` command, it simply treats what is between the double quotes as text.

```shell
% today="date '+%D'"
% echo $today
date '+%D'
```

By adding the back quotes, the `date` command is executed first, and the output is then assigned to the variable:

```shell
% today=`date '+%D'`
% echo $today
03/05/21
```

Note that the single quote will also prevent the back quote from being interpreted as a special character by the shell. Again, it is probably easier to see the behaviour of the back quote with both single quotes and double quotes in an example that uses the `date` command our `$VAR` variable.

Let's first start by wrapping everything in single quotes. As you can see, none of what appears inside the single quotes is interpreted by the sshell.

```shell
% echo '$VAR. Today is `date`.'
$VAR. Today is `date`.
```

But if we wrap everything in double quotes, the command expansions in the back quotes now works:

```shell
% echo "$VAR. Today is `date`."
hello. Today is Fri  5 Mar 2021 09:11:55 GMT.
```

That completes the short lesson on quotes. [Click here to return to the lesson list](../README.md)
