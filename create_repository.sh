#!/bin/bash

##### Constants
TITLE="SVN Repository Creation"
RIGHT_NOW=$(date +"%x %r %Z")
TIME_STAMP="Updated on $RIGHT_NOW by $USER"
SVN_PARENT_PATH="/mnt/biomsvn/"

##### Functions
function conf_authz
{
    OUTFILE="$1/conf/authz"         # Name of the file to generate.
    rm $OUTFILE
    # ----------------------------------------------------------
    # 'The document containing the body of the authz.
    (
    cat <<- _EOF_
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
_EOF_
    ) > $OUTFILE
    # -----------------------------------------------------------
    #  Quoting the 'limit string' prevents variable expansion
    #+ within the body of the above 'here document.'
    #  This permits outputting literal strings in the output file.
    if [ -f "$OUTFILE" ]; then
        #chmod 770 $OUTFILE
        echo "creating file: \"$OUTFILE\""
        #ls -al "$1/conf"
    # Make the generated file executable.
    else
        echo "Problem in creating file: \"$OUTFILE\""
    fi
}

function usage
{
    echo "usage: create_repository [[[-r repository ] [-i]] | [-h]]"
}

function structure_repository
{
    url=http://$1
    #echo "svn mkdir $url/$2/trunk -m \"Creating basic directory structure [trunk]\" --parents"
    echo "Creating basic directory structure [trunk, tags, branches]"
    svn mkdir "$url/$2/trunk" "$url/$2/branches" "$url/$2/tags" -m "Creating basic directory structure [trunk, tags, branches]" --parents
    #svn mkdir $url/$2/trunk -m "Creating basic directory structure [trunk]" --parents
    #echo "svn mkdir $url/$2/branches -m \"Creating basic directory structure [tags]\" --parents"
    #svn mkdir $url/$2/branches -m "Creating basic directory structure [tags]" --parents
    #echo "svn mkdir $url/$2/tags -m \"Creating basic directory structure [branches]\" --parents"
    #svn mkdir $url/$2/tags -m "Creating basic directory structure [branches]" --parents
}

function change_rights
{
    echo "Change mod (770) [$1]"
    chmod 770 -R "$1"
    echo "Change owner (www-data) [$1]"
    chown www-data:www-data -R "$1"
    echo ""
}

##### Main
clear
interactive=1
#filename=
repository=

echo -e "\e[1;100;4m$TITLE\e[49m\e[0m"


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
    echo -e "Waiting for the repository [\e[91m$repository\e[0m] creation."
    loopDpt="0"
    while [ "$loopDpt" -eq "0" ]; do
        response=
        echo "Select the department : "
        echo "    biomdev (1)"
        echo "    datadev (2)"
        echo "    data    (3)"
        echo "    statdev (4)"
        echo "    stat    (5)"
        echo -n "Enter your choice > "
        read response
        if [ -n "$response" ]; then
            case $response in
                "1" )
                    response="biomdev"
                    loopDpt="1"
                    ;;
                "2" )
                    response="datadev"
                    loopDpt="1" ;;
                "3" )
                    response="data"
                    loopDpt="1" ;;
                "4" )
                   response="statdev"
                    loopDpt="1" ;;
                "5" )
                    response="stat"
                    loopDpt="1" ;;
            esac
        fi
        if [ "$loopDpt"=="1" ]; then
            repositoryPath="$SVN_PARENT_PATH$response"
            echo "Your choice [\e[91m$repositoryPath\e[0m]."
        else
            cd "The choice [\e[91m$response\e[0m] don't exist."
        fi
        #echo "$loopDpt"
    done

    #responseRepo=
    #echo -n "Enter the name of the [$repository] > "
    #read responseRepo
    #if [ -n "$responseRepo" ]; then
    #    repository=$responseRepo
    #fi

    if [ -d "$repositoryPath/$repository" ]; then
        echo "This repository [$repositoryPath/$repository] already exists."
        exit 1
    else
        echo "Creation of the repository [$repositoryPath/$repositoryyy]"
        svnadmin create "$repositoryPath/$repository"
        echo ""
        #cd "$repositoryPath/$repository"
        #svn mkdir trunk tags branches
        #svn commit -m"Creating basic directory structure"
        #cd "/"
        
        echo "Creation of the authz file : [$repositoryPath/$repository]"
        conf_authz "$repositoryPath/$repository" "$repository"
        echo ""
        
        change_rights "$repositoryPath/$repository"
        service apache2 restart
        echo ""
        
        echo "Creation of the repository structure [trunk, tags, branches]"
        structure_repository "svn$response.vls.local" "$repository"
        echo ""
        
        change_rights "$repositoryPath/$repository"
        
        echo "Repository and subfolders created successfully."
        echo ""
        echo "$TIME_STAMP"
    fi
fi
exit 0
