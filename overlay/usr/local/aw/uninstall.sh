#!/bin/sh
#
# De-installation script.
#
# See the file "license.txt" for information on usage and
# redistribution of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# ----------------------------------------------------------------------
#

#
# Test for privileged user.
#

case `uname -s` in
  SunOS)
    id=/usr/xpg4/bin/id
    ;;
  *)
    id=/usr/bin/id
    ;;
esac

if test `$id -u` -ne 0; then
    echo "Uninstalling P5 can only be done as user root!" >&2
    exit 1
fi

#
# Get home directory
#

dir=`dirname "$0"`
cwd=`pwd`
cd "$dir"
LDIR=`pwd`; export LDIR
cd "$cwd"

#
# Test if running
#

"$LDIR/ping-server" >/dev/null 2>&1
if test $? -eq 0; then
    echo ""
    echo "NOTE: The P5 application server is still runing."
    echo "You should stop the server with \"stop-server\""
    echo "before uninstalling P5 files from this system."
    echo ""
    exit 1
fi

ans="n"
mrk=0

echo ""
echo "This script removes P5 traces from startup directories."
echo -n "Do you really like to do this (y/n) [n]: "
read ans
if test "x"$ans = "xy"; then
    mrk=1
    echo -n "Removing traces from system startup directories..."
    case `uname -s` in
        Darwin)
            rm -rf /Library/PreferencePanes/PresSTORE.prefPane
            rm -rf /Library/LaunchDaemons/com.archiware.presstore*
        ;;
        FreeBSD)
            grep -v lexx_enable /etc/rc.conf > /tmp/$$; mv /tmp/$$ /etc/rc.conf
            case "`uname -i`" in
                FREENAS*)
                    rd=/conf/base/etc/rc.d
                    rf=/conf/base/etc/rc.conf
                    if test -d $rd; then
                        rm -f $rd/lexx
                        grep -v lexx_enable $rf > /tmp/$$; mv /tmp/$$ $rf
                    fi
                ;;
            esac
            rm -f /etc/rc.d/lexx
        ;;
        Linux)
            if test -x /usr/sbin/update-rc.d; then
                /usr/sbin/update-rc.d lexx remove
            elif test -x /bin/systemctl; then
                /bin/systemctl disable lexx.service 1>/dev/null 2>&1
                rm -f /lib/systemd/system/lexx.service
            fi
            for i in 0 1 2 3 4 5 6 S; do
                if test -d /etc/rc$i.d; then
                    rm -f /etc/rc$i.d/S*lexx
                    rm -f /etc/rc$i.d/K*lexx
                elif test -d /etc/init.d/rc$i.d; then
                    rm -f /etc/init.d/rc$i.d/S*lexx
                    rm -f /etc/init.d/rc$i.d/K*lexx
                fi
            done
            rm -f /etc/init.d/lexx
        ;;
        SunOS)
            for i in 0 1 2 3 4 5 6 S; do
                if test -d /etc/rc$i.d; then
                    rm -f /etc/rc$i.d/S*lexx
                    rm -f /etc/rc$i.d/K*lexx
                fi
            done
            rm -f /etc/init.d/lexx
        ;;
    esac
    echo " done."
fi

#
# Final message
#

if test $mrk -eq 0; then
    echo ""
    echo "No actions performed, exiting."
else
    echo ""
    echo "You may now want to delete the whole directory:"
    echo ""
    echo "    \"$LDIR\""
    echo ""
    echo "This removes last traces of P5 from this system."
    echo ""
    echo "Thank you for using/evaluating P5 product."
    echo "The Archiware P5 Team (http://www.archiware.com)."
    echo ""
fi

exit 0

