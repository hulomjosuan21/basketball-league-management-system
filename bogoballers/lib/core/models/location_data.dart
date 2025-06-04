class LocationData {
  final Map<String, List<String>> barangays;
  final List<String> municipalities;

  LocationData({required this.barangays, required this.municipalities});

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      barangays: Map<String, List<String>>.from(
        json['barangays'].map(
          (key, value) => MapEntry(key, List<String>.from(value)),
        ),
      ),
      municipalities: List<String>.from(json['municipalities']),
    );
  }
}
