#!/bin/bash

min_cpu="20"
min_mem="15"
file="1"

host_list=`netgrouplist  linux-login-sys`

if [ ! -d ./temp ] ; then
    mkdir temp
fi
rm last_runaways.txt
eval `ssh-agent`
ssh-add 
echo -e "\e[1;31m*** THIS SCRIPT ONLY WORKS WITH NO-PASSPHRASE SSH KEYS ON ALL HOSTS ***"
sleep 1
echo -e "\e[1;36mWelcome to Synt4x's runaway script."
sleep 2
echo -e "\e[1;36mPlease note that the information output by this script is easiest to read in a fullscreen Terminal window."
sleep 2
echo -e "\e[1;32mEvaluating hosts. Please wait...\e[0;37m"

check ()
{
    echo -e "${i}\n"
    ssh -o ConnectTimeout=5 $1@$2 ps -A -o user,pid,pcpu,pmem,tty,time,comm \
        | awk -v min_cpu=$3 -v min_mem=$4 '{ if($3 > min_cpu || $4 > min_mem){ 
    print "USER      PID     CPU    MEM    TTY    TIME        COMMAND" ; 
    printf "%-9s %-7s %-6s %-6s %-6s %-11s %s\n", $1, $2, $3, $4, $5, $6, $7 ; }}'
    ssh -o ConnectTimeout=5 $1@$2 "echo 'Uptime is: '; uptime"
    #echo $BASHPID >> pid.txt
}

# Subshell monitoring is not working yet...
#isRunning ()
#{
#    cat pid.txt | while read pid
#    do
#        if [[ $(ps -A | grep ${pid}) -ne 1 ]] ; then
#            return 0
#        fi
#    done
#    return 1
#}

for i in $host_list
do
    echo -ne "\n---------------------------------------------------------------------------------------\n" > ./temp/${i}.txt
    ( ( check $USER $i $min_cpu $min_mem ) >> ./temp/${i}.txt ) &
done

#while isRunning
#do
#    sleep .1
#done

sleep 10
cat ./temp/*.txt > last_check.txt
cat last_check.txt
echo -e "\n\e[1;36m^ Host information"
echo -e "\e[1;32mv Potential \e[1;31mrunaway processes\e[0;37m\n"
grep -A1 "USER" ./temp/*.txt > last_runaways.txt
rm ./temp/*.txt
if [ -s last_runaways.txt ] ; then
    cat last_runaways.txt
else
    echo -e "\e[1;31mNo processes to display.\e[0;37m"
fi

echo -e "\n\e[1;32mScroll up for \e[1;36mhost information\e[1;32m.\e[0;37m\n"

kill $SSH_AGENT_PID
