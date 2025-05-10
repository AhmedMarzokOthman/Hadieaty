class FriendCardState {
  final bool isLoading;
  final int upcomingEventsCount;
  final String? error;
  final String? friendUid;

  FriendCardState({
    this.isLoading = false,
    this.upcomingEventsCount = 0,
    this.error,
    this.friendUid,
  });

  FriendCardState copyWith({
    bool? isLoading,
    int? upcomingEventsCount,
    String? error,
    String? friendUid,
  }) {
    return FriendCardState(
      isLoading: isLoading ?? this.isLoading,
      upcomingEventsCount: upcomingEventsCount ?? this.upcomingEventsCount,
      error: error ?? this.error,
      friendUid: friendUid ?? this.friendUid,
    );
  }
}
