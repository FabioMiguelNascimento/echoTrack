import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;

class PermissionHelper {
  /// Requests microphone permission, shows a Snackbar and returns the status.
  /// If permission is permanently denied, shows a dialog that can open app settings.
  static Future<PermissionStatus> requestMicrophonePermission(
    BuildContext context,
  ) async {
    final current = await Permission.microphone.status;

    if (current.isGranted) {
      return current;
    }

    // If denied (but not permanently), request and return result
    if (current.isDenied) {
      final status = await Permission.microphone.request();
      if (status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissão de microfone concedida!')),
        );
      } else if (status.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissão de microfone negada.')),
        );
      }
      return status;
    }

    // If permanently denied or restricted, guide user to settings
    if (current.isPermanentlyDenied || current.isRestricted) {
      final open = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Permissão necessária'),
            content: const Text(
              'O app precisa acessar o microfone para busca por voz. Abra as configurações do app para liberar a permissão.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Abrir Configurações'),
              ),
            ],
          );
        },
      );

      if (open == true) {
        await openAppSettings();
      }
      return current;
    }

    // Fallback: request
    final status = await Permission.microphone.request();
    return status;
  }
}

extension GalleryPermission on PermissionHelper {
  /// Requests permission to access gallery/files. Chooses the proper
  /// permission depending on the platform (storage for Android, photos for iOS).
  static Future<PermissionStatus> requestGalleryPermission(
    BuildContext context,
  ) async {
    // Android: use storage (or READ_MEDIA_IMAGES on Android 13+, permission_handler
    // will map Permission.photos appropriately in newer versions).
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (status.isGranted) return status;
      if (status.isPermanentlyDenied) {
        final open = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Permissão necessária'),
            content: const Text(
              'O app precisa acessar as imagens do dispositivo para selecionar a foto da loja. Abra as configurações do app para liberar a permissão.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Abrir Configurações'),
              ),
            ],
          ),
        );
        if (open == true) await openAppSettings();
      }
      return status;
    } else {
      // iOS / macOS: request photos
      final status = await Permission.photos.request();
      if (status.isPermanentlyDenied) {
        final open = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Permissão necessária'),
            content: const Text(
              'O app precisa acessar as fotos para selecionar a foto da loja. Abra as configurações do app para liberar a permissão.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Abrir Configurações'),
              ),
            ],
          ),
        );
        if (open == true) await openAppSettings();
      }
      return status;
    }
  }
}
