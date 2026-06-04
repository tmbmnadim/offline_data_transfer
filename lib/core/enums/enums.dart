enum ViewModelState {
  initial,
  loading,
  success,
  empty, 
  error;

  bool get isLoading => this == loading;
  bool get isSuccess => this == success;
  bool get isError => this == error;
}

enum AuthStatus { authenticated, unauthenticated, unknown }

enum UserRole {
  admin,
  user,
  guest;
}