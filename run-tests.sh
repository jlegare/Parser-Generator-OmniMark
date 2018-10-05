#!/bin/sh
#

UsageMessage="Usage : $0 <option>* <test name>*

where <option> is

   -help       display this message and quit,
   -regression perform a regression run,
   -verbose    emit verbose results,
   -quiet      performs a quiet diff, and
   <test name> is the name of a test.

If no test names are specified, all tests are run.
"

TestsDirectory="./tests"
RegressionDirectories="errors lexical SLR LR0 LR1"

OmniMark="${OMNIMARK:-omnimark}"

DoQuietDiff=""
DoRegressionRun="FALSE"
DoVerboseResults="FALSE"

Report ()
{
   Phase=$1
   Input=$2
   Channel=$3

   echo "${Phase} (${Input}, ${Channel})"

   if [ $# -gt 3 ]
   then
      Reference=$4
      Current=$5

      echo "   input:     ${Input}"
      echo "   reference: ${Reference}"
      echo "   current:   ${Current}"
   fi
}


while [ $# -gt 0 ]
do
   case "$1" in
   -help)
      echo "${UsageMessage}"
      exit 1 ;;

   -regression)
      shift
      DoRegressionRun="TRUE" ;;

   -verbose)
      shift
      DoVerboseResults="TRUE" ;;

   -quiet)
      shift
      DoQuietDiff="-q" ;;

   # The rest of these options are undocumented.
   #
   -d)
      shift
      OmniMark="/home/jl/src/aves/d0406/o/linux/omnimarkd" ;;

   -CVM)
      shift
      OmniMark="$1" 
      shift ;;

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
   for shortTestName in $*
   do
       TestNames="${TestNames} ${TestsDirectory}/${shortTestName}"
   done

elif [ "${DoRegressionRun}" = "TRUE" ]
then
   TestNames=""
   for RegressionDirectory in ${RegressionDirectories}
   do
      TestNames="${TestNames} `find ${TestsDirectory}/${RegressionDirectory} -name '*.ebnf' | sort | sed 's/.ebnf$//g'`"
   done   

else
   TestNames=`find ${TestsDirectory} -name '*.ebnf' | sort | sed 's/.ebnf$//g'`
fi

FailedTests=""
for TestName in ${TestNames}
do
   echo "========================================================================"
   echo "${TestName} ... "

   PhasesFilename="`dirname ${TestName}`/PHASES.TXT"
   if [ -f "${PhasesFilename}" ]
   then
      Phases=`cat "${PhasesFilename}"`

   else
      Phases="scan analyze"
   fi

   for phase in ${Phases}
   do
      TestInput="${TestName}.ebnf"
      TestArgs="-s command-line/wrapper.xom"
      if [ -f "${TestName}.${phase}.xar" ]
      then
         TestArgs="${TestArgs} -f ${TestName}.${phase}.xar"

      elif [ -f "${TestName}.xar" ]
      then
         TestArgs="${TestArgs} -f ${TestName}.xar"
      fi

      CurrentTestLog=`echo ${TestInput} | sed "s/ebnf\$/${phase}.log.current/"`
      CurrentTestOutput=`echo ${TestInput} | sed "s/ebnf\$/${phase}.out.current/"`

      ReferenceTestLog=`echo ${TestInput} | sed "s/ebnf\$/${phase}.log.reference/"`
      ReferenceTestOutput=`echo ${TestInput} | sed "s/ebnf\$/${phase}.out.reference/"`

      echo "${TestName} ... ${phase} ..."
      if [ "${phase}" = "scan" ]
      then
         ${OmniMark} ${TestArgs} -dea handle-parsing "${TestInput}" -of "${CurrentTestOutput}" -log "${CurrentTestLog}"

      elif [ "${phase}" = "analyze" ]
      then
         ${OmniMark} ${TestArgs} -a handle-parsing "${TestInput}" -of "${CurrentTestOutput}" -log "${CurrentTestLog}"

      elif [ "${phase}" = "slr" ]
      then
         ${OmniMark} ${TestArgs} -a handle-slr "${TestInput}" -of "${CurrentTestOutput}" -log "${CurrentTestLog}"

      elif [ "${phase}" = "lr0" ]
      then
         ${OmniMark} ${TestArgs} -a handle-canonical-lr-0 "${TestInput}" -of "${CurrentTestOutput}" -log "${CurrentTestLog}"

      elif [ "${phase}" = "lr1" ]
      then
         ${OmniMark} ${TestArgs} -a handle-canonical-lr-1 "${TestInput}" -of "${CurrentTestOutput}" -log "${CurrentTestLog}"
      fi

      if [ "${DoVerboseResults}" = "TRUE" ]
      then
         diff ${DoQuietDiff} ${ReferenceTestLog} ${CurrentTestLog} \
            || FailedTests="${FailedTests}"`Report "${phase}" "${TestInput}" "log" "${ReferenceTestLog}" "${CurrentTestLog}"`"\n\n"

         diff ${DoQuietDiff} ${ReferenceTestOutput} ${CurrentTestOutput} \
            || FailedTests="${FailedTests}"`Report "${phase}" "${TestInput}" "output" "${ReferenceTestOutput}" "${CurrentTestOutput}"`"\n\n"

      else
         diff ${DoQuietDiff} ${ReferenceTestLog} ${CurrentTestLog} \
            || FailedTests="${FailedTests}"`Report "${phase}" "${TestInput}" "log"`"\n"

         diff ${DoQuietDiff} ${ReferenceTestOutput} ${CurrentTestOutput} \
            || FailedTests="${FailedTests}"`Report "${phase}" "${TestInput}" "output"`"\n"
      fi
   done

   echo ""
done

if [ "${FailedTests}" != "" ]
then
    echo "The following tests have failed:"
    echo "${FailedTests}"
fi
