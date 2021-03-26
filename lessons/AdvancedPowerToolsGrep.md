# Lesson 13 - Advanced Power Tools - grep #

In [Lesson 2 - Power Tools](./lessons/PowerTools.md) We had a look at some useful commands/tools that you can use as building blocks for your shell scripts. In this lesson we will look at some of these tools more in depth, and we will look at some additional tools that might be useful in some more complicated scripts.

## `grep` ##

### About Regular Expressions ###

The `grep` name originates from a command g/re/p, meaning scan for any line matching the re (regular expression), and p for print. So it should not be surprising if regular expressions are at the core (literally and figuratively) of `grep`.

The topic of regular expressions is quite large, and it is big enough to fill several books and courses, so it is a bit outside of the scope here, but there are a few concepts that might help avoid some head-aches when using `grep`.

If you are not familiar with regular expressions, it might be worth spending some time familiarising with them because they bring a lot of power, but don't be afraid of this section: we will cover just a few basics. Regular expression could be defined as a language to describe text matches, and this carries the unfortunate requirements to have some text to constitute the language (called special or meta symbols), and some text to constitute the content that needs to be matched. This means that some parts of the text will need to have both meanings, and this is confusing.

For example, in regular expressions, the dot (`.`) means any character, so it would match `a`, or `b`, or `.`, but what if one wants to match some text that contains a dot ? Obviously the meta `.` will match the text `.`, but as we've seen, it will match also `a` or `b`, but what if you want to match just a dot ?

That's why in regular expressions there's a way to assign or strip "special" or "meta" meanings from characters, and typically this is done by prepending a backslash (`\`) to the symbol.

Unfortunately different "dialects" and tools use different defaults for what is special and what is not.

In the case of the dot, almost every implementation of regular expression assigns the special meaning to it, and so, if you want to match a real dot, you need to use `\.`

Similarly, almost every regular expression implementation assigns special meaning by default to the star or asterisk (`*`), to mean "repeat 0 to n times", and if you really want to match a star, you need to escape it with `\*`, but its closest brother, the plus (`+`), which means "repeat 1 to n times" is by at times special, and at times not special by default.

In most implementations, the square brackets (`[` and `]`) are "special" by default, and need to be escaped if you want to match a literal square bracket. (In reality it's a bit more complicated than that, because the closed one might not be special if it is alone, but the idea is that it's a mess, so this helps to make the point)

`grep` in most implementations supports at least 2 "dialects" called "basic regular expression" (__BRE__) and "perl regular expressions" (__PRE__). Some versions of `grep` support even more "dialects", so you'll need to check the documentation of the version you are using to be sure.

The PRE version is documented extensively in perl documentation and website, and also in `pcresyntax(3)` and `pcrepattern(3)` man pages. The main thing to remember is that BRE tends to do the right thing for the average `grep` user: it tries to strip by default the special meaning from most characters, and it tries to give special meaning only to the most commonly used ones, such as dot and star. PRE, on the other hands, favours the regular expression expert, and tries to give by default as many characters their special meaning as possible, to avoid having to frequently use the backslash.

`grep` has been designed for searching text, for novices and experts, and therefore there's a way out of this apparent madness:

`grep` has a few options to allow you to specify which dialect you want to use:

- `--basic-regexp` (or `-G` for short) to force the use of a BRE (the default anyway)
- `--perl-regexp` (or `-P` for short) to force the use of PRE
- `--fixed-strings` (or `-F` for short) to force the use of no special characters or regular expressions at all. If in doubt, use this!

To make thins even more convenient, most systems have an alias for each of these commands, which are respectively:

- `grep`, which defaults to `--basic-regexp`
- `pgrep`, which defaults to `--perl-regexp`
- `fgrep`, which defaults to `--fixed-strings`

So, if you want to search for an IP address in some logs, use either:

- `grep "127\.0\.0\.1" /var/log/syslog`: notice the quoting plus the backslash, to prevent the shell from eating the backslashes
- `fgrep 127.0.0.2 /var/log/syslog`: much more compact and easy to use

If you want to read more about BREs, [click here for a good starting point](https://pubs.opengroup.org/onlinepubs/009696699/basedefs/xbd_chap09.html).

### Interesting Options ###

Due to its popularity, over the years, `grep` has received a lot of additional features and therefore additional command line options, so we won't look at each of them here, we will focus only on the most commonly used or the arbitrarily most interesting.

The first option from this list is `-v`, which can also be used in its long form as `--invert-match`, and what it does is reverse the behaviour, and print all the lines that do **NOT** match

```shell
grep root /etc/passwd
root:x:0:0:root:/root:/bin/bash
grep -v root /etc/passwd
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
sys:x:3:3:sys:/dev:/usr/sbin/nologin
sync:x:4:65534:sync:/bin:/bin/sync
games:x:5:60:games:/usr/games:/usr/sbin/nologin
man:x:6:12:man:/var/cache/man:/usr/sbin/nologin
lp:x:7:7:lp:/var/spool/lpd:/usr/sbin/nologin
mail:x:8:8:mail:/var/mail:/usr/sbin/nologin
news:x:9:9:news:/var/spool/news:/usr/sbin/nologin
uucp:x:10:10:uucp:/var/spool/uucp:/usr/sbin/nologin
proxy:x:13:13:proxy:/bin:/usr/sbin/nologin
www-data:x:33:33:www-data:/var/www:/usr/sbin/nologin
backup:x:34:34:backup:/var/backups:/usr/sbin/nologin
list:x:38:38:Mailing List Manager:/var/list:/usr/sbin/nologin
irc:x:39:39:ircd:/run/ircd:/usr/sbin/nologin
gnats:x:41:41:Gnats Bug-Reporting System (admin):/var/lib/gnats:/usr/sbin/nologin
nobody:x:65534:65534:nobody:/nonexistent:/usr/sbin/nologin
[…]
```

This is quite useful if you are looking for something, but you want to exclude some of its output:

What if we want to see all the lines containing "sy" in `/etc/passwd`

```shell
grep sy /etc/passwd
sys:x:3:3:sys:/dev:/usr/sbin/nologin
sync:x:4:65534:sync:/bin:/bin/sync
systemd-timesync:x:110:120:systemd Time Synchronization,,,:/run/systemd:/bin/false
systemd-network:x:111:121:systemd Network Management,,,:/run/systemd/netif:/bin/false
systemd-resolve:x:112:122:systemd Resolver,,,:/run/systemd/resolve:/bin/false
systemd-coredump:x:999:999:systemd Core Dumper:/:/usr/sbin/nologin
```

Suppose we do not want all these "systemd" users ?

```shell
grep sy /etc/passwd| grep -v systemd
sys:x:3:3:sys:/dev:/usr/sbin/nologin
sync:x:4:65534:sync:/bin:/bin/sync
```

If you use `grep` on more than one file, it will automatically enable the feature of prepending each output line with the name of the file that contains it plus a colon (`:`). This is to make sure it is clear which file produced which output, and when you only have 1 file, it is kind of obvious already.

Sometimes this behaviour is desirable also for when you are working on a single file, for example if you are using a `find -exec grep "{}" \;`, since `find` will run one `grep` for each file it finds, but overall, the user would probably want to know which file produced what output. In this case, the `-H` option does just what is needed.

Let's try this out!

```shell
find /var/log -name "*.log" -exec grep error "{}" \;
[2021-02-25T02:01:45.671Z] [ warning] [vmsvc] SimpleSock: failed to connect (1023 => 976), error 22: Invalid argument
[…]
```

This might not do much if you've had no errors in any of the log files, so in such a case, be creative and look for any other pattern rather than error.

Assuming it worked, or that you've found a better pattern, let's try the same, but with `-H`:

```shell
find /var/log -name "*.log" -exec grep -H error "{}" \;
/var/log/vmware-vmsvc-root.3.log:[2021-02-25T02:01:45.671Z] [ warning] [vmsvc] SimpleSock: failed to connect (1023 => 976), error 22: Invalid argument
[…]
```

Almost every time you run `grep` with `find`, you'll use `-H` or `-l` (see the advanced power tool lesson on [find](../lessons/AdvancedPowerToolsFind.md)). But in typical `grep` style, each option has its opposite in the opposite case, so if you specify `-h`, you suppress printing the file name, even when you have multiple files:

```shell
grep error /var/log/*.log
/var/log/vmware-vmsvc-root.3.log:[2021-02-25T02:01:45.671Z] [ warning] [vmsvc] SimpleSock: failed to connect (1023 => 976), error 22: Invalid argument
[…]
```

Compare that with this:

```shell
grep -h error /var/log/*.log
[2021-02-25T02:01:45.671Z] [ warning] [vmsvc] SimpleSock: failed to connect (1023 => 976), error 22: Invalid argument
[…]
```

Some times all you want to know is which file contains the text you are looking for, and you do not need to see the line(s) that match. This is particularly true when you have a lot of files, or large files, and it takes a lot of time to scan them all, so you want to first quickly figure out which file to focus on, and once selected a file, you can then use `grep` the standard way and see the lines that match.

The `-l` option was designed for this: it causes `grep` to bail out of scanning a file as soon as the 1st pattern is found, and print the name of the file. This has a potentially big performance improvement, since you otherwise would need to scan the whole file before moving to the next. It also means producing a list of files that you can then machine-read if necessary, without having to process the lines with the `:` between the name of the file and the rest of the text which you do not want.

```shell
grep -l /var/log/*.log
/var/log/daemon.log
/var/log/vmware-vmsvc.1.log
/var/log/vmware-vmsvc.2.log
/var/log/vmware-vmsvc.3.log
/var/log/vmware-vmsvc.log
/var/log/vmware-vmsvc-root.1.log
/var/log/vmware-vmsvc-root.2.log
/var/log/vmware-vmsvc-root.3.log
/var/log/vmware-vmsvc-root.log
```

The `-l` is also frequently used with `find`:

```shell
find /var/log/ -name "*.log" -exec grep -l error "{}" \;
/var/log/apt/term.log
/var/log/vmware-vmsvc-root.3.log
/var/log/daemon.log
/var/log/vmware-vmsvc-root.2.log
/var/log/vmware-vmsvc-root.log
/var/log/vmware-vmsvc.log
/var/log/vmware-vmsvc.1.log
/var/log/vmware-vmsvc-root.1.log
/var/log/vmware-vmsvc.3.log
/var/log/vmware-vmsvc.2.log
```

The opposite of `-l` is, as you might have guessed, `-L`, and what it does is print the name of all the files that do not match the pattern.

Many times you might want to know how many lines in a file match a certain pattern, and you might be tempted to use `wc`:

```shell
grep error /var/log/vmware-vmsvc-root.2.log | wc -l
1188
```

But there's a more efficient way to do this: `grep` + `-c`:

```shell
grep -c error /var/log/vmware-vmsvc-root.2.log
/var/log/vmware-vmsvc-root.2.log:1188
```

You can use the `-h` option to make it more like `wc` :

```shell
grep -hc error /var/log/vmware-vmsvc-root.2.log
1188
```

But besides the performance issues, which might be negligible in modern hardware, there's another advantage: this works on multiple files:

```shell
 grep -c error /var/log/*.log
/var/log/vmware-network.1.log:0
/var/log/vmware-network.log:0
/var/log/vmware-vmsvc.1.log:1
/var/log/vmware-vmsvc.2.log:1
/var/log/vmware-vmsvc.3.log:7
/var/log/vmware-vmsvc.log:1
/var/log/vmware-vmsvc-root.1.log:6
/var/log/vmware-vmsvc-root.2.log:1188
/var/log/vmware-vmsvc-root.3.log:8887
/var/log/vmware-vmsvc-root.log:1710
/var/log/vmware-vmtoolsd-root.log:0
[…]
```

This is a pretty handy way to decide what log to analyse first.

At times `grep` is used to **extract** information from files, rather than to see what lines or files match a certain pattern, and `grep` has the `-o` option for this use case: it will print only the text matching the pattern.

```shell
grep -o error /var/log/syslog
error
error
error
error
error
error
```

As demonstrated here, it is only useful if the pattern is a regular expression, because otherwise it will just print the same text that was provided as pattern. For example, if we look for `error` followed by a space, and then multiple non-space characters, we might be able to see what type of error we're dealing with:

```shell
grep -o "error [^ ]\+" /var/log/syslog
error running
error parsing
error running
error parsing
error running
error parsing
```

Depending on the content of your log files, this might not be very useful for you. You'll need to know a bit more about regular expressions to take advantage of this, but let's try an example that is likely to work in any machine:

```shell
grep -o '^[^:]\+' /etc/passwd
root
daemon
bin
sys
sync
games
man
lp
mail
news
uucp
proxy
www-data
backup
list
irc
gnats
nobody
```

What this does is look for the first non colon characters of each line, which, in `/etc/passwd` represent the username. It is true that this is a bit of an abuse of `grep`, because `cut -d: -f1` does the same, but if the regular expression is a bit more complicated, this is more powerful: think for example of the case where you have a regular expression matching an IP address, that can be anywhere in the line.

The `-o` option is powerful, but it is eclipsed in power by the stream editor `sed` (see the lesson on [sed and awk](../lessons/AdvancedPowerToolsSedAwk.md) later) for the same purpose. If you want to invest in learning regular expressions, use that skill for `sed` rather than `grep` in this type of use-case.

That completes the Advanced Power Tool lesson on `grep`. [Click here to return to the lesson list](../README.md)
