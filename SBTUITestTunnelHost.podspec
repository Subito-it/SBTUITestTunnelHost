Pod::Spec.new do |s|
    s.name             = 'SBTUITestTunnelHost'
    s.version          = '2.1.0'
    s.summary          = 'Execute commands on your testing mac host while using SBTUITestTunnel'

    s.description      = <<-DESC
    Extend SBTUITestTunnel adding a tunnel between your test target and host mac running tests. This allows to launch terminal commands on your testing mac during test execution
    DESC

    s.homepage         = 'https://github.com/Subito-it/SBTUITestTunnelHost'
    s.license          = 'Apache License, Version 2.0'
    s.author           = { "Tomas Camin" => "tomas.camin@scmitaly.it" }
    s.source           = { :git => "https://github.com/Subito-it/SBTUITestTunnelHost.git", :tag => s.version.to_s }

    s.platform     = :ios, '12.0'
    s.requires_arc = true

    s.frameworks = 'XCTest'

    s.source_files = 'SBTUITestTunnelHost/*.{h,m}'
    s.pod_target_xcconfig = { :prebuild_configuration => 'debug' }    
end
