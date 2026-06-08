import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/helpers/app_validator.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';

class EditProfileScreen extends StatefulWidget {
  static const String routeName = '/edit-profile';
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthCubit>().state.user;
    _name = TextEditingController(text: user?.name);
    _phone = TextEditingController(text: user?.phone);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        title: Text(context.l10n.editProfile, style: AppTextStyles.heading3(context)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                label: context.l10n.fullName,
                controller: _name,
                validator: (v) => AppValidator.validateNotEmpty(v, 'Name'),
              ),
              SizedBox(height: 16.h),
              AppTextField(
                label: context.l10n.phone,
                controller: _phone,
                keyboardType: TextInputType.phone,
                validator: AppValidator.validatePhone,
              ),
              SizedBox(height: 24.h),
              AppButton(
                label: context.l10n.save,
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    context.read<AuthCubit>().updateProfile(
                          name: _name.text.trim(),
                          phone: _phone.text.trim(),
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.l10n.profileUpdated)),
                    );
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
