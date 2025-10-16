import 'package:libero/src/common/apiendpoint.dart';
import 'package:libero/src/http/webservice.dart';
import 'package:libero/src/model/shift_frame_model.dart';
import '../../common/globals.dart' as globals;

class ClShiftFrame {
  Future<List<ShiftFrameModel>> loadShiftFrame(
      context, String organId, String fromTime, String toTime) async {
    Map<dynamic, dynamic> results = {};

    await Webservice().loadHttp(context, apiLoadShiftFrames, {
      'organ_id': organId,
      'from_time': fromTime,
      'to_time': toTime,
      'user_id': globals.userId,
    }).then((v) => {results = v});

    List<ShiftFrameModel> shiftFrames = [];
    if (results['is_result']) {
      for (var item in results['data']) {
        shiftFrames.add(ShiftFrameModel.fromJson(item));
      }
    }

    return shiftFrames;
  }
}
