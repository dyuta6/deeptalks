import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'full_screen_image_page.dart';
import 'dart:io' show Platform; // Platformu kontrol etmek için

class IzgaraPage extends StatelessWidget {
  final String collectionPath;
  
  const IzgaraPage({
    super.key,
    required this.collectionPath,
  });

  @override
  Widget build(BuildContext context) {
    // iOS tarzı geri butonu için bir kontrol
    final bool isIOS = Platform.isIOS;

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
      
        iconTheme: const IconThemeData(color: Colors.white), // Bu genel ikon temasını etkiler, leading'i etkilemeyebilir
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .doc(collectionPath)
            .collection('pics')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Bir hata oluştu',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }

          final docs = snapshot.data!.docs;
          
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'Henüz resim eklenmemiş',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(2),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              childAspectRatio: 0.7,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              
              String? imageUrlToShow;
              final imageFields = List.generate(15, (i) => 'main${i == 0 ? '' : (i + 1).toString()}');

              for (var field in imageFields) {
                if (data.containsKey(field)) {
                  final url = data[field] as String?;
                  if (url != null && url.isNotEmpty) {
                    imageUrlToShow = url;
                    break;
                  }
                }
              }

              if (imageUrlToShow == null || imageUrlToShow.isEmpty) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    border: Border.all(
                      color: Colors.grey[800]!,
                      width: 1,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.grey,
                      size: 30,
                    ),
                  ),
                );
              }
              
              final cleanedImageUrl = imageUrlToShow.startsWith('@') ? imageUrlToShow.substring(1) : imageUrlToShow;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenImagePage(
                        documentData: data,
                        initialImageUrl: cleanedImageUrl,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[800]!,
                      width: 1,
                    ),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: cleanedImageUrl,
                    fit: BoxFit.fitWidth,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[900],
                      child: Center(
                        child: Container(
                          width: 30.0, // Diameter of the circular border
                          height: 30.0, // Diameter of the circular border
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5), // White circular border
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(2.0), // Padding between border and indicator
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.0, // Thickness of the indicator's line
                            ),
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[900],
                      child: const Center(
                        child: Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
} 