#!/bin/bash


pwd
echo 'Linting and building project'




function runSwiftlintJob() {
    swiftlint
}

function buildAndTestProject() {
    NAME = $1
    SCHEME = $2
    xcodebuild -project $NAME -scheme $SCHEME -derivedDataPath Build/ -destination "platform=iOS Simulator,name=iPhone 11,OS=14.0" -enableCodeCoverage YES clean build test CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO
}

function readCodeCoverage() {
    xcrun xccov view --report --json Build/Logs/Test/*.xcresult
}

function parseCodeCoverageDataIntoHumanReadable() {
    sed -e 's/[{}]/''/g'
}
function transformJsonPropertiesToStringList() {
    awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}'
}

function filterTotalCoverageLine() {
    grep '"lineCoverage"' | head -n 1
}

function cutToCheckCoverage() {
    cut -d':' -f2 | cut -c1-4
}
runSwiftlintJob && buildAndTestProject "MeliSearcher.xcodeproj" "MeliSearcher" && readCodeCoverage | parseCodeCoverageDataIntoHumanReadable | transformJsonPropertiesToStringList | filterTotalCoverageLine | cutToCheckCoverage




if [ $? -ne 0 ]; then
 exit 1
fi