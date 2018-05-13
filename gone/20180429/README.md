# 生成合法mac地址
```python
import random
print('%02x:%02x:%02x:%02x:%02x:%02x' % (
    random.randint(0x00, 0x7f) // 2 * 2,
    random.randint(0x00, 0x7f),
    random.randint(0x00, 0x7f),
    random.randint(0x00, 0x7f),
    random.randint(0x00, 0x7f),
    random.randint(0x00, 0x7f),
))
```