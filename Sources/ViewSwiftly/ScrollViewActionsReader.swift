//
//  ScrollViewActionsReader.swift
//
//
//  Created by Mira Yang on 8/10/24.
//

import SwiftUI
import Combine

struct ScrollViewActionsReader: View {
    private let scrollDidStart: (CGRect) -> Void
    private let scrollDidEnd: (CGRect) -> Void
    private let onOffsetChange: (CGRect) -> Void
    
    private let detector: CurrentValueSubject<CGRect, Never>
    private let publisher: AnyPublisher<CGRect, Never>
    private let coordinatorSpaceName: String
    @State private var scrolling: Bool = false
    
    init(coordinatorSpaceName: String) {
        self.init(coordinatorSpaceName: coordinatorSpaceName, scrollDidStart: {_ in }, scrollDidEnd: {_ in }, onOffsetChange: {_ in })
    }
    
    private init(
        coordinatorSpaceName: String,
        scrollDidStart: @escaping (CGRect) -> Void,
        scrollDidEnd: @escaping (CGRect) -> Void,
        onOffsetChange: @escaping (CGRect) -> Void
    ) {
        self.coordinatorSpaceName = coordinatorSpaceName
        self.scrollDidStart = scrollDidStart
        self.scrollDidEnd = scrollDidEnd
        self.onOffsetChange = onOffsetChange
        let detector = CurrentValueSubject<CGRect, Never>(.zero)
        self.publisher = detector
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
        self.detector = detector
    }
    
    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .frame(width: 0, height: 0)
                .onChange(of: geometry.frame(in: .named(coordinatorSpaceName))) { frame in
                    onOffsetChange(frame)
                    if !scrolling {
                        scrolling = true
                        scrollDidStart(frame)
                    }
                    detector.send(frame)
                }
                .onReceive(publisher) { frame in
                    scrolling = false
                    scrollDidEnd(frame)
                }
        }
    }
    
    func scrollDidStart(_ closure: @escaping (CGRect) -> Void) -> Self {
        .init(
            coordinatorSpaceName: self.coordinatorSpaceName,
            scrollDidStart: closure,
            scrollDidEnd: scrollDidEnd,
            onOffsetChange: onOffsetChange
        )
    }
    
    func scrollDidEnd(_ closure: @escaping (CGRect) -> Void) -> Self {
        .init(
            coordinatorSpaceName: self.coordinatorSpaceName,
            scrollDidStart: scrollDidStart,
            scrollDidEnd: closure,
            onOffsetChange: onOffsetChange
        )
    }
    
    func onOffsetChange(_ closure: @escaping (CGRect) -> Void) -> Self {
        .init(
            coordinatorSpaceName: self.coordinatorSpaceName,
            scrollDidStart: scrollDidStart,
            scrollDidEnd: scrollDidEnd,
            onOffsetChange: closure
        )
    }
}
