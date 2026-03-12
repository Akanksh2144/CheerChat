// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:cheerchat/screens_notcompleted/ongoing_call_screen.dart';
// import 'package:mocktail/mocktail.dart';
// // import 'package:cheerchat/screens_notcompleted/ongoing_call_screen.dart'; // Update with your actual path
// import 'package:cheerchat/services/agora_service.dart'; // Update with your actual path

// // 1. Create the Mock Service
// class MockAgoraService extends Mock implements AgoraService {}

// void main() {
//   late MockAgoraService mockAgoraService;
//   late ValueNotifier<Set<int>> mockRemoteUids;
//   late ValueNotifier<bool> mockIsAudioMuted;
//   late ValueNotifier<bool> mockIsVideoMuted;

//   setUp(() {
//     mockAgoraService = MockAgoraService();

//     // 2. Initialize the reactive state for our mock
//     mockRemoteUids = ValueNotifier(<int>{});
//     mockIsAudioMuted = ValueNotifier(false);
//     mockIsVideoMuted = ValueNotifier(false);

//     // 3. Stub the getters to return our mock state
//     when(
//       () => mockAgoraService.remoteUids,
//     ).thenReturn(mockRemoteUids);
//     when(
//       () => mockAgoraService.isAudioMuted,
//     ).thenReturn(mockIsAudioMuted);
//     when(
//       () => mockAgoraService.isVideoMuted,
//     ).thenReturn(mockIsVideoMuted);

//     // 4. Stub the async network calls so they return immediately without crashing
//     when(
//       () => mockAgoraService.initialize(
//         appId: any(named: 'appId'),
//         fetchNewToken: any(named: 'fetchNewToken'),
//       ),
//     ).thenAnswer((_) async {});

//     when(
//       () => mockAgoraService.join(
//         token: any(named: 'token'),
//         channelId: any(named: 'channelId'),
//         uid: any(named: 'uid'),
//       ),
//     ).thenAnswer((_) async {});

//     when(
//       () => mockAgoraService.leave(),
//     ).thenAnswer((_) async {});

//     // 5. Stub the UI builders to return dummy widgets for the test environment
//     when(() => mockAgoraService.buildLocalVideo()).thenReturn(
//       const SizedBox(key: Key('local_video_placeholder')),
//     );
//     when(
//       () => mockAgoraService.buildRemoteVideo(any()),
//     ).thenReturn(
//       const SizedBox(key: Key('remote_video_placeholder')),
//     );
//   });

//   Widget buildTestableWidget() {
//     return MaterialApp(
//       home: OngoingCallScreen(
//         agoraService: mockAgoraService,
//         channelId: 'test_channel',
//         token: 'test_token',
//         localUid: 1,
//       ),
//     );
//   }

//   group('OngoingCallScreen Widget Tests', () {
//     testWidgets(
//       'Renders loading screen initially, then displays call UI',
//       (WidgetTester tester) async {
//         await tester.pumpWidget(buildTestableWidget());

//         // At first, it should show the connecting text
//         expect(
//           find.text('Securing connection...'),
//           findsOneWidget,
//         );
//         expect(
//           find.byType(CircularProgressIndicator),
//           findsOneWidget,
//         );

//         // Wait for _startCall() futures to resolve and trigger setState
//         await tester.pumpAndSettle();

//         // Loading UI should be gone
//         expect(
//           find.text('Securing connection...'),
//           findsNothing,
//         );

//         // Local video placeholder should be visible
//         expect(
//           find.byKey(const Key('local_video_placeholder')),
//           findsOneWidget,
//         );

//         // Since no remote user has joined yet, it should show the waiting text
//         expect(
//           find.text('Waiting for user to join...'),
//           findsOneWidget,
//         );
//       },
//     );

//     testWidgets('Renders remote video when a user joins', (
//       WidgetTester tester,
//     ) async {
//       await tester.pumpWidget(buildTestableWidget());
//       await tester.pumpAndSettle();

//       // Simulate a remote user joining by updating the ValueNotifier
//       mockRemoteUids.value = {999};

//       // Pump the widget to rebuild the ValueListenableBuilder
//       await tester.pump();

//       // The waiting text should disappear
//       expect(
//         find.text('Waiting for user to join...'),
//         findsNothing,
//       );

//       // The remote video placeholder should appear
//       expect(
//         find.byKey(const Key('remote_video_placeholder')),
//         findsOneWidget,
//       );

//       // Verify the service was asked to build the video for UID 999
//       verify(
//         () => mockAgoraService.buildRemoteVideo(999),
//       ).called(1);
//     });

//     testWidgets(
//       'Tapping the end call button calls leave() and pops the screen',
//       (WidgetTester tester) async {
//         await tester.pumpWidget(buildTestableWidget());
//         await tester.pumpAndSettle();

//         // Find and tap the end call button
//         final endCallButton = find.byIcon(Icons.call_end);
//         expect(endCallButton, findsOneWidget);
//         await tester.tap(endCallButton);
//         await tester.pumpAndSettle();

//         // Verify the service's leave method was triggered
//         verify(() => mockAgoraService.leave()).called(1);
//       },
//     );
//   });
// }
