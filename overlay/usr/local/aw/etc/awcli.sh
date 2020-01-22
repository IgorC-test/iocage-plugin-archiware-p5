#!/bin/sh
#
# Example script for how to use PresStore CLI for a simple task
# of archiving and/or restoring local files. It is build upon
# the PresStore CLI. For more information about the CLI visit:
#
#   https://support.archiware.com/support/download/cli.pdf
#
# This script assumes the following syntax:
#
#   awcli.sh archive <plan_name> file1 file2 ... fileN
#   awcli.sh restore <plan_name> file1 file2 ... fileN
#
# This submits files file1...fileN for operation (archive/restore)
# using archive plan <plan_name>. The plan must be properly setup
# and enabled by using the PresStore GUI.
#
# The script requires environment variable AWPST_HOME properly
# pointing to the installation directory of PresStore. If no
# such variable set, it will default to /usr/local/aw directory.
#
# See the file "license.txt" for information on usage and
# redistribution of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# ----------------------------------------------------------------------

#
# Override locale settings
#

LC_ALL="C"; export LC_ALL

usage() {
    echo "usage: $0 [archive | restore] plan_name file1 file2 ... fileN"
    exit 1
}
clierr() {
    echo "`$nc -c geterror`"
    exit 1
}

#
# Locate the nsdchat utility
#

if test -z "$AWPST_HOME"; then
    nc=/usr/local/aw/bin/nsdchat
else
    nc=$AWPST_HOME/bin/nsdchat
fi
if test ! -x $nc; then
    echo "$0: $nc is not an executable"
    exit 1
fi

#
# Check the operation.
#

task="$1"
if test "$task" != "archive" -a "$task" != "restore"; then
    usage
fi

#
# Check the name of the Archive plan to use
# Bail-out if the plan is missing
#

shift
aplan="$1"
dummy=`$nc -c ArchivePlan $aplan describe`
if test $? -ne 0; then
    echo "$0: archive plan $aplan not found"
    exit 1
fi

#
# Refuse to work when no files given
#

shift
if test "$#" -eq 0; then
    echo "$0 no files to $task"
    exit 1
fi

#
# Now do the archive or restore task
#

case $task in
    archive)
        # Create archive selection object
        as=`$nc -c ArchiveSelection create localhost $aplan`
        if test $? -ne 0; then
            clierr
        fi
        # Add files to it
        adfile=0
        for file do
            if test ! -r "$file"; then
                echo "$0: $file: no such file"
            elif test ! -f "$file"; then
                echo "$0: $file: not a plain file"
            else
                aentry=`$nc -c ArchiveSelection $as addentry "{$file}"`
                if test $? -ne 0; then
                    clierr
                fi
                adfile=`expr $adfile + 1`
            fi
        done
        # Submit archive job
        if test $adfile -eq 0; then
            echo "$0: no files selected for $task"
        else
            jobid=`$nc -c ArchiveSelection $as submit 1`
            if test $? -ne 0; then
                clierr
            fi
        fi
    ;;

    restore)
        # Get the database for the given plan
        dbase=`$nc -c ArchivePlan $aplan database`
        if test $? -ne 0; then
            clierr
        fi
        # Create restore selection object
        rs=`$nc -c RestoreSelection create localhost`
        if test $? -ne 0; then
            clierr
        fi
        # Add files to it
        for file do
            aentry=`$nc -c ArchiveEntry handle localhost "{$file}" $dbase`
            if test $? -ne 0; then
                clierr
            fi
            apath=`$nc -c RestoreSelection $rs addentry $aentry`
            if test $? -ne 0; then
                clierr
            fi
        done
        # Submit the restore job
        jobid=`$nc -c RestoreSelection $rs submit 1`
        if test $? -ne 0; then
            clierr
        fi
    ;;
esac

exit 0
