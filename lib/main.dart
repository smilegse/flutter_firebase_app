import 'dart:io';
import 'package:path/path.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_firebase_app/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:developer';

import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BookListScreen(),
    );
  }
}

class BookListScreen extends StatefulWidget {
  const BookListScreen({Key? key}) : super(key: key);

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  final firebaseFirestore = FirebaseFirestore.instance;
  final fireStorage = FirebaseStorage.instance;

  List<Book> books = [];
  bool _getBooksInProgress = false;

  @override
  void initState() {
    super.initState();
    //getAllBooks();
  }

  Future<void> getAllBooks() async {
    _getBooksInProgress = true;
    setState(() {});
    books.clear();
    await firebaseFirestore.collection('books').get().then((documents) {
      //log(documents.docs.length.toString());
      for (var doc in documents.docs) {
        books.add(Book(doc.get('name'), doc.get('writer'), doc.get('year')));
      }
    });
    log(books.length.toString());
    _getBooksInProgress = false;
    setState(() {});
  }

  Future<File> getImageFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');
    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.create(recursive: true);
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes,byteData.lengthInBytes),);
    return file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Collection'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ImageScreen()));
              },
              icon: const Icon(Icons.image)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.upload_file_rounded),
        onPressed: () async {
          File file = await getImageFromAssets('images/enzyme.jpg');
          if(await file.exists()){
            log('found');
          }else{
            log('not found');
          }
          fireStorage .ref('profile_pic').child(basename(file.path)).putFile(file).then((p0) {
            log(p0.toString());
          }).onError((error, stackTrace) {
            log(error.toString());
            log(stackTrace.toString());
          });
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: firebaseFirestore.collection('books').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }
            if (snapshot.hasData) {
              books.clear();
              for (var doc in snapshot.data!.docs) {
                books.add(
                    Book(doc.get('name'), doc.get('writer'), doc.get('year')));
              }

              return ListView.builder(
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(books[index].name),
                      subtitle: Text(books[index].authorName),
                      trailing: Text(books[index].year),
                    );
                  });
            } else {
              return const Center(
                child: Text('No data available'),
              );
            }
          }),
    );
  }
}

class Book {
  final String name, authorName, year;

  Book(this.name, this.authorName, this.year);
}

class ImageScreen extends StatefulWidget {
  const ImageScreen({Key? key}) : super(key: key);

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  final fireStorage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    getImages();
  }

  Future getImages() async {
    fireStorage.ref().child("profile_pic").listAll().then((listResult) {
      log(listResult.items.length.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Screen'),
      ),
      body: Center(
        child: Text('Image screen'),
      ),
    );
  }
}
