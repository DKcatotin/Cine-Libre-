import 'package:cine_libre/models/episode.dart';

import '../models/movie.dart';

final List<Movie> mockMovies = [
  Movie(
    id: '1',
    title: 'Sin límites',
    description: 'Sin Límites es un thriller de acción protagonizado por Bradley Cooper y Robert De Niro. La película trata sobre un escritor fracasado que toma una "droga inteligente" secreta que le permite usar el 100% de su capacidad cerebral y convertirse en una versión perfecta de sí mismo. La película es un thriller de acción.',
    youtubeId: 'p3M3wjPNH_k',
    imageUrl: 'https://es.web.img2.acsta.net/medias/nmedia/18/83/43/68/19690921.jpg',
    genre: 'Terror, Ciencia Ficción, Aventura',
    isSeries: false,
    
  ),
  Movie(
    id: '2',
    title: 'Comedia Retro',
    description: 'Ríe con los clásicos de la vieja escuela.',
    youtubeId: 'sNPnbI1arSE',
    imageUrl: 'https://image.tmdb.org/t/p/w500/qmDpIHrmpJINaRKAfWQfftjCdyi.jpg',
    genre: 'Comedia',
    isSeries: false,
  ),
   Movie(
    id: '3',
    title: 'Documental Naturaleza',
    description: 'Explora la belleza del mundo salvaje.',
    youtubeId: 'MB3inHJO2FM',
    imageUrl: 'https://image.tmdb.org/t/p/w500/rAiYTfKGqDCRIIqo664sY9XZIvQ.jpg',
    genre: 'Documental',
    isSeries: false,
  ),
  Movie(
    id: '4',
    title: 'Video musical',
    description: 'Musica de artista argentino con 802 millones de reproducciónes',
    youtubeId: 'XQ0D_QD_DhM',
    imageUrl: 'https://i.ytimg.com/vi/IvWzv9a_Aw8/maxresdefault.jpg',
    genre: 'Acción, Drama',
    isSeries: false,
  ),
  Movie(
    id: '5',
    title: 'Pelicula un Don exepcional ',
    description: 'Un Don Excepcional es una película que relata la historia de una niña con un asombroso talento para las matemáticas. Su tío busca criarla bajo un marco de normalidad, pero la abuela materna quiere explotar su don especial. La película trata sobre las dificultades de la niña para asimilar la realidad social, personal, sentimental y familiar que la rodea',
    youtubeId: 'oDYMxslKPeY',
    imageUrl: 'https://is4-ssl.mzstatic.com/image/thumb/Video123/v4/c7/16/08/c7160896-a065-b269-28d8-7b6f1719796d/1223524760-ES-AMP_SF.lsr/1200x675.jpg',
    genre: 'Acción',
    isSeries: false,
    isFeatured: true,
  ),
  Movie(
    id: '6',
    title: 'Una pelicula de Huevos ',
    description: '"Una película de huevos" es una producción mexicana de los directores Gabriel y Rodolfo Riva Palacio. La película presenta a Toto, un huevito sagaz y simpático que sueña con convertirse en un gran pollo de granja. Junto con su compañero Willy y un Tocino de baja inteligencia, emprende una emocionante aventura para llegar a "las granjas el pollón"',
    youtubeId: 'h_zUuj81jH4',
    imageUrl: 'https://www.lavanguardia.com/peliculas-series/images/movie/poster/2006/4/w1280/sWl9Qhv8PZyq6gviDeT88kBU3tI.jpg',
    genre: 'Acción, Animación, Aventura',
    isSeries: false,
    isFeatured: true,
  ),
  Movie(
    id: '7',
    title: 'Matilda',
    description: 'Disfruta de la mágica aventura de Matilda, una película llena de risas, ingenio y enseñanzas inolvidables! Con audio en español latino y calidad HD, acompaña a esta pequeña genio en su lucha contra las injusticias y en su viaje para descubrir su verdadero poder. 🌟👩‍🏫 ¡Ideal para toda la familia!',
    youtubeId: 'zdbEYAXDXFo',
    imageUrl: 'https://www.mubis.es/media/movies/3161/62641/matilda-original.jpg',
    genre: 'Acción, Comedia, Aventura',
    isSeries: false,
    isFeatured: true,
  ),
   Movie(
    id: '9',
    title: 'The Walking Dead',
    description: 'Una serie llena de intrigas y secretos.',
    youtubeId: '',
    imageUrl: 'https://m.media-amazon.com/images/I/814FWjSQFfL._RI_.jpg',
    genre: 'Suspenso',
    isSeries: true,
    episodes: [
  Episode(
    title: 'Episodio 1: El comienzo',
    videoUrl: 'MB3inHJO2FM',
    duration: '47:01',
  ),
  Episode(
    title: 'Episodio 2: El secreto',
    videoUrl: 'DmlOLwyHpLQ',
    duration: '45:11',
  ),
],
  ),
];

