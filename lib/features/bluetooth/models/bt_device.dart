class BtDevice {
  final String address;
  final String? name;

  const BtDevice({required this.address, this.name});

  String get displayName => name?.isNotEmpty == true ? name! : address;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BtDevice &&
          runtimeType == other.runtimeType &&
          address == other.address;

  @override
  int get hashCode => address.hashCode;
}
