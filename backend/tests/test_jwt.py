import sys
import os

user_site = os.path.expanduser('~/.local/lib/python3.14/site-packages')
if user_site not in sys.path:
    sys.path.insert(0, user_site)

import jwt
print("PyJWT imported successfully!")
