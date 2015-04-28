'use strict'

module.exports = function fibonacci(n) {
  /**
   * Here we declare and set our variables.
   */
  var a = 0;
  var b = 1;
  var sum;
  var i;

  /**
   * Here is the standard for loop. This will step through, performing the code
   * inside the braces until i is equal to n.
   */
  for (i=0;i<n;i++) {
    sum = a + b;
    a = b;
    b = sum;
  }
  return sum;
}


