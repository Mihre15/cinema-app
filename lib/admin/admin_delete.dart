import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ManageMoviesPage extends StatefulWidget {
  const ManageMoviesPage({super.key});

  @override
  State<ManageMoviesPage> createState() => _ManageMoviesPageState();
}

class _ManageMoviesPageState extends State<ManageMoviesPage> {
  List<dynamic> movies = [];
  bool isLoading = false; // to track loading state
  final String baseUrl = 'http://10.0.2.2:3000';

  Future<void> fetchMovies() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse('$baseUrl/movies'));
      if (response.statusCode == 200) {
        setState(() {
          movies = json.decode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load movies')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching movies: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteMovie(String id) async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.delete(Uri.parse('$baseUrl/movies/$id'));
      if (response.statusCode == 200) {
        
        setState(() {
          movies.removeWhere((movie) => movie['id'].toString() == id); // Optimistic update
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Movie deleted')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete movie')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting movie: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Movies'),
        backgroundColor: Color(0xffD59708),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Loading indicator
          : ListView.builder(
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                return ListTile(
                  leading: Image.network(
                    '$baseUrl/uploads/${movie['image']}',
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(movie['title']),
                  subtitle: Text('${movie['genre']} • ${movie['time']} • \$${movie['price']}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      deleteMovie(movie['id'].toString());
                    },
                  ),
                );
              },
            ),
    );
  }
}
