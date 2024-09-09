//
//  ScrollViewActionsReader.swift
//
//
//  Created by Mira Yang on 8/10/24.
//

import SwiftUI
import Combine

struct ScrollViewActionsReader: View {
    private let scrollDidStart: () -> Void
    private let scrollDidEnd: () -> Void
    
    private let detector: CurrentValueSubject<CGPoint, Never>
    private let publisher: AnyPublisher<CGPoint, Never>
    @State private var scrolling: Bool = false
    
    #if DEBUG
    var subscriptions = Set<AnyCancellable>()
    #endif
    
    init() {
        self.init(scrollDidStart: {}, scrollDidEnd: {})
    }
    
    private init(
        scrollDidStart: @escaping () -> Void,
        scrollDidEnd: @escaping () -> Void
    ) {
        self.scrollDidStart = scrollDidStart
        self.scrollDidEnd = scrollDidEnd
        let detector = CurrentValueSubject<CGPoint, Never>(.zero)
        self.publisher = detector
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .dropFirst()
            .eraseToAnyPublisher()
        self.detector = detector
        #if DEBUG
        self.detector.sink { offset in
            Logger.debug("detected scrolling offset: \(offset)")
        }
        .store(in: &subscriptions)
        #endif
    }
    
    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .frame(width: 0, height: 0)
                .onChange(of: geometry.frame(in: .global).origin) { offset in
                    Logger.debug("scrolling offset: \(offset)")
                    if !scrolling {
                        scrolling = true
                        scrollDidStart()
                    }
                    detector.send(offset)
                }
                .onReceive(publisher) { offset in
                    Logger.debug("detected scroll end at offset: \(offset)")
                    scrolling = false
                    scrollDidEnd()
                }
        }
    }
    
    func scrollDidStart(_ closure: @escaping () -> Void) -> Self {
        .init(
            scrollDidStart: closure,
            scrollDidEnd: scrollDidEnd
        )
    }
    
    func scrollDidEnd(_ closure: @escaping () -> Void) -> Self {
        .init(
            scrollDidStart: scrollDidStart,
            scrollDidEnd: closure
        )
    }
}
