# Simple test file with for loops
if True:
    print("Hello World")

# For loop with single argument in range
for i in range(5):
    print("Counting up")

# For loop with start and end values
for j in range(1, 10):
    print("Counting from 1 to 9")

# For loop with variable
x = 10
for k in range(x):
    print("Dynamic range")

# For loop with expressions
for m in range(2 * 3):
    print("Expression in range")

# Nested for loops
for a in range(3):
    for b in range(2):
        print("Nested loops")

# Function with a for loop
def count_to(n):
    for i in range(n):
        print("Counting in function")

# Call the function
count_to(5)