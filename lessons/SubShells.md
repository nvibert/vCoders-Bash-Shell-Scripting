# Lesson 11 - SubShells #

We briefly touch on subshells in some earlier topics. It is another example of a compound command, but since it is an important concept in shell programming, we wanted to include a short focused lesson on it. Sometimes, the way you construct your script causes the shell to `fork`, starting a new process that contains another shell: this new shell is usually called subshell.

The concept of subshell might look irrelevant, and most of the times it is invisible to the user, but it has one main consequence: a subshell contains a copy of the variables available in the parent shell, and since they are a **copy**, you can modify them, but the parent's variables won't be affected.

For example: let's say we want to see if the sum of the first 10 numbers is less or more than 50, like we did previously:

```shell
% TOTAL=0
% seq 1 10 | while read number
do
  ((TOTAL+= number))
  echo "partial total = $TOTAL"
done
echo "total = $TOTAL"
partial total = 1
partial total = 3
partial total = 6
partial total = 10
partial total = 15
partial total = 21
partial total = 28
partial total = 36
partial total = 45
partial total = 55
total = 0
```

Why is the total 0 ?

Well, if you look carefully, you'll notice that we are using `seq` to produce the 10 numbers we want to add up, and then we `pipe` that to our script, which does the calculation. But the `pipe` means that the right side is a `subshell`, since the parent shell needs to send its output to the `while read`. This means that the TOTAL variable gets copied into the subshell, and that's the one we're modifying, and we are printing it as "partial total". But when the while loop ends, the subshell ends, and it will get deleted. The parent shell resumes execution, and that TOTAL has never been changed.

How can we do this then ?

We have seen previously how you can do `for number in $(seq 1 10)`: this means that now `seq` is run in a subshell, but we do not mind, since `seq` is not modifying any variable.

This is only useful if we want to use the whole line of the output, but if we want to split the line in fields and use more than one of these fields for processing, we are forced to use `while read`, and so how can we avoid the subshell?

One way is to avoid the pipe, and use process substitution to send the output of `seq` into the `while read` as a redirection:

```shell
% TOTAL=0
% while read number
do
  ((TOTAL+= number))
  echo "partial total = $TOTAL"
done < <(seq 1 10)
echo "total = $TOTAL"
partial total = 1
partial total = 3
partial total = 6
partial total = 10
partial total = 15
partial total = 21
partial total = 28
partial total = 36
partial total = 45
partial total = 55
total = 55
```

Process substitution is very handy!

Remember the exercise of checking the %free for the filesystems? What if we want the total size of all the filesystem, and the overall percentage of disk usage?

```shell
% TOTALsize=0
% TOTALused=0
% while read fs size used available usedp mountpoint
do
  let TOTALsize+=size
  let TOTALused+=used
done < <(df -k | sed 1d)
echo "TOTAL size = $TOTALsize used = $TOTALused ($((100 * TOTALused / TOTALsize))%)"
TOTAL size = 20844062 used = 12665594 (60%)
```

In this case, the `for` loop wouldn't be suitable.

This completes the lesson on SubShells. [Click here to return to the lesson list](../README.md)
