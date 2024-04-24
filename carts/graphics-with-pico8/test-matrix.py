# import numpy as np

# # Define two 3x3 matrices for testing
# matrix1 = np.array([
# 	[1, 2, 3],
# 	[4, 5, 6],
# 	[7, 8, 9]
# ])

# matrix2 = np.array([
# 	[10, 11, 12],
# 	[13, 14, 15],
# 	[16, 17, 18]
# ])

# # Perform matrix multiplication
# result = np.matmul(matrix1, matrix2)

# print(result)

import numpy as np

def test_vecmul():
    matrix = np.array([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
    vector = np.array([1, 2, 3])
    expected_result = np.array([14, 32, 50])
    result = np.matmul(matrix, vector)
    assert np.array_equal(result, expected_result), "Test failed: result is not correct"
    print("Test passed: vecmul function works correctly")

test_vecmul()