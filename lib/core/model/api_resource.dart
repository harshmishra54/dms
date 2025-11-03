enum Status { loading, success, error }

class ApiResource<T> {
  final Status status;
  final T? data;
  final String? message;

  ApiResource.loading() : status = Status.loading, data = null, message = null;
  ApiResource.success(this.data) : status = Status.success, message = null;
  ApiResource.error(this.message) : status = Status.error, data = null;
}
