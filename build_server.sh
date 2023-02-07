#!/bin/bash

if ! command -v xcodegen &> /dev/null
then
    echo "XcodeGen not found!"
    exit
fi

rm -rf SBTUITestTunnelServer.app &>/dev/null; 

cd SBTUITunnelHostServer; xcodegen &>/dev/null && xcodebuild -workspace SBTUITestTunnelServer.xcworkspace -scheme SBTUITestTunnelServer -derivedDataPath build -configuration Release &>/dev/null && cp -R build/Build/Products/Release/SBTUITestTunnelServer.app .. && rm -rf build && cd .. && open .

if test $?
then
    echo "Server app $(pwd)/SBTUITestTunnelServer.app successfully built!"
else
    echo "Build failed"
fi
