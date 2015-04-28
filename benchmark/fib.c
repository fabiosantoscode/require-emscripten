/* require-emscripten: -O3 */

long fibonacci(int n) {
  /**
   * Here we declare and set our variables.
   */
  int a = 0;
  int b = 1;
  int sum;
  int i;

  /**
   * Here is the standard for loop. This will step through, performing the code
   * inside the braces until i is equal to n.
   */
  for (i=0;i<n;i++)
  {
    sum = a + b;
    a = b;
    b = sum;
  }
  return sum;
}
