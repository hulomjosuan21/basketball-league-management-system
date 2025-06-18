enum MatchStatus {
  scheduled('Scheduled'),
  ongoing('Ongoing'),
  completed('Completed'),
  postponed('Postponed'),
  cancelled('Cancelled');

  final String value;
  const MatchStatus(this.value);
}
