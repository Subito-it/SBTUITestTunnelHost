// BaseHandler.swift
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
import GCDWebServer

fileprivate let validationToken = "lkju32yt$£bmnA"

protocol BaseHandler {
    func addHandler(_ webServer: GCDWebServer, menubarUpdated: @escaping ((String) -> ()))
}

extension BaseHandler {
    func validToken(_ params: ([AnyHashable : Any])?) -> Bool {
        guard let token = params?["token"] as? String else {
            return false
        }
        
        return token == validationToken
    }
}
