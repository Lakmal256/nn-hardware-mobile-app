import 'dart:math';

import 'package:flutter/material.dart';
import 'package:insee_hardware/service/service.dart';
import 'package:intl/intl.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../localizations.dart';
import '../../locator.dart';
import '../ui.dart';

class ReportView extends StatefulWidget {
  const ReportView({Key? key}) : super(key: key);

  @override
  State<ReportView> createState() => _ReportViewState();
}

class _ReportViewState extends State<ReportView> {
  NumberPaginatorController controller = NumberPaginatorController();
  TextEditingController locationController = TextEditingController();
  RestService restService = locate<RestService>();

  OrderHistoryFormController orderHistoryFormController = OrderHistoryFormController(
    initialValue: OrderHistoryFormValue.empty(),
  );

  Future? future;

  List<ProductItemDto> materials = [];
  List<PromotionDto> promotions = [];

  String searchText = '';

  @override
  void initState() {
    super.initState();
    future = getData();
  }

  Future getData() async {
    List<PromotionDto> p0 = await restService.getPromotionList();
    ProductDto m0 = await restService.getMaterialList();
    setState(() {
      materials = m0.productList;
      promotions = p0;
    });
    locate<ReportsRepo>().setValue([]);
    return;
  }

  List<ReceiptDto> filterReportsByLocation() {
    return locate<ReportsRepo>().value.where((report) {
      final location = report.assignedHardwareOwner.location.toLowerCase(); // Access "location" using a map key
      // return location.contains(locationController.text.toLowerCase());
      return location.contains(searchText);
    }).toList();
  }

  Future getReports({bool isDaily = false}) async {
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');

    if (await orderHistoryFormController.validate()) {
      final reports = await restService.getReports(
        fromDate: dateFormat.format(orderHistoryFormController.value.formDate!),
        toDate: dateFormat.format(orderHistoryFormController.value.toDate!),
        material: orderHistoryFormController.value.material!.id,
        promotion: orderHistoryFormController.value.promotion!.id,
        isDaily: isDaily,
      );

      locate<ReportsRepo>().setValue(reports);
    }
  }

  handleOnReportChange(ReceiptDto r0) async {
    await getReports();
  }

  handleReportGenerate() async {
    setState(() {
      future = getReports();
    });
  }

  handleDailyReportGenerate() async {
    setState(() {
      future = getReports(isDaily: true);
    });
  }

  Widget buildForm(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        FilterForm(
          controller: orderHistoryFormController,
          materials: materials,
          promotions: promotions,
        ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ReportGenerateButton(
                  onPressed: handleReportGenerate,
                  title: AppLocalizations.of(context)!.nN_040,
                  backgroundColor: const Color(0xFFEE1C25),
                  textColor: const Color(0xFFFFFFFF),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ReportGenerateButton(
                  onPressed: handleDailyReportGenerate,
                  title: AppLocalizations.of(context)!.nN_041,
                  backgroundColor: const Color(0xFFFFFFFF),
                  textColor: const Color(0xFFEE1C25),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          return Column(
            children: [
              if (snapshot.connectionState == ConnectionState.waiting) const LinearProgressIndicator(),
              buildForm(context),
              const SizedBox(height: 15),
              Divider(
                color: const Color(0xFF000000).withOpacity(0.25),
                thickness: 1,
                indent: 12,
                endIndent: 12,
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9).withOpacity(0.4),
                    borderRadius: BorderRadius.circular(40),
                    shape: BoxShape.rectangle,
                  ),
                  child: Center(
                    child: TextField(
                      // controller: locationController,
                      onChanged: (value) => setState(() {
                        searchText = value;
                      }),
                      cursorColor: const Color(0xFF000000),
                      autocorrect: false,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(left: 30, right: 10),
                          child: Icon(
                            Icons.search,
                            color: Color(0xFF868687),
                            size: 25,
                          ),
                        ),
                        hintText: AppLocalizations.of(context)!.nN_042,
                        hintStyle: const TextStyle(fontSize: 16, color: Color(0xFF868687)),
                      ),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: const Color(0xFF000000), fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: locate<ReportsRepo>(),
                  builder: (context, value, child) {
                    if (filteredList.isEmpty) {
                      return const Center(
                        child: Icon(
                          Icons.info,
                          size: 70,
                          color: Colors.black12,
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      child: Column(
                        children: filteredList
                            .map((report) => ReportCard(
                                  orderId: report.id,
                                  orderStatus: report.status,
                                  promotionCount: report.promotions.length,
                                  customerContact: report.omsUser.mobileNo,
                                  deliveryCharge: report.deliveryCharge.toString(),
                                  orderDate: DateFormat('dd-MM-yyyy').format(report.createdDate),
                                  orderQuantity: report.orderItems.length.toString(),
                                  hardwareStore: report.assignedHardwareOwner.name,
                                  location: report.assignedHardwareOwner.location,
                                  material: report.orderItems.first.product.name,
                                  deductionFromPromotion:
                                      report.promotionTotal == 0.0 ? "N/A" : report.promotionTotal.toString(),
                                  formController: orderHistoryFormController,
                                  onChange: () => handleOnReportChange(report),
                                ))
                            .toList(),
                      ),
                    );
                  },
                ),
              ),
              if (filteredList.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: NumberPaginator(
                    controller: controller,
                    onPageChange: (int page) {
                      setState(() {
                        controller.navigateToPage(page);
                      });
                    },
                    numberPages: max(1, filteredList.length),
                    showPrevButton: true,
                    showNextButton: true,
                    config: NumberPaginatorUIConfig(
                      buttonShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                        side: const BorderSide(
                          color: Color(0xFFD9D9D9),
                          width: 1.0,
                        ),
                      ),
                      buttonSelectedForegroundColor: Colors.white,
                      buttonUnselectedForegroundColor: Colors.black,
                      buttonUnselectedBackgroundColor: const Color(0xFFD9D9D9),
                      buttonSelectedBackgroundColor: Colors.red,
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                    prevButtonContent: const Icon(Icons.chevron_left),
                    nextButtonContent: const Icon(Icons.chevron_right),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  List<ReceiptDto> get filteredList => filterReportsByLocation();
}

class ReportCard extends StatelessWidget {
  const ReportCard({
    super.key,
    required this.orderId,
    required this.orderDate,
    required this.orderQuantity,
    required this.hardwareStore,
    required this.location,
    required this.material,
    // required this.totalValueWithoutVAT,
    // required this.tax,
    // required this.taxValueWithVAT,
    required this.deductionFromPromotion,
    required this.formController,
    required this.orderStatus,
    required this.customerContact,
    required this.deliveryCharge,
    required this.onChange,
    required this.promotionCount,
    // required this.materialId,
    // required this.promotionId,
  });
  final int orderId;
  final String orderDate;
  final String orderQuantity;
  final String hardwareStore;
  final String location;
  final String material;
  final String orderStatus;
  final String customerContact;
  final String deliveryCharge;
  final int promotionCount;

  // final String totalValueWithoutVAT;
  // final String tax;
  // final String taxValueWithVAT;
  final String deductionFromPromotion;
  final OrderHistoryFormController formController;
  // final String materialId;
  // final String promotionId;

  final Function() onChange;

  handleMapUrl() async {
    String googleMapUrl = "https://www.google.com/maps/search/?api=1&query=$location";
    if (await canLaunchUrl(Uri.parse(googleMapUrl))) {
      await launchUrl(Uri.parse(googleMapUrl), mode: LaunchMode.externalApplication);
    }
  }

  handleReport(BuildContext context) async {
    RestService service = locate<RestService>();
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');

    try {
      locate<ProgressIndicatorController>().show();

      final url0 = await service.generateSalesReportUrl(
        fromDate: dateFormat.format(formController.value.formDate!),
        toDate: dateFormat.format(formController.value.toDate!),
        material: formController.value.material!.id.toString(),
        promotion: formController.value.promotion!.id.toString(),
        isDaily: false,
      );

      if(url0 != null) launchUrl(url0, mode: LaunchMode.externalApplication);
    } catch (_) {
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8),
            topLeft: Radius.circular(8),
          ),
          side: BorderSide(
            color: Color(0xFFFFFFFF),
            width: 1.0,
          ),
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Container(
                height: 30,
                width: 110,
                decoration: const BoxDecoration(
                  color: Color(0xFFEE1C25),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                          // onPressed: () {
                          //   showModalBottomSheet(
                          //     context: context,
                          //     builder: (context) => ExportBottomSheet(
                          //       formController: formController,
                          //       onClose: Navigator.of(context).pop,
                          //     ),
                          //   );
                          // },
                          onPressed: () => handleReport(context),
                          style: ButtonStyle(
                            visualDensity: VisualDensity.standard,
                            minimumSize: MaterialStateProperty.all(const Size.fromWidth(30)),
                            backgroundColor: MaterialStateProperty.all(const Color(0xFFEE1C25)),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                ),
                              ),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.nN_043,
                            // "Export",
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .copyWith(color: const Color(0xFFFFFFFF), fontWeight: FontWeight.w700),
                          )),
                    ),
                    const Icon(
                      Icons.arrow_forward,
                      color: Color(0xFFFFFFFF),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: FittedBox(
                      child: Text(
                        AppLocalizations.of(context)!.nN_044,
                        // "Order Date",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: const Color(0xFF000000),
                            ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: FittedBox(
                      child: Text(
                        orderDate,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF000000),
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Divider(
              color: const Color(0xFF000000).withOpacity(0.3),
              thickness: 1,
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: FittedBox(
                      child: Text(
                        AppLocalizations.of(context)!.nN_070,
                        // "Order Status",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: const Color(0xFF000000),
                            ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: FittedBox(
                      child: Text(
                        orderStatus,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF000000),
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Divider(
              color: const Color(0xFF000000).withOpacity(0.3),
              thickness: 1,
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: FittedBox(
                      child: Text(
                        AppLocalizations.of(context)!.nN_071,
                        // "Customer Contact",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: const Color(0xFF000000),
                            ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: FittedBox(
                      child: Text(
                        customerContact,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF000000),
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Divider(
              color: const Color(0xFF000000).withOpacity(0.3),
              thickness: 1,
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: FittedBox(
                      child: Text(
                        AppLocalizations.of(context)!.nN_045,
                        // "Order Quantity",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: const Color(0xFF000000),
                            ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: FittedBox(
                      child: Text(
                        orderQuantity,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF000000),
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Divider(
              color: const Color(0xFF000000).withOpacity(0.3),
              thickness: 1,
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: FittedBox(
                      child: Text(
                        AppLocalizations.of(context)!.nN_046,
                        // "Hardware Store",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: const Color(0xFF000000),
                            ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: FittedBox(
                      child: Text(
                        hardwareStore,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF000000),
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Divider(
              color: const Color(0xFF000000).withOpacity(0.3),
              thickness: 1,
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 1,
                    fit: FlexFit.loose,
                    child: FittedBox(
                      child: Text(
                        AppLocalizations.of(context)!.nN_047,
                        // "Location",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: const Color(0xFF000000),
                            ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    fit: FlexFit.tight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            location,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: const Color(0xFF000000),
                                ),
                          ),
                        ),
                        IconButton(
                          onPressed: handleMapUrl,
                          icon: const Icon(Icons.navigation_rounded),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Divider(
              color: const Color(0xFF000000).withOpacity(0.3),
              thickness: 1,
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: FittedBox(
                      child: Text(
                        AppLocalizations.of(context)!.nN_048,
                        // "Material",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: const Color(0xFF000000),
                            ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: FittedBox(
                      child: Text(
                        material,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF000000),
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Divider(
              color: const Color(0xFF000000).withOpacity(0.3),
              thickness: 1,
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FittedBox(
                    child: Text(
                      AppLocalizations.of(context)!.nN_049,
                      // "Promotion Applied",
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: const Color(0xFF000000),
                          ),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: FittedBox(
                      child: Text(
                        promotionCount.toString(),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF000000),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Divider(
              color: const Color(0xFF000000).withOpacity(0.3),
              thickness: 1,
            ),
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 3,
                    child: FittedBox(
                      child: Text(
                        AppLocalizations.of(context)!.nN_050,
                        // "Deduction From Promotion:",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: const Color(0xFF000000),
                            ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: FittedBox(
                      child: Text(
                        deductionFromPromotion,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF000000),
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Divider(
              color: const Color(0xFF000000).withOpacity(0.3),
              thickness: 1,
            ),
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 3,
                    child: FittedBox(
                      child: Text(
                        AppLocalizations.of(context)!.nN_072,
                        // "Delivery Charge:",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: const Color(0xFF000000),
                            ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: FittedBox(
                      child: Text(
                        deliveryCharge,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF000000),
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // const SizedBox(
            //   height: 5,
            // ),
            // Divider(
            //   color: const Color(0xFF000000).withOpacity(0.3),
            //   thickness: 1,
            // ),
            // const SizedBox(
            //   height: 5,
            // ),
            // FilledButton(
            //   onPressed: handleMarkAsComplete,
            //   child: Text(AppLocalizations.of(context)!.nN_073),
            // ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}

class ReportsRepo extends ValueNotifier<List<ReceiptDto>> {
  ReportsRepo({List<ReceiptDto>? value}) : super(value ?? []);

  setValue(List<ReceiptDto> value) {
    this.value = value;
    // notifyListeners();
  }
}

// class ExportBottomSheet extends StatelessWidget {
//   const ExportBottomSheet({Key? key, required this.onClose, required this.formController}) : super(key: key);
//
//   final VoidCallback onClose;
//   final OrderHistoryFormController formController;
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Container(
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(25.0),
//             topRight: Radius.circular(25.0),
//           ),
//         ),
//         height: MediaQuery.of(context).size.height / 4,
//         width: double.infinity,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.only(left: 18.0),
//                     child: Text(
//                       AppLocalizations.of(context)!.nN_051,
//                       // "Export Results",
//                       style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                             color: const Color(0xFF000000),
//                           ),
//                     ),
//                   ),
//                   const Spacer(),
//                   IconButton(
//                     onPressed: onClose,
//                     icon: const Icon(Icons.cancel_outlined, size: 30, color: Color(0xFF717579)),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(
//               height: 10,
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ExportCard(
//                   onPressed: () async {
//                     RestService service = locate<RestService>();
//                     DateFormat dateFormat = DateFormat('yyyy-MM-dd');
//
//                     try {
//                       locate<ProgressIndicatorController>().show();
//
//                       final url0 = await service.generateSalesReportUrl(
//                         fromDate: dateFormat.format(formController.value.formDate!),
//                         toDate: dateFormat.format(formController.value.toDate!),
//                         material: formController.value.material!.id.toString(),
//                         promotion: formController.value.promotion!.id.toString(),
//                         isDaily: false,
//                       );
//
//                       if(url0 != null) launchUrl(url0);
//
//                       if (context.mounted) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text(
//                               AppLocalizations.of(context)!.nN_064,
//                             ),
//                           ),
//                         );
//                         Navigator.pop(context);
//                       }
//                     } catch (_) {
//                       if (context.mounted) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text(
//                               AppLocalizations.of(context)!.nN_065,
//                             ),
//                           ),
//                         );
//                         Navigator.pop(context);
//                       }
//                     } finally {
//                       locate<ProgressIndicatorController>().hide();
//                     }
//                   },
//                   // type: "Export as Excel file",
//                   title: AppLocalizations.of(context)!.nN_052,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class ExportCard extends StatelessWidget {
//   const ExportCard({
//     super.key,
//     required this.title,
//     required this.onPressed,
//   });
//   final VoidCallback onPressed;
//   final String title;
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onPressed,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 18.0),
//         child: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(5),
//             color: const Color(0xFFD9D9D9).withOpacity(0.4),
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // Image.asset(
//               //   iconPath,
//               //   width: 30,
//               // ),
//               const SizedBox(
//                 height: 10,
//               ),
//               Text(
//                 title,
//                 style: Theme.of(context).textTheme.titleSmall?.copyWith(
//                       color: const Color(0xFF000000),
//                     ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class ReportGenerateButton extends StatelessWidget {
  const ReportGenerateButton(
      {super.key,
      required this.onPressed,
      required this.title,
      required this.backgroundColor,
      required this.textColor});

  final VoidCallback onPressed;
  final String title;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: const Color(0xFFEE1C25), width: 1),
        ),
        // height: 30,
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class FilterForm extends StatefulFormWidget {
  const FilterForm({
    super.key,
    required super.controller,
    required this.materials,
    required this.promotions,
  });

  final List<ProductItemDto> materials;
  final List<PromotionDto> promotions;

  @override
  FilterFormState createState() => FilterFormState();
}

class FilterFormState extends State<FilterForm> with FormMixin {
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, formValue, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                AppLocalizations.of(context)!.nN_053,
                // "Created Date",
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(color: const Color(0xFF000000), fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: fromDateController,
                      readOnly: true,
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2010),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null && picked != DateTime.now()) {
                          fromDateController.text = DateFormat('dd-MM-yyyy').format(picked);
                          var controller0 = widget.controller;
                          controller0.setValue(controller0.value..formDate = picked);
                        }
                      },
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                        suffixIcon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Color(0xFF868687),
                          size: 20,
                        ),
                        errorText: formValue.getError("fromDate"),
                        hintText: 'From',
                        hintStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: const Color(0xFF1D1B23),
                            ),
                        filled: true,
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Center(
                      child: TextField(
                        controller: toDateController,
                        readOnly: true,
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2010),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null && picked != DateTime.now()) {
                            toDateController.text = DateFormat('dd-MM-yyyy').format(picked);
                            var controller = widget.controller;

                            controller.setValue(controller.value..toDate = picked);
                          }
                        },
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          suffixIcon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Color(0xFF868687),
                            size: 20,
                          ),
                          isDense: true,
                          errorText: formValue.getError("toDate"),
                          hintText: 'To',
                          hintStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: const Color(0xFF1D1B23),
                              ),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.nN_054,
                          // "Materials",
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: const Color(0xFF000000),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 5),
                        InputDecorator(
                          decoration: InputDecoration(
                            errorText: formValue.getError("material"),
                            hintText: AppLocalizations.of(context)!.nN_055,
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(),
                            ),
                            isDense: true,
                          ),
                          child: PopupMenuButton<String>(
                            offset: const Offset(0, 40),
                            child: Text(
                              formValue.material?.name ?? AppLocalizations.of(context)!.nN_055,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onSelected: (value) {
                              widget.controller.setValue(
                                widget.controller.value
                                  ..material = widget.materials.firstWhere(
                                    (product) => product.name == value,
                                  ),
                              );
                            },
                            itemBuilder: (BuildContext context) {
                              return widget.materials.map((material) {
                                return PopupMenuItem<String>(
                                  value: material.name,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                    child: Text(
                                      material.name,
                                      style: const TextStyle(
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.nN_056,
                          // "Promotion",
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(color: const Color(0xFF000000), fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 5),
                        InputDecorator(
                          decoration: InputDecoration(
                            errorText: formValue.getError("promotion"),
                            hintText: AppLocalizations.of(context)!.nN_057,
                            fillColor: Colors.white,
                            filled: true,
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(),
                            ),
                          ),
                          child: PopupMenuButton<String>(
                            offset: const Offset(0, 40),
                            child: Text(
                              formValue.promotionDisplayValue ?? AppLocalizations.of(context)!.nN_057,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onSelected: (value) {
                              widget.controller.setValue(
                                widget.controller.value
                                  ..promotion = widget.promotions.firstWhere(
                                    (promo) => promo.mainPromotionType == value,
                                  ),
                              );
                            },
                            itemBuilder: (BuildContext context) {
                              return widget.promotions.map((promo) {
                                var text = "${promo.mainPromotionType} ${promo.type} ${promo.promoCode}";
                                return PopupMenuItem<String>(
                                  value: promo.mainPromotionType,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                    child: Text(
                                      text,
                                      style: const TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class OrderHistoryFormValue {
  ProductItemDto? material;
  PromotionDto? promotion;
  DateTime? formDate;
  DateTime? toDate;
  Map<String, String> errors = {};

  String? getError(String key) => errors[key];

  OrderHistoryFormValue.empty();

  OrderHistoryFormValue copyWith({
    ProductItemDto? material,
    PromotionDto? promotion,
    DateTime? fromDate,
    DateTime? toDate,
    Map<String, String>? errors,
  }) {
    return OrderHistoryFormValue.empty()
      ..material = material ?? this.material
      ..promotion = promotion ?? this.promotion
      ..errors = errors ?? this.errors;
  }

  String? get promotionDisplayValue {
    if (promotion != null) {
      return "${promotion?.mainPromotionType} ${promotion?.type} ${promotion?.promoCode}";
    }
    return null;
  }
}

class OrderHistoryFormController extends FormController<OrderHistoryFormValue> {
  OrderHistoryFormController({required super.initialValue});

  clear() {
    value = OrderHistoryFormValue.empty();
  }

  @override
  Future<bool> validate() async {
    value.errors.clear();

    if (value.material == null) {
      value.errors.addAll({"material": "Material is required"});
    }

    if (value.promotion == null) {
      value.errors.addAll({"promotion": "Promotion is required"});
    }

    DateTime? fromDate = value.formDate;
    if (fromDate == null) {
      value.errors.addAll({'fromDate': 'Date is required'});
    }

    DateTime? toDate = value.toDate;
    if (toDate == null) {
      value.errors.addAll({'toDate': 'Date is required'});
    }

    if (toDate != null && fromDate != null && toDate.isBefore(fromDate)) {
      value.errors.addAll({'fromDate': 'Date range must be valid'});
    }
    if (toDate != null && fromDate != null && toDate.isAfter(DateTime.now())) {
      value.errors.addAll({'toDate': 'Please enter valid date'});
    }

    setValue(value);
    return value.errors.isEmpty;
  }
}
