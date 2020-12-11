

class CategoryModel {
  String name;
  bool isSelected;
  String sub = '';

  //Handle logic cuisine
  int index = 0;
  bool isRight = false;
  bool isLeft = false;
  double width = 0;

  CategoryModel(this.name, this.isSelected);

}