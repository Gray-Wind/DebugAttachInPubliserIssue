//
//  ModelTracker.swift
//  PubliserSubscriptionIssue
//
//  Created by Ilia Kolomeitsev on 04.10.2023.
//

import Foundation
import Combine

class ModelTracker {

    enum ReactFrom: String {
        case weakGuard
        case weakGuardBefore
        case weakGuardAfter
        case weak
        case unowned
        case otherGuardFirst
        case otherWeakFirst
    }

    weak var model: Model? {
        didSet {
            modelSubscriptions = []

            guard let model else { return }

            // MARK: - Simple cases

            model.$publisherTrigger.sink { [weak self] triggerStatus in
                guard let self else { return }
                // Cannot attach with debugger here, the breakpoint is ignored
                react(on: triggerStatus, from: .weakGuard)
            }
            .store(in: &modelSubscriptions)
            model.$publisherTrigger.sink { [weak self] triggerStatus in
                guard let self = self else { return }
                // Cannot attach here...
                react(on: triggerStatus, from: .weakGuard)
            }
            .store(in: &modelSubscriptions)
            model.$publisherTrigger.sink { [weak self] triggerStatus in
                // Can attach here with the breakpoint without any issues
                self?.react(on: triggerStatus, from: .weak)
            }
            .store(in: &modelSubscriptions)
            model.$publisherTrigger.sink { [unowned self] triggerStatus in
                // Can attach here as well
                react(on: triggerStatus, from: .unowned)
            }
            .store(in: &modelSubscriptions)

            // MARK: - More complex cases

            model.$publisherTrigger.sink { [weak self] triggerStatus in
                guard let model = self?.model, let self else { return }
                // In this case the debugger surprisingly can attach
                let _ = model  // just touch model to remove warnings
                react(on: triggerStatus, from: .otherGuardFirst)
            }
            .store(in: &modelSubscriptions)
            model.$publisherTrigger.sink { [weak model, weak self] triggerStatus in
                guard let model, let self else { return }
                // But this case doesn't work
                let _ = model  // just touch model to remove warnings
                react(on: triggerStatus, from: .otherWeakFirst)
            }
            .store(in: &modelSubscriptions)

            model.$publisherTrigger.sink { [weak self] triggerStatus in
                // And this case work fine...
                self?.react(on: triggerStatus, from: .weakGuardBefore)
                guard let self else { return }
                react(on: triggerStatus, from: .weakGuardAfter)
            }
            .store(in: &modelSubscriptions)
            model.$publisherTrigger.sink { [weak self] triggerStatus in
                // And this case work fine as well...
                print("reacting on publisher...")
                guard let self else { return }
                react(on: triggerStatus, from: .weakGuardAfter)
            }
            .store(in: &modelSubscriptions)
        }
    }

    // The breakpoint here works in every case
    private func react(on status: Bool, from: ReactFrom) {
        print("triggerStatus: \(status), from: \(from)")
    }

    private var modelSubscriptions: Set<AnyCancellable> = []
}
