import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/address/data/remote/address_data_source.dart';
import '../../features/address/data/remote/impl/supabase_address_data_source.dart';
import '../../features/address/data/repo/address_repository.dart';
import '../../features/address/data/repo/address_repository_impl.dart';
import '../../features/address/presentation/cubits/address_cubit.dart';
import '../../features/app_settings/data/remote/app_settings_data_source.dart';
import '../../features/app_settings/data/remote/impl/supabase_app_settings_data_source.dart';
import '../../features/app_settings/data/repo/app_settings_repository.dart';
import '../../features/app_settings/data/repo/app_settings_repository_impl.dart';
import '../../features/app_settings/presentation/cubits/app_settings_cubit.dart';
import '../../features/auth/data/remote/auth_data_source.dart';
import '../../features/auth/data/remote/impl/supabase_auth_data_source.dart';
import '../../features/auth/data/repo/auth_repository.dart';
import '../../features/auth/data/repo/auth_repository_impl.dart';
import '../../features/auth/presentation/cubits/auth_cubit.dart';
import '../../features/cart/data/local/cart_local_data_source.dart';
import '../../features/cart/presentation/cubits/cart_cubit.dart';
import '../../features/checkout/data/repo/governorates_repository.dart';
import '../../features/checkout/presentation/cubits/checkout_cubit.dart';
import '../../features/checkout/presentation/cubits/governorates_cubit.dart';
import '../../features/collections/data/remote/collections_data_source.dart';
import '../../features/collections/data/remote/impl/supabase_collections_data_source.dart';
import '../../features/collections/data/repo/collections_repository.dart';
import '../../features/collections/data/repo/collections_repository_impl.dart';
import '../../features/collections/presentation/cubits/collections_cubit.dart';
import '../../features/home/data/remote/home_data_source.dart';
import '../../features/home/data/remote/impl/supabase_home_data_source.dart';
import '../../features/home/data/repo/home_repository.dart';
import '../../features/home/data/repo/home_repository_impl.dart';
import '../../features/home/presentation/cubits/home_cubit.dart';
import '../../features/orders/data/remote/impl/supabase_orders_data_source.dart';
import '../../features/orders/data/remote/orders_data_source.dart';
import '../../features/orders/data/repo/orders_repository.dart';
import '../../features/orders/data/repo/orders_repository_impl.dart';
import '../../features/orders/presentation/cubits/orders_cubit.dart';
import '../../features/products/data/remote/impl/supabase_products_data_source.dart';
import '../../features/products/data/remote/products_data_source.dart';
import '../../features/products/data/repo/products_repository.dart';
import '../../features/products/data/repo/products_repository_impl.dart';
import '../../features/products/presentation/cubits/products_cubit.dart';
import '../navigation/cubits/navigation_cubit.dart';

class DependencyInjector {
  static final DependencyInjector _singleton = DependencyInjector._internal();
  static final Map<Type, dynamic> _deps = {};

  factory DependencyInjector() => _singleton;
  DependencyInjector._internal();

  SupabaseClient get _supabase => Supabase.instance.client;

  // Auth
  AuthDataSource get authDataSource =>
      _deps[AuthDataSource] ??= SupabaseAuthDataSource(_supabase);
  AuthRepository get authRepository =>
      _deps[AuthRepository] ??= AuthRepositoryImpl(authDataSource);
  AuthCubit get authCubit => _deps[AuthCubit] ??= AuthCubit(authRepository);

  // Collections
  CollectionsDataSource get collectionsDataSource =>
      _deps[CollectionsDataSource] ??= SupabaseCollectionsDataSource(_supabase);
  CollectionsRepository get collectionsRepository =>
      _deps[CollectionsRepository] ??= CollectionsRepositoryImpl(collectionsDataSource);
  CollectionsCubit get collectionsCubit => CollectionsCubit(collectionsRepository);

  // Products
  ProductsDataSource get productsDataSource =>
      _deps[ProductsDataSource] ??= SupabaseProductsDataSource(_supabase);
  ProductsRepository get productsRepository =>
      _deps[ProductsRepository] ??= ProductsRepositoryImpl(productsDataSource);
  ProductsCubit get productsCubit => ProductsCubit(productsRepository);

  // Home
  HomeDataSource get homeDataSource =>
      _deps[HomeDataSource] ??= SupabaseHomeDataSource(_supabase);
  HomeRepository get homeRepository =>
      _deps[HomeRepository] ??= HomeRepositoryImpl(homeDataSource);
  HomeCubit get homeCubit => HomeCubit(homeRepository, productsRepository, collectionsRepository);

  // Cart
  CartLocalDataSource get cartLocalDataSource =>
      _deps[CartLocalDataSource] ??= CartLocalDataSource();
  CartCubit get cartCubit => _deps[CartCubit] ??= CartCubit(cartLocalDataSource);

  // Address
  AddressDataSource get addressDataSource =>
      _deps[AddressDataSource] ??= SupabaseAddressDataSource(_supabase);
  AddressRepository get addressRepository =>
      _deps[AddressRepository] ??= AddressRepositoryImpl(addressDataSource);
  AddressCubit get addressCubit => AddressCubit(addressRepository);

  // App settings
  AppSettingsDataSource get appSettingsDataSource =>
      _deps[AppSettingsDataSource] ??= SupabaseAppSettingsDataSource(_supabase);
  AppSettingsRepository get appSettingsRepository =>
      _deps[AppSettingsRepository] ??= AppSettingsRepositoryImpl(appSettingsDataSource);
  AppSettingsCubit get appSettingsCubit => AppSettingsCubit(appSettingsRepository);

  // Orders
  OrdersDataSource get ordersDataSource =>
      _deps[OrdersDataSource] ??= SupabaseOrdersDataSource(_supabase);
  OrdersRepository get ordersRepository =>
      _deps[OrdersRepository] ??= OrdersRepositoryImpl(ordersDataSource);
  OrdersCubit get ordersCubit => OrdersCubit(ordersRepository);

  // Checkout
  CheckoutCubit get checkoutCubit => CheckoutCubit(ordersRepository);
  GovernoratesRepository get governoratesRepository =>
      _deps[GovernoratesRepository] ??= GovernoratesRepository(_supabase);
  GovernoratesCubit get governoratesCubit => GovernoratesCubit(governoratesRepository);

  // Navigation
  NavigationCubit get navigationCubit => _deps[NavigationCubit] ??= NavigationCubit();
}
