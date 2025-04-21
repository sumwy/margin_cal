import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For number formatting

// Expanded data model based on the spreadsheet
class SpreadsheetData {
  final String productKeyword;
  final double salesPrice;
  final double coupangFeeRate; // 쿠팡 판매수수료
  final double logisticsFee; // 물류수수료 (입출고+택배)
  final double properCost; // 적정원가
  final double returnRate; // 반품률
  final double domesticMargin; // 국내사업 마진
  final double overseasMargin; // 해외수입 마진
  final double domesticFinalCost; // 국내최종원가
  final double overseasFinalCost; // 해외최종원가

  SpreadsheetData({
    required this.productKeyword,
    required this.salesPrice,
    required this.coupangFeeRate,
    required this.logisticsFee,
    required this.properCost,
    required this.returnRate,
    required this.domesticMargin,
    required this.overseasMargin,
    required this.domesticFinalCost,
    required this.overseasFinalCost,
  });
}

class SpreadsheetView extends StatelessWidget {
  const SpreadsheetView({super.key});

  // Populate this list with data parsed from the spreadsheet
  // Ensure all numeric values are treated as doubles where necessary
  final List<SpreadsheetData> data = const [
    SpreadsheetData(
      productKeyword: '탈모모자',
      salesPrice: 20000.0, // Explicitly double
      coupangFeeRate: 0.108,
      logisticsFee: 2150.0, // Explicitly double
      properCost: 6400.0, // Explicitly double
      returnRate: 0.10,
      domesticMargin: 10142.0, // Explicitly double
      overseasMargin: 13272.0, // Explicitly double
      domesticFinalCost: 7265.0, // Explicitly double
      overseasFinalCost: 4135.0, // Explicitly double
    ),
    SpreadsheetData(
      productKeyword: '쿨링 마스크',
      salesPrice: 15000.0, // Explicitly double
      coupangFeeRate: 0.12,
      logisticsFee: 2000.0, // Explicitly double
      properCost: 5000.0, // Explicitly double
      returnRate: 0.05,
      domesticMargin: 8000.0, // Explicitly double
      overseasMargin: 9500.0, // Explicitly double
      domesticFinalCost: 6000.0, // Explicitly double
      overseasFinalCost: 3500.0, // Explicitly double
    ),
    SpreadsheetData(
      productKeyword: '휴대용 선풍기',
      salesPrice: 25000.0, // Explicitly double
      coupangFeeRate: 0.11,
      logisticsFee: 2500.0, // Explicitly double
      properCost: 8000.0, // Explicitly double
      returnRate: 0.08,
      domesticMargin: 12000.0, // Explicitly double
      overseasMargin: 15000.0, // Explicitly double
      domesticFinalCost: 9000.0, // Explicitly double
      overseasFinalCost: 5500.0, // Explicitly double
    ),
  ];

  // Helper to format currency
  String _formatCurrency(double amount) {
    // Added safety check for null or non-finite numbers, though unlikely here
    if (amount.isNaN || amount.isInfinite) {
      return 'N/A';
    }
    // Ensure locale is supported, 'ko_KR' should be fine
    final format = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');
    return format.format(amount);
  }

   // Helper to format percentage
  String _formatPercentage(double rate) {
     // Added safety check
    if (rate.isNaN || rate.isInfinite) {
      return 'N/A';
    }
    // Specify decimal places for clarity if needed, e.g., NumberFormat('##0.0%', 'ko_KR')
    final format = NumberFormat.percentPattern('ko_KR');
    return format.format(rate);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('상품 정보'),
      ),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          // Defensive check in case the index somehow goes out of bounds
          if (index >= data.length) {
             return const SizedBox.shrink(); // Return an empty widget if index is invalid
          }
          final item = data[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Ensure productKeyword is not null, though it's required in constructor
                  Text(
                    item.productKeyword, // Removed '?? '' ' as it's required
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  // Use try-catch for formatting as an extra precaution, though unlikely needed
                  try { _buildInfoRow('판매가격:', _formatCurrency(item.salesPrice)) } catch (e) { Text('판매가격: Error')},
                  try { _buildInfoRow('쿠팡 수수료율:', _formatPercentage(item.coupangFeeRate)) } catch (e) { Text('쿠팡 수수료율: Error')},
                  try { _buildInfoRow('물류 수수료:', _formatCurrency(item.logisticsFee)) } catch (e) { Text('물류 수수료: Error')},
                  try { _buildInfoRow('적정원가:', _formatCurrency(item.properCost)) } catch (e) { Text('적정원가: Error')},
                  try { _buildInfoRow('반품률:', _formatPercentage(item.returnRate)) } catch (e) { Text('반품률: Error')},
                  const Divider(height: 20),
                  try { _buildInfoRow('국내 마진:', _formatCurrency(item.domesticMargin)) } catch (e) { Text('국내 마진: Error')},
                  try { _buildInfoRow('국내 최종원가:', _formatCurrency(item.domesticFinalCost)) } catch (e) { Text('국내 최종원가: Error')},
                  const SizedBox(height: 5),
                  try { _buildInfoRow('해외 마진:', _formatCurrency(item.overseasMargin)) } catch (e) { Text('해외 마진: Error')},
                  try { _buildInfoRow('해외 최종원가:', _formatCurrency(item.overseasFinalCost)) } catch (e) { Text('해외 최종원가: Error')},
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper widget to build consistent label-value rows
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          // Handle potential null or empty values from formatting, though unlikely now
          Text(value), // Removed '?? '-'' as formatters should handle errors
        ],
      ),
    );
  }
}
