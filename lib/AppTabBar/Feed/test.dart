import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;
  List<dynamic>? _data = [];
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _tabController!.addListener(_handleTabChange);
    _fetchData(page: _currentPage);
  }

  void _handleTabChange() {
    if (_tabController!.index == _tabController!.length - 1) {
      _fetchData(page: _currentPage + 1);
    }
  }

  Future<void> _fetchData({int page = 0}) async {
    final storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'access_token');

    final url = Uri.parse('http://localhost:8080/api/events?page=$page&limit=10&latitude=59.436962&longitude=24.753574&sort=distance');
    print(url); // Print the URL before making the request

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    print(response.body);

    if (response.statusCode == 200) {
      final List<dynamic> newData = jsonDecode(response.body);
      setState(() {
        _data!.addAll(newData);
        _currentPage = page;
        _tabController = TabController(length: (_data!.length / 10).ceil(), vsync: this);
      });
    } else {
      // Handle error
      print('Error: ${response.statusCode}');
    }
  }



  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pagination Tabs Example'),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: List.generate(
              _tabController!.length,
                  (index) => Tab(text: 'Tab ${index + 1}'),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(
                _tabController!.length,
                    (index) => ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, innerIndex) {
                    final dataIndex = (index * 10) + innerIndex;
                    if (dataIndex < _data!.length) {
                      final item = _data![dataIndex];
                      // Build your item widget here
                      return ListTile(title: Text(item.toString()));
                    } else {
                      // You can show a loading indicator at the end of the list here
                      return null;
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
