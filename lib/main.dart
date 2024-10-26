import 'package:flutter/material.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Dead Inside'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<UsageInfo> _usageData = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _fetchUsageData();
    } else {
      _errorMessage = "Usage stats are not available on the web.";
      _isLoading = false;
    }
  }

  Future<void> _fetchUsageData() async {
    try {
      DateTime now = DateTime.now();
      DateTime startTime = now.subtract(Duration(days: 7));

      List<UsageInfo> usageData = await UsageStats.queryUsageStats(
        startTime,
        now,
      );

      setState(() {
        _usageData = usageData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Unable to fetch usage data. Please check that the "
            "app has usage access permissions in system settings.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title, style: TextStyle(fontFamily: 'Jacquard24')),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _usageData.isNotEmpty
                  ? ListView.builder(
                      itemCount: _usageData.length,
                      itemBuilder: (context, index) {
                        final usageInfo = _usageData[index];
                        final totalTime = int.tryParse(
                              usageInfo.totalTimeInForeground ?? '0',
                            ) ??
                            0;
                        return ListTile(
                          title: Text(usageInfo.packageName ?? 'Unknown'),
                          subtitle: Text(
                            'Usage time: ${_formatDuration(totalTime)}',
                          ),
                        );
                      },
                    )
                  : Center(child: Text('No usage data available')),
    );
  }

  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitHours = twoDigits(duration.inHours);
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    return '$twoDigitHours:$twoDigitMinutes';
  }
}
// x