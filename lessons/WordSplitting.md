# Lesson 8 - Word Splitting #

We have mentioned __word splitting__ a few times now. We could describe this lesson another way and describe it as _white space handling_ is shell programming, in other words dealing with spaces and tabs. __Word splitting__ is an action performed by the shell where it splits the command line into "words". The shell does this by scanning the command line looking for word separators, such as spaces and tabulations, or command terminators (such as `;` or `&`), and quotes (`'` and `"`), which we've seen in [Lesson 5 - Fun with quotes](../lessons/FunWithQuotes.md).

Note that the shell will ignore word delimiters or separators if they are escaped (preceded by a backslash, or `\`), or if they are inside a quote (single or double).

Once the splitting is performed, the shell will pass each word separately to the application. This means that the application will not see the separators - they will be lost. This makes sense in the average case, but what can you do if you need to work on a file whose name contains spaces (e.g. pass it as an argument to a script), and you do not want the name of the file to be split up into multiple words? Let's have a look.

Again, note the use of `%` to distinguish between shell command and output. If copying and pasting these commands to your own shell, omit the `%`.

First, let's try to create a files with spaces in the name:

```shell
% cd /tmp/
% cat > file with spaces in the name
cat: with: No such file or directory
cat: spaces: No such file or directory
cat: in: No such file or directory
cat: the: No such file or directory
cat: name: No such file or directory
```

What happened?

```shell
% ls
file
```

The word splitting here is working against you. The shell has split the file name into 6 file names, and assumed you issued a command to create a file called `file`. By passing additional arguments, the __cat__ command then assumed that you wanted to copy into that file the content of a bunch of other files, such as `with`, `spaces`, `in`, `the`, and `name`.

Do you want to verify that this is the behaviour? Let's try it. Let's create these files individually:

```shell
% for fname in with spaces in the name
do
  echo $fname > fname
done
```

What this does is, via a `for` loop, create 5 files, respectively called "with", "spaces", "in", "the" and finally "name, and sets the contents of each of the files to be the same as the filename. So the file "with" contains the contents "with", the file "spaces" contains the contents "spaces", and so on.

You can check the content of all the files with `grep`. When `grep` has more than 1 file to work with, it will by default prepend each line of output with the name of the current file and a colon (`:`). So, if we `grep` for a pattern that will match every line of every file, we'll see the content of every file. We can use `.` as a generic pattern which will basically match any single character.

```shell
% grep . with spaces in the name
with:with
spaces:spaces
in:in
the:the
name:name
```

Now, let's try the command again:

```shell
% cat > file with spaces in the name
```

And now let's check the contents of the file called `file`:

```shell
% cat file
with
spaces
in
the
name
```

Clearly it has copied the content of all these files into `file`. Not what we wanted. How shall we deal with this then? __Use Quotes!__ Try the same command, but put the file in quotes, and then type something that will go in the file, press enter and then `ctrl-d`.  `ctrl-d` means **end of file**, or **end of input**.

Be careful where you type it, because if you type `ctrl-d` in a shell, you're telling the shell `logout`.

```shell
% rm file with spaces in the name
% cat > "file with spaces in the name"
...type something here...
ctrl-d
```

Now create another file with spaces in the name, using `touch` command to create an empty file:

```shell
% touch "another file"
```

Now, what happens if you are processing these files in a `for` loop? Let's say you want to print each filename, followed by the file contents. You might do something like this `for` loop to achieve this goal:

```shell
% for f in *file*
do
  echo $f:
  cat $f
done
another file:
cat: another: No such file or directory
cat: file: No such file or directory
file with spaces in the name:
cat: file: No such file or directory
cat: with: No such file or directory
cat: spaces: No such file or directory
cat: in: No such file or directory
cat: the: No such file or directory
cat: name: No such file or directory
```

We seem to be able to get the filename printed with the `echo` command but not the file contents using the `cat` command. Once again, the word splitting is working against us. If you remember, the word splitting happens **after** the various expansions, and in this case the variable expansion brings in the spaces in the name of the files.

But, as the author of this script, you can't control what comes in as input to your script. You are simply doing a `for f in *file*`. So what can you do to handle this expansion behaviour?

The golden rule for shell scripting is this: __never use any variable as a path or command name without double quoting it__:

```shell
% for f in *file*
do
  echo $f:
  cat "$f"
done
another file:
this is the content of another file
file with spaces in the name:
this is the content of file with spaces in the name
```

If you are using `@`, for example to work on all the parameters of a script (e.g. `$@`), or all the values of an array (e.g. `${mysuperarray[@]}`), the idea is the same: double-quote them, the shell will take care of double quoting each value individually for you.

If you paid attention, you might have an objection to the above: why does the `for` work fine with spaces? Shouldn't it fail too? To answer that, let's try first to see what happens if you use `ls`:

```shell
% for f in $(ls *file*)
do
  echo $f:
  cat "$f"
done

another:
cat: another: No such file or directory
file:
cat: file: No such file or directory
file:
cat: file: No such file or directory
with:
cat: with: No such file or directory
spaces:
cat: spaces: No such file or directory
in:
cat: in: No such file or directory
the:
cat: the: No such file or directory
name:
cat: name: No such file or directory
```

This is what you'd have expected from the `for` above. The output of `ls` is basically a bunch of words and spaces, meaning that we can't even get the file names, but why does it work without `ls` ?

Let's simplify the test, and just use a variable.

```shell
% A=*file*
% echo $A
another file file with spaces in the name
```

What we've done here is that we've forced _pathname expansion_ to happen _before_ word splitting, because we do them in different lines! This is another explanation for why it is important to keep in mind the order of operations for expansion.

Let's look at the events that occur when we run the `for f in $(ls *file*)` part:

1. The shell detects that there is a command substitution (the `$()`), so it starts a subshell for that
1. The subshell runs `ls *file*` following the usual order of processing. There is no expansion here, since we do not have any `$`, so the subshell moves to word-splitting (there's only 1 space between `ls` and `*file*`), and then pathname expansion of `*file*`.
1. After pathname expansion, the main shell, which is still performing expansion, will replace the place-holder represented by the command substitution with the output of the subshell, so `$(ls *file*)` will become `another file file with spaces in the name`
1. You might see now where this is going: after all the expansions, the shell will move to word-splitting, and we are in trouble, since we have just introduced a lot of spaces!

So why does the `for f in *file*` work instead? Well, there's no expansion. Word-splitting finds only 3 spaces to work with, wich are intentional - between the `for` and `f`, between the `f` and `in`, and between the `in` and `*file*`. Only _then_ does it perform the pathname expansion by creating additional parameters, one per file. The fact that these contain spaces is irrelevant to the shell.

This is one of the most common sources of errors in shell scripting. You might therefore decide to use double-quotes everywhere, but that comes with additional challenges. For example, what if you are in the situation above, where you have these 2 files: `file with spaces in the name` and `another file`. Your script is expected to work on files that contain a word that is passed in via a variable, rather than a fixed string such as `file`, so you might be tempted to do something like this:

```shell
% fname=file
% for f in "*$fname*"
do
  echo $f:
  cat "$f"
done
*file*:
cat: '*file*': No such file or directory
```

What is happening here is that the quotes inhibit pathname expansion, and therefore the only value that `for` has to iterate over is the string `*file*`. "Easy", you might say. "Just remove the quotes from the `cat` command, and the pathname expansion will do the job for me!". Well, yes and no: it will do something, but not what you want:

```shell
% fname=file
% for f in "*$fname*"
do
  echo $f:
  cat $f
done
*file*:
this is the content of another file
this is the content of file with spaces in the name
```

As you can see, the `cat` did indeed do show us the content of the 2 files, but we see their content all merged together, and more importantly: why did the `echo` print `*file*` instead of the 2 file names ?

If you look carefully, there's a colon (`:`) after $f, so this translates to `echo *file*:`, and again, word-splitting happens *before* pathname-expansion, so the word is `*file*:`, and there's no file matching that pattern, in other words, there's no file that contains ¬file¬ in the name and ends with a colon! So pathname expansion does not happen.

If you remove the colon from the `echo`, you'll get proof of this:

```shell
% fname=file
% for f in "*$fname*"
do
  echo $f
  cat $f
done
another file file with spaces in the name
this is the content of another file
this is the content of file with spaces in the name
```

So, the solution in this case is to quote just the variable, but not the pattern.

```shell
% fname=file
% for f in *"$fname"*
do
  echo $f:
  cat $f
done
another file:
this is the content of another file
file with spaces in the name:
this is the content of file with spaces in the name
```

The golden rule should be that anything that the programmer can't control should end up being quoted. For example, if you are in the same directory with these 2 files with spaces, and you do a `find`, you'd get this:

```shell
% find . -type f
./another file
./file with spaces in the name
```

If you want your script to work on a bunch of files that a `find` commands produces, and if you do not strictly control the names of all the files and directories "found" by `find`, you are exposed to the same issue.

If you use `find "$somedirectory" -type f | while read fname`, the read fname will not be impacted by any space, because you have only 1 variable name, and in that case, the splitting doesn't happen (but it will happen if you have more than 1 variable!). Then, inside the `while` loop, you need to protect the `$fname` variable from word-splitting by double-quoting it.

That completes the word splitting / white spaces handling lesson. [Click here to return to the lesson list](../README.md)
