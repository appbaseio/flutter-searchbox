bool isNumeric(var arg) {
  if (arg is String) {
    if (arg == null || arg.isEmpty) {
      return false;
    }
    final number = num.tryParse(arg);

    if (number == null) {
      return false;
    }

    return true;
  } else if (arg is num) {
    return true;
  } else if (arg is List) {
    for (var i = 1; i < arg.length; i++) {
      // leaving out the first element for other options
      if (isNumeric(arg[i])) {
        return true;
      } else {
        return false;
      }
    }
  }

  return false;
}
