class IError {
  int? id;
  String? brand;
  String? model;
  String? platform;
  String? version;
  String? content;
  String? stack;
  DateTime? upTime;

  IError({
    this.id,
    this.brand,
    this.model,
    this.platform,
    this.version,
    this.content,
    this.upTime,
    this.stack,
  });

  Map<String, dynamic> toJson() {
    return {
      'brand': brand,
      'model': model,
      'platform': platform,
      'version': version,
      'content': content,
      'stack': stack,
      'upTime': upTime?.toString(),
    };
  }

  factory IError.fromJson(Map<String, dynamic> json) {
    return IError(
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      platform: json['platform'] as String?,
      version: json['version'] as String?,
      content: json['content'] as String?,
      stack: json['stack'] as String?,
      upTime: json['upTime'] != null
          ? DateTime.parse(json['upTime'] as String)
          : null,
    );
  }
}
