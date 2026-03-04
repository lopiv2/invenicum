class VoucherTemplate {
  final String template;
  final String? logoUrl;

  VoucherTemplate({required this.template, this.logoUrl});

  factory VoucherTemplate.fromJson(Map<String, dynamic> json) {
    return VoucherTemplate(
      template: json['template'],
      logoUrl: json['logoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'template': template,
      'logoUrl': logoUrl,
    };
  }
}
