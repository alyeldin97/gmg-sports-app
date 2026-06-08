import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/extensions/price_x.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../address/data/model/address.dart';
import '../../../address/presentation/cubits/address_cubit.dart';
import '../../../address/presentation/screens/address_form_screen.dart';
import '../../../app_settings/data/model/app_settings.dart';
import '../../../app_settings/presentation/cubits/app_settings_cubit.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../cart/presentation/cubits/cart_cubit.dart';
import 'order_confirmed_screen.dart';
import '../cubits/checkout_cubit.dart';

class CheckoutScreen extends StatefulWidget {
  static const String routeName = '/checkout';
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AddressCubit>().load();
    context.read<AppSettingsCubit>().load();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 30)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primaryDark, onPrimary: AppColors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null && context.mounted) context.read<CheckoutCubit>().setDeliveryDate(picked);
  }

  void _openAddressForm() {
    final cubit = context.read<AddressCubit>();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BlocProvider.value(value: cubit, child: const AddressFormScreen()),
    ));
  }

  void _placeOrder(AppSettings settings) {
    final addressCubit = context.read<AddressCubit>();
    final address = addressCubit.selectedAddress;
    if (address == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.selectAddress)));
      return;
    }
    final cart = context.read<CartCubit>().state;
    context.read<CheckoutCubit>().placeOrder(
          items: cart.items,
          address: address,
          subtotal: cart.subtotal,
          deliveryFee: settings.deliveryFeeFor(cart.subtotal),
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthCubit>().state;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        title: Text(context.l10n.checkout, style: AppTextStyles.heading3(context)),
      ),
      body: !auth.isLoggedIn
          ? EmptyState(
              icon: Icons.lock_outline_rounded,
              title: context.l10n.guestCheckoutTitle,
              subtitle: context.l10n.guestCheckoutHint,
              actionLabel: context.l10n.signIn,
              onAction: () => Navigator.of(context).pushNamed(LoginScreen.routeName),
            )
          : BlocConsumer<CheckoutCubit, CheckoutState>(
              listener: (context, state) {
                if (state.status == CheckoutStatus.success && state.createdOrder != null) {
                  context.read<CartCubit>().clear();
                  Navigator.of(context).pushReplacementNamed(
                    OrderConfirmedScreen.routeName,
                    arguments: state.createdOrder,
                  );
                } else if (state.status == CheckoutStatus.failure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.errorMessage ?? context.l10n.somethingWrong)),
                  );
                }
              },
              builder: (context, checkout) {
                return BlocBuilder<AppSettingsCubit, AppSettings>(
                  builder: (context, settings) {
                    final cart = context.watch<CartCubit>().state;
                    final fee = settings.deliveryFeeFor(cart.subtotal);
                    return Column(
                      children: [
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.all(16.r),
                            children: [
                              _AddressSection(onAdd: _openAddressForm),
                              SizedBox(height: 16.h),
                              _DateSection(
                                date: checkout.deliveryDate,
                                onTap: () => _pickDate(context),
                              ),
                              SizedBox(height: 16.h),
                              _PaymentSection(
                                selected: checkout.paymentMethod,
                                instapayHandle: settings.instapayHandle,
                                onChanged: (m) => context.read<CheckoutCubit>().setPaymentMethod(m),
                              ),
                              SizedBox(height: 16.h),
                              AppTextField(label: context.l10n.orderNotes, controller: _notesController, maxLines: 3),
                              SizedBox(height: 16.h),
                              _SummarySection(subtotal: cart.subtotal, fee: fee),
                            ],
                          ),
                        ),
                        SafeArea(
                          child: Container(
                            padding: EdgeInsets.all(16.r),
                            decoration: const BoxDecoration(color: AppColors.white, boxShadow: [
                              BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, -4)),
                            ]),
                            child: AppButton(
                              label: context.l10n.placeOrder,
                              loading: checkout.status == CheckoutStatus.placing,
                              onPressed: () => _placeOrder(settings),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.r16,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.subtitle(context)),
          SizedBox(height: 10.h),
          child,
        ],
      ),
    );
  }
}

class _AddressSection extends StatelessWidget {
  const _AddressSection({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: context.l10n.deliveryAddress,
      child: BlocBuilder<AddressCubit, AddressState>(
        builder: (context, state) {
          if (state.addresses.isEmpty) {
            return Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_location_alt_outlined, color: AppColors.primaryDark),
                label: Text(context.l10n.addAddress,
                    style: AppTextStyles.label(context).copyWith(color: AppColors.primaryDark)),
              ),
            );
          }
          return Column(
            children: [
              ...state.addresses.map((a) => _AddressTile(
                    address: a,
                    selected: a.id == state.selectedId,
                    onTap: () => context.read<AddressCubit>().select(a.id),
                  )),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add, size: 18, color: AppColors.primaryDark),
                  label: Text(context.l10n.addAddress,
                      style: AppTextStyles.label(context).copyWith(color: AppColors.primaryDark)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  const _AddressTile({required this.address, required this.selected, required this.onTap});
  final Address address;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryMist : AppColors.scaffoldBg,
          borderRadius: AppBorderRadius.r12,
          border: Border.all(color: selected ? AppColors.primaryDark : AppColors.border),
        ),
        child: Row(
          children: [
            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? AppColors.primaryDark : AppColors.textLight, size: 20.r),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(address.displayLabel, style: AppTextStyles.label(context).copyWith(color: AppColors.textDark)),
                  Text(address.fullAddress, style: AppTextStyles.bodySmall(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateSection extends StatelessWidget {
  const _DateSection({required this.date, required this.onTap});
  final DateTime? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: context.l10n.deliveryDate,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorderRadius.r12,
        child: Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            borderRadius: AppBorderRadius.r12,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_month_outlined, color: AppColors.primaryDark, size: 20),
              SizedBox(width: 10.w),
              Text(
                date == null ? context.l10n.selectDate : DateFormat('EEE, d MMM yyyy').format(date!),
                style: AppTextStyles.body(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentSection extends StatelessWidget {
  const _PaymentSection({required this.selected, required this.instapayHandle, required this.onChanged});
  final String selected;
  final String instapayHandle;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: context.l10n.paymentMethod,
      child: Column(
        children: [
          _option(context, 'cod', context.l10n.cod, context.l10n.codDesc, Icons.payments_outlined),
          SizedBox(height: 8.h),
          _option(context, 'instapay', context.l10n.instapay,
              context.l10n.instapayDesc(instapayHandle), Icons.account_balance_wallet_outlined),
        ],
      ),
    );
  }

  Widget _option(BuildContext context, String value, String title, String desc, IconData icon) {
    final isSel = selected == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: isSel ? AppColors.primaryMist : AppColors.scaffoldBg,
          borderRadius: AppBorderRadius.r12,
          border: Border.all(color: isSel ? AppColors.primaryDark : AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryDark, size: 22.r),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.label(context).copyWith(color: AppColors.textDark)),
                  Text(desc, style: AppTextStyles.bodySmall(context)),
                ],
              ),
            ),
            Icon(isSel ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isSel ? AppColors.primaryDark : AppColors.textLight, size: 20.r),
          ],
        ),
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.subtotal, required this.fee});
  final double subtotal;
  final double fee;

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: context.l10n.orderSummary,
      child: Column(
        children: [
          _row(context, context.l10n.subtotal, '${subtotal.asPrice} ${context.l10n.currency}'),
          SizedBox(height: 6.h),
          _row(context, context.l10n.deliveryFee,
              fee == 0 ? context.l10n.free : '${fee.asPrice} ${context.l10n.currency}'),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: const Divider(height: 1, color: AppColors.border),
          ),
          _row(context, context.l10n.total, '${(subtotal + fee).asPrice} ${context.l10n.currency}', bold: true),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: bold ? AppTextStyles.subtitle(context) : AppTextStyles.label(context)),
        Text(value, style: bold ? AppTextStyles.price(context) : AppTextStyles.body(context)),
      ],
    );
  }
}
