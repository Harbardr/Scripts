#!/bin/bash

##### Constants
TITLE="SVN Repository Creation"
RIGHT_NOW=$(date +"%x %r %Z")
TIME_STAMP="Updated on $RIGHT_NOW by $USER"

##### Functions

function system_info
{
    echo "<h2>System release info</h2>"
    echo "<p>Function not yet implemented</p>"
}   # end of system_info


function show_uptime
{
    echo "<h2>System uptime</h2>"
    echo "<pre>"
    uptime
    echo "</pre>"
}   # end of show_uptime


function drive_space
{
    echo "<h2>Filesystem space</h2>"
    echo "<pre>"
    df
    echo "</pre>"
}   # end of drive_space


function home_space
{
    # Only the superuser can get this information

    if [ "$(id -u)" = "0" ]; then
        echo "<h2>Home directory space by user</h2>"
        echo "<pre>"
        echo "Bytes Directory"
        du -s /home/* | sort -nr
        echo "</pre>"
    fi

}   # end of home_space


function write_page
{
    cat <<- _EOF_
    <html>
        <head>
        <title>$TITLE</title>
        </head>
        <body>
        <h1>$TITLE</h1>
        <p>$TIME_STAMP</p>
        $(system_info)
        $(show_uptime)
        $(drive_space)
        $(home_space)
        </body>
    </html>
_EOF_

}

function usage
{
    echo "usage: system_page [[[-f file ] [-i]] | [-h]]"
}


##### Main

interactive=
#filename=
repository=

while [ "$1" != "" ]; do
    case $1 in
        -r | --repository )     shift
                                repository=$1
                                ;;
        -i | --interactive )    interactive=1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done


# Test code to verify command line processing

if [ "$interactive" = "1" ]; then
    response=
    echo -n "Enter name of output file [$repository] > "
    read response
    if [ -n "$response" ]; then
        repository=$response
    fi

    if [ -d $repository ]; then
        echo -n "Repository already exists. Overwrite? (y/n) > "
        read response
        if [ "$response" != "y" ]; then
            echo "Exiting program."
            exit 1
        fi
    else
        echo "Creation of the repository"
        svn create $repository
        echo "Change mod (770) for the repository"
        chmod 770 -R $repository
        echo "Change owner (www-data) to the repository"
        chown www-data:www-data -R $repository
        
    fi
fi


# Write page (comment out until testing is complete)

# write_page > $filename
echo -n "Enter name of output file [$filename] > "