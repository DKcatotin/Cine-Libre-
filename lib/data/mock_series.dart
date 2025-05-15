import 'package:cine_libre/models/series.dart';

final List<Series> mockSeries = [
  Series(
    id: 101,
    name: "Beat the Geeks",
    overview: "Walter White se convierte en narcotraficante.",
    posterPath: "",
    voteAverage: 9.5,
    genres: ["Drama", "Crimen"],
    numberOfSeasons: 5,
    numberOfEpisodes: 62,
    backdropPath: "",
  ),
  Series(
    id: 102,
    name: "Driven",
    overview: "Un grupo de niños descubre un mundo sobrenatural.",
    posterPath: "/example.jpg",
    voteAverage: 8.7,
    genres: ["Ciencia Ficción", "Misterio"],
    numberOfSeasons: 4,
    numberOfEpisodes: 34,
    backdropPath: "/example.jpg",
  ),
  Series(
    id: 30,
    name: 'St.Elsewhere',
    overview: 'Una serie llena de intrigas y secretos.',
    posterPath: '/example.jpg',
    voteAverage: 8.1,
    genres: ["Aventuras", "Acción"],
    numberOfSeasons: 11,
  ),
];
