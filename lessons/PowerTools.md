# Lesson 2 - Power Tools #

Shell scripting is mostly combining multiple commands and tools that are already available in your environment. In this section, we are going to look at some of the most useful commands and tools. In this lesson we will be only looking at the basic usage of these comands. There are some more advanced lessons later in the tutorial where we revisit these commands and go into much greater detail.

## find ##

The __find__ command is very powerful, and can be used for searching for files and directories based on many different criteria, including permissions, owner, date and size. For the purposes of this example, we will focus on looking for files based on name, but there are many, many more which we will come across during the course of this tutorial.

The __find__ command format is generally:

```shell
% find <starting point> -name <thing-to-search-for>
```

Try the following example, where we create an empty file using the __touch__ command and then search for it using __find__, starting from the current directory ".":

```shell
% touch myFile.txt
% find . -name myFile.txt
./myFile.txt
```

The command shows that the file is in this directory, represented by the "." period in front of the filename. You can also search for files, whilst ignoring the case of the filename using the `-iname` option:

```shell
% find . -iname myfile.txt
./myFile.txt
```

There are many more options to find, but for the purposes of our tutorial, these simple examples will suffice for the moment.

## grep ##

Whilst __find__ searches for files and directories, we can use __grep__ to search for patterns within a file or files.

The __grep__ command format is generally:

```shell
% grep <some pattern> <some file or list of files>
```

Try the following example, where we use our previous file, `myFile.txt`. We will use the __echo__ command to display some text, and use the __>__ character to redirect the text into a file (this redirection of standard out was explained back in [lesson 1](../lessons/YourShell.md)). We then search the file using __grep__ to see if we can get a pattern match.

```shell
% echo "Hello World" > myFile.txt
% grep "Hello" myFile.txt
Hello World
```

We can also use the `-i` option to ignore case when searching for patterns:

```shell
% grep "hello" myFile.txt

% grep -i "hello" myFile.txt
Hello World
```

Another popular option is to use the `-v` option to search for all lines which _do not_ match a pattern.

```shell
% grep -v "Hello" myFile.txt

% grep -v "Goodbye" myFile.txt
Hello World
```

## wc - word count ##

Word count, __wc__, is very useful for getting statistics about files (or indeed any input). It can be used to provide a count of lines, words or even characters. Let's continue to work with `myFile.txt` and get some information about its contents using __wc__.

Let's do a `line` count to begin - there is only one line:

```shell
% wc -l myFile.txt 
1 myFile.txt
```

Let's do a `word` count next - there should be 2 words, _Hello_ and _World_:

```shell
% wc -w myFile.txt 
2 myFile.txt
```

Finally, let's do a `character` count:

```shell
% wc -m myFile.txt 
12 myFile.txt
```

Now you may wonder why there are 12 characters reported. This is because __wc__ also reports white spaces and newline as characters in a file. There are, of course, ways to remove all the white spaces from a file, but those are more advanced topics that will be covered later. It is suffice to take away from this exercise that there ability to count up patterns can be very useful when searching log files, for example, to give an idea how often a particular event occurred.

## head ##

Look at the beginning, or __head__, of a file. By default, it displays the first 10 lines. You can change the number of lines displayed by using the __-n__ option, e.g. _head -n 5 "some-file"_. Here is an example take from my MacOS:

```shell
% head -n 1 /var/log/system.log 
Mar 10 00:00:30 chogan-a01 com.apple.xpc.launchd[1] (com.apple.xpc.launchd.domain.pid.fdesetup.76385): Failed to bootstrap path: path = /usr/bin/fdesetup, error = 2: No such file or directory
```

## tail ##

Similar to __head__, the __tail__ commands displays the end, or tail of a file. Again, by default, the number of lines displayed is 10. This can also be changed by using the __-n__ option to specify how many lines to display, e.g. _tail -n 5 "some-file"_. One of the most useful attributes of the tail command is the __-f__  (follow) option which can be used to continuously monitor the output of a file. This is especially use when you want to see new entries added to a file, especially log files.

## cut ##

The __cut__ command is a parser that allow you to cut or display certain fields or columns. Let's look at a very simple example using _myFile.txt_ created earlier.

```shell
% cat myFile.txt 
Hello World
```

The words in this file are seperated by a space, so we will need to specify this as the delimiter to the __cut__ command, using the __-d__ option. by default, __cut__ uses tabs as the delimiter. The field to cut / display is specified in the __-f__ option.

```shell
% cat myFile.txt | cut -d ' ' -f1
Hello
% cat myFile.txt | cut -d ' ' -f2
World
```

## sed ##

Next we will look at the stream editor, __sed__. This tool is very good for text manipulation, such as deleting a line or lines from a stream of input, or indeed substituting some patterns in the data with other patterns.

For example, we might want to do some work on filesystems and mountpoints (we will in fact be doing so in a later exercise). Here is the __df__ (display filesystem) output from my MacOS:

```shell
% df
Filesystem    512-blocks      Used Available Capacity iused      ifree %iused  Mounted on
/dev/disk1s5   489620264  22308472  45115800    34%  488435 2447612885    0%   /
devfs                380       380         0   100%     658          0  100%   /dev
/dev/disk1s1   489620264 418626528  45115800    91% 2221040 2445880280    0%   /System/Volumes/Data
/dev/disk1s4   489620264   2097528  45115800     5%       1 2448101319    0%   /private/var/vm
map auto_home          0         0         0   100%       0          0  100%   /System/Volumes/Data/home
/dev/disk1s3   489620264   1033168  45115800     3%      54 2448101266    0%   /Volumes/Recovery
```

Note that the first line of the output simply contains column or header descriptions. We can use the stream editor `sed`, with the command `1d` which means **d**elete line number **1**, to get rid of the first line.

```shell
$ df | sed 1d
/dev/disk1s5   489620264  22308472  45115808    34%  488435 2447612885    0%   /
devfs                380       380         0   100%     658          0  100%   /dev
/dev/disk1s1   489620264 418626520  45115808    91% 2221054 2445880266    0%   /System/Volumes/Data
/dev/disk1s4   489620264   2097528  45115808     5%       1 2448101319    0%   /private/var/vm
map auto_home          0         0         0   100%       0          0  100%   /System/Volumes/Data/home
/dev/disk1s3   489620264   1033168  45115808     3%      54 2448101266    0%   /Volumes/Recovery
```

This tool can also be used to do pattern matching and substitution. Let's take the previous example, and do something fun. Let's change all occurences of "%" to "tomato". We would do that using the substitute command `s/%/tomato/` as follows:

```shell
% df | sed 1d | sed s/%/tomato/
/dev/disk1s5   489620264  22308472  44881856    34tomato  488435 2447612885    0%   /
devfs                380       380         0   100tomato     658          0  100%   /dev
/dev/disk1s1   489620264 418860472  44881856    91tomato 2221129 2445880191    0%   /System/Volumes/Data
/dev/disk1s4   489620264   2097528  44881856     5tomato       1 2448101319    0%   /private/var/vm
map auto_home          0         0         0   100tomato       0          0  100%   /System/Volumes/Data/home
/dev/disk1s3   489620264   1033168  44881856     3tomato      54 2448101266    0%   /Volumes/Recovery
```

OK - this appears to have worked, as the fifth colume which previosuly held _%_ signs now contains _tomato_. But if you look closely you will see that this has only changed the first occurrence of the % sign in each line to tomato. There is another % sign in the eight column that has not been modified. This is correct & expected behavior. If we want sed to change every occurrence, we would need to post-fix the __sed__ substitute command with `g`, short for global. Let's try that now:

```shell
df | sed 1d | sed s/%/tomato/g
/dev/disk1s5   489620264  22308472  44889096    34tomato  488435 2447612885    0tomato   /
devfs                380       380         0   100tomato     658          0  100tomato   /dev
/dev/disk1s1   489620264 418853232  44889096    91tomato 2220923 2445880397    0tomato   /System/Volumes/Data
/dev/disk1s4   489620264   2097528  44889096     5tomato       1 2448101319    0tomato   /private/var/vm
map auto_home          0         0         0   100tomato       0          0  100tomato   /System/Volumes/Data/home
/dev/disk1s3   489620264   1033168  44889096     3tomato      54 2448101266    0tomato   /Volumes/Recovery
```

And now all occurences of % have been changed to tomato, not just the first occurence. Note that this is displaying the result to standard out. You would need to use the __>__ (redirect) character to redirect the output to a new file, e.g.

```shell
df | sed 1d | sed s/%/tomato/g > /tmp/tomato_df
```

## sort and uniq ##

Let's take these commands together and they are commonly used together when shell scripting. As you can imagine, __sort__ is used for sorting input, either from stdin (standard input) or file contents. Let's create a file which contains a number of names to begin with. This script will continue to add names to the file `/tmp/names` until it meets the entry EOF (short for End Of File). This is a common mechanism for creating files.

```shell
% cat > /tmp/names <<EOF
John
Alice
Philip
Bob
Karen
John
EOF

% cat /tmp/names 
John
Alice
Philip
Bob
Karen
John
```

This create a file called `/tmp/names` containing the list of names above. We can use the __sort__ command to arrange it in a number of ways. By default, __sort__ works alphabetically. If I simply run __sort__ against the file, the entries are reorganized alphabetically.

```shell
% sort /tmp/names
Alice
Bob
John
John
Karen
Philip
```

If I wanted to sort in reverse alphatetic order, I can use the `-r` option.

```shell
% sort -r /tmp/names
Philip
Karen
John
John
Bob
Alice
```

Now, as we can clearly see there are 2 entries for _John_ in the list. We can remove duplicate entries in a sorted list as well. We simply provide a __-u__ (unqiue) option to the sort command.

```shell
% sort -u /tmp/names
Alice
Bob
John
Karen
Philip
```

There is also a way of filtering out duplicates using another command, __uniq__. However __uniq__ only filters out duplicate lines/entries which are adjacent to one another. Thus, the previous command could be rewritten using the pipe (|) symbol as follows:

```shell
% sort /tmp/names | uniq
Alice
Bob
John
Karen
Philip
```

The __uniq__ command has some useful options, such as the ability to print a count of the number of times a particular pattern was found:

```shell
% sort /tmp/names | uniq -c
   1 Alice
   1 Bob
   2 John
   1 Karen
   1 Philip
```

And it can also be used to just print out the duplicate patterns found:

```shell
% sort /tmp/names | uniq -d
John
```

## paste ##

The __paste__ command is very useful for taking listings of input, e.g. file contents, and turning them into a single concantenate line. It is probably easier to understand this from our previous example which contains a list of names. Let's take that list of names, and display then on a single line. By default, __paste__ uses the tab character to seperate items:

```shell
% paste -s /tmp/names
John    Alice   Philip  Bob     Karen   John
```

We could also replace the default tab character seperator with a different seperator using the `-d` option. In this examples, let us the colon (:) symbol.

```shell
% paste -s -d: /tmp/names
John:Alice:Philip:Bob:Karen:John
```

## xargs ##

The final tool that we are going to look at is __xargs__. This tool is extremely useful as it allows the information piped into its standard input to be passed on as argument to another command. You will find this commonly used with the __find__ and __grep__ commands discussed earlier. __xargs__ allows the filenames discovered by the __find__ to be passed as arguments to the __grep__ command, so that __grep__ can then search the file contents. Let's see this use case in action.

Let's say I want to count up the number of files in `/tmp` that contain the word error.

```shell
% cd /tmp
% find . -print | grep -i error 2>/dev/null | wc -l
       0
```

So the reason this did not work is because __grep__ is looking for the keyword _error_ in the names of the files returned by the __find__ command, not in the contents of the files that were returned. We can use __xargs__ to change this behaviour. Note the _2>/dev/null_ included after the __grep__ is simply to stop any errors from the grep command getting displayed on the output. We previously saw _2>/dev/null_ in [lesson 1](../lessons/yourShell.md) when discussing standard error.

```shell
% find . -print | xargs grep -i error 2>/dev/null | wc -l
       4
```

Now, instead of searching the filenames for the keywork _error_, the command is searching the contents of each of the files returned by the __find__ command for the keywork _error_. We will be spending more time on these simple and compound commands in later lessons.

That completes the tools lesson. [Click here to return to the lesson list](../README.md)
