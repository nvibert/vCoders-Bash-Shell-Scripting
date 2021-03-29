# Lesson 10 - Compound Commands #

A compound command is a construct where one or more commands are treated as if they were a simple command.

Some of the forms of compound commands are more complicated, but the main ones are the `for` and `while` loops, the arithmetic and conditional expressions. We covered some of these compound commands in [lesson 4](./CompoundCommands.md). Here we will delve into more complex usage for some of these conditional and looping constructs, such as __if__, and __while__.

## if ##

We have already seen the `if` construct. It is very common, and will probably be used in most scripts. The structure, as we have previously seen, is as follows:

```shell
if conditional-command; then command fi
```

This will run `conditional-command`, and if that is successful, run `command` as well Here, `command` could be a list of commands. It is equivalent to using the `&&` operator to combine the 2 simple commands: `conditional-command && command`.

Before the `fi` to close the loop, you can also have an `else` followed by an alternative list of commands. This is  used when `conditional-command` failed. For example, let's say we want to see if a certain user exists on this system. We could use a dedicated command, designed specifically for this, but let's say we want to write an equivalent shell script. How do we do that?

One way to do this would be to define a variable with the user name, and then check if that user exists in the file `/etc/passwd`:

```shell
% user=username1
% if grep -q $user /etc/passwd ; then echo "$user exists"; fi
```

In the above example, there is no output. Maybe it would be better if we had an `else` part to be able to also mention that, if the conditional statement fails, then the user doesn't exist.

```shell
% user=username1
% if grep -q $user /etc/passwd ; then echo "$user exists"; else echo "$user is missing"; fi
username1 is missing
```

Now, we can try with a username that exists for sure:

```shell
% user=root
% if grep -q $user /etc/passwd ; then echo "$user exists"; else echo "$user is missing"; fi
root exists
```

Here, we can see that the `grep` command is being used as a conditional command: if it returns 0, the `then` part of the compound command is executed, otherwise the `else` part is used.

In the example we are using `grep` with the `-q` option to specify that `grep` should be _quiet_ as we are not interested in its output, only on its exit status.

You can use the `$?` variable to check the exit status (also known as return code) returned by a command. The exit status codes are covered in [lesson 9](./SimpleCommands.md).

```shell
% user=username1
% grep -q $user /etc/passwd; echo $?
1
```

```shell
% user=root
% grep -q $user /etc/passwd; echo $?
0
```

Any command can be used as conditional command, but many use-cases are actually performing a test Therefore, a dedicated command was introduced, aptly called `test`. This command has an alias, called `[`, which expects a corresponding `]` at the end of its parameters. This makes it look like `if` requires square parenthesis, while this is not true. They are only used as a shorthand for `test`. `test` has a lot of options to compare numbers and strings, or to check if a file exists, as shown below.

Example 1:

`/tmp/missingfile` does not exist

```shell
test -f /tmp/missingfile; echo $?
1
```

Example 2:

`/etc/passwd` does exists

```shell
test -f /etc/passwd echo $?
0
```

## for loops ##

The `for` loop will loop through a list of values, and for each value, it will execute the commands inside it, and make the value available using the named variable.

Since some commands can work on multiple files at once, they can accept all the files at once as parameters. However there are other commands that can only work on one file at a time and so can only accept one file at a time as a parameter. If you want to work on multiple files, but the tool you are using only works on a file at a time, a `for` loop is a perfect way to work on all the files anyway.

For example, let's say you want to rename a bunch of files you have in a directory, and you want to prepend a string to all of them. The tool you might use to rename a file is `mv`, but `mv` takes only 2 parameters: one or more source file names and exactly destination file name or directory.

Let's try this!

First some preparations, in case you want to try this multiple times:

Create a temporary working directory, such as `/tmp/renameexercise`

```shell
% mkdir /tmp/renameexercise
```

Then go to the `/var/log` directory and copy some files to your `/tmp/renameexercise` working directory, and then switch to the working directory:

```shell
% cd /var/log
% cp * /tmp/renameexercise/
% cd /tmp/renameexercise/
```

You can ignore the errors about not using `-r` for directories during the `cp`, we just need some files for the test.

The last step is to decide the prefix to prepend. We will use "test"

```shell
% PREFIX=test
```

Now, we're ready: try to rename all of them first:

```shell
% mv * $PREFIX*
mv: target 'test*' is not a directory
```

Here `mv` interprets your command to mean "move this bunch of files into the directory whose name matches the last file that matches `test*`". What this does depends on what files match or do not match this pattern, so the result is unpredictable.

Let's see an example of that. Create a couple of directories that would match the pattern:

```shell
% mkdir test1
% mkdir test2
```

And try again:

```shell
% mv * $PREFIX*
mv: cannot move 'test2' to a subdirectory of itself, 'test2/test2'
mv: cannot stat 'test1': No such file or directory
```

As you can see, `mv` now tried to move all the files into `test2`, and failed.

The failure related to `test1` is because it already matched the initial `*`, so it was already moved to the location that appeared at the end of the expansion, which was `test2`. It also failed to move `test2` because it can't go inside itself, i.e. it cannot `mv test2 test2`.

If you now check the content of the working directory, everything has moved into `test2`!

```shell
ls
test2
```

That is **NOT** what we wanted. Let's bring the files back. Go into `test2` and move the files back out:

```shell
cd test2/
mv * ../
cd ../
```

We can visualise what the command actually did, by prepending an `echo` command in front of the command, to see what it actually translates to, after the pathname expansion. This does not execute the command, it simply prints out the command.

```shell
echo mv * $PREFIX*
mv syslog.1.gz syslog.2.gz syslog.3.gz syslog.4.gz syslog.5.gz syslog.6.gz syslog.7.gz syslog.gz test1 test2 user.log.1.gz user.log.2.gz user.log.3.gz user.log.4.gz user.log.gz wtmp.1.gz wtmp.gz test1 test2
```

The output might be smaller or bigger for you depending on what log files you have, but notice that `*` expanded to all the files and directories, including `test1` and `test2`, and `$PREFIX*` expanded to `test1` and `test2`. So essentially the command tried to `mv` everything to `test2`, including `test2` itself.

So, what can we do to make it work like we want? We can use a for loop, and use `mv` on each individual file, in a controlled manner. __It is always a good idea to test potentially destructive commands first, especially when run in a loop!__ Let's first add an `echo` in front of the `mv` to see what it does:

```shell
for f in *
do
  echo mv $f $PREFIX$f
done
```

This shows you all the commands that this compound command is actually containing. This will also allow you to find mistakes, before it's too late. But this time it looks good! Let's run it without the debugging `echo`:

```shell
for f in *
do
  mv $f $PREFIX$f
done
```

All the files have now been renamed to start with `test`. Now you might wonder: how do I go back?

How can I **remove** a prefix? (or a suffix, for that matter?)

There are multiple ways to do this, as is usually the case in shell scripting, and many of the solutions might use `sed`, the stream editor seen in a few lessons already. However, we will just look at one way that doesn't depend on `sed`:

Bash offers a feature called "__parameter expansion__" which we saw in [lesson 7](../lessons/Expansion.md), and one of the types of parameter expansion is conveniently called "Remove matching prefix pattern". Sounds just what we need!

The format for this expansion is `${parameter##pattern}`. `##` means match the biggest matching pattern, and `#` means match the smallest matching pattern. In our case it makes no difference.

```shell
for f in *
do
  mv $f ${f##$PREFIX}
done
```

Add the `echo` before the `mv` as discussed, if you want to test this script before running it.

## Expressions ##

We have already seen a number of different expressions during the course of this tutorial, typically when it came to evaluating if a condition is true or false in `while` loops, `for` loops and `if` statements, amongst others. Compound commands that fall under the "__Expression__" category are commands that get replaced by the value of the resulting evaluation of the expression they describe.

They are usually used for 2 types of operations: __arithmetic evaluation__, to make calculations, and __conditional operations__, to take decisions.

Both types of expressions can work with or without prepending `$` to the variable names

### Arithmetic Expressions ###

Compound commands of the type called "arithmetic evaluation" perform the valuation of an arithmetic expression, and are identified by the double parenthesis format (`((` and `))`). This is equivalent to using the `let` command.

Arithmetic evaluation behaves like a command, and returns 0 if the evaluation of the expression is non-zero, or a non-zero if the result is 0, which is a bit confusing, but only if you try to look at the values: the best way to deal with this and remove the confusion is to ignore the fact that in bash 0 means success, and just remember that it is a success: so the return value is failure when the calculation returns a 0 value, and success when your expression evaluates to a non-zero value.

Arithmetic substitution is very similar to an arithmetic evaluation, but it is preceded by a dollar (`$`), and it is replaced during expansion with the value resulting from the expression. Let's look at some short examples.

If we use the arithmetic evaluation as a command, we can use it together with `&&` and/or `||` to perform some actions depending on the value of a variable:

```shell
% A=1
% ((A)) && echo "$A is not zero"
1 is not zero

% A=0
% ((A)) && echo "$A is not zero"
```

As you can see, if the first part of the test is 0, the `echo` command will not run. You might ask: why can't I use `test` or `[` for that ?

```shell
% A=0
% test $A -gt 0 && echo "$A is bigger than zero"
%
% A=1
% test $A -gt 0 && echo "$A is bigger than zero"
1 is bigger than zero
```

But note what happens if A is not a number:

```shell
% A=zero
% test $A -gt 0 && echo "$A is bigger than zero"
-bash: test: zero: integer expression expected
% ((A)) && echo "$A is not zero"
% ((A)) || echo "$A is zero"
zero is zero
```

Arithmetic expressions will convert anything that does not look like a number to a number, 0 Also, they allow you to do more advanced evaluations than what is possible in `test`:

```shell
% (( (A+A)/2 * A > 10 )) && echo "The value of $A is good"
The value of 100 is good
```

And it can also change values!

```shell
% A=0
% for a in {1..100}
do
 (( A+=a )) 
 if ((A > 50))
 then
      echo "the sum of the first $a integers is above 50"
      break
 fi
done
```

Here you see one of the most common uses of arithmetic evaluation: use it as a simple command in an `if`.

The `break` command is used to jump out of loops.

If you add a `$` in front of an arithmetic evaluation, you get arithmetic expansion, so rather than getting a success/failure, you get the result of the expression.

We can use the arithmetic expression to assign values to a variable, as we have seen:

```shell
% A=4
% ((B=A/2))
% echo "half of $A is $B"
half of 4 is 2
```

But you can avoid needing the 2nd variable and just print the result!

```shell
% A=4
% echo "half of $A is $((B=A/2))"
half of 4 is 2
```

Or, if you want, use the variable anyway:

```shell
% A=4
% B=$((A/2))
% echo "half of $A is $B"
half of 4 is 2
```

In some versions of shell, the arithmetic expression is not implemented, but you can use it's grandfather: `let`

```shell
% A=4
% let B=A/2
% echo "half of $A is $B"
half of 4 is 2
```

This will work even if the shell you are using is old enough not to allow you to use variables without `$`:

```shell
% A=4
% let B=$A/2
% echo "half of $A is $B"
half of 4 is 2
```

`let` can be used as a full replacement of arithmetic evaluation, even as a conditional command!

```shell
% A=4
% if let A>0
then
 echo "$A is bigger than zero"
fi
4 is bigger than zero
```

### Conditional Expressions ###

The conditional expression compound commands are similar in concept to the arithmetic ones we've just seen, but they implement, and intend to replace, the functionalities of the `test` command.

For this reason, probably, they have been designed to use the double square brackets (`[[` `]]`).

For most of the use-cases, you can just add an extra set of square brackets to the existing `test` expressions, but there are several additional features and advantages on top of `test`, such as additional tests. Another advantage is the fact that they do not error out if a variable is not defined.

For example, check if a variable matches a string:

```shell
unset variable1
[ $variable1 == "test" ] && echo "ok!"
-bash: [: ==: unary operator expected
```

The `unset variable1` is just to make sure that `variable1` does not contain a value.

The error comes from the fact that `[ $variable1 == "test" ]` translates to: `[ == test ]` since $variable is not set, which is a syntactical error

Now, what does it look like with an extra set of square brackets?

```shell
unset variable1
[[ $variabe1 == "test" ]] && echo "ok!"
```

It worked as expected, and no error is reported with the syntax because the `[[` and `]]` are not a command, they are a construct of the shell, so the shell is able to understand the intention of the programmer, and it can detect that there is a variable where the `$variable1` placeholder is.

## While loops ##

As we have seen, a `while` loop can be seen as a repeating `if`, which keeps repeating **while** the condition is true. The `while` is followed by a conditional command whose exit status will be used to decide whether the compound or simple command following it will be executed, and, just like `if`, the conditional command can be anything. As we know, there are commands called `true` and `false`, which always success or always fails. If you use `false` in a `while` loop, it means the `while` loop will never start:

```shell
% while false
do
  echo "This should never happen™"
done
```

### Stopping a never ending while loop ###

Similar to the `false` scenario, `true` will always run. Before you try this command, you need to make sure you can stop it, or it will go on forever. Typically this is done with `ctrl-c`, but sometimes some of the ways to access the console of a machine, and some other remote access systems do not translate the `ctrl` part of `ctrl-c`, and so you end up stuck with the command running forever.

If that's the case, you will need to find a secondary access to the machine and stop the script, usually with a `kill` command.

The procedure for doing this is easy or complicated depending on how many sessions are open to the machine you are using for the tests. To make it easier, take a small precaution, and make this easier in any case, get one bit of information before starting the script:

Run this command to keep track

```shell
% tty
/dev/pts/0
```

Keep note of the output, after removing the `/dev` part. In this example above, the "tty" used to run the script is called `pts/0`. Most of the time, for __ssh__ secure shell connections it will be `pts/0` or similar. If you are using remote console it might be something like `tty0`. Let's first see the example, and then how to kill it:

```shell
% while true
do
  echo "This message will be repeated forever"
done
This message will be repeated forever
This message will be repeated forever
[…]
```

To stop it, use the `ctrl-c` as mentioned, or try this:

```shell
% ps ax | grep 'pts/0'
19916 ?        Rs     0:32 sshd: root@pts/0
19944 pts/0    Rs+    0:36 -bash
20581 pts/1    S+     0:00 grep pts/0
```

The important part is the one that is not the same `grep` command, and (optionally) not the sshd process that allowed you to connect. In this case it's `-bash`, and what we need is the corresponding process id, or pid, which in this example would be 19944.

Now, try first to just `kill` the process:

```shell
% kill 19944
```

Did the `while true` loop stop ?

This depends on the shell you use, but most probably, it did not. This is because the default signal used by kill is 15, which is called `TERM`, which is a kind way to ask a process to terminate.

There are a few increasingly more aggressive signals that one can use to terminate a process, such as 2, or `INT`, also called **Interrupt**, which is the same signal that a program would receive in a shell when you press `ctrl-c`, and the most famous and most frequently used, 9, `KILL`.

So, let's send a `ctrl-c` to the shell running the script in a loop!

```shell
% kill -2 19944
```

Did that stop the while loop?

Now, what happens if you use the 9 instead ? Restart your `while true` loop, and in the other session, try now

```shell
% kill -9 19944
```

What happened to your while loop? And what happened to the session where you were running the loop?

This is because the `kill` signal is much stronger than a `ctrl-c`, and the shell understood that to mean "not only stop the script, but stop everything else".

### break ###

To get out of the `while` loop, like for the `for`, you can use `break`, but you might also use a variable, and use an arithmetic or conditional expression.

We have seen how you can use a `for` loop to print the first numbers up to a variable called MAX, can we do this with a `while` loop too ?

```shell
% A=0
% MAX=3
% while ((A++ < MAX))
do
  echo $A
done
1
2
3
```

Or, if you prefer to `break` out of a `while`:

```shell
MAX=3
A=1
while true
do
  echo $((A++))
  (( A > MAX )) && break
 done
1
2
3
```

This completes the lesson on Compound Commands. [Click here to return to the lesson list](../README.md)
