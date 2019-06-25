#!/bin/sh

echo "pwd;find . | sort | sed -e '1d' -e 's/^\.//' -e 's/\/\([^/]*\)$/|--\1/' -e 's/\/[^/|]*/|  /g'"
echo "pwd;find ."
      pwd;find .
echo "pwd;find . | sort"
      pwd;find . | sort
echo "pwd;find . | sort | sed -e '1d'"
      pwd;find . | sort | sed -e '1d'
echo "pwd;find . | sort | sed -e '1d' -e 's/^\.//'" 
      pwd;find . | sort | sed -e '1d' -e 's/^\.//' 
echo "pwd;find . | sort | sed -e '1d' -e 's/^\.//' -e 's/\/\([^/]*\)$/|--\1/'"
      pwd;find . | sort | sed -e '1d' -e 's/^\.//' -e 's/\/\([^/]*\)$/|--\1/'
echo "pwd;find . | sort | sed -e '1d' -e 's/^\.//' -e 's/\/\([^/]*\)$/|--\1/' -e 's/\/[^/|]*/|  /g'"
      pwd;find . | sort | sed -e '1d' -e 's/^\.//' -e 's/\/\([^/]*\)$/|--\1/' -e 's/\/[^/|]*/|  /g'


echo "ls -R $ODIR | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//| -/g' -e 's/^/ /' -e 's/-|/ |/g' -e 's/-|/ |/g'"
echo "ls -R $ODIR"
      ls -R $ODIR
echo "ls -R $ODIR | grep ":$""
      ls -R $ODIR | grep ":$"
echo "ls -R $ODIR | grep ":$" | sed -e 's/:$//'"
      ls -R $ODIR | grep ":$" | sed -e 's/:$//'
echo "ls -R $ODIR | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//| -/g'"
      ls -R $ODIR | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//| -/g'
echo "ls -R $ODIR | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//| -/g' -e 's/^/ /'"
      ls -R $ODIR | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//| -/g' -e 's/^/ /'
echo "ls -R $ODIR | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//| -/g' -e 's/^/ /' -e 's/-|/ |/g'"
      ls -R $ODIR | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//| -/g' -e 's/^/ /' -e 's/-|/ |/g'
echo "ls -R $ODIR | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//| -/g' -e 's/^/ /' -e 's/-|/ |/g' -e 's/-|/ |/g'"
      ls -R $ODIR | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//| -/g' -e 's/^/ /' -e 's/-|/ |/g' -e 's/-|/ |/g'

echo "du -k --max-depth=1 | sort -nr "
du -k --max-depth=1 | sort -nr | awk '
     BEGIN {
        split("KB,MB,GB,TB", Units, ",");
     }
     {
        u = 1;
        while ($1 >= 1024) {
           $1 = $1 / 1024;
           u += 1
        }
        $1 = sprintf("%.1f %s", $1, Units[u]);
        print $0;
     }
    '
