class User {
  final String uid;

  User({this.uid});
}

class UserData {
  String uid;
  String calendarToUse;
  bool isConfigured;
  String calendarToUseName;
  String email;
  bool nightOwl;
  int sweetSpotStart;
  int sweetSpotEnd;
  int morning;
  int night;

  UserData(
      {this.calendarToUseName,
      this.isConfigured,
      this.calendarToUse,
      this.uid,
      this.morning,
      this.night,
      this.email,
      this.nightOwl,
      this.sweetSpotEnd,
      this.sweetSpotStart});
}
