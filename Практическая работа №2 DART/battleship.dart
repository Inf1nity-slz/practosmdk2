import 'dart:io';
import 'dart:math';

const int boardSize = 10;
const List<int> shipSizes = [4, 3, 3, 2, 2, 2, 1, 1, 1, 1];
List<List<String>> playerBoard = createBoard();
List<List<String>> opponentBoard = createBoard();

void displayBoard(List<List<String>> board, {bool hideShips = true}) {
  stdout.write("  |");
  for (int i = 1; i <= boardSize; i++) {
    stdout.write("$i|");
  }
  stdout.writeln();
  stdout.write("-" * (boardSize * 2 + 3));
  stdout.writeln();

  for (int i = 0; i < boardSize; i++) {
    stdout.write("${i + 1} |");
    for (int j = 0; j < boardSize; j++) {
      if (hideShips && board[i][j] == 'S') {
        stdout.write(" |");
      } else {
        stdout.write("${board[i][j]}|");
      }
    }
    stdout.writeln();
    stdout.write("-" * (boardSize * 2 + 3));
    stdout.writeln();
  }
}

List<List<String>> createBoard() {
  return List.generate(
      boardSize, (_) => List.filled(boardSize, ' ', growable: false),
      growable: false);
}

bool isValidPlacement(List<List<String>> board, int shipSize, int row, int col,
    bool isHorizontal) {
  if (isHorizontal) {
    if (col + shipSize > boardSize) return false;
    for (int i = 0; i < shipSize; i++) {
      if (board[row][col + i] != ' ') return false;
    }
  } else {
    if (row + shipSize > boardSize) return false;
    for (int i = 0; i < shipSize; i++) {
      if (board[row + i][col] != ' ') return false;
    }
  }
  return true;
}

void placeShip(List<List<String>> board, int shipSize, int row, int col,
    bool isHorizontal) {
  if (isHorizontal) {
    for (int i = 0; i < shipSize; i++) {
      board[row][col + i] = 'S';
    }
  } else {
    for (int i = 0; i < shipSize; i++) {
      board[row + i][col] = 'S';
    }
  }
}

void playerPlaceShips() {
  print("Разместите ваши корабли (S) на поле.");
  displayBoard(playerBoard, hideShips: false);

  for (int shipSize in shipSizes) {
    bool placed = false;
    while (!placed) {
      print("Разместите корабль длиной $shipSize.");
      stdout.write(
          "Введите строку (1-${boardSize}), столбец (1-${boardSize}) и ориентацию (h/v) через пробел: ");
      String? input = stdin.readLineSync();
      if (input == null) {
        print("Некорректный ввод.");
        continue;
      }

      List<String> parts = input.split(' ');
      if (parts.length != 3) {
        print("Некорректный ввод. Нужно 3 значения.");
        continue;
      }

      try {
        int row = int.parse(parts[0]) - 1;
        int col = int.parse(parts[1]) - 1;
        bool isHorizontal = parts[2].toLowerCase() == 'h';

        if (row < 0 || row >= boardSize || col < 0 || col >= boardSize) {
          print("Координаты вне диапазона.");
          continue;
        }

        if (!isValidPlacement(playerBoard, shipSize, row, col, isHorizontal)) {
          print("Невозможно разместить корабль здесь.");
          continue;
        }

        placeShip(playerBoard, shipSize, row, col, isHorizontal);
        displayBoard(playerBoard, hideShips: false);
        placed = true;
      } catch (e) {
        print(
            "Ошибка ввода. Введите числовые координаты и h/v для ориентации.");
      }
    }
  }
  print("Все корабли размещены!");
}

void autoPlaceShips(List<List<String>> board) {
  Random random = Random();
  for (int shipSize in shipSizes) {
    bool placed = false;
    while (!placed) {
      int row = random.nextInt(boardSize);
      int col = random.nextInt(boardSize);
      bool isHorizontal = random.nextBool();
      if (isValidPlacement(board, shipSize, row, col, isHorizontal)) {
        placeShip(board, shipSize, row, col, isHorizontal);
        placed = true;
      }
    }
  }
}

List<int> getPlayerMove() {
  while (true) {
    stdout.write('Введите координаты выстрела (например, 1 2): ');
    String? input = stdin.readLineSync();

    if (input == null) {
      print("Некорректный ввод. Пожалуйста, попробуйте еще раз.");
      continue;
    }

    List<String> parts = input.split(' ');
    if (parts.length != 2) {
      print(
          "Некорректный ввод. Пожалуйста, введите две координаты, разделенные пробелом.");
      continue;
    }

    try {
      int row = int.parse(parts[0]) - 1;
      int col = int.parse(parts[1]) - 1;

      if (row < 0 || row >= boardSize || col < 0 || col >= boardSize) {
        print(
            "Координаты выходят за пределы игрового поля. Пожалуйста, попробуйте еще раз.");
        continue;
      }
      return [row, col];
    } catch (e) {
      print("Некорректный ввод. Пожалуйста, введите числовые координаты.");
    }
  }
}

void main() {
  print("Добро пожаловать в Морской Бой!");

  playerPlaceShips();

  print("Теперь расставляем корабли противника...");
  autoPlaceShips(opponentBoard);

  int shotsFired = 0;
  int shipsSunk = 0;

  while (shipsSunk < shipSizes.length) {
    shotsFired++;
    List<int> move = getPlayerMove();
    int row = move[0];
    int col = move[1];

    if (opponentBoard[row][col] == 'S') {
      print('Попадание!');
      opponentBoard[row][col] = 'X';
      shipsSunk++;
    } else {
      print('Промах!');
      opponentBoard[row][col] = 'O';
    }
    displayBoard(opponentBoard);
    print('Выстрелов сделано: $shotsFired, Кораблей потоплено: $shipsSunk');
  }

  print(
      'Поздравляем! Вы потопили все корабли противника за $shotsFired выстрелов.');
}