// ShellCommands.swift
//
// Copyright (C) 2017 Subito.it S.r.l (www.subito.it)
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


import Foundation

func executeShellCommand(_ cmd: String, basePath: String) -> String {
    let task = Process()
    let pipeStd = Pipe()
    let pipeErr = Pipe()
    task.standardOutput = pipeStd
    task.standardError = pipeErr
    
    task.currentDirectoryPath = basePath
    
    task.launchPath = "/bin/sh"
    
    task.arguments = ["-c", cmd]
    
    task.launch()
    task.waitUntilExit()
    
    let retStd: String?
    let retErr: String?
    
    let pipeStdRead = pipeStd.fileHandleForReading
    retStd = String(data: pipeStdRead.readDataToEndOfFile(), encoding: String.Encoding.utf8)?.trimmingCharacters(in: CharacterSet.newlines)
    let pipeErrRead = pipeErr.fileHandleForReading
    retErr = String(data: pipeErrRead.readDataToEndOfFile(), encoding: String.Encoding.utf8)?.trimmingCharacters(in: CharacterSet.newlines)
    
    return (retStd ?? "") + (retErr ?? "")
}
