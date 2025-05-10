class PledgeState {
  final bool isLoading;
  final List<Map<String, dynamic>> pledgedGifts;
  final String? error;

  PledgeState({
    this.isLoading = false,
    this.pledgedGifts = const [],
    this.error,
  });

  PledgeState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? pledgedGifts,
    String? error,
  }) {
    return PledgeState(
      isLoading: isLoading ?? this.isLoading,
      pledgedGifts: pledgedGifts ?? this.pledgedGifts,
      error: error ?? this.error,
    );
  }
}
