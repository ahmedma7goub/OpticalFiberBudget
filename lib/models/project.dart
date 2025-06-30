import 'package:json_annotation/json_annotation.dart';

part 'project.g.dart';

@JsonSerializable()
class Project {
  String name;
  String fiberType;
  String smStandard;
  String mmStandard;
  int wavelength;
  String txPower;
  String rxSensitivity;
  String fiberLoss;
  String spliceLoss;
  String connectorLoss;
  String distance;
  String numSplices;
  String numConnectors;
  String otherLoss;
  double? totalLoss;
  double? powerBudget;
  double? availableMargin;

  Project({
    required this.name,
    required this.fiberType,
    required this.smStandard,
    required this.mmStandard,
    required this.wavelength,
    required this.txPower,
    required this.rxSensitivity,
    required this.fiberLoss,
    required this.spliceLoss,
    required this.connectorLoss,
    required this.distance,
    required this.numSplices,
    required this.numConnectors,
    required this.otherLoss,
    this.totalLoss,
    this.powerBudget,
    this.availableMargin,
  });

  factory Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}
