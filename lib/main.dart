import 'package:flutter/material.dart';
import 'package:app_usage/app_usage.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  List<AppUsageInfo> _infos = [];
  late DateTime endDate;
  late DateTime startDate;

  @override
  void initState() {
    endDate = DateTime.now();
    startDate = DateTime(endDate.year, endDate.month, endDate.day);

    super.initState();
  }

  void getUsageStats() async {
    try {
      List<AppUsageInfo> infoList =
          await AppUsage().getAppUsage(startDate, endDate);
      setState(() => _infos = infoList);
    } on AppUsageException catch (exception) {
      print(exception);
    }
  }

  Future<AppInfo> getIcon(String packageName) async {
    AppInfo app = await InstalledApps.getAppInfo(packageName);
    return app;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('App Usage Example'),
          backgroundColor: Colors.green,
        ),
        body: ListView.builder(
            itemCount: _infos.length,
            itemBuilder: (context, index) {
              return FutureBuilder(
                  future: getIcon(_infos[index].packageName),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          ListTile(
                            title: Text(snapshot.data!.name),
                            leading: Image.memory(snapshot.data!.icon!),
                            trailing: Text(
                              _infos[index].usage.toString().split(".")[0],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                        ],
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Container();
                    } else {
                      return const Text("failed");
                    }
                  });
            }),
        floatingActionButton: FloatingActionButton(
            onPressed: getUsageStats, child: const Icon(Icons.file_download)),
      ),
    );
  }
}
