/// 카테고리 정보를 담는 클래스
class CategoryFee {
  final String categoryId;
  final String categoryName;
  final String parentId;
  final double feeRate;
  final String? description;
  
  const CategoryFee({
    required this.categoryId,
    required this.categoryName,
    required this.parentId,
    required this.feeRate,
    this.description,
  });
}

/// 마켓 정보를 담는 클래스
class Marketplace {
  final String id;
  final String name;
  final String? logoUrl;
  
  const Marketplace({
    required this.id,
    required this.name,
    this.logoUrl,
  });
}

/// 수수료율 데이터베이스 관리 클래스
class FeeDatabase {
  // 마켓 리스트
  static const List<Marketplace> marketplaces = [
    Marketplace(
      id: 'coupang',
      name: '쿠팡', 
      logoUrl: 'assets/images/coupang_logo.png'
    ),
    Marketplace(
      id: 'naver',
      name: '네이버 스마트스토어', 
      logoUrl: 'assets/images/naver_logo.png'
    ),
    Marketplace(
      id: '11st',
      name: '11번가', 
      logoUrl: 'assets/images/11st_logo.png'
    ),
  ];
  
  // 쿠팡 카테고리별 수수료율 (로켓그로스 수수료율 시트 기반)
  static const List<CategoryFee> coupangFees = [
    // 대분류 카테고리
    CategoryFee(
      categoryId: 'digital',
      categoryName: '가전디지털',
      parentId: '',
      feeRate: 7.8,
    ),
    CategoryFee(
      categoryId: 'furniture',
      categoryName: '가구/홈인테리어',
      parentId: '',
      feeRate: 10.8,
    ),
    CategoryFee(
      categoryId: 'book',
      categoryName: '도서',
      parentId: '',
      feeRate: 10.8,
    ),
    CategoryFee(
      categoryId: 'baby',
      categoryName: '출산/유아',
      parentId: '',
      feeRate: 10.0,
    ),
    CategoryFee(
      categoryId: 'beauty',
      categoryName: '뷰티',
      parentId: '',
      feeRate: 9.6,
    ),
    CategoryFee(
      categoryId: 'household',
      categoryName: '생활용품',
      parentId: '',
      feeRate: 7.8,
    ),
    CategoryFee(
      categoryId: 'food',
      categoryName: '식품',
      parentId: '',
      feeRate: 10.6,
    ),
    CategoryFee(
      categoryId: 'fashion',
      categoryName: '패션',
      parentId: '',
      feeRate: 10.5,
    ),
    
    // 디지털 하위 카테고리 (특별 수수료율 적용)
    CategoryFee(
      categoryId: 'computer',
      categoryName: '컴퓨터',
      parentId: 'digital',
      feeRate: 5.0,
      description: '특별 수수료율 적용',
    ),
    CategoryFee(
      categoryId: 'monitor',
      categoryName: '모니터',
      parentId: 'digital',
      feeRate: 4.5,
      description: '특별 수수료율 적용',
    ),
    CategoryFee(
      categoryId: 'tablet',
      categoryName: '태블릿PC',
      parentId: 'digital',
      feeRate: 5.0,
      description: '특별 수수료율 적용',
    ),
    
    // 식품 하위 카테고리
    CategoryFee(
      categoryId: 'fmcg',
      categoryName: '가공식품',
      parentId: 'food',
      feeRate: 10.6,
    ),
    
    // 출산/유아 하위 카테고리
    CategoryFee(
      categoryId: 'milk_powder',
      categoryName: '유아분유',
      parentId: 'baby',
      feeRate: 6.4,
      description: '특별 수수료율 적용',
    ),
  ];
  
  // 네이버 스마트스토어 수수료율 샘플 데이터 (실제 데이터로 교체 필요)
  static const List<CategoryFee> naverFees = [
    CategoryFee(
      categoryId: 'fashion_naver',
      categoryName: '패션의류',
      parentId: '',
      feeRate: 9.0,
    ),
    CategoryFee(
      categoryId: 'beauty_naver',
      categoryName: '화장품/미용',
      parentId: '',
      feeRate: 8.5,
    ),
  ];
  
  // 11번가 수수료율 샘플 데이터 (실제 데이터로 교체 필요)
  static const List<CategoryFee> elevenFees = [
    CategoryFee(
      categoryId: 'fashion_11st',
      categoryName: '패션의류',
      parentId: '',
      feeRate: 10.0,
    ),
    CategoryFee(
      categoryId: 'beauty_11st',
      categoryName: '화장품/미용',
      parentId: '',
      feeRate: 9.0,
    ),
  ];
  
  /// 마켓 ID로 카테고리별 수수료율 목록 가져오기
  static List<CategoryFee> getFeesByMarketplace(String marketplaceId) {
    switch (marketplaceId) {
      case 'coupang':
        return coupangFees;
      case 'naver':
        return naverFees;
      case '11st':
        return elevenFees;
      default:
        return [];
    }
  }
  
  /// 상위 카테고리에 속한 하위 카테고리 목록 가져오기
  static List<CategoryFee> getSubcategories(String marketplaceId, String parentCategoryId) {
    final fees = getFeesByMarketplace(marketplaceId);
    return fees.where((fee) => fee.parentId == parentCategoryId).toList();
  }
  
  /// 카테고리ID로 수수료율 정보 가져오기
  static CategoryFee? getCategoryFee(String marketplaceId, String categoryId) {
    final fees = getFeesByMarketplace(marketplaceId);
    try {
      return fees.firstWhere((fee) => fee.categoryId == categoryId);
    } catch (e) {
      return null;
    }
  }
} 