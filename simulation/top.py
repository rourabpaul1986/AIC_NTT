import argparse
import subprocess
import threading

def run_script(script, args_list):
    """Run a python script with the provided argument list."""
    cmd = ["python3", script] + args_list
    print(f"[INFO] Running: {' '.join(cmd)}")
    subprocess.run(cmd)

def main():
    parser = argparse.ArgumentParser()

    parser.add_argument("-s", "--size", required=True)
    parser.add_argument("-f", "--fault", required=True)
    parser.add_argument("-a", "--application", required=True)
    parser.add_argument("-i", "--injection", required=True)
    parser.add_argument("-m", "--mode", required=True)
    parser.add_argument("-c", "--chunk", required=True)

    args = parser.parse_args()

    # Forward arguments as string list
    forwarded_args = [
        "-s", args.size,
        "-f", args.fault,
        "-a", args.application,
        "-i", args.injection,
        "-m", args.mode,
        "-c", args.chunk
    ]

    # Create worker threads
    t1 = threading.Thread(target=run_script,
                          args=("partial_AIC_NTT.py", forwarded_args))
    t2 = threading.Thread(target=run_script,
                          args=("full_AIC_NTT.py", forwarded_args))

    # Start both in parallel
    t1.start()
    t2.start()

    # Wait for both to finish
    t1.join()
    t2.join()

    print("[INFO] Both scripts finished.")

if __name__ == "__main__":
    main()

