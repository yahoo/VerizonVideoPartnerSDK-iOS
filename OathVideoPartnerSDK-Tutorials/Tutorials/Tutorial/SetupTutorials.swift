//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import UIKit
import OathVideoPartnerSDK
import PlayerControls


typealias Props = PlayerViewControllerWrapper.Props
func select(controller: @escaping (PlayerViewControllerWrapper) -> ()) -> (UIViewController) -> () {
    return {
        guard let wrapper = $0 as? PlayerViewControllerWrapper else { return }
        controller(wrapper)
    }
}

func setupPlayingVideos(tutorialCasesViewController: TutorialCasesViewController) {
    tutorialCasesViewController.props = .init(
        rows: [.init(name: "Single video", select: select(controller: { $0.player = singleVideo() })),
               .init(name: "Array of videos", select: select(controller: { $0.player = arrayOfVideos() })),
               .init(name: "Video playlist", select: select(controller: { $0.player = videoPlaylist() })),
               .init(name: "Muted video", select: select(controller: { $0.player = mutedVideo() })),
               .init(name: "Video without autoplay", select: select(controller: { $0.player = videoWithoutAutoplay() }))])
}

func setupCustomUX(tutorialCasesViewController: TutorialCasesViewController) {
    func customColors(wrapper: PlayerViewControllerWrapper) {
        wrapper.player = singleVideo()
        wrapper.props.controls.color = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
    }
    
    func customSidebar(wrapper: PlayerViewControllerWrapper) {
        wrapper.props.controls.sidebarProps = [.init(isEnabled: true,
                                                     isSelected: false,
                                                     icons: .init(normal: UIImage(named: "icon-fav")!,
                                                                  selected: UIImage(named: "icon-fav-active")!,
                                                                  highlighted: nil),
                                                     handler: .nop,
                                                     accessibility: .init(label: "Mark video as favorite", hint: "")),
                                               .init(isEnabled: true,
                                                     isSelected: false,
                                                     icons: .init(normal: UIImage(named: "icon-share")!,
                                                                  selected: UIImage(named: "icon-share-active")!,
                                                                  highlighted: nil),
                                                     handler: .nop,
                                                     accessibility: .init(label: "Share video", hint: ""))]
        wrapper.player = singleVideo()
    }
    
    func hiddenControls(wrapper: PlayerViewControllerWrapper) {
        wrapper.props.controls.isSomeHidden = true
        wrapper.player = arrayOfVideos()
    }
    
    func liveDotColor(wrapper: PlayerViewControllerWrapper) {
        wrapper.props.controls.liveDotColor = .red
        wrapper.player = liveVideo()
    }
    
    func filteredSubtitles(wrapper: PlayerViewControllerWrapper) {
        wrapper.props.controls.isFilteredSubtitles = true
        wrapper.player = subtitlesVideo()
    }
    
    func disabledAnimations(wrapper: PlayerViewControllerWrapper) {
        wrapper.props.controls.isAnimationsDisabled = true
        wrapper.player = singleVideo()
    }
    
    func customSeekerColors(wrapper: PlayerViewControllerWrapper) {
        wrapper.props.controls.isCustomColorsMode = true
        wrapper.player = singleVideo()
    }
    
    tutorialCasesViewController.props = .init(
        rows: [.init(name: "Custom color", select: select(controller: customColors)),
               .init(name: "Custom sidebar", select: select(controller: customSidebar)),
               .init(name: "Hidden 10s seek and settings", select: select(controller: hiddenControls)),
               .init(name: "Live dot color", select: select(controller: liveDotColor)),
               .init(name: "Filtered subtitles", select: select(controller: filteredSubtitles)),
               .init(name: "Disabled Animations", select: select(controller: disabledAnimations)),
               .init(name: "Custom seeker colors", select: select(controller: customSeekerColors))])
}

func setupObserving(tutorialCasesViewController: TutorialCasesViewController) {
    func videoStats(wrapper: PlayerViewControllerWrapper) {
        wrapper.props.showStats = true
        wrapper.player = videoPlaylist()
    }
    
    func loopingVideos(wrapper: PlayerViewControllerWrapper) {
        wrapper.props.looping = true
        wrapper.player = videoPlaylist()
    }
    
    func hooking(wrapper: PlayerViewControllerWrapper) {
        wrapper.props.nextVideoHooking = true
        wrapper.player = videoPlaylist()
    }
    
    tutorialCasesViewController.props = .init(
        rows: [.init(name: "Video states", select: select(controller: videoStats)),
               .init(name: "Looping videos", select: select(controller: loopingVideos)),
               .init(name: "Next video hooking (random index)", select: select(controller: hooking))])
}

func setupErrorHandling(tutorialCasesViewController: TutorialCasesViewController) {
    func restricted(wrapper: PlayerViewControllerWrapper) {
        wrapper.player = restrictedVideo()
    }
    
    func deleted(wrapper: PlayerViewControllerWrapper) {
        wrapper.player = deletedVideo()
    }
    
    func unknown(wrapper: PlayerViewControllerWrapper) {
        wrapper.player = unknownVideo()
    }
    
    tutorialCasesViewController.props = .init(
        rows: [.init(name: "Restricted video", select: select(controller: restricted)),
               .init(name: "Deleted video", select: select(controller: deleted)),
               .init(name: "Unknown video", select: select(controller: unknown))])
}

extension SideBarView.ButtonProps.Accessibility {
    init(label: String, hint: String) {
        self.label = label
        self.hint = hint
        self.traits = UIAccessibilityTraitButton
    }
}
