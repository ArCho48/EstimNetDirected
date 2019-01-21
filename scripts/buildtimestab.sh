#!/bin/sh
#
# File:    buildtimestab.sh
# Author:  Alex Stivala
# Created: September 2013
#
#
# Build table for reading into R of elapsed times of snowball esitmation
# 
# Usage: buildtimestab.sh joboutputroot
#
# E.g.:
#   buildtimestab.sh  ~/snowball_estimations_kstart_n5000
#
# Output is to stdout with column for sample and total elapsed time (seconds)
#
# Uses various GNU utils options on  echo, etc.

PATH=$PATH:`dirname $0`

if [ $# -ne 1 ]; then
    echo "usage: $0 joboutputrootdir" >&2
    exit 1
fi

joboutputroot=$1

echo "# Generated by: $0 $*"
echo "# At: " `date`
echo "# On: " `uname -a`

echo -e "sampleId\telapsedTime\tnodeCount"
for outfile in ${joboutputroot}/sample*/slurm-*.out
do
    sampledir=`dirname ${outfile}`
    sampleid=`basename "${sampledir}" | sed 's/sample//g'`
    networkfile=${sampledir}/network.txt
    networkedgefile=${sampledir}/arclist.txt
    if [ -f ${networkfile} ]; then 
      nodecount=`cat ${networkfile} | grep -v '^$' |wc -l`
    elif [ -f ${networkedgefile} ]; then
      nodecount=`cat ${networkedgefile} | grep -i '^*Vertices'| awk '{print $2}'`
    else
      nodecount="NA"
    fi
    echo -e -n "${sampleid}\t"
    sumtimes.sh -s $outfile
    echo -e -n "\t${nodecount}"
    echo
done
