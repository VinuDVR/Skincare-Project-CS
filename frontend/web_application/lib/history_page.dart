import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<dynamic> history = [];
  bool isLoading = true;
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    fetchRecommendationHistory();
  }

  Future<String?> getToken() async => await storage.read(key: 'jwt_token');

  Future<bool> checkAuthStatus() async {
    final token = await getToken();
    if (token == null) return false;

    final response = await http.get(
      Uri.parse('http://localhost:5000/check-auth'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) return true;

    await storage.delete(key: 'jwt_token');
    return false;
  }

  Future<void> fetchRecommendationHistory() async {
    if (!await checkAuthStatus()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You need to log in to view history.")),
      );
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final token = await getToken();
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/history'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          history = List<Map<String, dynamic>>.from(data['history']).map((entry) {
            entry['recommendations'] = {
              "primary": List<Map<String, dynamic>>.from(entry['recommendations']['primary']),
              "alternate": List<Map<String, dynamic>>.from(entry['recommendations']['alternate']),
            };
            return entry;
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  String formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return timestamp;
    }
  }

  Widget buildFiltersWidget(Map<String, dynamic> filters) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: filters.entries.map((entry) {
        return Chip(
          backgroundColor: Colors.teal.shade100,
          label: Text("${entry.key}: ${entry.value is List ? entry.value.join(', ') : entry.value}"),
        );
      }).toList(),
    );
  }

  Widget buildProductTile(Map<String, dynamic> product) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CachedNetworkImage(
          imageUrl: product['imageUrl'] ?? '',
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, size: 50),
        ),
      ),
      title: Text(product['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text("£${product['price']?.toStringAsFixed(2) ?? 'N/A'}", style: const TextStyle(color: Colors.green)),
    );
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    extendBodyBehindAppBar: true,
    appBar: AppBar(
      title: const Text('History'),
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade800, Colors.teal.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : history.isEmpty
              ? const Center(
                  child: Text(
                    "No history found.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: kToolbarHeight + 16, bottom: 16),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final entry = history[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Filters Used",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal.shade800)),
                            const SizedBox(height: 6),
                            buildFiltersWidget(Map<String, dynamic>.from(entry['filters'])),
                            const SizedBox(height: 12),
                            const Divider(thickness: 1),
                            const Text("Primary Recommendations",
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            ...List<Widget>.from(entry['recommendations']['primary'].map(buildProductTile)),
                            const SizedBox(height: 8),
                            const Text("Alternate Recommendations",
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            ...List<Widget>.from(entry['recommendations']['alternate'].map(buildProductTile)),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Date: ${formatTimestamp(entry['timestamp'])}",
                                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    ),
  );
}
}