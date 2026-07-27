import '../../domain/entities/memberships.dart';

class MembershipsModel extends Memberships {
  const MembershipsModel(
      {required String data})
      : super(data: data);

  MembershipsModel copyWith({
    String? data,
  }) {
    return MembershipsModel(
      data: data ?? this.data  ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    "data": data,
  };

  factory MembershipsModel.fromJson(Map<String, dynamic> json) => MembershipsModel(
    data: json["data"],
  );
}

