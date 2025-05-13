import 'package:cine_libre/models/series.dart';

final List<Series> mockSeries = [
  Series(
    id: 101,
    name: "Beat the Geeks",
    overview: "Walter White se convierte en narcotraficante.",
    posterPath: "",
    voteAverage: 9.5,
    genres: [{"id": 18, "name": "Drama"}, {"id": 80, "name": "Crimen"}],
    numberOfSeasons: 5,
    numberOfEpisodes: 62,
    backdropPath: "",
  ),
  Series(
    id: 102,
    name: "Stranger Things",
    overview: "Un grupo de niños descubre un mundo sobrenatural.",
    posterPath: "/example.jpg",
    voteAverage: 8.7,
    genres: [{"id": 10765, "name": "Ciencia Ficción"}, {"id": 9648, "name": "Misterio"}],
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
    genres: [{"id": 27, "name": "Aventuras"}, {"id":
    878, "name": "Acción"}],
    numberOfSeasons: 11,
  )
];
