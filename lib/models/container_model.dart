class ContainerNode {
  final String id;
  final String name;
  final String? description;
  final List<ContainerNode> children;
  final List<String> elements;
  final List<String> dataLists;

  ContainerNode({
    required this.id,
    required this.name,
    this.description,
    List<ContainerNode>? children,
    List<String>? elements,
    List<String>? dataLists,
  }) : 
    children = children ?? [],
    elements = elements ?? [],
    dataLists = dataLists ?? [];

  factory ContainerNode.fromJson(Map<String, dynamic> json) {
    return ContainerNode(
      id: json['id'].toString(),
      name: json['name'],
      description: json['description'],
      elements: (json['items'] as List?)?.map((e) => e['name'].toString()).toList() ?? [],
      dataLists: [], // Se implementará cuando se agregue el modelo de listas
    );
  }

  ContainerNode copyWith({
    String? id,
    String? name,
    String? description,
    List<ContainerNode>? children,
    List<String>? elements,
    List<String>? dataLists,
  }) {
    return ContainerNode(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      children: children ?? this.children,
      elements: elements ?? this.elements,
      dataLists: dataLists ?? this.dataLists,
    );
  }
}