class CodeModel {
  late String code;
  late String url;

  CodeModel({
    required this.code,
    required this.url,
  });

  CodeModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    url = json['url'];
  }

  toMap() => {
        'code': code,
        'url': url,
      };
}
