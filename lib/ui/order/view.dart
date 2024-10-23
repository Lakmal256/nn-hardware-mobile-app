import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:insee_hardware/service/service.dart';
import 'package:insee_hardware/ui/ui.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../localizations.dart';
import '../../locator.dart';

class OrderView extends StatelessWidget {
  const OrderView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Material(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(height: 10),
          OrderViewTabs(),
        ],
      ),
    );
  }
}

class OrderViewTabs extends StatefulWidget {
  const OrderViewTabs({Key? key}) : super(key: key);

  @override
  State<OrderViewTabs> createState() => _OrderViewTabsState();
}

class _OrderViewTabsState extends State<OrderViewTabs> {
  // late TabController tabController;
  RestService restService = locate<RestService>();
  Future? action;

  @override
  void initState() {
    super.initState();
    action = restService.getReceivedOrders();
    // tabController = TabController(length: 2, vsync: this);
    // tabController.addListener(_handleTabSelection);
  }

  handleOnChange() {
    setState(() {
      action = restService.getReceivedOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                AppLocalizations.of(context)!.nN_011,
                // "Received Orders",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF000000),
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 15.0),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: FutureBuilder(
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("${snapshot.error}"),
                    );
                  }
                  return ValueListenableBuilder(
                    valueListenable: locate<OrdersRepo>(),
                    builder: (context, value, _) {
                      if(value.isEmpty) {
                        return const EmptyDataIndicator(
                          description: "There are no received orders to present at this moment",
                        );
                      }

                      return ListView.builder(
                        itemCount: value.length,
                        itemBuilder: (context, index) {
                          double handling = ((value[index].handlingCharge.price / 100) * value[index].itemTotal);
                          return OrderCard(
                            orderId: value[index].id,
                            tabSelect: 1,
                            orderNumber: index + 1,
                            handlingCharge: handling.toStringAsFixed(2),
                            deliveryCharge: value[index].deliveryCharge.toStringAsFixed(2),
                            itemTotal: value[index].itemTotal.toStringAsFixed(2),
                            promotion: value[index].promotionTotal.toStringAsFixed(2),
                            totalPayment: value[index].totalPayment.toStringAsFixed(2),
                            orderStatus: value[index].status,
                            customerName: value[index].omsUser.displayName,
                            customerContact: value[index].omsUser.mobileNo,
                            orderDate: value[index].createdDate,
                            location: value[index].currentAddress,
                            orderItems: value[index].orderItems,
                            onChange: handleOnChange,
                          );
                        },
                      );
                    },
                  );
                },
                future: action,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderViewCustomTab extends StatelessWidget {
  final String text;
  final bool isSelected;

  const OrderViewCustomTab({super.key, required this.text, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Center(
        child: FittedBox(
          child: Text(
            text,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isSelected ? Colors.white : const Color(0xFF000000),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
                ),
          ),
        ),
      ),
    );
  }
}

class OrdersRepo extends ValueNotifier<List<OrderDto>> {
  OrdersRepo({List<OrderDto>? value}) : super(value ?? []);

  setValue(List<OrderDto> value) {
    this.value = value;
    notifyListeners();
  }
}

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.orderNumber,
    required this.handlingCharge,
    required this.itemTotal,
    required this.orderStatus,
    required this.promotion,
    required this.totalPayment,
    required this.customerName,
    required this.orderDate,
    required this.location,
    required this.tabSelect,
    required this.orderItems,
    required this.deliveryCharge,
    required this.customerContact,
    required this.onChange,
    required this.orderId,
  });

  final int orderNumber;
  final int orderId;
  final String handlingCharge;
  final String deliveryCharge;
  final String itemTotal;
  final String orderStatus;
  final String promotion;
  final String totalPayment;
  final String customerName;
  final String customerContact;
  final DateTime orderDate;
  final String location;
  final int tabSelect;
  final List<OrderItem> orderItems;
  final Function() onChange;

  handleMapUrl() async {
    String googleMapUrl = "https://www.google.com/maps/search/?api=1&query=$location";
    if (await canLaunchUrl(Uri.parse(googleMapUrl))) {
      await launchUrl(Uri.parse(googleMapUrl), mode: LaunchMode.externalApplication);
    }
  }

  handleMarkAsComplete() async {
    try {
      locate<ProgressIndicatorController>().show();
      await locate<RestService>().updateOrderStatus(id: orderId, status: 'COMPLETED');
      onChange();
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
    String formatInt(int number) {
      if (number <= 9) return '0$number';
      return '$number';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      color: const Color(0xFFD9D9D9).withOpacity(0.5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: const Color(0xFFD9D9D9).withOpacity(0.5),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                  ),
                  child: Center(
                    child: Text(
                      formatInt(orderNumber),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: const Color(0xFF000000),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 20.0),
                child: Text(
                  "#${AppLocalizations.of(context)!.nN_012} $orderNumber",
                  // "#Order $orderNumber",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF000000),
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const Spacer(),
              Visibility(
                visible: false,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0, top: 35.0),
                  child: SizedBox(
                    height: 40,
                    child: FilledButton(
                      onPressed: () {},
                      style: ButtonStyle(
                        visualDensity: VisualDensity.standard,
                        minimumSize: MaterialStateProperty.all(const Size.fromWidth(60)),
                        backgroundColor: MaterialStateProperty.all(
                          tabSelect == 0 ? const Color(0xFF63BB43) : const Color(0xFFEE1C25),
                        ),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3.0),
                          ),
                        ),
                      ),
                      child: tabSelect == 0
                          ? Text(
                              AppLocalizations.of(context)!.nN_013,
                              // "Accept Order",
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color: const Color(0xFFFFFFFF),
                                    fontWeight: FontWeight.w500,
                                  ),
                            )
                          : Text(
                              AppLocalizations.of(context)!.nN_014,
                              // "Download Invoice",
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color: const Color(0xFFFFFFFF),
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "${orderItems.length} ${AppLocalizations.of(context)!.nN_015}",
                // "${orderItems.length} Items",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF000000),
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Column(
            children: orderItems.map((item) {
              return Column(children: [ProductCard(item: item)]);
            }).toList(),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.nN_016,
                  // "Items Total:",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF1D1B23).withOpacity(0.6),
                      ),
                ),
                Text(
                  "${AppLocalizations.of(context)!.nN_017} : $itemTotal",
                  // "Rs : $itemTotal",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.black,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.nN_018,
                  // "Handling Charges:",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF1D1B23).withOpacity(0.6),
                      ),
                ),
                Text(
                  "${AppLocalizations.of(context)!.nN_017} : $handlingCharge",
                  // "Rs : $handlingCharge",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF000000),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${AppLocalizations.of(context)!.nN_072}:',
                  // "Delivery Charges:",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF1D1B23).withOpacity(0.6),
                      ),
                ),
                Text(
                  "${AppLocalizations.of(context)!.nN_017} : $deliveryCharge",
                  // "Rs : $handlingCharge",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF000000),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.nN_019,
                  // "Promotion:",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF1D1B23).withOpacity(0.6),
                      ),
                ),
                Text(
                  "${AppLocalizations.of(context)!.nN_017} : $promotion",
                  // "Rs : $promotion",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF000000),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.nN_020,
                  // "Total Payment:",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF1D1B23).withOpacity(0.6),
                      ),
                ),
                Text(
                  "${AppLocalizations.of(context)!.nN_017} : $totalPayment",
                  // "Rs : $totalPayment",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xFFFF0000),
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF).withOpacity(0.5),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Row(
                  children: [
                    Flexible(
                      flex: 5,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.person_outlined,
                            color: Color(0xFF000000),
                            size: 25,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: FittedBox(
                              alignment: Alignment.centerLeft,
                              fit: BoxFit.scaleDown,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    customerName,
                                    // orderStatus,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: const Color(0xFF000000),
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    customerContact,
                                    // orderStatus,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: const Color(0xFF000000),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0.0, 5.0, 10.0, 5.0),
                            child: Text(
                              DateFormat('dd-MM-yyyy').format(orderDate),
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: const Color(0xFF1D1B23).withOpacity(0.6),
                                  ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: handleMapUrl,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xFF000000),
                                  borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(10),
                                  ),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(width: 5),
                                      const Icon(Icons.location_on, color: Color(0xFFFFFFFF), size: 20),
                                      Flexible(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                          child: Text(
                                            location,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Color(0xFFFFFFFF),
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Visibility(
            visible: orderStatus != "COMPLETED",
            // visible: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: FilledButton(
                onPressed: handleMarkAsComplete,
                child: Text(AppLocalizations.of(context)!.nN_073),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final OrderItem item;

  const ProductCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Card(
        margin: const EdgeInsets.only(bottom: 5),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF).withOpacity(0.5),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 40,
                    child: CircleAvatar(
                      backgroundColor: const Color(0xFFD9D9D9),
                      radius: 20,
                      child: CachedNetworkImage(
                        imageUrl: item.product.mobileImage,
                        placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width * 0.35,
                    child: Text(
                      item.product.name,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  SizedBox(
                    width: 30,
                    child: Text(
                      "${item.quantity} x",
                      textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF1D1B23).withOpacity(0.5),
                          ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    item.product.price.toStringAsFixed(2),
                    maxLines: 1,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
