import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'izgara.dart';

// İkon eşleştirme (State sınıfının dışında veya bir yardımcı dosyada olabilir)
Map<String, IconData> _stringToIconData = {
  'favorite': Icons.favorite, // Kırmızı olacak
  'star_icon': Icons.star,    // Sarı olacak
  'qa_icon': Icons.question_answer,
  'bolt_icon': Icons.bolt,      // Mavi olacak
  'home': Icons.home,          // Yeşil olacak
  'settings': Icons.settings,
  'search': Icons.search,
  'info': Icons.info_outline,
  'arrow_drop_down': Icons.arrow_drop_down,
  'play_arrow': Icons.play_arrow,
  'audiotrack': Icons.audiotrack,
  'movie': Icons.movie,
  // Diğer ikonlar...
};

IconData getIconDataFromString(String? iconName) {
  return _stringToIconData[iconName ?? ''] ?? Icons.arrow_drop_down; // Varsayılan ikon
}

Color getIconColor(String? iconName) {
  switch (iconName) {
    case 'favorite':
      return Colors.red;
    case 'star_icon':
      return Colors.yellow[700]!;
    case 'bolt_icon':
      return Colors.blue;
    case 'home':
      return Colors.green;
    default:
      return Colors.white;
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _expandedDocId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          child: Padding( 
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0), // Yatay padding de eklendi
            child: Column( 
              children: [
                const Text( // En üste "Bir Paket Seçin"
                  'Bir Paket Seçin',
                  style: TextStyle(
                    color: Colors.white70, // Biraz daha soluk bir renk
                    fontSize: 24.0, 
                    fontWeight: FontWeight.w500, // Biraz daha ince bir kalınlık
                  ),
                ),
                const SizedBox(height: 20.0), // "Bir Paket Seçin" ile StreamBuilder arasında boşluk
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('posts').snapshots(),
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

                    var sortedDocs = snapshot.data!.docs.toList()
                      ..sort((a, b) {
                        String titleA = (a.data() as Map<String, dynamic>)['title'] ?? '';
                        String titleB = (b.data() as Map<String, dynamic>)['title'] ?? '';
                        
                        if (titleA == 'Premium Sorular') return 1;
                        if (titleB == 'Premium Sorular') return -1;
                        return titleA.compareTo(titleB);
                      });

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: sortedDocs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                        String? description = data['description'] as String?;
                        String? iconFieldName = data['icon'] as String?;

                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _expandedDocId = _expandedDocId == document.id ? null : document.id;
                                });
                                
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0), 
                                margin: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(15.0),
                                  border: Border.all(color: Colors.grey, width: 2.0),
                                ),
                                child: Row( 
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                                  children: [
                                    Expanded( 
                                      child: Column( 
                                        crossAxisAlignment: CrossAxisAlignment.start, 
                                        mainAxisSize: MainAxisSize.min, 
                                        children: [
                                          Text(
                                            data['title'] ?? 'Başlık Yok',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20.0,
                                            ),
                                          ),
                                          if (description != null && description.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 4.0), 
                                              child: Text(
                                                description,
                                                style: TextStyle(
                                                  color: Colors.grey[400],
                                                  fontSize: 14.0,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      getIconDataFromString(iconFieldName),
                                      color: getIconColor(iconFieldName), 
                                      size: 24.0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_expandedDocId == document.id)
                              StreamBuilder<QuerySnapshot>(
                                stream: _firestore
                                    .collection('posts')
                                    .doc(document.id)
                                    .collection('alt')
                                    .snapshots(),
                                builder: (context, subSnapshot) {
                                  if (subSnapshot.hasError) {
                                    return const Center(
                                      child: Text(
                                        'Alt koleksiyon yüklenirken hata oluştu',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    );
                                  }

                                  if (subSnapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    );
                                  }

                                  return Column(
                                    children: subSnapshot.data!.docs.map((subDoc) {
                                      Map<String, dynamic> subData = subDoc.data() as Map<String, dynamic>;
                                      return GestureDetector(
                                        onTap: () {
                                          String collectionPath = 'posts/${document.id}/alt/${subDoc.id}';
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => IzgaraPage(
                                                collectionPath: collectionPath,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          height: 80,
                                          margin: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 4.0),
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: BorderRadius.circular(12.0),
                                            border: Border.all(color: Colors.grey[700]!, width: 1.0),
                                          ),
                                          child: Center(
                                            child: Text(
                                              subData['title'] ?? 'Alt Başlık Yok',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                          ],
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 30.0), // StreamBuilder ile "DeepTalks" arasında boşluk
                const Text(  // En alta DeepTalks başlığı
                  'DeepTalks',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28.0, // Boyutu biraz küçültüldü
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 