import os
for it in os.listdir("test_data"):
    os.system(f"cat test_data/{it} | ./parser >> execution_result/{it}.asm")
