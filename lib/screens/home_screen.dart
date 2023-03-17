// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// es un widget con estados
class _HomeScreenState extends State<HomeScreen> {
  // Los estados de los dos campos de texto
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // variable que referencia a la colección 'products'
  final CollectionReference _products =
      FirebaseFirestore.instance.collection('products');

  // Función que se dispara cuando se pulsa el botón flotante o el icono de editar
  // Añade un documento si no se le pasa un documentSnapshot
  // Si documentSnapshot != null actualiza un documento existente
  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';

    // hay un documentSnapshot
    if (documentSnapshot != null) {
      action = 'update';
      // mete el contenido del snapshot en los states
      _nameController.text = documentSnapshot['name'];
      _priceController.text = documentSnapshot['price'].toString();
    }

    // funcion propia de flutter que muestra una ventanida emergente abajo
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                // Cuida que el teclado no tape los campos de texto:
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  // lee la variable que configuramos arriba dependiendo de cual botón disparó esto:
                  child: Text(action == 'create' ? 'Create' : 'Update'),
                  onPressed: () async {
                    // mete en nuevas variables los states (convierte a numero el precio)
                    final String? name = _nameController.text;
                    final double? price =
                        double.tryParse(_priceController.text);

                    if (name != null && price != null) {
                      if (action == 'create') {
                        // Guarda un nuevo documento en Firebase
                        await _products.add({'name': name, 'price': price});
                      }

                      if (action == 'update') {
                        // Edita un documento existente
                        await _products
                            .doc(documentSnapshot!.id)
                            .update({"name": name, "price": price});
                      }

                      // Limpia los states de los campos de texto
                      _nameController.text = '';
                      _priceController.text = '';

                      // Oculta la ventanita inferior
                      Navigator.of(context).pop();
                    }
                  },
                )
              ],
            ),
          );
        });
  }

  // Función para borrar un documento en Firebase
  Future<void> _deleteProduct(String productId) async {
    await _products.doc(productId).delete();

    // Muestra notificación en snackbar
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El producto se eliminó con éxito.')));
  }

  // Declarados los states y las funciones, aqui declaramos el widget HomeScreen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prueba Flutter Firebase'),
      ),
      // El widget StreamBuilder actualiza en tiempo real los cambios de Firebase
      body: StreamBuilder(
        // se alimenta con un onSnapshot() de Firestore
        stream: _products.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          // si hay documentos, renderiza una lista
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              // itemBuilder va a recorrer automáticamente el array de docs
              itemBuilder: (context, index) {
                // guarda en variable el documento actual por el index que devuelve el itemBuilder
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                return Card(
                  margin: const EdgeInsets.all(6),
                  child: ListTile(
                    // muestra directamente el contenido del documento de Firebase en pantalla
                    title: Text(documentSnapshot['name']),
                    subtitle: Text(documentSnapshot['price'].toString()),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          // Press this button to edit a single product
                          IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  _createOrUpdate(documentSnapshot)),
                          // This icon button is used to delete a single product
                          IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  _deleteProduct(documentSnapshot.id)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          // si no habia datos se muestra el spinner
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),

      // Botón flotante para crear nuevo producto
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createOrUpdate(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
