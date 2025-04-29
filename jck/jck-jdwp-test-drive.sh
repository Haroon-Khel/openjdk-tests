#!/bin/bash

# Query list of tests
# In a for loop over the tests, run GEN_SUMMARY_GENERIC over each test, using $(GEN_JTB_GENERIC) tests=vm/$test testsuite=RUNTIME concurrency=1
# And then run $(EXEC_RUNTIME_TEST)

jckAgentPID=0
harnessExitCode=0
jckHarnessPID=0

testJDK=$4
jckRootDir=$5/JCK-runtime-$6

$testJDK/bin/java -cp $jckRootDir/lib/javatest.jar com.sun.javatest.finder.ShowTests -finder com.sun.javatest.finder.HTMLTestFinder -end $jckRootDir/tests/testsuite.html -initial vm/jdwp | tr -d "[:blank:]" | while read -r test;
do
    # $(GEN_JTB_GENERIC) tests=vm/jdwp testsuite=RUNTIME concurrency=1
    eval "$1 tests=$test testsuite=RUNTIME concurrency=1"
    # Start agent
    eval "$2"
    jckAgentPID=$!
    # Start harness
    eval "$3"
    jckHarnessPID=$!
    sleep 30
    if kill -s 0 $jckHarnessPID 2>nul; then
        echo "Testcase $test : Process $jckHarnessPID is still running after 60 seconds... killing..."
        kill -9 $jckHarnessPID
        harnessExitCode=124
    else
        wait $jckHarnessPID
        harnessExitCode=$?
    fi
    kill -9 $jckAgentPID
done
