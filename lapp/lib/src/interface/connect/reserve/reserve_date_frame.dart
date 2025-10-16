import 'package:libero/src/common/bussiness/shift_frame.dart';
import 'package:libero/src/common/const.dart';
import 'package:libero/src/interface/component/form/main_form.dart';
import 'package:libero/src/interface/component/text/label_text.dart';
import 'package:libero/src/interface/connect/reserve/connect_reserve_confirm.dart';
import 'package:libero/src/model/organmodel.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:libero/src/model/shift_frame_model.dart';

import 'package:syncfusion_flutter_calendar/calendar.dart';

class ReserveDateFrame extends StatefulWidget {
  final OrganModel organ;
  const ReserveDateFrame({required this.organ, Key? key}) : super(key: key);

  @override
  _ReserveDateFrame createState() => _ReserveDateFrame();
}

class _ReserveDateFrame extends State<ReserveDateFrame> {
  late Future<List> loadData;

  DateTime selectedDate = DateTime.now();
  String viewFromTime = '';
  String viewToTime = '';
  List<ShiftFrameModel> shiftFrames = [];

  // List<TimeRegion> regions = <TimeRegion>[];
  List<Appointment> appointments = <Appointment>[];
  int minHour = 0;
  int maxHour = 24;
  double sfCalanderHeight = 0;

  @override
  void initState() {
    super.initState();
    loadData = loadInitData();
  }

  DateTime getDate(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<List> loadInitData() async {
    viewFromTime = DateFormat('yyyy-MM-dd 00:00:00').format(getDate(
        selectedDate.subtract(Duration(days: selectedDate.weekday - 1))));
    viewToTime = DateFormat('yyyy-MM-dd 23:59:59').format(selectedDate
        .add(Duration(days: DateTime.daysPerWeek - selectedDate.weekday)));

    shiftFrames = await ClShiftFrame().loadShiftFrame(
        context, widget.organ.organId, viewFromTime, viewToTime);

    appointments = [];
    for (var item in shiftFrames) {
      if (minHour == 0 || (item.fromTime.hour - 1) < minHour) {
        minHour = item.fromTime.hour - 1;
      }
      if (maxHour == 24 || (item.toTime.hour + 1) > maxHour) {
        maxHour = item.toTime.hour + 1;
      }
      if (minHour < 0) minHour = 0;
      if (maxHour > 24) maxHour = 24;

      appointments.add(Appointment(
        startTime: item.fromTime,
        endTime: item.toTime,
        subject:
            '${item.comment ?? ''},${item.isReserve ? 1 : 0},${item.blankCnt},${item.id}',
        color: item.isReserve || item.blankCnt < 1
            ? Color(0xFFDFDFDF)
            : Color(0xFFB6DEFF),
        startTimeZone: '',
        endTimeZone: '',
      ));
    }
    sfCalanderHeight = 50 * (maxHour - minHour) + 70;

    setState(() {});
    return [];
  }

  Future<void> changeViewCalander(_date) async {
    String newFromTime = DateFormat('yyyy-MM-dd')
        .format(getDate(_date.subtract(Duration(days: _date.weekday))));
    if (newFromTime == viewFromTime) return;
    selectedDate = _date;
    await loadInitData();
  }

  // Future<void> setReserveTime(CalendarTapDetails _cell) async {
  //   if (_cell.date == null) return;

  //   String? selText =
  //       regions.firstWhere((element) => element.startTime == _cell.date).text;
  //   if (selText == null || selText == '' || selText == 'x') return;

  //   Navigator.push(context, MaterialPageRoute(builder: (_) {
  //     return ReserveDateSecond(
  //       organId: widget.organ.organId,
  //       isNoReserveType: widget.isNoReserveType,
  //       staffId: widget.staffId,
  //       selTime: _cell.date!,
  //     );
  //   }));

  //   setState(() {});
  // }
  void calendarTapped(CalendarTapDetails details) {
    if (details.targetElement == CalendarElement.appointment) {
      final Appointment appointmentDetails = details.appointments![0];
      String reserve = appointmentDetails.subject.split(',')[1];
      int blankCnt = int.parse(appointmentDetails.subject.split(',')[2]);
      String shiftFrameId = appointmentDetails.subject.split(',')[3];
      if (reserve == '1') return;
      if (blankCnt < 1) return;

      Navigator.push(context, MaterialPageRoute(builder: (_) {
        return ConnectReserveConfirm(
          reserveStatus: 1,
          reserveOrganId: widget.organ.organId,
          reserveStaffId: '',
          reserveStartTime: appointmentDetails.startTime,
          isNoReserveType: constCheckinReserveShift,
          shiftFrameId: shiftFrameId,
        );
      }));

      print(appointmentDetails.subject);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainForm(
      title: '予約',
      render: FutureBuilder<List>(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
                child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                  _getComments(),
                  _getReserveShiftComment(),
                  _getDateView(),
                  SizedBox(height: 8),
                  _getCalandarContent()
                ])));
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          // By default, show a loading spinner.
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _getComments() {
    return Container(
        padding: EdgeInsets.only(left: 30, top: 20),
        child: LeftSectionTitleText(label: '予約日と時間帯を選んでください'));
  }

  Widget _getDateView() {
    return Container(
      padding: EdgeInsets.only(left: 40),
      child: LeftSectionTitleText(
          label: DateFormat('y年M月').format(DateTime.parse(viewFromTime))),
    );
  }

  Widget _getReserveShiftComment() {
    var commentStyle = TextStyle(fontSize: 12);
    return Container(
      padding: EdgeInsets.only(left: 40),
      child: Column(
        children: [
          Row(
            children: [
              Text('〇', style: TextStyle(color: Colors.red)),
              SizedBox(width: 4),
              Text('空きがあります。', style: commentStyle)
            ],
          ),
          Row(
            children: [
              Text(' X', style: TextStyle(color: Colors.grey)),
              SizedBox(width: 4),
              Text('空きがありません。', style: commentStyle)
            ],
          )
        ],
      ),
    );
  }

  Widget _getCalandarContent() {
    return Container(
      height: sfCalanderHeight,
      child: Stack(
        children: [
          SafeArea(
            child: SfCalendar(
              headerHeight: 0,
              firstDayOfWeek: 1,
              view: CalendarView.week,
              todayHighlightColor: Colors.black,
              cellBorderColor: Color(0xffcccccc),
              timeSlotViewSettings: TimeSlotViewSettings(
                  dayFormat: '(E)',
                  timeInterval: Duration(hours: 1),
                  timeIntervalHeight: -1,
                  timeFormat: 'H:mm',
                  startHour: minHour.toDouble(),
                  // endHour: double.parse(organToTime.split(':')[0]) +
                  // (int.parse(organToTime.split(':')[1]) > 0 ? 1 : 0),
                  timeTextStyle: TextStyle(fontSize: 15, color: Colors.grey)),
              // specialRegions: regions,
              dataSource: _AppointmentDataSource(appointments),
              appointmentBuilder: appointmentBuilder,
              // timeRegionBuilder:
              //     (BuildContext context, TimeRegionDetails timeRegionDetails) =>
              //         timeRegionBuilder(timeRegionDetails),
              onTap: calendarTapped,
              onViewChanged: (d) => changeViewCalander(d.visibleDates[2]),
            ),
          ),
          Positioned(
              top: 52,
              left: 6,
              child: Container(
                child: Text(minHour.toString() + ':00',
                    style: TextStyle(
                        fontSize: 14.5,
                        color: Colors.grey,
                        letterSpacing: 0.5)),
              )),
        ],
      ),
    );
  }

  Widget timeRegionBuilder(timeRegionDetails) {
    return Container(
      height: 30,
      color: timeRegionDetails.region.color,
      alignment: Alignment.center,
      child: Text(
        timeRegionDetails.region.text.toString(),
        style: timeRegionDetails.region.textStyle,
      ),
    );
  }

  Widget appointmentBuilder(BuildContext context,
      CalendarAppointmentDetails calendarAppointmentDetails) {
    final Appointment appointment =
        calendarAppointmentDetails.appointments.first;

    String subject = appointment.subject;
    List memo = subject.split(',');
    String comment = memo[0] ?? '';
    String isReserve = memo[1] ?? '0';
    String blankCnt = memo[2] ?? '0';

    return Column(
      children: [
        Container(
          width: calendarAppointmentDetails.bounds.width,
          height: calendarAppointmentDetails.bounds.height * 3 / 4,
          color: appointment.color,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                DateFormat('HH:mm').format(appointment.startTime) +
                    '-' +
                    DateFormat('HH:mm').format(appointment.endTime),
                style: TextStyle(fontSize: 8),
              ),
              Text(
                comment,
                style: TextStyle(fontSize: 10),
              )
            ],
          ),
        ),
        Container(
          width: calendarAppointmentDetails.bounds.width,
          height: calendarAppointmentDetails.bounds.height / 4,
          color: appointment.color,
          child: Text(
            (isReserve == '1')
                ? '予約済み'
                : ((int.parse(blankCnt) > 0) ? '〇空き${blankCnt}席' : '満席'),
            style: TextStyle(fontSize: 8),
          ),
        ),
      ],
    );
  }
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
