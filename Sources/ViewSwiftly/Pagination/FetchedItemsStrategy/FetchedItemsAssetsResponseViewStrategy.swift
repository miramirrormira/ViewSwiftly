//
//  FetchedItemsAssetsResponseViewStrategy.swift
//  ViewSwiftly
//
//  Created by Mira Yang on 5/18/24.
//

import Foundation
import CacheSwiftly
import NetSwiftly

public class FetchedItemsAssetsResponseViewStrategy<Item: Identifiable, Asset>: FetchedItemsStrategy, ObservableObject {
    
    public typealias ItemType = Item
    
    var assetRequestableOfFetchedItem: (Item) -> AnyRequestable<Asset>?
    
    public var dataDiskCache: AnyCachable<Asset>?
    public var dataTaskMemoryCache: AnyCachable<Task<Asset, Error>>?
    public var semaphore: AsyncSemaphore?
    
    @Published public var state: [String: FetchResponseViewModel<Asset>] = [:]
    
    public init(
        assetRequestableOfFetchedItem: @escaping (Item) -> AnyRequestable<Asset>?,
        dataDiskCache: AnyCachable<Asset>?,
        dataTaskMemoryCache: AnyCachable<Task<Asset, Error>>?,
        semaphore: AsyncSemaphore? = nil
    ) {
        self.assetRequestableOfFetchedItem = assetRequestableOfFetchedItem
        self.dataDiskCache = dataDiskCache
        self.dataTaskMemoryCache = dataTaskMemoryCache
        self.semaphore = semaphore
    }
    
    public func onFetchedItems(_ items: [Item]) throws {
        for item in items {
            Task(priority: .userInitiated) {
                if let key = item.id as? String {
                    guard var assetRequestable = assetRequestableOfFetchedItem(item) else { return }
                    
                    if let dataDiskCache = dataDiskCache {
                        assetRequestable = AnyRequestable(CachedRequestableDecorator(cache: dataDiskCache, key: key, requestable: assetRequestable))
                    }
                    if let dataTaskMemoryCache = dataTaskMemoryCache {
                        assetRequestable = AnyRequestable(CachedTaskRequestableDecorator(cache: dataTaskMemoryCache, key: key, requestable: assetRequestable))
                    }
                    
                    let vm = FetchResponseViewModel(requestable: assetRequestable, label: key)
                    await semaphore?.wait()
                    await vm.trigger(.request)
                    await semaphore?.signal()
                    
                    await MainActor.run {
                        self.state[key] = vm
                    }
                }
            }
        }
    }
    
}
