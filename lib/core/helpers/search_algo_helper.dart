
class SearchAlgoHelper {

  static int binarySearch<E>(List<E> elements, {required int Function(E current) where}) {
    int left = 0;
    int right = elements.length - 1;

    while(left <= right) {
      final int mid = (left + right) ~/ 2;
      if(where(elements[mid]) == 0) {
        return mid;
      }else if(where(elements[left]) == 0) {
        return left;
      }else if(where(elements[right]) == 0) {
        return right;
      }else if(where(elements[mid]) == -1) {
        left = mid + 1;
      }else if(where(elements[mid]) == 1) {
        right = mid - 1;
      }
      if(left == mid || right == mid) break;
    }

    return -1;
  }
}