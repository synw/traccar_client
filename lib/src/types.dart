/// The current network status
enum DeviceStatus {
  /// The device is emiting positions
  online,

  /// The device has stopped emiting positions
  sleeping,

  /// The device is not emiting positions
  offline,

  /// The device has never been seen on the network
  unknown
}
