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
    #rm $OUTFILE
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
        echo -e "creating file: \e[92m\"$OUTFILE\"\e[0m"
        #ls -al "$1/conf"
    # Make the generated file executable.
    else
        echo -e "\e[92mProblem\e[0m in creating file: \e[91m\"$OUTFILE\"\e[0m"
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
    echo -e "Creation of the repository [\e[92m$repositoryPath/$repository\e[0m] structure"
    svn mkdir "$url/$2/trunk" "$url/$2/branches" "$url/$2/tags" -m "Creating basic directory structure [trunk, tags, branches]" --parents
    #svn mkdir $url/$2/trunk -m "Creating basic directory structure [trunk]" --parents
    #echo "svn mkdir $url/$2/branches -m \"Creating basic directory structure [tags]\" --parents"
    #svn mkdir $url/$2/branches -m "Creating basic directory structure [tags]" --parents
    #echo "svn mkdir $url/$2/tags -m \"Creating basic directory structure [branches]\" --parents"
    #svn mkdir $url/$2/tags -m "Creating basic directory structure [branches]" --parents
}

function change_rights
{
    echo "Change mod (770) [\e[92m$1\e[0m]"
    chmod 770 -R "$1"
    echo "Change owner (www-data) [\e[92m$1\e[0m]"
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
    echo -e "Waiting for the repository [\e[92m$repository\e[0m] creation."
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
            echo -e "Your choice [\e[92m$repositoryPath\e[0m]."
        else
            cd -e "The choice [\e[91m$response\e[0m] don't exist."
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
        echo -e "This repository [\e[91m$repositoryPath/$repository\e[0m] already exists."
        exit 1
    else
        svnadmin create "$repositoryPath/$repository"
        echo ""
        #cd "$repositoryPath/$repository"
        #svn mkdir trunk tags branches
        #svn commit -m"Creating basic directory structure"
        #cd "/"
        
        echo -e "Creation of the authz file : [\e[92m$repositoryPath/$repository\e[0m]"
        conf_authz "$repositoryPath/$repository" "$repository"
        echo ""
        
        change_rights "$repositoryPath/$repository"
        service apache2 restart
        echo ""
        
        echo -e "Creation of the repository structure [\e[96mtrunk, tags, branches\e[0m]"
        structure_repository "svn$response.vls.local" "$repository"
        echo ""
        
        change_rights "$repositoryPath/$repository"
        
        if [ -d "$repositoryPath/$repository" ]; then
            echo -e "Repository and subfolders created \e[92;4msuccessfully\e[0;24m."
        else
            echo -e "\e[91;4mProblem\e[0;24m during creation of the Repository and subfolders."
        fi
        echo ""
        echo -e "\e[1;100;4m$TIME_STAMP\e[49m\e[0m"
    fi
fi
exit 0
