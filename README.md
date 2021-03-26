# Bash Shell Scripting #

A Bash Shell Scripting Tutorial - one of the modules of the __vCoders__ Initiative.

## Introduction ##

Shell scripting can be very simple, because you can just take inspiration from the history of commands you used to solve a problem, and glue them together in a script.

However it can also become very complicated, because bash syntax has grown organically and is not based on a single grammar like many other programming languages. Therefore it might appear inconsistent and complicated at advanced levels.

The purpose of this tutorial is to give you some guidance on how to get started with bash shell programming. We will start with some fundamentals, and move onto more complex topics as the lessons progress.

## Self-paced ##

This tutorial is designed to be self-paced. Anyone with a Unix/Linux/Mac environment should be able to do these exercises. We have also provided plenty of real-life examples for you to try out along the way.

## Why bash? ##

We chose __bash__, the Bourne Again shell, due to its popularity, and the fact that it is the default login shell for most Linux distributions.

## Lessons ###

It is recommended that you take the following lessons in order as they start with the simpler introductions and progress to more challenging examples.

### Introductory Lessons ###

- [Lesson 1 - Your Shell](./lessons/YourShell.md). A look around your shell
- [Lesson 2 - Power Tools](./lessons/PowerTools.md) A look at some useful commands/tools
- [Lesson 3 - Your First Shell script](./lessons/YourFirstScript.md) Let's create your first script
- [Lesson 4 - An Introduction to Compound Commands](./lessons/CompoundCommands.md) Some looping and conditional constructs
- [Lesson 5 - Fun with Quotes](./lessons/FunWithQuotes.md) Understanding quotes

### Intermediate Lessons ###

- [Lesson 6 - Shell Variables](./lessons/Variables.md) How shell variables and positional parameters work
- [Lesson 7 - Parameter Expansion](./lessons/Expansion.md) Understanding Expansion Rules & Precedence
- [Lesson 8 - Word Splitting](./lessons/WordSplitting.md) Handling white spaces and seperators
- [Lesson 9 - Simple Single Action Commands](./lessons/SimpleCommands.md) The art of Pipe

### Advanced Lessons ###

- [Lesson 10 - More Compound Commands](./lessons/AdvancedCompoundCommands.md) Complex multi-action compound commands and flow control
- [Lesson 11 - SubShells](./lessons/SubShells.md) A special type of Compound Command: SubShells
- [Lesson 12 - Advanced Power Tools - find](./lessons/AdvancedPowerToolsFind.md)  Useful techniques on using _find_
- [Lesson 13 - Advanced Power Tools - grep](./lessons/AdvancedPowerToolsGrep.md)  Useful techniques on using _grep_
- [Lesson 14 - Advanced Power Tools - awk & sed](./lessons/AdvancedPowerToolsSedAwk.md)  Useful techniques on using _awk_ and _sed_
- [Lesson 15 - Advanced Power Tools - sort, comm & tr](./lessons/AdvancedPowerToolsSortCommTr.md)  Useful techniques on using _sort_, _comm_ and _tr_

### Practical ###

- [Lesson 16 - Bringing It All Together](./lessons/LogAnalysisViaShellCmds.md) Manipulating and Analysing log bundles with shell commands

## Quick Reference ##

### Shell Environment Variables ###

- $$
- $PATH
- $SHELL
- $HOME
- env
- .bashrc
- .bash_profile

### Condition Expressions and Control Loop Constructs ###

- if-then-fi
- while-do-done
- for-do-done
- select-do-done
- case-esac

### Useful commands featured in the tutorial ###

We will be using the following commands in the tutorial. More information about these commands can be found using the `man pages` on your Unix/Linux/MacOS distribution. Simply type `man <command-name>` for more information.

- awk
- cat
- cd
- chmod
- comm
- cut
- date
- echo
- expr
- file
- find
- grep
- head
- ls
- paste
- ps
- read
- rm
- sed
- seq
- sleep
- sort
- tail
- type
- touch
- tr
- uniq
- wc
- which
- xargs

## How to find help ##

In shell scripting, there are a few common pitfalls to be aware of, and then a lot of less known features that make your life easier. Knowing how to find information about the features of shell programmign is key.

For example, for bash, the `man bash` [bash(1)](https://man7.org/linux/man-pages/man1/bash.1.html)  and `man bash-builtins` [bash-builtins(7)](https://www.commandlinux.com/man-page/man7/bash-builtins.7.html) man pages are a very good resource, as is the old but still applicable [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/) or the official [Bash Reference Manual](https://www.gnu.org/software/bash/manual/html_node/index.html)

You might wonder about the difference between `bash(1)` and `bash-builtins(7)` man pages, since the latter is a sub-section of the former. The reason for this is because you might need to check out the _builtins_ when writing your script for reference. Finding the right section in the main manual might be a challenge, especially if the command you are looking for is mentioned all over the manual, for example, commands like `read` or `time`. Having a separate section only for the _builtin_ commands makes this search much easier. The `man` page for __bash__ is quite big, and it takes a bit of time to get used to how it is organised. We will see shortly the compund command `if`. When searching for information about `if`, you will need to remember that it is a compound command, and search the man pages for that.

We will see a few of the most important features during the course of this tutorial.
