import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:insee_hardware/service/service.dart';
import 'package:insee_hardware/ui/ui.dart';
import 'package:insee_hardware/ui/widgets/google_map_widget.dart';

import '../../localizations.dart';
import '../../locator.dart';
import '../../util/s_validators.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  VendorService vendor = locate<VendorService>();
  bool isEdit = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Material(
      color: Colors.white,
      child: SingleChildScrollView(
        child: isEdit
            ? (vendor.value != null)
                ? EditViewWidget(
                    vendorDto: vendor.value!,
                    onPressed: () {
                      setState(() {
                        isEdit = !isEdit;
                      });
                    },
                  )
                : const SizedBox.shrink()
            : ProfileWidget(
                vendor: vendor,
                size: size,
                onPressed: () {
                  setState(() {
                    isEdit = !isEdit;
                  });
                },
              ),
      ),
    );
  }
}

class EditViewWidget extends StatefulWidget {
  const EditViewWidget({super.key, required this.onPressed, required this.vendorDto});
  final VendorDto vendorDto;

  final VoidCallback onPressed;

  @override
  State<EditViewWidget> createState() => _EditViewWidgetState();
}

class _EditViewWidgetState extends State<EditViewWidget> {
  UpdateVerifierFormController updateVerifierFormController = UpdateVerifierFormController();

  var mobileTextEditingController = TextEditingController();

  var locationTextEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  @override
  void initState() {
    locationTextEditingController.text = widget.vendorDto.location;
    mobileTextEditingController.text = widget.vendorDto.contactNumber.substring(3);
    super.initState();
  }

  Future<bool> _handleLocationPermission(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.nN_021,
              // 'Location services are disabled. Please enable the services',
            ),
          ),
        );
      }
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.nN_022,
                // 'Location permissions are denied',
              ),
            ),
          );
        }
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.nN_023,
              // 'Location permissions are permanently denied, we cannot request permissions.',
            ),
          ),
        );
      }
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: widget.onPressed,
                icon: const Icon(
                  Icons.arrow_back,
                  size: 32,
                  color: Colors.black,
                ),
              ),
              Text(
                AppLocalizations.of(context)!.nN_024,
                // "Edit Hardware Info ",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.nN_025,
            // "Change the number and location that you want to appear as your hardware information.",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w300,
                ),
          ),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.nN_026,
                  // "Contact Number",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: mobileTextEditingController,
                  keyboardType: TextInputType.phone,
                  autocorrect: false,
                  validator: validateMobile,
                  decoration: InputDecoration(
                    isDense: true,
                    prefixIcon: const SizedBox(width: 20, child: Center(child: Text("+94"))),
                    fillColor: Colors.black.withOpacity(0.1),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: const Color.fromARGB(255, 151, 96, 96).withOpacity(0.1),
                        width: 0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.1),
                        width: 0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.1),
                        width: 0,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 5,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context)!.nN_027,
                  // "Location",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: locationTextEditingController,
                  keyboardType: TextInputType.streetAddress,
                  autocorrect: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.nN_028;
                      return "Location is requred!";
                    }
                  },
                  decoration: InputDecoration(
                    isDense: true,
                    fillColor: Colors.black.withOpacity(0.1),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: const Color.fromARGB(255, 151, 96, 96).withOpacity(0.1),
                        width: 0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.1),
                        width: 0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.1),
                        width: 0,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 5,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.location_on_outlined,
                        size: 20,
                      ),
                      onPressed: () async {
                        final hasPermission = await _handleLocationPermission(context);
                        if (!hasPermission) return;

                        // ignore: use_build_context_synchronously
                        var result = await markLocationDialog(context);
                        if (result != null) {
                          setState(() {
                            locationTextEditingController.text = result;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                FilledButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // print("Phone : ${mobileTextEditingController.text}");
                      var response = await locate<RestService>().putVendor(
                        id: locate<VendorService>().value!.id.toString(),
                        name: locate<VendorService>().value!.name.toString(),
                        location: locationTextEditingController.text,
                        mobileNumber: "+94${mobileTextEditingController.text}",
                      );

                      if (response!.result == 'Success') {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(context)!.nN_029,
                                // "Please re login to see updates!",
                              ),
                            ),
                          );
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(context)!.nN_030,
                                // "Something went wrong!",
                              ),
                            ),
                          );
                        }
                      }
                    }
                  },
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
                  child: Text(AppLocalizations.of(context)!.nN_031),
                  // child: const Text("Update"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> markLocationDialog(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Builder(
          builder: (context) {
            return const Dialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              insetPadding: EdgeInsets.all(20),
              child: GoogleMapWidget(),
            );
          },
        );
      },
    );
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
}

class UpdateMobileVerifierFormValue extends FormValue {
  String? mobile;
  String? location;
  String? countryCode = "+94";

  UpdateMobileVerifierFormValue({this.mobile, this.location});

  UpdateMobileVerifierFormValue.empty() : mobile = "";

  /// With country code
  get fullMobile => "$countryCode$mobile";
}

class UpdateVerifierFormController extends FormController<UpdateMobileVerifierFormValue> {
  UpdateVerifierFormController() : super(initialValue: UpdateMobileVerifierFormValue.empty());

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

    if (StringValidators.isEmpty(value.location)) {
      value.errors.addAll({"location": "Location is required"});
    }

    setValue(value);
    return value.errors.isEmpty;
  }
}

class UpdateForm extends StatefulFormWidget<UpdateMobileVerifierFormValue> {
  const UpdateForm({Key? key, required UpdateVerifierFormController controller, required VendorDto vender})
      : super(
          key: key,
          controller: controller,
        );

  @override
  State<UpdateForm> createState() => _UserIdentityFormState();
}

class _UserIdentityFormState extends State<UpdateForm> with FormMixin {
  TextEditingController mobileTextEditingController = TextEditingController();
  TextEditingController locationEditingController = TextEditingController();

  @override
  void init() {
    // TODO: implement init

    super.init();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, formValue, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.nN_032,
              // "Contact Number",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black.withOpacity(0.1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Text("+94", style: TextStyle(color: Colors.black)),
                    const SizedBox(width: 10),
                    TextField(
                      controller: mobileTextEditingController,
                      keyboardType: TextInputType.phone,
                      autocorrect: false,
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        errorText: formValue.getError("mobile"),
                      ),
                      onChanged: (value) => widget.controller.setValue(widget.controller.value..mobile = value),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.nN_033,
              // "Location",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black.withOpacity(0.1),
              ),
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: locationEditingController,
                keyboardType: TextInputType.phone,
                autocorrect: false,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  errorText: formValue.getError("location"),
                ),
                onChanged: (value) => widget.controller.setValue(widget.controller.value..mobile = value),
              ),
            )
          ],
        );
      },
    );
  }
}

class ProfileWidget extends StatelessWidget {
  const ProfileWidget({
    super.key,
    required this.vendor,
    required this.size,
    required this.onPressed,
  });

  final VendorService vendor;
  final Size size;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(children: [
        HeaderStack(vendor: vendor),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    AppLocalizations.of(context)!.nN_034,
                    // "Hardware Info ",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    onPressed: onPressed,
                    icon: const Icon(
                      Icons.navigate_next,
                      size: 30,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              const Divider(height: 1.5, thickness: 1),
              const SizedBox(height: 20),
              InformationCard(
                size: size,
                parameter: AppLocalizations.of(context)!.nN_035,
                // parameter: "Hardware Name",
                value: vendor.value?.name ?? "N/A",
              ),
              const SizedBox(height: 10),
              InformationCard(
                size: size,
                parameter: AppLocalizations.of(context)!.nN_036,
                // parameter: "Contact Number",
                value: vendor.value?.contactNumber ?? "N/A",
              ),
              const SizedBox(height: 10),
              InformationCard(
                size: size,
                parameter: AppLocalizations.of(context)!.nN_037,
                // parameter: "Location",
                value: vendor.value?.location ?? "N/A",
              ),
              const SizedBox(height: 10),
              // const Divider(height: 1.5, thickness: 1),
            ],
          ),
        )
      ]),
    );
  }
}

class InformationCard extends StatelessWidget {
  final Size size;
  final String parameter;
  final String value;

  const InformationCard({super.key, required this.size, required this.parameter, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: size.width / 2 - 20,
            child: Text(
              parameter,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                  ),
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String trimString(String value) {
    try {
      var value0 = value.split(" ");
      return "${value0[value0.length - 2]} ${value0.last}";
    } catch (e) {
      return value;
    }
  }
}

class HeaderStack extends StatelessWidget {
  const HeaderStack({super.key, required this.vendor});

  final VendorService vendor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 180.0,
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fitWidth,
                image: NetworkImage(
                  "https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcSGfm7RfQDYKWur0Zj5hpzYS-EWPBctygAwrQMNYRJhfvRLq9Z4",
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: MediaQuery.sizeOf(context).width / 2 - 65,
            child: CircleAvatar(
              minRadius: 65,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                minRadius: 58,
                backgroundColor: const Color.fromARGB(255, 1, 52, 128),
                child: Center(
                  child: Text(
                    vendor.value?.name.characters.first ?? "N/A",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
