// comment
int global;

int add(int a, int b) {
  return a + b;
}

int main() {
  global = 1;
  bool b;
  string s = "Hello";
  double d = 4.2;

  while(global < 10) {
    if (b) {
      b = false;
    } else {
      b = true;
    }

    global = global + 1; // note
  }

  print("%d - %s\n", global, s);

  return add(0, 0);
}
