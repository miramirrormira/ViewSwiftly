//
//  ImageAssetView.swift
//
//
//  Created by Mira Yang on 6/14/24.
//

import Foundation
import SwiftUI

struct ImageAssetView: View {
    
    @ObservedObject private var vm: AnyViewModel<AssetState<Data>, AssetActions>
    
    init(vm: AnyViewModel<AssetState<Data>, AssetActions>) {
        self.vm = vm
        Task {
            await vm.trigger(.request)
        }
    }
    
    var body: some View {
        if vm.state.status == .loading {
            ProgressView()
        } else if let data = vm.state.asset, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
        }
    }
}
