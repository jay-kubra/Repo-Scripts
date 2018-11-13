#!/bin/bash



# script compares the time modified timestamps of DEV,TEST,PROD repos and
# outputs then in JSON it also pulls a bunch of information about the enabled
# repos and outputs that as well
#
# To run in debug mode: "DEBUG=1 ./repoinfo.sh"
################################################################################

################################################################################

# declare a new array to keep things in
declare -A REPO_ARRAY


# Make sure out JSON output/input file exists, if it doesn't we create one, if
# it does we clear all data from it
FILE=/tmp/repoinfo.json
if [ -f $FILE ]; then
   echo > $FILE
else
   touch $FILE
fi


#DEFINE REPO VARIABLES WHILE CREATING ARRAYS OF THE REPO TIMESTAMPS
################################################################################
#Creating an array of files that contain the times since the file has been last
#touched
declare -A epel
epel[test]=$(stat -c '%Y' /opt/maintenance/repos/epel/test/6/x86_64/repodata/\
*filelists.sqlite.bz2 | sort -nr | head -n 1)
epel[dev]=$(stat -c '%Y' /opt/maintenance/repos/epel/dev/6/x86_64/repodata/\
*filelists.sqlite.bz2 | sort -nr | head -n 1)
epel[prod]=$(stat -c '%Y' /opt/maintenance/repos/epel/production/6/x86_64/\
repodata/*filelists.sqlite.bz2 | sort -nr | head -n 1)

test $DEBUG && echo "Debugging enabled. Looking for "epel="${epel[@]}"""

#Creating an array of files that contain the times since the file has been last
#touched
declare -A ius
ius[test]=$(stat -c '%Y' /opt/maintenance/repos/ius/test/latest/x86_64/\
repodata/*filelists.sqlite.bz2 | sort -nr | head -n 1)
ius[dev]=$(stat -c '%Y' /opt/maintenance/repos/ius/dev/latest/x86_64/\
repodata/*filelists.sqlite.bz2 | sort -nr | head -n 1)
ius[prod]=$(stat -c '%Y' /opt/maintenance/repos/ius/production/latest/\
x86_64/repodata/*filelists.sqlite.bz2 | sort -nr | head -n 1)

test $DEBUG && echo "Debugging enabled. Looking for "ius="${ius[@]}"""

#Creating an array of files that contain the times since the file has been last
#touched
#declare -A ius7
#ius7[test]=$(stat -c '%Y' /opt/maintenance/repos/ius/test/7/x86_64/\
#repodata/*filelists.sqlite.bz2 | sort -nr | head -n 1)
#ius7[dev]=$(stat -c '%Y' /opt/maintenance/repos/ius/dev/7/x86_64/\
#repodata/*filelists.sqlite.bz2 | sort -nr | head -n 1)
#ius7[prod]=$(stat -c '%Y' /opt/maintenance/repos/ius/production/7/x86_64/\
#repodata/*filelists.sqlite.bz2 | sort -nr | head -n 1)

#Creating an array of files that contain the times since the file has been last
#touched
declare -A cnt6
cnt6[test]=$(stat -c '%Y' /opt/maintenance/repos/CentOS/test/6/os/x86_64/\
repodata/*filelists.sqlite.bz2 | sort -nr | head -n 1)
cnt6[dev]=$(stat -c '%Y' /opt/maintenance/repos/CentOS/dev/6/os/x86_64/\
repodata/*filelists.sqlite.bz2 | sort -nr | head -n 1)
cnt6[prod]=$(stat -c '%Y' /opt/maintenance/repos/CentOS/production/6/os/\
x86_64/repodata/*filelists.sqlite.bz2 | sort -nr | head -n 1)

test $DEBUG && echo "Debugging enabled. Looking for "cnt6="${cnt6[@]}"""

#Creating an array of files that contain the times since the file has been last
#touched
declare -A cnt7
cnt7[test]=$(stat -c '%Y' /opt/maintenance/repos/CentOS/test/7/os/x86_64/\
repodata/*filelists.sqlite.bz2 | sort -nr | head -n 1)
cnt7[dev]=$(stat -c '%Y' /opt/maintenance/repos/CentOS/dev/7/os/x86_64/\
repodata/*filelists.sqlite.bz2 | sort -nr | head -n 1)
cnt7[prod]=$(stat -c '%Y' /opt/maintenance/repos/CentOS/production/7/os/\
x86_64/repodata/*filelists.sqlite.bz2 | sort -nr | head -n 1)

test $DEBUG && echo "Debugging enabled. Looking for "cnt7="${cnt7[@]}"""

###############################################################################
#
#   Sample output from these arrays
#   # echo ${epel[@]}
#     1539819107 1481911940 1481911940
#
###############################################################################

###############################################################################
#
# This begins file check and calulation functions for each repo
#   NOTE: IUS7 is commented out because there is currently no version 7 setup
#   for this repo
#
###############################################################################


epel_diff () {
   # check epel repo, make sure everyone is present and accounted for!
   # if everyone is here, lets get started! we are going to compare the times on
   # these repos.
  if [ -f ${epel[dev]} ] || [ -f ${epel[test]} ] || [ ${epel[prod]}  ]; then
    epeltest_diff=$((( ${epel[dev]} - ${epel[test]})/86400 ))
    epelprod_diff=$((( ${epel[test]} - ${epel[prod]})/86400 ))

          # debug commands
    test $DEBUG && echo "Debugging enabled. Looking for epel "\
    epeltest_diff="${epeltest_diff}"""
          # check time between dev and test
    test $DEBUG && echo "Debugging enabled. Looking for epel "\
    epelprod_diff="${epelprod_diff}"""
          # check time between test and prod

  else
    # if any but of this fails, exit quick and in a hurry!
    logger -t "$(basename $"0")" "Something is wrong with one of the EPEL\
    variables"
    exit 1

  fi
}

#########################################################################
#  Sample output from the calculation statements above:
#   #test_diff=$((( ${epel[dev]} - ${epel[test]})/86400 ))
#   # echo ${test_diff}
#   670
##########################################################################


ius_diff () {
   # check epel repo, make sure everyone is present and accounted for!
   # if everyone is here, lets get started! we are going to compare the times on
   # these repos.
  if [ -f ${ius[dev]} ] || [ -f ${ius[test]} ] || [ ${ius[prod]}  ]; then
    iustest_diff=$((( ${ius[dev]} - ${ius[test]})/86400 ))
    iusprod_diff=$((( ${ius[test]} - ${ius[prod]})/86400 ))

    # debug commands
    test $DEBUG && echo "Debugging enabled. Looking for ius \
    "iustest_diff="${iustest_diff}"""
    # check time between dev and test
    test $DEBUG && echo "Debugging enabled. Looking for ius \
    "iusprod_diff="${iusprod_diff}"""
    # check time between test and prod

 else
    # if any bit of this fails, exit quick and in a hurry!
    logger -t "$(basename $"0")" "Something is wrong with one of the IUS\
    variables"
    exit 1

  fi
}

ius7-diff () {
   # check epel repo, make sure everyone is present and accounted for!
   # if everyone is here, lets get started! we are going to compare the times on
   # these repos.
  if [ -f ${ius7[dev]} ] || [ -f ${ius7[test]} ] || [ ${ius7[prod]}  ]; then
     ius7test_diff=$((( ${ius7[dev]} - ${ius7[test]})/86400 ))
     ius7prod_diff=$((( ${ius7[test]} - ${ius7[prod]})/86400 ))

    # debug commands
    test $DEBUG && echo "Debugging enabled. Looking for ius7 \
    "ius7test_diff="${test_diff}"""
    # check time between dev and test
    test $DEBUG && echo "Debugging enabled. Looking for ius7 \
    "ius7prod_diff="${prod_diff}"""
    # check time between test and prod

  else
 # if any bit of this fails, exit quick and in a hurry!
    logger -t "$(basename $"0")" "Something is wrong with one of the IUS7\
    variables"
    exit 1

  fi
}



cnt6_diff () {
   # check cnt6 repo, make sure everyone is present and accounted for!
   # if everyone is here, lets get started! we are going to compare the times on
   # these repos.
  if [ -f ${cnt6[dev]} ] || [ -f ${cnt6[test]} ] || [ ${cnt6[prod]}  ]; then
    cnt6test_diff=$((( ${cnt6[dev]} - ${cnt6[test]})/86400 ))
    cnt6prod_diff=$((( ${cnt6[test]} - ${cnt6[prod]})/86400 ))

    # debug commands
    test $DEBUG && echo "Debugging enabled. Looking for CentOS 6 test diff \
    "cnt6test_diff="${cnt6test_diff}"""
    # check time between dev and test
    test $DEBUG && echo "Debugging enabled. Looking for CentOS 6 production diff\
    "cnt6prod_diff="${cnt6prod_diff}"""
    # check time between test and prod

  else
    # if any bit of this fails, exit quick and in a hurry!
    logger -t "$(basename $"0")" "Something is wrong with one of the CentOS 6\
    variables"
    exit 1

  fi
}


cnt7_diff () {
   # check cnt7 repo, make sure everyone is present and accounted for!
   # if everyone is here, lets get started! we are going to compare the times on
   # these repos.
  if [ -f ${cnt7[dev]} ] || [ -f ${cnt7[test]} ] || [ ${cnt7[prod]}  ]; then
    cnt7test_diff=$((( ${cnt7[dev]} - ${cnt7[test]})/86400 ))
    cnt7prod_diff=$((( ${cnt7[test]} - ${cnt7[prod]})/86400 ))

    # debug commands
    test $DEBUG && echo "Debugging enabled. Looking for CentOS 7 \
    "cnt7test_diff="${cnt7test_diff}"""
    # check time between dev and test
    test $DEBUG && echo "Debugging enabled. Looking for CentOS 7 \
    "cnt7prod_diff="${cnt7prod_diff}"""
    # check time between test and prod

  else
    # if any bit of this fails, exit quick and in a hurry!
    logger -t "$(basename $"0")" "Something is wrong with one of the EPEL\
    variables"
    exit 1

  fi
}


repo_JSON () {
# first sed replaces any blank lines with --
json=$(yum -v repolist all | grep -B2 -A6 "enabled" | sed 's/^$/--/')


# read lines and add them to the array if they match
while read -r line
do
    case "${line}" in
        *Repo-name* )
            line=$(echo "${line}" | sed -e 's/^[^:]*://' | sed -e 's,^ *,,')
            REPO_ARRAY[repo_name]="${line}"
        ;;
        *Repo-id* )
            line=$(echo "${line}" | sed -e 's/^[^:]*://' | sed -e 's,^ *,,')
            REPO_ARRAY[repo_id]="${line}"
                if [ "${line}" = "ius" ]; then
                  REPO_ARRAY[repo_tstsync]=${iustest_diff}
                  REPO_ARRAY[repo_prdsync]=${iusprod_diff}
                fi
                    if [ "${line}" = "epel" ]; then
                      REPO_ARRAY[repo_tstsync]=${epeltest_diff}
                      REPO_ARRAY[repo_prdsync]=${epelprod_diff}
                    fi
                       if [ "${line}" = "base" ]; then
                         REPO_ARRAY[repo_tstsync]=${cnt6test_diff}
                         REPO_ARRAY[repo_prdsync]=${cnt6prod_diff}
                       fi
                          if [[ "${line}" != @("epel"|"ius") ]]; then
                            REPO_ARRAY[repo_tstsync]="null"
                            REPO_ARRAY[repo_prdsync]="null"
                          fi
        ;;
        *Repo-size* )
            line=$(echo "${line}" | sed -e 's/^[^:]*://' | sed -e 's,^ *,,')
            REPO_ARRAY[repo_size]="${line}"
        ;;
        *Repo-updated* )
            line=$(echo "${line}" | sed -e 's/^[^:]*://' | sed -e 's,^ *,,')
            REPO_ARRAY[repo_updated]="${line}"
        ;;
        *Repo-pkgs* )
            line=$(echo "${line}" | sed -e 's/^[^:]*://' | sed -e 's,^ *,,')
            REPO_ARRAY[repo_pkgs]="${line}"
        ;;
        *Repo-expire* )
            line=$(echo "${line}" | sed -e 's/^[^:]*://' | sed -e 's,^ *,,')
            REPO_ARRAY[repo_expire]="${line}"
        ;;
        *Repo-revision* )
            line=$(echo "${line}" | sed -e 's/^[^:]*://' | sed -e 's,^ *,,')
            REPO_ARRAY[repo_revision]="${line}"
        ;;
        *Repo-baseurl* )
            line=$(echo "${line}" | sed -e 's/^[^:]*://' | sed -e 's,^ *,,')
            REPO_ARRAY[repo_url]="${line}"
        ;;

          # if we see -- that means the end of the repo
        -- )


# https://stackoverflow.com/questions/44792241/constructing-a-json-hash-from-a-bash-associative-array

          for i in "${!REPO_ARRAY[@]}"
        do
          echo "$i"
          echo "${REPO_ARRAY[$i]}"
        done | jq -n -R 'reduce inputs as $i ({}; . + { ($i): (input|(tonumber?\
         // .)) })' >> /tmp/repoinfo.json
     esac
done <<< "$json"
}

format () {
(printf "%s" "$(</tmp/repoinfo.json)" | sed 's/}/},/g' | sed '1s/^/[ \n/' \
| sed '$s/$/\n]/' | sed 'x; ${s/.*/}/;p;x}; 1d')
}


epel_diff
ius_diff
#ius7_diff
cnt6_diff
#cnt7_diff
repo_JSON
format
