import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import '../models/product.dart';
import '../models/user.dart';

class ConnectedProductsModel extends Model {
  List<Product> _products = [];
  User _authenticatedUser;
  String _selProductId;
  bool _isLoading = false;

  Future<bool> addProduct(String title, String description, String image, double price) {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'image': 'https://cdn.pixabay.com/photo/2013/09/18/18/24/chocolate-183543_1280.jpg',
      'price': price,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id
    };
    return http.post('https://flutter-products-afca4.firebaseio.com/products.json', body: json.encode(productData))
    .then((http.Response response) {
      if (response.statusCode != 200 && response.statusCode != 201) {
        return false;
      }
      final Map<String, dynamic> responseData = json.decode(response.body);
      final Product newProduct = Product(
      id: responseData['name'],
      title: title, 
      description: description, 
      image: image, price: price,
      userEmail: _authenticatedUser.email,
      userId: _authenticatedUser.id
    );
    _products.add(newProduct);
    _isLoading = false;
    notifyListeners();
    return true;
    });
  }
}

class ProductsModel extends ConnectedProductsModel {
  bool _showFavorites = false;

  List<Product> get allProducts {
    // The below List.from() is used to create the copy of the existing list.

    return List.from(_products);
  }

  List<Product> get displayedProducts {
    // The below List.from() is used to create the copy of the existing list.
    if (_showFavorites) {
      return List.from(_products.where((Product product) => product.isFavorite).toList());
    }
    return List.from(_products);
  }

  int get selectedProductIndex {
    return _products.indexWhere((Product product) {
      return product.id == _selProductId;
    });
  } 

  String get selectedProductId {
    return _selProductId;
  }

  Product get selectedProduct {
    if (selectedProductId == null) return null;
    return _products.firstWhere((Product product) {
      return product.id == _selProductId;
    });
  }

  Future<Null> updateProduct(String title, String description, String image, double price) {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> updateData = {
      'title': title,
      'description': description,
      'image': 'https://cdn.pixabay.com/photo/2013/09/18/18/24/chocolate-183543_1280.jpg',
      'price': price,
      'userEmail': selectedProduct.userEmail,
      'userId': selectedProduct.userId
    };
    return http.put('https://flutter-products-afca4.firebaseio.com/products/${selectedProduct.id}.json', body: json.encode(updateData))
      .then((http.Response response) {
        _isLoading = false;
        final Product updatedProduct = Product(
          id: selectedProduct.id,
          title: title,
          description: description,
          image: image,
          price: price,
          userEmail: selectedProduct.userEmail,
          userId: selectedProduct.userId
        );
      _products[selectedProductIndex] = updatedProduct;
      notifyListeners();
      });
  }

  void deleteProduct() {
    _isLoading = true;
    final deletedProductId = selectedProduct.id;
    _products.removeAt(selectedProductIndex);
    _selProductId = null;
    notifyListeners();
    http.delete('https://flutter-products-afca4.firebaseio.com/products/${deletedProductId}.json')
      .then((http.Response response) {
        _isLoading = false;
        _products.removeAt(selectedProductIndex);
      notifyListeners();
      });
  }

  void selectProduct(String productId) {
    _selProductId = productId;
    notifyListeners();
  }

  Future<Null> fetchProducts() {
    _isLoading = true;
    notifyListeners();
    return http.get('https://flutter-products-afca4.firebaseio.com/products.json')
      .then((http.Response response) {
        final List<Product> fetchedProductList = [];
        final Map<String, dynamic> productListData = json.decode(response.body);
        if (productListData == null) {
          _isLoading = false;
          notifyListeners();
          return;
        }
        productListData.forEach((String productId, dynamic productData) {
          final Product product = Product(
            id: productId,
            title: productData['title'],
            description: productData['description'],
            image: productData['image'],
            price: productData['price'],
            userEmail: productData['userEmail'],
            userId: productData['userId']
          );
          fetchedProductList.add(product);
        });
        _products = fetchedProductList;
        _isLoading = false;
        notifyListeners();
        _selProductId = null;
      });
  }

  void toggleProductFavoriteStatus() {
    final bool isCurrentlyFavorite =
        selectedProduct.isFavorite;
    final bool newFavoriteStatus = !isCurrentlyFavorite;
    final Product updatedProduct = Product(
      id: selectedProduct.id,
      title: selectedProduct.title,
      description: selectedProduct.description,
      image: selectedProduct.image,
      price: selectedProduct.price,
      userEmail: selectedProduct.userEmail,
      userId: selectedProduct.userId,
      isFavorite: newFavoriteStatus
    );

    _products[selectedProductIndex] = updatedProduct;
    notifyListeners();
  }

  bool get displayFavoritesOnly {
    return _showFavorites;
  }

  void toggleDisplayMode() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }
}


class UserModel extends ConnectedProductsModel {

  void login(String email, String password) {
    _authenticatedUser = User(id: 'fsadlsfasf', email: email, password: password);
  }
}

class UtilityModel extends ConnectedProductsModel {
  bool get isLoading {
    return _isLoading;
  }
}