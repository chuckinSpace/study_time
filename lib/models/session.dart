class Session {
  String testId;
  int sessionNumber;
  DateTime start;
  DateTime end;
  DateTime eventDate;
  String uid;
  String description;

  Session(
      {this.eventDate,
      this.description,
      this.end,
      this.sessionNumber,
      this.start,
      this.testId,
      this.uid});

  @override
  String toString() {
    return "Description: $description TestId:$testId Start: $start End: $end Session Num: $sessionNumber";
  }
}
