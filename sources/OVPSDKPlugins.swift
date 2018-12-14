//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

public protocol _OVPSDKPlugin: class {
    func provideObserverFor(ids: [VideoId], siteSection: String) -> Player.PropsObserver
}

extension OVPSDK {
    public typealias Plugin = _OVPSDKPlugin
    
    public final class Plugins {
        private var plugins: [Plugin] = []
        
        public func add(plugin: Plugin) {
            if plugins.index(where: { $0 === plugin }) != nil {
                return
            }
            plugins.append(plugin)
        }
        
        public func remove(plugin: Plugin) {
            if let index = plugins.index(where: { $0 === plugin}) {
                plugins.remove(at: index)
            }
        }
        
        func bindTo(player: Player, ids: [VideoId], siteSection: String) {
            for plugin in plugins {
                let observer = plugin.provideObserverFor(ids: ids, siteSection: siteSection)
                _ = player.addObserver(observer)
            }
        }
    }
}
