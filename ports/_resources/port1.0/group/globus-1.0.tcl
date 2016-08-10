# -*- coding: utf-8; mode: tcl; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- vim:fenc=utf-8:ft=tcl:et:sw=4:ts=4:sts=4
# $Id$
#
# Copyright (c) 2012-2013 The MacPorts Project
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. Neither the name of The MacPorts Project nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#
# This PortGroup sets up default behaviors for Globus Toolkit components.
#
# Usage:
#
#   PortGroup               globus 1.0
#
#   name
#   version
#
#   globus.setup
#
# Optional
#
#   globus.perl          yes/[no]
#   globus.description   <Short component description>
#

categories          net devel sciences
license             Apache-2
homepage            http://www.globus.org/


# TODO: revise the way descriptions are handled
# 
# configure.post_args \
# --with-docdir='\${datadir}/doc/${name}-${version}'


description         Globus Toolkit -
long_description    \
    The Globus Toolkit is an open source software toolkit used for building \
    Grid systems and applications. It is being developed by the \
    Globus Alliance and many others all over the world. A growing number of \
    projects and companies are using the Globus Toolkit to unlock the \
    potential of grids for their cause.

depends_build       port:pkgconfig


# TESTING!
# this would put all header files into a separate globus dir
# (not $prefix/include/globus/gssapi.h )
configure.post_args \
    --includedir=${prefix}/include/globus

# TODO: +doc variant would be nice
# currently there is no way to control the creation of devel documentation
default_variants +doc

variant doc description {Add developer documentation} {
    depends_build-append    port:doxygen

    # This option is currently not available
    #configure.post_args-append \
    #    --enable-doxygen
}


options globus.tk_major
default globus.tk_major 6

proc globus_get_package_name {} {
    return [string map {"-" "_"} [option name] ]
}

options globus.package globus.version 

proc globus.setup {} {
    global name version master_sites distname
    global globus.package globus.version globus.tk_major

    globus.package  [globus_get_package_name]
    globus.version  ${version}             

    distname        ${globus.package}-${globus.version}

    # GT 6
    master_sites    http://www.globus.org/ftppub/gt${globus.tk_major}/packages/

    livecheck.type  regex
    livecheck.url   ${master_sites}
    livecheck.regex ">${globus.package}-(\[.\\d\]+)\\.tar\\.gz<"
}


# description
options globus.description
option_proc globus.description globus_set_description

proc globus_set_description {option action args} {
    global globus.description globus.package

    if {$action != "set"} {
        return
    }

    if {$args ne ""} {
        description-append \
            ${globus.description}

        long_description-append \
            The Globus package `[globus_get_package_name]` contains \
            the ${globus.description}.
    }
}


# Perl
options globus.perl
default globus.perl     no
option_proc globus.perl globus_set_perl

proc globus_set_perl {option action args} {
    global perl5.branches perl5.bin perl5.lib

    if {$action != "set"} {
        return
    }

    if {$args} {

        PortGroup               perl5 1.0

        perl5.require_variant   yes
        perl5.conflict_variants yes
        perl5.branches          5.22
        perl5.create_variants   ${perl5.branches}

        configure.env-append  \
            PERL=${perl5.bin} \
            GLOBUS_SH_PERL=${perl5.bin}

        configure.post_args-append \
            --with-perlmoduledir=${perl5.lib}
    }
}
