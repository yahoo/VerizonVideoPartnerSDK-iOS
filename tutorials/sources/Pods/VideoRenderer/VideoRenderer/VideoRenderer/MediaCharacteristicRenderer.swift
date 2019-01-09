//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import AVFoundation

private let assetKey = "availableMediaCharacteristicsWithMediaSelectionOptions"

public protocol UUIDPhantom: Hashable {
    var uuid: UUID { get }
}

extension UUIDPhantom {
    public var hashValue: Int { return uuid.hashValue }
    public static func ==(left: Self, right: Self) -> Bool {
        return left.uuid == right.uuid
    }
}

public enum ResizeOptions {
    case resize
    case resizeAspect
    case resizeAspectFill
}

public struct AvailableMediaOptions {
    public struct Option: UUIDPhantom {
        public let uuid: UUID
        public let name: String
        
        public init(uuid: UUID = UUID(), name: String) {
            self.uuid = uuid
            self.name = name
        }
    }
    
    public static let empty = AvailableMediaOptions(unselectedOptions: [],
                                                    selectedOption: nil)
    public let unselectedOptions: [Option]
    public let selectedOption: Option?
}

final class MediaCharacteristicRenderer {
    typealias Option = AvailableMediaOptions.Option
    
    struct Props {
        let item: AVPlayerItem
        let didStartMediaOptionsDiscovery: () -> ()
        let didDiscoverAudibleOptions: (AvailableMediaOptions) -> ()
        let didDiscoverLegibleOptions: (AvailableMediaOptions) -> ()
        var selectedAudibleOption: Option?
        var selectedLegibleOption: Option?
    }
    
    struct MediaOptionCache {
        let item: AVPlayerItem
        var audibleOptions: [Option: AVMediaSelectionOption] = [:]
        var legibleOptions: [Option: AVMediaSelectionOption] = [:]
        
        init(item: AVPlayerItem) { self.item = item }
    }
    
    var mediaOptionCache: MediaOptionCache?
    
    var props: Props? {
        didSet(oldProps) {
            /// Verify that we have item to look for
            guard let item = props?.item else { return mediaOptionCache = nil }
            
            func selectedOptions() -> [AVMediaSelectionGroup: AVMediaSelectionOption] {
                guard let props = props,
                    item.asset.statusOfValue(forKey: assetKey, error: nil) == .loaded,
                    let mediaOptionCache = mediaOptionCache
                    else { return [:] }
                var options: [AVMediaSelectionGroup: AVMediaSelectionOption] = [:]
                if oldProps?.selectedAudibleOption != props.selectedAudibleOption,
                    let selectedOption = props.selectedAudibleOption {
                    if let group = item.asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristic.audible) {
                        options[group] = mediaOptionCache.audibleOptions[selectedOption]
                    }
                }

                if oldProps?.selectedLegibleOption != props.selectedLegibleOption,
                    let selectedOption = props.selectedLegibleOption {
                    if let group = item.asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristic.legible) {
                        options[group] = mediaOptionCache.legibleOptions[selectedOption]
                    }
                }

                return options
            }

            selectedOptions().forEach { item.select($0.value, in: $0.key) }
            
            guard item != mediaOptionCache?.item else { return }
            
            mediaOptionCache = MediaOptionCache(item: item)
            
            item.asset.loadValuesAsynchronously(forKeys: [assetKey]) { [weak self] in
                guard let `self` = self else { return }
                guard case .loaded = item.asset.statusOfValue(forKey: assetKey, error: nil) else { return }
                
                func mapToPair(option: AVMediaSelectionOption) -> (Option, AVMediaSelectionOption) {
                    return (Option(name: option.displayName), option)
                }
                func first<T, U>(pair: (T, U)) -> T { return pair.0 }
                
                func audibleOptions() -> AvailableMediaOptions {
                    func map(group: AVMediaSelectionGroup) -> AvailableMediaOptions {
                        let audibleOptionsPairs = group.options.map(mapToPair)
                        self.mediaOptionCache?.audibleOptions = Dictionary(uniqueKeysWithValues: audibleOptionsPairs)
                        let selectedAudibleOptionPair = audibleOptionsPairs.first {
                            $0.1 == item.selectedMediaOption(in: group)
                        }
                        return .init(unselectedOptions: audibleOptionsPairs.map(first),
                                     selectedOption: selectedAudibleOptionPair?.0)
                    }
                    return item.asset
                        .mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristic.audible)
                        .flatMap(map) ?? .empty
                }
                self.props?.didDiscoverAudibleOptions(audibleOptions())
                
                func legibleOptions() -> AvailableMediaOptions {
                    func map(group: AVMediaSelectionGroup) -> AvailableMediaOptions {
                        let pairs = group.options
                            .filter(AVMediaSelectionOption.hasLanguageTag)
                            .map(mapToPair)
                            // Add 'None' option on top. Selected by default
                            .extend(element: (Option(name: "None"), AVMediaSelectionOption()),
                                    onTop: true)
                        self.mediaOptionCache?.legibleOptions = Dictionary(uniqueKeysWithValues: pairs)
                        return .init(unselectedOptions: pairs.map(first),
                                     selectedOption: pairs.first?.0)
                    }
                    return item.asset
                        .mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristic.legible)
                        .flatMap(map) ?? .empty
                }
                self.props?.didDiscoverLegibleOptions(legibleOptions())
            }
        }
    }
}

extension Array {
    fileprivate func extend(element: Element, onTop: Bool = true) -> [Element] {
        var new = self
        onTop ? new.insert(element, at: 0) : new.append(element)
        return new
    }
}
