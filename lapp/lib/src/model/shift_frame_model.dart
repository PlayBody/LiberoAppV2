class ShiftFrameModel {
  final String id;
  final String organId;
  final DateTime fromTime;
  final DateTime toTime;
  final int count;
  final String? comment;
  final bool isReserve;
  final int blankCnt;

  ShiftFrameModel({
    required this.id,
    required this.organId,
    required this.fromTime,
    required this.toTime,
    required this.count,
    this.comment,
    required this.isReserve,
    required this.blankCnt,
  });

  factory ShiftFrameModel.fromJson(Map<String, dynamic> json) {
    return ShiftFrameModel(
        id: json['id'].toString(),
        organId: json['organ_id'].toString(),
        fromTime: DateTime.parse(json['from_time']),
        toTime: DateTime.parse(json['to_time']),
        count: int.parse(json['count'].toString()),
        comment: json['comment'],
        isReserve: json['is_reserve'],
        blankCnt: json['blank_cnt']);
  }
}
