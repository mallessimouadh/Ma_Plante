class DashboardStats {
  final int totalUsers;
  final int activeUsers;
  final int totalScans;
  final int diseasesDetected;
  final int reclamationsOpen;
  final int reclamationsResolved;

  DashboardStats({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalScans,
    required this.diseasesDetected,
    required this.reclamationsOpen,
    required this.reclamationsResolved,
  });
}
