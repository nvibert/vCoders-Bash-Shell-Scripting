# Lesson 9 - Simple Single Action Commands #

A simple command is a command made up by a single action, such as: `ls /tmp`, `grep error /var/log/syslog`, `cp /home/user/Downloads/logbundle.tgz /tmp`

Simple commands can be combined together by composing/concatenating them:

-	in a pipeline, using one or more pipe (`|`) symbols, 
-	logically, with a logical AND (`&&`) or OR (`||`), 
-	by just typing them one after the other, separating them with either: newline (also called `\n`) or a semicolon (`;`);you can also use a so called "ampersand" (`&`).

The pipeline is a very useful feature, because it allows you to combine capabilities of many programs, all applying different changes to the output of the previous one.

For example, let's say you want to know how many errors there are in the `syslog` file: how do you do that ?

There are 2 tools at our disposal:

`grep`, which will filter all the lines in input, and will produce in output only the ones we are interested.

`wc`, which, with the `-l` option will count the input lines.

So, we can proceed with a pipeline:

```shell
% grep error /var/log/syslog | wc -l
14
```

For completeness, note that technically, `grep` does this for you already with the `-c` option:

```shell
% grep -c error /var/log/syslog
14
```

This is because the example is trivial, just to demonstrate the pipeline construct. In real cases, the use-case for the pipeline is more complicated, and `grep -c` won't suffice.

For example: how would you find out how many user have a certain shell as default login shell ?

First, how does one find the list of users in the system, and then find out for each user their default login shell ?

There are many ways to do this, but the way we will use in this example is by reading `/etc/passwd` directly.  This file contains a user per line, and for each user, it contains a record where the fields are separated by a column (':').

We can use the `while read` trick, if we can tell `read` to use `:` as separator, but this time we will take a different approach: we will use `cut`, which is used to extract fields or sections of each line from the input:

If you look at the file using `cat` or `head -1`, you'll see that first field is the username, and that the field we are interested in (the default login shell) is the 7th.

`cat /etc/passwd` will show you the contents of the whole file, while `head -1` will show you just the first line: we'll use the latter here for brevity:

```shell
% head -1 /etc/passwd
root:x:0:0:root:/root:/bin/bash
```

If you check the man page for `passwd(5)` you proper confirmation of this guess:

```shell
% man 5 passwd
[…]
DESCRIPTION
       /etc/passwd contains one line for each user account, with seven fields delimited by colons (“:”). These fields are:
       •   login name
       •   optional encrypted password
       •   numerical user ID
       •   numerical group ID
       •   user name or comment field
       •   user home directory
       •   optional user command interpreter
```

So, we can use `cut` with the `-d` option to specify the colum delimiter set to colon (`:`) and select the 7th column with `-f 7`.

Also notice how the space between the option and its argument is optional.

```shell
% cut -d: -f 7  /etc/passwd
/bin/bash
/usr/sbin/nologin
/usr/sbin/nologin
/usr/sbin/nologin
/bin/sync
/usr/sbin/nologin
/usr/sbin/nologin
/usr/sbin/nologin
/usr/sbin/nologin
/usr/sbin/nologin
/usr/sbin/nologin
/usr/sbin/nologin
/usr/sbin/nologin
/usr/sbin/nologin
/usr/sbin/nologin
/usr/sbin/nologin
/usr/sbin/nologin
/usr/sbin/nologin
/bin/bash
/usr/sbin/nologin
/bin/false
/bin/false
/bin/false
/bin/false
/bin/sh
/bin/false
/bin/false
/bin/false
/bin/false
/bin/false
/bin/false
/bin/false
/bin/false
/usr/sbin/nologin
/usr/sbin/nologin
/usr/sbin/nologin
```

Now, we can use `sort` to sort this output:

```shell
% cut -d: -f 7  /etc/passwd | sort
/bin/bash
/bin/bash
/bin/false
/bin/false
/bin/false
/bin/false
/bin/false
/bin/false
/bin/false
/bin/false
/bin/false
/bin/false
/bin/false
/bin/false
/bin/sh
/bin/sync
/usr/sbin/nologin
/usr/sbin/nologin
/usr/sbin/nologin
/usr/sbin/nologin
/usr/sbin/nologin
/usr/sbin/nologin
/usr/sbin/nologin
/usr/sbin/nologin
/usr/sbin/nologin
/usr/sbin/nologin
/usr/sbin/nologin
/usr/sbin/nologin
/usr/sbin/nologin
/usr/sbin/nologin
/usr/sbin/nologin
/usr/sbin/nologin
/usr/sbin/nologin
/usr/sbin/nologin
/usr/sbin/nologin
/usr/sbin/nologin
```

But that's not enough: we want to count each shell separately. `sort` has an option to remove duplicates with `-u`:

```shell
% cut -d: -f 7  /etc/passwd | sort -u
/bin/bash
/bin/false
/bin/sh
/bin/sync
/usr/sbin/nologin
```

This is closer to what we need: what we need now is to know how many of each of these there are, so we could pipe this output to a `while read`, and then `grep -c` for each on the same output:

```shell
% cut -d: -f 7  /etc/passwd | sort -u | while read loginshell; do echo -n "$loginshell "; cut -d: -f 7  /etc/passwd | grep -c $loginshell; done
/bin/bash 2
/bin/false 12
/bin/sh 1
/bin/sync 1
/usr/sbin/nologin 20
```

But this is not really efficient, as you will be parsing the file over and over, for each username. A better approach is to use the aggregated counting feature of `uniq` that is enabled with the `-c` option:

```shell
% cut -d: -f 7  /etc/passwd| sort | uniq -c
      2 /bin/bash
     12 /bin/false
      1 /bin/sh
      1 /bin/sync
     20 /usr/sbin/nologin
```

As you can see, in this case the pipeline is better than `grep -c`

## exit status ##

When a simple command terminates, it will return back to the shell with a value between 0 and 127 if it terminated regularly, or 128 + the signal that caused its termination.

The important part here is just that for the shell, the simple command succeeded if it returned 0, or it failed for any other value that is not 0.

This is used for the cases where the simple command is used as a conditional expression (such as with `if` or `while`), or when used in a chain of commands with `&&` or `||`

The shell will make the exist status of the last simple command available in the variable `$?`, but even the command to look at it will update the available too, so be careful.

Also, if you have pipes, the exit status might not be what you think.

There are some commands that always return a certain status code: `/bin/true` and `/bin/false`:

True always return success:

```shell
% true; echo $?
0
```

False always returns failure:

```shell
% false; echo $?
1
```

Each command decides what success or failure is, and in most cases the man page describes what each failure code means, for example `ls`:

```shell
% man ls
[…]
   Exit status:
       0      if OK,

       1      if minor problems (e.g., cannot access subdirectory),

       2      if serious trouble (e.g., cannot access command-line argument).
```

Success is 0 as we expected:

```shell
% ls /etc/passwd ; echo $?
/etc/passwd
0
```

For "minor" problems, we get a 1, such as for missing directories:

```shell
% ls /missingdirectory ; echo $?
ls: cannot access '/missingdirectory': No such file or directory
1
```

For what `ls` considers "major" issues, like wrong arguments, the code is 2:

```shell
% ls --missing-argument; echo $?
ls: unrecognized option '--missing-argument'
Try 'ls --help' for more information.
2
```

Be careful with pipes. If the second command fails, you get what you expect, a failure status code:

```shell
true | false
echo $?
1
```

But if the 1st command fails, you might not get what you expect:

```shell
false | true
echo $?
0
```

The `$?` returns success, but the command technically failed! Most shells offer ways to deal with this, in bash you can use `PIPESTATUS`, which is an array of exit statuses for each command in the pipe. `PIPESTATUS` is an array, so to print all the values in the array, you need to use `${PIPESTATUS[@]}`.


```shell
% true | false; echo "${PIPESTATUS[@]}"
0 1

% false | true ; echo "${PIPESTATUS[@]}"
1 0

% ls | grep test; echo "${PIPESTATUS[@]}"
test
test.c
0 0
```

That completed the lesson on Simple Commands. [Click here to return to the lesson list](../README.md)
