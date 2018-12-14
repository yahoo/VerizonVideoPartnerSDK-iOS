//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

extension OVPSDK {
    public struct Configuration {
        
        public enum Error: Swift.Error {
            case emptyUserAgent
        }
        
        public var userAgent: String
        public var video: Service
        public var vpaid: VPAID
        public var openMeasurement: OpenMeasurement
        public var tracking: Tracking
        public var telemetry: Service?
        
        public init(userAgent: String,
                    video: Service,
                    vpaid: VPAID,
                    openMeasurement: OpenMeasurement,
                    tracking: Tracking,
                    telemetry: Service?) throws {
            
            guard !userAgent.isEmpty else { throw Error.emptyUserAgent }
            
            self.userAgent = userAgent
            self.video = video
            self.vpaid = vpaid
            self.openMeasurement = openMeasurement
            self.tracking = tracking
            self.telemetry = telemetry
        }
        
        public struct VPAID {
            public var document: URL
        }
        public struct OpenMeasurement {
            public var script: URL
        }
        
        public struct Service {
            public var url: URL
            public var context: JSON
            
            public init(url: URL, context: JSON) {
                self.url = url
                self.context = context
            }
        }
        
        public enum Tracking {
            case native
            case javascript(Javascript)
            
            public struct Javascript {
                public var source: URL
                public let telemetry: Service
                
                public init(source: URL, telemetry: Service) {
                    self.source = source
                    self.telemetry = telemetry
                }
            }
        }
    }
}
