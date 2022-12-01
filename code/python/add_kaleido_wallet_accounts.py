import os
from sys import argv
import requests
from dotenv import load_dotenv


load_dotenv()
USERNAME = os.environ.get("KALEIDO_API_USERNAME")
PASSWORD = os.environ.get("KALEIDO_API_PASSWORD")
KALEIDO_WALLET_ENDPOINT = \
    f'https://{USERNAME}:{PASSWORD}@u0e8jf3exo-u0r55violj-ethwallet.us0-aws.kaleido.io/'
KALEIDO_WALLET_API_ENDPOINT = KALEIDO_WALLET_ENDPOINT + 'api/v1/'


if __name__ == '__main__':
    accounts_to_add = int(argv[1])

    for _ in range(accounts_to_add):
        NEW_ACCOUNT_ENDPOINT = KALEIDO_WALLET_API_ENDPOINT + 'accounts'
        response = requests.post(NEW_ACCOUNT_ENDPOINT)

        if response.ok:
            new_account = response.json()['result']['address']
            print(new_account)
        else:
            print(response.status_code)
            print(response.text)

