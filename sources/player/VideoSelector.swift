//  Copyright © 2018 Oath Inc
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

struct VideoSelector: Equatable {
    let index: Int
    
    init(index: Int, currentIndex: Int?, playlistCount: Int) throws {
        guard index != currentIndex else { struct IgnoreSimilarIndex: Error { }; throw IgnoreSimilarIndex() }
        guard index < playlistCount else { struct IndexOutOfRange: Error { }; throw IndexOutOfRange() }
        self.index = index
    }
}
