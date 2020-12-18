import random

# Encode a list of 64-bit numbers as hexadecimal.
def encode_hex(nums):
    max = 1 << 64
    parts = []
    for n in nums:
        assert 0 <= n < max
        parts.append(hex(n + max)[3:])
    return "".join(parts)

# Return a list of random 64-bit numbers of a given length.
def gen_nums(length):
    return [random.getrandbits(64) for _ in range(length)]

length = int(input("Number of u64s: "))
nums = gen_nums(length)

print("As array:", nums)
print("As hex:  ", encode_hex(nums))
