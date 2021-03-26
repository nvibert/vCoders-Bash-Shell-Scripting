# Lesson 1 - A look around your Shell #

In this exercise, we will examine your current shell environment.

## What shell are you using? ##

Before doing anything else, lets look at which __shell__ you are using on your Linux/Unix environment. You can do this by using the __echo__ command. The __echo__ command is used for display text or variables. To look at the type of shell being used, type the following at the shell prompt:

`echo $SHELL`

On a Mac, this might be the __zsh__ (the Z shell) :

```shell
chogan@chogan-a01 ~ % echo $SHELL
/bin/zsh
```

On an Ubuntu Linux distro, it might be the __bash__ shell:

```shell
cormac@pks-cli:~$ echo $SHELL
/bin/bash
```

There are lots of different shells, each with their own particular nuances. For the purposes of this tutorial, we will be working in the __bash__ shell. Note for the purposes of differentiating shell commands from the output of the commands, we may include a `%` sign from time to time to denote a shell prompt.

## .bashrc ##

The __bash__ shell has a special file in your home directory called __.bashrc__, short for `bash run commands`. This is called every time a new shell session is opened in the environment (not just a login). It is in essence a shell script, and is typically used for setting up aliases (shortened commands) and variables, as well as running some commands if required. Your shell prompt, which is typically a combination of username and working directory is set here using the variable PS1.

## .bash_profile ##

The __bash__ shell has another special file in the home directory called __.bash_profile__. This is a configuration file for the bash shell. This is run to configure your shell, before the shell prompt appears. It does pretty much what __.bashrc__ with the difference being when it is run. __.bash_profile__ is run on initial login, but is not run when a new shell is invoked, e.g. by typing bash. __.bashrc__ is run in every new shell session. This file typically contains environment variables such as $PATH.

## env ##

The __env__ command is used to print the list of environment variables, and what they are currently set to.

## Other useful environment variables ##

As well as $SHELL, there are a number of other environment variables that might be useful to be aware of for the purposes of this tutorial.

### $PATH ###

$PATH is a variable that holds the lists of all paths that will be searched to locate a command that is run at the command line / shell prompt. Note that the outputs below are showing the command prompt `%` to differentiate the commands and the resulting output. You do not need to include the `%` prompt when running these commands in your own shell.

```shell
% echo $PATH
/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/go/bin
```

The PATH variable can be extended and new PATHs can be added as follows:

```shell
% PATH=$PATH:/my/new/path
% echo $PATH
/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/go/bin:/my/new/path
```

`/my/new/path` will now also be searched when a command is run.

#### $HOME ###

$HOME is a variable that points to your home directory

```shell
% echo $HOME
/Users/chogan
```

### $$ ####

This is a special one. $$ is a variable which holds the Process Id of your session.

```shell
 % echo $$
96666
```

You can check it against the list of processes returned by __ps -ef__ and piping the output, using the __|__ symbol, to a __grep__ command, which does pattern searching.

`Piping` the output of one command to the input of another command is one of the most powerful features leveraged in shell scripting.

```shell
% ps -ef | grep 96666
  502 96666 96664   0 11:56am ttys003    0:00.03 -zsh
    0 97360 96666   0 12:04pm ttys003    0:00.01 ps -ef
  502 97361 96666   0 12:04pm ttys003    0:00.00 grep 96666
  ```

### $PWD ###

$PWD is the shell variable for displaying the working directory. This will tell you which folder you are currently working in and is often a useful shorthand for reading from, or writing to, files.

```shell
% echo $PWD
/Users/chogan
% cd Desktop
% echo $PWD
/Users/chogan/Desktop
%
```

## Standard In, Standard Out, and Standard Error ##

There is one last topic to cover before we leave this lesson, and that is the concept of standard in (`stdin`), standard out (`stdout`) and standard error (`stderr`). In scripting terms, these can be considered respectively as where your script input comes from, where your output is written to, and where any error from the commands or scripts that you run in your shell are written to. You can probably guess that, by default, your `stdin` comes from your keyboard and that both the `stdout` and `stderr` are displayed on your screen. However these can be modified, and in scripting it is useful to be able to do something like that at times. These standards each have a numeric association as well. 0 represents stdin, 1 stdout and 2 stderr. Let's look at a few simple examples on how to manipulate stdin, stdout and stderr.

Let's deal with stdout first. By default, stdout display to the screen.

```shell
% cd /tmp
% ls
MSS_Menulet                             boost_interprocess
MozillaUpdateLock-2656FF1E876E9973      com.apple.launchd.sNe55SMcx5
assist_core.stderr                      ls.out
assist_core.stdout                      names
assist_xpc.stderr                       powerlog
assist_xpc.stdout                       safeq-chogan
```

We can redirect `stdout`, represented by the number 1, to somewhere else, such as a file in /tmp. Both `stdout` and `stderr` are redirected using the __>__ greater than character, as follows:

```shell
% ls 1>/tmp/ls.out
%
% cat /tmp/ls.out 
MSS_Menulet
MozillaUpdateLock-2656FF1E876E9973
assist_core.stderr
assist_core.stdout
assist_xpc.stderr
assist_xpc.stdout
boost_interprocess
com.apple.launchd.sNe55SMcx5
ls.out
names
powerlog
safeq-chogan
```

In fact, we do not need to include the __1__. We can redirect stdout as follows, and the __1__ is implied:

```shell
% ls >/tmp/ls.out
```

Let's look at `stderr` next. Let's say we wanted to search all files in a directory for some keyword. Let's continue to work with the `/tmp` folder and let's search all files for the keyword `error`. For that, we will use the command __grep__ which we will look at in more detail in a later lesson. Here the wildcard `*` matches all files in the directory.

```shell
% cd /tmp
% grep error *
assist_xpc.stderr:2021-03-09 10:25:29.064 assistd[142:25809] NError : XPC: Daemon connection is interrupted.
assist_xpc.stderr:2021-03-10 02:26:54.634 assistd[142:424921] NError : XPC: Daemon connection is interrupted.
assist_xpc.stdout:Error : XPC: Daemon connection is interrupted.
assist_xpc.stdout:Error : XPC: Daemon connection is interrupted.
grep: boost_interprocess: Is a directory
grep: com.apple.launchd.sNe55SMcx5: Is a directory
grep: powerlog: Is a directory
grep: safeq-chogan: Operation not supported on socket
```

In the above output, we receieved some results but also some errors. The command __grep__ is used for searching file contents. It cannot search a _directory_ object. It can of course search all the files in a directory, just not the directory object itself. There is also another non-file object here, called a _socket_ which cannot be searched either. So that output is rather messy since both the `stdout` and `stderr` and writing to the display.

But, we do have the ability to redirect stderr to somewhere other than the display, similar to what we did with `stdout` previously. Let's send the errors to `/dev/null`, a special file which basically discards anything written to it. Remember, the number 2 is used for `stderr`, so that is the number we will need to reference in the redirection. We also use the __>__ greater than character to redirect standard error, same as we did for standard out.

```shell
% grep Error * 2>/dev/null
assist_xpc.stderr:2021-03-09 10:25:29.064 assistd[142:25809] NError : XPC: Daemon connection is interrupted.
assist_xpc.stderr:2021-03-10 02:26:54.634 assistd[142:424921] NError : XPC: Daemon connection is interrupted.
assist_xpc.stdout:Error : XPC: Daemon connection is interrupted.
assist_xpc.stdout:Error : XPC: Daemon connection is interrupted.
```

Now that output is so much tidier than before. The error messages have been redirected away from the default `stderr` setting of the display to /dev/null. Now we can clearly see the results of what we are searching for.

Lastly, `stdin` can be redirected to come from somewhere other than the keyboard by using the __<__ less than character. A common example is to take input from a file. We will see a number of examples as the tutorial progresses. Here is one simple example which takes the stdin from one file, `/tmp/names` and send the stdout to another file, called `/tmp/newnames`. It's not an ideal example since the same thing can be achieved with a __cp__ (copy) command, but hopefully you get the idea:

```shell
% cat /tmp/names
John
Alice
Philip
Karen
%
% cat < /tmp/names > /tmp/newnames
%
% cat /tmp/newnames 
John
Alice
Philip
Karen
```

That completes the shell lesson. You should now be ready to move on to some additional shell programming topics. [Click here to return to the lesson list](../README.md)
