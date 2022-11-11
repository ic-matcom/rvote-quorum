#!/bin/bash
set -e

testName=""

if [ $# -gt 0 ]
    then
        testName="test/Test$1.sol"
fi

truffle test $testName --compile-all