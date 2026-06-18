// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'GMG Sports';

  @override
  String get navHome => 'Home';

  @override
  String get navShop => 'Shop';

  @override
  String get navCart => 'Cart';

  @override
  String get navOrders => 'Orders';

  @override
  String get navProfile => 'Profile';

  @override
  String get loading => 'Loading…';

  @override
  String get retry => 'Retry';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get search => 'Search';

  @override
  String get seeAll => 'See all';

  @override
  String get somethingWrong => 'Something went wrong. Please try again.';

  @override
  String get noInternet => 'No internet connection';

  @override
  String get currency => 'EGP';

  @override
  String get off => 'OFF';

  @override
  String get login => 'Log in';

  @override
  String get register => 'Create account';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get fullName => 'Full name';

  @override
  String get phone => 'Phone number';

  @override
  String get signIn => 'Sign in';

  @override
  String get signUp => 'Sign up';

  @override
  String get continueAsGuest => 'Continue as guest';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get resetPassword => 'Reset password';

  @override
  String get resetLinkSent => 'Password reset link sent to your email';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get logout => 'Log out';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to continue shopping';

  @override
  String get createAccountSubtitle => 'Join GMG Sports today';

  @override
  String get featured => 'Featured';

  @override
  String get collections => 'Collections';

  @override
  String get shopByCollection => 'Shop by collection';

  @override
  String get newArrivals => 'New arrivals';

  @override
  String get heroTitle => 'Gear up.\\nPlay harder.';

  @override
  String get addToCart => 'Add to cart';

  @override
  String get outOfStock => 'Out of stock';

  @override
  String get inStock => 'In stock';

  @override
  String get selectOption => 'Select option';

  @override
  String get description => 'Description';

  @override
  String get products => 'Products';

  @override
  String get noProducts => 'No products yet';

  @override
  String get added => 'Added to cart';

  @override
  String get cartEmpty => 'Your cart is empty';

  @override
  String get cartEmptyHint => 'Browse the shop and add your favourite gear.';

  @override
  String get startShopping => 'Start shopping';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get deliveryFee => 'Delivery fee';

  @override
  String get total => 'Total';

  @override
  String get free => 'Free';

  @override
  String get checkout => 'Checkout';

  @override
  String get clearCart => 'Clear cart';

  @override
  String get qty => 'Qty';

  @override
  String get deliveryAddress => 'Delivery address';

  @override
  String get selectAddress => 'Select an address';

  @override
  String get noAddressSelected => 'No address selected';

  @override
  String get deliveryDate => 'Delivery date';

  @override
  String get selectDate => 'Select a date';

  @override
  String get paymentMethod => 'Payment method';

  @override
  String get cod => 'Cash on delivery';

  @override
  String get codDesc => 'Pay with cash when your order arrives';

  @override
  String get instapay => 'InstaPay on delivery';

  @override
  String instapayDesc(Object handle) {
    return 'Pay via InstaPay to $handle when your order arrives';
  }

  @override
  String get orderNotes => 'Order notes (optional)';

  @override
  String get orderSummary => 'Order summary';

  @override
  String get placeOrder => 'Place order';

  @override
  String get orderPlaced => 'Order placed!';

  @override
  String get orderPlacedHint =>
      'Thank you. We\'ll start preparing your order right away.';

  @override
  String get viewOrder => 'View order';

  @override
  String get continueShopping => 'Continue shopping';

  @override
  String get guestCheckoutTitle => 'Sign in to checkout';

  @override
  String get guestCheckoutHint =>
      'You need an account to place and track orders.';

  @override
  String get myAddresses => 'My addresses';

  @override
  String get addAddress => 'Add address';

  @override
  String get editAddress => 'Edit address';

  @override
  String get addressLabel => 'Label (e.g. Home, Work)';

  @override
  String get city => 'City';

  @override
  String get area => 'Area';

  @override
  String get street => 'Street';

  @override
  String get building => 'Building';

  @override
  String get apartment => 'Apartment';

  @override
  String get notes => 'Notes';

  @override
  String get setAsDefault => 'Set as default';

  @override
  String get defaultAddress => 'Default';

  @override
  String get noAddresses => 'No saved addresses';

  @override
  String get addressSaved => 'Address saved';

  @override
  String get myOrders => 'My orders';

  @override
  String get orderDetails => 'Order details';

  @override
  String get noOrders => 'You have no orders yet';

  @override
  String get orderTracking => 'Order tracking';

  @override
  String get orderItems => 'Items';

  @override
  String orderNumber(Object id) {
    return 'Order #$id';
  }

  @override
  String placedOn(Object date) {
    return 'Placed on $date';
  }

  @override
  String get statusPending => 'Pending';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusProcessing => 'Processing';

  @override
  String get statusOutForDelivery => 'Out for delivery';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get account => 'Account';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get guestUser => 'Guest';

  @override
  String get guestPrompt => 'Sign in to sync your cart and track orders.';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get cancelOrder => 'Cancel Order';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get noCollections => 'No collections yet';

  @override
  String get clearCartConfirm => 'Remove all items from your cart?';

  @override
  String get cancelOrderConfirm => 'Are you sure you want to cancel this order?';

  @override
  String get cancelledSuccessfully => 'Order cancelled successfully';

  @override
  String get deleteAddressConfirm => 'Delete this address?';

  @override
  String get addressDeleted => 'Address deleted';

  @override
  String get contactInfo => 'Contact Information';

  @override
  String get deliveryInfo => 'Delivery Information';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get governorate => 'Governorate';

  @override
  String get selectGovernorate => 'Select governorate';

  @override
  String get shippingCost => 'Shipping';

  @override
  String get shippingUnavailable => 'Shipping not available to this governorate';

  @override
  String get useSavedAddress => 'Use saved address';

  @override
  String get requiredField => 'Required';

  @override
  String get invalidEmail => 'Enter a valid email';

  @override
  String get shipping => 'Shipping';

  @override
  String deliveryIn(int days) => 'Delivery in $days day${days == 1 ? '' : 's'}';
}
