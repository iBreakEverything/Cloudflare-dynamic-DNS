import os
import re

SCRIPT_FILE = 'cloudflare-template-ipv4.sh'

PREFIX = 'cloudflare'
SUFFIX = 'ipv4.sh'

modes = ['crontab', 'user']
shells = ['bash'] #sh not yet ready

def main():
  with open(SCRIPT_FILE, 'r', encoding='utf8') as f:
    script = f.read()

  for mode in modes:
    for shell in shells:
      # Make filename
      filename = '-'.join([PREFIX, mode, shell, SUFFIX])
      # Set shell
      content = script.replace('#SHELL', f'#!/bin/{shell}')
      
      if mode == 'crontab': 
        # Remove debug lines
        content = '\n'.join([x for x in content.split('\n') if not x.endswith('#DEBUG')])
      elif mode == 'user':
        # Remove debug comments, convert logger to echo
        content = content.replace(' #DEBUG', '')
        content = content.replace('logger ', 'echo ')

      with open(filename, 'w', encoding='utf8') as f:
        f.write(content)

main()
