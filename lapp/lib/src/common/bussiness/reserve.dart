import 'dart:convert';

import 'package:libero/src/common/bussiness/stamps.dart';
import 'package:libero/src/common/globals.dart' as globals;
import 'package:libero/src/http/webservice.dart';
import 'package:libero/src/model/order_model.dart';
import 'package:libero/src/model/reservemodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../apiendpoint.dart';
import '../const.dart';

class ClReserve {
  Future<List<ReserveModel>> loadUserReserveList(
      context, userId, organId, fromDate, toDate) async {
    String apiURL = apiBase + '/apireserves/loadUserReserveList';

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiURL, {
      'user_id': globals.userId,
      'organ_id': organId,
      'from_date': fromDate,
      'to_date': toDate,
    }).then((value) => results = value);

    List<ReserveModel> reserves = [];
    if (results['isLoad']) {
      for (var item in results['reserves']) {
        reserves.add(ReserveModel.fromJson(item));
      }
    }

    return reserves;
  }

  Future<String?> loadLastReserveStaffId(context, String organId) async {
    String apiUrl = apiBase + '/apireserves/getLastReserve';

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl, {
      'user_id': globals.userId,
      'organ_id': organId,
    }).then((v) => {results = v});
    return results['staff_id'] == '' ? null : results['staff_id'].toString();
  }

  Future<bool> updateReserveStatus(context, String reserveId) async {
    String apiUrl = apiBase + '/apireserves/updateReserveStatus';
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl, {
      'reserve_id': reserveId,
    }).then((v) => {results = v});

    return results['isStampAdd'];
  }

  Future<bool> enteringOrgan(
      context, String organId, String reserveId, String menuIds) async {
    String apiUrl = apiBase + '/apireserves/enteringOrgan';
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl, {
      'organ_id': organId,
      'order_id': reserveId,
      'menu_ids': menuIds,
      'user_id': globals.userId
    }).then((v) => {results = v});

    if (results['isUpdateGrade'])
      globals.userRank = await ClCoupon().loadRankData(context, globals.userId);

    return results['isStampAdd'];
  }

  Future<ReserveModel?> getReserveNow(context, String organId) async {
    String apiUrl = apiBase + '/apireserves/getReserveNow';
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl, {
      'user_id': globals.userId,
      'organ_id': organId,
    }).then((v) => {results = v});

    if (results['isExistReserve']) {
      return ReserveModel.fromJson(results['reserve']);
    }

    return null;
  }

  Future<List<OrderModel>> loadReserveList(context) async {
    String apiURL = apiBase + '/apiorders/loadOrderList';
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiURL, {
      'user_id': globals.userId,
      'is_reserve_list': '1'
    }).then((value) => results = value);
    List<OrderModel> historys = [];
    if (results['isLoad']) {
      for (var item in results['orders']) {
        historys.add(OrderModel.fromJson(item));
      }
    }

    return historys;
  }

  Future<List<OrderModel>> loadReserves(context, param) async {
    String apiURL = apiBase + '/apiorders/loadOrderList';
    Map<dynamic, dynamic> results = {};
    await Webservice()
        .loadHttp(context, apiURL, param)
        .then((value) => results = value);
    List<OrderModel> reserves = [];
    if (results['isLoad']) {
      for (var item in results['orders']) {
        reserves.add(OrderModel.fromJson(item));
      }
    }

    return reserves;
  }

  Future<OrderModel?> loadReserveInfo(context, String orderId) async {
    String apiURL = apiBase + '/apiorders/loadOrderInfo';

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiURL, {'order_id': orderId}).then(
        (value) => results = value);
    OrderModel? reserve;

    if (results['isLoad']) {
      reserve = OrderModel.fromJson(results['order']);
    }

    return reserve;
  }

  Future<ReserveModel?> loadReserveMenus(context, reserveId) async {
    String apiURL = apiBase + '/apireserves/loadReserveInfo';

    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiURL,
        {'reserve_id': reserveId}).then((value) => results = value);
    ReserveModel? reserve;
    if (results['isLoad']) {
      reserve = ReserveModel.fromJson(results['reserve']);
    }

    return reserve;
  }

  Future<bool> updateReserveCancel(context, String reserveId) async {
    String apiUrl = apiBase + '/apiorders/updateStatus';
    await Webservice()
        .loadHttp(context, apiUrl, {'order_id': reserveId, 'status': ORDER_STATUS_RESERVE_CANCEL});
    return true;
  }

  Future<bool> updateReceiptUserName(
      context, String reserveId, String updateUserName) async {
    dynamic data = {'id': reserveId, 'user_input_name': updateUserName};
    String apiUrl = apiBase + '/apiorders/updateOrder';
    await Webservice()
        .loadHttp(context, apiUrl, {'update_data': jsonEncode(data)});
    return true;
  }

  Future<List<TimeRegion>> loadReserveTimeStatus(
      context,
      String organId,
      String staffType,
      String staffId,
      String fromDate,
      String toDate,
      bool isDetail) async {
    // List<String> menuIds = [];
    List<String> menuIds = [];
    globals.connectReserveMenuList.forEach((element) {
      menuIds.add(element.menuId);
    });
    Map<dynamic, dynamic> results = {};
    var param = {
      'organ_id': organId,
      'staff_type': staffType,
      'stafF_id': staffId,
      'menu_ids': menuIds.join(','),
      'from_date': fromDate,
      'to_date': toDate,
      'user_id': globals.userId
    };
    results =
        await Webservice().loadHttp(context, apiLoadReserveTimeStatus, param);

    if (!results['is_result']) return [];

    DateTime fDateTime = DateTime.parse(fromDate);
    DateTime tDateTime = DateTime.parse(toDate + " 23:59:59");
    DateTime now = DateTime.parse(
        DateFormat('yyyy-MM-dd HH:00:00').format(DateTime.now()));
    now = now.add(Duration(hours: 1));

    List<TimeRegion> regions = [];
    List<String> existHours = [];

    if (isDetail) {
      for (var item in results['data']['mins']) {
        if (item['type'] == 1 || item['type'] == 2) {
          String st = '${item["date"]} ${item['hour']}:${item['min']}:00';
          existHours.add(st);
          regions
              .add(statusRegion(DateTime.parse(st), 5, item['type'], staffId));
        }
      }
    } else {
      for (var item in results['data']['hours']) {
        if (item['type'] == 1 || item['type'] == 2) {
          String st = '${item["date"]} ${item['hour']}:00:00';
          existHours.add(st);
          regions
              .add(statusRegion(DateTime.parse(st), 60, item['type'], staffId));
        }
      }
    }

    DateTime curDateTime = now.isAfter(fDateTime) ? now : fDateTime;
    while (!curDateTime.isAfter(tDateTime)) {
      if (!existHours
          .contains(DateFormat('yyyy-MM-dd HH:mm:00').format(curDateTime))) {
        regions.add(statusRegion(curDateTime, isDetail ? 5 : 60, 3, ''));
      }
      curDateTime = curDateTime.add(Duration(minutes: isDetail ? 5 : 60));
    }
    return regions;
  }

  TimeRegion statusRegion(DateTime f, int diff, int type, staffId) {
    var _cellBGColor = Color(0xfffdfdf6);
    var _cellText = 'x';
    var _textColor = Colors.grey;

    if (type == 1) {
      _cellBGColor = Colors.white;
      _cellText = staffId == '' ? '○' : '◎';
      _textColor = Colors.red;
    }
    if (type == 2) {
      _cellBGColor = Colors.white;
      _textColor = Colors.green;
      _cellText = '□';
    }
    return TimeRegion(
        startTime: f,
        endTime: f.add(Duration(minutes: diff)),
        enablePointerInteraction: true,
        color: _cellBGColor,
        text: _cellText,
        textStyle: TextStyle(
            color: _textColor, fontSize: 18, fontWeight: FontWeight.bold));
  }
}
