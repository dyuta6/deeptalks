import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FullScreenImagePage extends StatefulWidget {
  final Map<String, dynamic> documentData;
  final String initialImageUrl;

  const FullScreenImagePage({
    super.key,
    required this.documentData,
    required this.initialImageUrl,
  });

  @override
  State<FullScreenImagePage> createState() => _FullScreenImagePageState();
}

class _FullScreenImagePageState extends State<FullScreenImagePage> {
  late PageController _pageController;
  late List<String> _imageUrls;
  late int _initialPage;
  late int _currentPageIndex;

  @override
  void initState() {
    super.initState();
    _imageUrls = _extractImageUrlsFromDocument();
    
    final cleanedTappedImageUrl = widget.initialImageUrl.startsWith('@')
        ? widget.initialImageUrl.substring(1)
        : widget.initialImageUrl;

    _initialPage = _imageUrls.indexOf(cleanedTappedImageUrl);

    if (_initialPage == -1) {
      _initialPage = _imageUrls.isNotEmpty ? 0 : -1;
    }

    _currentPageIndex = _initialPage != -1 ? _initialPage : 0;
    
    if (_imageUrls.isNotEmpty && _initialPage != -1) {
      _pageController = PageController(initialPage: _initialPage);
    } else {
      _pageController = PageController(initialPage: 0);
    }
  }

  List<String> _extractImageUrlsFromDocument() {
    final urls = <String>[];
    final fields = List<String>.generate(15, (i) => 'main${i == 0 ? '' : (i + 1).toString()}');

    for (var field in fields) {
      if (widget.documentData.containsKey(field)) {
        final url = widget.documentData[field] as String?;
        if (url != null && url.isNotEmpty) {
          urls.add(url.startsWith('@') ? url.substring(1) : url);
        }
      }
    }
    return urls;
  }

  @override
  Widget build(BuildContext context) {
    if (_imageUrls.isEmpty || _initialPage == -1) { 
        return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
                backgroundColor: Colors.black,
                iconTheme: const IconThemeData(color: Colors.white),
                title: const Text('Resim Galerisi', style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            body: const Center(
                child: Text(
                    'Gösterilecek resim bulunamadı.',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                ),
            ),
        );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
         leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(2.0), // Padding around the icon inside the circle
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5), // White circular border
            ),
            child: Center(child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18)), // Adjusted icon size
          ),
          tooltip: 'Geri', // Erişilebilirlik için
          onPressed: () => Navigator.of(context).pop(),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentPageIndex + 1} / ${_imageUrls.length}',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: _imageUrls.length,
        onPageChanged: (index) { 
          setState(() {
            _currentPageIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final imageUrl = _imageUrls[index];
          return Center(
            child: InteractiveViewer(
              panEnabled: false,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 50,
                  ),
                ),
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
} 