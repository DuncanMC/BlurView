//
//  Dispatcher.swift
//  BlurView
//
//  Created by Duncan Champney on 8/13/20.
//  Copyright © 2020 Duncan Champney. All rights reserved.
//

import Foundation

typealias DispatcherIdentifier = Int

class Dispatcher {
    private var items = [DispatcherIdentifier: DispatchWorkItem]()

    private let queue: DispatchQueue

    deinit {
        cancelAllActions()
    }

    init(_ queue: DispatchQueue = .main) {
        self.queue = queue
    }

    func schedule(after timeInterval: TimeInterval,
                  with identifier: DispatcherIdentifier,
                  on queue: DispatchQueue? = nil,
                  action: @escaping () -> Void) {
        print("Scheduling item \(identifier)")
        cancelAction(with: identifier)

        print("Scheduled \(identifier)")
        let item = DispatchWorkItem(block: action)
        items[identifier] = item

        (queue ?? self.queue).asyncAfter(deadline: .now() + timeInterval, execute: item)
    }

    @discardableResult
    func cancelAction(with identifier: DispatcherIdentifier) -> Bool {
        guard let item = items[identifier] else {
            return false
        }

        defer {
            items[identifier] = nil
        }

        guard !item.isCancelled else {
            return false
        }

        item.cancel()
        print("Cancelled \(identifier)")

        return true
    }

    func cancelAllActions() {
        print("items contains \(items.count) items")
        items.keys.forEach {
            print("Cancelling item \($0)")
            items[$0]?.cancel()
            items[$0] = nil
        }
    }
}
