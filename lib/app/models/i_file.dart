class IFile {
  String path;
  String name;
  int size;
  DateTime time;

  IFile(this.path, this.name, this.size, this.time);

  factory IFile.fromJson(Map<String, dynamic> json) {
    return IFile(
      json['path'],
      json['name'],
      json['size'],
      DateTime.fromMillisecondsSinceEpoch(json['time']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'name': name,
      'size': size,
      'time': time.millisecondsSinceEpoch,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is IFile && other.path == path;
  }

  @override
  int get hashCode => path.hashCode;
}
