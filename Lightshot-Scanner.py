import cloudscraper
import requests
import random
import re
import json
import time

hookurl = "YOUR_WEBHOOK_HERE"

print("Starting Image URL Scanner..")

def get_random_sc(length):
    characters = 'abcdefghijklmnopqrstuvwxyz'
    random_string = ''.join(random.choice(characters) for _ in range(length))
    return random_string

def webhook_send_message(new_url, image_url):
    # Define the body of the message and convert it to JSON
    body = {
        "username": "Lightshot-BOT",
        "content": f"Found an Image : {new_url}\nDownload Link : {image_url}"
    }
    # Use requests to send the message to Discord
    requests.post(hookurl, json=body)

def check_image_exists(image_url):
    try:
        scraper = cloudscraper.create_scraper()
        response = scraper.head(image_url)
        return response.status_code == 200
    except Exception as e:
        print("Error checking image URL:", e)
        return False

while True:
    # prnt.sc link checker
    url = "https://prnt.sc/"
    ext = 6
    random_string = get_random_sc(ext)
    new_url = url + random_string
    
    # Use cloudscraper to fetch HTML content and bypass Cloudflare
    scraper = cloudscraper.create_scraper()
    html_content = scraper.get(new_url).text

    # Use regex to find the image URL in the HTML content
    image_url_match = re.search(r'https://image\.prntscr\.com/image/[^\s"]+', html_content)

    if image_url_match:
        image_url = image_url_match.group(0)
        if check_image_exists(image_url):
            print("Found image URL:", image_url)
            if hookurl:
                print("Uploading", image_url)
                webhook_send_message(new_url, image_url)
                time.sleep(5)
        else:
            print("Image URL does not exist:", image_url)
    else:
        print("Image URL not found in HTML content.")

    time.sleep(1)

