import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'SignUp.dart';
import 'booking.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final String baseUrl = 'http://10.0.2.2:3000';

  Future<List<dynamic>> fetchMovies() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/movies'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load movies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch movies: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              final price = movie['price'] ?? movie['movie_price'] ?? '0';
              final image = movie['image'] ?? '';

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
                        moviePrice: price.toString(),
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        if (image.isNotEmpty)
                          Image.network(
                            '$baseUrl/uploads/$image',
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => 
                              Container(height: 180, color: Colors.grey, child: const Icon(Icons.broken_image)),),
                        const SizedBox(height: 8),
                        if (movie['genre'] != null) Text('Genre: ${movie['genre']}'),
                        Text('Time: $time'),
                        Text('Price: \$$price'),
                          
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}