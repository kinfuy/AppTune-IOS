import Foundation
import Network

public class CheckInternetConnection {
  private static let monitor = NWPathMonitor()
  private static var isMonitoring = false
  private static var currentStatus = false

  private static let maxRetries = 2
  private static let retryInterval: UInt64 = 1_000_000_000  // 1秒

  class func isConnected() -> Bool {
    if !isMonitoring {
      startMonitoring()
    }
    return currentStatus
  }

  class func checkConnection(retries: Int = maxRetries) async -> Bool {
    if !isMonitoring {
      startMonitoring()
    }

    var remainingRetries = retries
    while remainingRetries > 0 && !currentStatus {
      try? await Task.sleep(nanoseconds: retryInterval)
      remainingRetries -= 1
    }

    return currentStatus
  }

  private class func startMonitoring() {
    monitor.pathUpdateHandler = { path in
      currentStatus = path.status == .satisfied
    }
    monitor.start(queue: DispatchQueue.global(qos: .background))
    isMonitoring = true
  }

  class func stopMonitoring() {
    monitor.cancel()
    isMonitoring = false
  }
}
