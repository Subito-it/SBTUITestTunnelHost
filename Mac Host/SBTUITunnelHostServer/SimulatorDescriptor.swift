//
//  SimulatorDescriptor.swift
//  SBTUITunnelHostServer
//
//  Created by mattia.valzelli on 13/12/2017.
//  Copyright © 2017 Subito.it. All rights reserved.
//

import Foundation

enum SimulatorDescriptor {
    case byCompleteName(String)
    case byDeviceNameAndRuntime(String, String)
    
    func recogniseSimulator(from windowName: String) -> Bool {
        switch self {
        case .byCompleteName(let simulatorCompleteName):
            return windowName.contains(simulatorCompleteName)
        case .byDeviceNameAndRuntime(let deviceName, let runtime):
            return windowName.range(of: "(\(deviceName))+|[ ]*(\(runtime))+", options: .regularExpression, range: nil, locale: nil) != nil
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
        case (.some(let simulatorWindowName), nil, nil):
            self = .byCompleteName(simulatorWindowName)
        case (nil, .some(let simulatorName), .some(let simulatorRuntime)):
            self = .byDeviceNameAndRuntime(simulatorName, simulatorRuntime)
        default:
            return nil
        }
    }
}

extension SimulatorDescriptor: CustomStringConvertible {
    var description: String {
        switch self {
        case .byCompleteName(let completeName):
            return completeName
        case .byDeviceNameAndRuntime(let deviceName, let runtime):
            return "with name: \(deviceName) and runtime: \(runtime)"
        }
    }
}
