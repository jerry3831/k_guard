class DashboardStats {
  final int totalScans;
  final int authenticCount;
  final int suspiciousCount;
  final int thisWeekCount;

  const DashboardStats({
    required this.totalScans,
    required this.authenticCount,
    required this.suspiciousCount,
    required this.thisWeekCount,
  });

  const DashboardStats.empty()
      : totalScans = 0,
        authenticCount = 0,
        suspiciousCount = 0,
        thisWeekCount = 0;
}
