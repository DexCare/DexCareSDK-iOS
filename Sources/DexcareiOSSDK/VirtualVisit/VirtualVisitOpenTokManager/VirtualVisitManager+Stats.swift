import Foundation

extension VirtualVisitOpenTokManager {
    func startStatsCollection() {
        videoPublisher.networkStatsPublisherDelegate = self
        videoSubscriber?.networkStatsSubscriberDelegate = self

        videoSubscriber?.rtcStatsSubscriberDelegate = self
        videoPublisher.rtcStatsPublisherDelegate = self

        // RTC Stats are asynchronous and can't be queried after the session is completed, so we're going to set a timer and query them every so often, saving the info.
        addStatsWorkItem()
    }

    func stopStatsCollection() {
        cancelStatsWorkItem()
    }

    private func addStatsWorkItem() {
        if inWaitingRoom {
            return
        }

        // Cancel any existing workItem if there is any
        if statsWorkItem != nil {
            cancelStatsWorkItem()
        }

        // Dispatch the work item based on wall time
        let workItem = DispatchWorkItem { [weak self] in
            self?.updateStats()
        }
        statsWorkItem = workItem
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + statsRefreshTime, execute: workItem)
    }

    private func updateStats() {
        videoSubscriber?.getSubscriberRTCStats()
        videoPublisher.getPublisherRTCStats()

        addStatsWorkItem()
    }

    private func cancelStatsWorkItem() {
        statsWorkItem?.cancel()
        statsWorkItem = nil
    }
}
