# Lesson 12 - Advanced Power Tools - find #

In [Lesson 2 - Power Tools](./lessons/PowerTools.md) We had a look at some useful commands/tools that you can use as building blocks for your shell scripts. In this lesson we will look at some of these tools more in depth, and we will look at some additional tools that might be useful in some more complicated scripts.

## `find` ##

We have seen that find is a tool to produce a list of files and directories based on a set of criteria, here we will look at some of its advanced features.

Please refer to the `find(1)` man page for more details.

### `-type` ###

The `-type` option specifies a filter on the type of the filesystem object. The most common types are:

- `f` for file
- `d` for directory

Try this out in your machine: select a directory with some files and directories, such as `/etc`. First try find alone. This will produce a lot of output, so use a pager like `less`:

```shell
find /etc | less
```

If you are not familiar with pagers like `less` or `more`, just use your arrow keys and spacebar to scroll, and press `q` to exit when you're done. Notice how you are getting a mix of files and directories in the output.

__Note__: If you are trying this exercise on MacOS, you will notice that the above command only returns the folder `/etc`. This is because `/etc` is a symbolic link of `private/etc` on MacOS, and find normally ignored symbolic links. Do an `ls -al /etc` to confirm. To get the list of files from `/etc`, either use the `-L` option to the `find` command so that it searches symlinks, or run find on `/private/etc`.

Now, run the same commands as before, but specify a `-type d`.

Let's try first without the pager, less:

```shell
find -type d /etc 
find: paths must precede expression: `/etc/'
find: possible unquoted pattern after predicate `-type'?
```

You get an error! This is because `find` is very prescriptive with various type of parameters and options and their order:

1. Symbolic link related options
1. Starting point related options
1. Expressions, which contain filtering criteria (called tests) and actions

So, the mistake in our last command is that we specified a test (`-type d`) *before* the starting point (`/etc`). Let's swap them around, and re-introduce the pager:

```shell
find /etc -type d | less
```

Note how the output is much shorter, and that each line is a directory. Try now with the `-type f` option instead:

```shell
find /etc -type f | less
```

Tests can be combined, so you can look in `/tmp` for files (`-type f`) whose name ends in `.bak`, and select an action such as `-delete`. __Note__: `/tmp` is also a symlinked directory to `/private/tmp` on MacOS, so the command will also require a `-L` to work.

Before deleting, you'd better check if you got the syntax right, so use the `-print` action (the default), and swap to `-delete` once you are sure:

```shell
find /tmp -name "*.bak" -type f
```

If you did not get any files returned, it is because we do not have any files that match the requirement, e.g. there are no files in `/tmp` that end in `.bak`.

Now go in `/tmp` and using `touch`, create a few files, and put some of them in some directories. You can use brace expansion or for loops now that you are an expert!

```shell
mkdir /tmp/backup{1..5}
touch /tmp/backup{1..5}/backup{1..5}.bak
touch /tmp/backup{1..5}.bak
```

Now, to add some complexity, add a few backup directories too!

```shell
mkdir /tmp/oldbackup{1..5}.bak
```

To check that we've done well, we can use `find`:

```shell
find /tmp -name "*.bak"
```

If you've done everything as indicated, you should see something like this:

```shell
/tmp/backup1/backup1.bak
/tmp/backup1/backup2.bak
/tmp/backup1/backup3.bak
/tmp/backup1/backup4.bak
/tmp/backup1/backup5.bak
/tmp/backup2/backup1.bak
/tmp/backup2/backup2.bak
/tmp/backup2/backup3.bak
/tmp/backup2/backup4.bak
/tmp/backup2/backup5.bak
/tmp/backup3/backup1.bak
/tmp/backup3/backup2.bak
/tmp/backup3/backup3.bak
/tmp/backup3/backup4.bak
/tmp/backup3/backup5.bak
/tmp/backup4/backup1.bak
/tmp/backup4/backup2.bak
/tmp/backup4/backup3.bak
/tmp/backup4/backup4.bak
/tmp/backup4/backup5.bak
/tmp/backup5/backup1.bak
/tmp/backup5/backup2.bak
/tmp/backup5/backup3.bak
/tmp/backup5/backup4.bak
/tmp/backup5/backup5.bak
/tmp/backup1.bak
/tmp/backup2.bak
/tmp/backup3.bak
/tmp/backup4.bak
/tmp/backup5.bak
/tmp/oldbackup1.bak
/tmp/oldbackup2.bak
/tmp/oldbackup3.bak
/tmp/oldbackup4.bak
/tmp/oldbackup5.bak
```

We get all our files, and also some of the directories, which we do not want to delete!

But before that, some of you might ask: why do you need to quote the argument for `-name` ? Can't we just use it as is ? Or better: what happens if we don't quote the pattern ?

Let's check 2 different cases: when you are not in `/tmp` and when you are.

```shell
cd /
find /tmp -name *.bak
```

This works as expected! So, it looks like we do not really need to use the quotes! What if we go into `/tmp` then ?

```shell
cd /tmp
find /tmp -name *.bak
find: paths must precede expression: `backup2.bak'
find: possible unquoted pattern after predicate `-name'?
```

See, what is happening here is that the shell's pathname expansion got all excited about that `*.bak`, and expanded it for you before find was even started. If you want to check this out more in detail, add an `echo` in front of the `find`, so we can see what `find` actually thought you'd typed:

```shell
echo find /tmp -name *.bak
find /tmp -name backup1.bak backup2.bak backup3.bak backup4.bak backup5.bak oldbackup1.bak oldbackup2.bak oldbackup3.bak oldbackup4.bak oldbackup5.bak
```

This is because in the current directory we have files that match the pattern `*.bak`. In the previous directory, we did not!

To repeat, __best practice__: quote all the arguments that look like a pathname expansion pattern, but that are not meant for the shell to expand. The `-name` and `-iname` options of `find` are almost always a candidate for this.

The "starting point" for your find might have good reasons to contain _pathname expansion_ pattern, if you want to look into multiple support bundles which we will see later, for example: `find esx-* -name "*.log"`

Now, back to our task: first list, and then delete, all the `*.bak` files, but not directories.

```shell
find /tmp -name "*.bak" -type f
```

Does it matter the order of the tests ?

```shell
find /tmp -type f -name "*.bak"
```

The output should be the same:

```shell
/tmp/backup1/backup1.bak
/tmp/backup1/backup2.bak
/tmp/backup1/backup3.bak
/tmp/backup1/backup4.bak
/tmp/backup1/backup5.bak
/tmp/backup2/backup1.bak
/tmp/backup2/backup2.bak
/tmp/backup2/backup3.bak
/tmp/backup2/backup4.bak
/tmp/backup2/backup5.bak
/tmp/backup3/backup1.bak
/tmp/backup3/backup2.bak
/tmp/backup3/backup3.bak
/tmp/backup3/backup4.bak
/tmp/backup3/backup5.bak
/tmp/backup4/backup1.bak
/tmp/backup4/backup2.bak
/tmp/backup4/backup3.bak
/tmp/backup4/backup4.bak
/tmp/backup4/backup5.bak
/tmp/backup5/backup1.bak
/tmp/backup5/backup2.bak
/tmp/backup5/backup3.bak
/tmp/backup5/backup4.bak
/tmp/backup5/backup5.bak
/tmp/backup1.bak
/tmp/backup2.bak
/tmp/backup3.bak
/tmp/backup4.bak
/tmp/backup5.bak
```

Now, you can finally add the `-delete` and free up some space

```shell
find /tmp -type f -name "*.bak" -delete
```

This demonstrates that you can combine multiple tests in find. Once again, __note__ that MacOS won't let you delete files via a symlink find `-L`. To run the above exercise, you will have to use the `/private/tmp` path and not the symlinked `/tmp`.

### `-maxdepth' ###

The `-maxdepth` option is useful to limit the amount of levels that find will descend in the directory structure. If you have a very big tree, you might now want to spend all the time to scan all of the sub-directories, so you might use this option, but there's also another and probably more interesting use-case, which is to `find` fiesystem objects that match your criteria, but only in the current directory. For example: how can you list all the directories in `/etc`, but not files?

If you try with `ls`, it has a `-d` option, to avoid descending directories, but it will still show you all the files too:

```shell
ls /etc | wc -l
235
ls -d /etc/|wc -l
1
ls -d /etc/* |wc -l
235
```

As you can see, the `ls -d /etc` listed only `/etc` and not its contents. If we add a "wildcard" (`*`), it goes back listing all the files and directories together.

With `find` and `-maxdepth 1`, we can get the answer we were looking for:

```shell
find /etc -maxdepth 1 -type d | wc -l
122
```

If you don't specify `-maxdepth 1`, you count all the directories in the tree:

```shell
find /etc -type d | wc -l
259
```

### `-exec` ###

The `-exec` action runs the specified command on each file found. The "command" to be run is build by scanning everything that comes after the `-exec`, up until a semicolon (`;`), which has a special meaning for the shell, and by replacing any `{}` found in between with the name of each file found.

Because of the choice of the command terminator (`;`) and the file name place-holder (`{}`), there is a lot of potential interference by the shell, so a lot of quoting or escaping needs to be performed to protect these symbols from the shell, to ensure that `find` will receive them unchanged.

The typical format of `-exec` is something like this:

```shell
find /var/log -type f -name "*.log" -exec grep -l error "{}" \;
```

This will find any file that is a log, in the `/var/log` directory, and search it for any error, and if any is found, print its name.

The parts that are important to notice are the last 2 arguments of the command: the `"{}"` and the `\;`.

The former is the place-holder for each of the found files, and the latter is the terminator, escaped to make sure the shell does not consider it as the terminator for the `find` command, but rather as the terminator for whatever command comes after `exec`.

### `-printf` ###

As we've seen, the default action, if none is specified, is `-print`, which prints the path of the object, followed by a newline (`/n`). There's a sister option called `-print0`, which replaces the newline with a "null" character (`\0`), which is handy if you plan to machine-parse the output, since it is not possible to have a file with a null character in its name.

There is also a 3rd option (technically there are more, such as `-ls`), called `-printf`, which allows you to customise what you print. __Note__: May not be available on MacOS.

As the name suggest, `-printf` works like the C language's `printf` function that has been adopted by several other languages. It uses a format string as its parameter, based on the '%' symbol as place-holder.

There are several parameters you can use in the format string, and the `find(1)` man page is the best place to start reading about them. Here are just a few examples:

`%p` file path and name
`%P` file path and name without starting point
`%H` Just the starting point
`%f` file name only, no path
`%h` file name's path without name
`%s` size in bytes
`%k` Amount of kilobytes of disk space used to store this file

… and many more!

Something to remember is that `-printf` does not add a newline (`\n`) or a null (`\0`) automatically at the end of each entry by default, so that the user remains in total control of the output, for human or machine parsing.

The useful aspect of `-printf` is down to the fact that in some cases the use case requires parsing and changing of the file, and `-printf` can probably avoid doing this in the shell.

Let's see some examples. First, prepare a directory with some files that we will "find".

```shell
cd /tmp
mkdir searchandfind
mkdir searchandfind/dir{1,2}
touch searchandfind/dir{1,2}/file{1..5}
```

Now, the default behaviour of `find` is `-print`:

```shell
find /tmp/searchandfind -print
/tmp/searchandfind/
/tmp/searchandfind/dir1
/tmp/searchandfind/dir1/file1
/tmp/searchandfind/dir1/file2
/tmp/searchandfind/dir1/file3
/tmp/searchandfind/dir1/file4
/tmp/searchandfind/dir1/file5
/tmp/searchandfind/dir2
/tmp/searchandfind/dir2/file1
/tmp/searchandfind/dir2/file2
/tmp/searchandfind/dir2/file3
/tmp/searchandfind/dir2/file4
/tmp/searchandfind/dir2/file5
```

Which is the same as `-printf "%p\n"`

```shell
find /tmp/searchandfind/ -printf "%p\n"
/tmp/searchandfind/
/tmp/searchandfind/dir1
/tmp/searchandfind/dir1/file1
/tmp/searchandfind/dir1/file2
/tmp/searchandfind/dir1/file3
/tmp/searchandfind/dir1/file4
/tmp/searchandfind/dir1/file5
/tmp/searchandfind/dir2
/tmp/searchandfind/dir2/file1
/tmp/searchandfind/dir2/file2
/tmp/searchandfind/dir2/file3
/tmp/searchandfind/dir2/file4
/tmp/searchandfind/dir2/file5
```

What happens if one forgets the `\n` ?

```shell
find /tmp/searchandfind/ -printf %p
/tmp/searchandfind//tmp/searchandfind/dir1/tmp/searchandfind/dir1/file1/tmp/searchandfind/dir1/file2/tmp/searchandfind/dir1/file3/tmp/searchandfind/dir1/file4/tmp/searchandfind/dir1/file5/tmp/searchandfind/dir2/tmp/searchandfind/dir2/file1/tmp/searchandfind/dir2/file2/tmp/searchandfind/dir2/file3/tmp/searchandfind/dir2/file4/tmp/searchandfind/dir2/file5
```

Everything is jumbled together in a single line. Since the last line of the output also lacks a newline, the shell prompt might be a bit messed up, you can fix it with `control-l` to force a clean-up of the screen.

You'll get a similar result if you specify `\n` but without quotes:

```shell
find /tmp/searchandfind/ -printf %p\n
/tmp/searchandfind/n/tmp/searchandfind/dir1n/tmp/searchandfind/dir1/file1n/tmp/searchandfind/dir1/file2n/tmp/searchandfind/dir1/file3n/tmp/searchandfind/dir1/file4n/tmp/searchandfind/dir1/file5n/tmp/searchandfind/dir2n/tmp/searchandfind/dir2/file1n/tmp/searchandfind/dir2/file2n/tmp/searchandfind/dir2/file3n/tmp/searchandfind/dir2/file4n/tmp/searchandfind/dir2/file5n
```

This is because the backslash (`\`) is intercepted by the shell, if you want `find` to receive it, you need to either quote it, or escape it with another backslash

```shell
find /tmp/searchandfind/ -printf %p\\n
/tmp/searchandfind/
/tmp/searchandfind/dir1
/tmp/searchandfind/dir1/file1
/tmp/searchandfind/dir1/file2
/tmp/searchandfind/dir1/file3
/tmp/searchandfind/dir1/file4
/tmp/searchandfind/dir1/file5
/tmp/searchandfind/dir2
/tmp/searchandfind/dir2/file1
/tmp/searchandfind/dir2/file2
/tmp/searchandfind/dir2/file3
/tmp/searchandfind/dir2/file4
/tmp/searchandfind/dir2/file5
```

The double-quoting looks more elegant, and plays better to the habit of a shell programmer to quote almost everything else anyway.

The `%P` is similar to `%p`, but it produces the path relative to the starting point:

```shell
find /tmp/searchandfind/ -printf "%P\n"

dir1
dir1/file1
dir1/file2
dir1/file3
dir1/file4
dir1/file5
dir2
dir2/file1
dir2/file2
dir2/file3
dir2/file4
dir2/file5
```

This is useful, for example, if you want to synchronise or compare files from 2 directories, without having to remove the first part of each file in shell.

If you use `%f`, you get an even shorter output: just the last part of the name, without any path at all:

```shell
find /tmp/searchandfind/ -printf "%f\n"
searchandfind/
dir1
file1
file2
file3
file4
file5
dir2
file1
file2
file3
file4
file5
```

And if you use the `%h` you get the opposite of `%f`: the path to each file

```shell
find /tmp/searchandfind/ -printf "%h/%f\n"
/tmp/searchandfind/
/tmp/searchandfind/dir1
/tmp/searchandfind/dir1/file1
/tmp/searchandfind/dir1/file2
/tmp/searchandfind/dir1/file3
/tmp/searchandfind/dir1/file4
/tmp/searchandfind/dir1/file5
/tmp/searchandfind/dir2
/tmp/searchandfind/dir2/file1
/tmp/searchandfind/dir2/file2
/tmp/searchandfind/dir2/file3
/tmp/searchandfind/dir2/file4
/tmp/searchandfind/dir2/file5
```

Similarly, the `%H` gives you the starting point

```shell
find /tmp/searchandfind/ -printf "%H\n"
/tmp/searchandfind/
/tmp/searchandfind/
/tmp/searchandfind/
/tmp/searchandfind/
/tmp/searchandfind/
/tmp/searchandfind/
/tmp/searchandfind/
/tmp/searchandfind/
/tmp/searchandfind/
/tmp/searchandfind/
/tmp/searchandfind/
/tmp/searchandfind/
/tmp/searchandfind/
```

This might look pointless, since that's just the parameter that was passed to find, but inside a script this information might not be directly available, for example if there are multiple starting points:

```shell
find /tmp/searchandfind/dir{1,2} -printf "%H\n"
/tmp/searchandfind/dir1
/tmp/searchandfind/dir1
/tmp/searchandfind/dir1
/tmp/searchandfind/dir1
/tmp/searchandfind/dir1
/tmp/searchandfind/dir1
/tmp/searchandfind/dir2
/tmp/searchandfind/dir2
/tmp/searchandfind/dir2
/tmp/searchandfind/dir2
/tmp/searchandfind/dir2
/tmp/searchandfind/dir2
```

You can combine all these together to build more complicated actions, such as moving files in other places, maintaining the same structure.

For example, if you want to move some files from where they are into a certain directory called `somenewdirectory`, but you want to preserve the structure, you could do something like this:

Step 1: create the new directories:

```shell
find /tmp/searchandfind/ -type d -printf "%Hsomenewdirectory/%P\n" | while read d;
do
mkdir -p $d
done
```

Step 2: test the output of the

```shell
find /tmp/searchandfind/ -type f -name "file*" -printf "copy %p to %Hsomenewdirectory/%P\n"
copy /tmp/searchandfind/dir1/file1 to /tmp/searchandfind/somenewdirectory/dir1/file1
copy /tmp/searchandfind/dir1/file2 to /tmp/searchandfind/somenewdirectory/dir1/file2
copy /tmp/searchandfind/dir1/file3 to /tmp/searchandfind/somenewdirectory/dir1/file3
copy /tmp/searchandfind/dir1/file4 to /tmp/searchandfind/somenewdirectory/dir1/file4
copy /tmp/searchandfind/dir1/file5 to /tmp/searchandfind/somenewdirectory/dir1/file5
copy /tmp/searchandfind/dir2/file1 to /tmp/searchandfind/somenewdirectory/dir2/file1
copy /tmp/searchandfind/dir2/file2 to /tmp/searchandfind/somenewdirectory/dir2/file2
copy /tmp/searchandfind/dir2/file3 to /tmp/searchandfind/somenewdirectory/dir2/file3
copy /tmp/searchandfind/dir2/file4 to /tmp/searchandfind/somenewdirectory/dir2/file4
copy /tmp/searchandfind/dir2/file5 to /tmp/searchandfind/somenewdirectory/dir2/file5
```

Step 3: perform the copy

```shell
find /tmp/searchandfind/ -type f -name "file*" -printf "%p %Hsomenewdirectory/%P\n"| while read fromname toname
do
  cp "$fromname" "$toname"
done
```

Step 4: verify

```shell
find /tmp/searchandfind/somenewdirectory/
/tmp/searchandfind/somenewdirectory/
/tmp/searchandfind/somenewdirectory/dir1
/tmp/searchandfind/somenewdirectory/dir1/file1
/tmp/searchandfind/somenewdirectory/dir1/file2
/tmp/searchandfind/somenewdirectory/dir1/file3
/tmp/searchandfind/somenewdirectory/dir1/file4
/tmp/searchandfind/somenewdirectory/dir1/file5
/tmp/searchandfind/somenewdirectory/dir2
/tmp/searchandfind/somenewdirectory/dir2/file1
/tmp/searchandfind/somenewdirectory/dir2/file2
/tmp/searchandfind/somenewdirectory/dir2/file3
/tmp/searchandfind/somenewdirectory/dir2/file4
/tmp/searchandfind/somenewdirectory/dir2/file5
```

If you wanted to do this without `-printf`, you would have needed to use a `find | while read` where you'd have to find the "starting point" part, remove it, insert the new component of the path, and join it all together, but in case of multiple search points, you would have needed to use an outer `for` loop, so that you'd know each starting point, to be able to remove each one from the output. This approach is a lot simpler and more efficient too.

There are many other variables you can use in `-printf`, besides the names, which will help you build any sort of report or script. We look here at `%s` and `%k` as one example:

```shell
 find /etc/ -name "*bash*" -printf "%p - size:%s bytes, disk usage:%k kb\n"
/etc/skel/.bashrc - size:3526 bytes, disk usage:4 kb
/etc/skel/.bash_logout - size:220 bytes, disk usage:4 kb
/etc/bash.bashrc - size:2022 bytes, disk usage:4 kb
/etc/bash_completion.d - size:48 bytes, disk usage:0 kb
/etc/profile.d/bash_completion.sh - size:726 bytes, disk usage:4 kb
/etc/bash_completion - size:45 bytes, disk usage:4 kb
/etc/bash.bashrc.dpkg-dist - size:1994 bytes, disk usage:4 kb
```

That completes the Advanced Power Tools lesson on `find`. [Click here to return to the lesson list](../README.md)
