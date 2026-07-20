import '../../../models/product.dart';

List<Product> getLowStockProduct(List<Product> products){
  List<Product> lowStock = [];
  products.forEach((e){
    double restOfStock = e.stock!.baseStock - e.stock!.totalSell;
    if(restOfStock < 10) {
      lowStock.add(e);
    }
  });
  return lowStock;


}