import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'SignUp.dart';
import 'booking.dart';

class Home extends StatefulWidget {
  // final int userID;
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final String baseUrl = 'http://10.0.2.2:3000';
  final Dio dio = Dio();

  Future<List<dynamic>> fetchMovies() async {
    try {
      final response = await dio.get('$baseUrl/movies');
      if (response.statusCode == 200) {
        return response.data is List
            ? response.data
            : jsonDecode(response.data.toString());
      } else {
        throw Exception('Failed to load movies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch movies: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // print('Home loaded with userID: ${widget.userID}');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        textTheme: Theme.of(context).textTheme.apply(bodyColor: Colors.white),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Color(0xffD59708)),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Image.asset(
            'assets/logo.png',
            height: 40,
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.person,
                size: 36,
                color: Color(0XffD59708),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpPage()),
                );
              },
            ),
            const SizedBox(width: 10),
          ],
        ),
        body: FutureBuilder(
          future: fetchMovies(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final movies = snapshot.data as List;

            return ListView.builder(
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                final movieId = movie['id']?.toString() ?? '';
                final title = movie['title'] ?? movie['movie_title'] ?? 'No Title';
                final time = movie['time'] ?? movie['movie_time'] ?? 'Time not available';
                final price = movie['price']?.toString() ?? movie['movie_price']?.toString() ?? '0';
                final image = movie['image'] ?? '';
                final genre = movie['genre'] ?? 'Unknown';

                return InkWell(
                  onTap: () {
                    if (movieId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invalid movie data')),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingPage(
                          movieId: movieId,
                          movieTitle: title,
                          movieTime: time,
                          moviePrice: price,
                          // userId: widget.userID,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          if (image.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                '$baseUrl/uploads/$image',
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 180,
                                  color: Colors.grey,
                                  child: const Icon(Icons.broken_image, color: Colors.white),
                                ),
                              ),
                            ),
                          const SizedBox(height: 10),
                          Text('Genre: $genre', style: const TextStyle(color: Colors.white70)),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.access_time, size: 16, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text('Time: $time', style: const TextStyle(color: Colors.white)),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.attach_money, size: 16, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text('Price: \$$price', style: const TextStyle(color: Colors.white)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
