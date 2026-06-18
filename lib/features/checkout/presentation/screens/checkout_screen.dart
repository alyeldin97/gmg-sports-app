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
import '../../../address/presentation/cubits/address_cubit.dart';
import '../../../app_settings/presentation/cubits/app_settings_cubit.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../cart/presentation/cubits/cart_cubit.dart';
import '../../data/model/governorate.dart';
import 'order_confirmed_screen.dart';
import '../cubits/checkout_cubit.dart';
import '../cubits/governorates_cubit.dart';

class CheckoutScreen extends StatefulWidget {
  static const String routeName = '/checkout';
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _aptCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  Governorate? _selectedGovernorate;

  @override
  void initState() {
    super.initState();
    context.read<GovernoratesCubit>().load();
    context.read<AppSettingsCubit>().load();
    final auth = context.read<AuthCubit>().state;
    if (auth.isLoggedIn && auth.user != null) {
      _emailCtrl.text = auth.user!.email;
      final parts = auth.user!.name.split(' ');
      _firstNameCtrl.text = parts.first;
      if (parts.length > 1) _lastNameCtrl.text = parts.sublist(1).join(' ');
      _phoneCtrl.text = auth.user!.phone ?? '';
      context.read<AddressCubit>().load();
    }
  }

  @override
  void dispose() {
    for (final c in [_emailCtrl, _firstNameCtrl, _lastNameCtrl, _phoneCtrl,
        _cityCtrl, _streetCtrl, _aptCtrl, _notesCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  void _prefillFromAddress() {
    final addr = context.read<AddressCubit>().selectedAddress;
    if (addr == null) return;
    final parts = addr.fullName.split(' ');
    setState(() {
      _firstNameCtrl.text = parts.first;
      _lastNameCtrl.text = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      _phoneCtrl.text = addr.phone;
      _cityCtrl.text = addr.city;
      _streetCtrl.text = addr.street;
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 30)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
              primary: AppColors.primaryDark, onPrimary: AppColors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      context.read<CheckoutCubit>().setDeliveryDate(picked);
    }
  }

  void _placeOrder() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedGovernorate == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.selectGovernorate)));
      return;
    }
    if (!_selectedGovernorate!.isActive) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.shippingUnavailable)));
      return;
    }
    if (context.read<CheckoutCubit>().state.deliveryDate == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.selectDate)));
      return;
    }
    final cart = context.read<CartCubit>().state;
    context.read<CheckoutCubit>().placeOrder(
          items: cart.items,
          email: _emailCtrl.text,
          firstName: _firstNameCtrl.text,
          lastName: _lastNameCtrl.text,
          phone: _phoneCtrl.text,
          governorateId: _selectedGovernorate!.id,
          governorateName: _selectedGovernorate!.name,
          shippingCost: _selectedGovernorate!.shippingCost,
          city: _cityCtrl.text,
          street: _streetCtrl.text,
          apartment: _aptCtrl.text.isEmpty ? null : _aptCtrl.text,
          notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        title: Text(context.l10n.checkout, style: AppTextStyles.heading3(context)),
      ),
      body: BlocConsumer<CheckoutCubit, CheckoutState>(
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
          final cart = context.watch<CartCubit>().state;
          final shipping = _selectedGovernorate?.shippingCost ?? 0.0;
          return Column(
            children: [
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: EdgeInsets.all(16.r),
                    children: [
                      _ContactSection(
                        emailCtrl: _emailCtrl,
                        firstNameCtrl: _firstNameCtrl,
                        lastNameCtrl: _lastNameCtrl,
                        phoneCtrl: _phoneCtrl,
                        onUseSaved: _prefillFromAddress,
                      ),
                      SizedBox(height: 16.h),
                      _DeliverySection(
                        selectedGovernorate: _selectedGovernorate,
                        cityCtrl: _cityCtrl,
                        streetCtrl: _streetCtrl,
                        aptCtrl: _aptCtrl,
                        onGovernorateChanged: (g) =>
                            setState(() => _selectedGovernorate = g),
                      ),
                      SizedBox(height: 16.h),
                      _DateSection(
                          date: checkout.deliveryDate, onTap: _pickDate),
                      SizedBox(height: 16.h),
                      _PaymentSection(
                        selected: checkout.paymentMethod,
                        onChanged: (m) =>
                            context.read<CheckoutCubit>().setPaymentMethod(m),
                      ),
                      SizedBox(height: 16.h),
                      AppTextField(
                          label: context.l10n.orderNotes,
                          controller: _notesCtrl,
                          maxLines: 3),
                      SizedBox(height: 16.h),
                      _SummarySection(
                        subtotal: cart.subtotal,
                        shipping: shipping,
                        governorate: _selectedGovernorate,
                      ),
                      SizedBox(height: 8.h),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 16,
                          offset: Offset(0, -4)),
                    ],
                  ),
                  child: AppButton(
                    label: context.l10n.placeOrder,
                    loading: checkout.status == CheckoutStatus.placing,
                    onPressed: _placeOrder,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Shared card wrapper ──────────────────────────────────────────────────────

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
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }
}

// ── Contact section ──────────────────────────────────────────────────────────

class _ContactSection extends StatelessWidget {
  const _ContactSection({
    required this.emailCtrl,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.phoneCtrl,
    required this.onUseSaved,
  });
  final TextEditingController emailCtrl, firstNameCtrl, lastNameCtrl, phoneCtrl;
  final VoidCallback onUseSaved;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthCubit>().state;
    return _Card(
      title: context.l10n.contactInfo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (auth.isLoggedIn)
            BlocBuilder<AddressCubit, AddressState>(
              builder: (context, state) {
                if (state.addresses.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: TextButton.icon(
                    onPressed: onUseSaved,
                    icon: const Icon(Icons.location_on_outlined,
                        size: 18, color: AppColors.primaryDark),
                    label: Text(context.l10n.useSavedAddress,
                        style: AppTextStyles.label(context)
                            .copyWith(color: AppColors.primaryDark)),
                  ),
                );
              },
            ),
          AppTextField(
            label: context.l10n.email,
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return context.l10n.requiredField;
              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
                return context.l10n.invalidEmail;
              }
              return null;
            },
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: context.l10n.firstName,
                  controller: firstNameCtrl,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? context.l10n.requiredField
                      : null,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: AppTextField(
                  label: context.l10n.lastName,
                  controller: lastNameCtrl,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? context.l10n.requiredField
                      : null,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          AppTextField(
            label: context.l10n.phone,
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? context.l10n.requiredField
                : null,
          ),
        ],
      ),
    );
  }
}

// ── Delivery section ─────────────────────────────────────────────────────────

class _DeliverySection extends StatelessWidget {
  const _DeliverySection({
    required this.selectedGovernorate,
    required this.cityCtrl,
    required this.streetCtrl,
    required this.aptCtrl,
    required this.onGovernorateChanged,
  });
  final Governorate? selectedGovernorate;
  final TextEditingController cityCtrl, streetCtrl, aptCtrl;
  final ValueChanged<Governorate?> onGovernorateChanged;

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return _Card(
      title: context.l10n.deliveryInfo,
      child: BlocBuilder<GovernoratesCubit, GovernoratesState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.governorate, style: AppTextStyles.label(context)),
              SizedBox(height: 6.h),
              DropdownButtonFormField<Governorate>(
                value: selectedGovernorate,
                hint: Text(context.l10n.selectGovernorate,
                    style: AppTextStyles.body(context)),
                isExpanded: true,
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: AppColors.white,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                  border: OutlineInputBorder(
                      borderRadius: AppBorderRadius.r12,
                      borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: AppBorderRadius.r12,
                      borderSide: const BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: AppBorderRadius.r12,
                      borderSide: const BorderSide(
                          color: AppColors.primaryDark, width: 1.5)),
                ),
                items: state.governorates
                    .map((g) => DropdownMenuItem(
                          value: g,
                          child: Text(g.localizedName(isArabic),
                              style: AppTextStyles.body(context)),
                        ))
                    .toList(),
                onChanged: onGovernorateChanged,
                validator: (v) =>
                    v == null ? context.l10n.requiredField : null,
              ),
              if (selectedGovernorate != null) ...[
                SizedBox(height: 8.h),
                Row(
                  children: [
                    const Icon(Icons.local_shipping_outlined,
                        size: 16, color: AppColors.primaryDark),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        '${context.l10n.shipping}: ${selectedGovernorate!.shippingCost.asPrice} ${context.l10n.currency}  •  ${context.l10n.deliveryIn(selectedGovernorate!.deliveryDays)}',
                        style: AppTextStyles.bodySmall(context)
                            .copyWith(color: AppColors.primaryDark),
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: 12.h),
              AppTextField(
                label: context.l10n.city,
                controller: cityCtrl,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? context.l10n.requiredField
                    : null,
              ),
              SizedBox(height: 12.h),
              AppTextField(
                label: context.l10n.street,
                controller: streetCtrl,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? context.l10n.requiredField
                    : null,
              ),
              SizedBox(height: 12.h),
              AppTextField(
                  label: context.l10n.apartment, controller: aptCtrl),
            ],
          );
        },
      ),
    );
  }
}

// ── Date section ─────────────────────────────────────────────────────────────

class _DateSection extends StatelessWidget {
  const _DateSection({required this.date, required this.onTap});
  final DateTime? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: '${context.l10n.deliveryDate} *',
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorderRadius.r12,
        child: Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
              borderRadius: AppBorderRadius.r12,
              border: Border.all(color: AppColors.border)),
          child: Row(
            children: [
              const Icon(Icons.calendar_month_outlined,
                  color: AppColors.primaryDark, size: 20),
              SizedBox(width: 10.w),
              Text(
                date == null
                    ? context.l10n.selectDate
                    : DateFormat('EEE, d MMM yyyy').format(date!),
                style: AppTextStyles.body(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Payment section ───────────────────────────────────────────────────────────

class _PaymentSection extends StatelessWidget {
  const _PaymentSection({required this.selected, required this.onChanged});
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsCubit>().state;
    return _Card(
      title: context.l10n.paymentMethod,
      child: Column(
        children: [
          _option(context, 'cod', context.l10n.cod, context.l10n.codDesc,
              Icons.payments_outlined),
          SizedBox(height: 8.h),
          _option(
              context,
              'instapay',
              context.l10n.instapay,
              context.l10n.instapayDesc(settings.instapayHandle),
              Icons.account_balance_wallet_outlined),
        ],
      ),
    );
  }

  Widget _option(BuildContext context, String value, String title, String desc,
      IconData icon) {
    final isSel = selected == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: isSel ? AppColors.primaryMist : AppColors.scaffoldBg,
          borderRadius: AppBorderRadius.r12,
          border: Border.all(
              color: isSel ? AppColors.primaryDark : AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryDark, size: 22.r),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.label(context)
                          .copyWith(color: AppColors.textDark)),
                  Text(desc, style: AppTextStyles.bodySmall(context)),
                ],
              ),
            ),
            Icon(
                isSel
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: isSel ? AppColors.primaryDark : AppColors.textLight,
                size: 20.r),
          ],
        ),
      ),
    );
  }
}

// ── Summary section ───────────────────────────────────────────────────────────

class _SummarySection extends StatelessWidget {
  const _SummarySection({
    required this.subtotal,
    required this.shipping,
    required this.governorate,
  });
  final double subtotal;
  final double shipping;
  final Governorate? governorate;

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: context.l10n.orderSummary,
      child: Column(
        children: [
          _row(context, context.l10n.subtotal,
              '${subtotal.asPrice} ${context.l10n.currency}'),
          SizedBox(height: 6.h),
          _row(
            context,
            context.l10n.shippingCost,
            governorate == null
                ? '—'
                : '${shipping.asPrice} ${context.l10n.currency}',
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: const Divider(height: 1, color: AppColors.border),
          ),
          _row(context, context.l10n.total,
              '${(subtotal + shipping).asPrice} ${context.l10n.currency}',
              bold: true),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value,
      {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: bold
                ? AppTextStyles.subtitle(context)
                : AppTextStyles.label(context)),
        Text(value,
            style: bold
                ? AppTextStyles.price(context)
                : AppTextStyles.body(context)),
      ],
    );
  }
}
