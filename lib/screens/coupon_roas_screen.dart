import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../calculator/margin_calculator.dart';

class CouponRoasScreen extends StatefulWidget {
  const CouponRoasScreen({super.key});

  @override
  State<CouponRoasScreen> createState() => _CouponRoasScreenState();
}

class _CouponRoasScreenState extends State<CouponRoasScreen> {
  // 사용자 입력 컨트롤러
  final TextEditingController _originalPriceController = TextEditingController(text: '20000');
  final TextEditingController _productCostController = TextEditingController(text: '6000');
  final TextEditingController _couponAmountController = TextEditingController(text: '2000');
  final TextEditingController _commissionRateController = TextEditingController(text: '10');
  final TextEditingController _returnRateController = TextEditingController(text: '5');
  final TextEditingController _returnCollectionFeeController = TextEditingController(text: '3000');
  
  // 계산 결과
  double _discountedPrice = 0.0;
  double _marketFee = 0.0;
  double _restockingFee = 0.0;
  double _netProfit = 0.0;
  double _marginRate = 0.0;
  double _zeroMarginAdCost = 0.0;
  double _roas = 0.0;
  
  @override
  void initState() {
    super.initState();
    // 컨트롤러 리스너 등록
    _originalPriceController.addListener(_recalculate);
    _productCostController.addListener(_recalculate);
    _couponAmountController.addListener(_recalculate);
    _commissionRateController.addListener(_recalculate);
    _returnRateController.addListener(_recalculate);
    _returnCollectionFeeController.addListener(_recalculate);
    
    // 초기 계산 실행
    _recalculate();
  }
  
  @override
  void dispose() {
    // 컨트롤러 해제
    _originalPriceController.dispose();
    _productCostController.dispose();
    _couponAmountController.dispose();
    _commissionRateController.dispose();
    _returnRateController.dispose();
    _returnCollectionFeeController.dispose();
    super.dispose();
  }
  
  // 모든 계산 수행
  void _recalculate() {
    final originalPrice = double.tryParse(_originalPriceController.text) ?? 0.0;
    final productCost = double.tryParse(_productCostController.text) ?? 0.0;
    final couponAmount = double.tryParse(_couponAmountController.text) ?? 0.0;
    final commissionRate = double.tryParse(_commissionRateController.text) ?? 0.0;
    final returnRate = double.tryParse(_returnRateController.text) ?? 0.0;
    final returnCollectionFee = double.tryParse(_returnCollectionFeeController.text) ?? 0.0;
    
    // 계산 실행
    setState(() {
      // 쿠폰 적용 가격
      _discountedPrice = MarginCalculator.calculateDiscountedPrice(
        originalPrice, 
        couponAmount
      );
      
      // 마켓 수수료
      _marketFee = MarginCalculator.calculateMarketFee(
        _discountedPrice, 
        commissionRate
      );
      
      // 반품 재입고비
      _restockingFee = MarginCalculator.calculateRestockingFee(_discountedPrice);
      
      // 순수익
      _netProfit = MarginCalculator.calculateNetProfit(
        _discountedPrice,
        productCost,
        _marketFee,
        returnRate,
        returnCollectionFee,
        _restockingFee
      );
      
      // 마진율
      _marginRate = MarginCalculator.calculateMarginRate(_netProfit, originalPrice) * 100;
      
      // 제로마진 광고비
      _zeroMarginAdCost = MarginCalculator.calculateZeroMarginAdCost(_netProfit);
      
      // ROAS
      _roas = MarginCalculator.calculateROAS(originalPrice, _zeroMarginAdCost);
    });
  }
  
  // 통화 형식 포맷 함수
  String _formatCurrency(double amount) {
    if (amount.isNaN || amount.isInfinite) {
      return 'N/A';
    }
    final format = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');
    return format.format(amount);
  }
  
  // ROAS 포맷 함수
  String _formatRoas(double roas) {
    if (roas.isNaN || roas.isInfinite) {
      return 'N/A';
    }
    return '${roas.toStringAsFixed(1)}배';
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('할인쿠폰 ROAS 계산기'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 기본 정보 입력 영역
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '상품 기본 정보',
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 판매가 입력
                    TextFormField(
                      controller: _originalPriceController,
                      decoration: const InputDecoration(
                        labelText: '원래 판매가 (원)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 제품원가 입력
                    TextFormField(
                      controller: _productCostController,
                      decoration: const InputDecoration(
                        labelText: '제품원가 (원)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 수수료율 입력
                    TextFormField(
                      controller: _commissionRateController,
                      decoration: const InputDecoration(
                        labelText: '수수료율 (%)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 할인 및 반품 정보 입력 영역
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '할인 및 반품 정보',
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 할인쿠폰 금액 입력
                    TextFormField(
                      controller: _couponAmountController,
                      decoration: const InputDecoration(
                        labelText: '할인쿠폰 금액 (원)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 반품률 입력
                    TextFormField(
                      controller: _returnRateController,
                      decoration: const InputDecoration(
                        labelText: '반품률 (%)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 반품회수비 입력
                    TextFormField(
                      controller: _returnCollectionFeeController,
                      decoration: const InputDecoration(
                        labelText: '반품회수비 (원)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 쿠폰 적용가 표시
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: '쿠폰 적용가',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _formatCurrency(_discountedPrice),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 반품 재입고비 표시
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: '반품 재입고비',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _formatCurrency(_restockingFee),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 결과 영역
            Card(
              elevation: 2,
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '계산 결과',
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 마켓 수수료
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('마켓 수수료:'),
                        Text(
                          _formatCurrency(_marketFee),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    
                    // 순수익
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('순수익:'),
                        Text(
                          _formatCurrency(_netProfit),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _netProfit >= 0 ? Colors.blue[700] : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // 마진율
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('마진율:'),
                        Text(
                          '${_marginRate.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _marginRate >= 0 ? Colors.blue[700] : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // 제로마진 광고비
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('제로마진 광고비(부가세별도):'),
                        Text(
                          _formatCurrency(_zeroMarginAdCost),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // 광고 효율(ROAS)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('광고 효율(ROAS):'),
                        Text(
                          _formatRoas(_roas),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: _roas >= 0 ? Colors.blue[700] : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // ROAS 해석
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ROAS 해석',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _roas >= 4.0
                                ? '매우 우수한 광고 효율입니다. 쿠폰 홍보에 적극 투자해도 좋습니다.'
                                : _roas >= 3.0
                                    ? '양호한 광고 효율입니다. 쿠폰 홍보 투자를 신중하게 진행해 보세요.'
                                    : _roas >= 2.0
                                        ? '보통 수준의 광고 효율입니다. 제한된 예산으로 테스트해 보세요.'
                                        : '광고 효율이 낮습니다. 쿠폰 조건을 재검토하는 것이 좋습니다.',
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 