import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../calculator/margin_calculator.dart';
import '../data/fee_database.dart';

class MarginCalculatorScreen extends StatefulWidget {
  const MarginCalculatorScreen({super.key});

  @override
  State<MarginCalculatorScreen> createState() => _MarginCalculatorScreenState();
}

class _MarginCalculatorScreenState extends State<MarginCalculatorScreen> {
  // 마켓 선택 상태
  String _selectedMarketplaceId = 'coupang';
  
  // 카테고리 상태
  String? _selectedCategoryId;
  
  // 수수료율 상태
  double _commissionRate = 10.0;
  
  // 사용자 입력 컨트롤러
  final TextEditingController _salesPriceController = TextEditingController(text: '20000');
  final TextEditingController _logisticsFeeController = TextEditingController(text: '2150');
  final TextEditingController _domesticCostController = TextEditingController();
  final TextEditingController _foreignCostController = TextEditingController();
  final TextEditingController _exchangeRateController = TextEditingController(text: '300');
  final TextEditingController _returnRateController = TextEditingController(text: '5');
  
  // 계산 결과
  double _properCost = 0.0;
  double _restockingFee = 0.0;
  double _domesticMargin = 0.0;
  double _overseasMargin = 0.0;
  double _domesticFinalCost = 0.0;
  double _overseasFinalCost = 0.0;
  
  @override
  void initState() {
    super.initState();
    // 컨트롤러 리스너 등록
    _salesPriceController.addListener(_recalculate);
    _logisticsFeeController.addListener(_recalculate);
    _domesticCostController.addListener(_recalculate);
    _foreignCostController.addListener(_recalculate);
    _exchangeRateController.addListener(_recalculate);
    _returnRateController.addListener(_recalculate);
    
    // 초기 계산 실행
    _recalculate();
  }
  
  @override
  void dispose() {
    // 컨트롤러 해제
    _salesPriceController.dispose();
    _logisticsFeeController.dispose();
    _domesticCostController.dispose();
    _foreignCostController.dispose();
    _exchangeRateController.dispose();
    _returnRateController.dispose();
    super.dispose();
  }
  
  // 마켓 변경 처리
  void _onMarketplaceChanged(String? marketplaceId) {
    if (marketplaceId != null) {
      setState(() {
        _selectedMarketplaceId = marketplaceId;
        _selectedCategoryId = null; // 카테고리 선택 초기화
      });
      _recalculate();
    }
  }
  
  // 카테고리 변경 처리
  void _onCategoryChanged(String? categoryId) {
    if (categoryId != null) {
      final category = FeeDatabase.getCategoryFee(_selectedMarketplaceId, categoryId);
      setState(() {
        _selectedCategoryId = categoryId;
        if (category != null) {
          _commissionRate = category.feeRate;
        }
      });
      _recalculate();
    }
  }
  
  // 모든 계산 수행
  void _recalculate() {
    final salesPrice = double.tryParse(_salesPriceController.text) ?? 0.0;
    final logisticsFee = double.tryParse(_logisticsFeeController.text) ?? 0.0;
    final domesticCost = double.tryParse(_domesticCostController.text) ?? 0.0;
    final foreignCost = double.tryParse(_foreignCostController.text) ?? 0.0;
    final exchangeRate = double.tryParse(_exchangeRateController.text) ?? 300.0;
    final returnRate = double.tryParse(_returnRateController.text) ?? 5.0;
    
    // 계산 실행
    setState(() {
      // 적정원가 계산
      _properCost = MarginCalculator.calculateOptimalCost(
        salesPrice, 
        _commissionRate, 
        logisticsFee
      );
      
      // 반품 재입고비 계산
      _restockingFee = MarginCalculator.calculateRestockingFee(salesPrice);
      
      // 국내사입 마진 계산
      if (domesticCost > 0) {
        _domesticMargin = MarginCalculator.calculateDomesticMargin(
          salesPrice, 
          _commissionRate, 
          logisticsFee, 
          domesticCost, 
          returnRate, 
          _restockingFee + 3000 // 재입고비 + 반품회수비
        );
        _domesticFinalCost = domesticCost; // 국내 최종원가
      } else {
        _domesticMargin = 0.0;
        _domesticFinalCost = 0.0;
      }
      
      // 해외수입 마진 계산
      if (foreignCost > 0) {
        _overseasMargin = MarginCalculator.calculateOverseasMargin(
          salesPrice, 
          _commissionRate, 
          logisticsFee, 
          foreignCost, 
          returnRate, 
          _restockingFee + 3000, // 재입고비 + 반품회수비
          exchangeRate: exchangeRate
        );
        _overseasFinalCost = MarginCalculator.calculateForeignCostInKRW(
          foreignCost,
          exchangeRate: exchangeRate
        );
      } else {
        _overseasMargin = 0.0;
        _overseasFinalCost = 0.0;
      }
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
  
  // 퍼센트 형식 포맷 함수
  String _formatPercentage(double rate) {
    if (rate.isNaN || rate.isInfinite) {
      return 'N/A';
    }
    final format = NumberFormat.percentPattern('ko_KR');
    return format.format(rate / 100);
  }
  
  // 마진율 계산 및 포맷
  String _calculateMarginRate(double margin, double salesPrice) {
    if (salesPrice <= 0 || margin <= 0) return '0%';
    final rate = (margin / salesPrice) * 100;
    return '${rate.toStringAsFixed(1)}%';
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('마진 계산기'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 마켓 및 카테고리 선택 영역
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '마켓 및 카테고리 선택',
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 마켓 선택 드롭다운
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: '마켓',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedMarketplaceId,
                      items: FeeDatabase.marketplaces.map((marketplace) {
                        return DropdownMenuItem<String>(
                          value: marketplace.id,
                          child: Text(marketplace.name),
                        );
                      }).toList(),
                      onChanged: _onMarketplaceChanged,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 카테고리 선택 드롭다운
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: '카테고리',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedCategoryId,
                      items: FeeDatabase.getFeesByMarketplace(_selectedMarketplaceId)
                          .where((fee) => fee.parentId.isEmpty) // 상위 카테고리만 표시
                          .map((category) {
                        return DropdownMenuItem<String>(
                          value: category.categoryId,
                          child: Text(category.categoryName),
                        );
                      }).toList(),
                      onChanged: _onCategoryChanged,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 수수료율 표시
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: '수수료율 (%)',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: _commissionRate.toString(),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        setState(() {
                          _commissionRate = double.tryParse(value) ?? 10.0;
                        });
                        _recalculate();
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 상품 정보 입력 영역
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '상품 정보',
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 판매가 입력
                    TextFormField(
                      controller: _salesPriceController,
                      decoration: const InputDecoration(
                        labelText: '판매가 (원)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 물류비 입력
                    TextFormField(
                      controller: _logisticsFeeController,
                      decoration: const InputDecoration(
                        labelText: '물류비 (원)',
                        border: OutlineInputBorder(),
                        helperText: '입출고비 + 택배비',
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
                    
                    // 적정원가 표시
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: '적정원가',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _formatCurrency(_properCost),
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
            
            // 국내사입 마진 계산 영역
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '국내사입 마진 계산',
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 국내 원가 입력
                    TextFormField(
                      controller: _domesticCostController,
                      decoration: const InputDecoration(
                        labelText: '국내 원가 (원)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 국내사입 마진 표시
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: '국내사입 마진',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _formatCurrency(_domesticMargin),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // 국내사입 마진율 표시
                    if (_domesticMargin > 0) 
                      Text(
                        '마진율: ${_calculateMarginRate(_domesticMargin, double.tryParse(_salesPriceController.text) ?? 0.0)}',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 해외수입 마진 계산 영역
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '해외수입 마진 계산',
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 해외 원가 입력
                    TextFormField(
                      controller: _foreignCostController,
                      decoration: const InputDecoration(
                        labelText: '해외 원가 (달러/위안 등)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 환율 입력
                    TextFormField(
                      controller: _exchangeRateController,
                      decoration: const InputDecoration(
                        labelText: '환율',
                        border: OutlineInputBorder(),
                        helperText: '기본값: 300원',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 해외수입 원가(원화) 표시
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: '해외수입 원가(원화)',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _formatCurrency(_overseasFinalCost),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 해외수입 마진 표시
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: '해외수입 마진',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _formatCurrency(_overseasMargin),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // 해외수입 마진율 표시
                    if (_overseasMargin > 0) 
                      Text(
                        '마진율: ${_calculateMarginRate(_overseasMargin, double.tryParse(_salesPriceController.text) ?? 0.0)}',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // 비교 결과 영역
            if (_domesticMargin > 0 && _overseasMargin > 0)
              Card(
                elevation: 2,
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '마진 비교 결과',
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('국내사입 마진:'),
                          Text(
                            _formatCurrency(_domesticMargin),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('해외수입 마진:'),
                          Text(
                            _formatCurrency(_overseasMargin),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('차이:'),
                          Text(
                            _formatCurrency(_overseasMargin - _domesticMargin),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _overseasMargin > _domesticMargin ? Colors.red : Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Center(
                        child: Text(
                          _overseasMargin > _domesticMargin 
                            ? '해외수입이 ${_formatCurrency(_overseasMargin - _domesticMargin)} 더 유리합니다'
                            : '국내사입이 ${_formatCurrency(_domesticMargin - _overseasMargin)} 더 유리합니다',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: _overseasMargin > _domesticMargin ? Colors.red : Colors.blue,
                          ),
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