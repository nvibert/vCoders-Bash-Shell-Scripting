# Lesson 6 - Variables #

Using variables is a very basic feature of any programming language, and shell programs can take advantage of variables as well, but as with many things in shell programming, there are quirks to be aware of. Variables in shell are part of a broader category of mechanisms to produce dynamic content in the commands, and this broader category is called __"Expansion"__ in shell terminology. __Expansion__ will be examined in greater detail in [lesson 7](./lessons/Expansion.md).

## Introduction to Variables ##

Variables in a shell are created by assigning a value to a variable name. This is done by specifying the name of the variable, followed by an assignment symbol (the equal, or `=`) and the value. It is a strict requirement that __no space__ is introduced between the name and the assignment symbol.

Let's try to create some shell variables. Again, for clarification purposes, we have include `%` as the shell prompt to differentiate between shell commands and output in the following example. If copying and pasting, do not include the `%` symbol. Also note that as you create shell commands at the prompt, such as a function, the shell will use the `>` symbol to prompt for additional inputs to complete the command, e.g. the open curly bracket `{` requires a matching closing curly bracket `}`. However these have been omitted to make it easier for you to copy and paste the examples to your own shell.

```shell
% LOGDIR=/var/log
% TMPDIR=/tmp
% COUNT=10
```

Most of the time when you use a variable in shell scripting, and you want to access the value of the variable, you simply put a `$` sign in front of the variable name. But if there is any ambiguity around where the name ends, (e.g. when the variable name is used in a context where it ends up with some additional trailing characters), the shell tends to take the longest name it can find.

To prevent this, and ensure the user has full control over the variable name, most shells offer the `${}` format, where the name is enclosed in curly braces, and prefixed by the dollar `$`

Although we saw this behaviour back in [lesson 5](../lessons/FunWithQuotes.md) when we were looking at quotes, let's revisit it once more. Let's try an example where your script has a variable, called `n`. It keeps track of how many times you run a certain section of the script. Now you want to print a message to inform the user about the current iteration number. We will skip the looping part for now, and let's just simulate it by just choosing a single value of `n`:

```shell
% n=10
% echo "this is the $nth time this script runs"
this is the time this script runs
```

What happened? Here, the shell assumed that `$nth` was meant to print the value of a variable called nth, not `$n` followed by "th".

If we use the curly braces, we can tell the shell what we really want to do:

```shell
% n=10
% echo "this is the ${n}th time this script runs"
this is the 10th time this script runs
```

As a golden rule, use braces to protect your variable names as much as possible. The downside is that some bare-bone or older shells might not support this construct.

### Positional Parameters ###

A subset of shell variables are called __"Positional Parameters"__, and they are used to pass parameters to a shell script or to shell functions. The main way to distinguish variables from parameters is based on their names: parameters have names that are numbers only. The first parameter is identified as `$1`, the second as `$2` and so on. `$0` is the name of the script itself, as called by the user.

This is not specific to shell scripts, but it is just how processes are started.

Imagine you want to run a program called `fancyprogram` with 2 parameters: `--check-everything` and `/tmp/filename`:

The command line you'd enter in the shell would look like this, if `fancyprogram` happens to be in the shell's search path (`$PATH`).:

`fancyprogram --check-everything /tmp/filename`

If it isn't in the path, (and many custom made scripts will typically not be in the search path), you will need to specify to the shell how to find the `fancyprogram`, by specifying an absolute path or a relative path.

An example of an abolsute path would be:

`/home/me/coolprojects/fancyprogram --check-everything /tmp/filename`

And an example of a relative path would be:

`./fancyprogram --check-everything /tmp/filename`

When you run the command in any of these 3 forms, what the shell does is to split the line into words, and then each word will be a positional parameter. (We will delve deeper into __Word Splitting__ shortly in [lesson 8](./WordSplitting.md)).

So, taking the positional parameters from the three examples previously:

`$0` is `/home/me/coolprojects/fancyprogram`, `./fancyprogram` or `fancyprogram` depending on how you ran the script
`$1` is `--check-everything`
`$2` is `/tmp/filename`

So, let's try this out! To try it, you do need to write a script. Technically, you could type the commands directly in the shell, but it will be much easier to create a script. Create a file and call it `/tmp/fancyprogram`, with the following content:

```shell
#!/bin/bash

echo "the 0th parameter is $0"
echo "the 1st parameter is $1"
echo "the 2nd parameter is $2"
echo "the 3rd parameter is $3"
```

Then make the file executable with `chmod a+x /tmp/fancyprogram`, and run it with a variation of parameters:

```shell
% /tmp/fancyprogram
the 0th parameter is /tmp/fancyprogram
the 1st parameter is
the 2nd parameter is
the 3rd parameter is

% /tmp/fancyprogram --check-everything
the 0th parameter is /tmp/fancyprogram
the 1st parameter is --check-everything
the 2nd parameter is
the 3rd parameter is

% /tmp/fancyprogram --check-everything /tmp/filename
the 0th parameter is /tmp/fancyprogram
the 1st parameter is --check-everything
the 2nd parameter is /tmp/filename
the 3rd parameter is
```

This should be a good indicator on how you can work on various arguments passed into a script. Before we move on from positional parameters, there are 2 more variables associated with parameters worth mentioning: `$@` and `$#`. The `$@` expands to all the parameters passed to the script, and the `$#` expands to the count the number of parameters passed to the script (note that it does not count `$0`, although some other programming languages do count it). Add these 2 to your script, so that it looks like this:

```shell
#!/bin/bash

echo "the 0th parameter is $0"
echo "the 1st parameter is $1"
echo "the 2nd parameter is $2"
echo "the 3rd parameter is $3"
echo "Here are all the parameters: $@"
echo "This script received $# parameters"
```

Because of word splitting (see [lesson 8](../lessons/WordSplitting.md) for further details), it is always a good idea to always use `$@` in double quotes. If we now run the script:

```shell
% ./fancyprogram --check-everything /tmp/filename
the 0th parameter is ./fancyprogram
the 1st parameter is --check-everything
the 2nd parameter is /tmp/filename
the 3rd parameter is 
Here are all the parameters: --check-everything /tmp/filename
This script received 2 parameters
```

## Variables in Shell Functions ##

 A function is a way to create new commands in a shell script, and they are created by specifying the (optional) keyword `function`, followed by a name, followed by parenthesys `()` and a compound command, typically a curly braces one (`{}`).

Let's look at a quick example:

```shell
% function test1() {
echo this is a function!
}

% test1
this is a function!

% type test1
test1 is a function
test1 ()
{
    echo this is a function!
}
```

As you can see, now `test1` behaves like a new script or command, you can even `pipe` it!

```shell
% test1 | grep this
this is a function!

% test1 | grep -v this
```

One last note for positional parameters: the variables passed to the main program are not available inside a __shell function__, because they are replaced with the parameters for the function itself. We can see this behaviour if we create another function. In this example, we display the value of `$1`, the first argument passed to the function. The echo statement echo's out an escape `\$` so we can print it. 

Let's see what happens  (we can actually omit the _optional_ `function` keyword). First we will not provide any argument. In the second run, we will provide an argument.

```shell
% test2() {
echo "this is \$1: $1"
}

% test2
this is $1:

% test2 --check-everything
this is $1: --check-everything
```

This is behaviing as expected. However, if you defined and used the `test2` function inside a script, `$1` would have had 2 different values. It would have one value outside of the function `test2` (the first argument passed to the script) and another value inside the function `test2` (the first argument passed to the function).

Let's look at an example of such a situation. This requires you to create a script so that we can pass a parameter to it. Let's create a new file called `/tmp/parameter-test`, with the following content:

```shell
#!/bin/bash
test2() {
echo "test2: this is function \$1: $1"
}
echo "$0: this is script \$1: $1"
test2 some-option
```

Now make the file executable with `chmod a+x /tmp/parameter-test`, and then try to run it with and without parameter:

```shell
% /tmp/parameter-test
/tmp/parameter-test: this is script $1:
test2: this is function $1: some-option

% /tmp/parameter-test some-parameter
/tmp/parameter-test: this is script $1: some-parameter
test2: this is function $1: some--option
```

As you can see, the function behaves completely as a separate command, and that includes having its own set of parameters.

That completes the variables lesson. [Click here to return to the lesson list](../README.md)
