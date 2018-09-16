class Resource {
  final String id;
  final String name;
  Resource(this.id, this.name);

  factory Resource.fromJson(Map<String, dynamic> json) =>
      new Resource(json["id"], json["name"]);

  Map<String, dynamic> toJson() => {"name": name, "id": id};
}
