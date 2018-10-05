#!/bin/sh
#

UsageMessage="Usage : $0 [-help] <test name>*

where
   -help       display this message and quit,
   <test name> is the name of a test.

If no test names are specified, all tests with differences are updated.
"

TestsDirectory="./tests"

OmniMark="${OMNIMARK:-omnimark}"

while [ $# -gt 0 ]
do
   case "$1" in
   -help)
      echo "${UsageMessage}"
      exit 1 ;;

   -*)
      echo "ERROR: Unrecognised command-line option \"$1\"."
      echo "${UsageMessage}"
      exit 1 ;;

   *)
      break ;;
   esac
done      

if [ $# -ge 1 ]
then
   TestNames=$*

else
   TestNames=`cd ${TestsDirectory} ; find . -name '*.ebnf' | sort | sed 's/^..//g' | sed 's/.ebnf$//g'`
fi

for TestName in ${TestNames}
do
   echo "========================================================================"
   echo "${TestName} ... "

   PhasesFilename="${TestsDirectory}/`dirname ${TestName}`/PHASES.TXT"

   if [ -f "${PhasesFilename}" ]
   then
      Phases=`cat "${PhasesFilename}"`

   else
      Phases="scan analyze slr lr0 lr1"
   fi

   for phase in ${Phases}
   do
      TestInput="${TestsDirectory}/${TestName}.ebnf"

      TestLog=`echo ${TestInput} | sed "s/ebnf\$/${phase}.log/"`
      TestOutput=`echo ${TestInput} | sed "s/ebnf\$/${phase}.out/"`

      for File in "${TestLog}" "${TestOutput}"
      do
         Current="${File}.current"
         Reference="${File}.reference"

         if [ ! -f "${Current}" ]
         then
            echo "${Current} doesn't exist ... skipping ..."
            continue
         fi

         if [ ! -f "${Reference}" ]
         then
            echo "${Reference} doesn't exist ... adding ..."
            cp "${Current}" "${Reference}"
            p4 add "${Reference}"

         else
            diff ${DoQuietDiff} ${Reference} ${Current} > /dev/null
         
            if [ "$?" != "0" ]
            then
               echo "Updating ${Reference} from ${Current} ..."
               p4 edit "${Reference}"
               cp "${Current}" "${Reference}"
            fi
         fi
      done
   done
done
