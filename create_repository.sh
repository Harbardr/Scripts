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

function template_authz
{
    OUTFILE="$1/conf/authz"         # Name of the file to generate.
    TEMPLATE="$2"
    PROJECT_TEMPLATE="$3"
    LEAD_TEMPLATE="$4"
    SUB_TEMPLATE="$5"
    LEAD_TEMPLATE="\\&${LEAD_TEMPLATE//,/,\\&}"
    SUB_TEMPLATE="\\&${SUB_TEMPLATE//,/,\\&}"
    USERS_FILE="$6"
    
    cp $TEMPLATE $OUTFILE
    if [ -f "$OUTFILE" ]; then
        echo -e "creating file: \e[92m\"$OUTFILE\"\e[0m"
    else
        echo -e "\e[92mProblem\e[0m in creating file: \e[91m\"$OUTFILE\"\e[0m"
    fi
    sed -i "s/PROJECT_TEMPLATE/$PROJECT_TEMPLATE/g" $OUTFILE
    sed -i "s/LEAD_TEMPLATE/$LEAD_TEMPLATE/g" $OUTFILE
    sed -i "s/SUB_TEMPLATE/$SUB_TEMPLATE/g" $OUTFILE
    sed -e '/USERS_LIST/ {' -e "r $USERS_FILE" -e 'd' -e '}' -i $OUTFILE
}

function usage
{
    echo "usage: create_repository [[[-r repository ] [-i]] | [-h]]"
    man "./manpage"
    echo ""
}

function structure_repository 
{
    local url=http://$1
    echo -e "Creation of the repository [\e[92m$3\e[0m] structure at [\e[92m$url\e[0m]"
    if [ -n "$4" ]; then
        #echo -e "[\e[92m$4\e[0m]"
        if [ $4="biomdev" ]; then
                svn mkdir "$url/$2/trunk" "$url/$2/branches" "$url/$2/tags" \
                -m "Creating basic directory \e[92;4mbiomdev\e[0;24m structure [trunk, tags, branches]" --parents
        elif [ $4="datadev" ]; then
                svn mkdir "$url/$2/trunk" "$url/$2/branches" "$url/$2/tags" \
                -m "Creating basic directory \e[92;4mdatadev\e[0;24m structure [trunk, tags, branches]" --parents
        elif [ $4="data" ]; then
                echo -e "[\e[92m$4\e[0m]"
                svn mkdir "$url/$2/trunk" "$url/$2/branches" "$url/$2/tags" \
                "$url/$2/trunk/data_base" "$url/$2/trunk/data_base/edc" "$url/$2/trunk/data_base/lock" "$url/$2/trunk/data_base/main" "$url/$2/trunk/data_base/pgm" \
                "$url/$2/trunk/data_cleaning" "$url/$2/trunk/data_cleaning/ec" "$url/$2/trunk/data_cleaning/listings" "$url/$2/trunk/data_cleaning/sec" \
                "$url/$2/trunk/data_coding" "$url/$2/trunk/data_coding/manual_coding" "$url/$2/trunk/data_coding/listings" "$url/$2/trunk/data_coding/pgm" \
                "$url/$2/trunk/data_edh" "$url/$2/trunk/data_edh/pgm" "$url/$2/trunk/data_edh/source" \
                "$url/$2/trunk/data_review" "$url/$2/trunk/data_review/datasets" "$url/$2/trunk/data_review/listings" "$url/$2/trunk/data_review/pgm" \
                "$url/$2/trunk/reporting" \
                "$url/$2/trunk/sae_rec" "$url/$2/trunk/sae_rec/pgm" "$url/$2/trunk/sae_rec/source" \
                -m "Creating basic directory \e[92;4mdata\e[0;24m structure [trunk, tags, branches]" --parents
        elif [ $4="statdev" ]; then
                svn mkdir "$url/$2/trunk" "$url/$2/branches" "$url/$2/tags" \
                -m "Creating basic directory \e[92;4mstatdev\e[0;24m structure [trunk, tags, branches]" --parents
        elif [ $4="stat" ]; then
                svn mkdir "$url/$2/trunk" "$url/$2/branches" "$url/$2/tags" \
                -m "Creating basic directory \e[92;4mstat\e[0;24m structure [trunk, tags, branches]" --parents
        fi
    else
        echo -e "\e[91;4mProblem\e[0;24m during creation of the Repository and subfolders."
        svn mkdir "$url/$2/trunk" "$url/$2/branches" "$url/$2/tags" \
        -m "Creating basic directory structure [trunk, tags, branches]" --parents
    fi
    
    if [ -d "$3" ]; then
        echo -e "Repository and subfolders created \e[92;4msuccessfully\e[0;24m."
    else
        echo -e "\e[91;4mProblem\e[0;24m during creation of the Repository and subfolders."
    fi
}

function change_rights
{
    echo -e "Change mod (770) [\e[92m$1\e[0m]"
    chmod 770 -R "$1"
    echo -e "Change owner (www-data) [\e[92m$1\e[0m]"
    chown www-data:www-data -R "$1"
    echo ""
}

function multiple_choice
{
    local loopUsers="0"
    type_users_list=""
    while [ "$loopUsers" -eq "0" ]; do
        local response=
        local loopList=0
        local arrayUsers=()
        while IFS='=' read -r -a input; do
            if [ -n "${input[0]}" ];then
                printf "    %s:%s(%d)\n" "${input[0]}" "${input[1]}" $loopList
                arrayUsers=("${arrayUsers[@]}" "${input[0]}")
                ((loopList+=1))
            fi
        done < "$1"
        echo -e -n "Enter your selection \e[96mSeparated by comma [,]\e[0m > "
        read response
        if [ -n "$response" ]; then
            while IFS=',' read -r -a RESP; do
                for i in "${RESP[@]}"; do
                    printf "    %d:%s\n" "$i" "${arrayUsers[((i))]}"
                    type_users_list="$type_users_list,${arrayUsers[((i))]}"
                done
            done <<< $response
            loopUsers="1"
        fi
    done
    type_users_list=${type_users_list:1}
}


##### Main
clear
interactive=1
#filename=
repository=
users_list="users.list"

echo ""
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

#if [ -n "$1" ]; then
#    interactive=1
#else
#    usage
#    exit 1
#fi

if [ -f "$users_list" ]; then
    echo -e "Users list [\e[92m$users_list\e[0m] available."
    sed -i "s/ //g" $users_list 
    echo ""
else
    echo -e "Users list [\e[91m$users_list\e[0m] not available."
    exit 1
fi


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
                    template="template_biom.authz"
                    loopDpt="1"
                    ;;
                "2" )
                    response="datadev"
                    template="template_biom.authz"
                    loopDpt="1" ;;
                "3" )
                    response="data"
                    template="template_data.authz"
                    loopDpt="1" ;;
                "4" )
                   response="statdev"
                    template="template_biom.authz"
                    loopDpt="1" ;;
                "5" )
                    response="stat"
                    template="template_stat.authz"
                    loopDpt="1" ;;
            esac
        fi
        if [ "$loopDpt"=="1" ]; then
            repositoryPath="$SVN_PARENT_PATH$response"
            echo -e "Your choice [\e[92m$repositoryPath\e[0m]."
        else
            cd -e "The choice [\e[91m$response\e[0m] don't exist."
        fi
    done

    if [ -d "$repositoryPath/$repository" ]; then
        echo -e "This repository [\e[91m$repositoryPath/$repository\e[0m] already exists."
        exit 1
    else
        svnadmin create "$repositoryPath/$repository"
        echo ""
        
        echo -e "Selection of \e[96mlead(s)\e[0m users  :"
        multiple_choice "$users_list"
        lead_users_list="$type_users_list"
        echo -e "Lead users : \e[96m$lead_users_list\e[0m"
        echo ""
        
        echo -e "Selection of \e[96msub(s)\e[0m users  :"
        multiple_choice "$users_list"
        sub_users_list="$type_users_list"
        echo -e "Sub users : \e[96m$sub_users_list\e[0m"
        echo ""
        
        echo -e "Creation of the authz file : [\e[92m$repositoryPath/$repository\e[0m]"
        template_authz "$repositoryPath/$repository" "$template" "$repository" "$lead_users_list" "$sub_users_list" "$users_list"
        echo ""
        
        change_rights "$repositoryPath/$repository"
        service apache2 restart
        echo ""
        
        if [ -d "$repositoryPath/$repository/trunk" ] || [ -d "$repositoryPath/$repository/tags" ] || [ -d "$repositoryPath/$repository/branches" ]; then
            echo -e "The repository structure [\e[91m$repositoryPath/$repository/(trunk|tags|branches)\e[0m] already exists."
            echo ""
        else
            echo -e "Creation of the repository structure [\e[96mtrunk, tags, branches\e[0m]"
            structure_repository "svn$response.vls.local" "$repository" "$repositoryPath/$repository" "$response"
            echo ""
            change_rights "$repositoryPath/$repository"
        fi

        echo ""
        echo -e "\e[1;100;4m$TIME_STAMP\e[49m\e[0m"
        echo ""
    fi
fi
exit 0
