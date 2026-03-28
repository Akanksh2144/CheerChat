// // // // // lib/providers/follow_provider.dart
// // // // //
// // // // // Global follow state — tracks which hosts the current user follows.
// // // // // Both host_card and profile_details_screen read/write from this provider,
// // // // // so follow state stays in sync across screens.

// // // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // // import 'package:cheerchat/services/social_service.dart';

// // // // /// Tracks follow state for individual hosts by userId.
// // // // /// Returns true if the current user follows that host.
// // // // final followStateProvider =
// // // //     StateNotifierProvider.family<FollowNotifier, bool, String>(
// // // //       (ref, hostUserId) => FollowNotifier(ref, hostUserId),
// // // //     );

// // // // class FollowNotifier extends StateNotifier<bool> {
// // // //   final Ref _ref;
// // // //   final String _hostUserId;

// // // //   FollowNotifier(this._ref, this._hostUserId) : super(false);

// // // //   /// Set initial state (e.g. from API response)
// // // //   void setInitial(bool isFollowed) {
// // // //     if (state != isFollowed) {
// // // //       state = isFollowed;
// // // //     }
// // // //   }

// // // //   /// Toggle follow — optimistic UI + revert on failure
// // // //   Future<void> toggle() async {
// // // //     final wasFollowed = state;
// // // //     state = !wasFollowed;

// // // //     final social = _ref.read(socialServiceProvider);
// // // //     final future = state
// // // //         ? social.follow(_hostUserId)
// // // //         : social.unfollow(_hostUserId);

// // // //     final ok = await future;
// // // //     if (!ok) {
// // // //       state = wasFollowed; // revert
// // // //     }
// // // //   }
// // // // }
// // // // lib/providers/follow_provider.dart
// // // //
// // // // Global follow state — tracks which hosts the current user follows.
// // // // Both host_card and profile_details_screen read/write from this provider,
// // // // so follow state stays in sync across screens.

// // // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // // import 'package:cheerchat/services/social_service.dart';

// // // // /// Tracks follow state for individual hosts by userId.
// // // // final followStateProvider =
// // // //     NotifierProvider.family<FollowNotifier, bool, String>(
// // // //   FollowNotifier.new,
// // // // );

// // // // class FollowNotifier extends FamilyNotifier<bool, String> {
// // // //   @override
// // // //   bool build(String hostUserId) => false;

// // // //   /// Set initial state (e.g. from API response)
// // // //   void setInitial(bool isFollowed) {
// // // //     if (state != isFollowed) {
// // // //       state = isFollowed;
// // // //     }
// // // //   }

// // // //   /// Toggle follow — optimistic UI + revert on failure
// // // //   Future<void> toggle() async {
// // // //     final wasFollowed = state;
// // // //     state = !wasFollowed;

// // // //     final social = ref.read(socialServiceProvider);
// // // //     final future = state
// // // //         ? social.follow(arg)
// // // //         : social.unfollow(arg);

// // // //     final ok = await future;
// // // //     if (!ok) {
// // // //       state = wasFollowed; // revert
// // // //     }
// // // //   }
// // // // }
// // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // import 'package:cheerchat/services/social_service.dart';

// // // /// Tracks follow state for individual hosts by userId.
// // // final followStateProvider =
// // //     NotifierProvider.family<FollowNotifier, bool, String>(
// // //       FollowNotifier.new,
// // //     );

// // // class FollowNotifier extends FamilyNotifier<bool, String> {
// // //   @override
// // //   bool build(String hostUserId) => false;

// // //   /// Set initial state (e.g. from API response)
// // //   void setInitial(bool isFollowed) {
// // //     if (state != isFollowed) {
// // //       state = isFollowed;
// // //     }
// // //   }

// // //   /// Toggle follow — optimistic UI + revert on failure
// // //   Future<void> toggle() async {
// // //     final wasFollowed = state;
// // //     state = !wasFollowed;

// // //     try {
// // //       final social = ref.read(socialServiceProvider);
// // //       final ok = await (state
// // //           ? social.follow(arg)
// // //           : social.unfollow(arg));

// // //       if (!ok) {
// // //         state = wasFollowed; // revert on API rejection
// // //       }
// // //     } catch (e) {
// // //       state = wasFollowed; // revert on network error/exception
// // //     }
// // //   }
// // // }
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:cheerchat/services/social_service.dart';

// // /// Tracks follow state for individual hosts by userId.
// // final followStateProvider =
// //     StateNotifierProvider.family<FollowNotifier, bool, String>(
// //       (ref, hostUserId) => FollowNotifier(ref, hostUserId),
// //     );

// // class FollowNotifier extends StateNotifier<bool> {
// //   FollowNotifier(this.ref, this.hostUserId) : super(false);

// //   final Ref ref;
// //   final String hostUserId;

// //   /// Set initial state (e.g. from API response)
// //   void setInitial(bool isFollowed) {
// //     if (state != isFollowed) {
// //       state = isFollowed;
// //     }
// //   }

// //   /// Toggle follow — optimistic UI + revert on failure
// //   Future<void> toggle() async {
// //     final wasFollowed = state;
// //     state = !wasFollowed;

// //     try {
// //       final social = ref.read(socialServiceProvider);
// //       final ok = await (state
// //           ? social.follow(hostUserId)
// //           : social.unfollow(hostUserId));

// //       if (!ok) {
// //         state = wasFollowed; // revert on API rejection
// //       }
// //     } catch (e) {
// //       state = wasFollowed; // revert on network error/exception
// //     }
// //   }
// // }
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:cheerchat/services/social_service.dart';

// // Watch state in UI: final isFollowed = ref.watch(followStateProvider(hostUserId));
// final followStateProvider = Provider.family<bool, String>((
//   ref,
//   hostUserId,
// ) {
//   return ref.watch(followNotifierProvider)[hostUserId] ?? false;
// });

// // Trigger actions in UI: ref.read(followNotifierProvider.notifier).toggle(hostUserId);
// final followNotifierProvider =
//     NotifierProvider<FollowNotifier, Map<String, bool>>(
//       FollowNotifier.new,
//     );

// class FollowNotifier extends Notifier<Map<String, bool>> {
//   @override
//   Map<String, bool> build() => {};

//   void setInitial(String hostUserId, bool isFollowed) {
//     if (state[hostUserId] != isFollowed) {
//       state = {...state, hostUserId: isFollowed};
//     }
//   }

//   Future<void> toggle(String hostUserId) async {
//     final wasFollowed = state[hostUserId] ?? false;
//     state = {...state, hostUserId: !wasFollowed};

//     try {
//       final social = ref.read(socialServiceProvider);
//       final ok = await (!wasFollowed
//           ? social.follow(hostUserId)
//           : social.unfollow(hostUserId));

//       if (!ok) {
//         state = {
//           ...state,
//           hostUserId: wasFollowed,
//         }; // revert on API rejection
//       }
//     } catch (e) {
//       state = {
//         ...state,
//         hostUserId: wasFollowed,
//       }; // revert on network error/exception
//     }
//   }
// }
// // // // lib/providers/follow_provider.dart
// // // //
// // // // Global follow state — tracks which hosts the current user follows.
// // // // Both host_card and profile_details_screen read/write from this provider,
// // // // so follow state stays in sync across screens.

// // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // import 'package:cheerchat/services/social_service.dart';

// // // /// Tracks follow state for individual hosts by userId.
// // // /// Returns true if the current user follows that host.
// // // final followStateProvider =
// // //     StateNotifierProvider.family<FollowNotifier, bool, String>(
// // //       (ref, hostUserId) => FollowNotifier(ref, hostUserId),
// // //     );

// // // class FollowNotifier extends StateNotifier<bool> {
// // //   final Ref _ref;
// // //   final String _hostUserId;

// // //   FollowNotifier(this._ref, this._hostUserId) : super(false);

// // //   /// Set initial state (e.g. from API response)
// // //   void setInitial(bool isFollowed) {
// // //     if (state != isFollowed) {
// // //       state = isFollowed;
// // //     }
// // //   }

// // //   /// Toggle follow — optimistic UI + revert on failure
// // //   Future<void> toggle() async {
// // //     final wasFollowed = state;
// // //     state = !wasFollowed;

// // //     final social = _ref.read(socialServiceProvider);
// // //     final future = state
// // //         ? social.follow(_hostUserId)
// // //         : social.unfollow(_hostUserId);

// // //     final ok = await future;
// // //     if (!ok) {
// // //       state = wasFollowed; // revert
// // //     }
// // //   }
// // // }
// // // lib/providers/follow_provider.dart
// // //
// // // Global follow state — tracks which hosts the current user follows.
// // // Both host_card and profile_details_screen read/write from this provider,
// // // so follow state stays in sync across screens.

// // // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // // import 'package:cheerchat/services/social_service.dart';

// // // /// Tracks follow state for individual hosts by userId.
// // // final followStateProvider =
// // //     NotifierProvider.family<FollowNotifier, bool, String>(
// // //   FollowNotifier.new,
// // // );

// // // class FollowNotifier extends FamilyNotifier<bool, String> {
// // //   @override
// // //   bool build(String hostUserId) => false;

// // //   /// Set initial state (e.g. from API response)
// // //   void setInitial(bool isFollowed) {
// // //     if (state != isFollowed) {
// // //       state = isFollowed;
// // //     }
// // //   }

// // //   /// Toggle follow — optimistic UI + revert on failure
// // //   Future<void> toggle() async {
// // //     final wasFollowed = state;
// // //     state = !wasFollowed;

// // //     final social = ref.read(socialServiceProvider);
// // //     final future = state
// // //         ? social.follow(arg)
// // //         : social.unfollow(arg);

// // //     final ok = await future;
// // //     if (!ok) {
// // //       state = wasFollowed; // revert
// // //     }
// // //   }
// // // }
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:cheerchat/services/social_service.dart';

// // /// Tracks follow state for individual hosts by userId.
// // final followStateProvider =
// //     NotifierProvider.family<FollowNotifier, bool, String>(
// //       FollowNotifier.new,
// //     );

// // class FollowNotifier extends FamilyNotifier<bool, String> {
// //   @override
// //   bool build(String hostUserId) => false;

// //   /// Set initial state (e.g. from API response)
// //   void setInitial(bool isFollowed) {
// //     if (state != isFollowed) {
// //       state = isFollowed;
// //     }
// //   }

// //   /// Toggle follow — optimistic UI + revert on failure
// //   Future<void> toggle() async {
// //     final wasFollowed = state;
// //     state = !wasFollowed;

// //     try {
// //       final social = ref.read(socialServiceProvider);
// //       final ok = await (state
// //           ? social.follow(arg)
// //           : social.unfollow(arg));

// //       if (!ok) {
// //         state = wasFollowed; // revert on API rejection
// //       }
// //     } catch (e) {
// //       state = wasFollowed; // revert on network error/exception
// //     }
// //   }
// // }
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:cheerchat/services/social_service.dart';

// /// Tracks follow state for individual hosts by userId.
// final followStateProvider =
//     StateNotifierProvider.family<FollowNotifier, bool, String>(
//       (ref, hostUserId) => FollowNotifier(ref, hostUserId),
//     );

// class FollowNotifier extends StateNotifier<bool> {
//   FollowNotifier(this.ref, this.hostUserId) : super(false);

//   final Ref ref;
//   final String hostUserId;

//   /// Set initial state (e.g. from API response)
//   void setInitial(bool isFollowed) {
//     if (state != isFollowed) {
//       state = isFollowed;
//     }
//   }

//   /// Toggle follow — optimistic UI + revert on failure
//   Future<void> toggle() async {
//     final wasFollowed = state;
//     state = !wasFollowed;

//     try {
//       final social = ref.read(socialServiceProvider);
//       final ok = await (state
//           ? social.follow(hostUserId)
//           : social.unfollow(hostUserId));

//       if (!ok) {
//         state = wasFollowed; // revert on API rejection
//       }
//     } catch (e) {
//       state = wasFollowed; // revert on network error/exception
//     }
//   }
// }
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cheerchat/services/social_service.dart';

// Watch state in UI: final isFollowed = ref.watch(followStateProvider(hostUserId));
final followStateProvider = Provider.family<bool, String>((
  ref,
  hostUserId,
) {
  return ref.watch(followNotifierProvider)[hostUserId] ?? false;
});

// Trigger actions in UI: ref.read(followNotifierProvider.notifier).toggle(hostUserId);
final followNotifierProvider =
    NotifierProvider<FollowNotifier, Map<String, bool>>(
      FollowNotifier.new,
    );

class FollowNotifier extends Notifier<Map<String, bool>> {
  @override
  Map<String, bool> build() => {};

  void setInitial(String hostUserId, bool isFollowed) {
    if (state[hostUserId] != isFollowed) {
      // Must use [] operator — Dart map literals treat `hostUserId:` as a literal key
      state = Map<String, bool>.of(state)
        ..[hostUserId] = isFollowed;
    }
  }

  Future<void> toggle(String hostUserId) async {
    final wasFollowed = state[hostUserId] ?? false;
    state = Map<String, bool>.of(state)
      ..[hostUserId] = !wasFollowed;

    try {
      final social = ref.read(socialServiceProvider);
      final ok = await (!wasFollowed
          ? social.follow(hostUserId)
          : social.unfollow(hostUserId));

      if (!ok) {
        state = Map<String, bool>.of(state)
          ..[hostUserId] = wasFollowed;
      }
    } catch (e) {
      state = Map<String, bool>.of(state)
        ..[hostUserId] = wasFollowed;
    }
  }
}
