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
    let processEnvironment = ProcessEnvironment(cmd, basePath: basePath)
    
    processEnvironment.launch()
    processEnvironment.waitUntilExit()
    
    return (processEnvironment.standardOutput ?? "") +
        (processEnvironment.standardError ?? "")
}

private var runningProcesses = Set<ProcessEnvironment>() 

func launchShellCommand(_ cmd: String, basePath: String) -> UUID {
    let processEnvironment = ProcessEnvironment(cmd, basePath: basePath)
    processEnvironment.launch()
    
    runningProcesses.insert(processEnvironment)
    
    return processEnvironment.id
}

private func getShellCommandStatus(
    for process: ProcessEnvironment,
    afterRunning command: ((ProcessEnvironment) -> Void)? = nil
) -> ProcessEnvironment.Status? {
    let status = process.status
    
    command?(process)
        
    if case .finished = status {
        runningProcesses.remove(process)
    }
    
    return status
}

func getShellCommandStatus(for id: UUID) -> ProcessEnvironment.Status? {
    guard let process = runningProcesses.first(where: { $0.id == id }) else {
        return nil
    }
    
    return getShellCommandStatus(for: process)
}

func interruptCommand(with id: UUID) -> ProcessEnvironment.Status? {
    guard let process = runningProcesses.first(where: { $0.id == id }) else {
        return nil
    }
    
    return getShellCommandStatus(for: process,
                                 afterRunning: { $0.interrupt() })
}

func terminateCommand(with id: UUID) -> ProcessEnvironment.Status? {
    guard let process = runningProcesses.first(where: { $0.id == id }) else {
        return nil
    }
    
    return getShellCommandStatus(for: process,
                                 afterRunning: { $0.terminate() })
}
