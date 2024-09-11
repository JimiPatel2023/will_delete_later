import requests

class DiscordAPIRequest:
    def message_discord(self, content):
        with open('DiscordCredentials.txt', 'r') as file:
            lines = file.readlines()

        BOT_TOKEN = lines[0].split("=")[1].strip()
        CHANNEL_ID = lines[1].split("=")[1].strip()

        url = f"https://discord.com/api/v9/channels/{CHANNEL_ID}/messages"
        headers = {
            "Authorization": f"Bot {BOT_TOKEN}",
            "Content-Type": "application/json"
        }
        data = {
            "content": content
        }

        response = requests.post(url, headers=headers, json=data)
        print(response.status_code)
        print(response.json())
