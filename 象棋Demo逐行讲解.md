# 象棋 Demo：从零看懂每一行

这份讲义对应当前项目里的代码。每张表的“行号”以对应原文件为准；空行只用于排版，所以不单独列出。原有代码没有被讲义修改。建议在编辑器中打开对应文件，边看边对照下面的解释。

## 先看程序在做什么

现在这是一个尚未完成的图形界面示例：它显示棋盘、一个红帅和两个红仕；红仕可以按照目前写好的局部规则移动，红帅的移动规则仍是占位代码。没有黑棋，也尚未实现完整对局、吃子、轮流走棋、将军或胜负判断。左上角的 Click 按钮只用来演示按钮和标签。

各文件的分工：

| 文件 | 作用 |
| --- | --- |
| Main.java | 程序入口，创建并连接各个对象。 |
| Board.java | 保存棋盘和棋子的位置，检查并执行移动。 |
| Piece.java | 定义棋子的共同信息及必须实现的移动方法。 |
| AdvisorPiece.java、GeneralPiece.java | 分别提供红仕、红帅的具体类型。 |
| ChessFrame.java | 创建窗口、按钮、标签和棋盘面板。 |
| BoardPanel.java | 画出棋盘、棋子和高亮；把鼠标像素坐标转换成棋盘行列。 |
| ChessController.java | 处理鼠标点击、选中棋子和发起移动。 |
| start.bat、build.ps1 | 在 Windows 上编译并启动程序。 |
| pom.xml | Maven 项目描述文件；当前双击启动流程没有使用它。 |

数据流可以按下面的顺序理解：

```text
双击 start.bat → build.ps1 编译并运行 Main.main
                       ↓
创建 Board → 创建 ChessFrame / BoardPanel → 创建 ChessController
                       ↓
用户左键点棋盘 → Controller 换算并处理选择 → Board 检查和更新位置
                       ↓
Panel 收到 repaint 请求 → 根据 Board 的最新状态重新画出来
```

## 看代码前先认识几个符号

- 行、列都从 0 开始：行是 0～9，列是 0～8。棋盘左上角是 (0,0)，下方红帅起始位置是 (9,4)。坐标写法为 (行,列)；屏幕坐标则是 (x,y)，即 (列对应的水平坐标,行对应的垂直坐标)。
- `class` 定义类型，`new` 创建对象；变量如 `board` 可以保存对象引用。构造方法与类同名，创建对象时调用。
- `public` 允许外部访问，`private` 限制在本类内部，`protected` 允许相关继承场景等访问。具体能否访问还与包有关。
- `int` 是整数，`boolean` 是真假值，`String` 是字符串，`void` 表示方法不返回值，`null` 表示没有对象引用。
- `static` 成员属于类本身；`final` 限制变量重新赋值。对于数组或对象引用，`final` 不意味着对象内部内容不能改变。
- `if` 表示条件判断，`for` 表示循环；`return` 结束当前方法并可返回结果，`continue` 跳到循环的下一次。
- `=` 是赋值，`==` 是比较是否相等，`!=` 是不相等，`!` 是取反，`&&` 是并且，`||` 是或者。
- `//` 后面是单行注释，`/** ... */` 是文档注释，编译后的程序不会执行它们；`TODO` 表示以后计划补充，**不表示已经实现**。
- `{` 和 `}` 用来标记类、方法、判断或循环的范围；结束大括号本身没有额外的业务操作。

## 跟着一次真实操作走一遍

以红仕从 (9,3) 走到 (8,4) 为例，假设目标为空：

1. 第一次点击时，面板把屏幕上的鼠标位置换算成行列；控制器查到 (9,3) 有红仕，就记录选中位置并请求高亮。
2. 第二次点击 (8,4)，控制器调用 `board.tryMove(9, 3, 8, 4)`。
3. Board 检查坐标有效、起点有棋子、终点为空，再调用该棋子的 `canMove`。
4. AdvisorPiece 检查行和列都变化 1，目标列在 3～5、目标行在 7～9，于是返回 true。
5. Board 把原格设为 null、目标格设为那枚棋子，返回 true。控制器清除选中并请求重绘；面板重新读取棋盘后，新位置就显示棋子。

如果试着移动红帅，GeneralPiece.canMove 现在总是返回 false，所以帅会保持原位；这是目前代码的真实行为。

## 逐行对照

表里每一行都保留原文件的行号和代码；注释和结束符也会说明。很长的源码被拆成几行时，要结合上下文一起阅读。

### Main.java：程序入口

[打开原文件](XiangQi/src/main/java/edu/sustech/xiangqi/Main.java)

| 行号 | 原代码 | 解释 |
| ---: | --- | --- |
| 1 | `package edu.sustech.xiangqi;` | 声明本类所在的包，相当于给类安排命名空间。 |
| 3 | `import edu.sustech.xiangqi.controller.ChessController;` | 引入负责鼠标交互的 ChessController 类，后面可直接使用类名。 |
| 4 | `import edu.sustech.xiangqi.model.Board;` | 引入保存棋盘状态的 Board 类。 |
| 5 | `import edu.sustech.xiangqi.view.ChessFrame;` | 引入棋盘窗口 ChessFrame 类。 |
| 7 | `import javax.swing.SwingUtilities;` | 引入 Swing 的工具类，用它安排界面任务。 |
| 9 | `// 程序入口` | 原代码注释，仅供阅读：程序入口。 |
| 10 | `public class Main {` | 声明一个可供外部使用的 Main 类；后面的花括号包住类的内容。 |
| 11 | `public static void main(String[] args) {` | Java 程序入口。public 允许调用，static 表示无需创建 Main 实例，void 表示无返回值，args 接收启动参数。 |
| 12 | `SwingUtilities.invokeLater(new Runnable() {` | 创建一个实现 Runnable 的匿名对象，并把它交给 Swing 事件派发线程稍后执行；界面创建和更新应安排在该线程。 |
| 13 | `@Override` | 说明接下来的 run 方法覆盖了 Runnable 声明的方法，编译器会检查是否正确覆盖。 |
| 14 | `public void run() {` | 界面任务的入口：事件派发线程执行到这里时，会依次执行下面的语句。 |
| 15 | `Board board = new Board();` | 调用 Board 构造方法创建棋盘，构造时会初始化棋子；board 保存这个对象的引用。 |
| 16 | `ChessFrame frame = new ChessFrame(board);` | 创建窗口，把刚才的同一个 board 传进去，让窗口中的棋盘面板读取这份状态。 |
| 17 | `ChessController controller = new ChessController(board, frame.getBoardPanel());` | 创建控制器，传入同一份棋盘数据，以及从窗口取得的棋盘面板。 |
| 19 | `frame.getBoardPanel().addMouseListener(controller);` | 把 controller 注册为棋盘面板的鼠标监听器，面板收到鼠标事件后才能通知它。 |
| 20 | `frame.setVisible(true);` | 让窗口可见；前面只是创建和配置窗口，到这里才显示。 |
| 21 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 22 | `});` | 结束匿名 Runnable 的创建，并结束 invokeLater 方法调用。 |
| 23 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 24 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |

### Board.java：棋盘数据和移动检查

[打开原文件](XiangQi/src/main/java/edu/sustech/xiangqi/model/Board.java)

| 行号 | 原代码 | 解释 |
| ---: | --- | --- |
| 1 | `package edu.sustech.xiangqi.model;` | 声明本类属于 model 包，model 主要放数据与规则。 |
| 3 | `// 保存棋盘数据，并统一检查和执行移动` | 原代码注释，仅供阅读：保存棋盘数据，并统一检查和执行移动。 |
| 5 | `public class Board {` | 声明公开的 Board 类；一个 Board 对象代表一份棋盘状态。 |
| 6 | `// 定义棋盘大小` | 原代码注释，仅供阅读：定义棋盘大小。 |
| 7 | `public static final int ROWS = 10;` | 定义公共常量 ROWS 为 10，表示十条横向交叉点行；static 属于类，final 表示这个值不能重新赋值。 |
| 8 | `public static final int COLS = 9;` | 定义列数常量 COLS 为 9，列编号是 0～8。 |
| 10 | `// 存储棋子位置` | 原代码注释，仅供阅读：存储棋子位置。 |
| 11 | `private final Piece[][] pieces = new Piece[ROWS][COLS];` | 创建 10×9 的 Piece 引用二维数组；数组元素初始均为 null。final 固定数组引用，但允许改变某一格的内容。 |
| 13 | `public Board() {` | 声明无参数构造方法；new Board() 时自动调用。 |
| 14 | `initializePieces();` | 调用初始化方法，向空棋盘放入示例棋子。 |
| 15 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 17 | `private void initializePieces() {` | 声明仅本类内部使用的初始化方法，void 表示不返回值。 |
| 18 | `pieces[9][3] = new AdvisorPiece();` | 创建一个红仕，放到第 9 行、第 3 列；下标从 0 开始。 |
| 19 | `pieces[9][4] = new GeneralPiece();` | 创建红帅，放到第 9 行、第 4 列。 |
| 20 | `pieces[9][5] = new AdvisorPiece();` | 再创建一个独立的红仕对象，放到第 9 行、第 5 列。 |
| 21 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 23 | `public boolean isInside(int row, int col) {` | 定义判断棋盘行列是否有效的方法，返回 boolean（true 或 false）。 |
| 24 | `return row >= 0 && row < ROWS && col >= 0 && col < COLS;` | 行必须在 0～9、列必须在 0～8；四个条件都满足才返回 true。&& 表示并且。 |
| 25 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 27 | `public Piece getPieceAt(int row, int col) {` | 定义按行列获取棋子的方法，返回 Piece 或 null。 |
| 28 | `if (!isInside(row, col)) {` | 如果坐标不在棋盘内，进入条件块；! 表示取反。 |
| 29 | `return null;` | 对越界坐标返回 null，避免直接访问数组导致下标越界。 |
| 30 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 31 | `return pieces[row][col];` | 坐标有效时返回该格的棋子引用；该格为空时本身也是 null。 |
| 32 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 34 | `public boolean tryMove(int fromRow, int fromCol, int toRow, int toCol) {` | 定义尝试移动的方法，参数依次是起点行、起点列、终点行、终点列。 |
| 35 | `if (!isInside(fromRow, fromCol) \|\| !isInside(toRow, toCol)) {` | 只要起点或终点越界，就不允许移动；\|\| 表示或者。 |
| 36 | `return false;` | 返回 false 表示本次移动失败，方法立即结束。 |
| 37 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 38 | `if (fromRow == toRow && fromCol == toCol) {` | 若起点与终点的行、列都相同，说明没有实际移动。 |
| 39 | `return false;` | 原地不动按失败处理并立即返回。 |
| 40 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 42 | `Piece piece = getPieceAt(fromRow, fromCol);` | 读取起点的棋子，存入局部变量 piece。 |
| 43 | `if (piece == null) {` | 检查起点是否为空。 |
| 44 | `return false;` | 起点没有棋子时不能移动。 |
| 45 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 47 | `// TODO: 加入回合检查，只允许当前一方移动自己的棋子` | 待完成事项：加入回合检查，只允许当前一方移动自己的棋子。这行只是注释，功能尚未由它实现。 |
| 49 | `// TODO: 区分己方占用与敌方棋子，并实现吃子` | 待完成事项：区分己方占用与敌方棋子，并实现吃子。这行只是注释，功能尚未由它实现。 |
| 50 | `if (getPieceAt(toRow, toCol) != null) {` | 如果目标格已经有任何棋子，就拒绝；当前实现还不区分己方和对方，也不能吃子。 |
| 51 | `return false;` | 目标格被占用时返回失败。 |
| 52 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 54 | `if (!piece.canMove(this, fromRow, fromCol, toRow, toCol)) {` | 调用具体棋子自己的 canMove 检查走法，并将当前 Board 作为 this 传入；! 表示走法不合法时进入分支。 |
| 55 | `return false;` | 棋子自身规则不允许时返回失败。 |
| 56 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 58 | `// TODO: 检查走完后己方将帅是否安全` | 待完成事项：检查走完后己方将帅是否安全。这行只是注释，功能尚未由它实现。 |
| 59 | `pieces[fromRow][fromCol] = null;` | 所有已实现的检查通过后，先把起点数组格设为空。 |
| 60 | `pieces[toRow][toCol] = piece;` | 把同一个棋子引用放到目标格；这两行完成棋盘数据上的移动。 |
| 62 | `// TODO: 仅在成功移动后切换回合，并判断将军、胜负等状态` | 待完成事项：仅在成功移动后切换回合，并判断将军、胜负等状态。这行只是注释，功能尚未由它实现。 |
| 63 | `return true;` | 返回 true 表示移动成功；这本身不负责绘图。 |
| 64 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 65 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |

### Piece.java：棋子共同的父类

[打开原文件](XiangQi/src/main/java/edu/sustech/xiangqi/model/Piece.java)

| 行号 | 原代码 | 解释 |
| ---: | --- | --- |
| 1 | `package edu.sustech.xiangqi.model;` | 声明 Piece 位于 model 包。 |
| 3 | `// 棋子的抽象父类。棋子保存身份信息，所在位置由 Board 的数组下标表示` | 原代码注释，仅供阅读：棋子的抽象父类。棋子保存身份信息，所在位置由 Board 的数组下标表示。 |
| 5 | `public abstract class Piece {` | 声明抽象类 Piece：它描述棋子的共同特点，不能直接 new Piece()。 |
| 6 | `private final String name;` | 每个棋子有一个私有名称，例如“仕”或“帅”；final 表示赋值后不能再换成别的名称。 |
| 7 | `private final boolean isRed;` | 每个棋子有一个私有布尔字段，true 表示红方，false 可用来表示黑方；本示例实际只创建红棋。 |
| 9 | `protected Piece(String name, boolean isRed) {` | 受保护的构造方法，供子类通过 super 调用，接收名称与颜色。 |
| 10 | `this.name = name;` | 将参数 name 存入当前对象的 name 字段；this.name 指字段，右边 name 指参数。 |
| 11 | `this.isRed = isRed;` | 将传入的颜色存入当前棋子的 isRed 字段。 |
| 12 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 14 | `public String getName() {` | 定义公开方法，供外部读取棋子的文字名称。 |
| 15 | `return name;` | 把当前棋子的 name 返回给调用者。 |
| 16 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 18 | `public boolean isRed() {` | 定义公开方法，用来询问这个棋子是否为红方。 |
| 19 | `return isRed;` | 返回保存的布尔值。 |
| 20 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 22 | `/**` | 开始一段 Java 文档注释，后面介绍方法用途。 |
| 23 | `* 判断本棋子的局部走法是否合法` | 文档注释内容：判断本棋子的局部走法是否合法；不会作为代码执行。 |
| 24 | `* @return 是否可以移动` | 文档注释内容：@return 是否可以移动；不会作为代码执行。 |
| 25 | `*/` | 结束这段 Java 文档注释。 |
| 26 | `public abstract boolean canMove(Board board, int fromRow, int fromCol, int toRow, int toCol);` | 声明抽象方法而不给出方法体，要求具体子类实现自己的走法；参数含棋盘及起终点，返回是否合法。 |
| 27 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |

### AdvisorPiece.java：红仕的移动规则

[打开原文件](XiangQi/src/main/java/edu/sustech/xiangqi/model/AdvisorPiece.java)

| 行号 | 原代码 | 解释 |
| ---: | --- | --- |
| 1 | `package edu.sustech.xiangqi.model;` | 声明本类属于 model 包，因此无需 import 同包的 Piece 和 Board。 |
| 3 | `// 红仕：每次斜走一格，不能离开红方九宫` | 原代码注释，仅供阅读：红仕：每次斜走一格，不能离开红方九宫。 |
| 5 | `public class AdvisorPiece extends Piece {` | 定义 AdvisorPiece（仕），extends Piece 表示它继承棋子的名称、颜色等共同能力。 |
| 6 | `public AdvisorPiece() {` | 定义红仕的无参数构造方法。 |
| 7 | `super("仕", true);` | 调用父类 Piece 的构造方法，将名称设为“仕”、颜色设为红色。 |
| 8 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 10 | `@Override` | 声明下面的方法是对父类方法的覆盖。 |
| 11 | `public boolean canMove(Board board, int fromRow, int fromCol, int toRow, int toCol) {` | 实现棋子的局部走法检查；本实现暂不需要读取传入的 board，但签名要与父类一致。 |
| 12 | `// 行和列必须都变化一格，不能直走、原地停留或跨越多格` | 原代码注释，仅供阅读：行和列必须都变化一格，不能直走、原地停留或跨越多格。 |
| 13 | `if (Math.abs(toRow - fromRow) != 1 \|\| Math.abs(toCol - fromCol) != 1) {` | Math.abs 取绝对值；如果行差或列差不等于 1，就不是斜走一格。!= 表示不等于。 |
| 14 | `return false;` | 走法不是斜走一格，返回 false。 |
| 15 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 17 | `// 列判断` | 原代码注释，仅供阅读：列判断。 |
| 18 | `if (toCol < 3 \|\| toCol > 5) {` | 红方九宫的列号只能是 3、4、5；目标列在范围外就拒绝。 |
| 19 | `return false;` | 目标列不在九宫中，返回 false。 |
| 20 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 22 | `// 行判断` | 原代码注释，仅供阅读：行判断。 |
| 23 | `// TODO: 补齐黑方棋子的行判断` | 待完成事项：补齐黑方棋子的行判断。这行只是注释，功能尚未由它实现。 |
| 24 | `return toRow >= 7 && toRow <= 9;` | 目标行是 7、8 或 9 时返回 true，否则返回 false；这只适用于红方九宫。 |
| 25 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 26 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |

### GeneralPiece.java：红帅的占位规则

[打开原文件](XiangQi/src/main/java/edu/sustech/xiangqi/model/GeneralPiece.java)

| 行号 | 原代码 | 解释 |
| ---: | --- | --- |
| 1 | `package edu.sustech.xiangqi.model;` | 声明本类属于 model 包。 |
| 3 | `// 红帅` | 原代码注释，仅供阅读：红帅。 |
| 5 | `public class GeneralPiece extends Piece {` | 定义继承 Piece 的 GeneralPiece，表示这里的红帅。 |
| 6 | `public GeneralPiece() {` | 定义红帅的无参数构造方法。 |
| 7 | `super("帅", true);` | 调用父类构造方法，设置名称“帅”和红方颜色。 |
| 8 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 10 | `@Override` | 标记下面的方法覆盖父类的抽象方法。 |
| 11 | `public boolean canMove(Board board, int fromRow, int fromCol, int toRow, int toCol) {` | 实现父类要求的 canMove 方法，但目前只有占位逻辑。 |
| 12 | `// TODO：实现帅的移动规则。` | 待完成事项：实现帅的移动规则。。这行只是注释，功能尚未由它实现。 |
| 13 | `return false;` | 无论起点和终点是什么都返回 false，因此当前示例中的帅不能移动。 |
| 14 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 15 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |

### ChessFrame.java：窗口和示例按钮

[打开原文件](XiangQi/src/main/java/edu/sustech/xiangqi/view/ChessFrame.java)

| 行号 | 原代码 | 解释 |
| ---: | --- | --- |
| 1 | `package edu.sustech.xiangqi.view;` | 声明类位于负责界面显示的 view 包。 |
| 3 | `import edu.sustech.xiangqi.model.Board;` | 引入棋盘数据类 Board，以便传给棋盘面板。 |
| 5 | `import javax.swing.*;` | 引入 javax.swing 包中的类，本文件用到了 JFrame、JButton、JLabel；星号不是引入子包。 |
| 7 | `public final class ChessFrame extends JFrame {` | 声明 ChessFrame 继承 Swing 窗口 JFrame；final 表示这个类不能再被继承。 |
| 8 | `private static final long serialVersionUID = 1L;` | 声明序列化版本标识；Swing 组件可序列化，这行主要用于版本标识，与当前走棋逻辑无关。 |
| 10 | `private final BoardPanel boardPanel;` | 保存窗口持有的棋盘面板引用；final 表示构造后不能改指其他面板。 |
| 12 | `public ChessFrame(Board board) {` | 构造窗口时接收棋盘数据对象。 |
| 13 | `super("中国象棋");` | 调用父类 JFrame 的构造方法，把窗口标题设为“中国象棋”；super 必须放在构造方法开头。 |
| 14 | `setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);` | 用户关闭这个窗口时结束应用进程。 |
| 15 | `boardPanel = new BoardPanel(board);` | 创建 BoardPanel，并让它使用传入的同一份 board。 |
| 16 | `boardPanel.setLayout(null);  // 关键：关闭布局管理器` | 关闭此面板子组件的布局管理器，使按钮和标签使用后面手动设定的位置；棋盘本身仍由绘图代码绘制。 |
| 18 | `JButton button = new JButton("Click");` | 创建一个显示 Click 的按钮。 |
| 19 | `button.setBounds(10, 10, 80, 30);  // x, y, width, height` | 设置按钮在面板内的位置和尺寸：左上角 (10,10)，宽 80、高 30，单位为像素。 |
| 20 | `boardPanel.add(button);` | 把按钮添加到棋盘面板；按钮会作为子组件显示在面板上。 |
| 21 | `JLabel label=new JLabel("Sample");` | 创建一个初始文字为 Sample 的标签。 |
| 22 | `label.setBounds(100, 10, 80, 30);` | 设置标签的位置和尺寸。 |
| 23 | `boardPanel.add(label);` | 把标签添加到面板。 |
| 24 | `button.addActionListener(e->{` | 给按钮注册点击动作；e -> { ... } 是 lambda 写法，e 接收动作事件，这里没有使用 e。 |
| 25 | `label.setText("Click");` | 按钮触发时，把标签文字改成 Click；它只是界面示例，不负责走棋。 |
| 26 | `});` | 结束 lambda 的代码块，并完成 addActionListener 调用。 |
| 27 | `setContentPane(boardPanel);` | 把 boardPanel 设为窗口的内容面板。 |
| 28 | `setSize(1000,1000);` | 把整个窗口尺寸设置为 1000×1000 像素；这包含窗口边框和标题栏。 |
| 29 | `setResizable(false);` | 禁止用户拖动改变窗口大小。 |
| 30 | `setLocationRelativeTo(null);` | 传入 null 让窗口相对屏幕居中；具体显示效果还受屏幕大小影响。 |
| 31 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 33 | `public BoardPanel getBoardPanel() {` | 提供公开方法，供外部取得这个窗口持有的棋盘面板。 |
| 34 | `return boardPanel;` | 把 boardPanel 返回给调用者，例如 Main 会用它注册鼠标监听器。 |
| 35 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 36 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |

### BoardPanel.java：绘图与鼠标坐标换算

[打开原文件](XiangQi/src/main/java/edu/sustech/xiangqi/view/BoardPanel.java)

| 行号 | 原代码 | 解释 |
| ---: | --- | --- |
| 1 | `package edu.sustech.xiangqi.view;` | 声明类属于 view 包。 |
| 3 | `import edu.sustech.xiangqi.model.Board;` | 引入棋盘数据类型 Board。 |
| 4 | `import edu.sustech.xiangqi.model.Piece;` | 引入棋子父类 Piece，以便读取棋子的名称和颜色。 |
| 6 | `import javax.swing.JPanel;` | 引入 Swing 的 JPanel，棋盘面板将继承它。 |
| 7 | `import java.awt.BasicStroke;` | 引入 BasicStroke，用于设置线条粗细。 |
| 8 | `import java.awt.Color;` | 引入 Color，用 RGB 数值表示颜色。 |
| 9 | `import java.awt.Dimension;` | 引入 Dimension，用于表示宽和高。 |
| 10 | `import java.awt.Font;` | 引入 Font，用于指定字体、粗细和大小。 |
| 11 | `import java.awt.FontMetrics;` | 引入 FontMetrics，用于测量文字宽高及基线。 |
| 12 | `import java.awt.Graphics;` | 引入基础绘图对象 Graphics。 |
| 13 | `import java.awt.Graphics2D;` | 引入功能更丰富的 Graphics2D。 |
| 14 | `import java.awt.Point;` | 引入 Point，用 x、y 两个整数保存位置。 |
| 15 | `import java.awt.RenderingHints;` | 引入 RenderingHints，用于设置抗锯齿等绘制选项。 |
| 17 | `// 绘制棋盘、棋子和选中效果` | 原代码注释，仅供阅读：绘制棋盘、棋子和选中效果。 |
| 18 | `public final class BoardPanel extends JPanel {` | 定义不可继承的棋盘面板类，继承 JPanel 从而成为可绘制、可接收鼠标事件的 Swing 组件。 |
| 19 | `private static final long serialVersionUID = 1L;` | 声明序列化版本标识，对当前棋局规则没有直接影响。 |
| 20 | `private static final int CELL_SIZE = 52;` | 常量：相邻棋盘交叉点相隔 52 像素。 |
| 21 | `private static final int MARGIN = 36;` | 常量：第一个交叉点距离面板左边、上边各 36 像素。 |
| 22 | `private static final int PIECE_RADIUS = 21;` | 常量：绘制棋子圆形时使用 21 像素半径。 |
| 23 | `private static final int HIT_RADIUS = 23;` | 常量：点击位置离交叉点不超过 23 像素时才算点中。 |
| 25 | `private final Board board;` | 保存棋盘数据引用，供绘图和边界检查使用。 |
| 26 | `private int highlightedRow = -1;` | 保存要高亮的行；-1 表示不高亮任何有效行。 |
| 27 | `private int highlightedCol = -1;` | 保存要高亮的列；初始同样为 -1。 |
| 29 | `public BoardPanel(Board board) {` | 构造棋盘面板时接收一个 Board。 |
| 30 | `this.board = board;` | 把参数 board 保存到当前面板字段中。 |
| 31 | `setBackground(new Color(239, 218, 179));` | 将面板背景设置为浅木色；三个数依次是红、绿、蓝分量。 |
| 32 | `setPreferredSize(new Dimension(` | 向 Swing 声明面板的首选尺寸；下一、下下一行给出宽和高。最终尺寸还受窗口和布局方式影响。 |
| 33 | `MARGIN * 2 + CELL_SIZE * (Board.COLS - 1),` | 宽度 = 左右各一个边距 + 8 个交叉点间距，即 36×2 + 52×(9-1) = 488。 |
| 34 | `MARGIN * 2 + CELL_SIZE * (Board.ROWS - 1)));` | 高度 = 上下各一个边距 + 9 个交叉点间距，即 36×2 + 52×(10-1) = 540，并结束这次调用。 |
| 35 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 37 | `// 返回交叉点坐标` | 原代码注释，仅供阅读：返回交叉点坐标。 |
| 38 | `public Point getIntersectionAt(int x, int y) {` | 定义坐标转换方法：接收面板内的像素 x、y，返回棋盘交叉点或 null。 |
| 39 | `int col = (int) Math.round((x - MARGIN) / (double) CELL_SIZE);` | 减去边距后除以间距，并四舍五入到最近列；(double) 保留小数，(int) 将结果转为整数。 |
| 40 | `int row = (int) Math.round((y - MARGIN) / (double) CELL_SIZE);` | 以相同方式将像素 y 转为最近的行号。 |
| 41 | `if (!board.isInside(row, col)) {` | 若换算出的行列不在棋盘范围内，就拒绝本次点击。 |
| 42 | `return null;` | 用 null 表示没有有效交叉点。 |
| 43 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 45 | `int dx = x - screenX(col);` | 计算点击位置与最近交叉点之间的水平距离 dx。 |
| 46 | `int dy = y - screenY(row);` | 计算点击位置与最近交叉点之间的垂直距离 dy。 |
| 47 | `if (dx * dx + dy * dy > HIT_RADIUS * HIT_RADIUS) {` | 通过 dx²+dy² 与半径²比较距离，避免开平方；大于阈值说明点击离交叉点太远。 |
| 48 | `return null;` | 距离太远，返回 null。 |
| 49 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 50 | `return new Point(col, row);` | 返回 Point(col, row)：注意 Point 的 x 存列，y 存行。 |
| 51 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 53 | `public void showSelection(int row, int col) {` | 定义显示选中位置的方法；调用方传入行和列。 |
| 54 | `highlightedRow = row;` | 记录要高亮的行。 |
| 55 | `highlightedCol = col;` | 记录要高亮的列。 |
| 57 | `repaint();` | 请求 Swing 在合适时机重新绘制面板，paintComponent 会再次读取当前状态。 |
| 58 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 60 | `@Override` | 标记下面的方法覆盖 JPanel 的绘制方法。 |
| 61 | `protected void paintComponent(Graphics graphics) {` | Swing 需要重绘组件时会调用 paintComponent；graphics 是系统提供的绘图上下文。 |
| 62 | `super.paintComponent(graphics);` | 先调用父类绘制逻辑，通常会处理背景等，避免残留旧画面。 |
| 63 | `Graphics2D g = (Graphics2D) graphics.create();` | 复制绘图上下文并转成 Graphics2D，后续修改颜色、线宽等不直接污染原上下文。 |
| 64 | `g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);` | 开启图形抗锯齿，让线条和圆边缘更平滑。 |
| 65 | `drawBoard(g);` | 先绘制棋盘线、九宫和河界文字。 |
| 66 | `drawPieces(g);` | 再绘制棋子，保证棋子出现在棋盘线之上。 |
| 67 | `g.dispose();` | 释放通过 create() 得到的临时绘图上下文。 |
| 68 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 70 | `private void drawBoard(Graphics2D g) {` | 定义私有方法，使用传入的画笔绘制棋盘。 |
| 71 | `g.setColor(new Color(117, 83, 51));` | 设置后续绘制的颜色为棕色。 |
| 72 | `g.setStroke(new BasicStroke(1.5f));` | 设置线宽为 1.5 像素；f 表示这是 float 字面量。 |
| 74 | `for (int row = 0; row < Board.ROWS; row++) {` | 从第 0 行循环到第 9 行；row++ 表示每轮行号加 1。 |
| 75 | `drawGridLine(g, row, 0, row, Board.COLS - 1);` | 在当前行从第 0 列画到第 8 列，形成一条横线。 |
| 76 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 77 | `for (int col = 0; col < Board.COLS; col++) {` | 从第 0 列循环到第 8 列，准备绘制竖线。 |
| 78 | `if (col == 0 \|\| col == Board.COLS - 1) {` | 判断当前列是不是棋盘最左或最右边界。 |
| 79 | `drawGridLine(g, 0, col, Board.ROWS - 1, col);` | 边界竖线从第 0 行一直画到第 9 行，穿过河界。 |
| 80 | `} else {` | 否则处理中间的竖线。 |
| 81 | `drawGridLine(g, 0, col, 4, col);` | 先画上半部分，从第 0 行到第 4 行。 |
| 82 | `drawGridLine(g, 5, col, Board.ROWS - 1, col);` | 再画下半部分，从第 5 行到第 9 行；第 4、5 行之间留出河界。 |
| 83 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 84 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 86 | `// 上下九宫各有两条对角线。` | 原代码注释，仅供阅读：上下九宫各有两条对角线。。 |
| 87 | `drawGridLine(g, 0, 3, 2, 5);` | 画上方九宫的一条斜线，从 (0,3) 到 (2,5)。 |
| 88 | `drawGridLine(g, 0, 5, 2, 3);` | 画上方九宫的另一条斜线，从 (0,5) 到 (2,3)。 |
| 89 | `drawGridLine(g, 7, 3, 9, 5);` | 画下方九宫的一条斜线，从 (7,3) 到 (9,5)。 |
| 90 | `drawGridLine(g, 7, 5, 9, 3);` | 画下方九宫的另一条斜线，从 (7,5) 到 (9,3)。 |
| 92 | `g.setFont(new Font(Font.SERIF, Font.BOLD, 23));` | 选择衬线字体、粗体、字号 23；实际中文字体由系统字体支持情况决定。 |
| 93 | `int riverY = (screenY(4) + screenY(5)) / 2;` | 求第 4、5 行像素 y 坐标的中点，作为河界文字的中心高度。 |
| 94 | `drawCenteredText(g, "楚 河", screenX(2), riverY);` | 在第 2 列附近、河界中心高度绘制“楚 河”。 |
| 95 | `drawCenteredText(g, "汉 界", screenX(6), riverY);` | 在第 6 列附近、河界中心高度绘制“汉 界”。 |
| 96 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 98 | `private void drawPieces(Graphics2D g) {` | 定义遍历棋盘并绘制棋子的方法。 |
| 99 | `for (int row = 0; row < Board.ROWS; row++) {` | 外层循环依次遍历所有行。 |
| 100 | `for (int col = 0; col < Board.COLS; col++) {` | 内层循环依次遍历该行的所有列，因此总共检查 10×9 个交叉点。 |
| 101 | `Piece piece = board.getPieceAt(row, col);` | 取得当前位置的棋子；可能是 null。 |
| 102 | `if (piece == null) {` | 判断当前位置有没有棋子。 |
| 103 | `continue;` | 如果没有，跳过本次内层循环，继续检查下一列。 |
| 104 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 106 | `int x = screenX(col);` | 把棋子的列号转换为面板内的像素横坐标。 |
| 107 | `int y = screenY(row);` | 把棋子的行号转换为面板内的像素纵坐标。 |
| 108 | `if (row == highlightedRow && col == highlightedCol) {` | 若当前位置等于高亮位置，就先画选中圈。 |
| 109 | `g.setColor(new Color(31, 120, 119));` | 把选中圈颜色设置为青绿色。 |
| 110 | `g.setStroke(new BasicStroke(3));` | 把选中圈线宽设为 3 像素。 |
| 111 | `int radius = PIECE_RADIUS + 5;` | 选中圈半径比棋子半径大 5 像素。 |
| 112 | `g.drawOval(x - radius, y - radius, radius * 2, radius * 2);` | 按圆的外接正方形左上角和宽高画空心圆；中心是 (x,y)。 |
| 113 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 115 | `g.setColor(new Color(255, 248, 228));` | 为棋子填充选择浅色。 |
| 116 | `g.fillOval(x - PIECE_RADIUS, y - PIECE_RADIUS, PIECE_RADIUS * 2, PIECE_RADIUS * 2);` | 以 (x,y) 为中心绘制实心圆；fillOval 接收的是外接矩形的左上角和宽高。 |
| 117 | `g.setColor(new Color(120, 79, 45));` | 把棋子边框颜色设为棕色。 |
| 118 | `g.setStroke(new BasicStroke(2));` | 把棋子边框线宽设为 2 像素。 |
| 119 | `g.drawOval(x - PIECE_RADIUS, y - PIECE_RADIUS, PIECE_RADIUS * 2, PIECE_RADIUS * 2);` | 在刚才填充的圆周上绘制棋子边框。 |
| 120 | `g.setColor(piece.isRed() ? new Color(177, 43, 39) : new Color(43, 43, 43));` | 三元表达式：如果 piece.isRed() 为 true 使用红色，否则使用深色，作为棋子文字颜色。 |
| 121 | `g.setFont(new Font(Font.SERIF, Font.BOLD, 28));` | 设置棋子文字为衬线字体、粗体、字号 28。 |
| 122 | `drawCenteredText(g, piece.getName(), x, y);` | 读取棋子名称，并以棋子圆心为中心绘制文字。 |
| 123 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 124 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 125 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 127 | `private void drawGridLine(Graphics2D g, int fromRow, int fromCol, int toRow, int toCol) {` | 定义画棋盘线的辅助方法，接收起点、终点的行列。 |
| 128 | `g.drawLine(screenX(fromCol), screenY(fromRow), screenX(toCol), screenY(toRow));` | 先把起终点的列、行分别转换为 x、y，再调用 Graphics2D.drawLine 画直线。 |
| 129 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 131 | `private void drawCenteredText(Graphics2D g, String text, int x, int y) {` | 定义居中绘制文字的辅助方法，x、y 是希望文字居中的位置。 |
| 132 | `FontMetrics metrics = g.getFontMetrics();` | 读取当前字体的度量信息，如字符串宽度、上升高度和下降高度。 |
| 133 | `int baseline = y + (metrics.getAscent() - metrics.getDescent()) / 2;` | 根据字体的上升高度和下降高度估算绘字基线，使文字大致竖直居中。 |
| 134 | `g.drawString(text, x - metrics.stringWidth(text) / 2, baseline);` | 减去字符串宽度的一半以水平居中，然后按计算出的基线绘制文字。 |
| 135 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 137 | `private int screenX(int col) {` | 定义列号到水平像素坐标的换算方法。 |
| 138 | `return MARGIN + col * CELL_SIZE;` | 水平坐标 = 左边距 + 列号 × 交叉点间距。 |
| 139 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 141 | `private int screenY(int row) {` | 定义行号到垂直像素坐标的换算方法。 |
| 142 | `return MARGIN + row * CELL_SIZE;` | 垂直坐标 = 上边距 + 行号 × 交叉点间距。 |
| 143 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 144 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |

### ChessController.java：鼠标点击和选择

[打开原文件](XiangQi/src/main/java/edu/sustech/xiangqi/controller/ChessController.java)

| 行号 | 原代码 | 解释 |
| ---: | --- | --- |
| 1 | `package edu.sustech.xiangqi.controller;` | 声明类属于 controller 包。 |
| 3 | `import edu.sustech.xiangqi.model.Board;` | 引入棋盘数据类 Board。 |
| 4 | `import edu.sustech.xiangqi.model.Piece;` | 引入棋子类型 Piece。 |
| 5 | `import edu.sustech.xiangqi.view.BoardPanel;` | 引入显示棋盘的 BoardPanel。 |
| 7 | `import javax.swing.SwingUtilities;` | 引入 SwingUtilities，后面用来判断鼠标左键。 |
| 8 | `import java.awt.Point;` | 引入 Point，用于接收行列位置。 |
| 9 | `import java.awt.event.MouseAdapter;` | 引入 MouseAdapter，它提供鼠标监听方法的默认空实现。 |
| 10 | `import java.awt.event.MouseEvent;` | 引入 MouseEvent，表示一次鼠标事件。 |
| 12 | `// 处理点击和选中状态` | 原代码注释，仅供阅读：处理点击和选中状态。 |
| 13 | `public class ChessController extends MouseAdapter {` | 控制器继承 MouseAdapter，因此只需要覆盖自己关心的鼠标事件方法。 |
| 14 | `private final Board board;` | 保存棋盘数据引用，用于查棋子和尝试移动。 |
| 15 | `private final BoardPanel boardPanel;` | 保存面板引用，用于换算位置和显示选中效果。 |
| 17 | `// 默认 -1 没有选中任何棋子` | 原代码注释，仅供阅读：默认 -1 没有选中任何棋子。 |
| 18 | `private int selectedRow = -1;` | 选中行初始设为 -1，表示没有选中棋子。 |
| 19 | `private int selectedCol = -1;` | 选中列也初始设为 -1。 |
| 21 | `public ChessController(Board board, BoardPanel boardPanel) {` | 构造控制器，接收同一局游戏的棋盘和面板。 |
| 22 | `this.board = board;` | 保存传入的棋盘对象。 |
| 23 | `this.boardPanel = boardPanel;` | 保存传入的棋盘面板。 |
| 24 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 26 | `@Override` | 说明下面的方法覆盖 MouseAdapter 中同名方法。 |
| 27 | `public void mouseClicked(MouseEvent event) {` | 面板收到点击事件后，Swing 会调用这个方法并传入事件对象。 |
| 28 | `if (!SwingUtilities.isLeftMouseButton(event)) {` | 如果事件不是鼠标左键点击，则进入分支。 |
| 29 | `return;` | 忽略非左键事件并立即结束本次处理。 |
| 30 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 32 | `Point position = boardPanel.getIntersectionAt(event.getX(), event.getY());` | 读取事件在面板内的像素坐标，调用面板方法转换成棋盘交叉点；结果可能为 null。 |
| 33 | `if (position != null) {` | 只有点到有效交叉点时才继续处理。 |
| 34 | `handleClick(position.y, position.x);` | Point 的 y 是行、x 是列，因此按 handleClick 的参数顺序传入 position.y、position.x。 |
| 35 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 36 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 38 | `private void handleClick(int row, int col) {` | 定义具体点击处理方法，参数是有效棋盘行、列。 |
| 39 | `if (row == selectedRow && col == selectedCol) {` | 如果再次点击当前选中的同一格，就执行取消选择。 |
| 40 | `clearSelection();` | 清除选中状态并请求面板更新。 |
| 41 | `return;` | 本次点击已经处理，立即退出。 |
| 42 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 44 | `Piece clickedPiece = board.getPieceAt(row, col);` | 读取本次点击位置上的棋子，可能为空。 |
| 45 | `if (selectedRow == -1) {` | 如果尚未选择任何棋子，进入首次选择流程。 |
| 46 | `if (clickedPiece != null) {` | 只有点到棋子时才选择；点到空格不会产生选择。 |
| 47 | `select(row, col);` | 记录这枚棋子的位置并显示高亮。 |
| 48 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 49 | `return;` | 首次点击处理完成后直接返回，避免把同一次点击当作落点。 |
| 50 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 52 | `// 点击另一枚己方棋子时切换选择` | 原代码注释，仅供阅读：点击另一枚己方棋子时切换选择。 |
| 53 | `Piece selectedPiece = board.getPieceAt(selectedRow, selectedCol);` | 读取先前选中位置的棋子。 |
| 54 | `if (clickedPiece != null && selectedPiece != null` | 先确认本次位置和先前选中位置都有棋子；&& 会在前面为 false 时短路。 |
| 55 | `&& clickedPiece.isRed() == selectedPiece.isRed()) {` | 再比较两枚棋子的颜色；相同则进入分支。当前示例只创建了红棋。 |
| 56 | `select(row, col);` | 将选中对象切换为刚点的同色棋子。 |
| 57 | `return;` | 切换选择完成，直接结束，不尝试移动。 |
| 58 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 60 | `// 移动失败时保留选择，用户可以继续选择其他落点` | 原代码注释，仅供阅读：移动失败时保留选择，用户可以继续选择其他落点。 |
| 61 | `if (board.tryMove(selectedRow, selectedCol, row, col)) {` | 否则把原选中位置和新位置交给 Board.tryMove；只有它返回 true 才进入条件块。 |
| 62 | `clearSelection();` | 移动成功后取消选中；clearSelection 会触发重绘。失败时不执行这里，因此原选择保留。 |
| 63 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 64 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 66 | `private void select(int row, int col) {` | 定义选中指定位置的辅助方法。 |
| 67 | `selectedRow = row;` | 记录选中棋子的行。 |
| 68 | `selectedCol = col;` | 记录选中棋子的列。 |
| 69 | `boardPanel.showSelection(row, col);` | 通知面板显示该位置的高亮并请求重绘。 |
| 70 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 72 | `private void clearSelection() {` | 定义清除选中状态的辅助方法。 |
| 73 | `selectedRow = -1;` | 把选中行恢复为无效值 -1。 |
| 74 | `selectedCol = -1;` | 把选中列也恢复为 -1。 |
| 75 | `boardPanel.showSelection(-1, -1);` | 让面板把高亮位置设为 (-1,-1) 并重绘；不会有有效棋子匹配这个位置。 |
| 76 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 77 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |

### start.bat：Windows 启动入口

[打开原文件](scripts/start.bat)

| 行号 | 原代码 | 解释 |
| ---: | --- | --- |
| 1 | `@echo off` | 关闭批处理命令本身的回显；前面的 @ 让这一行自己也不显示。 |
| 2 | `powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0build.ps1" run` | 启动 Windows PowerShell，跳过配置文件，并对这次进程使用 Bypass 策略运行同目录的 build.ps1，传入 run；%~dp0 是本 bat 所在目录。 |
| 3 | `set "exitCode=%errorlevel%"` | 把上一条命令的退出码保存到 exitCode；0 通常表示成功，非 0 表示失败。 |
| 4 | `if not "%exitCode%"=="0" pause` | 退出码不是 0 时暂停窗口，方便看到错误信息。 |
| 5 | `exit /b %exitCode%` | 结束当前批处理并返回先前保存的退出码。 |

### build.ps1：编译、运行和测试脚本

[打开原文件](scripts/build.ps1)

| 行号 | 原代码 | 解释 |
| ---: | --- | --- |
| 1 | `param([ValidateSet('run', 'test', 'build')][string]$Mode = 'build')` | 声明字符串参数 Mode，只接受 run、test、build，未传参时默认为 build。 |
| 3 | `$ErrorActionPreference = 'Stop'` | 遇到 PowerShell 非终止错误时按终止错误处理；外部程序退出码仍需另外检查。 |
| 4 | `Set-Location (Join-Path $PSScriptRoot '..')` | 以脚本所在目录的上一级作为当前目录，使后面的相对路径不依赖从哪里启动。 |
| 5 | `if (-not (Get-Command javac -ErrorAction SilentlyContinue)) {` | 检查是否能找到 javac 命令；-not 表示找不到时进入分支，SilentlyContinue 抑制查询时的报错。 |
| 6 | `throw 'JDK 17 or newer is required. Install a JDK and add it to PATH.'` | 抛出提示并停止脚本。这里检查的是 javac 是否存在，不直接检查其版本；编译阶段还会使用 --release 17。 |
| 7 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 8 | `$mainDir = Join-Path (Get-Location) 'build/classes'` | 把编译结果目录设为项目目录下的 build/classes。 |
| 9 | `New-Item -ItemType Directory -Force -Path $mainDir \| Out-Null` | 创建结果目录；-Force 允许目录已存在，Out-Null 隐藏创建命令的输出。 |
| 10 | `$sources = @(Get-ChildItem 'XiangQi/src/main/java' -Filter '*.java' -Recurse \| ForEach-Object { $_.FullName })` | 递归搜集 XiangQi/src/main/java 下的 .java 文件，取每个完整路径；@(...) 保证结果按数组处理。 |
| 11 | `& javac -encoding UTF-8 --release 17 -d $mainDir $sources` | 使用 javac 编译：源码编码 UTF-8、面向 Java 17、输出到 mainDir，最后传入全部源文件路径。 |
| 12 | `if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }` | 如果编译进程退出码不为 0，脚本以该退出码结束，不再运行后续程序。 |
| 14 | `if ($Mode -eq 'test') {` | 如果参数是 test，进入测试分支。注意当前项目中没有对应的测试源码目录和 ProjectTests 类，此分支目前无法完成测试。 |
| 15 | `$testDir = Join-Path (Get-Location) 'build/test-classes'` | 定义测试 class 文件输出目录。 |
| 16 | `New-Item -ItemType Directory -Force -Path $testDir \| Out-Null` | 创建测试输出目录并隐藏创建信息。 |
| 17 | `$tests = @(Get-ChildItem 'XiangQi/src/test/java' -Filter '*.java' -Recurse \| ForEach-Object { $_.FullName })` | 尝试递归搜集测试源码；当前项目不存在该目录，因此执行 test 时会在此报错。 |
| 18 | `& javac -encoding UTF-8 --release 17 -cp $mainDir -d $testDir $tests` | 如果存在测试源码，则以主程序 class 目录为类路径，编译测试源码到 testDir。 |
| 19 | `if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }` | 如果测试代码编译失败，返回该失败码。 |
| 20 | `& java -cp "$mainDir;$testDir" edu.sustech.xiangqi.model.ProjectTests` | 用主程序和测试输出目录组成 Windows 类路径，并尝试运行名为 ProjectTests 的测试入口。 |
| 21 | `exit $LASTEXITCODE` | 以测试进程的退出码结束脚本。 |
| 22 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 23 | `if ($Mode -eq 'run') {` | 如果参数是 run，进入运行分支；start.bat 传入的就是这个值。 |
| 24 | `& java -cp $mainDir edu.sustech.xiangqi.Main` | 调用 java，指定编译输出目录为类路径，运行 Main 的完整类名。窗口关闭后该进程才通常结束。 |
| 25 | `exit $LASTEXITCODE` | 以 Java 进程的退出码结束脚本。 |
| 26 | `}` | 结束前面最近的代码块，例如一个判断、循环、方法或类。 |
| 27 | `Write-Host 'Build succeeded.'` | 若只执行 build 且前面都成功，打印 Build succeeded。 |

### pom.xml：Maven 项目配置

[打开原文件](pom.xml)

| 行号 | 原代码 | 解释 |
| ---: | --- | --- |
| 1 | `<?xml version="1.0" encoding="UTF-8"?>` | XML 文件声明：使用 XML 1.0，文本编码为 UTF-8。 |
| 2 | `<project xmlns="http://maven.apache.org/POM/4.0.0"` | 开始 Maven 的 project 根元素，并声明默认 XML 命名空间。 |
| 3 | `xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"` | 声明 xsi 命名空间前缀，供下一行标记 schema 信息。 |
| 4 | `xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">` | 指定 Maven POM 所使用的 XML 结构描述文件位置，并结束 project 开始标签。 |
| 5 | `<modelVersion>4.0.0</modelVersion>` | 声明 POM 模型版本，通常是 4.0.0。 |
| 6 | `<groupId>edu.sustech</groupId>` | groupId 是项目组织或命名空间标识，这里是 edu.sustech。 |
| 7 | `<artifactId>xiangqi</artifactId>` | artifactId 是项目名称标识，这里是 xiangqi。 |
| 8 | `<version>1.0.0</version>` | 项目自身版本是 1.0.0，与下面编译插件版本是不同的概念。 |
| 9 | `<properties>` | 开始定义 Maven 属性。 |
| 10 | `<maven.compiler.release>17</maven.compiler.release>` | 设置 Maven 编译目标为 Java 17。 |
| 11 | `<project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>` | 声明项目源文件编码是 UTF-8。 |
| 12 | `</properties>` | 结束 properties 属性块。 |
| 13 | `<build>` | 开始构建配置。 |
| 14 | `<plugins>` | 开始插件列表。 |
| 15 | `<plugin>` | 开始一个插件配置。 |
| 16 | `<groupId>org.apache.maven.plugins</groupId>` | 指定该插件所属的 Maven 插件组织。 |
| 17 | `<artifactId>maven-compiler-plugin</artifactId>` | 指定使用 Maven 的 Java 编译插件。 |
| 18 | `<version>3.13.0</version>` | 指定这个插件的版本是 3.13.0。 |
| 19 | `</plugin>` | 结束当前插件配置。 |
| 20 | `</plugins>` | 结束插件列表。 |
| 21 | `</build>` | 结束构建配置。 |
| 22 | `</project>` | 结束 project 根元素。 |

## 关于当前项目配置

- 双击启动使用的是 `start.bat → build.ps1`，它会先编译现有 Java 源码，再运行 Main。电脑需要可用的 JDK；当前脚本使用 `--release 17`。
- `build.ps1 test` 引用了目前项目中不存在的测试目录和 `ProjectTests`，所以现在不能把该分支当作已配置好的测试。
- `pom.xml` 位于外层 XiangQi 文件夹，而 Java 源码在里面的 `XiangQi/src/main/java`。这个 POM 没有设置自定义源码目录，Maven 默认会寻找外层的 `src/main/java`；因此不能仅凭这个 POM 认为 Maven 会编译到当前源码。
