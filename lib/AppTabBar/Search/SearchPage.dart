import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:pull_down_button/pull_down_button.dart';
import 'package:ringoflutter/AppTabBar/Feed/FeedPage.dart';
import 'package:ringoflutter/AppTabBar/Map/GetLocation.dart';
import 'package:ringoflutter/Classes/CurrencyClass.dart';
import 'package:ringoflutter/Classes/CategoryClass.dart';
import 'package:ringoflutter/Classes/EventClass.dart';
import 'package:ringoflutter/Event/EventPage.dart';
import 'package:ringoflutter/Security/Functions/CheckTimestampFunc.dart';
import 'package:ringoflutter/UI/Functions/Formats.dart';
import 'package:ringoflutter/UI/Themes.dart';
import 'package:ringoflutter/api_endpoints.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;

class CirclePainter extends CustomPainter {
  final Offset center;
  final double radius;
  final Color color;
  final double strokeWidth;

  CirclePainter({
    required this.center,
    required this.radius,
    required this.color,
    this.strokeWidth = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.blue.withOpacity(0.1);
    canvas.drawCircle(center, radius, backgroundPaint);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, paint);
  }


  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}



class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _SearchedString = TextEditingController();

  List<EventInFeed> events = [];
  int currentPage = 0;
  bool isLoading = false;
  bool hasMoreData = true;

  bool _isPriceButtonTapped = false;
  bool _isLocationPickerTapped = false;
  bool _isDateStartButtonTapped = false;
  bool _isDateEndButtonTapped = false;


  double? mapCenterLat;
  double? mapCenterLong;
  int? radius;

  GoogleMapController? mapController;
  String? _mapStyle;
  String? _mapStyleDark;
  String? _mapStyleIos;
  String? _mapStyleIosDark;
    
  GoogleMapController? _mapController;
  var sortBy = "distance";
  var sortDirection = "ASC";

  final TextEditingController _TextFieldPriceTo = TextEditingController();
  final TextEditingController _TextFieldPriceFrom = TextEditingController();
  var selectedCurrency = "USD";
  var selectedCurrencySymbol = "\$";
  var selectedCurrencyId = 1;

  DateTime? startTime;
  bool isStartTimeSelected = false;

  DateTime? endTime;
  bool isEndTimeSelected = false;

  List<String> selectedCategoryList = [];
  List<int> selectedCategoryListIds = [];
  bool isCategorySelected = false;

  @override
  void initState() {
    super.initState();
    fetchEvents();
    getCurrencies();
    rootBundle.loadString('assets/map/light.txt').then((string) {
      _mapStyle = string;
    });

    rootBundle.loadString('assets/map/dark.txt').then((string) {
      _mapStyleDark = string;
    });

    rootBundle.loadString('assets/map/light.json').then((string) {
      _mapStyleIos = string;
    });

    rootBundle.loadString('assets/map/dark.json').then((string) {
      _mapStyleIosDark = string;
    });
  }

  Future<String> buildRequest() async {
    var location = await getUserLocation();
    List<EventInFeed> events = [];
    int currentPage = 0;
    bool isLoading = false;
    bool hasMoreData = true;
    var result = "";

    if (sortDirection == "ASC") {
      result = "$result&dir=ASC";
    }
    else if (sortDirection == "DESC") {
      result = "$result&dir=DESC";
    }

    if (sortBy == "distance") {
      result = "$result&sort=distance";
    }
    else if (sortBy == "price") {
      result = "$result&sort=price";
    }
    else if (sortBy == "date") {
      result = "$result&sort=startTime";
    }
    else if (sortBy == "popularity") {
      result = "$result&sort=peopleCount";
    }

    //location
    if (mapCenterLat != null) {
      result = "$result&latitude=$mapCenterLat&longitude=$mapCenterLong&maxDistance=$radius";
    } else {
      result = "$result&latitude=${location.latitude}&longitude=${location.longitude}";
    }

    //date
    if (startTime != null) {
      result = "$result&startTimeMin=${convertToUtc(startTime!)}";
      setState(() {
        isStartTimeSelected = true;
      });
    }

    if (endTime != null) {
      result = "$result&endTimeMax=${convertToUtc(endTime!)}";
      setState(() {
        isEndTimeSelected = true;
      });
    }

    else if (startTime == null && endTime == null) {
      result = "$result&startTimeMin=${convertToUtc(DateTime.now())}";
    }


    //category
    if (selectedCategoryListIds.isNotEmpty) {
      result = "$result&categoryIds=${selectedCategoryListIds.join(",")}";
    }

    //searchString
    if (_SearchedString.text != "") {
      result = "$result&search=${_SearchedString.text}";
    }

    //price
    if (_TextFieldPriceFrom.text != "") {
      result = "$result&priceMin=${_TextFieldPriceFrom.text}&currencyId=$selectedCurrencyId";
    }
    if (_TextFieldPriceTo.text != "") {
      result = "$result&priceMax=${_TextFieldPriceTo.text}&currencyId=$selectedCurrencyId";
    }

    return result;
  }

  Future<void> fetchEvents() async {
    var userCoordinates = await getUserLocation();
    await checkTimestamp();
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'access_token');
    try {
      setState(() {
        isLoading = true;
      });
      var getRequest = await buildRequest();
      var url = Uri.parse(
          '${ApiEndpoints.SEARCH}?page=$currentPage&limit=10&isActive=true&$getRequest');
      print(url);
      var headers = {
        'Authorization': 'Bearer $token',
      };
      var response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = customJsonDecode(response.body);
        final List<EventInFeed> newEvents =
        data.map((item) => EventInFeed.fromJson(item)).toList();

        setState(() {
          events.addAll(newEvents);
          isLoading = false;
          hasMoreData = newEvents.isNotEmpty;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('Failed to load events: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading events: $e');
    }
  }

  List<Currency> listOfCurrencies = [];
  void getCurrencies() async {
    await checkTimestamp();
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'access_token');
    var url = Uri.parse(ApiEndpoints.GET_CURRENCY);
    var headers = {
      'Authorization': 'Bearer $token'
    };
    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = customJsonDecode(response.body);
      final List<Currency> newCurrencies =
      data.map((item) => Currency.fromJson(item)).toList();
      setState(() {
        listOfCurrencies.addAll(newCurrencies);
      });
    } else {
      print('Failed to load currencies: ${response.statusCode}');
    }
  }

  bool _onNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification &&
        notification.metrics.extentAfter == 0 &&
        !isLoading &&
        hasMoreData) {
      currentPage++;
      fetchEvents();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    var previousValue = "";
    Timer? timer;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: CupertinoPageScaffold(
        backgroundColor: currentTheme.scaffoldBackgroundColor,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: currentTheme.scaffoldBackgroundColor,
          middle: Text('Search',
          style: TextStyle(
            color: currentTheme.colorScheme.primary,
          ),
          ),
        ),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Column(
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.65,
                    child: CupertinoTextField(
                      controller: _SearchedString,
                      placeholder: 'Search',
                      clearButtonMode: OverlayVisibilityMode.editing,
                      cursorColor: currentTheme.colorScheme.primary,
                      style: TextStyle(
                        color: currentTheme.colorScheme.primary,
                      ),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: currentTheme.colorScheme.background,
                        borderRadius: defaultWidgetCornerRadius,
                      ),
                      prefix: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Icon(
                          CupertinoIcons.search,
                          color: Colors.grey,
                          size: 18,
                        ),
                      ),
                      onChanged: (value) {
                        var currentValue = value;
                        timer?.cancel();

                        timer = Timer(Duration(milliseconds: 500), () {
                          setState(() {
                            if (currentValue != previousValue) {
                              events = [];
                              currentPage = 0;
                              fetchEvents();
                            }
                            previousValue = currentValue;
                          });
                        });
                      },
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                  ClipRRect(
                    borderRadius: defaultWidgetCornerRadius,
                    child: Container(
                      color: currentTheme.colorScheme.background,
                      width: MediaQuery.of(context).size.width * 0.24,
                      child: CupertinoButton(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          'Clear',
                          style: TextStyle(
                            color: currentTheme.colorScheme.primary,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _SearchedString.text = "";
                            mapCenterLat = null;
                            mapCenterLong = null;
                            radius = null;
                            startTime = null;
                            endTime = null;
                            selectedCategoryList = [];
                            selectedCategoryListIds = [];
                            isCategorySelected = false;
                            _TextFieldPriceFrom.text = "";
                            _TextFieldPriceTo.text = "";
                            selectedCurrency = "USD";
                            selectedCurrencySymbol = "\$";
                            selectedCurrencyId = 1;
                            sortBy = "price";
                            sortDirection = "ASC";
                            events = [];
                            currentPage = 0;
                            fetchEvents();
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                ],
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      PullDownButton(
                        itemBuilder: (context) => [
                          PullDownMenuHeader(
                            leading: ColoredBox(
                              color: currentTheme.colorScheme.primary,
                              child: Icon(
                                sortBy == "distance"
                                ? CupertinoIcons.location_fill
                                : sortBy == "price"
                                ? CupertinoIcons.money_dollar
                                : sortBy == "date"
                                ? CupertinoIcons.calendar_today
                                : sortBy == "popularity"
                                ? CupertinoIcons.person_2_fill
                                : CupertinoIcons.sort_down,
                                color: currentTheme.scaffoldBackgroundColor,
                              ),
                            ),
                            title: sortDirection == "ASC"
                                ? sortBy == "distance"
                                ? "Closest"
                                : sortBy == "price"
                                ? "Cheapest"
                                : sortBy == "date"
                                ? "Newest"
                                : sortBy == "popularity"
                                ? "Least popular"
                                : "Sort by"
                                : sortBy == "distance"
                                ? "Furthest"
                                : sortBy == "price"
                                ? "Most expensive"
                                : sortBy == "date"
                                ? "Oldest"
                                : sortBy == "popularity"
                                ? "Most popular"
                                : "Sort by",
                            subtitle: 'Sorted by $sortBy',
                          ),
                          PullDownMenuActionsRow.small(
                            items: [
                              PullDownMenuItem(
                                onTap: () {
                                  setState(() {
                                    sortBy = "distance";
                                    events = [];
                                    currentPage = 0;
                                    fetchEvents();
                                  });
                                },
                                title: "Distance",
                                icon: CupertinoIcons.location_fill,
                              ),
                              PullDownMenuItem(
                                onTap: () {
                                  setState(() {
                                    sortBy = "price";
                                    events = [];
                                    currentPage = 0;
                                    fetchEvents();
                                  });
                                },
                                title: "Price",
                                icon: CupertinoIcons.money_dollar,
                              ),
                              PullDownMenuItem(
                                onTap: () {
                                  setState(() {
                                    sortBy = "date";
                                    events = [];
                                    currentPage = 0;
                                    fetchEvents();
                                  });
                                },
                                title: "Date",
                                icon: CupertinoIcons.calendar_today,
                              ),
                              PullDownMenuItem(
                                onTap: () {
                                  setState(() {
                                    sortBy = "popularity";
                                    events = [];
                                    currentPage = 0;
                                    fetchEvents();
                                  });
                                },
                                title: "Popularity",
                                icon: CupertinoIcons.person_2_fill,
                              ),
                            ],
                          ),
                          PullDownMenuActionsRow.medium(
                            items: [
                              PullDownMenuItem(
                                onTap: () {
                                  setState(() {
                                    sortDirection = "ASC";
                                    events = [];
                                    currentPage = 0;
                                    fetchEvents();
                                  });
                                },
                                title: sortBy == "distance"
                                    ? "Closest"
                                    : sortBy == "price"
                                    ? "Cheapest"
                                    : sortBy == "date"
                                    ? "Newest"
                                    : sortBy == "popularity"
                                    ? "Least popular"
                                    : "",
                                icon: CupertinoIcons.arrow_up,
                              ),
                              PullDownMenuItem(
                                onTap: () {
                                  setState(() {
                                    sortDirection = "DESC";
                                    events = [];
                                    currentPage = 0;
                                    fetchEvents();
                                  });
                                },
                                title: sortBy == "distance"
                                    ? "Furthest"
                                    : sortBy == "price"
                                    ? "Most expensive"
                                    : sortBy == "date"
                                    ? "Oldest"
                                    : sortBy == "popularity"
                                    ? "Most popular"
                                    : "",
                                icon: CupertinoIcons.arrow_down,
                              ),
                            ],
                          ),
                        ],
                        buttonBuilder: (context, showMenu) => ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CupertinoButton(
                            onPressed: showMenu,
                            color: currentTheme.colorScheme.background,
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            child: Row(
                              children: [
                                Icon(
                                  CupertinoIcons.arrow_up_arrow_down_circle,
                                  color: currentTheme.colorScheme.primary,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Sorted by $sortBy',
                                  style: TextStyle(
                                    color: currentTheme.colorScheme.primary,
                                    decoration: TextDecoration.none,
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CupertinoButton(
                          onPressed: () {
                            setState(() {
                              _isLocationPickerTapped = !_isLocationPickerTapped;
                              _isPriceButtonTapped = false;
                              _isDateStartButtonTapped = false;
                              _isDateEndButtonTapped = false;
                            });
                          },
                          color: (mapCenterLat == null) ? currentTheme.colorScheme.background
                              : (currentTheme.brightness == Brightness.light) ? currentTheme.colorScheme.primary.withOpacity(0.1) : currentTheme.colorScheme.primary.withOpacity(0.3),
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.location_circle,
                                color: currentTheme.colorScheme.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Location',
                                style: TextStyle(
                                  color: currentTheme.colorScheme.primary,
                                  decoration: TextDecoration.none,
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CupertinoButton(
                          onPressed: () {
                            setState(() {
                              _isPriceButtonTapped = !_isPriceButtonTapped;
                              _isLocationPickerTapped = false;
                              _isDateStartButtonTapped = false;
                              _isDateEndButtonTapped = false;
                            });
                          },
                          color: !(_TextFieldPriceTo.text != "" || _TextFieldPriceFrom.text != "") ? currentTheme.colorScheme.background
                              : (currentTheme.brightness == Brightness.light) ? currentTheme.colorScheme.primary.withOpacity(0.1) : currentTheme.colorScheme.primary.withOpacity(0.3),
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.money_dollar_circle,
                                color: currentTheme.colorScheme.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Price',
                                style: TextStyle(
                                  color: currentTheme.colorScheme.primary,
                                  decoration: TextDecoration.none,
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CupertinoButton(
                          onPressed: () {
                            setState(() {
                              _isDateStartButtonTapped = !_isDateStartButtonTapped;
                              _isPriceButtonTapped = false;
                              _isLocationPickerTapped = false;
                              _isDateEndButtonTapped = false;
                            });
                          },

                          color: !(startTime != null) ? currentTheme.colorScheme.background
                              : (currentTheme.brightness == Brightness.light) ? currentTheme.colorScheme.primary.withOpacity(0.1) : currentTheme.colorScheme.primary.withOpacity(0.3),
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.calendar_circle,
                                color: currentTheme.colorScheme.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Start Time',
                                style: TextStyle(
                                  color: currentTheme.colorScheme.primary,
                                  decoration: TextDecoration.none,
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CupertinoButton(
                          onPressed: () {
                            setState(() {
                              _isDateEndButtonTapped = !_isDateEndButtonTapped;
                              _isPriceButtonTapped = false;
                              _isLocationPickerTapped = false;
                              _isDateStartButtonTapped = false;
                            });
                          },

                          color: !(endTime != null) ? currentTheme.colorScheme.background
                              : (currentTheme.brightness == Brightness.light) ? currentTheme.colorScheme.primary.withOpacity(0.1) : currentTheme.colorScheme.primary.withOpacity(0.3),
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.calendar_circle,
                                color: currentTheme.colorScheme.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'End Time',
                                style: TextStyle(
                                  color: currentTheme.colorScheme.primary,
                                  decoration: TextDecoration.none,
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CupertinoButton(
                          onPressed: () async {
                            List<CategoryClass> listOfCategories = [];
                            var url = Uri.parse(ApiEndpoints.GET_CATEGORY);
                            var response = await http.get(url);
                            if (response.statusCode == 200) {
                              final List<dynamic> data = customJsonDecode(response.body);
                              final List<CategoryClass> newCategoryList =
                              data.map((item) => CategoryClass.fromJson(item)).toList();
                              for (var category in newCategoryList) {
                                listOfCategories.add(category);
                              }
                              await showDialog(
                                context: context,
                                builder: (ctx) {
                                  return  MultiSelectDialog(
                                    width: MediaQuery.of(context).size.width * 1,
                                    title: const Text("Select categories"),
                                    itemsTextStyle: TextStyle(
                                      color: currentTheme.colorScheme.primary,
                                    ),
                                    searchable: true,
                                    backgroundColor: currentTheme.colorScheme.background,
                                    checkColor: currentTheme.colorScheme.background,
                                    colorator: (item) {
                                      return currentTheme.colorScheme.primary;
                                    },
                                    selectedItemsTextStyle: TextStyle(
                                      color: currentTheme.colorScheme.primary,
                                    ),
                                    searchIcon: Icon(
                                      CupertinoIcons.search,
                                      color: currentTheme.colorScheme.primary,
                                    ),
                                    closeSearchIcon: Icon(
                                      CupertinoIcons.clear,
                                      color: currentTheme.colorScheme.primary,
                                    ),
                                    items: listOfCategories.map((category) {
                                      return MultiSelectItem(
                                        category,
                                        category.name,
                                      );
                                    }).toList(),
                                    initialValue: const [],
                                    onConfirm: (values) {
                                      setState(() {
                                        selectedCategoryList = [];
                                        selectedCategoryListIds = [];
                                        for (var category in values) {
                                          selectedCategoryList.add(category.name);
                                          selectedCategoryListIds.add(category.id);
                                        }
                                        print(selectedCategoryList);
                                        print(selectedCategoryListIds);
                                        if (selectedCategoryListIds.isEmpty) {
                                          isCategorySelected = false;
                                        } else {
                                          isCategorySelected = true;
                                        }
                                        events = [];
                                        currentPage = 0;
                                        fetchEvents();
                                      });
                                    },
                                  );
                                },
                              );
                            } else {
                              print('Failed to load currencies: ${response.statusCode}');
                            }
                          },
                          color: !(selectedCategoryList.isNotEmpty) ? currentTheme.colorScheme.background
                              : (currentTheme.brightness == Brightness.light) ? currentTheme.colorScheme.primary.withOpacity(0.1) : currentTheme.colorScheme.primary.withOpacity(0.3),
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.list_bullet_below_rectangle,
                                color: currentTheme.colorScheme.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Category',
                                style: TextStyle(
                                  color: currentTheme.colorScheme.primary,
                                  decoration: TextDecoration.none,
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: (_isLocationPickerTapped || _isPriceButtonTapped) ? 0 : 10,
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _isPriceButtonTapped
                    ? Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.25,
                          height: 70,
                          padding: const EdgeInsets.all(10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CupertinoTextField(
                              style: TextStyle(
                                color: currentTheme.colorScheme.primary,
                              ),
                              decoration: BoxDecoration(
                                color: currentTheme.colorScheme.background,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              cursorColor: currentTheme.colorScheme.primary,
                              maxLength: 3,
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  _TextFieldPriceFrom.text = value;
                                });
                              },
                              controller: _TextFieldPriceFrom,
                              placeholder: 'From',
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.25,
                          height: 70,
                          padding: const EdgeInsets.all(10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CupertinoTextField(
                              decoration: BoxDecoration(
                                color: currentTheme.colorScheme.background,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              cursorColor: currentTheme.colorScheme.primary,
                              style: TextStyle(
                                color: currentTheme.colorScheme.primary,
                              ),
                              maxLength: 3,
                              keyboardType: TextInputType.number,
                              controller: _TextFieldPriceTo,
                              onChanged: (value) {
                                setState(() {
                                  _TextFieldPriceTo.text = value;
                                });
                              },
                              placeholder: 'To',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        PullDownButton(
                          itemBuilder: (context) => listOfCurrencies.map((currency) {
                            return PullDownMenuItem.selectable(
                              title: "${currency.symbol} ${currency.name}",
                              selected: selectedCurrency == currency.name,
                              onTap: () {
                                setState(() {
                                  selectedCurrency = currency.name;
                                  selectedCurrencySymbol = currency.symbol;
                                  selectedCurrencyId = currency.id;
                                });
                              },
                            );
                          }).toList(),
                          buttonBuilder: (context, showMenu) => CupertinoButton(
                            onPressed: showMenu,
                            padding: EdgeInsets.zero,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.21,
                              height: 50,
                              decoration: BoxDecoration(
                                color: currentTheme.colorScheme.background,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  '$selectedCurrencySymbol $selectedCurrency',
                                  style: TextStyle(fontSize: 16, color: currentTheme.colorScheme.primary),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Spacer(),
                        CupertinoButton(
                          onPressed: () {
                            setState(() {
                              _TextFieldPriceFrom.text = "";
                              _TextFieldPriceTo.text = "";
                              _isPriceButtonTapped = !_isPriceButtonTapped;
                              events = [];
                              currentPage = 0;
                              fetchEvents();
                            });
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.30,
                            height: 50,
                            decoration: BoxDecoration(
                              color: currentTheme.colorScheme.background,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                'Cancel',
                                style: TextStyle(fontSize: 16, color: currentTheme.colorScheme.primary),
                              ),
                            ),
                          ),
                        ),
                        CupertinoButton(
                          onPressed: () {
                            setState(() {
                              _isPriceButtonTapped = false;
                              events = [];
                              currentPage = 0;
                              fetchEvents();
                            });
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.30,
                            height: 50,
                            decoration: BoxDecoration(
                              color: currentTheme.colorScheme.background,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                'Apply',
                                style: TextStyle(fontSize: 16, color: currentTheme.colorScheme.primary, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ],
                )
                    : const SizedBox(),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: _isLocationPickerTapped
                  ? Column(
                  children: [
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: defaultWidgetCornerRadius,
                      child: SizedBox(
                        height: MediaQuery.of(context).size.width * 0.93,
                        width: MediaQuery.of(context).size.width * 0.93,
                        child: Stack(
                          children: [
                            GoogleMap(
                              onMapCreated: (controller) {
                                _mapController = controller;
                                (Platform.isAndroid)
                                    ? (currentTheme.brightness == Brightness.light)
                                    ? _mapController?.setMapStyle(_mapStyle!)
                                    : _mapController?.setMapStyle(_mapStyleDark!)
                                    : (currentTheme.brightness == Brightness.light)
                                    ? _mapController?.setMapStyle(_mapStyleIos!)
                                    : _mapController?.setMapStyle(_mapStyleIosDark!);
                              },
                              initialCameraPosition: const CameraPosition(
                                target: LatLng(59.47644736286131, 24.781226109442517),
                                zoom: 11,
                              ),
                              myLocationEnabled: true,
                              myLocationButtonEnabled: false,
                              zoomControlsEnabled: false,
                            ),
                            CustomPaint(
                              painter: CirclePainter(
                                  center: Offset(MediaQuery.of(context).size.width * 0.465, MediaQuery.of(context).size.width * 0.465),
                                  radius: MediaQuery.of(context).size.width * 0.435,
                                  color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.93,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CupertinoButton(
                            onPressed: () {
                              mapCenterLat = null;
                              mapCenterLong = null;
                              radius = null;
                              setState(() {
                                _isLocationPickerTapped = false;
                                events = [];
                                currentPage = 0;
                                fetchEvents();
                              });
                            },
                            color: currentTheme.colorScheme.background,
                            child: Text(
                              'Cancel',
                              style: TextStyle(fontSize: 16, color: currentTheme.colorScheme.primary),
                            ),
                          ),
                          CupertinoButton(
                            onPressed: () async {
                              LatLngBounds visibleRegion = await _mapController!.getVisibleRegion();
                              var topLeftLat = visibleRegion.northeast.latitude;
                              var topLeftLong = visibleRegion.southwest.longitude;
                              var bottomRightLat = visibleRegion.southwest.latitude;
                              var bottomRightLong = visibleRegion.northeast.longitude;
                              var zoomLevel = await _mapController!.getZoomLevel();

                              mapCenterLat = (topLeftLat + bottomRightLat) / 2;
                              mapCenterLong = (topLeftLong + bottomRightLong) / 2;

                              double calculatedValue = (((topLeftLat - bottomRightLat) /2 )* 111) * 1000;
                              radius = calculatedValue.toInt();
                              setState(() {
                                _isLocationPickerTapped = false;
                                events = [];
                                currentPage = 0;
                                fetchEvents();
                              });
                            },
                            color: currentTheme.colorScheme.background,
                            child: Text(
                              'Apply',
                              style: TextStyle(fontSize: 16, color: currentTheme.colorScheme.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                )
                    : const SizedBox(),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _isDateStartButtonTapped
                    ? Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.width * 0.93,
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.dateAndTime,
                        initialDateTime: startTime ?? DateTime.now(),
                        onDateTimeChanged: (DateTime newDateTime) {
                          setState(() {
                            startTime = newDateTime;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.93,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Aligns buttons to the left and right
                        children: [
                          CupertinoButton(
                            onPressed: () {
                              setState(() {
                                startTime = null;
                                _isDateStartButtonTapped = false;
                                events = [];
                                currentPage = 0;
                                fetchEvents();
                              });
                            },
                            color: currentTheme.colorScheme.background,
                            child: Text(
                              'Cancel',
                              style: TextStyle(fontSize: 16, color: currentTheme.colorScheme.primary),
                            ),
                          ),
                          CupertinoButton(
                            onPressed: () {
                              setState(() {
                                _isDateStartButtonTapped = false;
                                events = [];
                                currentPage = 0;
                                fetchEvents();
                              });
                            },
                            color: currentTheme.colorScheme.background,
                            child: Text(
                              'Apply',
                              style: TextStyle(fontSize: 16, color: currentTheme.colorScheme.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                )
                    : const SizedBox(),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child:  _isDateEndButtonTapped
                    ? SizedBox(
                  width: MediaQuery.of(context).size.width * 0.93,
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.93,
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.dateAndTime,
                          initialDateTime: endTime ?? DateTime.now(),
                          onDateTimeChanged: (DateTime newDateTime) {
                            setState(() {
                              endTime = newDateTime;
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.93,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Aligns buttons to the left and right
                          children: [
                            CupertinoButton(
                              onPressed: () {
                                setState(() {
                                  endTime = null;
                                  _isDateEndButtonTapped = false;
                                  events = [];
                                  currentPage = 0;
                                  fetchEvents();
                                });
                              },
                              color: currentTheme.colorScheme.background,
                              child: Text(
                                'Cancel',
                                style: TextStyle(fontSize: 16, color: currentTheme.colorScheme.primary),
                              ),
                            ),
                            CupertinoButton(
                              onPressed: () {
                                setState(() {
                                  _isDateEndButtonTapped = false;
                                  events = [];
                                  currentPage = 0;
                                  fetchEvents();
                                });
                              },
                              color: currentTheme.colorScheme.background,
                              child: Text(
                                'Apply',
                                style: TextStyle(fontSize: 16, color: currentTheme.colorScheme.primary, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                )
                    : const SizedBox(),
              ),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: _onNotification,
                  child: (events.isNotEmpty)
                  ? RefreshIndicator(
                    color: currentTheme.colorScheme.primary,
                    child: ListView.builder(
                      itemCount: events.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return const SizedBox();
                        } else if (index <= events.length) {
                          final event = events[index - 1];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>EventPage(eventId: event.id!),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                (mapCenterLat == null)
                                ? eventCard(context, event, false)
                                : eventCard(context, event, true),
                                const SizedBox(height: 10),
                              ],
                            ),
                          );
                        } else if (isLoading) {
                          return Center(child: CircularProgressIndicator(
                            color: currentTheme.colorScheme.primary
                          ));
                        } else {
                          return const SizedBox();
                        }
                      },
                    ),
                    onRefresh: () async {
                      setState(() {
                        events = [];
                        currentPage = 0;
                        fetchEvents();
                      });
                    },
                  )
                    : Center(
                    child: Text("No events found",
                      style: TextStyle(
                      color: currentTheme.colorScheme.primary,
                        decoration: TextDecoration.none,
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
