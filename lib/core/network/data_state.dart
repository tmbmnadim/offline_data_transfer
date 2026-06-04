abstract class DataState<T> {
  final T? data;
  final String? message;
  final Object? error;
  final int? code;
  final StackTrace? stackTrace;

  DataState({
    this.data,
    this.message,
    this.error,
    this.code,
    this.stackTrace,
  });

  @override
  String toString() {
    return "$runtimeType(data: $data, code: $code, message: $message)";
  }
}

class DataSuccess<T> extends DataState<T> {
  DataSuccess(T data) : super(data: data);
}

class DataFailed<T> extends DataState<T> {
  DataFailed(String message, {super.error, super.code, super.stackTrace})
    : super(message: message);
}

class ControllerDataState<T> {
  final T? data;
  final int code;
  final String? errorMessage;
  final bool isLoading;

  ControllerDataState({
    this.data,
    this.code = 200,
    this.errorMessage,
    this.isLoading = false,
  });

  ControllerDataState<T> copyWith({
    T? data,
    int? code,
    String? errorMessage,
    bool? isLoading,
  }) {
    return ControllerDataState(
      data: data ?? this.data,
      code: code ?? this.code,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
