sealed class SyncStatus {
  const SyncStatus();
}

class SyncIdle extends SyncStatus {
  const SyncIdle();
}

class SyncRunning extends SyncStatus {
  const SyncRunning();
}

class SyncSuccess extends SyncStatus {
  final int completedAt;

  const SyncSuccess(this.completedAt);
}

class SyncError extends SyncStatus {
  final String message;

  const SyncError(this.message);
}
