import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ImageService {
  static const String defaultRecipeImage = 'assets/images/default_recipe.png';

  // Verificar si una URL es válida
  static bool isValidUrl(String? url) {
    if (url == null || url.isEmpty) {
      return false;
    }

    return url.startsWith('http://') || url.startsWith('https://');
  }

  // Verificar si hay conexión a internet
  static Future<bool> isConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Obtener el widget de imagen adecuado según la URL
  static Widget getImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    // Si es una URL web válida y hay conexión, usar CachedNetworkImage
    if (isValidUrl(imageUrl)) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => Image.asset(
          defaultRecipeImage,
          width: width,
          height: height,
          fit: fit,
        ),
      );
    } 
    // Si es una ruta de asset o la URL es inválida, usar imagen local
    else {
      // Verificar si es una ruta de assets o usar la imagen predeterminada
      String imagePath = imageUrl.startsWith('assets/') 
          ? imageUrl 
          : defaultRecipeImage;
      
      return Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            defaultRecipeImage,
            width: width,
            height: height,
            fit: fit,
          );
        },
      );
    }
  }
}
