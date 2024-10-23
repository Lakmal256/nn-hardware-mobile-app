import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../localizations.dart';
import '../../locator.dart';
import '../../service/service.dart';
import '../../util/s_validators.dart';
import '../ui.dart';

class MobileVerifierFormValue extends FormValue {
  String? mobile;
  String? countryCode = "+94";

  MobileVerifierFormValue({this.mobile});

  MobileVerifierFormValue.empty() : mobile = "";

  /// With country code
  get fullMobile => "$countryCode$mobile";
}

class MobileVerifierFormController extends FormController<MobileVerifierFormValue> {
  MobileVerifierFormController() : super(initialValue: MobileVerifierFormValue.empty());

  @override
  Future<bool> validate() async {
    value.errors.clear();

    if (StringValidators.isEmpty(value.mobile)) {
      value.errors.addAll({"mobile": "Mobile number is required"});
    } else {
      try {
        /// Validating with the +94 prefix
        StringValidators.mobile(value.fullMobile);
      } on ArgumentError catch (err) {
        value.errors.addAll({"mobile": err.message});
      }
    }

    setValue(value);
    return value.errors.isEmpty;
  }
}

class MobileVerifierForm extends StatefulFormWidget<MobileVerifierFormValue> {
  const MobileVerifierForm({
    Key? key,
    required MobileVerifierFormController controller,
  }) : super(key: key, controller: controller);

  @override
  State<MobileVerifierForm> createState() => _UserIdentityFormState();
}

class _UserIdentityFormState extends State<MobileVerifierForm> with FormMixin {
  TextEditingController mobileTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, formValue, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                const Text("+94", style: TextStyle(color: Colors.black45)),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: mobileTextEditingController,
                    keyboardType: TextInputType.phone,
                    autocorrect: false,
                    maxLength: 9,
                    // validator: validateMobile,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.nN_007,
                      // hintText: "Mobile No",
                      errorText: formValue.getError("mobile"),
                    ),
                    onChanged: (value) => widget.controller.setValue(
                      widget.controller.value..mobile = value,
                    ),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }
}

String? validateMobile(String? value) {
  if (value == null || value.isEmpty) {
    return "Please enter your mobile number.";
  }
  if (value.length != 9) {
    return "Mobile number must be 9 digits long.";
  }
  if (!RegExp(r'^[0-9]*$').hasMatch(value)) {
    return "Mobile number must contain only digits.";
  }
  // Optional: you can also add more specific validation rules here,
  // such as checking for valid country codes or prefixes.
  return null;
}

class MobileVerifierFormView extends StatefulWidget {
  const MobileVerifierFormView({
    Key? key,
    required this.onDone,
  }) : super(key: key);

  final Function(MobileVerifierFormValue) onDone;

  @override
  State<MobileVerifierFormView> createState() => _MobileVerifierFormViewState();
}

class _MobileVerifierFormViewState extends State<MobileVerifierFormView> {
  MobileVerifierFormController controller = MobileVerifierFormController();

  handleSendOtp() async {
    if (await controller.validate()) {
      widget.onDone(controller.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 2,
                child: FractionallySizedBox(
                  widthFactor: .5,
                  child: Image.asset(
                    "assets/images/tm_001.png",
                    alignment: Alignment.bottomCenter,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  AppLocalizations.of(context)!.nN_008,
                  // "Welcome!",
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  AppLocalizations.of(context)!.nN_009,
                  // "Please login or sign up to continue our app",
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.black45,
                      ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                child: MobileVerifierForm(
                  controller: controller,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: FilledButton(
                  onPressed: handleSendOtp,
                  style: ButtonStyle(
                    visualDensity: VisualDensity.standard,
                    minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
                    backgroundColor: MaterialStateProperty.all(AppColors.red),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                    ),
                  ),
                  child: Text(AppLocalizations.of(context)!.nN_010),
                  // child: const Text("Verify"),
                ),
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}

class MobileVerifierFormStandaloneView extends StatelessWidget {
  const MobileVerifierFormStandaloneView({super.key});

  @override
  Widget build(BuildContext context) {
    final service = UserSignInViewService(context);
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: MobileVerifierFormView(
        onDone: (MobileVerifierFormValue value) async {
          service.verifyMobile(value.fullMobile);

          // todo: remove below, this is for testing
          // (locate<RestService>().authDataProvider as RestAuthDataProvider).authData = AuthData(
          //   identityId: '98e509f2-d3fd-4880-8e62-6cedabfc5595',
          //   accessToken: '',
          // );
          // locate<InAppNotificationHandler>().sync();
          // await locate<CloudMessagingHelperService>().requestPermission();
          // await locate<CloudMessagingHelperService>().registerDeviceToken();
          // final vendor = await locate<RestService>().getVendor();
          // if (vendor != null) {
          //   locate<VendorService>().setValue(vendor);
          //   if (context.mounted) GoRouter.of(context).go("/orders");
          // }
        },
      ),
    );
  }
}

class UserSignInViewService {
  BuildContext context;

  UserSignInViewService(this.context);

  Future verifyMobile(String mobile) async {
    try {
      RestService restService = locate<RestService>();

      bool canProceed = await restService.checkUserRegistrationStatus(mobile);
      if (!canProceed) throw UserNotFoundException();

      locate<ProgressIndicatorController>().show();
      final isOtpSent = await restService.sendOtp(OtpMethod.mobile, mobile);
      locate<ProgressIndicatorController>().hide();

      if (!isOtpSent) throw Exception();

      if (context.mounted) {
        final authorizationCode = await showOtpDialog(context, mobile: mobile);
        if (authorizationCode == null) return;

        locate<ProgressIndicatorController>().show();

        final response = await restService.loginWithAuthorizationCode(authorizationCode: authorizationCode!);
        if (response?.identityId == null) return;

        locate<RestAuthService>().setData(
          AuthData(
            identityId: response!.identityId!,
            accessToken: response.token!,
            refreshToken: response.refreshToken!,
            userIdentificationRecord: response.user!.email!,
          ),
        );

        locate<InAppNotificationHandler>().sync();

        await locate<CloudMessagingHelperService>().requestPermission();
        await locate<CloudMessagingHelperService>().registerDeviceToken();

        final vendor = await restService.getVendor();
        if (vendor != null) {
          locate<VendorService>().setValue(vendor);
          if (context.mounted) GoRouter.of(context).go("/orders");
        }

        locate<ProgressIndicatorController>().hide();
      }
    } on UserNotFoundException catch (_) {
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "User not found",
          subtitle: "There is no user record corresponding to this mobile number",
          color: Colors.red,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
    } on UnauthorizedException catch (_) {
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Invalid login credentials",
          subtitle: "You may have entered invalid username or password",
          color: Colors.red,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
    } on BlockedUserException catch (_) {
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "User Deactivated",
          subtitle: "Your account has been deactivated",
          color: Colors.red,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
    } catch (err) {
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Something went wrong",
          subtitle: "Sorry, something went wrong here",
          color: Colors.red,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
    } finally {
      locate<ProgressIndicatorController>().hide();
    }
  }
}
