import "package:equatable/equatable.dart";

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadCctvData extends HomeEvent {
  const LoadCctvData();
}

class LoadLocations extends HomeEvent {
  const LoadLocations();
}

class FilterByLocation extends HomeEvent {
  final int? locationId;

  const FilterByLocation(this.locationId);

  @override
  List<Object?> get props => [locationId];
}

class SearchCctv extends HomeEvent {
  final String query;

  const SearchCctv(this.query);

  @override
  List<Object?> get props => [query];
}