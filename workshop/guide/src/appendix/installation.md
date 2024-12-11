# Installation

The best place to get Alloy is from the [download page][alloy].

## MacOS

For macOS, the download page above includes a disk image that
is self-contained.

## Windows and Linux

On Windows and Linux, you download nad run the `.jar` file.

It is a Java Archive (JAR) file so you need to install a [Java Runtime
Environment][jre] (JRE).

Once everything is in place one can start Alloy via the commandline as

```sh
java -jar org.alloytools.alloy.dist.jar
```

I prefer to be able to run a single command, so I have the following available
as an `alloy` command on my path.

```sh
#! /usr/bin/sh

java -jar ~/.local/lib/org.alloytools.alloy.dist.jar
```

[alloy]: https://alloytools.org/download.html
[jre]: https://www.java.com/en/download/manual.jsp
