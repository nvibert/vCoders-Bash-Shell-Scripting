# Lesson 3 - Your First Shell Script #

In the next few lessons, we will look at examples of scripts that will look like similar to this:

```shell
while read -p "What's your name? " Name
do
  if test "$Name"
  then
    echo "Hello there, $Name"
    sleep 1s
  else
    echo "There's no one"
    break
 fi
done
```

The example above is a collection of commands that builds up the logic to make a script solve a certain problem. To make the shell run this, you have 2 options:

* type (or copy and paste) these lines into a shell
* type (or copy and paste) these lines into a file, and make that file a script.

To avoid repeating these instructions for each of the upcoming examples, we will assume that you are comfortable with trying both. In general, shell scripting will assume either form, depending on the situation: if you need to perform a one-off task, you will probably just type your script in the shell. If this task is something you'll end up doing repeatedly and/or frequently, it's better to keep it as a script.

But how does one turn a bunch of commands into a script? __It's easy!__

Using your favourite editor, create a new file, give it an appropriate name (there's no need to specify any specific extension! Many people like to follow a convention of adding `.sh` at the end, but that's not required). Let's say you will call this file `HelloWorld`, in the `/tmp` direcrtory.

Now type the following text inside this file, and save the file:

```shell
echo "Hello, world!"
```

If you are unfamiliar with the machine you are using for this course, and you don't know what is your "favourite editor", you can use `nano`, which is more friendly for inexperienced users. Just check the bottom part of the screen for hints of what to do, keeping in mind that `^` in that context means `control`, so `^X` means `control-x`.

This means that the command to create the file would be `nano /tmp/HelloWorld`. Type the line above, hit `control-X`, and follow the instructions (press `y` and then confirm the file name).

Now that you have your first file, try to run it:

```shell
/tmp/HelloWorld
```

You'll be surprised: It doesn't print what you expected, but rather something like this: `bash: /tmp/HelloWorld: Permission denied`. This is because your file is not executable. You can make it executable with `chmod`:

```shell
chmod +x /tmp/HelloWorld
```

And then try again:

```shell
/tmp/HelloWorld
Hello, World!
```

It works! But it isn't technically a shell script yet. `file` is a command that tells you what kind of file you are dealing with:

```shell
file /tmp/HelloWorld
/tmp/HelloWorld: ASCII text
```

`file` detected our script as a text file. So why does it still work? This is because you are already running a shell, the one where you are typing your commands, so the shell will try, by default, to read everything as a shell script.

There's nothing wrong with leaving this like that, but if you want to do things the proper way (and if you plan to run this script on a bunch of different machines you do not control), you might want to add what is called a __"shebang"__. 
First, find out where bash is running, using the __which__ command. Your __bash__ may be in a different location to the one shown here:

```shell
which bash
/bin/bash
```

Now go back to your editor, and add the following line at the top of your file, with the PATH to your bash shell binary:

```shell
#!/bin/bash
```

What this does is it tells anyone trying to execute this script that the interpreter that needs to be used is `/bin/bash`. If you want to make the script more portable, you might use a more generic `#!/bin/sh` (again, confirm the PATH with the __which__ command, e.g. which sh), but keep in mind that this will disable a bunch of advanced features of bash. Each shell has its own unique features and options.

So, what does `file` say about the script now that we have the shebang pointing to `/bin/bash` ?

```shell
file /tmp/HelloWorld
/tmp/HelloWorld: Bourne-Again shell script, ASCII text executable
```

Does the script still work ? Try it!

And what if instead, we set the shebang to the bourne shell `/usr/bin/sh` (or whereever `sh` is location on your system)?

```shell
which sh
/usr/bin/sh
```

```shell
file /tmp/HelloWorld
/tmp/HelloWorld: a /usr/bin/sh script, ASCII text executable
```

Does that work too ? Try to run it!

From now on, we will just list the contents of the scripts, and you will have the choice of typing them straight into your shell, or you can put them into a script, with or without the shebang, and then run the script to see what it does.

That completes the first shell script lesson. Let's move on to some other shell programming topics. [Click here to return to the lesson list](../README.md)
