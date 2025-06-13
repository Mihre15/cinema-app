import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class BookedPage extends StatefulWidget {
  const BookedPage({Key? key}) : super(key: key);

  @override
  _BookedPageState createState() => _BookedPageState();
}

class _BookedPageState extends State<BookedPage> {
  Map? booking;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchBooking();
  }

  Future<void> fetchBooking() async {
    try {
      final dio = Dio();
      dio.options.baseUrl = 'http://10.0.2.2:3000';
      dio.options.headers['Content-Type'] = 'application/json';
      

      final response = await dio.get('/user/last-booking');

      setState(() {
        booking = response.data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    if (error != null) return Center(child: Text("Error: $error"));

    if (booking == null) return const Center(child: Text("No bookings found."));

    final movie = booking!['movie'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Latest Booking"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              'http://10.0.2.2:3000/uploads/${movie['image']}',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            Text("🎬 Title: ${movie['title']}", style: const TextStyle(fontSize: 18)),
            Text("🎭 Genre: ${movie['genre']}"),
            Text("⏰ Time: ${movie['time']}"),
            Text("🎟️ Seats: ${booking!['seats'].join(', ')}"),
            Text("💵 Total Paid: \$${booking!['totalPrice']}"),
            Text("🗓️ Date: ${booking!['bookingDate']}"),
          ],
        ),
      ),
    );
  }
}
