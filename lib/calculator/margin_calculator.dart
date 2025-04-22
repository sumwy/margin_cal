import 'dart:math' as math;

/// 마진 계산기의 핵심 계산 함수들을 제공하는 클래스
class MarginCalculator {
  /// 적정원가 계산 함수
  /// 
  /// [sellingPrice] 판매가격(원)
  /// [commissionRate] 수수료율(%)
  /// [logisticsFee] 물류비(원)
  /// [targetMarginRate] 목표 마진율(%, 기본값 40%)
  /// 
  /// 엑셀 공식: =FLOOR(E3*(1-B$2/100-B$3/E3)*(1-40/100),-2)
  static double calculateOptimalCost(
    double sellingPrice, 
    double commissionRate, 
    double logisticsFee, 
    {double targetMarginRate = 40.0}
  ) {
    // 수수료율과 물류비를 반영한 순매출
    double netRevenue = sellingPrice * (1 - commissionRate/100 - logisticsFee/sellingPrice);
    
    // 목표 마진율을 반영한 적정원가
    double optimalCost = netRevenue * (1 - targetMarginRate/100);
    
    // 100원 단위 내림 처리
    return (optimalCost / 100).floor() * 100;
  }

  /// 반품 재입고비 계산 함수
  /// 
  /// [sellingPrice] 판매가격(원)
  /// 
  /// 엑셀 공식: =IF(E3<5000,300,IF(E3<10000,400,IF(E3<15000,600,IF(E3<20000,800,IF(E3>=20000,1000,"ERROR")))))
  static double calculateRestockingFee(double sellingPrice) {
    if (sellingPrice < 5000) {
      return 300;
    } else if (sellingPrice < 10000) {
      return 400;
    } else if (sellingPrice < 15000) {
      return 600;
    } else if (sellingPrice < 20000) {
      return 800;
    } else {
      return 1000;
    }
  }

  /// 국내사입 마진 계산 함수
  /// 
  /// [sellingPrice] 판매가격(원)
  /// [commissionRate] 수수료율(%)
  /// [logisticsFee] 물류비(원)
  /// [cost] 상품원가(원)
  /// [returnRate] 반품률(%)
  /// [returnFee] 반품 관련 비용(회수비+재입고비)(원)
  /// 
  /// 엑셀 공식: =E3-E3*B$2/100-B$3-H3-K3*B$6/100
  static double calculateDomesticMargin(
    double sellingPrice,
    double commissionRate,
    double logisticsFee,
    double cost,
    double returnRate,
    double returnFee
  ) {
    // 수수료
    double commission = sellingPrice * commissionRate / 100;
    
    // 반품 관련 비용(반품률 반영)
    double returnCost = returnFee * returnRate / 100;
    
    // 마진 계산
    return sellingPrice - commission - logisticsFee - cost - returnCost;
  }

  /// 해외수입 원가 환산 함수
  /// 
  /// [foreignCost] 해외 원가(달러, 위안 등)
  /// [exchangeRate] 환율(기본값 300원)
  /// 
  /// 엑셀 공식: =P3*300
  static double calculateForeignCostInKRW(
    double foreignCost, 
    {double exchangeRate = 300.0}
  ) {
    return foreignCost * exchangeRate;
  }

  /// 해외수입 마진 계산 함수
  /// 
  /// [sellingPrice] 판매가격(원)
  /// [commissionRate] 수수료율(%)
  /// [logisticsFee] 물류비(원)
  /// [foreignCost] 해외 원가(달러, 위안 등)
  /// [exchangeRate] 환율(기본값 300원)
  /// [returnRate] 반품률(%)
  /// [returnFee] 반품 관련 비용(회수비+재입고비)(원)
  static double calculateOverseasMargin(
    double sellingPrice,
    double commissionRate,
    double logisticsFee,
    double foreignCost,
    double returnRate,
    double returnFee,
    {double exchangeRate = 300.0}
  ) {
    // 해외 원가를 원화로 환산
    double costInKRW = calculateForeignCostInKRW(foreignCost, exchangeRate: exchangeRate);
    
    // 국내 마진 계산과 동일한 방식 적용
    return calculateDomesticMargin(
      sellingPrice,
      commissionRate,
      logisticsFee,
      costInKRW,
      returnRate,
      returnFee
    );
  }

  /// 쿠폰 적용 후 판매가 계산 함수
  /// 
  /// [originalPrice] 원래 판매가격(원)
  /// [couponAmount] 할인쿠폰 금액(원)
  static double calculateDiscountedPrice(double originalPrice, double couponAmount) {
    return math.max(0, originalPrice - couponAmount);
  }

  /// 마켓 수수료 계산 함수(부가세 포함)
  /// 
  /// [price] 판매가격(원)
  /// [commissionRate] 수수료율(%)
  /// [vatRate] 부가세율(%, 기본값 10%)
  static double calculateMarketFee(
    double price, 
    double commissionRate, 
    {double vatRate = 10.0}
  ) {
    return (price * commissionRate / 100) * (1 + vatRate / 100);
  }

  /// 순수익 계산 함수
  /// 
  /// [discountedPrice] 쿠폰 적용 후 판매가(원)
  /// [productCost] 제품원가(원)
  /// [marketFee] 마켓 수수료(원)
  /// [returnRate] 반품률(%)
  /// [returnCollectionFee] 반품회수비(원)
  /// [restockingFee] 반품재입고비(원)
  /// [vatRate] 부가세율(%, 기본값 10%)
  static double calculateNetProfit(
    double discountedPrice,
    double productCost,
    double marketFee,
    double returnRate,
    double returnCollectionFee,
    double restockingFee,
    {double vatRate = 10.0}
  ) {
    // 반품 관련 비용(부가세 포함)
    double returnCost = (returnCollectionFee + restockingFee) * (1 + vatRate / 100) * returnRate / 100;
    
    // 순수익 계산
    return discountedPrice - productCost - marketFee - returnCost;
  }

  /// 마진율 계산 함수
  /// 
  /// [netProfit] 순수익(원)
  /// [originalPrice] 원래 판매가격(원)
  static double calculateMarginRate(double netProfit, double originalPrice) {
    if (originalPrice <= 0) return 0;
    return netProfit / originalPrice;
  }

  /// 제로마진 광고비 계산 함수(부가세 별도)
  /// 
  /// [netProfit] 순수익(원)
  /// [vatRate] 부가세율(%, 기본값 10%)
  static double calculateZeroMarginAdCost(double netProfit, {double vatRate = 10.0}) {
    return netProfit / (1 + vatRate / 100);
  }

  /// 광고 효율(ROAS) 계산 함수
  /// 
  /// [sellingPrice] 판매가격(원)
  /// [adCost] 광고비(원, 부가세 별도)
  static double calculateROAS(double sellingPrice, double adCost) {
    if (adCost <= 0) return 0;
    return sellingPrice / adCost;
  }
} 