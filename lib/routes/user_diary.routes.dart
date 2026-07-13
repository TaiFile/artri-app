import 'package:artriapp/models/index.dart';
import 'package:artriapp/views/index.dart';
import 'package:go_router/go_router.dart';

abstract class UserDiaryRoutes implements RoutesSession {
  static const String diary = '/diary';
  static const String fatigueSelectionPage = '$diary/fatigue-selection';
  static const String sleepSelectionPage = '$diary/sleep-selection';
  static const String swellingSelectionPage = '$diary/swelling-selection';
  static const String painSelectionPage = '$diary/pain-selection';
  static const String settings = '$diary/settings';

  static List<RouteBase> getGoRoutes() => [
        GoRoute(
          path: diary,
          pageBuilder: (context, state) => NoTransitionPage(
            child: UserDiaryInitialSelection(),
          ),
          routes: [
            GoRoute(
              path: 'fatigue-selection',
              pageBuilder: (context, state) => NoTransitionPage(
                child: const FatigueSelectionPage(),
              ),
            ),
            GoRoute(
              path: 'pain-selection',
              pageBuilder: (context, state) => NoTransitionPage(
                child: UserLevelSelectionWithOptions(
                  title: 'Dor',
                ),
              ),
            ),
            GoRoute(
              path: 'sleep-selection',
              pageBuilder: (context, state) => NoTransitionPage(
                child: const UserLevelSelection(
                  title: 'Sono',
                  description: 'De 0 a 10, como esta seu nível de sono hoje?',
                ),
              ),
            ),
            GoRoute(
              path: 'swelling-selection',
              pageBuilder: (context, state) => NoTransitionPage(
                child: UserLevelSelectionWithOptions(
                  title: 'Inchaço',
                  tooltipMessage:
                      'Inchaço é quando uma parte do corpo parece maior ou mais “cheia” do que o normal, como se estivesse acumulando líquido ou inflamada. A região inchada pode ficar mais dura, quente, avermelhada ou sensível ao toque.',
                ),
              ),
            ),
          ],
        ),
        GoRoute(
          path: settings,
          pageBuilder: (context, state) => NoTransitionPage(
            child: LoggedSettingsPage(),
          ),
        ),
      ];
}
