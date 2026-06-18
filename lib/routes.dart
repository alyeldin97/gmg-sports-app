import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/dependency_injection.dart';
import 'features/address/presentation/screens/my_addresses_screen.dart';
import 'features/auth/presentation/screens/forgot_password_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/checkout/presentation/screens/checkout_screen.dart';
import 'features/checkout/presentation/screens/order_confirmed_screen.dart';
import 'features/collections/data/model/collection.dart';
import 'features/layout/presentation/screens/layout_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/orders/data/model/order.dart';
import 'features/orders/presentation/screens/order_details_screen.dart';
import 'features/products/data/model/product.dart';
import 'features/products/presentation/screens/product_details_screen.dart';
import 'features/products/presentation/screens/products_screen.dart';
import 'features/profile/presentation/screens/edit_profile_screen.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'features/coupon/presentation/cubits/coupon_cubit.dart';
import 'features/wishlist/presentation/screens/wishlist_screen.dart';

class RouteGenerator {
  static const String initialRoute = LayoutScreen.routeName;

  static Route<dynamic> getRoute(RouteSettings settings) {
    switch (settings.name) {
      case SplashScreen.routeName:
        return _page(const SplashScreen());

      case OnboardingScreen.routeName:
        return _page(const OnboardingScreen());

      case LoginScreen.routeName:
        return _page(const LoginScreen());

      case RegisterScreen.routeName:
        return _page(const RegisterScreen());

      case ForgotPasswordScreen.routeName:
        return _page(const ForgotPasswordScreen());

      case LayoutScreen.routeName:
        return MaterialPageRoute(settings: settings, builder: (_) => const LayoutScreen());

      case ProductsScreen.routeName:
        final collection = settings.arguments as Collection;
        return _page(ProductsScreen(collection: collection));

      case ProductDetailsScreen.routeName:
        final product = settings.arguments as Product;
        return _page(ProductDetailsScreen(product: product));

      case CheckoutScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => DependencyInjector().checkoutCubit),
              BlocProvider(create: (_) => DependencyInjector().governoratesCubit),
              BlocProvider(create: (_) => DependencyInjector().addressCubit),
              BlocProvider(create: (_) => DependencyInjector().appSettingsCubit),
              BlocProvider(create: (_) => DependencyInjector().couponCubit),
            ],
            child: const CheckoutScreen(),
          ),
        );

      case OrderConfirmedScreen.routeName:
        final order = settings.arguments as Order;
        return _page(OrderConfirmedScreen(order: order));

      case OrderDetailsScreen.routeName:
        final orderId = settings.arguments as String;
        return _page(OrderDetailsScreen(orderId: orderId));

      case MyAddressesScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => DependencyInjector().addressCubit..load(),
            child: const MyAddressesScreen(),
          ),
        );

      case WishlistScreen.routeName:
        return _page(const WishlistScreen());

      case EditProfileScreen.routeName:
        return _page(const EditProfileScreen());

      default:
        return _page(const Scaffold(body: Center(child: Text('Route not found'))));
    }
  }

  static Route<dynamic> _page(Widget child) => MaterialPageRoute(builder: (_) => child);
}
