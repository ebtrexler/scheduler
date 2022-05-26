String formatIsoDateTime(String isoDateTime, bool aMpM) {
  DateTime dt = DateTime.parse(isoDateTime);
  return formatDateTime(dt, aMpM);
}

String formatDateTime(DateTime dt, bool aMpM) {
  var month = dt.month.toString().padLeft(2, '0');
  var day = dt.day.toString().padLeft(2, '0');
  var hour = dt.hour.toString().padLeft(2, '0');
  var minute = dt.minute.toString().padLeft(2, '0');
  if (aMpM) {
    if (dt.hour > 12) {
      hour = (dt.hour - 12).toString().padLeft(2, '0');
      minute = "$minute PM";
    } else {
      minute = "$minute AM";
    }
  }

  return "${dt.year}-$month-$day $hour:$minute";
}
