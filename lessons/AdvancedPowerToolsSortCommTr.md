# Lesson 15 - Advanced Power Tools - sort, comm and tr #

In [Lesson 2 - Power Tools](./lessons/PowerTools.md) We had a look at some useful commands/tools that you can use as building blocks for your shell scripts. In this lesson we will look at some of these tools more in depth, and we will look at some additional tools that might be useful in some more complicated scripts.

## `sort` ##

We've seen that `sort` takes input, either as a file, or as standard-in, and returns in output the same, but sorted alphabetically.

Typically this is used to feed the data to other tool that require the input to be sorted, such as `comm` or `uniq` (comm will be covered next), but sort can be used also on its own.

Many times `sort` is used to sort files, which is not a very good idea, because `ls` does that more efficiently, and offers options to sort by time, size, and name (the default), among other options, so try to avoid doing `ls | sort`.

There are other tools, on the other hand, that do not offer sorting options, such as `du`.

If you run `du -sh *` inside `/var`, you get an idea of where has all your disk space gone, but the answer is difficult to find at a glance, because the data is not sorted: which directory uses the most disk space ? The `-h` option is nice, because it makes the output "human readable", and the `-s` option gives us a summary per directory, rather than the details of the contents.

```shell
cd /var
du -sh *
15M     backups
1.7G    cache
127M    lib
63M     log
560M    mail
116K    spool
4.0K    tmp
38M     www
```

Your results might vary, but you can clearly see that the results are not sorted, and sorting the output of `-h` might seem challenging for a shell script, because we have many multipliers such as G, M, K.

Well, `sort` also has a `-h` option, and the name is not a coincidence: it means "sort human readable values".

```shell
cd /var
du -sh * | sort -h
4.0K    tmp
116K    spool
15M     backups
38M     www
63M     log
127M    lib
560M    mail
1.7G    cache
```

Woe, we've got a lot of unread mail there!

Sort has the "reverse" option `-r` too:

```shell
cd /var
du -sh * | sort -rh
1.7G    cache
560M    mail
127M    lib
63M     log
38M     www
15M     backups
116K    spool
4.0K    tmp
```

But you can also sort non human readable but numeric values, with `-n`:

```shell
du -sk *| grep -v ^0| sort -rn
1778604 cache
573348  mail
129908  lib
64088   log
38092   www
15044   backups
116     spool
4       tmp
```

What happens if we sort with the default options? (i.e. in text mode)

```shell
du -sk *| grep -v ^0| sort
116     spool
129908  lib
15044   backups
1778604 cache
38092   www
4       tmp
573348  mail
64088   log
```

This is typical of sorting numbers as string: 1 is followed by 10, and then 2 and then 20.

`sort` can also remove duplicates, with the `-u` option, so you might not even need `uniq`:

Create a working file, by typing some values, end as usual with `control-d`:

```shell
cat > /tmp/sortme
a
b
c
d
e
f
a
b
c
d
```

Now, try to extract only unique values:

```shell
sort -u /tmp/sortme
a
b
c
d
e
f
```

The last option we will discuss regarding `sort` is `-c`, which will check if a file is actually sorted.

```shell
find /etc/ -type f > /tmp/sorttest
sort -c /tmp/sorttest
sort: /tmp/sorttest:3: disorder: /etc/java-6-sun/management/jmxremote.access
echo $?
1
```

`sort -c` returns a proper exit status, so it can be easily used in `if` and `while` compound commands.

```shell
ls /etc > /tmp/sorttest
sort -c /tmp/sorttest
echo $?
0
```

As we already knew, ls sorts automatically.

## `comm` ##

The typical use-case for `comm`, as the name suggests, is when you have a couple of files, and you want to find out what is in common and what is only present on each of the files.

`comm` expects the input files to be already sorted, and will produce output in 3 columns: lines that are unique to the first file, lines that are unique to the second file, and lines that are present in both files

You might use this to compare 2 configuration files, to see what's the difference, or to check the output of `ls` from 2 different directories, to find what is missing, or even, with the help of tools like `tshark`, to find packets missing from one pcap to another.

We will try it with a couple of example files, so we'll first generate our files:

```shell
find /etc/ -type f > /tmp/commtest1
cp /tmp/commtest1 /tmp/commtest2
```

We have 2 identical files: what happens if we compare them ?

```shell
comm /tmp/commtest{1,2}| less
comm: file 1 is not in sorted order
comm: file 2 is not in sorted order
```

Unfortunately comm gives you some (incorrect) output before it tells you that there was something wrong, rather than refusing to produce the output. This is probably because it doesn't do a precursory scan to see if the input is sorted, and it produces the output assuming the user knows what they are doing, but then, when it encounters evidence of the input not being sorted, it's too late to suppress the output.

Anyway, if you quit out of the `less` with `q`, you'll be greeted by the error message(s).

So, we need to sort the input files! You can't redirect the output over the same file used as input, so you can't do `sort /tmp/commtest1 > /tmp/commtest1` (technically you can, in the sense that the system will allow you to do it, but the result is not good), so we will create 2 new files:

```shell
for f in /tmp/commtest{1,2}
do
  sort "$f" > "$f.sorted"
done
```

It doesn't make much sense to test the files sorted by `sort` with `sort -c`, but you can definitely try it if you want, what we can do now is re-try the comparison:

```shell
comm /tmp/commtest{1,2}.sorted| less
```

This will show you the whole contents of `/tmp/commtest1.sorted`, but with 2 tabs prepended to each line:

Snippet of output of `comm`:

```
[…]
                /etc/sysctl.conf
                /etc/sysctl.d/README.sysctl
                /etc/systemd/journald.conf
[…]
```

Snippet of `/tmp/commtest1.sorted`:

```
/etc/sysctl.conf
/etc/sysctl.d/README.sysctl
/etc/systemd/journald.conf
```

This means that the whole file is in column 3, which means the 2 files are identical.

We need to make the 2 files a bit different, so let's edit `/tmp/commtest2.sorted` and remove some of the lines, and modify some other lines. You can either do it by hand with your favourite editor, or use `sed` like this: (we'll talk a little bit about `sed` just a few lines below)

```shell
sed -i '/systemd/d; s/conf/txt/g' /tmp/commtest2.sorted
```

And now let's try again to compare the 2 files:

```shell
comm /tmp/commtest{1,2}.sorted| less
```

What you will see varies depending on your system, and the changes you made to the files, but here is an example snippet of the output that will probably apply to your machine too if you used the `sed` changes:

```
/etc/sysctl.conf
                /etc/sysctl.d/README.sysctl
        /etc/sysctl.txt
/etc/systemd/journald.conf
```

Here you can see the 3 different columns: 

-	`/etc/sysctl.conf` is  unique to `/tmp/commtest1`, which is correct, since we replaced `conf` with `txt`
-	`/etc/sysctl.d/README.sysctl` is in common, since it doesn't contain `conf` nor `systemd`
-	`/etc/sysctl.txt` is unique to `/tmp/commtest2` since since we replaced `conf` with `txt`
-	`/etc/systemd/journald.conf` is unique to `/tmp/commtest1` since we deleted all the lines that contain `systemd`

## `tr` ## 

`tr` stands for translate, and `sed` has a similar functionality with the `y` command, but the power of `tr` is that it can also be used to remove characters, and some of the most typical characters you want to remove (such as the `\r` that comes with DOS files), which `sed` can't easily work with.

Let's try an example: imagine you have to download the mvps host list to protect your browsing experience form unwanted advertising.

The first step is to download the latest mvps host file from https://winhelp2002.mvps.org/hosts.txt

Like before, use `curl` or `wget`:

```shell
cd /tmp
wget https://winhelp2002.mvps.org/hosts.txt
```

or 

```shell
cd /tmp
curl --remote-name https://winhelp2002.mvps.org/hosts.txt
```

Either way, now you have your file, but is it in DOS or Unix format ?

```shell
file hosts.txt
hosts.txt: ASCII text, with CRLF line terminators
```

`CR`, or Carriage Return, is another name for `\r`, which is also known as `control-M`, or `^M`
`LF`, or Line Feed,  is another name for `\n`, or `control-J`, or `^J`. As we've seen above, it can also be represented as `$`, to mean the end of the line

Let's check directly to confirm what `file` is telling us:

```shell
cat -A hosts.txt | head -1
# This MVPS HOSTS file is a free download from:            #^M$
```

The presence of `CR`, or `^M` at the end of the line means that it is a DOS format file: we need to convert it.

```shell
tr -d '\r' < hosts.txt > hosts
```

`tr` is quite opinionated about how it should be used, and it doesn't want any file name, it just wants standard input, and it produces standard output.

But let's check the result:

```shell
file hosts
hosts: ASCII text
cat -A hosts | head -1
# This MVPS HOSTS file is a free download from:            #$
```

Perfect, now we can use the file.

You might wonder why this extra `\r` is a problem, so let's try an example:

Create a new file called `/tmp/dosfile` with your favourite editor, something like this:

```shell
#!/bin/bash
echo This script ran perfectly
```

If you are using `nano`, when saving it, after `control-x` and `Y`, type the file name and before pressing `enter`, ensure to do `alt-d`, so that the prompt for the file mane mentions "DOS Format", something like this: `File Name to Write [DOS Format]: /tmp/dosfile`
If you are using `vi`, at the end of each line, do `control-v` `control-m` to insert the `\r` delimiter

Double check that you were successful:

```shell
file /tmp/dosfile
/tmp/dosfile: Bourne-Again shell script, ASCII text executable, with CRLF line terminators
```

Make executable, and run it

```shell
chmod a+x /tmp/dosfile
/tmp/dosfile
-bash: /tmp/dosfile: /bin/bash^M: bad interpreter: No such file or directory
```

Result: the script can't run!

You might object that we had to go out of our way to cause this issue, which is true, but if you happen to copy and paste scripts from some place to another, such as from an email or a browser, into an editor such as notepad, you have a good chance of hitting issues like this.

You might also object that opening the file in `nano` and saving it in the appropriate format is a handy way to fix the issue, which is also true to some extent (not all systems have `nano`, for example ESX), but you might have hundreds of files in this condition, and you can't waste your time opening each one in `nano` when a `for` loop and a `tr` can do this in almost no time.

Another example of where `tr` is helpful is when the text you want to use contains nulls (`\0`), such as the command line for a process.

Pretend you're troubleshooting a situation where a certain machine is running out of memory, you start `top`, press `M` to sort by memory usage, and see at the top something like this:

```
  PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND
21322 root      20   0  761560 239324 224272 S   0.0  1.0   2:50.83 sssd_nss
20727 epops     30  10 6789428 141768   2324 S   0.0  0.6 740:57.91 java
```

What is thsi `java` thing ? You might press `c` and see the command line expanded, but it's very long and even with a 4k screen, it doesn't fit!

How can one read it ?

Well, you can read `/prot/<pid>/cmdline`, to see the command line as parsed by the shell (or whoever forked out the process) and passed on to the `java` process, but the convention for splitting words and passing them to the executable is to separate them with nulls, or `\0`, so if you use `cat`, everythinf is jumbled together:

```shell
cat /proc/20727/cmdline
/opt/epops/epops-agent/bundles/agent-x86-64-linux-8.0.0/jre/bin/java-Djava.security.auth.login.config=../../bundles/agent-x86-64-linux-8.0.0/jaas.config-Xmx128m-Djava.net.preferIPv4Stack=false-Dagent.install.home=../..-Dagent.bundle.home=../../bundles/agent-x86-64-linux-8.0.0-Dsun.net.inetaddr.ttl=-1-Djava.library.path=%LD_LIBRARY_PATH%:../../wrapper/lib-classpath../../bundles/agent-x86-64-linux-8.0.0/lib/dcs-agent-core-8.0.0.jar:../../bundles/agent-x86-64-linux-8.0.0/lib/dcs-tools-lather-8.0.0.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/JavaEWAH-1.1.2.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/animal-sniffer-annotations-1.9.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/ant-1.7.1.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/ant-launcher-1.7.1.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/antlr-2.7.6.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/aopalliance-1.0.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/asm-1.5.3.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/asm-attrs-1.5.3.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/backport-util-concurrent-3.1.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/bcpkix-jdk15on-1.51.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/bcprov-jdk15on-1.51.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/cglib-2.1_3.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/commons-beanutils-1.7.0.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/commons-codec-1.4.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/commons-collections-3.2.2.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/commons-digester-1.6.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/commons-io-1.4.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/commons-lang-2.5.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/commons-logging-1.0.4.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/commons-validator-1.3.1.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/dcs-agent-product.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/dcs-tools-common-8.0.0.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/dcs-tools-pdk-8.0.0.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/dcs-tools-util-8.0.0.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/dnsjava-2.0.6.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/dom4j-1.6.1.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/geronimo-j2ee-management_1.0_spec-1.1.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/getopt-1.0.13.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/hibernate-3.2.6.ga.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/httpclient-4.1.1.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/httpcore-4.1.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/icu4j-3.8.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/jasypt-1.8.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/jdom-1.1.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/jsch-0.1.42.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/log4j-1.2.14.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/org.springframework.roo.file.monitor-1.0.2.RELEASE.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/org.springframework.roo.file.monitor.polling-1.0.2.RELEASE.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/org.springframework.roo.support-1.0.2.RELEASE.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/oro-2.0.8.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/serializer-2.7.2.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/sigar-1.6.6.14.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/snmp4j-1.11.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/spring-aop-4.2.6.RELEASE.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/spring-beans-4.2.6.RELEASE.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/spring-context-4.2.6.RELEASE.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/spring-core-4.2.6.RELEASE.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/spring-expression-4.2.6.RELEASE.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/spring-tx-4.2.6.RELEASE.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/trove4j-3.0.3.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/velocity-1.6.3.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/wrapper-3.5.6.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/xalan-2.7.2.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/xml-apis-1.3.04.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/xpp3_min-1.1.4c.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/xstream-1.3.1.jar:../../wrapper/lib/wrapper.jar:../../bundles/agent-x86-64-linux-8.0.0/lib:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/jdbc/mysql-connector-java-5.1.10.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/jdbc/postgresql-42.2.4.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/mx4j/mx4j-3.0.1.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/mx4j/mx4j-jmx-3.0.1.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/mx4j/mx4j-remote-3.0.1.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/mx4j/mx4j-rjmx-2.1.1.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/mx4j/mx4j-tools-3.0.1.jar-Dwrapper.key=siqPSN32-LgrM83n-Dwrapper.port=32000-Dwrapper.jvm.port.min=31000-Dwrapper.jvm.port.max=31999-Dwrapper.disable_console_input=TRUE-Dwrapper.pid=2042-Dwrapper.version=3.5.6-Dwrapper.native_library=wrapper-Dwrapper.service=TRUE-Dwrapper.cpu.timeout=10-Dwrapper.jvmid=3org.tanukisoftware.wrapper.WrapperStartStopApporg.hyperic.hq.bizapp.agent.client.AgentClient1startorg.hyperic.hq.bizapp.agent.client.AgentClienttrue2die30
```

This is where `tr` can help better than any other tool: replace the `\0` with a space or a newline, if you prefer:


```shell
tr '\0' ' ' < /proc/20727/cmdline
/opt/epops/epops-agent/bundles/agent-x86-64-linux-8.0.0/jre/bin/java -Djava.security.auth.login.config=../../bundles/agent-x86-64-linux-8.0.0/jaas.config -Xmx128m -Djava.net.preferIPv4Stack=false -Dagent.install.home=../.. -Dagent.bundle.home=../../bundles/agent-x86-64-linux-8.0.0 -Dsun.net.inetaddr.ttl=-1 -Djava.library.path=%LD_LIBRARY_PATH%:../../wrapper/lib -classpath ../../bundles/agent-x86-64-linux-8.0.0/lib/dcs-agent-core-8.0.0.jar:../../bundles/agent-x86-64-linux-8.0.0/lib/dcs-tools-lather-8.0.0.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/JavaEWAH-1.1.2.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/animal-sniffer-annotations-1.9.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/ant-1.7.1.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/ant-launcher-1.7.1.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/antlr-2.7.6.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/aopalliance-1.0.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/asm-1.5.3.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/asm-attrs-1.5.3.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/backport-util-concurrent-3.1.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/bcpkix-jdk15on-1.51.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/bcprov-jdk15on-1.51.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/cglib-2.1_3.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/commons-beanutils-1.7.0.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/commons-codec-1.4.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/commons-collections-3.2.2.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/commons-digester-1.6.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/commons-io-1.4.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/commons-lang-2.5.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/commons-logging-1.0.4.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/commons-validator-1.3.1.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/dcs-agent-product.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/dcs-tools-common-8.0.0.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/dcs-tools-pdk-8.0.0.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/dcs-tools-util-8.0.0.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/dnsjava-2.0.6.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/dom4j-1.6.1.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/geronimo-j2ee-management_1.0_spec-1.1.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/getopt-1.0.13.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/hibernate-3.2.6.ga.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/httpclient-4.1.1.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/httpcore-4.1.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/icu4j-3.8.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/jasypt-1.8.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/jdom-1.1.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/jsch-0.1.42.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/log4j-1.2.14.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/org.springframework.roo.file.monitor-1.0.2.RELEASE.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/org.springframework.roo.file.monitor.polling-1.0.2.RELEASE.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/org.springframework.roo.support-1.0.2.RELEASE.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/oro-2.0.8.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/serializer-2.7.2.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/sigar-1.6.6.14.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/snmp4j-1.11.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/spring-aop-4.2.6.RELEASE.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/spring-beans-4.2.6.RELEASE.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/spring-context-4.2.6.RELEASE.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/spring-core-4.2.6.RELEASE.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/spring-expression-4.2.6.RELEASE.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/spring-tx-4.2.6.RELEASE.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/trove4j-3.0.3.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/velocity-1.6.3.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/wrapper-3.5.6.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/xalan-2.7.2.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/xml-apis-1.3.04.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/xpp3_min-1.1.4c.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/xstream-1.3.1.jar:../../wrapper/lib/wrapper.jar:../../bundles/agent-x86-64-linux-8.0.0/lib:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/jdbc/mysql-connector-java-5.1.10.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/jdbc/postgresql-42.2.4.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/mx4j/mx4j-3.0.1.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/mx4j/mx4j-jmx-3.0.1.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/mx4j/mx4j-remote-3.0.1.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/mx4j/mx4j-rjmx-2.1.1.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/mx4j/mx4j-tools-3.0.1.jar -Dwrapper.key=siqPSN32-LgrM83n -Dwrapper.port=32000 -Dwrapper.jvm.port.min=31000 -Dwrapper.jvm.port.max=31999 -Dwrapper.disable_console_input=TRUE -Dwrapper.pid=2042 -Dwrapper.version=3.5.6 -Dwrapper.native_library=wrapper -Dwrapper.service=TRUE -Dwrapper.cpu.timeout=10 -Dwrapper.jvmid=3 org.tanukisoftware.wrapper.WrapperStartStopApp org.hyperic.hq.bizapp.agent.client.AgentClient 1 start org.hyperic.hq.bizapp.agent.client.AgentClient true 2 die 30
```

Much more readable! And with a newline instead:

```shell
tr '\0' '\n' < /proc/20727/cmdline
/opt/epops/epops-agent/bundles/agent-x86-64-linux-8.0.0/jre/bin/java
-Djava.security.auth.login.config=../../bundles/agent-x86-64-linux-8.0.0/jaas.config
-Xmx128m
-Djava.net.preferIPv4Stack=false
-Dagent.install.home=../..
-Dagent.bundle.home=../../bundles/agent-x86-64-linux-8.0.0
-Dsun.net.inetaddr.ttl=-1
-Djava.library.path=%LD_LIBRARY_PATH%:../../wrapper/lib
-classpath
../../bundles/agent-x86-64-linux-8.0.0/lib/dcs-agent-core-8.0.0.jar:../../bundles/agent-x86-64-linux-8.0.0/lib/dcs-tools-lather-8.0.0.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/JavaEWAH-1.1.2.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/animal-sniffer-annotations-1.9.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/ant-1.7.1.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/ant-launcher-1.7.1.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/antlr-2.7.6.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/aopalliance-1.0.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/asm-1.5.3.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/asm-attrs-1.5.3.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/backport-util-concurrent-3.1.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/bcpkix-jdk15on-1.51.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/bcprov-jdk15on-1.51.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/cglib-2.1_3.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/commons-beanutils-1.7.0.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/commons-codec-1.4.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/commons-collections-3.2.2.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/commons-digester-1.6.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/commons-io-1.4.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/commons-lang-2.5.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/commons-logging-1.0.4.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/commons-validator-1.3.1.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/dcs-agent-product.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/dcs-tools-common-8.0.0.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/dcs-tools-pdk-8.0.0.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/dcs-tools-util-8.0.0.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/dnsjava-2.0.6.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/dom4j-1.6.1.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/geronimo-j2ee-management_1.0_spec-1.1.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/getopt-1.0.13.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/hibernate-3.2.6.ga.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/httpclient-4.1.1.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/httpcore-4.1.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/icu4j-3.8.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/jasypt-1.8.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/jdom-1.1.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/jsch-0.1.42.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/log4j-1.2.14.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/org.springframework.roo.file.monitor-1.0.2.RELEASE.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/org.springframework.roo.file.monitor.polling-1.0.2.RELEASE.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/org.springframework.roo.support-1.0.2.RELEASE.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/oro-2.0.8.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/serializer-2.7.2.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/sigar-1.6.6.14.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/snmp4j-1.11.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/spring-aop-4.2.6.RELEASE.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/spring-beans-4.2.6.RELEASE.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/spring-context-4.2.6.RELEASE.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/spring-core-4.2.6.RELEASE.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/spring-expression-4.2.6.RELEASE.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/spring-tx-4.2.6.RELEASE.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/trove4j-3.0.3.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/velocity-1.6.3.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/wrapper-3.5.6.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/xalan-2.7.2.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/xml-apis-1.3.04.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/xpp3_min-1.1.4c.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/xstream-1.3.1.jar:../../wrapper/lib/wrapper.jar:../../bundles/agent-x86-64-linux-8.0.0/lib:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/jdbc/mysql-connector-java-5.1.10.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/jdbc/postgresql-42.2.4.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/mx4j/mx4j-3.0.1.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/mx4j/mx4j-jmx-3.0.1.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/mx4j/mx4j-remote-3.0.1.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/mx4j/mx4j-rjmx-2.1.1.jar:../../bundles/agent-x86-64-linux-8.0.0/pdk/lib/mx4j/mx4j-tools-3.0.1.jar
-Dwrapper.key=siqPSN32-LgrM83n
-Dwrapper.port=32000
-Dwrapper.jvm.port.min=31000
-Dwrapper.jvm.port.max=31999
-Dwrapper.disable_console_input=TRUE
-Dwrapper.pid=2042
-Dwrapper.version=3.5.6
-Dwrapper.native_library=wrapper
-Dwrapper.service=TRUE
-Dwrapper.cpu.timeout=10
-Dwrapper.jvmid=3
org.tanukisoftware.wrapper.WrapperStartStopApp
org.hyperic.hq.bizapp.agent.client.AgentClient
1
start
org.hyperic.hq.bizapp.agent.client.AgentClient
true
2
die
30
```

This also shows you why you should never type passwords as parameters to any command line: the parameters to any command is easily read by anyone.

That completes the Advanced Power Tools lesson on `sort`, `comm` and `tr`. [Click here to return to the lesson list](../README.md)
