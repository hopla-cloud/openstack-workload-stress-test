#!/bin/bash
# Script Version 1.0 (11-02-2019)
# Written by jskandera@iilyo.com

# check if we are root or not
WHOISIT=`whoami`
[ $WHOISIT != 'root' ] && echo "Ce script doit être lancé avec sudo." && exit 1

# CheckArg
if [[ -n $2 ]]
then
        [ $2 == 0 ] && echo "<args> ne peut etre 0." && exit 1
fi


### Stress IO ###

# FIO read
function stress_io_r {
	size=$1\G
	sync
	fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --filename=test --bs=4k --iodepth=64 --size=$size --readwrite=randread --output-format=json --output=output-io-r.json
}
# FIO write
function stress_io_w {
	size=$1\G
	sync
	fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --filename=test --bs=4k --iodepth=64 --size=$size --readwrite=randwrite --output-format=json --output=output-io-w.json
}
# FIO read-write
function stress_io_rw {
	size=$1\G
	sync
	fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --filename=test --bs=4k --iodepth=64 --size=$size --readwrite=randrw --rwmixread=75 --output-format=json --output=output-io-rw.json
}

### Stress CPU ###

function stress_cpu {
	time=$1\s
	stress-ng --cpu 2 --timeout $time
}

### Stress RAM ###

function stress_ram {
	time=$1\s
	stress-ng --vm 2 --vm-bytes 700M --timeout $time
}

### Stress Network ###

function stress_net {
	time=$1\s
	iperf3 -c 192.168.0.101 -t $time -J | jq '.end.streams[0]' > output-net.json
}

case $1 in
        io-r)
			if [[ -n $2 ]]
			then
					stress_io_r $2
					exit 0
			else
				echo "Erreur : Vous devez indiquer une taille en Go."
				exit 1
			fi
        ;;

        io-w)
			if [[ -n $2 ]]
			then
					stress_io_w $2
					exit 0
			else
				echo "Erreur : Vous devez indiquer une taille en Go."
				exit 1
			fi
        ;;

        io-rw)
			if [[ -n $2 ]]
			then
					stress_io_rw $2
					exit 0
			else
				echo "Erreur : Vous devez indiquer une taille en Go."
				exit 1
			fi
        ;;
		
        cpu)
			if [[ -n $2 ]]
			then
					stress_cpu $2
					exit 0
			else
				echo "Erreur : Vous devez indiquer une durée en secondes."
				exit 1
			fi
        ;;
		
        ram)
			if [[ -n $2 ]]
			then
					stress_ram $2
					exit 0
			else
				echo "Erreur : Vous devez indiquer une durée en secondes."
				exit 1
			fi
        ;;
		
        net)
			if [[ -n $2 ]]
			then
					stress_net $2
					exit 0
			else
				echo "Erreur : Vous devez indiquer une durée en secondes."
				exit 1
			fi
        ;;

        *)
		echo -e "Usage : $0 <type> <args>\n---\n$0 io-r <args>\n$0 io-w <args>\n$0 io-rw <args>\n <args> en Go\n\n---\n$0 cpu <args> en secondes\n\n---\n$0 ram <args> en secondes\n\n---\n$0 net <args> en Go\n"
		exit 1
        ;;
esac
