#!/bin/bash

##### Constants
TITLE="SVN Repository Creation"
RIGHT_NOW=$(date +"%x %r %Z")
TIME_STAMP="Updated on $RIGHT_NOW by $USER"
SVN_PARENT_PATH="/mnt/biomsvn/"

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

function conf_authz
{

    OUTFILE="$1/conf/authz"         # Name of the file to generate.


    # -----------------------------------------------------------
    # 'Here document containing the body of the generated script.
    (
    cat <<- EOF
    [aliases]
    jfern = julien.fernandez
    hsantinjanin = hugues.santinjanin
    acosta = adeline.costa
    alari = alberth.lari
    atourneroche = alice.tourneroche
    danbarasu = dhiwakar.anbarasu
    epauwels = elodie.pauwels
    faubin = francois.aubin
    iackermann = isabelle.ackermann
    lhannouche = linda.hannouche
    mmonnereau = magalie.monnereau
    chariz = cleo.hariz
    nbraquet = nelly.braquet
    smainard = sandrine.mainard

    [groups]
    stat = &hsantinjanin,&atourneroche,&faubin,&nbraquet
    data = &jfern,&acosta,&alari,&danbarasu,&faubin,&iackermann,&lhannouche,&chariz,&mmonnereau,&smainard
    all = &jfern,&acosta,&alari,&danbarasu,&faubin,&iackermann,&lhannouche,&chariz,&mmonnereau,&hsantinjanin,&atourneroche,&nbraquet,&smainard

    [/]
    * = r
    &jfern = rw
    &hsantinjanin = rw

    [$2:/]
    * =
    &jfern = rw
    &hsantinjanin = rw

    [$2:/trunk]
    * =
    &jfern = rw
    &hsantinjanin = rw

    [$2:/tags]
    * =
    &jfern = rw
    &hsantinjanin = rw

    [$2:/branches]
    * =
    &jfern = rw
    &hsantinjanin = rw
    EOF
    ) > $OUTFILE

    # -----------------------------------------------------------

    #  Quoting the 'limit string' prevents variable expansion
    #+ within the body of the above 'here document.'
    #  This permits outputting literal strings in the output file.

    if [ -f "$OUTFILE" ]; then
        chmod 770 $OUTFILE
    # Make the generated file executable.
    else
        echo "Problem in creating file: \"$OUTFILE\""
    fi
}


function usage
{
    echo "usage: create_repository [[[-r repository ] [-i]] | [-h]]"
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
    echo "Select the department : "
    echo "    biomdev (1)"
    echo "    datadev (2)"
    echo "    data    (3)"
    echo "    statdev (4)"
    echo "    stat    (5)"
    echo -n "Enter your choice > "
    read response
    if [ -n "$response" ] && ([ "$response" = "1"] || [ "$response" = "2" ] || [ "$response" = "3" ] || [ "$response" = "4" ] || [ "$response" = "5" ]); then
        repositoryPath="$SVN_PARENT_PATH$response"
    fi

    response=
    echo -n "Enter the name of the [$repository] > "
    read response
    if [ -n "$response" ]; then
        repository=$response
    fi

    if [ -d "$repositoryPath/$repository" ]; then
        echo "Repository already exists."
    else
        echo "Creation of the repository"
        svn create $repository
        echo "Creation of the authz file : [$repositoryPath/$repository]"
        conf_authz $repository "$repositoryPath/$repository"
        echo "Change mod (770) for the repository"
        chmod 770 -R "$repositoryPath/$repository"
        echo "Change owner (www-data) to the repository"
        chown www-data:www-data -R "$repositoryPath/$repository"
        
    fi
fi
