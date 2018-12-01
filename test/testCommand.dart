import 'package:flutter_test/flutter_test.dart';
import 'package:xiaoming/src/command/cmdMethod.dart';
import 'package:xiaoming/src/command/handleCommand.dart';
import 'package:xiaoming/src/command/handleEquations.dart';
import 'package:xiaoming/src/command/handleNonlinearEquation.dart';
import 'package:xiaoming/src/command/matrix.dart';

void main() {

  test('Polyomial', (){
    print(handleCommand('a=[1,-2,1]'));
    print(CmdMethodUtil.Polyomial([[1,-2,1]]));
  });

  test('calculus', (){
    print(handleCommand('Fun test(x):r=cos(x)'));
    print(handleCommand('calculus(test,0,180,1000)'));
  });
  
  test('test _nonlinearEquation', (){
    String cmd = 'x^2-2x+1';
    var instance = EquationsUtil.getInstance();
    print(instance.handleEquation(cmd, 'x'));
  });

  test('test getHessenberg', (){
    List<List<num>> matrix = [[4,1,0],[1,0,-1],[1,1,-4]];
    var result = MatrixUtil.getHessenberg(matrix);
    expect(result, [[4, 1.0, 0], [1, -1.0, -1], [0.0, -2.0, -3.0]]);
  });

  test('test EigenValue', (){
    List<List<num>> matrix = [[0,12,-16],[1,0,0],[0,1,0]];
    List<List<num>> result = MatrixUtil.EigenValue(matrix, 400, 4);
    print(result);
  });

  test('test handleNonlinearEquation', () {
    NonlinearEquationUtil instance = NonlinearEquationUtil.getInstance();
    var result = instance.handleNonlinearEquation('-3x^3+5x-10', 'x');
    expect(result, '-3*x^3+5*x-10');
  });

  test('test NonlinearEquationUtil.handleCaculStr', () {
    NonlinearEquationUtil instance = NonlinearEquationUtil.getInstance();
    var result = instance.handleCalcuStr('-2+4*(-3+4)');
    expect(result, 2);
  });
  test('test handleCaculStr', () {
    var result = handleCalcuStr('-2+4*(-3+4)');
    expect(result, 2);
  });
  test('test UserFunction invoke', () {
    var a = [
      [1, 1, 5, 3, 2],
      [2, 3, 2, 5, 7],
      [6, 4, 2, 5, 3],
      [3, 5, 2, 3, 2],
      [3, 2, 2, 1, 6]
    ];
    var b = [
      [2],
      [5]
    ];
    var instance = EquationsUtil.getInstance();
    print(MatrixUtil.mtoString(name: "B", list: MatrixUtil.upperTriangular(a)));
  });

  test('test upperTriangular function', () {
    var a = [
      [1, 1, 5, 3, 2],
      [2, 3, 2, 5, 7],
      [6, 4, 2, 5, 3],
      [3, 5, 2, 3, 2],
      [3, 2, 2, 1, 6]
    ];
    expect(MatrixUtil.upperTriangular(a), [
      [1, 1, 5, 3, 2],
      [0.0, 0.5, -4.0, -0.5, 1.5],
      [0.0, 0.0, 11.0, 3.7499999999999996, 0.7499999999999996],
      [0.0, 0.0, 0.0, -18.416666666666654, -37.41666666666665],
      [0.0, 0.0, 0.0, 0.0, 81.753086419753]
    ]);
  });

  test('test getResult function', () {
    var a = [
      [1, 1, 1, 6],
      [0, 4, -1, 5],
      [2, -2, 1, 1]
    ];
    expect(MatrixUtil.getResult(MatrixUtil.upperTriangular(a)), [1.0, 2.0, 3.0]);
  });
}
