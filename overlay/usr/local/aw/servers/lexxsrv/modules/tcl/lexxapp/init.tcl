##############################################################################
#
# init.tcl --
#
#    P5 application module initialization procedure.
#
#    See the file "license.txt" for information on usage and
#    redistribution of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
#    Rcsid: @(#)$Id: init.tcl,v 1.39 2015/01/01 20:49:40 jd Exp $
#
##############################################################################

namespace eval [file tail [file dirname [info script]]] {

    set nsp  [namespace current]
    set ctx /[namespace tail $nsp]
 
    #
    # Load this module and register at login module.
    #

    utility::modload $ctx $nsp
    set mid [login::register $ctx $nsp \
                 -indexpage start.tdp  -errorpage error.tdp]

    #
    # Register per/post page handlers. 
    #
    
    login::prepage $mid \
        prePageProcCommon

    login::prepage $mid \
        prePageProcWorkspace browser_filelist.tdp

    login::prepage $mid \
        prePageProcWorkspace browser_b2go.tdp

    login::prepage $mid \
        prePageProcWorkspace browser_index.tdp

    login::prepage $mid \
        prePageProcWorkspace browser_fuse.tdp

    login::prepage $mid \
        prePageProcRessource browser_ressource.tdp

    login::prepage $mid \
        prePageProcElement new_element.tdp

    login::prepage $mid \
        prePageProcElement info_*

    login::prepage $mid \
        prePageProcElement application/File*

    login::prepage $mid \
        prePageProcElement version_element/version_filelist.tdp

    login::prepage $mid \
        prePageProcElement system/BsxTree_manager.tdp

    login::prepage $mid \
        prePageProcElement system/BixTree_manager.tdp

    login::prepage $mid \
        prePageProcElement system/AsxTree_manager.tdp

    login::prepage $mid \
        prePageProcElement system/AixTree_manager.tdp

    login::prepage $mid \
        prePageProcElement application_loader/index.tdp

    login::prepage $mid \
        prePageProcElement file_picker/picker_filelist.tdp

    login::prepage $mid \
        prePageProcFilepicker getting_started/setup_assistant.tdp

    login::postpage $mid postPageProc

    #
    # Register application start handler.
    #

    login::atstart  $mid postAppStart
    login::atlogin  $mid postlogin
    login::atlogout $mid postlogout

    #
    # Initialize local configuration
    #

    if {[catch {lexxInit} err]} {
        ns_log error "cant load module for context $ctx: $err"
    }

    ns_register_proc GET /server utility::redirect /lexxapp/login
    ns_register_proc GET /admin utility::redirect /lexxapp/login

    ns_register_proc GET /user utility::redirect /lexxapp?u_app=client
    ns_register_proc GET /workstation utility::redirect /lexxapp?u_app=client
}

############################### End of file ##################################

