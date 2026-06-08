import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/helpers/app_validator.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/model/address.dart';
import '../cubits/address_cubit.dart';

/// Passed as route argument: an [AddressCubit] plus an optional [Address] to edit.
class AddressFormArgs {
  AddressFormArgs({required this.cubit, this.address});
  final AddressCubit cubit;
  final Address? address;
}

class AddressFormScreen extends StatefulWidget {
  static const String routeName = '/address-form';
  const AddressFormScreen({super.key, this.address});

  final Address? address;

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _label = TextEditingController(text: widget.address?.label);
  late final _name = TextEditingController(text: widget.address?.fullName);
  late final _phone = TextEditingController(text: widget.address?.phone);
  late final _city = TextEditingController(text: widget.address?.city);
  late final _area = TextEditingController(text: widget.address?.area);
  late final _street = TextEditingController(text: widget.address?.street);
  late final _building = TextEditingController(text: widget.address?.building);
  late final _apartment = TextEditingController(text: widget.address?.apartment);
  late bool _isDefault = widget.address?.isDefault ?? false;

  @override
  void dispose() {
    for (final c in [_label, _name, _phone, _city, _area, _street, _building, _apartment]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final address = Address(
      id: widget.address?.id ?? '',
      userId: '',
      label: _label.text.trim(),
      fullName: _name.text.trim(),
      phone: _phone.text.trim(),
      city: _city.text.trim(),
      area: _area.text.trim(),
      street: _street.text.trim(),
      building: _building.text.trim(),
      apartment: _apartment.text.trim(),
      isDefault: _isDefault,
    );
    context.read<AddressCubit>().save(address);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        title: Text(
          widget.address == null ? context.l10n.addAddress : context.l10n.editAddress,
          style: AppTextStyles.heading3(context),
        ),
      ),
      body: BlocListener<AddressCubit, AddressState>(
        listenWhen: (p, c) => p.status != c.status,
        listener: (context, state) {
          if (state.status == AddressStatus.saved) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.addressSaved)));
            Navigator.of(context).pop();
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(label: context.l10n.addressLabel, controller: _label),
                SizedBox(height: 14.h),
                AppTextField(
                  label: context.l10n.fullName,
                  controller: _name,
                  validator: (v) => AppValidator.validateNotEmpty(v, 'Name'),
                ),
                SizedBox(height: 14.h),
                AppTextField(
                  label: context.l10n.phone,
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  validator: AppValidator.validatePhone,
                ),
                SizedBox(height: 14.h),
                AppTextField(
                  label: context.l10n.city,
                  controller: _city,
                  validator: (v) => AppValidator.validateNotEmpty(v, 'City'),
                ),
                SizedBox(height: 14.h),
                AppTextField(label: context.l10n.area, controller: _area),
                SizedBox(height: 14.h),
                AppTextField(
                  label: context.l10n.street,
                  controller: _street,
                  validator: (v) => AppValidator.validateNotEmpty(v, 'Street'),
                ),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    Expanded(child: AppTextField(label: context.l10n.building, controller: _building)),
                    SizedBox(width: 12.w),
                    Expanded(child: AppTextField(label: context.l10n.apartment, controller: _apartment)),
                  ],
                ),
                SizedBox(height: 8.h),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: AppColors.primaryDark,
                  title: Text(context.l10n.setAsDefault, style: AppTextStyles.label(context)),
                  value: _isDefault,
                  onChanged: (v) => setState(() => _isDefault = v),
                ),
                SizedBox(height: 8.h),
                BlocBuilder<AddressCubit, AddressState>(
                  builder: (context, state) => AppButton(
                    label: context.l10n.save,
                    loading: state.status == AddressStatus.saving,
                    onPressed: _save,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
