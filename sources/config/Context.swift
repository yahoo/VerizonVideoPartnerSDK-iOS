//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import AdSupport
import VideoRenderer

extension VVPSDK {
    public struct Context {
        public struct Client {
            public var id: String
            public var name: String
            public var version: String
            public var build: String
            public var advertisementID: String?
        }
        
        public struct Device {
            public var platform: String
            public var model: String
            public var os: String
        }
        
        public struct SDK {
            public var version: String
            public var renderers: [Renderer.Descriptor]
        }
        
        public struct RapidConfig {
            public var spaceId: String?
        }
        
        public var client: Client
        public var device: Device
        public var sdk: SDK
        public var extra: JSON
        public var rapidConfig: RapidConfig
        
        public static var current: Context {
            let mainInfo = Bundle.main.infoDictionary!
            
            let hardwareVersion: String = {
                var sysinfo = utsname()
                uname(&sysinfo)
                let data  = Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN))
                let string = String(bytes: data, encoding: .ascii)!
                
                return string.trimmingCharacters(in: .controlCharacters)
            }()
            
            return Context(
                client: Client.init(
                    id: Bundle.main.bundleIdentifier!,
                    name: mainInfo["CFBundleName"] as! String,
                    version: mainInfo["CFBundleShortVersionString"] as! String,
                    build: mainInfo["CFBundleVersion"] as! String,
                    advertisementID: ASIdentifierManager.shared().advertisingIdentifier.uuidString),
                device: Device.init(
                    platform: "iOS",
                    model: hardwareVersion,
                    os: UIDevice.current.systemVersion),
                sdk: SDK.init(
                    version: VVPSDK.backendVersion,
                    renderers: Renderer.Repository.shared.availableRenderers
                ),
                extra: [:],
                rapidConfig: RapidConfig(spaceId: nil))
        }
        
        var json: JSON {
            var client: JSON = [
                "id": self.client.id,
                "name": self.client.name,
                "version": self.client.version,
                "build": self.client.build
            ]
            
            if let advertisementID = self.client.advertisementID {
                client["advertisementId"] = advertisementID
            }
            
            let device: JSON = [
                "platform": self.device.platform,
                "model": self.device.model,
                "os": self.device.os
            ]
            
            let sdk: JSON = [
                "version": self.sdk.version,
                "renderers": self.sdk.renderers.map { r in
                    [ "id": r.id,
                      "version": r.version ]
                }
            ]
            
            var context: JSON = [
                "client": client,
                "device": device,
                "sdk": sdk
            ]
            
            if !extra.isEmpty {
                context["extra"] = extra
            }
            
            if let spaceId = rapidConfig.spaceId {
                context["rapidConfig"] = [ "spaceId" : spaceId ]
            }
            
            return ["context": context]
        }
    }
}
