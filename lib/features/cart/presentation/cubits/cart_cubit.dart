import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/meta_pixel_service.dart';
import '../../../products/data/model/product.dart';
import '../../../products/data/model/product_variant.dart';
import '../../data/local/cart_local_data_source.dart';
import '../../data/model/cart_item.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartLocalDataSource _local;
  CartCubit(this._local) : super(const CartState()) {
    load();
  }

  Future<void> load() async {
    final items = await _local.load();
    emit(state.copyWith(items: items));
  }

  Future<void> addItem(Product product, {ProductVariant? variant, int quantity = 1}) async {
    final items = List<CartItem>.from(state.items);
    final key = '${product.id}__${variant?.id ?? ''}';
    final index = items.indexWhere((i) => i.cartKey == key);
    if (index >= 0) {
      items[index] = items[index].copyWith(quantity: items[index].quantity + quantity);
    } else {
      items.add(CartItem(product: product, variant: variant, quantity: quantity));
    }
    await _emitAndSave(items);
    MetaPixelService.addToCart(
      contentId: product.id,
      contentName: product.name,
      value: (variant?.price ?? product.price) * quantity,
    );
  }

  Future<void> setQuantity(String cartKey, int quantity) async {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((i) => i.cartKey == cartKey);
    if (index < 0) return;
    if (quantity <= 0) {
      items.removeAt(index);
    } else {
      items[index] = items[index].copyWith(quantity: quantity);
    }
    await _emitAndSave(items);
  }

  Future<void> removeItem(String cartKey) async {
    final items = List<CartItem>.from(state.items)..removeWhere((i) => i.cartKey == cartKey);
    await _emitAndSave(items);
  }

  Future<void> clear() async {
    await _local.clear();
    emit(const CartState());
  }

  Future<void> _emitAndSave(List<CartItem> items) async {
    emit(state.copyWith(items: items));
    await _local.save(items);
  }
}
