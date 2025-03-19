// Copyright (C) 2023 Subito.it
//
// Licensed under the Apache License, Version 2.0 (the "License");

import Foundation

struct ProcessEnvironment {
    enum Status {
        case running(pid: Int32)

        case finished(
            standardOutput: String?,
            standardError: String?,
            terminationStatus: Int32,
            terminationReason: Process.TerminationReason
        )
    }

    let task = Process()
    let standardOutputPipe = Pipe()
    let standardErrorPipe = Pipe()

    let id = UUID()

    init(_ cmd: String, basePath: String) {
        task.standardOutput = standardOutputPipe
        task.standardError = standardErrorPipe

        task.currentDirectoryPath = basePath
        task.launchPath = "/bin/zsh"

        task.arguments = ["-c", cmd]

        task.terminationHandler = { process in
            print("Process \(process.processIdentifier) terminated")
        }
    }

    @discardableResult
    func run() throws -> Int32 {
        try task.run()
        return task.processIdentifier
    }

    func interrupt() {
        task.interrupt()
    }

    func terminate() {
        task.terminate()
    }

    func waitUntilExit() {
        task.waitUntilExit()
    }

    var standardOutput: String? {
        guard task.isRunning == false else { return nil }

        let data = standardOutputPipe.fileHandleForReading.readDataToEndOfFile()

        guard let output = String(data: data, encoding: .utf8)
        else { return nil }

        return output
    }

    var standardError: String? {
        guard task.isRunning == false else { return nil }

        let data = standardErrorPipe.fileHandleForReading.readDataToEndOfFile()

        guard let error = String(data: data, encoding: .utf8)
        else { return nil }

        return error
    }

    var status: Status {
        if task.isRunning {
            return .running(pid: task.processIdentifier)
        } else {
            return .finished(standardOutput: standardOutput,
                             standardError: standardError,
                             terminationStatus: task.terminationStatus,
                             terminationReason: task.terminationReason)
        }
    }
}

extension ProcessEnvironment: Equatable {
    static func == (lhs: ProcessEnvironment, rhs: ProcessEnvironment) -> Bool {
        lhs.id == rhs.id
    }
}

extension ProcessEnvironment: Hashable {
    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}
