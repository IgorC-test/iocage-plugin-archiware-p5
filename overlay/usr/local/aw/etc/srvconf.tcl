
##############################################################################
#
# srvconf.tcl --
#
#    Server startup and configuration procedure. This procedure is
#    executed at server startup only. Therefore only limited server
#    command-set is available.
#    It should not be necessary to modify this file. Additional server
#    parameters can be set and/or overriden in file located in the
#    config/<server_name>.<server_port> per-server configuration file.
#
# See the file "license.txt" for information on usage and
# redistribution of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
##############################################################################


#
# These two variables configure the control-port access information.
# You can declare only one control-port user.
#
# You may choose to set this file to be viewed by the system privileged
# user (root) in order to keep the control-port user password secret.
#
# The control port listens at the address (web-port+1000). If you setup
# the webport to 8000 (the default setup) the control port will be set
# to 9000. Note: only localhost connects are allowed to the control-port.
#
# If you want to enable control-port access, uncomment the two following
# lines by removing the '#' sign from the beginning of each relevant line.
#

  set admin_user "nsadmin"
  set admin_pass "x"

#
# Generic server configuration procedure. Generally, you should not
# change anything below, unless instructed by Archiware tech-support.
#

proc srvconf {args} {

    global server name admin_user admin_pass

    #
    # This is the name of the current configuration file.
    # We assume several things about it's name and location.
    # The current configuration file must be:
    #
    #     - located under <server_home>/config/ directory
    #     - named like <server_name>.<http_port>
    #

    set cf [ns_info config]

    #
    # Change to directory where the configuration file is stored.
    # We must do this in order to obtain it's absolute path.
    #

    set cwd [pwd]; cd [file dirname $cf]
    set cfd [pwd]; cd $cwd

    #
    # Assuming above, server's home must be one directory
    # level above current configuration file directory.
    #

    set home [file dirname $cfd]

    #
    # With little arithmetic, we obtain the server name
    # and it's default http port. The control port is
    # calculated below using current httpport + 1000.
    #

    set server   [lindex [split [file tail $cf] "."] 0]
    set httpport [lindex [split [file tail $cf] "."] 1]

    #
    # Test directory structure and create it if needed.
    #

    foreach dir {
        pages modules modules/tcl modules/nslog modules/nsssl
    } {
        file mkdir $home/servers/$server/$dir
    }

    #
    # Global server parameters. There are myriad of server-related
    # parameters which one can put here. We use defaults for most,
    # and explicitly set only very few of them.
    #

    ns_section ns/parameters

    ns_param schedmaxelapsed  30
    ns_param home             $home
    ns_param pidfile          log/$server.pid
    ns_param logroll          true
    ns_param serverlog        log/$server.log
    ns_param tcllibrary       modules/tcl
    ns_param sanitizelogfiles false

    #
    # Rotate server log file per hand. It is really
    # tempting to use ns_logroll here but it will
    # not work always.
    #

    ns_rollfile $home/log/$server.log 365

    #
    # Empirically determined minimum thread stacksize.
    # This is also the maximum value for Darwin.
    #

    ns_section ns/threads
    ns_param stacksize [expr 512 * 1024]

    #
    # MIME types. You can extend this section by adding additional
    # "ns_param" lines giving link between the file extension and
    # the corresponding mime type, like: ns_param ".gif" "image/gif".
    # Server has a reasonable number of common types already built-in.
    #

    ns_section ns/mimetypes

    ns_param noextension "*/*"
    ns_param default     "*/*"

    #
    # Supported servers.
    #

    ns_section ns/servers
    ns_param $server $server

    #
    # Server-specific parameters. There are myriad of server-related
    # parameters which one can put here. We use defaults for most.
    #

    ns_section ns/server/$server

    ns_param directoryfile  index.adp,index.html,index.htm
    ns_param globalstats    false
    ns_param urlstats       false
    ns_param maxconnections 128
    ns_param maxthreads     128
    ns_param threadtimeout  180
    ns_param maxpost        [expr {1024 * 1024 * 1024}]

    ns_section ns/server/$server/tcl
    ns_param library  servers/$server/modules/tcl
    ns_param initfile lib/init.tcl

    #
    # Limit GUI handling threads per module.
    # Unfortunately, modules load too late
    # and there is no config-options there we
    # can modify, so we must do it here.
    #

    ns_section ns/server/$server/pools
    ns_param gui "GUI-service"

    ns_section ns/server/$server/pool/gui
    ns_param map "POST /login"
    ns_param map "GET  /login"
    ns_param map "POST /lexxapp"
    ns_param map "GET  /lexxapp"
    ns_param maxthreads 1
    ns_param minthreads 1
    ns_param threadtimeout 180

    #
    # Socket driver module parameters.
    #

    if {![info exists httpport]} {
        set httpport 8000
        set httpsport 8443
    } else {
        set httpsport [expr {$httpport + 443}]
    }

    ns_section ns/server/$server/module/nssock
    ns_param maxinput [expr {1024 * 1024 * 1024}]
    ns_param hostname [ns_info hostname]
    ns_param address 0.0.0.0
    ns_param port $httpport
    ns_param spoolerthreads 1

    #
    # HTTPS driver module parameters.
    #

    if {[file exists $home/config/$server.pem]} {
        set cert $home/config/$server.pem
    } else {
        set cert servers/$server/modules/nsssl/server.pem
    }

    ns_section ns/server/$server/module/nsssl
    ns_param certificate $cert
    ns_param maxinput [expr {1024 * 1024 * 1024}]
    ns_param hostname [ns_info hostname]
    ns_param address 0.0.0.0
    ns_param port $httpsport
    ns_param spoolerthreads 1

    #
    # Adjust default cache parameters for fastpath module.
    # Notice that same parameters are used for nsx_cache.
    #

    ns_section ns/server/$server/fastpath
    ns_param pagedir servers/$server/pages
    ns_param mmap true
    ns_param cache true
    ns_param cachemaxentry [expr {4096 * 1024}]

    #
    # Load shared objects and tcl modules.
    #

    ns_section ns/server/$server/modules
    set so [info sharedlibext]

    switch -glob -- $::tcl_platform(os) {
        Linux - Darwin - SunOS - FreeBSD {
            foreach lib {
                libarchdev
                libchanstack
                libcodebase
                libdnssd
                libfse
                libsv
                libtea
                libthread
                libtdp
                libnsx
                libuser
                libvolume
                libvss
                libxcmds
                libyajltcl
                libzzip
            } {
                ns_param $lib $lib$so
            }
            foreach mod {
                nscp
                nslog
                nsproxy
                nssock
                nsssl
            } {
                ns_param $mod $mod.so
            }
        }
        Windows* {
#nsssl
#nsproxy
            foreach lib {
                nscp
                nslog
                nssock
                nsx
                tcl_archdev
                tcl_chanstack
                tcl_codebase
                tcl_fse
                tcl_sv
                tcl_tea
                tcl_user
                tcl_volume
                tcl_winperms
                tcl_xcmds
                tcl_zzip
                tdom
                thread
                yajl
            } {
                ns_param $lib $lib$so
            }
        }
        default {
            error "unsupported platform: $::tcl_platform(os)"
        }
    }

    foreach dir [list $home/modules/tcl $home/servers/$server/modules/tcl] {
        foreach file [lsort [glob -nocomplain -directory $dir *]] {
            if {[file isdirectory $file]} {
                ns_param [file tail $file] tcl
            }
        }
    }

    #
    # Declare Tcl C-level modules which have
    # not (yet) been converted to NaviServer.
    #

    ns_section ns/server/$server/tclclibs

    foreach {libname libfile} {
        Nsf nsf Sqlite3 sqlite Tls tls
    } {
        ns_param $libname lib${libfile}[info sharedlibextension]
    }

    #
    # Control port parameters
    #

    ns_section ns/server/$server/module/nscp
    ns_param address 127.0.0.1

    if {![info exists ctrlport]} {
        ns_param port [expr {$httpport+1000}]
    } else {
        ns_param port $ctrlport
    }

    #
    # Control port user and password
    #
    #

    if {[info exists admin_user] && [info exists admin_pass]} {
        ns_section ns/server/$server/module/nscp/users
        ns_param user $admin_user:[ns_crypt $admin_pass ab]:
    }

    #
    # Access log parameters.
    #

    ns_section ns/server/$server/module/nslog

    ns_param maxbackup 7
    ns_param rollhour 0
    ns_param rolllog true
    ns_param rollonsignal true

    #
    # ADP (AOLserver Dynamic Page) parameters.
    # Note that we don't use ADP's but if we
    # don't declare it, we get the ugly message!
    #

    ns_section ns/server/$server/adp
    ns_param map /*.adp
}

#
# Now, run the configurator procedure
#
srvconf

# EOF $RCSfile: srvconf.tcl,v $
