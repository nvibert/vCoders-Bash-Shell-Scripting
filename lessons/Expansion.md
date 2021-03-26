# Lesson 7 - Shell Expansion and Expansion Precedence ##

Parameter Expansion, or Variable Expansion, is simply the the replacement of variables and parameters with actual values when a shell program is run. Unlike other programming languages, bash requires you to keep in mind that __expansion__ happens in a specific order. This lesson will delve into how expansion works in the bash shell, and which order they take. These are the list of expansions that occur, in order:

1. Brace or curly bracket `{}` expansion
1. Tilde `~` expansion, parameter and variable expansion, arithmetic expansion, command substitution, process substitution (done in a left-to-right fashion)
1. Word splitting, which will be covered in detail in [lesson 8](../lessons/WordSplitting.md)
1. Pathname expansion
1. Quote removal

So, for example, if you try to use curly brace expansion with a variable, it won't work. What we mean by that is that you can specify a range inside the curly brace whihc looks like `{starting-number..ending-number}`. Now if you try to replace the starting number of ending number with a variable, it won't work because parameter and variable expansion happens after it. Let's try out an example to show what we mean.

Try to print all the numbers from 1 to a certain number using a `for` loop. Note, as in other lessons, a `%` is used to indicate the shell prompt so that you can easily distinguish between shell commands and the resulting output. When copying and pasting these commands into your own shell, omit the `%` part of the command.

```shell
% for a in {1..3}; do echo $a; done
1
2
3
```

Now, let's make the length of this list dynamic. First, we use a variable for the max value:

```shell
% MAX=3
```

And then we try to use that variable:

```shell
% for a in {1..$MAX}; do echo $a; done
{1..3}
```

This doesn't work because `$MAX` is expanded to its value, 3, after the brace expansion `{1..$MAX}` is expanded. For the shell, `{1..$MAX}` does not look like a real range, since it goes from 1 to a string, and the shell interpreter decides to treat the whole thing as a single string. Then $MAX is expanded to 3, and this string remains `{1..3}`: not what you wanted!

How can we do this then ? Well, you can use the `seq` command:

```shell
% seq 1 $MAX
1
2
3
```

OK! so this `seq` command already does what we want without needing the `for` loop. But if we need further processing, rather than just printing the value, we might want to loop through each value individually. In that case, we can use the command substitution `$()`:

```shell
% for a in $(seq 1 $MAX); do echo $a; done
1
2
3
```

`for` loops, together with `while`, `select` and `if` and others are called "Compound Commands" in shell terminology. We have briefly looked at these in [lesson 4](./CompoundCommands.md) but we will look at them again in more detail in lessons [9](./SimpleCommands.md) and [10](./AdvancedCompoundCommands.md).

## Expansion and Arithmetic Expressions ##

One other option hinstead of `seq` is to use a different `for` loop format, some times called "c-style", a reference to the `C` Programming Language. This is how we could use the `for` loop to achieve our goal:

```shell
% for ((a=1; a<=$MAX; a++)); do echo $a; done
1
2
3
```

Notice how inside the double parenthesis (`((` `))`), we can use what are called ARITHMETIC EXPRESSIONS, where variables can be accessed _with_ or _without_ the `$` prefix.

```shell
% for ((a=1; $a<=MAX; a++)); do echo $a; done
1
2
3
```

We could also use a **pipe** to get the output of `seq`, and pass it to `while` and `read`. Pipes `|` take the standard output (stdout) from one command and passes it to the standard input (stdin) of the subsequent command.

```shell
% seq 1 $MAX | while read a; do echo $a; done
1
2
3
```

`read` does the work in the previous example, reading each line and assigning the values to the variables specified. If you specify more than one variable, the line will be split according to the defined separator (which defaults to spaces and tabs), up to the line delimiter (default `\n`). This means that each value or entry on each line can be assigned its own variable.

The seperator can be changed from spaces and tabs if you are parsing a file with a different format (e.g. a `:` seperated list of items). If the content divides up in a number of values that do not match the number of variables provided to the `read` command, the remaining values are assigned to the last variable, If there are too many variables provided to the read command, the missing values are replaced with empty values.

Let's see an example where we want to see the __%Free__ for the filesystems in the machine. There is a command called `df` that will print some details, but it does not include the value:

```shell
% df -k
Filesystem       1K-blocks      Used Available Use% Mounted on
udev              16264016         0  16264016   0% /dev
tmpfs              3257268      3736   3253532   1% /run
/dev/mapper/Root 523898948 482330000  41568948  93% /
tmpfs             16286328    213528  16072800   2% /dev/shm
tmpfs                 5120         8      5112   1% /run/lock
tmpfs             16286328     30468  16255860   1% /tmp
/dev/md0            508260    440632     67628  87% /boot
/dev/nvme0n1p1      510984     38216    472768   8% /boot/efi
tmpfs              3257264       108   3257156   1% /run/user/1000
```

Your output might be different, depending on the filesystems used in your machine, but the structure will be the same. `-k` is used to list the values in kilobytes. You can use other options for other units, but do not use the human readable format option `-h` because the output is not meant to be read by machines.

Now, we need to get rid of the first line, since it is not interesting for what we want to do. We can use the stream editor `sed`, with the command `1d` which means **d**elete line number **1** (Yes, you've guess it! We'll be looking at `sed` in more detail in a later lesson.)

```shell
% df -k| sed 1d
udev              16264016         0  16264016   0% /dev
tmpfs              3257268      3072   3254196   1% /run
/dev/mapper/Root 523898948 482321844  41577104  93% /
tmpfs             16286328    216600  16069728   2% /dev/shm
tmpfs                 5120         8      5112   1% /run/lock
tmpfs             16286328     30484  16255844   1% /tmp
/dev/md0            508260    440632     67628  87% /boot
/dev/nvme0n1p1      510984     38216    472768   8% /boot/efi
tmpfs              3257264       108   3257156   1% /run/user/1000
```

Next, we want to print the first column, the __%Free__ and then the last column, the mount point. __%Free__ is not available in the output. To get the __%Free__, we could do a calcualtion which is __100 - %used__, and work to get the `%` out of the way. Alternatively, we could use the size and used fields to do the calculation.

To be able to do this, we need to read each value, line by line, and do the calculation. Then we can report back what % of space is free on each mount point:

```shell
% df -k | sed 1d | while read fs size used available usedp mountpoint; do echo $fs $(( 100 * (size - used) / size )) $mountpoint; done
udev 100 /dev
tmpfs 99 /run
/dev/mapper/Root 7 /
tmpfs 98 /dev/shm
tmpfs 99 /run/lock
tmpfs 99 /tmp
/dev/md0 13 /boot
/dev/nvme0n1p1 92 /boot/efi
tmpfs 99 /run/user/1000
```

All of the variables that follow the read command are respectively assigned to each entry returned from the `df -k` command. We can add some headers to provide a description of each column, and also add some formatting to make the output prettier, but the main point to observe in this example is how powerful the `while` + `read` combination is. It allows you to give names to the columns, as well as do some work with them. This is pretty useful in shell scripting!

That completes the expansion lesson. [Click here to return to the lesson list](../README.md)
