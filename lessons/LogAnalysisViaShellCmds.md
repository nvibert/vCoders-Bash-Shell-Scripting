# Lesson 16 - Bringing It All Together #

In this lesson, you are going to be mostly on your own. We have a log dump taken from a vSphere environment which you will analyze using some of your new scripting skills.

## Log Analysis using Shell Commands ##

The plan is to use what you've learnt so far, and try to apply it to a *somewhat* realistic use case, such as looking at a log bundle. The idea is to try and do the following:

1. Reassemble any fragment in the log bundle
1. Find all log files, and concatenate them together in order after unzipping them to get a single file to work with
1. Search through the resulting concatenated files for some error.
1. Improve the search script with more advanced functionalities
1. Create a script to generate a report of the inventory of the server (VMs)

### Step 1 - Get the logs ready ###

First you will need to unzip and untar the bundles. You can now use the following shell  commands to do that, after you have navigated to the log bundle.

```shell
% mkdir /tmp/logs
% cd /tmp/logs
% unzip /home/vcoders/Desktop/VMware-vCenter-support-2021-03-08@14-49-25.zip
Archive:  /home/vcoders/Desktop/VMware-vCenter-support-2021-03-08@14-49-25.zip
  inflating: esxi-dell-m.rainpole.com-vm2021-8-03@14-49-26.tgz
  inflating: esxi-dell-n.rainpole.com-vm2021-8-03@14-59-36.tgz
% for a in *.tgz; do tar xzf $a; done
% ls -d esx-esxi*
esx-esxi-dell-m.rainpole.com-2021-03-08--14.49-17885597  esx-esxi-dell-n.rainpole.com-2021-03-08--14.59-17727230
```

### Step 2 - Rebuild all the fragmented files ###

When analysing logs using the standard tools, the logs are downloaded, unzipped and then the fragments are used to reconstruct the files that are larger than 1mb, automatically.

If you happen to be analysing logs somewhere else than the standard "CSP" (support) servers, you will have to take care of all these steps, which offers an opportunity to use our newly acquired scripting skills! If you don't know what CSP is, it means you do not have access to GSS' helper scripts, so you will have to do this process anyway.

We have already taken care of acquiring and unzipping all the logs, so what is left to do is reconstructing all the fragmented files.

When building a script, the first thing you will do is "reconnaissance", which means to try a few of the core commands that will constitute the back-bone of your script. In this case, we need first to look for the fragments, and see what they look like: this looks like a job for `find`:

```shell
% find -type f -name "*.FRAG*"
[…]
```

A lot of output there, how many file fragments are we talking about?

```shell
% find -type f -name "*.FRAG*" | wc -l
2083
```

Looking at the output, you might notice that there are always at least 2 fragments, and the first is always `0`, so we can use that to reduce the amount of data we need to work with, and to get a good input for our script:

```shell
% find -type f -name "*.FRAG-00000"
[…]
```

Excellent! The second step is, after a merge together the fragments, to decide on what the resulting file should be called. It is probably a matter of removing the `.FRAG-00000` part, and this looks like the perfect job for the shell's "Remove matching suffix pattern" feature. Let's try it!

```shell
% find -type f -name "*.FRAG-00000" | while read firstfrag
do
  echo $firstfrag will become ${firstfrag##.FRAG-00000}
done
./esx-esxi-dell-m.rainpole.com-2021-03-08--14.49-17885597/commands/vsi_traverse_-s.txt.FRAG-00000 will become ./esx-esxi-dell-m.rainpole.com-2021-03-08--14.49-17885597/commands/vsi_traverse_-s.txt.FRAG-00000
[…]
```

The script is starting to take form, but wait! The output is wrong: the 2nd file name is just the same as the first! Can you spot what is wrong ?

We actually used "Remove matching prefix pattern" (`##`) instead of "Remove matching suffix pattern" (`%%`)! It's hard to remember which is which. The trick I use is this mnemonic: the `#` is typically at the beginning of a line because it's the beginning of a comment, and the `%` is usually after a number to mean percentage. If you find a better mnemonic, let me know. Anyway, let's replace the `##` with `%%`, and try again:

```shell
% find -type f -name "*.FRAG-00000" | while read firstfrag
do
  echo $firstfrag will become ${firstfrag%%.FRAG-00000}
done
./esx-esxi-dell-m.rainpole.com-2021-03-08--14.49-17885597/commands/vsi_traverse_-s.txt.FRAG-00000 will become ./esx-esxi-dell-m.rainpole.com-2021-03-08--14.49-17885597/commands/vsi_traverse_-s.txt
[…]
```

Excellent. The next step is to find the names of all the other fragments, so that we can concatenate them. We need to be careful with the order, because otherwise the reconstructed file will have its contents all mixed up too. Let's do some more reconnaissance.

We don't need to test the `find` any more, so we will just simulate it with `firstfrag` being assigned to `./esx-esxi-dell-m.rainpole.com-2021-03-08--14.49-17885597/commands/vsi_traverse_-s.txt.FRAG-00000`

```shell
% firstfrag=./esx-esxi-dell-m.rainpole.com-2021-03-08--14.49-17885597/commands/vsi_traverse_-s.txt.FRAG-00000

% endfilename=${firstfrag%%.FRAG-00000}

% ls $endfilename.FRAG-*| wc -l
314
```

Sounds about right - we would normally expect around 300 fragments for the _vsi_traverse_-s.txt_ file. However, to verify, run `ls $endfilename.FRAG-*|less` and make sure the fragments are for the same file. Once that's confirmed, keep the number in a variable for later use:

```shell
% firstfrag=./esx-esxi-dell-m.rainpole.com-2021-03-08--14.49-17885597/commands/vsi_traverse_-s.txt.FRAG-00000

% endfilename=${firstfrag%%.FRAG-00000}

% fragcount=$(ls $endfilename.FRAG-*| wc -l)

% for ((fragn=0; fragn<fragcount; fragn++))
do
  printf "$endfilename.FRAG-%05d\n" "$fragn"
done
```

The output might look the same, but we are forcing the order to be in our control. You might want to look up the `printf` command to understand what it does. It is a shell builtin, so check `bash-builtins(7)` with `man bash-builtins`.

```shell
% type printf
printf is a shell builtin
```

The manual page might tell you to check out `printf(1)` for more information, but I'd say you might be more interested in `printf(3)`.

Now, how do we work with these file names? We could store them in an array. Arrays can be built using parenthesis (`(` and `)`):

```shell
% firstfrag=./esx-esxi-dell-m.rainpole.com-2021-03-08--14.49-17885597/commands/vsi_traverse_-s.txt.FRAG-00000

% endfilename=${firstfrag%%.FRAG-00000}

% fragcount=$(ls $endfilename.FRAG-*| wc -l)

% listoffrags=($(for ((fragn=0; fragn<fragcount; fragn++)) do printf "$endfilename.FRAG-%05d\n" "$fragn"; done))

% echo ${listoffrags[7]}
./esx-esxi-dell-m.rainpole.com-2021-03-08--14.49-17885597/commands/vsi_traverse_-s.txt.FRAG-00007
```

You might ask: can we avoid using the array, and just use:

`listoffrags=$(for ((fragn=0; fragn<fragcount; fragn++)) do printf "$endfilename.FRAG-%05d\n" $fragn; done)`

Well, in this case you would be correct, since we know there are no spaces in any of the directories or file names. Therefore you could just as easily use:

`lisroffrags=$(ls $endfilename.FRAG-*)`

This because we've already seen how `ls` sorts its output alphabetically, and the fragment names are zero padded to ensure that numeric and string sorting coincide. But none of these would deal with spaces in the names, and we want to be cautious. So, the solution we are planning to use is this:

```shell
% firstfrag=./esx-esxi-dell-m.rainpole.com-2021-03-08--14.49-17885597/commands/vsi_traverse_-s.txt.FRAG-00000

% endfilename=${firstfrag%%.FRAG-00000}

% fragcount=$(ls $endfilename.FRAG-*| wc -l)

% listoffrags=($(for ((fragn=0; fragn<fragcount; fragn++)) do printf "$endfilename.FRAG-%05d\n" "$fragn"; done))

% cat "${listoffrags[@]}" > "$endfilename"

% ls -lh "$endfilename"
```

So far we are doing great, all we have left to do is clean-up of the old fragments, which are not needed any more. It might be a good idea to delete the files only if the re-assembly was successful, so in this case, we could use `&&`:

```shell
% firstfrag=./esx-esxi-dell-m.rainpole.com-2021-03-08--14.49-17885597/commands/vsi_traverse_-s.txt.FRAG-00000

% endfilename=${firstfrag%%.FRAG-00000}

% fragcount=$(ls $endfilename.FRAG-*| wc -l)

% listoffrags=($(for ((fragn=0; fragn<fragcount; fragn++)) do printf "$endfilename.FRAG-%05d\n" "$fragn"; done))

% cat "${listoffrags[@]}" > "$endfilename" && rm "${listoffrags[@]}"

% ls -lh "$endfilename"*
-rw-r--r-- 1 tse tse 314M Mar 12 11:41 ./esx-esxi-dell-m.rainpole.com-2021-03-08--14.49-17885597/commands/vsi_traverse_-s.txt
```

Excellent. So, let's put all this in a file, and stitch together this part with the previous `find` part. Let's call this script `~/reconstruct.sh`, with the following content:

```shell
#!/bin/bash
find -type f -name "*.FRAG-00000" | while read firstfrag
do
  endfilename=${firstfrag%%.FRAG-00000}

  fragcount=$(ls $endfilename.FRAG-*| wc -l)

  listoffrags=($(for ((fragn=0; fragn<fragcount; fragn++)) do printf "$endfilename.FRAG-%05d\n" "$fragn"; done))

  cat "${listoffrags[@]}" > "$endfilename" && rm "${listoffrags[@]}"

done
```

Make executable with `chmod a+x ~/reconstruct.sh`, and run it from the `/tmp/logs` directory

### Step 3 - find and unzip all logs ###

The last part of the log bundle preparation is to look for all the logs in the `/var/run/log` directory, and prepare them for being read. Most of the logs are rotated to keep the disk usage under control, and so they appear in the format `filename.log`, `filename.1.gz`, `filename.2.gz` and so on.

What you should do now is create a new script, let's call it `~/prepareAllLogs.sh`, which does the following:

1. Assume it is being run from the base directory of the ESXi host's log bundle (e.g. the one whose name is of the form `esx-<hostname>-<timestamp>-<pid>`).
1. Scan all the files in `var/log` and `var/run/log`, and for each file, identify the "resulting file name" (e.g. for `filename.log`, `filename.1.gz`, etc. We could call the resulting file name something like `filename.log.all`).
1. Concatenate all the logs that are related to the "resulting file name" in order, starting from the oldest to the newest (so from `filename.100.gz` through to `filename.1.gz` and then `filename.log`).
1. Before concatenating the files, you may need to unzip them. Use the `gunzip` or `zcat` tools if necessary.
1. The end result should be that, for each group of related log files, there will be a "resulting file name" in the same directory, with all the content in chronological order.

### Step 4 - Search through the logs ###

Write a script called `~/searchLogs`, that will allow you to search through the logs for a pattern (you can assume it will be a BRE - Basic Regular Expression), that will be provided as the first argument to your script, and report back the list of files that match.

An optional second parameter, when set to `count`, should change the output to also include the number of lines that match the supplied pattern, after the file name.

If the second parameter is `list`, on the other hand, the script should list each line that matches, prepending it with the name of the file.

Lastly, after the above parameters have been provided, the script should also expect to receive a list of log files to scan. If no files are provided, the script should print an error or help message in standard error.

Similarly, if no parameters are supplied to the script, the script should print some help to describe the script usage, again in standard error .

You can find a reference implementation in [searchLogs](../samples/searchLogs) to get you started, but see if you can write something before looking at the sample script.

### Step 5 - More Advanced Searching ###

Make a copy of `searchLogs`, called `searchLogsAdvanced`. We are going to expand the functionalities by adding 2 new commands for the 2nd option: `hourly` and `minutely`.

If the second parameter is `hourly`, the script show now report how many lines match the supplied regular expression, aggregated for each hour. Scan across all supplied files

Similarly, if the second parameter is `minutely`, the script should aggregate and report the lines per minute, rather than per hour.

You can assume that the timestamp follows the iso 8601 format, which is the standard for VMware products. This means the timestamps will look like this: `2021-03-08T14:22:51.488Z`, followed by a space, followed by the log

When `hourly` or `minutely` is specified, and if pattern starts with a "hat", the script will fail. Therefore you will need to take that into account and, remove the "hat" if that issue is encountered.

Here is what a sample output might look like:

```shell
% searchLogsAdvanced KeyCache minutely esx-esxi-dell-m.rainpole.com-2021-03-08--14.49-17885597/var/run/log/vmkernel.log
     28 2021-03-08T14:22
     12 2021-03-08T14:23
     24 2021-03-08T14:24
      4 2021-03-08T14:28
     24 2021-03-08T14:29
      4 2021-03-08T14:33
     24 2021-03-08T14:34
      4 2021-03-08T14:38
     24 2021-03-08T14:39
      4 2021-03-08T14:43
     24 2021-03-08T14:44
      4 2021-03-08T14:48
     24 2021-03-08T14:49
      4 2021-03-08T14:53
     24 2021-03-08T14:54

% searchLogsAdvanced KeyCache hourly esx-esxi-dell-m.rainpole.com-2021-03-08--14.49-17885597/var/run/log/vmkernel.log
    232 2021-03-08T14
```

You can find a reference implementation in [searchLogsAdvanced](../samples/searchLogsAdvanced) to get you started, but see if you can write something before looking at the sample script.

### Step 6 - Inventory script / Parsing XML ###

Create a script called `vms`, which will scan the `etc/vmware/host/vmInventory.xml` file in each ESXi host log bundle main directory. It is safe to assume that the format of the xml file will maintain one XML tag per line, thus allowing text tools that are not XML aware to work on it.

Using the `vmxCfgPath` tags, build a list of virtual machines that are registered in the host. Find the corresponding `vmx` file by converting the absolute path in vmxCfgPath to be relative to the log bundle's bnase directory, and read each virtual machines corresponding `vmx` file to gather some more details for the VM, such as:

- display name
- guestOs type
- number of CPUs
- amount of memory
- number of disks
- number of NICs

For each VM, your script should report the VM's display name, followed by the (absolute) `vmx` path, and then the details obtained from the vmx.

The script will need to check that it is being from inside a log bundle's base directory to locate `etc/vmware/hostd/vmInventory.xml`. The script should error if it can't find that path to the `xml` file from the current directory.

The script should also accept as parameters a list of paths to log bundle base directories, and in that case, for each log bundle directory, it should print its name, and then work from that directory, and then move to the next.

You can find a reference implementation in [vms](../samples/vms) to get you started, but see if you can write something before looking at the sample script.

That completes the log analysis lesson. And that also completed the tutorial. Congratulations! [Click here to return to the lesson list](../README.md)
