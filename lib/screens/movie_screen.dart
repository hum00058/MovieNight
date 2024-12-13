import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/utils/http_helper.dart';

class MovieScreen extends StatefulWidget {
  final String deviceId;
  final String sessionId;

  const MovieScreen({
    super.key,
    required this.deviceId,
    required this.sessionId,
  });

  @override
  _MovieScreenState createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {
  List<Map<String, dynamic>> movies = [];
  int currentIndex = 0;
  int currentPage = 1;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      final newMovies = await HttpHelper.getMovies(currentPage);

      if (kDebugMode) {
        print(newMovies);
      }

      setState(() {
        movies.addAll(newMovies);
        currentPage++;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load movies: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void handleVote(bool vote) async {
    final movieId = movies[currentIndex]['id'];
    final result = await HttpHelper.voteMovie(widget.sessionId, movieId, vote);

    if (result['match'] == true) {
      // Show a dialog if there's a match
      return;
    }

    setState(() {
      currentIndex++;
      if (currentIndex == movies.length) {
        currentIndex = 0;
        fetchMovies();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Movie Selection')),
        body: Center(
          child: isLoading
              ? CircularProgressIndicator()
              : Text('No movies available'),
        ),
      );
    }

    final movie = movies[currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text('Movie Selection')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          movie['poster_path'] != null
              ? Image.network(
                  'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                  height: 400,
                )
              : Container(
                  height: 400,
                  color: Colors.grey,
                  child: Center(child: Text('No Image')),
                ),
          SizedBox(height: 20),
          Text(
            movie['title'] ?? 'Not Found',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.close, size: 50, color: Colors.red),
                onPressed: () => handleVote(false),
              ),
              SizedBox(width: 50),
              IconButton(
                icon: Icon(Icons.check, size: 50, color: Colors.green),
                onPressed: () => handleVote(true),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
