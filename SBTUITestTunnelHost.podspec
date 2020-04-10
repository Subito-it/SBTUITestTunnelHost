Pod::Spec.new do |s|
    s.name             = 'SBTUITestTunnelHost'
    s.version          = '1.2.0'
    s.summary          = 'Execute commands on your testing mac host while using SBTUITestTunnel'

    s.description      = <<-DESC
    Extend SBTUITestTunnel adding a tunnel between your test target and host mac running tests. This allows to launch terminal commands on your testing mac during test execution
    DESC

    s.homepage         = 'https://github.com/Subito-it/SBTUITestTunnelHost'
    s.license          = 'Apache License, Version 2.0'
    s.author           = { "Tomas Camin" => "tomas.camin@scmitaly.it" }
    s.source           = { :git => "https://github.com/Subito-it/SBTUITestTunnelHost.git", :tag => s.version.to_s }

    s.platform     = :ios, '9.0'
    s.requires_arc = true

    s.frameworks = 'XCTest'

    s.default_subspec = 'Core'

    s.prepare_command = <<-CMD
                        test -f SBTUITunnelHostServer/Binary/SBTUITestTunnelServer.app.zip && unzip -f SBTUITunnelHostServer/Binary/SBTUITestTunnelServer.app.zip -d SBTUITunnelHostServer/Binary/ && rm SBTUITunnelHostServer/Binary/SBTUITestTunnelServer.app.zip
                   CMD
    
    s.subspec 'Core' do |subspec|
        subspec.source_files = 'SBTUITestTunnelHost/*.{h,m}'
        subspec.pod_target_xcconfig = { :prebuild_configuration => 'debug' }    
    end

    s.subspec 'ServerBinary' do |subspec|
        subspec.dependency 'SBTUITestTunnelHost/Core'
        subspec.source_files = 'SBTUITunnelHostServer/Binary/*.{zip}'
    end
end
