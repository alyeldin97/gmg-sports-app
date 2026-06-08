import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../cubits/address_cubit.dart';
import 'address_form_screen.dart';

class MyAddressesScreen extends StatelessWidget {
  static const String routeName = '/my-addresses';
  const MyAddressesScreen({super.key});

  void _openForm(BuildContext context, {address}) {
    final cubit = context.read<AddressCubit>();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: AddressFormScreen(address: address),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        title: Text(context.l10n.myAddresses, style: AppTextStyles.heading3(context)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.ink,
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: Text(context.l10n.addAddress, style: AppTextStyles.button(context)),
      ),
      body: BlocBuilder<AddressCubit, AddressState>(
        builder: (context, state) {
          if (state.status == AddressStatus.loading || state.status == AddressStatus.initial) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryDark));
          }
          if (state.addresses.isEmpty) {
            return EmptyState(
              icon: Icons.location_on_outlined,
              title: context.l10n.noAddresses,
              actionLabel: context.l10n.addAddress,
              onAction: () => _openForm(context),
            );
          }
          return ListView.separated(
            padding: EdgeInsets.fromLTRB(16.r, 16.r, 16.r, 90.r),
            itemCount: state.addresses.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, i) {
              final a = state.addresses[i];
              return Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: AppBorderRadius.r16,
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, color: AppColors.primaryDark, size: 20.r),
                        SizedBox(width: 6.w),
                        Text(a.displayLabel, style: AppTextStyles.subtitle(context)),
                        if (a.isDefault) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                color: AppColors.primaryMist, borderRadius: AppBorderRadius.full),
                            child: Text(context.l10n.defaultAddress,
                                style: AppTextStyles.bodySmall(context).copyWith(color: AppColors.primaryDark)),
                          ),
                        ],
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          onPressed: () => _openForm(context, address: a),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                          onPressed: () => context.read<AddressCubit>().delete(a.id),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text('${a.fullName} · ${a.phone}', style: AppTextStyles.bodySmall(context)),
                    SizedBox(height: 2.h),
                    Text(a.fullAddress, style: AppTextStyles.body(context)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
