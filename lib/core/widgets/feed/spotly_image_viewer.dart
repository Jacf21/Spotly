import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Modelo genérico para el visor — cualquier página puede usarlo
class SpotlyImageItem {
  final String imageUrl;
  final String? descripcion;
  final String? usuario;

  const SpotlyImageItem({
    required this.imageUrl,
    this.descripcion,
    this.usuario,
  });
}

class SpotlyImageViewer extends StatefulWidget {
  final List<SpotlyImageItem> items;
  final int initialIndex;

  const SpotlyImageViewer({
    super.key,
    required this.items,
    this.initialIndex = 0,
  });

  /// Abre el visor como ruta modal sobre cualquier página
  static void show(
    BuildContext context, {
    required List<SpotlyImageItem> items,
    int initialIndex = 0,
  }) {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black87,
      pageBuilder: (_, __, ___) => SpotlyImageViewer(
        items: items,
        initialIndex: initialIndex,
      ),
    ));
  }

  @override
  State<SpotlyImageViewer> createState() => _SpotlyImageViewerState();
}

class _SpotlyImageViewerState extends State<SpotlyImageViewer> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.items[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [

        // Swipe + zoom entre imágenes
        PageView.builder(
          controller: _pageController,
          itemCount: widget.items.length,
          onPageChanged: (i) => setState(() => _currentIndex = i),
          itemBuilder: (_, i) {
            return InteractiveViewer(
              minScale: 1.0,
              maxScale: 4.0,
              child: Center(
                child: Image.network(
                  widget.items[i].imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (_, child, progress) => progress == null
                      ? child
                      : const Center(
                          child: CircularProgressIndicator(
                              color: Colors.white54)),
                  errorBuilder: (_, __, ___) => const Icon(
                      Icons.broken_image,
                      color: Colors.white54,
                      size: 64),
                ),
              ),
            );
          },
        ),

        // Botón cerrar
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 12,
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
          ),
        ),

        // Indicador de puntos (si hay más de 1 imagen)
        if (widget.items.length > 1)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "${_currentIndex + 1} / ${widget.items.length}",
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13),
              ),
            ),
          ),

        // Info inferior
        if (current.descripcion != null || current.usuario != null)
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 20, right: 20, top: 20,
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.85),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (current.descripcion != null &&
                      current.descripcion!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(current.descripcion!,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14)),
                    ),
                  if (current.usuario != null &&
                      current.usuario!.isNotEmpty)
                    Row(children: [
                      const Icon(LucideIcons.user,
                          size: 14, color: Colors.white60),
                      const SizedBox(width: 6),
                      Text(current.usuario!,
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ]),
                ],
              ),
            ),
          ),
      ]),
    );
  }
}