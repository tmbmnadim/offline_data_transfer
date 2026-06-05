enum BtAdapterState {
  unknown,
  turningOn,
  on,
  turningOff,
  off;

  bool get isOn => this == BtAdapterState.on;
  bool get isOff => this == BtAdapterState.off;
  bool get isTurningOn => this == BtAdapterState.turningOn;
  bool get isTurningOff => this == BtAdapterState.turningOff;
  bool get isUnknown => this == BtAdapterState.unknown;
}
