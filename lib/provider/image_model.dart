// Copyright © 2020 - AudiSoft Consulting (https://www.audisoft.com/).
// Copyright © 2020 - Ideas Control (https://www.ideascontrol.com/).

// ----------------------------------------------------
// ----------Modelo de Imagen para Provider------------
// ----------------------------------------------------

import 'dart:async';
import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:henutsen_cli/globals.dart';
import 'package:photo_view/photo_view.dart';

/// Modelo de imagen
class ImageModel extends ChangeNotifier {
  /// Lista de imágenes a subir
  List<PlatformFile> imageArray = [];

  /// Lista de imágenes en el servidor
  List<String> loadedImages = [];

  /// Lista de todas las imágenes
  // Estructura {'Imagen': (ruta_imagen), 'Origen': (memoria_o_servidor)}
  List<Map<String, dynamic>> allImages = [];

  /// Índice de foto actualmente mostrada
  int photoIndex = 0;

  /// Reiniciar todas las variables de este modelo
  void resetAll() {
    imageArray = [];
    loadedImages = [];
    allImages = [];
    photoIndex = 0;
  }

  /// Agregar elemento a lista de imágenes
  void addPicture(PlatformFile newItem) {
    imageArray.add(newItem);
    allImages.add({'Imagen': newItem, 'Origen': 'Memoria'});
    notifyListeners();
  }

  /// Remover elemento de lista de imágenes
  void removePicture(int index) {
    final item = imageArray.removeAt(index);
    allImages.removeWhere((element) => element['Imagen'] == item);
    if (photoIndex > 0 && photoIndex >= index) {
      photoIndex--;
    }
    notifyListeners();
  }

  /// Remover elemento de lista de imágenes en servidor
  void removePictureFromServer(int index) {
    final item = loadedImages.removeAt(index);
    allImages.removeWhere((element) => element['Imagen'] == item);
    if (photoIndex > 0 && photoIndex >= index) {
      photoIndex--;
    }
    notifyListeners();
  }

  /// Incrementar índice de imagen mostrada
  void increaseIndex() {
    photoIndex++;
    notifyListeners();
  }

  /// Decrementar índice de imagen mostrada
  void decreaseIndex() {
    photoIndex--;
    notifyListeners();
  }

  /// Método para listar imágenes cargadas
  List<Widget> myPictures(BuildContext context) {
    final files = <Widget>[
      const Text('Imágenes cargadas:',
          style: TextStyle(fontWeight: FontWeight.bold))
    ];
    allImages.clear();
    // Revisar imágenes cargadas en servidor o en memoria
    if (imageArray.isEmpty && loadedImages.isEmpty) {
      files.add(Container());
    } else {
      // Primero imágenes del servidor
      for (var i = 0; i < loadedImages.length; i++) {
        var _name2show = '';
        if (loadedImages[i].length < 15) {
          _name2show = loadedImages[i];
        } else {
          _name2show = '${loadedImages[i].substring(0, 15)}...';
        }
        files.add(
          Row(children: [
            Text(_name2show),
            IconButton(
              icon: Icon(
                Icons.delete,
                color: Theme.of(context).highlightColor,
              ),
              onPressed: () {
                removePictureFromServer(i);
              },
            )
          ]),
        );
        allImages.add({'Imagen': loadedImages[i], 'Origen': 'Servidor'});
      }
      // Luego imágenes en memoria
      for (var i = 0; i < imageArray.length; i++) {
        var _name2show = '';
        if (imageArray[i].name.length < 15) {
          _name2show = imageArray[i].name;
        } else {
          _name2show = '${imageArray[i].name.substring(0, 15)}...';
        }
        files.add(
          Row(children: [
            Text(_name2show),
            IconButton(
              icon: Icon(
                Icons.delete,
                color: Theme.of(context).highlightColor,
              ),
              onPressed: () {
                removePicture(i);
              },
            )
          ]),
        );
        allImages.add({'Imagen': imageArray[i], 'Origen': 'Memoria'});
      }
    }
    return files;
  }

  /// Método para pre-cargar imágenes del servidor en el arreglo
  void preloadImageArray(List<String> myImages) {
    loadedImages.clear();
    for (var i = 0; i < myImages.length; i++) {
      loadedImages.add(myImages[i]);
      allImages.add({'Imagen': myImages[i], 'Origen': 'Servidor'});
    }
  }

  /// Método que retorna las fotos cargadas
  Widget photoContents(BuildContext context) {
    // Para información sobre tamaño de pantalla
    final mediaSize = MediaQuery.of(context).size;
    // Tamaños ajustables de widgets
    final _boxWidth = (mediaSize.width < screenSizeLimit) ? 300.0 : 600.0;
    const _boxHeight = 450.0;
    final _photoCount = loadedImages.length + imageArray.length;
    if (_photoCount == 0) {
      return const Center(child: Text('No hay imágenes cargadas'));
    } else {
      final pic = allImages[photoIndex]['Origen'] == 'Memoria'
          ? Image.memory(
              (allImages[photoIndex]['Imagen'] as PlatformFile).bytes!)
          : Image.network(allImages[photoIndex]['Imagen']);
      return Column(children: [
        SizedBox(
          width: 100,
          height: 150,
          child: InkWell(
            child: pic,
            onTap: () async {
              // Capturar información de la imagen
              final completer = Completer<ui.Image>();
              final picProvider = pic.image;
              picProvider
                  .resolve(ImageConfiguration.empty)
                  .addListener(ImageStreamListener((info, _) {
                completer.complete(info.image);
              }));
              final imageInfo = await completer.future;
              final _imgWidth = imageInfo.width.toDouble();
              final _imgHeight = imageInfo.height.toDouble();
              //print('${_imgWidth.toString()} x ${_imgHeight.toString()}');
              // Imagen grande en un cuadro de diálogo
              await showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  content: SingleChildScrollView(
                    child: SizedBox(
                      width: _boxWidth,
                      height: _boxHeight,
                      child: PhotoView(
                        imageProvider: picProvider,
                        loadingBuilder: (context, progress) => const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        backgroundDecoration:
                            const BoxDecoration(color: Colors.white),
                        customSize: Size(
                            _imgWidth < _boxWidth ? _imgWidth : _boxWidth - 20,
                            _imgHeight < _boxHeight
                                ? _imgHeight
                                : _boxHeight - 20),
                        enableRotation: true,
                        //minScale: PhotoViewComputedScale.contained * 0.5,
                        //maxScale: PhotoViewComputedScale.covered * 1.8,
                        //initialScale: PhotoViewComputedScale.contained * 0.7,
                        basePosition: Alignment.center,
                      ),
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Volver'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Text(
            _photoCount == 1 ? '$_photoCount imagen' : '$_photoCount imágenes'),
      ]);
    }
  }
}
