import 'package:cine_libre/models/series.dart';

final List<Series> mockSeries = [
  Series(
    id: 101,
    name: "Beat the Geeks",
    overview: "Walter White se convierte en narcotraficante.",
    posterPath: "https://static.tvtropes.org/pmwiki/pub/images/beat_the_geeks_1.png",
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
    posterPath: "https://media.themoviedb.org/t/p/w500/lVJe0I0dYO1vY527g3SixIwVQ1D.jpg",
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
    posterPath: 'https://m.media-amazon.com/images/S/pv-target-images/19e062be29e67bf0907baa2dc1b0358c4c86cf739cd8e6dac2527028bdb98cda.jpg',
    voteAverage: 8.1,
    genres: ["Aventuras", "Acción"],
    numberOfSeasons: 11,
  ),
];
