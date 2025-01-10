class GpxController {
  bool speed;
  bool heading;
  bool numSatelites;
  bool accuracy;
  bool provider;

  GpxController({
    required this.speed,
    required this.accuracy,
    required this.heading,
    required this.provider,
    required this.numSatelites,
  });
}
