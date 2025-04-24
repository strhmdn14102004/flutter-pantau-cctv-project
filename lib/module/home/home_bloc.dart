import "package:cctv_sasat/api/api_manager.dart";
import "package:cctv_sasat/api/endpoint/cctv/cctv_item.dart";
import "package:cctv_sasat/api/endpoint/location/location_item.dart";
import "package:cctv_sasat/module/home/home_event.dart";
import "package:cctv_sasat/module/home/home_state.dart";
import "package:flutter_bloc/flutter_bloc.dart";

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<LoadCctvData>(_onLoadCctvData);
    on<LoadLocations>(_onLoadLocations);
    on<FilterByLocation>(_onFilterByLocation);
    on<SearchCctv>(_onSearchCctv);
  }

  List<CctvItem> _allCctvs = [];
  List<LocationItem> _locations = [];
  final int _limit = 15;

  Future<void> _onLoadCctvData(LoadCctvData event, Emitter<HomeState> emit) async {
    emit(CctvDataLoading());
    try {
      _allCctvs = await ApiManager.getAllCctvs();
      final activeCctvs = _allCctvs.where((c) => c.isActive).take(_limit).toList();
      emit(CctvDataLoaded(activeCctvs, _locations));
    } catch (e) {
      emit(CctvDataError(e.toString()));
    }
  }

  Future<void> _onLoadLocations(LoadLocations event, Emitter<HomeState> emit) async {
    try {
      _locations = await ApiManager.getAllLocations();
      if (state is CctvDataLoaded) {
        emit((state as CctvDataLoaded).copyWith(locations: _locations));
      }
    } catch (e) {
      // Handle error jika diperlukan
    }
  }

  void _onFilterByLocation(FilterByLocation event, Emitter<HomeState> emit) {
    if (state is CctvDataLoaded) {
      final currentState = state as CctvDataLoaded;
      List<CctvItem> filteredCctvs = _allCctvs.where((c) => c.isActive).toList();
      
      if (event.locationId != null) {
        filteredCctvs = filteredCctvs.where((c) => c.location.id == event.locationId).toList();
      }
      
      emit(currentState.copyWith(
        cctvList: filteredCctvs.take(_limit).toList(),
        selectedLocationId: event.locationId,
      ),);
    }
  }

  void _onSearchCctv(SearchCctv event, Emitter<HomeState> emit) {
    if (state is CctvDataLoaded) {
      final currentState = state as CctvDataLoaded;
      List<CctvItem> filteredCctvs = _allCctvs.where((c) => c.isActive).toList();
      
      if (event.query.isNotEmpty) {
        filteredCctvs = filteredCctvs.where((c) => 
          c.name.toLowerCase().contains(event.query.toLowerCase()) ||
          c.location.name.toLowerCase().contains(event.query.toLowerCase()),
        ).toList();
      }
      
      emit(currentState.copyWith(
        cctvList: filteredCctvs.take(_limit).toList(),
        searchQuery: event.query,
      ),);
    }
  }
}