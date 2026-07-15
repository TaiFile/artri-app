import 'package:artriapp/services/index.dart';
import 'package:artriapp/utils/interceptors/index.dart';
import 'package:artriapp/view_models/index.dart';
import 'package:artriapp/view_models/remedy_view_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:artriapp/view_models/diary_view_model.dart';

class GlobalProviders {
  final _serviceProviders = <SingleChildWidget>[
    Provider(create: (context) => AuthService()),
    Provider(create: (context) => SecurityTokenService()),
    Provider(create: (context) => PhysicalExercisesService()), 
    Provider<http.Client>(
      create: (context) => InterceptedClient.build(
        interceptors: [
          AuthInterceptor(
            Provider.of<SecurityTokenService>(context, listen: false),
          ),
        ],
        retryPolicy: RefreshTokenPolicy(
          Provider.of<AuthService>(context, listen: false),
          Provider.of<SecurityTokenService>(context, listen: false),
        ),
      ),
    ),
    Provider(
      create: (context) => ReportsService(
        Provider.of<http.Client>(context, listen: false),
      ),
    ),
    Provider(
      create: (context) => RemedyService(
        Provider.of<http.Client>(context, listen: false),
      ),
    ),
  ];

  final _viewModelProviders = <SingleChildWidget>[
    ChangeNotifierProvider(
      create: (context) => LoginViewModel(
        Provider.of<AuthService>(context, listen: false),
        Provider.of<SecurityTokenService>(context, listen: false),
      ),
    ),
    ChangeNotifierProvider(
      create: (context) => PhysicalExercisesViewModel(
        Provider.of<PhysicalExercisesService>(context, listen: false),
      ),
    ),
    ChangeNotifierProvider(
      create: (context) => CustomExercisesViewModel(
        Provider.of<PhysicalExercisesService>(context, listen: false),
      ),
    ),
    ChangeNotifierProvider(
      create: (context) => RemedyViewModel(
        Provider.of<RemedyService>(context, listen: false),
      ),
    ),
    ChangeNotifierProvider(
      create: (context) => DiaryViewModel(
        Provider.of<http.Client>(context, listen: false),
      ),
    ),
    ChangeNotifierProvider(
      create: (context) => EvolutionViewModel(
        Provider.of<ReportsService>(context, listen: false),
      ),
    ),
  ];

  static List<SingleChildWidget> getProviders() {
    return GlobalProviders()
        ._serviceProviders
        .followedBy(GlobalProviders()._viewModelProviders)
        .toList();
  }
}
