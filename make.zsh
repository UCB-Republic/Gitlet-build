#! /usr/bin/env zsh

# Copyright 2015 Chen Ruichao <linuxer.sheep.0x@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# ==================== config ====================
jarname=gitlet.jar

# examples:
#   abc/def         use abc/def.source to generate regular file abc/def
#   abc/def/        use abc/def.source to generate directory abc/def
meta=(
    #gitlet/exceptions/
)

# ==================== preparation ====================
if [[ ! $PWD/ = */proj2/* ]]; then
    # Although we can guess from $0, it's: 1. not always doable; 2. too much
    # coding for an unimportant feature; 3. not strict enough
    echo "This script must be run in proj2's directory tree" >&2
    exit 2
fi

until [[ $PWD = */proj2 ]] { cd .. }    # doesn't always work

set -o NULL_GLOB

# ==================== subroutines ====================
function clean-jar {
    [[ -f $jarname ]] || return 0
    echo "Removing $jarname"
    rm -- $jarname
}

function clean-class {
    echo 'Removing *.class'
    local f
    for f in **/*.class; {
        rm -- $f || return
    }
}

function clean-generated-code {
    local f
    for f in $meta; {
        if [[ $meta = */ ]] {
            [[ -d $f ]] || continue
        } else {
            [[ -f $f ]] || continue
        }
        echo "Removing $f"
        rm -r -- $f || return
    }
}

function generate-code {
    local f tmp
    for f in $meta; {
        echo "Generating $f"
        if [[ $meta = */ ]] {
            # cd $f doesn't always work
            tmp=${f:0:-1}
            [[ -d $f ]] && { rm -r $f || return }
            { mkdir $f && (cd $f && ../${tmp##*/}.source) } || return
        } else {
            ./$f.source > $f || return
        }
    }
}

# compile all .java files, whether needed or not
# javac(1) doesn't seem to recompile when file is up to date, but I'm still
# not sure if classes will be repeatedly processed.
function check-compile {
    local tmpd
    tmpd=$(mktemp --tmpdir -d Gitlet.build.XXXXXXXXXX) || return
    echo 'Checking compilation'
    for f in **/*.java; {
        javac -d $tmpd $f || return
    }
}

# not used
function compile-in-place {
    echo 'Compiling'
    javac Gitlet.java
}

function compile-and-package {
    local tmpd
    tmpd=$(mktemp --tmpdir -d Gitlet.build.XXXXXXXXXX) || return
    echo "Compiling into tmp dir"
    javac -d $tmpd Gitlet.java || return
    echo "Packaging into $jarname"
    # create package $jarname, with Gitlet.main as entry point
    jar cfe $jarname Gitlet -C $tmpd . && rm -r -- $tmpd
}

# ==================== main ====================
# args
(( $# <= 1 )) || exit 2
target=${1-build}

case $target in
    build)
        clean-jar && generate-code && compile-and-package
        ;;

    submit) # prepare for submission
        clean-jar && generate-code
        ;;

    clean)
        clean-jar && clean-class && clean-generated-code
        ;;

    check)
        generate-code && check-compile
        ;;

    gen)
        generate-code
        ;;

    *)
        echo "Unknown target: $target" >&2
        exit 2
        ;;
esac
