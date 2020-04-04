class Test {
  final String subject;
  final int complexity; // how difficult is for the user 1 to 5
  final int importance;
  final String description;
  final DateTime dueDate;
  final String testId;
  final bool isAllocated;
  final String calendarEventId;
  final DateTime start;
  final DateTime end;
  final String calendarToUse;

  Test(
      {this.calendarToUse,
      this.subject,
      this.complexity,
      this.importance,
      this.description,
      this.dueDate,
      this.testId,
      this.isAllocated,
      this.calendarEventId,
      this.start,
      this.end});

  @override
  String toString() {
    return "Description: $description TestId:$testId CalendarId:$calendarEventId Start: $start End: $end";
  }
}
