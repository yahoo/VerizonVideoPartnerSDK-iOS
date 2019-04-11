//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation
import CoreGraphics

extension CGSize: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.width)
        hasher.combine(self.height)
    }
}

extension Model.Video {
    public struct Thumbnail {
        public let data: [CGSize : URL]
        fileprivate class Cache {
            fileprivate var size: CGSize?
            fileprivate var url: URL?
        }
        fileprivate let cache: Cache
    }
}

extension PlayerCore.Model.Video.Thumbnail {
    public init?(items: [PlayerCore.Thumbnail]) {
        guard items.count > 0 else { return nil }
        
        var result = [CGSize : URL]()
        for item in items {
            result[CGSize(width: CGFloat(item.width), height: CGFloat(item.height))] = item.url
        }
        
        data = result
        cache = Cache()
    }
    
    public subscript(size: CGSize) -> URL {
        precondition(data.keys.count > 0)
        
        if cache.size == size {
            guard let url = cache.url else { fatalError("Url is not set with size!") }
            return url
        } else {
            var aspect: CGFloat?
            var resultSize: CGSize?
            
            func minimalAspect(from size1: CGSize, to size2: CGSize) -> CGFloat {
                return min(size1.width / size2.width, size1.height / size2.height)
            }
            
            for thumbSize in data.keys {
                let minAspect = minimalAspect(from: thumbSize, to: size)
                if let currentAspect = aspect {
                    if minAspect >= 1 && currentAspect < minAspect {
                        aspect = minAspect
                        resultSize = thumbSize
                    } else if currentAspect < 1 && currentAspect < minAspect {
                        aspect = minAspect
                        resultSize = thumbSize
                    }
                } else {
                    aspect = minAspect
                    resultSize = thumbSize
                }
            }
            guard let size = resultSize, let url = data[size] else {
                fatalError("Url and size are not set for some reason!")
            }
            
            cache.size = size
            cache.url = url
            return url
        }
    }
}
