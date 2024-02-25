import requests
import os
import concurrent.futures
import threading
import time
import getpass

def test_url(url):
    if not url.startswith("http://") and not url.startswith("https://"):
        url = "https://" + url
    try:
        response = requests.head(url, allow_redirects=True)
        return response.status_code
    except requests.exceptions.RequestException as e:
        if hasattr(e, 'response') and e.response is not None:
            return e.response.status_code
        else:
            return None

def test_urls(base_url, extensions, progress_callback):
    with open("loot.txt", "a") as loot_file:
        total_items = len(extensions)
        for i, extension in enumerate(extensions, 1):
            extension = extension.strip()
            url = base_url + extension
            status_code = test_url(url)
            if status_code == 200:
                loot_file.write(url + "\n")
                loot_file.flush()
            progress_callback(i, total_items)

def track_progress(progress_dict):
    with track_progress.lock:
        os.system('cls' if os.name == 'nt' else 'clear')
        print(f"Testing URLs - Progress: {progress_dict['percent']}% complete")

track_progress.lock = threading.Lock()

def main():
    os.system('cls' if os.name == 'nt' else 'clear')
    print("URL Fuzzer")
    print("Enter the website you want to fuzz:")
    base_url = input().strip()
    base_url += "/" if not base_url.endswith("/") else ""
    print(f"URL set to https://{base_url}")
    max_threads = int(input("Enter maximum thread count: "))
    word_list = input("Enter name of wordlist file: ")

    uptest = test_url(base_url)

    if uptest == 200:
        print("Site is up!")
    else:
        print("Site is down.. exiting")
        input("Press Enter to exit")
        exit()

    with open(word_list, "r") as f:
        extensions = f.readlines()

    total_items = len(extensions)
    num_threads = min(max_threads, total_items)

    chunk_size = (total_items + num_threads - 1) // num_threads
    chunks = [extensions[i:i + chunk_size] for i in range(0, total_items, chunk_size)]

    progress_dict = {'percent': 0}

    def update_progress(current, total):
        progress_dict['percent'] = int(current / total * 100)

    with concurrent.futures.ThreadPoolExecutor(max_workers=num_threads) as executor:
        futures = [executor.submit(test_urls, base_url, chunk, update_progress) for chunk in chunks]
        while not all(future.done() for future in futures):
            track_progress(progress_dict)
            time.sleep(1)

if __name__ == "__main__":
    main()
