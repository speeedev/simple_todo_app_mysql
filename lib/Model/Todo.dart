class Todo {
  int id;
  String? title;
  bool iscomplated;
  bool? isstar;
  Todo({
    required this.id,
    required this.title,
    required this.iscomplated,
    this.isstar = false,
  });
}
