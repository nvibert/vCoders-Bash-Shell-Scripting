# Lesson 4 - An introduction to Compound Commands #

There are many compound commands in the bash shell, some of which we have already met in earlier lessons. Some compound commands are looping constructs, whilst others are conditional constructs. In this lesson, we are going to spend some time looking at (and revisiting) the following compound commands:

- if-then-fi
- for-do-done
- while-do-done
- case-esac
- select-do-done

These compound commands and constructs will form the basis for many more complex shell scripts, which will be discussed in detail when you get to some later lessons. This lesson is a primer to help you understand the functionality of these constructs

What you will notice as we progress through the exercises is that some of these conditional statements can be combined to add more powerful logic to a shell script.

## if-then-fi ##

The __if-then-fi__ statement is used to test if a statement is true or correct, and then to take an action depending on the outcome of the test. The format is:

```shell
if <some-condition>
then
    <take-some-course-of-action>
fi
```

## if-then-else-fi ##

The __if-then-fi__ statement can be extended to include an __else__ clause. It is again used to test if a statement is true or correct, and then to take an action depending on the outcome of the test. The format now becomes:

```shell
if <some-condition>
then
    <take-some-course-of-action>
else
    <take-some-other-course-of-action>
fi
```

Note that the stanza is opened with an __if__ statement and closed with a __fi__ statement. The stanza can be expanded even more through the use of __elif__ to test some other conditions.

```shell
if <test-some-condition>
then
    <take-some-course-of-action>
elif <test-some-other-condition>
then
    <take-some-other-course-of-action>
else
    <take-some-other-different-course-of-action>
fi
```

However, as the number of conditions grow, this becomes slow to test every condition. We will see some other condition statements that handle multiple conditions more elegantly shortly.

### Testing for some condition ###

Both the __if__ and __elif__ statements test if some condition is true or false. Your shell has a __test__ command, as we will see next.

```shell
% echo $PWD
/Users/chogan/bashshellscripting

% if test $PWD == "/Users/chogan/bashshellscripting"
then 
echo TRUE
else 
echo FALSE
fi
TRUE

% if test $PWD == "/tmp"
then 
echo TRUE
else 
echo FALSE
fi
FALSE
```

Hopefully the above script is fairly easy to understand. My working directory `$PWD` is __/Users/chogan/bashshellscripting__. The __if__ statement is testing if this is correct. It is, so the script prints TRUE.

However if I stay in the same directory, but change the test condition to check if my working directory is __/tmp__, the script prints false.

Let's take another example. This one will take a name that you typed in and return a greeting. Note that this only returns something if you provide some input for your name:

```shell
read -p "What's your name? " Name
if test "$Name"
then
  echo "Hello there, $Name"
fi
```

Now, you might observe that if you type a name, you get the greeting. But if you just press enter, nothing happens. This might leave you wondering if the program is actually working. To address this, we can add an alternative execution path with the `else`:

```shell
read -p "What's your name? " Name
if test "$Name"
then
  echo "Hello there, $Name"
else
  echo "Hello there, whoever you are"
fi
```

Now, if you notice in the previous example, there is a part of the script that is the same for both code paths, i.e. the `echo "Hello there, "` appears in both the __if__ and __else__ sections. This repeated text/code can be avoided. The trick here is the `-n` option to `echo`, which basically means "don't start a new line automatically after writing this text". This allows the "Hello there, $Name" to be printed on the same line, allowing us to stitch together the output from multiple lines.

```shell
read -p "What's your name? " Name
echo -n "Hello there, "
if test "$Name"
then
  echo "$Name"
else
  echo "whoever you are"
fi
```

The command `test` is a frequent choice for conditions in `if` and many other compound commands, and it is a shell builtin:

```shell
type test
test is a shell builtin
```

So, you can find more about `test` in the `shell-builtin(7)` man page, but it contains just a brief description. However `test` also happens to be a real command:

```shell
which test
/usr/bin/test
```

This means that you can also use `man test` to look up the `test(1)` man page, which has a lot more detail on what you can do with it.

In many conditional statements, shorthand for __test__ is to encapsulate the condition you are testing in square brackets `[ ]`. Note also that there must be a space between the brackets and the condition that we are testing, both at the beginnning and end of the statement. Now, I can write the same functionality using the square bracker shorthand.

```shell
% echo $PWD
/Users/chogan/bashshellscripting

% if [ $PWD == "/Users/chogan/bashshellscripting" ]
then 
echo TRUE
else 
echo FALSE
fi
TRUE

% if [ $PWD == "/tmp" ]
then 
echo TRUE
else 
echo FALSE
fi
FALSE
```

Take a minute or two to look at this sample [if-then-else script](./samples/if-then-else-fi.sh). Can you understand what it does by simply reading the code? Run it in your own shell to see if what you thought it did was correct.

## while-do-done ##

The while loop contains 2 sections: the conditional command, and a list of commands to be continuously executed **while** the conditional expression is true. The __while loop__ format is:

```shell
while <some-condition>
do
    <some-task-or-tasks>
done
```

Here is a simple loop which will continue to look for input until the value that is inputted is an '1'. Note that the test condition is using square brackets. The __read__ command looks for an input.

```shell
% i=0
% while [ $i != 1 ]
do
    echo "$i is not equal to 1, enter a new value:"
    read i
done
```

Since the `while` is similar to a "repeating `if`", we could re-use the name example above, and switch it to greet a large number of people:

```shell
% Name=something
% while test "$Name"
do
  read -p "What's your name? " Name
  if test "$Name"
  then
    echo "Hello there, $Name"
    sleep 1s
  else
    echo "There is no one else to greet"
  fi
done
```

The `sleep` commands is used to introduce a small delay of `1s`, which means sleep for 1 second. This is simulating the time it takes for the next person to show up.

Now you can type a bunch of names, each followed by `enter`, and you'll get the greetings, and if you type nothing, and simply hit the  `enter`, the script terminates.

As you can see, we need to set the `Name` variable before the `while` loop starts. This works, but is not very elegant!

An alternative is to remove the `test` in the `while` and move the `read` there. This is an extremely common construct, since the `read` command returns false when there is nothing to read. This also removes the need of initialising the `Name` variable:

```shell
while read -p "What's your name? " Name
do
  if test "$Name"
  then
    echo "Hello there, $Name"
    sleep 1s
  else
    echo "There is no one else to greet"
  fi
done
```

Try it, and you'll notice that there's a little annoying aspect of this format. If you press enter without any name, you get the message that there is no one else to greet. However the script doesn't finish. It starts asking for names again! This is because an empty string is considered a valid input for `read`, only an end-of-file (also known as __EOF__) will stop the loop.

You can enter an EOF with `control-d`. What can we do to avoid this annoying behaviour?

Well, all the loops in shell scripting allow for an unconditional "quick exit" with the command `break`. We can take advantage of that!

```shell
% while read -p "What's your name? " Name
  do
    if test "$Name"
    then
      echo "Hello there, $Name"
      sleep 1s
    else
      echo "There is no one else to greet"
      break
    fi
  done
```

Now it works as we expected, but let's try something else. Let's use a list of names rather than entering them at the prompt. Create a file with a list of names, let's call it `/tmp/names`. Type the names and end with EOF (or `control-d`)

```shell
cat > /tmp/names
Alice
Bob
```

Now add this file as input for the script:

```shell
while read -p "What's your name? " Name
do
  if test "$Name"
  then
    echo "Hello there, $Name"
    sleep 1s
  else
    echo "There is no one else to greet"
    break
  fi
done < /tmp/names
```

This is the most typical usage of `while read`, and when `read` reaches the end of the file, it will tell `while` to stop. It will stop before actually printing the "There is no one else to greet" line. To account for that, add an empty line at the end of the file, for example with:

```shell
% echo >> /tmp/names
```

The `>>` means "append". Now it should work as expected.

Now take a minute or two to look at this sample [while-do-done script](./samples/while-do-done.sh). Can you understand what it does by simply reading the code? Run it in your own shell to see if what you thought it did was correct.

We'll finish with one other common use of while-do-done. This is to run something indefinitely until it is interrupted, by a control-c for example. In such cases, the while test condition is simply replaced with a __while true__ statement. There is another sample script included - [while-forever-true](./samples/while-forever-true.sh) that shows this behaviour

## for-do-done ##

In some ways, `for` loops are similar to `while` loops, because they repeat commands until a certain condition is met. For standard `for` loops, this condition is just that the loop has iterated over the supplied list of "things".

There's a less frequently used `for` loop format, frequently called "c-style", which is a lot closer to the `while` loop, but we'll forcus on the main format here.

The "standard" `for` loop looks like this:

```shell
for new_variable in list_of_things
do
  commands
done
```

This loops through the `list_of_things`, and for each element, it assigns the element's value to `new_variable`, and runs the `commands`.

You can learn more about variables in [Lesson 6 - Variables and Expansion](./lessons/VarsAndExp.md). Here we will just focus on the `for` loop.

Let's say you want to do something similar to the previous `while` script, and you want to greet a bunch of friends, but you don't want to keep a file with their names, and you don't want to type their names all the time: this is perfect for a `for` loop:

```shell
% for Name in Alice Bob Charlie Eve
  do
    echo "Hello there, $Name"
    sleep 1s
  done
```

As you can see, it is much simpler than the `while` loop, because the script now has the list of names in advance. The difficult part in scripts like this is building up the list, which is not relevant for this section.

If you review the lesson about __expansion__, you'll see that there's something called __pathname expansion__, where you can work with files. This is a very common use for a `for` loop:

Go to the `/tmp/` directory and create some files, all with a name starting with `forloopfile`, followed by a number.

```shell
% cd /tmp
% touch forloopfile1
% touch forloopfile2
% touch forloopfile3
% touch forloopfile4
```

The `touch` command is a tool that changes the timestamp of a file, and if the file doesn't exist, it creates an empty file.

But this is a bit boring, can it not be automated a bit? The first idea would be to put the files in the loop:

```shell
% cd /tmp
% rm forloopfile*
% for fname in forloopfile1 forloopfile2 forloopfile3 forloopfile4
  do
    touch $fname
  done
```

But this is just as boring as the previous example, because we end up typing all the names anyway: can't it be made a bit easier? How about doing it this way:

```shell
% cd /tmp
% rm forloopfile*
% for a in 1 2 3 4
  do
    touch forloopfile$a
  done
```

What we are seeing here is a feature called expansion. We will come to a lesson about [expansion](./Expansion.md) very soon, but hopefully you can see that the variable `$a` is matching the numbers if the for loop and we are using that to create the unqie filenames.

And in fact, once we've covered expansion is nore detail, you will see that there is an even faster way to do this!

```shell
% cd /tmp
% touch forloopfile{1..4}
```

But since we're talking about __for__ loops, that would be considered cheating :-)

## case-esac ##

The __case__ statement is typically used where there might be many different actions to take depending on the condition that is arrived at. It takes the format of:

```shell
case <some-condition> in
    matches-condition-scenario-1) <some-action>
    ;;
    matches-condition-scenario-2) <some-action>
    ;;
    matches-condition-scenario-3) <some-action>
    ;;
esac
```

Of note is the fact that the __case__ condition has a trailing __in__ and the whole structure is closed by an __esac__ statement. Each condition test has a right-hand round brack `)` to seperate it from the `<some-action>` statements which follow. Each condition's actions are finished by a set of two `;;` commas to seperate it from the next condition.

Take a minute or two to look at this sample [case-esac script](./samples/case-esac.sh). Can you understand what it does by simply reading the code? Run it in your own shell to see if what you thought it did was correct.

## select-do-done ##

And now we come to our final conditional statement, the __select__ statement. This is a useful statement since it provides users with a menu of items to choose from, and these menu items are also enumerated to make selection easier. It also uses the environment variable `PS3` to provide a prompt to users to provide some information about the list of items in the menu. The __select__ statement takes the format:

```shell
select <some-variable> in <list of items to display>
do
    <some-actions>
done
```

What is also interesting is that this conditional statements continues to loop after the action is taken, prompting you to choose more items from the list. If you need to exit after a chose is make a __break;__ statement is needed after the `<some-action>` is taken.

Here is a very simple example of how the __select__ statement works.

```shell
% PS3="Pick a band: "
% select band in Metallica ACDC ABBA
  do
    echo "You picked $band"
  done
```

If you did not want to continuously loop after making a choice, you simply add the __break;__ statement after the __echo__ command.

```shell
% PS3="Pick a band: "
% select band in Metallica ACDC ABBA
  do
    echo "You picked $band"
    break;
  done
```

Lastly, you will often find __select__ statements used with __case__ statements to handle the many possible menu items a select statement might offer. Take a minute or two to look at this sample [select-do-done and case-esac script](./samples/select-do-done.sh). Once more, try to understand what it does by first reading the code. Then run it in your own shell to see if what you thought it did was correct.

That completes the conditional expressions lesson. [Click here to return to the lesson list](../README.md)
