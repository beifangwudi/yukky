# 暴力回溯数独
[看到](http://tieba.baidu.com/p/4010650539)这个数独,听说是世界最难数独,一看解法完全不懂,只好暴力跑一遍,理论上适用于任何标准数独.
```python
#!/usr/bin/python3
# -*- coding:utf-8 -*-
s = '8..........36......7..9.2...5...7.......457.....1...3...1....68..85...1..9....4..'
sudoku = [0 if i in ['.', '0'] else int(i) for i in s]

# 找出所有可能值
sudoku_possible = list(
    map(lambda x: list(range(1, 10)) if x == 0 else x, sudoku))
for i, v in enumerate(sudoku):
    if v == 0:
        for ii, vv in enumerate(sudoku):
            if vv > 0:
                if ii % 9 == i % 9 or ii // 9 == i // 9 or (
                    (ii % 9) // 3 == (i % 9) // 3 and ii // 27 == i // 27):
                    try:
                        sudoku_possible[i].remove(vv)
                    except:
                        pass
# 参与回溯的节点
sudoku_trace = [[i, v, 0] for i, v in enumerate(sudoku_possible)
                if isinstance(v, list)]
# 尝试优化,速度反而慢了,本题算特例,不优化只需1秒,优化完了需要6分钟
# sudoku_trace = sorted(
#     [[i, v, 0] for i, v in enumerate(sudoku_possible) if isinstance(v, list)],
#     key=lambda x: len(x[1]))
# 指向正在回溯的节点的指针
point = 0

while point >= 0:
    # 如果这个节点的所有值都不合适,则回退到上一个节点
    if sudoku_trace[point][2] == len(sudoku_trace[point][1]):
        sudoku_trace[point][2] = 0
        sudoku[sudoku_trace[point][0]] = 0
        point -= 1
        sudoku_trace[point][2] += 1
        continue

    # 尝试设置一个值,然后判断该节点是否正确
    sudoku[sudoku_trace[point][0]] = sudoku_trace[point][1][sudoku_trace[point]
                                                            [2]]
    if (sudoku[sudoku_trace[point][0] // 9 * 9:sudoku_trace[point][0] // 9 * 9
               + 9] + sudoku[sudoku_trace[point][0] % 9::9] +
            sudoku[sudoku_trace[point][0] // 27 * 27 + sudoku_trace[point][0] %
                   9 // 3 * 3:sudoku_trace[point][0] // 27 * 27 +
                   sudoku_trace[point][0] % 9 // 3 * 3 + 3] +
            sudoku[sudoku_trace[point][0] // 27 * 27 + sudoku_trace[point][0] %
                   9 // 3 * 3 + 9:sudoku_trace[point][0] // 27 * 27 +
                   sudoku_trace[point][0] % 9 // 3 * 3 + 12] +
            sudoku[sudoku_trace[point][0] // 27 * 27 + sudoku_trace[point][0] %
                   9 // 3 * 3 + 18:sudoku_trace[point][0] // 27 * 27 +
                   sudoku_trace[point][0] % 9 // 3 * 3 + 21]).count(
                       sudoku[sudoku_trace[point][0]]) != 3:
        # 上面这一串就是横竖和九宫的所有值,懒得简化了
        # 如果出现了3遍以上,说明错误,再试下一个值
        sudoku_trace[point][2] += 1
    else:
        # 否则正确,指针指向下一个节点
        point += 1
        if point == len(sudoku_trace):
            print(''.join(map(str, sudoku)))
            exit()

print('unsolvable')
```