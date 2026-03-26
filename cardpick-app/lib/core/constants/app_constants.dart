class AppConstants {
  // Android 에뮬레이터에서 localhost를 가리키는 주소
  // iOS 시뮬레이터 / 실기기에서는 실제 IP로 변경 필요
  static const String baseUrl = 'http://localhost:8090';

  static const List<String> spendingCategories = [
    '식비',
    '카페',
    '교통',
    '주유',
    '쇼핑',
    '편의점',
    '통신',
    '의료',
    '여가',
    '여행',
    '보험',
    '교육',
  ];
}
