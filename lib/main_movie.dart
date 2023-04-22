import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Movieflix!',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MovieHome(),
    );
  }
}

class Movie {
  final int id, vote_count;
  final num popularity, vote_average;
  final List<dynamic> genre_ids;
  final bool adult, video;
  final String original_language,
      original_title,
      overview,
      poster_path,
      release_date,
      title;

  Movie.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        vote_count = json['vote_count'],
        popularity = json['popularity'],
        vote_average = json['vote_average'],
        genre_ids = json['genre_ids'],
        adult = json['adult'],
        video = json['video'],
        original_language = json['original_language'],
        original_title = json['original_title'],
        overview = json['overview'],
        poster_path = json['poster_path'],
        release_date = json['release_date'],
        title = json['title'];
}

class MovieInfo {
  final String original_title,
      overview,
      title,
      backdrop_path,
      poster_path,
      homepage;
  final List<dynamic> genres;
  final int runtime;
  final num vote_average;

  MovieInfo.fromJson(Map<String, dynamic> json)
      : original_title = json['original_title'],
        overview = json['overview'],
        title = json['title'],
        genres = json['genres'],
        runtime = json['runtime'],
        vote_average = json['vote_average'],
        backdrop_path = json['backdrop_path'],
        poster_path = json['poster_path'],
        homepage = json['homepage'];
}

class MovieService {
  static const String baseUrl = "https://movies-api.nomadcoders.workers.dev";
  static String detailBaseUrl =
      "https://movies-api.nomadcoders.workers.dev/movie?id=";
  static const String popular = "popular"; // 가장 인기있는 영화
  static const String nowPlaying = "now-playing"; // 극장 상영중인 영화
  static const String comingSoon = "coming-soon"; // 곧 개봉하는 영화

  static List<Movie> popularList = [];
  static List<Movie> nowPlayingList = [];
  static List<Movie> comingSoonList = [];

  static Future<MovieInfo> fetchMovieInfo(int id) async {
    var url = Uri.parse('$detailBaseUrl$id');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      return MovieInfo.fromJson(data);
    } else {
      throw Exception('Failed to load data');
    }
  }

  static Future<List<Movie>> fetchPopular() async {
    var url = Uri.parse('$baseUrl/$popular');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      for (var movie in data["results"]) {
        popularList.add(Movie.fromJson(movie));
      }
    } else {
      throw Exception('Failed to load data');
    }
    return popularList;
  }

  static Future<List<Movie>> fetchNow() async {
    var url = Uri.parse('$baseUrl/$nowPlaying');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      for (var movie in data['results']) {
        nowPlayingList.add(Movie.fromJson(movie));
      }
    } else {
      throw Exception('Failed to load data');
    }
    return nowPlayingList;
  }

  static Future<List<Movie>> fetchComingSoon() async {
    var url = Uri.parse('$baseUrl/$comingSoon');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      for (var movie in data['results']) {
        comingSoonList.add(Movie.fromJson(movie));
      }
    } else {
      throw Exception('Failed to load data');
    }
    return comingSoonList;
  }
}

class MovieHome extends StatefulWidget {
  const MovieHome({super.key});

  @override
  State<MovieHome> createState() => _MovieHomeState();
}

class _MovieHomeState extends State<MovieHome> {
  void _onMovieTap(Movie movie) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MovieDetail(id: movie.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                const Text(
                  'Popular Movies',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                FutureBuilder(
                  future: MovieService.fetchPopular(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return SizedBox(
                        height: 250,
                        child: popularMovies(snapshot),
                      );
                    }
                    return const Text('Loading..');
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Now in Cinemas',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                FutureBuilder(
                  future: MovieService.fetchNow(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return SizedBox(
                        height: 200,
                        child: nowMovies(snapshot),
                      );
                    }
                    return const Text('Loading..');
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Coming soon',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                FutureBuilder(
                  future: MovieService.fetchComingSoon(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return SizedBox(
                        height: 200,
                        child: nowMovies(snapshot),
                      );
                    }
                    return const Text('Loading..');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ListView popularMovies(AsyncSnapshot<List<Movie>> snapshot) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: snapshot.data!.length,
      separatorBuilder: (context, index) {
        return const SizedBox(width: 10);
      },
      itemBuilder: (context, index) {
        var movie = snapshot.data![index];
        return GestureDetector(
          onTap: () => _onMovieTap(movie),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: FittedBox(
              fit: BoxFit.cover,
              child: Image.network(
                'https://image.tmdb.org/t/p/w500${movie.poster_path}',
              ),
            ),
          ),
        );
      },
    );
  }

  ListView nowMovies(AsyncSnapshot<List<Movie>> snapshot) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: snapshot.data!.length,
      separatorBuilder: (context, index) {
        return const SizedBox(width: 10);
      },
      itemBuilder: (context, index) {
        var movie = snapshot.data![index];
        return GestureDetector(
          onTap: () => _onMovieTap(movie),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.4,
                height: 150,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: Image.network(
                    'https://image.tmdb.org/t/p/w500${movie.poster_path}',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: Text(
                  movie.title,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class MovieDetail extends StatefulWidget {
  final int id;
  const MovieDetail({super.key, required this.id});

  @override
  State<MovieDetail> createState() => _MovieDetailState();
}

class _MovieDetailState extends State<MovieDetail> {
  late Future<MovieInfo> info;

  @override
  void initState() {
    super.initState();
    info = MovieService.fetchMovieInfo(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    String convertRuntime(int runtime) {
      Duration duration = Duration(minutes: runtime);
      int t = duration.inHours;
      int m = duration.inMinutes % 60;
      return '${t}h ${m}min';
    }

    String convertGenres(List<dynamic> genres) {
      String genresList = '';
      for (var g in genres) {
        if (genresList.isEmpty) {
          genresList = g['name'];
        } else {
          genresList += ',';
          genresList += g['name'];
        }
      }
      return genresList;
    }

    return FutureBuilder(
      future: info,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var movie = snapshot.data!;

          return Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  'https://image.tmdb.org/t/p/w500${movie.backdrop_path}',
                  fit: BoxFit.cover,
                ),
              ),
              Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  title: const Text(
                    'Back to list',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  centerTitle: false,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                body: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      starScore(movie.vote_average),
                      const SizedBox(height: 20),
                      Text(
                        '${convertRuntime(movie.runtime)} | ${convertGenres(movie.genres)}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Storyline',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        movie.overview,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 60),
                      FractionallySizedBox(
                        widthFactor: 1,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.yellow,
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Buy ticket',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
        return const Center(
          child: Text('Loading...'),
        );
      },
    );
  }

  Row starScore(num score) {
    int s = (score / 2).round();
    return Row(
      children: [
        Icon(
          Icons.star,
          size: 30,
          color: s >= 1 ? Colors.yellow.shade600 : Colors.white30,
        ),
        Icon(
          Icons.star,
          size: 30,
          color: s >= 2 ? Colors.yellow.shade600 : Colors.white30,
        ),
        Icon(
          Icons.star,
          size: 30,
          color: s >= 3 ? Colors.yellow.shade600 : Colors.white30,
        ),
        Icon(
          Icons.star,
          size: 30,
          color: s >= 4 ? Colors.yellow.shade600 : Colors.white30,
        ),
        Icon(
          Icons.star,
          size: 30,
          color: s >= 5 ? Colors.yellow.shade600 : Colors.white30,
        ),
      ],
    );
  }
}
