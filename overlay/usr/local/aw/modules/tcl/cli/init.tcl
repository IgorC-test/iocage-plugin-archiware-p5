##############################################################################
#
# init.tcl --
#
#    Loader for the CLI module. 
#
#    See the file "license.txt" for information on usage and
#    redistribution of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
##############################################################################

namespace eval [file tail [file dirname [info script]]] {

    set nsp  [namespace current  ]
    set ctx /[namespace tail $nsp]

    #
    # Bootstraps the module.
    #

    utility::modload $ctx $nsp
}

############################### End of file ##################################
