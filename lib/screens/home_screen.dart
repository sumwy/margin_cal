import 'package:flutter/material.dart';
import 'margin_calculator_screen.dart';
import 'coupon_roas_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('스마트 마진 계산기'),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '온라인 판매자를 위한 마진 계산 도구',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            
            const SizedBox(height: 24),
            
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  // 기본 마진 계산기 카드
                  _buildFeatureCard(
                    context,
                    title: '기본 마진 계산기',
                    description: '적정원가, 국내/해외 마진 비교 계산',
                    icon: Icons.calculate,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MarginCalculatorScreen(),
                        ),
                      );
                    },
                  ),
                  
                  // 할인쿠폰 ROAS 계산기 카드
                  _buildFeatureCard(
                    context,
                    title: '할인쿠폰 ROAS 계산기',
                    description: '쿠폰 적용 시 마진 및 광고 효율 계산',
                    icon: Icons.local_offer,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CouponRoasScreen(),
                        ),
                      );
                    },
                  ),
                  
                  // 가격 전략 시뮬레이터 카드 (준비 중)
                  _buildFeatureCard(
                    context,
                    title: '가격 전략 시뮬레이터',
                    description: '다양한 가격대별 수익성 비교 (준비 중)',
                    icon: Icons.auto_graph,
                    color: Colors.green,
                    onTap: () {
                      _showComingSoonDialog(context);
                    },
                  ),
                  
                  // 수수료율 데이터베이스 카드 (준비 중)
                  _buildFeatureCard(
                    context,
                    title: '수수료율 데이터베이스',
                    description: '마켓별 카테고리 수수료 정보 (준비 중)',
                    icon: Icons.category,
                    color: Colors.purple,
                    onTap: () {
                      _showComingSoonDialog(context);
                    },
                  ),
                ],
              ),
            ),
            
            // 앱 정보 영역
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                '© 2024 스마트 마진 계산기 - 온라인 판매자 커뮤니티를 위한 무료 도구',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 기능 카드 위젯
  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // '준비 중' 다이얼로그
  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('준비 중'),
        content: const Text('이 기능은 현재 개발 중입니다. 조금만 기다려주세요!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
} 