import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculateur de prix',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    PriceCalculator(),
    PriceComparator(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculateur de prix'),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // Fermer le clavier
        },
        child: _children[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Prix au kilo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.compare),
            label: 'Comparer',
          ),
        ],
      ),
    );
  }
}

class PriceCalculator extends StatefulWidget {
  @override
  _PriceCalculatorState createState() => _PriceCalculatorState();
}

class _PriceCalculatorState extends State<PriceCalculator> {
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  double _pricePerKilo = 0.0;

  void _calculatePricePerKilo() {
    final double quantity = double.tryParse(_quantityController.text) ?? 0.0;
    final double price = double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0; // Convert commas to dots
    setState(() {
      if (quantity != 0.0) {
        _pricePerKilo = (price / quantity) * 1000;
      } else {
        _pricePerKilo = 0.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          TextField(
            controller: _quantityController,
            decoration: InputDecoration(
              labelText: 'Contenance (g ou mL)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16.0),
          TextField(
            controller: _priceController,
            decoration: InputDecoration(
              labelText: 'Prix (en euros)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true), // Allow decimal input
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: _calculatePricePerKilo,
            child: Text('Calculer le prix au kilo'),
          ),
          SizedBox(height: 16.0),
          Text(
            'Prix au kilo: $_pricePerKilo €',
            style: TextStyle(fontSize: 20.0),
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              FocusScope.of(context).unfocus(); // Close keyboard
            },
            child: Text('Fermer le clavier'),
          ),
        ],
      ),
    );
  }
}

class PriceComparator extends StatefulWidget {
  @override
  _PriceComparatorState createState() => _PriceComparatorState();
}

class _PriceComparatorState extends State<PriceComparator> {
  List<TextEditingController> _quantityControllers = [];
  List<TextEditingController> _priceControllers = [];
  String _result = '';
  List<double> _pricePerKiloList = [];

  @override
  void initState() {
    super.initState();
    _addNewProduct(); // Ajouter le premier produit par défaut
  }

  void _addNewProduct() {
    setState(() {
      _quantityControllers.add(TextEditingController());
      _priceControllers.add(TextEditingController());
    });
  }

  void _comparePrices() {
    double lowestPricePerKilo = double.infinity;
    int bestProductIndex = -1;
    _pricePerKiloList.clear();

    for (int i = 0; i < _quantityControllers.length; i++) {
      final double quantity = double.tryParse(_quantityControllers[i].text) ?? 0.0;
      final double price = double.tryParse(_priceControllers[i].text.replaceAll(',', '.')) ?? 0.0; // Convert commas to dots

      if (quantity > 0) {
        final double pricePerKilo = (price / quantity) * 1000;
        _pricePerKiloList.add(pricePerKilo);
        if (pricePerKilo < lowestPricePerKilo) {
          lowestPricePerKilo = pricePerKilo;
          bestProductIndex = i;
        }
      } else {
        _pricePerKiloList.add(double.infinity); // Valeur infinie si quantité invalide
      }
    }

    setState(() {
      if (bestProductIndex >= 0) {
        _result = 'Le produit ${bestProductIndex + 1} est le plus économique';
      } else {
        _result = 'Veuillez entrer des données valides';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _quantityControllers.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    TextField(
                      controller: _quantityControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Contenance produit ${index + 1} (g ou mL)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 8.0),
                    TextField(
                      controller: _priceControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Prix produit ${index + 1} (en euros)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true), // Allow decimal input
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      _pricePerKiloList.length > index && _pricePerKiloList[index] != double.infinity
                          ? 'Prix au kilo: ${_pricePerKiloList[index].toStringAsFixed(2)} €'
                          : '',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 16.0),
                  ],
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _addNewProduct,
            child: Text('Ajouter un produit'),
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: _comparePrices,
            child: Text('Comparer les prix'),
          ),
          SizedBox(height: 16.0),
          Text(
            _result,
            style: TextStyle(fontSize: 20.0),
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              FocusScope.of(context).unfocus(); // Close keyboard
            },
            child: Text('Fermer le clavier'),
          ),
        ],
      ),
    );
  }
}
