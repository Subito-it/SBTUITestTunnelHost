// Copyright (C) 2023 Subito.it
//
// Licensed under the Apache License, Version 2.0 (the "License");

import Foundation

enum SimulatorDescriptor {
    case byCompleteName(String)
    case byDeviceNameAndRuntime(String, String)

    func recogniseSimulator(from windowName: String) -> Bool {
        switch self {
        case let .byCompleteName(simulatorCompleteName):
            return windowName.contains(simulatorCompleteName)
        case .byDeviceNameAndRuntime(let deviceName, var runtime):
            runtime = runtime.components(separatedBy: ".").prefix(2).joined(separator: ".") // 11.1.1 -> 11.1
            let escapedDeviceName = NSRegularExpression.escapedPattern(for: deviceName)
            let regex = "\(escapedDeviceName) (-|—) (iOS )?\(runtime)(\\.\\d)?"

            return windowName.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
        }
    }
}

extension SimulatorDescriptor {
    init?(requestParameters: [AnyHashable: Any]?) {
        guard let params = requestParameters else { return nil }
        let simulatorWindowName = params["simulator_window_name"] as? String
        let simulatorName = params["simulator_device_name"] as? String
        let simulatorRuntime = params["simulator_device_runtime"] as? String

        switch (simulatorWindowName, simulatorName, simulatorRuntime) {
        case (let .some(simulatorWindowName), nil, nil):
            self = .byCompleteName(simulatorWindowName)
        case (nil, let .some(simulatorName), let .some(simulatorRuntime)):
            self = .byDeviceNameAndRuntime(simulatorName, simulatorRuntime)
        default:
            return nil
        }
    }
}

extension SimulatorDescriptor: CustomStringConvertible {
    var description: String {
        switch self {
        case let .byCompleteName(completeName):
            return completeName
        case let .byDeviceNameAndRuntime(deviceName, runtime):
            return "with name: \(deviceName) and runtime: \(runtime)"
        }
    }
}
