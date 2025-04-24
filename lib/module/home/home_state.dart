import "package:cctv_sasat/api/endpoint/cctv/cctv_item.dart";
import "package:cctv_sasat/api/endpoint/location/location_item.dart";
import "package:equatable/equatable.dart";

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class CctvDataLoading extends HomeState {}

class CctvDataLoaded extends HomeState {
  final List<CctvItem> cctvList;
  final List<LocationItem> locations;
  final int? selectedLocationId;
  final String searchQuery;

  const CctvDataLoaded(
    this.cctvList,
    this.locations, {
    this.selectedLocationId,
    this.searchQuery = "",
  });

  CctvDataLoaded copyWith({
    List<CctvItem>? cctvList,
    List<LocationItem>? locations,
    int? selectedLocationId,
    String? searchQuery,
  }) {
    return CctvDataLoaded(
      cctvList ?? this.cctvList,
      locations ?? this.locations,
      selectedLocationId: selectedLocationId ?? this.selectedLocationId,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [cctvList, locations, selectedLocationId, searchQuery];
}

class CctvDataError extends HomeState {
  final String message;

  const CctvDataError(this.message);

  @override
  List<Object?> get props => [message];
}