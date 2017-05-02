# SBTUITestTunnelHost

[![Version](https://img.shields.io/cocoapods/v/SBTUITestTunnelHost.svg?style=flat)](http://cocoadocs.org/docsets/SBTUITestTunnelHost)
[![License](https://img.shields.io/cocoapods/l/SBTUITestTunnelHost.svg?style=flat)](http://cocoadocs.org/docsets/SBTUITestTunnelHost)
[![Platform](https://img.shields.io/cocoapods/p/SBTUITestTunnelHost.svg?style=flat)](http://cocoadocs.org/docsets/SBTUITestTunnelHost)

## Overview

If you've been writing UI Tests in Xcode you may have been in the situation where you wanted to execute some command line tools (on the mac host) during the test execution. This tool does just that and consists of a Mac App (server) and an extension of XCTests (client).

## Installation (CocoaPods)

We strongly suggest to use [cocoapods](https://cocoapods.org) being the easiest way to embed the library inside your project. You simply need to add `SBTUITestTunnelHost` to your UI Test target. 

## Installation (Manual)

Add files in the *SBTUITestTunnelHost* to the UI test target.

## Usage

### Mac

Launch the Mac App (either by compiling the `Mac Host/SBTUITunnelHostServer.xcworkspace` or launching the executable in `Mac Host/Binary/SBTUITestTunnelServer.zip`) which will fire a server on your local machine on port 8667. The current status of the server will be shown in the macOS menubar.

### UI Tests

In your code just import SBTUITestTunnelHost. This will add a `host` property to the XCTest class which is an instance of `SBTUITestTunnelHost` that allows to remotely execute a command by calling `host.executeCommand(cmd)`. Commands are executed synchronously and return a string with the stdout output.

In the Example project there are two very simple examples in Swift and Objective-C.

## Security Warnings 🔥🔥🔥 

The tool is intended for testing enviornments only, use with care since **it allows to access and execute commands** on the running host. **Make sure that the host is only reachable by trusted clients.**

For additional security launch the tool with a system user with [specific access privileges](https://support.apple.com/kb/PH25796?locale=en_US&viewlocale=en_US)

## Contributions

Contributions are welcome! If you have a bug to report, feel free to help out by opening a new issue or sending a pull request.

## Authors

[Tomas Camin](https://github.com/tcamin) ([@tomascamin](https://twitter.com/tomascamin))

## License

SBTUITestTunnelHost is available under the Apache License, Version 2.0. See the LICENSE file for more info.
