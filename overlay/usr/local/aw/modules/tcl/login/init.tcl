##############################################################################
#
# init.tcl --
#
#    Loader for login module. Interesting point is that this module
#    registers itself by itself recursively. This is the only module
#    whose namespace and/or context has to be known by other modules.
#
#    See the file "license.txt" for information on usage and
#    redistribution of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
#    Rcsid: @(#)$Id: init.tcl,v 1.13 2003/12/16 18:59:38 jd Exp $
#
##############################################################################

namespace eval [file tail [file dirname [info script]]] {

    set nsp  [namespace current  ]
    set ctx /[namespace tail $nsp]

    #
    # Bootstraps the module.
    #

    utility::modload $ctx $nsp
    login::register  $ctx $nsp -indexpage login
}

############################### End of file ##################################
