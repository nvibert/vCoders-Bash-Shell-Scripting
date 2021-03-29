# Lesson 14 - Advanced Power Tools - sed & awk #

In [Lesson 2 - Power Tools](./lessons/PowerTools.md) We had a look at some useful commands/tools that you can use as building blocks for your shell scripts. In this lesson we will look at some of these tools more in depth, and we will look at some additional tools that might be useful in some more complicated scripts.

## `sed` ##

`sed` stands for steam editor, and it is quite useful to make scripted edits to files in a non-interactive way. This include processing log files, especially when trying to extract information, similarly to what we did previously with `grep -o`.

`sed` is a very popular tool, and it has a very large set of features, which would be out of scope here, so we will just focus on a very small subset of features.

Because it is a "stream editor", `sed` performs operations it receives as input in the form of commands, which it then applies to the input files (or standard input).

The most commonly used commands for `sed` are:

- `d` for delete
- `p` for print
- `s` for substitute

Each command can also have an optional parameter before it, that selects the range of lines where the command needs to operate.

This range can be specified as line numbers, such as `1` to mean the first line, `$` to mean the last, and `500` to mean the 500th, and it can be just one, to mean just that line, or a range, with a beginning, a comma, and an end, such as `1,500` to mean the first 500 lines, or `500,$` to mean from the 500th to the end.
The range can also be dynamic, rather than based on the line number, based on pattern matching, such as `/config/`, to match all the lines that contain the word "config", and these dynamic selections can be mixed with line numbers too, such as `/config/,$` to mean from the first line that contains "config" till the end of the file, or `/config/,/end/`, to match every range in the file that is between lines that contain "config" and "end".

So, as we've already seen previously in a couple of lessons, you can do `sed 1d` to delete the first line of a file, and you can do the same as `grep -v pattern` if you run `sed /pattern/d`.

Let's try a new file:

```shell
for a in {1..10}
do
  echo "Line number $a"
done > /tmp/testfile1
```

And try the above commands:

```shell
sed 1d /tmp/testfile1
```

And we get the content without the 1st line:

```shell
Line number 2
[…]
Line number 10
```

Now let's try `grep -v`:

```shell
grep -v 6 /tmp/testfile1
```

And we see that line 6 is missing as expected:

```shell
[…]
Line number 4
Line number 5
Line number 7
[…]
```

You will get the same result with:

```shell
sed 6d /tmp/testfile1
```

Compare that with `sed /6/d`, which is providing a range for all lines that contain a _6_:

```shell
sed /6/d /tmp/testfile1
```

Just the same output:

```shell
[…]
Line number 4
Line number 5
Line number 7
[…]
```

So, what about `grep` without `-v` you might say? Sure! `sed` has an implicit `p` command, meaning that it will print all the lines, after applying the modifications or even when no change was made, but this default `p` can be removed with the `-n` option: in such a case, only explicit `p` will print something.

So, here is the baseline behaviour from `grep`:

```shell
grep 6 /tmp/testfile1
```

Which, as expected, returns only the 6th line:

```shell
Line number 6
```

So, taking advantage of the `-n` option, we can do:

```shell
sed -n /6/p /tmp/testfile1
```

And we can confirm that we get the same behaviour. If you try `sed -n 6p`, you'll still get the same output, but for a different reason.

```shell
Line number 6
```

`sed` being an editor, it needs to be able to also modify files, not just print out the modified content of a file. This is achieved with the `-i` option, which will basically hide the process from the user, and output to a temporary file, delete the source file, and rename the temporary file to take the place of the source file.

We've seen an example of `sed -i` above in the `comm` exercise, so we don't need to look at another one.

The biggest topic for `sed` is the `s` command: its structure is like this: `[range]s/match pattern/replacement instructions/flags`.

We've already covered the range part; the match pattern is **almost** BRE, with the addition that groups (identified by special parenthesis, or `\(` and `\)`) become now "capturing groups".

The replacement part contains the text that should be used to replace the text that matches the match pattern, and the flags add some extra functionalities to the `s` command; the most common flags you can find are `g` to mean global (i.e. repeat the replacement on each line, instead of replacing only the first match), and `p`, which means "print the modified line".

A group, in regular expressions, is a way to allow for treating a bunch of symbols as one, for example to
repeat them, or to restrict the field of effect for alternatives with the special pipe symbol (`\|`)

A group is called "capturing" when the context allows for the part of the content that matches the group to be referenced elsewhere, either in the match, or in the replacement. In `sed`, referring to the content captured by a group is called back-reference, and is identified by a number preceded by a backspace (e.g. `\1`), where the number identified the group in the match. `sed` does not allow back-references to more than 9 groups.

`sed` has another way to refer to content that matches the whole pattern, which is identified by `&`, but this works only in the replacement part, while the group back-references can be used also in the match part.

This might sound quite confusing, but the power of this construct is very important, so it deserves a bit of extra effort. Maybe a few examples will clarify. To prepare for this, rather than creating a bunch of files each time, we might just as well use a word-list file such as scowl, so let's download it and prepare it!

You can use `curl` or `wget` to download the file, depending on which one you have and/or prefer, so chose one of these 2 options:

```shell
cd /tmp
wget http://downloads.sourceforge.net/wordlist/scowl-2020.12.07.tar.gz
```

or

```shell
cd /tmp
curl --remote-name http://downloads.sourceforge.net/wordlist/scowl-2020.12.07.tar.gz
```

Either way, now you have a `/tmp/scowl-2020.12.07.tar.gz` file to work with, let's "un-tar" it, and get the files we need ready to be used:

```shell
cd /tmp
tar xzf scowl-2020.12.07.tar.gz
```

The "scowl" archive contains a lot of dictionaries and word-files, we will use the English one, but it needs some assembly. We could use the supplied `Makefile`, but we are now experts with scripts, so we can do this ourselves!

```shell
cd /tmp/scowl-2020.12.07
cat final/english-words.??  | sort > /tmp/english-words
cd /tmp/
wc -l english-words
490253 english-words
```

Now, we have a file with almost half a million words.

The first thing we can try to find out is if there are any 3 letter words that are palindrome? (i.e. they can be read in either direction). This is a job that `grep` can do easily, but only with a back-reference, which is what we want to demonstrate here

First, how do we get all the 3 letter words?

```shell
grep "^...$" /tmp/english-words
[…]
```

If you are new to regular expressions, let's stop for a second to look at what we've written here:

- the caret, or, as friends of regular expressions call it, the "hat" (`^`) is an anchor, and it anchors the following text to be forcefully at the beginning of the line
- the dot (`.`), as we know, matches any single character. Here we have 3, because we want to match any line that has 3 characters in it, no more, and no less
- the dollar (`$`), which is the opposite of the "hat", is another anchor, and it anchors the preceding text to be at the end of a line

If you knew all the above already, congratulations, you might then also know that you can replace the 3 dots with the special curly braces (`\{` and `\}`), and the exact number of repetitions.

```shell
grep -c "^.\{3\}$" /tmp/english-words
[…]
```

Arguably, some of these are not really words, but we want to find out palindromes, so let's move on. Let's introduce a capturing group with special parenthesis, and let's also add a back-reference to this group. This command is essentially a `grep` for any line with 3 characters where the first character can be any character represented by `.`, the second character can again be any character represented by `.`, but the third character must match the first character, so we use the first back reference `\1`. The back reference refers to what is inside the parenthesis, `\(` and `\)`, in this example, the first character.

```shell
grep "^\(.\).\1$" /tmp/english-words
aaa
aba
aga
aha
aia
ala
ama
[…]
```

Without the back-reference, this sort of test wouldn't be possible. The capturing group can be anything, not just a dot. For example, we can look for any word that contain two times the same string, taken from a list of strings such as one, can, do.

```shell
grep "\(one\|can\|do\).*\1$" /tmp/english-words
cancan
clogdogdo
dodo
dorado
eldorado
honestone
honeystone
protoneurone
```

Now, we've been using `grep` all the time here, why did we say that `sed` is more powerful? Let's try an example where we can compare `grep -o` and `sed -n` to extract information from a log file. First, we need to identify our baseline. Let's check the `/var/log/syslog` file in your machine. It should contain a bunch of lines with "systemd" in it:

```shell
grep systemd /var/log/syslog
[…]
Mar 11 09:33:30 testrig systemd[8026]: Reached target Sockets.
Mar 11 09:33:30 testrig systemd[8026]: Reached target Basic System.
Mar 11 09:33:30 testrig systemd[1]: Started User Manager for UID 0.
Mar 11 09:33:30 testrig systemd[8026]: Reached target Main User Target.
Mar 11 09:33:30 testrig systemd[8026]: Startup finished in 451ms.
Mar 11 09:33:30 testrig systemd[1]: Started Session 1627 of user root.
```

Now, imagine that you are troubleshooting an issue where it is important to check how many times each different _process id_ inside systemd produced such an error message. With `grep -o`, you'd do something like this (remembering that the square brackets are special by default in most cases):

```shell
grep -o 'systemd\[[0-9]\+\]' /var/log/syslog
[…]
systemd[8026]
systemd[8026]
systemd[1]
systemd[8026]
systemd[8026]
systemd[1]
```

As you can see, the limitation of `grep -o` is that it can't distinguish between anchors and values. `sed` can overcome such limitation:

```shell
sed -n  's/^.\+systemd\[\([0-9]\+\)\].*$/\1/p' /var/log/syslog
[…]
8026
8026
1
8026
8026
1
```

Let's unpack this command:

- First of all, you can see that the "systemd" part was being used as an anchor: we wanted to get the text immediately after it, but we didn't want "systemd" in the output!
- Second, we are using `sed` with the `s` command, because we want to substitute the whole line with just the bit that we want to capture.
- Third, the match pattern is quite similar to the one used by `grep -o`, we just added two more anchors: the "hat" and the "dollar", and between the 3 anchors, we've added the most flexible match: dot-star (`.*`). Dot-star means basically "anything, any number of times", and is useful to allow fitting any sort of text between fixed anchors.
- Fourth, once we anchored our match to the 2 square brackets (using the backslash `\` to strip them from their special meaning), we are sure to match the numbers inside it. We do this with a range, `[0-9]`, and we repeat that range 1 or more times with the `\+`.
- Fifth, we used a capturing group (`\(` and `\)`) around the text we wanted to extract, which is the number (`[0-9]\+`)
- Sixth, in the replacement part of `s`, we used a back-reference referring to the first group, or `\1`. Since we matched the whole line, using the "hat" and dollar anchor, we would be replacing the whole line, and we'll be left with only the information we wanted.
- Seventh, we are running `sed` with `-n`, so nothing will be printed, and therefore we add `p` as a flag of `s`, to force the printing of the replaced lines, so that any line that doesn't match won't be printed.

It's best to use single quotes here to make sure we do not get any interference at all from the shell, since the double quoting is a bit more permissive (although the naming seems to imply the opposite)

Keep in mind that you can use up to 9 capturing groups, so you can extract many parts of the log line, depending on what you want to do.

## `awk` ##

Just like `sed`, or even more than `sed`, `awk` is a very powerful tool that deserves a full dedicated training, due to its vast amount of features. Both are turing complete!

`awk` can be considered a programming language on its own, especially considering that perl is kind of a superset of `awk`, so we will just briefly mention that it exists and demonstrate what it can do, with the intention of enabling the reader to decide whether investing the time for learning `awk` is appropriate or not.

`awk` at its core is a pattern based text processing language, but since it is a programming language, it can do just about anything. Let's just try some examples. First, we need to create a few files in a new directory:

```shell
mkdir /tmp/awkExperiments
touch /tmp/awkExperiments/file{1..10}
```

Then let's try `ls -l` from the new directory

```shell
cd /tmp/awkExperiments
ls -l
total 0
-rw-r--r-- 1 root root 0 Mar 11 13:41 file1
-rw-r--r-- 1 root root 0 Mar 11 13:41 file10
-rw-r--r-- 1 root root 0 Mar 11 13:41 file2
-rw-r--r-- 1 root root 0 Mar 11 13:41 file3
-rw-r--r-- 1 root root 0 Mar 11 13:41 file4
-rw-r--r-- 1 root root 0 Mar 11 13:41 file5
-rw-r--r-- 1 root root 0 Mar 11 13:41 file6
-rw-r--r-- 1 root root 0 Mar 11 13:41 file7
-rw-r--r-- 1 root root 0 Mar 11 13:41 file8
-rw-r--r-- 1 root root 0 Mar 11 13:41 file9
```

And now, let's say we want to print just the name from that output:

```shell
ls -l | awk '{print $9}'

file1
file10
file2
file3
file4
file5
file6
file7
file8
file9
```

As you can see, `awk` has split automatically each line in words, and the 9th is the name. But the first line, the one that displays _"total"_ breaks everything, since there are only 2 field in that line, not 9! We could use `sed 1d`, but we've just said that `awk` can do about anything, can it not deal with that? You need to remember that `awk` was designed as a pattern based text processing, and this is a problem that can be easily be fixed by pattern matching, and there are a few hundreds way to do it! For example, we can use a match against all the lines that start with a dash, using a regular expression:

```shell
ls -l | awk '/^-/ {print $9}'
file1
file10
file2
file3
file4
file5
file6
file7
file8
file9
```

Or, we can look for all the lines that start with "total" (which again does not return anything in the 9th field):

```shell
ls -l | awk '/^total/ {print $9}'

```

And then reverse the match with a bang (`!`) (kind of what `grep -v` would do)

```shell
ls -l | awk '!/^total/ {print $9}'
file1
file10
file2
file3
file4
file5
file6
file7
file8
file9
```

Or, we can use the value of the first column, $1, after the line was split and seeing if it called _"total"_. Again, nothing is returned since it does not have 9 fields of information!

```shell
ls -l | awk '$1=="total" {print $9}'

```

So if reverse the match in the last command to report when the first column is not _"total"_:

```shell
ls -l | awk '$1!="total" {print $9}'
file1
file10
file2
file3
file4
file5
file6
file7
file8
file9
```

This is because the format of an awk program is the following:

`MATCH {commands}`

MATCH can be a regular expression, as we've seen, or a logical expression, such as $1=="total"
there are a few special matches, such as BEGIN, and END. This is useful to perform a bunch of other things, such as sum up all the numbers from a file:

```shell
seq 1 10 | awk 'BEGIN {tot=0} /^[0-9]+$/{tot+=$1} END {printf "total=%1$d\n", tot}'
total=55
```

As we know from previous examples, the sum of the first 10 numbers is 55, but the important observation to make here is how this works:

- the `BEGIN` pattern matches before the input is parsed, and what it does is it resets the counter to 0
- the `/^[0-9]+$/` pattern matches any line which is just a number, which wouldn't be strictly necessary in this case since we're using `seq`, but it's a good precaution to deal with any other sort of input file
- the END pattern matches after all the input is processed, and it just prints out the total

The set of `awk` commands can be placed in a file, and if the first line is a shebang pointing to `awk -f`, the script will work just like a shell script would. Create a new file called `/tmp/total` with the following content:

```shell
#!/usr/bin/env -S awk -f
BEGIN {tot=0}
/^[0-9]+$/ {tot+=$1}
END {printf "total=%1$d\n", tot}
```

This shebang with `env` is just a way to make sure you do not hard-code the path to awk, but if you have `/usr/bin/awk -f` it does just the same, if `awk` is in `/usr/bin/awk`.

Make it executable with `chmod a+x /tmp/total`, and try it again:

```shell
seq 1 10 | /tmp/total
total=55
```

`awk` can work with multiple columns, in a similar fashion to what we've learnt to do with `while read` in shell:

```shell
cd /etc
ls -l | awk 'BEGIN {tot=0} !/^total/{tot+=$5} {print} END {printf "total=%1$d\n", tot}'
```

Now you've added a total size to your `ls -l` command! (the additional `{print}` command just prints the output of `ls`).

That completes the Advanced Power Tools lesson on `sed` and `awk`. [Click here to return to the lesson list](../README.md)
