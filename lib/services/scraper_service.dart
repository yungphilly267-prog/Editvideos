import 'dart:math';
import '../models/product_metadata.dart';

class ScraperService {
  Future<ProductMetadata> scrapeProductUrl(String url) async {
    // Simulate web request delays and parse realistic e-commerce products
    await Future.delayed(const Duration(seconds: 2));

    final cleanUrl = url.toLowerCase().trim();
    if (cleanUrl.contains('shopify') || cleanUrl.contains('store') || cleanUrl.contains('product')) {
      final isEtsy = cleanUrl.contains('etsy');
      return ProductMetadata(
        title: isEtsy ? 'Handcrafted Linen Studio Apron' : 'Minimalist Ceramic Coffee Dripper',
        description: isEtsy
            ? 'Individually tailored linen apron with reinforced pockets. Made from sustainable soft European flax. Perfect for cooking, gardening, or painting.'
            : 'Artisanal matte stoneware coffee dripper. Conical design maintains optimal water flow rate for precise, balanced extraction.',
        price: isEtsy ? 48.00 : 34.50,
        imageUrls: isEtsy 
            ? [
                'https://images.unsplash.com/photo-1544816155-12df9643f363?w=600',
                'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?w=600'
              ]
            : [
                'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=600',
                'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=600'
              ],
        sourceUrl: url,
      );
    } else {
      // Return a random mock product for general URLs
      final index = Random().nextInt(3);
      if (index == 0) {
        return ProductMetadata(
          title: 'Premium Leather Field Journal',
          description: 'Full-grain vegetable-tanned leather binder with heavy refillable ivory pages. Elegantly preserves thoughts, drafts, and designs.',
          price: 59.00,
          imageUrls: [
            'https://images.unsplash.com/photo-1531346878377-a5be20888e57?w=600',
            'https://images.unsplash.com/photo-1544816155-12df9643f363?w=600'
          ],
          sourceUrl: url,
        );
      } else if (index == 1) {
        return ProductMetadata(
          title: 'Organic Soy Candle - Sandalwood',
          description: 'Hand-poured coconut soy wax infused with pure sandalwood, cedar, and amber essential oils. Wooden wick crackles gently.',
          price: 28.00,
          imageUrls: [
            'https://images.unsplash.com/photo-1603006905003-be475563bc59?w=600',
            'https://images.unsplash.com/photo-1602872030219-cbf90029b35e?w=600'
          ],
          sourceUrl: url,
        );
      } else {
        return ProductMetadata(
          title: 'Ergonomic Walnut Monitor Stand',
          description: 'Solid american walnut desk shelf that elevates your workspace, improves posture, and organizes accessories.',
          price: 119.00,
          imageUrls: [
            'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=600',
            'https://images.unsplash.com/photo-1585776245991-cf89dd7fc73a?w=600'
          ],
          sourceUrl: url,
        );
      }
    }
  }
}
