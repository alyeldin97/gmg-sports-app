import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import 'core/di/dependency_injection.dart';
import 'core/localization/locale_cubit.dart';
import 'core/services/meta_pixel_service.dart';
import 'core/navigation/cubits/navigation_cubit.dart';
import 'core/styling/colors.dart';
import 'core/utils/configurations.dart';
import 'features/app_settings/presentation/cubits/app_settings_cubit.dart';
import 'features/auth/presentation/cubits/auth_cubit.dart';
import 'features/cart/presentation/cubits/cart_cubit.dart';
import 'features/collections/presentation/cubits/collections_cubit.dart';
import 'features/home/presentation/cubits/home_cubit.dart';
import 'features/orders/presentation/cubits/orders_cubit.dart';
import 'features/wishlist/presentation/cubits/wishlist_cubit.dart';
import 'l10n/app_localizations.dart';
import 'routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: AppConfigurations.supabaseUrl,
    anonKey: AppConfigurations.supabaseAnonKey,
  );
  runApp(const GmgApp());
}

class GmgApp extends StatelessWidget {
  const GmgApp({super.key});

  @override
  Widget build(BuildContext context) {
    final di = DependencyInjector();
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<LocaleCubit>(create: (_) => LocaleCubit()..load()),
            BlocProvider<AuthCubit>(create: (_) => di.authCubit),
            BlocProvider<CartCubit>(create: (_) => di.cartCubit),
            BlocProvider<NavigationCubit>(create: (_) => di.navigationCubit),
            BlocProvider<HomeCubit>(create: (_) => di.homeCubit..load()),
            BlocProvider<AppSettingsCubit>(create: (_) => di.appSettingsCubit..load()),
            BlocProvider<CollectionsCubit>(create: (_) => di.collectionsCubit..load()),
            BlocProvider<OrdersCubit>(create: (_) => di.ordersCubit),
            BlocProvider<WishlistCubit>(create: (_) => di.wishlistCubit),
          ],
          child: BlocBuilder<LocaleCubit, Locale>(
            builder: (context, locale) {
              return MaterialApp(
                title: 'GMG Sports',
                debugShowCheckedModeBanner: false,
                locale: locale,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [Locale('en'), Locale('ar')],
                theme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: AppColors.primary,
                    primary: AppColors.primary,
                  ),
                  scaffoldBackgroundColor: AppColors.scaffoldBg,
                  useMaterial3: true,
                ),
                navigatorObservers: [MetaPixelObserver()],
                onGenerateRoute: RouteGenerator.getRoute,
                initialRoute: RouteGenerator.initialRoute,
              );
            },
          ),
        );
      },
    );
  }
}
