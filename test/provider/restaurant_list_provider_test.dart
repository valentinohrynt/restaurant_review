import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:restaurant_review/data/api/api_service.dart';
import 'package:restaurant_review/providers/home/restaurant_list_provider.dart';
import 'package:restaurant_review/data/model/restaurant_list_response.dart';
import 'package:restaurant_review/static/restaurant_list_result_state.dart';
import 'restaurant_list_provider_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  late RestaurantListProvider provider;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    provider = RestaurantListProvider(mockApiService);
  });

  group('Restaurant List Provider Test', () {
    // Test 1: Memastikan state awal provider harus didefinisikan
    test('initial state should be RestaurantListNoneState', () {
      expect(provider.resultState, isA<RestaurantListNoneState>());
    });

    // Test 2: Memastikan harus mengembalikan daftar restoran ketika pengambilan data API berhasil
    test('should return restaurant list when API call is successful', () async {
      when(mockApiService.getRestaurantList())
          .thenAnswer((_) async => RestaurantListResponse.fromJson({
                'error': false,
                'message': 'success',
                'count': 2,
                'restaurants': [
                  {
                    'id': '1',
                    'name': 'Warung Bu Ani',
                    'description':
                        'Sajian khas Banyuwangi dengan cita rasa autentik.',
                    'pictureId': 'pic1',
                    'city': 'Banyuwangi',
                    'rating': 4.7
                  },
                  {
                    'id': '2',
                    'name': 'Sego Tempong Mbok Wah',
                    'description':
                        'Nasi tempong pedas yang terkenal di Banyuwangi.',
                    'pictureId': 'pic2',
                    'city': 'Banyuwangi',
                    'rating': 4.6
                  }
                ]
              }));
      await provider.fetchRestaurantList();
      expect(provider.resultState, isA<RestaurantListLoadedState>());
      final state = provider.resultState as RestaurantListLoadedState;
      expect(state.data.length, 2);
      expect(state.data[0].name, 'Warung Bu Ani');
      expect(state.data[1].name, 'Sego Tempong Mbok Wah');
    });

    // Test 3: Memastikan harus mengembalikan kesalahan ketika pengambilan data API gagal
    test('should return error when API call is failed', () async {
      when(mockApiService.getRestaurantList())
          .thenThrow(Exception('Failed to load restaurant list'));
      await provider.fetchRestaurantList();
      expect(provider.resultState, isA<RestaurantListErrorState>());
      final state = provider.resultState as RestaurantListErrorState;
      expect(state.error,
          'Failed to load restaurant list. Please check your connection');
    });

    // Test 4: Memastikan state loading muncul saat fetching data
    test('should show loading state when fetching data', () async {
      when(mockApiService.getRestaurantList()).thenAnswer((_) async =>
          RestaurantListResponse.fromJson({
            'error': false,
            'message': 'success',
            'count': 0,
            'restaurants': []
          }));

      provider.fetchRestaurantList();

      expect(provider.resultState, isA<RestaurantListLoadingState>());
    });

    // Test 5: Memastikan daftar restoran kosong ditangani dengan benar
    test('should handle empty restaurant list correctly', () async {
      when(mockApiService.getRestaurantList()).thenAnswer((_) async =>
          RestaurantListResponse.fromJson({
            'error': false,
            'message': 'success',
            'count': 0,
            'restaurants': []
          }));

      await provider.fetchRestaurantList();

      expect(provider.resultState, isA<RestaurantListLoadedState>());
      final state = provider.resultState as RestaurantListLoadedState;
      expect(state.data.isEmpty, true);
    });

    // Test 6: Memastikan data restoran memiliki properti yang benar
    test('should have correct restaurant properties', () async {
      when(mockApiService.getRestaurantList())
          .thenAnswer((_) async => RestaurantListResponse.fromJson({
                'error': false,
                'message': 'success',
                'count': 1,
                'restaurants': [
                  {
                    'id': '1',
                    'name': 'Pondok Rasa Banyuwangi',
                    'description':
                        'Menyediakan hidangan laut segar khas Banyuwangi.',
                    'pictureId': 'pic1',
                    'city': 'Banyuwangi',
                    'rating': 4.8
                  }
                ]
              }));

      await provider.fetchRestaurantList();

      expect(provider.resultState, isA<RestaurantListLoadedState>());
      final state = provider.resultState as RestaurantListLoadedState;
      final restaurant = state.data[0];
      expect(restaurant.id, '1');
      expect(restaurant.name, 'Pondok Rasa Banyuwangi');
      expect(restaurant.description,
          'Menyediakan hidangan laut segar khas Banyuwangi.');
      expect(restaurant.pictureId, 'pic1');
      expect(restaurant.city, 'Banyuwangi');
      expect(restaurant.rating, 4.8);
    });
  });
}
