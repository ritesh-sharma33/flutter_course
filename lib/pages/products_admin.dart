import 'package:flutter/material.dart';

import './product_edit.dart';
import './product_list.dart';
import '../scoped-models/main.dart';

class ProductsAdminPage extends StatelessWidget {
  final MainModel model;

  /* The below commented code is the implementation without scoped-model
  final Function addProduct;
  final Function deleteProduct;
  final List<Product> products;
  final Function updateProduct;

  ProductsAdminPage(this.addProduct, this.updateProduct,this.deleteProduct, this.products);
  */
  ProductsAdminPage(this.model);

  Widget _buildSideDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            automaticallyImplyLeading: false,
            title: Text('Choose'),
          ),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('All Products'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/products');
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: _buildSideDrawer(context),
        appBar: AppBar(
          title: Text('Manage Products'),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.create),
                text: 'Create Product'),
              Tab(
                icon: Icon(Icons.list),
                text: 'My Products')
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            ProductEditPage(),
            ProductListPage(model)
          ],
        ),
      ),
    );
  }
}


// TabBarView is a widget provided by flutter which interacts
// with the TabBarController which then detects and automatically
// load the right page in the TabBarView.

// A point to be noted for TabBarView Wodget
// It is a widget which doesnot changes the entire page 
// but instead it just loads the content of a page into another
// page i.e. it only require the main body of the page 
// instead of all those Scaffold() or AppBar().